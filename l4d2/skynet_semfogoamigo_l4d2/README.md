# SKYNET No Friendly Fire / Sem Fogo Amigo

**Left 4 Dead 2** · v1.3 · `skynet_semfogoamigo_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Sem fogo amigo entre sobreviventes, com regras próprias para fogo e explosões.

### O que faz
- Sobreviventes não causam dano uns nos outros (tiros, granadas, lança-granadas).
- O molotov continua queimando quem o jogou.
- Fogo de galão de gasolina, de barril de combustível e de fogos de artifício não fere nenhum sobrevivente.
- O fogo do próprio mapa (fogueiras, carros e prédios pegando fogo) fica mais forte (`skynet_fogo_mapa`).

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_semfogoamigo_l4d2` no console.

### Cvars
O arquivo `cfg/sourcemod/skynet_semfogoamigo_l4d2.cfg` é criado sozinho no primeiro carregamento. Edite os valores lá e troque de mapa.

| Cvar | Padrão | Descrição |
|---|---|---|
| `skynet_sem_fogo_amigo` | `1` | 1 = sobreviventes nao causam dano uns nos outros |
| `skynet_galao_sem_dano` | `1` | 1 = o fogo de galao de gasolina, de barril e dos fogos de artificio nao fere sobreviventes |
| `skynet_fogo_mapa` | `3.0` | Multiplicador do dano do fogo do proprio mapa nos sobreviventes (1 = normal do jogo) |

## English

No friendly fire between survivors, with custom rules for fire and explosions.

### What it does
- Survivors deal no damage to each other (bullets, grenades, grenade launcher).
- A molotov still burns the player who threw it.
- Fire from gas cans, fuel barrels and fireworks does not hurt any survivor.
- Map fire (bonfires, burning cars and buildings) gets stronger (`skynet_fogo_mapa`).

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_semfogoamigo_l4d2` in the console.

### Cvars
`cfg/sourcemod/skynet_semfogoamigo_l4d2.cfg` is created automatically on first load. Edit the values there and change map.

| Cvar | Default | Description |
|---|---|---|
| `skynet_sem_fogo_amigo` | `1` | 1 = survivors deal no damage to each other |
| `skynet_galao_sem_dano` | `1` | 1 = fire from gas cans, barrels and fireworks does not hurt survivors |
| `skynet_fogo_mapa` | `3.0` | Damage multiplier for map fire on survivors (1 = game default) |
