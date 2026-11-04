# SKYNET Map Vote

**Team Fortress 2** · v1.5 · `skynet_mapvote.smx`

[All plugins](../../README.md)

Next-map vote whose options are drawn by hype, time since last played and time since last shown.

## What it does
- Each map gets a **hype** score from 0 to 5 in `configs/skynet_mapvote.txt`. Higher hype means the map shows up more often.
- Maps played in the last few matches are left out of the vote (`skynet_mapvote_cooldown`).
- Maps that have not been played or shown for a while get a bonus. A map that misses many votes in a row gets a guaranteed slot (`skynet_mapvote_starve`).
- **Time mode** (default): the vote opens when `skynet_mapvote_before` seconds are left on `mp_timelimit`. Best for Dodgeball and timed maps.
- **Round mode**: with `skynet_mapvote_before 0`, the vote opens `skynet_mapvote_delay` seconds after the last round starts (`mp_maxrounds`).
- The winning map becomes the `nextmap`. If nobody votes, the first option wins.
- History is saved to `configs/skynet_mapvote_state.txt` and survives server restarts.
- Maps in the list that are not installed are skipped (a warning goes to the error log).
- **Extend**: every end-of-map vote has one extra fixed option, `Estender <current map> (+10 min)`. If it wins, `mp_timelimit` grows by `skynet_mapvote_extend` minutes (and `mp_maxrounds` gets 1 more round, if used) and the vote comes back near the new end. The original values return on map change.
- **!rtv**: when `skynet_rtv_needed` of the players (default: 60%) type `!rtv` (or just `rtv`), a vote to change map right now opens. Its fixed option is `Continuar em <current map>` (stay). If a map wins, the change happens in 5 seconds. If the next map was already chosen, the server goes straight to it.
- **!nominate**: opens a menu with the maps in alphabetical order to nominate one for the next vote (`!nominate <part of the name>` filters). Each player nominates one map; nominating another replaces theirs. Nominated maps go into the vote first, in nomination order, and the remaining slots are drawn as usual. The current map, maps with hype 0 and maps on cooldown cannot be nominated.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Edit `addons/sourcemod/configs/skynet_mapvote.txt` with your server's maps and each one's hype (0 to 5).
3. Restart the server or run `sm plugins load skynet_mapvote` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_mapvote_status` / `!mapvote_status` | admin (flag `g`) | Shows hype, history and weight of each map |
| `sm_mapvote_now` / `!mapvote_now` | admin (flag `g`) | Starts the next-map vote now |
| `sm_rtv` / `!rtv` (or `rtv`, `rockthevote`) | everyone | Votes to change map now |
| `sm_nominate` / `!nominate [search]` (or `nominate`) | everyone | Nominates a map for the next vote |

## Cvars
`cfg/sourcemod/skynet_mapvote.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_mapvote_time` | `20` | Vote duration, in seconds |
| `skynet_mapvote_cooldown` | `3` | Maps played in the last N matches are left out of the vote |
| `skynet_mapvote_starve` | `12` | A map missing from the last N votes gets a guaranteed slot |
| `skynet_mapvote_options` | `3` | Number of maps in each vote |
| `skynet_mapvote_hype_exp` | `2.5` | Weight of hype in the draw (hype raised to this power) |
| `skynet_mapvote_recent_penalty` | `0.8` | Multiplier for maps shown in the previous vote |
| `skynet_mapvote_vote_grow` | `0.10` | Bonus per vote without being shown |
| `skynet_mapvote_vote_cap` | `1.8` | Maximum bonus for time without being shown |
| `skynet_mapvote_play_grow` | `0.10` | Bonus per match without being played (after the cooldown) |
| `skynet_mapvote_play_cap` | `1.8` | Maximum bonus for time without being played |
| `skynet_mapvote_delay` | `180` | Round mode: seconds after the last round starts before opening the vote |
| `skynet_mapvote_before` | `180` | Time mode: open the vote when this many seconds are left on mp_timelimit. 0 = round mode |
| `skynet_mapvote_extend` | `10` | Extra minutes when the vote picks extending the current map. 0 = no extend option |
| `skynet_rtv_needed` | `0.60` | Fraction of players who must type !rtv to change map |
| `skynet_rtv_delay` | `60` | Seconds after the map starts before !rtv is allowed |
| `skynet_rtv_interval` | `240` | If most players choose to stay, seconds until !rtv counts again |

## Notes
- Disable SourceMod's own map plugins (`mapchooser.smx`, `rockthevote.smx`, `nominations.smx`): this plugin covers all three, and with them loaded two votes would open.

## Changes since 1.2
- 1.3: fixed option to extend the current map.
- 1.4: `!rtv`.
- 1.5: `!nominate`.
