local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next

function S:Blizzard_CatalogShop()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.catalogShop) then return end

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.CatalogShopTooltip)
	end

	local CatalogShopFrame = _G.CatalogShopFrame
	CatalogShopFrame:StripTextures()
	CatalogShopFrame:SetTemplate('Transparent')
	S:HandleCloseButton(CatalogShopFrame.CloseButton)

	local TitleContainer = CatalogShopFrame.TitleContainer
	TitleContainer:CreateBackdrop()
	TitleContainer.backdrop:ClearAllPoints()
	TitleContainer.backdrop:Point('TOPLEFT', CatalogShopFrame, 'TOPLEFT')
	TitleContainer.backdrop:Point('TOPRIGHT', CatalogShopFrame, 'TOPRIGHT', 0, -30)
	TitleContainer.backdrop:Height(TitleContainer:GetHeight() + 3)

	S:HandleEditBox(CatalogShopFrame.HeaderFrame.SearchBox)
	S:HandleTrimScrollBar(CatalogShopFrame.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBar)

	local DetailsFrame = CatalogShopFrame.CatalogShopDetailsFrame
	DetailsFrame.Border:Hide()
	DetailsFrame:SetTemplate('Transparent')

	for _, button in next, { DetailsFrame.ButtonContainer:GetChildren() } do
		if button:IsObjectType('Button') then
			S:HandleButton(button, nil, nil, nil, true)
		end
	end

	local ProductDetails = CatalogShopFrame.ProductDetailsContainerFrame
	S:HandleButton(ProductDetails.BackButton, nil, nil, nil, true)
	S:HandleTrimScrollBar(ProductDetails.DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBar)
end

S:AddCallback('Blizzard_CatalogShop')
