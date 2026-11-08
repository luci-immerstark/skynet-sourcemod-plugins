# SKYNET Rescue Glow / Brilho no Resgate

**Left 4 Dead 2** · v1.0 · `skynet_brilho_resgate_l4d2.smx`

[All plugins](../../README.md)

A dead survivor waiting in a rescue closet glows through walls until rescued.

## What it does
- The glow starts when the survivor appears in the closet and stops when they are rescued, die again or the round restarts.
- Helps the team find the closet when the game's own outline does not show.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_brilho_resgate_l4d2` in the console.

## Cvars
`cfg/sourcemod/skynet_brilho_resgate_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_resgate_cor` | `255 140 0` | Glow color (R G B) |
