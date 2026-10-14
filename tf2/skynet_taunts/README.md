# SKYNET Taunts

**Team Fortress 2** · v1.0 · `skynet_taunts.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Menu `!taunt` com todas as taunts do jogo, mesmo as que o jogador não tem no inventário.

### O que faz
- As taunts da classe do jogador aparecem primeiro, depois as de todas as classes.
- Também aceita o número da taunt (o mesmo de `configs/skynet_taunts.txt`): `!taunt <número>`.
- A lista fica em `configs/skynet_taunts.txt`. Depois de uma atualização do TF2 com taunts novas, gere a lista de novo com `tools/gerar_lista_taunts.py` e use `sm_taunts_reload`.
- Usa o sistema de scripts do próprio jogo (VScript), sem precisar de extensões extras.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_taunts` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_taunt` / `!taunt` | todos | Abre o menu de taunts (ou `sm_taunt <número>`) |
| `sm_taunts` / `!taunts` | todos | Igual ao sm_taunt |
| `sm_taunts_reload` / `!taunts_reload` | admin (flag `i`) | Recarrega a lista de taunts |

### Cvars
O arquivo `cfg/sourcemod/skynet_taunts.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_taunts_enabled` | `1` | Liga (1) ou desliga (0) o comando !taunt |
| `skynet_taunts_cooldown` | `3` | Segundos de espera entre uma taunt e outra |

## English

`!taunt` menu with every taunt in the game, even ones the player does not own.

### What it does
- Taunts for the player's class are listed first, then the all-class ones.
- Also accepts the taunt's item number (as listed in `configs/skynet_taunts.txt`): `!taunt <number>`.
- The list lives in `configs/skynet_taunts.txt`. After a TF2 update that adds taunts, rebuild it with `tools/gerar_lista_taunts.py` and run `sm_taunts_reload`.
- Uses the game's own scripting system (VScript); no extra extensions needed.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_taunts` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_taunt` / `!taunt` | everyone | Opens the taunt menu (or `sm_taunt <number>`) |
| `sm_taunts` / `!taunts` | everyone | Same as sm_taunt |
| `sm_taunts_reload` / `!taunts_reload` | admin (flag `i`) | Reloads the taunt list |

### Cvars
`cfg/sourcemod/skynet_taunts.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_taunts_enabled` | `1` | Turns the !taunt command on (1) or off (0) |
| `skynet_taunts_cooldown` | `3` | Seconds between two taunts |
