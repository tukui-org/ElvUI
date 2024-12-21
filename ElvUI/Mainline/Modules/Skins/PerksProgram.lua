local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function HandleSetButtons(button)
	if not button then return end

	if not button.Icon.backdrop then
		S:HandleIcon(button.Icon, true)
		S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
	end

	button.BackgroundTexture:SetAlpha(0)
	button.SelectedTexture:SetColorTexture(1, .8, 0, .25)
	button.SelectedTexture:SetInside()
	button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	button.HighlightTexture:SetInside()
end

local function HandleRewardButton(box)
	local container = box.ContentsContainer
	if not container then return end

	local icon = container.Icon
	if icon then
		S:HandleIcon(container.Icon)
	end

	local price = container.Price
	if price then
		S.ReplaceIconString(price)

		if not price.IsSkinned then
			price.IsSkinned = true

			hooksecurefunc(price, 'SetText', S.ReplaceIconString)
		end
	end
end

local function HandleRewards(box)
	if box then
		box:ForEachFrame(HandleRewardButton)
	end
end

local function HandleSortLabel(button)
	if button and button.Label then
		button.Label:FontTemplate()
	end
end

local function HandleNextPrev(button)
	S:HandleNextPrevButton(button)

	button:SetScript('OnMouseUp', nil)
	button:SetScript('OnMouseDown', nil)
end

local function PurchaseButton_EnterLeave(button, enter)
	local perks = _G.PerksProgramFrame
	local footer = perks and perks.FooterFrame
	local enabled = footer and footer.purchaseButtonEnabled
	local label = button:GetFontString()

	if enter then
		if enabled then
			label:SetTextColor(0.3, 1, 0.3, 1)
		else
			label:SetTextColor(1, 1, 1, 1)
		end
	elseif enabled then
		label:SetTextColor(0.3, 0.8, 0.3, 1)
	else
		label:SetTextColor(1, 0.8, 0, 1)
	end
end

local function PurchaseButton_OnEnter(button)
	PurchaseButton_EnterLeave(button, true)
end

local function PurchaseButton_OnLeave(button)
	PurchaseButton_EnterLeave(button)
end

local function GlowEmitterFactory_Toggle(frame, target, show)
	local perks = _G.PerksProgramFrame
	local footer = perks and perks.FooterFrame
	local button = footer and footer.PurchaseButton
	if not button or target ~= button then return end

	if show then
		frame:Hide(target) -- turn the glow off
	end

	PurchaseButton_EnterLeave(target, target:IsMouseOver()) -- update the text color instantly
end

local function GlowEmitterFactory_Show(frame, target)
	GlowEmitterFactory_Toggle(frame, target, true)
end

local function GlowEmitterFactory_Hide(frame, target)
	GlowEmitterFactory_Toggle(frame, target)
end

local function DetailsScrollBoxUpdate(box)
	box:ForEachFrame(HandleSetButtons)
end

local function HandleCheckbox(box)
	S:HandleCheckBox(box)

	local text = box.Text
	if text then
		text:FontTemplate()
	end
end

function S:Blizzard_PerksProgram() -- Trading Post
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame
	local products = frame.ProductsFrame

	if E.private.skins.parchmentRemoverEnable then
		frame.ThemeContainer:SetAlpha(0)
	end

	if products then
		S:HandleButton(products.PerksProgramFilter)

		local currency = products.PerksProgramCurrencyFrame
		if currency then
			S:HandleIcon(currency.Icon, true)
			currency.Icon:Size(30)
			currency.Text:FontTemplate(nil, 30)
		end

		local details = products.PerksProgramProductDetailsContainerFrame
		if details then
			details.Border:Hide()
			details:CreateBackdrop('Transparent')
			details.backdrop:SetFrameLevel(details.Border:GetFrameLevel() - 10)

			local container = details.SetDetailsScrollBoxContainer
			if container then
				S:HandleTrimScrollBar(container.ScrollBar)

				hooksecurefunc(container.ScrollBox, 'Update', DetailsScrollBoxUpdate)
			end

			local carousel = details.CarouselFrame
			if carousel and carousel.IncrementButton then
				HandleNextPrev(carousel.IncrementButton)
				HandleNextPrev(carousel.DecrementButton)
			end
		end

		local container = products.ProductsScrollBoxContainer
		if container then
			container:StripTextures()
			container:CreateBackdrop('Transparent')
			container.backdrop:SetFrameLevel(container.Border:GetFrameLevel() - 10)

			S:HandleTrimScrollBar(container.ScrollBar)

			local hold = container.PerksProgramHoldFrame
			if hold then
				hold:StripTextures()
				hold:CreateBackdrop('Transparent')
				hold.backdrop:SetInside(hold, 3, 3)
			end

			HandleSortLabel(container.NameSortButton)
			HandleSortLabel(container.PriceSortButton)

			hooksecurefunc(container.ScrollBox, 'Update', HandleRewards)
		end
	end

	local footer = frame.FooterFrame
	if footer then
		HandleCheckbox(footer.ToggleAttackAnimation)
		HandleCheckbox(footer.TogglePlayerPreview)
		HandleCheckbox(footer.ToggleMountSpecial)
		HandleCheckbox(footer.ToggleHideArmor)

		local purchase = footer.PurchaseButton
		if purchase then
			S:HandleButton(footer.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(footer.RefundButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(footer.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)

			purchase:HookScript('OnEnter', PurchaseButton_OnEnter)
			purchase:HookScript('OnLeave', PurchaseButton_OnLeave)

			-- handle the glow
			hooksecurefunc(_G.GlowEmitterFactory, 'Show', GlowEmitterFactory_Show)
			hooksecurefunc(_G.GlowEmitterFactory, 'Hide', GlowEmitterFactory_Hide)
		end

		local rotate = footer.RotateButtonContainer
		if rotate and rotate.RotateLeftButton then
			S:HandleButton(rotate.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(rotate.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
		end
	end
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
