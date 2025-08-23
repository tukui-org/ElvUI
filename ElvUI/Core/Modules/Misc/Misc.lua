local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local B = E:GetModule('Bags')

local _G = _G
local next = next
local wipe = wipe
local select = select
local format = format
local strmatch = strmatch
local hooksecurefunc = hooksecurefunc

local AcceptGroup = AcceptGroup
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local GetCurrentCombatTextEventInfo = GetCurrentCombatTextEventInfo
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRepairAllCost = GetRepairAllCost
local InCombatLockdown = InCombatLockdown
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local IsArenaSkirmish = IsArenaSkirmish
local IsGuildMember = IsGuildMember
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RepairAllItems = RepairAllItems
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local UninviteUnit = UninviteUnit
local UnitGUID = UnitGUID
local UnitInRaid = UnitInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitName = UnitName

local SendChatMessage = C_ChatInfo.SendChatMessage or SendChatMessage
local GetNumFactions = C_Reputation.GetNumFactions or GetNumFactions
local GetFactionInfo = C_Reputation.GetFactionDataByIndex or GetFactionInfo
local GetFactionDataByID = C_Reputation.GetFactionDataByID or GetFactionDataByID
local ExpandAllFactionHeaders = C_Reputation.ExpandAllFactionHeaders or ExpandAllFactionHeaders
local SetWatchedFactionIndex = C_Reputation.SetWatchedFactionByIndex or SetWatchedFactionIndex
local LeaveParty = C_PartyInfo.LeaveParty or LeaveParty
local IsPartyWalkIn = C_PartyInfo.IsPartyWalkIn
local GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local GetItemInfo = C_Item.GetItemInfo
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local IsFriend = C_FriendList.IsFriend
local SetWatchedFactionByID = C_Reputation.SetWatchedFactionByID

local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY
local LE_GAME_ERR_NOT_ENOUGH_MONEY = LE_GAME_ERR_NOT_ENOUGH_MONEY
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local UNKNOWN = UNKNOWN

local function KillFeedback(frame)
	local debug = true
	if not debug then
		frame:Kill()
		frame.TriggerEvent = E.noop
		wipe(frame.Data.RegisteredEvents)
	end
end

local BOOST_THANKSFORPLAYING_SMALLER = SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER
local INTERRUPT_MSG = L["Interrupted %s's |cff71d5ff|Hspell:%d:0|h[%s]|h|r!"]

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end

	if event == 'PLAYER_REGEN_DISABLED' then
		_G.UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		_G.UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:ZoneTextToggle()
	if E.db.general.hideZoneText then
		_G.ZoneTextFrame:UnregisterAllEvents()
	else
		_G.ZoneTextFrame:RegisterEvent('ZONE_CHANGED')
		_G.ZoneTextFrame:RegisterEvent('ZONE_CHANGED_INDOORS')
		_G.ZoneTextFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	end
end

function M:IsRandomGroup()
	return IsPartyLFG() or (E.Retail and IsPartyWalkIn()) -- This is the API for Delves
end

function M:COMBAT_LOG_EVENT_UNFILTERED()
	local inGroup = IsInGroup()
	if not inGroup then return end

	local _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	local announce = spellName and (destGUID ~= E.myguid) and (sourceGUID == E.myguid or sourceGUID == UnitGUID('pet')) and strmatch(event, '_INTERRUPT')
	if not announce then return end -- No announce-able interrupt from player or pet, exit.

	local inRaid, inPartyLFG = IsInRaid(), M:IsRandomGroup()

	--Skirmish/non-rated arenas need to use INSTANCE_CHAT but IsPartyLFG() returns 'false'
	local _, instanceType = GetInstanceInfo()
	if not E.Classic and instanceType == 'arena' then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end

		inRaid = false --IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local name, msg = destName or UNKNOWN
	if E.locale == 'msMX' or E.locale == 'esES' or E.locale == 'ptBR' then -- name goes after
		msg = format(INTERRUPT_MSG, spellID, spellName, name)
	else
		msg = format(INTERRUPT_MSG, name, spellID, spellName)
	end

	local channel = E.db.general.interruptAnnounce
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

do
	local twwBW = 2673	-- 11.1.0, both factions, account wide
	local cataBW = 1133	-- 4.0.3, horde only, not account wide
	local bilgewater = E.Retail and GetFactionDataByID(twwBW)
	function M:COMBAT_TEXT_UPDATE(_, messagetype)
		if messagetype ~= 'FACTION' or not E.db.general.autoTrackReputation then return end

		local faction, rep = GetCurrentCombatTextEventInfo()
		if (faction and faction ~= 'Guild') and (rep and rep > 0) then
			local data = E:GetWatchedFactionInfo()
			if not (data and data.name) or faction ~= data.name then
				ExpandAllFactionHeaders()

				local khazAlgar = E.MapInfo.continentMapID == 2274
				for i = 1, GetNumFactions() do
					if E.Retail then
						local info = GetFactionInfo(i)
						if info then
							local name, factionID = info.name, info.factionID
							if factionID == twwBW then
								bilgewater = info -- reupdate this info
							end

							if name == faction and factionID and factionID ~= 0 then
								if bilgewater and name == bilgewater.name then -- two have matching faction names
									SetWatchedFactionByID(khazAlgar and twwBW or cataBW) -- prefer TWW when in Khaz Algar
								else
									SetWatchedFactionByID(factionID)
								end

								break
							end
						end
					else
						local name, _, _, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
						if name == faction and factionID and factionID ~= 0 then
							SetWatchedFactionIndex(i)

							break
						end
					end
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

	local myIndex = UnitInRaid('player')
	if myIndex then
		local _, myRank = GetRaidRosterInfo(myIndex)
		if myRank == 2 then -- real raid leader
			for i = 1, GetNumGroupMembers() do
				if i ~= myIndex then -- dont kick yourself
					local name = GetRaidRosterInfo(i)
					if name then
						UninviteUnit(name)
					end
				end
			end
		end
	elseif not myIndex and UnitIsGroupLeader('player', LE_PARTY_CATEGORY_HOME) then
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			local name = UnitName('party'..i)
			if name then
				UninviteUnit(name)
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

		local queueButton = M:GetQueueStatusButton() -- don't auto accept during a queue
		if queueButton and queueButton:IsShown() then return end

		if GetGameAccountInfoByGUID(inviterGUID) or IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
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
	elseif addon == 'Blizzard_PTRFeedback' then
		KillFeedback(_G.PTR_IssueReporter)
	elseif addon == 'Blizzard_GroupFinder_VanillaStyle' then
		M:LoadQueueStatus()
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
		local sellPrice = questLink and select(11, GetItemInfo(questLink))
		if sellPrice and sellPrice > 0 then
			local _, _, amount = GetQuestItemInfo('choice', i)
			local totalValue = (amount and amount > 0) and (sellPrice * amount) or 0
			if totalValue > bestValue then
				bestValue = totalValue
				bestItem = i
			end
		end
	end

	if bestItem then
		local btn = _G['QuestInfoRewardsFrameQuestInfoItem'..bestItem]
		if btn and btn.type == 'choice' then
			M.QuestRewardGoldIconFrame:ClearAllPoints()
			M.QuestRewardGoldIconFrame:Point('TOPRIGHT', btn, 'TOPRIGHT', -2, -2)
			M.QuestRewardGoldIconFrame:SetFrameStrata('HIGH')
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

function M:ToggleInterrupt()
	local announce = E.db.general.interruptAnnounce
	if announce and announce ~= 'NONE' then
		M:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	else
		M:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end
end

function M:Initialize()
	M.Initialized = true

	M:LoadRaidMarker()
	M:LoadLootRoll()
	M:LoadChatBubbles()
	M:LoadLoot()
	M:ToggleItemLevelInfo(true)
	M:ZoneTextToggle()
	M:ToggleInterrupt()

	if not E.ClassicAnniv then -- it uses Blizzard_GroupFinder_VanillaStyle
		M:LoadQueueStatus()
	end

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
	M:RegisterEvent('ADDON_LOADED')

	for _, addon in next, { 'Blizzard_InspectUI', 'Blizzard_PTRFeedback', E.ClassicAnniv and 'Blizzard_GroupFinder_VanillaStyle' or nil } do
		if IsAddOnLoaded(addon) then
			M:ADDON_LOADED(nil, addon)
		end
	end

	do	-- questRewardMostValueIcon
		local MostValue = CreateFrame('Frame', 'ElvUI_QuestRewardGoldIconFrame', _G.QuestInfoRewardsFrame)
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

	if E.Retail then
		M:Hook('BossBanner_ConfigureLootFrame', nil, true) -- fix blizz thing x.x
	end
end

E:RegisterModule(M:GetName())
