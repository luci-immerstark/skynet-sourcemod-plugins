# SKYNET Nuke

**Team Fortress 2** · v2.0 · `skynet_nuke.smx`

[All plugins](../../README.md)

Dodgeball: the NUKE rocket is bigger than the others.

## What it does
- Every rocket of the Dodgeball `nuke` class is `skynet_nuke_escala` times bigger (default: 5). Visual only: the hitbox stays the size of a normal rocket.
- The class is matched by its name in the Dodgeball `general.cfg` (`skynet_nuke_classe`).
- Our Dodgeball server no longer uses the NUKE (only the normal rocket), but the plugin stays here for anyone who wants it.
- Uses the Soldier's regular rocket, which ships with the game, so players download nothing.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2 running Dodgeball
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): required.

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_nuke` in the console.

## Cvars
`cfg/sourcemod/skynet_nuke.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_nuke_escala` | `5.0` | Size of the NUKE compared with a normal rocket |
| `skynet_nuke_classe` | `nuke` | Name of the NUKE rocket class in the Dodgeball general.cfg |

## Notes
- Leave the `nuke` class in `general.cfg` without a `"model"` line (default rocket). Models of other objects, such as the Mann vs. Machine bomb, were not made to fly and travel sideways.
