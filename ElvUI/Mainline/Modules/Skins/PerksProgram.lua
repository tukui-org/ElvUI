local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_PerksProgram()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame
	local products = frame.ProductsFrame
	S:HandleButton(products.PerksProgramFilter.FilterDropDownButton)
	products.PerksProgramCurrencyFrame.Text:FontTemplate(nil, 30)
	S:HandleIcon(products.PerksProgramCurrencyFrame.Icon)
	products.PerksProgramCurrencyFrame.Icon:Size(30)

	products.ProductsScrollBoxContainer.Border:Hide()
	products.ProductsScrollBoxContainer:SetTemplate('Transparent')
	products.ProductsScrollBoxContainer.PerksProgramHoldFrame:StripTextures()
	S:HandleTrimScrollBar(products.ProductsScrollBoxContainer.ScrollBar, true)

	products.PerksProgramProductDetailsContainerFrame.Border:Hide()
	products.PerksProgramProductDetailsContainerFrame:SetTemplate('Transparent')

	local footer = frame.FooterFrame
	S:HandleButton(footer.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)

	S:HandleCheckBox(footer.TogglePlayerPreview)
	S:HandleButton(footer.RotateButtonContainer.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.RotateButtonContainer.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
