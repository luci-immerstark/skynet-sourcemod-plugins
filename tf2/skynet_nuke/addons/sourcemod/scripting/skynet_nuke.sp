#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Nuke",
    author = "SKYNET GAMING",
    description = "Deixa a NUKE do Dodgeball maior que os outros foguetes (so o visual)",
    version = "2.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

native int TFDB_FindRocketByEntity(int iEntity);
native int TFDB_GetRocketClass(int iIndex);
native void TFDB_GetRocketClassName(int iClass, char[] strBuffer, int iMaxLen);
native void TFDB_GetRocketClassLongName(int iClass, char[] strBuffer, int iMaxLen);

ConVar g_cvEscala;
ConVar g_cvClasse;
int g_iTentativas[2049];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("TFDB_FindRocketByEntity");
    MarkNativeAsOptional("TFDB_GetRocketClass");
    MarkNativeAsOptional("TFDB_GetRocketClassName");
    MarkNativeAsOptional("TFDB_GetRocketClassLongName");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_cvEscala = CreateConVar("skynet_nuke_escala", "5.0", "Tamanho da NUKE em relacao a um foguete normal", _, true, 0.5, true, 10.0);
    g_cvClasse = CreateConVar("skynet_nuke_classe", "nuke", "Nome da classe de foguete da NUKE no general.cfg do Dodgeball");
    AutoExecConfig(true, "skynet_nuke");
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity > MaxClients && entity < sizeof(g_iTentativas) && StrEqual(classname, "tf_projectile_rocket"))
    {
        g_iTentativas[entity] = 0;
        RequestFrame(F_Checar, EntIndexToEntRef(entity));
    }
}

public void F_Checar(int ref)
{
    int foguete = EntRefToEntIndex(ref);
    if (foguete == INVALID_ENT_REFERENCE)
        return;
    if (GetFeatureStatus(FeatureType_Native, "TFDB_GetRocketClassName") != FeatureStatus_Available)
        return;
    int idx = TFDB_FindRocketByEntity(foguete);
    if (idx == -1)
    {
        if (++g_iTentativas[foguete] < 5)
            RequestFrame(F_Checar, ref);
        return;
    }
    int classe = TFDB_GetRocketClass(idx);
    char nome[64], longo[64], alvo[64];
    TFDB_GetRocketClassName(classe, nome, sizeof(nome));
    TFDB_GetRocketClassLongName(classe, longo, sizeof(longo));
    g_cvClasse.GetString(alvo, sizeof(alvo));
    if (StrEqual(nome, alvo, false) || StrContains(longo, alvo, false) != -1)
        SetEntPropFloat(foguete, Prop_Send, "m_flModelScale", g_cvEscala.FloatValue);
}
