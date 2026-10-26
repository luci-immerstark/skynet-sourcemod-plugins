# SKYNET Projéteis

**Team Fortress 2** · v1.0.0 · `skynet_projeteis.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Quando um jogador morre, os projéteis dele somem do mapa.

### O que faz
- Na morte, remove todos os projéteis (`tf_projectile_*`) do jogador: foguetes, granadas, stickies, flechas, flares e os outros.
- Quem finge a morte com o Dead Ringer não perde os projéteis.
- Pode ser desligado sem descarregar o plugin com `skynet_projeteis 0`.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_projeteis` no console.

### Cvars
Coloque as cvars que quiser mudar no `cfg/server.cfg`.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_projeteis` | `1` | 1 = os projéteis de quem morre somem; 0 = desliga |

### Observações
- Deixe fora de servidores de Dodgeball: lá o foguete passa a ser de quem rebateu por último, e ele sumiria se essa pessoa morresse.

## English

When a player dies, their projectiles vanish from the map.

### What it does
- On death, removes every projectile (`tf_projectile_*`) owned by the player: rockets, grenades, stickies, arrows, flares and the rest.
- A Spy faking death with the Dead Ringer keeps their projectiles.
- Can be turned off without unloading the plugin with `skynet_projeteis 0`.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_projeteis` in the console.

### Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_projeteis` | `1` | 1 = projectiles of a dead player vanish; 0 = off |

### Notes
- Keep it off Dodgeball servers: there the rocket belongs to whoever reflected it last, and it would vanish if that player died.
