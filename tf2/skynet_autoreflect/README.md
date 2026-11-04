# SKYNET Auto Reflect

**Team Fortress 2** · v4.2 · `skynet_autoreflect.smx`

[All plugins](../../README.md)

Dodgeball: auto reflect for admins and an automatic ALL VS BOT mode when there are few players.

## What it does
- `!autoreflect` toggles auto reflect on yourself (or on another player with `!autoreflect <name>`): your aim snaps to the rocket and the airblast fires at the right moment. Everyone sees in chat when it is turned on or off.
- It only airblasts with the rocket inside the Pyro's real airblast area and with the airblast ready, so it keeps working when rockets get very fast.
- **Automatic ALL VS BOT mode:** with 1 to 3 players on the teams (fewer than `skynet_bot_jogadores`), **SKYNET BOT** joins as a Pyro on BLU and every player goes to RED. Anyone who joins later goes straight to RED.
- When the 4th player joins a team, the bot leaves, the teams are scrambled (2v2) and the game goes back to normal. The switch waits for 5 seconds with the same player count, so it does not flip back and forth. On an empty server, the bot leaves.
- The bot stands still where it spawns and reflects any enemy rocket heading its way as soon as the rocket enters the airblast area. Its airblast has no cooldown, so it reflects almost everything, even at close range.
- There is only one bot: the plugin sets `tf_bot_quota` to 0 and removes any other bot, so the game does not keep adding random bots.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2 running Dodgeball
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): optional but recommended. With it, the plugin knows which rocket targets whom; without it, it decides by the rocket's position and direction.

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_autoreflect` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_autoreflect` / `!autoreflect` | admin (flag `z`) | Toggles auto reflect (no name = on yourself) |

## Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_bot_auto` | `1` | 1 = with few players on the teams, everyone against SKYNET BOT |
| `skynet_bot_jogadores` | `4` | With this many players on the teams the bot leaves and the game is normal |
| `skynet_autoreflect_frente` | `128` | Distance from the eye to the center of the airblast area |
| `skynet_autoreflect_lado` | `112` | Half the width of the airblast area used (the game uses 128; smaller = safer) |
| `skynet_autoreflect_altura` | `56` | Half the height of the airblast area used (the game uses 64; smaller = safer) |
| `skynet_autoreflect_emergencia` | `110` | Reflects any enemy rocket closer than this, even one aimed at another player |
| `skynet_autoreflect_perto` | `180` | With a slow rocket, waits until it is this close before airblasting |

## Notes
- While the bot mode is on, the plugin sets `mp_autoteambalance` and `mp_teams_unbalance_limit` to 0. When the bot leaves, both go back to 1.
- Do not use it with another plugin that adds bots, or with `tf_bot_quota` in `server.cfg`.
- To keep bot practice out of the ranking (HLstatsX, HLstatsZ), set it to need at least 4 players and to ignore bots.
- [Chat Limpo](../skynet_chatlimpo/) hides the cvar and bot messages the bot mode causes.

## Changes since 3.0
- 4.0: the ALL VS BOT mode turns on and off by itself based on the player count. The `!votebot` and `!botoff` commands are gone.
- 4.1: sets `tf_bot_quota` to 0 before removing bots (the game kept adding random bots back).
- 4.2: the bot reflects almost everything, even at close range, and works well on 100-tick servers.
