local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local _G = _G
local type, pairs, select = type, pairs, select
local strmatch, tonumber, tostring = strmatch, tonumber, tostring
local lower, format, wipe, next, print = strlower, format, wipe, next, print

local debugprofilestop = debugprofilestop
local EnableAddOn = EnableAddOn
local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetNumAddOns = GetNumAddOns
local GetCVarBool = GetCVarBool
local DisableAddOn = DisableAddOn
local ResetCPUUsage = ResetCPUUsage
local GetFunctionCPUUsage = GetFunctionCPUUsage
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
local ReloadUI = ReloadUI
local SetCVar = SetCVar
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
				ElvDB.DisabledAddOns[name] = i
			end
		end

		SetCVar('scriptErrors', 1)
		ReloadUI()
	elseif switch == 'off' or switch == '0' then
		if switch == 'off' then
			SetCVar('scriptErrors', 0)
			E:Print('Lua errors off.')
		end

		if next(ElvDB.DisabledAddOns) then
			for name in pairs(ElvDB.DisabledAddOns) do
				EnableAddOn(name, E.myname)
			end

			wipe(ElvDB.DisabledAddOns)
			ReloadUI()
		end
	else
		E:Print('/edebug on - /edebug off')
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

do
	local num = 0
	local frame = CreateFrame('Frame')
	frame:SetScript('OnUpdate', function() num = num + 1 end)
	frame:Hide()

	local toggle, timer, message = false, 0, 'Consumed %sms per frame. Each frame took %sms to render.'
	function E:GetCPUImpact()
		if not GetCVarBool('scriptProfile') then
			E:Print('For `/cpuimpact` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.')
			return
		end

		if not toggle then
			ResetCPUUsage()
			toggle, num, timer = true, 0, debugprofilestop()
			self:Print('CPU Impact being calculated, type /cpuimpact to get results when you are ready.')
			frame:Show()
		else
			frame:Hide()
			local ms_passed = debugprofilestop() - timer
			UpdateAddOnCPUUsage()

			local per, passed = ((num == 0 and 0) or (GetAddOnCPUUsage('ElvUI') / num)), ((num == 0 and 0) or (ms_passed / num))
			self:Print(format(message, per and per > 0 and format('%.3f', per) or 0, passed and passed > 0 and format('%.3f', passed) or 0))
			toggle = false
		end
	end
end

do
	local CPU_USAGE = {}
	local function CompareCPUDiff(showall, minCalls)
		local greatestUsage, greatestCalls, greatestName, newName, newFunc
		local greatestDiff, lastModule, mod, usage, calls, diff = 0

		for name, oldUsage in pairs(CPU_USAGE) do
			newName, newFunc = strmatch(name, '^([^:]+):(.+)$')
			if not newFunc then
				E:Print('CPU_USAGE:', name, newFunc)
			else
				if newName ~= lastModule then
					mod = E:GetModule(newName, true) or E
					lastModule = newName
				end
				usage, calls = GetFunctionCPUUsage(mod[newFunc], true)
				diff = usage - oldUsage
				if showall and (calls > minCalls) then
					E:Print('Name('..name..')  Calls('..calls..') MS('..(usage or 0)..') Diff('..(diff > 0 and format('%.3f', diff) or 0)..')')
				end
				if (diff > greatestDiff) and calls > minCalls then
					greatestName, greatestUsage, greatestCalls, greatestDiff = name, usage, calls, diff
				end
			end
		end

		if greatestName then
			E:Print(greatestName.. ' had the CPU usage of: '..(greatestUsage > 0 and format('%.3f', greatestUsage) or 0)..'ms. And has been called '.. greatestCalls..' times.')
		else
			E:Print('CPU Usage: No CPU Usage differences found.')
		end

		wipe(CPU_USAGE)
	end

	function E:GetTopCPUFunc(msg)
		if not GetCVarBool('scriptProfile') then
			E:Print('For `/cpuusage` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.')
			return
		end

		local module, showall, delay, minCalls = strmatch(msg, '^(%S+)%s*(%S*)%s*(%S*)%s*(.*)$')
		local checkCore, mod = (not module or module == '') and 'E'

		showall = (showall == 'true' and true) or false
		delay = (delay == 'nil' and nil) or tonumber(delay) or 5
		minCalls = (minCalls == 'nil' and nil) or tonumber(minCalls) or 15

		wipe(CPU_USAGE)
		if module == 'all' then
			for moduName, modu in pairs(self.modules) do
				for funcName, func in pairs(modu) do
					if funcName ~= 'GetModule' and type(func) == 'function' then
						CPU_USAGE[moduName..':'..funcName] = GetFunctionCPUUsage(func, true)
					end
				end
			end
		else
			if not checkCore then
				mod = self:GetModule(module, true)
				if not mod then
					self:Print(module..' not found, falling back to checking core.')
					mod, checkCore = self, 'E'
				end
			else
				mod = self
			end
			for name, func in pairs(mod) do
				if (name ~= 'GetModule') and type(func) == 'function' then
					CPU_USAGE[(checkCore or module)..':'..name] = GetFunctionCPUUsage(func, true)
				end
			end
		end

		self:Delay(delay, CompareCPUDiff, showall, minCalls)
		self:Print('Calculating CPU Usage differences (module: '..(checkCore or module)..', showall: '..tostring(showall)..', minCalls: '..tostring(minCalls)..', delay: '..tostring(delay)..')')
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
	'Blizzard_PlayerChoice',
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
	'Blizzard_UIFrameManager',
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

function E:DBConvertProfile()
	E.db.dbConverted = nil
	E:DBConversions()
	ReloadUI()
end

function E:LoadCommands()
	if E.private.actionbar.enable then
		self:RegisterChatCommand('kb', AB.ActivateBindMode)
	end

	self:RegisterChatCommand('in', 'DelayScriptCall')
	self:RegisterChatCommand('ec', 'ToggleOptionsUI')
	self:RegisterChatCommand('elvui', 'ToggleOptionsUI')

	self:RegisterChatCommand('hdt', DT.HyperDT)
	self:RegisterChatCommand('bgstats', DT.ToggleBattleStats)

	self:RegisterChatCommand('moveui', 'ToggleMoveMode')
	self:RegisterChatCommand('resetui', 'ResetUI')
	self:RegisterChatCommand('luaerror', 'LuaError')

	self:RegisterChatCommand('emove', 'ToggleMoveMode')
	self:RegisterChatCommand('ereset', 'ResetUI')
	self:RegisterChatCommand('edebug', 'LuaError')

	self:RegisterChatCommand('ehelp', 'EHelp')
	self:RegisterChatCommand('ecommands', 'EHelp')
	self:RegisterChatCommand('eblizzard', 'EnableBlizzardAddOns')
	self:RegisterChatCommand('estatus', 'ShowStatusReport')
	self:RegisterChatCommand('efixdb', 'DBConvertProfile')
	self:RegisterChatCommand('egrid', 'Grid')

	self:RegisterChatCommand('eimpact', 'GetCPUImpact')
	self:RegisterChatCommand('eusage', 'GetTopCPUFunc')

	--[[
		eusage args: module, showall [optional], delay [optional], minCalls [optional]
		- Note: arg1 can be 'all' this will scan all registered modules!

		example 1: /eusage all
		example 2: /eusage Bags true
		example 3: /eusage UnitFrames nil 50 25
	]]
end
