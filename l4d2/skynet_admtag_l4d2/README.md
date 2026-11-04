# SKYNET Admin Tag

**Left 4 Dead 2** · v1.0 · `skynet_admtag_l4d2.smx`

[All plugins](../../README.md)

Green `[ADM]` tag before admin names in chat.

## What it does
- Keeps the game's own prefixes: *DEAD*, (Survivor), (Infected) and (Spectator).
- Anyone with flag `b` (generic) or the `sm_tag_adm` override gets the tag.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_admtag_l4d2` in the console.

## Permission
Override `sm_tag_adm` (default: flag `b`). To change who has access, use `addons/sourcemod/configs/admin_overrides.cfg`.
