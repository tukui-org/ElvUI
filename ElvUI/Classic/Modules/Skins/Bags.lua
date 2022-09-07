local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')

local _G = _G
local select, unpack = select, unpack
local hooksecurefunc = hooksecurefunc

local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetInventoryItemLink = GetInventoryItemLink
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local CreateFrame = CreateFrame

local BANK_CONTAINER = BANK_CONTAINER
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM

local bagIconCache = {
	[-2] = [[Interface\ICONS\INV_Misc_Key_03]],
	[0] = E.Media.Textures.Backpack
}

local function setBagIcon(frame, texture)
	if not frame.BagIcon then
		local portraitButton = _G[frame:GetName()..'PortraitButton']

		portraitButton:CreateBackdrop()
		portraitButton:Size(32)
		portraitButton:Point('TOPLEFT', 12, -7)
		portraitButton:StyleButton(nil, true)
		portraitButton.hover:SetAllPoints()

		frame.BagIcon = portraitButton:CreateTexture()
		frame.BagIcon:SetTexCoord(unpack(E.TexCoords))
		frame.BagIcon:SetAllPoints()
	end

	frame.BagIcon:SetTexture(texture)
end

function S:ContainerFrame()
	if E.private.bags.enable or not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bags) then return end

	-- ContainerFrame
	for i = 1, NUM_CONTAINER_FRAMES do
		local frame = _G['ContainerFrame'..i]
		local closeButton = _G['ContainerFrame'..i..'CloseButton']

		frame:StripTextures(true)
		S:HandleFrame(frame, true, nil, 9, -4, -4, 2)

		S:HandleCloseButton(closeButton, frame.backdrop)

		for j = 1, MAX_CONTAINER_ITEMS do
			local item = _G['ContainerFrame'..i..'Item'..j]
			local icon = _G['ContainerFrame'..i..'Item'..j..'IconTexture']
			local questIcon = _G['ContainerFrame'..i..'Item'..j..'IconQuestTexture']
			local cooldown = _G['ContainerFrame'..i..'Item'..j..'Cooldown']

			item:SetNormalTexture('')
			item:SetTemplate(nil, true)
			item:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))

			questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
			questIcon.SetTexture = E.noop
			questIcon:SetTexCoord(0, 1, 0, 1)
			questIcon:SetInside()

			cooldown.CooldownOverride = 'bags'
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('ContainerFrame_GenerateFrame', function(frame)
		local id = frame:GetID()

		if id > 0 then
			local itemID = GetInventoryItemID('player', ContainerIDToInventoryID(id))

			if not bagIconCache[itemID] then
				bagIconCache[itemID] = select(10, GetItemInfo(itemID))
			end

			setBagIcon(frame, bagIconCache[itemID])
		else
			setBagIcon(frame, bagIconCache[id])
		end
	end)

	hooksecurefunc('ContainerFrame_Update', function(frame)
		local frameName = frame:GetName()
		local id = frame:GetID()
		local _, bagType = GetContainerNumFreeSlots(id)

		for i = 1, frame.size do
			local item = _G[frameName..'Item'..i]
			local questIcon = _G[frameName..'Item'..i..'IconQuestTexture']
			local link = GetContainerItemLink(id, item:GetID())

			questIcon:Hide()

			if B.ProfessionColors[bagType] then
				item:SetBackdropBorderColor(unpack(B.ProfessionColors[bagType]))
				item.ignoreBorderColors = true
			elseif link then
				local _, _, quality, _, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)

				if itemClassID == LE_ITEM_CLASS_QUESTITEM then
					item:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
					item.ignoreBorderColors = true

					if questIcon then
						questIcon:Show()
					end
				elseif quality and quality > 1 then
					item:SetBackdropBorderColor(GetItemQualityColor(quality))
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
	end)

	-- BankFrame
	local BankFrame = _G.BankFrame
	BankFrame:StripTextures(true)
	S:HandleFrame(BankFrame, true, nil, 11, -12, -32, 93)

	S:HandleCloseButton(_G.BankCloseButton, BankFrame.backdrop)

	_G.BankSlotsFrame:StripTextures()

	for i = 1, NUM_BANKGENERIC_SLOTS do
		local button = _G['BankFrameItem'..i]
		local icon = _G['BankFrameItem'..i..'IconTexture']
		local cooldown = _G['BankFrameItem'..i..'Cooldown']

		button:SetNormalTexture('')
		button:SetTemplate(nil, true)
		button:StyleButton()
		button.IconBorder:StripTextures()
		button.IconOverlay:StripTextures()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		button.IconQuestTexture:SetTexture(E.Media.Textures.BagQuestIcon)
		button.IconQuestTexture.SetTexture = E.noop
		button.IconQuestTexture:SetTexCoord(0, 1, 0, 1)
		button.IconQuestTexture:SetInside()

		cooldown.CooldownOverride = 'bags'
		E:RegisterCooldown(cooldown)
	end

	BankFrame.itemBackdrop = CreateFrame('Frame', 'BankFrameItemBackdrop', BankFrame)
	BankFrame.itemBackdrop:SetTemplate()
	BankFrame.itemBackdrop:Point('TOPLEFT', _G.BankFrameItem1, 'TOPLEFT', -6, 6)
	BankFrame.itemBackdrop:Point('BOTTOMRIGHT', _G.BankFrameItem24, 'BOTTOMRIGHT', 6, -6)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	BankFrame.bagBackdrop = CreateFrame('Frame', 'BankFrameBagBackdrop', BankFrame)
	BankFrame.bagBackdrop:SetTemplate()
	BankFrame.bagBackdrop:Point('TOPLEFT', _G.BankSlotsFrame.Bag1, 'TOPLEFT', -6, 6)
	BankFrame.bagBackdrop:Point('BOTTOMRIGHT', _G.BankSlotsFrame.Bag6, 'BOTTOMRIGHT', 6, -6)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(_G.BankFramePurchaseButton)

	hooksecurefunc('BankFrameItemButton_Update', function(button)
		local id = button:GetID()

		if button.isBag then
			button:SetNormalTexture('')
			button:SetTemplate(nil, true)
			button:StyleButton()

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))

			button.HighlightFrame.HighlightTexture:SetInside()
			button.HighlightFrame.HighlightTexture:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)

			local link = GetInventoryItemLink('player', ContainerIDToInventoryID(id))
			if link then
				local _, _, quality = GetItemInfo(link)
				if quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
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
			if questIcon then
				questIcon:Hide()
			end

			local link = GetContainerItemLink(BANK_CONTAINER, id)
			if link then
				local _, _, quality, _, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)

				if itemClassID == LE_ITEM_CLASS_QUESTITEM then
					button:SetBackdropBorderColor(unpack(B.QuestColors.questItem))
					button.ignoreBorderColors = true

					if questIcon then
						questIcon:Show()
					end
				elseif quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
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
	end)
end

S:AddCallback('ContainerFrame')
