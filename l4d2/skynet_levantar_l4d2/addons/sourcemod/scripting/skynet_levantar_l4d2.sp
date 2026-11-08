#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

// SKYNET: a downed survivor (incapacitated or hanging from a ledge) who has pills or adrenaline gets up alone by
// holding E for a few seconds (progress bar on screen). The item is used up. It does not work while a special
// infected is holding the player or while a teammate is already reviving them.

native void L4D_ReviveSurvivor(int client);     // Provided by Left 4 DHooks

public Plugin myinfo =
{
    name = "SKYNET Levantar Sozinho (L4D2)",
    author = "SKYNET GAMING",
    description = "Caido com pills ou adrenalina: segure E para se levantar sozinho",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvTempo;
float g_fInicio[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("L4D_ReviveSurvivor");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_cvTempo = CreateConVar("skynet_levantar_tempo", "3.0", "Segundos segurando E para se levantar sozinho com pills ou adrenalina", _, true, 0.5, true, 10.0);
    AutoExecConfig(true, "skynet_levantar_l4d2");
    HookEvent("player_incapacitated", Ev_Caiu);
    HookEvent("player_ledge_grab", Ev_Caiu);
}

public void OnClientDisconnect(int client)
{
    g_fInicio[client] = 0.0;
}

bool Caido(int c)
{
    return GetEntProp(c, Prop_Send, "m_isIncapacitated") != 0 || GetEntProp(c, Prop_Send, "m_isHangingFromLedge") != 0;
}

// held by a Smoker, Hunter, Jockey or Charger
bool Preso(int c)
{
    static const char props[][] = {"m_tongueOwner", "m_pounceAttacker", "m_jockeyAttacker", "m_pummelAttacker", "m_carryAttacker"};
    for (int i = 0; i < sizeof(props); i++)
    {
        if (HasEntProp(c, Prop_Send, props[i]) && GetEntPropEnt(c, Prop_Send, props[i]) > 0)
            return true;
    }
    return false;
}

// pills or adrenaline in the player's slot, or -1
int Remedio(int c)
{
    int w = GetPlayerWeaponSlot(c, 4);
    if (w <= MaxClients || !IsValidEntity(w))
        return -1;
    char cls[32];
    GetEntityClassname(w, cls, sizeof(cls));
    return (StrEqual(cls, "weapon_pain_pills") || StrEqual(cls, "weapon_adrenaline")) ? w : -1;
}

public void Ev_Caiu(Event e, const char[] nome, bool sem)
{
    int c = GetClientOfUserId(e.GetInt("userid"));
    if (c && IsClientInGame(c) && !IsFakeClient(c) && GetClientTeam(c) == 2 && Remedio(c) != -1)
        PrintHintText(c, "Você tem pills ou adrenalina: segure E para se levantar sozinho");
}

void Cancela(int c)
{
    if (g_fInicio[c] == 0.0)
        return;
    g_fInicio[c] = 0.0;
    if (IsClientInGame(c))
    {
        SetEntPropFloat(c, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
        SetEntPropFloat(c, Prop_Send, "m_flProgressBarDuration", 0.0);
    }
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
    if (!(buttons & IN_USE))
    {
        Cancela(client);
        return Plugin_Continue;
    }
    if (IsFakeClient(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client) || !Caido(client) || Preso(client)
        || GetEntPropEnt(client, Prop_Send, "m_reviveOwner") > 0 || Remedio(client) == -1
        || GetFeatureStatus(FeatureType_Native, "L4D_ReviveSurvivor") != FeatureStatus_Available)
    {
        Cancela(client);
        return Plugin_Continue;
    }
    float agora = GetGameTime();
    float tempo = g_cvTempo.FloatValue;
    if (g_fInicio[client] == 0.0)
    {
        g_fInicio[client] = agora;
        SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", agora);
        SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", tempo);
        return Plugin_Continue;
    }
    if (agora - g_fInicio[client] < tempo)
        return Plugin_Continue;
    int w = Remedio(client);
    Cancela(client);
    if (w != -1)
    {
        RemovePlayerItem(client, w);
        RemoveEntity(w);
    }
    L4D_ReviveSurvivor(client);
    PrintHintText(client, "Você se levantou sozinho");
    return Plugin_Continue;
}
