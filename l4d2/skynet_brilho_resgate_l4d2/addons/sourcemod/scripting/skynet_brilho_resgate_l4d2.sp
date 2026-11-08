#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

// SKYNET: a dead survivor who reappears in a rescue closet glows through walls until rescued
// (the game's own outline sometimes does not show, and nobody finds them).

public Plugin myinfo =
{
    name = "SKYNET Brilho no Resgate (L4D2)",
    author = "SKYNET GAMING",
    description = "Quem espera resgate no quartinho brilha atraves das paredes",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvCor;
bool g_bBrilho[MAXPLAYERS + 1];

public void OnPluginStart()
{
    g_cvCor = CreateConVar("skynet_resgate_cor", "255 140 0", "Cor do brilho (R G B) de quem espera resgate no quartinho");
    AutoExecConfig(true, "skynet_brilho_resgate_l4d2");
    HookEvent("survivor_call_for_help", Ev_PedeAjuda);
    HookEvent("survivor_rescued", Ev_Resgatado);
    HookEvent("player_death", Ev_Morreu);
    HookEvent("round_start", Ev_Rodada, EventHookMode_PostNoCopy);
}

public void OnClientDisconnect(int c)
{
    g_bBrilho[c] = false;
}

void Brilho(int c, bool liga)
{
    if (c < 1 || c > MaxClients || !IsClientInGame(c) || !HasEntProp(c, Prop_Send, "m_iGlowType"))
        return;
    if (liga)
    {
        char s[32], p[3][8];
        g_cvCor.GetString(s, sizeof(s));
        ExplodeString(s, " ", p, 3, 8);
        int cor = StringToInt(p[0]) + StringToInt(p[1]) * 256 + StringToInt(p[2]) * 65536;
        if (HasEntProp(c, Prop_Send, "m_glowColorOverride"))
            SetEntProp(c, Prop_Send, "m_glowColorOverride", cor);
        if (HasEntProp(c, Prop_Send, "m_nGlowRange"))
            SetEntProp(c, Prop_Send, "m_nGlowRange", 0);
        if (HasEntProp(c, Prop_Send, "m_nGlowRangeMin"))
            SetEntProp(c, Prop_Send, "m_nGlowRangeMin", 0);
        SetEntProp(c, Prop_Send, "m_iGlowType", 3);
    }
    else
    {
        SetEntProp(c, Prop_Send, "m_iGlowType", 0);
        if (HasEntProp(c, Prop_Send, "m_glowColorOverride"))
            SetEntProp(c, Prop_Send, "m_glowColorOverride", 0);
    }
    g_bBrilho[c] = liga;
}

public void Ev_PedeAjuda(Event e, const char[] nome, bool sem)
{
    int c = GetClientOfUserId(e.GetInt("userid"));
    if (c && IsClientInGame(c) && GetClientTeam(c) == 2 && IsPlayerAlive(c))
        Brilho(c, true);
}

public void Ev_Resgatado(Event e, const char[] nome, bool sem)
{
    int c = GetClientOfUserId(e.GetInt("victim"));
    if (c && g_bBrilho[c])
        Brilho(c, false);
}

public void Ev_Morreu(Event e, const char[] nome, bool sem)
{
    int c = GetClientOfUserId(e.GetInt("userid"));
    if (c && c <= MaxClients && g_bBrilho[c])
        Brilho(c, false);
}

public void Ev_Rodada(Event e, const char[] nome, bool sem)
{
    for (int c = 1; c <= MaxClients; c++)
    {
        if (g_bBrilho[c])
            Brilho(c, false);
        g_bBrilho[c] = false;
    }
}
