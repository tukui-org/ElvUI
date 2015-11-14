local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local _G = _G
local tonumber, type, pairs, select = tonumber, type, pairs, select
local format, lower, split = string.format, string.lower, string.split
--WoW API / Variables
local InCombatLockdown = InCombatLockdown
local UIFrameFadeOut, UIFrameFadeIn = UIFrameFadeOut, UIFrameFadeIn
local EnableAddOn, DisableAllAddOns = EnableAddOn, DisableAllAddOns
local SetCVar = SetCVar
local ReloadUI = ReloadUI
local GuildControlGetNumRanks = GuildControlGetNumRanks
local GuildControlGetRankName = GuildControlGetRankName
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local GetGuildRosterLastOnline = GetGuildRosterLastOnline
local GuildUninvite = GuildUninvite
local SendChatMessage = SendChatMessage
local debugprofilestart, debugprofilestop = debugprofilestart, debugprofilestop
local UpdateAddOnCPUUsage, GetAddOnCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage
local ResetCPUUsage = ResetCPUUsage
local GetAddOnInfo = GetAddOnInfo
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: FarmMode, Minimap, FarmModeMap, EGrid, MacroEditBox, HelloKittyLeft


function FarmMode()
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT); return; end
	if E.private.general.minimap.enable ~= true then return; end
	if Minimap:IsShown() then
		UIFrameFadeOut(Minimap, 0.3)
		UIFrameFadeIn(FarmModeMap, 0.3)
		Minimap.fadeInfo.finishedFunc = function() Minimap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
		FarmModeMap.enabled = true
	else
		UIFrameFadeOut(FarmModeMap, 0.3)
		UIFrameFadeIn(Minimap, 0.3)
		FarmModeMap.fadeInfo.finishedFunc = function() FarmModeMap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
		FarmModeMap.enabled = false
	end
end

function E:FarmMode(msg)
	if E.private.general.minimap.enable ~= true then return; end
	if msg and type(tonumber(msg))=="number" and tonumber(msg) <= 500 and tonumber(msg) >= 20 and not InCombatLockdown() then
		E.db.farmSize = tonumber(msg)
		FarmModeMap:Size(tonumber(msg))
	end

	FarmMode()
end

function E:Grid(msg)
	if msg and type(tonumber(msg))=="number" and tonumber(msg) <= 256 and tonumber(msg) >= 4 then
		E.db.gridSize = msg
		E:Grid_Show()
	else
		if EGrid then
			E:Grid_Hide()
		else
			E:Grid_Show()
		end
	end
end

function E:LuaError(msg)
	msg = lower(msg)
	if (msg == 'on') then
		DisableAllAddOns()
		EnableAddOn("ElvUI");
		EnableAddOn("ElvUI_Config");
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif (msg == 'off') then
		SetCVar("scriptErrors", 0)
		E:Print("Lua errors off.")
	else
		E:Print("/luaerror on - /luaerror off")
	end
end

function E:BGStats()
	local DT = E:GetModule('DataTexts')
	DT.ForceHideBGStats = nil;
	DT:LoadDataTexts()

	E:Print(L["Battleground datatexts will now show again if you are inside a battleground."])
end

local function OnCallback(command)
	MacroEditBox:GetScript("OnEvent")(MacroEditBox, "EXECUTE_CHAT_LINE", command)
end

function E:DelayScriptCall(msg)
	local secs, command = msg:match("^([^%s]+)%s+(.*)$")
	secs = tonumber(secs)
	if (not secs) or (#command == 0) then
		self:Print("usage: /in <seconds> <command>")
		self:Print("example: /in 1.5 /say hi")
	else
		E:ScheduleTimer(OnCallback, secs, command)
	end
end

function E:MassGuildKick(msg)
	local minLevel, minDays, minRankIndex = split(',', msg)
	minRankIndex = tonumber(minRankIndex);
	minLevel = tonumber(minLevel);
	minDays = tonumber(minDays);

	if not minLevel or not minDays then
		E:Print("Usage: /cleanguild <minLevel>, <minDays>, [<minRankIndex>]");
		return;
	end

	if minDays > 31 then
		E:Print("Maximum days value must be below 32.");
		return;
	end

	if not minRankIndex then minRankIndex = GuildControlGetNumRanks() - 1 end

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, level, class, _, note, officerNote, connected, _, class = GetGuildRosterInfo(i)
		local minLevelx = minLevel

		if class == "DEATHKNIGHT" then
			minLevelx = minLevelx + 55
		end

		if not connected then
			local years, months, days, hours = GetGuildRosterLastOnline(i)
			if days ~= nil and ((years > 0 or months > 0 or days >= minDays) and rankIndex >= minRankIndex) and note ~= nil and officerNote ~= nil and (level <= minLevelx) then
				GuildUninvite(name)
			end
		end
	end

	SendChatMessage("Guild Cleanup Results: Removed all guild members below rank "..GuildControlGetRankName(minRankIndex)..", that have a minimal level of "..minLevel..", and have not been online for at least: "..minDays.." days.", "GUILD")
end

local num_frames = 0
local function OnUpdate()
	num_frames = num_frames + 1
end
local f = CreateFrame("Frame")
f:Hide()
f:SetScript("OnUpdate", OnUpdate)

local toggleMode = false
function E:GetCPUImpact()
	if(not toggleMode) then
		ResetCPUUsage()
		num_frames = 0;
		debugprofilestart()
		f:Show()
		toggleMode = true
		self:Print("CPU Impact being calculated, type /cpuimpact to get results when you are ready.")
	else
		f:Hide()
		local ms_passed = debugprofilestop()
		UpdateAddOnCPUUsage()

		self:Print("Consumed "..(GetAddOnCPUUsage("ElvUI") / num_frames).." milliseconds per frame. Each frame took "..(ms_passed / num_frames).." to render.");
		toggleMode = false
	end
end

local BLIZZARD_ADDONS = {
    "Blizzard_AchievementUI",
    "Blizzard_ArchaeologyUI",
    "Blizzard_ArenaUI",
    "Blizzard_AuctionUI",
    "Blizzard_AuthChallengeUI",
    "Blizzard_BarbershopUI",
    "Blizzard_BattlefieldMinimap",
    "Blizzard_BindingUI",
    "Blizzard_BlackMarketUI",
    "Blizzard_Calendar",
    "Blizzard_ChallengesUI",
    "Blizzard_ClientSavedVariables",
    "Blizzard_CombatLog",
    "Blizzard_CombatText",
    "Blizzard_CompactRaidFrames",
    "Blizzard_CUFProfiles",
    "Blizzard_DebugTools",
    "Blizzard_EncounterJournal",
    "Blizzard_GarrisonUI",
    "Blizzard_GlyphUI",
    "Blizzard_GMChatUI",
    "Blizzard_GMSurveyUI",
    "Blizzard_GuildBankUI",
    "Blizzard_GuildControlUI",
    "Blizzard_GuildUI",
    "Blizzard_InspectUI",
    "Blizzard_ItemAlterationUI",
    "Blizzard_ItemSocketingUI",
    "Blizzard_ItemUpgradeUI",
    "Blizzard_LookingForGuildUI",
    "Blizzard_MacroUI",
    "Blizzard_MovePad",
    "Blizzard_ObjectiveTracker",
    "Blizzard_PetBattleUI",
    "Blizzard_PetJournal",
    "Blizzard_PVPUI",
    "Blizzard_QuestChoice",
    "Blizzard_RaidUI",
    "Blizzard_StoreUI",
    "Blizzard_TalentUI",
    "Blizzard_TimeManager",
    "Blizzard_TokenUI",
    "Blizzard_TradeSkillUI",
    "Blizzard_TrainerUI",
    "Blizzard_VoidStorageUI",
}
function E:EnableBlizzardAddOns()
	for _, addon in pairs(BLIZZARD_ADDONS) do
		local reason = select(5, GetAddOnInfo(addon))
		if reason == "DISABLED" then
			EnableAddOn(addon)
			E:Print("The following addon was re-enabled: "..addon)
		end
	end
end

function E:LoadCommands()
	self:RegisterChatCommand("in", "DelayScriptCall")
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	self:RegisterChatCommand('cpuimpact', 'GetCPUImpact')
	self:RegisterChatCommand('cpuusage', 'GetTopCPUFunc')
	self:RegisterChatCommand('bgstats', 'BGStats')
	self:RegisterChatCommand('hellokitty', 'HelloKittyToggle')
	self:RegisterChatCommand('hellokittyfix', 'HelloKittyFix')
	self:RegisterChatCommand('harlemshake', 'HarlemShakeToggle')
	self:RegisterChatCommand('luaerror', 'LuaError')
	self:RegisterChatCommand('egrid', 'Grid')
	self:RegisterChatCommand("moveui", "ToggleConfigMode")
	self:RegisterChatCommand("resetui", "ResetUI")
	self:RegisterChatCommand('farmmode', 'FarmMode')
	self:RegisterChatCommand('cleanguild', 'MassGuildKick')
	self:RegisterChatCommand('enableblizzard', 'EnableBlizzardAddOns')
	if E.ActionBars then
		self:RegisterChatCommand('kb', E.ActionBars.ActivateBindMode)
	end
end