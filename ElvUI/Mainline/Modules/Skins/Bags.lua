local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local select = select
local unpack = unpack

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local hooksecurefunc = hooksecurefunc

local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local QUESTS_LABEL = QUESTS_LABEL
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local TEXTURE_ITEM_QUEST_BORDER = TEXTURE_ITEM_QUEST_BORDER

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
	for i = 1, button:GetNumRegions() do
		local region = select(i, button:GetRegions())
		if region and region:IsObjectType('Texture') and region ~= button.UpgradeIcon and region ~= button.ItemContextOverlay then
			region:SetTexture()
		end
	end
end

local function SkinButton(button)
	if button.template then return end

	StripBlizzard(button)

	button:SetTemplate()
	button:StyleButton()
	button.IconBorder:Kill()

	button.icon:SetInside()
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.searchOverlay:SetColorTexture(0, 0, 0, 0.8)

	if button.IconQuestTexture then
		button.IconQuestTexture:SetTexCoord(unpack(E.TexCoords))
		button.IconQuestTexture:SetInside(button)
	end

	if button.Cooldown then
		E:RegisterCooldown(button.Cooldown)
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

	local slotID = button:GetID()
	local texture, _, _, rarity, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bagID, slotID)
	local isQuestItem, questId = GetContainerItemQuestInfo(bagID, slotID)
	button.icon:SetTexture(texture)
	button.itemID, button.ilink = itemID, itemLink

	if itemLink then
		button.name, _, button.quality, _, _, button.type = GetItemInfo(itemLink)
		if not button.quality then
			button.quality = rarity
		end
	else
		button.name, button.quality, button.type = nil, nil, nil
	end

	if questId or isQuestItem then
		button.type = QUESTS_LABEL
	end

	UpdateBorderColors(button)
end

local function BagIcon(container, texture)
	if not container.PortraitButton then return end

	if not container.BagIcon then
		container.BagIcon = container.PortraitButton:CreateTexture()
		container.BagIcon:SetTexCoord(unpack(E.TexCoords))
		container.BagIcon:SetInside()
	end

	container.BagIcon:SetTexture(texture)
end

local function SkinContainer(container)
	local size = container.size
	if not size then return end

	local name = container:GetName()
	local bagID = container:GetID()

	for i = 1, size do
		local button = _G[name..'Item'..i]
		if button then
			SkinItemButton(button, bagID)
		end
	end
end

local function ContainerOnEvent(container, event, bagID)
	if event == 'BAG_UPDATE' and container:GetID() == bagID then
		SkinContainer(container)
	end
end

local function SkinBag(bagID)
	local container = _G['ContainerFrame'..bagID]
	if container and not container.template then
		container:SetFrameStrata('HIGH')
		container:StripTextures(true)
		container:SetTemplate('Transparent')
		container:HookScript('OnEvent', ContainerOnEvent)
		container:HookScript('OnShow', SkinContainer)

		S:HandleCloseButton(_G[container:GetName()..'CloseButton'])
		S:HandleButton(container.PortraitButton)
		container.PortraitButton:Size(35)
		container.PortraitButton.Highlight:SetAlpha(0)

		if bagID == 1 then
			_G.BackpackTokenFrame:StripTextures(true)

			for j = 1, MAX_WATCHED_TOKENS do
				local token = _G['BackpackTokenFrameToken'..j]
				token.count:SetPoint('RIGHT', token.icon, 'LEFT', -3, 0)
				S:HandleIcon(token.icon, true)
			end
		end
	end
end

local function SkinAllBags()
	for bagID = 1, NUM_CONTAINER_FRAMES do
		SkinBag(bagID)
	end
end

local bagIconCache = {}
local function UpdateContainerButton(frame)
	local frameName = frame:GetName()
	for i=1, frame.size do
		local questTexture = _G[frameName..'Item'..i..'IconQuestTexture']
		if questTexture:IsShown() and questTexture:GetTexture() == TEXTURE_ITEM_QUEST_BORDER then
			questTexture:Hide()
		end
	end

	local title = _G[frameName..'Name']
	if title and title.GetText then
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

	_G.BagItemAutoSortButton:ClearAllPoints()
	_G.BagItemAutoSortButton:Point('LEFT', _G.BagItemSearchBox, 'RIGHT', 5, 3)
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

	_G.BankItemAutoSortButton:ClearAllPoints()
	_G.BankItemAutoSortButton:Point('LEFT', _G.BankItemSearchBox, 'RIGHT', 5, 2)

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
		local _, _, _, rarity, _, _, itemLink, _, _, itemID = GetContainerItemInfo(container, slotID)
		local isQuestItem, questId = GetContainerItemQuestInfo(container, slotID)
		button.itemID, button.ilink = itemID, itemLink

		if itemLink then
			button.name, _, button.quality, _, _, button.type = GetItemInfo(itemLink)
			if not button.quality then
				button.quality = rarity
			end
		else
			button.name, button.quality, button.type = nil, nil, nil
		end

		if isQuestItem or questId then
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

	for _, icon in pairs({_G.BagItemAutoSortButton, _G.BankItemAutoSortButton}) do
		icon:StripTextures()
		icon:SetTemplate()
		icon:StyleButton()

		icon.Icon = icon:CreateTexture()
		icon.Icon:SetTexture(E.Media.Textures.PetBroom)
		icon.Icon:SetTexCoord(unpack(E.TexCoords))
		icon.Icon:SetInside()
	end

	hooksecurefunc('ContainerFrame_Update', UpdateContainerButton)
	hooksecurefunc('BankFrameItemButton_Update', UpdateBankItem)

	SkinAllBags()
end

S:AddCallback('ContainerFrame')
