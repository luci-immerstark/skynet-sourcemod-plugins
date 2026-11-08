// SKYNET God Mode: admins turn god mode on or off for a player (sm_god <target> [0|1]; no value toggles it).
//   It survives respawns until turned off or the player leaves.
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
    name = "SKYNET God Mode",
    author = "SKYNET GAMING BRASIL",
    description = "sm_god <alvo> [0|1]: liga ou desliga o modo deus",
    version = "1.0",
    url = "https://skynet-tf2.com.br"
};

bool g_bGod[MAXPLAYERS + 1];

public void OnPluginStart()
{
    LoadTranslations("common.phrases");
    RegAdminCmd("sm_god", Cmd_God, ADMFLAG_CHEATS, "sm_god <alvo> [0|1]");
    HookEvent("player_spawn", Event_Spawn);
}

public void OnClientDisconnect(int client)
{
    g_bGod[client] = false;
}

void Apply(int client)
{
    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        SetEntProp(client, Prop_Data, "m_takedamage", g_bGod[client] ? 0 : 2, 1);
    }
}

public Action Cmd_God(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[SM] Uso: sm_god <alvo> [0|1]");
        return Plugin_Handled;
    }

    char arg[MAX_TARGET_LENGTH], val[8], tname[MAX_TARGET_LENGTH];
    GetCmdArg(1, arg, sizeof(arg));
    int mode = -1;
    if (args >= 2)
    {
        GetCmdArg(2, val, sizeof(val));
        mode = StringToInt(val) != 0 ? 1 : 0;
    }

    int targets[MAXPLAYERS];
    bool ml;
    int n = ProcessTargetString(arg, client, targets, MAXPLAYERS, COMMAND_FILTER_CONNECTED, tname, sizeof(tname), ml);
    if (n <= 0)
    {
        ReplyToTargetError(client, n);
        return Plugin_Handled;
    }

    for (int i = 0; i < n; i++)
    {
        int t = targets[i];
        g_bGod[t] = (mode == -1) ? !g_bGod[t] : (mode == 1);
        Apply(t);
        ReplyToCommand(client, "[SM] Modo deus %s: %N", g_bGod[t] ? "LIGADO" : "DESLIGADO", t);
        LogAction(client, t, "\"%L\" %s o modo deus de \"%L\"", client, g_bGod[t] ? "ligou" : "desligou", t);
    }
    return Plugin_Handled;
}

public void Event_Spawn(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (client && g_bGod[client])
    {
        RequestFrame(Frame_Apply, userid);
    }
}

void Frame_Apply(any data)
{
    int client = GetClientOfUserId(data);
    if (client)
    {
        Apply(client);
    }
}
