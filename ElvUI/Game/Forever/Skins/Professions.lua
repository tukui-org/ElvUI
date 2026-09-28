local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
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

	local icon = not button.IsSkinned and button.Icon
	if icon then
		S:HandleIcon(icon, true)
		S:HandleIconBorder(button.IconBorder, icon.backdrop)
		icon:SetOutside(button)

		button.IsSkinned = true
	end
end

local function HandleSchematicInit(form)
	for slot in form.reagentSlotPool:EnumerateActive() do
		ReskinSlotButton(slot.Button)
	end

	if form.salvageSlot then
		ReskinSlotButton(form.salvageSlot.Button)
	end

	if form.enchantSlot then
		ReskinSlotButton(form.enchantSlot.Button)
	end
end

local function HandleSchematicForm(form, noParchment)
	form:StripTextures()
	form:CreateBackdrop('Transparent')
	form.backdrop:SetInside()

	-- Blizzard re-applies the atlas and shows these on profession change
	form.Background:SetInside(form.backdrop)

	if noParchment or E.private.skins.parchmentRemoverEnable then
		form.Background:SetAlpha(0)
		form.MinimalBackground:SetAlpha(0)
	else
		form.Background:SetTexCoord(0.02, 0.98, 0.02, 0.98)
		form.Background:SetAlpha(0.6)
		form.MinimalBackground:SetAlpha(0.6)
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

	hooksecurefunc(form, 'Init', HandleSchematicInit)
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

-- ProfessionsRankBarTemplate
local function HandleRankBar(bar)
	bar.Border:Hide()
	bar.Background:Hide()

	bar.Fill:CreateBackdrop()

	if bar.overrideWidth then -- the book cards size the bar but leave the Fill at 441
		bar.Fill:SetWidth(bar.overrideWidth)
	end

	bar.Rank.Text:FontTemplate()

	local expansionDropdown = bar.ExpansionDropdownButton
	local arrow = expansionDropdown:CreateTexture(nil, 'ARTWORK')
	arrow:SetTexture(E.Media.Textures.ArrowUp)
	arrow:Size(11)
	arrow:Point('CENTER')
	S:SetupArrow(arrow, 'down')

	S:HandleButton(expansionDropdown)
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

	if child.CollapseButton then
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
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local ProfessionsFrame = _G.ProfessionsFrame
	local pageBG = ProfessionsFrame.Bg:GetAtlas()
	S:HandlePortraitFrame(ProfessionsFrame)

	if not E.private.skins.parchmentRemoverEnable then
		ProfessionsFrame.Bg:SetAtlas(pageBG)
		ProfessionsFrame.Bg:SetDrawLayer('BACKGROUND', 1) -- above the ElvUI backdrop
	end

	S:HandleLargeSideTab(ProfessionsFrame.ProfessionsOverviewTab)
	for _, tab in next, ProfessionsFrame.rightProfessionTabs do
		S:HandleLargeSideTab(tab)
	end

	hooksecurefunc(ProfessionsFrame, 'RefreshRightTabs', RefreshRightTabs)
	RefreshRightTabs(ProfessionsFrame)

	-- CraftingPage (ProfessionsCraftingPageTemplate)
	local CraftingPage = ProfessionsFrame.CraftingPage
	if E.private.skins.parchmentRemoverEnable then
		CraftingPage:StripTextures() -- Profession-Background-Template2 artwork
	end

	S:HandleButton(CraftingPage.CreateButton, nil, nil, nil, true) -- SharedButtonSmallTemplate, doesn't have a backdrop
	S:HandleButton(CraftingPage.CreateAllButton, nil, nil, nil, true)
	S:HandleButton(CraftingPage.ViewGuildCraftersButton)
	S:HandleEditBox(CraftingPage.MinimizedSearchBox)
	HandleInputBox(CraftingPage.CreateMultipleInputBox)
	HandleRankBar(CraftingPage.RankBar)
	HandleSchematicForm(CraftingPage.SchematicForm)
	ReskinOutputLog(CraftingPage.CraftingOutputLog)

	if CraftingPage.SetOverrideCastBarActive ~= E.noop then
		CraftingPage.SetOverrideCastBarActive = E.noop
	end

	if E.global.general.disableTutorialButtons then
		CraftingPage.TutorialButton:Kill()
	else
		CraftingPage.TutorialButton.Ring:Hide()
	end

	local LinkButton = CraftingPage.LinkButton
	LinkButton:SetTemplate()
	LinkButton:Size(17, 14)

	local GuildFrame = CraftingPage.GuildFrame
	GuildFrame:StripTextures()
	GuildFrame:CreateBackdrop('Transparent')
	GuildFrame.Container:StripTextures()
	GuildFrame.Container:CreateBackdrop('Transparent')

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
	CraftList:CreateBackdrop('Transparent')
	CraftList.backdrop:SetInside()

	S:HandleTrimScrollBar(CraftList.ScrollBar)
	S:HandleEditBox(CraftList.SearchBox)
	S:HandleButton(CraftList.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleCloseButton(CraftList.FilterDropdown.ResetButton)

	hooksecurefunc(CraftList.ScrollBox, 'Update', HandleRecipeList)

	local InspectRecipe = _G.InspectRecipeFrame
	S:HandleFrame(InspectRecipe)
	HandleSchematicForm(InspectRecipe.SchematicForm, true)

	-- BookPage (ProfessionsBookFrameTemplate)
	local BookContent = ProfessionsFrame.BookPage.ProfessionsContentFrame
	for _, frame in next, { BookContent.PrimaryProfession1, BookContent.PrimaryProfession2, BookContent.SecondaryProfession1, BookContent.SecondaryProfession2, BookContent.SecondaryProfession3 } do
		HandleBookProfession(frame)
	end
end

S:AddCallbackForAddon('Blizzard_Professions')
