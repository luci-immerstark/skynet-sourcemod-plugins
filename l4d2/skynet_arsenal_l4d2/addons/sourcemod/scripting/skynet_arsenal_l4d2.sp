#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

// Arsenal no abrigo: no inicio de cada capitulo coloca no abrigo inicial
// todas as armas de fogo do jogo (cada uma pode ser pega varias vezes)
// e todas as armas corpo a corpo disponiveis no mapa.

#define PLUGIN_VERSION  "1.0"
#define GRADE_PASSO     34.0     // distancia entre uma arma e outra
#define GRADE_MEIA      6        // grade de 13 x 13 pontos em volta do jogador
#define RAIO_MAX        210.0
#define ALTURA_OLHO     48.0
#define MAX_PONTOS      180
#define MAX_CRIADOS     256
#define MAX_MELEE       32
#define LIMITE_EDICTS   1900
#define DIST_PORTA      90.0     // nada perto da porta do abrigo (para nao travar a porta)
#define MAX_PORTAS      16

// Fornecidas pelo Left 4 DHooks (opcionais; o plugin funciona sem elas)
native bool L4D_IsPositionInFirstCheckpoint(float vecPos[3]);
native bool L4D_HasAnySurvivorLeftSafeArea();

// Armas de fogo: id interno do jogo, modelo, nome da entidade, grupo
// grupo 0 = normal, 1 = Counter-Strike (MP5, SG552, Scout, AWP), 2 = pistola
static const int g_iArmaId[] = { 2, 7, 33, 3, 8, 4, 11, 5, 26, 9, 34, 6, 10, 36, 35, 32, 1 };

static const char g_sArmaModelo[][] =
{
    "models/w_models/weapons/w_smg_uzi.mdl",
    "models/w_models/weapons/w_smg_a.mdl",
    "models/w_models/weapons/w_smg_mp5.mdl",
    "models/w_models/weapons/w_shotgun.mdl",
    "models/w_models/weapons/w_pumpshotgun_a.mdl",
    "models/w_models/weapons/w_autoshot_m4super.mdl",
    "models/w_models/weapons/w_shotgun_spas.mdl",
    "models/w_models/weapons/w_rifle_m16a2.mdl",
    "models/w_models/weapons/w_rifle_ak47.mdl",
    "models/w_models/weapons/w_desert_rifle.mdl",
    "models/w_models/weapons/w_rifle_sg552.mdl",
    "models/w_models/weapons/w_sniper_mini14.mdl",
    "models/w_models/weapons/w_sniper_military.mdl",
    "models/w_models/weapons/w_sniper_scout.mdl",
    "models/w_models/weapons/w_sniper_awp.mdl",
    "models/w_models/weapons/w_desert_eagle.mdl",
    "models/w_models/weapons/w_pistol_B.mdl"
};

static const char g_sArmaClasse[][] =
{
    "weapon_smg", "weapon_smg_silenced", "weapon_smg_mp5",
    "weapon_pumpshotgun", "weapon_shotgun_chrome", "weapon_autoshotgun", "weapon_shotgun_spas",
    "weapon_rifle", "weapon_rifle_ak47", "weapon_rifle_desert", "weapon_rifle_sg552",
    "weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_scout", "weapon_sniper_awp",
    "weapon_pistol_magnum", "weapon_pistol"
};

static const int g_iArmaGrupo[] = { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 2, 2 };

// Especiais: sao itens soltos (1 unidade cada por padrao)
static const char g_sEspecial[][] = { "weapon_rifle_m60", "weapon_grenade_launcher", "weapon_chainsaw" };

ConVar g_cvEnable, g_cvQtd, g_cvCss, g_cvPistolas, g_cvMelee, g_cvEspeciais, g_cvAviso;

char g_sLog[PLATFORM_MAX_PATH];
bool g_bFeito;          // arsenal ja montado nesta rodada
bool g_bSaiu;           // alguem ja saiu da area inicial
int g_iTentativas;
Handle g_hTimer;

int g_iCriados[MAX_CRIADOS];
int g_iNumCriados;

bool g_bUsarAbrigo;     // validar pontos com o Left 4 DHooks (dentro do abrigo)

float g_vPortas[MAX_PORTAS][3];
int g_iNumPortas;

bool g_bAvisado[MAXPLAYERS + 1];
int g_iAvisoArmas, g_iAvisoMelee;

public Plugin myinfo =
{
    name = "SKYNET Arsenal (L4D2)",
    author = "SKYNET GAMING",
    description = "Coloca muitas armas de fogo e corpo a corpo no abrigo inicial de cada capitulo",
    version = PLUGIN_VERSION,
    url = "https://github.com/lmattedi/skynet-sourcemod-plugins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("L4D_IsPositionInFirstCheckpoint");
    MarkNativeAsOptional("L4D_HasAnySurvivorLeftSafeArea");
    return APLRes_Success;
}

public void OnPluginStart()
{
    BuildPath(Path_SM, g_sLog, sizeof(g_sLog), "logs/skynet_arsenal.log");

    g_cvEnable    = CreateConVar("skynet_arsenal_enable", "1", "Liga (1) ou desliga (0) o arsenal no abrigo", _, true, 0.0, true, 1.0);
    g_cvQtd       = CreateConVar("skynet_arsenal_qtd", "10", "Quantas vezes cada arma de fogo pode ser pega no abrigo (0 = infinito)", _, true, 0.0, true, 99.0);
    g_cvCss       = CreateConVar("skynet_arsenal_css", "1", "Incluir as armas do Counter-Strike (MP5, SG552, Scout, AWP)", _, true, 0.0, true, 1.0);
    g_cvPistolas  = CreateConVar("skynet_arsenal_pistolas", "1", "Incluir Magnum e pistola", _, true, 0.0, true, 1.0);
    g_cvMelee     = CreateConVar("skynet_arsenal_melee", "2", "Quantas unidades de cada arma corpo a corpo (0 = nenhuma)", _, true, 0.0, true, 6.0);
    g_cvEspeciais = CreateConVar("skynet_arsenal_especiais", "1", "Quantas M60, lanca-granadas e motosserras (0 = nenhuma)", _, true, 0.0, true, 4.0);
    g_cvAviso     = CreateConVar("skynet_arsenal_aviso", "1", "Avisar no chat quando o arsenal for montado", _, true, 0.0, true, 1.0);
    AutoExecConfig(true, "skynet_arsenal_l4d2");

    HookEvent("round_start", Ev_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("player_spawn", Ev_PlayerSpawn);
    HookEvent("player_left_start_area", Ev_SaiuInicio, EventHookMode_PostNoCopy);
    HookEvent("bot_player_replace", Ev_AssumiuBot);

    RegAdminCmd("sm_arsenal", Cmd_Arsenal, ADMFLAG_CHEATS, "sm_arsenal = monta o arsenal onde voce esta | sm_arsenal limpar = remove o arsenal");
}

public void OnMapStart()
{
    g_bFeito = false;
    g_bSaiu = false;
    g_hTimer = null;
    g_iNumCriados = 0;

    for (int i = 0; i < sizeof(g_sArmaModelo); i++)
        PrecacheModel(g_sArmaModelo[i], true);

    // Criar e remover uma unidade carrega a arma por completo (modelos e script)
    // antes de qualquer jogador entrar. Necessario para as armas do CS e especiais.
    for (int i = 0; i < sizeof(g_sArmaClasse); i++)
    {
        if (g_iArmaGrupo[i] == 1)
            PreCarregar(g_sArmaClasse[i]);
    }
    for (int i = 0; i < sizeof(g_sEspecial); i++)
        PreCarregar(g_sEspecial[i]);
}

void PreCarregar(const char[] classe)
{
    int ent = CreateEntityByName(classe);
    if (ent != -1)
    {
        DispatchSpawn(ent);
        RemoveEdict(ent);
    }
}

public void OnMapEnd()
{
    g_hTimer = null;
}

public void OnClientDisconnect(int client)
{
    g_bAvisado[client] = false;
}

// ---------------------------------------------------------------- eventos

public void Ev_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_bFeito = false;
    g_bSaiu = false;
    for (int i = 1; i <= MaxClients; i++)
        g_bAvisado[i] = false;
    Agendar();
}

public void Ev_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bSaiu)
        return;
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || GetClientTeam(client) != 2)
        return;
    if (!g_bFeito)
        Agendar();
    else if (!IsFakeClient(client) && !g_bAvisado[client])
        CreateTimer(3.0, T_AvisarCliente, userid, TIMER_FLAG_NO_MAPCHANGE);
}

// Jogador que chega depois e assume um sobrevivente controlado por bot
public void Ev_AssumiuBot(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bFeito && !g_bSaiu)
        CreateTimer(3.0, T_AvisarCliente, event.GetInt("player"), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_AvisarCliente(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client) && !IsFakeClient(client) && !g_bAvisado[client]
        && g_bFeito && !g_bSaiu && g_cvAviso.BoolValue && g_iAvisoArmas + g_iAvisoMelee > 0)
    {
        Avisar(client);
    }
    return Plugin_Stop;
}

void Avisar(int client)
{
    g_bAvisado[client] = true;
    PrintToChat(client, "\x04[SKYNET GAMING]\x01 Arsenal liberado no abrigo: \x05%d\x01 armas de fogo e \x05%d\x01 tipos de corpo a corpo. Escolha a sua!",
        g_iAvisoArmas, g_iAvisoMelee);
}

public void Ev_SaiuInicio(Event event, const char[] name, bool dontBroadcast)
{
    g_bSaiu = true;
}

void Agendar()
{
    g_iTentativas = 0;
    if (g_hTimer == null)
        g_hTimer = CreateTimer(1.0, T_Tentar, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Tentar(Handle timer)
{
    if (g_bFeito || g_bSaiu || !g_cvEnable.BoolValue)
    {
        g_hTimer = null;
        return Plugin_Stop;
    }

    g_iTentativas++;
    if (g_iTentativas < 4)      // espera os sobreviventes aparecerem no abrigo
        return Plugin_Continue;

    if (GetFeatureStatus(FeatureType_Native, "L4D_HasAnySurvivorLeftSafeArea") == FeatureStatus_Available
        && L4D_HasAnySurvivorLeftSafeArea())
    {
        g_bSaiu = true;
        g_hTimer = null;
        return Plugin_Stop;
    }

    float ancora[3];
    int quem = AcharAncora(ancora);
    if (quem == 0)
    {
        if (g_iTentativas > 90)
        {
            g_hTimer = null;
            return Plugin_Stop;
        }
        return Plugin_Continue;
    }

    g_bFeito = true;
    g_hTimer = null;
    MontarArsenal(ancora, quem, "automatico");
    return Plugin_Stop;
}

// ---------------------------------------------------------------- comando de admin

public Action Cmd_Arsenal(int client, int args)
{
    char arg[16];
    if (args > 0)
        GetCmdArg(1, arg, sizeof(arg));

    if (StrEqual(arg, "limpar", false))
    {
        int n = LimparArsenal();
        ReplyToCommand(client, "[SKYNET] Arsenal removido (%d itens).", n);
        return Plugin_Handled;
    }

    if (client == 0 || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[SKYNET] Use dentro do jogo: o arsenal e montado onde voce esta.");
        return Plugin_Handled;
    }

    float pos[3];
    GetClientAbsOrigin(client, pos);
    g_bFeito = true;
    int n = MontarArsenal(pos, client, "manual (sm_arsenal)");
    ReplyToCommand(client, "[SKYNET] Arsenal montado: %d itens.", n);
    return Plugin_Handled;
}

// ---------------------------------------------------------------- posicao

// Escolhe o sobrevivente vivo mais perto do centro do grupo (de preferencia dentro do abrigo)
int AcharAncora(float ancora[3])
{
    bool temL4DH = GetFeatureStatus(FeatureType_Native, "L4D_IsPositionInFirstCheckpoint") == FeatureStatus_Available;
    int lista[MAXPLAYERS + 1];
    int n = 0;

    for (int passo = 0; passo < 2 && n == 0; passo++)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i) || GetClientTeam(i) != 2 || !IsPlayerAlive(i))
                continue;
            if (passo == 0)
            {
                if (!temL4DH)
                    continue;
                float p[3];
                GetClientAbsOrigin(i, p);
                p[2] += 16.0;
                if (!L4D_IsPositionInFirstCheckpoint(p))
                    continue;
            }
            lista[n++] = i;
        }
    }
    if (n == 0)
        return 0;

    float centro[3], p[3];
    for (int k = 0; k < n; k++)
    {
        GetClientAbsOrigin(lista[k], p);
        AddVectors(centro, p, centro);
    }
    ScaleVector(centro, 1.0 / float(n));

    int melhor = lista[0];
    float menor = -1.0;
    for (int k = 0; k < n; k++)
    {
        GetClientAbsOrigin(lista[k], p);
        float d = GetVectorDistance(p, centro, true);
        if (menor < 0.0 || d < menor)
        {
            menor = d;
            melhor = lista[k];
        }
    }
    GetClientAbsOrigin(melhor, ancora);
    return melhor;
}

public bool Filtro(int entity, int contentsMask, any data)
{
    if (entity >= 1 && entity <= MaxClients)
        return false;           // ignora jogadores
    if (entity > MaxClients && IsValidEntity(entity))
    {
        char cls[32];
        GetEntityClassname(entity, cls, sizeof(cls));
        if (strncmp(cls, "weapon_", 7) == 0)
            return false;       // ignora armas e itens
    }
    return true;
}

// Procura o chao debaixo de um ponto. Retorna false se nao achar.
bool AcharChao(const float de[3], float distancia, float chao[3], float normal[3])
{
    float ate[3];
    ate = de;
    ate[2] -= distancia;
    TR_TraceRayFilter(de, ate, MASK_PLAYERSOLID, RayType_EndPoint, Filtro);
    if (!TR_DidHit())
        return false;
    TR_GetEndPosition(chao);
    TR_GetPlaneNormal(null, normal);
    return true;
}

bool PontoValido(const float olho[3], float chaoBase, float x, float y, float saida[3])
{
    float alto[3];
    alto[0] = x;
    alto[1] = y;
    alto[2] = chaoBase + ALTURA_OLHO;

    // 1) caminho livre do jogador ate o ponto (parede, porta, janela, cerca invisivel)
    TR_TraceRayFilter(olho, alto, MASK_PLAYERSOLID, RayType_EndPoint, Filtro);
    if (TR_DidHit())
        return false;

    // 2) chao plano na mesma altura do jogador (nada de cima de mesa ou andar de baixo)
    float chao[3], normal[3];
    if (!AcharChao(alto, ALTURA_OLHO + 40.0, chao, normal))
        return false;
    if (normal[2] < 0.85 || FloatAbs(chao[2] - chaoBase) > 20.0)
        return false;

    // 3) espaco livre em volta (nao encostar em movel ou parede)
    float mins[3] = { -10.0, -10.0, 0.0 };
    float maxs[3] = { 10.0, 10.0, 4.0 };
    TR_TraceHullFilter(alto, chao, mins, maxs, MASK_PLAYERSOLID, Filtro);
    if (TR_StartSolid())
        return false;
    float fim[3];
    TR_GetEndPosition(fim);
    if (fim[2] - chao[2] > 4.0)
        return false;

    // 4) longe das portas do abrigo
    for (int k = 0; k < g_iNumPortas; k++)
    {
        float dx = chao[0] - g_vPortas[k][0];
        float dy = chao[1] - g_vPortas[k][1];
        if (dx * dx + dy * dy < DIST_PORTA * DIST_PORTA && FloatAbs(chao[2] - g_vPortas[k][2]) < 100.0)
            return false;
    }

    // 5) dentro do abrigo, quando da para saber
    if (g_bUsarAbrigo)
    {
        float p[3];
        p = chao;
        p[2] += 16.0;
        if (!L4D_IsPositionInFirstCheckpoint(p))
            return false;
    }

    saida = chao;
    return true;
}

int AcharPontos(const float ancora[3], float pontos[MAX_PONTOS][3])
{
    float chaoBase = ancora[2];
    float de[3], chao[3], normal[3];
    de = ancora;
    de[2] += 16.0;
    if (AcharChao(de, 200.0, chao, normal))
        chaoBase = chao[2];

    float olho[3];
    olho = ancora;
    olho[2] = chaoBase + ALTURA_OLHO;

    g_iNumPortas = 0;
    int porta = -1;
    while ((porta = FindEntityByClassname(porta, "prop_door_rotating_checkpoint")) != -1 && g_iNumPortas < MAX_PORTAS)
        GetEntPropVector(porta, Prop_Send, "m_vecOrigin", g_vPortas[g_iNumPortas++]);

    // pontos candidatos em grade, do mais perto para o mais longe
    float cx[MAX_PONTOS], cy[MAX_PONTOS], cd[MAX_PONTOS];
    int nc = 0;
    for (int dx = -GRADE_MEIA; dx <= GRADE_MEIA; dx++)
    {
        for (int dy = -GRADE_MEIA; dy <= GRADE_MEIA; dy++)
        {
            if (dx == 0 && dy == 0)
                continue;
            float d = SquareRoot(float(dx * dx + dy * dy)) * GRADE_PASSO;
            if (d > RAIO_MAX || nc >= sizeof(cx))
                continue;
            int j = nc++;
            while (j > 0 && cd[j - 1] > d)
            {
                cx[j] = cx[j - 1];
                cy[j] = cy[j - 1];
                cd[j] = cd[j - 1];
                j--;
            }
            cx[j] = ancora[0] + float(dx) * GRADE_PASSO;
            cy[j] = ancora[1] + float(dy) * GRADE_PASSO;
            cd[j] = d;
        }
    }

    int n = 0;
    for (int k = 0; k < nc && n < MAX_PONTOS; k++)
    {
        if (PontoValido(olho, chaoBase, cx[k], cy[k], pontos[n]))
            n++;
    }
    return n;
}

// ---------------------------------------------------------------- criacao

void Registrar(int ent)
{
    if (g_iNumCriados < MAX_CRIADOS)
        g_iCriados[g_iNumCriados++] = EntIndexToEntRef(ent);
}

int LimparArsenal()
{
    int n = 0;
    for (int k = 0; k < g_iNumCriados; k++)
    {
        int ent = EntRefToEntIndex(g_iCriados[k]);
        if (ent == INVALID_ENT_REFERENCE)
            continue;
        // nao tira arma da mao de ninguem
        if (HasEntProp(ent, Prop_Send, "m_hOwner") && GetEntPropEnt(ent, Prop_Send, "m_hOwner") != -1)
            continue;
        RemoveEntity(ent);
        n++;
    }
    g_iNumCriados = 0;
    return n;
}

bool EdictSeguro(int ent)
{
    if (ent > LIMITE_EDICTS)
    {
        RemoveEntity(ent);
        return false;
    }
    return true;
}

// Ponto de arma que pode ser pego varias vezes (igual aos do mapa)
bool CriarPontoDeArma(int idx, const float pos[3], float yaw)
{
    int ent = CreateEntityByName("weapon_spawn");
    if (ent == -1)
        return false;
    if (!EdictSeguro(ent))
        return false;

    SetEntProp(ent, Prop_Send, "m_weaponID", g_iArmaId[idx]);
    SetEntityModel(ent, g_sArmaModelo[idx]);

    int qtd = g_cvQtd.IntValue;
    if (qtd <= 0)
    {
        DispatchKeyValue(ent, "spawnflags", "8");   // infinito
        DispatchKeyValue(ent, "count", "1");
    }
    else
    {
        char s[8];
        IntToString(qtd, s, sizeof(s));
        DispatchKeyValue(ent, "count", s);
    }
    DispatchKeyValue(ent, "disableshadows", "1");

    float p[3], a[3];
    p = pos;
    p[2] += 2.0;
    a[0] = 0.0;
    a[1] = yaw;
    a[2] = 90.0;                // deitada de lado, como as do mapa
    TeleportEntity(ent, p, a, NULL_VECTOR);
    DispatchSpawn(ent);
    SetEntityMoveType(ent, MOVETYPE_NONE);
    Registrar(ent);
    return true;
}

// Item solto (corpo a corpo e especiais): cai no chao com fisica
bool CriarItemSolto(const char[] classe, const char[] melee, const float pos[3], int camada)
{
    int ent = CreateEntityByName(classe);
    if (ent == -1)
        return false;
    if (!EdictSeguro(ent))
        return false;

    DispatchKeyValue(ent, "solid", "6");
    if (melee[0] != '\0')
        DispatchKeyValue(ent, "melee_script_name", melee);

    float p[3], a[3];
    p = pos;
    p[0] += GetRandomFloat(-6.0, 6.0);
    p[1] += GetRandomFloat(-6.0, 6.0);
    p[2] += 10.0 + 6.0 * float(camada);
    a[0] = 0.0;
    a[1] = GetRandomFloat(0.0, 360.0);
    a[2] = 90.0;
    TeleportEntity(ent, p, a, NULL_VECTOR);
    DispatchSpawn(ent);
    ActivateEntity(ent);

    if (StrEqual(classe, "weapon_grenade_launcher"))
    {
        ConVar cv = FindConVar("ammo_grenadelauncher_max");
        if (cv != null && HasEntProp(ent, Prop_Send, "m_iExtraPrimaryAmmo"))
            SetEntProp(ent, Prop_Send, "m_iExtraPrimaryAmmo", cv.IntValue);
    }
    Registrar(ent);
    return true;
}

int LerMelees(char lista[MAX_MELEE][64])
{
    int tabela = FindStringTable("MeleeWeapons");
    if (tabela == INVALID_STRING_TABLE)
        return 0;
    int n = GetStringTableNumStrings(tabela);
    if (n > MAX_MELEE)
        n = MAX_MELEE;
    for (int i = 0; i < n; i++)
        ReadStringTable(tabela, i, lista[i], sizeof(lista[]));
    return n;
}

int MontarArsenal(const float ancora[3], int quem, const char[] motivo)
{
    LimparArsenal();

    g_bUsarAbrigo = false;
    if (GetFeatureStatus(FeatureType_Native, "L4D_IsPositionInFirstCheckpoint") == FeatureStatus_Available)
    {
        float p[3];
        p = ancora;
        p[2] += 16.0;
        g_bUsarAbrigo = L4D_IsPositionInFirstCheckpoint(p);
    }

    float pontos[MAX_PONTOS][3];
    int np = AcharPontos(ancora, pontos);
    if (np == 0)
    {
        // sem espaco livre: usa o proprio lugar do jogador
        pontos[0] = ancora;
        np = 1;
    }

    int usado = 0, armas = 0, tiposMelee = 0, melees = 0, especiais = 0, falhas = 0;

    // 1) armas de fogo (prioridade nos lugares mais perto)
    for (int i = 0; i < sizeof(g_iArmaId); i++)
    {
        if (g_iArmaGrupo[i] == 1 && !g_cvCss.BoolValue)
            continue;
        if (g_iArmaGrupo[i] == 2 && !g_cvPistolas.BoolValue)
            continue;
        int slot = usado % np;
        float pos[3];
        pos = pontos[slot];
        if (usado >= np)    // faltou lugar: encosta ao lado de outra arma
        {
            pos[0] += 12.0 * float(usado / np);
            pos[1] -= 12.0 * float(usado / np);
        }
        if (CriarPontoDeArma(i, pos, 45.0))
            armas++;
        else
            falhas++;
        usado++;
    }

    // 2) corpo a corpo: todas as do mapa, cada tipo num lugar
    char lista[MAX_MELEE][64];
    int nm = LerMelees(lista);
    int qm = g_cvMelee.IntValue;
    for (int i = 0; i < nm && qm > 0; i++)
    {
        int slot = usado % np;
        bool ok = false;
        for (int q = 0; q < qm; q++)
        {
            if (CriarItemSolto("weapon_melee", lista[i], pontos[slot], q))
            {
                melees++;
                ok = true;
            }
            else
                falhas++;
        }
        if (ok)
            tiposMelee++;
        usado++;
    }

    // 3) especiais
    int qe = g_cvEspeciais.IntValue;
    for (int i = 0; i < sizeof(g_sEspecial) && qe > 0; i++)
    {
        int slot = usado % np;
        for (int q = 0; q < qe; q++)
        {
            if (CriarItemSolto(g_sEspecial[i], "", pontos[slot], q))
                especiais++;
            else
                falhas++;
        }
        usado++;
    }

    char nome[64] = "?";
    if (quem > 0 && IsClientInGame(quem))
        GetClientName(quem, nome, sizeof(nome));
    char mapa[64];
    GetCurrentMap(mapa, sizeof(mapa));
    LogToFileEx(g_sLog, "%s | %s | perto de %s em %.0f %.0f %.0f | abrigo=%s | %d lugares livres para %d | %d armas de fogo, %d corpo a corpo (%d tipos de %d no mapa), %d especiais, %d falhas",
        mapa, motivo, nome, ancora[0], ancora[1], ancora[2], g_bUsarAbrigo ? "sim" : "nao",
        np, usado, armas, melees, tiposMelee, nm, especiais, falhas);

    g_iAvisoArmas = armas + (especiais > 0 ? sizeof(g_sEspecial) : 0);
    g_iAvisoMelee = tiposMelee;
    if (g_cvAviso.BoolValue && (armas + melees) > 0)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && !IsFakeClient(i))
                Avisar(i);
        }
    }
    return armas + melees + especiais;
}
