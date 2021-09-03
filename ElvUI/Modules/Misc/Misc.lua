local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local Bags = E:GetModule('Bags')

local _G = _G
local select = select
local format = format

local CreateFrame = CreateFrame
local AcceptGroup = AcceptGroup
local C_FriendList_IsFriend = C_FriendList.IsFriend
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetInstanceInfo = GetInstanceInfo
local GetItemInfo = GetItemInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetNumQuestChoices = GetNumQuestChoices
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRepairAllCost = GetRepairAllCost
local InCombatLockdown = InCombatLockdown
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local IsAddOnLoaded = IsAddOnLoaded
local IsArenaSkirmish = IsArenaSkirmish
local IsGuildMember = IsGuildMember
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local IsShiftKeyDown = IsShiftKeyDown
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RepairAllItems = RepairAllItems
local SendChatMessage = SendChatMessage
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local UninviteUnit = UninviteUnit
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitInRaid = UnitInRaid
local UnitName = UnitName
local IsInGuild = IsInGuild
local PlaySound = PlaySound
local GetNumFactions = GetNumFactions
local GetFactionInfo = GetFactionInfo
local GetWatchedFactionInfo = GetWatchedFactionInfo
local ExpandAllFactionHeaders = ExpandAllFactionHeaders
local SetWatchedFactionIndex = SetWatchedFactionIndex
local GetCurrentCombatTextEventInfo = GetCurrentCombatTextEventInfo
local hooksecurefunc = hooksecurefunc

local C_PartyInfo_LeaveParty = C_PartyInfo.LeaveParty
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY
local LE_GAME_ERR_NOT_ENOUGH_MONEY = LE_GAME_ERR_NOT_ENOUGH_MONEY
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local BOOST_THANKSFORPLAYING_SMALLER = SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER
local INTERRUPT_MSG = L["Interrupted %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"]

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end
	if event == 'PLAYER_REGEN_DISABLED' then
		_G.UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		_G.UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED()
	local inGroup = IsInGroup()
	if not inGroup then return end

	local _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	local announce = event == 'SPELL_INTERRUPT' and (sourceGUID == E.myguid or sourceGUID == UnitGUID('pet')) and destGUID ~= E.myguid
	if not announce then return end -- No announce-able interrupt from player or pet, exit.
	local inRaid, inPartyLFG = IsInRaid(), IsPartyLFG()

	--Skirmish/non-rated arenas need to use INSTANCE_CHAT but IsPartyLFG() returns 'false'
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'arena' then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end
		inRaid = false --IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local channel, msg = E.db.general.interruptAnnounce, format(INTERRUPT_MSG, destName, spellID, spellName)
	if channel == 'PARTY' then
		SendChatMessage(msg, inPartyLFG and 'INSTANCE_CHAT' or 'PARTY')
	elseif channel == 'RAID' then
		SendChatMessage(msg, inPartyLFG and 'INSTANCE_CHAT' or (inRaid and 'RAID' or 'PARTY'))
	elseif channel == 'RAID_ONLY' and inRaid then
		SendChatMessage(msg, inPartyLFG and 'INSTANCE_CHAT' or 'RAID')
	elseif channel == 'SAY' and instanceType ~= 'none' then
		SendChatMessage(msg, 'SAY')
	elseif channel == 'YELL' and instanceType ~= 'none' then
		SendChatMessage(msg, 'YELL')
	elseif channel == 'EMOTE' then
		SendChatMessage(msg, 'EMOTE')
	end
end

function M:COMBAT_TEXT_UPDATE(_, messagetype)
	if not E.db.general.autoTrackReputation then return end

	if messagetype == 'FACTION' then
		local faction = GetCurrentCombatTextEventInfo()
		if faction ~= 'Guild' and faction ~= GetWatchedFactionInfo() then
			ExpandAllFactionHeaders()

			for i = 1, GetNumFactions() do
				if faction == GetFactionInfo(i) then
					SetWatchedFactionIndex(i)
					break
				end
			end
		end
	end
end

do -- Auto Repair Functions
	local STATUS, TYPE, COST, canRepair
	function M:AttemptAutoRepair(playerOverride)
		STATUS, TYPE, COST, canRepair = '', E.db.general.autoRepair, GetRepairAllCost()

		if canRepair and COST > 0 then
			local tryGuild = not playerOverride and TYPE == 'GUILD' and IsInGuild()
			local useGuild = tryGuild and CanGuildBankRepair() and COST <= GetGuildBankWithdrawMoney()
			if not useGuild then TYPE = 'PLAYER' end

			RepairAllItems(useGuild)

			--Delay this a bit so we have time to catch the outcome of first repair attempt
			E:Delay(0.5, M.AutoRepairOutput)
		end
	end

	function M:AutoRepairOutput()
		if TYPE == 'GUILD' then
			if STATUS == 'GUILD_REPAIR_FAILED' then
				M:AttemptAutoRepair(true) --Try using player money instead
			else
				E:Print(L["Your items have been repaired using guild bank funds for: "]..E:FormatMoney(COST, 'SMART', true)) --Amount, style, textOnly
			end
		elseif TYPE == 'PLAYER' then
			if STATUS == 'PLAYER_REPAIR_FAILED' then
				E:Print(L["You don't have enough money to repair."])
			else
				E:Print(L["Your items have been repaired for: "]..E:FormatMoney(COST, 'SMART', true)) --Amount, style, textOnly
			end
		end
	end

	function M:UI_ERROR_MESSAGE(_, messageType)
		if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
			STATUS = 'GUILD_REPAIR_FAILED'
		elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
			STATUS = 'PLAYER_REPAIR_FAILED'
		end
	end
end

function M:MERCHANT_CLOSED()
	self:UnregisterEvent('UI_ERROR_MESSAGE')
	self:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
	self:UnregisterEvent('MERCHANT_CLOSED')
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then E:Delay(0.5, Bags.VendorGrays, Bags) end

	if E.db.general.autoRepair == 'NONE' or IsShiftKeyDown() or not CanMerchantRepair() then return end

	--Prepare to catch 'not enough money' messages
	self:RegisterEvent('UI_ERROR_MESSAGE')

	--Use this to unregister events afterwards
	self:RegisterEvent('MERCHANT_CLOSED')

	M:AttemptAutoRepair()
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid('player') then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if UnitExists('party'..i) then
				UninviteUnit(UnitName('party'..i))
			end
		end
	end

	C_PartyInfo_LeaveParty()
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' or instanceType == 'arena' then
		RaidNotice_AddMessage(_G.RaidBossEmoteFrame, msg, _G.ChatTypeInfo.RAID_BOSS_EMOTE)
	end
end

local hideStatic
function M:AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if not E.db.general.autoAcceptInvite then return end

	if event == 'PARTY_INVITE_REQUEST' then
		-- Prevent losing que inside LFD if someone invites you to group
		if _G.QueueStatusMinimapButton:IsShown() or IsInGroup() or (not inviterGUID or inviterGUID == '') then return end

		if C_BattleNet_GetGameAccountInfoByGUID(inviterGUID) or C_FriendList_IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			hideStatic = true
			AcceptGroup()
		end
	elseif event == 'GROUP_ROSTER_UPDATE' and hideStatic then
		StaticPopupSpecial_Hide(_G.LFGInvitePopup) --New LFD popup when invited in custom created group
		StaticPopup_Hide('PARTY_INVITE')
		hideStatic = nil
	end
end

function M:ForceCVars()
	if not GetCVarBool('lockActionBars') and E.private.actionbar.enable then
		SetCVar('lockActionBars', 1)
	end
end

function M:PLAYER_ENTERING_WORLD()
	self:ForceCVars()
end

function M:RESURRECT_REQUEST()
	if E.db.general.resurrectSound then
		PlaySound(BOOST_THANKSFORPLAYING_SMALLER, 'Master')
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_InspectUI' then
		M:SetupInspectPageInfo()
	end
end

function M:QUEST_COMPLETE()
	if not E.db.general.questRewardMostValueIcon then return end

	local firstItem = _G.QuestInfoRewardsFrameQuestInfoItem1
	if not firstItem then return end

	local numQuests = GetNumQuestChoices()
	if numQuests < 2 then return end

	local bestValue, bestItem = 0
	for i = 1, numQuests do
		local questLink = GetQuestItemLink('choice', i)
		local _, _, amount = GetQuestItemInfo('choice', i)
		local itemSellPrice = questLink and select(11, GetItemInfo(questLink))

		local totalValue = (itemSellPrice and itemSellPrice * amount) or 0
		if totalValue > bestValue then
			bestValue = totalValue
			bestItem = i
		end
	end

	if bestItem then
		local btn = _G['QuestInfoRewardsFrameQuestInfoItem'..bestItem]
		if btn and btn.type == 'choice' then
			M.QuestRewardGoldIconFrame:ClearAllPoints()
			M.QuestRewardGoldIconFrame:Point('TOPRIGHT', btn, 'TOPRIGHT', -2, -2)
			M.QuestRewardGoldIconFrame:Show()
		end
	end
end

-- TEMP: fix `SetItemButtonOverlay` error at `button.IconOverlay2:SetAtlas("ConduitIconFrame-Corners")`
-- because the `BossBannerLootFrameTemplate` doesnt add `IconOverlay2` so we can before it gets there
function M:BossBanner_ConfigureLootFrame(lootFrame)
	if not lootFrame.IconHitBox then return end

	if not lootFrame.IconHitBox.IconOverlay2 then
		lootFrame.IconHitBox.IconOverlay2 = lootFrame.IconHitBox:CreateTexture(nil, 'OVERLAY', nil, 2)
		lootFrame.IconHitBox.IconOverlay2:SetSize(37, 37)
		lootFrame.IconHitBox.IconOverlay2:SetPoint('CENTER')
	end

	lootFrame.IconHitBox.IconOverlay2:Hide()
end

function M:Initialize()
	self.Initialized = true
	self:LoadRaidMarker()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:LoadLoot()
	self:ToggleItemLevelInfo(true)
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('RESURRECT_REQUEST')
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL', 'PVPMessageEnhancement')
	self:RegisterEvent('PARTY_INVITE_REQUEST', 'AutoInvite')
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'AutoInvite')
	self:RegisterEvent('CVAR_UPDATE', 'ForceCVars')
	self:RegisterEvent('COMBAT_TEXT_UPDATE')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('QUEST_COMPLETE')

	do	-- questRewardMostValueIcon
		local MostValue = CreateFrame('Frame', 'ElvUI_QuestRewardGoldIconFrame', _G.UIParent)
		MostValue:SetFrameStrata('HIGH')
		MostValue:Size(19)
		MostValue:Hide()

		MostValue.Icon = MostValue:CreateTexture(nil, 'OVERLAY')
		MostValue.Icon:SetAllPoints(MostValue)
		MostValue.Icon:SetTexture([[Interface\MONEYFRAME\UI-GoldIcon]])

		M.QuestRewardGoldIconFrame = MostValue

		hooksecurefunc(_G.QuestFrameRewardPanel, 'Hide', function()
			if M.QuestRewardGoldIconFrame then
				M.QuestRewardGoldIconFrame:Hide()
			end
		end)
	end

	if E.db.general.interruptAnnounce ~= 'NONE' then
		self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end

	if IsAddOnLoaded('Blizzard_InspectUI') then
		M:SetupInspectPageInfo()
	else
		self:RegisterEvent('ADDON_LOADED')
	end

	M:Hook('BossBanner_ConfigureLootFrame', nil, true) -- fix blizz thing x.x
end

E:RegisterModule(M:GetName())
