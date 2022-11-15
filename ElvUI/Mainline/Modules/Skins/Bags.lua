local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')

local _G = _G
local next = next
local select = select
local unpack = unpack

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetCVarBool = GetCVarBool
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local hooksecurefunc = hooksecurefunc

local GetContainerItemCooldown = GetContainerItemCooldown or (C_Container and C_Container.GetContainerItemCooldown)

local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local QUESTS_LABEL = QUESTS_LABEL

local function UpdateBorderColors(button)
	if button.type and button.type == QUESTS_LABEL then
		button:SetBackdropBorderColor(1, 0.2, 0.2)
	elseif button.quality and button.quality > 1 then
		local r, g, b = GetItemQualityColor(button.quality)
		button:SetBackdropBorderColor(r, g, b)
	else
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function BagButtonOnEnter(self)
	AB:BindUpdate(self, 'BAG')
end

local function StripBlizzard(button)
	for _, region in next, { button:GetRegions() } do
		if region:IsObjectType('Texture') and (region ~= button.UpgradeIcon and region ~= button.ItemContextOverlay) then
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
	button.itemID, button.itemLink = info.itemID, info.hyperlink

	if info.hyperlink then
		button.name, _, button.quality, _, _, button.type = GetItemInfo(info.hyperlink)

		if not button.quality then
			button.quality = info.quality
		end
	else
		button.name, button.quality, button.type = nil, nil, nil
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
	if combined then
		portrait:Size(50)
		portrait:ClearAllPoints()
		portrait:Point('TOPLEFT', 5, -5)
	else
		portrait:Size(35)

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

local function UpdateBankItem(button)
	if not button.teplate then
		SkinButton(button)
	end

	local BankFrame = _G.BankFrame
	if not BankFrame.isSkinned then
		S:HandleButton(_G.BankFramePurchaseButton, true)
		S:HandleCloseButton(_G.BankFrameCloseButton)

		_G.BankFrameMoneyFrameInset:Kill()
		_G.BankFrameMoneyFrameBorder:Kill()

		BankFrame:StripTextures(true)
		BankFrame:SetTemplate('Transparent')

		BankFrame.backdrop2 = CreateFrame('Frame', nil, _G.BankSlotsFrame)
		BankFrame.backdrop2:SetTemplate('Transparent')
		BankFrame.backdrop2:Point('TOPLEFT', _G.BankFrameItem1, 'TOPLEFT', -6, 6)
		BankFrame.backdrop2:Point('BOTTOMRIGHT', _G.BankFrameItem28, 'BOTTOMRIGHT', 6, -6)

		BankFrame.backdrop3 = CreateFrame('Frame', nil, _G.BankSlotsFrame)
		BankFrame.backdrop3:SetTemplate('Transparent')
		BankFrame.backdrop3:Point('TOPLEFT', _G.BankSlotsFrame.Bag1, 'TOPLEFT', -6, 6)
		BankFrame.backdrop3:Point('BOTTOMRIGHT', _G.BankSlotsFrame.Bag7, 'BOTTOMRIGHT', 6, -6)

		BankFrame.isSkinned = true
	end

	local ReagentBankFrame = _G.ReagentBankFrame
	if _G.ReagentBankFrameItem1 and not ReagentBankFrame.backdrop2 then
		ReagentBankFrame.backdrop2 = CreateFrame('Frame', nil, ReagentBankFrame)
		ReagentBankFrame.backdrop2:SetTemplate('Transparent')
		ReagentBankFrame.backdrop2:Point('TOPLEFT', _G.ReagentBankFrameItem1, 'TOPLEFT', -6, 6)
		ReagentBankFrame.backdrop2:Point('BOTTOMRIGHT', _G.ReagentBankFrameItem98, 'BOTTOMRIGHT', 6, -6)
	end

	if not button.levelAdjusted then
		button:SetFrameLevel(button:GetFrameLevel() + 1)
		button.levelAdjusted = true
	end

	local slotID = button:GetID()
	local inventoryID = button:GetInventorySlot()
	local textureName = GetInventoryItemTexture('player', inventoryID)

	if textureName then
		button.icon:SetTexture(textureName)
	elseif button.isBag then
		local _, slotTextureName = GetInventorySlotInfo('Bag'..slotID)
		button.icon:SetTexture(slotTextureName)
	end

	if not button.isBag then
		local container = button:GetParent():GetID()
		local info = B:GetContainerItemInfo(container, slotID)
		local questInfo = B:GetContainerItemQuestInfo(container, slotID)
		button.itemID, button.itemLink = info.itemID, info.hyperlink

		if info.hyperlink then
			local _
			button.name, _, button.quality, _, _, button.type = GetItemInfo(info.hyperlink)
		else
			button.name, button.quality, button.type = nil, nil, nil
		end

		if questInfo.isQuestItem or questInfo.questID then
			button.type = QUESTS_LABEL
		end

		UpdateBorderColors(button)
	end
end

function S:ContainerFrame()
	if E.private.bags.enable or not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bags) then return end

	_G.BankSlotsFrame:StripTextures()
	S:HandleTab(_G.BankFrameTab1)
	S:HandleTab(_G.BankFrameTab2)
	S:HandleEditBox(_G.BagItemSearchBox)
	S:HandleEditBox(_G.BankItemSearchBox)

	S:HandleButton(_G.ReagentBankFrame.DespositButton)
	_G.ReagentBankFrame:HookScript('OnShow', _G.ReagentBankFrame.StripTextures)

	for _, icon in next, { _G.BagItemAutoSortButton, _G.BankItemAutoSortButton } do
		icon:StripTextures()
		icon:SetTemplate()
		icon:StyleButton()

		icon.Icon = icon:CreateTexture()
		icon.Icon:SetTexture(E.Media.Textures.PetBroom)
		icon.Icon:SetTexCoord(unpack(E.TexCoords))
		icon.Icon:SetInside()
	end

	_G.BackpackTokenFrame:StripTextures(true)
	hooksecurefunc(_G.BackpackTokenFrame, 'Update', BackpackToken_Update)
	hooksecurefunc('BankFrameItemButton_Update', UpdateBankItem)

	SkinAllBags()
end

S:AddCallback('ContainerFrame')
