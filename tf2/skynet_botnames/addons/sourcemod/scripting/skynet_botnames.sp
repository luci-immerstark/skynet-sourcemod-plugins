#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Bot Names",
    author = "SKYNET GAMING",
    description = "Nomes fixos para os bots e chat limpo nas entradas e saidas deles",
    version = "1.1",
    url = "https://github.com/lmattedi/skynet-sourcemod-plugins"
};

// Edite esta lista com os nomes que quiser. / Edit this list with any names you like.
static const char g_Nomes[][] =
{
    "Bot Alpha",
    "Bot Bravo",
    "Bot Charlie",
    "Bot Delta",
    "Bot Echo",
    "Bot Foxtrot"
};

public void OnPluginStart()
{
    HookEventEx("player_connect_client", Ev_EsconderBot, EventHookMode_Pre);
    HookEventEx("player_disconnect", Ev_EsconderBot, EventHookMode_Pre);
    HookEventEx("player_changename", Ev_EsconderTrocaDeNome, EventHookMode_Pre);
    HookEventEx("server_cvar", Ev_EsconderCvar, EventHookMode_Pre);
}

bool EhBot(int client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client)
        && !IsClientSourceTV(client) && !IsClientReplay(client);
}

public Action Ev_EsconderBot(Event event, const char[] name, bool dontBroadcast)
{
    char id[32];
    event.GetString("networkid", id, sizeof(id));
    if (StrEqual(id, "BOT"))
        event.BroadcastDisabled = true;
    return Plugin_Continue;
}

public Action Ev_EsconderTrocaDeNome(Event event, const char[] name, bool dontBroadcast)
{
    if (EhBot(GetClientOfUserId(event.GetInt("userid"))))
        event.BroadcastDisabled = true;
    return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
    if (IsFakeClient(client) && !IsClientSourceTV(client) && !IsClientReplay(client))
        RequestFrame(Frame_Renomear, GetClientUserId(client));
}

void Frame_Renomear(int userid)
{
    int client = GetClientOfUserId(userid);
    if (!EhBot(client))
        return;
    for (int i = 0; i < sizeof(g_Nomes); i++)
    {
        if (!NomeEmUso(g_Nomes[i], client))
        {
            SetClientName(client, g_Nomes[i]);
            return;
        }
    }
}

bool NomeEmUso(const char[] nome, int ignorar)
{
    char n[MAX_NAME_LENGTH];
    for (int c = 1; c <= MaxClients; c++)
    {
        if (c == ignorar || !IsClientInGame(c))
            continue;
        GetClientName(c, n, sizeof(n));
        if (StrEqual(n, nome))
            return true;
    }
    return false;
}

// Esconde do chat o aviso "Server cvar 'tf_bot_count' changed", que aparece a cada entrada e saida de bot
public Action Ev_EsconderCvar(Event event, const char[] name, bool dontBroadcast)
{
    char cvar[64];
    event.GetString("cvarname", cvar, sizeof(cvar));
    if (StrEqual(cvar, "tf_bot_count"))
        event.BroadcastDisabled = true;
    return Plugin_Continue;
}
