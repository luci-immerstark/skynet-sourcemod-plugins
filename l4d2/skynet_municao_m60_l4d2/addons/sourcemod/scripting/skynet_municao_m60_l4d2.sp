#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

// SKYNET: the M60 and the grenade launcher can be refilled at ammo piles (the game refuses them) and with
// !buy ammo from Point System API (its "give ammo" does not refill them).

public Plugin myinfo =
{
    name = "SKYNET Municao M60 e Lanca-granadas (L4D2)",
    author = "SKYNET GAMING",
    description = "M60 e lanca-granadas recarregam na pilha de municao e com !buy ammo",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvM60;

public void OnPluginStart()
{
    g_cvM60 = CreateConVar("skynet_m60_balas", "150", "Balas da M60 depois de recarregar", _, true, 1.0, true, 999.0);
    AutoExecConfig(true, "skynet_municao_m60_l4d2");
    HookEvent("ammo_pile_weapon_cant_use_ammo", Ev_PilhaRecusou);
}

// returns true if the player's main weapon is an M60 or grenade launcher and was refilled
bool Recarregar(int c)
{
    if (c < 1 || c > MaxClients || !IsClientInGame(c) || GetClientTeam(c) != 2 || !IsPlayerAlive(c))
        return false;
    int w = GetPlayerWeaponSlot(c, 0);
    if (w <= MaxClients || !IsValidEntity(w))
        return false;
    char cls[48];
    GetEntityClassname(w, cls, sizeof(cls));
    if (StrEqual(cls, "weapon_rifle_m60"))
    {
        SetEntProp(w, Prop_Send, "m_iClip1", g_cvM60.IntValue);
        return true;
    }
    if (StrEqual(cls, "weapon_grenade_launcher"))
    {
        ConVar max = FindConVar("ammo_grenadelauncher_max");
        int tipo = GetEntProp(w, Prop_Send, "m_iPrimaryAmmoType");
        if (tipo >= 0)
            SetEntProp(c, Prop_Send, "m_iAmmo", max != null ? max.IntValue : 30, _, tipo);
        if (GetEntProp(w, Prop_Send, "m_iClip1") < 1)
            SetEntProp(w, Prop_Send, "m_iClip1", 1);
        return true;
    }
    return false;
}

public void Ev_PilhaRecusou(Event e, const char[] nome, bool sem)
{
    int c = GetClientOfUserId(e.GetInt("userid"));
    if (Recarregar(c))
        PrintHintText(c, "Munição recarregada");
}

// Point System API: !buy ammo
public Action PointSystemAPI_OnShouldGiveProduct(int buyer, const char[] info, const char[] sAliases, const char[] sName, int target, float fCost, float fDelay, float fCooldown)
{
    if (StrEqual(sAliases, "ammo"))
        Recarregar(target > 0 ? target : buyer);
    return Plugin_Continue;
}
