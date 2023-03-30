#!/bin/bash

### Make sure either bitcoind or bitcoin-qt are running before starting this script.

### Stop the script if any commands error
set -e

### Set the Unix timestamp to target. (Default: 1234567890, or Fri Feb 13 2009 23:31:30)
target_time=1234567890

### Define the starting block for the search. (Default: 0)

bitcoin_cli_path="${HOME}/bitcoin/bin/bitcoin-cli"

clear
echo -e "Starting the script...\n\nThe target timestamp is $target_time (local time is $(perl -le 'print scalar localtime $ARGV[0]' $target_time))."

echo -n "Connecting to Bitcoin Core... "
blockchain_info=$($bitcoin_cli_path getblockchaininfo)
echo "connected."

### Display an alert if the node is still performing its initial block download
$(echo $blockchain_info | jq '.initialblockdownload') && echo -e "\nALERT: Bitcoin Core is still performing the \"initial block download\".\nALERT: Please consider waiting for the entire blockchain to sync.\nALERT: This script will only search up to block height $block_count.\nPlease re-run this script after Bitcoin Core finished the initial block download process." && exit 1

### Save the hight 
block_count=$(echo $blockchain_info | jq '.blocks')

### Set the block has and block time based the current_block
echo -n "Finding block details... "

lowerbound_block=0
lowerbound_block_hash=$($bitcoin_cli_path getblockhash $lowerbound_block)
lowerbound_block_time=$($bitcoin_cli_path getblockheader $lowerbound_block_hash | jq '.time')
lowerbound_block_mediantime=$lowerbound_block_time
upperbound_block=$block_count
upperbound_block_hash=$($bitcoin_cli_path getblockhash $upperbound_block)
upperbound_block_header=$($bitcoin_cli_path getblockheader $upperbound_block_hash)
upperbound_block_time=$(echo $upperbound_block_header | jq '.time')
upperbound_block_mediantime=$(echo $upperbound_block_header | jq '.mediantime')
echo "finished."

[[ target_time -lt lowerbound_block_time ]] && echo "The target timestamp came before the genesis block." && exit 0
[[ target_time -gt upperbound_block_time ]] && echo "The target timestamp is in the future." && exit 0

### Start the binary search
echo -e "\nStarting the binary search."
binary_search_counter=0

while [ $((upperbound_block-lowerbound_block)) -gt 1  ]; do
  binary_search_counter=$(($binary_search_counter+1))
  midpoint_block=$(( ( $upperbound_block + $lowerbound_block ) / 2))
  midpoint_block_hash=$($bitcoin_cli_path getblockhash $midpoint_block)
  midpoint_block_mediantime=$($bitcoin_cli_path getblockheader $midpoint_block_hash | jq '.mediantime')

  echo "Searching for blocks between $lowerbound_block and $upperbound_block."

  [[ target_time -eq midpoint_block_mediantime ]] && lowerbound_block=$midpoint_block && lowerbound_block_mediantime=$midpoint_block_mediantime && upperbound_block=$midpoint_block && upperbound_block_mediantime=$midpoint_block_mediantime
  [[ target_time -gt midpoint_block_mediantime ]] && lowerbound_block=$midpoint_block && lowerbound_block_mediantime=$midpoint_block_mediantime
  [[ target_time -lt midpoint_block_mediantime ]] && upperbound_block=$midpoint_block && upperbound_block_mediantime=$midpoint_block_mediantime
done

echo "Found the mediantime between blocks $lowerbound_block and $upperbound_block."
#echo "The lowest block is:            $lowerbound_block"
#echo "The lowest block mediantime is: $lowerbound_block_mediantime."
#echo "The target time is:             $target_time."
#echo "The highest block is:           $upperbound_block."
#echo "The highest block mediantime is $upperbound_block_mediantime."


### Start the linear search
linear_search_buffer=9
current_block=$(($lowerbound_block-$linear_search_buffer))
current_block_hash=$($bitcoin_cli_path getblockhash $current_block)
current_block_header=$($bitcoin_cli_path getblockheader $current_block_hash)
current_block_time=$(echo $current_block_header | jq -r '.time')

echo -e "\nStarting the linear search at block $current_block."


while [ $current_block -le $block_count ] && [ $current_block_time -lt $target_time ]; do
  current_block_header=$($bitcoin_cli_path getblockheader $current_block_hash)
  current_block_time=$(echo $current_block_header | jq -r '.time')

  echo "Searching block $current_block, created $current_block_time. (Local time is $(perl -le 'print scalar localtime $ARGV[0]' $current_block_time).)"

  if [ $current_block_time -ge $target_time ]; then
    echo -e "\nSUCCESS: Found the target block."
    echo "Timestamp $target_time was born on block $current_block."
    echo "This block was made at $current_block_time, or $(perl -le 'print scalar localtime $ARGV[0]' $current_block_time)."

    ntx=$(echo $current_block_header | jq -r '.nTx')
    echo -n "This block contains $ntx transaction"
    [ $ntx -ne 1 ] && echo -n "s"
    echo "."

    echo "The hash is $current_block_hash."

    current_block_difficulty=$(echo $current_block_header | jq -r '.difficulty')
    echo "The difficulty is ${current_block_difficulty%.*}."

  else
    if [ $current_block -eq $block_count ]; then
      echo "FAILURE: You were born in the future -_-"
    else
      current_block=$(($current_block+1))
      current_block_hash=$(echo $current_block_header | jq -r '.nextblockhash')
    fi
  fi
done
