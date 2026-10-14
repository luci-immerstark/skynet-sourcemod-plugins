#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Jogo com Ausentes (L4D2)",
    author = "SKYNET GAMING",
    description = "A partida continua quando todos os jogadores ficam ausentes (idle)",
    version = "1.0",
    url = "https://github.com/lmattedi/skynet-sourcemod-plugins"
};

// Por padrao o jogo encerra a partida quando nao sobra nenhum humano controlando sobrevivente
// (todo mundo ausente, os bots no lugar). Com alguem conectado, os bots seguram a partida;
// com o servidor vazio volta ao padrao, para o servidor hibernar normalmente.

ConVar g_cvTodosBots;
ConVar g_cvTimeBots;

public void OnPluginStart()
{
    g_cvTodosBots = FindConVar("sb_all_bot_game");
    g_cvTimeBots = FindConVar("allow_all_bot_survivor_team");
    CreateTimer(5.0, T_Conferir, _, TIMER_REPEAT);
    Conferir();
}

public void OnConfigsExecuted()
{
    Conferir();
}

public void OnClientPutInServer(int client)
{
    Conferir();
}

public void OnClientDisconnect_Post(int client)
{
    Conferir();
}

public Action T_Conferir(Handle timer)
{
    Conferir();
    return Plugin_Continue;
}

void Conferir()
{
    int valor = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i) && !IsFakeClient(i))
        {
            valor = 1;
            break;
        }
    }
    if (g_cvTodosBots != null && g_cvTodosBots.IntValue != valor)
        g_cvTodosBots.IntValue = valor;
    if (g_cvTimeBots != null && g_cvTimeBots.IntValue != valor)
        g_cvTimeBots.IntValue = valor;
}
