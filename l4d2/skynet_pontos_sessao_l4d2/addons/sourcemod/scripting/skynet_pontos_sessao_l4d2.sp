#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

// Fornecidas pelo Point System API (PointSystemAPI.smx)
native float PSAPI_GetPoints(int client);
native void PSAPI_HardSetPoints(int client, float fPoints);

public Plugin myinfo =
{
    name = "SKYNET Pontos por Sessao (L4D2)",
    author = "SKYNET GAMING",
    description = "Os pontos da loja duram a campanha inteira e zeram quando o jogador sai do servidor ou a campanha termina",
    version = "1.1",
    url = "https://github.com/lmattedi/skynet-sourcemod-plugins"
};

// 1.1: o Point System devolve, na fase seguinte, o saldo que o jogador tinha quando entrou no time
// (ele so guarda o saldo quando o jogador troca de time). Agora este plugin guarda o saldo de cada um
// e devolve depois da troca de fase.

StringMap g_hSessao;          // SteamIDs de quem esta numa sessao (sobrevive a troca de mapa)
StringMap g_hPontos;          // SteamID -> saldo guardado
bool g_bPronto[MAXPLAYERS + 1];   // saldo ja conferido nesta fase: pode ser guardado
int g_iEspera[MAXPLAYERS + 1];    // rodadas do T_Guardar esperando a conferencia
ConVar g_cvInicio;
char g_sLog[PLATFORM_MAX_PATH];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("PSAPI_GetPoints");
    MarkNativeAsOptional("PSAPI_HardSetPoints");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_hSessao = new StringMap();
    g_hPontos = new StringMap();
    BuildPath(Path_SM, g_sLog, sizeof(g_sLog), "logs/skynet_pontos.log");
    HookEvent("player_disconnect", Ev_Saiu, EventHookMode_Pre);   // so dispara quando o jogador sai de verdade
    HookEvent("player_team", Ev_Time);
    HookEvent("finale_win", Ev_FimDaCampanha, EventHookMode_PostNoCopy);
    HookEvent("round_end", Ev_FimDaRodada, EventHookMode_PostNoCopy);
    CreateTimer(2.0, T_Guardar, _, TIMER_REPEAT);

    // carregado com gente jogando: quem ja esta no servidor continua a sessao que tem
    char id[64];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientAuthId(i, AuthId_Steam2, id, sizeof(id)))
        {
            g_hSessao.SetValue(id, true);
            g_bPronto[i] = true;
        }
    }
}

public void OnConfigsExecuted()
{
    if (g_cvInicio == null)
        g_cvInicio = FindConVar("l4d2_points_start");
}

bool PsapiPronto()
{
    return GetFeatureStatus(FeatureType_Native, "PSAPI_HardSetPoints") == FeatureStatus_Available;
}

float PontosIniciais()
{
    if (g_cvInicio == null)
        g_cvInicio = FindConVar("l4d2_points_start");
    return g_cvInicio != null ? g_cvInicio.FloatValue : 0.0;
}

// guarda o saldo de quem ja foi conferido nesta fase e esta jogando de sobrevivente
void GuardarTodos()
{
    if (!PsapiPronto())
        return;
    char id[64];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_bPronto[i] && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2
            && GetClientAuthId(i, AuthId_Steam2, id, sizeof(id)))
            g_hPontos.SetValue(id, PSAPI_GetPoints(i));
    }
}

public Action T_Guardar(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!g_bPronto[i] && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2 && ++g_iEspera[i] >= 3)
            Conferir(i);
    }
    GuardarTodos();
    return Plugin_Continue;
}

public void Ev_FimDaRodada(Event event, const char[] name, bool dontBroadcast)
{
    GuardarTodos();
}

public void OnMapEnd()
{
    GuardarTodos();
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bPronto[i] = false;
        g_iEspera[i] = 0;
    }
}

public void OnClientDisconnect(int client)
{
    g_bPronto[client] = false;
    g_iEspera[client] = 0;
}

public void Ev_Saiu(Event event, const char[] name, bool dontBroadcast)
{
    if (event.GetInt("bot"))
        return;
    char id[64];
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientConnected(client) || IsFakeClient(client) || !GetClientAuthId(client, AuthId_Steam2, id, sizeof(id), false))
        event.GetString("networkid", id, sizeof(id));
    if (id[0] != '\0')
    {
        g_hSessao.Remove(id);
        g_hPontos.Remove(id);
    }
}

public void Ev_Time(Event event, const char[] name, bool dontBroadcast)
{
    if (event.GetBool("disconnect"))
        return;
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (client <= 0 || IsFakeClient(client))
        return;
    DataPack dp = new DataPack();
    dp.WriteCell(userid);
    dp.WriteCell(0);
    CreateTimer(1.0, T_ConferirSessao, dp, TIMER_DATA_HNDL_CLOSE);
}

public Action T_ConferirSessao(Handle timer, DataPack dp)
{
    dp.Reset();
    int userid = dp.ReadCell();
    int tentativas = dp.ReadCell();
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Stop;

    if (!Conferir(client) && tentativas < 20)   // a Steam ainda nao confirmou o jogador: tenta de novo
    {
        DataPack outro = new DataPack();
        outro.WriteCell(userid);
        outro.WriteCell(tentativas + 1);
        CreateTimer(2.0, T_ConferirSessao, outro, TIMER_DATA_HNDL_CLOSE);
    }
    return Plugin_Stop;
}

// sessao nova: pontos iniciais; mesma sessao: devolve o saldo guardado se o Point System mexeu nele
// retorna false se a Steam ainda nao confirmou o jogador
bool Conferir(int client)
{
    char id[64];
    if (!GetClientAuthId(client, AuthId_Steam2, id, sizeof(id)))
        return false;
    if (!PsapiPronto() || GetClientTeam(client) != 2)   // so confere quem esta jogando de sobrevivente
        return true;
    float agora = PSAPI_GetPoints(client);

    bool ja;
    if (g_hSessao.GetValue(id, ja))
    {
        float guardado;
        if (!g_bPronto[client] && g_hPontos.GetValue(id, guardado) && RoundToFloor(guardado) != RoundToFloor(agora))
        {
            PSAPI_HardSetPoints(client, guardado);
            LogToFileEx(g_sLog, "%L troca de fase: pontos %.0f -> %.0f (saldo guardado)", client, agora, guardado);
        }
        g_bPronto[client] = true;
        return true;
    }
    g_hSessao.SetValue(id, true);

    float inicio = PontosIniciais();
    PSAPI_HardSetPoints(client, inicio);
    g_hPontos.SetValue(id, inicio);
    g_bPronto[client] = true;
    if (RoundToFloor(agora) != RoundToFloor(inicio))
        LogToFileEx(g_sLog, "%L entrou no servidor: pontos %.0f -> %.0f (sessao nova)", client, agora, inicio);
    return true;
}

public void Ev_FimDaCampanha(Event event, const char[] name, bool dontBroadcast)
{
    // espera o proprio Point System terminar o que ele faz no fim da campanha
    CreateTimer(0.5, T_ZerarTodos, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_ZerarTodos(Handle timer)
{
    if (!PsapiPronto())
        return Plugin_Stop;
    float inicio = PontosIniciais();
    char id[64];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i))
            continue;
        PSAPI_HardSetPoints(i, inicio);
        if (GetClientAuthId(i, AuthId_Steam2, id, sizeof(id)))
            g_hPontos.SetValue(id, inicio);
        PrintToChat(i, "\x04[PONTOS]\x01 Campanha concluída! Seus pontos voltaram para \x05%d\x01.", RoundToFloor(inicio));
    }
    LogToFileEx(g_sLog, "Fim da campanha: pontos de todos voltaram para %.0f", inicio);
    return Plugin_Stop;
}
