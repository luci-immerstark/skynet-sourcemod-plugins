#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Sem !map (L4D2)",
    author = "SKYNET GAMING",
    description = "Bloqueia !map e !votemap no jogo: a troca de campanha e pelo menu de admin",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

// O !map e o !votemap usam a troca de mapa antiga (nome em codigo e abertura da campanha quebrada).
// O console do servidor (rcon) continua podendo usar.

public void OnPluginStart()
{
    AddCommandListener(L_Bloquear, "sm_map");
    AddCommandListener(L_Bloquear, "sm_votemap");
}

bool Espanhol(int client)
{
    char codigo[8], nome[32];
    GetLanguageInfo(GetClientLanguage(client), codigo, sizeof(codigo), nome, sizeof(nome));
    return StrEqual(codigo, "es") || StrEqual(codigo, "las");
}

public Action L_Bloquear(int client, const char[] comando, int args)
{
    if (client <= 0 || !IsClientInGame(client))
        return Plugin_Continue;
    if (Espanhol(client))
        PrintToChat(client, "\x04[SKYNET]\x01 Usa el menú de admin (\x03!admin\x01) para cambiar de campaña.");
    else
        PrintToChat(client, "\x04[SKYNET]\x01 Use o menu de admin (\x03!admin\x01) para trocar de campanha.");
    return Plugin_Stop;
}
