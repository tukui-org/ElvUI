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

local function HandleSalvageItem(item)
	if item.NormalTexture then
		item.NormalTexture:SetAlpha(0)
		item.PushedTexture:SetAlpha(0)
	end

	if not item.IsSkinned then
		S:HandleIcon(item.icon, true)
		S:HandleIconBorder(item.IconBorder, item.icon.backdrop)

		local hl = item:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetOutside(item)

		item.IsSkinned = true
	end
end

local function HandleItemFlyoutContents(child)
	child.NineSlice:SetTemplate('Transparent')

	if child.ScrollBar then
		S:HandleTrimScrollBar(child.ScrollBar)
	end

	if child.HideUnownedCheckbox then
		S:HandleCheckBox(child.HideUnownedCheckbox)
		child.HideUnownedCheckbox:Size(24)
	end

	child.ScrollBox:ForEachFrame(HandleSalvageItem)
end

local professionFlyoutHooks = {}
local function HandleProfessionsItemFlyout()
	local CraftingPage = _G.ProfessionsFrame.CraftingPage
	local SchematicForm = CraftingPage and CraftingPage.SchematicForm
	if not SchematicForm then return end

	for _, child in next, { SchematicForm:GetChildren() } do
		if child.InitializeContents and not professionFlyoutHooks[child] then
			E:Delay(0.05, HandleItemFlyoutContents, child)

			hooksecurefunc(child, 'InitializeContents', HandleItemFlyoutContents)
		end
	end
end

local function ReskinSlotButton(button)
	local icon = button and button.Icon
	if not icon then return end

	if button.CropFrame then button.CropFrame:SetAlpha(0) end
	if button.SlotBackground then button.SlotBackground:SetAlpha(0) end

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
		S:HandleIcon(icon, true)
		S:HandleIconBorder(button.IconBorder, icon.backdrop)
		icon:SetOutside(button)

		button.IsSkinned = true
	end
end

local function HandleOutputButton(child)
	if not child.IsSkinned then
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
			itemContainer.NameFrame:Hide()
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

		child.IsSkinned = true
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

local function HandleOutputButtons(frame)
	frame:ForEachFrame(HandleOutputButton)
end

local function ReskinOutputLog(outputlog)
	outputlog:StripTextures()
	outputlog:SetTemplate('Transparent')
	outputlog.Bg:SetAlpha(0)

	S:HandleCloseButton(outputlog.ClosePanelButton)
	S:HandleTrimScrollBar(outputlog.ScrollBar)

	hooksecurefunc(outputlog.ScrollBox, 'Update', HandleOutputButtons)
end

local function HandleRewardButton(button)
	if not button then return end

	button:StripTextures()
	S:HandleIcon(button.Icon, true)
	S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
end

function S:Blizzard_Professions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local ProfessionsFrame = _G.ProfessionsFrame
	S:HandlePortraitFrame(ProfessionsFrame)

	local CraftingPage = ProfessionsFrame.CraftingPage
	S:HandleButton(CraftingPage.CreateButton)
	S:HandleButton(CraftingPage.CreateAllButton)
	S:HandleButton(CraftingPage.ViewGuildCraftersButton)
	S:HandleIcon(CraftingPage.ConcentrationDisplay.Icon)
	S:HandleEditBox(CraftingPage.MinimizedSearchBox)
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

	if CraftingRankBar.ExpansionDropdownButton then
		local arrow = CraftingRankBar.ExpansionDropdownButton:CreateTexture(nil, 'ARTWORK')
		arrow:SetTexture(E.Media.Textures.ArrowUp)
		arrow:Size(11)
		arrow:Point('CENTER')
		S:SetupArrow(arrow, 'down')

		S:HandleButton(CraftingRankBar.ExpansionDropdownButton)
	end

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

	S:HandleMaxMinFrame(ProfessionsFrame.MaximizeMinimize)

	for _, tab in next, { ProfessionsFrame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	ProfessionsFrame.TabSystem:ClearAllPoints()
	ProfessionsFrame.TabSystem:Point('TOPLEFT', ProfessionsFrame, 'BOTTOMLEFT', -3, 0)

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
	S:HandleTrimScrollBar(CraftList.ScrollBar)

	if CraftList.BackgroundNineSlice then
		CraftList.BackgroundNineSlice:Hide()
	end

	CraftList:CreateBackdrop('Transparent')
	CraftList.backdrop:SetInside()
	S:HandleEditBox(CraftList.SearchBox)
	S:HandleButton(CraftList.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleCloseButton(CraftList.FilterDropdown.ResetButton)

	local SchematicForm = CraftingPage.SchematicForm
	SchematicForm:StripTextures()

	if E.private.skins.parchmentRemoverEnable then
		SchematicForm.Background:SetAlpha(0)
		SchematicForm.MinimalBackground:SetAlpha(0)
	else
		SchematicForm.Background:SetTexCoord(0.02, 0.98, 0.02, 0.98)
		SchematicForm.Background:SetAlpha(0.6)
		SchematicForm.MinimalBackground:SetAlpha(0.6)
	end

	SchematicForm:CreateBackdrop('Transparent')
	SchematicForm.backdrop:SetInside()
	SchematicForm.Background:SetInside(SchematicForm.backdrop)

	hooksecurefunc('ToggleProfessionsItemFlyout', HandleProfessionsItemFlyout)
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

	local TrackRecipeCheckBox = SchematicForm.TrackRecipeCheckbox
	if TrackRecipeCheckBox then
		S:HandleCheckBox(TrackRecipeCheckBox)
		TrackRecipeCheckBox:Size(24)
	end

	local QualityCheckBox = SchematicForm.AllocateBestQualityCheckbox
	if QualityCheckBox then
		S:HandleCheckBox(QualityCheckBox)
		QualityCheckBox:Size(24)
	end

	local QualityDialog = SchematicForm.QualityDialog
	if QualityDialog then
		QualityDialog:StripTextures()
		QualityDialog:CreateBackdrop('Transparent')

		if QualityDialog.Bg then
			QualityDialog.Bg:SetAlpha(0)
		end

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
	S:HandleButton(SpecPage.ViewTreeButton)
	S:HandleButton(SpecPage.UnlockTabButton)
	S:HandleButton(SpecPage.ApplyButton)
	S:HandleButton(SpecPage.ViewPreviewButton)
	S:HandleButton(SpecPage.BackToFullTreeButton)
	S:HandleButton(SpecPage.BackToPreviewButton)

	SpecPage.PanelFooter:StripTextures()
	SpecPage.TreeView:StripTextures()
	SpecPage.TreeView:CreateBackdrop('Transparent')
	SpecPage.TreeView.Background:SetInside(SpecPage.TreeView.backdrop)
	SpecPage.TreeView.Background:SetTexCoord(0.02, 0.98, 0.02, 0.98)

	SpecPage.TreeView.backdrop:ClearAllPoints()
	SpecPage.TreeView.backdrop:Point('TOPLEFT', -1, -1)
	SpecPage.TreeView.backdrop:Point('BOTTOMRIGHT', -41, 1)

	if E.private.skins.parchmentRemoverEnable then
		SpecPage.TreeView.Background:SetAlpha(0)
	else
		SpecPage.TreeView.Background:SetAlpha(0.6)
	end

	hooksecurefunc(SpecPage, 'UpdateTabs', function(frame)
		for tab in frame.tabsPool:EnumerateActive() do
			if not tab.IsSkinned then
				S:HandleTab(tab)
				tab.IsSkinned = true
			end
		end
	end)

	local DetailedView = SpecPage.DetailedView
	DetailedView:StripTextures()
	DetailedView:CreateBackdrop('Transparent')
	S:HandleButton(DetailedView.UnlockPathButton)
	S:HandleButton(DetailedView.SpendPointsButton)
	S:HandleIcon(DetailedView.UnspentPoints.Icon)

	DetailedView.backdrop:ClearAllPoints()
	DetailedView.backdrop:Point('TOPLEFT', -1, -1)
	DetailedView.backdrop:Point('BOTTOMRIGHT', -1, 1)

	ReskinOutputLog(CraftingPage.CraftingOutputLog)

	local Orders = ProfessionsFrame.OrdersPage
	S:HandleTab(Orders.BrowseFrame.PublicOrdersButton)
	S:HandleTab(Orders.BrowseFrame.NpcOrdersButton)
	S:HandleTab(Orders.BrowseFrame.GuildOrdersButton)
	S:HandleTab(Orders.BrowseFrame.PersonalOrdersButton)

	local BrowseFrame = Orders.BrowseFrame
	BrowseFrame.OrdersRemainingDisplay:StripTextures()
	BrowseFrame.OrdersRemainingDisplay:CreateBackdrop('Transparent')
	S:HandleButton(BrowseFrame.SearchButton)
	S:HandleButton(BrowseFrame.FavoritesSearchButton)
	BrowseFrame.FavoritesSearchButton:Size(22)

	do
		S:HandleNextPrevButton(BrowseFrame.BackButton, 'left', nil, true)
		S:HandleBlizzardRegions(BrowseFrame.BackButton)
		BrowseFrame.BackButton:SetTemplate()
	end

	local BrowseList = Orders.BrowseFrame.RecipeList
	BrowseList:StripTextures()
	S:HandleTrimScrollBar(BrowseList.ScrollBar)
	S:HandleEditBox(BrowseList.SearchBox)
	S:HandleButton(BrowseList.FilterDropdown)
	BrowseList.BackgroundNineSlice:SetTemplate('Transparent')

	local OrderList = Orders.BrowseFrame.OrderList
	OrderList:StripTextures()
	S:HandleTrimScrollBar(OrderList.ScrollBar)

	local OrderView = Orders.OrderView

	local DeclineOrderDialog = OrderView.DeclineOrderDialog
	DeclineOrderDialog:StripTextures()
	DeclineOrderDialog:CreateBackdrop('Transparent')
	DeclineOrderDialog.NoteEditBox:StripTextures()
	S:HandleEditBox(DeclineOrderDialog.NoteEditBox.ScrollingEditBox)
	S:HandleButton(DeclineOrderDialog.ConfirmButton)
	S:HandleButton(DeclineOrderDialog.CancelButton)

	local OrderRankBar = OrderView.RankBar
	OrderRankBar.Border:Hide()
	OrderRankBar.Background:Hide()
	OrderRankBar.Fill:CreateBackdrop()
	OrderRankBar.Rank.Text:FontTemplate()

	if OrderRankBar.ExpansionDropdownButton then
		local arrow = OrderRankBar.ExpansionDropdownButton:CreateTexture(nil, 'ARTWORK')
		arrow:SetTexture(E.Media.Textures.ArrowUp)
		arrow:Size(11)
		arrow:Point('CENTER')
		S:SetupArrow(arrow, 'down')

		S:HandleButton(OrderRankBar.ExpansionDropdownButton)
	end

	ReskinOutputLog(OrderView.CraftingOutputLog)

	S:HandleButton(OrderView.CreateButton)
	S:HandleButton(OrderView.StartRecraftButton)
	S:HandleButton(OrderView.CompleteOrderButton)

	local OrderInfo = OrderView.OrderInfo
	OrderInfo:StripTextures()
	OrderInfo:CreateBackdrop('Transparent')
	S:HandleButton(OrderInfo.BackButton)
	--S:HandleButton(OrderInfo.IgnoreButton) -- plx check that
	S:HandleButton(OrderInfo.StartOrderButton)
	S:HandleButton(OrderInfo.DeclineOrderButton)
	S:HandleButton(OrderInfo.ReleaseOrderButton)
	S:HandleButton(OrderInfo.SocialDropdown)
	S:HandleEditBox(OrderInfo.NoteBox)
	if OrderInfo.NoteBox.backdrop then
		OrderInfo.NoteBox.backdrop:SetTemplate('Transparent')
	end

	local RewardsFrame = OrderInfo.NPCRewardsFrame
	if RewardsFrame then
		RewardsFrame.Background:SetAlpha(0)
		RewardsFrame.Background:CreateBackdrop('Transparent')

		HandleRewardButton(RewardsFrame.RewardItem1)
		HandleRewardButton(RewardsFrame.RewardItem2)
	end

	local OrderDetails = OrderView.OrderDetails
	OrderDetails:StripTextures()
	OrderDetails:CreateBackdrop('Transparent')
	OrderDetails.Background:ClearAllPoints()
	OrderDetails.Background:SetInside(OrderDetails.backdrop)
	OrderDetails.Background:SetAlpha(.5)

	local OrderSchematicForm = OrderDetails.SchematicForm
	S:HandleCheckBox(OrderSchematicForm.AllocateBestQualityCheckbox)
	S:HandleCheckBox(OrderSchematicForm.TrackRecipeCheckbox)

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

	S:HandleIcon(OrderView.ConcentrationDisplay.Icon)

	local OrderItemIcon = OrderDetails.FulfillmentForm.ItemIcon
	if OrderItemIcon then
		S:HandleIcon(OrderItemIcon.Icon, true)
		S:HandleIconBorder(OrderItemIcon.IconBorder, OrderItemIcon.Icon.backdrop)
		OrderItemIcon:GetHighlightTexture():Hide()
		OrderItemIcon.CircleMask:Hide()
	end
end

S:AddCallbackForAddon('Blizzard_Professions')
