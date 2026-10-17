#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Welcome (L4D2)",
    author = "SKYNET GAMING",
    description = "Mensagem de boas-vindas uma vez por conexao",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

StringMap g_Shown;

public void OnPluginStart()
{
    g_Shown = new StringMap();
    HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
}

public void OnClientPostAdminCheck(int client)
{
    if (IsFakeClient(client))
        return;
    char auth[32];
    bool shown;
    if (!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)) || g_Shown.GetValue(auth, shown))
        return;
    CreateTimer(30.0, Timer_Welcome, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Welcome(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client))
        return Plugin_Stop;
    char auth[32];
    bool shown;
    if (!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)) || g_Shown.GetValue(auth, shown))
        return Plugin_Stop;
    g_Shown.SetValue(auth, true);
    PrintToChat(client, "\x04[SKYNET GAMING]\x01 Bem-vindo! Aproveite a partida, respeite os outros jogadores e siga as regras do servidor.");
    PrintToChat(client, "\x04[SKYNET GAMING]\x01 Ficou como espectador? Digite \x03!join\x01 para entrar como sobrevivente.");
    return Plugin_Stop;
}

public void Event_Disconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1)
        return;
    char auth[32];
    if (GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)))
        g_Shown.Remove(auth);
}
