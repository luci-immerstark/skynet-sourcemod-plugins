#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Robots",
    author = "SKYNET GAMING",
    description = "Comando !robot: vira um robo do Mann vs. Machine (modelo, voz e passos)",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

bool g_Robot[MAXPLAYERS + 1];
float g_Next[MAXPLAYERS + 1];
ConVar g_cvEnabled, g_cvSounds, g_cvCooldown;

// Indice = numero da classe no TF2 (1 = Scout ... 9 = Engineer)
static const char g_ModelName[][] = { "", "scout", "sniper", "soldier", "demo", "medic", "heavy", "pyro", "spy", "engineer" };
static const char g_VoiceName[][] = { "", "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer" };

public void OnPluginStart()
{
    g_cvEnabled  = CreateConVar("skynet_robot_enabled", "1", "Liga (1) ou desliga (0) o comando !robot", _, true, 0.0, true, 1.0);
    g_cvSounds   = CreateConVar("skynet_robot_sounds", "1", "Robos usam voz e passos de robo (1) ou os sons normais (0)", _, true, 0.0, true, 1.0);
    g_cvCooldown = CreateConVar("skynet_robot_cooldown", "3", "Segundos de espera entre um uso e outro do !robot", _, true, 0.0);
    AutoExecConfig(true, "skynet_robot");
    g_cvEnabled.AddChangeHook(OnEnabledChanged);

    RegConsoleCmd("sm_robot", Cmd_Robot, "Vira ou deixa de ser um robo");
    RegConsoleCmd("sm_robots", Cmd_Robot, "Vira ou deixa de ser um robo");
    RegConsoleCmd("sm_robo", Cmd_Robot, "Vira ou deixa de ser um robo");

    HookEvent("player_spawn", Ev_Spawn, EventHookMode_Post);
    HookEvent("post_inventory_application", Ev_Spawn, EventHookMode_Post);
    AddNormalSoundHook(Hook_Sound);
}

public void OnPluginEnd()
{
    ClearAll();
}

public void OnMapStart()
{
    char path[PLATFORM_MAX_PATH];
    for (int c = 1; c <= 9; c++)
    {
        FormatEx(path, sizeof(path), "models/bots/%s/bot_%s.mdl", g_ModelName[c], g_ModelName[c]);
        PrecacheModel(path, true);
    }
    for (int i = 1; i <= 18; i++)
    {
        FormatEx(path, sizeof(path), "mvm/player/footsteps/robostep_%02d.wav", i);
        PrecacheSound(path, true);
    }
    for (int i = 1; i <= MaxClients; i++)
        g_Next[i] = 0.0;
}

public void OnClientPutInServer(int client)
{
    g_Robot[client] = false;
    g_Next[client] = 0.0;
}

public void OnClientDisconnect(int client)
{
    g_Robot[client] = false;
}

public void OnEnabledChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (!convar.BoolValue)
        ClearAll();
}

void ClearAll()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_Robot[i] && IsClientInGame(i))
            ClearRobot(i);
        g_Robot[i] = false;
    }
}

void ApplyRobot(int client)
{
    int cls = view_as<int>(TF2_GetPlayerClass(client));
    if (cls < 1 || cls > 9)
        return;
    char model[PLATFORM_MAX_PATH];
    FormatEx(model, sizeof(model), "models/bots/%s/bot_%s.mdl", g_ModelName[cls], g_ModelName[cls]);
    SetVariantString(model);
    AcceptEntityInput(client, "SetCustomModel");
    SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

void ClearRobot(int client)
{
    SetVariantString("");
    AcceptEntityInput(client, "SetCustomModel");
}

public Action Cmd_Robot(int client, int args)
{
    if (client < 1 || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[SKYNET] Este comando so funciona dentro do jogo.");
        return Plugin_Handled;
    }
    if (!g_cvEnabled.BoolValue)
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 O modo robô está desligado no momento.");
        return Plugin_Handled;
    }
    float agora = GetGameTime();
    if (agora < g_Next[client])
    {
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Aguarde um instante para usar o \x0700E5FF!robot\x01 de novo.");
        return Plugin_Handled;
    }
    g_Next[client] = agora + g_cvCooldown.FloatValue;

    g_Robot[client] = !g_Robot[client];
    if (g_Robot[client])
    {
        if (IsPlayerAlive(client))
            ApplyRobot(client);
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Você agora é um \x0700E5FFrobô\x01! Digite \x0700E5FF!robot\x01 de novo para voltar ao normal.");
    }
    else
    {
        ClearRobot(client);
        PrintToChat(client, "\x07FFD700[SKYNET GAMING]\x01 Você voltou ao normal.");
    }
    return Plugin_Handled;
}

// Reaplica o modelo ao nascer e ao trocar de classe
public void Ev_Spawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || !g_Robot[client] || !IsClientInGame(client) || !IsPlayerAlive(client))
        return;
    if (g_cvEnabled.BoolValue)
        ApplyRobot(client);
}

// Troca a voz e os passos dos robos pelos sons do Mann vs. Machine
public Action Hook_Sound(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
    if (entity < 1 || entity > MaxClients || !g_Robot[entity] || !g_cvSounds.BoolValue || !IsClientInGame(entity))
        return Plugin_Continue;

    if (StrContains(sample, "player/footsteps/", false) != -1)
    {
        FormatEx(sample, sizeof(sample), "mvm/player/footsteps/robostep_%02d.wav", GetRandomInt(1, 18));
        return Plugin_Changed;
    }

    if (StrContains(sample, "vo/", false) == -1 || StrContains(sample, "vo/mvm/", false) != -1 || StrContains(sample, "announcer", false) != -1)
        return Plugin_Continue;

    int cls = view_as<int>(TF2_GetPlayerClass(entity));
    if (cls < 1 || cls > 9)
        return Plugin_Continue;

    char novo[PLATFORM_MAX_PATH], de[32], para[40];
    strcopy(novo, sizeof(novo), sample);
    ReplaceStringEx(novo, sizeof(novo), "vo/", "vo/mvm/norm/", -1, -1, false);
    FormatEx(de, sizeof(de), "%s_", g_VoiceName[cls]);
    FormatEx(para, sizeof(para), "%s_mvm_", g_VoiceName[cls]);
    if (ReplaceStringEx(novo, sizeof(novo), de, para, -1, -1, false) == -1)
        return Plugin_Continue;
    ReplaceString(novo, sizeof(novo), ".wav", ".mp3", false);

    // So troca se a fala de robo existir no jogo; senao, mantem a fala normal
    char arquivo[PLATFORM_MAX_PATH];
    FormatEx(arquivo, sizeof(arquivo), "sound/%s", novo);
    if (!FileExists(arquivo, true))
        return Plugin_Continue;

    PrecacheSound(novo);
    strcopy(sample, sizeof(sample), novo);
    return Plugin_Changed;
}
