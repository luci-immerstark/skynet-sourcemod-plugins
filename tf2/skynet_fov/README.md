# SKYNET FOV

**Team Fortress 2** · v1.1.0 · `skynet_fov.smx`

[All plugins](../../README.md)

`!fov <number>` in chat to change the field of view.

## What it does
- `!fov 110` sets the field of view to 110. The value is saved and comes back on the player's next visit.
- `!fov` on its own goes back to the game's field of view (the player's `fov_desired`).
- The value must be between `skynet_fov_min` and `skynet_fov_max`. Otherwise the plugin shows the limits in chat.
- Works with `!fov` or `/fov` in chat (the command is hidden from everyone else) and with `sm_fov` in the console.
- The FOV is applied again on every spawn and leaves the Sniper scope alone.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2
- The Client Preferences extension (`clientprefs`), which ships with SourceMod, to save the value.

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_fov` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_fov <number>` / `!fov <number>` | everyone | Changes the field of view; no number goes back to normal |

## Cvars
`cfg/sourcemod/skynet_fov.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_fov_min` | `75` | Lowest FOV allowed with !fov |
| `skynet_fov_max` | `120` | Highest FOV allowed with !fov |

## Notes
- Our Dodgeball server uses `skynet_fov_min 50` and `skynet_fov_max 130`.
