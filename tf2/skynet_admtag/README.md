# SKYNET Admin Tag

**Team Fortress 2** · v1.2 · `skynet_admtag.smx`

[All plugins](../../README.md)

Gold `[ADM]` tag before admin names and blue `[MOD]` tag before moderator names in chat.

## What it does
- Keeps the game's own prefixes: *DEAD*, (TEAM), (Spectator) and (Coach).
- `[ADM]` (gold): anyone with flag `d` (ban) or the `sm_tag_adm` override.
- `[MOD]` (blue): anyone who is not an admin but has flag `b` (generic) or the `sm_tag_mod` override. A typical moderator has the kick, map change and vote flags, without ban.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_admtag` in the console.

## Permission
Overrides `sm_tag_adm` (default: flag `d`) and `sm_tag_mod` (default: flag `b`). To change who gets each tag, use `addons/sourcemod/configs/admin_overrides.cfg`.

## Changes in 1.2
- New `[MOD]` tag for moderators.
- The `[ADM]` tag now needs flag `d` (ban) instead of `b`.
