// SKYNET Vote Difficulty (L4D2): !dificuldade (or !dif) opens a menu with the difficulties and a vote for everyone.
//   It passes with more "Yes" than "No" votes (players who do not vote do not count). One vote every 2 minutes.
//   The voted difficulty lasts until the end of the campaign (or until the server empties); then it goes back to Expert.
//   While it lasts, SKYNET Always Expert is turned off (skynet_sempre_expert 0).
// 1.2: back to the 1.0 behavior (one player starts the vote, the majority approves with Yes/No); 1.1 worked like RTV.
#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name        = "SKYNET Votar Dificuldade (L4D2)",
    author      = "SKYNET GAMING",
    description = "Votacao dos jogadores para mudar a dificuldade; volta ao Expert no fim da campanha",
    version     = "1.2",
    url         = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

native bool L4D_IsFirstMapInScenario();     // Left 4 DHooks

static const char g_sValor[][] = {"Easy", "Normal", "Hard", "Impossible"};
static const char g_sNome[][]  = {"Fácil", "Normal", "Avançado", "Expert"};

ConVar g_cvDif, g_cvEspera, g_cvTempo;
float g_fUltimo;
int g_iAlvo = -1;
bool g_bVotada;                 // difficulty changed by a vote (goes back to Expert later)
char g_sMapa[64];               // last map played (to know when another campaign starts)

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("L4D_IsFirstMapInScenario");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_cvDif = FindConVar("z_difficulty");
    if (g_cvDif == null)
        SetFailState("z_difficulty nao existe neste jogo");
    g_cvEspera = CreateConVar("skynet_dificuldade_espera", "120", "Segundos entre uma votacao e outra", _, true, 0.0);
    g_cvTempo  = CreateConVar("skynet_dificuldade_tempo", "20", "Duracao da votacao em segundos", _, true, 5.0, true, 60.0);
    AutoExecConfig(true, "skynet_dificuldade_l4d2");
    RegConsoleCmd("sm_dificuldade", Cmd_Dif, "Abre uma votacao para mudar a dificuldade");
    RegConsoleCmd("sm_dif", Cmd_Dif, "Abre uma votacao para mudar a dificuldade");
    HookEvent("finale_win", Ev_Fim, EventHookMode_PostNoCopy);
    HookEvent("player_disconnect", Ev_Saiu, EventHookMode_PostNoCopy);   // only fires when someone really leaves
    GetCurrentMap(g_sMapa, sizeof(g_sMapa));
}

public void OnMapStart()
{
    char mapa[64];
    GetCurrentMap(mapa, sizeof(mapa));
    if (g_bVotada && !StrEqual(mapa, g_sMapa) && GetFeatureStatus(FeatureType_Native, "L4D_IsFirstMapInScenario") == FeatureStatus_Available && L4D_IsFirstMapInScenario())
        VoltaExpert("campanha nova");
    strcopy(g_sMapa, sizeof(g_sMapa), mapa);
}

public void Ev_Fim(Event e, const char[] n, bool b)
{
    VoltaExpert("fim da campanha");
}

public void Ev_Saiu(Event e, const char[] n, bool b)
{
    if (g_bVotada)
        CreateTimer(5.0, T_Vazio, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Vazio(Handle t)
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientConnected(i) && !IsFakeClient(i))
            return Plugin_Stop;
    VoltaExpert("servidor vazio");
    return Plugin_Stop;
}

void VoltaExpert(const char[] motivo)
{
    if (!g_bVotada)
        return;
    g_bVotada = false;
    ConVar sempre = FindConVar("skynet_sempre_expert");
    if (sempre != null)
        sempre.BoolValue = true;
    g_cvDif.SetString("Impossible");
    LogMessage("Dificuldade de volta ao Expert (%s)", motivo);
    PrintToChatAll("\x04[SKYNET]\x01 Dificuldade de volta ao \x05Expert\x01 (%s).", motivo);
}

int Atual()
{
    char s[32];
    g_cvDif.GetString(s, sizeof(s));
    for (int i = 0; i < sizeof(g_sValor); i++)
        if (StrEqual(s, g_sValor[i], false))
            return i;
    return -1;
}

bool Pode(int client)
{
    if (IsVoteInProgress())
    {
        PrintToChat(client, "\x04[SKYNET]\x01 Já tem uma votação acontecendo. Espere ela terminar.");
        return false;
    }
    float falta = g_fUltimo + g_cvEspera.FloatValue - GetEngineTime();
    if (g_fUltimo > 0.0 && falta > 0.0)
    {
        PrintToChat(client, "\x04[SKYNET]\x01 Espere \x05%d s\x01 para abrir outra votação de dificuldade.", RoundToCeil(falta));
        return false;
    }
    return true;
}

public Action Cmd_Dif(int client, int args)
{
    if (client < 1 || !IsClientInGame(client))
        return Plugin_Handled;
    if (!Pode(client))
        return Plugin_Handled;
    int atual = Atual();
    Menu m = new Menu(H_Escolha);
    m.SetTitle("Dificuldade agora: %s\nMudar para:", atual >= 0 ? g_sNome[atual] : "?");
    char id[4];
    for (int i = 0; i < sizeof(g_sValor); i++)
    {
        if (i == atual)
            continue;
        IntToString(i, id, sizeof(id));
        m.AddItem(id, g_sNome[i]);
    }
    m.Display(client, 20);
    return Plugin_Handled;
}

public int H_Escolha(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End)
        delete menu;
    else if (action == MenuAction_Select)
    {
        char id[4];
        menu.GetItem(item, id, sizeof(id));
        IniciaVoto(client, StringToInt(id));
    }
    return 0;
}

void IniciaVoto(int client, int alvo)
{
    if (!IsClientInGame(client) || !Pode(client) || alvo < 0 || alvo >= sizeof(g_sValor) || alvo == Atual())
        return;
    int clientes[MAXPLAYERS], n = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i))
            clientes[n++] = i;
    if (n == 0)
        return;
    g_iAlvo = alvo;
    Menu v = new Menu(H_Voto);
    v.SetTitle("Mudar a dificuldade para %s?", g_sNome[alvo]);
    v.AddItem("sim", "Sim");
    v.AddItem("nao", "Não");
    v.ExitButton = false;
    v.VoteResultCallback = R_Voto;
    v.DisplayVote(clientes, n, g_cvTempo.IntValue);
    g_fUltimo = GetEngineTime();
    PrintToChatAll("\x04[SKYNET]\x01 %N abriu uma votação para mudar a dificuldade para \x05%s\x01.", client, g_sNome[alvo]);
}

public int H_Voto(Menu menu, MenuAction action, int p1, int p2)
{
    if (action == MenuAction_End)
        delete menu;
    else if (action == MenuAction_VoteCancel && p1 == VoteCancel_NoVotes)
        PrintToChatAll("\x04[SKYNET]\x01 Ninguém votou. A dificuldade continua a mesma.");
    return 0;
}

public void R_Voto(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
    int sim = 0, nao = 0;
    char info[8];
    for (int i = 0; i < num_items; i++)
    {
        menu.GetItem(item_info[i][VOTEINFO_ITEM_INDEX], info, sizeof(info));
        if (StrEqual(info, "sim"))
            sim = item_info[i][VOTEINFO_ITEM_VOTES];
        else
            nao = item_info[i][VOTEINFO_ITEM_VOTES];
    }
    if (sim <= nao || g_iAlvo < 0)
    {
        PrintToChatAll("\x04[SKYNET]\x01 A votação não passou (%d sim x %d não). A dificuldade continua a mesma.", sim, nao);
        return;
    }
    int alvo = g_iAlvo;
    bool expert = alvo == 3;
    ConVar sempre = FindConVar("skynet_sempre_expert");
    if (sempre != null)
        sempre.BoolValue = expert;          // turns Always Expert off while the vote lasts
    g_cvDif.SetString(g_sValor[alvo]);
    g_bVotada = !expert;
    GetCurrentMap(g_sMapa, sizeof(g_sMapa));
    LogMessage("Votacao passou (%d x %d): dificuldade %s", sim, nao, g_sValor[alvo]);
    if (expert)
        PrintToChatAll("\x04[SKYNET]\x01 A votação passou (%d sim x %d não). Dificuldade: \x05Expert\x01.", sim, nao);
    else
        PrintToChatAll("\x04[SKYNET]\x01 A votação passou (%d sim x %d não). Dificuldade: \x05%s\x01 até o fim desta campanha.", sim, nao, g_sNome[alvo]);
}
