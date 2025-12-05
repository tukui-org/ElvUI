local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next

function S:Blizzard_CatalogShop()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.catalogShop) then return end

	if E.private.skins.blizzard.tooltip and _G.CatalogShopTooltip then
		TT:SetStyle(_G.CatalogShopTooltip)
	end

	local CatalogShopFrame = _G.CatalogShopFrame
	if CatalogShopFrame then
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

		local ProductDetails = CatalogShopFrame.ProductDetailsContainerFrame
		if ProductDetails then
			local BackButton = ProductDetails.BackButton
			if BackButton then
				S:HandleButton(BackButton, nil, nil, nil, true)
			end

			local ProductContainer = ProductDetails.DetailsProductContainerFrame
			local ProductScrollContainer = ProductContainer.ProductsScrollBoxContainer
			local ProductScrollBar = ProductScrollContainer and ProductScrollContainer.ScrollBar
			if ProductScrollBar then
				S:HandleTrimScrollBar(ProductScrollBar)
			end
		end
	end
end

S:AddCallback('Blizzard_CatalogShop')
