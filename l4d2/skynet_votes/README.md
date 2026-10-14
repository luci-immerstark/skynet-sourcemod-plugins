# SKYNET Votes

**Left 4 Dead 2** · v1.0 · `skynet_votes.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Só admins abrem as votações do jogo (dificuldade, kick, reiniciar, trocar campanha, lobby).

### O que faz
- Jogadores comuns que tentam abrir uma votação pelo menu ESC recebem um aviso no chat.
- Libere votações específicas para todos em `skynet_votes_allow` (ex.: `Kick,ChangeAllTalk`).
- Pode abrir votações quem tem a flag `b` (generic) ou o override `skynet_callvote`.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_votes` no console.

### Cvars
O arquivo `cfg/sourcemod/skynet_votes.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_votes_allow` | `""` | Votacoes que jogadores comuns podem abrir, separadas por virgula (ex.: Kick,ChangeAllTalk). Vazio = so admins |

### Permissão
Override `skynet_callvote` (padrão: flag `b`). Para mudar quem tem acesso, use o `addons/sourcemod/configs/admin_overrides.cfg`.

## English

Only admins can call the game's votes (difficulty, kick, restart, change campaign, lobby).

### What it does
- Regular players who try to call a vote from the ESC menu get a chat notice.
- Allow specific votes for everyone in `skynet_votes_allow` (e.g. `Kick,ChangeAllTalk`).
- Anyone with flag `b` (generic) or the `skynet_callvote` override can call votes.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_votes` in the console.

### Cvars
`cfg/sourcemod/skynet_votes.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_votes_allow` | `""` | Votes regular players may call, comma separated (e.g. Kick,ChangeAllTalk). Empty = admins only |

### Permission
Override `skynet_callvote` (default: flag `b`). To change who has access, use `addons/sourcemod/configs/admin_overrides.cfg`.
