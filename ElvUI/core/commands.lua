local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local tonumber, type, pairs, select = tonumber, type, pairs, select
local lower, split, format = string.lower, string.split, format
--WoW API / Variables
local EnableAddOn, DisableAllAddOns = EnableAddOn, DisableAllAddOns
local SetCVar = SetCVar
local ReloadUI = ReloadUI
local GuildControlGetNumRanks = GuildControlGetNumRanks
local GuildControlGetRankName = GuildControlGetRankName
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local GetGuildRosterLastOnline = GetGuildRosterLastOnline
local GuildUninvite = GuildUninvite
local SendChatMessage = SendChatMessage
local debugprofilestop = debugprofilestop
local UpdateAddOnCPUUsage, GetAddOnCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage
local ResetCPUUsage = ResetCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetCVarBool = GetCVarBool

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: Minimap, EGrid, MacroEditBox, HelloKittyLeft

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
	local secs, command = msg:match("^(%S+)%s+(.*)$")
	secs = tonumber(secs)
	if (not secs) or (#command == 0) then
		self:Print("usage: /in <seconds> <command>")
		self:Print("example: /in 1.5 /say hi")
	else
		E:Delay(secs, OnCallback, command)
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
		local name, _, rankIndex, level, _, _, note, officerNote, connected, _, classFileName = GetGuildRosterInfo(i)
		local minLevelx = minLevel

		if classFileName == "DEATHKNIGHT" then
			minLevelx = minLevelx + 55
		end

		if not connected then
			local years, months, days = GetGuildRosterLastOnline(i)
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

local toggleMode, debugTimer = false, 0;
function E:GetCPUImpact()
	if not GetCVarBool("scriptProfile") then
		E:Print("For `/cpuimpact` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.")
		return
	end

	if(not toggleMode) then
		ResetCPUUsage();
		toggleMode, num_frames, debugTimer = true, 0, debugprofilestop();
		self:Print("CPU Impact being calculated, type /cpuimpact to get results when you are ready.");
		f:Show();
	else
		f:Hide();
		local ms_passed = debugprofilestop() - debugTimer;
		UpdateAddOnCPUUsage();

		local per, passed = ((num_frames == 0 and 0) or (GetAddOnCPUUsage("ElvUI") / num_frames)), ((num_frames == 0 and 0) or (ms_passed / num_frames));
		self:Print("Consumed "..(per and per > 0 and format("%.3f", per) or 0).."ms per frame. Each frame took "..(passed and passed > 0 and format("%.3f", passed) or 0).."ms to render.");
		toggleMode = false;
	end
end

local BLIZZARD_ADDONS = {
	"Blizzard_AchievementUI",
	"Blizzard_AdventureMap",
	"Blizzard_ArchaeologyUI",
	"Blizzard_ArenaUI",
	"Blizzard_ArtifactUI",
	"Blizzard_AuctionUI",
	"Blizzard_AuthChallengeUI",
	"Blizzard_BarbershopUI",
	"Blizzard_BattlefieldMinimap",
	"Blizzard_BindingUI",
	"Blizzard_BlackMarketUI",
	"Blizzard_BoostTutorial",
	"Blizzard_Calendar",
	"Blizzard_ChallengesUI",
	"Blizzard_ClassTrial",
	"Blizzard_ClientSavedVariables",
	"Blizzard_Collections",
	"Blizzard_CombatLog",
	"Blizzard_CombatText",
	"Blizzard_CompactRaidFrames",
	"Blizzard_CUFProfiles",
	"Blizzard_DeathRecap",
	"Blizzard_DebugTools",
	"Blizzard_EncounterJournal",
	"Blizzard_FlightMap",
	"Blizzard_GarrisonTemplates",
	"Blizzard_GarrisonUI",
	"Blizzard_GlyphUI",
	"Blizzard_GMChatUI",
	"Blizzard_GMSurveyUI",
	"Blizzard_GuildBankUI",
	"Blizzard_GuildControlUI",
	"Blizzard_GuildUI",
	"Blizzard_InspectUI",
	"Blizzard_ItemSocketingUI",
	"Blizzard_ItemUpgradeUI",
	"Blizzard_LookingForGuildUI",
	"Blizzard_MacroUI",
	"Blizzard_MapCanvas",
	"Blizzard_MovePad",
	"Blizzard_NamePlates",
	"Blizzard_ObjectiveTracker",
	"Blizzard_ObliterumUI",
	"Blizzard_OrderHallUI",
	"Blizzard_PetBattleUI",
	"Blizzard_PVPUI",
	"Blizzard_QuestChoice",
	"Blizzard_RaidUI",
	"Blizzard_SecureTransferUI",
	"Blizzard_SharedMapDataProviders",
	"Blizzard_SocialUI",
	"Blizzard_StoreUI",
	"Blizzard_TalentUI",
	"Blizzard_TalkingHeadUI",
	"Blizzard_TimeManager",
	"Blizzard_TokenUI",
	"Blizzard_TradeSkillUI",
	"Blizzard_TrainerUI",
	"Blizzard_Tutorial",
	"Blizzard_TutorialTemplates",
	"Blizzard_VoidStorageUI",
	"Blizzard_WowTokenUI",
}
function E:EnableBlizzardAddOns()
	for _, addon in pairs(BLIZZARD_ADDONS) do
		local reason = select(5, GetAddOnInfo(addon))
		if reason == "DISABLED" then
			EnableAddOn(addon)
			E:Print("The following addon was re-enabled:", addon)
		end
	end
end

function E:LoadCommands()
	self:RegisterChatCommand("in", "DelayScriptCall")
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	self:RegisterChatCommand("cpuimpact", "GetCPUImpact")

	self:RegisterChatCommand("cpuusage", "GetTopCPUFunc")
	-- args: module, showall, delay, minCalls
	-- Example1: /cpuusage all
	-- Example2: /cpuusage Bags true
	-- Example3: /cpuusage UnitFrames nil 50 25
	-- Note: showall, delay, and minCalls will default if not set
	-- arg1 can be "all" this will scan all registered modules!

	self:RegisterChatCommand("bgstats", "BGStats")
	self:RegisterChatCommand("hellokitty", "HelloKittyToggle")
	self:RegisterChatCommand("hellokittyfix", "HelloKittyFix")
	self:RegisterChatCommand("harlemshake", "HarlemShakeToggle")
	self:RegisterChatCommand("luaerror", "LuaError")
	self:RegisterChatCommand("egrid", "Grid")
	self:RegisterChatCommand("moveui", "ToggleConfigMode")
	self:RegisterChatCommand("resetui", "ResetUI")
	self:RegisterChatCommand("cleanguild", "MassGuildKick")
	self:RegisterChatCommand("enableblizzard", "EnableBlizzardAddOns")
	self:RegisterChatCommand("estatus", "ShowStatusReport")
	-- self:RegisterChatCommand("aprilfools", "") --Don't need this until next april fools

	if E.private.actionbar.enable then
		local AB = E:GetModule("ActionBars")
		self:RegisterChatCommand("kb", AB.ActivateBindMode)
	end
end
