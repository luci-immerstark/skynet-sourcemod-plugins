# SKYNET Next Campaign / Próxima Campanha

**Left 4 Dead 2** · v1.6 · `skynet_campanhas_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Votação da próxima campanha na fase final, troca automática depois do resgate e menu de campanhas para admins.

### O que faz
- Na fase final, alguns segundos depois de o time sair do abrigo, abre a votação da próxima campanha (teclas 1 a N).
- As opções são sorteadas com peso: campanhas jogadas há pouco ficam de fora e as que estão há mais tempo sem aparecer ganham bônus e vaga garantida.
- Depois do resgate, espera os créditos e troca para o primeiro capítulo da campanha escolhida, com a abertura da campanha normal.
- Se o time perder na fase final, a escolha continua valendo e a votação não abre de novo.
- `!proxima` mostra a próxima campanha para qualquer jogador.
- No menu de admin (`!admin`): **Trocar campanha** (troca agora) e **Votar campanha** (abre a votação; a troca só acontece depois do resgate).
- Cobre as 14 campanhas oficiais (c1 a c14). O histórico fica salvo em `data/skynet_campanhas.txt`.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (recomendado: sem ele a detecção do resgate e da saída do abrigo fica mais simples)

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_campanhas_l4d2` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_proxima` / `!proxima` | todos | Mostra a proxima campanha |
| `sm_campanha_trocar` / `!campanha_trocar` | admin (flag `g`) | Troca de campanha agora (comeca do primeiro capitulo) |
| `sm_campanha_votar` / `!campanha_votar` | admin (flag `k`) | Votacao da proxima campanha (a troca so acontece depois do resgate) |
| `sm_campanha_status` / `!campanha_status` | admin (flag `g`) | Mostra o historico e o peso de cada campanha |

### Cvars
O arquivo `cfg/sourcemod/skynet_campanhas_l4d2.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_campanha_tempo` | `25` | Duracao da votacao, em segundos |
| `skynet_campanha_opcoes` | `3` | Quantas campanhas aparecem na votacao |
| `skynet_campanha_cooldown` | `3` | Campanhas jogadas nas ultimas N campanhas ficam fora da votacao |
| `skynet_campanha_starve` | `4` | Campanha que nao aparece ha N votacoes ganha vaga garantida |
| `skynet_campanha_espera` | `20` | Segundos depois de sair do abrigo, na fase final, para abrir a votacao |
| `skynet_campanha_troca` | `15` | Segundos maximos depois do resgate para trocar, se o fim do resgate nao for detectado |
| `skynet_campanha_penalidade` | `0.25` | Multiplicador para quem apareceu na votacao anterior e nao ganhou |
| `skynet_campanha_vote_grow` | `0.20` | Bonus por votacao sem aparecer |
| `skynet_campanha_vote_cap` | `2.0` | Bonus maximo por tempo fora da votacao |
| `skynet_campanha_play_grow` | `0.30` | Bonus por campanha sem ser jogada (depois do cooldown) |
| `skynet_campanha_play_cap` | `3.0` | Bonus maximo por tempo sem ser jogada |
| `skynet_campanha_atraso` | `12` | Segundos de creditos e musica final, depois que a tela escurece no fim do resgate, antes de trocar de campanha |
| `skynet_campanha_abertura` | `1` | 1 = troca pelo caminho da votacao do jogo (a abertura da campanha aparece), 0 = changelevel |

## English

Next-campaign vote during the finale, automatic switch after the rescue, and a campaign menu for admins.

### What it does
- During the finale, a few seconds after the team leaves the saferoom, a vote for the next campaign opens (keys 1 to N).
- Options are drawn by weight: recently played campaigns are left out, and the ones missing for longer get a bonus and a guaranteed slot.
- After the rescue it waits for the credits and switches to the first chapter of the chosen campaign, with the normal campaign intro.
- If the team loses the finale, the choice still stands and the vote does not open again.
- `!proxima` shows the next campaign to any player.
- Admin menu (`!admin`): **Trocar campanha** (switches now) and **Votar campanha** (opens the vote; the switch only happens after the rescue).
- Covers the 14 official campaigns (c1 to c14). History is saved to `data/skynet_campanhas.txt`.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (recommended: without it, rescue and saferoom-exit detection is simpler)

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_campanhas_l4d2` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_proxima` / `!proxima` | everyone | Shows the next campaign |
| `sm_campanha_trocar` / `!campanha_trocar` | admin (flag `g`) | Changes campaign now (starts at chapter 1) |
| `sm_campanha_votar` / `!campanha_votar` | admin (flag `k`) | Opens the next-campaign vote (switch happens after the rescue) |
| `sm_campanha_status` / `!campanha_status` | admin (flag `g`) | Shows history and weight of each campaign |

### Cvars
`cfg/sourcemod/skynet_campanhas_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_campanha_tempo` | `25` | Vote duration, in seconds |
| `skynet_campanha_opcoes` | `3` | Number of campaigns in the vote |
| `skynet_campanha_cooldown` | `3` | Campaigns played in the last N campaigns are left out of the vote |
| `skynet_campanha_starve` | `4` | A campaign missing from the last N votes gets a guaranteed slot |
| `skynet_campanha_espera` | `20` | Seconds after leaving the saferoom, in the finale, before opening the vote |
| `skynet_campanha_troca` | `15` | Maximum seconds after the rescue to switch, if the end of the rescue is not detected |
| `skynet_campanha_penalidade` | `0.25` | Multiplier for campaigns shown in the previous vote that did not win |
| `skynet_campanha_vote_grow` | `0.20` | Bonus per vote without being shown |
| `skynet_campanha_vote_cap` | `2.0` | Maximum bonus for time without being shown |
| `skynet_campanha_play_grow` | `0.30` | Bonus per campaign without being played (after the cooldown) |
| `skynet_campanha_play_cap` | `3.0` | Maximum bonus for time without being played |
| `skynet_campanha_atraso` | `12` | Seconds of credits and ending music, after the screen fades at the end of the rescue, before switching |
| `skynet_campanha_abertura` | `1` | 1 = switch through the game's vote path (campaign intro plays), 0 = changelevel |
