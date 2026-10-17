#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

// Fornecida pelo Point System API (declarada aqui para nao depender do include na compilacao)
native float PSAPI_GetPoints(int client);

public Plugin myinfo =
{
    name = "SKYNET Points Messages (L4D2)",
    author = "SKYNET GAMING",
    description = "Mensagens de pontos e de compras em portugues, no lugar das originais do Point System API",
    version = "1.0",
    url = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("PSAPI_GetPoints");
    return APLRes_Success;
}

int Saldo(int client)
{
    if (GetFeatureStatus(FeatureType_Native, "PSAPI_GetPoints") != FeatureStatus_Available)
        return -1;
    return RoundToFloor(PSAPI_GetPoints(client));
}

// Copia o que vem depois do prefixo, sem os codigos de cor do plugin original
void Resto(const char[] texto, int inicio, char[] saida, int tam)
{
    int j = 0;
    for (int i = inicio; texto[i] != '\0' && j < tam - 1; i++)
    {
        if (texto[i] >= 1 && texto[i] <= 8)
            continue;
        saida[j++] = texto[i];
    }
    saida[j] = '\0';
}

void Traduzir(const char[] m, char[] saida, int tam)
{
    char nome[64];
    if (StrEqual(m, "Head Hunter"))                    strcopy(saida, tam, "Tiros na cabeça");
    else if (StrEqual(m, "Killing Spree"))             strcopy(saida, tam, "Matança de zumbis");
    else if (StrEqual(m, "TANK SOLO!"))                strcopy(saida, tam, "Matou o Tank sozinho!");
    else if (StrEqual(m, "Killed Tank"))               strcopy(saida, tam, "Tank derrotado");
    else if (StrEqual(m, "Crowned The Witch"))         strcopy(saida, tam, "Witch morta num tiro só");
    else if (StrEqual(m, "Killed Witch"))              strcopy(saida, tam, "Witch morta");
    else if (StrEqual(m, "Protection"))                strcopy(saida, tam, "Protegeu um colega");
    else if (StrEqual(m, "Burned The Tank"))           strcopy(saida, tam, "Tank incendiado");
    else if (StrEqual(m, "Burned Witch"))              strcopy(saida, tam, "Witch incendiada");
    else if (StrEqual(m, "Biled Tank"))                strcopy(saida, tam, "Bile no Tank");
    else if (StrEqual(m, "Don't Harvest Heal Points")) strcopy(saida, tam, "Cura desnecessária");
    else if (strncmp(m, "Killed ", 7) == 0)
    {
        Resto(m, 7, nome, sizeof(nome));
        Format(saida, tam, "Matou \x03%s\x01", nome);
    }
    else if (strncmp(m, "Healed ", 7) == 0)
    {
        Resto(m, 7, nome, sizeof(nome));
        Format(saida, tam, "Curou \x03%s\x01", nome);
    }
    else if (strncmp(m, "Revived ", 8) == 0)
    {
        Resto(m, 8, nome, sizeof(nome));
        if (ReplaceString(nome, sizeof(nome), " From Ledge", "") > 0)
            Format(saida, tam, "Puxou \x03%s\x01 da beirada", nome);
        else
            Format(saida, tam, "Levantou \x03%s\x01", nome);
    }
    else if (strncmp(m, "Defibbed ", 9) == 0)
    {
        Resto(m, 9, nome, sizeof(nome));
        Format(saida, tam, "Reviveu \x03%s\x01", nome);
    }
    else
        Resto(m, 0, saida, tam);
}

// Chamado pelo Point System API antes de somar os pontos
public void PointSystemAPI_OnGainPoints(int client, float &fPoints, const char[] reason)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) || reason[0] == '\0')
        return;
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(client));
    dp.WriteCell(RoundToFloor(fPoints));
    dp.WriteString(reason);
    RequestFrame(Frame_Ganho, dp);
}

// Um instante depois, quando o saldo ja foi atualizado
public void Frame_Ganho(DataPack dp)
{
    dp.Reset();
    int client = GetClientOfUserId(dp.ReadCell());
    int pontos = dp.ReadCell();
    char motivo[96];
    dp.ReadString(motivo, sizeof(motivo));
    delete dp;
    if (client < 1 || !IsClientInGame(client))
        return;

    char texto[128];
    Traduzir(motivo, texto, sizeof(texto));
    int saldo = Saldo(client);
    if (saldo >= 0)
        PrintToChat(client, "\x04[PONTOS]\x01 %s \x05+%d\x01 | Saldo: \x03%d", texto, pontos, saldo);
    else
        PrintToChat(client, "\x04[PONTOS]\x01 %s \x05+%d", texto, pontos);
}

// Chamado pelo Point System API quando uma compra e concluida
public Action PointSystemAPI_OnBuyProductPost(int buyer, const char[] sInfo, const char[] sAliases, const char[] sName, int target, float fCost, float fDelay, float fCooldown)
{
    if (buyer < 1 || buyer > MaxClients || !IsClientInGame(buyer) || IsFakeClient(buyer))
        return Plugin_Continue;

    int custo = RoundToFloor(fCost);
    int saldo = Saldo(buyer);
    if (target == buyer || target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        PrintToChat(buyer, "\x04[LOJA]\x01 Você comprou \x03%s\x01 por \x05%d\x01 | Saldo: \x03%d", sName, custo, saldo);
    }
    else
    {
        PrintToChat(buyer, "\x04[LOJA]\x01 Você comprou \x03%s\x01 para \x03%N\x01 por \x05%d\x01 | Saldo: \x03%d", sName, target, custo, saldo);
        if (!IsFakeClient(target))
            PrintToChat(target, "\x04[LOJA]\x01 \x03%N\x01 comprou \x03%s\x01 para você.", buyer, sName);
    }
    return Plugin_Continue;
}
