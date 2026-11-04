# SKYNET No Friendly Fire / Sem Fogo Amigo

**Left 4 Dead 2** · v1.3 · `skynet_semfogoamigo_l4d2.smx`

[All plugins](../../README.md)

No friendly fire between survivors, with custom rules for fire and explosions.

## What it does
- Survivors deal no damage to each other (bullets, grenades, grenade launcher).
- A molotov still burns the player who threw it.
- Fire from gas cans, fuel barrels and fireworks does not hurt any survivor.
- Map fire (bonfires, burning cars and buildings) gets stronger (`skynet_fogo_mapa`).

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_semfogoamigo_l4d2` in the console.

## Cvars
`cfg/sourcemod/skynet_semfogoamigo_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_sem_fogo_amigo` | `1` | 1 = survivors deal no damage to each other |
| `skynet_galao_sem_dano` | `1` | 1 = fire from gas cans, barrels and fireworks does not hurt survivors |
| `skynet_fogo_mapa` | `3.0` | Damage multiplier for map fire on survivors (1 = game default) |
