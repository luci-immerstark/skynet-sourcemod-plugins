// SKYNET: quando um jogador morre, os projeteis dele que ainda estao no ar (foguete, granada, flecha, flare...)
//   somem na hora e nao dao mais dano. Assim, no duelo, quem morre primeiro nao leva o outro junto.
//   Stickies ja somem sozinhas no TF2. O Dead Ringer (morte falsa) nao conta.
#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define DEATHFLAG_DEADRINGER 32

public Plugin myinfo =
{
    name        = "SKYNET Projeteis",
    author      = "SKYNET GAMING",
    description = "Remove os projeteis de quem morreu",
    version     = "1.0.0",
    url         = "https://github.com/luci-immerstark/skynet-sourcemod-plugins"
};

ConVar g_cvAtivo;

public void OnPluginStart()
{
    g_cvAtivo = CreateConVar("skynet_projeteis", "1", "1 = os projeteis de quem morre somem; 0 = desliga", _, true, 0.0, true, 1.0);
    HookEvent("player_death", Ev_Morte);
}

int Dono(int ent)
{
    int dono = -1;
    if (HasEntProp(ent, Prop_Send, "m_hThrower"))
        dono = GetEntPropEnt(ent, Prop_Send, "m_hThrower");
    if (dono < 1 && HasEntProp(ent, Prop_Send, "m_hOwnerEntity"))
        dono = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
    return dono;
}

public void Ev_Morte(Event event, const char[] nome, bool semTransmitir)
{
    if (!g_cvAtivo.BoolValue || (event.GetInt("death_flags") & DEATHFLAG_DEADRINGER))
        return;
    int vitima = GetClientOfUserId(event.GetInt("userid"));
    if (vitima < 1)
        return;
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "tf_projectile_*")) != -1)
    {
        if (Dono(ent) == vitima)
            RemoveEntity(ent);
    }
}
