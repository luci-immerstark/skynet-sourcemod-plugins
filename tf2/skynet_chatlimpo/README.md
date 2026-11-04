# SKYNET Chat Limpo

**Team Fortress 2** · v1.0.0 · `skynet_chatlimpo.smx`

[All plugins](../../README.md)

Hides console notices from chat: cvar changes and bots joining or leaving.

## What it does
- Hides the `Server cvar 'x' changed to y` lines that show up when a plugin or the console changes a cvar.
- Hides bots joining, leaving, changing team or changing name.
- Notices for real players stay as they are.
- No cvars or commands: load it and it works.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_chatlimpo` in the console.

## Notes
- Handy together with the bot mode of [Auto Reflect](../skynet_autoreflect/), which changes cvars and adds and removes bots.
- Cvar changes still show in the server console and logs; they only leave the chat.
