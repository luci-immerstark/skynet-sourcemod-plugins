# SKYNET Taunts

**Team Fortress 2** · v1.0 · `skynet_taunts.smx`

[All plugins](../../README.md)

`!taunt` menu with every taunt in the game, even ones the player does not own.

## What it does
- Taunts for the player's class are listed first, then the all-class ones.
- Also accepts the taunt's item number (as listed in `configs/skynet_taunts.txt`): `!taunt <number>`.
- The list lives in `configs/skynet_taunts.txt`. After a TF2 update that adds taunts, rebuild it with `tools/gerar_lista_taunts.py` and run `sm_taunts_reload`.
- Uses the game's own scripting system (VScript); no extra extensions needed.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_taunts` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_taunt` / `!taunt` | everyone | Opens the taunt menu (or `sm_taunt <number>`) |
| `sm_taunts` / `!taunts` | everyone | Same as sm_taunt |
| `sm_taunts_reload` / `!taunts_reload` | admin (flag `i`) | Reloads the taunt list |

## Cvars
`cfg/sourcemod/skynet_taunts.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_taunts_enabled` | `1` | Turns the !taunt command on (1) or off (0) |
| `skynet_taunts_cooldown` | `3` | Seconds between two taunts |
