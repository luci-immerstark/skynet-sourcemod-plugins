# SKYNET Always Expert / Sempre Expert

**Left 4 Dead 2** · v1.0 · `skynet_sempre_expert_l4d2.smx`

[All plugins](../../README.md)

Keeps the server on Expert difficulty at all times.

## What it does
- Any difficulty change (from the lobby or a vote) is switched back to Expert.
- Removes the "change difficulty" option from the in-game vote.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_sempre_expert_l4d2` in the console.

## Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_sempre_expert` | `1` | 1 = server always stays on Expert (0 = allow difficulty changes) |
