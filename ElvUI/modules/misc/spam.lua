-- This file is used for enGB or enUS client only.
-- translate or do anything you want if you want to 
-- use this feature on others clients.
local ElvCF = ElvCF
local ElvDB = ElvDB

if ElvDB.client ~= "enUS" and ElvDB.client ~= "enGB" then return end

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
			if arg2 == ElvDB.myname then return end
			if (strfind(arg1, SpamList)) then
				return true
			end
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TRADE_FILTER)

----------------------------------------------------------------------------------
-- Hide annoying chat text when talent switch.
----------------------------------------------------------------------------------

local function SPELL_FILTER(self, event, arg1)
    if (strfind(arg1,"You have unlearned") or strfind(arg1,"You have learned a new spell:") or strfind(arg1,"You have learned a new ability:")) and ElvDB.level == MAX_PLAYER_LEVEL then
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

----------------------------------------------------------------------------------
-- Report AFKer's to RaidWarning
----------------------------------------------------------------------------------

local function SPELL_FILTER(self, event, arg1)
    if strfind(arg1,"is not ready") or strfind(arg1,"The following players are Away") then
        SendChatMessage(arg1, "RAID_WARNING", nil ,nil)
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)


----------------------------------------------------------------------------------
-- Only enabling this for me because i get asked too much
----------------------------------------------------------------------------------
if ElvDB.myname == "Elv" then

	local waitTable = {};
	local waitFrame = nil;
	local whispered = {}
	local function whisper_wait(delay, func, ...)
		if(type(delay)~="number" or type(func)~="function") then
			return false;
		end
		if(waitFrame == nil) then
			waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
			waitFrame:SetScript("onUpdate",function (self,elapse)
				local count = #waitTable;
				local i = 1;
				while(i<=count) do
					local waitRecord = tremove(waitTable,i);
					local d = tremove(waitRecord,1);
					local f = tremove(waitRecord,1);
					local p = tremove(waitRecord,1);
					if(d>elapse) then
					  tinsert(waitTable,i,{d-elapse,f,p});
					  i = i + 1;
					else
					  count = count - 1;
					  f(unpack(p));
					end
				end
			end)
		end
		tinsert(waitTable,{delay,func,{...}})
		return true
	end

	
	local function NOOB_FILTER(self, event, arg1, arg2)
		if strfind(arg1, "mount") then
			for i, name in pairs(whispered) do if name == tostring(arg2) then return end end -- dont reply to the same person more than once
			whisper_wait(5, SendChatMessage, "I got this in Desolace it was a world drop, you need to open up some crates near the shore. It only works for the first one you open per day.", "WHISPER", nil, arg2) -- 5 second delay.. more realistic :) 
			
			tinsert(whispered, tostring(arg2))
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", NOOB_FILTER)	
end