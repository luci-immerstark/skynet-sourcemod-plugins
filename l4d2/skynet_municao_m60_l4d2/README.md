# SKYNET M60 Ammo / Municao M60

**Left 4 Dead 2** · v1.0 · `skynet_municao_m60_l4d2.smx`

[All plugins](../../README.md)

The M60 and the grenade launcher can be refilled at ammo piles and with `!buy ammo`.

## What it does
- The game refuses ammo piles for these two weapons; this plugin refills them.
- Also refills them on `!buy ammo` from Point System API (its "give ammo" does not).

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (optional: for `!buy ammo`)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_municao_m60_l4d2` in the console.

## Cvars
`cfg/sourcemod/skynet_municao_m60_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_m60_balas` | `150` | M60 bullets after a refill |
