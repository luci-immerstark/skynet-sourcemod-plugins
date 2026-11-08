# SKYNET Give Item / Passar Item

**Left 4 Dead 2** · v1.1 · `skynet_passar_item_l4d2.smx`

[All plugins](../../README.md)

Survivors hand items to each other.

## What it does
- Hold R (reload) and right-click while aiming at a survivor to hand over the item in your hands: grenades, first aid kit, defibrillator, upgrade packs, pills and adrenaline.
- The teammate must have that inventory slot free. Holding R also stops the right click from shoving or healing.
- `!gw <name> <item>` gives one of your items to that survivor from anywhere (e.g. `!gw Franco kit`). Items: kit, defib, pills, adren, molotov, pipe, bile, incendiaria, explosiva.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_passar_item_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_gw` / `!gw` | everyone | `!gw <player> <item>` gives one of your items to that survivor |

## Cvars
`cfg/sourcemod/skynet_passar_item_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_passar_distancia` | `150` | Maximum distance (units) to hand over an item by aiming |
