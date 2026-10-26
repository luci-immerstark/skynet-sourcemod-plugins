# SKYNET Chat Limpo

**Team Fortress 2** · v1.0.0 · `skynet_chatlimpo.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Esconde do chat os avisos do console: mudança de cvar e entrada/saída de bots.

### O que faz
- Esconde as linhas `Server cvar 'x' changed to y`, que aparecem quando um plugin ou o console muda uma cvar.
- Esconde quando um bot entra, sai, troca de time ou troca de nome.
- Os avisos de jogadores de verdade continuam normais.
- Não tem cvars nem comandos: carregou, funciona.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_chatlimpo` no console.

### Observações
- Útil junto com o modo bot do [Auto Reflect](../skynet_autoreflect/), que muda cvars e coloca e tira bots.
- A mudança de cvar continua no console e nos logs do servidor; só sai do chat.

## English

Hides console notices from chat: cvar changes and bots joining or leaving.

### What it does
- Hides the `Server cvar 'x' changed to y` lines that show up when a plugin or the console changes a cvar.
- Hides bots joining, leaving, changing team or changing name.
- Notices for real players stay as they are.
- No cvars or commands: load it and it works.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_chatlimpo` in the console.

### Notes
- Handy together with the bot mode of [Auto Reflect](../skynet_autoreflect/), which changes cvars and adds and removes bots.
- Cvar changes still show in the server console and logs; they only leave the chat.
