local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G


function S:Blizzard_PerksProgram()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame

	S:HandleButton(frame.ProductsFrame.PerksProgramFilter.FilterDropDownButton)
	frame.ProductsFrame.PerksProgramCurrencyFrame.Text:FontTemplate(nil, 30)
	S:HandleIcon(frame.ProductsFrame.PerksProgramCurrencyFrame.Icon)
	frame.ProductsFrame.PerksProgramCurrencyFrame.Icon:Size(30)

	frame.ProductsFrame.ProductsScrollBoxContainer.Border:Hide()
	frame.ProductsFrame.ProductsScrollBoxContainer:SetTemplate('Transparent')
	frame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:StripTextures()
	S:HandleTrimScrollBar(frame.ProductsFrame.ProductsScrollBoxContainer.ScrollBar, true)

	frame.ProductsFrame.PerksProgramProductDetailsContainerFrame.Border:Hide()
	frame.ProductsFrame.PerksProgramProductDetailsContainerFrame:SetTemplate('Transparent')

	S:HandleButton(frame.FooterFrame.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(frame.FooterFrame.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)

	S:HandleCheckBox(frame.FooterFrame.TogglePlayerPreview)
	S:HandleButton(frame.FooterFrame.RotateButtonContainer.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(frame.FooterFrame.RotateButtonContainer.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
