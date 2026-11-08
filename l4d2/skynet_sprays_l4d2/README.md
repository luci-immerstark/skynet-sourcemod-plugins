# SKYNET Sprays (L4D2)

**Left 4 Dead 2** · v1.4.1 · `skynet_sprays_l4d2.smx`

[All plugins](../../README.md)

Looking at a spray shows whose it is; admins can block offensive sprays.

## What it does
- Everyone sees the owner's name; admins also see the SteamID and the command to block it.
- Display mode (`skynet_spray_modo`): 0 = hint box (default), 1 = game instructor message, 2 = small panel that closes the moment you look away.
- Blocked players are saved; their current spray disappears on map change.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_sprays_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_quemspray` / `!quemspray`, `sm_spraytrace` | admin (flag `b`) | Who made the spray you are aiming at, and how long ago |
| `sm_sprayban` | admin (flag `b`) | `sm_sprayban <player>` blocks the player's sprays |
| `sm_sprayunban` | admin (flag `b`) | `sm_sprayunban <player>` allows them again |

## Cvars
`cfg/sourcemod/skynet_sprays_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_spray_mostrar` | `1` | 1 = show whose spray it is to players looking at it |
| `skynet_spray_distancia` | `800` | Maximum distance (units) to show the owner |
| `skynet_spray_modo` | `0` | 0 = hint box, 1 = game instructor, 2 = panel |
