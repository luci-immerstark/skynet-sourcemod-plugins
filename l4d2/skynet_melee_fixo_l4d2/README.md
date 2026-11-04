# SKYNET Fixed Melee Damage / Melee Fixo

**Left 4 Dead 2** · v1.2 · `skynet_melee_fixo_l4d2.smx`

[All plugins](../../README.md)

Melee hits deal fixed damage to the Tank and the Witch, and the Witch's health grows with the number of survivors.

## What it does
- In the base game, each melee hit takes a percentage of max health: 5% of the Tank's (dies in 20 hits) and 25% of the Witch's (dies in 4). With the plugin, each hit deals a fixed amount (`skynet_melee_tank` and `skynet_melee_witch`).
- The Witch's health follows the living survivors when she spawns: `skynet_witch_vida_min` with 4 or fewer, rising evenly up to `skynet_witch_vida_max` at `skynet_witch_vida_max_com` or more. Good for servers with more than 4 survivors.
- The chainsaw is unchanged.
- Test mode (`skynet_melee_debug 1`): on every hit on the Tank or Witch, the hitter sees in chat the damage the game would deal, the plugin's damage and the health before the hit. It also goes to the SourceMod log.
- Damage bonuses from other plugins (perks, for example) still apply on top of the fixed damage.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_melee_fixo_l4d2` in the console.

## Cvars
`cfg/sourcemod/skynet_melee_fixo_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_melee_tank` | `500` | Damage of each melee hit on the Tank (0 = game default: 5% of its health) |
| `skynet_melee_witch` | `300` | Damage of each melee hit on the Witch (0 = game default: 25% of her health) |
| `skynet_witch_vida_min` | `1000` | Witch health with 4 or fewer living survivors |
| `skynet_witch_vida_max` | `5000` | Maximum Witch health (0 = game default health, nothing changes) |
| `skynet_witch_vida_max_com` | `10` | Number of living survivors at which the Witch reaches maximum health |
| `skynet_melee_debug` | `0` | 1 = on every melee hit on the Tank or Witch, shows the damage and health in the hitter's chat (and writes it to the SourceMod log) |
