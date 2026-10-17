#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Melee Fixo (L4D2)",
    author = "SKYNET GAMING",
    description = "Golpe corpo a corpo tira dano fixo do Tank e da Witch; vida da Witch cresce com o numero de sobreviventes",
    version = "1.2",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

// No jogo original, cada golpe corpo a corpo tira uma PORCENTAGEM da vida maxima:
// 5% do Tank (morre com 20 golpes) e 25% da Witch (morre com 4), nao importa quanta vida eles tenham.
// Aqui cada golpe tira um valor fixo. A motosserra nao muda.

#define TIME_SOBREVIVENTE 2
#define TIME_INFECTADO    3
#define CLASSE_TANK       8

ConVar g_cvTank;
ConVar g_cvWitch;
ConVar g_cvVidaMin;
ConVar g_cvVidaMax;
ConVar g_cvVidaMaxCom;
ConVar g_cvDebug;

public void OnPluginStart()
{
    g_cvTank      = CreateConVar("skynet_melee_tank", "500", "Dano de cada golpe corpo a corpo no Tank (0 = como no jogo: 5% da vida dele)", _, true, 0.0);
    g_cvWitch     = CreateConVar("skynet_melee_witch", "300", "Dano de cada golpe corpo a corpo na Witch (0 = como no jogo: 25% da vida dela)", _, true, 0.0);
    g_cvVidaMin    = CreateConVar("skynet_witch_vida_min", "1000", "Vida da Witch com 4 sobreviventes vivos ou menos", _, true, 1.0);
    g_cvVidaMax    = CreateConVar("skynet_witch_vida_max", "5000", "Vida maxima da Witch (0 = vida normal do jogo, sem mudar nada)", _, true, 0.0);
    g_cvVidaMaxCom = CreateConVar("skynet_witch_vida_max_com", "10", "Numero de sobreviventes vivos em que a Witch chega na vida maxima", _, true, 5.0);
    g_cvDebug      = CreateConVar("skynet_melee_debug", "0", "1 = a cada golpe corpo a corpo no Tank ou na Witch, mostra no chat de quem bateu (e grava no log do SourceMod) o dano e a vida", _, true, 0.0, true, 1.0);
    AutoExecConfig(true, "skynet_melee_fixo_l4d2");

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            OnClientPutInServer(i);
    }
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
        SDKHook(witch, SDKHook_OnTakeDamage, OnDanoWitch);
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnDanoTank);
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity > MaxClients && StrEqual(classname, "witch"))
    {
        SDKHook(entity, SDKHook_OnTakeDamage, OnDanoWitch);
        RequestFrame(F_VidaWitch, EntIndexToEntRef(entity));
    }
}

// Golpe de arma corpo a corpo dado por um sobrevivente (a motosserra fica de fora)
bool GolpeCorpoACorpo(int atacante, int inflictor, int tipo)
{
    if (atacante < 1 || atacante > MaxClients || !IsClientInGame(atacante) || GetClientTeam(atacante) != TIME_SOBREVIVENTE)
        return false;
    char classe[32];
    if (inflictor > MaxClients && IsValidEntity(inflictor))
    {
        GetEntityClassname(inflictor, classe, sizeof(classe));
        if (StrEqual(classe, "weapon_melee"))
            return true;
    }
    if (!(tipo & DMG_SLOWBURN))
        return false;
    int arma = GetEntPropEnt(atacante, Prop_Send, "m_hActiveWeapon");
    if (arma <= MaxClients || !IsValidEntity(arma))
        return false;
    GetEntityClassname(arma, classe, sizeof(classe));
    return StrEqual(classe, "weapon_melee");
}

public Action OnDanoTank(int vitima, int &atacante, int &inflictor, float &dano, int &tipo)
{
    float fixo = g_cvTank.FloatValue;
    if (fixo <= 0.0 || dano <= 0.0 || vitima < 1 || vitima > MaxClients || !IsClientInGame(vitima)
        || GetClientTeam(vitima) != TIME_INFECTADO || GetEntProp(vitima, Prop_Send, "m_zombieClass") != CLASSE_TANK)
        return Plugin_Continue;
    if (!GolpeCorpoACorpo(atacante, inflictor, tipo))
        return Plugin_Continue;
    if (g_cvDebug.BoolValue)
        Avisar(atacante, "Tank", dano, fixo, GetClientHealth(vitima), GetEntProp(vitima, Prop_Data, "m_iMaxHealth"));
    dano = fixo;
    return Plugin_Changed;
}

public Action OnDanoWitch(int vitima, int &atacante, int &inflictor, float &dano, int &tipo)
{
    float fixo = g_cvWitch.FloatValue;
    if (fixo <= 0.0 || dano <= 0.0 || !GolpeCorpoACorpo(atacante, inflictor, tipo))
        return Plugin_Continue;
    if (g_cvDebug.BoolValue)
        Avisar(atacante, "Witch", dano, fixo, GetEntProp(vitima, Prop_Data, "m_iHealth"), GetEntProp(vitima, Prop_Data, "m_iMaxHealth"));
    dano = fixo;
    return Plugin_Changed;
}

// Teste: "o jogo tiraria" e o dano que chegou ao plugin (sem plugin nenhum, 5% da vida maxima do Tank e 25% da Witch);
// se a "vida antes do golpe" cair menos que o dano do plugin de um golpe pro outro, outro plugin esta reduzindo o dano depois.
void Avisar(int atacante, const char[] alvo, float jogo, float fixo, int vida, int maxima)
{
    PrintToChat(atacante, "\x04[melee]\x01 %s: o jogo tiraria %.0f, o plugin tira %.0f | vida antes do golpe: %d de %d", alvo, jogo, fixo, vida, maxima);
    LogMessage("%N bateu no %s: jogo %.0f, plugin %.0f, vida antes %d/%d", atacante, alvo, jogo, fixo, vida, maxima);
}

int SobreviventesVivos()
{
    int n = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && GetClientTeam(i) == TIME_SOBREVIVENTE && IsPlayerAlive(i))
            n++;
    }
    return n;
}

// Vida da Witch: minima com ate 4 sobreviventes vivos, sobe por igual ate a maxima e para nela
// (padrao: 4 = 1000, 5 = 1667, 6 = 2333, 7 = 3000, 8 = 3667, 9 = 4333, 10 ou mais = 5000)
public void F_VidaWitch(int ref)
{
    int witch = EntRefToEntIndex(ref);
    int maxima = g_cvVidaMax.IntValue;
    if (witch == INVALID_ENT_REFERENCE || maxima <= 0)
        return;
    int minima = g_cvVidaMin.IntValue;
    int ate = g_cvVidaMaxCom.IntValue;
    int vivos = SobreviventesVivos();
    int vida = minima;
    if (vivos >= ate)
        vida = maxima;
    else if (vivos > 4)
        vida = minima + RoundToNearest(float(maxima - minima) * float(vivos - 4) / float(ate - 4));
    SetEntProp(witch, Prop_Data, "m_iMaxHealth", vida);
    SetEntProp(witch, Prop_Data, "m_iHealth", vida);
}
