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

----------------------------------------------------------------------------------
-- Hide annoying /sleep commands from goldspammer 
-- with their hacks for multiple chars.
----------------------------------------------------------------------------------


local function FUCKYOU_GOLDSPAMMERS(self, event, arg1)
    if strfind(arg1, "falls asleep. Zzzzzzz.") then
		return true
    end
end

local function GOLDSPAM_FILTER()
	if GetMinimapZoneText() == "Valley of Strength" or GetMinimapZoneText() == "Trade District" then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FUCKYOU_GOLDSPAMMERS)
	else
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FUCKYOU_GOLDSPAMMERS)
	end
end

local GOLDSPAM = CreateFrame("Frame")
GOLDSPAM:RegisterEvent("PLAYER_ENTERING_WORLD")
GOLDSPAM:RegisterEvent("ZONE_CHANGED_INDOORS")
GOLDSPAM:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GOLDSPAM:SetScript("OnEvent", GOLDSPAM_FILTER)

if E.myname == "Elv" then
	----------------------------------------------------------------------------------
	-- Trade Chat Stuff
	----------------------------------------------------------------------------------
	local SpamList = {
		";Powerlevel",
		"SusanExpress",
		"recruiting",
		"Discount",
		"discount",
	}

	local function TRADE_FILTER(self, event, arg1, arg2)
		if (SpamList and SpamList[1]) then
			for i, SpamList in pairs(SpamList) do
				if arg2 == E.myname then return end
				if (strfind(arg1, SpamList)) then
					return true
				end
			end
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TRADE_FILTER)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, arg1) 
		if strfind(arg1, 'has been dropped') then 
			RaidNotice_AddMessage( RaidBossEmoteFrame, arg1, ChatTypeInfo["RAID_BOSS_EMOTE"] ); 
		end 
	end)
	
	local function SPELL_FILTER(self, event, arg1)
		if strfind(arg1,"is not ready") or strfind(arg1,"The following players are Away") then
			SendChatMessage(arg1, "RAID_WARNING", nil ,nil)
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)
	
	local whispered = {}
	local responses = {
		"kill monsters on the shore of Desolace until it drops",
		"sorry, i got this account off ebay",
	}
	
	local function NOOB_FILTER(self, event, arg1, arg2)
		if strfind(arg1, " mount") then
			for i, name in pairs(whispered) do if name == tostring(arg2) then return end end -- dont reply to the same person more than once
			E.Delay(6, SendChatMessage, responses[math.random(1, #responses)], "WHISPER", nil, arg2) -- 6 second delay.. more realistic :) 
			
			tinsert(whispered, tostring(arg2))
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", NOOB_FILTER)	
end