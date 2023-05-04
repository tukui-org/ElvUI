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

local function HandleRewardButton(box)
	local container = box.ContentsContainer
	if container and not container.isSkinned then
		container.isSkinned = true

		S:HandleIcon(container.Icon)
		ReplaceIconString(container.Price)
		hooksecurefunc(container.Price, 'SetText', ReplaceIconString)
	end
end

local function HandleRewards(box)
	if box then
		box:ForEachFrame(HandleRewardButton)
	end
end

-- Same as Barber Skin
local function HandleButton(button)
	S:HandleNextPrevButton(button)

	button:SetScript('OnMouseUp', nil)
	button:SetScript('OnMouseDown', nil)
end

function S:Blizzard_PerksProgram()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame
	local products = frame.ProductsFrame
	if products then
		S:HandleButton(products.PerksProgramFilter.FilterDropDownButton)

		local currency = products.PerksProgramCurrencyFrame
		if currency then
			S:HandleIcon(currency.Icon)
			currency.Icon:Size(30)
			currency.Text:FontTemplate(nil, 30)
		end

		local details = products.PerksProgramProductDetailsContainerFrame
		if details then
			details.Border:Hide()
			details:SetTemplate('Transparent')

			local carousel = details.CarouselFrame
			if carousel then
				HandleButton(carousel.IncrementButton)
				HandleButton(carousel.DecrementButton)
			end
		end

		local container = products.ProductsScrollBoxContainer
		if container then
			container:StripTextures()
			container:SetTemplate('Transparent')
			S:HandleTrimScrollBar(container.ScrollBar)

			container.PerksProgramHoldFrame:StripTextures()
			container.PerksProgramHoldFrame:CreateBackdrop('Transparent')
			container.PerksProgramHoldFrame.backdrop:SetInside(3, 3)

			hooksecurefunc(container.ScrollBox, 'Update', HandleRewards)
		end
	end

	local footer = frame.FooterFrame
	if footer then
		S:HandleCheckBox(footer.TogglePlayerPreview)
		S:HandleCheckBox(footer.ToggleHideArmor)

		S:HandleButton(footer.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(footer.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(footer.RefundButton, nil, nil, nil, true, nil, nil, nil, true)

		local rotate = footer.RotateButtonContainer
		if rotate then
			S:HandleButton(rotate.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(rotate.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
		end
	end
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
