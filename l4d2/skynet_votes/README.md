# SKYNET Votes

**Left 4 Dead 2** · v1.1 · `skynet_votes.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Desliga as votações do menu do jogo (dificuldade, kick, reiniciar, trocar campanha, lobby), com aviso na tela.

### O que faz
- Quem tenta abrir uma votação pelo menu ESC recebe um aviso no meio da tela e no chat (o menu de votação cobre o chat).
- Por padrão ninguém abre votações pelo menu, nem os admins: eles usam o `!admin` para kick e troca de campanha.
- Com `skynet_votes_admins 1`, quem tem a flag `b` (generic) ou o override `skynet_callvote` volta a abrir votações pelo menu.
- Libere votações específicas para todos em `skynet_votes_allow` (ex.: `Kick,ChangeAllTalk`).

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
| `skynet_votes_allow` | `""` | Votacoes do menu que continuam liberadas pra todos, separadas por virgula (ex.: Kick,ChangeAllTalk). Vazio = nenhuma |
| `skynet_votes_admins` | `0` | 1 = admins (override skynet_callvote, flag b) ainda abrem votacoes pelo menu; 0 = ninguem abre |

### Mudanças da 1.1
- Nova cvar `skynet_votes_admins`. O padrão (0) desliga as votações do menu também para os admins.
- Aviso no meio da tela, além do chat.

### Permissão
Override `skynet_callvote` (padrão: flag `b`), usado com `skynet_votes_admins 1`. Para mudar quem tem acesso, use o `addons/sourcemod/configs/admin_overrides.cfg`.

## English

Turns off the game's menu votes (difficulty, kick, restart, change campaign, lobby), with an on-screen notice.

### What it does
- Anyone who tries to call a vote from the ESC menu gets a notice in the middle of the screen and in chat (the vote menu covers the chat).
- By default nobody can call menu votes, admins included: they use `!admin` to kick and change campaign.
- With `skynet_votes_admins 1`, anyone with flag `b` (generic) or the `skynet_callvote` override can call menu votes again.
- Allow specific votes for everyone in `skynet_votes_allow` (e.g. `Kick,ChangeAllTalk`).

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
| `skynet_votes_allow` | `""` | Menu votes still open to everyone, comma separated (e.g. Kick,ChangeAllTalk). Empty = none |
| `skynet_votes_admins` | `0` | 1 = admins (skynet_callvote override, flag b) can still call menu votes; 0 = nobody can |

### Changes in 1.1
- New `skynet_votes_admins` cvar. The default (0) turns menu votes off for admins too.
- On-screen notice, besides the chat.

### Permission
Override `skynet_callvote` (default: flag `b`), used with `skynet_votes_admins 1`. To change who has access, use `addons/sourcemod/configs/admin_overrides.cfg`.
