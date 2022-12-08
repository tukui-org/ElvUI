local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:MerchantFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant) then return end

	S:HandlePortraitFrame(_G.MerchantFrame)
	_G.MerchantFrame:Width(360)

	_G.MerchantExtraCurrencyInset:StripTextures()
	_G.MerchantExtraCurrencyBg:StripTextures()

	_G.MerchantMoneyBg:StripTextures()
	_G.MerchantMoneyInset:StripTextures()

	S:HandleDropDownBox(_G.MerchantFrameLootFilter)

	-- Center the columns on the frame
	_G.MerchantItem1:Point('TOPLEFT', _G.MerchantFrame, 'TOPLEFT', 22, -65)

	-- Skin tabs
	for i = 1, 2 do
		S:HandleTab(_G['MerchantFrameTab'..i])
	end

	-- Reposition tabs
	_G.MerchantFrameTab1:ClearAllPoints()
	_G.MerchantFrameTab2:ClearAllPoints()
	_G.MerchantFrameTab1:Point('TOPLEFT', _G.MerchantFrame, 'BOTTOMLEFT', -3, 0)
	_G.MerchantFrameTab2:Point('TOPLEFT', _G.MerchantFrameTab1, 'TOPRIGHT', -5, 0)

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
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:ClearAllPoints()
		icon:Point('TOPLEFT', 1, -1)
		icon:Point('BOTTOMRIGHT', -1, 1)

		S:HandleIconBorder(button.IconBorder)
	end

	hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
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
	end)

	-- Skin buyback item frame + icon
	_G.MerchantBuyBackItem:Point('TOPLEFT', _G.MerchantItem10, 'BOTTOMLEFT', 0, -45)
	_G.MerchantBuyBackItem:StripTextures(true)
	_G.MerchantBuyBackItem:CreateBackdrop('Transparent')
	_G.MerchantBuyBackItem.backdrop:Point('TOPLEFT', -6, 6)
	_G.MerchantBuyBackItem.backdrop:Point('BOTTOMRIGHT', 6, -6)

	_G.MerchantBuyBackItemItemButton:StripTextures()
	_G.MerchantBuyBackItemItemButton:StyleButton()
	_G.MerchantBuyBackItemItemButton:SetTemplate(nil, true)

	_G.MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
	_G.MerchantBuyBackItemItemButtonIconTexture:Point('TOPLEFT', 1, -1)
	_G.MerchantBuyBackItemItemButtonIconTexture:Point('BOTTOMRIGHT', -1, 1)

	S:HandleButton(_G.MerchantRepairItemButton)
	_G.MerchantRepairItemButton:StyleButton()
	_G.MerchantRepairItemButton:GetRegions():SetTexCoord(0.04, 0.24, 0.06, 0.5)
	_G.MerchantRepairItemButton:GetRegions():SetInside()

	S:HandleIconBorder(_G.MerchantBuyBackItemItemButton.IconBorder)

	S:HandleButton(_G.MerchantGuildBankRepairButton)
	_G.MerchantGuildBankRepairButton:StyleButton()
	_G.MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	_G.MerchantGuildBankRepairButtonIcon:SetInside()

	S:HandleButton(_G.MerchantRepairAllButton)
	_G.MerchantRepairAllIcon:StyleButton()
	_G.MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	_G.MerchantRepairAllIcon:SetInside()

	S:HandleNextPrevButton(_G.MerchantNextPageButton, nil, nil, true, true)
	S:HandleNextPrevButton(_G.MerchantPrevPageButton, nil, nil, true, true)
	_G.MerchantNextPageButton:ClearAllPoints() -- Monitor this
	_G.MerchantNextPageButton:Point('LEFT', _G.MerchantPageText, 'RIGHT', 100, 4)
end

S:AddCallback('MerchantFrame')
