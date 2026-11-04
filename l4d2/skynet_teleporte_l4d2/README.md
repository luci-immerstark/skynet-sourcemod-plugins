# SKYNET Teleport / Teleporte

**Left 4 Dead 2** · v1.1 · `skynet_teleporte_l4d2.smx`

[All plugins](../../README.md)

Admins go to a player (`!goto`) or bring a player to them (`!bring`).

## What it does
- Without a name, the commands open the player list.
- **Teleport** section in the admin menu (`!admin`) with "Go to a player" and "Bring a player".
- Does not teleport players hanging from a ledge (that gets them stuck).
- Texts in Portuguese, English and Spanish (`translations/skynet_teleporte.phrases.txt`).

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_teleporte_l4d2` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_goto` / `!goto` | admin (flag `f`) | `sm_goto <player>` goes to the player (no name opens the list) |
| `sm_bring` / `!bring` | admin (flag `f`) | `sm_bring <player>` brings the player to you (no name opens the list) |
