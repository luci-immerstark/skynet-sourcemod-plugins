#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <adminmenu>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Teleporte (L4D2)",
    author = "SKYNET GAMING",
    description = "Admin vai ate um jogador (!goto) ou traz um jogador ate ele (!bring)",
    version = "1.1",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

#define TAG "\x04[SKYNET]\x01 "

// 1.1: secao "Teleporte" no menu de admin (!admin), com "Ir ate um jogador" e "Trazer um jogador"
TopMenu g_hMenuAdmin;
TopMenuObject g_oSecao = INVALID_TOPMENUOBJECT;
bool g_bDoAdmin[MAXPLAYERS + 1];   // a lista foi aberta pelo menu de admin: o "Voltar" retorna a ele

public void OnPluginStart()
{
    LoadTranslations("common.phrases");
    LoadTranslations("skynet_teleporte.phrases");
    RegAdminCmd("sm_goto", Cmd_Ir, ADMFLAG_SLAY, "sm_goto <jogador> - vai ate o jogador (sem nome abre a lista)");
    RegAdminCmd("sm_bring", Cmd_Trazer, ADMFLAG_SLAY, "sm_bring <jogador> - traz o jogador ate voce (sem nome abre a lista)");
    TopMenu menu;
    if (LibraryExists("adminmenu") && (menu = GetAdminTopMenu()) != null)
        OnAdminMenuReady(menu);
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "adminmenu"))
    {
        g_hMenuAdmin = null;
        g_oSecao = INVALID_TOPMENUOBJECT;
    }
}

public void OnAdminMenuCreated(Handle aMenu)
{
    TopMenu menu = TopMenu.FromHandle(aMenu);
    if (menu == g_hMenuAdmin && g_oSecao != INVALID_TOPMENUOBJECT)
        return;
    g_oSecao = menu.AddCategory("skynet_teleporte", Secao_Admin, "sm_goto", ADMFLAG_SLAY);
}

public void OnAdminMenuReady(Handle aMenu)
{
    TopMenu menu = TopMenu.FromHandle(aMenu);
    if (g_oSecao == INVALID_TOPMENUOBJECT)
        OnAdminMenuCreated(menu);
    if (menu == g_hMenuAdmin)
        return;
    g_hMenuAdmin = menu;
    g_hMenuAdmin.AddItem("skynet_tele_ir", Item_Ir, g_oSecao, "sm_goto", ADMFLAG_SLAY);
    g_hMenuAdmin.AddItem("skynet_tele_trazer", Item_Trazer, g_oSecao, "sm_bring", ADMFLAG_SLAY);
}

public void Secao_Admin(TopMenu menu, TopMenuAction acao, TopMenuObject obj, int client, char[] texto, int tam)
{
    if (acao == TopMenuAction_DisplayTitle || acao == TopMenuAction_DisplayOption)
        Format(texto, tam, "%T", "Tele Section", client);
}

public void Item_Ir(TopMenu menu, TopMenuAction acao, TopMenuObject obj, int client, char[] texto, int tam)
{
    if (acao == TopMenuAction_DisplayOption)
        Format(texto, tam, "%T", "Tele Item Goto", client);
    else if (acao == TopMenuAction_SelectOption && AdminPode(client))
        Lista(client, true, true);
}

public void Item_Trazer(TopMenu menu, TopMenuAction acao, TopMenuObject obj, int client, char[] texto, int tam)
{
    if (acao == TopMenuAction_DisplayOption)
        Format(texto, tam, "%T", "Tele Item Bring", client);
    else if (acao == TopMenuAction_SelectOption && AdminPode(client))
        Lista(client, false, true);
}

void VoltarAoAdmin(int client)
{
    if (g_bDoAdmin[client] && g_hMenuAdmin != null && g_oSecao != INVALID_TOPMENUOBJECT && IsClientInGame(client))
        g_hMenuAdmin.DisplayCategory(g_oSecao, client);
}

// vivo, em jogo e nao pendurado na beirada (teleportar quem esta pendurado trava o jogador)
bool Movivel(int c)
{
    if (c < 1 || c > MaxClients || !IsClientInGame(c) || GetClientTeam(c) < 2 || !IsPlayerAlive(c))
        return false;
    return GetClientTeam(c) != 2 || GetEntProp(c, Prop_Send, "m_isHangingFromLedge") == 0;
}

bool AdminPode(int client)
{
    if (client == 0)
    {
        ReplyToCommand(client, "%t", "Command is in-game only");
        return false;
    }
    if (!Movivel(client))
    {
        PrintToChat(client, "%s%t", TAG, "Tele Alive");
        return false;
    }
    return true;
}

void Mover(int quem, int ate)
{
    float pos[3];
    GetClientAbsOrigin(ate, pos);
    TeleportEntity(quem, pos, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
}

void Ir(int admin, int alvo)
{
    Mover(admin, alvo);
    ShowActivity2(admin, TAG, "%t", "Tele Goto", alvo);
    LogAction(admin, alvo, "\"%L\" foi ate \"%L\"", admin, alvo);
}

public Action Cmd_Ir(int client, int args)
{
    if (!AdminPode(client))
        return Plugin_Handled;
    if (args < 1)
    {
        Lista(client, true);
        return Plugin_Handled;
    }
    char arg[64];
    GetCmdArgString(arg, sizeof(arg));
    StripQuotes(arg);
    int alvo = FindTarget(client, arg, false, false);
    if (alvo == -1)
        return Plugin_Handled;
    if (alvo == client || !Movivel(alvo))
    {
        PrintToChat(client, "%s%t", TAG, "Tele Invalid");
        return Plugin_Handled;
    }
    Ir(client, alvo);
    return Plugin_Handled;
}

public Action Cmd_Trazer(int client, int args)
{
    if (!AdminPode(client))
        return Plugin_Handled;
    if (args < 1)
    {
        Lista(client, false);
        return Plugin_Handled;
    }
    char arg[64], nome[MAX_TARGET_LENGTH];
    GetCmdArgString(arg, sizeof(arg));
    StripQuotes(arg);
    int alvos[MAXPLAYERS], n;
    bool ml;
    if ((n = ProcessTargetString(arg, client, alvos, MAXPLAYERS, COMMAND_FILTER_ALIVE, nome, sizeof(nome), ml)) <= 0)
    {
        ReplyToTargetError(client, n);
        return Plugin_Handled;
    }
    int movidos = 0;
    for (int i = 0; i < n; i++)
    {
        if (alvos[i] != client && Movivel(alvos[i]))
        {
            Mover(alvos[i], client);
            LogAction(client, alvos[i], "\"%L\" trouxe \"%L\"", client, alvos[i]);
            movidos++;
        }
    }
    if (movidos == 0)
        PrintToChat(client, "%s%t", TAG, "Tele Invalid");
    else if (ml)
        ShowActivity2(client, TAG, "%t", "Tele Bring", nome);
    else
        ShowActivity2(client, TAG, "%t", "Tele Bring", "_s", nome);
    return Plugin_Handled;
}

void Lista(int client, bool ir, bool doAdmin = false)
{
    g_bDoAdmin[client] = doAdmin;
    Menu m = new Menu(ir ? Menu_Ir : Menu_Trazer);
    m.SetTitle("%T", ir ? "Tele Menu Goto" : "Tele Menu Bring", client);
    char id[12], nome[MAX_NAME_LENGTH + 8];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client || !Movivel(i) || (!ir && !CanUserTarget(client, i)))
            continue;
        IntToString(GetClientUserId(i), id, sizeof(id));
        FormatEx(nome, sizeof(nome), "%s%N", GetClientTeam(i) == 3 ? "[INF] " : "", i);
        m.AddItem(id, nome);
    }
    if (m.ItemCount == 0)
    {
        delete m;
        PrintToChat(client, "%s%t", TAG, "Tele None");
        VoltarAoAdmin(client);
        return;
    }
    m.ExitBackButton = doAdmin;
    m.Display(client, MENU_TIME_FOREVER);
}

int Escolhido(Menu m, int item)
{
    char id[12];
    m.GetItem(item, id, sizeof(id));
    return GetClientOfUserId(StringToInt(id));
}

public int Menu_Ir(Menu m, MenuAction acao, int client, int item)
{
    if (acao == MenuAction_End)
        delete m;
    else if (acao == MenuAction_Cancel && item == MenuCancel_ExitBack)
        VoltarAoAdmin(client);
    else if (acao == MenuAction_Select && AdminPode(client))
    {
        int alvo = Escolhido(m, item);
        if (alvo > 0 && alvo != client && Movivel(alvo))
            Ir(client, alvo);
        else
            PrintToChat(client, "%s%t", TAG, "Tele Invalid");
    }
    return 0;
}

public int Menu_Trazer(Menu m, MenuAction acao, int client, int item)
{
    if (acao == MenuAction_End)
        delete m;
    else if (acao == MenuAction_Cancel && item == MenuCancel_ExitBack)
        VoltarAoAdmin(client);
    else if (acao == MenuAction_Select && AdminPode(client))
    {
        int alvo = Escolhido(m, item);
        if (alvo > 0 && alvo != client && Movivel(alvo) && CanUserTarget(client, alvo))
        {
            char nome[MAX_NAME_LENGTH];
            GetClientName(alvo, nome, sizeof(nome));
            Mover(alvo, client);
            ShowActivity2(client, TAG, "%t", "Tele Bring", "_s", nome);
            LogAction(client, alvo, "\"%L\" trouxe \"%L\"", client, alvo);
        }
        else
            PrintToChat(client, "%s%t", TAG, "Tele Invalid");
    }
    return 0;
}
