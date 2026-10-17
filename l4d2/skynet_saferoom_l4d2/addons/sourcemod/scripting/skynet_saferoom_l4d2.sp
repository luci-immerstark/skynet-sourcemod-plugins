#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

#define FLAG_IGNORE_USE 32768   // porta ignora o botao de usar dos jogadores

// Fornecidas pelo Left 4 DHooks (declaradas aqui para nao depender do include na compilacao)
native int L4D_GetCheckpointFirst();
native int L4D_GetCheckpointLast();

public Plugin myinfo =
{
    name = "SKYNET Saferoom Door (L4D2)",
    author = "SKYNET GAMING",
    description = "Avisa quem abre e fecha a porta do abrigo e trava aberta a porta do abrigo inicial",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvAnnounce;
ConVar g_cvLock;
int g_iStartDoor = INVALID_ENT_REFERENCE;
float g_fLast[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("L4D_GetCheckpointFirst");
    MarkNativeAsOptional("L4D_GetCheckpointLast");
    return APLRes_Success;
}

// 1 = porta do abrigo inicial, 2 = porta do abrigo final, 0 = nao sei
int TipoDaPorta(int porta)
{
    if (GetFeatureStatus(FeatureType_Native, "L4D_GetCheckpointFirst") == FeatureStatus_Available)
    {
        if (porta == L4D_GetCheckpointFirst())
            return 1;
        if (porta == L4D_GetCheckpointLast())
            return 2;
    }
    // Reserva: pelo modelo (01 = saida do abrigo inicial, 02 = entrada do abrigo final)
    char model[96];
    GetEntPropString(porta, Prop_Data, "m_ModelName", model, sizeof(model));
    if (StrContains(model, "checkpoint_door_01") != -1 || StrContains(model, "checkpoint_door_-01") != -1)
        return 1;
    if (StrContains(model, "checkpoint_door_02") != -1 || StrContains(model, "checkpoint_door_-02") != -1)
        return 2;
    return 0;
}

public void OnPluginStart()
{
    g_cvAnnounce = CreateConVar("skynet_door_announce", "1", "Avisa no chat quem abre e fecha a porta do abrigo", _, true, 0.0, true, 1.0);
    g_cvLock = CreateConVar("skynet_door_lock_start", "1", "Depois de aberta, a porta do abrigo inicial nao pode mais ser fechada", _, true, 0.0, true, 1.0);
    HookEvent("door_open", Ev_Door);
    HookEvent("door_close", Ev_Door);
    HookEvent("round_start", Ev_RoundStart, EventHookMode_PostNoCopy);
}

void Zerar()
{
    g_iStartDoor = INVALID_ENT_REFERENCE;
    for (int i = 1; i <= MaxClients; i++)
        g_fLast[i] = 0.0;
}

public void OnMapStart()
{
    Zerar();
}

public void Ev_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    Zerar();
}

// Porta de abrigo mais perto do jogador que acabou de usar uma
int PortaMaisProxima(int client)
{
    float pos[3], dpos[3];
    GetClientAbsOrigin(client, pos);
    int melhor = -1;
    float menor = 250.0;
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1)
    {
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", dpos);
        float d = GetVectorDistance(pos, dpos);
        if (d < menor)
        {
            menor = d;
            melhor = ent;
        }
    }
    return melhor;
}

public void Ev_Door(Event event, const char[] name, bool dontBroadcast)
{
    if (!event.GetBool("checkpoint"))
        return;
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || !IsClientInGame(client))
        return;

    bool abriu = StrEqual(name, "door_open");
    int porta = PortaMaisProxima(client);
    int travada = EntRefToEntIndex(g_iStartDoor);
    bool inicial = false;
    bool final = false;
    if (porta != -1)
    {
        if (travada > MaxClients && porta == travada)
            inicial = true;
        else
        {
            int tipo = TipoDaPorta(porta);
            inicial = (tipo == 1);
            final = (tipo == 2);
        }
    }

    if (g_cvAnnounce.BoolValue && GetGameTime() - g_fLast[client] >= 1.0)
    {
        g_fLast[client] = GetGameTime();
        char qual[12];
        if (inicial)
            strcopy(qual, sizeof(qual), " inicial");
        else if (final)
            strcopy(qual, sizeof(qual), " final");
        if (abriu)
            PrintToChatAll("\x04[SKYNET GAMING]\x01 \x03%N\x01 abriu a porta do abrigo%s.", client, qual);
        else
            PrintToChatAll("\x04[SKYNET GAMING]\x01 \x03%N\x01 fechou a porta do abrigo%s.", client, qual);
    }

    if (!inicial || !g_cvLock.BoolValue)
        return;

    if (abriu)
    {
        if (travada <= MaxClients)
        {
            g_iStartDoor = EntIndexToEntRef(porta);
            SetEntProp(porta, Prop_Data, "m_spawnflags", GetEntProp(porta, Prop_Data, "m_spawnflags") | FLAG_IGNORE_USE);
            PrintToChatAll("\x04[SKYNET GAMING]\x01 A porta do abrigo inicial foi aberta e agora fica aberta ate o fim da rodada.");
        }
    }
    else if (travada > MaxClients && porta == travada)
    {
        // Fechou mesmo travada: abre de novo
        AcceptEntityInput(porta, "Open");
    }
}
