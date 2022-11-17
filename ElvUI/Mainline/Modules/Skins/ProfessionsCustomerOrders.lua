local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- Custom Orders (Credits: siweia - NDUI)

local function RefreshFlyoutButtons(box)
	for _, button in next, { box.ScrollTarget:GetChildren() } do
		if button.IconBorder and not button.IsSkinned then
			S:HandleIcon(button.icon, true)
			S:HandleIconBorder(button.IconBorder, button.icon.backdrop)

			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.IsSkinned = true
		end
	end
end

local function HideCategoryButton(button)
	--button:SetTemplate('Transparnt')
	button.NormalTexture:Hide()
	button.SelectedTexture:SetColorTexture(0, .6, 1, .3)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
end

local function HandleListIcon(frame)
	local builder = frame.tableBuilder
	if not builder then return end

	for i = 1, 22 do
		local row = builder.rows[i]
		if row then
			local cell = row.cells and row.cells[1]
			if cell and cell.Icon then
				if not cell.isSkinned then
					S:HandleIcon(cell.Icon, true)

					if cell.IconBorder then
						cell.IconBorder:Hide()
					end

					cell.isSkinned = true
				end

				cell.Icon.backdrop:SetShown(cell.Icon:IsShown())
			end
		end
	end
end

local function HandleListHeader(headerContainer)
	local maxHeaders = headerContainer:GetNumChildren()

	for i, header in next, { headerContainer:GetChildren() } do
		if not header.isSkinned then
			header:DisableDrawLayer('BACKGROUND')
			header:CreateBackdrop('Transparent')

			local highlight = header:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, .1)
			highlight:SetAllPoints(header.backdrop)

			header.isSkinned = true
		end

		if header.backdrop then
			header.backdrop:SetPoint('BOTTOMRIGHT', i < maxHeaders and -5 or 0, -2)
		end
	end
end

local function HandleMoneyInput(box)
	S:HandleEditBox(box)

	box.backdrop:SetPoint('TOPLEFT', 0, -3)
	box.backdrop:SetPoint('BOTTOMRIGHT', 0, 3)
end

local function HandleBrowseOrders(frame)
	local headerContainer = frame.RecipeList and frame.RecipeList.HeaderContainer
	if headerContainer then
		HandleListHeader(headerContainer)
	end
end

local function FormInit(form)
	for slot in form.reagentSlotPool:EnumerateActive() do
		local button = slot and slot.Button
		if button and not button.IsSkinned then
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			S:HandleIcon(button.Icon, true)
			S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)

			local highlight = button:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, .25)
			highlight:SetInside(button.bg)

			if button.SlotBackground then
				button.SlotBackground:Hide()
			end

			button.IsSkinned = true
		end
	end
end

local function HandleFlyouts(flyout)
	if not flyout.isSkinned then
		flyout:StripTextures()
		flyout:SetTemplate('Transparent')

		S:HandleCheckBox(flyout.HideUnownedCheckBox)

		hooksecurefunc(flyout.ScrollBox, 'Update', RefreshFlyoutButtons)

		flyout.isSkinned = true
	end
end

local flyoutFrame
local function OpenItemFlyout(frame)
	if flyoutFrame then return end

	for _, child in next, { frame:GetChildren() } do
		if child.HideUnownedCheckBox then
			flyoutFrame = child

			HandleFlyouts(flyoutFrame)

			break
		end
	end
end

local function BrowseOrdersUpdate(box)
	for _, child in next, { box.ScrollTarget:GetChildren() } do
		if child.Text and not child.IsSkinned then
			HideCategoryButton(child)

			hooksecurefunc(child, 'Init', HideCategoryButton)

			child.IsSkinned = true
		end
	end
end

function S:Blizzard_ProfessionsCustomerOrders()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local frame = _G.ProfessionsCustomerOrdersFrame
	S:HandleFrame(frame)

	for _, tab in next, frame.Tabs do
		S:HandleTab(tab)
	end

	-- Item flyout
	if _G.OpenProfessionsItemFlyout then
		hooksecurefunc('OpenProfessionsItemFlyout', OpenItemFlyout)
	end

	frame.MoneyFrameBorder:StripTextures()
	frame.MoneyFrameBorder:SetTemplate('Transparent')
	frame.MoneyFrameInset:StripTextures()

	local browseOrders = frame.BrowseOrders
	frame.BrowseOrders.CategoryList:StripTextures()
	S:HandleTrimScrollBar(browseOrders.CategoryList.ScrollBar, true)

	local search = browseOrders.SearchBar
	search.FavoritesSearchButton:Size(22)
	S:HandleButton(search.FavoritesSearchButton)
	S:HandleEditBox(search.SearchBox)
	S:HandleButton(search.SearchButton)

	local filter = search.FilterButton
	S:HandleCloseButton(filter.ClearFiltersButton)
	S:HandleButton(filter)

	hooksecurefunc(browseOrders.CategoryList.ScrollBox, 'Update', BrowseOrdersUpdate)

	local recipeList = frame.BrowseOrders.RecipeList
	recipeList:StripTextures()
	recipeList.ScrollBox:CreateBackdrop('Transparent')
	recipeList.ScrollBox.backdrop:SetInside()
	S:HandleTrimScrollBar(recipeList.ScrollBar, true)

	hooksecurefunc(frame.BrowseOrders, 'SetupTable', HandleBrowseOrders)
	hooksecurefunc(frame.BrowseOrders, 'StartSearch', HandleListIcon)

	-- Form
	S:HandleButton(frame.Form.BackButton)
	S:HandleCheckBox(frame.Form.TrackRecipeCheckBox.Checkbox)
	frame.Form.RecipeHeader:Hide()
	frame.Form.RecipeHeader:CreateBackdrop('Transparent')
	frame.Form.LeftPanelBackground:StripTextures()
	frame.Form.RightPanelBackground:StripTextures()

	local itemButton = frame.Form.OutputIcon
	itemButton.CircleMask:Hide()
	S:HandleIcon(itemButton.Icon, true)
	S:HandleIconBorder(itemButton.IconBorder, itemButton.Icon.backdrop)

	local itemHighlight = itemButton:GetHighlightTexture()
	itemHighlight:SetColorTexture(1, 1, 1, .25)
	itemHighlight:SetInside(itemButton.backdrop)

	S:HandleEditBox(frame.Form.OrderRecipientTarget)
	frame.Form.OrderRecipientTarget.backdrop:SetPoint('TOPLEFT', -8, -2)
	frame.Form.OrderRecipientTarget.backdrop:SetPoint('BOTTOMRIGHT', 0, 2)

	local payment = frame.Form.PaymentContainer
	payment.NoteEditBox:StripTextures()
	payment.NoteEditBox:CreateBackdrop('Transparent')
	payment.NoteEditBox.backdrop:SetPoint('TOPLEFT', 15, 5)
	payment.NoteEditBox.backdrop:SetPoint('BOTTOMRIGHT', -18, 0)

	S:HandleDropDownBox(frame.Form.MinimumQuality.DropDown)
	S:HandleDropDownBox(frame.Form.OrderRecipientDropDown)
	HandleMoneyInput(payment.TipMoneyInputFrame.GoldBox)
	HandleMoneyInput(payment.TipMoneyInputFrame.SilverBox)
	S:HandleDropDownBox(payment.DurationDropDown)
	S:HandleButton(payment.ListOrderButton)

	local viewListingButton = payment.ViewListingsButton
	viewListingButton:SetAlpha(0)
	local viewListingRepair = CreateFrame('Frame', nil, payment)
	viewListingRepair:SetInside(viewListingButton)
	local viewListingTexture = viewListingRepair:CreateTexture(nil, 'ARTWORK')
	viewListingTexture:SetAllPoints()
	viewListingTexture:SetTexture([[Interface\CURSOR\Crosshair\Repair]])

	local currentListings = frame.Form.CurrentListings
	currentListings:StripTextures()
	currentListings:SetTemplate('Transparent')
	S:HandleButton(currentListings.CloseButton)
	S:HandleTrimScrollBar(currentListings.OrderList.ScrollBar, true)
	HandleListHeader(currentListings.OrderList.HeaderContainer)
	currentListings.OrderList:StripTextures()
	currentListings:ClearAllPoints()
	currentListings:SetPoint('LEFT', frame, 'RIGHT', 10, 0)

	hooksecurefunc(frame.Form, 'Init', FormInit)

	-- Orders
	S:HandleButton(frame.MyOrdersPage.RefreshButton)
	frame.MyOrdersPage.RefreshButton:Size(26)
	HandleListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
	S:HandleTrimScrollBar(frame.MyOrdersPage.OrderList.ScrollBar, true)

	frame.MyOrdersPage.OrderList:StripTextures()
	frame.MyOrdersPage.OrderList:CreateBackdrop('Transparent')
end

S:AddCallbackForAddon('Blizzard_ProfessionsCustomerOrders')
