#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

// Fornecida pelo Left 4 DHooks (declarada aqui para nao depender do include na compilacao)
native void L4D_RespawnPlayer(int client, bool reset = true);

public Plugin myinfo =
{
    name = "SKYNET Rejoin (L4D2)",
    author = "SKYNET GAMING",
    description = "No inicio de cada rodada, recoloca no time quem ficou preso como espectador ou morto",
    version = "1.1",
    url = "https://github.com/lmattedi/skynet-sourcemod-plugins"
};

char g_sLog[PLATFORM_MAX_PATH];
ConVar g_cvEnable;
float g_fInicio;
float g_fMorte[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("L4D_RespawnPlayer");
    return APLRes_Success;
}

public void OnPluginStart()
{
    BuildPath(Path_SM, g_sLog, sizeof(g_sLog), "logs/skynet_rejoin.log");
    g_cvEnable = CreateConVar("skynet_rejoin_enable", "1", "Recoloca no time, no inicio da rodada, quem ficou preso como espectador ou morto", _, true, 0.0, true, 1.0);
    HookEvent("round_start", Ev_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("player_death", Ev_Morte);
    RegAdminCmd("sm_rejoin_check", Cmd_Check, ADMFLAG_GENERIC, "Faz agora a verificacao de jogadores presos");
}

public void OnMapStart()
{
    g_fInicio = 0.0;
    for (int i = 0; i <= MaxClients; i++)
        g_fMorte[i] = 0.0;
}

public void OnClientDisconnect(int client)
{
    g_fMorte[client] = 0.0;
}

public void Ev_Morte(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
        g_fMorte[client] = GetGameTime();
}

public void Ev_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_fInicio = GetGameTime();
    CreateTimer(8.0, T_Check, 8, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(20.0, T_Check, 20, TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Check(Handle timer, any segundos)
{
    char motivo[48];
    Format(motivo, sizeof(motivo), "%d s depois do round_start", segundos);
    Verificar(motivo);
    return Plugin_Stop;
}

public Action Cmd_Check(int client, int args)
{
    int n = Verificar("manual (sm_rejoin_check)");
    ReplyToCommand(client, "[SKYNET] Verificacao feita: %d jogador(es) recolocado(s).", n);
    return Plugin_Handled;
}

// Jogador ausente (idle): existe um bot sobrevivente guardando o lugar dele
bool EstaAusente(int client)
{
    int uid = GetClientUserId(client);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && HasEntProp(i, Prop_Send, "m_humanSpectatorUserID")
            && GetEntProp(i, Prop_Send, "m_humanSpectatorUserID") == uid)
            return true;
    }
    return false;
}

int SobreviventeVivo(int exceto)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i != exceto && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
            return i;
    }
    return 0;
}

int Verificar(const char[] motivo)
{
    if (!g_cvEnable.BoolValue)
        return 0;
    int n = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i))
            continue;
        if (GetClientTime(i) < 15.0)   // acabou de entrar: o plugin de slots cuida dele
            continue;

        int time = GetClientTeam(i);
        if (time == 1 && !EstaAusente(i))
        {
            LogToFileEx(g_sLog, "%s: %L estava como espectador sem personagem, colocando de volta no time", motivo, i);
            FakeClientCommand(i, "sm_join");
            PrintToChat(i, "\x04[SKYNET GAMING]\x01 Você foi colocado de volta no time.");
            n++;
        }
        else if (time == 2 && !IsPlayerAlive(i))
        {
            if (g_fMorte[i] > g_fInicio)    // morreu nesta rodada: morte normal, nao revive
                continue;
            if (GetFeatureStatus(FeatureType_Native, "L4D_RespawnPlayer") != FeatureStatus_Available)
            {
                LogToFileEx(g_sLog, "%s: %L estava morto, mas o Left 4 DHooks nao esta disponivel para reviver", motivo, i);
                continue;
            }
            int alvo = SobreviventeVivo(i);
            L4D_RespawnPlayer(i);
            if (alvo > 0)
            {
                float pos[3];
                GetClientAbsOrigin(alvo, pos);
                TeleportEntity(i, pos, NULL_VECTOR, NULL_VECTOR);
            }
            LogToFileEx(g_sLog, "%s: %L estava morto no inicio da rodada, revivido junto de #%d", motivo, i, alvo);
            PrintToChat(i, "\x04[SKYNET GAMING]\x01 Você foi revivido no início da rodada.");
            n++;
        }
    }
    return n;
}
