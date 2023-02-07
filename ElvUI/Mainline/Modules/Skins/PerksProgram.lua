local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub
local hooksecurefunc = hooksecurefunc

local function ReplaceIconString(frame, text)
	if not text then text = frame:GetText() end
	if not text or text == '' then return end

	local newText, count = gsub(text, '|T(%d+):24:24[^|]*|t', ' |T%1:16:16:0:0:64:64:5:59:5:59|t')
	if count > 0 then frame:SetFormattedText('%s', newText) end
end

local function HandleRewardButton(button)
	local container = button.ContentsContainer
	if container and not container.isSkinned then
		container.isSkinned = true

		S:HandleIcon(container.Icon)
		ReplaceIconString(container.Price)
		hooksecurefunc(container.Price, 'SetText', ReplaceIconString)
	end
end

function S:Blizzard_PerksProgram()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame

	local productsFrame = frame.ProductsFrame
	if productsFrame then
		S:HandleButton(productsFrame.PerksProgramFilter.FilterDropDownButton)
		productsFrame.PerksProgramCurrencyFrame.Text:FontTemplate(nil, 30)
		S:HandleIcon(productsFrame.PerksProgramCurrencyFrame.Icon)
		productsFrame.PerksProgramCurrencyFrame.Icon:Size(30)

		productsFrame.PerksProgramProductDetailsContainerFrame.Border:Hide()
		productsFrame.PerksProgramProductDetailsContainerFrame:SetTemplate('Transparent')

		local productsContainer = productsFrame.ProductsScrollBoxContainer
		productsContainer:StripTextures()
		productsContainer:SetTemplate('Transparent')
		S:HandleTrimScrollBar(productsFrame.ProductsScrollBoxContainer.ScrollBar, true)
		productsContainer.PerksProgramHoldFrame:StripTextures()
		productsContainer.PerksProgramHoldFrame:CreateBackdrop('Transparent')
		productsContainer.PerksProgramHoldFrame.backdrop:SetInside(3, 3)

		hooksecurefunc(productsContainer.ScrollBox, 'Update', function(container)
			container:ForEachFrame(HandleRewardButton)
		end)
	end

	local footer = frame.FooterFrame
	if footer then
		S:HandleButton(footer.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(footer.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(footer.RefundButton, nil, nil, nil, true, nil, nil, nil, true)

		if footer.RotateButtonContainer then
			S:HandleButton(footer.RotateButtonContainer.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(footer.RotateButtonContainer.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
		end

		S:HandleCheckBox(footer.TogglePlayerPreview)
		S:HandleCheckBox(footer.ToggleHideArmor)
	end
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
