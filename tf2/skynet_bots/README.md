# SKYNET Test Bots

**Team Fortress 2** · v1.0.0 · `skynet_bots.smx`

[All plugins](../../README.md)

Admins and moderators add and remove test bots (`!bots` or the admin menu).

## What it does
- Menu to add 1, 3, 5 or 10 bots and to remove them all.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_bots` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_bots` / `!bots` | admin (flag `b`) | Test bots menu |

## Cvars
`cfg/sourcemod/skynet_bots.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_bots_teste` | `0` | Test bots on the server (the plugin updates it by itself) |
