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

function S:Blizzard_PerksProgram()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame

	local products = frame.ProductsFrame
	if products then
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

		hooksecurefunc(products.ProductsScrollBoxContainer.ScrollBox, 'Update', function(self)
			self:ForEachFrame(function(button)
				if button.IsSkinned then return end

				local container = button.ContentsContainer
				if container then
					S:HandleIcon(container.Icon)
					ReplaceIconString(container.Price)
					hooksecurefunc(container.Price, 'SetText', ReplaceIconString)
				end
				button.IsSkinned = true
			end)
		end)
	end

	local footer = frame.FooterFrame
	if footer then
		S:HandleButton(footer.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(footer.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)

		S:HandleCheckBox(footer.TogglePlayerPreview)
		S:HandleButton(footer.RotateButtonContainer.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(footer.RotateButtonContainer.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
	end
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
