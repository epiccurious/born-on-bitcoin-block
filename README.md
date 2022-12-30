# Born on Bitcoin Block

Without trusting any third parties, find the block that was mined immediately after a target time.

Useful for determining what block a baby was born immediately before, but the script has other use cases too.

The current version is quite slow because it traverses the bitcoin blockchain as a linked list, requiring a separate RPC call for each block.

Planning a future version to use a binary search algorith to significantly speed up execution, requiring a log-base-2 of the block count number of RPC calls, which is currently ~20.

## Pre-requisites

- Ubuntu or other Debian-based Linux distribution
- Bitcoin Core with a synced node
- jq (`sudo apt install -y jq`)

## How to Execute The Script

1. Save `born_on_bitcoin_block.sh` to your home directory.
2. Figure out your target Unix time. [Here's an online converter.](https://time.is/Unix_time_converter)
3. Update `target_time` on line 1 of the script.
4. Figure out the path to your `bitcoin-cli` binary.
5. Update the path on lines 3, 6, and 10.
6. Execute the script in Terminal with `~/born_on_bitcoin_block.sh`.
