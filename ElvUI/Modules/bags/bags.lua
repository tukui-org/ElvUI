local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule('Bags', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local Search = LibStub('LibItemSearch-1.2-ElvUI')
-- Workaround to fix broken Blizzard API to get the GetDetailedItemLevelInfo
local LibItemLevel = LibStub("LibItemLevel-ElvUI")

--Cache global variables
--Lua functions
local _G = _G
local type, ipairs, pairs, unpack, select, assert, pcall = type, ipairs, pairs, unpack, select, assert, pcall
local tinsert, tremove, twipe, tmaxn = table.insert, table.remove, table.wipe, table.maxn
local floor, ceil, abs, mod = math.floor, math.ceil, math.abs, math.fmod
local format, len, sub = string.format, string.len, string.sub
--WoW API / Variables
local BankFrameItemButton_Update = BankFrameItemButton_Update
local BankFrameItemButton_UpdateLocked = BankFrameItemButton_UpdateLocked
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_Item_CanScrapItem = C_Item.CanScrapItem
local C_Item_DoesItemExist = C_Item.DoesItemExist
local C_NewItems_IsNewItem = C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = C_NewItems.RemoveNewItem
local C_Timer_After = C_Timer.After
local CloseBag, CloseBackpack, CloseBankFrame = CloseBag, CloseBackpack, CloseBankFrame
local ContainerIDToInventoryID = ContainerIDToInventoryID
local CooldownFrame_Set = CooldownFrame_Set
local CreateAnimationGroup = CreateAnimationGroup
local CreateFrame = CreateFrame
local DeleteCursorItem = DeleteCursorItem
local DepositReagentBank = DepositReagentBank
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetBagSlotFlag = GetBagSlotFlag
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
local GetGuildBankItemLink = GetGuildBankItemLink
local GetGuildBankTabInfo = GetGuildBankTabInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMoney = GetMoney
local GetNumBankSlots = GetNumBankSlots
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local IsBagOpen, IsOptionFrameOpen = IsBagOpen, IsOptionFrameOpen
local IsInventoryItemProfessionBag = IsInventoryItemProfessionBag
local IsModifiedClick = IsModifiedClick
local IsReagentBankUnlocked = IsReagentBankUnlocked
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local PickupContainerItem = PickupContainerItem
local PlaySound = PlaySound
local PutItemInBag = PutItemInBag
local SetBagSlotFlag = SetBagSlotFlag
local SetBankBagSlotFlag = SetBankBagSlotFlag
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local SetItemButtonTexture = SetItemButtonTexture
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
local SortReagentBankBags = SortReagentBankBags
local StaticPopup_Show = StaticPopup_Show
local ToggleFrame = ToggleFrame
local UpdateSlot = UpdateSlot
local UseContainerItem = UseContainerItem

local BAG_FILTER_ASSIGN_TO = BAG_FILTER_ASSIGN_TO
local BAG_FILTER_LABELS = BAG_FILTER_LABELS
local CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y = CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y
local CONTAINER_SCALE = CONTAINER_SCALE
local CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING = CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING
local CONTAINER_WIDTH = CONTAINER_WIDTH
local IG_BACKPACK_CLOSE = SOUNDKIT.IG_BACKPACK_CLOSE
local IG_BACKPACK_OPEN = SOUNDKIT.IG_BACKPACK_OPEN
local LE_BAG_FILTER_FLAG_EQUIPMENT = LE_BAG_FILTER_FLAG_EQUIPMENT
local LE_BAG_FILTER_FLAG_JUNK = LE_BAG_FILTER_FLAG_JUNK
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

local hooksecurefunc = hooksecurefunc

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, BankFrame, ElvUIReagentBankFrameItem1, GuildBankFrame, ElvUIBags
-- GLOBALS: ContainerFrame1, RightChatToggleButton, GuildItemSearchBox, StackSplitFrame
-- GLOBALS: LeftChatToggleButton, MAX_GUILDBANK_SLOTS_PER_TAB, UISpecialFrames, HandleModifiedItemClick
-- GLOBALS: ElvUIReagentBankFrame, MerchantFrame, BagItemAutoSortButton, SetInsertItemsLeftToRight
-- GLOBALS: ElvUIBankMover, ElvUIBagMover, RightChatPanel, LeftChatPanel, IsContainerItemAnUpgrade
-- GLOBALS: ToggleDropDownMenu, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, UIDropDownMenu_Initialize

local ElvUIAssignBagDropdown, TooltipModule, SkinModule
local SEARCH_STRING = ""

function B:GetContainerFrame(arg)
	if type(arg) == 'boolean' and (arg == true) then
		return self.BankFrame;
	elseif type(arg) == 'number' then
		if self.BankFrame then
			for _, bagID in ipairs(self.BankFrame.BagIDs) do
				if bagID == arg then
					return self.BankFrame;
				end
			end
		end
	end

	return self.BagFrame;
end

function B:Tooltip_Show()
	GameTooltip:SetOwner(self);
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

function B:Tooltip_Hide()
	GameTooltip:Hide()
end

function B:DisableBlizzard()
	BankFrame:UnregisterAllEvents();

	for i=1, NUM_CONTAINER_FRAMES do
		_G['ContainerFrame'..i]:Kill();
	end
end

function B:SearchReset()
	SEARCH_STRING = ""
end

function B:IsSearching()
	return (SEARCH_STRING ~= "" and SEARCH_STRING ~= SEARCH)
end

function B:UpdateSearch()
	if self.Instructions then self.Instructions:SetShown(self:GetText() == "") end

	local MIN_REPEAT_CHARACTERS = 3;
	local searchString = self:GetText();
	local prevSearchString = SEARCH_STRING;
	if len(searchString) > MIN_REPEAT_CHARACTERS then
		local repeatChar = true
		for i=1, MIN_REPEAT_CHARACTERS, 1 do
			if sub(searchString,(0-i), (0-i)) ~= sub(searchString,(-1-i),(-1-i)) then
				repeatChar = false
				break
			end
		end

		if repeatChar then
			B.ResetAndClear(self)
			return
		end
	end

	--Keep active search term when switching between bank and reagent bank
	if searchString == SEARCH and prevSearchString ~= "" then
		searchString = prevSearchString
	elseif searchString == SEARCH then
		searchString = ''
	end

	SEARCH_STRING = searchString

	B:RefreshSearch()
	B:SetGuildBankSearch(SEARCH_STRING);
end

function B:OpenEditbox()
	self.BagFrame.detail:Hide();
	self.BagFrame.editBox:Show();
	self.BagFrame.editBox:SetText(SEARCH);
	self.BagFrame.editBox:HighlightText();
end

function B:ResetAndClear()
	local editbox = self:GetParent().editBox or self
	if editbox then editbox:SetText(SEARCH) end

	self:ClearFocus();
	B:SearchReset();
end

function B:SetSearch(query)
	local empty = len(query:gsub(' ', '')) == 0
	local method = Search.Matches
	local allowPartialMatch
	if Search.Filters.tipPhrases.keywords[query] then
		if query == "rel" or query == "reli" or query == "relic" then
			allowPartialMatch = true
		end

		method = Search.TooltipPhrase
		query = Search.Filters.tipPhrases.keywords[query]
	end

	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, link = GetContainerItemInfo(bagID, slotID);
				local button = bagFrame.Bags[bagID][slotID];
				local success, result = pcall(method, Search, link, query, allowPartialMatch)
				if empty or (success and result) then
					SetItemButtonDesaturated(button);
					button.searchOverlay:Hide();
					button:SetAlpha(1);
				else
					SetItemButtonDesaturated(button, 1);
					button.searchOverlay:Show();
					button:SetAlpha(0.5);
				end
			end
		end
	end

	if ElvUIReagentBankFrameItem1 then
		for slotID=1, 98 do
			local _, _, _, _, _, _, link = GetContainerItemInfo(REAGENTBANK_CONTAINER, slotID);
			local button = _G["ElvUIReagentBankFrameItem"..slotID]
			local success, result = pcall(method, Search, link, query)
			if empty or (success and result) then
				SetItemButtonDesaturated(button);
				button.searchOverlay:Hide();
				button:SetAlpha(1);
			else
				SetItemButtonDesaturated(button, 1);
				button.searchOverlay:Show();
				button:SetAlpha(0.5);
			end
		end
	end
end

function B:SetGuildBankSearch(query)
	local empty = len(query:gsub(' ', '')) == 0
	local method = Search.Matches
	local allowPartialMatch
	if Search.Filters.tipPhrases.keywords[query] then
		if query == "rel" or query == "reli" or query == "relic" then
			allowPartialMatch = true
		end

		method = Search.TooltipPhrase
		query = Search.Filters.tipPhrases.keywords[query]
	end

	if GuildBankFrame and GuildBankFrame:IsShown() then
		local tab = GetCurrentGuildBankTab()
		local _, _, isViewable = GetGuildBankTabInfo(tab)

		if isViewable then
			for slotID = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				local link = GetGuildBankItemLink(tab, slotID)
				--A column goes from 1-14, e.g. GuildBankColumn1Button14 (slotID 14) or GuildBankColumn2Button3 (slotID 17)
				local col = ceil(slotID / 14)
				local btn = (slotID % 14)
				if col == 0 then col = 1 end
				if btn == 0 then btn = 14 end
				local button = _G["GuildBankColumn"..col.."Button"..btn]
				local success, result = pcall(method, Search, link, query, allowPartialMatch)
				if empty or (success and result) then
					SetItemButtonDesaturated(button);
					button.searchOverlay:Hide();
					button:SetAlpha(1);
				else
					SetItemButtonDesaturated(button, 1);
					button.searchOverlay:Show();
					button:SetAlpha(0.5);
				end
			end
		end
	end
end

function B:UpdateItemLevelDisplay()
	if E.private.bags.enable ~= true then return end
	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = bagFrame.Bags[bagID][slotID]
				if slot and slot.itemLevel then
					slot.itemLevel:FontTemplate(E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
				end
			end
		end

		if bagFrame.UpdateAllSlots then
			bagFrame:UpdateAllSlots()
		end
	end
end

function B:UpdateCountDisplay()
	if E.private.bags.enable ~= true then return end
	local color = E.db.bags.countFontColor

	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = bagFrame.Bags[bagID][slotID]
				if slot and slot.Count then
					slot.Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
					slot.Count:SetTextColor(color.r, color.g, color.b)
				end
			end
		end

		if bagFrame.UpdateAllSlots then
			bagFrame:UpdateAllSlots()
		end
	end

	--Reagent Bank
	if self.BankFrame and self.BankFrame.reagentFrame then
		for i = 1, 98 do
			local slot = self.BankFrame.reagentFrame.slots[i]
			if slot then
				slot.Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
				slot.Count:SetTextColor(color.r, color.g, color.b)
				self:UpdateReagentSlot(i)
			end
		end
	end
end

function B:UpdateBagTypes(isBank)
	local f = self:GetContainerFrame(isBank);
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			f.Bags[bagID].type = select(2, GetContainerNumFreeSlots(bagID));
		end
	end
end

function B:UpdateAllBagSlots()
	if E.private.bags.enable ~= true then return end

	for _, bagFrame in pairs(self.BagFrames) do
		if bagFrame.UpdateAllSlots then
			bagFrame:UpdateAllSlots()
		end
	end
end

local function IsItemEligibleForItemLevelDisplay(classID, subClassID, equipLoc, rarity)
	if ((classID == 3 and subClassID == 11) --Artifact Relics
		or (equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_BAG" and equipLoc ~= "INVTYPE_QUIVER" and equipLoc ~= "INVTYPE_TABARD"))
		and (rarity and rarity > 1) then

		return true
	end

	return false
end

local UpdateItemUpgradeIcon;
local ITEM_UPGRADE_CHECK_TIME = 0.5;
local function UpgradeCheck_OnUpdate(self, elapsed)
	self.timeSinceUpgradeCheck = self.timeSinceUpgradeCheck + elapsed;

	if self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME then
		UpdateItemUpgradeIcon(self);
	end
end

function UpdateItemUpgradeIcon(slot)
	if not E.db.bags.upgradeIcon then
		slot.UpgradeIcon:SetShown(false);
		slot:SetScript("OnUpdate", nil);
		return
	end

	slot.timeSinceUpgradeCheck = 0;

	local itemIsUpgrade = IsContainerItemAnUpgrade(slot:GetParent():GetID(), slot:GetID());
	if itemIsUpgrade == nil then -- nil means not all the data was available to determine if this is an upgrade.
		slot.UpgradeIcon:SetShown(false);
		slot:SetScript("OnUpdate", UpgradeCheck_OnUpdate);
	else
		slot.UpgradeIcon:SetShown(itemIsUpgrade);
		slot:SetScript("OnUpdate", nil);
	end
end

local UpdateItemScrapIcon;
function UpdateItemScrapIcon(slot)
	-- TO DO: Add an update to only show the Scrap Icon if the ScrappingMachineFrame is open
	-- Also the option dont update correctly.
	if not E.db.bags.scrapIcon then
		slot.ScrapIcon:SetShown(false)
		return
	end

	local itemLocation = ItemLocation:CreateFromBagAndSlot(slot:GetParent():GetID(), slot:GetID())
	if not itemLocation then return end

	if itemLocation and itemLocation ~= "" then
		if (C_Item_DoesItemExist(itemLocation) and C_Item_CanScrapItem(itemLocation)) and E.db.bags.scrapIcon then
			slot.ScrapIcon:SetShown(itemLocation)
		else
			slot.ScrapIcon:SetShown(false)
		end
	end
end

function B:NewItemGlowSlotSwitch(slot, show)
	if slot and slot.newItemGlow then
		if show and E.db.bags.newItemGlow then
			slot.newItemGlow:Show()
			E:Flash(slot.newItemGlow, 0.5, true)
		else
			slot.newItemGlow:Hide()
			E:StopFlash(slot.newItemGlow)

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

local function hideNewItemGlow(slot)
	B:NewItemGlowSlotSwitch(slot)
end

function B:UpdateSlot(bagID, slotID)
	if (self.Bags[bagID] and self.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or not self.Bags[bagID] or not self.Bags[bagID][slotID] then
		return;
	end

	local slot = self.Bags[bagID][slotID];
	local bagType = self.Bags[bagID].type;

	local assignedID = (self.isBank and bagID) or bagID - 1
	local assignedBag = self.Bags[assignedID] and self.Bags[assignedID].assigned

	slot.name, slot.rarity = nil, nil
	local texture, count, locked, readable, noValue, _
	texture, count, locked, slot.rarity, readable, _, _, _, noValue = GetContainerItemInfo(bagID, slotID)

	local clink = GetContainerItemLink(bagID, slotID)

	slot:Show();
	if slot.questIcon then
		slot.questIcon:Hide();
	end

	if slot.Azerite then
		slot.Azerite:Hide()
	end

	if slot.JunkIcon then
		if slot.rarity and (slot.rarity == LE_ITEM_QUALITY_POOR and not noValue) and E.db.bags.junkIcon then
			slot.JunkIcon:Show()
		else
			slot.JunkIcon:Hide()
		end
	end

	if slot.ScrapIcon then
		UpdateItemScrapIcon(slot)
	end

	if slot.UpgradeIcon then
		--Check if item is an upgrade and show/hide upgrade icon accordingly
		UpdateItemUpgradeIcon(slot)
	end

	slot.itemLevel:SetText("")

	if B.ProfessionColors[bagType] then
		local r, g, b = unpack(B.ProfessionColors[bagType])
		slot.newItemGlow:SetVertexColor(r, g, b)
		slot:SetBackdropBorderColor(r, g, b)
		slot.ignoreBorderColors = true
	elseif clink then
		local itemEquipLoc, itemClassID, itemSubClassID
		slot.name, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = GetItemInfo(clink);

		-- Workaround to fix broken Blizzard API to get the GetDetailedItemLevelInfo
		local _, iLvl = LibItemLevel:GetItemInfo(clink)
		-- iLvl = GetDetailedItemLevelInfo(clink)

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
		local r, g, b

		if slot.rarity then
			r, g, b = GetItemQualityColor(slot.rarity);
		end

		--Item Level
		if iLvl and B.db.itemLevel and IsItemEligibleForItemLevelDisplay(itemClassID, itemSubClassID, itemEquipLoc, slot.rarity) then
			if (iLvl >= B.db.itemLevelThreshold) then
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
				slot.questIcon:Show();
			end
		elseif questId or isQuestItem then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questItem))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
			slot.ignoreBorderColors = true
		elseif slot.rarity and slot.rarity > 1 then
			slot.newItemGlow:SetVertexColor(r, g, b);
			slot:SetBackdropBorderColor(r, g, b);
			slot.ignoreBorderColors = true
			if slot.Azerite and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(clink) then slot.Azerite:Show() end
		elseif B.AssignmentColors[assignedBag] then
			local rr, gg, bb = unpack(B.AssignmentColors[assignedBag])
			slot.newItemGlow:SetVertexColor(rr, gg, bb)
			slot:SetBackdropBorderColor(rr, gg, bb)
			slot.ignoreBorderColors = true
		else
			slot.newItemGlow:SetVertexColor(1, 1, 1)
			slot:SetBackdropBorderColor(unpack(E.media.bordercolor))
			slot.ignoreBorderColors = nil
		end
	elseif B.AssignmentColors[assignedBag] then
		local rr, gg, bb = unpack(B.AssignmentColors[assignedBag])
		slot.newItemGlow:SetVertexColor(rr, gg, bb)
		slot:SetBackdropBorderColor(rr, gg, bb)
		slot.ignoreBorderColors = true
	else
		slot.newItemGlow:SetVertexColor(1, 1, 1)
		slot:SetBackdropBorderColor(unpack(E.media.bordercolor))
		slot.ignoreBorderColors = nil
	end

	B:NewItemGlowSlotSwitch(slot, C_NewItems_IsNewItem(bagID, slotID))

	if texture then
		local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
		CooldownFrame_Set(slot.cooldown, start, duration, enable)
		if duration > 0 and enable == 0 then
			SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(slot, 1, 1, 1);
		end
		slot.hasItem = 1;
	else
		slot.cooldown:Hide()
		slot.hasItem = nil;
	end

	slot.readable = readable;

	SetItemButtonTexture(slot, texture);
	SetItemButtonCount(slot, count);
	SetItemButtonDesaturated(slot, locked);

	if GameTooltip:GetOwner() == slot and not slot.hasItem then
		B:Tooltip_Hide()
	end
end

function B:UpdateBagSlots(bagID)
	if bagID == REAGENTBANK_CONTAINER then
		for i=1, 98 do
			self:UpdateReagentSlot(i);
		end
	else
		for slotID = 1, GetContainerNumSlots(bagID) do
			if self.UpdateSlot then
				self:UpdateSlot(bagID, slotID);
			else
				self:GetParent():GetParent():UpdateSlot(bagID, slotID);
			end
		end
	end
end

function B:RefreshSearch()
	B:SetSearch(SEARCH_STRING)
end

function B:SortingFadeBags(bagFrame)
	if not (bagFrame and bagFrame.BagIDs) then return end

	for _, bagID in ipairs(bagFrame.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local button = bagFrame.Bags[bagID][slotID];
			SetItemButtonDesaturated(button, 1);
			button.searchOverlay:Show();
			button:SetAlpha(0.5);
		end
	end
end

function B:UpdateCooldowns()
	for _, bagID in ipairs(self.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
			CooldownFrame_Set(self.Bags[bagID][slotID].cooldown, start, duration, enable)
		end
	end
end

function B:UpdateAllSlots()
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			self.Bags[bagID]:UpdateBagSlots(bagID);
		end
	end

	-- Refresh search in case we moved items around
	if (not self.registerUpdate) and B:IsSearching() then
		B:RefreshSearch()
	end
end

function B:SetSlotAlphaForBag(f)
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			local numSlots = GetContainerNumSlots(bagID);
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
			local numSlots = GetContainerNumSlots(bagID);
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

function B:AssignBagFlagMenu()
	local holder = ElvUIAssignBagDropdown.holder
	ElvUIAssignBagDropdown.holder = nil

	if not (holder and holder.id and holder.id > 0) then return end

	local inventoryID = ContainerIDToInventoryID(holder.id)
	if IsInventoryItemProfessionBag("player", inventoryID) then return end

	local info = UIDropDownMenu_CreateInfo()
	info.text = BAG_FILTER_ASSIGN_TO
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info)

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

				holder.tempflag = (value and i) or -1
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
			UIDropDownMenu_AddButton(info)
		end
	end
end

function B:GetBagAssignedInfo(holder)
	if not (holder and holder.id and holder.id > 0) then return end

	local inventoryID = ContainerIDToInventoryID(holder.id)
	if IsInventoryItemProfessionBag("player", inventoryID) then return end

	if holder.tempflag then
		holder.tempflag = nil --clear tempflag from AssignBagFlagMenu
	end

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

function B:Layout(isBank)
	if E.private.bags.enable ~= true then return end
	local f = self:GetContainerFrame(isBank);

	if not f then return end
	local buttonSize = isBank and self.db.bankSize or self.db.bagSize;
	local buttonSpacing = E.Border*2;
	local containerWidth = ((isBank and self.db.bankWidth) or self.db.bagWidth)
	local numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing));
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local numContainerRows = 0;
	local numBags = 0;
	local numBagSlots = 0;
	local bagSpacing = self.db.split.bagSpacing
	local countColor = E.db.bags.countFontColor
	f.holderFrame:Width(holderWidth);

	local isSplit = self.db.split[isBank and 'bank' or 'player']

	if isBank then
		f.reagentFrame:Width(holderWidth)
	end

	f.totalSlots = 0
	local lastButton;
	local lastRowButton;
	local lastContainerButton;
	local numContainerSlots = GetNumBankSlots();
	local newBag
	for i, bagID in ipairs(f.BagIDs) do
		local assignedBag
		if isSplit then
			newBag = (bagID ~= -1 or bagID ~= 0) and self.db.split['bag'..bagID] or false;
		end

		--Bag Containers
		if (not isBank and bagID <= 3 ) or (isBank and bagID ~= -1 and numContainerSlots >= 1 and not (i - 1 > numContainerSlots)) then
			if not f.ContainerHolder[i] then
				if isBank then
					f.ContainerHolder[i] = CreateFrame("CheckButton", "ElvUIBankBag" .. (bagID-4), f.ContainerHolder, "BankItemButtonBagTemplate")
					f.ContainerHolder[i]:SetScript('OnClick', function(holder, button)
						if button == "RightButton" and holder.id then
							ElvUIAssignBagDropdown.holder = holder
							ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
						else
							local inventoryID = holder:GetInventorySlot();
							PutItemInBag(inventoryID);--Put bag on empty slot, or drop item in this bag
						end
					end)
				else
					f.ContainerHolder[i] = CreateFrame("CheckButton", "ElvUIMainBag" .. bagID .. "Slot", f.ContainerHolder, "BagSlotButtonTemplate")
					f.ContainerHolder[i]:SetScript('OnClick', function(holder, button)
						if button == "RightButton" and holder.id then
							ElvUIAssignBagDropdown.holder = holder
							ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
						else
							local id = holder:GetID();
							PutItemInBag(id);--Put bag on empty slot, or drop item in this bag
						end
					end)
				end

				f.ContainerHolder[i]:SetTemplate('Default', true)
				f.ContainerHolder[i]:StyleButton()
				f.ContainerHolder[i].IconBorder:SetAlpha(0)
				f.ContainerHolder[i]:SetNormalTexture("")
				f.ContainerHolder[i]:SetCheckedTexture(nil)
				f.ContainerHolder[i]:SetPushedTexture("")

				f.ContainerHolder[i].id = isBank and bagID or bagID + 1
				f.ContainerHolder[i]:HookScript("OnEnter", function(ch) B.SetSlotAlphaForBag(ch, f) end)
				f.ContainerHolder[i]:HookScript("OnLeave", function(ch) B.ResetSlotAlphaForBags(ch, f) end)

				if isBank then
					f.ContainerHolder[i]:SetID(bagID - 4)
					if not f.ContainerHolder[i].tooltipText then
						f.ContainerHolder[i].tooltipText = ""
					end
				end

				f.ContainerHolder[i].iconTexture = _G[f.ContainerHolder[i]:GetName()..'IconTexture'];
				f.ContainerHolder[i].iconTexture:SetInside()
				f.ContainerHolder[i].iconTexture:SetTexCoord(unpack(E.TexCoords))
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

			lastContainerButton = f.ContainerHolder[i];
		end

		--Bag Slots
		local numSlots = GetContainerNumSlots(bagID);
		if numSlots > 0 then
			if not f.Bags[bagID] then
				f.Bags[bagID] = CreateFrame('Frame', f:GetName()..'Bag'..bagID, f.holderFrame);
				f.Bags[bagID]:SetID(bagID);
				f.Bags[bagID].UpdateBagSlots = B.UpdateBagSlots;
				f.Bags[bagID].UpdateSlot = UpdateSlot;
			end

			f.Bags[bagID].numSlots = numSlots;
			f.Bags[bagID].assigned = assignedBag;
			f.Bags[bagID].type = select(2, GetContainerNumFreeSlots(bagID));

			--Hide unused slots
			for y = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID][y] then
					f.Bags[bagID][y]:Hide();
				end
			end

			for slotID = 1, numSlots do
				f.totalSlots = f.totalSlots + 1;
				if not f.Bags[bagID][slotID] then
					f.Bags[bagID][slotID] = CreateFrame('CheckButton', f.Bags[bagID]:GetName()..'Slot'..slotID, f.Bags[bagID], bagID == -1 and 'BankItemButtonGenericTemplate' or 'ContainerFrameItemButtonTemplate');
					f.Bags[bagID][slotID]:StyleButton();
					f.Bags[bagID][slotID]:SetTemplate('Default', true);
					f.Bags[bagID][slotID]:SetNormalTexture(nil);
					f.Bags[bagID][slotID]:SetCheckedTexture(nil);

					if _G[f.Bags[bagID][slotID]:GetName()..'NewItemTexture'] then
						_G[f.Bags[bagID][slotID]:GetName()..'NewItemTexture']:Hide()
					end

					f.Bags[bagID][slotID].Count:ClearAllPoints();
					f.Bags[bagID][slotID].Count:Point('BOTTOMRIGHT', 0, 2);
					f.Bags[bagID][slotID].Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
					f.Bags[bagID][slotID].Count:SetTextColor(countColor.r, countColor.g, countColor.b)

					if not(f.Bags[bagID][slotID].questIcon) then
						f.Bags[bagID][slotID].questIcon = _G[f.Bags[bagID][slotID]:GetName()..'IconQuestTexture'] or _G[f.Bags[bagID][slotID]:GetName()].IconQuestTexture
						f.Bags[bagID][slotID].questIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon");
						f.Bags[bagID][slotID].questIcon:SetTexCoord(0,1,0,1);
						f.Bags[bagID][slotID].questIcon:SetInside();
						f.Bags[bagID][slotID].questIcon:Hide();
					end

					if f.Bags[bagID][slotID].UpgradeIcon then
						f.Bags[bagID][slotID].UpgradeIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagUpgradeIcon");
						f.Bags[bagID][slotID].UpgradeIcon:SetTexCoord(0,1,0,1);
						f.Bags[bagID][slotID].UpgradeIcon:SetInside();
						f.Bags[bagID][slotID].UpgradeIcon:Hide();
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
						ScrapIcon:SetSize(14, 12)
						ScrapIcon:Point("TOPRIGHT", -1, -1)
						ScrapIcon:Hide()
						f.Bags[bagID][slotID].ScrapIcon = ScrapIcon
					end

					if not f.Bags[bagID][slotID].Azerite then
						f.Bags[bagID][slotID].Azerite = f.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
						f.Bags[bagID][slotID].Azerite:SetAtlas("AzeriteIconFrame")
						f.Bags[bagID][slotID].Azerite:SetTexCoord(0,1,0,1);
						f.Bags[bagID][slotID].Azerite:SetInside();
						f.Bags[bagID][slotID].Azerite:Hide();
					end

					f.Bags[bagID][slotID].iconTexture = _G[f.Bags[bagID][slotID]:GetName()..'IconTexture'];
					f.Bags[bagID][slotID].iconTexture:SetInside(f.Bags[bagID][slotID]);
					f.Bags[bagID][slotID].iconTexture:SetTexCoord(unpack(E.TexCoords));

					f.Bags[bagID][slotID].searchOverlay:SetAllPoints();
					f.Bags[bagID][slotID].cooldown = _G[f.Bags[bagID][slotID]:GetName()..'Cooldown'];
					f.Bags[bagID][slotID].cooldown.CooldownOverride = 'bags'
					E:RegisterCooldown(f.Bags[bagID][slotID].cooldown)
					f.Bags[bagID][slotID].bagID = bagID
					f.Bags[bagID][slotID].slotID = slotID

					f.Bags[bagID][slotID].itemLevel = f.Bags[bagID][slotID]:CreateFontString(nil, 'OVERLAY')
					f.Bags[bagID][slotID].itemLevel:Point("BOTTOMRIGHT", 0, 2)
					f.Bags[bagID][slotID].itemLevel:FontTemplate(E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)

					if f.Bags[bagID][slotID].BattlepayItemTexture then
						f.Bags[bagID][slotID].BattlepayItemTexture:Hide()
					end

					if not f.Bags[bagID][slotID].newItemGlow then
						local newItemGlow = f.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
						newItemGlow:SetInside()
						newItemGlow:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagNewItemGlow")
						newItemGlow:Hide()
						f.Bags[bagID][slotID].newItemGlow = newItemGlow
						f.Bags[bagID][slotID]:HookScript("OnEnter", hideNewItemGlow)
					end
				end

				f.Bags[bagID][slotID]:SetID(slotID);
				f.Bags[bagID][slotID]:Size(buttonSize);

				if f.Bags[bagID][slotID].JunkIcon then
					f.Bags[bagID][slotID].JunkIcon:Size(buttonSize/2)
				end

				f:UpdateSlot(bagID, slotID);

				if f.Bags[bagID][slotID]:GetPoint() then
					f.Bags[bagID][slotID]:ClearAllPoints();
				end

				local anchorPoint, relativePoint
				if lastButton then
					anchorPoint, relativePoint = (self.db.reverseSlots and 'BOTTOM' or 'TOP'), (self.db.reverseSlots and 'TOP' or 'BOTTOM')
					if isSplit and newBag and slotID == 1 then
						f.Bags[bagID][slotID]:Point(anchorPoint, lastRowButton, relativePoint, 0, self.db.reverseSlots and (buttonSpacing + bagSpacing) or -(buttonSpacing + bagSpacing));
						lastRowButton = f.Bags[bagID][slotID];
						numContainerRows = numContainerRows + 1;
						numBags = numBags + 1;
						numBagSlots = 0;
					elseif isSplit and numBagSlots % numContainerColumns == 0 then
						f.Bags[bagID][slotID]:Point(anchorPoint, lastRowButton, relativePoint, 0, self.db.reverseSlots and buttonSpacing or -buttonSpacing);
						lastRowButton = f.Bags[bagID][slotID];
						numContainerRows = numContainerRows + 1;
					elseif (not isSplit) and (f.totalSlots - 1) % numContainerColumns == 0 then
						f.Bags[bagID][slotID]:Point(anchorPoint, lastRowButton, relativePoint, 0, self.db.reverseSlots and buttonSpacing or -buttonSpacing);
						lastRowButton = f.Bags[bagID][slotID];
						numContainerRows = numContainerRows + 1;
					else
						anchorPoint, relativePoint = (self.db.reverseSlots and 'RIGHT' or 'LEFT'), (self.db.reverseSlots and 'LEFT' or 'RIGHT')
						f.Bags[bagID][slotID]:Point(anchorPoint, lastButton, relativePoint, self.db.reverseSlots and -buttonSpacing or buttonSpacing, 0);
					end
				else
					anchorPoint = self.db.reverseSlots and 'BOTTOMRIGHT' or 'TOPLEFT'
					f.Bags[bagID][slotID]:Point(anchorPoint, f.holderFrame, anchorPoint);
					lastRowButton = f.Bags[bagID][slotID];
					numContainerRows = numContainerRows + 1;
				end

				lastButton = f.Bags[bagID][slotID];
				numBagSlots = numBagSlots + 1;
			end
		else
			--Hide unused slots
			for y = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID] and f.Bags[bagID][y] then
					f.Bags[bagID][y]:Hide();
				end
			end

			if f.Bags[bagID] then
				f.Bags[bagID].numSlots = numSlots;
			end

			if self.isBank then
				if self.ContainerHolder[i] then
					BankFrameItemButton_Update(self.ContainerHolder[i])
					BankFrameItemButton_UpdateLocked(self.ContainerHolder[i])
				end
			end
		end
	end

	if isBank and f.reagentFrame:IsShown() then
		if not IsReagentBankUnlocked() then
			f.reagentFrame.cover:Show();
			B:RegisterEvent("REAGENTBANK_PURCHASED")
		else
			f.reagentFrame.cover:Hide();
		end

		local totalSlots, lastReagentRowButton = 0
		numContainerRows = 1
		for i = 1, 98 do
			totalSlots = totalSlots + 1;

			if(not f.reagentFrame.slots[i]) then
				f.reagentFrame.slots[i] = CreateFrame("Button", "ElvUIReagentBankFrameItem"..i, f.reagentFrame, "ReagentBankItemButtonGenericTemplate");
				f.reagentFrame.slots[i]:SetID(i)

				f.reagentFrame.slots[i]:StyleButton()
				f.reagentFrame.slots[i]:SetTemplate('Default', true);
				f.reagentFrame.slots[i]:SetNormalTexture(nil);

				f.reagentFrame.slots[i].Count:ClearAllPoints();
				f.reagentFrame.slots[i].Count:Point('BOTTOMRIGHT', 0, 2);
				f.reagentFrame.slots[i].Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
				f.reagentFrame.slots[i].Count:SetTextColor(countColor.r, countColor.g, countColor.b)

				f.reagentFrame.slots[i].searchOverlay:SetAllPoints();
				f.reagentFrame.slots[i].iconTexture = _G[f.reagentFrame.slots[i]:GetName()..'IconTexture'];
				f.reagentFrame.slots[i].iconTexture:SetInside(f.reagentFrame.slots[i]);
				f.reagentFrame.slots[i].iconTexture:SetTexCoord(unpack(E.TexCoords));
				f.reagentFrame.slots[i].IconBorder:SetAlpha(0)

				if not f.reagentFrame.slots[i].newItemGlow then
					local newItemGlow = f.reagentFrame.slots[i]:CreateTexture(nil, "OVERLAY")
					newItemGlow:SetInside()
					newItemGlow:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagNewItemGlow")
					newItemGlow:Hide()
					f.reagentFrame.slots[i].newItemGlow = newItemGlow
					f.reagentFrame.slots[i]:HookScript("OnEnter", hideNewItemGlow)
				end
			end

			f.reagentFrame.slots[i]:ClearAllPoints()
			f.reagentFrame.slots[i]:Size(buttonSize)
			if f.reagentFrame.slots[i-1] then
				if(totalSlots - 1) % numContainerColumns == 0 then
					f.reagentFrame.slots[i]:Point('TOP', lastReagentRowButton, 'BOTTOM', 0, -buttonSpacing);
					lastReagentRowButton = f.reagentFrame.slots[i];
					numContainerRows = numContainerRows + 1;
				else
					f.reagentFrame.slots[i]:Point('LEFT', f.reagentFrame.slots[i-1], 'RIGHT', buttonSpacing, 0);
				end
			else
				f.reagentFrame.slots[i]:Point('TOPLEFT', f.reagentFrame, 'TOPLEFT');
				lastReagentRowButton = f.reagentFrame.slots[i]
			end

			self:UpdateReagentSlot(i)
		end
	end

	f:Size(containerWidth, (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + (isSplit and (numBags * bagSpacing) or 0 ) + f.topOffset + f.bottomOffset); -- 8 is the cussion of the f.holderFrame
end

function B:UpdateReagentSlot(slotID)
	assert(slotID)
	local bagID = REAGENTBANK_CONTAINER
	local texture, count, locked = GetContainerItemInfo(bagID, slotID);
	local clink = GetContainerItemLink(bagID, slotID);
	local slot = _G["ElvUIReagentBankFrameItem"..slotID]
	if not slot then return end

	slot:Show();
	if slot.questIcon then
		slot.questIcon:Hide();
	end

	slot.name, slot.rarity = nil, nil;

	local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
	CooldownFrame_Set(slot.Cooldown, start, duration, enable)
	if duration > 0 and enable == 0 then
		SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4);
	else
		SetItemButtonTextureVertexColor(slot, 1, 1, 1);
	end

	if clink then
		local name, _, rarity = GetItemInfo(clink);
		slot.name, slot.rarity = name, rarity

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
		local r, g, b

		if slot.rarity then
			r, g, b = GetItemQualityColor(slot.rarity);
		end

		-- color slot according to item quality
		if questId and not isActiveQuest then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questStarter))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questStarter))
			slot.ignoreBorderColors = true
			if (slot.questIcon) then
				slot.questIcon:Show();
			end
		elseif questId or isQuestItem then
			slot.newItemGlow:SetVertexColor(unpack(B.QuestColors.questItem))
			slot:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
			slot.ignoreBorderColors = true
		elseif slot.rarity and slot.rarity > 1 then
			slot.newItemGlow:SetVertexColor(r, g, b);
			slot:SetBackdropBorderColor(r, g, b);
			slot.ignoreBorderColors = true
		else
			slot.newItemGlow:SetVertexColor(1, 1, 1)
			slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
			slot.ignoreBorderColors = nil
		end
	else
		slot.newItemGlow:SetVertexColor(1, 1, 1);
		slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
		slot.ignoreBorderColors = nil
	end

	B:NewItemGlowSlotSwitch(slot, C_NewItems_IsNewItem(bagID, slotID))

	SetItemButtonTexture(slot, texture);
	SetItemButtonCount(slot, count);
	SetItemButtonDesaturated(slot, locked);
end

function B:UpdateAll()
	if self.BagFrame then
		self:Layout();
	end

	if self.BankFrame then
		self:Layout(true);
	end
end

function B:OnEvent(event, ...)
	if event == 'ITEM_LOCK_CHANGED' or event == 'ITEM_UNLOCKED' then
		local bag, slot = ...
		if bag == REAGENTBANK_CONTAINER then
			B:UpdateReagentSlot(slot);
		else
			self:UpdateSlot(bag, slot);
		end
	elseif event == 'BAG_UPDATE' then
		for _, bagID in ipairs(self.BagIDs) do
			local numSlots = GetContainerNumSlots(bagID)
			if (not self.Bags[bagID] and numSlots ~= 0) or (self.Bags[bagID] and numSlots ~= self.Bags[bagID].numSlots) then
				B:Layout(self.isBank);
				return;
			end
		end

		self:UpdateBagSlots(...);

		--Refresh search in case we moved items around
		if B:IsSearching() then
			B:RefreshSearch()
		end
	elseif event == 'BAG_UPDATE_COOLDOWN' then
		self:UpdateCooldowns();
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		local slot = ...
		local bagID = (slot <= NUM_BANKGENERIC_SLOTS) and -1 or (slot - NUM_BANKGENERIC_SLOTS)
		if bagID > -1 then
			B:Layout(true)
		else
			self:UpdateBagSlots(-1)
		end
	elseif event == 'PLAYERREAGENTBANKSLOTS_CHANGED' then
		B:UpdateReagentSlot(...)
	elseif (event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED") and self:IsShown() then
		self:UpdateAllSlots()
	elseif (event == "BANK_BAG_SLOT_FLAGS_UPDATED" or event == "BAG_SLOT_FLAGS_UPDATED") then
		B:Layout(self.isBank);
	end
end

function B:UpdateTokens()
	local f = self.BagFrame;

	local numTokens = 0
	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i);
		local button = f.currencyButton[i];

		button:ClearAllPoints();
		if name then
			button.icon:SetTexture(icon);

			if self.db.currencyFormat == 'ICON_TEXT' then
				button.text:SetText(name..': '..count);
			elseif self.db.currencyFormat == "ICON_TEXT_ABBR" then
				button.text:SetText(E:AbbreviateString(name)..': '..count);
			elseif self.db.currencyFormat == 'ICON' then
				button.text:SetText(count);
			end

			button.currencyID = currencyID;
			button:Show();
			numTokens = numTokens + 1;
		else
			button:Hide();
		end
	end

	if numTokens == 0 then
		f.bottomOffset = 8;

		if f.currencyButton:IsShown() then
			f.currencyButton:Hide();
			self:Layout();
		end

		return;
	elseif not f.currencyButton:IsShown() then
		f.bottomOffset = 28;
		f.currencyButton:Show();
		self:Layout();
	end

	f.bottomOffset = 28;
	if numTokens == 1 then
		f.currencyButton[1]:Point('BOTTOM', f.currencyButton, 'BOTTOM', -(f.currencyButton[1].text:GetWidth() / 2), 3);
	elseif numTokens == 2 then
		f.currencyButton[1]:Point('BOTTOM', f.currencyButton, 'BOTTOM', -(f.currencyButton[1].text:GetWidth()) - (f.currencyButton[1]:GetWidth() / 2), 3);
		f.currencyButton[2]:Point('BOTTOMLEFT', f.currencyButton, 'BOTTOM', f.currencyButton[2]:GetWidth() / 2, 3);
	else
		f.currencyButton[1]:Point('BOTTOMLEFT', f.currencyButton, 'BOTTOMLEFT', 3, 3);
		f.currencyButton[2]:Point('BOTTOM', f.currencyButton, 'BOTTOM', -(f.currencyButton[2].text:GetWidth() / 3), 3);
		f.currencyButton[3]:Point('BOTTOMRIGHT', f.currencyButton, 'BOTTOMRIGHT', -(f.currencyButton[3].text:GetWidth()) - (f.currencyButton[3]:GetWidth() / 2), 3);
	end
end

function B:Token_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetBackpackToken(self:GetID());
end

function B:Token_OnClick()
	if IsModifiedClick("CHATLINK") then
		HandleModifiedItemClick(GetCurrencyLink(self.currencyID));
	end
end

function B:UpdateGoldText()
	self.BagFrame.goldText:SetText(E:FormatMoney(GetMoney(), E.db.bags.moneyFormat, not E.db.bags.moneyCoins))
end

function B:FormatMoney(amount)
	local str, coppername, silvername, goldname = "", "|cffeda55fc|r", "|cffc7c7cfs|r", "|cffffd700g|r"

	local value = abs(amount)
	local gold = floor(value / 10000)
	local silver = floor(mod(value / 100, 100))
	local copper = floor(mod(value, 100))

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
	local value, itemID, rarity, itype, itemPrice, stackCount, stackPrice, _ = 0

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemID = GetContainerItemID(bag, slot)
			if itemID then
				_, _, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)
				if itemPrice then
					stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
					stackPrice = itemPrice * stackCount
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
	if (not MerchantFrame or not MerchantFrame:IsShown()) and not delete then
		E:Print(L["You must be at a vendor."])
		return
	end

	local link, rarity, itype, itemPrice, itemID, _
	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			itemID = GetContainerItemID(bag, slot)
			if itemID then
				_, link, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)

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
	elseif not MerchantFrame or not MerchantFrame:IsShown() then
		E.PopupDialogs["DELETE_GRAYS"].Money = value
		E:StaticPopup_Show('DELETE_GRAYS')
	else
		B:VendorGrays()
	end
end

function B:ContructContainerFrame(name, isBank)
	if not SkinModule then SkinModule = E:GetModule('Skins') end

	local strata = E.db.bags.strata or 'HIGH'

	local f = CreateFrame('Button', name, E.UIParent);
	f:SetTemplate('Transparent');
	f:SetFrameStrata(strata);
	f.UpdateSlot = B.UpdateSlot;
	f.UpdateAllSlots = B.UpdateAllSlots;
	f.UpdateBagSlots = B.UpdateBagSlots;
	f.UpdateCooldowns = B.UpdateCooldowns;
	f:RegisterEvent("BAG_UPDATE") -- Has to be on both frames
	f:RegisterEvent("BAG_UPDATE_COOLDOWN") -- Has to be on both frames
	f.events = isBank and { "PLAYERREAGENTBANKSLOTS_CHANGED", "BANK_BAG_SLOT_FLAGS_UPDATED", "PLAYERBANKSLOTS_CHANGED" } or { "ITEM_LOCK_CHANGED", "ITEM_UNLOCKED", "BAG_SLOT_FLAGS_UPDATED", "QUEST_ACCEPTED", "QUEST_REMOVED" }

	for _, event in pairs(f.events) do
		f:RegisterEvent(event)
	end

	f:SetScript('OnEvent', B.OnEvent);
	f:Hide();

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
	f:RegisterForClicks("AnyUp");
	f:SetScript("OnDragStart", function(frame) if IsShiftKeyDown() then frame:StartMoving() end end)
	f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
	f:SetScript("OnClick", function(frame) if IsControlKeyDown() then B.PostBagMove(frame.mover) end end)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	f:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Hold Control + Right Click:"], L["Reset Position"], 1, 1, 1)
		GameTooltip:Show()
	end)

	f.closeButton = CreateFrame('Button', name..'CloseButton', f, 'UIPanelCloseButton');
	f.closeButton:Point('TOPRIGHT', -4, -4);

	SkinModule:HandleCloseButton(f.closeButton);

	f.holderFrame = CreateFrame('Frame', nil, f);
	f.holderFrame:Point('TOP', f, 'TOP', 0, -f.topOffset);
	f.holderFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8);

	f.ContainerHolder = CreateFrame('Button', name..'ContainerHolder', f)
	f.ContainerHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1)
	f.ContainerHolder:SetTemplate('Transparent')
	f.ContainerHolder:Hide()

	if isBank then
		f.reagentFrame = CreateFrame("Frame", "ElvUIReagentBankFrame", f);
		f.reagentFrame:Point('TOP', f, 'TOP', 0, -f.topOffset);
		f.reagentFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8);
		f.reagentFrame.slots = {}
		f.reagentFrame:SetID(REAGENTBANK_CONTAINER)
		f.reagentFrame:Hide()

		f.reagentFrame.cover = CreateFrame("Button", nil, f.reagentFrame)
		f.reagentFrame.cover:SetAllPoints(f.reagentFrame)
		f.reagentFrame.cover:SetTemplate("Default", true)
		f.reagentFrame.cover:SetFrameLevel(f.reagentFrame:GetFrameLevel() + 10)

		f.reagentFrame.cover.purchaseButton = CreateFrame("Button", nil, f.reagentFrame.cover)
		f.reagentFrame.cover.purchaseButton:Height(20)
		f.reagentFrame.cover.purchaseButton:Width(150)
		f.reagentFrame.cover.purchaseButton:Point('CENTER', f.reagentFrame.cover, 'CENTER')
		SkinModule:HandleButton(f.reagentFrame.cover.purchaseButton)
		f.reagentFrame.cover.purchaseButton:SetFrameLevel(f.reagentFrame.cover.purchaseButton:GetFrameLevel() + 2)
		f.reagentFrame.cover.purchaseButton.text = f.reagentFrame.cover.purchaseButton:CreateFontString(nil, 'OVERLAY')
		f.reagentFrame.cover.purchaseButton.text:FontTemplate()
		f.reagentFrame.cover.purchaseButton.text:Point('CENTER')
		f.reagentFrame.cover.purchaseButton.text:SetJustifyH('CENTER')
		f.reagentFrame.cover.purchaseButton.text:SetText(L["Purchase"])
		f.reagentFrame.cover.purchaseButton:SetScript("OnClick", function()
			PlaySound(852) --IG_MAINMENU_OPTION
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB");
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

		f.reagentToggle = CreateFrame("Button", name..'ReagentButton', f);
		f.reagentToggle:SetSize(16 + E.Border, 16 + E.Border)
		f.reagentToggle:SetTemplate()
		f.reagentToggle:Point("RIGHT", f.bagText, "LEFT", -5, E.Border * 2)
		f.reagentToggle:SetNormalTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.reagentToggle:GetNormalTexture():SetInside()
		f.reagentToggle:SetPushedTexture("Interface\\ICONS\\INV_Enchant_DustArcane")
		f.reagentToggle:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.reagentToggle:GetPushedTexture():SetInside()
		f.reagentToggle:StyleButton(nil, true)
		f.reagentToggle.ttText = L["Show/Hide Reagents"];
		f.reagentToggle:SetScript("OnEnter", self.Tooltip_Show)
		f.reagentToggle:SetScript("OnLeave", self.Tooltip_Hide)
		f.reagentToggle:SetScript("OnClick", function()
			PlaySound(841) --IG_CHARACTER_INFO_TAB
			if f.holderFrame:IsShown() then
				BankFrame.selectedTab = 2
				f.holderFrame:Hide()
				f.reagentFrame:Show()
				f.editBox:Point('RIGHT', f.depositButton, 'LEFT', -5, 0);
				f.bagText:SetText(L["Reagent Bank"])
			else
				BankFrame.selectedTab = 1
				f.reagentFrame:Hide()
				f.holderFrame:Show()
				f.editBox:Point('RIGHT', f.purchaseBagButton, 'LEFT', -5, 0);
				f.bagText:SetText(L["Bank"])
			end

			self:Layout(true)
			f:Show()
		end)

		--Sort Button
		f.sortButton = CreateFrame("Button", name..'SortButton', f);
		f.sortButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.sortButton:SetScript("OnEnter", BagItemAutoSortButton:GetScript("OnEnter"))
		f.sortButton:SetScript('OnClick', function()
			if f.holderFrame:IsShown() then
				f:UnregisterAllEvents() --Unregister to prevent unnecessary updates
				if not f.registerUpdate then
					B:SortingFadeBags(f)
				end
				f.registerUpdate = true --Set variable that indicates this bag should be updated when sorting is done
				B:CommandDecorator(B.SortBags, 'bank')();
			else
				SortReagentBankBags()
			end
		end)
		if E.db.bags.disableBankSort then
			f.sortButton:Disable()
		end

		--Toggle Bags Button
		f.depositButton = CreateFrame("Button", name..'DepositButton', f.reagentFrame);
		f.depositButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.depositButton:SetScript("OnEnter", self.Tooltip_Show)
		f.depositButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.depositButton:SetScript('OnClick', function()
			PlaySound(852) --IG_MAINMENU_OPTION
			DepositReagentBank()
		end)

		--Toggle Bags Button
		f.bagsButton = CreateFrame("Button", name..'BagsButton', f.holderFrame);
		f.bagsButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.bagsButton:SetScript("OnEnter", self.Tooltip_Show)
		f.bagsButton:SetScript("OnLeave", self.Tooltip_Hide)
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
		f.purchaseBagButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.purchaseBagButton:SetScript("OnEnter", self.Tooltip_Show)
		f.purchaseBagButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.purchaseBagButton:SetScript("OnClick", function()
			local _, full = GetNumBankSlots()
			if full then
				E:StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
			else
				E:StaticPopup_Show("BUY_BANK_SLOT")
			end
		end)

		f:SetScript('OnHide', function()
			CloseBankFrame()

			B:NewItemGlowBagClear(f)

			if E.db.bags.clearSearchOnClose then
				B.ResetAndClear(f.editBox);
			end
		end)

		--Search
		f.editBox = CreateFrame('EditBox', name..'EditBox', f);
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2);
		f.editBox:CreateBackdrop('Default');
		f.editBox.backdrop:Point("TOPLEFT", f.editBox, "TOPLEFT", -20, 2)
		f.editBox:Height(15);
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', (E.Border * 2) + 18, E.Border * 2 + 2);
		f.editBox:Point('RIGHT', f.purchaseBagButton, 'LEFT', -5, 0);
		f.editBox:SetAutoFocus(false);
		f.editBox:SetScript("OnEscapePressed", self.ResetAndClear);
		f.editBox:SetScript("OnEnterPressed", function(eb) eb:ClearFocus() end);
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText);
		f.editBox:SetScript("OnTextChanged", self.UpdateSearch);
		f.editBox:SetScript('OnChar', self.UpdateSearch);
		f.editBox:SetText(SEARCH);
		f.editBox:FontTemplate();

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, 'OVERLAY')
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		f.editBox.searchIcon:Point("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1)
		f.editBox.searchIcon:SetSize(15, 15)

	else
		--Gold Text
		f.goldText = f:CreateFontString(nil, 'OVERLAY')
		f.goldText:FontTemplate()
		f.goldText:Point('BOTTOMRIGHT', f.holderFrame, 'TOPRIGHT', -2, 4)
		f.goldText:SetJustifyH("RIGHT")

		--Sort Button
		f.sortButton = CreateFrame("Button", name..'SortButton', f);
		f.sortButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.sortButton:SetScript("OnEnter", BagItemAutoSortButton:GetScript("OnEnter"))
		f.sortButton:SetScript('OnClick', function()
			f:UnregisterAllEvents() --Unregister to prevent unnecessary updates
			if not f.registerUpdate then
				B:SortingFadeBags(f)
			end
			f.registerUpdate = true --Set variable that indicates this bag should be updated when sorting is done
			B:CommandDecorator(B.SortBags, 'bags')();
		end)
		if E.db.bags.disableBagSort then
			f.sortButton:Disable()
		end

		--Bags Button
		f.bagsButton = CreateFrame("Button", name..'BagsButton', f);
		f.bagsButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.bagsButton:SetScript("OnEnter", self.Tooltip_Show)
		f.bagsButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.bagsButton:SetScript('OnClick', function() ToggleFrame(f.ContainerHolder) end)

		--Vendor Grays
		f.vendorGraysButton = CreateFrame('Button', nil, f.holderFrame)
		f.vendorGraysButton:SetSize(16 + E.Border, 16 + E.Border)
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
		f.vendorGraysButton:SetScript("OnEnter", self.Tooltip_Show)
		f.vendorGraysButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.vendorGraysButton:SetScript("OnClick", B.VendorGrayCheck)

		--Search
		f.editBox = CreateFrame('EditBox', name..'EditBox', f);
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2);
		f.editBox:CreateBackdrop('Default');
		f.editBox.backdrop:Point("TOPLEFT", f.editBox, "TOPLEFT", -20, 2)
		f.editBox:Height(15);
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', (E.Border * 2) + 18, E.Border * 2 + 2);
		f.editBox:Point('RIGHT', f.vendorGraysButton, 'LEFT', -5, 0);
		f.editBox:SetAutoFocus(false);
		f.editBox:SetScript("OnEscapePressed", self.ResetAndClear);
		f.editBox:SetScript("OnEnterPressed", function(eb) eb:ClearFocus() end);
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText);
		f.editBox:SetScript("OnTextChanged", self.UpdateSearch);
		f.editBox:SetScript('OnChar', self.UpdateSearch);
		f.editBox:SetText(SEARCH);
		f.editBox:FontTemplate();

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, 'OVERLAY')
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		f.editBox.searchIcon:Point("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1)
		f.editBox.searchIcon:SetSize(15, 15)

		--Currency
		f.currencyButton = CreateFrame('Frame', nil, f);
		f.currencyButton:Point('BOTTOM', 0, 4);
		f.currencyButton:Point('TOPLEFT', f.holderFrame, 'BOTTOMLEFT', 0, 18);
		f.currencyButton:Point('TOPRIGHT', f.holderFrame, 'BOTTOMRIGHT', 0, 18);
		f.currencyButton:Height(22);
		for i = 1, MAX_WATCHED_TOKENS do
			f.currencyButton[i] = CreateFrame('Button', f:GetName().."CurrencyButton"..i, f.currencyButton);
			f.currencyButton[i]:Size(16);
			f.currencyButton[i]:SetTemplate('Default');
			f.currencyButton[i]:SetID(i);
			f.currencyButton[i].icon = f.currencyButton[i]:CreateTexture(nil, 'OVERLAY');
			f.currencyButton[i].icon:SetInside();
			f.currencyButton[i].icon:SetTexCoord(unpack(E.TexCoords));
			f.currencyButton[i].text = f.currencyButton[i]:CreateFontString(nil, 'OVERLAY');
			f.currencyButton[i].text:Point('LEFT', f.currencyButton[i], 'RIGHT', 2, 0);
			f.currencyButton[i].text:FontTemplate();

			f.currencyButton[i]:SetScript('OnEnter', B.Token_OnEnter);
			f.currencyButton[i]:SetScript('OnLeave', function() GameTooltip:Hide() end);
			f.currencyButton[i]:SetScript('OnClick', B.Token_OnClick);
			f.currencyButton[i]:Hide();
		end

		f:SetScript('OnHide', function()
			CloseBackpack()
			for i = 1, NUM_BAG_FRAMES do
				CloseBag(i)
			end

			B:NewItemGlowBagClear(f)

			if ElvUIBags and ElvUIBags.buttons then
				for _, bagButton in pairs(ElvUIBags.buttons) do
					bagButton:SetChecked(false)
				end
			end

			if E.db.bags.clearSearchOnClose then
				B.ResetAndClear(f.editBox);
			end
		end)
	end

	tinsert(UISpecialFrames, f:GetName()) --Keep an eye on this for taints..
	tinsert(self.BagFrames, f)
	return f
end

function B:ToggleBags(id)
	if id and (GetContainerNumSlots(id) == 0) then return end --Closes a bag when inserting a new container..

	if self.BagFrame:IsShown() then
		self:CloseBags()
	else
		self:OpenBags()
	end
end

function B:ToggleBackpack()
	if IsOptionFrameOpen() then
		return;
	end

	if IsBagOpen(0) then
		self:OpenBags()
	else
		self:CloseBags()
	end
end

function B:ToggleSortButtonState(isBank)
	local button, disable;
	if isBank and self.BankFrame then
		button = self.BankFrame.sortButton
		disable = E.db.bags.disableBankSort
	elseif not isBank and self.BagFrame then
		button = self.BagFrame.sortButton
		disable = E.db.bags.disableBagSort
	end

	if button and disable then
		button:Disable()
	elseif button and not disable then
		button:Enable()
	end
end

function B:OpenBags()
	self.BagFrame:Show()
	PlaySound(IG_BACKPACK_OPEN)

	if not TooltipModule then TooltipModule = E:GetModule('Tooltip') end
	TooltipModule:GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:CloseBags()
	self.BagFrame:Hide()
	PlaySound(IG_BACKPACK_CLOSE)

	if self.BankFrame then
		self.BankFrame:Hide()
	end

	if not TooltipModule then TooltipModule = E:GetModule('Tooltip') end
	TooltipModule:GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:OpenBank()
	if not self.BankFrame then
		self.BankFrame = self:ContructContainerFrame('ElvUI_BankContainerFrame', true);
	end

	--Call :Layout first so all elements are created before we update
	self:Layout(true)

	BankFrame:Show()
	self.BankFrame:Show()

	self:OpenBags()
	self:UpdateTokens()

	--Allow opening reagent tab directly by holding Shift
	if IsShiftKeyDown() then
		BankFrame.selectedTab = 2
		self.BankFrame.holderFrame:Hide()
		self.BankFrame.reagentFrame:Show()
		self.BankFrame.editBox:Point('RIGHT', self.BankFrame.depositButton, 'LEFT', -5, 0);
		self.BankFrame.bagText:SetText(L["Reagent Bank"])
	end
end

function B:PLAYERBANKBAGSLOTS_CHANGED()
	self:Layout(true)
end

function B:GuildBankFrame_Update()
	B:SetGuildBankSearch(SEARCH_STRING);
end

function B:CloseBank()
	if not self.BankFrame then return end -- WHY??? WHO KNOWS!
	self.BankFrame:Hide()
	BankFrame:Hide()
	self.BagFrame:Hide()
end

function B:GUILDBANKFRAME_OPENED(event)
	--[[
		local button = CreateFrame("Button", "GuildSortButton", GuildBankFrame, "UIPanelButtonTemplate")
		button:StripTextures()
		button:SetTemplate("Default", true)
		button:Size(110, 20)
		button:Point("RIGHT", GuildItemSearchBox, "LEFT", -4, 0)
		button:SetText(L["Sort Tab"])
		button:SetScript("OnClick", function() B:CommandDecorator(B.SortBags, 'guild')() end)
		E.Skins:HandleButton(button, true)
	]]

	if GuildItemSearchBox then
		GuildItemSearchBox:SetScript("OnEscapePressed", self.ResetAndClear);
		GuildItemSearchBox:SetScript("OnEnterPressed", function(sb) sb:ClearFocus() end);
		GuildItemSearchBox:SetScript("OnEditFocusGained", GuildItemSearchBox.HighlightText);
		GuildItemSearchBox:SetScript("OnTextChanged", self.UpdateSearch);
		GuildItemSearchBox:SetScript('OnChar', self.UpdateSearch);
	end

	hooksecurefunc('GuildBankFrame_Update', B.GuildBankFrame_Update)

	self:UnregisterEvent(event)
end

local playerEnteringWorldFunc = function() B:UpdateBagTypes() B:Layout() end
function B:PLAYER_ENTERING_WORLD()
	self:UpdateGoldText()

	C_Timer_After(2, playerEnteringWorldFunc) -- Update bag types for bagslot coloring
end

function B:UpdateContainerFrameAnchors()
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;

	if BankFrame:IsShown() then
		leftLimit = BankFrame:GetRight() - 25;
	end

	while containerScale > CONTAINER_SCALE do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale;
		yOffset = CONTAINER_OFFSET_Y / containerScale;
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;

		local frameHeight;
		for _, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = _G[frameName]:GetHeight();

			if freeScreenHeight < frameHeight then
				-- Start a new column
				column = column + 1;
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset;
				freeScreenHeight = screenHeight - yOffset;
			end

			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
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

	screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	-- xOffset = CONTAINER_OFFSET_X / containerScale;
	yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset;
	column = 0;

	local bagsPerColumn = 0
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = _G[frameName];
		frame:SetScale(1);

		if index == 1 then
			-- First bag
			frame:Point("BOTTOMRIGHT", ElvUIBagMover, "BOTTOMRIGHT", E.Spacing, -E.Border);
			bagsPerColumn = bagsPerColumn + 1
		elseif freeScreenHeight < frame:GetHeight() then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = screenHeight - yOffset;
			if column > 1 then
				frame:Point("BOTTOMRIGHT", ContainerFrame1.bags[(index - bagsPerColumn) - 1], "BOTTOMLEFT", -CONTAINER_SPACING, 0 );
			else
				frame:Point("BOTTOMRIGHT", ContainerFrame1.bags[index - bagsPerColumn], "BOTTOMLEFT", -CONTAINER_SPACING, 0 );
			end
			bagsPerColumn = 0
		else
			-- Anchor to the previous bag
			frame:Point("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);
			bagsPerColumn = bagsPerColumn + 1
		end

		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
	end
end

function B:PostBagMove()
	if not E.private.bags.enable then return end

	-- self refers to the mover (bag or bank)
	local x, y = self:GetCenter();
	local screenHeight = E.UIParent:GetTop();
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
	local stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
	if B.SellFrame.Info.delete then
		PickupContainerItem(bag, slot)
		DeleteCursorItem()
	else
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
	B.SellFrame.Info.ProgressTimer = B.SellFrame.Info.ProgressTimer - elapsed;
	if (B.SellFrame.Info.ProgressTimer > 0) then return; end
	B.SellFrame.Info.ProgressTimer = B.SellFrame.Info.SellInterval

	local goldGained, lastItem = B:ProgressQuickVendor();
	if (goldGained) then
		B.SellFrame.Info.goldGained = B.SellFrame.Info.goldGained + goldGained
		B.SellFrame.Info.itemsSold = B.SellFrame.Info.itemsSold + 1
		B.SellFrame.statusbar:SetValue(B.SellFrame.Info.itemsSold);
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

	B.SellFrame.statusbar.anim = CreateAnimationGroup(B.SellFrame.statusbar)
	B.SellFrame.statusbar.anim.progress = B.SellFrame.statusbar.anim:CreateAnimation("Progress")
	B.SellFrame.statusbar.anim.progress:SetSmoothing("Out")
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
	self[table][B.BagIndice[indice]] = { r, g, b }
end

function B:UpdateQuestColors(table, indice, r, g, b)
	self[table][B.QuestKeys[indice]] = { r, g, b }
end

function B:Initialize()
	--Creating vendor grays frame
	self:CreateSellFrame()

	self:LoadBagBar();

	--Bag Mover (We want it created even if Bags module is disabled, so we can use it for default bags too)
	local BagFrameHolder = CreateFrame("Frame", nil, E.UIParent)
	BagFrameHolder:Width(200)
	BagFrameHolder:Height(22)
	BagFrameHolder:SetFrameLevel(BagFrameHolder:GetFrameLevel() + 400)

	if not E.private.bags.enable then
		--Set a different default anchor
		BagFrameHolder:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", -(E.Border*2), 22 + E.Border*4 - E.Spacing*2)
		E:CreateMover(BagFrameHolder, 'ElvUIBagMover', L["Bag Mover"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

		self:SecureHook('UpdateContainerFrameAnchors')

		return
	end

	E.bags = self
	self.db = E.db.bags
	self.BagFrames = {}

	self.ProfessionColors = {
		[0x0008]   = { self.db.colors.profession.leatherworking.r, self.db.colors.profession.leatherworking.g, self.db.colors.profession.leatherworking.b },
		[0x0010]   = { self.db.colors.profession.inscription.r, self.db.colors.profession.inscription.g, self.db.colors.profession.inscription.b },
		[0x0020]   = { self.db.colors.profession.herbs.r, self.db.colors.profession.herbs.g, self.db.colors.profession.herbs.b },
		[0x0040]   = { self.db.colors.profession.enchanting.r, self.db.colors.profession.enchanting.g, self.db.colors.profession.enchanting.b },
		[0x0080]   = { self.db.colors.profession.engineering.r, self.db.colors.profession.engineering.g, self.db.colors.profession.engineering.b },
		[0x0200]   = { self.db.colors.profession.gems.r, self.db.colors.profession.gems.g, self.db.colors.profession.gems.b },
		[0x0400]   = { self.db.colors.profession.mining.r, self.db.colors.profession.mining.g, self.db.colors.profession.mining.b },
		[0x8000]   = { self.db.colors.profession.fishing.r, self.db.colors.profession.fishing.g, self.db.colors.profession.fishing.b },
		[0x010000] = { self.db.colors.profession.cooking.r, self.db.colors.profession.cooking.g, self.db.colors.profession.cooking.b },
	}

	self.AssignmentColors = {
		[0] = { .99, .23, .21 },   -- fallback
		[2] = { self.db.colors.assignment.equipment.r , self.db.colors.assignment.equipment.g, self.db.colors.assignment.equipment.b },
		[3] = { self.db.colors.assignment.consumables.r , self.db.colors.assignment.consumables.g, self.db.colors.assignment.consumables.b },
		[4] = { self.db.colors.assignment.tradegoods.r , self.db.colors.assignment.tradegoods.g, self.db.colors.assignment.tradegoods.b },
	}

	self.QuestColors = {
		["questStarter"] = {self.db.colors.items.questStarter.r, self.db.colors.items.questStarter.g, self.db.colors.items.questStarter.b},
		["questItem"] = {self.db.colors.items.questItem.r, self.db.colors.items.questItem.g, self.db.colors.items.questItem.b},
	}

	--Bag Mover: Set default anchor point and create mover
	BagFrameHolder:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", 0, 22 + E.Border*4 - E.Spacing*2)
	E:CreateMover(BagFrameHolder, 'ElvUIBagMover', L["Bag Mover (Grow Up)"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

	--Bank Mover
	local BankFrameHolder = CreateFrame("Frame", nil, E.UIParent)
	BankFrameHolder:Width(200)
	BankFrameHolder:Height(22)
	BankFrameHolder:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", 0, 22 + E.Border*4 - E.Spacing*2)
	BankFrameHolder:SetFrameLevel(BankFrameHolder:GetFrameLevel() + 400)
	E:CreateMover(BankFrameHolder, 'ElvUIBankMover', L["Bank Mover (Grow Up)"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

	--Bag Assignment Dropdown Menu
	ElvUIAssignBagDropdown = CreateFrame("Frame", "ElvUIAssignBagDropdown", E.UIParent, "UIDropDownMenuTemplate")
	ElvUIAssignBagDropdown:SetID(1)
	ElvUIAssignBagDropdown:SetClampedToScreen(true)
	ElvUIAssignBagDropdown:Hide()
	UIDropDownMenu_Initialize(ElvUIAssignBagDropdown, self.AssignBagFlagMenu, "MENU");

	--Set some variables on movers
	ElvUIBagMover.textGrowUp = L["Bag Mover (Grow Up)"]
	ElvUIBagMover.textGrowDown = L["Bag Mover (Grow Down)"]
	ElvUIBagMover.POINT = "BOTTOM"
	ElvUIBankMover.textGrowUp = L["Bank Mover (Grow Up)"]
	ElvUIBankMover.textGrowDown = L["Bank Mover (Grow Down)"]
	ElvUIBankMover.POINT = "BOTTOM"

	--Create Bag Frame
	self.BagFrame = self:ContructContainerFrame('ElvUI_ContainerFrame');

	--Hook onto Blizzard Functions
	--self:SecureHook('UpdateNewItemList', 'ClearNewItems')
	self:SecureHook('OpenAllBags', 'OpenBags');
	self:SecureHook('CloseAllBags', 'CloseBags');
	self:SecureHook('ToggleBag', 'ToggleBags')
	self:SecureHook('ToggleAllBags', 'ToggleBackpack');
	self:SecureHook('ToggleBackpack')
	self:SecureHook('BackpackTokenFrame_Update', 'UpdateTokens');
	self:Layout();

	E.Bags = self;

	self:DisableBlizzard();
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_MONEY", "UpdateGoldText")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGoldText")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGoldText")
	self:RegisterEvent("BANKFRAME_OPENED", "OpenBank")
	self:RegisterEvent("BANKFRAME_CLOSED", "CloseBank")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	self:RegisterEvent("GUILDBANKFRAME_OPENED")
	self:RegisterEvent("MERCHANT_CLOSED")

	BankFrame:SetScale(0.0001)
	BankFrame:SetAlpha(0)
	BankFrame:Point("TOPLEFT")
	BankFrame:SetScript("OnShow", nil)

	--Enable/Disable "Loot to Leftmost Bag"
	SetInsertItemsLeftToRight(E.db.bags.reverseLoot)
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)
