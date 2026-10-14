# SKYNET Robots

**Team Fortress 2** · v1.0 · `skynet_robot.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Comando `!robot`: o jogador vira um robô do Mann vs. Machine.

### O que faz
- Usa o modelo de robô da própria classe e troca a voz e os passos pelos sons de robô do MvM.
- Digite `!robot` de novo para voltar ao normal. O modo continua depois de morrer ou trocar de classe.
- Os modelos e sons já vêm no jogo: o jogador não precisa baixar nada.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_robot` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_robot` / `!robot` | todos | Vira ou deixa de ser um robo |
| `sm_robots` / `!robots` | todos | Igual ao sm_robot |
| `sm_robo` / `!robo` | todos | Igual ao sm_robot |

### Cvars
O arquivo `cfg/sourcemod/skynet_robot.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_robot_enabled` | `1` | Liga (1) ou desliga (0) o comando !robot |
| `skynet_robot_sounds` | `1` | Robos usam voz e passos de robo (1) ou os sons normais (0) |
| `skynet_robot_cooldown` | `3` | Segundos de espera entre um uso e outro do !robot |

## English

`!robot` command: the player turns into a Mann vs. Machine robot.

### What it does
- Uses the robot model of the player's own class and swaps voice lines and footsteps for MvM robot sounds.
- Type `!robot` again to go back to normal. The mode stays on after dying or changing class.
- Models and sounds ship with the game, so players download nothing.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_robot` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_robot` / `!robot` | everyone | Turns into a robot or back |
| `sm_robots` / `!robots` | everyone | Same as sm_robot |
| `sm_robo` / `!robo` | everyone | Same as sm_robot |

### Cvars
`cfg/sourcemod/skynet_robot.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_robot_enabled` | `1` | Turns the !robot command on (1) or off (0) |
| `skynet_robot_sounds` | `1` | Robots use robot voice and footsteps (1) or normal sounds (0) |
| `skynet_robot_cooldown` | `3` | Seconds between two uses of !robot |
