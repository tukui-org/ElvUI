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

			if button.SlotBackground then
				button.SlotBackground:Hide()
			end

			if button.HighlightTexture then
				button.HighlightTexture:SetAlpha(0)
			end

			local highlight = button:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, .25)
			highlight:SetAllPoints(button)

			S:HandleCheckBox(slot.Checkbox)

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

	-- Item flyout
	if _G.OpenProfessionsItemFlyout then
		hooksecurefunc('OpenProfessionsItemFlyout', OpenItemFlyout)
	end

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

	local filter = search.FilterButton
	S:HandleCloseButton(filter.ClearFiltersButton)
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
	S:HandleButton(frame.Form.BackButton)
	S:HandleCheckBox(frame.Form.TrackRecipeCheckBox.Checkbox)
	frame.Form.RecipeHeader:Hide()
	frame.Form.RecipeHeader:CreateBackdrop('Transparent')
	frame.Form.LeftPanelBackground:StripTextures()
	frame.Form.LeftPanelBackground:CreateBackdrop('Transparent')
	frame.Form.LeftPanelBackground.backdrop:SetInside(nil, 2, 2)
	frame.Form.RightPanelBackground:StripTextures()
	frame.Form.RightPanelBackground:CreateBackdrop('Transparent')
	frame.Form.RightPanelBackground.backdrop:SetInside(nil, 2, 2)

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
	if payment then
		payment.NoteEditBox:StripTextures()
		payment.NoteEditBox:CreateBackdrop('Transparent')
		payment.NoteEditBox.backdrop:SetPoint('TOPLEFT', 15, 5)
		payment.NoteEditBox.backdrop:SetPoint('BOTTOMRIGHT', -18, 0)
	end

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
	if currentListings then
		currentListings:StripTextures()
		currentListings:SetTemplate('Transparent')
		S:HandleButton(currentListings.CloseButton)
		S:HandleTrimScrollBar(currentListings.OrderList.ScrollBar)
		HandleListHeader(currentListings.OrderList.HeaderContainer)
		currentListings.OrderList:StripTextures()
		currentListings:ClearAllPoints()
		currentListings:SetPoint('LEFT', frame, 'RIGHT', 10, 0)
	end

	local qualityDialog = frame.Form.QualityDialog
	if qualityDialog then
		qualityDialog:StripTextures()
		qualityDialog:SetTemplate('Transparent')
		S:HandleCloseButton(qualityDialog.ClosePanelButton)
		S:HandleButton(qualityDialog.AcceptButton)
		S:HandleButton(qualityDialog.CancelButton)

		ReskinQualityContainer(qualityDialog.Container1)
		ReskinQualityContainer(qualityDialog.Container2)
		ReskinQualityContainer(qualityDialog.Container3)
	end

	hooksecurefunc(frame.Form, 'Init', FormInit)

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
