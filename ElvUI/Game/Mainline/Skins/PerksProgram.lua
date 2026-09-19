local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function HandleSetButtons(button)
	if not button.Icon.backdrop then
		S:HandleIcon(button.Icon, true)
		S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
	end

	button.BackgroundTexture:SetAlpha(0)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	button.HighlightTexture:SetInside()
end

local function HandleCartToggleButton(button)
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

local function HandleRewardButton(child)
	local container = child.ContentsContainer -- the divider rows have none
	if not container then return end

	S:HandleIcon(container.Icon)
	container.IconMask:Hide()
	S:HandleIcon(container.PriceIcon)

	local cartButton = container.CartToggleButton
	if not cartButton.text then
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

local function PurchaseButton_EnterLeave(button, enter)
	local enabled = button:IsEnabled()
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
	if target ~= _G.PerksProgramFrame.FooterFrame.PurchaseButton then return end

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

local function HandleShoppingCardButtons(button) -- set headers, cart items and set items share the list
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

		local r, g, b = E:GetItemQualityColor(button.elementData.itemQuality)
		button.bgSetTexture:SetVertexColor(r, g, b, button.elementData.isSetItem and 0.2 or 0)
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
	box.Text:FontTemplate()
end

function S:Blizzard_PerksProgram() -- Trading Post
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.perks) then return end

	local frame = _G.PerksProgramFrame
	local products = frame.ProductsFrame

	if E.private.skins.parchmentRemoverEnable then
		frame.ThemeContainer:SetAlpha(0)
	end

	S:HandleButton(products.PerksProgramFilter)
	S:HandleCloseButton(products.PerksProgramFilter.ResetButton)

	local currency = products.PerksProgramCurrencyFrame
	S:HandleIcon(currency.Icon, true)
	currency.Icon:Size(30)
	currency.Text:FontTemplate(nil, 30)

	local details = products.PerksProgramProductDetailsContainerFrame
	details.Border:Hide()
	details:CreateBackdrop('Transparent')
	details.backdrop:OffsetFrameLevel(-10, details.Border)

	S:HandleTrimScrollBar(details.SetDetailsScrollBoxContainer.ScrollBar)
	hooksecurefunc(details.SetDetailsScrollBoxContainer.ScrollBox, 'Update', DetailsScrollBoxUpdate)

	local container = products.ProductsScrollBoxContainer
	container:StripTextures()
	container:CreateBackdrop('Transparent')
	container.backdrop:OffsetFrameLevel(-10, container.Border)

	S:HandleTrimScrollBar(container.ScrollBar)

	local hold = container.PerksProgramHoldFrame
	hold:StripTextures()
	hold:CreateBackdrop('Transparent')
	hold.backdrop:SetInside(hold, 3, 3)

	container.NameSortButton.Label:FontTemplate()
	container.PriceSortButton.Label:FontTemplate()

	hooksecurefunc(container.ScrollBox, 'Update', HandleRewards)

	local shoppingCart = products.PerksProgramShoppingCartFrame
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

	S:HandleTrimScrollBar(shoppingCart.ItemList.ScrollBar)
	hooksecurefunc(shoppingCart.ItemList.ScrollBox, 'Update', ShoppingCartScrollBoxUpdate)

	local footer = frame.FooterFrame
	HandleCheckbox(footer.ToggleAttackAnimation)
	HandleCheckbox(footer.TogglePlayerPreview)
	HandleCheckbox(footer.ToggleMountSpecial)
	HandleCheckbox(footer.ToggleHideArmor)

	S:HandleButton(footer.LeaveButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.RefundButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.PurchaseButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.ViewCartButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.AddToCartButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.RemoveFromCartButton, nil, nil, nil, true, nil, nil, nil, true)

	local viewCart = footer.ViewCartButton
	viewCart.ItemCountBG:StripTextures()
	viewCart.ItemCountText:ClearAllPoints()
	viewCart.ItemCountText:Point('BOTTOMLEFT', 4, 2)

	viewCart.texture = viewCart:CreateTexture(nil, 'ARTWORK')
	viewCart.texture:SetAtlas('Perks-ShoppingCart')
	viewCart.texture:SetInside(nil, 8, 8)

	footer.PurchaseButton:HookScript('OnEnter', PurchaseButton_OnEnter)
	footer.PurchaseButton:HookScript('OnLeave', PurchaseButton_OnLeave)

	-- handle the glow
	hooksecurefunc(_G.GlowEmitterFactory, 'Show', GlowEmitterFactory_Show)
	hooksecurefunc(_G.GlowEmitterFactory, 'Hide', GlowEmitterFactory_Hide)

	S:HandleButton(footer.RotateButtonContainer.RotateLeftButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(footer.RotateButtonContainer.RotateRightButton, nil, nil, nil, true, nil, nil, nil, true)
end

S:AddCallbackForAddon('Blizzard_PerksProgram')
