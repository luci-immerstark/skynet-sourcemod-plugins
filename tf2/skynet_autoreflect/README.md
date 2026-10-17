# SKYNET Auto Reflect

**Team Fortress 2** · v3.0 · `skynet_autoreflect.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Dodgeball: auto reflect para admins e o modo TODOS CONTRA O BOT, aberto por votação.

### O que faz
- `!autoreflect` liga ou desliga o auto reflect em você (ou em outro jogador, com `!autoreflect <nome>`): a mira vira para o foguete e o sopro sai sozinho na hora certa. Todo mundo vê no chat quando ele é ligado ou desligado.
- O sopro só sai com o foguete dentro da área real do sopro do Pyro e com o sopro pronto, então continua funcionando quando o foguete fica muito rápido.
- `!votebot` abre uma votação de 20 segundos. Se mais da metade dos votos for **Sim**, entra o **SKYNET BOT**: um Pyro no time azul que fica parado onde nasce e rebate os foguetes. Todos os jogadores vão para o time vermelho, e quem entra depois vai direto para o vermelho.
- Com o modo ligado, `!votebot` abre a votação para tirar o bot e `!botoff` tira na hora. O modo também desliga sozinho na troca de mapa e quando o servidor esvazia.
- O bot não é imortal: se dois foguetes chegarem nele quase juntos, a recarga do sopro não dá tempo.

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
| `sm_votebot` / `!votebot` | admin (flag `k`) | Abre a votacao do modo TODOS CONTRA O BOT (ou para tirar o bot) |
| `sm_botoff` / `!botoff` | admin (flag `k`) | Tira o bot na hora |

### Cvars
Coloque as cvars que quiser mudar no `cfg/server.cfg`.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_autoreflect_frente` | `128` | Distancia do olho ate o centro da area do sopro |
| `skynet_autoreflect_lado` | `112` | Metade da largura da area do sopro usada (o jogo usa 128; menor = mais seguro) |
| `skynet_autoreflect_altura` | `56` | Metade da altura da area do sopro usada (o jogo usa 64; menor = mais seguro) |
| `skynet_autoreflect_emergencia` | `110` | Rebate qualquer foguete inimigo mais perto que isto, mesmo mirando outro jogador |
| `skynet_autoreflect_perto` | `180` | Com o foguete lento, espera ele chegar a esta distancia para soprar |

### Observações
- Os abates feitos com o auto reflect e pelo bot contam no ranking, se o servidor usar um (HLstatsX, HLstatsZ). O auto reflect de admin é bom para testar mapas e foguetes.

## English

Dodgeball: auto reflect for admins and an ALL VS BOT mode started by a vote.

### What it does
- `!autoreflect` toggles auto reflect on yourself (or on another player with `!autoreflect <name>`): your aim snaps to the rocket and the airblast fires at the right moment. Everyone sees in chat when it is turned on or off.
- It only airblasts with the rocket inside the Pyro's real airblast area and with the airblast ready, so it keeps working when rockets get very fast.
- `!votebot` opens a 20-second vote. If more than half of the votes are **Yes**, **SKYNET BOT** joins: a Pyro on BLU that stands still where it spawns and reflects rockets. Every player goes to RED, and anyone who joins later goes straight to RED.
- While the mode is on, `!votebot` opens a vote to remove the bot and `!botoff` removes it right away. The mode also turns off on map change and when the server empties.
- The bot is not immortal: if two rockets reach it almost together, the airblast cooldown is too short to stop both.

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
| `sm_votebot` / `!votebot` | admin (flag `k`) | Opens the ALL VS BOT vote (or the vote to remove the bot) |
| `sm_botoff` / `!botoff` | admin (flag `k`) | Removes the bot right away |

### Cvars
Put any cvars you want to change in `cfg/server.cfg`.

| Cvar | Default | Description |
|---|---|---|
| `skynet_autoreflect_frente` | `128` | Distance from the eye to the center of the airblast area |
| `skynet_autoreflect_lado` | `112` | Half the width of the airblast area used (the game uses 128; smaller = safer) |
| `skynet_autoreflect_altura` | `56` | Half the height of the airblast area used (the game uses 64; smaller = safer) |
| `skynet_autoreflect_emergencia` | `110` | Reflects any enemy rocket closer than this, even one aimed at another player |
| `skynet_autoreflect_perto` | `180` | With a slow rocket, waits until it is this close before airblasting |

### Notes
- Kills made with auto reflect and by the bot count in the ranking if the server uses one (HLstatsX, HLstatsZ). Admin auto reflect is handy for testing maps and rockets.
