-- always show worldstate behind buffs
WorldStateAlwaysUpFrame:SetFrameStrata("BACKGROUND")
WorldStateAlwaysUpFrame:SetFrameLevel(0)

-- remove uiscale option via blizzard option, users need to set this in the config file
VideoOptionsResolutionPanelUIScaleSlider:Hide()
VideoOptionsResolutionPanelUseUIScale:Hide()

-- tutorial button shit
TukuiDB.Kill(TutorialFrameAlertButton)

-- enable or disable an addon via command
SlashCmdList.DISABLE_ADDON = function(s) DisableAddOn(s) ReloadUI() end
SLASH_DISABLE_ADDON1 = "/disable"
SlashCmdList.ENABLE_ADDON = function(s) EnableAddOn(s) LoadAddOn(s) ReloadUI() end
SLASH_ENABLE_ADDON1 = "/enable"

-- switch to heal layout via a command
local function HEAL()
	DisableAddOn("Tukui_Dps_Layout"); 
	EnableAddOn("Tukui_Heal_Layout"); 
	ReloadUI();
end
SLASH_HEAL1 = "/heal"
SlashCmdList["HEAL"] = HEAL

-- switch to dps layout via a command
local function DPS()
	DisableAddOn("Tukui_Heal_Layout"); 
	EnableAddOn("Tukui_Dps_Layout");
	ReloadUI();
end
SLASH_DPS1 = "/dps"
SlashCmdList["DPS"] = DPS

-- fix combatlog manually when it broke
local function CLFIX()
	CombatLogClearEntries()
end
SLASH_CLFIX1 = "/clfix"
SlashCmdList["CLFIX"] = CLFIX

-- a command to show frame you currently have mouseovered
SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() then
			ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
		end
 
		ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
 
		if x then
			ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if y then
			ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo then
			ChatFrame1:AddMessage("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end

-- enable lua error by command
function SlashCmdList.LUAERROR(msg, editbox)
	if (msg == 'on') then
		SetCVar("scriptErrors", 1)
		-- because sometime we need to /rl to show error.
		ReloadUI()
	elseif (msg == 'off') then
		SetCVar("scriptErrors", 0)
	else
		print("/luaerror on - /luaerror off")
	end
end
SLASH_LUAERROR1 = '/luaerror'

SlashCmdList["GROUPDISBAND"] = function()
		SendChatMessage(tukuilocal.disband, "RAID" or "PARTY")
		if UnitInRaid("player") then
			for i = 1, GetNumRaidMembers() do
				local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
				if online and name ~= TukuiDB.myname then
					UninviteUnit(name)
				end
			end
		else
			for i = MAX_PARTY_MEMBERS, 1, -1 do
				if GetPartyMember(i) then
					UninviteUnit(UnitName("party"..i))
				end
			end
		end
		LeaveParty()
end
SLASH_GROUPDISBAND1 = '/rd'

-- hide emotes from showing in chat when in these areas due to gold spammers
local function CHINESE_FILTER()
	if GetMinimapZoneText() == "Valley of Strength" or GetMinimapZoneText() == "Trade District" then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FUCKYOU_CHINESE)
	else
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FUCKYOU_CHINESE)
	end
end

function FUCKYOU_CHINESE(self, event, ...)
    if strfind(arg1, "falls asleep. Zzzzzzz.") then
	return true
    end
end

local CHINESESPAM = CreateFrame("Frame")
CHINESESPAM:RegisterEvent("PLAYER_ENTERING_WORLD")
CHINESESPAM:RegisterEvent("ZONE_CHANGED_INDOORS")
CHINESESPAM:RegisterEvent("ZONE_CHANGED_NEW_AREA")
CHINESESPAM:SetScript("OnEvent", CHINESE_FILTER)