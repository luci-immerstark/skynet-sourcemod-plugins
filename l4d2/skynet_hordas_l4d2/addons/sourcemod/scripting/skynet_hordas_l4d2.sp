#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

// SKYNET: o jogo foi feito para 4 sobreviventes e nao aumenta as hordas de zumbis comuns sozinho.
// Este plugin ajusta as hordas pelo numero de sobreviventes vivos (os especiais ficam com o Infected Bots).
//   fator = 1 + skynet_hordas_fator x (vivos - 4), nunca abaixo de 0.6; cada valor fica limitado a skynet_hordas_max

public Plugin myinfo =
{
    name = "SKYNET Hordas L4D2",
    author = "SKYNET GAMING",
    description = "Hordas de zumbis comuns proporcionais ao numero de sobreviventes vivos",
    version = "1.0",
    url = "https://github.com/lmattedi/skynet-sourcemod-plugins"
};

// cvars do jogo e os valores originais (feitos para 4 sobreviventes)
static const char g_sCvar[][] = { "z_common_limit", "z_mob_spawn_min_size", "z_mob_spawn_max_size", "z_mob_spawn_finale_size", "z_mega_mob_size" };
static const int g_iBase[] = { 30, 10, 30, 20, 50 };

ConVar g_cvFator;
ConVar g_cvMax;
ConVar g_hJogo[sizeof(g_sCvar)];
int g_iVivos = -1;

public void OnPluginStart()
{
    g_cvFator = CreateConVar("skynet_hordas_fator", "0.10", "Quanto cada sobrevivente vivo acima de 4 aumenta as hordas (0.10 = +10% por sobrevivente)", _, true, 0.0, true, 1.0);
    g_cvMax   = CreateConVar("skynet_hordas_max", "100", "Teto de cada valor (zumbis comuns ao mesmo tempo e tamanho das hordas)", _, true, 30.0, true, 200.0);
    AutoExecConfig(true, "skynet_hordas_l4d2");
    for (int i = 0; i < sizeof(g_sCvar); i++)
        g_hJogo[i] = FindConVar(g_sCvar[i]);
    g_cvFator.AddChangeHook(OnAjusteMudou);
    g_cvMax.AddChangeHook(OnAjusteMudou);
    RegAdminCmd("sm_hordas", Cmd_Hordas, ADMFLAG_GENERIC, "Mostra o tamanho atual das hordas");
    CreateTimer(3.0, T_Conferir, _, TIMER_REPEAT);
}

public void OnPluginEnd()
{
    for (int i = 0; i < sizeof(g_sCvar); i++)
        if (g_hJogo[i] != null)
            g_hJogo[i].IntValue = g_iBase[i];
}

// o server.cfg e a troca de mapa podem voltar os valores: aplica de novo
public void OnConfigsExecuted()
{
    g_iVivos = -1;
}

public void OnAjusteMudou(ConVar convar, const char[] antigo, const char[] novo)
{
    g_iVivos = -1;
}

public Action T_Conferir(Handle timer)
{
    int vivos = ContarVivos();
    if (vivos > 0 && vivos != g_iVivos)
    {
        g_iVivos = vivos;
        Aplicar(vivos);
    }
    return Plugin_Continue;
}

int ContarVivos()
{
    int n = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
            n++;
    return n;
}

float Fator(int vivos)
{
    float f = 1.0 + g_cvFator.FloatValue * float(vivos - 4);
    return f < 0.6 ? 0.6 : f;
}

int Valor(int i, int vivos)
{
    int v = RoundToNearest(float(g_iBase[i]) * Fator(vivos));
    return v > g_cvMax.IntValue ? g_cvMax.IntValue : v;
}

void Aplicar(int vivos)
{
    for (int i = 0; i < sizeof(g_sCvar); i++)
        if (g_hJogo[i] != null)
            g_hJogo[i].IntValue = Valor(i, vivos);
}

public Action Cmd_Hordas(int client, int args)
{
    int vivos = ContarVivos();
    ReplyToCommand(client, "[SKYNET] Sobreviventes vivos: %d (hordas x%.2f)", vivos, Fator(vivos));
    for (int i = 0; i < sizeof(g_sCvar); i++)
        if (g_hJogo[i] != null)
            ReplyToCommand(client, "  %s = %d (original %d)", g_sCvar[i], g_hJogo[i].IntValue, g_iBase[i]);
    return Plugin_Handled;
}
