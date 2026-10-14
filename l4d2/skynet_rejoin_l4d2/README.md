# SKYNET Rejoin

**Left 4 Dead 2** · v1.1 · `skynet_rejoin_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

No início de cada rodada, devolve ao time quem ficou preso como espectador ou morto.

### O que faz
- Confere 8 e 20 segundos depois do início da rodada.
- Quem ficou como espectador sem personagem (e não está ausente) volta ao time pelo `sm_join`.
- Quem começou a rodada morto é revivido ao lado de um sobrevivente vivo. Quem morreu durante a rodada não é revivido.
- Registro em `logs/skynet_rejoin.log`.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (para reviver)
- Um plugin que crie o comando `sm_join`, como o [MultiSlots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots)

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_rejoin_l4d2` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_rejoin_check` / `!rejoin_check` | admin (flag `b`) | Faz agora a verificacao de jogadores presos |

### Cvars
Coloque as cvars que quiser mudar no `cfg/server.cfg`.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_rejoin_enable` | `1` | Recoloca no time, no inicio da rodada, quem ficou preso como espectador ou morto |

## English

At the start of every round, puts back into the team anyone stuck as a spectator or dead.

### What it does
- Checks 8 and 20 seconds after the round starts.
- Players left as spectators without a character (and not idle) rejoin through `sm_join`.
- Players who start the round dead are respawned next to a living survivor. Deaths during the round are not undone.
- Logs to `logs/skynet_rejoin.log`.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (to respawn)
- A plugin that provides `sm_join`, such as [MultiSlots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots)

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_rejoin_l4d2` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_rejoin_check` / `!rejoin_check` | admin (flag `b`) | Runs the stuck-player check now |

### Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_rejoin_enable` | `1` | At round start, put back into the team anyone stuck as spectator or dead |
