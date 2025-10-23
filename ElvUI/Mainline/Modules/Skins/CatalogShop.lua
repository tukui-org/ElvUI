local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local next = next

function S:Blizzard_CatalogShop()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.catalogShop) then return end

	local CatalogShopFrame = _G.CatalogShopFrame
	if not CatalogShopFrame then
		return
	end

	CatalogShopFrame:StripTextures()
	CatalogShopFrame:SetTemplate('Transparent')

	local CloseButton = CatalogShopFrame.CloseButton
	if CloseButton then
		S:HandleCloseButton(CatalogShopFrame.CloseButton)
	end

	local TitleContainer = CatalogShopFrame.TitleContainer
	if TitleContainer then
		TitleContainer:CreateBackdrop()
		TitleContainer.backdrop:ClearAllPoints()
		TitleContainer.backdrop:Point('TOPLEFT', CatalogShopFrame, 'TOPLEFT')
		TitleContainer.backdrop:Point('TOPRIGHT', CatalogShopFrame, 'TOPRIGHT', 0, -30)
		TitleContainer.backdrop:Height(TitleContainer:GetHeight() + 3)
	end

	local HeaderFrame = CatalogShopFrame.HeaderFrame
	if HeaderFrame then
		local SearchBox = HeaderFrame.SearchBox
		if SearchBox then
			S:HandleEditBox(SearchBox)
		end
	end

	local ProductContainerFrame = CatalogShopFrame.ProductContainerFrame
	if ProductContainerFrame and ProductContainerFrame.ProductsScrollBoxContainer then
		local ScrollBar = ProductContainerFrame.ProductsScrollBoxContainer.ScrollBar
		if ScrollBar then
			S:HandleTrimScrollBar(ScrollBar)
		end
	end

	local CatalogShopDetailsFrame = CatalogShopFrame.CatalogShopDetailsFrame
	if CatalogShopDetailsFrame then
		CatalogShopDetailsFrame.Border:Hide()
		CatalogShopDetailsFrame:SetTemplate('Transparent')

		local ButtonContainer = CatalogShopDetailsFrame.ButtonContainer
		if ButtonContainer then
			for _, button in next, { ButtonContainer:GetChildren() } do
				if button and button.IsObjectType and button:IsObjectType('Button') then
					S:HandleButton(button, nil, nil, nil, true)
				end
			end
		end
	end

	local ProductDetailsContainerFrame = CatalogShopFrame.ProductDetailsContainerFrame
	if ProductDetailsContainerFrame then
		local BackButton = ProductDetailsContainerFrame.BackButton
		if BackButton then
			S:HandleButton(BackButton, nil, nil, nil, true)
		end

		local DetailsProductContainerFrame = ProductDetailsContainerFrame.DetailsProductContainerFrame
		if DetailsProductContainerFrame and DetailsProductContainerFrame.ProductsScrollBoxContainer then
			local ScrollBar = DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBar
			if ScrollBar then
				S:HandleTrimScrollBar(ScrollBar)
			end
		end
	end
end

S:AddCallback('Blizzard_CatalogShop')
