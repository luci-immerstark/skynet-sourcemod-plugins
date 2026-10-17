#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Votes",
    author = "SKYNET GAMING",
    description = "Somente admins abrem votacoes do jogo (dificuldade, kick, reiniciar, trocar campanha, lobby)",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvAllow;

public void OnPluginStart()
{
    g_cvAllow = CreateConVar("skynet_votes_allow", "", "Votacoes que jogadores comuns podem abrir, separadas por virgula (ex.: Kick,ChangeAllTalk). Vazio = so admins");
    AutoExecConfig(true, "skynet_votes");
    AddCommandListener(Cmd_CallVote, "callvote");
}

public Action Cmd_CallVote(int client, const char[] command, int argc)
{
    if (client < 1 || !IsClientInGame(client))
        return Plugin_Continue;
    if (CheckCommandAccess(client, "skynet_callvote", ADMFLAG_GENERIC, true))
        return Plugin_Continue;

    char issue[32], lista[256];
    GetCmdArg(1, issue, sizeof(issue));
    g_cvAllow.GetString(lista, sizeof(lista));
    if (issue[0] != '\0' && lista[0] != '\0')
    {
        char itens[16][32];
        int n = ExplodeString(lista, ",", itens, sizeof(itens), sizeof(itens[]));
        for (int i = 0; i < n; i++)
        {
            TrimString(itens[i]);
            if (StrEqual(itens[i], issue, false))
                return Plugin_Continue;
        }
    }
    PrintToChat(client, "\x04[SKYNET GAMING]\x01 Votações são abertas apenas pelos administradores.");
    return Plugin_Handled;
}
