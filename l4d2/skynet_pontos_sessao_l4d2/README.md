# SKYNET Session Points / Pontos por Sessão

**Left 4 Dead 2** · v1.1 · `skynet_pontos_sessao_l4d2.smx`

[Português](#português) · [English](#english) · [Todos os plugins / All plugins](../../README.md)

## Português

Os pontos da loja (Points System) duram a campanha inteira.

### O que faz
- O saldo de cada jogador passa de um capítulo para o outro, em vez de zerar a cada mapa.
- O saldo volta ao valor inicial (`l4d2_points_start`) quando o jogador sai do servidor ou quando a campanha termina.
- Corrige o Points System devolvendo, no capítulo seguinte, o saldo antigo de quando o jogador entrou no time.

### Requisitos
- SourceMod 1.12 ou mais novo e Metamod:Source
- Left 4 Dead 2
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (Eyal282)

### Instalação
1. Copie a pasta `addons` desta pasta para dentro da pasta do jogo no servidor (`<pasta-do-servidor>/left4dead2/`), juntando com a que já existe.
2. Reinicie o servidor ou digite `sm plugins load skynet_pontos_sessao_l4d2` no console.

## English

Shop points (Points System) last for the whole campaign.

### What it does
- Each player's balance carries over between chapters instead of resetting every map.
- The balance goes back to the starting value (`l4d2_points_start`) when the player leaves the server or the campaign ends.
- Fixes Points System restoring, in the next chapter, the old balance from when the player joined the team.

### Requirements
- SourceMod 1.12 or newer and Metamod:Source
- Left 4 Dead 2
- [Points System API](https://github.com/eyal282/l4d2-point-system-api) (Eyal282)

### Installation
1. Copy the `addons` folder from here into the game folder on the server (`<server-folder>/left4dead2/`), merging with the existing one.
2. Restart the server or run `sm plugins load skynet_pontos_sessao_l4d2` in the console.
