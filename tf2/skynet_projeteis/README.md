# SKYNET Projectiles

**Team Fortress 2** · v1.0.0 · `skynet_projeteis.smx`

[All plugins](../../README.md)

When a player dies, their projectiles vanish from the map.

## What it does
- On death, removes every projectile (`tf_projectile_*`) owned by the player: rockets, grenades, stickies, arrows, flares and the rest.
- A Spy faking death with the Dead Ringer keeps their projectiles.
- Can be turned off without unloading the plugin with `skynet_projeteis 0`.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_projeteis` in the console.

## Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_projeteis` | `1` | 1 = projectiles of a dead player vanish; 0 = off |

## Notes
- Keep it off Dodgeball servers: there the rocket belongs to whoever reflected it last, and it would vanish if that player died.
