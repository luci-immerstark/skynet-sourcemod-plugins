# SKYNET Welcome

**Team Fortress 2** · v1.1 · `skynet_welcome.smx`

[All plugins](../../README.md)

Welcome message in chat, once per connection.

## What it does
- Shows 30 seconds after the player joins, to that player only.
- It is not repeated on map change, only after the player leaves and comes back.
- To change the text, edit the message in the `.sp` and recompile.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_welcome` in the console.
