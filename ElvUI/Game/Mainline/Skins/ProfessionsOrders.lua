local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- Custom Orders (Credits: siweia - NDUI)

local function RefreshFlyoutButton(button)
	button.NormalTexture:SetAlpha(0)
	button.PushedTexture:SetAlpha(0)

	if not button.IsSkinned then
		S:HandleIcon(button.icon, true)
		S:HandleIconBorder(button.IconBorder, button.icon.backdrop)

		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetOutside(button)

		button.IsSkinned = true
	end
end

local function RefreshFlyoutButtons(frame)
	frame:ForEachFrame(RefreshFlyoutButton)
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

	for _, row in next, builder.rows do
		local cell = row.cells[1] -- the item name column
		if not cell.IsSkinned then
			S:HandleIcon(cell.Icon, true)
			cell.IconBorder:Hide()

			cell.IsSkinned = true
		end

		cell.Icon.backdrop:SetShown(cell.Icon:IsShown())
	end
end

local function HandleListHeader(headerContainer)
	local maxHeaders = headerContainer:GetNumChildren()
	for i, header in next, { headerContainer:GetChildren() } do
		if not header.IsSkinned then
			header:DisableDrawLayer('BACKGROUND')
			header:CreateBackdrop('Transparent')

			local highlight = header:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, .1)
			highlight:SetAllPoints(header.backdrop)

			header.IsSkinned = true
		end

		header.backdrop:SetPoint('BOTTOMRIGHT', i < maxHeaders and -5 or 0, -2)
	end
end

local function HandleMoneyInput(box)
	S:HandleEditBox(box)

	box.backdrop:SetPoint('TOPLEFT', 0, -3)
	box.backdrop:SetPoint('BOTTOMRIGHT', 0, 3)
end

local function HandleBrowseOrders(frame)
	HandleListHeader(frame.RecipeList.HeaderContainer)
end

local function FormInit(form)
	for slot in form.reagentSlotPool:EnumerateActive() do
		local button = slot.Button
		button.CropFrame:SetAlpha(0)
		button.SlotBackground:SetAlpha(0)
		button.HighlightTexture:SetAlpha(0)

		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetOutside(button)

		local nt = button:GetNormalTexture()
		local greenPlus = nt:GetAtlas() == 'ItemUpgrade_GreenPlusIcon'
		nt:SetAlpha(greenPlus and 1 or 0)
		nt:SetOutside(button)

		local ps = button:GetPushedTexture()
		ps:SetAlpha(greenPlus and 1 or 0)
		ps:SetOutside(button)

		if not button.IsSkinned then
			local icon = button.Icon
			S:HandleIcon(icon, true)
			S:HandleIconBorder(button.IconBorder, icon.backdrop)
			icon:SetOutside(button)

			S:HandleCheckBox(slot.Checkbox)

			button.IsSkinned = true
		end
	end
end

-- the reagent flyout is a single frame that gets reparented to whichever form opened it
-- Professions.lua hooks the same function with the same skin, whichever runs first skins it
local function OpenItemFlyout(_, owner)
	for _, child in next, { owner:GetChildren() } do
		if child.InitializeContents and not child.IsSkinned then
			child.NineSlice:SetTemplate('Transparent')
			S:HandleTrimScrollBar(child.ScrollBar)
			S:HandleCheckBox(child.HideUnownedCheckbox)
			child.HideUnownedCheckbox:Size(24)

			RefreshFlyoutButtons(child.ScrollBox)
			hooksecurefunc(child.ScrollBox, 'Update', RefreshFlyoutButtons)

			child.IsSkinned = true
		end
	end
end

local function BrowseOrdersUpdateChild(child)
	if not child.IsSkinned then
		HideCategoryButton(child)

		hooksecurefunc(child, 'Init', HideCategoryButton)

		child.IsSkinned = true
	end
end

local function BrowseOrdersUpdate(frame)
	frame:ForEachFrame(BrowseOrdersUpdateChild)
end

local function HandleInputBox(box)
	box:DisableDrawLayer('BACKGROUND')
	S:HandleEditBox(box)
	S:HandleNextPrevButton(box.DecrementButton, 'left')
	S:HandleNextPrevButton(box.IncrementButton, 'right')
end

local function ReskinQualityContainer(container)
	local button = container.Button
	button:StripTextures()
	button:SetNormalTexture(E.ClearTexture)
	button:SetPushedTexture(E.ClearTexture)
	button:SetHighlightTexture(E.ClearTexture)
	S:HandleIcon(button.Icon, true)
	S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
	HandleInputBox(container.EditBox)
end

local function HandleTabs(frame)
	local lastTab
	for index, tab in next, frame.Tabs do
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', -3, -32)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -5, 0)
		end

		lastTab = tab

		S:HandleTab(tab)
	end
end

function S:Blizzard_ProfessionsCustomerOrders()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local frame = _G.ProfessionsCustomerOrdersFrame
	S:HandleFrame(frame)
	HandleTabs(frame)

	hooksecurefunc('OpenProfessionsItemFlyout', OpenItemFlyout)

	frame.MoneyFrameBorder:StripTextures()
	frame.MoneyFrameInset:StripTextures()

	local browseOrders = frame.BrowseOrders
	frame.BrowseOrders.CategoryList:StripTextures()
	frame.BrowseOrders.CategoryList:CreateBackdrop('Transparent')
	S:HandleTrimScrollBar(browseOrders.CategoryList.ScrollBar)
	browseOrders.CategoryList.ScrollBar:ClearAllPoints()
	browseOrders.CategoryList.ScrollBar:Point('TOPRIGHT', -5, -2)
	browseOrders.CategoryList.ScrollBar:Point('BOTTOMRIGHT', 0, -2)

	local search = browseOrders.SearchBar
	search.FavoritesSearchButton:Size(22)
	S:HandleButton(search.FavoritesSearchButton)
	S:HandleEditBox(search.SearchBox)
	S:HandleButton(search.SearchButton)

	local filter = search.FilterDropdown
	S:HandleCloseButton(filter.ResetButton)
	S:HandleButton(filter)

	hooksecurefunc(browseOrders.CategoryList.ScrollBox, 'Update', BrowseOrdersUpdate)

	local recipeList = frame.BrowseOrders.RecipeList
	recipeList:StripTextures()
	S:HandleTrimScrollBar(recipeList.ScrollBar)
	recipeList.ScrollBar:ClearAllPoints()
	recipeList.ScrollBar:Point('TOPRIGHT', -8, -26)
	recipeList.ScrollBar:Point('BOTTOMRIGHT', 0, -2)
	recipeList.ScrollBox:CreateBackdrop('Transparent')
	recipeList.ScrollBox.backdrop:ClearAllPoints()
	recipeList.ScrollBox.backdrop:Point('TOPLEFT', 4, -4)
	recipeList.ScrollBox.backdrop:Point('BOTTOMRIGHT', -4, 0)
	recipeList.ScrollBox:SetFrameLevel(3)

	hooksecurefunc(frame.BrowseOrders, 'SetupTable', HandleBrowseOrders)
	hooksecurefunc(frame.BrowseOrders, 'StartSearch', HandleListIcon)

	-- Form
	local form = frame.Form
	S:HandleButton(form.BackButton)
	S:HandleCheckBox(form.TrackRecipeCheckbox.Checkbox)
	S:HandleCheckBox(form.AllocateBestQualityCheckbox)

	form.RecipeHeader:Hide()
	form.RecipeHeader:CreateBackdrop('Transparent')

	form.LeftPanelBackground:StripTextures()
	form.LeftPanelBackground:CreateBackdrop('Transparent')
	form.LeftPanelBackground.backdrop:SetInside(nil, 2, 2)

	form.RightPanelBackground:StripTextures()
	form.RightPanelBackground:CreateBackdrop('Transparent')
	form.RightPanelBackground.backdrop:SetInside(nil, 2, 2)

	local itemButton = form.OutputIcon
	itemButton.CircleMask:Hide()
	S:HandleIcon(itemButton.Icon, true)
	S:HandleIconBorder(itemButton.IconBorder, itemButton.Icon.backdrop)

	local itemHighlight = itemButton:GetHighlightTexture()
	itemHighlight:SetColorTexture(1, 1, 1, .25)
	itemHighlight:SetInside(itemButton.backdrop)

	S:HandleEditBox(form.OrderRecipientTarget)
	form.OrderRecipientTarget.backdrop:SetPoint('TOPLEFT', -8, -2)
	form.OrderRecipientTarget.backdrop:SetPoint('BOTTOMRIGHT', 0, 2)

	local payment = form.PaymentContainer
	payment.NoteEditBox:StripTextures()
	payment.NoteEditBox:CreateBackdrop('Transparent')
	payment.NoteEditBox.backdrop:SetPoint('TOPLEFT', 15, 5)
	payment.NoteEditBox.backdrop:SetPoint('BOTTOMRIGHT', -18, 0)
	S:HandleButton(payment.CancelOrderButton)

	S:HandleDropDownBox(form.MinimumQuality.Dropdown)
	S:HandleDropDownBox(form.OrderRecipientDropdown)
	HandleMoneyInput(payment.TipMoneyInputFrame.GoldBox)
	HandleMoneyInput(payment.TipMoneyInputFrame.SilverBox)
	S:HandleDropDownBox(payment.DurationDropdown)
	S:HandleButton(payment.ListOrderButton)

	local viewListingButton = payment.ViewListingsButton
	viewListingButton:SetAlpha(0)
	local viewListingRepair = CreateFrame('Frame', nil, payment)
	viewListingRepair:SetInside(viewListingButton)
	local viewListingTexture = viewListingRepair:CreateTexture(nil, 'ARTWORK')
	viewListingTexture:SetAllPoints()
	viewListingTexture:SetTexture([[Interface\CURSOR\Crosshair\Repair]])

	local currentListings = form.CurrentListings
	currentListings:StripTextures()
	currentListings:SetTemplate('Transparent')
	S:HandleButton(currentListings.CloseButton)
	S:HandleTrimScrollBar(currentListings.OrderList.ScrollBar)
	HandleListHeader(currentListings.OrderList.HeaderContainer)
	currentListings.OrderList:StripTextures()
	currentListings:ClearAllPoints()
	currentListings:SetPoint('LEFT', frame, 'RIGHT', 10, 0)

	local qualityDialog = form.QualityDialog
	qualityDialog:StripTextures()
	qualityDialog:SetTemplate('Transparent')
	qualityDialog.Bg:SetAlpha(0)

	S:HandleCloseButton(qualityDialog.ClosePanelButton)
	S:HandleButton(qualityDialog.AcceptButton)
	S:HandleButton(qualityDialog.CancelButton)

	ReskinQualityContainer(qualityDialog.Container1)
	ReskinQualityContainer(qualityDialog.Container2)
	ReskinQualityContainer(qualityDialog.Container3)

	hooksecurefunc(form, 'Init', FormInit)

	-- Orders
	S:HandleButton(frame.MyOrdersPage.RefreshButton)
	frame.MyOrdersPage.RefreshButton:Size(26)
	HandleListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
	S:HandleTrimScrollBar(frame.MyOrdersPage.OrderList.ScrollBar)

	frame.MyOrdersPage.OrderList:StripTextures()
	frame.MyOrdersPage.OrderList:CreateBackdrop('Transparent')
	frame.MyOrdersPage.OrderList.backdrop:ClearAllPoints()
	frame.MyOrdersPage.OrderList.backdrop:Point('TOPLEFT', frame.MyOrdersPage.OrderList.ScrollBox, 4, -4)
	frame.MyOrdersPage.OrderList.backdrop:Point('BOTTOMRIGHT', frame.MyOrdersPage.OrderList.ScrollBox, -4, 0)
end

S:AddCallbackForAddon('Blizzard_ProfessionsCustomerOrders')
