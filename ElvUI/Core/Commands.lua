local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local _G = _G
local tonumber, type, pairs, select = tonumber, type, pairs, select
local lower, split, format, wipe, next, print = strlower, strsplit, format, wipe, next, print

local debugprofilestop = debugprofilestop
local EnableAddOn = EnableAddOn
local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetNumAddOns = GetNumAddOns
local GetCVarBool = GetCVarBool
local DisableAddOn = DisableAddOn
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildRosterLastOnline = GetGuildRosterLastOnline
local GetNumGuildMembers = GetNumGuildMembers
local GuildControlGetNumRanks = GuildControlGetNumRanks
local GuildControlGetRankName = GuildControlGetRankName
local GuildUninvite = GuildUninvite
local ResetCPUUsage = ResetCPUUsage
local SendChatMessage = SendChatMessage
local ReloadUI = ReloadUI
local SetCVar = SetCVar
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
-- GLOBALS: ElvUIGrid, ElvDB

function E:Grid(msg)
	msg = msg and tonumber(msg)
	if type(msg) == 'number' and (msg <= 256 and msg >= 4) then
		E.db.gridSize = msg
		E:Grid_Show()
	elseif ElvUIGrid and ElvUIGrid:IsShown() then
		E:Grid_Hide()
	else
		E:Grid_Show()
	end
end

function E:LuaError(msg)
	local switch = lower(msg)
	if switch == 'on' or switch == '1' then
		for i=1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if name ~= 'ElvUI' and name ~= 'ElvUI_OptionsUI' and E:IsAddOnEnabled(name) then
				DisableAddOn(name, E.myname)
				ElvDB.LuaErrorDisabledAddOns[name] = i
			end
		end

		SetCVar('scriptErrors', 1)
		ReloadUI()
	elseif switch == 'off' or switch == '0' then
		if switch == 'off' then
			SetCVar('scriptErrors', 0)
			E:Print('Lua errors off.')
		end

		if next(ElvDB.LuaErrorDisabledAddOns) then
			for name in pairs(ElvDB.LuaErrorDisabledAddOns) do
				EnableAddOn(name, E.myname)
			end

			wipe(ElvDB.LuaErrorDisabledAddOns)
			ReloadUI()
		end
	else
		E:Print('/luaerror on - /luaerror off')
	end
end

local function OnCallback(command)
	_G.MacroEditBox:GetScript('OnEvent')(_G.MacroEditBox, 'EXECUTE_CHAT_LINE', command)
end

function E:DelayScriptCall(msg)
	local secs, command = msg:match('^(%S+)%s+(.*)$')
	secs = tonumber(secs)
	if not secs or (#command == 0) then
		self:Print('usage: /in <seconds> <command>')
		self:Print('example: /in 1.5 /say hi')
	else
		E:Delay(secs, OnCallback, command)
	end
end

-- make this a locale later?
local MassKickMessage = 'Guild Cleanup Results: Removed all guild members below rank %s, that have a minimal level of %s, and have not been online for at least: %s days.'
function E:MassGuildKick(msg)
	local minLevel, minDays, minRankIndex = split(',', msg)
	minRankIndex = tonumber(minRankIndex)
	minLevel = tonumber(minLevel)
	minDays = tonumber(minDays)

	if not minLevel or not minDays then
		E:Print('Usage: /cleanguild <minLevel>, <minDays>, [<minRankIndex>]')
		return
	end

	if minDays > 31 then
		E:Print('Maximum days value must be below 32.')
		return
	end

	if not minRankIndex then
		minRankIndex = GuildControlGetNumRanks() - 1
	end

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, level, _, _, note, officerNote, connected, _, classFileName = GetGuildRosterInfo(i)
		local minLevelx = minLevel

		if classFileName == 'DEATHKNIGHT' then
			minLevelx = minLevelx + 55
		end

		if not connected then
			local years, months, days = GetGuildRosterLastOnline(i)
			if days ~= nil and ((years > 0 or months > 0 or days >= minDays) and rankIndex >= minRankIndex)
			and note ~= nil and officerNote ~= nil and (level <= minLevelx) then
				GuildUninvite(name)
			end
		end
	end

	SendChatMessage(format(MassKickMessage, GuildControlGetRankName(minRankIndex), minLevel, minDays), 'GUILD')
end

local num_frames = 0
local function OnUpdate()
	num_frames = num_frames + 1
end
local f = CreateFrame('Frame')
f:Hide()
f:SetScript('OnUpdate', OnUpdate)

local toggleMode, debugTimer, cpuImpactMessage = false, 0, 'Consumed %sms per frame. Each frame took %sms to render.'
function E:GetCPUImpact()
	if not GetCVarBool('scriptProfile') then
		E:Print('For `/cpuimpact` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.')
		return
	end

	if not toggleMode then
		ResetCPUUsage()
		toggleMode, num_frames, debugTimer = true, 0, debugprofilestop()
		self:Print('CPU Impact being calculated, type /cpuimpact to get results when you are ready.')
		f:Show()
	else
		f:Hide()
		local ms_passed = debugprofilestop() - debugTimer
		UpdateAddOnCPUUsage()

		local per, passed = ((num_frames == 0 and 0) or (GetAddOnCPUUsage('ElvUI') / num_frames)), ((num_frames == 0 and 0) or (ms_passed / num_frames))
		self:Print(format(cpuImpactMessage, per and per > 0 and format('%.3f', per) or 0, passed and passed > 0 and format('%.3f', passed) or 0))
		toggleMode = false
	end
end

function E:EHelp()
	print(L["EHELP_COMMANDS"])
end

local BLIZZARD_ADDONS = {
	'Blizzard_APIDocumentation',
	'Blizzard_AchievementUI',
	'Blizzard_AdventureMap',
	'Blizzard_AlliedRacesUI',
	'Blizzard_AnimaDiversionUI',
	'Blizzard_ArchaeologyUI',
	'Blizzard_ArdenwealdGardening',
	'Blizzard_ArenaUI',
	'Blizzard_ArtifactUI',
	'Blizzard_AuctionHouseUI',
	'Blizzard_AuthChallengeUI',
	'Blizzard_AzeriteEssenceUI',
	'Blizzard_AzeriteRespecUI',
	'Blizzard_AzeriteUI',
	'Blizzard_BarbershopUI',
	'Blizzard_BattlefieldMap',
	'Blizzard_BindingUI',
	'Blizzard_BlackMarketUI',
	'Blizzard_BoostTutorial',
	'Blizzard_CUFProfiles',
	'Blizzard_Calendar',
	'Blizzard_ChallengesUI',
	'Blizzard_Channels',
	'Blizzard_CharacterCreate',
	'Blizzard_CharacterCustomize',
	'Blizzard_ChromieTimeUI',
	'Blizzard_ClassTrial',
	'Blizzard_ClientSavedVariables',
	'Blizzard_Collections',
	'Blizzard_CombatLog',
	'Blizzard_CombatText',
	'Blizzard_Commentator',
	'Blizzard_Communities',
	'Blizzard_CompactRaidFrames',
	'Blizzard_Console',
	'Blizzard_Contribution',
	'Blizzard_CovenantCallings',
	'Blizzard_CovenantPreviewUI',
	'Blizzard_CovenantRenown',
	'Blizzard_CovenantSanctum',
	'Blizzard_CovenantToasts',
	'Blizzard_DeathRecap',
	'Blizzard_DebugTools',
	'Blizzard_Deprecated',
	'Blizzard_EncounterJournal',
	'Blizzard_EventTrace',
	'Blizzard_FlightMap',
	'Blizzard_FrameEffects',
	'Blizzard_GMChatUI',
	'Blizzard_GarrisonTemplates',
	'Blizzard_GarrisonUI',
	'Blizzard_GuildBankUI',
	'Blizzard_GuildControlUI',
	'Blizzard_GuildRecruitmentUI',
	'Blizzard_GuildUI',
	'Blizzard_HybridMinimap',
	'Blizzard_InspectUI',
	'Blizzard_IslandsPartyPoseUI',
	'Blizzard_IslandsQueueUI',
	'Blizzard_ItemInteractionUI',
	'Blizzard_ItemSocketingUI',
	'Blizzard_ItemUpgradeUI',
	'Blizzard_Kiosk',
	'Blizzard_LandingSoulbinds',
	'Blizzard_LookingForGuildUI',
	'Blizzard_MacroUI',
	'Blizzard_MapCanvas',
	'Blizzard_MawBuffs',
	'Blizzard_MoneyReceipt',
	'Blizzard_MovePad',
	'Blizzard_NamePlates',
	'Blizzard_NewPlayerExperience',
	'Blizzard_NewPlayerExperienceGuide',
	'Blizzard_ObjectiveTracker',
	'Blizzard_ObliterumUI',
	'Blizzard_OrderHallUI',
	'Blizzard_PTRFeedback',
	'Blizzard_PTRFeedbackGlue',
	'Blizzard_PVPMatch',
	'Blizzard_PVPUI',
	'Blizzard_PartyPoseUI',
	'Blizzard_PetBattleUI',
	'Blizzard_PlayerChoiceUI',
	'Blizzard_QuestNavigation',
	'Blizzard_RaidUI',
	'Blizzard_RuneforgeUI',
	'Blizzard_ScrappingMachineUI',
	'Blizzard_SecureTransferUI',
	'Blizzard_SharedMapDataProviders',
	'Blizzard_SocialUI',
	'Blizzard_Soulbinds',
	'Blizzard_StoreUI',
	'Blizzard_SubscriptionInterstitialUI',
	'Blizzard_TalentUI',
	'Blizzard_TalkingHeadUI',
	'Blizzard_TimeManager',
	'Blizzard_TokenUI',
	'Blizzard_TorghastLevelPicker',
	'Blizzard_TradeSkillUI',
	'Blizzard_TrainerUI',
	'Blizzard_Tutorial',
	'Blizzard_TutorialTemplates',
	'Blizzard_UIWidgets',
	'Blizzard_VoidStorageUI',
	'Blizzard_WarfrontsPartyPoseUI',
	'Blizzard_WeeklyRewards',
	'Blizzard_WorldMap',
	'Blizzard_WowTokenUI'
}

function E:EnableBlizzardAddOns()
	for _, addon in pairs(BLIZZARD_ADDONS) do
		local reason = select(5, GetAddOnInfo(addon))
		if reason == 'DISABLED' then
			EnableAddOn(addon)
			E:Print('The following addon was re-enabled:', addon)
		end
	end
end

do -- Blizzard Commands
	local SlashCmdList = _G.SlashCmdList

	-- DeveloperConsole (without starting with `-console`)
	if not SlashCmdList.DEVCON then
		local DevConsole = _G.DeveloperConsole
		if DevConsole then
			_G.SLASH_DEVCON1 = '/devcon'
			SlashCmdList.DEVCON = function()
				DevConsole:Toggle()
			end
		end
	end

	-- ReloadUI: /rl, /reloadui, /reload  NOTE: /reload is from SLASH_RELOAD
	if not SlashCmdList.RELOADUI then
		_G.SLASH_RELOADUI1 = '/rl'
		_G.SLASH_RELOADUI2 = '/reloadui'
		SlashCmdList.RELOADUI = _G.ReloadUI
	end
end

function E:DBConvertProfile()
	E.db.dbConverted = nil
	E:DBConversions()
	ReloadUI()
end

function E:LoadCommands()
	self:RegisterChatCommand('in', 'DelayScriptCall')
	self:RegisterChatCommand('ec', 'ToggleOptionsUI')
	self:RegisterChatCommand('elvui', 'ToggleOptionsUI')
	self:RegisterChatCommand('cpuimpact', 'GetCPUImpact')
	self:RegisterChatCommand('cpuusage', 'GetTopCPUFunc')
	-- cpuusage args: module, showall, delay, minCalls
	--- Example1: /cpuusage all
	--- Example2: /cpuusage Bags true
	--- Example3: /cpuusage UnitFrames nil 50 25
	---- Note: showall, delay, and minCalls will default if not set
	---- arg1 can be 'all' this will scan all registered modules!

	self:RegisterChatCommand('hdt', DT.HyperDT)
	self:RegisterChatCommand('bgstats', DT.ToggleBattleStats)
	self:RegisterChatCommand('hellokitty', 'HelloKittyToggle')
	self:RegisterChatCommand('hellokittyfix', 'HelloKittyFix')
	self:RegisterChatCommand('harlemshake', 'HarlemShakeToggle')
	self:RegisterChatCommand('luaerror', 'LuaError')
	self:RegisterChatCommand('egrid', 'Grid')
	self:RegisterChatCommand('moveui', 'ToggleMoveMode')
	self:RegisterChatCommand('resetui', 'ResetUI')
	self:RegisterChatCommand('cleanguild', 'MassGuildKick')
	self:RegisterChatCommand('enableblizzard', 'EnableBlizzardAddOns')
	self:RegisterChatCommand('estatus', 'ShowStatusReport')
	self:RegisterChatCommand('ehelp', 'EHelp')
	self:RegisterChatCommand('ecommands', 'EHelp')
	self:RegisterChatCommand('efixdb', 'DBConvertProfile')
	-- self:RegisterChatCommand('aprilfools', '') --Don't need this until next april fools

	if E.private.actionbar.enable then
		self:RegisterChatCommand('kb', AB.ActivateBindMode)
	end
end
