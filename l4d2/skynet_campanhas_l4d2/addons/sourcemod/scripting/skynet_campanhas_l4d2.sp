#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <adminmenu>
#pragma semicolon 1
#pragma newdecls required

#define MAX_CAMP 14
#define MAX_OPTS 5
#define NUNCA -100000

// Fornecida pelo Left 4 DHooks (opcional: as campanhas oficiais ja estao na tabela abaixo)
native bool L4D_IsMissionFinalMap(bool anyMap = false);
// Verdadeiro enquanto o veiculo de resgate vai embora, ate a tela escurecer e os creditos comecarem
native bool L4D_IsFinaleEscapeInProgress();
native bool L4D_HasAnySurvivorLeftSafeArea();
// Caminho da votacao do jogo: reinicia a rodada trocando de mapa (a abertura da campanha roda normal)
native int L4D_RestartScenarioFromVote(const char[] map);

public Plugin myinfo =
{
    name = "SKYNET Proxima Campanha (L4D2)",
    author = "SKYNET GAMING",
    description = "Votacao da proxima campanha na fase final, troca automatica no fim e menu de campanhas para os admins",
    version = "1.6",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

static const char g_sCod[MAX_CAMP][] = { "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10", "c11", "c12", "c13", "c14" };
static const char g_sNome[MAX_CAMP][] =
{
    "Dead Center", "Dark Carnival", "Swamp Fever", "Hard Rain", "The Parish", "The Passing", "The Sacrifice",
    "No Mercy", "Crash Course", "Death Toll", "Dead Air", "Blood Harvest", "Cold Stream", "The Last Stand"
};
static const char g_sInicio[MAX_CAMP][] =
{
    "c1m1_hotel", "c2m1_highway", "c3m1_plankcountry", "c4m1_milltown_a", "c5m1_waterfront", "c6m1_riverbank",
    "c7m1_docks", "c8m1_apartment", "c9m1_alleys", "c10m1_caves", "c11m1_greenhouse", "c12m1_hilltop",
    "c13m1_alpinecreek", "c14m1_junkyard"
};
static const char g_sFinal[MAX_CAMP][] =
{
    "c1m4_atrium", "c2m5_concert", "c3m4_plantation", "c4m5_milltown_escape", "c5m5_bridge", "c6m3_port",
    "c7m3_port", "c8m5_rooftop", "c9m2_lots", "c10m5_houseboat", "c11m5_runway", "c12m5_cornfield",
    "c13m4_cutthroatcreek", "c14m2_lighthouse"
};

ConVar g_cvTempo, g_cvOpcoes, g_cvCooldown, g_cvStarve, g_cvEspera, g_cvTroca;
ConVar g_cvPenal, g_cvVoteGrow, g_cvVoteCap, g_cvPlayGrow, g_cvPlayCap;

bool g_bValida[MAX_CAMP];
int g_LastPlayed[MAX_CAMP];      // numero da campanha (contador) em que foi jogada pela ultima vez
int g_LastVoted[MAX_CAMP];       // numero da votacao em que apareceu pela ultima vez
int g_Contador;                  // quantas campanhas ja comecaram
int g_VoteCounter;               // quantas votacoes ja aconteceram
int g_Atual = -1;                // campanha em andamento (registrada quando alguem sai do abrigo)

int g_Proxima = -1;              // escolhida para depois desta campanha
bool g_bVotou;                   // a votacao deste mapa ja aconteceu
char g_sMapaVoto[PLATFORM_MAX_PATH];   // mapa (fase final) em que a votacao aconteceu: o resultado vale ate o resgate
TopMenu g_hTopMenu;
bool g_bTrocando;
int g_Opt[MAX_OPTS];
int g_OptCount;
int g_Tentativas;
Handle g_hTimerVoto;
Handle g_hTimerFuga;
Handle g_hTimerSaida;
ConVar g_cvAtraso;
ConVar g_cvAbertura;
bool g_bFugaVista;
bool g_bMudou;
int g_iTicksFuga;
char g_sEstado[PLATFORM_MAX_PATH];
char g_sLog[PLATFORM_MAX_PATH];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("L4D_IsMissionFinalMap");
    MarkNativeAsOptional("L4D_IsFinaleEscapeInProgress");
    MarkNativeAsOptional("L4D_HasAnySurvivorLeftSafeArea");
    MarkNativeAsOptional("L4D_RestartScenarioFromVote");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_cvTempo     = CreateConVar("skynet_campanha_tempo", "25", "Duracao da votacao, em segundos", _, true, 10.0, true, 60.0);
    g_cvOpcoes    = CreateConVar("skynet_campanha_opcoes", "3", "Quantas campanhas aparecem na votacao", _, true, 2.0, true, 5.0);
    g_cvCooldown  = CreateConVar("skynet_campanha_cooldown", "3", "Campanhas jogadas nas ultimas N campanhas ficam fora da votacao", _, true, 0.0, true, 8.0);
    g_cvStarve    = CreateConVar("skynet_campanha_starve", "4", "Campanha que nao aparece ha N votacoes ganha vaga garantida", _, true, 2.0);
    g_cvEspera    = CreateConVar("skynet_campanha_espera", "20", "Segundos depois de sair do abrigo, na fase final, para abrir a votacao", _, true, 5.0);
    g_cvTroca     = CreateConVar("skynet_campanha_troca", "15", "Segundos maximos depois do resgate para trocar, se o fim do resgate nao for detectado", _, true, 5.0, true, 120.0);
    g_cvPenal     = CreateConVar("skynet_campanha_penalidade", "0.25", "Multiplicador para quem apareceu na votacao anterior e nao ganhou", _, true, 0.0);
    g_cvVoteGrow  = CreateConVar("skynet_campanha_vote_grow", "0.20", "Bonus por votacao sem aparecer", _, true, 0.0);
    g_cvVoteCap   = CreateConVar("skynet_campanha_vote_cap", "2.0", "Bonus maximo por tempo fora da votacao", _, true, 1.0);
    g_cvPlayGrow  = CreateConVar("skynet_campanha_play_grow", "0.30", "Bonus por campanha sem ser jogada (depois do cooldown)", _, true, 0.0);
    g_cvPlayCap   = CreateConVar("skynet_campanha_play_cap", "3.0", "Bonus maximo por tempo sem ser jogada", _, true, 1.0);
    g_cvAtraso    = CreateConVar("skynet_campanha_atraso", "12", "Segundos de creditos e musica final, depois que a tela escurece no fim do resgate, antes de trocar de campanha", _, true, 1.0, true, 60.0);
    g_cvAbertura  = CreateConVar("skynet_campanha_abertura", "1", "1 = troca pelo caminho da votacao do jogo (a abertura da campanha aparece), 0 = changelevel", _, true, 0.0, true, 1.0);
    AutoExecConfig(true, "skynet_campanhas_l4d2");

    BuildPath(Path_SM, g_sEstado, sizeof(g_sEstado), "data/skynet_campanhas.txt");
    BuildPath(Path_SM, g_sLog, sizeof(g_sLog), "logs/skynet_campanhas.log");

    HookEvent("player_left_start_area", Ev_SaiuDoAbrigo, EventHookMode_PostNoCopy);
    HookEvent("finale_win", Ev_Resgate, EventHookMode_PostNoCopy);
    HookEventEx("finale_vehicle_leaving", Ev_VeiculoSaindo, EventHookMode_PostNoCopy);
    HookEvent("round_start", Ev_InicioRodada, EventHookMode_PostNoCopy);
    HookEventEx("finale_start", Ev_FinalComecou, EventHookMode_PostNoCopy);

    RegConsoleCmd("sm_proxima", Cmd_Proxima, "Mostra a proxima campanha");
    RegAdminCmd("sm_campanha_trocar", Cmd_Trocar, ADMFLAG_CHANGEMAP, "Troca de campanha agora (comeca do primeiro capitulo)");
    RegAdminCmd("sm_campanha_votar", Cmd_Votar, ADMFLAG_VOTE, "Votacao da proxima campanha (a troca so acontece depois do resgate)");
    RegAdminCmd("sm_campanha_status", Cmd_Status, ADMFLAG_CHANGEMAP, "Mostra o historico e o peso de cada campanha");

    TopMenu topmenu;
    if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
        OnAdminMenuReady(topmenu);
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "adminmenu"))
        g_hTopMenu = null;
}

// Menu de admin: "Trocar campanha" (comandos do servidor) e "Votar campanha" (comandos de votacao)
public void OnAdminMenuReady(Handle aTopMenu)
{
    TopMenu topmenu = TopMenu.FromHandle(aTopMenu);
    if (topmenu == g_hTopMenu)
        return;
    g_hTopMenu = topmenu;
    TopMenuObject servidor = g_hTopMenu.FindCategory(ADMINMENU_SERVERCOMMANDS);
    if (servidor != INVALID_TOPMENUOBJECT)
        g_hTopMenu.AddItem("skynet_campanha_trocar", Item_Trocar, servidor, "sm_campanha_trocar", ADMFLAG_CHANGEMAP);
    TopMenuObject votos = g_hTopMenu.FindCategory(ADMINMENU_VOTINGCOMMANDS);
    if (votos != INVALID_TOPMENUOBJECT)
        g_hTopMenu.AddItem("skynet_campanha_votar", Item_Votar, votos, "sm_campanha_votar", ADMFLAG_VOTE);
}

public void Item_Trocar(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
    if (action == TopMenuAction_DisplayOption)
        strcopy(buffer, maxlength, "Trocar campanha");
    else if (action == TopMenuAction_SelectOption)
        MenuTrocar(param, true);
}

public void Item_Votar(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
    if (action == TopMenuAction_DisplayOption)
        strcopy(buffer, maxlength, "Votar proxima campanha");
    else if (action == TopMenuAction_SelectOption)
        VotacaoAgora(param);
}

int IntMax(int a, int b) { return a > b ? a : b; }

int CampanhaDoMapa(const char[] mapa)
{
    // mapas oficiais: c<numero>m<capitulo>_...
    if (mapa[0] != 'c' || !IsCharNumeric(mapa[1]))
        return -1;
    int n = 0, i = 1;
    while (IsCharNumeric(mapa[i]))
    {
        n = n * 10 + (mapa[i] - '0');
        i++;
    }
    if (mapa[i] != 'm' || n < 1 || n > MAX_CAMP)
        return -1;
    return n - 1;
}

bool EhFaseFinal()
{
    char mapa[PLATFORM_MAX_PATH];
    GetCurrentMap(mapa, sizeof(mapa));
    int c = CampanhaDoMapa(mapa);
    if (c != -1 && StrEqual(mapa, g_sFinal[c], false))
        return true;
    if (GetFeatureStatus(FeatureType_Native, "L4D_IsMissionFinalMap") == FeatureStatus_Available)
        return L4D_IsMissionFinalMap();
    return false;
}

void CarregarEstado()
{
    g_Contador = 0;
    g_VoteCounter = 0;
    g_Atual = -1;
    for (int i = 0; i < MAX_CAMP; i++)
    {
        g_bValida[i] = IsMapValid(g_sInicio[i]);
        g_LastPlayed[i] = NUNCA;
        g_LastVoted[i] = NUNCA;
    }
    KeyValues kv = new KeyValues("SkynetCampanhas");
    if (kv.ImportFromFile(g_sEstado))
    {
        g_Contador = kv.GetNum("contador", 0);
        g_VoteCounter = kv.GetNum("votacoes", 0);
        char atual[8];
        kv.GetString("atual", atual, sizeof(atual), "");
        for (int i = 0; i < MAX_CAMP; i++)
        {
            if (StrEqual(atual, g_sCod[i]))
                g_Atual = i;
            if (kv.JumpToKey(g_sCod[i]))
            {
                g_LastPlayed[i] = kv.GetNum("jogada", NUNCA);
                g_LastVoted[i] = kv.GetNum("votada", NUNCA);
                kv.GoBack();
            }
        }
    }
    delete kv;
}

void SalvarEstado()
{
    KeyValues kv = new KeyValues("SkynetCampanhas");
    kv.SetNum("contador", g_Contador);
    kv.SetNum("votacoes", g_VoteCounter);
    kv.SetString("atual", g_Atual >= 0 ? g_sCod[g_Atual] : "");
    for (int i = 0; i < MAX_CAMP; i++)
    {
        kv.JumpToKey(g_sCod[i], true);
        kv.SetString("nome", g_sNome[i]);
        kv.SetNum("jogada", g_LastPlayed[i]);
        kv.SetNum("votada", g_LastVoted[i]);
        kv.GoBack();
    }
    kv.Rewind();
    kv.ExportToFile(g_sEstado);
    delete kv;
}

public void OnMapStart()
{
    CarregarEstado();
    // O resultado da votacao da fase final so vale ate o resgate. Se o time perder e a fase final
    // recomecar, a escolha continua guardada e a votacao nao abre de novo.
    char mapa[PLATFORM_MAX_PATH];
    GetCurrentMap(mapa, sizeof(mapa));
    // a escolha vale ate o fim da campanha em que foi votada (troca de capitulo e derrota nao apagam)
    int cAgora = CampanhaDoMapa(mapa);
    bool mesma = g_sMapaVoto[0] != '\0' && (cAgora != -1 ? cAgora == CampanhaDoMapa(g_sMapaVoto) : StrEqual(mapa, g_sMapaVoto, false));
    if (cAgora != -1 && StrEqual(mapa, g_sInicio[cAgora], false))
        mesma = false;                 // campanha recomecou do capitulo 1: vota de novo no final
    if (!mesma)
    {
        g_Proxima = -1;
        g_bVotou = false;
        g_OptCount = 0;
        g_sMapaVoto[0] = '\0';
    }
    g_bTrocando = false;
    g_hTimerVoto = null;
    g_hTimerFuga = null;
    g_hTimerSaida = null;
    g_bFugaVista = false;
    g_bMudou = false;
}

public void OnMapEnd()
{
    g_hTimerVoto = null;
}

float Peso(int i, int proxVoto)
{
    int sinceP = g_Contador - g_LastPlayed[i];
    int sinceV = proxVoto - g_LastVoted[i];
    float fp = 1.0 + g_cvPlayGrow.FloatValue * float(IntMax(sinceP - g_cvCooldown.IntValue, 0));
    if (fp > g_cvPlayCap.FloatValue)
        fp = g_cvPlayCap.FloatValue;
    float fv;
    if (sinceV == 1)
        fv = g_cvPenal.FloatValue;
    else
    {
        fv = 1.0 + g_cvVoteGrow.FloatValue * float(IntMax(sinceV - 1, 0));
        if (fv > g_cvVoteCap.FloatValue)
            fv = g_cvVoteCap.FloatValue;
    }
    return fp * fv;
}

int MontarOpcoes(int[] saida, int quantas, bool registrar)
{
    int proxVoto = g_VoteCounter + 1;
    int cooldown = g_cvCooldown.IntValue;
    char mapa[PLATFORM_MAX_PATH];
    GetCurrentMap(mapa, sizeof(mapa));
    int atual = CampanhaDoMapa(mapa);

    int pool[MAX_CAMP];
    int n = 0;
    for (int i = 0; i < MAX_CAMP; i++)
    {
        if (!g_bValida[i] || i == atual || i == g_Atual || g_Contador - g_LastPlayed[i] <= cooldown)
            continue;
        pool[n++] = i;
    }
    if (n < quantas)                  // poucas fora do cooldown: completa com as recentes
    {
        for (int i = 0; i < MAX_CAMP; i++)
        {
            if (!g_bValida[i] || i == atual || i == g_Atual)
                continue;
            bool ja = false;
            for (int k = 0; k < n; k++)
            {
                if (pool[k] == i)
                    ja = true;
            }
            if (!ja && n < MAX_CAMP)
                pool[n++] = i;
        }
    }

    int feitas = 0;
    // vaga garantida para quem esta ha mais tempo sem aparecer
    int melhor = -1, melhorTempo = -1;
    for (int k = 0; k < n; k++)
    {
        int s = proxVoto - g_LastVoted[pool[k]];
        if (s >= g_cvStarve.IntValue && s > melhorTempo)
        {
            melhor = k;
            melhorTempo = s;
        }
    }
    if (melhor != -1 && feitas < quantas)
    {
        saida[feitas++] = pool[melhor];
        pool[melhor] = pool[--n];
    }
    // sorteio com peso, sem repetir
    while (feitas < quantas && n > 0)
    {
        float total = 0.0;
        for (int k = 0; k < n; k++)
            total += Peso(pool[k], proxVoto);
        float r = GetURandomFloat() * total;
        int escolhida = n - 1;
        float acc = 0.0;
        for (int k = 0; k < n; k++)
        {
            acc += Peso(pool[k], proxVoto);
            if (acc >= r)
            {
                escolhida = k;
                break;
            }
        }
        saida[feitas++] = pool[escolhida];
        pool[escolhida] = pool[--n];
    }
    // embaralha a ordem na tela: a vaga garantida nao fica sempre na tecla 1
    for (int k = feitas - 1; k > 0; k--)
    {
        int j = GetURandomInt() % (k + 1);
        int tmp = saida[k];
        saida[k] = saida[j];
        saida[j] = tmp;
    }

    if (registrar && feitas > 0)
    {
        g_VoteCounter = proxVoto;
        for (int k = 0; k < feitas; k++)
            g_LastVoted[saida[k]] = proxVoto;
        SalvarEstado();
    }
    return feitas;
}

int ContarHumanos()
{
    int c = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
            c++;
    }
    return c;
}

public void Ev_SaiuDoAbrigo(Event event, const char[] name, bool dontBroadcast)
{
    AoSairDoAbrigo();
}

// Left 4 DHooks avisa a saida do abrigo de forma mais confiavel que o evento do jogo
public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
    AoSairDoAbrigo();
}

// Fase final: confere a cada segundo se alguem ja saiu do abrigo (nao depende de evento do jogo)
public void Ev_InicioRodada(Event event, const char[] name, bool dontBroadcast)
{
    if (g_hTimerSaida == null && EhFaseFinal())
        g_hTimerSaida = CreateTimer(1.0, T_VigiaSaida, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_VigiaSaida(Handle timer)
{
    if (g_bVotou || g_bTrocando || g_hTimerVoto != null)
    {
        g_hTimerSaida = null;
        return Plugin_Stop;
    }
    if (GetFeatureStatus(FeatureType_Native, "L4D_HasAnySurvivorLeftSafeArea") == FeatureStatus_Available
        && L4D_HasAnySurvivorLeftSafeArea())
    {
        g_hTimerSaida = null;
        AoSairDoAbrigo();
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// O final comecou (radio/botao do resgate): se a votacao ainda nao abriu, abre agora
public void Ev_FinalComecou(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bVotou || g_bTrocando || g_hTimerVoto != null || !EhFaseFinal())
        return;
    g_Tentativas = 0;
    g_hTimerVoto = CreateTimer(2.0, T_AbrirVotacao, _, TIMER_FLAG_NO_MAPCHANGE);
    LogToFileEx(g_sLog, "Final comecou: votacao abre em 2 s");
}

void AoSairDoAbrigo()
{
    char mapa[PLATFORM_MAX_PATH];
    GetCurrentMap(mapa, sizeof(mapa));
    int c = CampanhaDoMapa(mapa);
    if (c != -1 && c != g_Atual)       // comecou uma campanha nova (vale pra votacao: fica na "geladeira")
    {
        g_Contador++;
        g_LastPlayed[c] = g_Contador;
        g_Atual = c;
        SalvarEstado();
        LogToFileEx(g_sLog, "Campanha em andamento: %s (%s), numero %d", g_sNome[c], mapa, g_Contador);
    }
    if (!EhFaseFinal() || g_hTimerVoto != null)
        return;
    if (g_bVotou)
    {
        LogToFileEx(g_sLog, "Fase final (%s): votacao nao abre, a proxima ja foi escolhida (%s)", mapa,
            g_Proxima != -1 ? g_sNome[g_Proxima] : "?");
        return;
    }
    g_Tentativas = 0;
    g_hTimerVoto = CreateTimer(g_cvEspera.FloatValue, T_AbrirVotacao, _, TIMER_FLAG_NO_MAPCHANGE);
    LogToFileEx(g_sLog, "Fase final (%s): votacao abre em %d s", mapa, g_cvEspera.IntValue);
}

public Action T_AbrirVotacao(Handle timer)
{
    if (g_bVotou || g_bTrocando)
    {
        g_hTimerVoto = null;
        return Plugin_Stop;
    }
    if (IsVoteInProgress())            // outra votacao rolando: tenta de novo daqui a pouco
    {
        if (++g_Tentativas < 36)
        {
            g_hTimerVoto = CreateTimer(5.0, T_AbrirVotacao, _, TIMER_FLAG_NO_MAPCHANGE);
            return Plugin_Stop;
        }
        g_hTimerVoto = null;
        return Plugin_Stop;
    }
    g_hTimerVoto = null;
    AbrirVotacao();
    return Plugin_Stop;
}

void AbrirVotacao()
{
    if (g_bVotou || ContarHumanos() == 0)
        return;
    int quantas = g_cvOpcoes.IntValue;
    if (quantas > MAX_OPTS)
        quantas = MAX_OPTS;
    g_OptCount = MontarOpcoes(g_Opt, quantas, true);
    if (g_OptCount == 0)
        return;
    g_bVotou = true;
    GetCurrentMap(g_sMapaVoto, sizeof(g_sMapaVoto));
    if (g_OptCount == 1)
    {
        g_Proxima = g_Opt[0];
        PrintToChatAll("\x04[SKYNET GAMING]\x01 Próxima campanha: \x05%s\x01.", g_sNome[g_Proxima]);
        return;
    }

    Menu menu = new Menu(Handler_Voto, MENU_ACTIONS_ALL);
    menu.SetTitle("Vote na proxima campanha:");
    for (int k = 0; k < g_OptCount; k++)
        menu.AddItem(g_sCod[g_Opt[k]], g_sNome[g_Opt[k]]);
    menu.ExitButton = false;
    menu.DisplayVoteToAll(g_cvTempo.IntValue);
    if (EhFaseFinal())
        PrintToChatAll("\x04[SKYNET GAMING]\x01 Fase final! Vote na \x05próxima campanha\x01 com as teclas \x051\x01 a \x05%d\x01.", g_OptCount);
    else
        PrintToChatAll("\x04[SKYNET GAMING]\x01 Vote na \x05próxima campanha\x01 com as teclas \x051\x01 a \x05%d\x01. Ela começa quando vocês terminarem esta.", g_OptCount);
}

int IndicePorCodigo(const char[] cod)
{
    for (int i = 0; i < MAX_CAMP; i++)
    {
        if (StrEqual(cod, g_sCod[i]))
            return i;
    }
    return -1;
}

public int Handler_Voto(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_VoteEnd)
    {
        char cod[8];
        menu.GetItem(param1, cod, sizeof(cod));
        int votos, total;
        GetMenuVoteInfo(param2, votos, total);
        g_Proxima = IndicePorCodigo(cod);
        if (g_Proxima != -1)
        {
            PrintToChatAll("\x04[SKYNET GAMING]\x01 Próxima campanha: \x05%s\x01 (%d de %d votos). Ela começa logo depois do resgate.",
                g_sNome[g_Proxima], votos, total);
            LogToFileEx(g_sLog, "Votacao: %s venceu com %d de %d votos", g_sNome[g_Proxima], votos, total);
        }
    }
    else if (action == MenuAction_VoteCancel && g_OptCount > 0)
    {
        g_Proxima = g_Opt[0];
        PrintToChatAll("\x04[SKYNET GAMING]\x01 Ninguém votou. Próxima campanha: \x05%s\x01.", g_sNome[g_Proxima]);
        LogToFileEx(g_sLog, "Votacao sem votos: %s escolhida pelo sorteio", g_sNome[g_Proxima]);
    }
    return 0;
}

public void Ev_Resgate(Event event, const char[] name, bool dontBroadcast)
{
    if (!FinalizarCampanha())
        return;
    IniciarVigia();
    CreateTimer(g_cvTroca.FloatValue, T_Reserva, _, TIMER_FLAG_NO_MAPCHANGE);
}

// Resgate concluido: escolhe a proxima (se ninguem votou) e guarda o estado. Roda uma vez so.
bool FinalizarCampanha()
{
    if (g_bTrocando)
        return false;
    g_bTrocando = true;
    delete g_hTimerVoto;
    if (g_Proxima == -1 && g_OptCount > 0)
        g_Proxima = g_Opt[0];
    if (g_Proxima == -1)
    {
        int escolha[MAX_OPTS];
        if (MontarOpcoes(escolha, 3, true) > 0)
        {
            g_Proxima = escolha[0];        // as opcoes ja saem embaralhadas
            LogToFileEx(g_sLog, "Sem votacao nesta campanha: proxima sorteada (%s)", g_sNome[g_Proxima]);
        }
    }
    g_Atual = -1;                      // campanha terminada
    SalvarEstado();
    if (g_Proxima == -1)
        return false;
    PrintToChatAll("\x04[SKYNET GAMING]\x01 Campanha concluída! A próxima é \x05%s\x01, logo depois do resgate.", g_sNome[g_Proxima]);
    LogToFileEx(g_sLog, "Resgate: proxima campanha %s (%s)", g_sNome[g_Proxima], g_sInicio[g_Proxima]);
    return true;
}

public void Ev_VeiculoSaindo(Event event, const char[] name, bool dontBroadcast)
{
    IniciarVigia();
}

// Acompanha o veiculo indo embora: quando a tela escurece para os creditos, troca de campanha
void IniciarVigia()
{
    if (g_hTimerFuga != null || g_bMudou)
        return;
    if (GetFeatureStatus(FeatureType_Native, "L4D_IsFinaleEscapeInProgress") != FeatureStatus_Available)
        return;
    g_iTicksFuga = 0;
    g_hTimerFuga = CreateTimer(0.1, T_VigiaFuga, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_VigiaFuga(Handle timer)
{
    if (L4D_IsFinaleEscapeInProgress())
        g_bFugaVista = true;
    else if (g_bFugaVista)
    {
        g_hTimerFuga = null;
        TrocarNoFim("fim do resgate");
        return Plugin_Stop;
    }
    if (++g_iTicksFuga > 3000)          // 5 minutos sem sinal: desiste (a reserva cuida)
    {
        g_hTimerFuga = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

public Action T_Reserva(Handle timer)
{
    TrocarNoFim("tempo limite");
    return Plugin_Stop;
}

void TrocarNoFim(const char[] motivo)
{
    if (g_bMudou)
        return;
    FinalizarCampanha();
    if (g_Proxima == -1)
        return;
    g_bMudou = true;
    delete g_hTimerFuga;
    LogToFileEx(g_sLog, "Trocando para %s (%s) em %.0f s: %s", g_sNome[g_Proxima], g_sInicio[g_Proxima], g_cvAtraso.FloatValue, motivo);
    CreateTimer(g_cvAtraso.FloatValue, T_Trocar, g_Proxima, TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Trocar(Handle timer, any c)
{
    if (c < 0 || c >= MAX_CAMP || !g_bValida[c])
        return Plugin_Stop;
    if (g_cvAbertura.BoolValue
        && GetFeatureStatus(FeatureType_Native, "L4D_RestartScenarioFromVote") == FeatureStatus_Available)
    {
        // reserva antes da chamada: se o jogo nao trocar de mapa, o changelevel garante a troca
        CreateTimer(15.0, T_TrocarReserva, c, TIMER_FLAG_NO_MAPCHANGE);
        LogToFileEx(g_sLog, "Mudando para %s pelo caminho da votacao do jogo", g_sInicio[c]);
        L4D_RestartScenarioFromVote(g_sInicio[c]);
        return Plugin_Stop;
    }
    ForceChangeLevel(g_sInicio[c], "SKYNET: proxima campanha");
    return Plugin_Stop;
}

public Action T_TrocarReserva(Handle timer, any c)
{
    LogToFileEx(g_sLog, "O jogo nao trocou de mapa em 15 s: usando changelevel para %s", g_sInicio[c]);
    ForceChangeLevel(g_sInicio[c], "SKYNET: proxima campanha");
    return Plugin_Stop;
}

public Action Cmd_Proxima(int client, int args)
{
    if (g_Proxima != -1)
        ReplyToCommand(client, "[SKYNET] Próxima campanha: %s", g_sNome[g_Proxima]);
    else
        ReplyToCommand(client, "[SKYNET] A próxima campanha é escolhida por votação no início da fase final.");
    return Plugin_Handled;
}

public Action Cmd_Votar(int client, int args)
{
    VotacaoAgora(client);
    return Plugin_Handled;
}

public Action Cmd_Trocar(int client, int args)
{
    if (args > 0)                      // pelo console: sm_campanha_trocar c2
    {
        char cod[8];
        GetCmdArg(1, cod, sizeof(cod));
        int c = IndicePorCodigo(cod);
        if (c == -1 || !g_bValida[c])
            ReplyToCommand(client, "[SKYNET] Use o codigo da campanha: c1 a c14.");
        else
            TrocarAgora(client, c);
        return Plugin_Handled;
    }
    if (client == 0)
    {
        ReplyToCommand(client, "[SKYNET] Use: sm_campanha_trocar c1 (a c14)");
        return Plugin_Handled;
    }
    MenuTrocar(client, false);
    return Plugin_Handled;
}

void MenuTrocar(int client, bool voltar)
{
    char mapa[PLATFORM_MAX_PATH], texto[64];
    GetCurrentMap(mapa, sizeof(mapa));
    int atual = CampanhaDoMapa(mapa);
    Menu menu = new Menu(Handler_Trocar);
    menu.SetTitle("Trocar campanha (comeca do primeiro capitulo):");
    for (int i = 0; i < MAX_CAMP; i++)
    {
        if (!g_bValida[i])
            continue;
        if (i == atual)
            Format(texto, sizeof(texto), "%s (atual)", g_sNome[i]);
        else
            strcopy(texto, sizeof(texto), g_sNome[i]);
        menu.AddItem(g_sCod[i], texto);
    }
    menu.ExitBackButton = voltar && g_hTopMenu != null;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Trocar(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End)
        delete menu;
    else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack && g_hTopMenu != null)
        g_hTopMenu.Display(param1, TopMenuPosition_LastCategory);
    else if (action == MenuAction_Select)
    {
        char cod[8];
        menu.GetItem(param2, cod, sizeof(cod));
        int c = IndicePorCodigo(cod);
        if (c != -1)
            TrocarAgora(param1, c);
    }
    return 0;
}

void TrocarAgora(int client, int c)
{
    if (g_bTrocando)
        return;
    g_bTrocando = true;
    if (client > 0 && IsClientInGame(client))
        PrintToChatAll("\x04[SKYNET GAMING]\x01 \x03%N\x01 trocou a campanha para \x05%s\x01. Começando do primeiro capítulo...", client, g_sNome[c]);
    else
        PrintToChatAll("\x04[SKYNET GAMING]\x01 Trocando a campanha para \x05%s\x01. Começando do primeiro capítulo...", g_sNome[c]);
    LogAction(client, -1, "\"%L\" trocou a campanha para %s", client, g_sNome[c]);
    LogToFileEx(g_sLog, "Admin %L trocou para %s (%s)", client, g_sNome[c], g_sInicio[c]);
    CreateTimer(3.0, T_Trocar, c, TIMER_FLAG_NO_MAPCHANGE);
}

// Votacao aberta por um admin: escolhe a PROXIMA campanha, igual a da fase final (troca so depois do resgate)
void VotacaoAgora(int client)
{
    if (IsVoteInProgress())
    {
        if (client > 0)
            PrintToChat(client, "\x04[SKYNET GAMING]\x01 Já tem uma votação acontecendo.");
        return;
    }
    if (g_bTrocando)
        return;
    if (client > 0 && IsClientInGame(client))
        PrintToChatAll("\x04[SKYNET GAMING]\x01 \x03%N\x01 abriu a votação da próxima campanha.", client);
    delete g_hTimerVoto;               // a votacao automatica da fase final nao abre mais
    g_bVotou = false;
    g_Proxima = -1;
    AbrirVotacao();
}

public Action Cmd_Status(int client, int args)
{
    int proxVoto = g_VoteCounter + 1;
    int cooldown = g_cvCooldown.IntValue;
    ReplyToCommand(client, "[SKYNET] campanha | campanhas sem jogar | votacoes sem aparecer | peso");
    for (int i = 0; i < MAX_CAMP; i++)
    {
        int sinceP = g_Contador - g_LastPlayed[i];
        int sinceV = proxVoto - g_LastVoted[i];
        char sp[16], sv[16];
        if (sinceP > 50000) strcopy(sp, sizeof(sp), "nunca"); else IntToString(sinceP, sp, sizeof(sp));
        if (sinceV > 50000) strcopy(sv, sizeof(sv), "nunca"); else IntToString(sinceV - 1, sv, sizeof(sv));
        bool fora = sinceP <= cooldown || i == g_Atual;
        ReplyToCommand(client, "%s %s | %s | %s | %.2f%s", g_sCod[i], g_sNome[i], sp, sv,
            fora ? 0.0 : Peso(i, proxVoto), !g_bValida[i] ? " (nao instalada)" : (fora ? " (recente, fora)" : ""));
    }
    if (g_Proxima != -1)
        ReplyToCommand(client, "Proxima campanha: %s", g_sNome[g_Proxima]);
    return Plugin_Handled;
}
