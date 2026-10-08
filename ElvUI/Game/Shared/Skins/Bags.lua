local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')

local _G = _G
local next = next
local unpack = unpack
local select = select
local tinsert, sort = tinsert, sort
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetCVarBool = C_CVar.GetCVarBool
local GetItemInfo = C_Item.GetItemInfo
local GetItemQualityByID = C_Item.GetItemQualityByID
local GetInventoryItemID = GetInventoryItemID
local GetContainerItemCooldown = C_Container.GetContainerItemCooldown
local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID
local GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetInventoryItemLink = C_Container.GetInventoryItemLink or GetInventoryItemLink

local ITEMQUALITY_POOR = Enum.ItemQuality.Poor
local BANK_CONTAINER = Enum.BagIndex.Bank
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local QUESTS_LABEL = QUESTS_LABEL

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'ContainerFrame', nil, nil, nil, nil, function()
	return not E.private.bags.enable and E.private.skins.blizzard.enable and E.private.skins.blizzard.bags -- the bags module replaces these frames
end)

local function UpdateBorderColors(button)
	if button.type and button.type == QUESTS_LABEL then
		local r, g, b = unpack(B.QuestColors.questItem)
		button:SetBackdropBorderColor(r, g, b)
	else
		local r, g, b = E:GetItemQualityColor(button.quality and button.quality > 1 and button.quality)
		button:SetBackdropBorderColor(r, g, b)
	end
end

local function BagButtonOnEnter(self)
	AB:BindUpdate(self, 'BAG')
end

local function StripBlizzard(button)
	for _, region in next, { button:GetRegions() } do
		if region:IsObjectType('Texture') and (region ~= button.UpgradeIcon and region ~= button.JunkIcon and region ~= button.ItemContextOverlay) then
			region:SetTexture()
		end
	end
end

local function BackpackToken_Update(container)
	for _, token in next, container.Tokens do
		if not token.Icon.backdrop then
			S:HandleIcon(token.Icon, true)
			token.Count:ClearAllPoints()
			token.Count:Point('RIGHT', token.Icon, 'LEFT', -3, 0)
			token.Count:FontTemplate(nil, 12)
			token.Icon:Size(14)
		end
	end
end

local function SkinButton(button)
	if button.template then return end

	StripBlizzard(button)

	button:SetTemplate()
	button:StyleButton()
	button.IconBorder:SetAlpha(0)

	button.icon:SetInside()
	button.icon:SetTexCoords()
	button.searchOverlay:SetColorTexture(0, 0, 0, 0.8)
	button.IconQuestTexture:SetTexCoords()
	button.IconQuestTexture:SetInside(button)

	E:RegisterCooldown(button.Cooldown, 'bags')

	local slotID, bagID = button:GetSlotAndBagID()
	local start, duration = GetContainerItemCooldown(bagID, slotID)
	button.Cooldown:SetCooldown(start, duration)

	-- bag keybind support from actionbar module
	if E.private.actionbar.enable then
		button:HookScript('OnEnter', BagButtonOnEnter)
	end
end

local function SkinItemButton(button, bagID)
	if not button.template then
		SkinButton(button)
	end

	local slotID, _ = button:GetID()
	local info = B:GetContainerItemInfo(bagID, slotID)
	local quest = B:GetContainerItemQuestInfo(bagID, slotID)

	button.icon:SetTexture((info.iconFileID ~= 4701874 and info.iconFileID) or E.Media.Textures.Invisible)
	button.itemID, button.itemLink, button.rarity = info.itemID, info.hyperlink, info.quality
	button.isJunk = (button.rarity and button.rarity == ITEMQUALITY_POOR) and not info.hasNoValue

	if info.hyperlink then
		button.name, _, button.quality, _, _, button.type = GetItemInfo(info.hyperlink)

		if not button.quality then
			button.quality = info.quality
		end
	else
		button.name, button.quality, button.type = nil, nil, nil
	end

	button.JunkIcon:SetShown(button.isJunk)

	if quest and (quest.questID or quest.isQuestItem) then
		button.type = QUESTS_LABEL

		local questIcon = button.IconQuestTexture
		if questIcon:GetTexture() ~= E.Media.Textures.BagQuestIcon then
			questIcon:ClearAllPoints()
			questIcon:Point('TOPLEFT', button, 3, -3)
			questIcon:Point('BOTTOMRIGHT', button, -3, 3)
			questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
		end
	end

	UpdateBorderColors(button)
end

local function BagIcon(container, texture)
	if not container.BagIcon then
		container.BagIcon = container.PortraitButton:CreateTexture()
		container.BagIcon:SetTexCoords()
		container.BagIcon:SetInside()
	end

	container.BagIcon:SetTexture(texture)
end

local bagIconCache = {}
local function UpdateContainerButton(frame)
	local box = frame.TitleContainer
	local title = box.TitleText
	title:ClearAllPoints()
	title:Point('TOP', box, 0, -5)
	title:Point('LEFT', box, 45, 0)
	title:Point('RIGHT', box, -20, 0)

	local name = title:GetText()
	local icon = bagIconCache[name]
	if icon then
		BagIcon(frame, icon)
	elseif name then
		icon = (name ~= BACKPACK_TOOLTIP and select(10, GetItemInfo(name))) or E.Media.Textures.Backpack

		BagIcon(frame, icon)
		bagIconCache[name] = icon
	end

	local portrait = frame.PortraitButton
	local combined = GetCVarBool('combinedBags')
	portrait:Size(frame == _G.ContainerFrameCombinedBags and 50 or 35)

	if combined then
		portrait:ClearAllPoints()
		portrait:Point('TOPLEFT', 5, -5)
	else
		_G.BagItemAutoSortButton:ClearAllPoints()
		_G.BagItemAutoSortButton:Point('LEFT', _G.BagItemSearchBox, 'RIGHT', 5, 3)
	end

	if frame.MoneyFrame then -- container 1
		frame.MoneyFrame.Border:StripTextures()

		if not combined then
			_G.BagItemSearchBox:ClearAllPoints()
			_G.BagItemSearchBox:Point('TOPLEFT', frame, 9, -45)
			_G.BagItemSearchBox:Width(128)
		end
	end
end

local function SkinContainer(container)
	UpdateContainerButton(container)

	for _, button in container:EnumerateValidItems() do
		local bagID = button:GetBagID()
		SkinItemButton(button, bagID)
	end
end

local function SkinBag(bagID, bag)
	local container = bag or _G['ContainerFrame'..bagID]
	if not container.template then
		container:SetFrameStrata('HIGH')
		container:StripTextures(true)
		container:SetTemplate('Transparent')
		container.Bg:Hide()

		S:HandleCloseButton(container.CloseButton)
		S:HandleButton(container.PortraitButton)
		container.PortraitButton:NudgePoint(15, -7)
		container.PortraitButton.Highlight:SetAlpha(0)

		hooksecurefunc(container, 'UpdateItems', SkinContainer)
	end
end

local function SkinAllBags()
	for bagID = 1, NUM_CONTAINER_FRAMES do
		SkinBag(bagID)
	end

	SkinBag(1, _G.ContainerFrameCombinedBags)
end

local function HandleItem(button)
	button:StripTextures()
	button:StyleButton()
	button:SetTemplate()

	button.icon:SetInside()
	button.icon:SetTexCoords()
	button.Background:Hide()

	-- CamelotBankPanelItemButtonMixin:Refresh sets the slot frame atlas again on every refresh
	if E.Forever then
		button:GetNormalTexture():SetAlpha(0)
	end

	S:HandleIconBorder(button.IconBorder)
end

local function HandleTab(tab)
	S:HandleIcon(tab.Icon, true)
	S:HandleTab(tab)

	tab.SelectedTexture:SetColorTexture(1, 1, 1, .25)
	tab.Border:SetAlpha(0)
end

local function RefreshTabs(frame)
	for tab in frame.bankTabPool:EnumerateActive() do
		if not tab.IsSkinned then
			HandleTab(tab)

			tab.IsSkinned = true
		end
	end
end

local function HandleBagSlot(button)
	button:StyleButton()
	button:SetTemplate()
	button:GetNormalTexture():SetAlpha(0)
	button.Background:Hide()

	button.icon:SetInside()
	button.icon:SetTexCoords()

	S:HandleIconBorder(button.IconBorder)
end

local function RefreshBagButtons(frame)
	for button in frame.itemButtonBagPool:EnumerateActive() do
		if not button.IsSkinned then
			HandleBagSlot(button)

			button.IsSkinned = true
		end
	end
end

local function SortPageTabs(a, b)
	if a.bankType ~= b.bankType then
		return a.bankType < b.bankType
	end

	return a.pageNumber < b.pageNumber
end

local function RefreshPageTabs(frame)
	local tabs = {}
	for tab in frame.bankPageTabPool:EnumerateActive() do
		S:HandleLargeSideTab(tab)
		tinsert(tabs, tab)
	end

	sort(tabs, SortPageTabs)
	S:LayoutLargeSideTabs(frame.backdrop, tabs)
end

local function HandleSlots(frame)
	for item in frame.itemButtonPool:EnumerateActive() do
		if not item.IsSkinned then
			HandleItem(item)

			item.IsSkinned = true
		end
	end
end

local function HandleAutoSortButton(button)
	button:StripTextures()
	button:SetTemplate()
	button:StyleButton()

	button.Icon = button:CreateTexture()
	button.Icon:SetTexture(E.Media.Textures.PetBroom)
	button.Icon:SetTexCoords()
	button.Icon:SetInside()
end

local function HandleTabMenu(menu)
	B:BankTabs_MenuSkin(menu)
end

local containerIconCache = {
	[-2] = [[Interface\ICONS\INV_Misc_Key_03]],
	[0] = E.Media.Textures.Backpack
}

local function SetBagIcon(frame, texture)
	if not frame.BagIcon then
		local portraitButton = _G[frame:GetName()..'PortraitButton']

		portraitButton:CreateBackdrop()
		portraitButton:Size(32)
		portraitButton:Point('TOPLEFT', 12, -7)
		portraitButton:StyleButton(nil, true)
		portraitButton.hover:SetAllPoints()

		frame.BagIcon = portraitButton:CreateTexture()
		frame.BagIcon:SetTexCoords()
		frame.BagIcon:SetAllPoints()
	end

	frame.BagIcon:SetTexture(texture)
end

local function BankFrameItemUpdate(button)
	local id = button:GetID()

	if button.isBag then
		button:SetNormalTexture(E.ClearTexture)
		button:SetTemplate(nil, true)
		button:StyleButton()

		button.icon:SetInside()
		button.icon:SetTexCoords()

		local r, g, b = unpack(E.media.rgbvaluecolor)
		local highlight = button.HighlightFrame.HighlightTexture
		highlight:SetColorTexture(r, g, b, .3)
		highlight:SetInside()

		local slot = button:GetInventorySlot()
		local link = GetInventoryItemLink('player', slot)
		if link then
			local quality = GetItemQualityByID(link)
			if quality and quality > 1 then
				local itemR, itemG, itemB = E:GetItemQualityColor(quality)
				button:SetBackdropBorderColor(itemR, itemG, itemB)
				button.ignoreBorderColors = true
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = nil
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			button.ignoreBorderColors = nil
		end
	else
		local questIcon = button.IconQuestTexture
		questIcon:Hide()

		local link = GetContainerItemLink(BANK_CONTAINER, id)
		if link then
			local _, _, quality, _, _, _, _, _, _, _, _, itemClassID, _, bindType = GetItemInfo(link)
			local questItem = B:GetItemQuestInfo(link, bindType, itemClassID)
			if questItem then
				button:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
				button.ignoreBorderColors = true
				questIcon:Show()
			elseif quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)
				button:SetBackdropBorderColor(r, g, b)
				button.ignoreBorderColors = true
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = nil
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			button.ignoreBorderColors = nil
		end
	end
end

local function Container_GenerateFrame(frame)
	local id = frame:GetID()

	if id > 0 then
		local itemID = GetInventoryItemID('player', ContainerIDToInventoryID(id))

		if not containerIconCache[itemID] then
			containerIconCache[itemID] = select(10, GetItemInfo(itemID))
		end

		SetBagIcon(frame, containerIconCache[itemID])
	else
		SetBagIcon(frame, containerIconCache[id])
	end
end

local function Container_Update(frame)
	local id = frame:GetID()
	local frameName = frame:GetName()
	local _, bagType = GetContainerNumFreeSlots(id)

	for i = 1, frame.size do
		local item = _G[frameName..'Item'..i]
		local link = GetContainerItemLink(id, item:GetID())

		local questIcon = _G[frameName..'Item'..i..'IconQuestTexture']
		questIcon:Hide()

		local profession = B.ProfessionColors[bagType]
		if profession then
			item:SetBackdropBorderColor(profession.r, profession.g, profession.b, profession.a)
			item.ignoreBorderColors = true
		elseif link then
			local _, _, quality, _, _, _, _, _, _, _, _, itemClassID, _, bindType = GetItemInfo(link)

			local questItem = B:GetItemQuestInfo(link, bindType, itemClassID)
			if questItem then
				item:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
				item.ignoreBorderColors = true
				questIcon:Show()
			elseif quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)
				item:SetBackdropBorderColor(r, g, b)
				item.ignoreBorderColors = true
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
				item.ignoreBorderColors = nil
			end
		else
			item:SetBackdropBorderColor(unpack(E.media.bordercolor))
			item.ignoreBorderColors = nil
		end
	end
end

function S:ContainerFrame()
	if E.Modern then
		local bankFrame = _G.BankFrame
		bankFrame:CreateBackdrop('Transparent')

		bankFrame.NineSlice:StripTextures()
		bankFrame.PortraitContainer:Hide()
		bankFrame.TopTileStreaks:Hide()
		bankFrame.Background:Hide()
		bankFrame.Bg:Hide()

		S:HandleCloseButton(bankFrame.CloseButton)

		if E.Forever then -- Forever bank: page side tabs and bag slots, no TabSystem
			-- The page tabs are LargeSideTabButtonTemplate
			hooksecurefunc(bankFrame, 'RefreshPageTabs', RefreshPageTabs)
			hooksecurefunc(bankFrame, 'RefreshBagButtons', RefreshBagButtons)
		else
			local tabSystem = bankFrame.TabSystem
			for _, tab in next, tabSystem.tabs do
				S:HandleTab(tab)
			end

			tabSystem.spacing = -5
			tabSystem:MarkDirty()
			tabSystem:ClearAllPoints()
			tabSystem:Point('TOPLEFT', bankFrame, 'BOTTOMLEFT', -4, -1)
		end

		S:HandleEditBox(_G.BagItemSearchBox)
		S:HandleEditBox(_G.BankItemSearchBox)

		local panel = _G.BankPanel
		S:HandleButton(panel.MoneyFrame.DepositButton)
		S:HandleButton(panel.MoneyFrame.WithdrawButton)

		if E.Forever then -- Forever bank: bag slot purchase, no AutoDepositFrame
			S:HandleButton(panel.PurchaseButton)
		else
			S:HandleButton(panel.AutoDepositFrame.DepositButton)
			S:HandleCheckBox(panel.AutoDepositFrame.IncludeReagentsCheckbox)
		end

		HandleAutoSortButton(panel.AutoSortButton)

		panel:StripTextures()
		panel.EdgeShadows:Hide()
		panel.MoneyFrame.Border:Hide()

		panel.PurchasePrompt:StripTextures()
		S:HandleButton(panel.PurchasePrompt.TabCostFrame.PurchaseButton)
		panel.TabSettingsMenu:HookScript('OnShow', HandleTabMenu)

		if not E.Forever then -- Forever bank: this box would wrap the item grid and bag slots
			panel.backdrop2 = CreateFrame('Frame', nil, panel)
			panel.backdrop2:SetTemplate('Transparent')
			panel.backdrop2:Point('TOPLEFT', panel.PurchasePrompt, 'TOPLEFT', 8, 2)
			panel.backdrop2:Point('BOTTOMRIGHT', panel.PurchasePrompt, 'BOTTOMRIGHT', -6, 2)
		end

		HandleTab(panel.PurchaseTab)

		if not E.Forever then -- Forever has no bankTabPool
			hooksecurefunc(panel, 'RefreshBankTabs', RefreshTabs)
		end

		hooksecurefunc(panel, 'GenerateItemSlotsForSelectedTab', HandleSlots)

		HandleAutoSortButton(_G.BagItemAutoSortButton)

		_G.BackpackTokenFrame:StripTextures(true)
		hooksecurefunc(_G.BackpackTokenFrame, 'Update', BackpackToken_Update)

		SkinAllBags()
	else
		S:HandleEditBox(_G.BagItemSearchBox)

		-- ContainerFrame
		for i = 1, NUM_CONTAINER_FRAMES do
			local frame = _G['ContainerFrame'..i]
			frame:StripTextures(true)
			S:HandleFrame(frame, true, nil, 9, -4, -4, 2)

			for j = 1, _G.MAX_CONTAINER_ITEMS do
				local item = _G['ContainerFrame'..i..'Item'..j]
				item:SetNormalTexture(E.ClearTexture)
				item:SetTemplate(nil, true)
				item:StyleButton()

				local icon = _G['ContainerFrame'..i..'Item'..j..'IconTexture']
				icon:SetInside()
				icon:SetTexCoords()

				local questIcon = _G['ContainerFrame'..i..'Item'..j..'IconQuestTexture']
				questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
				questIcon.SetTexture = E.noop
				questIcon:SetTexCoord(0, 1, 0, 1)
				questIcon:SetInside()

				E:RegisterCooldown(_G['ContainerFrame'..i..'Item'..j..'Cooldown'], 'bags')
			end
		end

		hooksecurefunc('ContainerFrame_GenerateFrame', Container_GenerateFrame)
		hooksecurefunc('ContainerFrame_Update', Container_Update)

		_G.BackpackTokenFrame:StripTextures()

		-- BankFrame
		local bankFrame = _G.BankFrame
		bankFrame:StripTextures(true)
		S:HandleFrame(bankFrame, true, nil, 12, 0, 10, 80)

		if E.Mists then
			S:HandleEditBox(_G.BankItemSearchBox)
		else
			local closeButton = _G.BankCloseButton
			closeButton:ClearAllPoints()
			S:HandleCloseButton(closeButton, bankFrame.backdrop)
		end

		_G.BankSlotsFrame:StripTextures()

		local moneyFrame = _G.BankFrameMoneyFrame
		moneyFrame:ClearAllPoints()
		moneyFrame:Point('RIGHT', 0, 0)

		for i = 1, _G.NUM_BANKGENERIC_SLOTS do
			local button = _G['BankFrameItem'..i]
			local icon = _G['BankFrameItem'..i..'IconTexture']
			local cooldown = _G['BankFrameItem'..i..'Cooldown']

			button:SetNormalTexture(E.ClearTexture)
			button:SetTemplate(nil, true)
			button:StyleButton()
			button.IconBorder:StripTextures()
			button.IconOverlay:StripTextures()

			icon:SetInside()
			icon:SetTexCoords()

			button.IconQuestTexture:SetTexture(E.Media.Textures.BagQuestIcon)
			button.IconQuestTexture.SetTexture = E.noop
			button.IconQuestTexture:SetTexCoord(0, 1, 0, 1)
			button.IconQuestTexture:SetInside()

			E:RegisterCooldown(cooldown, 'bags')
		end

		S:HandleButton(_G.BankFramePurchaseButton)

		hooksecurefunc('BankFrameItemButton_Update', BankFrameItemUpdate)
	end
end
