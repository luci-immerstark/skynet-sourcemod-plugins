#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

#define MAX_MAPS 64
#define MAX_OPTS 5
#define NUNCA -100000
#define ESTENDER "__estender__"

public Plugin myinfo =
{
    name = "SKYNET Map Vote",
    author = "SKYNET GAMING",
    description = "Votacao do proximo mapa (hype, tempo sem jogar, tempo fora da votacao) + opcao fixa de estender o mapa atual + !rtv + !nominate",
    version = "1.5",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvVoteTime, g_cvCooldown, g_cvStarve, g_cvOptions;
ConVar g_cvHypeExp, g_cvRecentPenalty, g_cvVoteGrow, g_cvVoteCap, g_cvPlayGrow, g_cvPlayCap;

char g_Map[MAX_MAPS][PLATFORM_MAX_PATH];
int g_Hype[MAX_MAPS];
int g_LastPlayed[MAX_MAPS];
int g_LastVoted[MAX_MAPS];
int g_Count;
int g_MapCounter;
int g_VoteCounter;
bool g_VoteStarted;
int g_RoundsPlayed;
Handle g_VoteTimer = null;
ConVar g_cvVoteDelay, g_cvMaxRounds, g_cvBefore, g_cvExtend;
bool g_bEstendido;
ConVar g_cvRtvNeeded, g_cvRtvDelay, g_cvRtvInterval;
bool g_bRtv[MAXPLAYERS + 1];
int g_Indicou[MAXPLAYERS + 1] = {-1, ...};   // mapa (indice em g_Map) que cada jogador indicou com !nominate
float g_fIndicouEm[MAXPLAYERS + 1];
bool g_Excluir[MAX_MAPS];                     // mapas que o sorteio nao pode repetir (ja entraram por indicacao)
bool g_bModoRtv;        // a votacao aberta agora veio do !rtv (o mapa troca na hora)
bool g_bVotoFeito;      // a votacao normal ja escolheu o proximo mapa
float g_fRtvLiberado;   // GetEngineTime() a partir do qual o !rtv vale
int g_iLimiteOriginal = -1;
int g_iRodadasOriginal = -1;
char g_ConfigFile[PLATFORM_MAX_PATH];
char g_StateFile[PLATFORM_MAX_PATH];
int g_Opt[MAX_OPTS];
int g_OptCount;

public void OnPluginStart()
{
    g_cvVoteTime      = CreateConVar("skynet_mapvote_time", "20", "Duracao da votacao, em segundos", _, true, 10.0, true, 60.0);
    g_cvCooldown      = CreateConVar("skynet_mapvote_cooldown", "3", "Mapas jogados nas ultimas N partidas ficam fora da votacao", _, true, 0.0);
    g_cvStarve        = CreateConVar("skynet_mapvote_starve", "12", "Mapa que nao aparece na votacao ha N votacoes ganha vaga garantida", _, true, 2.0);
    g_cvOptions       = CreateConVar("skynet_mapvote_options", "3", "Quantidade de mapas em cada votacao", _, true, 2.0, true, 5.0);
    g_cvHypeExp       = CreateConVar("skynet_mapvote_hype_exp", "2.5", "Forca do hype no sorteio (hype elevado a este numero)", _, true, 0.0);
    g_cvRecentPenalty = CreateConVar("skynet_mapvote_recent_penalty", "0.8", "Multiplicador para quem apareceu na ultima votacao", _, true, 0.0);
    g_cvVoteGrow      = CreateConVar("skynet_mapvote_vote_grow", "0.10", "Bonus por votacao sem aparecer", _, true, 0.0);
    g_cvVoteCap       = CreateConVar("skynet_mapvote_vote_cap", "1.8", "Bonus maximo por tempo fora da votacao", _, true, 1.0);
    g_cvPlayGrow      = CreateConVar("skynet_mapvote_play_grow", "0.10", "Bonus por partida sem ser jogado (depois do cooldown)", _, true, 0.0);
    g_cvPlayCap       = CreateConVar("skynet_mapvote_play_cap", "1.8", "Bonus maximo por tempo sem ser jogado", _, true, 1.0);
    g_cvVoteDelay     = CreateConVar("skynet_mapvote_delay", "180", "Segundos depois do inicio da ultima rodada para abrir a votacao", _, true, 30.0);
    g_cvMaxRounds     = FindConVar("mp_maxrounds");
    g_cvBefore        = CreateConVar("skynet_mapvote_before", "180", "Abre a votacao quando faltar este tempo (segundos) para o fim do mapa pelo mp_timelimit. 0 = usa o modo por rodadas", _, true, 0.0);
    g_cvExtend        = CreateConVar("skynet_mapvote_extend", "10", "Minutos a mais quando a votacao escolhe estender o mapa atual. 0 = sem essa opcao", _, true, 0.0, true, 60.0);
    g_cvRtvNeeded     = CreateConVar("skynet_rtv_needed", "0.60", "Fracao dos jogadores que precisa digitar !rtv para trocar de mapa", _, true, 0.05, true, 1.0);
    g_cvRtvDelay      = CreateConVar("skynet_rtv_delay", "60", "Segundos depois do inicio do mapa para liberar o !rtv", _, true, 0.0);
    g_cvRtvInterval   = CreateConVar("skynet_rtv_interval", "240", "Se a maioria escolher continuar, segundos ate o !rtv valer de novo", _, true, 0.0);
    AutoExecConfig(true, "skynet_mapvote");

    BuildPath(Path_SM, g_ConfigFile, sizeof(g_ConfigFile), "configs/skynet_mapvote.txt");
    BuildPath(Path_SM, g_StateFile, sizeof(g_StateFile), "configs/skynet_mapvote_state.txt");

    HookEventEx("teamplay_game_over", Ev_GameOver, EventHookMode_PostNoCopy);
    HookEventEx("tf_game_over", Ev_GameOver, EventHookMode_PostNoCopy);
    HookEventEx("teamplay_round_win", Ev_RoundWin, EventHookMode_PostNoCopy);
    HookEventEx("teamplay_round_start", Ev_RoundStart, EventHookMode_PostNoCopy);

    RegConsoleCmd("sm_rtv", Cmd_Rtv, "Vota para trocar de mapa agora");
    RegConsoleCmd("sm_rockthevote", Cmd_Rtv, "Vota para trocar de mapa agora");
    RegConsoleCmd("sm_nominate", Cmd_Nominate, "Indica um mapa para a proxima votacao");
    RegAdminCmd("sm_mapvote_status", Cmd_Status, ADMFLAG_CHANGEMAP, "Mostra o hype, o historico e o peso de cada mapa");
    RegAdminCmd("sm_mapvote_now", Cmd_Now, ADMFLAG_CHANGEMAP, "Inicia agora a votacao do proximo mapa");
}

int IntMax(int a, int b) { return a > b ? a : b; }

int FindMapIndex(const char[] map)
{
    for (int i = 0; i < g_Count; i++)
        if (StrEqual(g_Map[i], map, false))
            return i;
    return -1;
}

void MV_LoadMaps()
{
    g_Count = 0;
    KeyValues kv = new KeyValues("SkynetMapVote");
    if (!kv.ImportFromFile(g_ConfigFile))
    {
        LogError("Arquivo de hype nao encontrado: %s", g_ConfigFile);
        delete kv;
        return;
    }
    if (kv.GotoFirstSubKey(false))
    {
        do
        {
            if (g_Count >= MAX_MAPS)
                break;
            char map[PLATFORM_MAX_PATH];
            kv.GetSectionName(map, sizeof(map));
            int hype = kv.GetNum(NULL_STRING, 3);
            if (!IsMapValid(map))
            {
                LogError("Mapa %s nao esta instalado e foi ignorado", map);
                continue;
            }
            strcopy(g_Map[g_Count], sizeof(g_Map[]), map);
            g_Hype[g_Count] = hype < 0 ? 0 : (hype > 5 ? 5 : hype);
            g_LastPlayed[g_Count] = NUNCA;
            g_LastVoted[g_Count] = NUNCA;
            g_Count++;
        } while (kv.GotoNextKey(false));
    }
    delete kv;
}

void MV_LoadState()
{
    g_MapCounter = 0;
    g_VoteCounter = 0;
    KeyValues kv = new KeyValues("SkynetMapVoteState");
    if (kv.ImportFromFile(g_StateFile))
    {
        g_MapCounter = kv.GetNum("map_counter", 0);
        g_VoteCounter = kv.GetNum("vote_counter", 0);
        if (kv.JumpToKey("maps"))
        {
            for (int i = 0; i < g_Count; i++)
            {
                if (kv.JumpToKey(g_Map[i]))
                {
                    g_LastPlayed[i] = kv.GetNum("played", NUNCA);
                    g_LastVoted[i] = kv.GetNum("voted", NUNCA);
                    kv.GoBack();
                }
            }
        }
    }
    delete kv;
}

void MV_SaveState()
{
    KeyValues kv = new KeyValues("SkynetMapVoteState");
    kv.SetNum("map_counter", g_MapCounter);
    kv.SetNum("vote_counter", g_VoteCounter);
    kv.JumpToKey("maps", true);
    for (int i = 0; i < g_Count; i++)
    {
        kv.JumpToKey(g_Map[i], true);
        kv.SetNum("played", g_LastPlayed[i]);
        kv.SetNum("voted", g_LastVoted[i]);
        kv.GoBack();
    }
    kv.Rewind();
    kv.ExportToFile(g_StateFile);
    delete kv;
}

public void OnMapStart()
{
    MV_LoadMaps();
    MV_LoadState();
    g_MapCounter++;
    char cur[PLATFORM_MAX_PATH];
    GetCurrentMap(cur, sizeof(cur));
    int i = FindMapIndex(cur);
    if (i != -1)
        g_LastPlayed[i] = g_MapCounter;
    MV_SaveState();
    g_VoteStarted = false;
    g_RoundsPlayed = 0;
    g_VoteTimer = null;
    g_bEstendido = false;
    g_bModoRtv = false;
    g_bVotoFeito = false;
    for (int c = 1; c <= MaxClients; c++)
    {
        g_bRtv[c] = false;
        g_Indicou[c] = -1;
    }
    g_fRtvLiberado = GetEngineTime() + g_cvRtvDelay.FloatValue;
    CreateTimer(5.0, Timer_CheckTimeLeft, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// Modo por tempo (mapas com mp_timelimit, como os de Dodgeball): abre a votacao quando falta pouco para o fim do mapa
public Action Timer_CheckTimeLeft(Handle timer)
{
    int before = g_cvBefore.IntValue;
    if (before <= 0 && g_bEstendido)
        before = 180;
    if (g_VoteStarted || before <= 0)
        return Plugin_Continue;
    int timeleft;
    if (GetMapTimeLeft(timeleft) && timeleft > 0 && timeleft <= before)
        StartMapVote();
    return Plugin_Continue;
}

// O que a extensao mudou volta ao normal no proximo mapa
public void OnMapEnd()
{
    if (g_iLimiteOriginal >= 0)
        FindConVar("mp_timelimit").SetInt(g_iLimiteOriginal);
    if (g_iRodadasOriginal >= 0 && g_cvMaxRounds != null)
        g_cvMaxRounds.SetInt(g_iRodadasOriginal);
    g_iLimiteOriginal = -1;
    g_iRodadasOriginal = -1;
    g_bEstendido = false;
}

// +N minutos no tempo do mapa; se o mapa acaba por rodadas, +1 rodada. Depois a votacao abre de novo perto do fim.
void Estender()
{
    int minutos = g_cvExtend.IntValue;
    ConVar limite = FindConVar("mp_timelimit");
    if (limite.IntValue > 0)
    {
        if (g_iLimiteOriginal < 0)
            g_iLimiteOriginal = limite.IntValue;
        ExtendMapTimeLimit(minutos * 60);
    }
    if (g_cvMaxRounds != null && g_cvMaxRounds.IntValue > 0)
    {
        if (g_iRodadasOriginal < 0)
            g_iRodadasOriginal = g_cvMaxRounds.IntValue;
        g_cvMaxRounds.SetInt(g_cvMaxRounds.IntValue + 1);
    }
    g_bEstendido = true;
    g_VoteStarted = false;
}

public void OnConfigsExecuted()
{
    CreateTimer(5.0, Timer_ProvisionalNext, _, TIMER_FLAG_NO_MAPCHANGE);
}

// Proximo mapa provisorio, para o caso de a votacao nao acontecer (ex.: a partida nao chega ao fim)
public Action Timer_ProvisionalNext(Handle timer)
{
    int pick[MAX_OPTS];
    if (BuildOptions(pick, 1, false) > 0)
        SetNextMap(g_Map[pick[0]]);
    return Plugin_Stop;
}

float Weight(int i, int nextVote)
{
    int cooldown = g_cvCooldown.IntValue;
    int sinceP = g_MapCounter - g_LastPlayed[i];
    int sinceV = nextVote - g_LastVoted[i];
    float w = Pow(float(g_Hype[i]), g_cvHypeExp.FloatValue);
    float fp = 1.0 + g_cvPlayGrow.FloatValue * float(IntMax(sinceP - cooldown, 0));
    if (fp > g_cvPlayCap.FloatValue)
        fp = g_cvPlayCap.FloatValue;
    float fv;
    if (sinceV == 1)
        fv = g_cvRecentPenalty.FloatValue;
    else
    {
        fv = 1.0 + g_cvVoteGrow.FloatValue * float(IntMax(sinceV - 1, 0));
        if (fv > g_cvVoteCap.FloatValue)
            fv = g_cvVoteCap.FloatValue;
    }
    return w * fp * fv;
}

int BuildOptions(int[] out, int wanted, bool registerVote)
{
    int nextVote = g_VoteCounter + 1;
    int cooldown = g_cvCooldown.IntValue;
    char cur[PLATFORM_MAX_PATH];
    GetCurrentMap(cur, sizeof(cur));

    int pool[MAX_MAPS];
    int poolCount = 0;
    for (int i = 0; i < g_Count; i++)
    {
        if (g_Hype[i] <= 0 || g_Excluir[i] || StrEqual(g_Map[i], cur, false))
            continue;
        if (g_MapCounter - g_LastPlayed[i] <= cooldown)
            continue;
        pool[poolCount++] = i;
    }
    // Poucos mapas fora do cooldown: completa com os que estao no cooldown
    if (poolCount < wanted)
    {
        for (int i = 0; i < g_Count; i++)
        {
            if (g_Hype[i] <= 0 || g_Excluir[i] || StrEqual(g_Map[i], cur, false))
                continue;
            bool already = false;
            for (int k = 0; k < poolCount; k++)
                if (pool[k] == i) { already = true; break; }
            if (!already)
                pool[poolCount++] = i;
        }
    }

    int n = 0;
    // Vaga garantida para o mapa ha mais tempo fora da votacao
    int starve = g_cvStarve.IntValue;
    int best = -1, bestSince = -1;
    for (int k = 0; k < poolCount; k++)
    {
        int s = nextVote - g_LastVoted[pool[k]];
        if (s >= starve && s > bestSince)
        {
            best = k;
            bestSince = s;
        }
    }
    if (best != -1 && n < wanted)
    {
        out[n++] = pool[best];
        pool[best] = pool[--poolCount];
    }
    // Sorteio ponderado, sem repetir mapa
    while (n < wanted && poolCount > 0)
    {
        float total = 0.0;
        for (int k = 0; k < poolCount; k++)
            total += Weight(pool[k], nextVote);
        float r = GetURandomFloat() * total;
        int chosen = poolCount - 1;
        float acc = 0.0;
        for (int k = 0; k < poolCount; k++)
        {
            acc += Weight(pool[k], nextVote);
            if (acc >= r) { chosen = k; break; }
        }
        out[n++] = pool[chosen];
        pool[chosen] = pool[--poolCount];
    }

    if (registerVote && n > 0)
    {
        g_VoteCounter = nextVote;
        for (int k = 0; k < n; k++)
            g_LastVoted[out[k]] = nextVote;
        MV_SaveState();
    }
    return n;
}

int CountHumans()
{
    int c = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i) && !IsClientSourceTV(i))
            c++;
    return c;
}

public void Ev_RoundWin(Event event, const char[] name, bool dontBroadcast)
{
    g_RoundsPlayed++;
}

// A votacao abre durante a ultima rodada, com o pessoal jogando (no placar final o menu fica escondido)
public void Ev_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (g_VoteStarted || g_cvBefore.IntValue > 0)
        return;
    int maxrounds = g_cvMaxRounds != null ? g_cvMaxRounds.IntValue : 1;
    if (maxrounds < 1)
        maxrounds = 1;
    if (g_RoundsPlayed < maxrounds - 1)
        return;
    delete g_VoteTimer;
    g_VoteTimer = CreateTimer(g_cvVoteDelay.FloatValue, Timer_StartVote, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_StartVote(Handle timer)
{
    g_VoteTimer = null;
    StartMapVote();
    return Plugin_Stop;
}

// Se a rodada acabou antes da votacao abrir, fica o proximo mapa ja sorteado pelo mesmo sistema
public void Ev_GameOver(Event event, const char[] name, bool dontBroadcast)
{
    if (g_VoteStarted)
        return;
    g_VoteStarted = true;
    delete g_VoteTimer;
    char next[PLATFORM_MAX_PATH];
    if (GetNextMap(next, sizeof(next)))
        PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 Próximo mapa: \x0700E5FF%s\x01.", next);
}

void StartMapVote()
{
    if (g_VoteStarted)
        return;
    g_VoteStarted = true;

    int wanted = g_cvOptions.IntValue;
    if (wanted > MAX_OPTS)
        wanted = MAX_OPTS;
    g_OptCount = MontarOpcoes(g_Opt, wanted);
    if (g_OptCount == 0)
        return;
    if (g_OptCount == 1 || CountHumans() == 0 || IsVoteInProgress())
    {
        SetNextMap(g_Map[g_Opt[0]]);
        return;
    }

    Menu menu = new Menu(Handler_Vote, MENU_ACTIONS_ALL);
    menu.SetTitle(g_bModoRtv ? "Trocar de mapa agora (RTV):" : "Vote no proximo mapa:");
    for (int k = 0; k < g_OptCount; k++)
        menu.AddItem(g_Map[g_Opt[k]], g_Map[g_Opt[k]]);
    int opcoes = g_OptCount;
    if (g_bModoRtv || g_cvExtend.IntValue > 0)
    {
        char atual[PLATFORM_MAX_PATH], texto[PLATFORM_MAX_PATH + 32];
        GetCurrentMap(atual, sizeof(atual));
        if (g_bModoRtv)
            Format(texto, sizeof(texto), "Continuar em %s", atual);
        else
            Format(texto, sizeof(texto), "Estender %s (+%d min)", atual, g_cvExtend.IntValue);
        menu.AddItem(ESTENDER, texto);
        opcoes++;
    }
    menu.ExitButton = false;
    menu.DisplayVoteToAll(g_cvVoteTime.IntValue);
    PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 Vote no próximo mapa! Use as teclas \x0700E5FF1\x01 a \x0700E5FF%d\x01.", opcoes);
}

public int Handler_Vote(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_VoteEnd)
    {
        char map[PLATFORM_MAX_PATH];
        menu.GetItem(param1, map, sizeof(map));
        int votes, total;
        GetMenuVoteInfo(param2, votes, total);
        if (StrEqual(map, ESTENDER) && g_bModoRtv)
        {
            FimRtv(true);
            PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 A maioria quer \x0700E5FFcontinuar neste mapa\x01 (%d de %d votos).", votes, total);
            return 0;
        }
        if (StrEqual(map, ESTENDER))
        {
            Estender();
            PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 O mapa foi \x0700E5FFestendido em %d minutos\x01 (%d de %d votos). Perto do fim tem votação de novo.",
                g_cvExtend.IntValue, votes, total);
            return 0;
        }
        SetNextMap(map);
        if (g_bModoRtv)
        {
            PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 Trocando para \x0700E5FF%s\x01 em 5 segundos (%d de %d votos).", map, votes, total);
            CreateTimer(5.0, T_Trocar, _, TIMER_FLAG_NO_MAPCHANGE);
            return 0;
        }
        g_bVotoFeito = true;
        PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 Próximo mapa: \x0700E5FF%s\x01 (%d de %d votos). Ele começa quando este mapa terminar.", map, votes, total);
    }
    else if (action == MenuAction_VoteCancel && g_bModoRtv)
    {
        FimRtv(true);
        PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 Ninguém votou: o mapa continua.");
    }
    else if (action == MenuAction_VoteCancel && g_OptCount > 0)
    {
        SetNextMap(g_Map[g_Opt[0]]);
        PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 Ninguém votou. Próximo mapa: \x0700E5FF%s\x01. Ele começa quando este mapa terminar.", g_Map[g_Opt[0]]);
    }
    return 0;
}

public Action Cmd_Status(int client, int args)
{
    int nextVote = g_VoteCounter + 1;
    int cooldown = g_cvCooldown.IntValue;
    ReplyToCommand(client, "[SKYNET] mapa | hype | partidas sem jogar | votacoes sem aparecer | peso");
    for (int i = 0; i < g_Count; i++)
    {
        int sinceP = g_MapCounter - g_LastPlayed[i];
        int sinceV = nextVote - g_LastVoted[i];
        char sp[16], sv[16];
        if (sinceP > 50000) strcopy(sp, sizeof(sp), "nunca"); else IntToString(sinceP, sp, sizeof(sp));
        if (sinceV > 50000) strcopy(sv, sizeof(sv), "nunca"); else IntToString(sinceV - 1, sv, sizeof(sv));
        bool cd = sinceP <= cooldown;
        ReplyToCommand(client, "%s | %d | %s | %s | %.1f%s", g_Map[i], g_Hype[i], sp, sv,
            (cd || g_Hype[i] <= 0) ? 0.0 : Weight(i, nextVote), cd ? " (recente, fora)" : "");
    }
    return Plugin_Handled;
}

public Action Cmd_Now(int client, int args)
{
    g_VoteStarted = false;
    StartMapVote();
    return Plugin_Handled;
}

// ---------------------------------------------------------------- !rtv

int RtvPrecisa()
{
    int n = RoundToCeil(float(CountHumans()) * g_cvRtvNeeded.FloatValue);
    return n < 1 ? 1 : n;
}

int RtvVotos()
{
    int n = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (g_bRtv[i] && IsClientInGame(i) && !IsFakeClient(i))
            n++;
    return n;
}

// Depois de uma votacao de RTV: zera os pedidos; se continuou, o !rtv so volta depois de um tempo
void FimRtv(bool continuou)
{
    g_bModoRtv = false;
    for (int i = 1; i <= MaxClients; i++)
        g_bRtv[i] = false;
    if (continuou)
    {
        g_VoteStarted = g_bVotoFeito;
        g_fRtvLiberado = GetEngineTime() + g_cvRtvInterval.FloatValue;
    }
}

public Action Cmd_Rtv(int client, int args)
{
    if (client < 1 || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Handled;
    Rtv(client);
    return Plugin_Handled;
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] texto)
{
    if (client > 0 && (StrEqual(texto, "rtv", false) || StrEqual(texto, "rockthevote", false)))
        Rtv(client);
    else if (client > 0 && StrEqual(texto, "nominate", false))
        MenuIndicar(client, "");
}

void Rtv(int client)
{
    if (g_bModoRtv)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 A votação para trocar de mapa já está aberta.");
        return;
    }
    float falta = g_fRtvLiberado - GetEngineTime();
    if (falta > 0.0)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 O \x0700E5FF!rtv\x01 libera em %d segundos.", RoundToCeil(falta));
        return;
    }
    if (g_bRtv[client])
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Você já pediu para trocar de mapa (%d de %d).", RtvVotos(), RtvPrecisa());
        return;
    }
    g_bRtv[client] = true;
    PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 \x0700E5FF%N\x01 quer trocar de mapa (%d de %d). Digite \x0700E5FF!rtv\x01 para trocar também.",
        client, RtvVotos(), RtvPrecisa());
    ChecarRtv();
}

public void OnClientDisconnect_Post(int client)
{
    g_bRtv[client] = false;
    g_Indicou[client] = -1;
    if (!g_bModoRtv && RtvVotos() > 0)
        ChecarRtv();
}

void ChecarRtv()
{
    if (g_bModoRtv || RtvVotos() < RtvPrecisa())
        return;
    if (IsVoteInProgress())
    {
        PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 A maioria quer trocar de mapa: a votação abre assim que a atual terminar.");
        CreateTimer(3.0, T_TentarRtv, _, TIMER_FLAG_NO_MAPCHANGE);
        return;
    }
    // a votacao normal ja escolheu o proximo mapa: vai direto para ele
    char next[PLATFORM_MAX_PATH];
    if (g_bVotoFeito && GetNextMap(next, sizeof(next)))
    {
        g_bModoRtv = true;
        PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 A maioria quer trocar: indo para \x0700E5FF%s\x01 em 5 segundos.", next);
        CreateTimer(5.0, T_Trocar, _, TIMER_FLAG_NO_MAPCHANGE);
        return;
    }
    g_bModoRtv = true;
    g_VoteStarted = false;
    StartMapVote();
    if (!IsVoteInProgress())   // nao abriu (ex.: so um mapa possivel): troca para o que ficou como proximo
        CreateTimer(5.0, T_Trocar, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_TentarRtv(Handle timer)
{
    if (IsVoteInProgress())
    {
        CreateTimer(3.0, T_TentarRtv, _, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }
    ChecarRtv();
    return Plugin_Stop;
}

public Action T_Trocar(Handle timer)
{
    char next[PLATFORM_MAX_PATH];
    if (GetNextMap(next, sizeof(next)))
        ForceChangeLevel(next, "RTV");
    return Plugin_Stop;
}

// ---------------------------------------------------------------- !nominate

// Opcoes da votacao: primeiro os mapas indicados (por ordem de chegada), o resto pelo sorteio de sempre
int MontarOpcoes(int[] out, int wanted)
{
    int n = 0;
    int ordem[MAXPLAYERS + 1];
    int k = 0;
    for (int c = 1; c <= MaxClients; c++)
        if (g_Indicou[c] >= 0 && IsClientInGame(c))
            ordem[k++] = c;
    SortCustom1D(ordem, k, PorHora);
    for (int j = 0; j < k && n < wanted; j++)
    {
        int m = g_Indicou[ordem[j]];
        if (m >= g_Count || g_Excluir[m])
            continue;
        g_Excluir[m] = true;
        out[n++] = m;
    }
    int resto[MAX_OPTS];
    int r = BuildOptions(resto, wanted - n, false);
    for (int j = 0; j < r; j++)
        out[n++] = resto[j];
    for (int i = 0; i < MAX_MAPS; i++)
        g_Excluir[i] = false;
    if (n > 0)
    {
        g_VoteCounter++;
        for (int j = 0; j < n; j++)
            g_LastVoted[out[j]] = g_VoteCounter;
        MV_SaveState();
    }
    return n;
}

public int PorHora(int a, int b, const int[] lista, Handle h)
{
    if (g_fIndicouEm[a] < g_fIndicouEm[b])
        return -1;
    return g_fIndicouEm[a] > g_fIndicouEm[b] ? 1 : 0;
}

public int PorNome(int a, int b, const int[] lista, Handle h)
{
    return strcmp(g_Map[a], g_Map[b], false);
}

// 0 = pode indicar; 1 = mapa atual; 2 = jogado ha pouco; 3 = fora da rotacao
int Situacao(int i)
{
    char cur[PLATFORM_MAX_PATH];
    GetCurrentMap(cur, sizeof(cur));
    if (StrEqual(g_Map[i], cur, false))
        return 1;
    if (g_Hype[i] <= 0)
        return 3;
    if (g_MapCounter - g_LastPlayed[i] <= g_cvCooldown.IntValue)
        return 2;
    return 0;
}

int Indicacoes(int i)
{
    int n = 0;
    for (int c = 1; c <= MaxClients; c++)
        if (g_Indicou[c] == i && IsClientInGame(c))
            n++;
    return n;
}

bool PodeIndicarAgora(int client)
{
    if (g_bModoRtv || (g_VoteStarted && IsVoteInProgress()))
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 A votação já está aberta: vote nela.");
        return false;
    }
    if (g_bVotoFeito)
    {
        char next[PLATFORM_MAX_PATH];
        GetNextMap(next, sizeof(next));
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 A votação deste mapa já aconteceu: o próximo é \x0700E5FF%s\x01.", next);
        return false;
    }
    return true;
}

public Action Cmd_Nominate(int client, int args)
{
    if (client < 1 || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Handled;
    char busca[64];
    GetCmdArgString(busca, sizeof(busca));
    TrimString(busca);
    StripQuotes(busca);
    MenuIndicar(client, busca);
    return Plugin_Handled;
}

void MenuIndicar(int client, const char[] busca)
{
    if (!PodeIndicarAgora(client))
        return;
    int lista[MAX_MAPS];
    int n = 0;
    for (int i = 0; i < g_Count; i++)
    {
        int sit = Situacao(i);
        if (sit != 1 && sit != 3 && (busca[0] == '\0' || StrContains(g_Map[i], busca, false) != -1))
            lista[n++] = i;
    }
    if (n == 0)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Nenhum mapa com \x0700E5FF%s\x01. Digite só \x0700E5FF!nominate\x01 para ver a lista.", busca);
        return;
    }
    if (n == 1 && busca[0] != '\0')
    {
        Indicar(client, lista[0]);
        return;
    }
    SortCustom1D(lista, n, PorNome);
    Menu menu = new Menu(H_Indicar);
    menu.SetTitle("Indique um mapa para a votação\n(os %d primeiros indicados entram)", g_cvOptions.IntValue);
    for (int j = 0; j < n; j++)
    {
        int i = lista[j];
        char info[8], texto[PLATFORM_MAX_PATH + 32];
        IntToString(i, info, sizeof(info));
        if (Situacao(i) == 2)
            Format(texto, sizeof(texto), "%s (jogado há pouco)", g_Map[i]);
        else if (g_Indicou[client] == i)
            Format(texto, sizeof(texto), "%s (sua indicação)", g_Map[i]);
        else if (Indicacoes(i) > 0)
            Format(texto, sizeof(texto), "%s (indicado)", g_Map[i]);
        else
            strcopy(texto, sizeof(texto), g_Map[i]);
        menu.AddItem(info, texto, Situacao(i) == 2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }
    menu.Display(client, 30);
}

public int H_Indicar(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End)
        delete menu;
    else if (action == MenuAction_Select)
    {
        char info[8];
        menu.GetItem(item, info, sizeof(info));
        Indicar(client, StringToInt(info));
    }
    return 0;
}

void Indicar(int client, int i)
{
    if (!PodeIndicarAgora(client) || i < 0 || i >= g_Count)
        return;
    int sit = Situacao(i);
    if (sit == 1)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Esse é o mapa atual: para ficar nele, vote em \x0700E5FFEstender\x01.");
        return;
    }
    if (sit == 2)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 \x0700E5FF%s\x01 foi jogado há pouco e está fora da votação por enquanto.", g_Map[i]);
        return;
    }
    if (sit == 3)
        return;
    if (g_Indicou[client] == i)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Você já indicou \x0700E5FF%s\x01.", g_Map[i]);
        return;
    }
    bool trocou = g_Indicou[client] >= 0;
    g_Indicou[client] = i;
    g_fIndicouEm[client] = GetGameTime();
    PrintToChatAll("\x07FFD700[SKYNET GAMING]\x01 \x0700E5FF%N\x01 %s \x0700E5FF%s\x01 para a votação. Use \x0700E5FF!nominate\x01 para indicar o seu.",
        client, trocou ? "trocou a indicação para" : "indicou", g_Map[i]);
}
