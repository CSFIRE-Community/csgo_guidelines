#include <sourcemod>
#define CSF_CVAR
#include <csfire>
#include <cstrike>
#include <clientprefs>

#pragma newdecls required
#pragma semicolon 1

Handle g_hClientRulesCookie = INVALID_HANDLE;
bool g_bAcceptedRules[MAXPLAYERS+1] = false;

public Plugin myinfo = {

	name = "[CSFIRE.GG] Guidelines",
	author = "CSFIRE.GG - DEV TEAM",
	description = "shows rules to new players",
	version = "1.0",
	url = "https://csfire.gg/discord"
};

public void OnPluginStart() {

	HookEvent("player_spawn", Event_OnPlayerSpawn);

	RegConsoleCmd("sm_rules", Command_Rules);
	RegConsoleCmd("sm_guidelines", Command_Rules);

	g_cv[EnableGuidelinesMessage] = CreateConVar("sm_enablerulesmessage", "0", "Enable or disabled server guidelines menu message", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	g_hClientRulesCookie = RegClientCookie("Rules", "CSFIRE Community Guidelines", CookieAccess_Private);

	for(int i = MaxClients; i > 0; --i) {

        if(!AreClientCookiesCached(i)) {

            continue;
        }
        
        OnClientCookiesCached(i);
    }
}

public void OnMapStart() {
	
	for (int i = 1; i <= MaxClients; i++) {
		
		g_bAcceptedRules[i] = false;
	}
}

public void OnClientCookiesCached(int client) {

	char sValue[8];
	GetClientCookie(client, g_hClientRulesCookie, sValue, sizeof(sValue));
	
	g_bAcceptedRules[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

public void Event_OnPlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast) {

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(!IsClientValid(client)) {

		return;
	}
	CreateTimer(27.0, GuidelinesDelay, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action GuidelinesDelay(Handle timer, any data) {

	int client = GetClientOfUserId(data);
	
	if (!IsClientValid(client) || !IsPlayerAlive(client) || g_bAcceptedRules[client]/*!g_cv[EnableGuidelinesMessage].BoolValue*/) {
		PrintToChatAll("CLient skipped");
		return Plugin_Continue;
	}
	PrintToChatAll("CLient skipped but not optimized");

	if(g_cv[EnableGuidelinesMessage].BoolValue) {

		Panel panel = new Panel();
		panel.SetTitle("CSFIRE | Guidelines");
		panel.DrawText(" ");
		panel.DrawText("No Cheating");
		panel.DrawText("No Bug Abusing");
		panel.DrawText("No Alt Accounts");
		panel.DrawText("No Impersonating");
		panel.DrawText(" ");
		SetPanelCurrentKey(panel, 4);
		panel.DrawItem("Accept", ITEMDRAW_CONTROL);
		panel.DrawText(" ");
		SetPanelCurrentKey(panel, 5);
		panel.DrawItem("Decline", ITEMDRAW_CONTROL);
		panel.DrawText("");

		panel.Send(client, GuideLinesPanelHandler, 20);
		delete panel;
		return Plugin_Handled;
    }
	return Plugin_Continue;
}

public Action Command_Rules(int client, int sArgs) {

	if(!g_bAcceptedRules[client]) {

		Panel panel = new Panel();
		panel.SetTitle("CSFIRE | Guidelines");
		panel.DrawText(" ");
		panel.DrawText("No Cheating");
		panel.DrawText("No Bug Abusing");
		panel.DrawText("No Alt Accounts");
		panel.DrawText("No Impersonating");
		panel.DrawText(" ");
		SetPanelCurrentKey(panel, 4);
		panel.DrawItem("Accept", ITEMDRAW_CONTROL);
		panel.DrawText(" ");
		SetPanelCurrentKey(panel, 5);
		panel.DrawItem("Decline", ITEMDRAW_CONTROL);
		panel.DrawText("");

		panel.Send(client, GuideLinesPanelHandler, 20);
		delete panel;
		return Plugin_Handled;
	} else {

		Panel panel = new Panel();
		panel.SetTitle("CSFIRE | Guidelines");
		panel.DrawText(" ");
		panel.DrawText("No Cheating");
		panel.DrawText("No Bug Abusing");
		panel.DrawText("No Alt Accounts");
		panel.DrawText("No Impersonating");
		panel.DrawText(" ");
		SetPanelCurrentKey(panel, 3);
		panel.DrawItem("Accept", ITEMDRAW_CONTROL);

		panel.Send(client, Command_GuideLinesPanelHandler, MENU_TIME_FOREVER);
		delete panel;
		return Plugin_Handled;
	}
}

public int GuideLinesPanelHandler(Menu menu, MenuAction choice, int client, int param2) {

	if(choice == MenuAction_Select) {

		ClientCommand(client, "playgamesound \"panel_close.wav\"");
		switch (param2) {

			case 4: {

                PrintToChat(client, "%s\x05Thank you for agreeing to your guidlines, have fun!", TAG_RULES_CLR);
                SetClientCookie(client, g_hClientRulesCookie, "1");
                g_bAcceptedRules[client] = true;
			} case 5: {

                PrintToChat(client, "%s\x0FYou have decliend our guidelines therefore you will not be able to chat, type !rules to review them again", TAG_RULES_CLR);
                SetClientCookie(client, g_hClientRulesCookie, "0");
                g_bAcceptedRules[client] = false;
			}
		}
	}
}

public int Command_GuideLinesPanelHandler(Menu menu, MenuAction choice, int client, int param2) {

	if(choice == MenuAction_Select) {

		ClientCommand(client, "playgamesound \"panel_close.wav\"");
		switch (param2) {

			case 3: {
				SetClientCookie(client, g_hClientRulesCookie, "1");
			}
		}
	}
}

