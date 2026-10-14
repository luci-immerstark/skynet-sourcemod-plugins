# SKYNET Hordes / Hordas

**Left 4 Dead 2** · v1.0 · `skynet_hordas_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Hordas de zumbis comuns proporcionais ao número de sobreviventes vivos.

### O que faz
- Feito para servidores com mais de 4 sobreviventes: o jogo não aumenta as hordas sozinho.
- Fator = 1 + `skynet_hordas_fator` × (vivos − 4), nunca abaixo de 0,6. Ajusta `z_common_limit`, `z_mob_spawn_min_size`, `z_mob_spawn_max_size`, `z_mob_spawn_finale_size` e `z_mega_mob_size`.
- Cada valor fica limitado a `skynet_hordas_max`. Ao descarregar o plugin, os valores originais voltam.
- Os infectados especiais não são alterados.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_hordas_l4d2` no console.

### Comandos
| Comando | Acesso | Descrição |
|---|---|---|
| `sm_hordas` / `!hordas` | admin (flag `b`) | Mostra o tamanho atual das hordas |

### Cvars
O arquivo `cfg/sourcemod/skynet_hordas_l4d2.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_hordas_fator` | `0.10` | Quanto cada sobrevivente vivo acima de 4 aumenta as hordas (0.10 = +10% por sobrevivente) |
| `skynet_hordas_max` | `100` | Teto de cada valor (zumbis comuns ao mesmo tempo e tamanho das hordas) |

## English

Common infected hordes scaled to the number of living survivors.

### What it does
- Made for servers with more than 4 survivors, since the game does not scale hordes by itself.
- Factor = 1 + `skynet_hordas_fator` × (alive − 4), never below 0.6. Adjusts `z_common_limit`, `z_mob_spawn_min_size`, `z_mob_spawn_max_size`, `z_mob_spawn_finale_size` and `z_mega_mob_size`.
- Each value is capped at `skynet_hordas_max`. Unloading the plugin restores the original values.
- Special infected are not touched.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_hordas_l4d2` in the console.

### Commands
| Command | Access | Description |
|---|---|---|
| `sm_hordas` / `!hordas` | admin (flag `b`) | Shows the current horde sizes |

### Cvars
`cfg/sourcemod/skynet_hordas_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_hordas_fator` | `0.10` | How much each living survivor above 4 grows the hordes (0.10 = +10% per survivor) |
| `skynet_hordas_max` | `100` | Cap for each value (commons at once and horde sizes) |
