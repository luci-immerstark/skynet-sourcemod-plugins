# SKYNET Welcome

**Left 4 Dead 2** · v1.0 · `skynet_welcome_l4d2.smx`

[All plugins](../../README.md)

Welcome message in chat, once per connection.

## What it does
- Shows 30 seconds after the player joins, to that player only, and reminds spectators about `!join`.
- It is not repeated on map change, only after the player leaves and comes back.
- To change the text, edit the messages in the `.sp` and recompile.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_welcome_l4d2` in the console.
