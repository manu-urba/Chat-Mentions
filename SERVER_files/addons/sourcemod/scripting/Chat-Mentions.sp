/*
 * Chat Mentions SM plugin.
 * 
 * Copyright (C) 2021  (Manuel|FrAgOrDiE)
 * https://github.com/manu-urba
 * 
 * This file is part of the Chat Mentions SourceMod plugin.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <regex>
#include <chat-processor>
#include <autoexecconfig>
#include <sdktools>

#pragma semicolon 1

#define TARGET_ERROR_MULTIPLE -7

public Plugin myinfo = {
	name = "Chat Mentions", 
	author = "FrAgOrDiE", 
	description = "Source plugin which allows player to mention nicknames in the chat", 
	version = "1.0", 
	url = "https://github.com/manu-urba"
};

ConVar cvar_sMentionColor;
ConVar cvar_sMentionSound;
ConVar cvar_bMentionShowAtSingle;
ConVar cvar_bMentionShowAtMultiple;

Handle g_Forward_OnPlayerMentioned;

public void OnPluginStart() {
	AutoExecConfig_SetFile("Chat-Mentions");
	cvar_sMentionColor = AutoExecConfig_CreateConVar("sm_chatmentions_color", "{green}", "Color prefix to use for mentioned name in chat", FCVAR_NOTIFY);
	cvar_sMentionSound = AutoExecConfig_CreateConVar("sm_chatmentions_sound", "Chat-Mentions/mention.wav", "Color prefix to use for mentioned name in chat", FCVAR_NOTIFY);
	cvar_bMentionShowAtSingle = AutoExecConfig_CreateConVar("sm_chatmentions_show_at_on_single_target", "0", "Show \"@\" sign before single player name mention", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_bMentionShowAtMultiple = AutoExecConfig_CreateConVar("sm_chatmentions_show_at_on_multiple_target", "1", "Show \"@\" sign before multiple targeting eg. @all, @t, @ct", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("chat_mentions");
	g_Forward_OnPlayerMentioned = CreateGlobalForward("Mentions_OnPlayerMentioned", ET_Ignore, Param_Cell);
}

public void OnMapStart() {
	char sSound[PLATFORM_MAX_PATH];
	cvar_sMentionSound.GetString(sSound, sizeof(sSound));
	
	if (strlen(sSound) > 0) {
		PrecacheSound(sSound);
		Format(sSound, sizeof(sSound), "sound/%s", sSound);
		AddFileToDownloadsTable(sSound);
	}
}

public Action CP_OnChatMessage(int & author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool & processcolors, bool & removecolors) {
	char sError[256];
	RegexError hRegexErr;
	Regex hRegex = new Regex("@(.[^@]*)", PCRE_CASELESS, sError, sizeof(sError), hRegexErr);
	
	if (hRegex == null) {
		LogError("Regex error(%i): %s", hRegexErr, sError);
		return Plugin_Continue;
	}
	
	int iMatches = hRegex.MatchAll(message, hRegexErr);
	
	if (iMatches <= 0) {
		if (iMatches == -1) LogError("Regex matching error %i", hRegexErr);
		
		delete hRegex;
		return Plugin_Continue;
	}
	
	char sSubString[MAX_NAME_LENGTH];
	char sTargetName[MAX_NAME_LENGTH];
	int iTarget[MAXPLAYERS + 1];
	bool tn_is_ml;
	bool bIsTarget[MAXPLAYERS + 1];
	
	for (int i = 0; i < iMatches; ++i) {
		hRegex.GetSubString(0, sSubString, sizeof(sSubString), i);
		TrimString(sSubString);
		
		strcopy(sSubString, sizeof(sSubString), sSubString[1]);
		
		char sPart[2][MAX_NAME_LENGTH];
		ExplodeString(sSubString, " ", sPart, sizeof(sPart), sizeof(sPart[]), true);
		char sTestMultiple[64];
		Format(sTestMultiple, sizeof(sTestMultiple), "@%s", sPart[0]);
		int cTarget = ProcessTargetString(sTestMultiple, author, iTarget, sizeof(iTarget), COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), tn_is_ml);
		if (cTarget <= 0) {
			cTarget = ProcessTargetString(sSubString, author, iTarget, sizeof(iTarget), COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), tn_is_ml);
			if (cTarget <= 0) {
				int iSpace;
				while ((iSpace = FindCharInString(sSubString, ' ', true)) != -1) {
					sSubString[iSpace] = '\0';
					cTarget = ProcessTargetString(sSubString, author, iTarget, sizeof(iTarget), COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), tn_is_ml);
					if (cTarget > 0) break;
				}
			}
			
			/*if (cTarget <= 0) {
				if (cTarget == TARGET_ERROR_MULTIPLE) LogMessage("Multiple targets");
				continue;
			}*/
		}
		
		char sFind[MAX_NAME_LENGTH + 16], sReplace[MAX_NAME_LENGTH + 16], sColor[32];
		cvar_sMentionColor.GetString(sColor, sizeof(sColor));
		Format(sFind, sizeof(sFind), "@%s", sSubString);
		if (cTarget == 1) {
			char sName[MAX_NAME_LENGTH];
			GetClientName(iTarget[0], sName, sizeof(sName));
			if (StrContains(sName, "@") != -1) {
				delete hRegex;
				return Plugin_Changed;
			}
			strcopy(sTargetName, sizeof(sTargetName), sName);
			Format(sReplace, sizeof(sReplace), "%s%s%s{default}", sColor, cvar_bMentionShowAtSingle.BoolValue ? "@" : "", sName);
		}
		else if (cTarget > 1) Format(sReplace, sizeof(sReplace), "%s%s%s{default} %s", sColor, cvar_bMentionShowAtMultiple.BoolValue ? "@" : "", cvar_bMentionShowAtMultiple.BoolValue ? sPart[0] : sTargetName, sPart[1]);
		
		LogMessage("sSubString: %s", sSubString);
		ReplaceStringEx(message, MAXLENGTH_MESSAGE, sFind, sReplace);
		
		Format(message, MAXLENGTH_MESSAGE, "{default}%s", message);
		
		for (int ix = 0; ix < sizeof(iTarget); ++ix) {
			if (iTarget[ix] == 0) break;
			if (bIsTarget[iTarget[ix]]) continue;
				
			Call_StartForward(g_Forward_OnPlayerMentioned);
			Call_PushCell(iTarget[ix]);
			Call_Finish();
			
			if (IsClientInGame(iTarget[ix]) && !IsFakeClient(iTarget[ix])) {
				static char sSound[PLATFORM_MAX_PATH];
				cvar_sMentionSound.GetString(sSound, sizeof(sSound));
				
				if (strlen(sSound) > 0) EmitSoundToClient(iTarget[ix], sSound);
			}
			bIsTarget[iTarget[ix]] = true;
		}
	}
	
	delete hRegex;
	return Plugin_Changed;
} 
