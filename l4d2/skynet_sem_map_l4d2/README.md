# SKYNET No !map / Sem !map

**Left 4 Dead 2** · v1.0 · `skynet_sem_map_l4d2.smx`

[All plugins](../../README.md)

Blocks `!map` and `!votemap` in game; campaign changes go through the admin menu.

## What it does
- `sm_map` changes level without the campaign intro and shows code names. The plugin blocks these commands for players and admins in game.
- The server console (rcon) can still use them.
- Pair it with **Next Campaign**, which adds campaign switching to the admin menu.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_sem_map_l4d2` in the console.
