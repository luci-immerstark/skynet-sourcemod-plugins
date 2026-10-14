# SKYNET Admin Tag

**Team Fortress 2** · v1.1 · `skynet_admtag.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Tag dourada `[ADM]` antes do nome dos administradores no chat.

### O que faz
- Mantém os prefixos normais do jogo: *DEAD*, (TEAM), (Spectator) e (Coach).
- Recebe a tag quem tem a flag `b` (generic) ou o override `sm_tag_adm`.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_admtag` no console.

### Permissão
Override `sm_tag_adm` (padrão: flag `b`). Para mudar quem tem acesso, use o `addons/sourcemod/configs/admin_overrides.cfg`.

## English

Gold `[ADM]` tag before admin names in chat.

### What it does
- Keeps the game's own prefixes: *DEAD*, (TEAM), (Spectator) and (Coach).
- Anyone with flag `b` (generic) or the `sm_tag_adm` override gets the tag.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_admtag` in the console.

### Permission
Override `sm_tag_adm` (default: flag `b`). To change who has access, use `addons/sourcemod/configs/admin_overrides.cfg`.
