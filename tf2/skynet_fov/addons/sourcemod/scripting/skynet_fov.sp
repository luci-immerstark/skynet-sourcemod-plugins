// SKYNET: !fov <numero> no chat muda o campo de visao do jogador (75 a 120). !fov sozinho volta ao do jogo.
//   Le o chat direto (!fov 110, /fov 110, !fov110), sem depender do gatilho do SourceMod.
//   O valor fica salvo (clientprefs) e volta sozinho a cada spawn e a cada vez que o jogador entra.
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name        = "SKYNET FOV",
    author      = "SKYNET GAMING",
    description = "!fov <numero> para mudar o campo de visao",
    version     = "1.1.0",
    url         = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvMin, g_cvMax;
Cookie g_Cookie;
int g_Fov[MAXPLAYERS + 1];

public void OnPluginStart()
{
    g_cvMin = CreateConVar("skynet_fov_min", "75", "FOV minimo permitido no !fov", _, true, 20.0, true, 179.0);
    g_cvMax = CreateConVar("skynet_fov_max", "120", "FOV maximo permitido no !fov", _, true, 20.0, true, 179.0);
    AutoExecConfig(true, "skynet_fov");
    g_Cookie = new Cookie("skynet_fov", "FOV escolhido com !fov (0 = o do jogo)", CookieAccess_Private);
    RegConsoleCmd("sm_fov", Cmd_Fov, "!fov <numero> muda o campo de visao; !fov sozinho volta ao normal");
    HookEvent("player_spawn", Ev_Spawn);
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && AreClientCookiesCached(i))
            OnClientCookiesCached(i);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] bruto)
{
    char texto[64];
    strcopy(texto, sizeof(texto), bruto);
    StripQuotes(texto);
    TrimString(texto);
    if (client < 1 || !IsClientInGame(client) || (texto[0] != '!' && texto[0] != '/'))
        return Plugin_Continue;
    if (StrContains(texto[1], "fov", false) != 0 || (texto[4] != '\0' && texto[4] != ' ' && !IsCharNumeric(texto[4])))
        return Plugin_Continue;
    char arg[16];
    strcopy(arg, sizeof(arg), texto[4]);
    TrimString(arg);
    Fov(client, arg);
    return Plugin_Handled;      // trata aqui e esconde o comando do chat
}

public void OnClientConnected(int client)
{
    g_Fov[client] = 0;
}

public void OnClientCookiesCached(int client)
{
    char v[8];
    g_Cookie.Get(client, v, sizeof(v));
    g_Fov[client] = StringToInt(v);
    if (IsClientInGame(client) && IsPlayerAlive(client))
        Aplicar(client);
}

void Aplicar(int client)
{
    if (client < 1 || !IsClientInGame(client) || IsFakeClient(client) || g_Fov[client] <= 0)
        return;
    int fov = g_Fov[client];
    SetEntProp(client, Prop_Send, "m_iDefaultFOV", fov);
    if (!TF2_IsPlayerInCondition(client, TFCond_Zoomed))     // nao estraga a luneta do Sniper
        SetEntProp(client, Prop_Send, "m_iFOV", fov);
}

public void Ev_Spawn(Event event, const char[] nome, bool semTransmitir)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && g_Fov[client] > 0)
        CreateTimer(0.2, T_Aplicar, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Aplicar(Handle timer, int userid)
{
    Aplicar(GetClientOfUserId(userid));
    return Plugin_Stop;
}

public Action Cmd_Fov(int client, int args)
{
    char arg[16];
    if (args >= 1)
        GetCmdArg(1, arg, sizeof(arg));
    if (client > 0 && IsClientInGame(client))
        Fov(client, arg);
    return Plugin_Handled;
}

void Salvar(int client, const char[] v)
{
    if (AreClientCookiesCached(client))
        g_Cookie.Set(client, v);
}

void Fov(int client, const char[] arg)
{
    int lo = g_cvMin.IntValue, hi = g_cvMax.IntValue;
    if (arg[0] == '\0')
    {
        PrintToChat(client, "\x01\x07FFD700[FOV]\x01 Campo de visão de volta ao do jogo. Use \x07FFD700!fov %d\x01 a \x07FFD700!fov %d\x01 para mudar.", lo, hi);
        LogMessage("%L voltou o FOV ao do jogo", client);
        g_Fov[client] = 0;
        Salvar(client, "0");
        QueryClientConVar(client, "fov_desired", Q_FovDoJogo);
        return;
    }
    int fov = StringToInt(arg);
    if (fov < lo || fov > hi)
    {
        PrintToChat(client, "\x01\x07FFD700[FOV]\x01 Escolha um número de \x07FFD700%d\x01 a \x07FFD700%d\x01. Ex.: \x07FFD700!fov 110", lo, hi);
        return;
    }
    PrintToChat(client, "\x01\x07FFD700[FOV]\x01 Campo de visão: \x07FFD700%d\x01 (fica salvo). \x07FFD700!fov\x01 sozinho volta ao normal.", fov);
    LogMessage("%L mudou o FOV para %d", client, fov);
    g_Fov[client] = fov;
    char v[8];
    IntToString(fov, v, sizeof(v));
    Salvar(client, v);
    Aplicar(client);
}

public void Q_FovDoJogo(QueryCookie cookie, int client, ConVarQueryResult result, const char[] nome, const char[] valor)
{
    if (result != ConVarQuery_Okay || !IsClientInGame(client))
        return;
    int fov = StringToInt(valor);
    if (fov < 20 || fov > 179)
        fov = 90;
    SetEntProp(client, Prop_Send, "m_iDefaultFOV", fov);
    if (!TF2_IsPlayerInCondition(client, TFCond_Zoomed))
        SetEntProp(client, Prop_Send, "m_iFOV", fov);
}
