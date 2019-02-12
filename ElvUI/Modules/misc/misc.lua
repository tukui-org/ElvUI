local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('Misc', 'AceEvent-3.0', 'AceTimer-3.0');
E.Misc = M;

--Cache global variables
--Lua functions
local _G = _G
local format, gsub = string.format, string.gsub
local tonumber = tonumber
--WoW API / Variables
local UnitGUID = UnitGUID
local UnitInRaid = UnitInRaid
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local IsPartyLFG, IsInInstance = IsPartyLFG, IsInInstance
local IsArenaSkirmish = IsArenaSkirmish
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local SendChatMessage = SendChatMessage
local IsShiftKeyDown = IsShiftKeyDown
local CanMerchantRepair = CanMerchantRepair
local GetRepairAllCost = GetRepairAllCost
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local CanGuildBankRepair = CanGuildBankRepair
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local RepairAllItems = RepairAllItems
local InCombatLockdown = InCombatLockdown
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UninviteUnit = UninviteUnit
local UnitExists = UnitExists
local UnitName = UnitName
local LeaveParty = LeaveParty
local RaidNotice_AddMessage = RaidNotice_AddMessage
local GetNumFriends = GetNumFriends
local ShowFriends = ShowFriends
local IsInGuild = IsInGuild
local GuildRoster = GuildRoster
local GetFriendInfo = GetFriendInfo
local AcceptGroup = AcceptGroup
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local BNGetNumFriendGameAccounts = BNGetNumFriendGameAccounts
local BNGetFriendGameAccountInfo = BNGetFriendGameAccountInfo
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfo = BNGetFriendInfo
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopup_Hide = StaticPopup_Hide
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetInventoryItemLink = GetInventoryItemLink
local IsAddOnLoaded = IsAddOnLoaded
local C_Timer_After = C_Timer.After
local UIErrorsFrame = UIErrorsFrame
local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local CHARACTER_LINK_ITEM_LEVEL_TOOLTIP = CHARACTER_LINK_ITEM_LEVEL_TOOLTIP
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY
local LE_GAME_ERR_NOT_ENOUGH_MONEY = LE_GAME_ERR_NOT_ENOUGH_MONEY
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local interruptMsg = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"
local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub('%%d', '(%%d+)')
local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')

local ScanTooltip = CreateFrame("GameTooltip", "ElvUI_InspectTooltip", UIParent, "GameTooltipTemplate")

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end
	if event == 'PLAYER_REGEN_DISABLED' then
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	if E.db.general.interruptAnnounce == "NONE" then return end -- No Announcement configured, exit.
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == E.myguid or sourceGUID == UnitGUID('pet'))) then return end -- No announce-able interrupt from player or pet, exit.

	local inGroup, inRaid, inPartyLFG = IsInGroup(), IsInRaid(), IsPartyLFG()
	if not inGroup then return end -- not in group, exit.

	--Skirmish/non-rated arenas need to use INSTANCE_CHAT but IsPartyLFG() returns "false"
	local _, instanceType = IsInInstance()
	if instanceType and instanceType == "arena" then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end
		inRaid = false --IsInRaid() returns true for arenas and they should not be considered a raid
	end

	if E.db.general.interruptAnnounce == "PARTY" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "PARTY")
	elseif E.db.general.interruptAnnounce == "RAID" then
		if inRaid then
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "RAID")
		else
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "PARTY")
		end
	elseif E.db.general.interruptAnnounce == "RAID_ONLY" then
		if inRaid then
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "RAID")
		end
	elseif E.db.general.interruptAnnounce == "SAY" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), "SAY")
	elseif E.db.general.interruptAnnounce == "EMOTE" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), "EMOTE")
	end
end

local autoRepairStatus
local function AttemptAutoRepair(playerOverride)
	autoRepairStatus = ""
	local autoRepair = E.db.general.autoRepair
	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney();
	--This check evaluates to true even if the guild bank has 0 gold, so we add an override
	if autoRepair == 'GUILD' and ((not CanGuildBankRepair() or cost > withdrawLimit) or playerOverride) then
		autoRepair = 'PLAYER'
	end

	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == 'GUILD')

			--Delay this a bit so we have time to catch the outcome of first repair attempt
			C_Timer_After(0.5, function()
				if autoRepair == 'GUILD' then
					if autoRepairStatus == "GUILD_REPAIR_FAILED" then
						AttemptAutoRepair(true) --Try using player money instead
					else
						E:Print(L["Your items have been repaired using guild bank funds for: "]..E:FormatMoney(cost, "SMART", true)) --Amount, style, textOnly
					end
				elseif autoRepair == "PLAYER" then
					if autoRepairStatus == "PLAYER_REPAIR_FAILED" then
						E:Print(L["You don't have enough money to repair."])
					else
						E:Print(L["Your items have been repaired for: "]..E:FormatMoney(cost, "SMART", true)) --Amount, style, textOnly
					end
				end
			end)
		end
	end
end

local function VendorGrays()
	E:GetModule('Bags'):VendorGrays()
end

function M:UI_ERROR_MESSAGE(_, messageType)
	if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		autoRepairStatus = "GUILD_REPAIR_FAILED"
	elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
		autoRepairStatus = "PLAYER_REPAIR_FAILED"
	end
end

function M:MERCHANT_CLOSED()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_CLOSED")
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then
		C_Timer_After(0.5, VendorGrays)
	end

	local autoRepair = E.db.general.autoRepair
	if IsShiftKeyDown() or autoRepair == 'NONE' or not CanMerchantRepair() then return end

	--Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")
	--Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	AttemptAutoRepair()
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid("player") then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if UnitExists("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end
	local _, instanceType = IsInInstance()
	if instanceType == 'pvp' or instanceType == 'arena' then
		RaidNotice_AddMessage(_G.RaidBossEmoteFrame, msg, _G.ChatTypeInfo["RAID_BOSS_EMOTE"]);
	end
end

local hideStatic = false;
local PLAYER_REALM = gsub(E.myrealm,'[%s%-]','');
function M:AutoInvite(event, leaderName)
	if not E.db.general.autoAcceptInvite then return; end

	if event == "PARTY_INVITE_REQUEST" then
		if _G.QueueStatusMinimapButton:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if IsInGroup() then return end
		hideStatic = true

		-- Update Guild and Friendlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end

		local friendName, guildMemberName, memberName, numGameAccounts, isOnline, accountName, bnToonName, bnClient, bnRealm, bnAcceptedInvite, _;
		local inGroup = false;

		for friendIndex = 1, GetNumFriends() do
			friendName = GetFriendInfo(friendIndex) --this is already stripped of your own realm
			if friendName and (friendName == leaderName) then
				AcceptGroup()
				inGroup = true
				break
			end
		end

		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				guildMemberName = GetGuildRosterInfo(guildIndex)
				memberName = guildMemberName and gsub(guildMemberName, '%-'..PLAYER_REALM, '')
				if memberName and (memberName == leaderName) then
					AcceptGroup()
					inGroup = true
					break
				end
			end
		end

		if not inGroup then
			for bnIndex = 1, BNGetNumFriends() do
				_, accountName, _, _, _, _, _, isOnline = BNGetFriendInfo(bnIndex);
				if isOnline then
					if accountName and (accountName == leaderName) then
						AcceptGroup()
						bnAcceptedInvite = true
					end
					if not bnAcceptedInvite then
						numGameAccounts = BNGetNumFriendGameAccounts(bnIndex);
						if numGameAccounts > 0 then
							for toonIndex = 1, numGameAccounts do
								_, bnToonName, bnClient, bnRealm = BNGetFriendGameAccountInfo(bnIndex, toonIndex);
								if bnClient == BNET_CLIENT_WOW then
									if bnRealm and bnRealm ~= '' and bnRealm ~= PLAYER_REALM then
										bnToonName = format('%s-%s', bnToonName, bnRealm)
									end
									if bnToonName and (bnToonName == leaderName) then
										AcceptGroup()
										bnAcceptedInvite = true
										break
									end
								end
							end
						end
					end
					if bnAcceptedInvite then
						break
					end
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic == true then
		StaticPopupSpecial_Hide(_G.LFGInvitePopup) --New LFD popup when invited in custom created group
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = false
	end
end

function M:ForceCVars()
	if not GetCVarBool('lockActionBars') and E.private.actionbar.enable then
		SetCVar('lockActionBars', 1)
	end
end

function M:PLAYER_ENTERING_WORLD()
	self:ForceCVars()
	self:ToggleChatBubbleScript()
end

local InspectItems = {
	"InspectHeadSlot",
	"InspectNeckSlot",
	"InspectShoulderSlot",
	"",
	"InspectChestSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectFinger0Slot",
	"InspectFinger1Slot",
	"InspectTrinket0Slot",
	"InspectTrinket1Slot",
	"InspectBackSlot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
}

function M:CreateSlotTexture(slot, x, y)
	local texture = _G[slot]:CreateTexture()
	texture:Point("BOTTOM", _G[slot], x, y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)
	return texture
end

function M:GetItemLevelPoints(id)
	if not id then return end

	if id <= 5 or (id == 9 or id == 15) then
		return 40, 3, 18, "BOTTOMLEFT" -- Left side
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then
		return -40, 3, 18, "BOTTOMRIGHT" -- Right side
	else
		return 0, 45, 60, "BOTTOM"
	end
end

function M:UpdateItemLevel()
	if not (_G.InspectFrame and _G.InspectFrame.ItemLevelText) then return end
	local unit = _G.InspectFrame.unit or "target"
	local iLevel, count = 0, 0

	for i=1, 17 do
		if i ~= 4 then
			local inspectItem = _G[InspectItems[i]]
			inspectItem.enchantText:SetText()
			inspectItem.iLvlText:SetText()

			ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
			ScanTooltip:SetInventoryItem(unit, i)
			ScanTooltip:Show()

			for y=1, 10 do
				inspectItem['textureSlot'..y]:SetTexture()
				local texture = _G["ElvUI_InspectTooltipTexture"..y]
				local hasTexture = texture and texture:GetTexture()
				if hasTexture then
					inspectItem['textureSlot'..y]:SetTexture(hasTexture)
					texture:SetTexture()
				end
			end

			for x = 1, ScanTooltip:NumLines() do
				local line = _G["ElvUI_InspectTooltipTextLeft"..x]
				if line then
					local lineText = line:GetText()
					local lr, lg, lb = line:GetTextColor()
					local tr, tg, tb = _G.ElvUI_InspectTooltipTextLeft1:GetTextColor()
					local iLvl = lineText:match(MATCH_ITEM_LEVEL)
					local enchant = lineText:match(MATCH_ENCHANT)
					if enchant then
						inspectItem.enchantText:SetText(enchant:sub(1,20))
						inspectItem.enchantText:SetTextColor(lr, lg, lb)
					end
					if iLvl and iLvl ~= "1" then
						inspectItem.iLvlText:SetText(iLvl)
						inspectItem.iLvlText:SetTextColor(tr, tg, tb)
						count, iLevel = count + 1, iLevel + tonumber(iLvl)
					end
				end
			end

			ScanTooltip:Hide()
		end
	end

	if iLevel > 0 then
		local itemLevelAverage = E:Round(iLevel / count)
		_G.InspectFrame.ItemLevelText:SetFormattedText(L["Gear Score: %d"], itemLevelAverage)
	else
		_G.InspectFrame.ItemLevelText:SetText('')
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_InspectUI" then
		_G.InspectFrame.ItemLevelText = _G.InspectFrame:CreateFontString(nil, "ARTWORK")
		_G.InspectFrame.ItemLevelText:Point("BOTTOMRIGHT", _G.InspectFrame, "BOTTOMRIGHT", -6, 6)
		_G.InspectFrame.ItemLevelText:FontTemplate(nil, 12)

		for i, slot in pairs(InspectItems) do
			if i ~= 4 then
				local x, y, z, justify = M:GetItemLevelPoints(i)
				_G[slot].iLvlText = _G[slot]:CreateFontString(nil, "OVERLAY")
				_G[slot].iLvlText:FontTemplate(nil, 12)
				_G[slot].iLvlText:Point("BOTTOM", _G[slot], x, y)

				_G[slot].enchantText = _G[slot]:CreateFontString(nil, "OVERLAY")
				_G[slot].enchantText:FontTemplate(nil, 11)

				if i == 16 or i == 17 then
					_G[slot].enchantText:Point(i==16 and "BOTTOMRIGHT" or "BOTTOMLEFT", _G[slot], i==16 and -40 or 40, 3)
				else
					_G[slot].enchantText:Point(justify, _G[slot], x + (justify == "BOTTOMLEFT" and 5 or -5), z)
				end

				for u=1, 10 do
					local offset = 8+(u*16)
					--local newY = (justify == "BOTTOM" and y+(offset*1.2)) or y
					local newX = --[[(justify == "BOTTOM" and 0) or]] (justify == "BOTTOMRIGHT" and x-offset) or x+offset
					_G[slot]['textureSlot'..u] = M:CreateSlotTexture(slot, newX, --[[newY or]] y)
				end
			end
		end

		self:UnregisterEvent("ADDON_LOADED")
	end
end

function M:Initialize()
	self:LoadRaidMarker()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:LoadLoot()
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('INSPECT_READY', 'UpdateItemLevel')
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL', 'PVPMessageEnhancement')
	self:RegisterEvent('PARTY_INVITE_REQUEST', 'AutoInvite')
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'AutoInvite')
	self:RegisterEvent('CVAR_UPDATE', 'ForceCVars')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')

	if IsAddOnLoaded("Blizzard_InspectUI") then
		self:ADDON_LOADED(nil, "Blizzard_InspectUI")
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)
