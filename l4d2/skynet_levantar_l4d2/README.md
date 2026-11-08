# SKYNET Get Up Alone / Levantar Sozinho

**Left 4 Dead 2** · v1.0 · `skynet_levantar_l4d2.smx`

[All plugins](../../README.md)

A downed survivor with pills or adrenaline gets up alone by holding E.

## What it does
- Works while incapacitated or hanging from a ledge: hold E for a few seconds (progress bar on screen); the pills or adrenaline are used up.
- Does not work while a special infected is holding the player or while a teammate is already reviving them.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (required: does the revive)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_levantar_l4d2` in the console.

## Cvars
`cfg/sourcemod/skynet_levantar_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_levantar_tempo` | `3.0` | Seconds holding E to get up |
