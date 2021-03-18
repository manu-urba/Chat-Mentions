#if defined _chat_mentions_included
 #endinput
#endif
#define _chat_mentions_included

forward void Mentions_OnPlayerMentioned(int client);

public SharedPlugin __pl_chat_mentions =
{
	name = "chat_mentions",
	file = "Chat-Mentions.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};