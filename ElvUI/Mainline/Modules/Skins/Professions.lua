local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, next, select = pairs, next, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local flyoutFrame

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

local function ReskinSlotButton(button)
	if button and not button.isSkinned then
		local texture = button.Icon:GetTexture()
		button:StripTextures()
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)

		S:HandleIcon(button.Icon, true)
		S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
		button.Icon:SetOutside(button)
		button.Icon:SetTexture(texture)

		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetOutside(button)

		if button.SlotBackground then
			button.SlotBackground:Hide()
		end

		button.isSkinned = true
	end
end

local function RefreshFlyoutButtons(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
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

local function HandleFlyouts(flyout)
	if not flyout.styled then
		flyout:StripTextures()
		flyout:SetTemplate('Transparent')
		S:HandleCheckBox(flyout.HideUnownedCheckBox)
		hooksecurefunc(flyout.ScrollBox, "Update", RefreshFlyoutButtons)

		flyout.styled = true
	end
end

function S:Blizzard_Professions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local ProfessionsFrame = _G.ProfessionsFrame
	S:HandlePortraitFrame(ProfessionsFrame)

	local CraftingPage = ProfessionsFrame.CraftingPage
	CraftingPage.TutorialButton.Ring:Hide()
	S:HandleButton(CraftingPage.CreateButton)
	S:HandleButton(CraftingPage.CreateAllButton)
	S:HandleButton(CraftingPage.ViewGuildCraftersButton)
	HandleInputBox(CraftingPage.CreateMultipleInputBox)

	local RankBar = CraftingPage.RankBar
	RankBar.Border:Hide()
	RankBar.Background:Hide()
	RankBar.Fill:CreateBackdrop()

	local LinkButton = CraftingPage.LinkButton
	LinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
	LinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
	LinkButton:GetHighlightTexture():Kill()
	LinkButton:SetTemplate()
	LinkButton:Size(17, 14)

	local GuildFrame = CraftingPage.GuildFrame
	GuildFrame:StripTextures()
	GuildFrame:CreateBackdrop('Transparent')
	GuildFrame.Container:StripTextures()
	GuildFrame.Container:CreateBackdrop('Transparent')

	for _, tab in next, { ProfessionsFrame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	for _, name in pairs({'Prof0ToolSlot', 'Prof0Gear0Slot', 'Prof0Gear1Slot', 'Prof1ToolSlot', 'Prof1Gear0Slot', 'Prof1Gear1Slot', 'CookingToolSlot', 'CookingGear0Slot', 'FishingToolSlot', 'FishingGear0Slot', 'FishingGear1Slot'}) do
		local button = CraftingPage[name]
		if button then
			button:StripTextures()
			S:HandleIcon(button.icon, true)
			S:HandleIconBorder(button.IconBorder, button.icon.backdrop)
			button:SetNormalTexture(E.ClearTexture)
			button:SetPushedTexture(E.ClearTexture)
		end
	end

	local RecipeList = CraftingPage.RecipeList
	RecipeList:StripTextures()
	S:HandleTrimScrollBar(RecipeList.ScrollBar, true)
	if RecipeList.BackgroundNineSlice then RecipeList.BackgroundNineSlice:Hide() end
	RecipeList:CreateBackdrop('Transparent')
	RecipeList.backdrop:SetInside()
	S:HandleEditBox(RecipeList.SearchBox)
	S:HandleButton(RecipeList.FilterButton)
	S:HandleCloseButton(RecipeList.FilterButton.ResetButton)

	local SchematicForm = CraftingPage.SchematicForm
	SchematicForm:StripTextures()
	SchematicForm.Background:SetAlpha(0)
	SchematicForm:CreateBackdrop('Transparent')
	SchematicForm.backdrop:SetInside()

	local Track = SchematicForm.TrackRecipeCheckBox
	if Track then
		S:HandleCheckBox(Track)
		Track:SetSize(24, 24)
	end

	local QualityCheckBox = SchematicForm.AllocateBestQualityCheckBox
	if QualityCheckBox then
		S:HandleCheckBox(QualityCheckBox)
		QualityCheckBox:SetSize(24, 24)
	end

	local QualityDialog = SchematicForm.QualityDialog
	if QualityDialog then
		QualityDialog:StripTextures()
		QualityDialog:CreateBackdrop('Transparent')
		S:HandleCloseButton(QualityDialog.ClosePanelButton)
		S:HandleButton(QualityDialog.AcceptButton)
		S:HandleButton(QualityDialog.CancelButton)

		ReskinQualityContainer(QualityDialog.Container1)
		ReskinQualityContainer(QualityDialog.Container2)
		ReskinQualityContainer(QualityDialog.Container3)
	end

	local OutputIcon = SchematicForm.OutputIcon
	if OutputIcon then
		S:HandleIcon(OutputIcon.Icon, true)
		S:HandleIconBorder(OutputIcon.IconBorder, OutputIcon.Icon.backdrop)
		OutputIcon:GetHighlightTexture():Hide()
		OutputIcon.CircleMask:Hide()
	end

	hooksecurefunc(SchematicForm, 'Init', function(frame)
		for slot in frame.reagentSlotPool:EnumerateActive() do
			ReskinSlotButton(slot.Button)
		end

		local slot = SchematicForm.salvageSlot
		if slot then
			ReskinSlotButton(slot.Button)
		end
	end)

	local SpecPage = ProfessionsFrame.SpecPage
	S:HandleButton(SpecPage.UnlockTabButton)
	S:HandleButton(SpecPage.ApplyButton)
	SpecPage.TreeView:StripTextures()
	SpecPage.TreeView.Background:Hide()
	SpecPage.TreeView:CreateBackdrop('Transparent')
	SpecPage.TreeView.backdrop:SetInside()

	hooksecurefunc(SpecPage, 'UpdateTabs', function(frame)
		for tab in frame.tabsPool:EnumerateActive() do
			if not tab.isSkinned then
				S:HandleTab(tab)
				tab.isSkinned = true
			end
		end
	end)

	local DetailedView = SpecPage.DetailedView
	DetailedView:StripTextures()
	DetailedView:CreateBackdrop('Transparent')
	DetailedView.backdrop:SetInside()
	S:HandleButton(DetailedView.UnlockPathButton)
	S:HandleButton(DetailedView.SpendPointsButton)
	S:HandleIcon(DetailedView.UnspentPoints.Icon)

	local OutputLog = CraftingPage.CraftingOutputLog
	OutputLog:StripTextures()
	OutputLog:CreateBackdrop()
	S:HandleCloseButton(OutputLog.ClosePanelButton)
	S:HandleTrimScrollBar(OutputLog.ScrollBar, true)

	hooksecurefunc(OutputLog.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				local itemContainer = child.ItemContainer
				if itemContainer then
					local item = itemContainer.Item
					item:SetNormalTexture(E.ClearTexture)
					item:SetPushedTexture(E.ClearTexture)
					item:SetHighlightTexture(E.ClearTexture)

					local icon = item:GetRegions()
					S:HandleIcon(icon, true)
					S:HandleIconBorder(item.IconBorder, icon.backdrop)

					itemContainer.CritFrame:SetAlpha(0)
					itemContainer.BorderFrame:Hide()
					itemContainer.HighlightNameFrame:SetAlpha(0)
					itemContainer.PushedNameFrame:SetAlpha(0)
					itemContainer.HighlightNameFrame:CreateBackdrop('Transparent')
				end

				local bonus = child.CreationBonus
				if bonus then
					local item = bonus.Item
					item:StripTextures()
					local icon = item:GetRegions()
					S:HandleIcon(icon)
				end

				child.isSkinned = true
			end

			local itemContainer = child.ItemContainer
			if itemContainer then
				itemContainer.Item.IconBorder:SetAlpha(0)

				local itemBG = itemContainer.backdrop
				if itemBG then
					if itemContainer.CritFrame:IsShown() then
						itemBG:SetBackdropBorderColor(1, .8, 0)
					else
						itemBG:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_Professions')

-- Custom Orders
-- Credits: siweia - NDUI

--[[ method to show it for now
	/run LoadAddOn('Blizzard_ProfessionsCustomerOrders')
	/run ProfessionsCustomerOrdersFrame:Show()
]]

local function HideCategoryButton(button)
	--button:SetTemplate('Transparnt')
	button.NormalTexture:Hide()
	button.SelectedTexture:SetColorTexture(0, .6, 1, .3)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
end

local function HandleListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			local cell = row.cells and row.cells[1]
			if cell and cell.Icon then
				if not cell.styled then
					S:HandleIcon(cell.Icon, true)
					if cell.IconBorder then cell.IconBorder:Hide() end
					cell.styled = true
				end
				cell.Icon.backdrop:SetShown(cell.Icon:IsShown())
			end
		end
	end
end

local function HandleListHeader(headerContainer)
	local maxHeaders = headerContainer:GetNumChildren()
	for i = 1, maxHeaders do
		local header = select(i, headerContainer:GetChildren())
		if header and not header.styled then
			header:DisableDrawLayer('BACKGROUND')
			header:CreateBackdrop('Transparent')
			local hl = header:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .1)
			hl:SetAllPoints(header.backdrop)

			header.styled = true
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

	hooksecurefunc(browseOrders.CategoryList.ScrollBox, 'Update', function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.Text and not child.IsSkinned then
				HideCategoryButton(child)
				hooksecurefunc(child, 'Init', HideCategoryButton)

				child.IsSkinned = true
			end
		end
	end)

	local recipeList = frame.BrowseOrders.RecipeList
	recipeList:StripTextures()
	recipeList.ScrollBox:CreateBackdrop('Transparent')
	recipeList.ScrollBox.backdrop:SetInside()
	S:HandleTrimScrollBar(recipeList.ScrollBar, true)

	hooksecurefunc(frame.BrowseOrders, "SetupTable", HandleBrowseOrders)
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

	local hl = itemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(itemButton.backdrop)

	S:HandleEditBox(frame.Form.OrderRecipientTarget)
	frame.Form.OrderRecipientTarget.backdrop:SetPoint('TOPLEFT', -8, -2)
	frame.Form.OrderRecipientTarget.backdrop:SetPoint('BOTTOMRIGHT', 0, 2)

	frame.Form.PaymentContainer.NoteEditBox:StripTextures()
	frame.Form.PaymentContainer.NoteEditBox:CreateBackdrop('Transparent')
	frame.Form.PaymentContainer.NoteEditBox.backdrop:SetPoint("TOPLEFT", 15, 5)
	frame.Form.PaymentContainer.NoteEditBox.backdrop:SetPoint("BOTTOMRIGHT", -18, 0)

	S:HandleDropDownBox(frame.Form.MinimumQuality.DropDown)
	S:HandleDropDownBox(frame.Form.OrderRecipientDropDown)
	HandleMoneyInput(frame.Form.PaymentContainer.TipMoneyInputFrame.GoldBox)
	HandleMoneyInput(frame.Form.PaymentContainer.TipMoneyInputFrame.SilverBox)
	S:HandleDropDownBox(frame.Form.PaymentContainer.DurationDropDown)
	S:HandleButton(frame.Form.PaymentContainer.ListOrderButton)

	local viewButton = frame.Form.PaymentContainer.ViewListingsButton
	viewButton:SetAlpha(0)
	local buttonFrame = CreateFrame('Frame', nil, frame.Form.PaymentContainer)
	buttonFrame:SetInside(viewButton)
	local tex = buttonFrame:CreateTexture(nil, 'ARTWORK')
	tex:SetAllPoints()
	tex:SetTexture('Interface\\CURSOR\\Crosshair\\Repair')

	local current = frame.Form.CurrentListings
	current:StripTextures()
	current:SetTemplate('Transparent')
	S:HandleButton(current.CloseButton)
	S:HandleTrimScrollBar(current.OrderList.ScrollBar, true)
	HandleListHeader(current.OrderList.HeaderContainer)
	current.OrderList:StripTextures()
	current:ClearAllPoints()
	current:SetPoint('LEFT', frame, 'RIGHT', 10, 0)

	hooksecurefunc(frame.Form, 'Init', function(self)
		for slot in self.reagentSlotPool:EnumerateActive() do
			local button = slot.Button
			if button and not button.IsSkinned then
				button:SetNormalTexture(0)
				button:SetPushedTexture(0)
				S:HandleIcon(button.Icon, true)
				S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetInside(button.bg)
				if button.SlotBackground then
					button.SlotBackground:Hide()
				end

				button.IsSkinned = true
			end
		end
	end)

	-- Item flyout
	if _G.OpenProfessionsItemFlyout then
		hooksecurefunc("OpenProfessionsItemFlyout", function()
			if flyoutFrame then return end

			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child.HideUnownedCheckBox then
					flyoutFrame = child
					HandleFlyouts(flyoutFrame)
					break
				end
			end
		end)
	end

	-- Orders
	S:HandleButton(frame.MyOrdersPage.RefreshButton)
	frame.MyOrdersPage.RefreshButton:Size(26)
	HandleListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
	S:HandleTrimScrollBar(frame.MyOrdersPage.OrderList.ScrollBar, true)

	frame.MyOrdersPage.OrderList:StripTextures()
	frame.MyOrdersPage.OrderList:CreateBackdrop('Transparent')
end

S:AddCallbackForAddon('Blizzard_ProfessionsCustomerOrders')
