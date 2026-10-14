# SKYNET Arsenal

**Left 4 Dead 2** · v1.0 · `skynet_arsenal_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Coloca várias armas de fogo e corpo a corpo no abrigo inicial de cada capítulo.

### O que faz
- Todas as armas de fogo do jogo, cada uma podendo ser pega várias vezes (`skynet_arsenal_qtd`).
- Opcional: armas do Counter-Strike (MP5, SG552, Scout, AWP), Magnum e pistola, M60, lança-granadas e motosserra.
- Todas as armas corpo a corpo disponíveis no mapa.
- Escolhe sozinho um lugar livre e plano dentro do abrigo, longe das portas e sem tirar a arma da mão de ninguém.
- `sm_arsenal` monta o arsenal onde o admin está; `sm_arsenal limpar` remove.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (opcional: ajuda a saber se o ponto está dentro do abrigo)

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_arsenal_l4d2` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_arsenal` / `!arsenal` | admin (flag `n`) | `sm_arsenal` monta o arsenal onde você está, `sm_arsenal limpar` remove |

### Cvars
O arquivo `cfg/sourcemod/skynet_arsenal_l4d2.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_arsenal_enable` | `1` | Liga (1) ou desliga (0) o arsenal no abrigo |
| `skynet_arsenal_qtd` | `10` | Quantas vezes cada arma de fogo pode ser pega no abrigo (0 = infinito) |
| `skynet_arsenal_css` | `1` | Incluir as armas do Counter-Strike (MP5, SG552, Scout, AWP) |
| `skynet_arsenal_pistolas` | `1` | Incluir Magnum e pistola |
| `skynet_arsenal_melee` | `2` | Quantas unidades de cada arma corpo a corpo (0 = nenhuma) |
| `skynet_arsenal_especiais` | `1` | Quantas M60, lanca-granadas e motosserras (0 = nenhuma) |
| `skynet_arsenal_aviso` | `1` | Avisar no chat quando o arsenal for montado |

## English

Places lots of firearms and melee weapons in the starting saferoom of every chapter.

### What it does
- Every firearm in the game, each one can be picked up several times (`skynet_arsenal_qtd`).
- Optional: Counter-Strike weapons (MP5, SG552, Scout, AWP), Magnum and pistol, M60, grenade launcher and chainsaw.
- Every melee weapon available on the map.
- Finds a clear, flat spot inside the saferoom by itself, away from the doors, without taking anyone's weapon.
- `sm_arsenal` builds the arsenal where the admin stands; `sm_arsenal limpar` removes it.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Left 4 DHooks Direct](https://forums.alliedmods.net/showthread.php?t=321696) (optional: helps tell whether a spot is inside the saferoom)

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_arsenal_l4d2` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_arsenal` / `!arsenal` | admin (flag `n`) | `sm_arsenal` builds the arsenal where you stand, `sm_arsenal limpar` removes it |

### Cvars
`cfg/sourcemod/skynet_arsenal_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_arsenal_enable` | `1` | Turns the saferoom arsenal on (1) or off (0) |
| `skynet_arsenal_qtd` | `10` | How many times each firearm can be picked up (0 = unlimited) |
| `skynet_arsenal_css` | `1` | Include Counter-Strike weapons (MP5, SG552, Scout, AWP) |
| `skynet_arsenal_pistolas` | `1` | Include Magnum and pistol |
| `skynet_arsenal_melee` | `2` | Units of each melee weapon (0 = none) |
| `skynet_arsenal_especiais` | `1` | How many M60s, grenade launchers and chainsaws (0 = none) |
| `skynet_arsenal_aviso` | `1` | Announce in chat when the arsenal is built |
