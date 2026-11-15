local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next

S:AddCallbackForAddon('Blizzard_CatalogShop', nil, nil, nil, nil, nil, 'catalogShop')

function S:Blizzard_CatalogShop()
	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.CatalogShopTooltip)
	end

	local CatalogShopFrame = _G.CatalogShopFrame
	
	CatalogShopFrame:StripTextures()
	CatalogShopFrame:SetTemplate('Transparent')

	if not E.Modern then
		if CatalogShopFrame.BorderTexture then CatalogShopFrame.BorderTexture:Hide() end
		if CatalogShopFrame.RightBorder then CatalogShopFrame.RightBorder:Hide() end
		if CatalogShopFrame.BackgroundContainer then CatalogShopFrame.BackgroundContainer:Hide() end
	end

	local CloseButton = CatalogShopFrame.CloseButton
	S:HandleCloseButton(CloseButton)
	if not E.Modern then CloseButton:SetFrameLevel(510) end

	local TitleContainer = CatalogShopFrame.TitleContainer
	TitleContainer:CreateBackdrop()
	TitleContainer.backdrop:ClearAllPoints()
	TitleContainer.backdrop:Point('TOPLEFT', CatalogShopFrame, 'TOPLEFT')
	TitleContainer.backdrop:Point('TOPRIGHT', CatalogShopFrame, 'TOPRIGHT', 0, -30)
	TitleContainer.backdrop:Height(TitleContainer:GetHeight() + 3)

	S:HandleEditBox(CatalogShopFrame.HeaderFrame.SearchBox)
	
	local ScrollBar = CatalogShopFrame.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBar
	S:HandleTrimScrollBar(ScrollBar)

	local ScrollBox = CatalogShopFrame.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBox
	if ScrollBox then
		for _, card in next, { ScrollBox:GetChildren() } do
			if card.Border then card.Border:Hide() end
			
			card:SetTemplate('Transparent') 
			
			for _, region in next, { card:GetRegions() } do
				if region:IsObjectType('Texture') then
					if region:GetName() and region:GetName():find("Highlight") then
						region:SetAlpha(0.1)
					else
						region:SetAlpha(0)
					end
				end
			end
		end
	end

	local DetailsFrame = CatalogShopFrame.CatalogShopDetailsFrame
	if DetailsFrame then
		if DetailsFrame.Border then DetailsFrame.Border:Hide() end
		DetailsFrame:SetTemplate('Transparent')
		
		for _, region in next, { DetailsFrame:GetRegions() } do
			if region:IsObjectType('Texture') then region:SetAlpha(0) end
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
