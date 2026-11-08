# SKYNET Next Campaign

**Left 4 Dead 2** · v1.7 · `skynet_campanhas_l4d2.smx`

[All plugins](../../README.md)

Next-campaign vote during the finale, automatic switch after the rescue, and a campaign menu for admins.

## What it does
- During the finale, a few seconds after the team leaves the saferoom, a vote for the next campaign opens (keys 1 to N).
- Options are drawn by weight: recently played campaigns are left out, and the ones missing for longer get a bonus and a guaranteed slot.
- After the rescue it waits for the credits and switches to the first chapter of the chosen campaign, with the normal campaign intro.
- If the team loses the finale, the choice still stands and the vote does not open again.
- `!proxima` shows the next campaign to any player.
- The server always starts on the same map: if that campaign was played recently, the first player who joins after a server start triggers a change to a campaign drawn by the same vote rules (no more repeating the same campaign after every restart).
- Admin menu (`!admin`): **Trocar campanha** (switches now) and **Votar campanha** (opens the vote; the switch only happens after the rescue).
- Covers the 14 official campaigns (c1 to c14). History is saved to `data/skynet_campanhas.txt`.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (recommended: without it, rescue and saferoom-exit detection is simpler)

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_campanhas_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_proxima` / `!proxima` | everyone | Shows the next campaign |
| `sm_campanha_trocar` / `!campanha_trocar` | admin (flag `g`) | Changes campaign now (starts at chapter 1) |
| `sm_campanha_votar` / `!campanha_votar` | admin (flag `k`) | Opens the next-campaign vote (switch happens after the rescue) |
| `sm_campanha_status` / `!campanha_status` | admin (flag `g`) | Shows history and weight of each campaign |

## Cvars
`cfg/sourcemod/skynet_campanhas_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_campanha_tempo` | `25` | Vote duration, in seconds |
| `skynet_campanha_opcoes` | `3` | Number of campaigns in the vote |
| `skynet_campanha_cooldown` | `3` | Campaigns played in the last N campaigns are left out of the vote |
| `skynet_campanha_starve` | `4` | A campaign missing from the last N votes gets a guaranteed slot |
| `skynet_campanha_espera` | `20` | Seconds after leaving the saferoom, in the finale, before opening the vote |
| `skynet_campanha_troca` | `15` | Maximum seconds after the rescue to switch, if the end of the rescue is not detected |
| `skynet_campanha_penalidade` | `0.25` | Multiplier for campaigns shown in the previous vote that did not win |
| `skynet_campanha_vote_grow` | `0.20` | Bonus per vote without being shown |
| `skynet_campanha_vote_cap` | `2.0` | Maximum bonus for time without being shown |
| `skynet_campanha_play_grow` | `0.30` | Bonus per campaign without being played (after the cooldown) |
| `skynet_campanha_play_cap` | `3.0` | Maximum bonus for time without being played |
| `skynet_campanha_atraso` | `12` | Seconds of credits and ending music, after the screen fades at the end of the rescue, before switching |
| `skynet_campanha_abertura` | `1` | 1 = switch through the game's vote path (campaign intro plays), 0 = changelevel |
