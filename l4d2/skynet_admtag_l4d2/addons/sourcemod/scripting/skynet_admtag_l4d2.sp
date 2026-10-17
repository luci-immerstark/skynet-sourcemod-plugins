#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "SKYNET Admin Tag (L4D2)",
    author = "SKYNET GAMING",
    description = "Tag [ADM] no chat para os administradores",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

public void OnPluginStart()
{
    UserMsg id = GetUserMessageId("SayText2");
    if (id == INVALID_MESSAGE_ID)
        SetFailState("Mensagem SayText2 nao encontrada");
    HookUserMessage(id, OnSayText2, true);
}

public Action OnSayText2(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
    int author = msg.ReadByte();
    if (author < 1 || author > MaxClients || !IsClientInGame(author) || IsFakeClient(author))
        return Plugin_Continue;
    if (!CheckCommandAccess(author, "sm_tag_adm", ADMFLAG_GENERIC, true))
        return Plugin_Continue;

    bool chat = msg.ReadByte() != 0;
    char fmt[64];
    msg.ReadString(fmt, sizeof(fmt));
    if (StrContains(fmt, "Chat_") == -1)
        return Plugin_Continue;

    char name[MAX_NAME_LENGTH], text[256];
    msg.ReadString(name, sizeof(name));
    msg.ReadString(text, sizeof(text));

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(author));
    dp.WriteCell(chat);
    dp.WriteString(fmt);
    dp.WriteString(name);
    dp.WriteString(text);
    dp.WriteCell(playersNum);
    for (int i = 0; i < playersNum; i++)
        dp.WriteCell(GetClientUserId(players[i]));
    RequestFrame(Frame_Resend, dp);
    return Plugin_Handled;
}

// Mesmo prefixo que o jogo usaria (morto, time, espectador)
void Prefixo(const char[] fmt, char[] pre, int len)
{
    bool morto = StrContains(fmt, "Dead") != -1;
    if (StrContains(fmt, "AllSpec") != -1)        strcopy(pre, len, "*SPEC* ");
    else if (StrContains(fmt, "Survivor") != -1)  strcopy(pre, len, morto ? "*DEAD*(Survivor) " : "(Survivor) ");
    else if (StrContains(fmt, "Infected") != -1)  strcopy(pre, len, morto ? "*DEAD*(Infected) " : "(Infected) ");
    else if (StrContains(fmt, "Spec") != -1)      strcopy(pre, len, "(Spectator) ");
    else if (morto)                               strcopy(pre, len, "*DEAD* ");
    else pre[0] = '\0';
}

public void Frame_Resend(DataPack dp)
{
    dp.Reset();
    int author = GetClientOfUserId(dp.ReadCell());
    bool chat = view_as<bool>(dp.ReadCell());
    char fmt[64], name[MAX_NAME_LENGTH], text[256];
    dp.ReadString(fmt, sizeof(fmt));
    dp.ReadString(name, sizeof(name));
    dp.ReadString(text, sizeof(text));
    int num = dp.ReadCell();
    int clients[MAXPLAYERS + 1];
    int total = 0;
    for (int i = 0; i < num; i++)
    {
        int c = GetClientOfUserId(dp.ReadCell());
        if (c > 0 && IsClientInGame(c) && total < MAXPLAYERS)
            clients[total++] = c;
    }
    delete dp;
    if (author == 0 || total == 0)
        return;

    char pre[32], linha[320];
    Prefixo(fmt, pre, sizeof(pre));
    Format(linha, sizeof(linha), "\x01%s\x04[ADM] \x03%s\x01 :  %s", pre, name, text);

    BfWrite bf = UserMessageToBfWrite(StartMessage("SayText2", clients, total, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS));
    bf.WriteByte(author);
    bf.WriteByte(chat ? 1 : 0);
    bf.WriteString(linha);
    bf.WriteString("");
    bf.WriteString("");
    bf.WriteString("");
    bf.WriteString("");
    EndMessage();
}
