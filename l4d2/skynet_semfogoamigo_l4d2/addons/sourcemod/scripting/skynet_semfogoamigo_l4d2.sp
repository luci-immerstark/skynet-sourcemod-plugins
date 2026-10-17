#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Sem Fogo Amigo (L4D2)",
    author = "SKYNET GAMING",
    description = "Sem fogo amigo; molotov queima quem jogou; fogo de galao nao fere sobrevivente; fogo do mapa mais forte",
    version = "1.3",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

// 1.2: o molotov volta a queimar quem jogou; o fogo de galao de gasolina (e de barril de combustivel,
// inclusive quando um galao acende outro) nao fere sobrevivente nenhum; o fogo do proprio mapa fica mais forte.

#define FOGO_NADA     0
#define FOGO_MOLOTOV  1
#define FOGO_OUTRO    2     // galao de gasolina, barril de combustivel, fogos de artificio

ConVar g_cvAtivo;
ConVar g_cvGalao;
ConVar g_cvFogoMapa;
int g_iFogo[2049];
float g_fMolTempo = -100.0;
float g_vMolPos[3];

public void OnPluginStart()
{
    g_cvAtivo    = CreateConVar("skynet_sem_fogo_amigo", "1", "1 = sobreviventes nao causam dano uns nos outros", _, true, 0.0, true, 1.0);
    g_cvGalao    = CreateConVar("skynet_galao_sem_dano", "1", "1 = o fogo de galao de gasolina, de barril e dos fogos de artificio nao fere sobreviventes", _, true, 0.0, true, 1.0);
    g_cvFogoMapa = CreateConVar("skynet_fogo_mapa", "3.0", "Multiplicador do dano do fogo do proprio mapa nos sobreviventes (1 = normal do jogo)", _, true, 0.0, true, 20.0);
    AutoExecConfig(true, "skynet_semfogoamigo_l4d2");
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            OnClientPutInServer(i);
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, AoLevarDano);
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity > MaxClients && entity < sizeof(g_iFogo))
    {
        g_iFogo[entity] = FOGO_NADA;
        if (StrEqual(classname, "fire_cracker_blast"))
            g_iFogo[entity] = FOGO_OUTRO;      // caixa de fogos de artificio
        else if (StrEqual(classname, "inferno"))
        {
            g_iFogo[entity] = FOGO_OUTRO;      // ate provar que veio de um molotov
            RequestFrame(T_QualFogo, EntIndexToEntRef(entity));
        }
    }
}

public void OnEntityDestroyed(int entity)
{
    if (entity <= MaxClients || entity >= sizeof(g_iFogo) || !IsValidEntity(entity))
        return;
    g_iFogo[entity] = FOGO_NADA;
    char classe[32];
    GetEntityClassname(entity, classe, sizeof(classe));
    if (StrEqual(classe, "molotov_projectile"))
    {
        g_fMolTempo = GetGameTime();
        GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", g_vMolPos);
    }
}

// o fogo do molotov nasce onde a garrafa quebrou, no mesmo instante
public void T_QualFogo(int ref)
{
    int fogo = EntRefToEntIndex(ref);
    if (fogo == INVALID_ENT_REFERENCE)
        return;
    float pos[3], outro[3];
    GetEntPropVector(fogo, Prop_Data, "m_vecAbsOrigin", pos);
    bool molotov = GetGameTime() - g_fMolTempo < 0.5 && GetVectorDistance(pos, g_vMolPos) < 250.0;
    int garrafa = -1;
    while (!molotov && (garrafa = FindEntityByClassname(garrafa, "molotov_projectile")) != -1)
    {
        GetEntPropVector(garrafa, Prop_Data, "m_vecAbsOrigin", outro);
        molotov = GetVectorDistance(pos, outro) < 250.0;
    }
    g_iFogo[fogo] = molotov ? FOGO_MOLOTOV : FOGO_OUTRO;
}

// fogo que faz parte do mapa (fogueiras, carros e predios pegando fogo)
bool FogoDoMapa(int inflictor, int atacante)
{
    int ent = inflictor > 0 ? inflictor : atacante;
    if (ent == 0)
        return true;
    if (ent <= MaxClients || !IsValidEntity(ent))
        return false;
    char classe[32];
    GetEntityClassname(ent, classe, sizeof(classe));
    return StrEqual(classe, "env_fire") || StrEqual(classe, "trigger_hurt") || StrEqual(classe, "point_hurt");
}

int TipoFogo(int ent)
{
    return (ent > MaxClients && ent < sizeof(g_iFogo)) ? g_iFogo[ent] : FOGO_NADA;
}

// Jogador responsavel por uma entidade (granada do lanca-granadas, fogo do molotov), ou 0
int Dono(int ent)
{
    if (ent >= 1 && ent <= MaxClients)
        return ent;
    if (ent > MaxClients && IsValidEntity(ent) && HasEntProp(ent, Prop_Data, "m_hOwnerEntity"))
    {
        int dono = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
        if (dono >= 1 && dono <= MaxClients)
            return dono;
    }
    return 0;
}

public Action AoLevarDano(int vitima, int &atacante, int &inflictor, float &dano, int &tipo)
{
    if (vitima < 1 || vitima > MaxClients || !IsClientInGame(vitima) || GetClientTeam(vitima) != 2)
        return Plugin_Continue;

    bool queima = (tipo & (DMG_BURN | DMG_SLOWBURN)) != 0;
    int fogo = TipoFogo(inflictor);
    if (fogo == FOGO_NADA)
        fogo = TipoFogo(atacante);

    // fogo de galao de gasolina ou barril (inclusive um galao acendendo outro): sem dano
    if (queima && fogo == FOGO_OUTRO && g_cvGalao.BoolValue)
    {
        dano = 0.0;
        return Plugin_Handled;
    }

    int quem = 0;
    if (atacante >= 1 && atacante <= MaxClients)
        quem = atacante;
    else
    {
        quem = Dono(atacante);
        if (quem == 0)
            quem = Dono(inflictor);
    }

    // fogo amigo: so o proprio jogador se machuca (o molotov queima quem jogou)
    if (g_cvAtivo.BoolValue && quem != 0 && quem != vitima && IsClientInGame(quem) && GetClientTeam(quem) == 2)
    {
        dano = 0.0;
        return Plugin_Handled;
    }

    // fogo do proprio mapa (nao veio de jogador, molotov nem galao): mais forte
    if (queima && fogo == FOGO_NADA && quem == 0 && g_cvFogoMapa.FloatValue != 1.0 && FogoDoMapa(inflictor, atacante))
    {
        dano *= g_cvFogoMapa.FloatValue;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}
