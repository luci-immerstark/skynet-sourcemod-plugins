# SKYNET FOV

**Team Fortress 2** · v1.1.0 · `skynet_fov.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

`!fov <número>` no chat para mudar o campo de visão.

### O que faz
- `!fov 110` muda o campo de visão para 110. O valor fica salvo e volta sozinho na próxima vez que o jogador entrar.
- `!fov` sozinho volta ao campo de visão do jogo (o `fov_desired` do jogador).
- O valor precisa estar entre `skynet_fov_min` e `skynet_fov_max`. Fora disso, o plugin mostra os limites no chat.
- Funciona por `!fov` ou `/fov` no chat (o comando não aparece para os outros) e por `sm_fov` no console.
- O FOV é reaplicado toda vez que o jogador nasce e não mexe na luneta do Sniper.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2
- A extensão Client Preferences (`clientprefs`), que já vem no SourceMod, para salvar o valor.

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_fov` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_fov <número>` / `!fov <número>` | todos | Muda o campo de visão; sem número volta ao normal |

### Cvars
O arquivo `cfg/sourcemod/skynet_fov.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_fov_min` | `75` | FOV mínimo permitido no !fov |
| `skynet_fov_max` | `120` | FOV máximo permitido no !fov |

### Observações
- No nosso servidor de Dodgeball usamos `skynet_fov_min 50` e `skynet_fov_max 130`.

## English

`!fov <number>` in chat to change the field of view.

### What it does
- `!fov 110` sets the field of view to 110. The value is saved and comes back on the player's next visit.
- `!fov` on its own goes back to the game's field of view (the player's `fov_desired`).
- The value must be between `skynet_fov_min` and `skynet_fov_max`. Otherwise the plugin shows the limits in chat.
- Works with `!fov` or `/fov` in chat (the command is hidden from everyone else) and with `sm_fov` in the console.
- The FOV is applied again on every spawn and leaves the Sniper scope alone.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2
- The Client Preferences extension (`clientprefs`), which ships with SourceMod, to save the value.

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_fov` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_fov <number>` / `!fov <number>` | everyone | Changes the field of view; no number goes back to normal |

### Cvars
`cfg/sourcemod/skynet_fov.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_fov_min` | `75` | Lowest FOV allowed with !fov |
| `skynet_fov_max` | `120` | Highest FOV allowed with !fov |

### Notes
- Our Dodgeball server uses `skynet_fov_min 50` and `skynet_fov_max 130`.
