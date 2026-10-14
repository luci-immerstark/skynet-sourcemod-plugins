# SKYNET Teleport / Teleporte

**Left 4 Dead 2** · v1.1 · `skynet_teleporte_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Admins vão até um jogador (`!goto`) ou trazem um jogador até eles (`!bring`).

### O que faz
- Sem nome, os comandos abrem a lista de jogadores.
- Seção **Teleporte** no menu de admin (`!admin`), com "Ir até um jogador" e "Trazer um jogador".
- Não teleporta quem está pendurado na beirada (isso trava o jogador).
- Textos em português, inglês e espanhol (`translations/skynet_teleporte.phrases.txt`).

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_teleporte_l4d2` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_goto` / `!goto` | admin (flag `f`) | sm_goto <jogador> - vai ate o jogador (sem nome abre a lista) |
| `sm_bring` / `!bring` | admin (flag `f`) | sm_bring <jogador> - traz o jogador ate voce (sem nome abre a lista) |

## English

Admins go to a player (`!goto`) or bring a player to them (`!bring`).

### What it does
- Without a name, the commands open the player list.
- **Teleport** section in the admin menu (`!admin`) with "Go to a player" and "Bring a player".
- Does not teleport players hanging from a ledge (that gets them stuck).
- Texts in Portuguese, English and Spanish (`translations/skynet_teleporte.phrases.txt`).

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_teleporte_l4d2` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_goto` / `!goto` | admin (flag `f`) | `sm_goto <player>` goes to the player (no name opens the list) |
| `sm_bring` / `!bring` | admin (flag `f`) | `sm_bring <player>` brings the player to you (no name opens the list) |
