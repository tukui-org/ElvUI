local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_Professions', nil, nil, nil, nil, nil, 'tradeskill')

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

-- the reagent flyout is a single frame that gets reparented to whichever form opened it
-- Professions.lua hooks the same function with the same skin, whichever runs first skins it
local function ItemFlyout_CustomerOrders(_, owner)
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

-- the reagent flyout is a single frame that gets reparented to whichever form opened it
local function ItemFlyout_Professions(_, owner)
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

local function OpenProfessionsItemFlyout(frame, owner)
	ItemFlyout_Professions(frame, owner)	-- Blizzard_Professions
	ItemFlyout_CustomerOrders(frame, owner) -- Blizzard_ProfessionsCustomerOrders
end

local function ReskinSlotButton(button)
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
		local icon = button.Icon
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

local hookedSchematicForm = {}
local function HandleSchematicForm(form, noParchment)
	if not hookedSchematicForm[form] then
		hookedSchematicForm[form] = true

		hooksecurefunc(form, 'Init', HandleSchematicInit)
	end

	form:StripTextures()
	form:CreateBackdrop('Transparent')
	form.backdrop:SetInside()

	if form.Background then -- crafting page and inspect recipe only, the order view form has no parchment
		form.Background:SetInside(form.backdrop)

		-- Blizzard re-applies the atlas and shows these on profession change
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

	if bar.overrideWidth then -- the book cards size the bar but leave the Fill at 441
		bar.Fill:SetWidth(bar.overrideWidth)
	end

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
	OrderDetails.Background:SetAlpha(0.5)

	HandleSchematicForm(OrderDetails.SchematicForm)

	S:HandleEditBox(OrderDetails.FulfillmentForm.NoteEditBox, 'Transparent')
	S:HandleIcon(frame.ConcentrationDisplay.Icon)

	local OrderItemIcon = OrderDetails.FulfillmentForm.ItemIcon
	S:HandleIcon(OrderItemIcon.Icon, true)
	S:HandleIconBorder(OrderItemIcon.IconBorder, OrderItemIcon.Icon.backdrop)
	OrderItemIcon:GetHighlightTexture():Hide()
	OrderItemIcon.CircleMask:Hide()
end

-- RecipeList category rows (ProfessionsRecipeListCategoryTemplate)
local function HandleRecipeCategory(button)
	button:StripTextures()
	button:CreateBackdrop('Transparent')
	button.backdrop:SetInside(button, 0, 1)

	local rankBar = button.RankBar
	rankBar.BorderLeft:SetAlpha(0)
	rankBar.BorderMid:SetAlpha(0)
	rankBar.BorderRight:SetAlpha(0)
	rankBar:SetStatusBarTexture(E.media.normTex)
	rankBar:CreateBackdrop('Transparent')
	rankBar.Rank:FontTemplate()

	E:RegisterStatusBar(rankBar)
end

-- RecipeList recipe rows (ProfessionsRecipeListRecipeTemplate)
local function HandleRecipe(button)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	button.SelectedOverlay:SetColorTexture(r, g, b, .25)
	button.SelectedOverlay:SetInside(button)

	button.HighlightOverlay:SetColorTexture(1, 1, 1, .5)
	button.HighlightOverlay:SetInside(button)
end

local function HandleRecipeListChild(child)
	if child.IsSkinned then return end

	if E.Forever and child.CollapseButton then -- ToDo: Forever
		HandleRecipeCategory(child)
	elseif child.SkillUps then
		HandleRecipe(child)
	end

	child.IsSkinned = true
end

local function HandleRecipeList(frame)
	frame:ForEachFrame(HandleRecipeListChild)
end

local function ProfessionButton_UpdateButton(button)
	button.highlightTexture:SetColorTexture(1, 1, 1, .25)
	button.spellString:SetTextColor(1, 1, 1) -- passives get a dark color meant for the card art
end

-- BookPage profession spell buttons (ProfessionButtonTemplate)
local function HandleProfessionButton(button)
	button:OffsetFrameLevel(1) -- backdrops sit a level below, the card art would cover them
	button.IconTexture:RemoveMaskTexture(button.OutlineMask)
	button.IconTextureOverlay:SetAlpha(0)
	button.IconTexture:SetInside()
	S:HandleIcon(button.IconTexture, true)
	button.highlightTexture:SetInside(button.IconTexture.backdrop)

	E:RegisterCooldown(button.cooldown)

	hooksecurefunc(button, 'UpdateButton', ProfessionButton_UpdateButton)
end

local function HandleBookProfession(frame)
	HandleRankBar(frame.StatusBar)

	local unlearn = frame.UnlearnButton
	if unlearn then
		S:HandleCloseButton(unlearn)
		unlearn:OffsetFrameLevel(1)
		unlearn:CreateBackdrop()
		unlearn:SetHitRectInsets(0, 0, 0, 0)

		-- line up with the skinned bar, the Fill sticks out past the StatusBar frame
		unlearn:Size(18)
		unlearn:ClearAllPoints()
		unlearn:Point('LEFT', frame.StatusBar.Fill.backdrop, 'RIGHT', 2, 0)
	end

	for _, button in next, frame.spellButtons do
		HandleProfessionButton(button)
	end
end

local function RefreshRightTabs(frame)
	local tabs = { frame.ProfessionsOverviewTab }
	for _, tab in next, frame.rightProfessionTabs do
		tabs[#tabs + 1] = tab
	end

	S:LayoutLargeSideTabs(frame, tabs)
end

function S:Blizzard_Professions()
	local ProfessionsFrame = _G.ProfessionsFrame
	S:HandlePortraitFrame(ProfessionsFrame)

	local CraftingPage = ProfessionsFrame.CraftingPage
	CraftingPage:StripTextures() -- Profession-Background-Template2 artwork on Forever
	S:HandleButton(CraftingPage.CreateButton, nil, nil, nil, E.Forever) -- Forever builds it from SharedButtonSmallTemplate, doesn't have a backdrop
	S:HandleButton(CraftingPage.CreateAllButton, nil, nil, nil, E.Forever)
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

	hooksecurefunc('OpenProfessionsItemFlyout', OpenProfessionsItemFlyout)

	if E.global.general.disableTutorialButtons then
		CraftingPage.TutorialButton:Kill()
	else
		CraftingPage.TutorialButton.Ring:Hide()
	end

	HandleRankBar(CraftingPage.RankBar)

	local LinkButton = CraftingPage.LinkButton
	if not E.Forever then -- ToDo: Forever
		LinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
		LinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
		LinkButton:GetHighlightTexture():Kill()
	end

	LinkButton:SetTemplate()
	LinkButton:Size(17, 14)

	local GuildFrame = CraftingPage.GuildFrame
	GuildFrame:StripTextures()
	GuildFrame:CreateBackdrop('Transparent')
	GuildFrame.Container:StripTextures()
	GuildFrame.Container:CreateBackdrop('Transparent')

	if E.Forever then -- Forever side tabs, no TabSystem or maximize button
		S:HandleLargeSideTab(ProfessionsFrame.ProfessionsOverviewTab)
		for _, tab in next, ProfessionsFrame.rightProfessionTabs do
			S:HandleLargeSideTab(tab)
		end

		hooksecurefunc(ProfessionsFrame, 'RefreshRightTabs', RefreshRightTabs)
		RefreshRightTabs(ProfessionsFrame)
	else
		S:HandleMaxMinFrame(ProfessionsFrame.MaximizeMinimize)

		local TabSystem = ProfessionsFrame.TabSystem
		for _, tab in next, { TabSystem:GetChildren() } do
			S:HandleTab(tab)
		end

		TabSystem.spacing = -5
		TabSystem:MarkDirty()
		TabSystem:ClearAllPoints()
		TabSystem:Point('TOPLEFT', ProfessionsFrame, 'BOTTOMLEFT', -3, 0)
	end

	-- the fishing gear slots are commented out in the XML
	for _, name in next, { 'Prof0ToolSlot', 'Prof0Gear0Slot', 'Prof0Gear1Slot', 'Prof1ToolSlot', 'Prof1Gear0Slot', 'Prof1Gear1Slot', 'CookingToolSlot', 'CookingGear0Slot', 'FishingToolSlot' } do
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

	hooksecurefunc(CraftList.ScrollBox, 'Update', HandleRecipeList)

	if E.Retail then -- no specializations page on Forever
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
	end

	ReskinOutputLog(CraftingPage.CraftingOutputLog)

	if E.Retail then -- no crafting orders page on Forever
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

	if E.Forever then -- Forever BookPage (ProfessionsBookFrameTemplate)
		local BookContent = ProfessionsFrame.BookPage.ProfessionsContentFrame
		for _, frame in next, { BookContent.PrimaryProfession1, BookContent.PrimaryProfession2, BookContent.SecondaryProfession1, BookContent.SecondaryProfession2, BookContent.SecondaryProfession3 } do
			HandleBookProfession(frame)
		end
	end
end
