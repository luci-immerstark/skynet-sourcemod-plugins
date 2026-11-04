# SKYNET Saferoom Door

**Left 4 Dead 2** · v1.0 · `skynet_saferoom_l4d2.smx`

[All plugins](../../README.md)

Announces who opens and closes the saferoom door and locks the starting door open.

## What it does
- Shows who opened or closed the starting or ending saferoom door.
- Once opened, the starting saferoom door cannot be closed again until the round ends (stops trolling).

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (optional: identifies the door more precisely)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_saferoom_l4d2` in the console.

## Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_door_announce` | `1` | Announce in chat who opens and closes the saferoom door |
| `skynet_door_lock_start` | `1` | Once opened, the starting saferoom door can no longer be closed |
