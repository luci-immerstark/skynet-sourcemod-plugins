// SKYNET Sprays (L4D2): looking at a spray shows whose it is (helps moderation and reports).
//   Everyone sees the owner's name; admins also see the SteamID and the command to block it.
//   1.2: the name shows only while you look at the spray; an empty hint hides it as soon as you look away
//   (1.2.1: back to the hint box, because the center text in L4D2 is tiny).
//   1.3: L4D2 does not close the hint box with an empty hint (it shows a junk character), so the name now uses the
//   game instructor (tutorial-style message), which closes the moment you look away. Players who turned the
//   instructor off (gameinstructor_enable 0) get the hint box. skynet_spray_modo 0 = always the hint box.
//   1.4: default mode 2 = a small text panel on the left that the server closes the instant the aim leaves the
//   spray (works for everyone; it never covers another open menu).
//   1.4.1: default back to mode 0 (the hint box, two lines); modes 1 and 2 stay available.
//   !quemspray / sm_spraytrace  - aim at a spray: who made it and how long ago (admins)
//   sm_sprayban <player>        - blocks the player's sprays (saved; the current spray disappears on map change)
//   sm_sprayunban <player>      - allows them again
#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name        = "SKYNET Sprays (L4D2)",
    author      = "SKYNET GAMING",
    description = "Mostra de quem e o spray que voce esta olhando e permite bloquear sprays ofensivos",
    version     = "1.4.1",
    url         = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

Cookie g_ckBan;
ConVar g_cvMostrar, g_cvDist, g_cvModo;
bool g_bInstrutor[MAXPLAYERS + 1];
bool g_bAberta[MAXPLAYERS + 1];
bool g_bPainel[MAXPLAYERS + 1];
bool g_bBan[MAXPLAYERS + 1];
float g_fAviso[MAXPLAYERS + 1];

// sprays on the map, by the slot of whoever sprayed (kept after the player leaves)
bool g_bTem[MAXPLAYERS + 1];
float g_fPos[MAXPLAYERS + 1][3];
float g_fQuando[MAXPLAYERS + 1];
int g_iUid[MAXPLAYERS + 1];
char g_sNome[MAXPLAYERS + 1][64];
char g_sId[MAXPLAYERS + 1][32];

// what each player is looking at
int g_iVendo[MAXPLAYERS + 1];
float g_fMostrou[MAXPLAYERS + 1];

public void OnPluginStart()
{
    LoadTranslations("common.phrases");
    g_ckBan = new Cookie("skynet_spray_ban", "Sprays bloqueados", CookieAccess_Private);
    g_cvMostrar = CreateConVar("skynet_spray_mostrar", "1", "1 = mostra de quem e o spray para quem olha para ele", _, true, 0.0, true, 1.0);
    g_cvDist = CreateConVar("skynet_spray_distancia", "800", "Distancia maxima (unidades) para mostrar o dono do spray", _, true, 100.0, true, 3000.0);
    g_cvModo = CreateConVar("skynet_spray_modo", "0", "2 = painel que some ao tirar a mira, 1 = mensagem do instrutor do jogo, 0 = caixa de dica", _, true, 0.0, true, 2.0);
    AutoExecConfig(true, "skynet_sprays_l4d2");
    RegAdminCmd("sm_spraytrace", Cmd_Trace, ADMFLAG_GENERIC, "Mostra de quem e o spray na sua mira");
    RegAdminCmd("sm_quemspray", Cmd_Trace, ADMFLAG_GENERIC, "Mostra de quem e o spray na sua mira");
    RegAdminCmd("sm_sprayban", Cmd_Ban, ADMFLAG_GENERIC, "sm_sprayban <jogador>: bloqueia os sprays");
    RegAdminCmd("sm_sprayunban", Cmd_Unban, ADMFLAG_GENERIC, "sm_sprayunban <jogador>: libera os sprays");
    AddTempEntHook("Player Decal", TE_Spray);
    CreateTimer(0.2, T_Olhar, _, TIMER_REPEAT);
    for (int c = 1; c <= MaxClients; c++)
    {
        if (IsClientInGame(c) && AreClientCookiesCached(c))
            OnClientCookiesCached(c);
        if (IsClientInGame(c))
        {
            g_bInstrutor[c] = true;        // 1.3.1: players already in the server when the plugin (re)loads
            OnClientPutInServer(c);
        }
    }
}

public void OnMapStart()
{
    for (int c = 0; c <= MaxClients; c++)
    {
        g_bTem[c] = false;
        g_iVendo[c] = 0;
    }
}

public void OnClientConnected(int c)
{
    g_bBan[c] = false;
    g_iVendo[c] = 0;
    g_bInstrutor[c] = true;
    g_bAberta[c] = false;
}

public void OnClientPutInServer(int c)
{
    if (!IsFakeClient(c))
        QueryClientConVar(c, "gameinstructor_enable", Q_Instrutor);
}

public void Q_Instrutor(QueryCookie cookie, int c, ConVarQueryResult res, const char[] nome, const char[] valor)
{
    if (res == ConVarQuery_Okay)
        g_bInstrutor[c] = StringToInt(valor) != 0;
    if (IsClientInGame(c))
        LogMessage("instrutor do jogo de %N: %s", c, res == ConVarQuery_Okay ? valor : "?");
}

// shows the text only to this player: game instructor message, or the hint box as a fallback
public int H_Painel(Menu m, MenuAction a, int c, int item)
{
    return 0;
}

void Mostrar(int c, const char[] texto)
{
    if (g_cvModo.IntValue == 2)
    {
        MenuSource fonte = GetClientMenu(c);
        if (fonte != MenuSource_None && !(g_bPainel[c] && fonte == MenuSource_RawPanel))
            return;                         // another menu is open: do not cover it
        char l1[128], l2[128];
        int p = StrContains(texto, "\n");
        if (p == -1)
        {
            strcopy(l1, sizeof(l1), texto);
            l2[0] = '\0';
        }
        else
        {
            strcopy(l1, (p + 1 < sizeof(l1)) ? p + 1 : sizeof(l1), texto);
            strcopy(l2, sizeof(l2), texto[p + 1]);
        }
        Panel pn = new Panel();
        pn.DrawText(l1);
        if (l2[0])
            pn.DrawText(l2);
        pn.Send(c, H_Painel, 2);
        delete pn;
        g_bPainel[c] = true;
        return;
    }
    if (g_cvModo.IntValue == 1 && g_bInstrutor[c])
    {
        Event e = CreateEvent("instructor_server_hint_create", true);
        if (e != null)
        {
            e.SetString("hint_name", "skynet_spray");
            e.SetString("hint_replace_key", "skynet_spray");
            e.SetInt("hint_target", c);
            e.SetInt("hint_activator_userid", GetClientUserId(c));
            e.SetInt("hint_timeout", 0);
            e.SetString("hint_icon_onscreen", "icon_info");
            e.SetString("hint_icon_offscreen", "icon_info");
            e.SetString("hint_caption", texto);
            e.SetString("hint_color", "255,255,255");
            e.SetFloat("hint_icon_offset", 0.0);
            e.SetFloat("hint_range", 0.0);
            e.SetInt("hint_flags", 0);
            e.SetString("hint_binding", "");
            e.SetBool("hint_allow_nodraw_target", true);
            e.SetBool("hint_nooffscreen", false);
            e.SetBool("hint_forcecaption", true);
            e.SetBool("hint_local_player_only", true);
            e.SetBool("hint_static", true);           // fixed on the screen (ignored if the game does not know it)
            e.FireToClient(c);
            e.Cancel();
            g_bAberta[c] = true;
            return;
        }
    }
    PrintHintText(c, "%s", texto);
}

// closes the instructor message (the hint box closes on its own after a few seconds)
void Esconder(int c)
{
    if (g_bPainel[c])
    {
        g_bPainel[c] = false;
        if (IsClientInGame(c) && GetClientMenu(c) == MenuSource_RawPanel)
            CancelClientMenu(c);            // closes the panel right away
    }
    if (!g_bAberta[c])
        return;
    g_bAberta[c] = false;
    Event e = CreateEvent("instructor_server_hint_stop", true);
    if (e != null)
    {
        e.SetString("hint_name", "skynet_spray");
        e.FireToClient(c);
        e.Cancel();
    }
}

public void OnClientCookiesCached(int c)
{
    char v[4];
    g_ckBan.Get(c, v, sizeof(v));
    g_bBan[c] = v[0] == '1';
}

public Action TE_Spray(const char[] te, const int[] jogadores, int n, float atraso)
{
    int c = TE_ReadNum("m_nPlayer");
    if (c < 1 || c > MaxClients || !IsClientInGame(c))
        return Plugin_Continue;
    if (g_bBan[c])
    {
        if (GetGameTime() > g_fAviso[c])
        {
            g_fAviso[c] = GetGameTime() + 10.0;
            PrintToChat(c, "[SKYNET] Seus sprays estão bloqueados neste servidor.");
        }
        return Plugin_Stop;
    }
    TE_ReadVector("m_vecOrigin", g_fPos[c]);
    g_fQuando[c] = GetGameTime();
    g_iUid[c] = GetClientUserId(c);
    GetClientName(c, g_sNome[c], sizeof(g_sNome[]));
    if (!GetClientAuthId(c, AuthId_Steam2, g_sId[c], sizeof(g_sId[])))
        strcopy(g_sId[c], sizeof(g_sId[]), "?");
    g_bTem[c] = true;
    return Plugin_Continue;
}

public bool F_Mundo(int ent, int mask)
{
    return ent == 0 || ent > MaxClients;
}

// spray (slot of the owner) where the player is aiming, or 0
int SprayNaMira(int c, float &dist)
{
    float olho[3], ang[3], fim[3];
    GetClientEyePosition(c, olho);
    GetClientEyeAngles(c, ang);
    TR_TraceRayFilter(olho, ang, MASK_SOLID_BRUSHONLY, RayType_Infinite, F_Mundo);
    if (!TR_DidHit())
        return 0;
    TR_GetEndPosition(fim);
    dist = GetVectorDistance(olho, fim);
    int dono = 0;
    float melhor = 40.0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!g_bTem[i])
            continue;
        float d = GetVectorDistance(fim, g_fPos[i]);
        if (d < melhor)
        {
            melhor = d;
            dono = i;
        }
    }
    return dono;
}

bool Saiu(int dono)
{
    return GetClientOfUserId(g_iUid[dono]) == 0;
}

public Action T_Olhar(Handle t)
{
    if (!g_cvMostrar.BoolValue)
        return Plugin_Continue;
    float agora = GetGameTime();
    for (int c = 1; c <= MaxClients; c++)
    {
        if (!IsClientInGame(c) || IsFakeClient(c))
            continue;
        float dist;
        int dono = SprayNaMira(c, dist);
        if (!dono || dist > g_cvDist.FloatValue)
        {
            if (g_iVendo[c])
                Esconder(c);                  // stopped looking: closes the message
            g_iVendo[c] = 0;
            continue;
        }
        if (dono == g_iVendo[c] && agora - g_fMostrou[c] < (g_cvModo.IntValue == 2 ? 1.0 : 3.0))
            continue;
        g_iVendo[c] = dono;
        g_fMostrou[c] = agora;
        char texto[192];
        if (CheckCommandAccess(c, "sm_sprayban", ADMFLAG_GENERIC))
            FormatEx(texto, sizeof(texto), "Spray de %s%s\n%s | sm_sprayban #%d", g_sNome[dono], Saiu(dono) ? " (saiu do servidor)" : "", g_sId[dono], g_iUid[dono]);
        else
            FormatEx(texto, sizeof(texto), "Spray de %s%s", g_sNome[dono], Saiu(dono) ? " (saiu do servidor)" : "");
        Mostrar(c, texto);
    }
    return Plugin_Continue;
}

public Action Cmd_Trace(int c, int args)
{
    if (!c || !IsClientInGame(c))
        return Plugin_Handled;
    float dist;
    int dono = SprayNaMira(c, dist);
    if (!dono)
    {
        ReplyToCommand(c, "[SKYNET] Nenhum spray nesse lugar (mire no spray).");
        return Plugin_Handled;
    }
    int seg = RoundToFloor(GetGameTime() - g_fQuando[dono]);
    ReplyToCommand(c, "[SKYNET] Spray de %s (%s)%s, feito há %d min %d s. Para bloquear: sm_sprayban #%d", g_sNome[dono], g_sId[dono],
        Saiu(dono) ? ", saiu do servidor" : "", seg / 60, seg % 60, g_iUid[dono]);
    return Plugin_Handled;
}

public Action Cmd_Ban(int c, int args)
{
    return Muda(c, args, true);
}

public Action Cmd_Unban(int c, int args)
{
    return Muda(c, args, false);
}

Action Muda(int c, int args, bool ban)
{
    if (args < 1)
    {
        ReplyToCommand(c, "[SKYNET] Uso: %s <jogador>", ban ? "sm_sprayban" : "sm_sprayunban");
        return Plugin_Handled;
    }
    char arg[64];
    GetCmdArg(1, arg, sizeof(arg));
    int alvo = FindTarget(c, arg, true, false);
    if (alvo == -1)
        return Plugin_Handled;
    g_bBan[alvo] = ban;
    if (AreClientCookiesCached(alvo))
        g_ckBan.Set(alvo, ban ? "1" : "");
    if (ban)
        g_bTem[alvo] = false;
    ShowActivity2(c, "[SKYNET] ", "%s os sprays de %N.", ban ? "bloqueou" : "liberou", alvo);
    LogAction(c, alvo, "\"%L\" %s os sprays de \"%L\"", c, ban ? "bloqueou" : "liberou", alvo);
    return Plugin_Handled;
}
