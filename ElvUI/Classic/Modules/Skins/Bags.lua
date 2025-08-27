local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')

local _G = _G
local select, unpack = select, unpack
local hooksecurefunc = hooksecurefunc

local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID
local GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetInventoryItemLink = C_Container.GetInventoryItemLink or GetInventoryItemLink

local GetItemInfo = C_Item.GetItemInfo
local GetItemQualityByID = C_Item.GetItemQualityByID
local GetInventoryItemID = GetInventoryItemID

local BANK_CONTAINER = Enum.BagIndex.Bank
local LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM

local bagIconCache = {
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
		frame.BagIcon:SetTexCoord(unpack(E.TexCoords))
		frame.BagIcon:SetAllPoints()
	end

	frame.BagIcon:SetTexture(texture)
end

function S:ContainerFrame()
	if E.private.bags.enable or not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bags) then return end

	-- ContainerFrame
	for i = 1, _G.NUM_CONTAINER_FRAMES do
		local frame = _G['ContainerFrame'..i]
		local closeButton = _G['ContainerFrame'..i..'CloseButton']

		frame:StripTextures(true)
		S:HandleFrame(frame, true, nil, 9, -4, -4, 2)

		S:HandleCloseButton(closeButton, frame.backdrop)

		for j = 1, _G.MAX_CONTAINER_ITEMS do
			local item = _G['ContainerFrame'..i..'Item'..j]
			item:SetNormalTexture(E.ClearTexture)
			item:SetTemplate(nil, true)
			item:StyleButton()

			local icon = _G['ContainerFrame'..i..'Item'..j..'IconTexture']
			if icon then
				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))
			end

			local questIcon = _G['ContainerFrame'..i..'Item'..j..'IconQuestTexture']
			if questIcon then
				questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
				questIcon.SetTexture = E.noop
				questIcon:SetTexCoord(0, 1, 0, 1)
				questIcon:SetInside()
			end

			local cooldown = _G['ContainerFrame'..i..'Item'..j..'Cooldown']
			if cooldown then
				E:RegisterCooldown(cooldown, 'bags')
			end
		end
	end

	hooksecurefunc('ContainerFrame_GenerateFrame', function(frame)
		local id = frame:GetID()

		if id > 0 then
			local itemID = GetInventoryItemID('player', ContainerIDToInventoryID(id))

			if not bagIconCache[itemID] then
				bagIconCache[itemID] = select(10, GetItemInfo(itemID))
			end

			SetBagIcon(frame, bagIconCache[itemID])
		else
			SetBagIcon(frame, bagIconCache[id])
		end
	end)

	hooksecurefunc('ContainerFrame_Update', function(frame)
		local id = frame:GetID()
		local frameName = frame:GetName()
		local _, bagType = GetContainerNumFreeSlots(id)

		for i = 1, frame.size do
			local item = _G[frameName..'Item'..i]
			local link = GetContainerItemLink(id, item:GetID())

			local questIcon = _G[frameName..'Item'..i..'IconQuestTexture']
			if questIcon then
				questIcon:Hide()
			end

			local profession = B.ProfessionColors[bagType]
			if profession then
				item:SetBackdropBorderColor(profession.r, profession.g, profession.b, profession.a)
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
	end)

	-- BankFrame
	local BankFrame = _G.BankFrame
	BankFrame:StripTextures(true)
	S:HandleFrame(BankFrame, true, nil, 12, 0, 10, 80)

	S:HandleCloseButton(_G.BankCloseButton, BankFrame.backdrop)

	_G.BankSlotsFrame:StripTextures()

	_G.BankFrameMoneyFrame:Point('RIGHT', 0, 0)

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
		icon:SetTexCoord(unpack(E.TexCoords))

		button.IconQuestTexture:SetTexture(E.Media.Textures.BagQuestIcon)
		button.IconQuestTexture.SetTexture = E.noop
		button.IconQuestTexture:SetTexCoord(0, 1, 0, 1)
		button.IconQuestTexture:SetInside()

		E:RegisterCooldown(cooldown, 'bags')
	end

	S:HandleButton(_G.BankFramePurchaseButton)

	hooksecurefunc('BankFrameItemButton_Update', function(button)
		local id = button:GetID()

		if button.isBag then
			button:SetNormalTexture(E.ClearTexture)
			button:SetTemplate(nil, true)
			button:StyleButton()

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))

			button.HighlightFrame.HighlightTexture:SetInside()
			button.HighlightFrame.HighlightTexture:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)

			local link = GetInventoryItemLink('player', ContainerIDToInventoryID(id))
			if link then
				local quality = GetItemQualityByID(link)
				if quality and quality > 1 then
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
	end)
end

S:AddCallback('ContainerFrame')
