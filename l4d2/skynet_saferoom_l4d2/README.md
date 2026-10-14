# SKYNET Saferoom Door

**Left 4 Dead 2** · v1.0 · `skynet_saferoom_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Avisa no chat quem abre e fecha a porta do abrigo e trava aberta a porta do abrigo inicial.

### O que faz
- Mostra quem abriu ou fechou a porta do abrigo inicial ou final.
- Depois de aberta, a porta do abrigo inicial não pode mais ser fechada até o fim da rodada (evita trollagem).

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (opcional: identifica a porta com mais precisão)

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_saferoom_l4d2` no console.

### Cvars
Coloque as cvars que quiser mudar no `cfg/server.cfg`.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_door_announce` | `1` | Avisa no chat quem abre e fecha a porta do abrigo |
| `skynet_door_lock_start` | `1` | Depois de aberta, a porta do abrigo inicial nao pode mais ser fechada |

## English

Announces who opens and closes the saferoom door and locks the starting door open.

### What it does
- Shows who opened or closed the starting or ending saferoom door.
- Once opened, the starting saferoom door cannot be closed again until the round ends (stops trolling).

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (optional: identifies the door more precisely)

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_saferoom_l4d2` in the console.

### Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_door_announce` | `1` | Announce in chat who opens and closes the saferoom door |
| `skynet_door_lock_start` | `1` | Once opened, the starting saferoom door can no longer be closed |
