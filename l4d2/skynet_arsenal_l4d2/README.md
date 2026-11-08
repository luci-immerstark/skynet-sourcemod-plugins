# SKYNET Arsenal

**Left 4 Dead 2** · v1.1 · `skynet_arsenal_l4d2.smx`

[All plugins](../../README.md)

Places lots of firearms and melee weapons in the starting saferoom of every chapter.

## What it does
- Every firearm in the game, each one can be picked up several times (`skynet_arsenal_qtd`).
- Optional: Counter-Strike weapons (MP5, SG552, Scout, AWP), Magnum and pistol, M60, grenade launcher and chainsaw.
- Every melee weapon available on the map.
- First aid kits in the starting saferoom: one per survivor (`skynet_arsenal_kits`); a survivor who joins later gets one too.
- Finds a clear, flat spot inside the saferoom by itself, away from the doors, without taking anyone's weapon.
- `sm_arsenal` builds the arsenal where the admin stands; `sm_arsenal limpar` removes it.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (optional: helps tell whether a spot is inside the saferoom)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_arsenal_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_arsenal` / `!arsenal` | admin (flag `n`) | `sm_arsenal` builds the arsenal where you stand, `sm_arsenal limpar` removes it |

## Cvars
`cfg/sourcemod/skynet_arsenal_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_arsenal_enable` | `1` | Turns the saferoom arsenal on (1) or off (0) |
| `skynet_arsenal_qtd` | `10` | How many times each firearm can be picked up (0 = unlimited) |
| `skynet_arsenal_css` | `1` | Include Counter-Strike weapons (MP5, SG552, Scout, AWP) |
| `skynet_arsenal_pistolas` | `1` | Include Magnum and pistol |
| `skynet_arsenal_melee` | `2` | Units of each melee weapon (0 = none) |
| `skynet_arsenal_especiais` | `1` | How many M60s, grenade launchers and chainsaws (0 = none) |
| `skynet_arsenal_aviso` | `1` | Announce in chat when the arsenal is built |
| `skynet_arsenal_kits` | `1` | Tops up the saferoom first aid kits: one for each survivor (0 = leave as is) |
