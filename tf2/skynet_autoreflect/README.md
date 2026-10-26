# SKYNET Auto Reflect

**Team Fortress 2** · v4.2 · `skynet_autoreflect.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Dodgeball: auto reflect para admins e o modo TODOS CONTRA O BOT automático quando há poucos jogadores.

### O que faz
- `!autoreflect` liga ou desliga o auto reflect em você (ou em outro jogador, com `!autoreflect <nome>`): a mira vira para o foguete e o sopro sai sozinho na hora certa. Todo mundo vê no chat quando ele é ligado ou desligado.
- O sopro só sai com o foguete dentro da área real do sopro do Pyro e com o sopro pronto, então continua funcionando quando o foguete fica muito rápido.
- **Modo TODOS CONTRA O BOT automático:** com 1 a 3 jogadores nos times (menos que `skynet_bot_jogadores`), entra o **SKYNET BOT**, um Pyro no time azul, e todos os jogadores vão para o time vermelho. Quem entra depois vai direto para o vermelho.
- Quando o 4º jogador entra num time, o bot sai, os times são embaralhados (2x2) e o jogo volta ao normal. A troca espera 5 segundos com o mesmo número de jogadores, para não ficar ligando e desligando. Com o servidor vazio, o bot sai.
- O bot fica parado onde nasce e rebate qualquer foguete inimigo que venha na direção dele assim que o foguete entra na área do sopro. O sopro dele não tem recarga, então ele rebate quase tudo, mesmo de perto.
- Só existe um bot: o plugin zera o `tf_bot_quota` e tira qualquer outro bot, para o jogo não ficar colocando bots aleatórios.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2 com o modo Dodgeball
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): opcional, mas recomendado. Com ele, o plugin sabe qual foguete está mirando em quem; sem ele, decide pela posição e pela direção do foguete.

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_autoreflect` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_autoreflect` / `!autoreflect` | admin (flag `z`) | Liga/desliga o auto reflect (sem nome = em voce) |

### Cvars
Coloque as cvars que quiser mudar no `cfg/server.cfg`.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_bot_auto` | `1` | 1 = com poucos jogadores nos times, todos contra o SKYNET BOT |
| `skynet_bot_jogadores` | `4` | Com este numero de jogadores nos times o bot sai e o jogo fica normal |
| `skynet_autoreflect_frente` | `128` | Distancia do olho ate o centro da area do sopro |
| `skynet_autoreflect_lado` | `112` | Metade da largura da area do sopro usada (o jogo usa 128; menor = mais seguro) |
| `skynet_autoreflect_altura` | `56` | Metade da altura da area do sopro usada (o jogo usa 64; menor = mais seguro) |
| `skynet_autoreflect_emergencia` | `110` | Rebate qualquer foguete inimigo mais perto que isto, mesmo mirando outro jogador |
| `skynet_autoreflect_perto` | `180` | Com o foguete lento, espera ele chegar a esta distancia para soprar |

### Observações
- Com o modo bot ligado, o plugin deixa `mp_autoteambalance` e `mp_teams_unbalance_limit` em 0. Quando o bot sai, os dois voltam para 1.
- Não use junto com outro plugin que coloque bots, nem com `tf_bot_quota` no `server.cfg`.
- Para o ranking (HLstatsX, HLstatsZ) não contar o treino contra o bot, configure nele um mínimo de 4 jogadores e para ignorar bots.
- O [Chat Limpo](../skynet_chatlimpo/) esconde do chat as mensagens de cvar e de bot que o modo bot gera.

### Mudanças desde a 3.0
- 4.0: o modo TODOS CONTRA O BOT liga e desliga sozinho pelo número de jogadores. Saíram os comandos `!votebot` e `!botoff`.
- 4.1: zera o `tf_bot_quota` antes de tirar bots (o jogo colocava bots aleatórios de volta).
- 4.2: o bot rebate quase tudo, inclusive de perto, e funciona bem em servidores de 100 tick.

## English

Dodgeball: auto reflect for admins and an automatic ALL VS BOT mode when there are few players.

### What it does
- `!autoreflect` toggles auto reflect on yourself (or on another player with `!autoreflect <name>`): your aim snaps to the rocket and the airblast fires at the right moment. Everyone sees in chat when it is turned on or off.
- It only airblasts with the rocket inside the Pyro's real airblast area and with the airblast ready, so it keeps working when rockets get very fast.
- **Automatic ALL VS BOT mode:** with 1 to 3 players on the teams (fewer than `skynet_bot_jogadores`), **SKYNET BOT** joins as a Pyro on BLU and every player goes to RED. Anyone who joins later goes straight to RED.
- When the 4th player joins a team, the bot leaves, the teams are scrambled (2v2) and the game goes back to normal. The switch waits for 5 seconds with the same player count, so it does not flip back and forth. On an empty server, the bot leaves.
- The bot stands still where it spawns and reflects any enemy rocket heading its way as soon as the rocket enters the airblast area. Its airblast has no cooldown, so it reflects almost everything, even at close range.
- There is only one bot: the plugin sets `tf_bot_quota` to 0 and removes any other bot, so the game does not keep adding random bots.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2 running Dodgeball
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): optional but recommended. With it, the plugin knows which rocket targets whom; without it, it decides by the rocket's position and direction.

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_autoreflect` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_autoreflect` / `!autoreflect` | admin (flag `z`) | Toggles auto reflect (no name = on yourself) |

### Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_bot_auto` | `1` | 1 = with few players on the teams, everyone against SKYNET BOT |
| `skynet_bot_jogadores` | `4` | With this many players on the teams the bot leaves and the game is normal |
| `skynet_autoreflect_frente` | `128` | Distance from the eye to the center of the airblast area |
| `skynet_autoreflect_lado` | `112` | Half the width of the airblast area used (the game uses 128; smaller = safer) |
| `skynet_autoreflect_altura` | `56` | Half the height of the airblast area used (the game uses 64; smaller = safer) |
| `skynet_autoreflect_emergencia` | `110` | Reflects any enemy rocket closer than this, even one aimed at another player |
| `skynet_autoreflect_perto` | `180` | With a slow rocket, waits until it is this close before airblasting |

### Notes
- While the bot mode is on, the plugin sets `mp_autoteambalance` and `mp_teams_unbalance_limit` to 0. When the bot leaves, both go back to 1.
- Do not use it with another plugin that adds bots, or with `tf_bot_quota` in `server.cfg`.
- To keep bot practice out of the ranking (HLstatsX, HLstatsZ), set it to need at least 4 players and to ignore bots.
- [Chat Limpo](../skynet_chatlimpo/) hides the cvar and bot messages the bot mode causes.

### Changes since 3.0
- 4.0: the ALL VS BOT mode turns on and off by itself based on the player count. The `!votebot` and `!botoff` commands are gone.
- 4.1: sets `tf_bot_quota` to 0 before removing bots (the game kept adding random bots back).
- 4.2: the bot reflects almost everything, even at close range, and works well on 100-tick servers.
