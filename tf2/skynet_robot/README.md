# SKYNET Robots

**Team Fortress 2** · v1.0 · `skynet_robot.smx`

[All plugins](../../README.md)

`!robot` command: the player turns into a Mann vs. Machine robot.

## What it does
- Uses the robot model of the player's own class and swaps voice lines and footsteps for MvM robot sounds.
- Type `!robot` again to go back to normal. The mode stays on after dying or changing class.
- Models and sounds ship with the game, so players download nothing.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_robot` in the console.

## Commands
| Command | Access | Description |
|---|---|---|
| `sm_robot` / `!robot` | everyone | Turns into a robot or back |
| `sm_robots` / `!robots` | everyone | Same as sm_robot |
| `sm_robo` / `!robo` | everyone | Same as sm_robot |

## Cvars
`cfg/sourcemod/skynet_robot.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_robot_enabled` | `1` | Turns the !robot command on (1) or off (0) |
| `skynet_robot_sounds` | `1` | Robots use robot voice and footsteps (1) or normal sounds (0) |
| `skynet_robot_cooldown` | `3` | Seconds between two uses of !robot |
