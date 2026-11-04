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

// The Pyro's airblast catches projectiles inside a box in front of him: the center is 128 units ahead
// of the eye and the box goes 128 to the sides and 64 up and down. It only airblasts with the rocket inside the
// box and with the airblast ready; the faster the rocket, the earlier inside the box.
//
// Automatic BOT mode: with 1 to 3 players on the teams (skynet_bot_jogadores - 1), SKYNET BOT joins blue,
// standing where it spawns and reflecting on its own, and all players go to red (practice). When the 4th
// player joins a team, the bot leaves and the teams are scrambled (2v2). The ranking (HLstats) already only counts with
// 4 or more players and ignores bots. The switch only happens after a few seconds in the same situation.
//
// Bot quota: TF2's tf_bot_add adds 1 to tf_bot_quota, and the game replaces any bot kicked
// while the quota does not go down (that is what made lots of bots join and leave and a "normal bot" show up).
// That is why the quota goes to 0 before removing any bot.

#define NOME_BOT "SKYNET BOT"
#define TIME_VERMELHO 2
#define TIME_AZUL 3
#define ESPERA 5          // checks (1 per second) in the same situation before switching mode

// Functions from the Dodgeball plugin (optional: without them, it decides only by the rocket's position)
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
    // the old version may have left autobalance off: start with the server's normal setting
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
    // on map change the bot leaves; on the new map the mode comes back by itself if there are few players
    if (g_bModoBot)
        DesligarBot(false);
    g_iEstavel = 0;
}

// ---------------------------------------------------------------- auto reflect on players

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

// ---------------------------------------------------------------- ALL VS BOT mode (automatic)

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

// Finds our bot and removes any other bot (or ours, with the mode off)
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
        Cota(g_iBot > 0 ? 1 : 0);   // otherwise TF2 puts another bot in its place
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

// With the mode on: the bot on blue and all players on red
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
    // everyone was on red: the game scrambles the teams and restarts the round (2v2)
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

// With bot mode on, players cannot join blue: they go to red
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

// Is point p inside the airblast area of someone looking from "eye" in direction "dir"?
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

// SKYNET BOT has no airblast cooldown and never runs out of ammo: it also reflects up close, with a quick switch
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

// If there is a rocket to reflect now, aims at it and returns true.
// bot = true: any rocket from the other team heading toward it counts, and it airblasts as soon as the rocket enters the area
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
            // up close, right after another player reflects, Dodgeball has not changed the target yet: look at the team and the direction
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
    // The bot: stays where it spawned and only airblasts (no walking or flamethrower)
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
