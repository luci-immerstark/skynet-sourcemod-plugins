# SKYNET Votes

**Left 4 Dead 2** · v1.1 · `skynet_votes.smx`

[All plugins](../../README.md)

Turns off the game's menu votes (difficulty, kick, restart, change campaign, lobby), with an on-screen notice.

## What it does
- Anyone who tries to call a vote from the ESC menu gets a notice in the middle of the screen and in chat (the vote menu covers the chat).
- By default nobody can call menu votes, admins included: they use `!admin` to kick and change campaign.
- With `skynet_votes_admins 1`, anyone with flag `b` (generic) or the `skynet_callvote` override can call menu votes again.
- Allow specific votes for everyone in `skynet_votes_allow` (e.g. `Kick,ChangeAllTalk`).

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_votes` in the console.

## Cvars
`cfg/sourcemod/skynet_votes.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_votes_allow` | `""` | Menu votes still open to everyone, comma separated (e.g. Kick,ChangeAllTalk). Empty = none |
| `skynet_votes_admins` | `0` | 1 = admins (skynet_callvote override, flag b) can still call menu votes; 0 = nobody can |

## Changes in 1.1
- New `skynet_votes_admins` cvar. The default (0) turns menu votes off for admins too.
- On-screen notice, besides the chat.

## Permission
Override `skynet_callvote` (default: flag `b`), used with `skynet_votes_admins 1`. To change who has access, use `addons/sourcemod/configs/admin_overrides.cfg`.
