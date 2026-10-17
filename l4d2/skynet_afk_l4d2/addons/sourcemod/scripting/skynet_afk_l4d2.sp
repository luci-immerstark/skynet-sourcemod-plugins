#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET AFK (L4D2)",
    author = "SKYNET GAMING",
    description = "Expulsa quem fica ausente (sem mexer) por muito tempo, para liberar a vaga",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

// Com o "Jogo com Ausentes" a partida nao acaba mais quando todo mundo fica ausente.
// Este plugin expulsa quem passa do tempo sem apertar nada nem mexer o mouse (avisando 1 minuto antes).
// Sobrevivente morto esperando resgate nao conta como ausente.

ConVar g_cvMinutos;
ConVar g_cvImuneAdmin;
float g_fAtivo[MAXPLAYERS + 1];
int g_iBotoes[MAXPLAYERS + 1];
bool g_bAvisado[MAXPLAYERS + 1];

public void OnPluginStart()
{
    g_cvMinutos = CreateConVar("skynet_afk_minutos", "10", "Minutos ausente ate ser expulso (0 = desligado)", _, true, 0.0, true, 120.0);
    g_cvImuneAdmin = CreateConVar("skynet_afk_imune_admin", "0", "1 = admins nunca sao expulsos por ausencia", _, true, 0.0, true, 1.0);
    AutoExecConfig(true, "skynet_afk_l4d2");
    for (int i = 1; i <= MaxClients; i++)
        Ativo(i);
    CreateTimer(10.0, T_Conferir, _, TIMER_REPEAT);
}

void Ativo(int client)
{
    g_fAtivo[client] = GetEngineTime();
    g_bAvisado[client] = false;
}

// troca de mapa: ninguem envia comandos durante o carregamento
public void OnMapStart()
{
    for (int i = 1; i <= MaxClients; i++)
        Ativo(i);
}

public void OnClientPutInServer(int client)
{
    Ativo(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon,
                             int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (buttons != g_iBotoes[client] || impulse != 0 || mouse[0] != 0 || mouse[1] != 0)
    {
        g_iBotoes[client] = buttons;
        if (!IsFakeClient(client))
            Ativo(client);
    }
    return Plugin_Continue;
}

bool Espanhol(int client)
{
    char codigo[8], nome[32];
    GetLanguageInfo(GetClientLanguage(client), codigo, sizeof(codigo), nome, sizeof(nome));
    return StrEqual(codigo, "es") || StrEqual(codigo, "las");
}

public Action T_Conferir(Handle timer)
{
    int minutos = g_cvMinutos.IntValue;
    if (minutos <= 0)
        return Plugin_Continue;
    float limite = minutos * 60.0;
    float agora = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i))
            continue;
        if ((GetClientTeam(i) == 2 && !IsPlayerAlive(i))
            || (g_cvImuneAdmin.BoolValue && GetUserAdmin(i) != INVALID_ADMIN_ID))
        {
            Ativo(i);
            continue;
        }
        float parado = agora - g_fAtivo[i];
        if (parado >= limite)
        {
            LogAction(-1, i, "\"%L\" expulso por ficar %d minutos ausente", i, minutos);
            if (Espanhol(i))
                KickClient(i, "Ausente por más de %d minutos", minutos);
            else
                KickClient(i, "Ausente por mais de %d minutos", minutos);
        }
        else if (parado >= limite - 60.0 && !g_bAvisado[i])
        {
            g_bAvisado[i] = true;
            if (Espanhol(i))
            {
                PrintToChat(i, "\x04[SKYNET]\x01 Estás ausente: si no te mueves en \x031 minuto\x01, serás expulsado.");
                PrintHintText(i, "¡Muévete o serás expulsado en 1 minuto!");
            }
            else
            {
                PrintToChat(i, "\x04[SKYNET]\x01 Você está ausente: se não se mexer em \x031 minuto\x01, será expulso.");
                PrintHintText(i, "Mexa-se ou será expulso em 1 minuto!");
            }
        }
    }
    return Plugin_Continue;
}
