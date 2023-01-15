#!/bin/bash

## Make sure either bitcoind or bitcoin-qt are running before starting this script.

## Stop the script if any commands error
set -e

## Set the Unix timestamp to target. (Default: 1234567890, or Fri Feb 13 2009 23:31:30)
target_time=1234567890

## Define the starting block for the search. (Default: 0)
current_block=0

clear
echo -e "Starting the script...\n\nThe target timestamp is $target_time.\nThe target timestamp is $(date -d @$target_time).\n"

echo -n "Connecting to Bitcoin Core... "
blockchain_info=$(bitcoin-cli getblockchaininfo)
header_count=$(echo $blockchain_info | jq '.headers')
echo "connected."

## Set the block has and block time based the current_block
echo -n "Finding the starting block's hash and time... "
current_block_hash=$(bitcoin-cli getblockhash $current_block)
current_block_time=$(bitcoin-cli getblockheader $current_block_hash | jq '.time')
echo "finished."

## Display an alert if the node is still performing its initial block download
$(echo $blockchain_info | jq '.initialblockdownload') && echo -e "\nALERT: Bitcoin Core is still performing the \"initial block download\".\nALERT: Please consider waiting for the entire blockchain to sync.\nALERT: This script will only search up to block height $header_count."

## Start the search
echo

while [ $current_block -le $header_count ] && [ $current_block_time -lt $target_time ]; do
  current_block_header=$(bitcoin-cli getblockheader $current_block_hash)
  current_block_time=$(echo $current_block_header | jq -r '.time')

  echo "Checking block $current_block, created $(date -d @$current_block_time)..."

  if [ $current_block_time -ge $target_time ]; then
    echo -e "\nSUCCESS: Found the target block."
    echo "Timestamp $target_time was born on block $current_block."
    echo "This block was made at $current_block_time, or $(date -d @$current_block_time)."
    
    ntx=$(echo $current_block_header | jq -r '.nTx')
    echo -n "This block contains $ntx transaction"
    [ $ntx -ne 1 ] && echo -n "s"
    echo "."
    
    echo "The hash is $current_block_hash."
    
    current_block_difficulty=$(echo $current_block_header | jq -r '.difficulty')
    echo "The difficulty is ${current_block_difficulty%.*}."

  else
    if [ $current_block -eq $header_count ]; then
      echo "FAILURE: You were born in the future -_-"
    else
      current_block=$(($current_block+1))
      current_block_hash=$(echo $current_block_header | jq -r '.nextblockhash')
    fi
  fi
done
