# SKYNET Vote Difficulty / Votar Dificuldade

**Left 4 Dead 2** · v1.2 · `skynet_dificuldade_l4d2.smx`

[All plugins](../../README.md)

`!dificuldade` (or `!dif`) lets players vote to change the difficulty.

## What it does
- Opens a menu with the difficulties and then a Yes/No vote for everyone; it passes with more Yes than No (players who do not vote do not count).
- One vote every 2 minutes (`skynet_dificuldade_espera`).
- The voted difficulty lasts until the end of the campaign or until the server empties; then it goes back to Expert.
- While it lasts, SKYNET Always Expert is turned off.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (optional: detects the start of a new campaign)
- SKYNET Always Expert (`skynet_sempre_expert_l4d2`), if you want the server back on Expert after the vote

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_dificuldade_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_dificuldade` / `!dificuldade` | everyone | Opens the difficulty vote |
| `sm_dif` / `!dif` | everyone | Same as `!dificuldade` |

## Cvars
`cfg/sourcemod/skynet_dificuldade_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_dificuldade_espera` | `120` | Seconds between votes |
| `skynet_dificuldade_tempo` | `20` | Vote duration, in seconds |
