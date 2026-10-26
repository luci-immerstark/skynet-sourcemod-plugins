# SKYNET Admin Tag

**Team Fortress 2** · v1.2 · `skynet_admtag.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Tag dourada `[ADM]` antes do nome dos administradores e tag azul `[MOD]` antes do nome dos moderadores no chat.

### O que faz
- Mantém os prefixos normais do jogo: *DEAD*, (TEAM), (Spectator) e (Coach).
- `[ADM]` (dourada): quem tem a flag `d` (ban) ou o override `sm_tag_adm`.
- `[MOD]` (azul): quem não é admin, mas tem a flag `b` (generic) ou o override `sm_tag_mod`. Um moderador típico tem as flags de kick, troca de mapa e votação, sem a de ban.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_admtag` no console.

### Permissão
Overrides `sm_tag_adm` (padrão: flag `d`) e `sm_tag_mod` (padrão: flag `b`). Para mudar quem recebe cada tag, use o `addons/sourcemod/configs/admin_overrides.cfg`.

### Mudanças da 1.2
- Nova tag `[MOD]` para moderadores.
- A tag `[ADM]` agora pede a flag `d` (ban) em vez da `b`.

## English

Gold `[ADM]` tag before admin names and blue `[MOD]` tag before moderator names in chat.

### What it does
- Keeps the game's own prefixes: *DEAD*, (TEAM), (Spectator) and (Coach).
- `[ADM]` (gold): anyone with flag `d` (ban) or the `sm_tag_adm` override.
- `[MOD]` (blue): anyone who is not an admin but has flag `b` (generic) or the `sm_tag_mod` override. A typical moderator has the kick, map change and vote flags, without ban.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_admtag` in the console.

### Permission
Overrides `sm_tag_adm` (default: flag `d`) and `sm_tag_mod` (default: flag `b`). To change who gets each tag, use `addons/sourcemod/configs/admin_overrides.cfg`.

### Changes in 1.2
- New `[MOD]` tag for moderators.
- The `[ADM]` tag now needs flag `d` (ban) instead of `b`.
