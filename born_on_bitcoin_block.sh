target_time=1234567890
current_block=0

clear
echo "Starting the script ..."
blockchain_info=$(~/bitcoin/bin/bitcoin-cli getblockchaininfo)
block_count=$(echo $blockchain_info | jq '.blocks')

current_block_hash=$(~/bitcoin/bin/bitcoin-cli getblockhash $current_block)
current_block_time=0

$(echo $blockchain_info | jq '.initialblockdownload') && echo -e "ALERT: Bitcoin Core is still performing the \"initial block download\".\nALERT: This script will only search up to block height $block_count.\nALERT: Strongly recommend you wait for the chain to fully sync."

while [ $current_block -le $block_count ] && [ $current_block_time -lt $target_time ]; do
  current_block_header=$(~/bitcoin/bin/bitcoin-cli getblockheader $current_block_hash)
  current_block_time=$(echo $current_block_header | jq -r '.time')

  echo --------
  echo "Checking block $current_block."
  echo "It was made at $current_block_time, or $(date -d @$current_block_time)."

  if [ $current_block_time -ge $target_time ]; then
    echo --------------------------------
    echo "Timestamp $target_time was born on block $current_block."
    echo "This block was made at $current_block_time, or $(date -d @$current_block_time)."
    echo "It contains $(echo $current_block_header | jq -r '.nTx') transactions."
    current_block_difficulty=$(echo $current_block_header | jq -r '.difficulty')
    echo "Its difficulty is ${current_block_difficulty%.*}."
    echo "Its hash is $current_block_hash."
  else
    if [ $current_block -eq $block_count ]; then
      echo "You were born in the future -_-"
    else
      current_block=$(($current_block+1))
      current_block_hash=$(echo $current_block_header | jq -r '.nextblockhash')
    fi
  fi
done
