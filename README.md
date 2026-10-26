# SKYNET GAMING · SourceMod Plugins

Plugins para **Team Fortress 2** e **Left 4 Dead 2** criados pela comunidade **SKYNET GAMING BRASIL / LATAM** e usados nos nossos servidores.

*SourceMod plugins for **Team Fortress 2** and **Left 4 Dead 2**, made by the **SKYNET GAMING BRASIL / LATAM** community and running on our servers.*

[Português](#português) · [English](#english)

## Português

As mensagens que os plugins mostram no chat estão em português (alguns também em espanhol). Cada plugin funciona sozinho: instale só os que quiser.

### Team Fortress 2

| Plugin | O que faz | Versão |
|---|---|---|
| [Map Vote](tf2/skynet_mapvote/) | Votação do próximo mapa com opções sorteadas por hype, tempo sem jogar e tempo fora da votação, opção de estender o mapa, `!rtv` e `!nominate`. | 1.5 |
| [Robots](tf2/skynet_robot/) | Comando `!robot`: o jogador vira um robô do Mann vs. Machine. | 1.0 |
| [Taunts](tf2/skynet_taunts/) | Menu `!taunt` com todas as taunts do jogo, mesmo as que o jogador não tem no inventário. | 1.0 |
| [Admin Tag](tf2/skynet_admtag/) | Tag dourada `[ADM]` para administradores e azul `[MOD]` para moderadores no chat. | 1.2 |
| [Welcome](tf2/skynet_welcome/) | Mensagem de boas-vindas no chat, uma vez por conexão. | 1.1 |
| [Bot Names](tf2/skynet_botnames/) | Nomes fixos para os bots e chat limpo nas entradas e saídas deles. | 1.1 |
| [Pyro Only](tf2/skynet_pyroonly/) | Para servidores de Dodgeball: todo mundo joga de Pyro. | 1.0 |
| [Auto Reflect](tf2/skynet_autoreflect/) | Dodgeball: auto reflect para admins e o modo TODOS CONTRA O BOT automático com 1 a 3 jogadores. | 4.2 |
| [Nuke](tf2/skynet_nuke/) | Dodgeball: o foguete NUKE fica maior que os outros. | 2.0 |
| [Entrada](tf2/skynet_entrada/) | Avisa no chat quem entrou no servidor e de qual país. | 1.0.0 |
| [FOV](tf2/skynet_fov/) | `!fov <número>` para mudar o campo de visão, com o valor salvo. | 1.1.0 |
| [Terceira Pessoa](tf2/skynet_terceira/) | `!tp` para jogar em terceira pessoa e `!fp` para voltar. | 1.0.0 |
| [Chat Limpo](tf2/skynet_chatlimpo/) | Esconde do chat os avisos de cvar e de entrada e saída de bots. | 1.0.0 |
| [Projéteis](tf2/skynet_projeteis/) | Os projéteis de quem morre somem do mapa. | 1.0.0 |

### Left 4 Dead 2

| Plugin | O que faz | Versão |
|---|---|---|
| [Próxima Campanha](l4d2/skynet_campanhas_l4d2/) | Votação da próxima campanha na fase final, troca automática depois do resgate e menu de campanhas para admins. | 1.6 |
| [Pontos por Sessão](l4d2/skynet_pontos_sessao_l4d2/) | Os pontos da loja (Points System) duram a campanha inteira. | 1.1 |
| [Points Messages](l4d2/skynet_points_msg_l4d2/) | Mensagens de pontos e de compras do Points System em português. | 1.0 |
| [Arsenal](l4d2/skynet_arsenal_l4d2/) | Coloca várias armas de fogo e corpo a corpo no abrigo inicial de cada capítulo. | 1.0 |
| [Saferoom Door](l4d2/skynet_saferoom_l4d2/) | Avisa no chat quem abre e fecha a porta do abrigo e trava aberta a porta do abrigo inicial. | 1.0 |
| [Rejoin](l4d2/skynet_rejoin_l4d2/) | No início de cada rodada, devolve ao time quem ficou preso como espectador ou morto. | 1.1 |
| [Hordas](l4d2/skynet_hordas_l4d2/) | Hordas de zumbis comuns proporcionais ao número de sobreviventes vivos. | 1.1 |
| [Sem Fogo Amigo](l4d2/skynet_semfogoamigo_l4d2/) | Sem fogo amigo entre sobreviventes, com regras próprias para fogo e explosões. | 1.3 |
| [Teleporte](l4d2/skynet_teleporte_l4d2/) | Admins vão até um jogador (`!goto`) ou trazem um jogador até eles (`!bring`). | 1.1 |
| [Sempre Expert](l4d2/skynet_sempre_expert_l4d2/) | Mantém o servidor sempre na dificuldade Expert. | 1.0 |
| [Jogo com Ausentes](l4d2/skynet_ausentes_l4d2/) | A partida continua quando todos os jogadores ficam ausentes (idle). | 1.0 |
| [Sem !map](l4d2/skynet_sem_map_l4d2/) | Bloqueia `!map` e `!votemap` no jogo; a troca de campanha fica pelo menu de admin. | 1.0 |
| [AFK](l4d2/skynet_afk_l4d2/) | Expulsa quem fica ausente (sem mexer) por muito tempo, para liberar a vaga. | 1.0 |
| [Votes](l4d2/skynet_votes/) | Desliga as votações do menu do jogo (dificuldade, kick, reiniciar, trocar campanha, lobby), com aviso na tela. | 1.1 |
| [Welcome](l4d2/skynet_welcome_l4d2/) | Mensagem de boas-vindas no chat, uma vez por conexão. | 1.0 |
| [Admin Tag](l4d2/skynet_admtag_l4d2/) | Tag verde `[ADM]` antes do nome dos administradores no chat. | 1.0 |
| [Melee Fixo](l4d2/skynet_melee_fixo_l4d2/) | Golpe corpo a corpo tira dano fixo do Tank e da Witch, e a vida da Witch cresce com o número de sobreviventes. | 1.2 |

### Instalação

**Antes de tudo:** o servidor precisa ter o [Metamod:Source](https://www.sourcemm.net/downloads.php) e o [SourceMod 1.12 ou mais novo](https://www.sourcemod.net/downloads.php) instalados.

1. **Baixe os plugins.** Opção mais fácil: na página de [Releases](https://github.com/luci-immerstark/skynet-sourcemod-plugins/releases/latest), baixe o `.zip` do seu jogo (vem com todos os plugins daquele jogo). Ou entre na pasta de um plugin aqui no GitHub e baixe só ele.
2. **Copie a pasta `addons`** para dentro da pasta do jogo no servidor, juntando com a que já existe:
   - Team Fortress 2: `<pasta-do-servidor>/tf/`
   - Left 4 Dead 2: `<pasta-do-servidor>/left4dead2/`
3. **Apague os que não quiser:** dentro de `addons/sourcemod/plugins/`, cada `.smx` é um plugin.
4. **Ative:** reinicie o servidor ou digite `sm plugins load <nome-do-plugin>` no console (ou pelo rcon).
5. **Confira:** `sm plugins list` deve mostrar os plugins `SKYNET ...`.
6. **Configure (se quiser):** no primeiro carregamento, os plugins com opções criam o arquivo `cfg/sourcemod/<nome-do-plugin>.cfg`. Mude os valores lá e troque de mapa. O README de cada plugin explica cada opção.

Onde cada arquivo fica:

```
<pasta-do-servidor>/tf/   (ou left4dead2/)
└── addons/sourcemod/
    ├── plugins/        os plugins (.smx)
    ├── scripting/      o código-fonte (.sp), só para quem quiser compilar
    ├── configs/        listas usadas por alguns plugins (Map Vote, Taunts)
    └── translations/   textos traduzidos (Teleporte)
```

### Dependências de outros autores (não incluídas)

Alguns plugins usam plugins de outros autores. O README de cada plugin diz se a dependência é obrigatória ou opcional.

- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (SilverShot): Próxima Campanha, Arsenal, Saferoom Door e Rejoin
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (Eyal282): Pontos por Sessão e Points Messages
- Um plugin que crie o comando `sm_join`, como o [MultiSlots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): Rejoin
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): Nuke (obrigatório) e Auto Reflect (opcional)
- Banco GeoIP2 da MaxMind ([GeoLite2](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data), grátis) em `addons/sourcemod/configs/geoip/`: Entrada

### Permissões de admin

Os comandos de admin usam as flags padrão do SourceMod (indicadas no README de cada plugin). Para mudar quem pode usar um comando, use o `addons/sourcemod/configs/admin_overrides.cfg`.

### Compilar você mesmo

Os `.smx` já vêm compilados (SourceMod 1.12). Para mudar algo, edite o `.sp` em `addons/sourcemod/scripting/` e compile com o `spcomp` do próprio SourceMod:

```
cd <pasta-do-servidor>/tf/addons/sourcemod/scripting
./spcomp nome_do_plugin.sp -o../plugins/nome_do_plugin.smx
```

Os plugins usam só os includes que já vêm no SourceMod, sem includes de terceiros.

### Licença

[GNU GPL v3](LICENSE). Pode usar, modificar e redistribuir, mantendo os créditos e a mesma licença.

## English

In-game chat messages are in Portuguese (some also in Spanish). Each plugin works on its own: install only the ones you want.

### Team Fortress 2

| Plugin | What it does | Version |
|---|---|---|
| [Map Vote](tf2/skynet_mapvote/) | Next-map vote whose options are drawn by hype, time since last played and time since last shown, plus an extend option, `!rtv` and `!nominate`. | 1.5 |
| [Robots](tf2/skynet_robot/) | `!robot` command: the player turns into a Mann vs. Machine robot. | 1.0 |
| [Taunts](tf2/skynet_taunts/) | `!taunt` menu with every taunt in the game, even ones the player does not own. | 1.0 |
| [Admin Tag](tf2/skynet_admtag/) | Gold `[ADM]` tag for admins and blue `[MOD]` tag for moderators in chat. | 1.2 |
| [Welcome](tf2/skynet_welcome/) | Welcome message in chat, once per connection. | 1.1 |
| [Bot Names](tf2/skynet_botnames/) | Fixed names for bots and a clean chat when they join and leave. | 1.1 |
| [Pyro Only](tf2/skynet_pyroonly/) | For Dodgeball servers: everyone plays Pyro. | 1.0 |
| [Auto Reflect](tf2/skynet_autoreflect/) | Dodgeball: auto reflect for admins and an automatic ALL VS BOT mode with 1 to 3 players. | 4.2 |
| [Nuke](tf2/skynet_nuke/) | Dodgeball: the NUKE rocket is bigger than the others. | 2.0 |
| [Entrada](tf2/skynet_entrada/) | Tells the chat who joined the server and from which country. | 1.0.0 |
| [FOV](tf2/skynet_fov/) | `!fov <number>` to change the field of view, saved per player. | 1.1.0 |
| [Third Person](tf2/skynet_terceira/) | `!tp` to play in third person and `!fp` to go back. | 1.0.0 |
| [Clean Chat](tf2/skynet_chatlimpo/) | Hides cvar notices and bots joining and leaving from chat. | 1.0.0 |
| [Projectiles](tf2/skynet_projeteis/) | A dead player's projectiles vanish from the map. | 1.0.0 |

### Left 4 Dead 2

| Plugin | What it does | Version |
|---|---|---|
| [Next Campaign](l4d2/skynet_campanhas_l4d2/) | Next-campaign vote during the finale, automatic switch after the rescue, and a campaign menu for admins. | 1.6 |
| [Session Points](l4d2/skynet_pontos_sessao_l4d2/) | Shop points (Points System) last for the whole campaign. | 1.1 |
| [Points Messages](l4d2/skynet_points_msg_l4d2/) | Portuguese messages for Points System earnings and purchases. | 1.0 |
| [Arsenal](l4d2/skynet_arsenal_l4d2/) | Places lots of firearms and melee weapons in the starting saferoom of every chapter. | 1.0 |
| [Saferoom Door](l4d2/skynet_saferoom_l4d2/) | Announces who opens and closes the saferoom door and locks the starting door open. | 1.0 |
| [Rejoin](l4d2/skynet_rejoin_l4d2/) | At the start of every round, puts back into the team anyone stuck as a spectator or dead. | 1.1 |
| [Hordes](l4d2/skynet_hordas_l4d2/) | Common infected hordes scaled to the number of living survivors. | 1.1 |
| [No Friendly Fire](l4d2/skynet_semfogoamigo_l4d2/) | No friendly fire between survivors, with custom rules for fire and explosions. | 1.3 |
| [Teleport](l4d2/skynet_teleporte_l4d2/) | Admins go to a player (`!goto`) or bring a player to them (`!bring`). | 1.1 |
| [Always Expert](l4d2/skynet_sempre_expert_l4d2/) | Keeps the server on Expert difficulty at all times. | 1.0 |
| [Idle-Proof Game](l4d2/skynet_ausentes_l4d2/) | The match keeps going when every player goes idle. | 1.0 |
| [No !map](l4d2/skynet_sem_map_l4d2/) | Blocks `!map` and `!votemap` in game; campaign changes go through the admin menu. | 1.0 |
| [AFK](l4d2/skynet_afk_l4d2/) | Kicks players who stay idle (not moving) too long, to free the slot. | 1.0 |
| [Votes](l4d2/skynet_votes/) | Turns off the game's menu votes (difficulty, kick, restart, change campaign, lobby), with an on-screen notice. | 1.1 |
| [Welcome](l4d2/skynet_welcome_l4d2/) | Welcome message in chat, once per connection. | 1.0 |
| [Admin Tag](l4d2/skynet_admtag_l4d2/) | Green `[ADM]` tag before admin names in chat. | 1.0 |
| [Fixed Melee Damage](l4d2/skynet_melee_fixo_l4d2/) | Melee hits deal fixed damage to the Tank and the Witch, and the Witch's health grows with the number of survivors. | 1.2 |

### Installation

**First:** the server needs [Metamod:Source](https://www.sourcemm.net/downloads.php) and [SourceMod 1.12 or newer](https://www.sourcemod.net/downloads.php).

1. **Download the plugins.** Easiest: grab your game's `.zip` from [Releases](https://github.com/luci-immerstark/skynet-sourcemod-plugins/releases/latest) (it has every plugin for that game). Or open a plugin's folder here on GitHub and download just that one.
2. **Copy the `addons` folder** into the game folder on the server, merging with the existing one:
   - Team Fortress 2: `<server-folder>/tf/`
   - Left 4 Dead 2: `<server-folder>/left4dead2/`
3. **Remove what you don't want:** each `.smx` inside `addons/sourcemod/plugins/` is one plugin.
4. **Load:** restart the server or run `sm plugins load <plugin-name>` in the console (or over rcon).
5. **Check:** `sm plugins list` should show the `SKYNET ...` plugins.
6. **Configure (optional):** on first load, plugins with options create `cfg/sourcemod/<plugin-name>.cfg`. Change the values there and change map. Each plugin's README explains every option.

Where each file goes:

```
<server-folder>/tf/   (or left4dead2/)
└── addons/sourcemod/
    ├── plugins/        the plugins (.smx)
    ├── scripting/      source code (.sp), only needed to compile
    ├── configs/        lists used by some plugins (Map Vote, Taunts)
    └── translations/   translated texts (Teleport)
```

### Third-party dependencies (not included)

Some plugins use plugins by other authors. Each plugin's README says whether the dependency is required or optional.

- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (SilverShot): Next Campaign, Arsenal, Saferoom Door and Rejoin
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (Eyal282): Session Points and Points Messages
- A plugin that provides `sm_join`, such as [MultiSlots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): Rejoin
- [TF2 Dodgeball Modified](https://github.com/Silorak/TF2-Dodgeball-Modified) (Silorak): Nuke (required) and Auto Reflect (optional)
- A MaxMind GeoIP2 database ([GeoLite2](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data), free) in `addons/sourcemod/configs/geoip/`: Entrada

### Admin permissions

Admin commands use SourceMod's standard flags (listed in each plugin's README). To change who can use a command, use `addons/sourcemod/configs/admin_overrides.cfg`.

### Compiling

The `.smx` files are already compiled (SourceMod 1.12). To change something, edit the `.sp` in `addons/sourcemod/scripting/` and compile it with SourceMod's own `spcomp`:

```
cd <server-folder>/tf/addons/sourcemod/scripting
./spcomp plugin_name.sp -o../plugins/plugin_name.smx
```

The plugins only use the includes that ship with SourceMod, no third-party includes.

### License

[GNU GPL v3](LICENSE). You may use, modify and redistribute them, keeping the credits and the same license.
