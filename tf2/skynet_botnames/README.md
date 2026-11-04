# SKYNET Bot Names

**Team Fortress 2** · v1.1 · `skynet_botnames.smx`

[All plugins](../../README.md)

Fixed names for bots and a clean chat when they join and leave.

## What it does
- Each bot gets a name from the plugin's list (edit the list in the `.sp`).
- Hides bot join, leave and name-change messages from chat.
- Hides the `Server cvar 'tf_bot_count' changed` notice that shows every time a bot joins or leaves.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_botnames` in the console.
