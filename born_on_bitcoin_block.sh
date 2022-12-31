target_time=1234567890

block_count=$(~/bitcoin/bin/bitcoin-cli getblockcount)

current_block=0
current_block_hash=$(~/bitcoin/bin/bitcoin-cli getblockhash $current_block)
current_block_time=0

while [ $current_block -le $block_count ] && [ $current_block_time -lt $target_time ]; do
  current_block_header=$(~/bitcoin/bin/bitcoin-cli getblockheader $current_block_hash)
  current_block_time=$(echo $current_block_header | jq -r '.time')
  current_block_difficulty=$(echo $current_block_header | jq -r '.difficulty')

  echo "--------"
  echo "The current block is $current_block"
  echo "It was mined on $current_block_time, or $(date -d @$current_block_time)."
  echo "Its difficulty is ${current_block_difficulty%.*}."

  if [ $current_block_time -ge $target_time ]; then
    echo "-------- -------- --------"
    echo "You were born on block $current_block, mined on $(date -d @$current_block_time)."
    echo "The block hash is $current_block_hash"
    echo "The block difficulty is ${current_block_difficulty%.*}."
  else
    if [ $current_block -eq $block_count ]; then
      echo "You were born in the future -_-"
    else
      current_block=$(($current_block+1))
      current_block_hash=$(echo $current_block_header | jq -r '.nextblockhash')
    fi
  fi
done
