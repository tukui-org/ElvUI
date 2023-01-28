local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, next = pairs, next
local hooksecurefunc = hooksecurefunc

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

local function HandleOutputButtons(frame)
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
end

local function ReskinOutputLog(outputlog)
	outputlog:StripTextures()
	outputlog:SetTemplate('Transparent')

	S:HandleCloseButton(outputlog.ClosePanelButton)
	S:HandleTrimScrollBar(outputlog.ScrollBar, true)

	hooksecurefunc(outputlog.ScrollBox, 'Update', HandleOutputButtons)
end

function S:Blizzard_Professions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local ProfessionsFrame = _G.ProfessionsFrame
	S:HandlePortraitFrame(ProfessionsFrame)

	local CraftingPage = ProfessionsFrame.CraftingPage
	S:HandleButton(CraftingPage.CreateButton)
	S:HandleButton(CraftingPage.CreateAllButton)
	S:HandleButton(CraftingPage.ViewGuildCraftersButton)
	HandleInputBox(CraftingPage.CreateMultipleInputBox)

	if E.global.general.disableTutorialButtons then
		CraftingPage.TutorialButton:Kill()
	else
		CraftingPage.TutorialButton.Ring:Hide()
	end

	local CraftingRankBar = CraftingPage.RankBar
	CraftingRankBar.Border:Hide()
	CraftingRankBar.Background:Hide()
	CraftingRankBar.Fill:CreateBackdrop()
	CraftingRankBar.Rank.Text:FontTemplate()

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

	local CraftList = CraftingPage.RecipeList
	CraftList:StripTextures()
	S:HandleTrimScrollBar(CraftList.ScrollBar, true)

	if CraftList.BackgroundNineSlice then
		if E.private.skins.parchmentRemoverEnable then
			CraftList.BackgroundNineSlice:Hide()
		else
			CraftList.BackgroundNineSlice:SetAlpha(.25)
		end
	end

	CraftList:CreateBackdrop('Transparent')
	CraftList.backdrop:SetInside()
	S:HandleEditBox(CraftList.SearchBox)
	S:HandleButton(CraftList.FilterButton)
	S:HandleCloseButton(CraftList.FilterButton.ResetButton)

	local SchematicForm = CraftingPage.SchematicForm
	SchematicForm:StripTextures()

	if E.private.skins.parchmentRemoverEnable then
		SchematicForm.Background:SetAlpha(0)
	else
		SchematicForm.Background:SetAlpha(.25)
	end
	SchematicForm:CreateBackdrop('Transparent')
	SchematicForm.backdrop:SetInside()

	hooksecurefunc(SchematicForm, 'Init', function(frame)
		for slot in frame.reagentSlotPool:EnumerateActive() do
			ReskinSlotButton(slot.Button)
		end

		local salvageSlot = SchematicForm.salvageSlot
		if salvageSlot then
			ReskinSlotButton(salvageSlot.Button)
		end

		local enchantSlot = SchematicForm.enchantSlot
		if enchantSlot then
			ReskinSlotButton(enchantSlot.Button)
		end
	end)

	local TrackRecipeCheckBox = SchematicForm.TrackRecipeCheckBox
	if TrackRecipeCheckBox then
		S:HandleCheckBox(TrackRecipeCheckBox)
		TrackRecipeCheckBox:SetSize(24, 24)
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

	local SpecPage = ProfessionsFrame.SpecPage
	S:HandleButton(SpecPage.UnlockTabButton)
	S:HandleButton(SpecPage.ApplyButton)
	SpecPage.TreeView:StripTextures()
	SpecPage.TreeView.Background:Hide()
	SpecPage.TreeView:CreateBackdrop('Transparent')
	SpecPage.TreeView.backdrop:SetInside()
	SpecPage.PanelFooter:StripTextures()

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

	ReskinOutputLog(CraftingPage.CraftingOutputLog)

	local Orders = ProfessionsFrame.OrdersPage
	S:HandleTab(Orders.BrowseFrame.PublicOrdersButton)
	S:HandleTab(Orders.BrowseFrame.GuildOrdersButton)
	S:HandleTab(Orders.BrowseFrame.PersonalOrdersButton)

	local BrowseFrame = Orders.BrowseFrame
	BrowseFrame.OrdersRemainingDisplay:StripTextures()
	BrowseFrame.OrdersRemainingDisplay:CreateBackdrop('Transparent')
	S:HandleButton(BrowseFrame.SearchButton)
	S:HandleButton(BrowseFrame.FavoritesSearchButton)
	S:HandleButton(BrowseFrame.BackButton)
	BrowseFrame.FavoritesSearchButton:Size(22)

	local BrowseList = Orders.BrowseFrame.RecipeList
	BrowseList:StripTextures()
	S:HandleTrimScrollBar(BrowseList.ScrollBar, true)
	S:HandleEditBox(BrowseList.SearchBox)
	S:HandleButton(BrowseList.FilterButton)
	BrowseList.BackgroundNineSlice:SetTemplate('Transparent')

	local OrderList = Orders.BrowseFrame.OrderList
	OrderList:StripTextures()
	S:HandleTrimScrollBar(OrderList.ScrollBar, true)

	local OrderView = Orders.OrderView
	local OrderRankBar = OrderView.RankBar
	OrderRankBar.Border:Hide()
	OrderRankBar.Background:Hide()
	OrderRankBar.Fill:CreateBackdrop()
	OrderRankBar.Rank.Text:FontTemplate()

	ReskinOutputLog(OrderView.CraftingOutputLog)

	S:HandleButton(OrderView.CreateButton)
	S:HandleButton(OrderView.StartRecraftButton)
	S:HandleButton(OrderView.CompleteOrderButton)

	local OrderInfo = OrderView.OrderInfo
	OrderInfo:StripTextures()
	OrderInfo:CreateBackdrop('Transparent')
	S:HandleButton(OrderInfo.BackButton)
	S:HandleButton(OrderInfo.IgnoreButton)
	S:HandleButton(OrderInfo.StartOrderButton)
	S:HandleButton(OrderInfo.DeclineOrderButton)
	S:HandleButton(OrderInfo.ReleaseOrderButton)
	S:HandleEditBox(OrderInfo.NoteBox)
	if OrderInfo.NoteBox.backdrop then
		OrderInfo.NoteBox.backdrop:SetTemplate('Transparent')
	end

	local OrderDetails = OrderView.OrderDetails
	OrderDetails:StripTextures()
	OrderDetails:CreateBackdrop('Transparent')
	OrderDetails.Background:ClearAllPoints()
	OrderDetails.Background:SetInside(OrderDetails.backdrop)
	OrderDetails.Background:SetAlpha(.5)

	local OrderSchematicForm = OrderDetails.SchematicForm
	S:HandleCheckBox(OrderSchematicForm.AllocateBestQualityCheckBox)

	hooksecurefunc(OrderSchematicForm, 'Init', function(frame)
		for slot in frame.reagentSlotPool:EnumerateActive() do
			ReskinSlotButton(slot.Button)
		end

		local slot = OrderSchematicForm.salvageSlot
		if slot then
			ReskinSlotButton(slot.Button)
		end
	end)

	local OrderOutputIcon = OrderSchematicForm.OutputIcon
	if OrderOutputIcon then
		S:HandleIcon(OrderOutputIcon.Icon, true)
		S:HandleIconBorder(OrderOutputIcon.IconBorder, OrderOutputIcon.Icon.backdrop)
		OrderOutputIcon:GetHighlightTexture():Hide()
		OrderOutputIcon.CircleMask:Hide()
	end

	local FulfillmentForm = OrderDetails.FulfillmentForm
	S:HandleEditBox(FulfillmentForm.NoteEditBox)
	if FulfillmentForm.NoteEditBox.backdrop then
		FulfillmentForm.NoteEditBox.backdrop:SetTemplate('Transparent')
	end

	local OrderItemIcon = OrderDetails.FulfillmentForm.ItemIcon
	if OrderItemIcon then
		S:HandleIcon(OrderItemIcon.Icon, true)
		S:HandleIconBorder(OrderItemIcon.IconBorder, OrderItemIcon.Icon.backdrop)
		OrderItemIcon:GetHighlightTexture():Hide()
		OrderItemIcon.CircleMask:Hide()
	end
end

S:AddCallbackForAddon('Blizzard_Professions')
