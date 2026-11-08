#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

// SKYNET: hold R (reload) and right-click while aiming at a survivor to hand over the item in your hands:
// grenades (molotov, pipe bomb, bile jar), first aid kit, defibrillator, upgrade packs, pills and adrenaline.
// The teammate must have that inventory slot free. Holding R also stops the right click from shoving or healing.
// 1.1: !gw <name> <item> gives one of your items to that survivor from anywhere (e.g. !gw Franco kit).

public Plugin myinfo =
{
    name = "SKYNET Passar Item (L4D2)",
    author = "SKYNET GAMING",
    description = "Segure R e clique direito mirando num sobrevivente, ou use !gw nome item, para dar um item",
    version = "1.1",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvDist;
int g_iAntes[MAXPLAYERS + 1];
float g_fProx[MAXPLAYERS + 1];

static const char g_sClasse[][] = {
    "weapon_molotov", "weapon_pipe_bomb", "weapon_vomitjar",
    "weapon_first_aid_kit", "weapon_defibrillator", "weapon_upgradepack_incendiary", "weapon_upgradepack_explosive",
    "weapon_pain_pills", "weapon_adrenaline"
};
static const char g_sNome[][] = {
    "um molotov", "uma bomba caseira", "uma bile",
    "um kit médico", "um desfibrilador", "munição incendiária", "munição explosiva",
    "pílulas", "adrenalina"
};
static const int g_iSlot[] = { 2, 2, 2, 3, 3, 3, 3, 4, 4 };
// names accepted by !gw for each item above (separated by spaces)
static const char g_sApelido[][] = {
    "molotov", "pipe bomba pipebomb", "bile vomit vomitjar",
    "kit medkit kitmedico", "defib desfibrilador", "incendiaria inc incammo", "explosiva exp expammo",
    "pills pilulas pilula", "adren adrenalina"
};

public void OnPluginStart()
{
    g_cvDist = CreateConVar("skynet_passar_distancia", "150", "Distancia maxima (unidades) para dar um item", _, true, 50.0, true, 500.0);
    AutoExecConfig(true, "skynet_passar_item_l4d2");
    LoadTranslations("common.phrases");
    RegConsoleCmd("sm_gw", Cmd_Gw, "!gw <jogador> <item>: da um item seu para outro sobrevivente");
}

public void OnClientDisconnect(int client)
{
    g_iAntes[client] = 0;
    g_fProx[client] = 0.0;
}

bool Caido(int c)
{
    return GetEntProp(c, Prop_Send, "m_isIncapacitated") != 0 || GetEntProp(c, Prop_Send, "m_isHangingFromLedge") != 0;
}

// index in g_sClasse of the item in the player's hands, or -1
int ItemNaMao(int client, int &arma)
{
    arma = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (arma <= MaxClients || !IsValidEntity(arma))
        return -1;
    char cls[48];
    GetEntityClassname(arma, cls, sizeof(cls));
    for (int i = 0; i < sizeof(g_sClasse); i++)
    {
        if (StrEqual(cls, g_sClasse[i]) && GetPlayerWeaponSlot(client, g_iSlot[i]) == arma)
            return i;
    }
    return -1;
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
    int antes = g_iAntes[client];
    g_iAntes[client] = buttons;
    if (!(buttons & IN_RELOAD) || !(buttons & IN_ATTACK2))
        return Plugin_Continue;
    if (IsFakeClient(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client) || Caido(client))
        return Plugin_Continue;
    int arma;
    int idx = ItemNaMao(client, arma);
    if (idx == -1)
        return Plugin_Continue;             // not an item that can be given: the right click works as usual
    buttons &= ~IN_ATTACK2;                 // R held: the right click is a hand-over, not a shove or heal
    if ((antes & IN_ATTACK2) || GetGameTime() < g_fProx[client])
        return Plugin_Changed;
    g_fProx[client] = GetGameTime() + 0.5;

    int alvo = GetClientAimTarget(client, true);
    if (alvo < 1 || alvo > MaxClients || !IsClientInGame(alvo) || GetClientTeam(alvo) != 2 || !IsPlayerAlive(alvo))
    {
        PrintHintText(client, "Mire num sobrevivente para dar %s", g_sNome[idx]);
        return Plugin_Changed;
    }
    float a[3], b[3];
    GetClientAbsOrigin(client, a);
    GetClientAbsOrigin(alvo, b);
    if (GetVectorDistance(a, b) > g_cvDist.FloatValue)
    {
        PrintHintText(client, "Chegue mais perto de %N para dar %s", alvo, g_sNome[idx]);
        return Plugin_Changed;
    }
    if (GetPlayerWeaponSlot(alvo, g_iSlot[idx]) != -1)
    {
        PrintHintText(client, "%N já tem um item desse tipo", alvo);
        return Plugin_Changed;
    }
    RemovePlayerItem(client, arma);
    RemoveEntity(arma);
    GivePlayerItem(alvo, g_sClasse[idx]);
    PrintHintText(client, "Você deu %s para %N", g_sNome[idx], alvo);
    if (!IsFakeClient(alvo))
        PrintHintText(alvo, "%N te deu %s", client, g_sNome[idx]);
    return Plugin_Changed;
}

// item index for a name typed in !gw, or -1
int ItemPorNome(const char[] nome)
{
    char partes[4][16];
    for (int i = 0; i < sizeof(g_sApelido); i++)
    {
        int n = ExplodeString(g_sApelido[i], " ", partes, sizeof(partes), sizeof(partes[]));
        for (int k = 0; k < n; k++)
        {
            if (StrEqual(nome, partes[k], false))
                return i;
        }
    }
    return -1;
}

public Action Cmd_Gw(int client, int args)
{
    if (!client || !IsClientInGame(client))
        return Plugin_Handled;
    if (args < 2)
    {
        PrintToChat(client, "[SKYNET] Use: !gw <jogador> <item>. Itens: kit, defib, pills, adren, molotov, pipe, bile, incendiaria, explosiva");
        return Plugin_Handled;
    }
    if (GetClientTeam(client) != 2 || !IsPlayerAlive(client))
    {
        PrintToChat(client, "[SKYNET] Só sobreviventes vivos podem dar itens.");
        return Plugin_Handled;
    }
    char quem[64], oque[32];
    GetCmdArg(1, quem, sizeof(quem));
    GetCmdArg(2, oque, sizeof(oque));
    int idx = ItemPorNome(oque);
    if (idx == -1)
    {
        PrintToChat(client, "[SKYNET] Item desconhecido: %s. Itens: kit, defib, pills, adren, molotov, pipe, bile, incendiaria, explosiva", oque);
        return Plugin_Handled;
    }
    int alvo = FindTarget(client, quem, false, false);
    if (alvo == -1)
        return Plugin_Handled;
    if (alvo == client || GetClientTeam(alvo) != 2 || !IsPlayerAlive(alvo))
    {
        PrintToChat(client, "[SKYNET] Escolha outro sobrevivente vivo.");
        return Plugin_Handled;
    }
    int arma = GetPlayerWeaponSlot(client, g_iSlot[idx]);
    char cls[48];
    if (arma > MaxClients && IsValidEntity(arma))
        GetEntityClassname(arma, cls, sizeof(cls));
    if (arma <= MaxClients || !StrEqual(cls, g_sClasse[idx]))
    {
        PrintToChat(client, "[SKYNET] Você não tem %s.", g_sNome[idx]);
        return Plugin_Handled;
    }
    if (GetPlayerWeaponSlot(alvo, g_iSlot[idx]) != -1)
    {
        PrintToChat(client, "[SKYNET] %N já tem um item desse tipo.", alvo);
        return Plugin_Handled;
    }
    RemovePlayerItem(client, arma);
    RemoveEntity(arma);
    GivePlayerItem(alvo, g_sClasse[idx]);
    PrintToChat(client, "[SKYNET] Você deu %s para %N.", g_sNome[idx], alvo);
    if (!IsFakeClient(alvo))
        PrintToChat(alvo, "[SKYNET] %N te deu %s.", client, g_sNome[idx]);
    return Plugin_Handled;
}
