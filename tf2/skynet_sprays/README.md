# SKYNET Sprays

**Team Fortress 2** · v1.0.0 · `skynet_sprays.smx`

[All plugins](../../README.md)

Spray moderation: who made a spray and blocking offensive sprays (replaces Super Spray Handler).

## What it does
- Aim at a spray to see who made it and how long ago.
- Blocked players are saved; their current spray disappears on map change.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_sprays` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_quemspray` / `!quemspray`, `sm_spraytrace` | admin (flag `b`) | Who made the spray you are aiming at |
| `sm_sprayban` | admin (flag `b`) | `sm_sprayban <player>` blocks the player's sprays |
| `sm_sprayunban` | admin (flag `b`) | `sm_sprayunban <player>` allows them again |
