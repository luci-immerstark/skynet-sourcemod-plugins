#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Auto Reflect",
    author = "SKYNET GAMING",
    description = "Auto reflect para admins (root) e o modo TODOS CONTRA O BOT automatico com poucos jogadores",
    version = "4.2",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

// O sopro do Pyro pega projeteis dentro de uma caixa na frente dele: o centro fica 128 unidades a frente
// do olho e a caixa vai 128 para os lados e 64 para cima e para baixo. So sopra com o foguete dentro da
// caixa e com o sopro pronto; quanto mais rapido o foguete, mais cedo dentro da caixa.
//
// Modo BOT automatico: com 1 a 3 jogadores nos times (skynet_bot_jogadores - 1), entra o SKYNET BOT no azul,
// parado onde nasce e rebatendo sozinho, e todos os jogadores vao para o vermelho (treino). Quando o 4o
// jogador entra num time, o bot sai e os times sao embaralhados (2x2). O ranking (HLstats) ja so conta com
// 4 jogadores ou mais e ignora bots. A troca so acontece depois de alguns segundos na mesma situacao.
//
// Cota de bots: o tf_bot_add do TF2 soma 1 no tf_bot_quota, e o jogo repoe qualquer bot que saia por kick
// enquanto a cota nao baixar (era isso que fazia entrar e sair um monte de bot e aparecer "bot normal").
// Por isso a cota vai para 0 antes de tirar qualquer bot.

#define NOME_BOT "SKYNET BOT"
#define TIME_VERMELHO 2
#define TIME_AZUL 3
#define ESPERA 5          // checagens (1 por segundo) na mesma situacao antes de trocar o modo

// Funcoes do plugin de Dodgeball (opcionais: sem elas, decide so pela posicao do foguete)
native int TFDB_FindRocketByEntity(int iEntity);
native int TFDB_GetRocketTarget(int iIndex);

bool g_bAuto[MAXPLAYERS + 1];
bool g_bTFDB;
ConVar g_cvFrente;
ConVar g_cvLado;
ConVar g_cvAltura;
ConVar g_cvEmergencia;
ConVar g_cvPerto;
ConVar g_cvBotAuto;
ConVar g_cvJogadores;

bool g_bModoBot;
int g_iBot;
bool g_bTemAncora;
float g_fAncora[3];
int g_iEstavel;
float g_fPedidoBot;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("TFDB_FindRocketByEntity");
    MarkNativeAsOptional("TFDB_GetRocketTarget");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_cvFrente     = CreateConVar("skynet_autoreflect_frente", "128", "Distancia do olho ate o centro da area do sopro", _, true, 32.0, true, 256.0);
    g_cvLado       = CreateConVar("skynet_autoreflect_lado", "112", "Metade da largura da area do sopro usada (o jogo usa 128; menor = mais seguro)", _, true, 32.0, true, 160.0);
    g_cvAltura     = CreateConVar("skynet_autoreflect_altura", "56", "Metade da altura da area do sopro usada (o jogo usa 64; menor = mais seguro)", _, true, 16.0, true, 96.0);
    g_cvEmergencia = CreateConVar("skynet_autoreflect_emergencia", "110", "Rebate qualquer foguete inimigo mais perto que isto, mesmo mirando outro jogador", _, true, 0.0, true, 300.0);
    g_cvPerto      = CreateConVar("skynet_autoreflect_perto", "180", "Com o foguete lento, espera ele chegar a esta distancia para soprar", _, true, 60.0, true, 256.0);
    LoadTranslations("common.phrases");
    RegAdminCmd("sm_autoreflect", Cmd_Auto, ADMFLAG_ROOT, "Liga/desliga o auto reflect (sem nome = em voce)");
    g_cvBotAuto    = CreateConVar("skynet_bot_auto", "1", "1 = com poucos jogadores nos times, todos contra o SKYNET BOT", _, true, 0.0, true, 1.0);
    g_cvJogadores  = CreateConVar("skynet_bot_jogadores", "4", "Com este numero de jogadores nos times o bot sai e o jogo fica normal", _, true, 2.0, true, 32.0);
    CreateTimer(1.0, T_Checar, _, TIMER_REPEAT);
    Cota(0);
    // a versao antiga podia ter deixado o balanceamento desligado: comeca no normal do servidor
    FindConVar("mp_autoteambalance").SetInt(1);
    FindConVar("mp_teams_unbalance_limit").SetInt(1);
    AddCommandListener(Ouvir_Time, "jointeam");
    AddCommandListener(Ouvir_Time, "autoteam");
    HookEvent("player_spawn", Ev_Spawn);
}

public void OnAllPluginsLoaded()
{
    g_bTFDB = GetFeatureStatus(FeatureType_Native, "TFDB_GetRocketTarget") == FeatureStatus_Available
           && GetFeatureStatus(FeatureType_Native, "TFDB_FindRocketByEntity") == FeatureStatus_Available;
}

public void OnPluginEnd()
{
    if (g_bModoBot)
        DesligarBot(false);
}

public void OnMapEnd()
{
    // na troca de mapa o bot sai; no mapa novo o modo volta sozinho se tiver poucos jogadores
    if (g_bModoBot)
        DesligarBot(false);
    g_iEstavel = 0;
}

// ---------------------------------------------------------------- auto reflect em jogadores

public Action Cmd_Auto(int client, int args)
{
    int alvo = client;
    if (args >= 1)
    {
        char arg[64];
        GetCmdArg(1, arg, sizeof(arg));
        alvo = FindTarget(client, arg, true, false);
        if (alvo == -1)
            return Plugin_Handled;
    }
    if (alvo < 1 || !IsClientInGame(alvo))
    {
        ReplyToCommand(client, "[SKYNET] Use dentro do jogo ou informe um jogador.");
        return Plugin_Handled;
    }
    g_bAuto[alvo] = !g_bAuto[alvo];
    PrintToChatAll("\x04[SKYNET]\x01 Auto reflect %s para \x03%N\x01.", g_bAuto[alvo] ? "LIGADO" : "desligado", alvo);
    LogAction(client, alvo, "\"%L\" %s o auto reflect de \"%L\"", client, g_bAuto[alvo] ? "ligou" : "desligou", alvo);
    return Plugin_Handled;
}

// ---------------------------------------------------------------- modo TODOS CONTRA O BOT (automatico)

int HumanosNosTimes()
{
    int n = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) >= TIME_VERMELHO)
            n++;
    }
    return n;
}

void Cota(int n)
{
    ConVar cota = FindConVar("tf_bot_quota");
    if (cota != null && cota.IntValue != n)
        cota.SetInt(n);
}

// Acha o nosso bot e tira qualquer outro bot (ou o nosso, com o modo desligado)
void AcharBot()
{
    int antes = g_iBot;
    g_iBot = 0;
    int sobra[MAXPLAYERS + 1];
    int n = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i))
            continue;
        char nome[MAX_NAME_LENGTH];
        GetClientName(i, nome, sizeof(nome));
        if (g_bModoBot && g_iBot == 0 && StrContains(nome, NOME_BOT) != -1)
            g_iBot = i;
        else
            sobra[n++] = i;
    }
    if (n > 0)
    {
        Cota(g_iBot > 0 ? 1 : 0);   // senao o TF2 coloca outro bot no lugar
        for (int k = 0; k < n; k++)
            KickClient(sobra[k], "%s", g_bModoBot ? "Bot sobrando" : "Modo bot desligado");
    }
    if (g_iBot != antes)
        g_bTemAncora = false;
}

public Action T_Checar(Handle timer)
{
    AcharBot();
    int humanos = HumanosNosTimes();
    bool quer = g_cvBotAuto.BoolValue && humanos >= 1 && humanos < g_cvJogadores.IntValue;
    if (quer != g_bModoBot)
    {
        g_iEstavel++;
        if (g_iEstavel >= ESPERA || humanos == 0)
        {
            g_iEstavel = 0;
            if (quer)
                LigarBot();
            else
                DesligarBot(humanos > 0);
        }
    }
    else
        g_iEstavel = 0;

    if (g_bModoBot)
        ManterBot();
    return Plugin_Continue;
}

void LigarBot()
{
    FindConVar("mp_autoteambalance").SetInt(0);
    FindConVar("mp_teams_unbalance_limit").SetInt(0);
    ConVar modo = FindConVar("tf_bot_quota_mode");
    if (modo != null)
        modo.SetString("normal");
    Cota(0);
    ServerCommand("tf_bot_auto_vacate 0");
    ServerCommand("tf_bot_keep_class_after_death 1");
    ServerCommand("tf_bot_taunt_victim_chance 0");
    g_bModoBot = true;
    g_iBot = 0;
    g_bTemAncora = false;
    g_fPedidoBot = 0.0;
    ManterBot();
    PrintToChatAll("\x04[SKYNET]\x01 Menos de %d jogadores: modo \x03TODOS CONTRA O BOT\x01 (treino, sem ranking). Todo mundo no vermelho.",
        g_cvJogadores.IntValue);
}

// Com o modo ligado: o bot no azul e todos os jogadores no vermelho
void ManterBot()
{
    if (g_iBot == 0 && (g_fPedidoBot == 0.0 || GetEngineTime() - g_fPedidoBot > 5.0))
    {
        ServerCommand("tf_bot_add 1 pyro blue expert \"%s\"", NOME_BOT);
        g_fPedidoBot = GetEngineTime();
    }
    if (g_iBot > 0 && GetClientTeam(g_iBot) != TIME_AZUL)
        ChangeClientTeam(g_iBot, TIME_AZUL);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TIME_AZUL)
            ChangeClientTeam(i, TIME_VERMELHO);
    }
}

void DesligarBot(bool avisar)
{
    g_bModoBot = false;
    g_bTemAncora = false;
    g_iBot = 0;
    Cota(0);
    AcharBot();
    ServerCommand("tf_bot_kick all");
    FindConVar("mp_autoteambalance").SetInt(1);
    FindConVar("mp_teams_unbalance_limit").SetInt(1);
    if (!avisar)
        return;
    // todos estavam no vermelho: o jogo embaralha os times e reinicia a rodada (2x2)
    ServerCommand("mp_scrambleteams");
    PrintToChatAll("\x04[SKYNET]\x01 %d jogadores! O SKYNET BOT saiu e os times foram divididos. \x03Valendo ranking.",
        HumanosNosTimes());
}

public void OnClientDisconnect(int client)
{
    g_bAuto[client] = false;
    if (client == g_iBot)
    {
        g_iBot = 0;
        g_bTemAncora = false;
    }
}

// Com o modo bot ligado, jogador nao entra no azul: vai para o vermelho
public Action Ouvir_Time(int client, const char[] command, int argc)
{
    if (!g_bModoBot || client < 1 || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Continue;
    char arg[16];
    if (argc >= 1)
        GetCmdArg(1, arg, sizeof(arg));
    if (StrEqual(command, "jointeam", false) && (StrEqual(arg, "red", false) || StrContains(arg, "spec", false) == 0))
        return Plugin_Continue;
    FakeClientCommandEx(client, "jointeam red");
    return Plugin_Handled;
}

public void Ev_Spawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (g_bModoBot && client > 0 && client == g_iBot)
    {
        g_bTemAncora = false;
        CreateTimer(0.2, T_Ancorar, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_Ancorar(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && client == g_iBot && IsPlayerAlive(client))
    {
        GetClientAbsOrigin(client, g_fAncora);
        g_bTemAncora = true;
    }
    return Plugin_Stop;
}

// ---------------------------------------------------------------- rebater

// O ponto p esta dentro da area do sopro de quem olha de "olho" na direcao "dir"?
bool NaCaixa(const float olho[3], const float dir[3], const float p[3], float lado, float altura)
{
    float frente = g_cvFrente.FloatValue;
    float c0 = olho[0] + dir[0] * frente;
    float c1 = olho[1] + dir[1] * frente;
    float c2 = olho[2] + dir[2] * frente;
    return FloatAbs(p[0] - c0) <= lado && FloatAbs(p[1] - c1) <= lado && FloatAbs(p[2] - c2) <= altura;
}

bool SoproPronto(int client)
{
    int arma = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (arma <= MaxClients || !IsValidEntity(arma) || !HasEntProp(arma, Prop_Send, "m_flNextSecondaryAttack"))
        return false;
    return GetEntPropFloat(arma, Prop_Send, "m_flNextSecondaryAttack") <= GetGameTime();
}

// O SKYNET BOT nao tem recarga de sopro nem fica sem municao: rebate tambem de perto, em troca rapida
void RecarregarSopro(int client)
{
    int arma = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (arma <= MaxClients || !IsValidEntity(arma) || !HasEntProp(arma, Prop_Send, "m_flNextSecondaryAttack"))
        return;
    if (GetEntPropFloat(arma, Prop_Send, "m_flNextSecondaryAttack") > GetGameTime())
        SetEntPropFloat(arma, Prop_Send, "m_flNextSecondaryAttack", GetGameTime());
    int tipo = HasEntProp(arma, Prop_Send, "m_iPrimaryAmmoType") ? GetEntProp(arma, Prop_Send, "m_iPrimaryAmmoType") : -1;
    if (tipo >= 0)
        SetEntProp(client, Prop_Send, "m_iAmmo", 200, _, tipo);
}

// Se tem foguete para rebater agora, aponta a mira para ele e devolve true.
// bot = true: qualquer foguete do outro time vindo na direcao dele conta, e ele sopra assim que o foguete entra na area
bool Refletir(int client, float angles[3], bool bot = false)
{
    if (bot)
        RecarregarSopro(client);
    else if (!SoproPronto(client))
        return false;
    float lado = bot ? 128.0 : g_cvLado.FloatValue;
    float altura = bot ? 64.0 : g_cvAltura.FloatValue;
    float olho[3];
    GetClientEyePosition(client, olho);
    int equipe = GetClientTeam(client);
    float dt = GetTickInterval();
    float emergencia = g_cvEmergencia.FloatValue;

    int melhor = -1;
    float menor = 999999.0;
    float mira[3];
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "tf_projectile_rocket")) != -1)
    {
        float p[3], v[3], p1[3], meio[3], dir[3], ate[3];
        GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", p);
        GetEntPropVector(ent, Prop_Data, "m_vecAbsVelocity", v);
        float d = GetVectorDistance(olho, p);

        int alvo = -1;
        if (g_bTFDB)
        {
            int idx = TFDB_FindRocketByEntity(ent);
            if (idx != -1)
                alvo = TFDB_GetRocketTarget(idx);
        }
        bool meu;
        if (bot)
        {
            // de perto, logo depois de outro jogador rebater, o Dodgeball ainda nao trocou o alvo: olha o time e a direcao
            if (GetEntProp(ent, Prop_Send, "m_iTeamNum") == equipe)
                continue;
            MakeVectorFromPoints(p, olho, ate);
            meu = (alvo == client) || (d < 600.0 && GetVectorDotProduct(v, ate) > 0.0);
        }
        else if (alvo > 0)
            meu = (alvo == client) || (d <= emergencia && GetEntProp(ent, Prop_Send, "m_iTeamNum") != equipe);
        else
        {
            MakeVectorFromPoints(p, olho, ate);
            meu = GetEntProp(ent, Prop_Send, "m_iTeamNum") != equipe && GetVectorDotProduct(v, ate) > 0.0;
        }
        if (!meu)
            continue;

        for (int k = 0; k < 3; k++)
        {
            p1[k] = p[k] + v[k] * dt;
            meio[k] = (p[k] + p1[k]) * 0.5;
        }
        MakeVectorFromPoints(olho, meio, dir);
        NormalizeVector(dir, dir);
        if (!NaCaixa(olho, dir, p, lado, altura))
            continue;
        float passo = GetVectorLength(v) * dt;
        if (!bot && d > g_cvPerto.FloatValue && d - 2.0 * passo > 60.0)
            continue;
        if (d < menor)
        {
            menor = d;
            melhor = ent;
            mira = dir;
        }
    }
    if (melhor == -1)
        return false;

    float ang[3];
    GetVectorAngles(mira, ang);
    if (ang[0] > 180.0)
        ang[0] -= 360.0;
    angles[0] = ang[0];
    angles[1] = ang[1];
    angles[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, angles, NULL_VECTOR);
    return true;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    // O bot: fica parado onde nasceu e so sopra (nada de andar ou soltar fogo)
    if (g_bModoBot && client == g_iBot)
    {
        vel[0] = 0.0;
        vel[1] = 0.0;
        vel[2] = 0.0;
        buttons = 0;
        impulse = 0;
        weapon = 0;
        if (IsPlayerAlive(client))
        {
            if (g_bTemAncora)
            {
                float agora[3], parado[3];
                GetClientAbsOrigin(client, agora);
                if (GetVectorDistance(agora, g_fAncora) > 16.0)
                    TeleportEntity(client, g_fAncora, NULL_VECTOR, parado);
            }
            if (Refletir(client, angles, true))
                buttons |= IN_ATTACK2;
        }
        return Plugin_Changed;
    }

    if (!g_bAuto[client] || !IsPlayerAlive(client))
        return Plugin_Continue;
    if (!Refletir(client, angles))
        return Plugin_Continue;
    buttons |= IN_ATTACK2;
    return Plugin_Changed;
}
