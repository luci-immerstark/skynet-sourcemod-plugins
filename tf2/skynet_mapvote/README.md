# SKYNET Map Vote

**Team Fortress 2** · v1.2 · `skynet_mapvote.smx`

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

### Observações
- Desative outras votações de fim de mapa (`mapchooser.smx`, `rockthevote.smx`) para não abrir duas votações ao mesmo tempo.

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

### Notes
- Disable other end-of-map votes (`mapchooser.smx`, `rockthevote.smx`) so two votes do not open at once.
