// SKYNET: tira do chat os avisos de console que nao interessam aos jogadores:
//   "Server cvar 'x' changed to ..." e as entradas/saidas/troca de nome/troca de time de bots.
//   Os eventos continuam acontecendo para os outros plugins (ranking, logs); so nao sao mostrados no chat.
#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name        = "SKYNET Chat Limpo",
    author      = "SKYNET GAMING",
    description = "Esconde do chat avisos de cvar e entrada/saida de bots",
    version     = "1.0.0",
    url         = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

public void OnPluginStart()
{
    HookEvent("server_cvar", Ev_Cvar, EventHookMode_Pre);
    HookEvent("player_connect_client", Ev_BotPorCampo, EventHookMode_Pre);
    HookEvent("player_disconnect", Ev_BotPorCampo, EventHookMode_Pre);
    HookEvent("player_team", Ev_BotPorId, EventHookMode_Pre);
    HookEvent("player_changename", Ev_BotPorId, EventHookMode_Pre);
}

public Action Ev_Cvar(Event event, const char[] nome, bool semTransmitir)
{
    event.BroadcastDisabled = true;
    return Plugin_Continue;
}

public Action Ev_BotPorCampo(Event event, const char[] nome, bool semTransmitir)
{
    if (event.GetInt("bot") != 0)
        event.BroadcastDisabled = true;
    return Plugin_Continue;
}

public Action Ev_BotPorId(Event event, const char[] nome, bool semTransmitir)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client) && IsFakeClient(client))
        event.BroadcastDisabled = true;
    return Plugin_Continue;
}
