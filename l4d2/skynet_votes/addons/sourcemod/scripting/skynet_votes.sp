#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Votes",
    author = "SKYNET GAMING",
    description = "Desliga as votacoes do menu do jogo (dificuldade, kick, reiniciar, trocar campanha, lobby) com aviso na tela",
    version = "1.1",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvAllow;
ConVar g_cvAdmins;

public void OnPluginStart()
{
    g_cvAllow = CreateConVar("skynet_votes_allow", "", "Votacoes do menu que continuam liberadas pra todos, separadas por virgula (ex.: Kick,ChangeAllTalk). Vazio = nenhuma");
    g_cvAdmins = CreateConVar("skynet_votes_admins", "0", "1 = admins (override skynet_callvote, flag b) ainda abrem votacoes pelo menu; 0 = ninguem abre", _, true, 0.0, true, 1.0);
    AutoExecConfig(true, "skynet_votes");
    AddCommandListener(Cmd_CallVote, "callvote");
}

bool Liberada(const char[] issue)
{
    char lista[256];
    g_cvAllow.GetString(lista, sizeof(lista));
    if (issue[0] == '\0' || lista[0] == '\0')
        return false;
    char itens[16][32];
    int n = ExplodeString(lista, ",", itens, sizeof(itens), sizeof(itens[]));
    for (int i = 0; i < n; i++)
    {
        TrimString(itens[i]);
        if (StrEqual(itens[i], issue, false))
            return true;
    }
    return false;
}

public Action Cmd_CallVote(int client, const char[] command, int argc)
{
    if (client < 1 || !IsClientInGame(client))
        return Plugin_Continue;
    bool admin = CheckCommandAccess(client, "skynet_callvote", ADMFLAG_GENERIC, true);
    if (admin && g_cvAdmins.BoolValue)
        return Plugin_Continue;

    char issue[32];
    GetCmdArg(1, issue, sizeof(issue));
    if (Liberada(issue))
        return Plugin_Continue;

    // aviso no meio da tela (o menu de votacao cobre o chat) e no chat
    if (admin)
    {
        PrintCenterText(client, "Votações pelo menu estão desligadas: use o !admin");
        PrintToChat(client, "\x04[SKYNET GAMING]\x01 Votações pelo menu estão desligadas. Admin: use o \x04!admin\x01 para kick e troca de campanha.");
    }
    else
    {
        PrintCenterText(client, "Apenas admins podem iniciar votações");
        PrintToChat(client, "\x04[SKYNET GAMING]\x01 Apenas admins podem iniciar votações neste servidor.");
    }
    return Plugin_Handled;
}
