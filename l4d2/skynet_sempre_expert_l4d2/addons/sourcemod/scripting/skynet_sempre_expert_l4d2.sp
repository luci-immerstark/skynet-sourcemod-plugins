#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Sempre Expert (L4D2)",
    author = "SKYNET GAMING",
    description = "Mantem o servidor sempre na dificuldade Expert",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

// O lobby do jogo (ou uma votacao) pode trocar a dificuldade; a primeira campanha depois do servidor vazio
// comecava no Normal. Qualquer troca volta para o Expert ("Impossible" no jogo).

ConVar g_cvAtivo;
ConVar g_cvDificuldade;

public void OnPluginStart()
{
    g_cvAtivo = CreateConVar("skynet_sempre_expert", "1", "1 = o servidor fica sempre no Expert (0 = deixa trocar a dificuldade)", _, true, 0.0, true, 1.0);
    g_cvDificuldade = FindConVar("z_difficulty");
    if (g_cvDificuldade == null)
        SetFailState("z_difficulty nao existe neste jogo");
    g_cvDificuldade.AddChangeHook(OnDificuldadeMudou);
    g_cvAtivo.AddChangeHook(OnDificuldadeMudou);
    Forcar();
}

public void OnMapStart()
{
    Forcar();
}

public void OnConfigsExecuted()
{
    Forcar();
}

public void OnDificuldadeMudou(ConVar cv, const char[] antigo, const char[] novo)
{
    RequestFrame(F_Forcar);
}

public void F_Forcar(any nada)
{
    Forcar();
}

void Forcar()
{
    if (!g_cvAtivo.BoolValue)
        return;
    char atual[32];
    g_cvDificuldade.GetString(atual, sizeof(atual));
    if (!StrEqual(atual, "Impossible", false))
    {
        g_cvDificuldade.SetString("Impossible");
        LogMessage("Dificuldade %s trocada de volta para Expert", atual);
    }
    // tira a opcao "mudar dificuldade" da votacao do jogo (ela nao teria efeito)
    ConVar voto = FindConVar("sv_vote_issue_change_difficulty_allowed");
    if (voto != null && voto.BoolValue)
        voto.BoolValue = false;
}
