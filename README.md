# Born on Bitcoin Block

Without trusting third parties, find the next block that was mined after a target time.

Useful for determining what block a baby was born on, but the script has other use cases too.

*Note:* This current version is quite slow because it traverses the blockchain as a linked list, requiring a separate RPC call for each block.

*Todo:* Planning to significantly speed up execution in a future version useusing a binary search algoritm, requiring only a log-base-2 of the block count of RPC calls (about 20).

## Prerequisites

- [Ubuntu](https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview) or other Debian-based Linux distribution
  - Should work on macOS too, although more testing is needed.
  - If you can test a Windows PowerShell script, please contact me.
- [Bitcoin Core](https://github.com/bitcoin/bitcoin/releases) with a synced node
  - Recommend using version 22.0 or higher
- [jq](https://stedolan.github.io/jq/)
  - On Linux, install with `sudo apt install -y jq` or similar.
  - on macOS, install with `brew install jq`.

## How to Execute The Script

1. Save `born_on_bitcoin_block.sh` to your home directory or clone this repository.
2. Figure out your target Unix time. [Here's an online converter.](https://time.is/Unix_time_converter)
3. Update `target_time` on line 5 of the script to the Unix time for your target.
4. Update `bitcoin_cli_path` on line 7 to the path of your `bitcoin-cli` binary.
5. Execute the script in Terminal by running `~/born_on_bitcoin_block.sh`.
