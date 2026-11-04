# SKYNET Entrada

**Team Fortress 2** · v1.0.0 · `skynet_entrada.smx`

[All plugins](../../README.md)

Tells the chat who joined the server and from which country.

## What it does
- When a player joins, everyone sees in chat: `[SKYNET] Name entrou no servidor, direto do Brasil!` (the message is in Portuguese).
- 40 countries get their Portuguese name with the right preposition (do Brasil, da Argentina, dos Estados Unidos...). The rest show the English name.
- If the country is not found, the message goes out without it.
- One message per connection: a map change does not repeat it. Bots are not announced.

## Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2
- A MaxMind GeoIP2 database in `addons/sourcemod/configs/geoip/` (SourceMod no longer ships one). [GeoLite2 Country or City](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data) is free with an account.

## Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Put `GeoLite2-Country.mmdb` (or `GeoLite2-City.mmdb`) in `addons/sourcemod/configs/geoip/`.
3. Restart the server or run `sm plugins load skynet_entrada` in the console.
4. Test it in the console: `skynet_entrada_teste 8.8.8.8` should print `dos Estados Unidos`.

## Commands
| Command | Access | Description |
|---|---|---|
| `skynet_entrada_teste <ip>` | server console / rcon | Shows which country an IP is from (to check the GeoIP database) |

## Notes
- If you run another join plugin (Welcome, for example), both messages show. They complement each other: Welcome talks to the player, Entrada tells everyone else.
