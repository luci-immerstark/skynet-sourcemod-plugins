# SKYNET Points Messages

**Left 4 Dead 2** · v1.0 · `skynet_points_msg_l4d2.smx`

[All plugins](../../README.md)

Portuguese messages for Points System earnings and purchases.

## What it does
- Shows every point gain with a translated reason and the balance: `[PONTOS] Matou Hunter +5 | Saldo: 120`.
- Shows purchases with item, cost and balance, and tells the player who received an item bought by someone else.
- To avoid duplicate messages, turn off Points System's own messages with `l4d2_points_notify 0`.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (Eyal282)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_points_msg_l4d2` in the console.
