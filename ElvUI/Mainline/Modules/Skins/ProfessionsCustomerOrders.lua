local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

--[[ method to show it for now
	/run LoadAddOn('Blizzard_ProfessionsCustomerOrders')
	/run ProfessionsCustomerOrdersFrame:Show()
]]

local function HandleContainer(container)
	local editbox = container.EditBox
	if editbox then
		editbox:StripTextures()
		S:HandleEditBox(editbox)
		S:HandleNextPrevButton(editbox.DecrementButton, 'left')
		S:HandleNextPrevButton(editbox.IncrementButton, 'right')
	end

	local button = container.Button
	if button then
		S:HandleIcon(button.Icon, true)
		S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
	end
end

function S:Blizzard_ProfessionsCustomerOrders()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local frame = _G.ProfessionsCustomerOrdersFrame
	S:HandleFrame(frame)

	for _, tab in next, frame.Tabs do
		S:HandleTab(tab)
	end

	frame.MoneyFrameBorder:StripTextures()
	frame.MoneyFrameBorder:SetTemplate('Transparent')
	frame.MoneyFrameInset:StripTextures()

	local myOrders = frame.MyOrdersPage
	myOrders.CategoryList:SetTemplate('Transparent')
	S:HandleTrimScrollBar(myOrders.CategoryList.ScrollBar)

	myOrders.OrderList:SetTemplate('Transparent')
	S:HandleTrimScrollBar(myOrders.OrderList.ScrollBar)

	local browseOrders = frame.BrowseOrders
	browseOrders.CategoryList:StripTextures()
	browseOrders.CategoryList:SetTemplate('Transparent') --probably adjust the backdrop
	S:HandleTrimScrollBar(browseOrders.CategoryList.ScrollBar)

	browseOrders.RecipeList:StripTextures()
	browseOrders.RecipeList:SetTemplate('Transparent') --probably adjust the backdrop
	S:HandleTrimScrollBar(browseOrders.RecipeList.ScrollBar)

	local search = browseOrders.SearchBar
	search.FavoritesSearchButton:Size(22)
	S:HandleButton(search.FavoritesSearchButton)
	S:HandleEditBox(search.SearchBox)
	S:HandleButton(search.SearchButton)

	local filter = search.FilterButton
	S:HandleCloseButton(filter.ClearFiltersButton)
	S:HandleButton(filter)

	-- Form Page
	local form = frame.Form
	form:StripTextures()
	--form:SetTemplate('Transparent')

	S:HandleButton(form.BackButton)
	S:HandleDropDownBox(form.MinimumQualityDropDown)
	S:HandleDropDownBox(form.OrderRecipientDropDown)

	-- Reagent Container
	form.ReagentContainer:StripTextures()
	form.ReagentContainer:SetTemplate('Transparent')

	--Payment Container
	local payment = form.PaymentContainer
	payment:StripTextures()
	payment:SetTemplate('Transparent')

	S:HandleDropDownBox(payment.DurationDropDown)
	S:HandleButton(payment.ListOrderButton)

	local scrollBox = payment.ScrollBoxContainer
	scrollBox:StripTextures()
	S:HandleEditBox(scrollBox.ScrollingEditBox)
	S:HandleTrimScrollBar(scrollBox.ScrollBar)

	-- Quality Dialog
	local dialog = form.QualityDialog
	dialog:StripTextures()
	dialog:SetTemplate()
	S:HandleCloseButton(dialog.ClosePanelButton)

	-- Containers
	HandleContainer(dialog.Container1)
	HandleContainer(dialog.Container2)
	HandleContainer(dialog.Container3)

	-- Form buttons
	S:HandleButton(dialog.AcceptButton)
	S:HandleButton(dialog.CancelButton)
end

S:AddCallbackForAddon('Blizzard_ProfessionsCustomerOrders')
