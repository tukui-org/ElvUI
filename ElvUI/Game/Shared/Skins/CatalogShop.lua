local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
local strfind = strfind

S:AddCallbackForAddon('Blizzard_CatalogShop', nil, nil, nil, nil, nil, 'catalogShop')

function S:Blizzard_CatalogShop()
	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.CatalogShopTooltip)
	end

	local CatalogShopFrame = _G.CatalogShopFrame
	CatalogShopFrame:StripTextures()
	CatalogShopFrame:SetTemplate('Transparent')

	local CloseButton = CatalogShopFrame.CloseButton
	S:HandleCloseButton(CloseButton)

	if not E.Modern then
		CloseButton:SetFrameLevel(510) -- classic UIPanelCloseButton has no frame level, keep it above the title backdrop

		if CatalogShopFrame.BorderTexture then
			CatalogShopFrame.BorderTexture:Hide()
		end

		if CatalogShopFrame.RightBorder then
			CatalogShopFrame.RightBorder:Hide()
		end

		if CatalogShopFrame.BackgroundContainer then
			CatalogShopFrame.BackgroundContainer:Hide()
		end
	end

	local TitleContainer = CatalogShopFrame.TitleContainer
	TitleContainer:CreateBackdrop()
	TitleContainer.backdrop:ClearAllPoints()
	TitleContainer.backdrop:Point('TOPLEFT', CatalogShopFrame, 'TOPLEFT')
	TitleContainer.backdrop:Point('TOPRIGHT', CatalogShopFrame, 'TOPRIGHT', 0, -30)
	TitleContainer.backdrop:Height(TitleContainer:GetHeight() + 3)

	S:HandleEditBox(CatalogShopFrame.HeaderFrame.SearchBox)

	local ProductsContainer = CatalogShopFrame.ProductContainerFrame.ProductsScrollBoxContainer
	S:HandleTrimScrollBar(ProductsContainer.ScrollBar)

	local ProductsScrollBox = ProductsContainer.ScrollBox
	if ProductsScrollBox and E.private.skins.parchmentRemoverEnable then
		for _, card in next, { ProductsScrollBox:GetChildren() } do
			card:SetTemplate('Transparent')

			if card.Border then
				card.Border:Hide()
			end

			for _, region in next, { card:GetRegions() } do
				local textureName = region:IsObjectType('Texture') and region:GetName()
				if textureName then
					region:SetAlpha(strfind(textureName, 'Highlight') and 0.1 or 0)
				end
			end
		end
	end

	local DetailsFrame = CatalogShopFrame.CatalogShopDetailsFrame
	if DetailsFrame then
		DetailsFrame:SetTemplate('Transparent')

		if DetailsFrame.Border then
			DetailsFrame.Border:Hide()
		end

		for _, button in next, { DetailsFrame.ButtonContainer:GetChildren() } do
			if button:IsObjectType('Button') then
				S:HandleButton(button, nil, nil, nil, true)
			end
		end
	end

	local ProductDetails = CatalogShopFrame.ProductDetailsContainerFrame
	S:HandleButton(ProductDetails.BackButton, nil, nil, nil, true)
	S:HandleTrimScrollBar(ProductDetails.DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBar)
end
