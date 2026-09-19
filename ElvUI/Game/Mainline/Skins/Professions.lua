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
	item.NormalTexture:SetAlpha(0)
	item.PushedTexture:SetAlpha(0)

	if not item.IsSkinned then
		S:HandleIcon(item.icon, true)
		S:HandleIconBorder(item.IconBorder, item.icon.backdrop)

		local hl = item:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetOutside(item)

		item.IsSkinned = true
	end
end

local function HandleFlyoutItems(scrollBox)
	scrollBox:ForEachFrame(HandleSalvageItem)
end

-- the reagent flyout is a single frame that gets reparented to whichever form opened it
local function HandleItemFlyout(_, owner)
	for _, child in next, { owner:GetChildren() } do
		if child.InitializeContents and not child.IsSkinned then
			child.NineSlice:SetTemplate('Transparent')
			S:HandleTrimScrollBar(child.ScrollBar)
			S:HandleCheckBox(child.HideUnownedCheckbox)
			child.HideUnownedCheckbox:Size(24)

			HandleFlyoutItems(child.ScrollBox)
			hooksecurefunc(child.ScrollBox, 'Update', HandleFlyoutItems)

			child.IsSkinned = true
		end
	end
end

local function ReskinSlotButton(button)
	local icon = button.Icon
	button.CropFrame:SetAlpha(0)
	button.SlotBackground:SetAlpha(0)

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
	local itemContainer = child.ItemContainer
	if not child.IsSkinned then
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

		child.IsSkinned = true
	end

	itemContainer.Item.IconBorder:SetAlpha(0)

	if itemContainer.CritFrame:IsShown() then
		itemContainer.HighlightNameFrame.backdrop:SetBackdropBorderColor(1, .8, 0)
	else
		itemContainer.HighlightNameFrame.backdrop:SetBackdropBorderColor(0, 0, 0)
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
	button:StripTextures()

	S:HandleIcon(button.Icon, true)
	S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
end

local function HandleSchematicInit(form)
	for slot in form.reagentSlotPool:EnumerateActive() do
		ReskinSlotButton(slot.Button)
	end

	if form.salvageSlot then -- created on the first salvage recipe
		ReskinSlotButton(form.salvageSlot.Button)
	end

	if form.enchantSlot then -- created on the first enchant recipe
		ReskinSlotButton(form.enchantSlot.Button)
	end
end

local hookedForms = {}
local function HandleSchematicForm(form, noParchment)
	if not hookedForms[form] then
		hookedForms[form] = true

		hooksecurefunc(form, 'Init', HandleSchematicInit)
	end

	form:StripTextures()
	form:CreateBackdrop('Transparent')
	form.backdrop:SetInside()

	if form.Background then -- crafting page and inspect recipe only, the order view form has no parchment
		form.Background:SetInside(form.backdrop)

		if noParchment or E.private.skins.parchmentRemoverEnable then
			form.Background:SetAlpha(0)
			form.MinimalBackground:SetAlpha(0)
		else
			form.Background:SetTexCoord(0.02, 0.98, 0.02, 0.98)
			form.Background:SetAlpha(0.6)
			form.MinimalBackground:SetAlpha(0.6)
		end
	end

	S:HandleCheckBox(form.TrackRecipeCheckbox)
	form.TrackRecipeCheckbox:Size(24)
	S:HandleCheckBox(form.AllocateBestQualityCheckbox)
	form.AllocateBestQualityCheckbox:Size(24)

	local QualityDialog = form.QualityDialog
	QualityDialog:StripTextures()
	QualityDialog:CreateBackdrop('Transparent')
	QualityDialog.Bg:SetAlpha(0)

	S:HandleCloseButton(QualityDialog.ClosePanelButton)
	S:HandleButton(QualityDialog.AcceptButton)
	S:HandleButton(QualityDialog.CancelButton)

	ReskinQualityContainer(QualityDialog.Container1)
	ReskinQualityContainer(QualityDialog.Container2)
	ReskinQualityContainer(QualityDialog.Container3)

	local OutputIcon = form.OutputIcon
	S:HandleIcon(OutputIcon.Icon, true)
	S:HandleIconBorder(OutputIcon.IconBorder, OutputIcon.Icon.backdrop)
	OutputIcon:GetHighlightTexture():Hide()
	OutputIcon.CircleMask:Hide()
end

local function SpecPage_UpdateTabs(frame)
	for tab in frame.tabsPool:EnumerateActive() do
		if not tab.IsSkinned then
			S:HandleTab(tab)
			tab.IsSkinned = true
		end
	end
end

local function HandleRankBar(bar)
	bar.Border:Hide()
	bar.Background:Hide()
	bar.Fill:CreateBackdrop()
	bar.Rank.Text:FontTemplate()

	local arrow = bar.ExpansionDropdownButton:CreateTexture(nil, 'ARTWORK')
	arrow:SetTexture(E.Media.Textures.ArrowUp)
	arrow:Size(11)
	arrow:Point('CENTER')
	S:SetupArrow(arrow, 'down')

	S:HandleButton(bar.ExpansionDropdownButton)
end

local function HandleOrderView(frame)
	local DeclineOrderDialog = frame.DeclineOrderDialog
	DeclineOrderDialog:StripTextures()
	DeclineOrderDialog:CreateBackdrop('Transparent')
	DeclineOrderDialog.NoteEditBox:StripTextures()

	S:HandleEditBox(DeclineOrderDialog.NoteEditBox.ScrollingEditBox)
	S:HandleButton(DeclineOrderDialog.ConfirmButton)
	S:HandleButton(DeclineOrderDialog.CancelButton)

	HandleRankBar(frame.RankBar)
	ReskinOutputLog(frame.CraftingOutputLog)

	if frame.SetOverrideCastBarActive ~= E.noop then
		frame.SetOverrideCastBarActive = E.noop
	end

	S:HandleButton(frame.CreateButton)
	S:HandleButton(frame.StartRecraftButton)
	S:HandleButton(frame.CompleteOrderButton)

	local OrderInfo = frame.OrderInfo
	OrderInfo:StripTextures()
	OrderInfo:CreateBackdrop('Transparent')
	S:HandleButton(OrderInfo.BackButton)
	S:HandleButton(OrderInfo.StartOrderButton)
	S:HandleButton(OrderInfo.DeclineOrderButton)
	S:HandleButton(OrderInfo.ReleaseOrderButton)
	S:HandleButton(OrderInfo.SocialDropdown)
	S:HandleEditBox(OrderInfo.NoteBox, 'Transparent')

	local RewardsFrame = OrderInfo.NPCRewardsFrame
	RewardsFrame.Background:SetAlpha(0)
	RewardsFrame.Background:CreateBackdrop('Transparent')

	HandleRewardButton(RewardsFrame.RewardItem1)
	HandleRewardButton(RewardsFrame.RewardItem2)

	local OrderDetails = frame.OrderDetails
	OrderDetails:StripTextures()
	OrderDetails:CreateBackdrop('Transparent')
	OrderDetails.Background:ClearAllPoints()
	OrderDetails.Background:SetInside(OrderDetails.backdrop)
	OrderDetails.Background:SetAlpha(.5)

	HandleSchematicForm(OrderDetails.SchematicForm)

	S:HandleEditBox(OrderDetails.FulfillmentForm.NoteEditBox, 'Transparent')
	S:HandleIcon(frame.ConcentrationDisplay.Icon)

	local OrderItemIcon = OrderDetails.FulfillmentForm.ItemIcon
	S:HandleIcon(OrderItemIcon.Icon, true)
	S:HandleIconBorder(OrderItemIcon.IconBorder, OrderItemIcon.Icon.backdrop)
	OrderItemIcon:GetHighlightTexture():Hide()
	OrderItemIcon.CircleMask:Hide()
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

	HandleSchematicForm(CraftingPage.SchematicForm)
	HandleInputBox(CraftingPage.CreateMultipleInputBox)

	if CraftingPage.SetOverrideCastBarActive ~= E.noop then
		CraftingPage.SetOverrideCastBarActive = E.noop
	end

	local InspectRecipe = _G.InspectRecipeFrame
	S:HandleFrame(InspectRecipe)
	HandleSchematicForm(InspectRecipe.SchematicForm, true)

	hooksecurefunc('OpenProfessionsItemFlyout', HandleItemFlyout)

	if E.global.general.disableTutorialButtons then
		CraftingPage.TutorialButton:Kill()
	else
		CraftingPage.TutorialButton.Ring:Hide()
	end

	HandleRankBar(CraftingPage.RankBar)

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

	local TabSystem = ProfessionsFrame.TabSystem
	for _, tab in next, { TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	TabSystem.spacing = -5
	TabSystem:MarkDirty()
	TabSystem:ClearAllPoints()
	TabSystem:Point('TOPLEFT', ProfessionsFrame, 'BOTTOMLEFT', -3, 0)

	for _, name in pairs({'Prof0ToolSlot', 'Prof0Gear0Slot', 'Prof0Gear1Slot', 'Prof1ToolSlot', 'Prof1Gear0Slot', 'Prof1Gear1Slot', 'CookingToolSlot', 'CookingGear0Slot', 'FishingToolSlot'}) do -- the fishing gear slots are commented out in the XML
		local button = CraftingPage[name]
		button:StripTextures()

		S:HandleIcon(button.icon, true)
		S:HandleIconBorder(button.IconBorder, button.icon.backdrop)

		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
	end

	local CraftList = CraftingPage.RecipeList
	CraftList:StripTextures()
	CraftList.BackgroundNineSlice:Hide()
	CraftList:CreateBackdrop('Transparent')
	CraftList.backdrop:SetInside()

	S:HandleTrimScrollBar(CraftList.ScrollBar)
	S:HandleEditBox(CraftList.SearchBox)
	S:HandleButton(CraftList.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleCloseButton(CraftList.FilterDropdown.ResetButton)

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

	hooksecurefunc(SpecPage, 'UpdateTabs', SpecPage_UpdateTabs)

	local DetailedView = SpecPage.DetailedView
	DetailedView:StripTextures()
	DetailedView:CreateBackdrop('Transparent')
	DetailedView.backdrop:ClearAllPoints()
	DetailedView.backdrop:Point('TOPLEFT', -1, -1)
	DetailedView.backdrop:Point('BOTTOMRIGHT', -1, 1)

	S:HandleButton(DetailedView.UnlockPathButton)
	S:HandleButton(DetailedView.SpendPointsButton)
	S:HandleIcon(DetailedView.UnspentPoints.Icon)

	ReskinOutputLog(CraftingPage.CraftingOutputLog)

	local OrdersPage = ProfessionsFrame.OrdersPage
	HandleOrderView(OrdersPage.OrderView)

	local BrowseFrame = OrdersPage.BrowseFrame
	S:HandleTab(BrowseFrame.PublicOrdersButton)
	S:HandleTab(BrowseFrame.NpcOrdersButton)
	S:HandleTab(BrowseFrame.GuildOrdersButton)
	S:HandleTab(BrowseFrame.PersonalOrdersButton)

	BrowseFrame.OrdersRemainingDisplay:StripTextures()
	BrowseFrame.OrdersRemainingDisplay:CreateBackdrop('Transparent')
	BrowseFrame.FavoritesSearchButton:Size(22)

	S:HandleButton(BrowseFrame.SearchButton)
	S:HandleButton(BrowseFrame.FavoritesSearchButton)

	S:HandleNextPrevButton(BrowseFrame.BackButton, 'left', nil, true)
	S:HandleBlizzardRegions(BrowseFrame.BackButton)
	BrowseFrame.BackButton:SetTemplate()

	local BrowseList = BrowseFrame.RecipeList
	BrowseList:StripTextures()
	BrowseList.BackgroundNineSlice:SetTemplate('Transparent')

	S:HandleTrimScrollBar(BrowseList.ScrollBar)
	S:HandleEditBox(BrowseList.SearchBox)
	S:HandleButton(BrowseList.FilterDropdown)

	BrowseFrame.OrderList:StripTextures()
	S:HandleTrimScrollBar(BrowseFrame.OrderList.ScrollBar)
end

S:AddCallbackForAddon('Blizzard_Professions')
