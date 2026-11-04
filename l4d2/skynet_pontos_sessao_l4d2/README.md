# SKYNET Session Points

**Left 4 Dead 2** · v1.1 · `skynet_pontos_sessao_l4d2.smx`

[All plugins](../../README.md)

Shop points (Points System) last for the whole campaign.

## What it does
- Each player's balance carries over between chapters instead of resetting every map.
- The balance goes back to the starting value (`l4d2_points_start`) when the player leaves the server or the campaign ends.
- Fixes Points System restoring, in the next chapter, the old balance from when the player joined the team.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (Eyal282)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_pontos_sessao_l4d2` in the console.
