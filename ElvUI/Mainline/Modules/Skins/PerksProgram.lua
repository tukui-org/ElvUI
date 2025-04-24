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

	if button.BackgroundTexture then
		button.BackgroundTexture:SetAlpha(0)
	end

	if button.HighlightTexture then
		button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
		button.HighlightTexture:SetInside()
	end
end

local function HandleCartToggleButton(button)
	if button.text then
		button:StripTextures()

		--button.texture:SetAtlas('Perks-ShoppingCart')
		--button.texture:SetOutside()

		button.text:SetText(button.itemInCart and '-' or '+')

		if button.itemInCart then
			button.text:SetTextColor(1, 0.3, 0.3)
		else
			button.text:SetTextColor(0.3, 1, 0.3)
		end
	end
end

local function HandleRewardButton(child)
	local container = child.ContentsContainer
	if not container then return end

	local icon = container.Icon
	if icon then
		S:HandleIcon(container.Icon)

		container.IconMask:Hide()
	end

	local priceIcon = container.PriceIcon
	if priceIcon then
		S:HandleIcon(priceIcon)
	end

	local cartButton = container.CartToggleButton
	if cartButton and not cartButton.text then
		S:HandleButton(cartButton, nil, nil, nil, true, nil, nil, nil, true)

		cartButton.text = cartButton:CreateFontString(nil, 'ARTWORK')
		cartButton.text:FontTemplate(nil, 30, 'OUTLINE')
		cartButton.text:Point('CENTER')
		cartButton.text:SetTextColor(0.3, 1, 0.3)

		--cartButton.texture = cartButton:CreateTexture(nil, 'ARTWORK')
		--cartButton.texture:SetVertexColor(1, 1, 1, 0.8)

		HandleCartToggleButton(cartButton)

		hooksecurefunc(cartButton, 'UpdateCartState', HandleCartToggleButton)
	end
end

local function HandleRewards(frame)
	frame:ForEachFrame(HandleRewardButton)
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

local function DetailsScrollBoxUpdate(frame)
	frame:ForEachFrame(HandleSetButtons)
end

local function HandleShoppingCardButtons(button)
	if not button then return end

	if button.RemoveFromCartItemButton then
		S:HandleCloseButton(button.RemoveFromCartItemButton.RemoveFromListButton)
	end

	if not button.bgSetTexture then
		button.bgSetTexture = button:CreateTexture(nil, 'BACKGROUND')
		button.bgSetTexture:SetTexture(E.media.blankTex)
		button.bgSetTexture:SetOutside(button, 10, 4)
	end

	if button.BackgroundTexture then
		if not button.BackgroundTexture.backdrop then
			button.BackgroundTexture:StripTextures()
			button.BackgroundTexture:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)
		end

		local r, g, b = E:GetItemQualityColor(button.elementData and button.elementData.itemQuality)
		button.bgSetTexture:SetVertexColor(r, g, b, button.elementData and button.elementData.isSetItem and 0.2 or 0)
	else
		button.bgSetTexture:SetVertexColor(0, 0, 0, 0.25)
	end

	if button.TopBraceTexture then
		button.TopBraceTexture:StripTextures()
	end

	if button.BottomBraceTexture then
		button.BottomBraceTexture:StripTextures()
	end

	if button.HighlightTexture then
		button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
	end

	local priceIcon = button.PriceIcon
	if priceIcon then
		S:HandleIcon(priceIcon)
	end
end

local function ShoppingCartScrollBoxUpdate(frame)
	frame:ForEachFrame(HandleShoppingCardButtons)
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

		if products.PerksProgramFilter.ResetButton then
			S:HandleCloseButton(products.PerksProgramFilter.ResetButton)
		end

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
			details.backdrop:OffsetFrameLevel(-10, details.Border)

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
			container.backdrop:OffsetFrameLevel(-10, container.Border)

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

		local shoppingCart = products.PerksProgramShoppingCartFrame
		if shoppingCart then
			shoppingCart:StripTextures()
			shoppingCart:CreateBackdrop('Transparent')
			S:HandleCloseButton(shoppingCart.CloseButton)
			shoppingCart.CloseButton:OffsetFrameLevel(1, shoppingCart.backdrop)

			S:HandleButton(shoppingCart.PurchaseCartButton, nil, nil, nil, true, nil, nil, nil, true)

			S:HandleButton(shoppingCart.ClearCartButton, nil, nil, nil, true, nil, nil, nil, true)

			shoppingCart.ClearCartButton.texture = shoppingCart.ClearCartButton:CreateTexture(nil, 'ARTWORK')
			shoppingCart.ClearCartButton.texture:SetAtlas('Perks-ShoppingCart')
			shoppingCart.ClearCartButton.texture:SetInside(nil, 8, 8)

			shoppingCart.ClearCartButton.text = shoppingCart.ClearCartButton:CreateFontString(nil, 'ARTWORK')
			shoppingCart.ClearCartButton.text:FontTemplate(nil, 40, 'OUTLINE')
			shoppingCart.ClearCartButton.text:Point('CENTER')
			shoppingCart.ClearCartButton.text:SetTextColor(1, 0.3, 0.3)
			shoppingCart.ClearCartButton.text:SetText('/')

			local itemList = shoppingCart.ItemList
			S:HandleTrimScrollBar(itemList.ScrollBar)

			hooksecurefunc(itemList.ScrollBox, 'Update', ShoppingCartScrollBoxUpdate)
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
			S:HandleButton(footer.ViewCartButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(footer.AddToCartButton, nil, nil, nil, true, nil, nil, nil, true)
			S:HandleButton(footer.RemoveFromCartButton, nil, nil, nil, true, nil, nil, nil, true)

			local viewCart = footer.ViewCartButton
			if viewCart then
				if viewCart.ItemCountBG then
					viewCart.ItemCountBG:StripTextures()
				end

				if viewCart.ItemCountText then
					viewCart.ItemCountText:ClearAllPoints()
					viewCart.ItemCountText:Point('BOTTOMLEFT', 4, 2)
				end

				viewCart.texture = viewCart:CreateTexture(nil, 'ARTWORK')
				viewCart.texture:SetAtlas('Perks-ShoppingCart')
				viewCart.texture:SetInside(nil, 8, 8)
			end

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
