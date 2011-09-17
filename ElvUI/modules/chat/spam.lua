-- This file is used for enGB or enUS client only.
-- translate or do anything you want if you want to 
-- use this feature on others clients.

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client ~= "enUS" and E.client ~= "enGB" then return end

----------------------------------------------------------------------------------
-- Hide annoying chat text when talent switch.
----------------------------------------------------------------------------------

local function SPELL_FILTER(self, event, arg1)
    if (strfind(arg1,"You have unlearned") or strfind(arg1,"You have learned a new spell:") or strfind(arg1,"You have learned a new ability:")) and E.level == MAX_PLAYER_LEVEL then
        return true
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)

if C.chat.spamFilter ~= true then return end

local authorList = {}
local responseMessage = C.chat.spamResponseMessage
local blackList = {
	'Cheapest Gold',
	'discount code',
}

local function CheckForTabMatch(author)
	for index, chatFrame in pairs(CHAT_FRAMES) do
		local frame = _G[chatFrame]
		if frame and frame.chatTarget == author then
			FCF_Close(frame)
		end
	end
end

local function SPAM_FILTER(self, event, msg, author)	
	--Block the response message from being seen
	if strfind(msg, responseMessage) and event == "CHAT_MSG_WHISPER_INFORM" then
		return true
	end

	for _, spam in pairs(blackList) do
		if strfind(msg, spam) then
			--Don't report the same author more than once per session, abusing the ComplainChat can be bad.
			if responseMessage ~= "" then
				SendChatMessage(responseMessage, 'WHISPER', nil, author)
			end
			
			if not authorList[author] then
				ComplainChat(author, msg)
				authorList[author] = true
			end
			
			if GetCVar("whisperMode") == "popout_and_inline" or GetCVar("whisperMode") == "popout" then
				E.Delay(2, CheckForTabMatch, author)
			end
			
			return true
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", SPAM_FILTER)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", SPAM_FILTER)