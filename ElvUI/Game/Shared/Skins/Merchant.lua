local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetBuybackItemInfo = GetBuybackItemInfo
local GetNumBuybackItems = GetNumBuybackItems
local GetMerchantNumItems = GetMerchantNumItems
local GetItemQualityByID = C_Item.GetItemQualityByID

local QUEST_ICON = [[Interface\ContainerFrame\UI-Icon-QuestBang]]

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'MerchantFrame', nil, nil, nil, nil, 'merchant')

local function HandleIconButton(button, ...)
	S:HandleButton(button)
	button:StyleButton()

	if E.Modern then
		S:HandleIcon(button.Icon)
		button.Icon:SetInside()
	end

	local region = button:GetRegions()
	region:SetTexCoord(...)
	region:SetInside()
end

local function QuestIcon_SetTexture(iconQuest, texture)
	if texture == QUEST_ICON then
		iconQuest:SetTexture(E.Media.Textures.BagQuestIcon)
	end
end

local function UpdateRepairButtons()
	_G.MerchantRepairAllButton:ClearAllPoints()
	_G.MerchantRepairAllButton:Point('BOTTOMRIGHT', _G.MerchantFrame, 'BOTTOMLEFT', 90, 32)
	_G.MerchantRepairItemButton:ClearAllPoints()
	_G.MerchantRepairItemButton:Point('RIGHT', _G.MerchantRepairAllButton, 'LEFT', -5, 0)
	_G.MerchantSellAllJunkButton:ClearAllPoints()
	_G.MerchantSellAllJunkButton:Point('RIGHT', _G.MerchantRepairAllButton, 'LEFT', 117, 0)
end

local function SetQualityColor(button, name, link)
	local quality = link and GetItemQualityByID(link)
	if quality and quality > 1 then
		local r, g, b = E:GetItemQualityColor(quality)
		button:SetBackdropBorderColor(r, g, b)
		name:SetTextColor(r, g, b)
	else
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		name:SetTextColor(1, 1, 1)
	end
end

local function UpdateBuybackInfo()
	local numBuybackItems = GetNumBuybackItems()

	for i = 1, _G.BUYBACK_ITEMS_PER_PAGE do
		if i <= numBuybackItems then
			local link = GetBuybackItemInfo(i)
			SetQualityColor(_G['MerchantItem'..i..'ItemButton'], _G['MerchantItem'..i..'Name'], link)
		end
	end
end

local function UpdateMerchantInfo()
	for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
		local button = _G['MerchantItem'..i..'ItemButton']

		local money = _G['MerchantItem'..i..'MoneyFrame']
		money:ClearAllPoints()
		money:Point('BOTTOMLEFT', button, 'BOTTOMRIGHT', 5, -3)

		local currency = _G['MerchantItem'..i..'AltCurrencyFrame']
		currency:ClearAllPoints()

		if button.price and button.extendedCost then
			currency:Point('LEFT', money, 'RIGHT', -8, 0)
		else
			currency:Point('BOTTOMLEFT', button, 'BOTTOMRIGHT', 5, -3)
		end
	end

	-- classic merchant has no quality borders
	if not E.Modern then
		local numBuybackItems = GetNumBuybackItems()
		local numMerchantItems = GetMerchantNumItems()
		local index = (_G.MerchantFrame.page - 1) * _G.MERCHANT_ITEMS_PER_PAGE

		for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
			index = index + 1

			if index <= numMerchantItems then
				local button = _G['MerchantItem'..i..'ItemButton']
				SetQualityColor(button, _G['MerchantItem'..i..'Name'], button.link)
			end
		end

		local link = GetBuybackItemInfo(numBuybackItems)
		SetQualityColor(_G.MerchantBuyBackItemItemButton, _G.MerchantBuyBackItemName, link)
	end
end

local function SetItemButtonScale(button, scale)
	if scale ~= 1 then
		button.Count:SetScale(1)
	end
end

local function SetItemButtonAnchorPoint(button, point, x, y)
	if point ~= 'BOTTOMRIGHT' or x ~= 0 or y ~= 1 then
		button.Count:ClearAllPoints()
		button.Count:Point('BOTTOMRIGHT', 0, 1)
	end
end

function S:MerchantFrame()
	S:HandlePortraitFrame(_G.MerchantFrame)
	_G.MerchantFrame:Width(360)

	_G.MerchantMoneyBg:StripTextures()
	_G.MerchantMoneyInset:StripTextures()

	if E.Modern then
		_G.MerchantExtraCurrencyInset:StripTextures()
		_G.MerchantExtraCurrencyBg:StripTextures()

		S:HandleDropDownBox(_G.MerchantFrame.FilterDropdown)
	end

	-- Center the columns on the frame
	_G.MerchantItem1:Point('TOPLEFT', _G.MerchantFrame, 'TOPLEFT', 22, -65)

	-- Skin tabs
	for i = 1, 2 do
		S:HandleTab(_G['MerchantFrameTab'..i])
	end

	-- Reposition tabs
	_G.MerchantFrameTab1:ClearAllPoints()
	_G.MerchantFrameTab2:ClearAllPoints()
	_G.MerchantFrameTab1:Point('TOPLEFT', _G.MerchantFrame, 'BOTTOMLEFT', E.Modern and -3 or -10, 0)
	_G.MerchantFrameTab2:Point('TOPLEFT', _G.MerchantFrameTab1, 'TOPRIGHT', E.Modern and -5 or -19, 0)

	-- Skin icons / merchant slots
	for i = 1, _G.BUYBACK_ITEMS_PER_PAGE do
		local item = _G['MerchantItem'..i]
		item:Size(155, 45)
		item:StripTextures(true)
		item:CreateBackdrop('Transparent')
		item.backdrop:Point('TOPLEFT', -3, 2)
		item.backdrop:Point('BOTTOMRIGHT', 2, -3)

		local slot = _G['MerchantItem'..i..'SlotTexture']
		item.Name:Point('LEFT', slot, 'RIGHT', -5, 5)
		item.Name:Size(110, 30)

		local button = _G['MerchantItem'..i..'ItemButton']
		button:StripTextures()
		button:StyleButton()
		button:SetTemplate(nil, true)
		button:Point('TOPLEFT', item, 'TOPLEFT', 4, -4)

		local icon = button.icon
		icon:SetTexCoords()
		icon:ClearAllPoints()
		icon:Point('TOPLEFT', 1, -1)
		icon:Point('BOTTOMRIGHT', -1, 1)

		if E.Modern then
			local questIcon = button.IconQuestTexture
			questIcon:SetTexCoord(0, 1, 0, 1)
			questIcon:SetInside()

			hooksecurefunc(questIcon, 'SetTexture', QuestIcon_SetTexture)
		end

		button.IconOverlay:SetInside(button, 1, 1) -- Decor items

		S:HandleIconBorder(button.IconBorder)

		for j = 1, _G.MAX_ITEM_COST do
			local currencyIcon = _G['MerchantItem'..i..'AltCurrencyFrameItem'..j..'Texture']
			currencyIcon:SetTexCoords()
		end
	end

	-- Skin buyback item frame + icon
	_G.MerchantBuyBackItem:Point('TOPLEFT', _G.MerchantItem10, 'BOTTOMLEFT', 0, -50)
	_G.MerchantBuyBackItem:StripTextures(true)
	_G.MerchantBuyBackItem:CreateBackdrop('Transparent')
	_G.MerchantBuyBackItem.backdrop:Point('TOPLEFT', -6, 6)
	_G.MerchantBuyBackItem.backdrop:Point('BOTTOMRIGHT', 6, -6)

	_G.MerchantBuyBackItemItemButton:StripTextures()
	_G.MerchantBuyBackItemItemButton:StyleButton()
	_G.MerchantBuyBackItemItemButton:SetTemplate(nil, true)
	S:HandleIconBorder(_G.MerchantBuyBackItemItemButton.IconBorder)

	_G.MerchantBuyBackItemItemButtonIconTexture:SetTexCoords()
	_G.MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
	_G.MerchantBuyBackItemItemButtonIconTexture:Point('TOPLEFT', 1, -1)
	_G.MerchantBuyBackItemItemButtonIconTexture:Point('BOTTOMRIGHT', -1, 1)

	HandleIconButton(_G.MerchantRepairItemButton, 0.04, 0.24, 0.06, 0.5)
	HandleIconButton(_G.MerchantGuildBankRepairButton, 0.61, 0.82, 0.1, 0.52)

	if E.Modern then
		HandleIconButton(_G.MerchantRepairAllButton, 0.61, 0.82, 0.1, 0.52)
		HandleIconButton(_G.MerchantSellAllJunkButton, 0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	else
		HandleIconButton(_G.MerchantRepairAllButton, 0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	end

	_G.MerchantGuildBankRepairButton:SetPoint('LEFT', _G.MerchantRepairAllButton, 'RIGHT', 5, 0)

	S:HandleNextPrevButton(_G.MerchantNextPageButton, nil, nil, true, true)
	S:HandleNextPrevButton(_G.MerchantPrevPageButton, nil, nil, true, true)
	_G.MerchantNextPageButton:ClearAllPoints() -- Monitor this
	_G.MerchantNextPageButton:Point('LEFT', _G.MerchantPageText, 'RIGHT', 100, 4)

	-- setup some hooks to fix placement
	if E.Modern then
		hooksecurefunc('MerchantFrame_UpdateRepairButtons', UpdateRepairButtons)
	else
		-- classic merchant has no quality borders
		hooksecurefunc('MerchantFrame_UpdateBuybackInfo', UpdateBuybackInfo)
	end

	hooksecurefunc('MerchantFrame_UpdateMerchantInfo', UpdateMerchantInfo)

	-- handle buyback count by the item button hooks
	_G.MerchantBuyBackItemItemButton.Count:SetScale(1)
	_G.MerchantBuyBackItemItemButton.Count:ClearAllPoints()
	_G.MerchantBuyBackItemItemButton.Count:Point('BOTTOMRIGHT', 0, 1)

	if E.Modern then
		hooksecurefunc(_G.MerchantBuyBackItemItemButton, 'SetItemButtonScale', SetItemButtonScale)
		hooksecurefunc(_G.MerchantBuyBackItemItemButton, 'SetItemButtonAnchorPoint', SetItemButtonAnchorPoint)
	end
end
