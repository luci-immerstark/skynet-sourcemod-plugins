# SKYNET Hordes / Hordas

**Left 4 Dead 2** · v1.1 · `skynet_hordas_l4d2.smx`

[All plugins](../../README.md)

Common infected hordes scaled to the number of living survivors.

## What it does
- Made for servers with more than 4 survivors, since the game does not scale hordes by itself.
- Factor = 1 + `skynet_hordas_fator` × (alive − 4), never below `skynet_hordas_minimo` (default: 0.6). Adjusts `z_common_limit`, `z_mob_spawn_min_size`, `z_mob_spawn_max_size`, `z_mob_spawn_finale_size` and `z_mega_mob_size`.
- Each value is capped at `skynet_hordas_max`. Unloading the plugin restores the original values.
- Special infected are not touched.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_hordas_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_hordas` / `!hordas` | admin (flag `b`) | Shows the current horde sizes |

## Cvars
`cfg/sourcemod/skynet_hordas_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_hordas_fator` | `0.10` | How much each living survivor above 4 grows the hordes (0.10 = +10% per survivor) |
| `skynet_hordas_max` | `100` | Cap for each value (commons at once and horde sizes) |
| `skynet_hordas_minimo` | `0.6` | Lowest horde factor (1.0 = the game's original size, made for 4 survivors) |
