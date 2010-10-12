-- This file is used for enGB or enUS client only.
-- translate or do anything you want if you want to 
-- use this feature on others clients.

if TukuiDB.client ~= "enUS" and TukuiDB.client ~= "enGB" then return end

----------------------------------------------------------------------------------
-- Hide annoying chat text when talent switch.
----------------------------------------------------------------------------------

function TukuiDB.SPELL_FILTER(self, event, arg1)
    if strfind(arg1,"You have unlearned") or strfind(arg1,"You have learned a new spell:") or strfind(arg1,"You have learned a new ability:") then
        return true
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TukuiDB.SPELL_FILTER)

----------------------------------------------------------------------------------
-- Hide annoying /sleep commands from goldspammer 
-- with their hacks for multiple chars.
----------------------------------------------------------------------------------

local function GOLDSPAM_FILTER()
	if GetMinimapZoneText() == "Valley of Strength" or GetMinimapZoneText() == "Trade District" then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", TukuiDB.FUCKYOU_GOLDSPAMMERS)
	else
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", TukuiDB.FUCKYOU_GOLDSPAMMERS)
	end
end

function TukuiDB.FUCKYOU_GOLDSPAMMERS(self, event, arg1)
    if strfind(arg1, "falls asleep. Zzzzzzz.") then
		return true
    end
end

local GOLDSPAM = CreateFrame("Frame")
GOLDSPAM:RegisterEvent("PLAYER_ENTERING_WORLD")
GOLDSPAM:RegisterEvent("ZONE_CHANGED_INDOORS")
GOLDSPAM:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GOLDSPAM:SetScript("OnEvent", GOLDSPAM_FILTER)



