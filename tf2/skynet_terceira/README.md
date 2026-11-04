# SKYNET Terceira Pessoa

**Team Fortress 2** · v1.0.0 · `skynet_terceira.smx`

[All plugins](../../README.md)

`!tp` to play in third person and `!fp` to go back.

## What it does
- `!tp` toggles the third-person camera (the same camera used by taunts).
- `!fp` goes back to first person.
- The choice stays after dying and respawning, until the player leaves the server.
- No `sv_cheats` needed.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_terceira` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_tp` / `!tp` (or `sm_thirdperson`) | everyone | Toggles third person |
| `sm_fp` / `!fp` (or `sm_firstperson`) | everyone | Goes back to first person |
