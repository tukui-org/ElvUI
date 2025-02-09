local E, L, V, P, G = unpack(ElvUI)
local CH = E:GetModule('Chat')
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local type, pairs, sort, tonumber = type, pairs, sort, tonumber
local lower, wipe, next, print = strlower, wipe, next, print
local ipairs, format, tinsert = ipairs, format, tinsert
local strmatch, gsub = strmatch, gsub

local CopyTable = CopyTable
local ReloadUI = ReloadUI

local DisableAddOn = C_AddOns.DisableAddOn
local EnableAddOn = C_AddOns.EnableAddOn
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns

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

local AddOns = {
	ElvUI = true,
	ElvUI_Options = true,
	ElvUI_Libraries = true
}

function E:LuaError(msg)
	local switch = lower(msg)
	if switch == 'on' or switch == '1' then
		for i=1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if not AddOns[name] and E:IsAddOnEnabled(name) then
				DisableAddOn(name, E.myname)
				ElvDB.DisabledAddOns[name] = i
			end
		end

		E:SetCVar('scriptErrors', 1)
		ReloadUI()
	elseif switch == 'off' or switch == '0' then
		if switch == 'off' then
			E:SetCVar('scriptProfile', 0)
			E:SetCVar('scriptErrors', 0)
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

do
	local temp = {}
	local list = {}
	local text = ''

	function E:BuildProfilerText(tbl, data, overall)
		local full = not overall or overall == 2
		for _, info in ipairs(tbl) do
			if info.key == '_module' then
				local all = E.Profiler.data._all
				if all then
					local total = info.total or 0
					local percent = (total / all.total) * 100
					text = format('%s%s total: %0.3f count: %d profiler: %0.2f%%\n', text, info.module or '', total, info.count or 0, percent)
				end
			elseif full then
				local total = info.total or 0
				local modulePercent = (total / data._module.total) * 100

				local all, allPercent = E.Profiler.data._all
				if all then
					allPercent = (total / all.total) * 100
				end

				text = format('%s%s:%s time %0.3f avg %0.3f total %0.3f (count: %d module: %0.2f%% profiler: %0.2f%%)\n', text, info.module or '', info.key or '', info.finish or 0, info.average or 0, total, info.count or 0, modulePercent, allPercent or 0)
			end
		end

		if full then
			text = format('%s\n', text)
		end

		wipe(temp)
		wipe(list)
	end

	function E:ProfilerSort(second)
		return self.total > second.total
	end

	function E:SortProfilerData(module, data, overall)
		for key, value in next, data do
			local info = CopyTable(value)
			info.module = module
			info.key = key

			tinsert(temp, info)
		end

		sort(temp, E.ProfilerSort)

		E:BuildProfilerText(temp, data, overall)
	end

	function E:ShowProfilerText()
		if text ~= '' then
			CH.CopyChatFrameEditBox:SetText(text)
			CH.CopyChatFrame:Show()
		end

		text = ''
	end

	function E:GetProfilerData(msg)
		local switch = lower(msg)
		if switch == '' then return end

		local ouf = switch == 'ouf'
		if ouf or switch == 'e' then
			local data = E.Profiler.data[ouf and E.oUF or E]
			if data then
				E:Dump(data, true)
			end
		elseif switch == 'pooler' then
			local data = E.Profiler.data[E.oUF.Pooler]
			if data then
				E:Dump(data, true)
			end
		elseif strmatch(switch, '^ouf%s+') then
			local element = gsub(switch, '^ouf%s+', '')
			if element == '' then return end

			for key, module in next, E.oUF.elements do
				local data = element == lower(key) and E.Profiler.data[module]
				if data then
					E:Dump(data, true)
				end
			end
		else
			for key, module in next, E.modules do
				local data = switch == lower(key) and E.Profiler.data[module]
				if data then
					E:Dump(data, true)
				end
			end
		end
	end

	local function FetchAll(overall)
		if overall == 2 then
			local ouf = E.Profiler.data[E.oUF]
			if ouf then
				E:SortProfilerData('oUF', ouf, overall)
			end

			local private = E.Profiler.oUF_Private -- this is special
			if private then
				E:SortProfilerData('oUF.Private', private, overall)
			end

			local pooler = E.Profiler.data[E.oUF.Pooler]
			if pooler then
				E:SortProfilerData('oUF.Pooler', pooler, overall)
			end

			for key, module in next, E.oUF.elements do
				local info = E.Profiler.data[module]
				if info then
					E:SortProfilerData(key, info, overall)
				end
			end
		else
			local data = E.Profiler.data[E]
			if data then
				E:SortProfilerData('E', data, overall)
			end

			local ouf = overall and E.Profiler.data[E.oUF]
			if ouf then
				E:SortProfilerData('oUF', ouf, overall)
			end

			for key, module in next, E.modules do
				local info = E.Profiler.data[module]
				if info then
					E:SortProfilerData(key, info, overall)
				end
			end
		end
	end

	function E:FetchProfilerData(msg)
		local switch = lower(msg)
		if switch ~= '' then
			if switch == 'on' then
				E.Profiler.state(true)

				return E:Print('Profiler: Enabled')
			elseif switch == 'off' then
				E.Profiler.state(false)

				return E:Print('Profiler: Disabled')
			elseif switch == 'reset' then
				E.Profiler.reset()

				return E:Print('Profiler: Reset')
			elseif switch == 'all' then
				FetchAll(1)
			elseif switch == 'ouf' then
				FetchAll(2)
			elseif switch == 'e' then
				local data = E.Profiler.data[E]
				if data then
					E:SortProfilerData('E', data)
				end
			elseif switch == 'ouf' then
				local data = E.Profiler.data[E.oUF]
				if data then
					E:SortProfilerData('oUF', data)
				end
			elseif switch == 'pooler' then
				local data = E.Profiler.data[E.oUF.Pooler]
				if data then
					E:SortProfilerData('oUF.Pooler', data)
				end
			elseif strmatch(switch, '^ouf%s+') then
				local element = gsub(switch, '^ouf%s+', '')
				if element ~= '' then
					for key, module in next, E.oUF.elements do
						local data = element == lower(key) and E.Profiler.data[module]
						if data then
							E:SortProfilerData(key, data)

							break
						end
					end
				end
			else
				for key, module in next, E.modules do
					local data = switch == lower(key) and E.Profiler.data[module]
					if data then
						E:SortProfilerData(key, data)

						break
					end
				end
			end
		else
			FetchAll()
		end

		E:ShowProfilerText()
	end
end

function E:DisplayCommands()
	print(L["EHELP_COMMANDS"])
end

local BLIZZARD_DEPRECATED = {
	'Blizzard_Deprecated',
	'Blizzard_DeprecatedCurrencyScript',
	'Blizzard_DeprecatedGlue',
	'Blizzard_DeprecatedGuildScript',
	'Blizzard_DeprecatedItemScript',
	'Blizzard_DeprecatedLFG',
	'Blizzard_DeprecatedPvpScript',
	'Blizzard_DeprecatedSoundScript',
	'Blizzard_DeprecatedSpecialization',
	'Blizzard_DeprecatedSpellScript',
	'Blizzard_Deprecated_ArenaUI',
}

local BLIZZARD_ADDONS = {
	'Blizzard_AccountSaveUI',
	'Blizzard_AccountStore',
	'Blizzard_AchievementUI',
	'Blizzard_ActionBar',
	'Blizzard_ActionBarController',
	'Blizzard_ActionStatus',
	'Blizzard_AddOnList',
	'Blizzard_AdventureMap',
	'Blizzard_AlliedRacesUI',
	'Blizzard_AnimaDiversionUI',
	'Blizzard_APIDocumentation',
	'Blizzard_APIDocumentationGenerated',
	'Blizzard_ArchaeologyUI',
	'Blizzard_ArdenwealdGardening',
	'Blizzard_ArrowCalloutFrame',
	'Blizzard_ArtifactUI',
	'Blizzard_AuctionHouseUI',
	'Blizzard_AuthChallengeUI',
	'Blizzard_AutoComplete',
	'Blizzard_AzeriteEssenceUI',
	'Blizzard_AzeriteRespecUI',
	'Blizzard_AzeriteUI',
	'Blizzard_BarbershopUI',
	'Blizzard_BattlefieldMap',
	'Blizzard_BehavioralMessaging',
	'Blizzard_BlackMarketUI',
	'Blizzard_BNet',
	'Blizzard_BoostTutorial',
	'Blizzard_BuffFrame',
	'Blizzard_Calendar',
	'Blizzard_ChallengesUI',
	'Blizzard_Channels',
	'Blizzard_CharacterCreate',
	'Blizzard_CharacterCustomize',
	'Blizzard_ChatFrame',
	'Blizzard_ChatFrameBase',
	'Blizzard_ChatFrameUtil',
	'Blizzard_ChromieTimeUI',
	'Blizzard_ClassMenu',
	'Blizzard_ClassTrial',
	'Blizzard_ClassTrialSecure',
	'Blizzard_ClickBindingUI',
	'Blizzard_ClientSavedVariables',
	'Blizzard_Collections',
	'Blizzard_CombatLog',
	'Blizzard_CombatText',
	'Blizzard_Commentator',
	'Blizzard_Communities',
	'Blizzard_CommunitiesSecure',
	'Blizzard_CompactRaidFrames',
	'Blizzard_Console',
	'Blizzard_ContentTracking',
	'Blizzard_Contribution',
	'Blizzard_CovenantCallings',
	'Blizzard_CovenantPreviewUI',
	'Blizzard_CovenantRenown',
	'Blizzard_CovenantSanctum',
	'Blizzard_CovenantToasts',
	'Blizzard_CUFProfiles',
	'Blizzard_DeathRecap',
	'Blizzard_DebugTools',
	'Blizzard_DeclensionFrame',
	'Blizzard_DeclensionFrameGlue',
	'Blizzard_DelvesCompanionConfiguration',
	'Blizzard_DelvesDashboardUI',
	'Blizzard_DelvesDifficultyPicker',
	'Blizzard_Dispatcher',
	'Blizzard_DurabilityFrame',
	'Blizzard_EditMode',
	'Blizzard_EncounterJournal',
	'Blizzard_EndOfMatchUI',
	'Blizzard_EnvironmentCleanup',
	'Blizzard_EventTrace',
	'Blizzard_ExpansionLandingPage',
	'Blizzard_ExpansionTrial',
	'Blizzard_FlightMap',
	'Blizzard_FontStyles_Frame',
	'Blizzard_FontStyles_Glue',
	'Blizzard_FontStyles_Shared',
	'Blizzard_Fonts_Frame',
	'Blizzard_Fonts_Glue',
	'Blizzard_Fonts_Shared',
	'Blizzard_FrameEffects',
	'Blizzard_FramerateFrame',
	'Blizzard_FrameStack',
	'Blizzard_FrameXML',
	'Blizzard_FrameXMLBase',
	'Blizzard_FrameXMLUtil',
	'Blizzard_FriendsFrame',
	'Blizzard_GameMenu',
	'Blizzard_GameTooltip',
	'Blizzard_GarrisonBase',
	'Blizzard_GarrisonTemplates',
	'Blizzard_GarrisonUI',
	'Blizzard_GenericTraitUI',
	'Blizzard_GlobalFXModelScenes',
	'Blizzard_GlueDialogs',
	'Blizzard_GlueParent',
	'Blizzard_GlueSavedVariables',
	'Blizzard_GlueStubs',
	'Blizzard_GlueXML',
	'Blizzard_GlueXMLBase',
	'Blizzard_GMChatUI',
	'Blizzard_GroupFinder',
	'Blizzard_GuildBankUI',
	'Blizzard_GuildControlUI',
	'Blizzard_HelpFrame',
	'Blizzard_HybridMinimap',
	'Blizzard_IME',
	'Blizzard_InspectUI',
	'Blizzard_IslandsPartyPoseUI',
	'Blizzard_IslandsQueueUI',
	'Blizzard_ItemBeltFrame',
	'Blizzard_ItemButton',
	'Blizzard_ItemInteractionUI',
	'Blizzard_ItemSocketingUI',
	'Blizzard_ItemUpgradeUI',
	'Blizzard_Kiosk',
	'Blizzard_LandingSoulbinds',
	'Blizzard_LevelUpDisplay',
	'Blizzard_LoadLocale',
	'Blizzard_LoginWarningDialogs',
	'Blizzard_MacroUI',
	'Blizzard_MailFrame',
	'Blizzard_MajorFactions',
	'Blizzard_MapCanvas',
	'Blizzard_MatchCelebrationPartyPoseUI',
	'Blizzard_MatchmakingQueueDisplay',
	'Blizzard_MawBuffs',
	'Blizzard_Menu',
	'Blizzard_Minimap',
	'Blizzard_MirrorTimer',
	'Blizzard_MoneyFrame',
	'Blizzard_MoneyReceipt',
	'Blizzard_MovePad',
	'Blizzard_NamePlates',
	'Blizzard_NewPlayerExperience',
	'Blizzard_NewPlayerExperienceGuide',
	'Blizzard_ObjectAPI',
	'Blizzard_ObjectiveTracker',
	'Blizzard_ObliterumUI',
	'Blizzard_OrderHallUI',
	'Blizzard_OverrideActionBar',
	'Blizzard_PagedContent',
	'Blizzard_PartyPoseUI',
	'Blizzard_PerksProgram',
	'Blizzard_PetBattleUI',
	'Blizzard_PingUI',
	'Blizzard_PlayerChoice',
	'Blizzard_PlayerSpells',
	'Blizzard_PlunderstormBasics',
	'Blizzard_PlunderstormPrematchUI',
	'Blizzard_POIButton',
	'Blizzard_PrintHandler',
	'Blizzard_PrivateAurasUI',
	'Blizzard_Professions',
	'Blizzard_ProfessionsBook',
	'Blizzard_ProfessionsCustomerOrders',
	'Blizzard_ProfessionsTemplates',
	'Blizzard_PTRFeedback',
	'Blizzard_PTRFeedbackGlue',
	'Blizzard_PVPMatch',
	'Blizzard_PVPUI',
	'Blizzard_QuestNavigation',
	'Blizzard_QuestTimer',
	'Blizzard_QueueStatusFrame',
	'Blizzard_QuickJoin',
	'Blizzard_QuickKeybind',
	'Blizzard_RaidFrame',
	'Blizzard_RaidUI',
	'Blizzard_RecruitAFriend',
	'Blizzard_ReforgingUI',
	'Blizzard_ReportFrame',
	'Blizzard_ReportFrameGlue',
	'Blizzard_ReportFrameShared',
	'Blizzard_RuneforgeUI',
	'Blizzard_ScrappingMachineUI',
	'Blizzard_SecureTransferUI',
	'Blizzard_SelectorUI',
	'Blizzard_Settings',
	'Blizzard_SettingsDefinitions_Frame',
	'Blizzard_SettingsDefinitions_Shared',
	'Blizzard_Settings_Shared',
	'Blizzard_SharedMapDataProviders',
	'Blizzard_SharedTalentUI',
	'Blizzard_SharedWidgetFrames',
	'Blizzard_SharedXML',
	'Blizzard_SharedXMLBase',
	'Blizzard_SharedXMLGame',
	'Blizzard_SocialToast',
	'Blizzard_Soulbinds',
	'Blizzard_SpectateFrame',
	'Blizzard_SpellPickUpIndicator',
	'Blizzard_SpellSearch',
	'Blizzard_StableUI',
	'Blizzard_StaticPopup',
	'Blizzard_StaticPopup_Frame',
	'Blizzard_StoreUI',
	'Blizzard_SubscriptionInterstitialUI',
	'Blizzard_Subtitles',
	'Blizzard_TalentUI',
	'Blizzard_TextStatusBar',
	'Blizzard_TimeManager',
	'Blizzard_TimerunningCharacterCreate',
	'Blizzard_TimerunningUtil',
	'Blizzard_TokenUI',
	'Blizzard_TorghastLevelPicker',
	'Blizzard_TrainerUI',
	'Blizzard_TransformTree',
	'Blizzard_TutorialManager',
	'Blizzard_Tutorials',
	'Blizzard_UIFrameManager',
	'Blizzard_UIPanels_Game',
	'Blizzard_UIPanelTemplates',
	'Blizzard_UIParent',
	'Blizzard_UIParentPanelManager',
	'Blizzard_UIWidgets',
	'Blizzard_UnitFrame',
	'Blizzard_UnitPopup',
	'Blizzard_UnitPopupShared',
	'Blizzard_VoiceToggleButton',
	'Blizzard_VoidStorageUI',
	'Blizzard_WarfrontsPartyPoseUI',
	'Blizzard_WeeklyRewards',
	'Blizzard_WeeklyRewardsUtil',
	'Blizzard_WorldLootObjectList',
	'Blizzard_WorldMap',
	'Blizzard_WowTokenUI',
	'Blizzard_ZoneAbility',
}

function E:DisableBlizzardDeprecated()
	for _, addon in pairs(BLIZZARD_DEPRECATED) do
		local enabled = E:IsAddOnEnabled(addon)
		if enabled then
			DisableAddOn(addon)
			E:Print('The following addon was disabled:', addon)
		end
	end
end

do
	local function Enable(addon)
		local _, _, _, _, reason = GetAddOnInfo(addon)
		if reason == 'DISABLED' then
			EnableAddOn(addon)
			E:Print('The following addon was re-enabled:', addon)
		end
	end

	function E:EnableBlizzardAddOns()
		for _, addon in pairs(BLIZZARD_ADDONS) do
			Enable(addon)
		end

		for _, addon in pairs(BLIZZARD_DEPRECATED) do
			Enable(addon)
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
		E:RegisterChatCommand('kb', AB.ActivateBindMode)
	end

	E:RegisterChatCommand('ec', 'ToggleOptions')
	E:RegisterChatCommand('elvui', 'ToggleOptions')

	E:RegisterChatCommand('bgstats', DT.ToggleBattleStats)

	E:RegisterChatCommand('moveui', 'ToggleMoveMode')
	E:RegisterChatCommand('resetui', 'ResetUI')

	E:RegisterChatCommand('emove', 'ToggleMoveMode')
	E:RegisterChatCommand('ereset', 'ResetUI')
	E:RegisterChatCommand('edebug', 'LuaError')

	E:RegisterChatCommand('eprofile', 'GetProfilerData') -- temp until we make display window
	E:RegisterChatCommand('eprofiler', 'FetchProfilerData') -- temp until we make display window

	E:RegisterChatCommand('ehelp', 'DisplayCommands')
	E:RegisterChatCommand('ecommands', 'DisplayCommands')
	E:RegisterChatCommand('eblizzard', 'EnableBlizzardAddOns')
	E:RegisterChatCommand('estatus', 'ShowStatusReport')
	E:RegisterChatCommand('efixdb', 'DBConvertProfile')
	E:RegisterChatCommand('egrid', 'Grid')
end
