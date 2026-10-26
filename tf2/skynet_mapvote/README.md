# SKYNET Map Vote

**Team Fortress 2** · v1.5 · `skynet_mapvote.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Votação do próximo mapa com opções sorteadas por hype, tempo sem jogar e tempo fora da votação.

### O que faz
- Cada mapa recebe uma nota de **hype** de 0 a 5 no arquivo `configs/skynet_mapvote.txt`. Quanto maior a nota, mais o mapa aparece na votação.
- Mapas jogados nas últimas partidas ficam fora da votação (`skynet_mapvote_cooldown`).
- Mapas que estão há muito tempo sem ser jogados ou sem aparecer na votação ganham bônus. Se um mapa passa muitas votações sem aparecer, ganha vaga garantida (`skynet_mapvote_starve`).
- **Modo por tempo** (padrão): a votação abre quando faltam `skynet_mapvote_before` segundos para o fim do `mp_timelimit`. É o ideal para Dodgeball e mapas com tempo.
- **Modo por rodadas**: com `skynet_mapvote_before 0`, a votação abre `skynet_mapvote_delay` segundos depois do início da última rodada (`mp_maxrounds`).
- O mapa vencedor vira o próximo mapa (`nextmap`). Se ninguém votar, vale a primeira opção.
- O histórico fica salvo em `configs/skynet_mapvote_state.txt` e continua depois de reiniciar o servidor.
- Mapas da lista que não estão instalados são ignorados (aparece um aviso no log de erros).
- **Estender**: toda votação de fim de mapa tem uma opção fixa a mais, `Estender <mapa atual> (+10 min)`. Se ela ganhar, o `mp_timelimit` cresce `skynet_mapvote_extend` minutos (e o `mp_maxrounds` ganha mais 1 rodada, se estiver em uso) e a votação volta perto do novo fim. Os valores originais voltam na troca de mapa.
- **!rtv**: quando `skynet_rtv_needed` dos jogadores (padrão: 60%) digita `!rtv` (ou só `rtv`), abre uma votação para trocar de mapa agora. A opção fixa dela é `Continuar em <mapa atual>`. Se um mapa ganhar, a troca acontece em 5 segundos. Se o próximo mapa já tinha sido escolhido, o servidor vai direto para ele.
- **!nominate**: abre um menu com os mapas em ordem alfabética para indicar um para a próxima votação (`!nominate <parte do nome>` filtra). Cada jogador indica um mapa; indicar outro troca o seu. Os indicados entram primeiro na votação, na ordem das indicações, e o resto das vagas é sorteado como sempre. O mapa atual, os mapas com hype 0 e os que estão em cooldown não podem ser indicados.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Team Fortress 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/tf/`), juntando com a que já existe.
2. Edite `addons/sourcemod/configs/skynet_mapvote.txt` com os mapas do seu servidor e o hype de cada um (0 a 5).
3. Reinicie o servidor ou digite `sm plugins load skynet_mapvote` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_mapvote_status` / `!mapvote_status` | admin (flag `g`) | Mostra o hype, o historico e o peso de cada mapa |
| `sm_mapvote_now` / `!mapvote_now` | admin (flag `g`) | Inicia agora a votacao do proximo mapa |
| `sm_rtv` / `!rtv` (ou `rtv`, `rockthevote`) | todos | Vota para trocar de mapa agora |
| `sm_nominate` / `!nominate [busca]` (ou `nominate`) | todos | Indica um mapa para a proxima votacao |

### Cvars
O arquivo `cfg/sourcemod/skynet_mapvote.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_mapvote_time` | `20` | Duracao da votacao, em segundos |
| `skynet_mapvote_cooldown` | `3` | Mapas jogados nas ultimas N partidas ficam fora da votacao |
| `skynet_mapvote_starve` | `12` | Mapa que nao aparece na votacao ha N votacoes ganha vaga garantida |
| `skynet_mapvote_options` | `3` | Quantidade de mapas em cada votacao |
| `skynet_mapvote_hype_exp` | `2.5` | Forca do hype no sorteio (hype elevado a este numero) |
| `skynet_mapvote_recent_penalty` | `0.8` | Multiplicador para quem apareceu na ultima votacao |
| `skynet_mapvote_vote_grow` | `0.10` | Bonus por votacao sem aparecer |
| `skynet_mapvote_vote_cap` | `1.8` | Bonus maximo por tempo fora da votacao |
| `skynet_mapvote_play_grow` | `0.10` | Bonus por partida sem ser jogado (depois do cooldown) |
| `skynet_mapvote_play_cap` | `1.8` | Bonus maximo por tempo sem ser jogado |
| `skynet_mapvote_delay` | `180` | Segundos depois do inicio da ultima rodada para abrir a votacao |
| `skynet_mapvote_before` | `180` | Abre a votacao quando faltar este tempo (segundos) para o fim do mapa pelo mp_timelimit. 0 = usa o modo por rodadas |
| `skynet_mapvote_extend` | `10` | Minutos a mais quando a votacao escolhe estender o mapa atual. 0 = sem essa opcao |
| `skynet_rtv_needed` | `0.60` | Fracao dos jogadores que precisa digitar !rtv para trocar de mapa |
| `skynet_rtv_delay` | `60` | Segundos depois do inicio do mapa para liberar o !rtv |
| `skynet_rtv_interval` | `240` | Se a maioria escolher continuar, segundos ate o !rtv valer de novo |

### Observações
- Desative os plugins de mapa que vêm no SourceMod (`mapchooser.smx`, `rockthevote.smx`, `nominations.smx`): este plugin já faz o papel dos três, e com eles ligados abririam duas votações.

### Mudanças desde a 1.2
- 1.3: opção fixa de estender o mapa atual.
- 1.4: `!rtv`.
- 1.5: `!nominate`.

## English

Next-map vote whose options are drawn by hype, time since last played and time since last shown.

### What it does
- Each map gets a **hype** score from 0 to 5 in `configs/skynet_mapvote.txt`. Higher hype means the map shows up more often.
- Maps played in the last few matches are left out of the vote (`skynet_mapvote_cooldown`).
- Maps that have not been played or shown for a while get a bonus. A map that misses many votes in a row gets a guaranteed slot (`skynet_mapvote_starve`).
- **Time mode** (default): the vote opens when `skynet_mapvote_before` seconds are left on `mp_timelimit`. Best for Dodgeball and timed maps.
- **Round mode**: with `skynet_mapvote_before 0`, the vote opens `skynet_mapvote_delay` seconds after the last round starts (`mp_maxrounds`).
- The winning map becomes the `nextmap`. If nobody votes, the first option wins.
- History is saved to `configs/skynet_mapvote_state.txt` and survives server restarts.
- Maps in the list that are not installed are skipped (a warning goes to the error log).
- **Extend**: every end-of-map vote has one extra fixed option, `Estender <current map> (+10 min)`. If it wins, `mp_timelimit` grows by `skynet_mapvote_extend` minutes (and `mp_maxrounds` gets 1 more round, if used) and the vote comes back near the new end. The original values return on map change.
- **!rtv**: when `skynet_rtv_needed` of the players (default: 60%) type `!rtv` (or just `rtv`), a vote to change map right now opens. Its fixed option is `Continuar em <current map>` (stay). If a map wins, the change happens in 5 seconds. If the next map was already chosen, the server goes straight to it.
- **!nominate**: opens a menu with the maps in alphabetical order to nominate one for the next vote (`!nominate <part of the name>` filters). Each player nominates one map; nominating another replaces theirs. Nominated maps go into the vote first, in nomination order, and the remaining slots are drawn as usual. The current map, maps with hype 0 and maps on cooldown cannot be nominated.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Team Fortress 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/tf/`), merging with the existing one.
2. Edit `addons/sourcemod/configs/skynet_mapvote.txt` with your server's maps and each one's hype (0 to 5).
3. Restart the server or run `sm plugins load skynet_mapvote` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_mapvote_status` / `!mapvote_status` | admin (flag `g`) | Shows hype, history and weight of each map |
| `sm_mapvote_now` / `!mapvote_now` | admin (flag `g`) | Starts the next-map vote now |
| `sm_rtv` / `!rtv` (or `rtv`, `rockthevote`) | everyone | Votes to change map now |
| `sm_nominate` / `!nominate [search]` (or `nominate`) | everyone | Nominates a map for the next vote |

### Cvars
`cfg/sourcemod/skynet_mapvote.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_mapvote_time` | `20` | Vote duration, in seconds |
| `skynet_mapvote_cooldown` | `3` | Maps played in the last N matches are left out of the vote |
| `skynet_mapvote_starve` | `12` | A map missing from the last N votes gets a guaranteed slot |
| `skynet_mapvote_options` | `3` | Number of maps in each vote |
| `skynet_mapvote_hype_exp` | `2.5` | Weight of hype in the draw (hype raised to this power) |
| `skynet_mapvote_recent_penalty` | `0.8` | Multiplier for maps shown in the previous vote |
| `skynet_mapvote_vote_grow` | `0.10` | Bonus per vote without being shown |
| `skynet_mapvote_vote_cap` | `1.8` | Maximum bonus for time without being shown |
| `skynet_mapvote_play_grow` | `0.10` | Bonus per match without being played (after the cooldown) |
| `skynet_mapvote_play_cap` | `1.8` | Maximum bonus for time without being played |
| `skynet_mapvote_delay` | `180` | Round mode: seconds after the last round starts before opening the vote |
| `skynet_mapvote_before` | `180` | Time mode: open the vote when this many seconds are left on mp_timelimit. 0 = round mode |
| `skynet_mapvote_extend` | `10` | Extra minutes when the vote picks extending the current map. 0 = no extend option |
| `skynet_rtv_needed` | `0.60` | Fraction of players who must type !rtv to change map |
| `skynet_rtv_delay` | `60` | Seconds after the map starts before !rtv is allowed |
| `skynet_rtv_interval` | `240` | If most players choose to stay, seconds until !rtv counts again |

### Notes
- Disable SourceMod's own map plugins (`mapchooser.smx`, `rockthevote.smx`, `nominations.smx`): this plugin covers all three, and with them loaded two votes would open.

### Changes since 1.2
- 1.3: fixed option to extend the current map.
- 1.4: `!rtv`.
- 1.5: `!nominate`.
