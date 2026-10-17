# SKYNET Nuke

**Team Fortress 2** · v2.0 · `skynet_nuke.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Dodgeball: o foguete NUKE fica maior que os outros.

### O que faz
- Cada foguete da classe `nuke` do Dodgeball sai `skynet_nuke_escala` vezes maior (padrão: 5). Só muda o visual: a área de acerto continua a de um foguete normal.
- A classe é reconhecida pelo nome no `general.cfg` do Dodgeball (`skynet_nuke_classe`).
- Usa o foguete normal do Soldier, que já vem no jogo: os jogadores não baixam nada.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2 com o modo Dodgeball
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): obrigatório.

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_nuke` no console.

### Cvars
O arquivo `cfg/sourcemod/skynet_nuke.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_nuke_escala` | `5.0` | Tamanho da NUKE em relacao a um foguete normal |
| `skynet_nuke_classe` | `nuke` | Nome da classe de foguete da NUKE no general.cfg do Dodgeball |

### Observações
- Na classe `nuke` do `general.cfg`, deixe sem a linha `"model"` (foguete padrão). Modelos de outros objetos, como a bomba do Mann vs. Machine, não foram feitos para voar e ficam de lado.

## English

Dodgeball: the NUKE rocket is bigger than the others.

### What it does
- Every rocket of the Dodgeball `nuke` class is `skynet_nuke_escala` times bigger (default: 5). Visual only: the hitbox stays the size of a normal rocket.
- The class is matched by its name in the Dodgeball `general.cfg` (`skynet_nuke_classe`).
- Uses the Soldier's regular rocket, which ships with the game, so players download nothing.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2 running Dodgeball
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): required.

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_nuke` in the console.

### Cvars
`cfg/sourcemod/skynet_nuke.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_nuke_escala` | `5.0` | Size of the NUKE compared with a normal rocket |
| `skynet_nuke_classe` | `nuke` | Name of the NUKE rocket class in the Dodgeball general.cfg |

### Notes
- Leave the `nuke` class in `general.cfg` without a `"model"` line (default rocket). Models of other objects, such as the Mann vs. Machine bomb, were not made to fly and travel sideways.
