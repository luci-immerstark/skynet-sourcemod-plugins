// SKYNET: removes from chat the console notices that players do not care about:
//   "Server cvar 'x' changed to ..." and bot joins/leaves/name changes/team changes.
//   The events still happen for other plugins (ranking, logs); they are just not shown in chat.
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
