local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')

local _G = _G
local next = next
local select = select
local unpack = unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local GetCVarBool = C_CVar.GetCVarBool
local GetItemInfo = C_Item.GetItemInfo
local GetContainerItemCooldown = C_Container.GetContainerItemCooldown

local ITEMQUALITY_POOR = Enum.ItemQuality.Poor
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local QUESTS_LABEL = QUESTS_LABEL

local function UpdateBorderColors(button)
	if button.type and button.type == QUESTS_LABEL then
		button:SetBackdropBorderColor(1, 0.2, 0.2)
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

local function GetSlotAndBagID(button)
	if button.GetSlotAndBagID then -- bags
		return button:GetSlotAndBagID()
	elseif button.GetBagID then -- bank
		local slotID, bagID = button:GetID(), button:GetBagID()
		return slotID, bagID
	end
end

local function SkinButton(button)
	if button.template then return end

	StripBlizzard(button)

	button:SetTemplate()
	button:StyleButton()
	button.IconBorder:SetAlpha(0)

	button.icon:SetInside()
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.searchOverlay:SetColorTexture(0, 0, 0, 0.8)

	if button.IconQuestTexture then
		button.IconQuestTexture:SetTexCoord(unpack(E.TexCoords))
		button.IconQuestTexture:SetInside(button)
	end

	if button.Cooldown then
		E:RegisterCooldown(button.Cooldown, 'bags')

		local slotID, bagID = GetSlotAndBagID(button)
		if slotID and bagID then -- initialize any cooldown
			local start, duration = GetContainerItemCooldown(bagID, slotID)
			button.Cooldown:SetCooldown(start, duration)
		end
	end

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

	if button.JunkIcon then
		button.JunkIcon:SetShown(button.isJunk)
	end

	if quest and (quest.questID or quest.isQuestItem) then
		button.type = QUESTS_LABEL

		local questIcon = button.IconQuestTexture
		local texture = questIcon and questIcon:GetTexture()
		if texture and texture ~= E.Media.Textures.BagQuestIcon then
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
		container.BagIcon:SetTexCoord(unpack(E.TexCoords))
		container.BagIcon:SetInside()
	end

	container.BagIcon:SetTexture(texture)
end

local bagIconCache = {}
local function UpdateContainerButton(frame)
	local box = frame.TitleContainer
	local title = box and box.TitleText
	if title and title.GetText then
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
	if container and not container.template then
		container:SetFrameStrata('HIGH')
		container:StripTextures(true)
		container:SetTemplate('Transparent')
		container.Bg:Hide()

		S:HandleCloseButton(container.CloseButton)
		S:HandleButton(container.PortraitButton)
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
	button.icon:SetTexCoord(unpack(E.TexCoords))

	if button.Background then
		button.Background:Hide()
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
	if frame.bankTabPool then
		for tab in frame.bankTabPool:EnumerateActive() do
			if not tab.IsSkinned then
				HandleTab(tab)

				tab.IsSkinned = true
			end
		end
	end
end

local function GenerateSlots(frame)
	if frame.itemButtonPool then
		for item in frame.itemButtonPool:EnumerateActive() do
			if not item.IsSkinned then
				HandleItem(item)

				item.IsSkinned = true
			end
		end
	end
end

local function HandleAutoSortButton(button)
	button:StripTextures()
	button:SetTemplate()
	button:StyleButton()

	button.Icon = button:CreateTexture()
	button.Icon:SetTexture(E.Media.Textures.PetBroom)
	button.Icon:SetTexCoord(unpack(E.TexCoords))
	button.Icon:SetInside()
end

local function HandleTabMenu(menu)
	B:BankTabs_MenuSkin(menu)
end

function S:ContainerFrame()
	if E.private.bags.enable or not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bags) then return end

	local bankFrame = _G.BankFrame
	if bankFrame then
		bankFrame:CreateBackdrop('Transparent')

		bankFrame.NineSlice:StripTextures()
		bankFrame.PortraitContainer:Hide()
		bankFrame.TopTileStreaks:Hide()
		bankFrame.Background:Hide()
		bankFrame.Bg:Hide()

		S:HandleCloseButton(bankFrame.CloseButton)

		local tabSystem = bankFrame.TabSystem
		if tabSystem then
			for _, tab in next, tabSystem.tabs do
				S:HandleTab(tab)
			end
		end
	end

	S:HandleEditBox(_G.BagItemSearchBox)
	S:HandleEditBox(_G.BankItemSearchBox)

	local panel = _G.BankPanel
	if panel then
		S:HandleButton(panel.MoneyFrame.DepositButton)
		S:HandleButton(panel.MoneyFrame.WithdrawButton)
		S:HandleButton(panel.AutoDepositFrame.DepositButton)
		S:HandleCheckBox(panel.AutoDepositFrame.IncludeReagentsCheckbox)

		HandleAutoSortButton(panel.AutoSortButton)

		panel:StripTextures()
		panel.EdgeShadows:Hide()
		panel.MoneyFrame.Border:Hide()

		panel.PurchasePrompt:StripTextures()
		S:HandleButton(panel.PurchasePrompt.TabCostFrame.PurchaseButton)

		local tabMenu = panel.TabSettingsMenu
		if tabMenu then -- skin the tab settings
			tabMenu:HookScript('OnShow', HandleTabMenu)
		end

		panel.backdrop2 = CreateFrame('Frame', nil, panel)
		panel.backdrop2:SetTemplate('Transparent')
		panel.backdrop2:Point('TOPLEFT', panel.PurchasePrompt, 'TOPLEFT', 8, 2)
		panel.backdrop2:Point('BOTTOMRIGHT', panel.PurchasePrompt, 'BOTTOMRIGHT', -6, 2)

		HandleTab(panel.PurchaseTab)

		hooksecurefunc(panel, 'RefreshBankTabs', RefreshTabs)
		hooksecurefunc(panel, 'GenerateItemSlotsForSelectedTab', GenerateSlots)
	end

	HandleAutoSortButton(_G.BagItemAutoSortButton)

	_G.BackpackTokenFrame:StripTextures(true)
	hooksecurefunc(_G.BackpackTokenFrame, 'Update', BackpackToken_Update)

	SkinAllBags()
end

S:AddCallback('ContainerFrame')
