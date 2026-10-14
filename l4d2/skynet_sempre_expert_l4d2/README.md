# SKYNET Always Expert / Sempre Expert

**Left 4 Dead 2** · v1.0 · `skynet_sempre_expert_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Mantém o servidor sempre na dificuldade Expert.

### O que faz
- Qualquer troca de dificuldade (pelo lobby ou por votação) volta para o Expert.
- Tira a opção "mudar dificuldade" da votação do jogo.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_sempre_expert_l4d2` no console.

### Cvars
Coloque as cvars que quiser mudar no `cfg/server.cfg`.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_sempre_expert` | `1` | 1 = o servidor fica sempre no Expert (0 = deixa trocar a dificuldade) |

## English

Keeps the server on Expert difficulty at all times.

### What it does
- Any difficulty change (from the lobby or a vote) is switched back to Expert.
- Removes the "change difficulty" option from the in-game vote.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_sempre_expert_l4d2` in the console.

### Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_sempre_expert` | `1` | 1 = server always stays on Expert (0 = allow difficulty changes) |
