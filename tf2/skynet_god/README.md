# SKYNET God Mode

**Team Fortress 2** · v1.0 · `skynet_god.smx`

[All plugins](../../README.md)

Admins turn god mode (no damage) on or off for a player.

## What it does
- `sm_god <target> [0|1]`: 1 turns it on, 0 turns it off, no value toggles it.
- Stays on after respawns until it is turned off or the player leaves.
- Every change goes to the SourceMod admin log.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_god` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_god` / `!god` | admin (flag `n`, cheats) | `sm_god <target> [0\|1]` turns god mode on, off or toggles it |
