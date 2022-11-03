local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

--[[
	-- To show it for now
	/run LoadAddOn('Blizzard_ProfessionsCustomerOrders');
	/run ProfessionsCustomerOrdersFrame:Show();
]]

function S:Blizzard_ProfessionsCustomerOrders()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local ProfessionFrame = _G.ProfessionsCustomerOrdersFrame
	S:HandleFrame(ProfessionFrame)

	for i = 1, 2 do
		S:HandleTab(ProfessionFrame.Tabs[i])
	end

	ProfessionFrame.MoneyFrameBorder:StripTextures()
	ProfessionFrame.MoneyFrameBorder:SetTemplate('Transparent')
	ProfessionFrame.MoneyFrameInset:StripTextures()

	local SearchBar = ProfessionFrame.BrowseOrders.SearchBar
	S:HandleButton(SearchBar.FavoritesSearchButton)
	SearchBar.FavoritesSearchButton:SetSize(22, 22)
	S:HandleEditBox(SearchBar.SearchBox)
	S:HandleButton(SearchBar.SearchButton)

	local FilterButton = SearchBar.FilterButton
	S:HandleButton(FilterButton)
	S:HandleCloseButton(FilterButton.ClearFiltersButton)

	ProfessionFrame.BrowseOrders.CategoryList:StripTextures()
	ProfessionFrame.BrowseOrders.CategoryList:SetTemplate('Transparent') --probably adjust the backdrop
	S:HandleTrimScrollBar(ProfessionFrame.BrowseOrders.CategoryList.ScrollBar)

	ProfessionFrame.BrowseOrders.RecipeList:StripTextures()
	ProfessionFrame.BrowseOrders.RecipeList:SetTemplate('Transparent') --probably adjust the backdrop
	S:HandleTrimScrollBar(ProfessionFrame.BrowseOrders.RecipeList.ScrollBar)

	ProfessionFrame.MyOrdersPage.CategoryList:SetTemplate('Transparent')
	S:HandleTrimScrollBar(ProfessionFrame.MyOrdersPage.CategoryList.ScrollBar)

	ProfessionFrame.MyOrdersPage.OrderList:SetTemplate('Transparent')
	S:HandleTrimScrollBar(ProfessionFrame.MyOrdersPage.OrderList.ScrollBar)

	-- Form Page
	ProfessionFrame.Form:StripTextures()
	--ProfessionFrame.Form:SetTemplate('Transparent')

	S:HandleButton(ProfessionFrame.Form.BackButton)
	S:HandleDropDownBox(ProfessionFrame.Form.MinimumQualityDropDown)
	S:HandleDropDownBox(ProfessionFrame.Form.OrderRecipientDropDown)

	-- Reagent Container
	ProfessionFrame.Form.ReagentContainer:StripTextures()
	ProfessionFrame.Form.ReagentContainer:SetTemplate('Transparent')

	--Payment Container
	ProfessionFrame.Form.PaymentContainer:StripTextures()
	ProfessionFrame.Form.PaymentContainer:SetTemplate('Transparent')
	ProfessionFrame.Form.PaymentContainer.ScrollBoxContainer:StripTextures()
	S:HandleEditBox(ProfessionFrame.Form.PaymentContainer.ScrollBoxContainer.ScrollingEditBox)
	S:HandleTrimScrollBar(ProfessionFrame.Form.PaymentContainer.ScrollBoxContainer.ScrollBar)

	S:HandleDropDownBox(ProfessionFrame.Form.PaymentContainer.DurationDropDown)
	S:HandleButton(ProfessionFrame.Form.PaymentContainer.ListOrderButton)


	-- Quality Dialog
	ProfessionFrame.Form.QualityDialog:StripTextures()
	ProfessionFrame.Form.QualityDialog:SetTemplate()
	S:HandleCloseButton(ProfessionFrame.Form.QualityDialog.ClosePanelButton)

	-- Container1
	S:HandleNextPrevButton(ProfessionFrame.Form.QualityDialog.Container1.EditBox.DecrementButton, 'left')
	ProfessionFrame.Form.QualityDialog.Container1.EditBox:StripTextures()
	S:HandleEditBox(ProfessionFrame.Form.QualityDialog.Container1.EditBox)
	S:HandleNextPrevButton(ProfessionFrame.Form.QualityDialog.Container1.EditBox.IncrementButton, 'right')
	S:HandleIcon(ProfessionFrame.Form.QualityDialog.Container1.Button.Icon, true) -- ToDo
	S:HandleIconBorder(ProfessionFrame.Form.QualityDialog.Container1.Button.IconBorder, ProfessionFrame.Form.QualityDialog.Container1.Button.Icon.backdrop) -- ToDo

	-- Container2
	S:HandleNextPrevButton(ProfessionFrame.Form.QualityDialog.Container2.EditBox.DecrementButton, 'left')
	ProfessionFrame.Form.QualityDialog.Container2.EditBox:StripTextures()
	S:HandleEditBox(ProfessionFrame.Form.QualityDialog.Container2.EditBox)
	S:HandleNextPrevButton(ProfessionFrame.Form.QualityDialog.Container2.EditBox.IncrementButton, 'right')
	S:HandleIcon(ProfessionFrame.Form.QualityDialog.Container2.Button.Icon, true) -- ToDo
	S:HandleIconBorder(ProfessionFrame.Form.QualityDialog.Container2.Button.IconBorder, ProfessionFrame.Form.QualityDialog.Container2.Button.Icon.backdrop) -- ToDo

	-- Container3
	S:HandleNextPrevButton(ProfessionFrame.Form.QualityDialog.Container3.EditBox.DecrementButton, 'left')
	ProfessionFrame.Form.QualityDialog.Container3.EditBox:StripTextures()
	S:HandleEditBox(ProfessionFrame.Form.QualityDialog.Container3.EditBox)
	S:HandleNextPrevButton(ProfessionFrame.Form.QualityDialog.Container3.EditBox.IncrementButton, 'right')
	S:HandleIcon(ProfessionFrame.Form.QualityDialog.Container3.Button.Icon, true) -- ToDo
	S:HandleIconBorder(ProfessionFrame.Form.QualityDialog.Container3.Button.IconBorder, ProfessionFrame.Form.QualityDialog.Container3.Button.Icon.backdrop) -- ToDo

	S:HandleButton(ProfessionFrame.Form.QualityDialog.AcceptButton)
	S:HandleButton(ProfessionFrame.Form.QualityDialog.CancelButton)
end

S:AddCallbackForAddon('Blizzard_ProfessionsCustomerOrders')
