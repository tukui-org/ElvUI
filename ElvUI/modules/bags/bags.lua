local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule('Bags', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local Search = LibStub('LibItemSearch-1.2-ElvUI')

--Cache global variables
--Lua functions
local _G = _G
local type, ipairs, pairs, unpack, select, assert = type, ipairs, pairs, unpack, select, assert
local tinsert = table.insert
local floor, abs, ceil = math.floor, math.abs, math.ceil
local len, sub, find, format, gsub = string.len, string.sub, string.find, string.format, string.gsub
--WoW API / Variables
local CreateFrame = CreateFrame
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local SetItemButtonDesaturated = SetItemButtonDesaturated
local GetContainerItemInfo = GetContainerItemInfo
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local IsBagOpen, IsOptionFrameOpen = IsBagOpen, IsOptionFrameOpen
local CloseBag, CloseBackpack, CloseBankFrame = CloseBag, CloseBackpack, CloseBankFrame
local ToggleFrame = ToggleFrame
local GetNumBankSlots = GetNumBankSlots
local PlaySound = PlaySound
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankTabInfo = GetGuildBankTabInfo
local GetGuildBankItemLink = GetGuildBankItemLink
local GetContainerItemLink = GetContainerItemLink
local GetItemInfo = GetItemInfo
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetItemQualityColor = GetItemQualityColor
local GetContainerItemCooldown = GetContainerItemCooldown
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonTexture = SetItemButtonTexture
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local BankFrameItemButton_Update = BankFrameItemButton_Update
local BankFrameItemButton_UpdateLocked = BankFrameItemButton_UpdateLocked
local UpdateSlot = UpdateSlot
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local IsReagentBankUnlocked = IsReagentBankUnlocked
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local IsModifiedClick = IsModifiedClick
local HandleModifiedItemClick = HandleModifiedItemClick
local GetCurrencyLink = GetCurrencyLink
local GetMoney = GetMoney
local PickupContainerItem = PickupContainerItem
local DeleteCursorItem = DeleteCursorItem
local UseContainerItem = UseContainerItem
local PickupMerchantItem = PickupMerchantItem
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local StaticPopup_Show = StaticPopup_Show
local SortReagentBankBags = SortReagentBankBags
local DepositReagentBank = DepositReagentBank
local C_NewItemsIsNewItem = C_NewItems.IsNewItem
local SEARCH = SEARCH
local REAGENTBANK_CONTAINER = REAGENTBANK_CONTAINER
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local REAGENTBANK_PURCHASE_TEXT = REAGENTBANK_PURCHASE_TEXT
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local CONTAINER_SCALE = CONTAINER_SCALE
local CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y = CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y
local CONTAINER_WIDTH = CONTAINER_WIDTH
local CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING = CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, BankFrame, ElvUIReagentBankFrameItem1, GuildBankFrame, ElvUIBags
-- GLOBALS: ContainerFrame1, RightChatToggleButton, GuildItemSearchBox, StackSplitFrame
-- GLOBALS: LeftChatToggleButton, MAX_GUILDBANK_SLOTS_PER_TAB, UISpecialFrames
-- GLOBALS: ElvUIReagentBankFrame, MerchantFrame, BagItemAutoSortButton

local SEARCH_STRING = ""

B.ProfessionColors = {
	[0x0008] = {224/255, 187/255, 74/255}, -- Leatherworking
	[0x0010] = {74/255, 77/255, 224/255}, -- Inscription
	[0x0020] = {18/255, 181/255, 32/255}, -- Herbs
	[0x0040] = {160/255, 3/255, 168/255}, -- Enchanting
	[0x0080] = {232/255, 118/255, 46/255}, -- Engineering
	[0x0200] = {8/255, 180/255, 207/255}, -- Gems
	[0x0400] = {105/255, 79/255,  7/255}, -- Mining
	[0x010000] = {222/255, 13/255,  65/255} -- Cooking
}

function B:GetContainerFrame(arg)
	if type(arg) == 'boolean' and arg == true then
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
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(self.ttText2, self.ttText2desc, 1, 1, 1)
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

function B:UpdateSearch()
	if self.Instructions then self.Instructions:SetShown(self:GetText() == "") end
	local MIN_REPEAT_CHARACTERS = 3;
	local searchString = self:GetText();
	local prevSearchString = SEARCH_STRING;
	if (len(searchString) > MIN_REPEAT_CHARACTERS) then
		local repeatChar = true;
		for i=1, MIN_REPEAT_CHARACTERS, 1 do
			if ( sub(searchString,(0-i), (0-i)) ~= sub(searchString,(-1-i),(-1-i)) ) then
				repeatChar = false;
				break;
			end
		end
		if ( repeatChar ) then
			B.ResetAndClear(self);
			return;
		end
	end

	--Keep active search term when switching between bank and reagent bank
	if searchString == SEARCH and prevSearchString ~= "" then
		searchString = prevSearchString
	elseif searchString == SEARCH then
		searchString = ''
	end

	SEARCH_STRING = searchString

	B:SetSearch(SEARCH_STRING);
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
	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, link = GetContainerItemInfo(bagID, slotID);
				local button = bagFrame.Bags[bagID][slotID];
				if ( empty or Search:Matches(link, query) ) then
					SetItemButtonDesaturated(button);
					button:SetAlpha(1);
				else
					SetItemButtonDesaturated(button, 1);
					button:SetAlpha(0.4);
				end
			end
		end
	end

	if(ElvUIReagentBankFrameItem1) then
		for slotID=1, 98 do
			local _, _, _, _, _, _, link = GetContainerItemInfo(REAGENTBANK_CONTAINER, slotID);
			local button = _G["ElvUIReagentBankFrameItem"..slotID]
			if ( empty or Search:Matches(link, query) ) then
				SetItemButtonDesaturated(button);
				button:SetAlpha(1);
			else
				SetItemButtonDesaturated(button, 1);
				button:SetAlpha(0.4);
			end
		end
	end
end

function B:SetGuildBankSearch(query)
	local empty = len(query:gsub(' ', '')) == 0
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
				if (empty or Search:Matches(link, query) ) then
					SetItemButtonDesaturated(button);
					button:SetAlpha(1);
				else
					SetItemButtonDesaturated(button, 1);
					button:SetAlpha(0.4);
				end
			end
		end
	end
end

function B:UpdateItemLevelDisplay()
	if E.private.bags.enable ~= true then return; end
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
	if E.private.bags.enable ~= true then return; end
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
end

function B:UpdateSlot(bagID, slotID)
	if (self.Bags[bagID] and self.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or not self.Bags[bagID] or not self.Bags[bagID][slotID] then
		return;
	end

	local slot, _ = self.Bags[bagID][slotID], nil;
	local bagType = self.Bags[bagID].type;
	local texture, count, locked, _, readable = GetContainerItemInfo(bagID, slotID);
	local clink = GetContainerItemLink(bagID, slotID);

	slot:Show();
	if(slot.questIcon) then
		slot.questIcon:Hide();
	end

	slot.name, slot.rarity = nil, nil;

	slot.itemLevel:SetText("")
	if B.ProfessionColors[bagType] then
		slot:SetBackdropBorderColor(unpack(B.ProfessionColors[bagType]))
	elseif (clink) then
		local iLvl, itemEquipLoc
		slot.name, _, slot.rarity, iLvl, _, _, _, _, itemEquipLoc = GetItemInfo(clink);

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
		local r, g, b

		if(slot.rarity) then
			r, g, b = GetItemQualityColor(slot.rarity);
			slot.shadow:SetBackdropBorderColor(r, g, b)
		end

		--Item Level
		if (iLvl and iLvl >= E.db.bags.itemLevelThreshold) and (itemEquipLoc ~= nil and itemEquipLoc ~= "" and itemEquipLoc ~= "INVTYPE_BAG" and itemEquipLoc ~= "INVTYPE_QUIVER" and itemEquipLoc ~= "INVTYPE_TABARD") and (slot.rarity and slot.rarity > 1) and B.db.itemLevel then
			slot.itemLevel:SetText(iLvl)
			slot.itemLevel:SetTextColor(r, g, b)
		end

		-- color slot according to item quality
		if questId and not isActiveQuest then
			slot:SetBackdropBorderColor(1.0, 0.3, 0.3);
			if(slot.questIcon) then
				slot.questIcon:Show();
			end
		elseif questId or isQuestItem then
			slot:SetBackdropBorderColor(1.0, 0.3, 0.3);
		elseif slot.rarity and slot.rarity > 1 then
			slot:SetBackdropBorderColor(r, g, b);
		else
			slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
		end
	else
		slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
	end

	if(C_NewItemsIsNewItem(bagID, slotID)) then
		slot.shadow:Show()
		E:Flash(slot.shadow, 1, true)
	else
		slot.shadow:Hide()
		E:StopFlash(slot.shadow)
	end
	
	if (texture) then
		local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
		CooldownFrame_SetTimer(slot.cooldown, start, duration, enable)
		if ( duration > 0 and enable == 0 ) then
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
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5);
end

function B:UpdateBagSlots(bagID)
	if(bagID == REAGENTBANK_CONTAINER) then
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

-- function TEST()
	-- B:UpdateBagSlots(REAGENTBANK_CONTAINER)
-- end

function B:UpdateCooldowns()
	for _, bagID in ipairs(self.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
			CooldownFrame_SetTimer(self.Bags[bagID][slotID].cooldown, start, duration, enable)
			if ( duration > 0 and enable == 0 ) then
				SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 0.4, 0.4, 0.4);
			else
				SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 1, 1, 1);
			end
		end
	end
end

function B:UpdateAllSlots()
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			self.Bags[bagID]:UpdateBagSlots(bagID);
		end
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

function B:Layout(isBank)
	if E.private.bags.enable ~= true then return; end
	local f = self:GetContainerFrame(isBank);

	if not f then return; end
	local buttonSize = isBank and self.db.bankSize or self.db.bagSize;
	local buttonSpacing = E.PixelMode and 2 or 4;
	local containerWidth = (self.db.alignToChat == true and ((not isBank and E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth) or E.db.chat.panelWidth) - (E.PixelMode and 6 or 10)) or (isBank and self.db.bankWidth) or self.db.bagWidth
	local numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing));
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local numContainerRows = 0;
	local bottomPadding = (containerWidth - holderWidth) / 2;
	local countColor = E.db.bags.countFontColor
	f.holderFrame:Width(holderWidth);

	if(isBank) then
		f.reagentFrame:Width(holderWidth)
	end

	f.totalSlots = 0
	local lastButton;
	local lastRowButton;
	local lastContainerButton;
	local numContainerSlots, fullContainerSlots = GetNumBankSlots();
	for i, bagID in ipairs(f.BagIDs) do
		--Bag Containers
		if (not isBank and bagID <= 3 ) or (isBank and bagID ~= -1 and numContainerSlots >= 1 and not (i - 1 > numContainerSlots)) then
			if not f.ContainerHolder[i] then
				if(isBank) then
					f.ContainerHolder[i] = CreateFrame("CheckButton", "ElvUIBankBag" .. bagID - 4, f.ContainerHolder, "BankItemButtonBagTemplate")
				else
					f.ContainerHolder[i] = CreateFrame("CheckButton", "ElvUIMainBag" .. bagID .. "Slot", f.ContainerHolder, "BagSlotButtonTemplate")
				end

				f.ContainerHolder[i]:SetTemplate('Default', true)
				f.ContainerHolder[i]:StyleButton()
				f.ContainerHolder[i].IconBorder:SetAlpha(0)
				f.ContainerHolder[i]:SetNormalTexture("")
				f.ContainerHolder[i]:SetCheckedTexture(nil)
				f.ContainerHolder[i]:SetPushedTexture("")
				f.ContainerHolder[i]:SetScript('OnClick', nil)
				f.ContainerHolder[i].id = isBank and bagID or bagID + 1
				f.ContainerHolder[i]:HookScript("OnEnter", function(self) B.SetSlotAlphaForBag(self, f) end)
				f.ContainerHolder[i]:HookScript("OnLeave", function(self) B.ResetSlotAlphaForBags(self, f) end)


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

			f.ContainerHolder[i]:Size(buttonSize)
			f.ContainerHolder[i]:ClearAllPoints()
			if (isBank and i == 2) or (not isBank and i == 1) then
				f.ContainerHolder[i]:SetPoint('BOTTOMLEFT', f.ContainerHolder, 'BOTTOMLEFT', buttonSpacing, buttonSpacing)
			else
				f.ContainerHolder[i]:SetPoint('LEFT', lastContainerButton, 'RIGHT', buttonSpacing, 0)
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
			f.Bags[bagID].type = select(2, GetContainerNumFreeSlots(bagID));

			--Hide unused slots
			for i = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID][i] then
					f.Bags[bagID][i]:Hide();
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

					if(_G[f.Bags[bagID][slotID]:GetName()..'NewItemTexture']) then
						_G[f.Bags[bagID][slotID]:GetName()..'NewItemTexture']:Hide()
					end

					f.Bags[bagID][slotID].Count:ClearAllPoints();
					f.Bags[bagID][slotID].Count:Point('BOTTOMRIGHT', 0, 2);
					f.Bags[bagID][slotID].Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline)
					f.Bags[bagID][slotID].Count:SetTextColor(countColor.r, countColor.g, countColor.b)

					if not(f.Bags[bagID][slotID].questIcon) then
						f.Bags[bagID][slotID].questIcon = _G[f.Bags[bagID][slotID]:GetName()..'IconQuestTexture'] or _G[f.Bags[bagID][slotID]:GetName()].IconQuestTexture
						f.Bags[bagID][slotID].questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG);
						f.Bags[bagID][slotID].questIcon:SetInside(f.Bags[bagID][slotID]);
						f.Bags[bagID][slotID].questIcon:SetTexCoord(unpack(E.TexCoords));
						f.Bags[bagID][slotID].questIcon:Hide();
					end

					f.Bags[bagID][slotID].iconTexture = _G[f.Bags[bagID][slotID]:GetName()..'IconTexture'];
					f.Bags[bagID][slotID].iconTexture:SetInside(f.Bags[bagID][slotID]);
					f.Bags[bagID][slotID].iconTexture:SetTexCoord(unpack(E.TexCoords));

					f.Bags[bagID][slotID].cooldown = _G[f.Bags[bagID][slotID]:GetName()..'Cooldown'];
					E:RegisterCooldown(f.Bags[bagID][slotID].cooldown)
					f.Bags[bagID][slotID].bagID = bagID
					f.Bags[bagID][slotID].slotID = slotID

					f.Bags[bagID][slotID].itemLevel = f.Bags[bagID][slotID]:CreateFontString(nil, 'OVERLAY')
					f.Bags[bagID][slotID].itemLevel:SetPoint("BOTTOMRIGHT", 0, 2)
					f.Bags[bagID][slotID].itemLevel:FontTemplate(E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)

					if(f.Bags[bagID][slotID].BattlepayItemTexture) then
						f.Bags[bagID][slotID].BattlepayItemTexture:Hide()
					end

					f.Bags[bagID][slotID]:CreateShadow()
				end

				f.Bags[bagID][slotID]:SetID(slotID);
				f.Bags[bagID][slotID]:Size(buttonSize);

				f:UpdateSlot(bagID, slotID);

				if f.Bags[bagID][slotID]:GetPoint() then
					f.Bags[bagID][slotID]:ClearAllPoints();
				end

				if lastButton then
					if (f.totalSlots - 1) % numContainerColumns == 0 then
						f.Bags[bagID][slotID]:Point('TOP', lastRowButton, 'BOTTOM', 0, -buttonSpacing);
						lastRowButton = f.Bags[bagID][slotID];
						numContainerRows = numContainerRows + 1;
					else
						f.Bags[bagID][slotID]:Point('LEFT', lastButton, 'RIGHT', buttonSpacing, 0);
					end
				else
					f.Bags[bagID][slotID]:Point('TOPLEFT', f.holderFrame, 'TOPLEFT');
					lastRowButton = f.Bags[bagID][slotID];
					numContainerRows = numContainerRows + 1;
				end

				lastButton = f.Bags[bagID][slotID];
			end
		else
			--Hide unused slots
			for i = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID] and f.Bags[bagID][i] then
					f.Bags[bagID][i]:Hide();
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

	if(isBank and f.reagentFrame:IsShown()) then
		if(not IsReagentBankUnlocked()) then
			f.reagentFrame.cover:Show();
			B:RegisterEvent("REAGENTBANK_PURCHASED")
		else
			f.reagentFrame.cover:Hide();
		end


		local totalSlots = 0
		local lastRowButton
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

				f.reagentFrame.slots[i].iconTexture = _G[f.reagentFrame.slots[i]:GetName()..'IconTexture'];
				f.reagentFrame.slots[i].iconTexture:SetInside(f.reagentFrame.slots[i]);
				f.reagentFrame.slots[i].iconTexture:SetTexCoord(unpack(E.TexCoords));
				f.reagentFrame.slots[i].IconBorder:SetAlpha(0)
				f.reagentFrame.slots[i]:CreateShadow()
				f.reagentFrame.slots[i].shadow:Hide()
			end

			f.reagentFrame.slots[i]:ClearAllPoints()
			f.reagentFrame.slots[i]:Size(buttonSize)
			if(f.reagentFrame.slots[i-1]) then
				if(totalSlots - 1) % numContainerColumns == 0 then
					f.reagentFrame.slots[i]:Point('TOP', lastRowButton, 'BOTTOM', 0, -buttonSpacing);
					lastRowButton = f.reagentFrame.slots[i];
					numContainerRows = numContainerRows + 1;
				else
					f.reagentFrame.slots[i]:Point('LEFT', f.reagentFrame.slots[i-1], 'RIGHT', buttonSpacing, 0);
				end
			else
				f.reagentFrame.slots[i]:Point('TOPLEFT', f.reagentFrame, 'TOPLEFT');
				lastRowButton = f.reagentFrame.slots[i]
			end

			self:UpdateReagentSlot(i)
		end
	end

	f:Size(containerWidth, (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + f.topOffset + f.bottomOffset); -- 8 is the cussion of the f.holderFrame
end

function B:UpdateReagentSlot(slotID)
	assert(slotID)
	local bagID = REAGENTBANK_CONTAINER
	local texture, count, locked = GetContainerItemInfo(bagID, slotID);
	local clink = GetContainerItemLink(bagID, slotID);
	local slot = _G["ElvUIReagentBankFrameItem"..slotID]
	if not slot then return; end

	slot:Show();
	if(slot.questIcon) then
		slot.questIcon:Hide();
	end

	slot.name, slot.rarity = nil, nil;

	local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
	CooldownFrame_SetTimer(slot.Cooldown, start, duration, enable)
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4);
	else
		SetItemButtonTextureVertexColor(slot, 1, 1, 1);
	end

	if (clink) then
		local name, _, rarity = GetItemInfo(clink);
		slot.name, slot.rarity = name, rarity

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
		local r, g, b

		if(slot.rarity) then
			r, g, b = GetItemQualityColor(slot.rarity);
			slot.shadow:SetBackdropBorderColor(r, g, b);
		end

		-- color slot according to item quality
		if questId and not isActiveQuest then
			slot:SetBackdropBorderColor(1.0, 0.3, 0.3);
			slot.questIcon:Show();
		elseif questId or isQuestItem then
			slot:SetBackdropBorderColor(1.0, 0.3, 0.3);
		elseif slot.rarity and slot.rarity > 1 then
			slot:SetBackdropBorderColor(r, g, b);
		else
			slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
		end
	else
		slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
	end

	if(C_NewItemsIsNewItem(bagID, slotID)) then
		slot.shadow:Show()
		E:Flash(slot.shadow, 1, true)
	else
		slot.shadow:Hide()
		E:StopFlash(slot.shadow)
	end

	SetItemButtonTexture(slot, texture);
	SetItemButtonCount(slot, count);
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5);
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
			self:UpdateSlot(...);
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
	elseif event == 'BAG_UPDATE_COOLDOWN' then
		self:UpdateCooldowns();
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		self:UpdateAllSlots()
	elseif event == 'PLAYERREAGENTBANKSLOTS_CHANGED' then
		B:UpdateReagentSlot(...)
	elseif (event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED") and self:IsShown() then
		self:UpdateAllSlots()
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
	if ( IsModifiedClick("CHATLINK") ) then
		HandleModifiedItemClick(GetCurrencyLink(self.currencyID));
	end
end

function B:UpdateGoldText()
	self.BagFrame.goldText:SetText(E:FormatMoney(GetMoney(), E.db['bags'].moneyFormat, not E.db['bags'].moneyCoins))
end

function B:GetGraysValue()
	local c = 0

	for b=0,4 do
		for s=1,GetContainerNumSlots(b) do
			local l = GetContainerItemLink(b, s)
			if l and select(11, GetItemInfo(l)) then
				local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))
				if select(3, GetItemInfo(l))==0 and p>0 then
					c = c+p
				end
			end
		end
	end

	return c
end

function B:VendorGrays(delete, nomsg, getValue)
	if (not MerchantFrame or not MerchantFrame:IsShown()) and not delete and not getValue then
		E:Print(L["You must be at a vendor."])
		return
	end

	local c = 0
	local count = 0
	for b=0,4 do
		for s=1,GetContainerNumSlots(b) do
			local l = GetContainerItemLink(b, s)
			if l and select(11, GetItemInfo(l)) then
				local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))

				if delete then
					if find(l,"ff9d9d9d") then
						if not getValue then
							PickupContainerItem(b, s)
							DeleteCursorItem()
						end
						c = c+p
						count = count + 1
					end
				else
					if select(3, GetItemInfo(l))==0 and p>0 then
						if not getValue then
							UseContainerItem(b, s)
							PickupMerchantItem()
						end
						c = c+p
					end
				end
			end
		end
	end

	if getValue then
		return c
	end

	if c>0 and not delete then
		local g, s, c = floor(c/10000) or 0, floor((c%10000)/100) or 0, c%100
		E:Print(L["Vendored gray items for:"].." |cffffffff"..g..L.goldabbrev.." |cffffffff"..s..L.silverabbrev.." |cffffffff"..c..L.copperabbrev..".")
	end
end

function B:VendorGrayCheck()
	local value = B:GetGraysValue()

	if(value == 0) then
		E:Print(L["No gray items to delete."])
	elseif(not MerchantFrame or not MerchantFrame:IsShown()) then
		E.PopupDialogs["DELETE_GRAYS"].Money = value
		E:StaticPopup_Show('DELETE_GRAYS')
	else
		B:VendorGrays()
	end
end

function B:ContructContainerFrame(name, isBank)
	local f = CreateFrame('Button', name, E.UIParent);
	f:SetTemplate('Transparent');
	f:SetFrameStrata('DIALOG');
	f.UpdateSlot = B.UpdateSlot;
	f.UpdateAllSlots = B.UpdateAllSlots;
	f.UpdateBagSlots = B.UpdateBagSlots;
	f.UpdateCooldowns = B.UpdateCooldowns;
	f:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED');
	f:RegisterEvent('ITEM_LOCK_CHANGED');
	f:RegisterEvent('ITEM_UNLOCKED');
	f:RegisterEvent('BAG_UPDATE_COOLDOWN')
	f:RegisterEvent('BAG_UPDATE');
	f:RegisterEvent('PLAYERBANKSLOTS_CHANGED');
	f:RegisterEvent("QUEST_ACCEPTED");
	f:RegisterEvent("QUEST_REMOVED");
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:RegisterForClicks("AnyUp");
	f:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
	f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	f:SetScript("OnClick", function(self) if IsControlKeyDown() then B:PositionBagFrames() end end)
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Hold Control + Right Click:"], L["Reset Position"], 1, 1, 1)

		GameTooltip:Show()
	end)
	f:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
	f.isBank = isBank

	f:SetScript('OnEvent', B.OnEvent);
	f:Hide();

	f.bottomOffset = isBank and 8 or 28;
	f.topOffset = 50;
	f.BagIDs = isBank and {-1, 5, 6, 7, 8, 9, 10, 11} or {0, 1, 2, 3, 4};
	f.Bags = {};

	f.closeButton = CreateFrame('Button', name..'CloseButton', f, 'UIPanelCloseButton');
	f.closeButton:Point('TOPRIGHT', -4, -4);

	E:GetModule('Skins'):HandleCloseButton(f.closeButton);

	f.holderFrame = CreateFrame('Frame', nil, f);
	f.holderFrame:Point('TOP', f, 'TOP', 0, -f.topOffset);
	f.holderFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8);

	f.ContainerHolder = CreateFrame('Button', name..'ContainerHolder', f)
	f.ContainerHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1)
	f.ContainerHolder:SetTemplate('Transparent')
	f.ContainerHolder:Hide()
	local buttonColor = E.PixelMode and {0.31, 0.31, 0.31} or E.media.bordercolor

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
		f.reagentFrame.cover:SetFrameStrata("FULLSCREEN_DIALOG")

		f.reagentFrame.cover.purchaseButton = CreateFrame("Button", nil, f.reagentFrame.cover)
		f.reagentFrame.cover.purchaseButton:Height(20)
		f.reagentFrame.cover.purchaseButton:Width(150)
		f.reagentFrame.cover.purchaseButton:Point('CENTER', f.reagentFrame.cover, 'CENTER')
		f.reagentFrame.cover.purchaseButton:SetFrameLevel(f.reagentFrame.cover.purchaseButton:GetFrameLevel() + 2)
		f.reagentFrame.cover.purchaseButton:SetTemplate('Default', true)
		f.reagentFrame.cover.purchaseButton.text = f.reagentFrame.cover.purchaseButton:CreateFontString(nil, 'OVERLAY')
		f.reagentFrame.cover.purchaseButton.text:FontTemplate()
		f.reagentFrame.cover.purchaseButton.text:SetPoint('CENTER')
		f.reagentFrame.cover.purchaseButton.text:SetJustifyH('CENTER')
		f.reagentFrame.cover.purchaseButton.text:SetText(L["Purchase"])
		f.reagentFrame.cover.purchaseButton:SetScript("OnEnter", self.Tooltip_Show)
		f.reagentFrame.cover.purchaseButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.reagentFrame.cover.purchaseButton:SetScript("OnClick", function()
			PlaySound("igMainMenuOption");
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB");
		end)

		f.reagentFrame.cover.purchaseText = f.reagentFrame.cover:CreateFontString(nil, 'OVERLAY')
		f.reagentFrame.cover.purchaseText:FontTemplate()
		f.reagentFrame.cover.purchaseText:SetPoint("BOTTOM", f.reagentFrame.cover.purchaseButton, "TOP", 0, 10)
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
		f.reagentToggle:SetPoint("RIGHT", f.bagText, "LEFT", -5, E.Border * 2)
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
			PlaySound("igCharacterInfoTab");
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
		f.sortButton:SetPoint("RIGHT", f.reagentToggle, "LEFT", -5, 0)
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetNormalTexture():SetInside()
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetPushedTexture():SetInside()
		f.sortButton:StyleButton(nil, true)
		f.sortButton:SetScript("OnEnter", BagItemAutoSortButton:GetScript("OnEnter"))
		f.sortButton:SetScript('OnClick', function()
			if f.holderFrame:IsShown() then
				B:CommandDecorator(B.SortBags, 'bank')();
			else
				SortReagentBankBags()
			end
		end)

		--Toggle Bags Button
		f.depositButton = CreateFrame("Button", name..'DepositButton', f.reagentFrame);
		f.depositButton:SetSize(16 + E.Border, 16 + E.Border)
		f.depositButton:SetTemplate()
		f.depositButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0)
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
			PlaySound("igMainMenuOption");
			DepositReagentBank()
		end)


		--Toggle Bags Button
		f.bagsButton = CreateFrame("Button", name..'BagsButton', f.holderFrame);
		f.bagsButton:SetSize(16 + E.Border, 16 + E.Border)
		f.bagsButton:SetTemplate()
		f.bagsButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetNormalTexture():SetInside()
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetPushedTexture():SetInside()
		f.bagsButton:StyleButton(nil, true)
		f.bagsButton.ttText = L["Toggle Bags"]
		f.bagsButton:SetScript("OnEnter", self.Tooltip_Show)
		f.bagsButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.bagsButton:SetScript('OnClick', function()
			local numSlots, full = GetNumBankSlots()
			PlaySound("igMainMenuOption");
			if numSlots >= 1 then
				ToggleFrame(f.ContainerHolder)
			else
				E:StaticPopup_Show("NO_BANK_BAGS")
			end
		end)

		f.purchaseBagButton = CreateFrame('Button', nil, f.holderFrame)
		f.purchaseBagButton:SetSize(16 + E.Border, 16 + E.Border)
		f.purchaseBagButton:SetTemplate()
		f.purchaseBagButton:SetPoint("RIGHT", f.bagsButton, "LEFT", -5, 0)
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
			if(full) then
				E:StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
			else
				E:StaticPopup_Show("BUY_BANK_SLOT")
			end
		end)

		f:SetScript('OnHide', CloseBankFrame)


		--Search
		f.editBox = CreateFrame('EditBox', name..'EditBox', f);
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2);
		f.editBox:CreateBackdrop('Default');
		f.editBox.backdrop:SetPoint("TOPLEFT", f.editBox, "TOPLEFT", -20, 2)
		f.editBox:Height(15);
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', (E.Border * 2) + 18, E.Border * 2 + 2);
		f.editBox:Point('RIGHT', f.purchaseBagButton, 'LEFT', -5, 0);
		f.editBox:SetAutoFocus(false);
		f.editBox:SetScript("OnEscapePressed", self.ResetAndClear);
		f.editBox:SetScript("OnEnterPressed", self.ResetAndClear);
		f.editBox:SetScript("OnEditFocusLost", self.ResetAndClear);
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText);
		f.editBox:SetScript("OnTextChanged", self.UpdateSearch);
		f.editBox:SetScript('OnChar', self.UpdateSearch);
		f.editBox:SetText(SEARCH);
		f.editBox:FontTemplate();

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, 'OVERLAY')
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		f.editBox.searchIcon:SetPoint("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1)
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
		f.sortButton:SetPoint("RIGHT", f.goldText, "LEFT", -5, E.Border * 2)
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetNormalTexture():SetInside()
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
		f.sortButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.sortButton:GetPushedTexture():SetInside()
		f.sortButton:StyleButton(nil, true)
		f.sortButton:SetScript("OnEnter", BagItemAutoSortButton:GetScript("OnEnter"))
		f.sortButton:SetScript('OnClick', function() B:CommandDecorator(B.SortBags, 'bags')(); end)


		--Bags Button
		f.bagsButton = CreateFrame("Button", name..'BagsButton', f);
		f.bagsButton:SetSize(16 + E.Border, 16 + E.Border)
		f.bagsButton:SetTemplate()
		f.bagsButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0)
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetNormalTexture():SetInside()
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up")
		f.bagsButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.bagsButton:GetPushedTexture():SetInside()
		f.bagsButton:StyleButton(nil, true)
		f.bagsButton.ttText = L["Toggle Bags"]
		f.bagsButton:SetScript("OnEnter", self.Tooltip_Show)
		f.bagsButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.bagsButton:SetScript('OnClick', function() ToggleFrame(f.ContainerHolder) end)

		--Vendor Grays
		f.vendorGraysButton = CreateFrame('Button', nil, f.holderFrame)
		f.vendorGraysButton:SetSize(16 + E.Border, 16 + E.Border)
		f.vendorGraysButton:SetTemplate()
		f.vendorGraysButton:SetPoint("RIGHT", f.bagsButton, "LEFT", -5, 0)
		f.vendorGraysButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.vendorGraysButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.vendorGraysButton:GetNormalTexture():SetInside()
		f.vendorGraysButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01")
		f.vendorGraysButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.vendorGraysButton:GetPushedTexture():SetInside()
		f.vendorGraysButton:StyleButton(nil, true)
		f.vendorGraysButton.ttText = L["Vendor Grays"]
		f.vendorGraysButton:SetScript("OnEnter", self.Tooltip_Show)
		f.vendorGraysButton:SetScript("OnLeave", self.Tooltip_Hide)
		f.vendorGraysButton:SetScript("OnClick", B.VendorGrayCheck)

		--Search
		f.editBox = CreateFrame('EditBox', name..'EditBox', f);
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2);
		f.editBox:CreateBackdrop('Default');
		f.editBox.backdrop:SetPoint("TOPLEFT", f.editBox, "TOPLEFT", -20, 2)
		f.editBox:Height(15);
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', (E.Border * 2) + 18, E.Border * 2 + 2);
		f.editBox:Point('RIGHT', f.vendorGraysButton, 'LEFT', -5, 0);
		f.editBox:SetAutoFocus(false);
		f.editBox:SetScript("OnEscapePressed", self.ResetAndClear);
		f.editBox:SetScript("OnEnterPressed", self.ResetAndClear);
		f.editBox:SetScript("OnEditFocusLost", self.ResetAndClear);
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText);
		f.editBox:SetScript("OnTextChanged", self.UpdateSearch);
		f.editBox:SetScript('OnChar', self.UpdateSearch);
		f.editBox:SetText(SEARCH);
		f.editBox:FontTemplate();

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, 'OVERLAY')
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		f.editBox.searchIcon:SetPoint("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1)
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

			if ElvUIBags and ElvUIBags.buttons then
				for _, bagButton in pairs(ElvUIBags.buttons) do
					bagButton:SetChecked(false)
				end
			end
		end)
	end

	tinsert(UISpecialFrames, f:GetName()) --Keep an eye on this for taints..
	tinsert(self.BagFrames, f)
	return f
end

function B:PositionBagFrames()
	if self.BagFrame then
		self.BagFrame:ClearAllPoints()
		if E.db.datatexts.rightChatPanel then
			self.BagFrame:Point('BOTTOMRIGHT', RightChatToggleButton, 'TOPRIGHT', 0 + E.db.bags.xOffset, 4 + E.db.bags.yOffset);
		else
			self.BagFrame:Point('BOTTOMRIGHT', RightChatToggleButton, 'BOTTOMRIGHT', 0 + E.db.bags.xOffset, 0 + E.db.bags.yOffset);
		end
	end

	if self.BankFrame then
		self.BankFrame:ClearAllPoints()
		if E.db.datatexts.leftChatPanel then
			self.BankFrame:Point('BOTTOMLEFT', LeftChatToggleButton, 'TOPLEFT', 0 + E.db.bags.xOffsetBank, 4 + E.db.bags.yOffsetBank);
		else
			self.BankFrame:Point('BOTTOMLEFT', LeftChatToggleButton, 'BOTTOMLEFT', 0 + E.db.bags.xOffsetBank, 0 + E.db.bags.yOffsetBank);
		end
	end
end

function B:ToggleBags(id)
	if id and GetContainerNumSlots(id) == 0 then return; end --Closes a bag when inserting a new container..

	if self.BagFrame:IsShown() then
		self:CloseBags();
	else
		self:OpenBags();
	end
end

function B:ToggleBackpack()
	if ( IsOptionFrameOpen() ) then
		return;
	end

	if IsBagOpen(0) then
		self:OpenBags()
	else
		self:CloseBags()
	end
end

function B:OpenBags()
	self.BagFrame:Show();
	self.BagFrame:UpdateAllSlots();
	E:GetModule('Tooltip'):GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:CloseBags()
	self.BagFrame:Hide();

	if self.BankFrame then
		self.BankFrame:Hide();
	end

	E:GetModule('Tooltip'):GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:OpenBank()
	if not self.BankFrame then
		self.BankFrame = self:ContructContainerFrame('ElvUI_BankContainerFrame', true);
		self:PositionBagFrames();
	end

	self:Layout(true)
	BankFrame:Show()
	self.BankFrame:Show();
	self.BankFrame:UpdateAllSlots();
	self.BagFrame:Show();
	self:UpdateTokens()
end

function B:PLAYERBANKBAGSLOTS_CHANGED()
	self:Layout(true)
end

--Update search when switching guild bank tab (slightly delayed, depending on how fast the event fires)
function B:GUILDBANKBAGSLOTS_CHANGED()
	self:SetGuildBankSearch(SEARCH_STRING);
end

function B:CloseBank()
	if not self.BankFrame then return; end -- WHY???, WHO KNOWS!
	self.BankFrame:Hide()
	BankFrame:Hide()
	self.BagFrame:Hide()
end

function B:GUILDBANKFRAME_OPENED()
	--[[local button = CreateFrame("Button", "GuildSortButton", GuildBankFrame, "UIPanelButtonTemplate")
	button:StripTextures()
	button:SetTemplate("Default", true)
	button:Size(110, 20)
	button:Point("RIGHT", GuildItemSearchBox, "LEFT", -4, 0)
	button:SetText(L["Sort Tab"])
	button:SetScript("OnClick", function() B:CommandDecorator(B.SortBags, 'guild')() end)
	E.Skins:HandleButton(button, true)]]
	if GuildItemSearchBox then
		GuildItemSearchBox:SetScript("OnEscapePressed", self.ResetAndClear);
		GuildItemSearchBox:SetScript("OnEnterPressed", self.ResetAndClear);
		GuildItemSearchBox:SetScript("OnEditFocusLost", self.ResetAndClear);
		GuildItemSearchBox:SetScript("OnEditFocusGained", GuildItemSearchBox.HighlightText);
		GuildItemSearchBox:SetScript("OnTextChanged", self.UpdateSearch);
		GuildItemSearchBox:SetScript('OnChar', self.UpdateSearch);
	end
	self:UnregisterEvent("GUILDBANKFRAME_OPENED")
end

function B:Initialize()
	self:LoadBagBar();

	if not E.private.bags.enable then
		self:SecureHook('UpdateContainerFrameAnchors');
		return;
	end
	E.bags = self;

	self.db = E.db.bags;
	self.BagFrames = {};

	self.BagFrame = self:ContructContainerFrame('ElvUI_ContainerFrame');

	--Hook onto Blizzard Functions
	--self:SecureHook('UpdateNewItemList', 'ClearNewItems')
	self:SecureHook('OpenAllBags', 'OpenBags');
	self:SecureHook('CloseAllBags', 'CloseBags');
	self:SecureHook('ToggleBag', 'ToggleBags')
	self:SecureHook('ToggleAllBags', 'ToggleBackpack');
	self:SecureHook('ToggleBackpack')
	self:SecureHook('BackpackTokenFrame_Update', 'UpdateTokens');

	self:PositionBagFrames();
	self:Layout();

	E.Bags = self;

	self:DisableBlizzard();
	self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	self:RegisterEvent("PLAYER_MONEY", "UpdateGoldText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateGoldText")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGoldText")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGoldText")
	self:RegisterEvent("BANKFRAME_OPENED", "OpenBank")
	self:RegisterEvent("BANKFRAME_CLOSED", "CloseBank")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	self:RegisterEvent("GUILDBANKFRAME_OPENED")

	BankFrame:SetScale(0.00001)
	BankFrame:SetAlpha(0)
	BankFrame:SetPoint("TOPLEFT")
	BankFrame:SetScript("OnShow", nil)

	StackSplitFrame:SetFrameStrata('DIALOG')
end

function B:UpdateContainerFrameAnchors()
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;
	if ( BankFrame:IsShown() ) then
		leftLimit = BankFrame:GetRight() - 25;
	end

	while ( containerScale > CONTAINER_SCALE ) do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale;
		yOffset = CONTAINER_OFFSET_Y / containerScale;
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;
		local frameHeight;
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = _G[frameName]:GetHeight();
			if ( freeScreenHeight < frameHeight ) then
				-- Start a new column
				column = column + 1;
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset;
				freeScreenHeight = screenHeight - yOffset;
			end
			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
		end
		if ( leftMostPoint < leftLimit ) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end

	if ( containerScale < CONTAINER_SCALE ) then
		containerScale = CONTAINER_SCALE;
	end

	screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	xOffset = CONTAINER_OFFSET_X / containerScale;
	yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset;
	column = 0;

	local bagsPerColumn = 0
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = _G[frameName];
		frame:SetScale(1);
		if ( index == 1 ) then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", RightChatToggleButton, "TOPRIGHT", 2, 2);
			bagsPerColumn = bagsPerColumn + 1
		elseif ( freeScreenHeight < frame:GetHeight() ) then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = screenHeight - yOffset;
			if column > 1 then
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[(index - bagsPerColumn) - 1], "BOTTOMLEFT", -CONTAINER_SPACING, 0 );
			else
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - bagsPerColumn], "BOTTOMLEFT", -CONTAINER_SPACING, 0 );
			end
			bagsPerColumn = 0
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);
			bagsPerColumn = bagsPerColumn + 1
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
	end
end

E:RegisterModule(B:GetName())