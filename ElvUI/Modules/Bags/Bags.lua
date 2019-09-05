local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Bags')
local TT = E:GetModule('Tooltip')
local Skins = E:GetModule('Skins')
local Search = E.Libs.ItemSearch

--Lua functions
local _G = _G
local type, ipairs, pairs, unpack, select, assert, pcall = type, ipairs, pairs, unpack, select, assert, pcall
local tinsert, tremove, twipe, tmaxn = tinsert, tremove, wipe, table.maxn
local floor, ceil, abs = floor, ceil, abs
local format, sub = format, strsub
local tonumber = tonumber
--WoW API / Variables
local BankFrameItemButton_Update = BankFrameItemButton_Update
local BankFrameItemButton_UpdateLocked = BankFrameItemButton_UpdateLocked
local CloseBag, CloseBackpack, CloseBankFrame = CloseBag, CloseBackpack, CloseBankFrame
local ContainerIDToInventoryID = ContainerIDToInventoryID
local CooldownFrame_Set = CooldownFrame_Set
local CreateFrame = CreateFrame
local DeleteCursorItem = DeleteCursorItem
local DepositReagentBank = DepositReagentBank
local GameTooltip_Hide = GameTooltip_Hide
local GetBackpackAutosortDisabled = GetBackpackAutosortDisabled
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetBagSlotFlag = GetBagSlotFlag
local GetBankAutosortDisabled = GetBankAutosortDisabled
local GetBankBagSlotFlag = GetBankBagSlotFlag
local GetContainerItemCooldown = GetContainerItemCooldown
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetCurrencyLink = GetCurrencyLink
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetCVarBool = GetCVarBool
local GetGuildBankItemLink = GetGuildBankItemLink
local GetGuildBankTabInfo = GetGuildBankTabInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMoney = GetMoney
local GetNumBankSlots = GetNumBankSlots
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local HandleModifiedItemClick = HandleModifiedItemClick
local IsBagOpen, IsOptionFrameOpen = IsBagOpen, IsOptionFrameOpen
local IsInventoryItemProfessionBag = IsInventoryItemProfessionBag
local IsModifiedClick = IsModifiedClick
local IsReagentBankUnlocked = IsReagentBankUnlocked
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local PickupContainerItem = PickupContainerItem
local PlaySound = PlaySound
local PutItemInBackpack = PutItemInBackpack
local PutItemInBag = PutItemInBag
local SetBackpackAutosortDisabled = SetBackpackAutosortDisabled
local SetBagSlotFlag = SetBagSlotFlag
local SetBankAutosortDisabled = SetBankAutosortDisabled
local SetBankBagSlotFlag = SetBankBagSlotFlag
local SetInsertItemsLeftToRight = SetInsertItemsLeftToRight
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local SetItemButtonTexture = SetItemButtonTexture
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
local SortBags = SortBags
local SortBankBags = SortBankBags
local SortReagentBankBags = SortReagentBankBags
local StaticPopup_Show = StaticPopup_Show
local ToggleFrame = ToggleFrame
local UseContainerItem = UseContainerItem

local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_Item_CanScrapItem = C_Item.CanScrapItem
local C_Item_DoesItemExist = C_Item.DoesItemExist
local C_NewItems_IsNewItem = C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = C_NewItems.RemoveNewItem
local hooksecurefunc = hooksecurefunc

local BAG_FILTER_ASSIGN_TO = BAG_FILTER_ASSIGN_TO
local BAG_FILTER_CLEANUP = BAG_FILTER_CLEANUP
local BAG_FILTER_IGNORE = BAG_FILTER_IGNORE
local BAG_FILTER_LABELS = BAG_FILTER_LABELS
local CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y = CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y
local CONTAINER_SCALE = CONTAINER_SCALE
local CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING = CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING
local CONTAINER_WIDTH = CONTAINER_WIDTH
local IG_BACKPACK_CLOSE = SOUNDKIT.IG_BACKPACK_CLOSE
local IG_BACKPACK_OPEN = SOUNDKIT.IG_BACKPACK_OPEN
local LE_BAG_FILTER_FLAG_EQUIPMENT = LE_BAG_FILTER_FLAG_EQUIPMENT
local LE_BAG_FILTER_FLAG_IGNORE_CLEANUP = LE_BAG_FILTER_FLAG_IGNORE_CLEANUP
local LE_BAG_FILTER_FLAG_JUNK = LE_BAG_FILTER_FLAG_JUNK
local LE_ITEM_QUALITY_COMMON = LE_ITEM_QUALITY_COMMON
local LE_ITEM_QUALITY_POOR = LE_ITEM_QUALITY_POOR
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local NUM_LE_BAG_FILTER_FLAGS = NUM_LE_BAG_FILTER_FLAGS
local REAGENTBANK_CONTAINER = REAGENTBANK_CONTAINER
local REAGENTBANK_PURCHASE_TEXT = REAGENTBANK_PURCHASE_TEXT
local SEARCH = SEARCH
-- GLOBALS: ElvUIBags, ElvUIBagMover, ElvUIBankMover, ElvUIReagentBankFrame, ElvUIReagentBankFrameItem1

local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub('%%d', '(%%d+)')

local ElvUIAssignBagDropdown
local SEARCH_STRING = ""
local BAG_FILTER_ICONS = {
	[_G.LE_BAG_FILTER_FLAG_EQUIPMENT] = "Interface\\ICONS\\INV_Chest_Plate10",
	[_G.LE_BAG_FILTER_FLAG_CONSUMABLES] = "Interface\\ICONS\\INV_Potion_93",
	[_G.LE_BAG_FILTER_FLAG_TRADE_GOODS] = "Interface\\ICONS\\INV_Fabric_Silk_02",
}

function B:GetContainerFrame(arg)
	if type(arg) == 'boolean' and (arg == true) then
		return B.BankFrame
	elseif type(arg) == 'number' then
		if B.BankFrame then
			for _, bagID in ipairs(B.BankFrame.BagIDs) do
				if bagID == arg then
					return B.BankFrame
				end
			end
		end
	end

	return B.BagFrame
end

function B:Tooltip_Show()
	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)

	if self.ttText2 then
		if self.ttText2desc then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(self.ttText2, self.ttText2desc, 1, 1, 1)
		else
			GameTooltip:AddLine(self.ttText2)
		end
	end

	GameTooltip:Show()
end

function B:DisableBlizzard()
	_G.BankFrame:UnregisterAllEvents()

	for i=1, NUM_CONTAINER_FRAMES do
		_G['ContainerFrame'..i]:Kill()
	end
end

function B:SearchReset()
	SEARCH_STRING = ""
end

function B:IsSearching()
	return SEARCH_STRING ~= "" and SEARCH_STRING ~= SEARCH
end

function B:UpdateSearch()
	local search = self:GetText()
	if self.Instructions then
		self.Instructions:SetShown(search == "")
	end

	local MIN_REPEAT_CHARACTERS = 3
	local prevSearch = SEARCH_STRING
	if #search > MIN_REPEAT_CHARACTERS then
		local repeatChar = true
		for i=1, MIN_REPEAT_CHARACTERS, 1 do
			if sub(search,(0-i), (0-i)) ~= sub(search,(-1-i),(-1-i)) then
				repeatChar = false
				break
			end
		end

		if repeatChar then
			B:ResetAndClear()
			return
		end
	end

	--Keep active search term when switching between bank and reagent bank
	if search == SEARCH and prevSearch ~= "" then
		search = prevSearch
	elseif search == SEARCH then
		search = ''
	end

	SEARCH_STRING = search

	B:RefreshSearch()
	B:SetGuildBankSearch(SEARCH_STRING)
end

function B:OpenEditbox()
	B.BagFrame.detail:Hide()
	B.BagFrame.editBox:Show()
	B.BagFrame.editBox:SetText(SEARCH)
	B.BagFrame.editBox:HighlightText()
end

function B:ResetAndClear()
	B.BagFrame.editBox:SetText(SEARCH)
	B.BagFrame.editBox:ClearFocus()

	if B.BankFrame then
		B.BankFrame.editBox:SetText(SEARCH)
		B.BankFrame.editBox:ClearFocus()
	end

	B:SearchReset()
end

function B:SetSearch(query)
	local empty = #(query:gsub(' ', '')) == 0
	local method = Search.Matches
	if Search.Filters.tipPhrases.keywords[query] then
		method = Search.TooltipPhrase
		query = Search.Filters.tipPhrases.keywords[query]
	end

	for _, bagFrame in pairs(B.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, link = GetContainerItemInfo(bagID, slotID)
				local button = bagFrame.Bags[bagID][slotID]
				local success, result = pcall(method, Search, link, query)
				if empty or (success and result) then
					SetItemButtonDesaturated(button, button.locked or button.junkDesaturate)
					button.searchOverlay:Hide()
					button:SetAlpha(1)
				else
					SetItemButtonDesaturated(button, 1)
					button.searchOverlay:Show()
					button:SetAlpha(0.5)
				end
			end
		end
	end

	if ElvUIReagentBankFrameItem1 then
		for slotID = 1, B.REAGENTBANK_SIZE do
			local _, _, _, _, _, _, link = GetContainerItemInfo(REAGENTBANK_CONTAINER, slotID)
			local button = _G["ElvUIReagentBankFrameItem"..slotID]
			local success, result = pcall(method, Search, link, query)
			if empty or (success and result) then
				SetItemButtonDesaturated(button, button.locked or button.junkDesaturate)
				button.searchOverlay:Hide()
				button:SetAlpha(1)
			else
				SetItemButtonDesaturated(button, 1)
				button.searchOverlay:Show()
				button:SetAlpha(0.5)
			end
		end
	end
end

function B:SetGuildBankSearch(query)
	local empty = #(query:gsub(' ', '')) == 0
	local method = Search.Matches
	if Search.Filters.tipPhrases.keywords[query] then
		method = Search.TooltipPhrase
		query = Search.Filters.tipPhrases.keywords[query]
	end

	if _G.GuildBankFrame and _G.GuildBankFrame:IsShown() then
		local tab = GetCurrentGuildBankTab()
		local _, _, isViewable = GetGuildBankTabInfo(tab)

		if isViewable then
			for slotID = 1, _G.MAX_GUILDBANK_SLOTS_PER_TAB do
				local link = GetGuildBankItemLink(tab, slotID)
				--A column goes from 1-14, e.g. GuildBankColumn1Button14 (slotID 14) or GuildBankColumn2Button3 (slotID 17)
				local col = ceil(slotID / 14)
				local btn = (slotID % 14)
				if col == 0 then col = 1 end
				if btn == 0 then btn = 14 end
				local button = _G["GuildBankColumn"..col.."Button"..btn]
				local success, result = pcall(method, Search, link, query)
				if empty or (success and result) then
					SetItemButtonDesaturated(button, button.locked or button.junkDesaturate)
					button.searchOverlay:Hide()
					button:SetAlpha(1)
				else
					SetItemButtonDesaturated(button, 1)
					button.searchOverlay:Show()
					button:SetAlpha(0.5)
				end
			end
		end
	end
end

function B:UpdateItemLevelDisplay()
	if E.private.bags.enable ~= true then return end
	for _, bagFrame in pairs(B.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = bagFrame.Bags[bagID][slotID]
				if slot and slot.itemLevel then
					slot.itemLevel:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
				end
			end
		end

		B:UpdateAllSlots(bagFrame)
	end
end

function B:UpdateCountDisplay()
	if E.private.bags.enable ~= true then return end
	local color = E.db.bags.countFontColor

	for _, bagFrame in pairs(B.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = bagFrame.Bags[bagID][slotID]
				if slot and slot.Count then
					slot.Count:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
					slot.Count:SetTextColor(color.r, color.g, color.b)
				end
			end
		end

		B:UpdateAllSlots(bagFrame)
	end

	--Reagent Bank
	if B.BankFrame and B.BankFrame.reagentFrame then
		for i = 1, B.REAGENTBANK_SIZE do
			local slot = B.BankFrame.reagentFrame.slots[i]
			if slot then
				slot.Count:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
				slot.Count:SetTextColor(color.r, color.g, color.b)
				B:UpdateReagentSlot(i)
			end
		end
	end
end

function B:UpdateBagTypes(isBank)
	local f = B:GetContainerFrame(isBank)
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			f.Bags[bagID].type = select(2, GetContainerNumFreeSlots(bagID))
		end
	end
end

function B:UpdateAllBagSlots()
	if E.private.bags.enable ~= true then return end

	for _, bagFrame in pairs(B.BagFrames) do
		B:UpdateAllSlots(bagFrame)
	end
end

function B:IsItemEligibleForItemLevelDisplay(classID, subClassID, equipLoc, rarity)
	if ((classID == 3 and subClassID == 11) --Artifact Relics
	or (equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_BAG"
		and equipLoc ~= "INVTYPE_QUIVER" and equipLoc ~= "INVTYPE_TABARD"))
	and (rarity and rarity > 1) then
		return true
	end

	return false
end

function B:UpdateItemUpgradeIcon(slot)
	if not E.db.bags.upgradeIcon then
		slot.UpgradeIcon:SetShown(false)
		slot:SetScript("OnUpdate", nil)
		return
	end

	local itemIsUpgrade = _G.IsContainerItemAnUpgrade(slot:GetParent():GetID(), slot:GetID())
	if itemIsUpgrade == nil then -- nil means not all the data was available to determine if this is an upgrade.
		slot.UpgradeIcon:SetShown(false)
		slot:SetScript("OnUpdate", B.UpgradeCheck_OnUpdate)
	else
		slot.UpgradeIcon:SetShown(itemIsUpgrade)
		slot:SetScript("OnUpdate", nil)
	end
end

local ITEM_UPGRADE_CHECK_TIME = 0.5
function B:UpgradeCheck_OnUpdate(elapsed)
	self.timeSinceUpgradeCheck = (self.timeSinceUpgradeCheck or 0) + elapsed
	if self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME then
		B:UpdateItemUpgradeIcon(self)
	end
end

function B:UpdateItemScrapIcon(slot)
	if not E.db.bags.scrapIcon then
		slot.ScrapIcon:SetShown(false)
		return
	end

	local itemLoc = _G.ItemLocation:CreateFromBagAndSlot(slot:GetParent():GetID(), slot:GetID())
	if itemLoc and itemLoc ~= "" then
		if E.db.bags.scrapIcon and (C_Item_DoesItemExist(itemLoc) and C_Item_CanScrapItem(itemLoc)) then
			slot.ScrapIcon:SetShown(itemLoc)
		else
			slot.ScrapIcon:SetShown(false)
		end
	end
end

function B:SCRAPPING_MACHINE_SHOW()
	E:Delay(0.1, B.Layout, B)
end

function B:SCRAPPING_MACHINE_CLOSE()
	E:Delay(0.1, B.Layout, B)
end

function B:NewItemGlowSlotSwitch(slot, show)
	if slot and slot.newItemGlow then
		if show then
			slot.newItemGlow:Show()

			local bank = slot:GetParent().isBank and B.BankFrame
			B:ShowItemGlow(bank or B.BagFrame, slot.newItemGlow)
		else
			slot.newItemGlow:Hide()

			-- also clear them on blizzard's side
			if slot.bagID and slot.slotID then
				C_NewItems_RemoveNewItem(slot.bagID, slot.slotID)
			end
		end
	end
end

function B:NewItemGlowBagClear(bagFrame)
	if not (bagFrame and bagFrame.BagIDs) then return end

	for _, bagID in ipairs(bagFrame.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			if bagFrame.Bags[bagID][slotID] then
				B:NewItemGlowSlotSwitch(bagFrame.Bags[bagID][slotID])
			end
		end
	end
end

function B:HideSlotItemGlow()
	B:NewItemGlowSlotSwitch(self)
end

function B:CheckSlotNewItem(slot, bagID, slotID)
	B:NewItemGlowSlotSwitch(slot, C_NewItems_IsNewItem(bagID, slotID))
end

function B:UpdateSlot(frame, bagID, slotID)
	if (frame.Bags[bagID] and frame.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or not frame.Bags[bagID] or not frame.Bags[bagID][slotID] then
		return
	end

	local slot = frame.Bags[bagID][slotID]
	local bagType = frame.Bags[bagID].type

	local assignedID = bagID
	local assignedBag = frame.Bags[assignedID] and frame.Bags[assignedID].assigned

	local texture, count, locked, rarity, readable, _, _, _, noValue = GetContainerItemInfo(bagID, slotID)
	slot.name, slot.rarity, slot.locked = nil, rarity, locked

	local clink = GetContainerItemLink(bagID, slotID)

	slot:Show()
	if slot.questIcon then
		slot.questIcon:Hide()
	end

	if slot.Azerite then
		slot.Azerite:Hide()
	end

	slot.isJunk = (slot.rarity and slot.rarity == LE_ITEM_QUALITY_POOR) and not noValue
	slot.junkDesaturate = slot.isJunk and E.db.bags.junkDesaturate

	if slot.JunkIcon then
		if slot.isJunk and E.db.bags.junkIcon then
			slot.JunkIcon:Show()
		else
			slot.JunkIcon:Hide()
		end
	end

	if slot.ScrapIcon then
		B:UpdateItemScrapIcon(slot)
	end

	slot:UpdateItemContextMatching() -- Blizzards way to highlight scrapable items if the Scrapping Machine Frame is open.

	if slot.UpgradeIcon then
		--Check if item is an upgrade and show/hide upgrade icon accordingly
		B:UpdateItemUpgradeIcon(slot)
	end

	slot.itemLevel:SetText('')
	slot.bindType:SetText('')

	local professionColors = B.ProfessionColors[bagType]
	local showItemLevel = B.db.itemLevel and clink and not professionColors
	local showBindType = B.db.showBindType and (slot.rarity and slot.rarity > LE_ITEM_QUALITY_COMMON)
	if showBindType or showItemLevel then
		E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
		if slot.GetInventorySlot then -- this fixes bank bagid -1
			E.ScanTooltip:SetInventoryItem("player", slot:GetInventorySlot())
		else
			E.ScanTooltip:SetBagItem(bagID, slotID)
		end
		E.ScanTooltip:Show()
	end

	if professionColors then
		local r, g, b = unpack(professionColors)
		slot.newItemGlow:SetVertexColor(r, g, b)
		slot:SetBackdropBorderColor(r, g, b)
		slot.ignoreBorderColors = true
	elseif clink then
		local name, _, itemRarity, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = GetItemInfo(clink)
		slot.name = name

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID)
		local r, g, b

		if slot.rarity or itemRarity then
			r, g, b = GetItemQualityColor(slot.rarity or itemRarity)
		end

		if showBindType or showItemLevel then
			local colorblind = GetCVarBool('colorblindmode')
			local canShowItemLevel = showItemLevel and B:IsItemEligibleForItemLevelDisplay(itemClassID, itemSubClassID, itemEquipLoc, slot.rarity)
			local itemLevelLines, bindTypeLines = colorblind and 4 or 3, colorblind and 8 or 7
			local iLvl, BoE, BoU --GetDetailedItemLevelInfo this api dont work for some time correctly for ilvl

			for i = 2, bindTypeLines do
				local line = _G["ElvUI_ScanTooltipTextLeft"..i]:GetText()
				if not line or line == "" then break end
				if canShowItemLevel and (i <= itemLevelLines) then
					local itemLevel = line:match(MATCH_ITEM_LEVEL)
					if itemLevel then iLvl = tonumber(itemLevel) end
				end
				if showBindType then
					-- as long as we check the ilvl first, we can savely break on these because they fall after ilvl
					if line == _G.ITEM_SOULBOUND or line == _G.ITEM_ACCOUNTBOUND or line == _G.ITEM_BNETACCOUNTBOUND then break end
					BoE, BoU = line == _G.ITEM_BIND_ON_EQUIP, line == _G.ITEM_BIND_ON_USE
				end
				if ((not showBindType) or (BoE or BoU)) and ((not canShowItemLevel) or iLvl) then
					break
				end
			end

			if BoE or BoU then
				slot.bindType:SetText(BoE and L["BoE"] or L["BoU"])
				slot.bindType:SetVertexColor(r, g, b)
			end

			if iLvl and iLvl >= B.db.itemLevelThreshold then
				slot.itemLevel:SetText(iLvl)
				if B.db.itemLevelCustomColorEnable then
					slot.itemLevel:SetTextColor(B.db.itemLevelCustomColor.r, B.db.itemLevelCustomColor.g, B.db.itemLevelCustomColor.b)
				else
					slot.itemLevel:SetTextColor(r, g, b)
				end
			end
		end

		-- color slot according to item quality
		if questId and not isActiveQuest then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questStarter))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questStarter))
			slot.ignoreBorderColors = true
			if(slot.questIcon) then
				slot.questIcon:Show()
			end
		elseif questId or isQuestItem then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questItem))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
			slot.ignoreBorderColors = true
		elseif B.db.qualityColors and slot.rarity and slot.rarity > LE_ITEM_QUALITY_COMMON then
			slot.newItemGlow:SetVertexColor(r, g, b)
			slot:SetBackdropBorderColor(r, g, b)
			slot.ignoreBorderColors = true
		elseif B.db.showAssignedColor and B.AssignmentColors[assignedBag] then
			local rr, gg, bb = unpack(B.AssignmentColors[assignedBag])
			slot.newItemGlow:SetVertexColor(rr, gg, bb)
			slot:SetBackdropBorderColor(rr, gg, bb)
			slot.ignoreBorderColors = true
		else
			local rr, gg, bb = unpack(E.media.bordercolor)
			slot.newItemGlow:SetVertexColor(rr, gg, bb)
			slot:SetBackdropBorderColor(rr, gg, bb)
			slot.ignoreBorderColors = nil
		end

		if slot.Azerite and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(clink) then slot.Azerite:Show() end
	elseif B.db.showAssignedColor and B.AssignmentColors[assignedBag] then
		local rr, gg, bb = unpack(B.AssignmentColors[assignedBag])
		slot.newItemGlow:SetVertexColor(rr, gg, bb)
		slot:SetBackdropBorderColor(rr, gg, bb)
		slot.ignoreBorderColors = true
	else
		local rr, gg, bb = unpack(E.media.bordercolor)
		slot.newItemGlow:SetVertexColor(rr, gg, bb)
		slot:SetBackdropBorderColor(rr, gg, bb)
		slot.ignoreBorderColors = nil
	end

	E.ScanTooltip:Hide()

	if E.db.bags.newItemGlow then
		E:Delay(0.1, B.CheckSlotNewItem, B, slot, bagID, slotID)
	end

	if texture then
		local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
		CooldownFrame_Set(slot.cooldown, start, duration, enable)
		if duration > 0 and enable == 0 then
			SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4)
		else
			SetItemButtonTextureVertexColor(slot, 1, 1, 1)
		end
		slot.hasItem = 1
	else
		slot.cooldown:Hide()
		slot.hasItem = nil
	end

	slot.readable = readable

	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, slot.locked or slot.junkDesaturate)

	if _G.GameTooltip:GetOwner() == slot and not slot.hasItem then
		GameTooltip_Hide()
	end
end

function B:UpdateBagSlots(frame, bagID)
	if bagID == REAGENTBANK_CONTAINER then
		for i=1, B.REAGENTBANK_SIZE do
			B:UpdateReagentSlot(i)
		end
	else
		for slotID = 1, GetContainerNumSlots(bagID) do
			B:UpdateSlot(frame, bagID, slotID)
		end
	end
end

function B:RefreshSearch()
	B:SetSearch(SEARCH_STRING)
end

function B:SortingFadeBags(bagFrame, registerUpdate)
	if not (bagFrame and bagFrame.BagIDs) then return end
	bagFrame.registerUpdate = registerUpdate

	for _, bagID in ipairs(bagFrame.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local button = bagFrame.Bags[bagID][slotID]
			SetItemButtonDesaturated(button, 1)
			button.searchOverlay:Show()
			button:SetAlpha(0.5)
		end
	end
end

function B:UpdateCooldowns(frame)
	if not (frame and frame.BagIDs) then return end

	for _, bagID in ipairs(frame.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
			CooldownFrame_Set(frame.Bags[bagID][slotID].cooldown, start, duration, enable, _, _)
		end
	end
end

function B:UpdateAllSlots(frame)
	if not (frame and frame.BagIDs) then return end

	for _, bagID in ipairs(frame.BagIDs) do
		local bag = frame.Bags[bagID]
		if bag then B:UpdateBagSlots(frame, bagID) end
	end

	-- Refresh search in case we moved items around
	if not frame.registerUpdate and B:IsSearching() then
		B:RefreshSearch()
	end
end

function B:SetSlotAlphaForBag(f)
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			local numSlots = GetContainerNumSlots(bagID)
			for slotID = 1, numSlots do
				if f.Bags[bagID][slotID] then
					if bagID == self.id then
						f.Bags[bagID][slotID]:SetAlpha(1)
					else
						f.Bags[bagID][slotID]:SetAlpha(0.1)
					end
				end
			end
		end
	end
end

function B:ResetSlotAlphaForBags(f)
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			local numSlots = GetContainerNumSlots(bagID)
			for slotID = 1, numSlots do
				if f.Bags[bagID][slotID] then
					f.Bags[bagID][slotID]:SetAlpha(1)
				end
			end
		end
	end
end

function B:REAGENTBANK_PURCHASED()
	ElvUIReagentBankFrame.cover:Hide()
end

--Look at ContainerFrameFilterDropDown_Initialize in FrameXML/ContainerFrame.lua
function B:AssignBagFlagMenu()
	local holder = ElvUIAssignBagDropdown.holder
	ElvUIAssignBagDropdown.holder = nil

	if not (holder and holder.id) then return end

	local info = _G.UIDropDownMenu_CreateInfo()
	if holder.id > 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(holder.id)) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
		info.text = BAG_FILTER_ASSIGN_TO
		info.isTitle = 1
		info.notCheckable = 1
		_G.UIDropDownMenu_AddButton(info)

		info.isTitle = nil
		info.notCheckable = nil
		info.tooltipWhileDisabled = 1
		info.tooltipOnButton = 1

		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			if i ~= LE_BAG_FILTER_FLAG_JUNK then
				info.text = BAG_FILTER_LABELS[i]
				info.func = function(_, _, _, value)
					value = not value

					if holder.id > NUM_BAG_SLOTS then
						SetBankBagSlotFlag(holder.id - NUM_BAG_SLOTS, i, value)
					else
						SetBagSlotFlag(holder.id, i, value)
					end

					if value then
						holder.tempflag = i
						holder.ElvUIFilterIcon.Icon:SetTexture(BAG_FILTER_ICONS[i])
						holder.ElvUIFilterIcon.Icon:SetTexCoord(unpack(E.TexCoords))
						holder.ElvUIFilterIcon:Show()
					else
						holder.ElvUIFilterIcon:Hide()
						holder.tempflag = -1
					end
				end

				if holder.tempflag then
					info.checked = holder.tempflag == i
				else
					if holder.id > NUM_BAG_SLOTS then
						info.checked = GetBankBagSlotFlag(holder.id - NUM_BAG_SLOTS, i)
					else
						info.checked = GetBagSlotFlag(holder.id, i)
					end
				end

				info.disabled = nil
				info.tooltipTitle = nil
				_G.UIDropDownMenu_AddButton(info)
			end
		end
	end

	info.text = BAG_FILTER_CLEANUP
	info.isTitle = 1
	info.notCheckable = 1
	_G.UIDropDownMenu_AddButton(info)

	info.isTitle = nil
	info.notCheckable = nil
	info.isNotRadio = true
	info.disabled = nil

	info.text = BAG_FILTER_IGNORE
	info.func = function(_, _, _, value)
		if holder.id == -1 then
			SetBankAutosortDisabled(not value)
		elseif holder.id == 0 then
			SetBackpackAutosortDisabled(not value)
		elseif holder.id > NUM_BAG_SLOTS then
			SetBankBagSlotFlag(holder.id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value)
		else
			SetBagSlotFlag(holder.id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value)
		end
	end
	if (holder.id == -1) then
		info.checked = GetBankAutosortDisabled()
	elseif (holder.id == 0) then
		info.checked = GetBackpackAutosortDisabled()
	elseif (holder.id > NUM_BAG_SLOTS) then
		info.checked = GetBankBagSlotFlag(holder.id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
	else
		info.checked = GetBagSlotFlag(holder.id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
	end

	_G.UIDropDownMenu_AddButton(info)
end

function B:GetBagAssignedInfo(holder)
	if not (holder and holder.id and holder.id > 0) then return end

	local inventoryID = ContainerIDToInventoryID(holder.id)
	if IsInventoryItemProfessionBag("player", inventoryID) then return end

	-- clear tempflag from AssignBagFlagMenu
	if holder.tempflag then holder.tempflag = nil end

	local active, color
	for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
		if i ~= LE_BAG_FILTER_FLAG_JUNK then --ignore this one
			if holder.id > NUM_BAG_SLOTS then
				active = GetBankBagSlotFlag(holder.id - NUM_BAG_SLOTS, i)
			else
				active = GetBagSlotFlag(holder.id, i)
			end

			if active then
				color = B.AssignmentColors[i]
				active = (color and i) or 0
				break
			end
		end
	end

	if not active then
		holder:SetBackdropBorderColor(unpack(E.media.bordercolor))
		holder.ignoreBorderColors = nil --restore these borders to be updated
	else
		holder:SetBackdropBorderColor(unpack(color or B.AssignmentColors[0]))
		holder.ignoreBorderColors = true --dont allow these border colors to update for now
		return active
	end
end

function B:Container_OnShow()
	if (self.id and self.id > 0) and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(self.id)) then
		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			local active
			if self.id > NUM_BAG_SLOTS then
				active = GetBankBagSlotFlag(self.id - NUM_BAG_SLOTS, i)
			else
				active = GetBagSlotFlag(self.id, i)
			end
			if active then
				self.ElvUIFilterIcon.Icon:SetTexture(BAG_FILTER_ICONS[i])
				self.ElvUIFilterIcon.Icon:SetTexCoord(unpack(E.TexCoords))
				self.ElvUIFilterIcon:Show()
				break
			end
		end
	end
end

function B:CreateFilterIcon(parent)
	--Create FilterIcon element needed for item type assignment
	parent.ElvUIFilterIcon = CreateFrame("Button", nil, parent)
	parent.ElvUIFilterIcon:Hide()
	parent.ElvUIFilterIcon:Size(18, 18)
	parent.ElvUIFilterIcon:CreateBackdrop("Transparent")
	parent.ElvUIFilterIcon:Point("TOPLEFT", parent, "TOPLEFT", E.Border, -E.Border)
	parent.ElvUIFilterIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	parent.ElvUIFilterIcon:SetScript("OnShow", function(efi)
		efi:SetFrameLevel(efi:GetParent():GetFrameLevel()+1)
	end)

	--Create the texture showing the assignment type
	parent.ElvUIFilterIcon.Icon = parent.ElvUIFilterIcon:CreateTexture(nil, "BORDER")
	parent.ElvUIFilterIcon.Icon:SetTexture("Interface\\ICONS\\INV_Potion_93")
	parent.ElvUIFilterIcon.Icon:SetTexCoord(unpack(E.TexCoords))
	parent.ElvUIFilterIcon.Icon:Size(18, 18)
	parent.ElvUIFilterIcon.Icon:Point("CENTER")

	--Re-route various mouse events to the underlying container bag icon
	parent.ElvUIFilterIcon:SetScript("OnEnter", function(efi)
		local target = efi:GetParent()
		target:GetScript("OnEnter")(target)
	end)
	parent.ElvUIFilterIcon:SetScript("OnLeave", function(efi)
		local target = efi:GetParent()
		target:GetScript("OnLeave")(target)
	end)
	parent.ElvUIFilterIcon:SetScript("OnClick", function(efi, btn)
		local target = efi:GetParent()
		target:GetScript("OnClick")(target, btn)
	end)
	parent.ElvUIFilterIcon:SetScript("OnReceiveDrag", function(efi)
		local target = efi:GetParent()
		target:GetScript("OnReceiveDrag")(target)
	end)

	--Update FilterIcon texture when container is shown
	parent:HookScript("OnShow", B.Container_OnShow)
end

function B:Layout(isBank)
	if E.private.bags.enable ~= true then return end

	local f = B:GetContainerFrame(isBank)
	if not f then return end

	local buttonSize = isBank and B.db.bankSize or B.db.bagSize
	local buttonSpacing = E.Border*2
	local containerWidth = ((isBank and B.db.bankWidth) or B.db.bagWidth)
	local numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing))
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing
	local numContainerRows = 0
	local numBags = 0
	local numBagSlots = 0
	local bagSpacing = B.db.split.bagSpacing
	local countColor = E.db.bags.countFontColor
	local isSplit = B.db.split[isBank and 'bank' or 'player']

	f.holderFrame:Width(holderWidth)
	if isBank then
		f.reagentFrame:Width(holderWidth)
	end

	f.totalSlots = 0
	local lastButton
	local lastRowButton
	local lastContainerButton
	local numContainerSlots = GetNumBankSlots()
	local newBag
	for i, bagID in ipairs(f.BagIDs) do
		local assignedBag
		if isSplit then
			newBag = (bagID ~= -1 or bagID ~= 0) and B.db.split['bag'..bagID] or false
		end

		--Bag Containers
		if (not isBank) or (isBank and bagID ~= -1 and numContainerSlots >= 1 and not (i - 1 > numContainerSlots)) then
			if not f.ContainerHolder[i] then
				if isBank then
					f.ContainerHolder[i] = CreateFrame("ItemButton", "ElvUIBankBag" .. (bagID-4), f.ContainerHolder, "BankItemButtonBagTemplate")
					B:CreateFilterIcon(f.ContainerHolder[i])
					f.ContainerHolder[i]:SetScript('OnClick', function(holder, button)
						if button == "RightButton" and holder.id then
							ElvUIAssignBagDropdown.holder = holder
							_G.ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
						else
							local inventoryID = holder:GetInventorySlot()
							PutItemInBag(inventoryID);--Put bag on empty slot, or drop item in this bag
						end
					end)
				else
					if bagID == 0 then --Backpack needs different setup
						f.ContainerHolder[i] = CreateFrame("ItemButton", "ElvUIMainBagBackpack", f.ContainerHolder, "ItemAnimTemplate")
						B:CreateFilterIcon(f.ContainerHolder[i])
						f.ContainerHolder[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
						f.ContainerHolder[i]:SetScript('OnClick', function(holder, button)
							if button == "RightButton" and holder.id then
								ElvUIAssignBagDropdown.holder = holder
								_G.ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
							else
								PutItemInBackpack();--Put bag on empty slot, or drop item in this bag
							end
						end)
						f.ContainerHolder[i]:SetScript('OnReceiveDrag', function()
							PutItemInBackpack();--Put bag on empty slot, or drop item in this bag
						end)
					else
						f.ContainerHolder[i] = CreateFrame("ItemButton", "ElvUIMainBag" .. (bagID-1) .. "Slot", f.ContainerHolder, "BagSlotButtonTemplate")
						B:CreateFilterIcon(f.ContainerHolder[i])
						f.ContainerHolder[i]:SetScript('OnClick', function(holder, button)
							if button == "RightButton" and holder.id then
								ElvUIAssignBagDropdown.holder = holder
								_G.ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
							else
								local id = holder:GetID()
								PutItemInBag(id);--Put bag on empty slot, or drop item in this bag
							end
						end)
					end
				end

				f.ContainerHolder[i]:SetTemplate(E.db.bags.transparent and 'Transparent', true)
				f.ContainerHolder[i]:StyleButton()
				f.ContainerHolder[i].IconBorder:SetAlpha(0)
				f.ContainerHolder[i]:SetNormalTexture("")
				f.ContainerHolder[i]:SetPushedTexture("")
				f.ContainerHolder[i].id = bagID
				f.ContainerHolder[i]:HookScript("OnEnter", function(ch) B.SetSlotAlphaForBag(ch, f) end)
				f.ContainerHolder[i]:HookScript("OnLeave", function(ch) B.ResetSlotAlphaForBags(ch, f) end)

				if isBank then
					f.ContainerHolder[i]:SetID(bagID - 4)
					if not f.ContainerHolder[i].tooltipText then
						f.ContainerHolder[i].tooltipText = ""
					end
				end

				f.ContainerHolder[i].iconTexture = _G[f.ContainerHolder[i]:GetName()..'IconTexture']
				f.ContainerHolder[i].iconTexture:SetInside()
				f.ContainerHolder[i].iconTexture:SetTexCoord(unpack(E.TexCoords))
				if bagID == 0 then --backpack
					f.ContainerHolder[i].iconTexture:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
				end
			end

			f.ContainerHolder:Size(((buttonSize + buttonSpacing) * (isBank and i - 1 or i)) + buttonSpacing,buttonSize + (buttonSpacing * 2))

			if isBank then
				BankFrameItemButton_Update(f.ContainerHolder[i])
				BankFrameItemButton_UpdateLocked(f.ContainerHolder[i])
			end

			assignedBag = B:GetBagAssignedInfo(f.ContainerHolder[i])

			f.ContainerHolder[i]:Size(buttonSize)
			f.ContainerHolder[i]:ClearAllPoints()
			if (isBank and i == 2) or (not isBank and i == 1) then
				f.ContainerHolder[i]:Point('BOTTOMLEFT', f.ContainerHolder, 'BOTTOMLEFT', buttonSpacing, buttonSpacing)
			else
				f.ContainerHolder[i]:Point('LEFT', lastContainerButton, 'RIGHT', buttonSpacing, 0)
			end

			lastContainerButton = f.ContainerHolder[i]
		end

		--Bag Slots
		local numSlots = GetContainerNumSlots(bagID)
		if numSlots > 0 then
			if not f.Bags[bagID] then
				f.Bags[bagID] = CreateFrame('Frame', f:GetName()..'Bag'..bagID, f.holderFrame)
				f.Bags[bagID]:SetID(bagID)
			end

			f.Bags[bagID].numSlots = numSlots
			f.Bags[bagID].assigned = assignedBag
			f.Bags[bagID].type = select(2, GetContainerNumFreeSlots(bagID))

			--Hide unused slots
			for y = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID][y] then
					f.Bags[bagID][y]:Hide()
				end
			end

			for slotID = 1, numSlots do
				f.totalSlots = f.totalSlots + 1
				if not f.Bags[bagID][slotID] then
					f.Bags[bagID][slotID] = CreateFrame('ItemButton', f.Bags[bagID]:GetName()..'Slot'..slotID, f.Bags[bagID], bagID == -1 and 'BankItemButtonGenericTemplate' or 'ContainerFrameItemButtonTemplate')
					f.Bags[bagID][slotID]:StyleButton()
					f.Bags[bagID][slotID]:SetTemplate(E.db.bags.transparent and 'Transparent', true)
					f.Bags[bagID][slotID]:SetNormalTexture(nil)

					if _G[f.Bags[bagID][slotID]:GetName()..'NewItemTexture'] then
						_G[f.Bags[bagID][slotID]:GetName()..'NewItemTexture']:Hide()
					end

					f.Bags[bagID][slotID].Count:ClearAllPoints()
					f.Bags[bagID][slotID].Count:Point('BOTTOMRIGHT', 0, 2)
					f.Bags[bagID][slotID].Count:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
					f.Bags[bagID][slotID].Count:SetTextColor(countColor.r, countColor.g, countColor.b)

					if not(f.Bags[bagID][slotID].questIcon) then
						f.Bags[bagID][slotID].questIcon = _G[f.Bags[bagID][slotID]:GetName()..'IconQuestTexture'] or _G[f.Bags[bagID][slotID]:GetName()].IconQuestTexture
						f.Bags[bagID][slotID].questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
						f.Bags[bagID][slotID].questIcon:SetTexCoord(0,1,0,1)
						f.Bags[bagID][slotID].questIcon:SetInside()
						f.Bags[bagID][slotID].questIcon:Hide()
					end

					if f.Bags[bagID][slotID].UpgradeIcon then
						f.Bags[bagID][slotID].UpgradeIcon:SetTexture(E.Media.Textures.BagUpgradeIcon)
						f.Bags[bagID][slotID].UpgradeIcon:SetTexCoord(0,1,0,1)
						f.Bags[bagID][slotID].UpgradeIcon:SetInside()
						f.Bags[bagID][slotID].UpgradeIcon:Hide()
					end

					--.JunkIcon only exists for items created through ContainerFrameItemButtonTemplate
					if not f.Bags[bagID][slotID].JunkIcon then
						local JunkIcon = f.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
						JunkIcon:SetAtlas("bags-junkcoin", true)
						JunkIcon:Point("TOPLEFT", 1, 0)
						JunkIcon:Hide()
						f.Bags[bagID][slotID].JunkIcon = JunkIcon
					end

					if not f.Bags[bagID][slotID].ScrapIcon then
						local ScrapIcon = f.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
						ScrapIcon:SetAtlas("bags-icon-scrappable")
						ScrapIcon:Size(14, 12)
						ScrapIcon:Point("TOPRIGHT", -1, -1)
						ScrapIcon:Hide()
						f.Bags[bagID][slotID].ScrapIcon = ScrapIcon
					end

					if not f.Bags[bagID][slotID].Azerite then
						f.Bags[bagID][slotID].Azerite = f.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
						f.Bags[bagID][slotID].Azerite:SetAtlas("AzeriteIconFrame")
						f.Bags[bagID][slotID].Azerite:SetTexCoord(0,1,0,1)
						f.Bags[bagID][slotID].Azerite:SetInside()
						f.Bags[bagID][slotID].Azerite:Hide()
					end

					f.Bags[bagID][slotID].iconTexture = _G[f.Bags[bagID][slotID]:GetName()..'IconTexture']
					f.Bags[bagID][slotID].iconTexture:SetInside(f.Bags[bagID][slotID])
					f.Bags[bagID][slotID].iconTexture:SetTexCoord(unpack(E.TexCoords))

					f.Bags[bagID][slotID].searchOverlay:SetAllPoints()
					f.Bags[bagID][slotID].cooldown = _G[f.Bags[bagID][slotID]:GetName()..'Cooldown']
					f.Bags[bagID][slotID].cooldown.CooldownOverride = 'bags'
					E:RegisterCooldown(f.Bags[bagID][slotID].cooldown)
					f.Bags[bagID][slotID].bagID = bagID
					f.Bags[bagID][slotID].slotID = slotID

					f.Bags[bagID][slotID].itemLevel = f.Bags[bagID][slotID]:CreateFontString(nil, 'OVERLAY')
					f.Bags[bagID][slotID].itemLevel:Point("BOTTOMRIGHT", 0, 2)
					f.Bags[bagID][slotID].itemLevel:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)

					f.Bags[bagID][slotID].bindType = f.Bags[bagID][slotID]:CreateFontString(nil, 'OVERLAY')
					f.Bags[bagID][slotID].bindType:Point("TOP", 0, -2)
					f.Bags[bagID][slotID].bindType:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)

					if f.Bags[bagID][slotID].BattlepayItemTexture then
						f.Bags[bagID][slotID].BattlepayItemTexture:Hide()
					end

					if not f.Bags[bagID][slotID].newItemGlow then
						local newItemGlow = f.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
						newItemGlow:SetInside()
						newItemGlow:SetTexture(E.Media.Textures.BagNewItemGlow)
						newItemGlow:Hide()
						B.BagFrame.NewItemGlow.Fade:AddChild(newItemGlow)
						f.Bags[bagID][slotID].newItemGlow = newItemGlow
						f.Bags[bagID][slotID]:HookScript('OnEnter', B.HideSlotItemGlow)
					end
				end

				f.Bags[bagID][slotID]:SetID(slotID)
				f.Bags[bagID][slotID]:Size(buttonSize)

				if f.Bags[bagID][slotID].JunkIcon then
					f.Bags[bagID][slotID].JunkIcon:Size(buttonSize/2)
				end

				B:UpdateSlot(f, bagID, slotID)

				if f.Bags[bagID][slotID]:GetPoint() then
					f.Bags[bagID][slotID]:ClearAllPoints()
				end

				if lastButton then
					local anchorPoint, relativePoint = (B.db.reverseSlots and 'BOTTOM' or 'TOP'), (B.db.reverseSlots and 'TOP' or 'BOTTOM')
					if isSplit and newBag and slotID == 1 then
						f.Bags[bagID][slotID]:Point(anchorPoint, lastRowButton, relativePoint, 0, B.db.reverseSlots and (buttonSpacing + bagSpacing) or -(buttonSpacing + bagSpacing))
						lastRowButton = f.Bags[bagID][slotID]
						numContainerRows = numContainerRows + 1
						numBags = numBags + 1
						numBagSlots = 0
					elseif isSplit and numBagSlots % numContainerColumns == 0 then
						f.Bags[bagID][slotID]:Point(anchorPoint, lastRowButton, relativePoint, 0, B.db.reverseSlots and buttonSpacing or -buttonSpacing)
						lastRowButton = f.Bags[bagID][slotID]
						numContainerRows = numContainerRows + 1
					elseif (not isSplit) and (f.totalSlots - 1) % numContainerColumns == 0 then
						f.Bags[bagID][slotID]:Point(anchorPoint, lastRowButton, relativePoint, 0, B.db.reverseSlots and buttonSpacing or -buttonSpacing)
						lastRowButton = f.Bags[bagID][slotID]
						numContainerRows = numContainerRows + 1
					else
						anchorPoint, relativePoint = (B.db.reverseSlots and 'RIGHT' or 'LEFT'), (B.db.reverseSlots and 'LEFT' or 'RIGHT')
						f.Bags[bagID][slotID]:Point(anchorPoint, lastButton, relativePoint, B.db.reverseSlots and -buttonSpacing or buttonSpacing, 0)
					end
				else
					local anchorPoint = B.db.reverseSlots and 'BOTTOMRIGHT' or 'TOPLEFT'
					f.Bags[bagID][slotID]:Point(anchorPoint, f.holderFrame, anchorPoint, 0, B.db.reverseSlots and f.bottomOffset - 8 or 0)
					lastRowButton = f.Bags[bagID][slotID]
					numContainerRows = numContainerRows + 1
				end

				lastButton = f.Bags[bagID][slotID]
				numBagSlots = numBagSlots + 1
			end
		else
			--Hide unused slots
			for y = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID] and f.Bags[bagID][y] then
					f.Bags[bagID][y]:Hide()
				end
			end

			if f.Bags[bagID] then
				f.Bags[bagID].numSlots = numSlots
			end

			local container = isBank and f.ContainerHolder[i]
			if container then
				BankFrameItemButton_Update(container)
				BankFrameItemButton_UpdateLocked(container)
			end
		end
	end

	if isBank and f.reagentFrame:IsShown() then
		if not IsReagentBankUnlocked() then
			f.reagentFrame.cover:Show()
			B:RegisterEvent("REAGENTBANK_PURCHASED")
		else
			f.reagentFrame.cover:Hide()
		end

		local totalSlots, lastReagentRowButton = 0
		numContainerRows = 1
		for i = 1, B.REAGENTBANK_SIZE do
			totalSlots = totalSlots + 1

			if(not f.reagentFrame.slots[i]) then
				f.reagentFrame.slots[i] = CreateFrame("ItemButton", "ElvUIReagentBankFrameItem"..i, f.reagentFrame, "ReagentBankItemButtonGenericTemplate")
				f.reagentFrame.slots[i]:SetID(i)
				f.reagentFrame.slots[i].isReagent = true

				f.reagentFrame.slots[i]:StyleButton()
				f.reagentFrame.slots[i]:SetTemplate(nil, true)
				f.reagentFrame.slots[i]:SetNormalTexture(nil)

				f.reagentFrame.slots[i].Count:ClearAllPoints()
				f.reagentFrame.slots[i].Count:Point('BOTTOMRIGHT', 0, 2)
				f.reagentFrame.slots[i].Count:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
				f.reagentFrame.slots[i].Count:SetTextColor(countColor.r, countColor.g, countColor.b)

				f.reagentFrame.slots[i].searchOverlay:SetAllPoints()
				f.reagentFrame.slots[i].iconTexture = _G[f.reagentFrame.slots[i]:GetName()..'IconTexture']
				f.reagentFrame.slots[i].iconTexture:SetInside(f.reagentFrame.slots[i])
				f.reagentFrame.slots[i].iconTexture:SetTexCoord(unpack(E.TexCoords))
				f.reagentFrame.slots[i].IconBorder:SetAlpha(0)

				if not f.reagentFrame.slots[i].newItemGlow then
					local newItemGlow = f.reagentFrame.slots[i]:CreateTexture(nil, "OVERLAY")
					newItemGlow:SetInside()
					newItemGlow:SetTexture(E.Media.Textures.BagNewItemGlow)
					newItemGlow:Hide()
					B.BankFrame.NewItemGlow.Fade:AddChild(newItemGlow)
					f.reagentFrame.slots[i].newItemGlow = newItemGlow
					f.reagentFrame.slots[i]:HookScript('OnEnter', B.HideSlotItemGlow)
				end
			end

			f.reagentFrame.slots[i]:ClearAllPoints()
			f.reagentFrame.slots[i]:Size(buttonSize)
			if f.reagentFrame.slots[i-1] then
				if(totalSlots - 1) % numContainerColumns == 0 then
					f.reagentFrame.slots[i]:Point('TOP', lastReagentRowButton, 'BOTTOM', 0, -buttonSpacing)
					lastReagentRowButton = f.reagentFrame.slots[i]
					numContainerRows = numContainerRows + 1
				else
					f.reagentFrame.slots[i]:Point('LEFT', f.reagentFrame.slots[i-1], 'RIGHT', buttonSpacing, 0)
				end
			else
				f.reagentFrame.slots[i]:Point('TOPLEFT', f.reagentFrame, 'TOPLEFT')
				lastReagentRowButton = f.reagentFrame.slots[i]
			end

			B:UpdateReagentSlot(i)
		end
	end

	f:Size(containerWidth, (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + (isSplit and (numBags * bagSpacing) or 0 ) + f.topOffset + f.bottomOffset); -- 8 is the cussion of the f.holderFrame
end

function B:UpdateReagentSlot(slotID)
	assert(slotID)
	local bagID = REAGENTBANK_CONTAINER
	local texture, count, locked = GetContainerItemInfo(bagID, slotID)
	local clink = GetContainerItemLink(bagID, slotID)
	local slot = _G["ElvUIReagentBankFrameItem"..slotID]
	if not slot then return end

	slot:Show()
	if slot.questIcon then
		slot.questIcon:Hide()
	end

	slot.name, slot.rarity, slot.locked = nil, nil, locked

	local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
	CooldownFrame_Set(slot.Cooldown, start, duration, enable)
	if duration > 0 and enable == 0 then
		SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4)
	else
		SetItemButtonTextureVertexColor(slot, 1, 1, 1)
	end

	if clink then
		local name, _, rarity = GetItemInfo(clink)
		slot.name, slot.rarity = name, rarity

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID)
		local r, g, b

		if slot.rarity then
			r, g, b = GetItemQualityColor(slot.rarity)
		end

		-- color slot according to item quality
		if questId and not isActiveQuest then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questStarter))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questStarter))
			slot.ignoreBorderColors = true
			if (slot.questIcon) then
				slot.questIcon:Show()
			end
		elseif questId or isQuestItem then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questItem))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
			slot.ignoreBorderColors = true
		elseif B.db.qualityColors and slot.rarity and slot.rarity > LE_ITEM_QUALITY_COMMON then
			slot.newItemGlow:SetVertexColor(r, g, b)
			slot:SetBackdropBorderColor(r, g, b)
			slot.ignoreBorderColors = true
		else
			local rr, gg, bb = unpack(E.media.bordercolor)
			slot.newItemGlow:SetVertexColor(rr, gg, bb)
			slot:SetBackdropBorderColor(rr, gg, bb)
			slot.ignoreBorderColors = nil
		end
	else
		local rr, gg, bb = unpack(E.media.bordercolor)
		slot.newItemGlow:SetVertexColor(rr, gg, bb)
		slot:SetBackdropBorderColor(rr, gg, bb)
		slot.ignoreBorderColors = nil
	end

	if E.db.bags.newItemGlow then
		E:Delay(0.1, B.CheckSlotNewItem, B, slot, bagID, slotID)
	end

	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, slot.locked)
end

function B:UpdateAll()
	if B.BagFrame then B:Layout() end
	if B.BankFrame then B:Layout(true) end
end

function B:OnEvent(event, ...)
	if event == 'ITEM_LOCK_CHANGED' or event == 'ITEM_UNLOCKED' then
		local bag, slot = ...
		if bag == REAGENTBANK_CONTAINER then
			B:UpdateReagentSlot(slot)
		else
			B:UpdateSlot(self, bag, slot)
		end
	elseif event == 'BAG_UPDATE' then
		for _, bagID in ipairs(self.BagIDs) do
			local numSlots = GetContainerNumSlots(bagID)
			if (not self.Bags[bagID] and numSlots ~= 0) or (self.Bags[bagID] and numSlots ~= self.Bags[bagID].numSlots) then
				B:Layout(self.isBank)
				return
			end
		end

		B:UpdateBagSlots(self, ...)

		--Refresh search in case we moved items around
		if B:IsSearching() then B:RefreshSearch() end
	elseif event == 'BAG_UPDATE_COOLDOWN' then
		B:UpdateCooldowns(self)
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		local slot = ...
		local bagID = (slot <= NUM_BANKGENERIC_SLOTS) and -1 or (slot - NUM_BANKGENERIC_SLOTS)
		if bagID > -1 then
			B:Layout(true)
		else
			B:UpdateBagSlots(self, -1)
		end
	elseif event == 'PLAYERREAGENTBANKSLOTS_CHANGED' then
		B:UpdateReagentSlot(...)
	elseif (event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED") and self:IsShown() then
		B:UpdateAllSlots(self)
	elseif (event == "BANK_BAG_SLOT_FLAGS_UPDATED" or event == "BAG_SLOT_FLAGS_UPDATED") then
		B:Layout(self.isBank)
	end
end

function B:UpdateTokens()
	local f = B.BagFrame
	local numTokens = 0
	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
		local button = f.currencyButton[i]

		button:ClearAllPoints()
		if name then
			button.icon:SetTexture(icon)

			if B.db.currencyFormat == 'ICON_TEXT' then
				button.text:SetText(name..': '..count)
			elseif B.db.currencyFormat == "ICON_TEXT_ABBR" then
				button.text:SetText(E:AbbreviateString(name)..': '..count)
			elseif B.db.currencyFormat == 'ICON' then
				button.text:SetText(count)
			end

			button.currencyID = currencyID
			button:Show()
			numTokens = numTokens + 1
		else
			button:Hide()
		end
	end

	if numTokens == 0 then
		f.bottomOffset = 8

		if f.currencyButton:IsShown() then
			f.currencyButton:Hide()
			B:Layout()
		end

		return
	elseif not f.currencyButton:IsShown() then
		f.bottomOffset = 28
		f.currencyButton:Show()
		B:Layout()
	end

	f.bottomOffset = 28

	if numTokens == 1 then
		f.currencyButton[1]:Point('BOTTOM', f.currencyButton, 'BOTTOM', -(f.currencyButton[1].text:GetWidth() / 2), 3)
	elseif numTokens == 2 then
		f.currencyButton[1]:Point('BOTTOM', f.currencyButton, 'BOTTOM', -(f.currencyButton[1].text:GetWidth()) - (f.currencyButton[1]:GetWidth() / 2), 3)
		f.currencyButton[2]:Point('BOTTOMLEFT', f.currencyButton, 'BOTTOM', f.currencyButton[2]:GetWidth() / 2, 3)
	else
		f.currencyButton[1]:Point('BOTTOMLEFT', f.currencyButton, 'BOTTOMLEFT', 3, 3)
		f.currencyButton[2]:Point('BOTTOM', f.currencyButton, 'BOTTOM', -(f.currencyButton[2].text:GetWidth() / 3), 3)
		f.currencyButton[3]:Point('BOTTOMRIGHT', f.currencyButton, 'BOTTOMRIGHT', -(f.currencyButton[3].text:GetWidth()) - (f.currencyButton[3]:GetWidth() / 2), 3)
	end
end

function B:Token_OnEnter()
	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetBackpackToken(self:GetID())
end

function B:Token_OnClick()
	if IsModifiedClick("CHATLINK") then
		HandleModifiedItemClick(GetCurrencyLink(self.currencyID))
	end
end

function B:UpdateGoldText()
	B.BagFrame.goldText:SetText(E:FormatMoney(GetMoney(), E.db.bags.moneyFormat, not E.db.bags.moneyCoins))
end

function B:FormatMoney(amount)
	local str, coppername, silvername, goldname = "", "|cffeda55fc|r", "|cffc7c7cfs|r", "|cffffd700g|r"

	local value = abs(amount)
	local gold = floor(value / 10000)
	local silver = floor((value / 100) % 100)
	local copper = floor(value % 100)

	if gold > 0 then
		str = format("%d%s%s", gold, goldname, (silver > 0 or copper > 0) and " " or "")
	end
	if silver > 0 then
		str = format("%s%d%s%s", str, silver, silvername, copper > 0 and " " or "")
	end
	if copper > 0 or value == 0 then
		str = format("%s%d%s", str, copper, coppername)
	end

	return str
end

function B:GetGraysValue()
	local value = 0

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemID = GetContainerItemID(bag, slot)
			if itemID then
				local _, _, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)
				if itemPrice then
					local stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
					local stackPrice = itemPrice * stackCount
					if (rarity and rarity == 0) and (itype and itype ~= "Quest") and (stackPrice > 0) then
						value = value + stackPrice
					end
				end
			end
		end
	end

	return value
end

function B:VendorGrays(delete)
	if B.SellFrame:IsShown() then return end
	if (not _G.MerchantFrame or not _G.MerchantFrame:IsShown()) and not delete then
		E:Print(L["You must be at a vendor."])
		return
	end

	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			local itemID = GetContainerItemID(bag, slot)
			if itemID then
				local _, link, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)

				if (rarity and rarity == 0) and (itype and itype ~= "Quest") and (itemPrice and itemPrice > 0) then
					tinsert(B.SellFrame.Info.itemList, {bag,slot,itemPrice,link})
				end
			end
		end
	end

	if (not B.SellFrame.Info.itemList) then return; end
	if (tmaxn(B.SellFrame.Info.itemList) < 1) then return; end
	--Resetting stuff
	B.SellFrame.Info.delete = delete or false
	B.SellFrame.Info.ProgressTimer = 0
	B.SellFrame.Info.SellInterval = 0.2
	B.SellFrame.Info.ProgressMax = tmaxn(B.SellFrame.Info.itemList)
	B.SellFrame.Info.goldGained = 0
	B.SellFrame.Info.itemsSold = 0

	B.SellFrame.statusbar:SetValue(0)
	B.SellFrame.statusbar:SetMinMaxValues(0, B.SellFrame.Info.ProgressMax)
	B.SellFrame.statusbar.ValueText:SetText("0 / "..B.SellFrame.Info.ProgressMax)

	--Time to sell
	B.SellFrame:Show()
end

function B:VendorGrayCheck()
	local value = B:GetGraysValue()

	if value == 0 then
		E:Print(L["No gray items to delete."])
	elseif not _G.MerchantFrame or not _G.MerchantFrame:IsShown() then
		E.PopupDialogs.DELETE_GRAYS.Money = value
		E:StaticPopup_Show('DELETE_GRAYS')
	else
		B:VendorGrays()
	end
end

function B:ContructContainerFrame(name, isBank)
	local strata = E.db.bags.strata or 'HIGH'

	local f = CreateFrame('Button', name, E.UIParent)
	f:SetTemplate('Transparent')
	f:SetFrameStrata(strata)
	f:RegisterEvent("BAG_UPDATE") -- Has to be on both frames
	f:RegisterEvent("BAG_UPDATE_COOLDOWN") -- Has to be on both frames
	f.events = isBank and { "PLAYERREAGENTBANKSLOTS_CHANGED", "BANK_BAG_SLOT_FLAGS_UPDATED", "PLAYERBANKSLOTS_CHANGED" } or { "ITEM_LOCK_CHANGED", "ITEM_UNLOCKED", "BAG_SLOT_FLAGS_UPDATED", "QUEST_ACCEPTED", "QUEST_REMOVED" }

	for _, event in pairs(f.events) do
		f:RegisterEvent(event)
	end

	f:SetScript('OnEvent', B.OnEvent)
	f:Hide()

	f.isBank = isBank
	f.bottomOffset = isBank and 8 or 28
	f.topOffset = 50
	f.BagIDs = isBank and {-1, 5, 6, 7, 8, 9, 10, 11} or {0, 1, 2, 3, 4}
	f.Bags = {}

	local mover = (isBank and ElvUIBankMover) or ElvUIBagMover
	if mover then
		f:Point(mover.POINT, mover)
		f.mover = mover
	end

	--Allow dragging the frame around
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:RegisterForClicks("AnyUp")
	f:SetScript("OnDragStart", function(frame) if IsShiftKeyDown() then frame:StartMoving() end end)
	f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
	f:SetScript("OnClick", function(frame) if IsControlKeyDown() then B.PostBagMove(frame.mover) end end)
	f:SetScript("OnLeave", GameTooltip_Hide)
	f:SetScript("OnEnter", function(frame)
		local GameTooltip = _G.GameTooltip
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Hold Control + Right Click:"], L["Reset Position"], 1, 1, 1)
		GameTooltip:Show()
	end)

	f.closeButton = CreateFrame('Button', name..'CloseButton', f, 'UIPanelCloseButton')
	f.closeButton:Point('TOPRIGHT', 5, 5)

	Skins:HandleCloseButton(f.closeButton)

	f.holderFrame = CreateFrame('Frame', nil, f)
	f.holderFrame:Point('TOP', f, 'TOP', 0, -f.topOffset)
	f.holderFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8)

	f.ContainerHolder = CreateFrame('Button', name..'ContainerHolder', f)
	f.ContainerHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1)
	f.ContainerHolder:SetTemplate('Transparent')
	f.ContainerHolder:Hide()

	if isBank then
		f.reagentFrame = CreateFrame("Frame", "ElvUIReagentBankFrame", f)
		f.reagentFrame:Point('TOP', f, 'TOP', 0, -f.topOffset)
		f.reagentFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8)
		f.reagentFrame.slots = {}
		f.reagentFrame:SetID(REAGENTBANK_CONTAINER)
		f.reagentFrame:Hide()

		f.reagentFrame.cover = CreateFrame("Button", nil, f.reagentFrame)
		f.reagentFrame.cover:SetAllPoints(f.reagentFrame)
		f.reagentFrame.cover:SetTemplate(nil, true)
		f.reagentFrame.cover:SetFrameLevel(f.reagentFrame:GetFrameLevel() + 10)

		f.reagentFrame.cover.purchaseButton = CreateFrame("Button", nil, f.reagentFrame.cover)
		f.reagentFrame.cover.purchaseButton:Height(20)
		f.reagentFrame.cover.purchaseButton:Width(150)
		f.reagentFrame.cover.purchaseButton:Point('CENTER', f.reagentFrame.cover, 'CENTER')
		Skins:HandleButton(f.reagentFrame.cover.purchaseButton)
		f.reagentFrame.cover.purchaseButton:SetFrameLevel(f.reagentFrame.cover.purchaseButton:GetFrameLevel() + 2)
		f.reagentFrame.cover.purchaseButton.text = f.reagentFrame.cover.purchaseButton:CreateFontString(nil, 'OVERLAY')
		f.reagentFrame.cover.purchaseButton.text:FontTemplate()
		f.reagentFrame.cover.purchaseButton.text:Point('CENTER')
		f.reagentFrame.cover.purchaseButton.text:SetJustifyH('CENTER')
		f.reagentFrame.cover.purchaseButton.text:SetText(L["Purchase"])
		f.reagentFrame.cover.purchaseButton:SetScript("OnClick", function()
			PlaySound(852) --IG_MAINMENU_OPTION
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
		end)

		f.reagentFrame.cover.purchaseText = f.reagentFrame.cover:CreateFontString(nil, 'OVERLAY')
		f.reagentFrame.cover.purchaseText:FontTemplate()
		f.reagentFrame.cover.purchaseText:Point("BOTTOM", f.reagentFrame.cover.purchaseButton, "TOP", 0, 10)
		f.reagentFrame.cover.purchaseText:SetText(REAGENTBANK_PURCHASE_TEXT)

		--Bag Text
		f.bagText = f:CreateFontString(nil, 'OVERLAY')
		f.bagText:FontTemplate()
		f.bagText:Point('BOTTOMRIGHT', f.holderFrame, 'TOPRIGHT', -2, 4)
		f.bagText:SetJustifyH("RIGHT")
		f.bagText:SetText(L["Bank"])

		f.reagentToggle = CreateFrame("Button", name..'ReagentButton', f)
		f.reagentToggle:Size(16 + E.Border, 16 + E.Border)
		f.reagentToggle:SetTemplate()
		f.reagentToggle:Point("RIGHT", f.bagText, "LEFT", -5, E.Border * 2)
		f.reagentToggle:SetNormalTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.reagentToggle:GetNormalTexture():SetInside()
		f.reagentToggle:SetPushedTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.reagentToggle:GetPushedTexture():SetInside()
		f.reagentToggle:StyleButton(nil, true)
		f.reagentToggle.ttText = L["Show/Hide Reagents"]
		f.reagentToggle:SetScript("OnEnter", B.Tooltip_Show)
		f.reagentToggle:SetScript("OnLeave", GameTooltip_Hide)
		f.reagentToggle:SetScript("OnClick", function()
			PlaySound(841) --IG_CHARACTER_INFO_TAB
			B:ShowBankTab(f, f.holderFrame:IsShown())
			B:Layout(true)
			f:Show()
		end)

		--Sort Button
		f.sortButton = CreateFrame("Button", name..'SortButton', f)
		f.sortButton:Size(16 + E.Border, 16 + E.Border)
		f.sortButton:SetTemplate()
		f.sortButton:Point("RIGHT", f.reagentToggle, "LEFT", -5, 0)
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetNormalTexture():SetInside()
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetPushedTexture():SetInside()
		f.sortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetDisabledTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetDisabledTexture():SetInside()
		f.sortButton:GetDisabledTexture():SetDesaturated(1)
		f.sortButton:StyleButton(nil, true)
		f.sortButton:SetScript("OnEnter", _G.BagItemAutoSortButton:GetScript("OnEnter"))
		f.sortButton:SetScript('OnClick', function()
			if f.holderFrame:IsShown() then
				if B.db.useBlizzardCleanup then
					SortBankBags()
				else
					f:UnregisterAllEvents() --Unregister to prevent unnecessary updates
					if not f.registerUpdate then B:SortingFadeBags(f, true) end
					B:CommandDecorator(B.SortBags, 'bank')()
				end
			else
				SortReagentBankBags()
			end
		end)
		if E.db.bags.disableBankSort then
			f.sortButton:Disable()
		end

		--Deposite Reagents Button
		f.depositButton = CreateFrame("Button", name..'DepositButton', f.reagentFrame)
		f.depositButton:Size(16 + E.Border, 16 + E.Border)
		f.depositButton:SetTemplate()
		f.depositButton:Point("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.depositButton:SetNormalTexture("Interface\\ICONS\\misc_arrowdown")
		f.depositButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.depositButton:GetNormalTexture():SetInside()
		f.depositButton:SetPushedTexture("Interface\\ICONS\\misc_arrowdown")
		f.depositButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.depositButton:GetPushedTexture():SetInside()
		f.depositButton:StyleButton(nil, true)
		f.depositButton.ttText = L["Deposit Reagents"]
		f.depositButton:SetScript("OnEnter", B.Tooltip_Show)
		f.depositButton:SetScript("OnLeave", GameTooltip_Hide)
		f.depositButton:SetScript('OnClick', function()
			PlaySound(852) --IG_MAINMENU_OPTION
			DepositReagentBank()
		end)

		f.depositButtonBank = CreateFrame("Button", name..'DepositButton', f.holderFrame)
		f.depositButtonBank:Size(16 + E.Border, 16 + E.Border)
		f.depositButtonBank:SetTemplate()
		f.depositButtonBank:Point("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.depositButtonBank:SetNormalTexture("Interface\\ICONS\\misc_arrowdown")
		f.depositButtonBank:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.depositButtonBank:GetNormalTexture():SetInside()
		f.depositButtonBank:SetPushedTexture("Interface\\ICONS\\misc_arrowdown")
		f.depositButtonBank:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.depositButtonBank:GetPushedTexture():SetInside()
		f.depositButtonBank:StyleButton(nil, true)
		f.depositButtonBank.ttText = L["Deposit Reagents"]
		f.depositButtonBank:SetScript("OnEnter", B.Tooltip_Show)
		f.depositButtonBank:SetScript("OnLeave", GameTooltip_Hide)
		f.depositButtonBank:SetScript('OnClick', function()
			PlaySound(852) --IG_MAINMENU_OPTION
			DepositReagentBank()
		end)

		--Toggle Bags Button
		f.bagsButton = CreateFrame("Button", name..'BagsButton', f.holderFrame)
		f.bagsButton:Size(16 + E.Border, 16 + E.Border)
		f.bagsButton:SetTemplate()
		f.bagsButton:Point("RIGHT", f.depositButtonBank, "LEFT", -5, 0)
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetNormalTexture():SetInside()
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetPushedTexture():SetInside()
		f.bagsButton:StyleButton(nil, true)
		f.bagsButton.ttText = L["Toggle Bags"]
		f.bagsButton.ttText2 = format("|cffFFFFFF%s|r", L["Right Click the bag icon to assign a type of item to this bag."])
		f.bagsButton:SetScript("OnEnter", B.Tooltip_Show)
		f.bagsButton:SetScript("OnLeave", GameTooltip_Hide)
		f.bagsButton:SetScript('OnClick', function()
			local numSlots = GetNumBankSlots()
			PlaySound(852) --IG_MAINMENU_OPTION
			if numSlots >= 1 then
				ToggleFrame(f.ContainerHolder)
			else
				E:StaticPopup_Show("NO_BANK_BAGS")
			end
		end)

		f.purchaseBagButton = CreateFrame('Button', nil, f.holderFrame)
		f.purchaseBagButton:Size(16 + E.Border, 16 + E.Border)
		f.purchaseBagButton:SetTemplate()
		f.purchaseBagButton:Point("RIGHT", f.bagsButton, "LEFT", -5, 0)
		f.purchaseBagButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.purchaseBagButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.purchaseBagButton:GetNormalTexture():SetInside()
		f.purchaseBagButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.purchaseBagButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.purchaseBagButton:GetPushedTexture():SetInside()
		f.purchaseBagButton:StyleButton(nil, true)
		f.purchaseBagButton.ttText = L["Purchase Bags"]
		f.purchaseBagButton:SetScript("OnEnter", B.Tooltip_Show)
		f.purchaseBagButton:SetScript("OnLeave", GameTooltip_Hide)
		f.purchaseBagButton:SetScript("OnClick", function()
			local _, full = GetNumBankSlots()
			if full then
				E:StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
			else
				E:StaticPopup_Show("BUY_BANK_SLOT")
			end
		end)

		f:SetScript('OnShow', B.RefreshSearch)
		f:SetScript('OnHide', function()
			CloseBankFrame()

			B:NewItemGlowBagClear(f)
			B:HideItemGlow(f)

			if E.db.bags.clearSearchOnClose then
				B:ResetAndClear()
			end
		end)

		--Search
		f.editBox = CreateFrame('EditBox', name..'EditBox', f)
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2)
		f.editBox:CreateBackdrop()
		f.editBox.backdrop:Point("TOPLEFT", f.editBox, "TOPLEFT", -20, 2)
		f.editBox:Height(15)
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', (E.Border * 2) + 18, E.Border * 2 + 2)
		f.editBox:Point('RIGHT', f.purchaseBagButton, 'LEFT', -5, 0)
		f.editBox:SetAutoFocus(false)
		f.editBox:SetScript("OnEscapePressed", B.ResetAndClear)
		f.editBox:SetScript("OnEnterPressed", function(eb) eb:ClearFocus() end)
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText)
		f.editBox:SetScript("OnTextChanged", B.UpdateSearch)
		f.editBox:SetScript('OnChar', B.UpdateSearch)
		f.editBox:SetText(SEARCH)
		f.editBox:FontTemplate()

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, 'OVERLAY')
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		f.editBox.searchIcon:Point("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1)
		f.editBox.searchIcon:Size(15, 15)

	else
		--Gold Text
		f.goldText = f:CreateFontString(nil, 'OVERLAY')
		f.goldText:FontTemplate()
		f.goldText:Point('BOTTOMRIGHT', f.holderFrame, 'TOPRIGHT', -2, 4)
		f.goldText:SetJustifyH("RIGHT")

		--Sort Button
		f.sortButton = CreateFrame("Button", name..'SortButton', f)
		f.sortButton:Size(16 + E.Border, 16 + E.Border)
		f.sortButton:SetTemplate()
		f.sortButton:Point("RIGHT", f.goldText, "LEFT", -5, E.Border * 2)
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetNormalTexture():SetInside()
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetPushedTexture():SetInside()
		f.sortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetDisabledTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetDisabledTexture():SetInside()
		f.sortButton:GetDisabledTexture():SetDesaturated(1)
		f.sortButton:StyleButton(nil, true)
		f.sortButton:SetScript("OnEnter", _G.BagItemAutoSortButton:GetScript("OnEnter"))
		f.sortButton:SetScript('OnClick', function()
			if B.db.useBlizzardCleanup then
				SortBags()
			else
				f:UnregisterAllEvents() --Unregister to prevent unnecessary updates
				if not f.registerUpdate then B:SortingFadeBags(f, true) end
				B:CommandDecorator(B.SortBags, 'bags')()
			end
		end)
		if E.db.bags.disableBagSort then
			f.sortButton:Disable()
		end

		--Bags Button
		f.bagsButton = CreateFrame("Button", name..'BagsButton', f)
		f.bagsButton:Size(16 + E.Border, 16 + E.Border)
		f.bagsButton:SetTemplate()
		f.bagsButton:Point("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetNormalTexture():SetInside()
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetPushedTexture():SetInside()
		f.bagsButton:StyleButton(nil, true)
		f.bagsButton.ttText = L["Toggle Bags"]
		f.bagsButton.ttText2 = format("|cffFFFFFF%s|r", L["Right Click the bag icon to assign a type of item to this bag."])
		f.bagsButton:SetScript("OnEnter", B.Tooltip_Show)
		f.bagsButton:SetScript("OnLeave", GameTooltip_Hide)
		f.bagsButton:SetScript('OnClick', function() ToggleFrame(f.ContainerHolder) end)

		--Vendor Grays
		f.vendorGraysButton = CreateFrame('Button', nil, f.holderFrame)
		f.vendorGraysButton:Size(16 + E.Border, 16 + E.Border)
		f.vendorGraysButton:SetTemplate()
		f.vendorGraysButton:Point("RIGHT", f.bagsButton, "LEFT", -5, 0)
		f.vendorGraysButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.vendorGraysButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.vendorGraysButton:GetNormalTexture():SetInside()
		f.vendorGraysButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.vendorGraysButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.vendorGraysButton:GetPushedTexture():SetInside()
		f.vendorGraysButton:StyleButton(nil, true)
		f.vendorGraysButton.ttText = L["Vendor / Delete Grays"]
		f.vendorGraysButton:SetScript("OnEnter", B.Tooltip_Show)
		f.vendorGraysButton:SetScript("OnLeave", GameTooltip_Hide)
		f.vendorGraysButton:SetScript("OnClick", B.VendorGrayCheck)

		--Search
		f.editBox = CreateFrame('EditBox', name..'EditBox', f)
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2)
		f.editBox:CreateBackdrop()
		f.editBox.backdrop:Point("TOPLEFT", f.editBox, "TOPLEFT", -20, 2)
		f.editBox:Height(15)
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', (E.Border * 2) + 18, E.Border * 2 + 2)
		f.editBox:Point('RIGHT', f.vendorGraysButton, 'LEFT', -5, 0)
		f.editBox:SetAutoFocus(false)
		f.editBox:SetScript("OnEscapePressed", B.ResetAndClear)
		f.editBox:SetScript("OnEnterPressed", function(eb) eb:ClearFocus() end)
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText)
		f.editBox:SetScript("OnTextChanged", B.UpdateSearch)
		f.editBox:SetScript('OnChar', B.UpdateSearch)
		f.editBox:SetText(SEARCH)
		f.editBox:FontTemplate()

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, 'OVERLAY')
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		f.editBox.searchIcon:Point("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1)
		f.editBox.searchIcon:Size(15, 15)

		--Currency
		f.currencyButton = CreateFrame('Frame', nil, f)
		f.currencyButton:Point('BOTTOM', 0, 4)
		f.currencyButton:Point('TOPLEFT', f.holderFrame, 'BOTTOMLEFT', 0, 18)
		f.currencyButton:Point('TOPRIGHT', f.holderFrame, 'BOTTOMRIGHT', 0, 18)

		f.currencyButton:Height(22)
		for i = 1, MAX_WATCHED_TOKENS do
			f.currencyButton[i] = CreateFrame('Button', f:GetName().."CurrencyButton"..i, f.currencyButton)
			f.currencyButton[i]:Size(16)
			f.currencyButton[i]:SetTemplate()
			f.currencyButton[i]:SetID(i)
			f.currencyButton[i].icon = f.currencyButton[i]:CreateTexture(nil, 'OVERLAY')
			f.currencyButton[i].icon:SetInside()
			f.currencyButton[i].icon:SetTexCoord(unpack(E.TexCoords))
			f.currencyButton[i].text = f.currencyButton[i]:CreateFontString(nil, 'OVERLAY')
			f.currencyButton[i].text:Point('LEFT', f.currencyButton[i], 'RIGHT', 2, 0)
			f.currencyButton[i].text:FontTemplate()

			f.currencyButton[i]:SetScript('OnEnter', B.Token_OnEnter)
			f.currencyButton[i]:SetScript('OnLeave', GameTooltip_Hide)
			f.currencyButton[i]:SetScript('OnClick', B.Token_OnClick)
			f.currencyButton[i]:Hide()
		end

		f:SetScript('OnShow', B.RefreshSearch)
		f:SetScript('OnHide', function()
			CloseBackpack()
			for i = 1, NUM_BAG_FRAMES do
				CloseBag(i)
			end

			B:NewItemGlowBagClear(f)
			B:HideItemGlow(f)

			if not _G.BankFrame:IsShown() and E.db.bags.clearSearchOnClose then
				B:ResetAndClear()
			end
		end)
	end

	tinsert(_G.UISpecialFrames, f:GetName()) --Keep an eye on this for taints..
	tinsert(B.BagFrames, f)
	return f
end

function B:ToggleBags(id)
	if id and (GetContainerNumSlots(id) == 0) then return end --Closes a bag when inserting a new container..

	if B.BagFrame:IsShown() then
		B:CloseBags()
	else
		B:OpenBags()
	end
end

function B:ToggleBackpack()
	if IsOptionFrameOpen() then
		return
	end

	if IsBagOpen(0) then
		B:OpenBags()
		PlaySound(IG_BACKPACK_OPEN)
	else
		B:CloseBags()
		PlaySound(IG_BACKPACK_CLOSE)
	end
end

function B:ToggleSortButtonState(isBank)
	local button, disable
	if isBank and B.BankFrame then
		button = B.BankFrame.sortButton
		disable = E.db.bags.disableBankSort
	elseif not isBank and B.BagFrame then
		button = B.BagFrame.sortButton
		disable = E.db.bags.disableBagSort
	end

	if button and disable then
		button:Disable()
	elseif button and not disable then
		button:Enable()
	end
end

function B:OpenBags()
	B.BagFrame:Show()

	TT:GameTooltip_SetDefaultAnchor(_G.GameTooltip)
end

function B:CloseBags()
	B.BagFrame:Hide()

	if B.BankFrame then
		B.BankFrame:Hide()
	end

	TT:GameTooltip_SetDefaultAnchor(_G.GameTooltip)
end

function B:ShowBankTab(f, showReagent)
	if showReagent then
		_G.BankFrame.selectedTab = 2
		f.holderFrame:Hide()
		f.reagentFrame:Show()
		f.editBox:Point('RIGHT', f.depositButton, 'LEFT', -5, 0)
		f.bagText:SetText(L["Reagent Bank"])
	else
		_G.BankFrame.selectedTab = 1
		f.reagentFrame:Hide()
		f.holderFrame:Show()
		f.editBox:Point('RIGHT', f.purchaseBagButton, 'LEFT', -5, 0)
		f.bagText:SetText(L["Bank"])
	end
end

function B:ItemGlowOnFinished()
	if self:GetChange() == 1 then
		self:SetChange(0)
	else
		self:SetChange(1)
	end
end

function B:ShowItemGlow(bag, slot)
	if slot then
		slot:SetAlpha(1)
	end

	if not bag.NewItemGlow:IsPlaying() then
		bag.NewItemGlow:Play()
	end
end

function B:HideItemGlow(bag)
	if bag.NewItemGlow:IsPlaying() then
		bag.NewItemGlow:Stop()

		for _, itemGlow in pairs(bag.NewItemGlow.Fade.children) do
			itemGlow:SetAlpha(0)
		end
	end
end

function B:SetupItemGlow(frame)
	frame.NewItemGlow = _G.CreateAnimationGroup(frame)
	frame.NewItemGlow:SetLooping(true)
	frame.NewItemGlow.Fade = frame.NewItemGlow:CreateAnimation("fade")
	frame.NewItemGlow.Fade:SetDuration(0.7)
	frame.NewItemGlow.Fade:SetChange(0)
	frame.NewItemGlow.Fade:SetEasing('in')
	frame.NewItemGlow.Fade:SetScript("OnFinished", B.ItemGlowOnFinished)
end

function B:OpenBank()
	if not B.BankFrame then
		B.BankFrame = B:ContructContainerFrame('ElvUI_BankContainerFrame', true)
		B:SetupItemGlow(B.BankFrame)
	end

	--Allow opening reagent tab directly by holding Shift
	B:ShowBankTab(B.BankFrame, IsShiftKeyDown())

	--Call :Layout first so all elements are created before we update
	B:Layout(true)

	B:OpenBags()
	B:UpdateTokens()

	_G.BankFrame:Show()
	B.BankFrame:Show()
end

function B:PLAYERBANKBAGSLOTS_CHANGED()
	B:Layout(true)
end

function B:GuildBankFrame_Update()
	B:SetGuildBankSearch(SEARCH_STRING)
end

function B:CloseBank()
	if not B.BankFrame then return end -- WHY??? WHO KNOWS!
	B.BankFrame:Hide()
	_G.BankFrame:Hide()
	B.BagFrame:Hide()
end

function B:GUILDBANKFRAME_OPENED(event)
	local GuildItemSearchBox = _G.GuildItemSearchBox
	--[[
		local button = CreateFrame("Button", "GuildSortButton", GuildBankFrame, "UIPanelButtonTemplate")
		button:StripTextures()
		button:SetTemplate(nil, true)
		button:Size(110, 20)
		button:Point("RIGHT", GuildItemSearchBox, "LEFT", -4, 0)
		button:SetText(L["Sort Tab"])
		button:SetScript("OnClick", function() B:CommandDecorator(B.SortBags, 'guild')() end)
		E.Skins:HandleButton(button, true)
	]]

	if GuildItemSearchBox then
		GuildItemSearchBox:SetScript("OnEscapePressed", B.ResetAndClear)
		GuildItemSearchBox:SetScript("OnEnterPressed", function(sb) sb:ClearFocus() end)
		GuildItemSearchBox:SetScript("OnEditFocusGained", GuildItemSearchBox.HighlightText)
		GuildItemSearchBox:SetScript("OnTextChanged", B.UpdateSearch)
		GuildItemSearchBox:SetScript('OnChar', B.UpdateSearch)
	end

	hooksecurefunc('GuildBankFrame_Update', B.GuildBankFrame_Update)

	B:UnregisterEvent(event)
end

function B:PlayerEnteringWorld()
	B:UpdateBagTypes()
	B:Layout()
end

function B:PLAYER_ENTERING_WORLD()
	B:UpdateGoldText()

	-- Update bag types for bagslot coloring
	E:Delay(2, B.PlayerEnteringWorld)
end

function B:UpdateContainerFrameAnchors()
	local xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
	local screenWidth = GetScreenWidth()
	local containerScale = 1
	local leftLimit = 0

	if _G.BankFrame:IsShown() then
		leftLimit = _G.BankFrame:GetRight() - 25
	end

	while containerScale > CONTAINER_SCALE do
		screenHeight = GetScreenHeight() / containerScale
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale
		yOffset = CONTAINER_OFFSET_Y / containerScale
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset
		leftMostPoint = screenWidth - xOffset
		column = 1

		for _, frameName in ipairs(_G.ContainerFrame1.bags) do
			local frameHeight = _G[frameName]:GetHeight()

			if freeScreenHeight < frameHeight then
				-- Start a new column
				column = column + 1
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset
				freeScreenHeight = screenHeight - yOffset
			end

			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
		end

		if leftMostPoint < leftLimit then
			containerScale = containerScale - 0.01
		else
			break
		end
	end

	if containerScale < CONTAINER_SCALE then
		containerScale = CONTAINER_SCALE
	end

	screenHeight = GetScreenHeight() / containerScale
	-- Adjust the start anchor for bags depending on the multibars
	-- xOffset = CONTAINER_OFFSET_X / containerScale
	yOffset = CONTAINER_OFFSET_Y / containerScale
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset
	column = 0

	local bagsPerColumn = 0
	for index, frameName in ipairs(_G.ContainerFrame1.bags) do
		local frame = _G[frameName]
		frame:SetScale(1)

		if index == 1 then
			-- First bag
			frame:Point("BOTTOMRIGHT", ElvUIBagMover, "BOTTOMRIGHT", E.Spacing, -E.Border)
			bagsPerColumn = bagsPerColumn + 1
		elseif freeScreenHeight < frame:GetHeight() then
			-- Start a new column
			column = column + 1
			freeScreenHeight = screenHeight - yOffset
			if column > 1 then
				frame:Point("BOTTOMRIGHT", _G.ContainerFrame1.bags[(index - bagsPerColumn) - 1], "BOTTOMLEFT", -CONTAINER_SPACING, 0 )
			else
				frame:Point("BOTTOMRIGHT", _G.ContainerFrame1.bags[index - bagsPerColumn], "BOTTOMLEFT", -CONTAINER_SPACING, 0 )
			end
			bagsPerColumn = 0
		else
			-- Anchor to the previous bag
			frame:Point("BOTTOMRIGHT", _G.ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING)
			bagsPerColumn = bagsPerColumn + 1
		end

		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING
	end
end

function B:PostBagMove()
	if not E.private.bags.enable then return end

	-- self refers to the mover (bag or bank)
	local x, y = self:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenWidth = E.UIParent:GetRight()

	if y > (screenHeight / 2) then
		self:SetText(self.textGrowDown)
		self.POINT = ((x > (screenWidth/2)) and "TOPRIGHT" or "TOPLEFT")
	else
		self:SetText(self.textGrowUp)
		self.POINT = ((x > (screenWidth/2)) and "BOTTOMRIGHT" or "BOTTOMLEFT")
	end

	local bagFrame
	if self.name == "ElvUIBankMover" then
		bagFrame = B.BankFrame
	else
		bagFrame = B.BagFrame
	end

	if bagFrame then
		bagFrame:ClearAllPoints()
		bagFrame:Point(self.POINT, self)
	end
end

function B:MERCHANT_CLOSED()
	B.SellFrame:Hide()

	twipe(B.SellFrame.Info.itemList)
	B.SellFrame.Info.delete = false
	B.SellFrame.Info.ProgressTimer = 0
	B.SellFrame.Info.SellInterval = E.db.bags.vendorGrays.interval
	B.SellFrame.Info.ProgressMax = 0
	B.SellFrame.Info.goldGained = 0
	B.SellFrame.Info.itemsSold = 0
end

function B:ProgressQuickVendor()
	local item = B.SellFrame.Info.itemList[1]
	if not item then return nil, true end --No more to sell
	local bag, slot,itemPrice, link = unpack(item)

	local stackPrice = 0
	if B.SellFrame.Info.delete then
		PickupContainerItem(bag, slot)
		DeleteCursorItem()
	else
		local stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
		stackPrice = (itemPrice or 0) * stackCount
		if E.db.bags.vendorGrays.details and link then
			E:Print(format("%s|cFF00DDDDx%d|r %s", link, stackCount, B:FormatMoney(stackPrice)))
		end
		UseContainerItem(bag, slot)
	end

	tremove(B.SellFrame.Info.itemList, 1)

	return stackPrice
end

function B:VendorGreys_OnUpdate(elapsed)
	B.SellFrame.Info.ProgressTimer = B.SellFrame.Info.ProgressTimer - elapsed
	if (B.SellFrame.Info.ProgressTimer > 0) then return; end
	B.SellFrame.Info.ProgressTimer = B.SellFrame.Info.SellInterval

	local goldGained, lastItem = B:ProgressQuickVendor()
	if (goldGained) then
		B.SellFrame.Info.goldGained = B.SellFrame.Info.goldGained + goldGained
		B.SellFrame.Info.itemsSold = B.SellFrame.Info.itemsSold + 1
		B.SellFrame.statusbar:SetValue(B.SellFrame.Info.itemsSold)
		local timeLeft = (B.SellFrame.Info.ProgressMax - B.SellFrame.Info.itemsSold)*B.SellFrame.Info.SellInterval
		B.SellFrame.statusbar.ValueText:SetText(B.SellFrame.Info.itemsSold.." / "..B.SellFrame.Info.ProgressMax.." ( "..timeLeft.."s )")
	elseif lastItem then
		B.SellFrame:Hide()
		if B.SellFrame.Info.goldGained > 0 then
			E:Print((L["Vendored gray items for: %s"]):format(B:FormatMoney(B.SellFrame.Info.goldGained)))
		end
	end
end

function B:CreateSellFrame()
	B.SellFrame = CreateFrame("Frame", "ElvUIVendorGraysFrame", E.UIParent)
	B.SellFrame:Size(200,40)
	B.SellFrame:Point("CENTER", E.UIParent)
	B.SellFrame:CreateBackdrop("Transparent")
	B.SellFrame:SetAlpha(E.db.bags.vendorGrays.progressBar and 1 or 0)

	B.SellFrame.title = B.SellFrame:CreateFontString(nil, "OVERLAY")
	B.SellFrame.title:FontTemplate(nil, 12, "OUTLINE")
	B.SellFrame.title:Point('TOP', B.SellFrame, 'TOP', 0, -2)
	B.SellFrame.title:SetText(L["Vendoring Grays"])

	B.SellFrame.statusbar = CreateFrame("StatusBar", "ElvUIVendorGraysFrameStatusbar", B.SellFrame)
	B.SellFrame.statusbar:Size(180, 16)
	B.SellFrame.statusbar:Point("BOTTOM", B.SellFrame, "BOTTOM", 0, 4)
	B.SellFrame.statusbar:SetStatusBarTexture(E.media.normTex)
	B.SellFrame.statusbar:SetStatusBarColor(1, 0, 0)
	B.SellFrame.statusbar:CreateBackdrop("Transparent")

	B.SellFrame.statusbar.anim = _G.CreateAnimationGroup(B.SellFrame.statusbar)
	B.SellFrame.statusbar.anim.progress = B.SellFrame.statusbar.anim:CreateAnimation("Progress")
	B.SellFrame.statusbar.anim.progress:SetEasing("Out")
	B.SellFrame.statusbar.anim.progress:SetDuration(.3)

	B.SellFrame.statusbar.ValueText = B.SellFrame.statusbar:CreateFontString(nil, "OVERLAY")
	B.SellFrame.statusbar.ValueText:FontTemplate(nil, 12, "OUTLINE")
	B.SellFrame.statusbar.ValueText:Point("CENTER", B.SellFrame.statusbar)
	B.SellFrame.statusbar.ValueText:SetText("0 / 0 ( 0s )")

	B.SellFrame.Info = {
		delete = false,
		ProgressTimer = 0,
		SellInterval = E.db.bags.vendorGrays.interval,
		ProgressMax = 0,
		goldGained = 0,
		itemsSold = 0,
		itemList = {},
	}

	B.SellFrame:SetScript("OnUpdate", B.VendorGreys_OnUpdate)

	B.SellFrame:Hide()
end

function B:UpdateSellFrameSettings()
	if not B.SellFrame or not B.SellFrame.Info then return; end

	B.SellFrame.Info.SellInterval = E.db.bags.vendorGrays.interval
	B.SellFrame:SetAlpha(E.db.bags.vendorGrays.progressBar and 1 or 0)
end

B.BagIndice = {
	leatherworking = 0x0008,
	inscription = 0x0010,
	herbs = 0x0020,
	enchanting = 0x0040,
	engineering = 0x0080,
	gems = 0x0200,
	mining = 0x0400,
	fishing = 0x8000,
	cooking = 0x010000,
	equipment = 2,
	consumables = 3,
	tradegoods = 4,
}

B.QuestKeys = {
	questStarter = "questStarter",
	questItem = "questItem",
}

function B:UpdateBagColors(table, indice, r, g, b)
	B[table][B.BagIndice[indice]] = { r, g, b }
end

function B:UpdateQuestColors(table, indice, r, g, b)
	B[table][B.QuestKeys[indice]] = { r, g, b }
end

function B:Initialize()
	B:LoadBagBar()

	--Creating vendor grays frame
	B:CreateSellFrame()
	B:RegisterEvent("MERCHANT_CLOSED")

	--Bag Mover (We want it created even if Bags module is disabled, so we can use it for default bags too)
	local BagFrameHolder = CreateFrame("Frame", nil, E.UIParent)
	BagFrameHolder:Width(200)
	BagFrameHolder:Height(22)
	BagFrameHolder:SetFrameLevel(BagFrameHolder:GetFrameLevel() + 400)

	--Bag Assignment Dropdown Menu (also used by BagBar)
	ElvUIAssignBagDropdown = CreateFrame("Frame", "ElvUIAssignBagDropdown", E.UIParent, "UIDropDownMenuTemplate")
	ElvUIAssignBagDropdown:SetID(1)
	ElvUIAssignBagDropdown:SetClampedToScreen(true)
	ElvUIAssignBagDropdown:Hide()
	_G.UIDropDownMenu_Initialize(ElvUIAssignBagDropdown, B.AssignBagFlagMenu, "MENU")

	if not E.private.bags.enable then
		-- Set a different default anchor
		BagFrameHolder:Point("BOTTOMRIGHT", _G.RightChatPanel, "BOTTOMRIGHT", -(E.Border*2), 22 + E.Border*4 - E.Spacing*2)
		E:CreateMover(BagFrameHolder, 'ElvUIBagMover', L["Bag Mover"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')
		B:SecureHook('UpdateContainerFrameAnchors')
		return
	end

	B.Initialized = true
	B.db = E.db.bags
	B.BagFrames = {}
	B.REAGENTBANK_SIZE = 98 -- numRow (7) * numColumn (7) * numSubColumn (2) = size = 98
	B.ProfessionColors = {
		[0x0008]   = { B.db.colors.profession.leatherworking.r, B.db.colors.profession.leatherworking.g, B.db.colors.profession.leatherworking.b },
		[0x0010]   = { B.db.colors.profession.inscription.r, B.db.colors.profession.inscription.g, B.db.colors.profession.inscription.b },
		[0x0020]   = { B.db.colors.profession.herbs.r, B.db.colors.profession.herbs.g, B.db.colors.profession.herbs.b },
		[0x0040]   = { B.db.colors.profession.enchanting.r, B.db.colors.profession.enchanting.g, B.db.colors.profession.enchanting.b },
		[0x0080]   = { B.db.colors.profession.engineering.r, B.db.colors.profession.engineering.g, B.db.colors.profession.engineering.b },
		[0x0200]   = { B.db.colors.profession.gems.r, B.db.colors.profession.gems.g, B.db.colors.profession.gems.b },
		[0x0400]   = { B.db.colors.profession.mining.r, B.db.colors.profession.mining.g, B.db.colors.profession.mining.b },
		[0x8000]   = { B.db.colors.profession.fishing.r, B.db.colors.profession.fishing.g, B.db.colors.profession.fishing.b },
		[0x010000] = { B.db.colors.profession.cooking.r, B.db.colors.profession.cooking.g, B.db.colors.profession.cooking.b },
	}

	B.AssignmentColors = {
		[0] = { .99, .23, .21 },   -- fallback
		[2] = { B.db.colors.assignment.equipment.r , B.db.colors.assignment.equipment.g, B.db.colors.assignment.equipment.b },
		[3] = { B.db.colors.assignment.consumables.r , B.db.colors.assignment.consumables.g, B.db.colors.assignment.consumables.b },
		[4] = { B.db.colors.assignment.tradegoods.r , B.db.colors.assignment.tradegoods.g, B.db.colors.assignment.tradegoods.b },
	}

	B.QuestColors = {
		["questStarter"] = {B.db.colors.items.questStarter.r, B.db.colors.items.questStarter.g, B.db.colors.items.questStarter.b},
		["questItem"] = {B.db.colors.items.questItem.r, B.db.colors.items.questItem.g, B.db.colors.items.questItem.b},
	}

	--Bag Mover: Set default anchor point and create mover
	BagFrameHolder:Point("BOTTOMRIGHT", _G.RightChatPanel, "BOTTOMRIGHT", 0, 22 + E.Border*4 - E.Spacing*2)
	E:CreateMover(BagFrameHolder, 'ElvUIBagMover', L["Bag Mover (Grow Up)"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

	--Bank Mover
	local BankFrameHolder = CreateFrame("Frame", nil, E.UIParent)
	BankFrameHolder:Width(200)
	BankFrameHolder:Height(22)
	BankFrameHolder:Point("BOTTOMLEFT", _G.LeftChatPanel, "BOTTOMLEFT", 0, 22 + E.Border*4 - E.Spacing*2)
	BankFrameHolder:SetFrameLevel(BankFrameHolder:GetFrameLevel() + 400)
	E:CreateMover(BankFrameHolder, 'ElvUIBankMover', L["Bank Mover (Grow Up)"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

	--Set some variables on movers
	ElvUIBagMover.textGrowUp = L["Bag Mover (Grow Up)"]
	ElvUIBagMover.textGrowDown = L["Bag Mover (Grow Down)"]
	ElvUIBagMover.POINT = "BOTTOM"
	ElvUIBankMover.textGrowUp = L["Bank Mover (Grow Up)"]
	ElvUIBankMover.textGrowDown = L["Bank Mover (Grow Down)"]
	ElvUIBankMover.POINT = "BOTTOM"

	--Create Bag Frame
	B.BagFrame = B:ContructContainerFrame('ElvUI_ContainerFrame')
	B:SetupItemGlow(B.BagFrame)

	--Hook onto Blizzard Functions
	B:SecureHook('OpenAllBags', 'OpenBags')
	B:SecureHook('CloseAllBags', 'CloseBags')
	B:SecureHook('ToggleBag', 'ToggleBags')
	B:SecureHook('ToggleAllBags', 'ToggleBackpack')
	B:SecureHook('ToggleBackpack')
	B:SecureHook('BackpackTokenFrame_Update', 'UpdateTokens')
	B:Layout()

	B:DisableBlizzard()
	B:RegisterEvent("PLAYER_ENTERING_WORLD")
	B:RegisterEvent("PLAYER_MONEY", "UpdateGoldText")
	B:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGoldText")
	B:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGoldText")
	B:RegisterEvent("BANKFRAME_OPENED", "OpenBank")
	B:RegisterEvent("BANKFRAME_CLOSED", "CloseBank")
	B:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	B:RegisterEvent("GUILDBANKFRAME_OPENED")
	B:RegisterEvent("SCRAPPING_MACHINE_SHOW")
	B:RegisterEvent("SCRAPPING_MACHINE_CLOSE")

	_G.BankFrame:SetScale(0.0001)
	_G.BankFrame:SetAlpha(0)
	_G.BankFrame:SetScript("OnShow", nil)
	_G.BankFrame:ClearAllPoints()
	_G.BankFrame:Point("TOPLEFT")

	--Enable/Disable "Loot to Leftmost Bag"
	SetInsertItemsLeftToRight(E.db.bags.reverseLoot)
end

E:RegisterModule(B:GetName())
