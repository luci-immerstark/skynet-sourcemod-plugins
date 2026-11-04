# SKYNET AFK

**Left 4 Dead 2** · v1.0 · `skynet_afk_l4d2.smx`

[All plugins](../../README.md)

Kicks players who stay idle (not moving) too long, to free the slot.

## What it does
- Any button press or mouse movement counts as activity.
- Warns in chat and on screen 1 minute before the kick.
- Dead survivors waiting for rescue do not count as idle. Admins can be made immune (`skynet_afk_imune_admin`).

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_afk_l4d2` in the console.

## Cvars
`cfg/sourcemod/skynet_afk_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_afk_minutos` | `10` | Idle minutes before the kick (0 = off) |
| `skynet_afk_imune_admin` | `0` | 1 = admins are never kicked for being idle |
