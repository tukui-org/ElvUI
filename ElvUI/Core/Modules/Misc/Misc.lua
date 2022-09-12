local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local B = E:GetModule('Bags')
local CH = E:GetModule('Chat')
local MM = E:GetModule('Minimap')

local _G = _G
local select = select
local format = format
local strmatch = strmatch

local CreateFrame = CreateFrame
local AcceptGroup = AcceptGroup
local C_FriendList_IsFriend = C_FriendList.IsFriend
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
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

local LeaveParty = C_PartyInfo.LeaveParty or LeaveParty
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY
local LE_GAME_ERR_NOT_ENOUGH_MONEY = LE_GAME_ERR_NOT_ENOUGH_MONEY
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local UNKNOWN = UNKNOWN

local BOOST_THANKSFORPLAYING_SMALLER = SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER
local INTERRUPT_MSG = L["Interrupted %s's |cff71d5ff|Hspell:%d:0|h[%s]|h|r!"]
if not E.Retail then
	INTERRUPT_MSG = INTERRUPT_MSG:gsub('|cff71d5ff|Hspell:%%d:0|h(%[%%s])|h|r','%1')
end

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
	local announce = strmatch(event, '_INTERRUPT') and (sourceGUID == E.myguid or sourceGUID == UnitGUID('pet')) and destGUID ~= E.myguid
	if not announce then return end -- No announce-able interrupt from player or pet, exit.

	local inRaid, inPartyLFG = IsInRaid(), E.Retail and IsPartyLFG()

	--Skirmish/non-rated arenas need to use INSTANCE_CHAT but IsPartyLFG() returns 'false'
	local _, instanceType = GetInstanceInfo()
	if E.Retail and instanceType == 'arena' then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end

		inRaid = false --IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local channel = E.db.general.interruptAnnounce
	local msg = E.Retail and format(INTERRUPT_MSG, destName or UNKNOWN, spellID, spellName) or format(INTERRUPT_MSG, destName or UNKNOWN, spellName)
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
		local faction, rep = GetCurrentCombatTextEventInfo()
		if faction ~= 'Guild' and faction ~= GetWatchedFactionInfo() and rep > 0 then
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
				E:Print(L["Your items have been repaired using guild bank funds for: "]..E:FormatMoney(COST, B.db.moneyFormat, not B.db.moneyCoins))
			end
		elseif TYPE == 'PLAYER' then
			if STATUS == 'PLAYER_REPAIR_FAILED' then
				E:Print(L["You don't have enough money to repair."])
			else
				E:Print(L["Your items have been repaired for: "]..E:FormatMoney(COST, B.db.moneyFormat, not B.db.moneyCoins))
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
	M:UnregisterEvent('UI_ERROR_MESSAGE')
	M:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
	M:UnregisterEvent('MERCHANT_CLOSED')
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then E:Delay(0.5, B.VendorGrays, B) end

	if E.db.general.autoRepair == 'NONE' or IsShiftKeyDown() or not CanMerchantRepair() then return end

	--Prepare to catch 'not enough money' messages
	M:RegisterEvent('UI_ERROR_MESSAGE')

	--Use this to unregister events afterwards
	M:RegisterEvent('MERCHANT_CLOSED')

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

	LeaveParty()
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
		if not inviterGUID or inviterGUID == '' or IsInGroup() then return end

		local queueButton = MM:GetQueueStatusButton() -- don't auto accept during a queue
		if queueButton and queueButton:IsShown() then return end

		if CH.BNGetGameAccountInfoByGUID(inviterGUID) or C_FriendList_IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			hideStatic = true
			AcceptGroup()
		end
	elseif event == 'GROUP_ROSTER_UPDATE' and hideStatic then
		if _G.LFGInvitePopup then -- invited in custom created group
			StaticPopupSpecial_Hide(_G.LFGInvitePopup)
		end

		StaticPopup_Hide('PARTY_INVITE')
		hideStatic = nil
	end
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
	M.Initialized = true
	M:LoadRaidMarker()
	M:LoadLootRoll()
	M:LoadChatBubbles()
	M:LoadLoot()
	M:ToggleItemLevelInfo(true)
	M:RegisterEvent('MERCHANT_SHOW')
	M:RegisterEvent('RESURRECT_REQUEST')
	M:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	M:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	M:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE', 'PVPMessageEnhancement')
	M:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE', 'PVPMessageEnhancement')
	M:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL', 'PVPMessageEnhancement')
	M:RegisterEvent('PARTY_INVITE_REQUEST', 'AutoInvite')
	M:RegisterEvent('GROUP_ROSTER_UPDATE', 'AutoInvite')
	M:RegisterEvent('COMBAT_TEXT_UPDATE')
	M:RegisterEvent('QUEST_COMPLETE')

	do	-- questRewardMostValueIcon
		local MostValue = CreateFrame('Frame', 'ElvUI_QuestRewardGoldIconFrame', _G.QuestInfoRewardsFrame)
		MostValue:SetFrameStrata('HIGH')
		MostValue:Size(19)
		MostValue:Hide()

		MostValue.Icon = MostValue:CreateTexture(nil, 'OVERLAY')
		MostValue.Icon:SetAllPoints(MostValue)
		MostValue.Icon:SetTexture(E.Media.Textures.Coins)
		MostValue.Icon:SetTexCoord(0.33, 0.66, 0.022, 0.66)

		M.QuestRewardGoldIconFrame = MostValue

		hooksecurefunc(_G.QuestFrameRewardPanel, 'Hide', function()
			if M.QuestRewardGoldIconFrame then
				M.QuestRewardGoldIconFrame:Hide()
			end
		end)
	end

	if E.db.general.interruptAnnounce ~= 'NONE' then
		M:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end

	if IsAddOnLoaded('Blizzard_InspectUI') then
		M:SetupInspectPageInfo()
	else
		M:RegisterEvent('ADDON_LOADED')
	end

	if E.Retail then
		M:Hook('BossBanner_ConfigureLootFrame', nil, true) -- fix blizz thing x.x
	end
end

E:RegisterModule(M:GetName())
