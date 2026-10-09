local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

S:AddCallbackForAddon('Blizzard_LegacySystem', nil, nil, nil, nil, nil, 'legacySystem')

local function HandleProgressBar(bar, background)
	S:HandleStatusBar(bar)
	bar.Text:FontTemplate()
	background:SetAlpha(0)
end

local function RewardCard_Refresh(card, _, displayLevel)
	local r, g, b = unpack(card:GetLevel() == displayLevel and E.media.rgbvaluecolor or E.media.bordercolor)
	card.backdrop:SetBackdropBorderColor(r, g, b)
	card.levelBG:SetBackdropBorderColor(r, g, b)
end

-- LegacyRewardCardTemplate (RenownLevelMixin)
local function HandleRewardCard(card)
	if card.IsSkinned then return end

	card.RewardCardBG:SetAlpha(0)
	card.IconBorder:SetAlpha(0)
	card.LevelSquare:SetAlpha(0)

	local cardLevel = card:GetFrameLevel()
	card:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, cardLevel - 2)
	card.backdrop:Point('TOPLEFT', 4, -4)
	card.backdrop:Point('BOTTOMRIGHT', -5, 5)

	S:HandleIcon(card.Icon, true)

	local levelBG = CreateFrame('Frame', nil, card)
	levelBG:OffsetFrameLevel(-1, card) -- backdrop is -2, level bg is -1
	levelBG:Point('CENTER', card.LevelSquare)
	levelBG:SetTemplate()
	levelBG:Size(32)
	card.levelBG = levelBG

	hooksecurefunc(card, 'Refresh', RewardCard_Refresh)

	card.IsSkinned = true
end

local function RewardTrack_Init(track)
	for card in track.elementPool:EnumerateActive() do
		HandleRewardCard(card)
	end
end

local function HandleCriteria(criteria)
	if criteria.IsSkinned then return end

	criteria.Background:SetAlpha(0)
	HandleProgressBar(criteria.ProgressBar, criteria.ProgressBarBackground)

	criteria.IsSkinned = true
end

local function Challenge_DisplayObjectives(button)
	for criteria in button:GetObjectiveFrame().criteriaPool:EnumerateActive() do
		HandleCriteria(criteria)
	end
end

-- Blizzard swaps the red plus / minus atlas on every state change, follow it with the ElvUI textures
local function Challenge_UpdatePlusMinusArt(button)
	button.PlusMinus:SetTexture(button.collapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton)
end

local function SelectedOverlay_SetShown(overlay, shown)
	local button = overlay:GetParent()
	if shown then
		button.backdrop:SetBackdropBorderColor(1, 0.8, 0.1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		button.backdrop:SetBackdropBorderColor(r, g, b)
	end
end

-- LegacyChallengeTemplate, achievement style cards in the detail pane
local function HandleChallenge(button)
	if button.IsSkinned then return end

	button.TitleBar:SetAlpha(0)
	button.Background:SetAlpha(0)
	button.BackgroundTop:SetAlpha(0)
	button.BackgroundMiddle:SetAlpha(0)
	button.BackgroundBottom:SetAlpha(0)
	button.SelectedOverlay:SetAlpha(0)
	button.Shield.CheckBackground:SetAlpha(0)

	button:CreateBackdrop('Transparent')
	button.backdrop:SetInside(button, 0, 1)

	button.Icon.frame:Hide()
	button.Icon.texture:RemoveMaskTexture(button.Icon.TextureMask)
	S:HandleIcon(button.Icon.texture, true)

	S:HandleCheckBox(button.Tracked)
	button.Tracked:Size(20)

	hooksecurefunc(button.SelectedOverlay, 'SetShown', SelectedOverlay_SetShown)

	hooksecurefunc(button, 'DisplayObjectives', Challenge_DisplayObjectives)
	hooksecurefunc(button, 'UpdatePlusMinusArt', Challenge_UpdatePlusMinusArt)

	Challenge_UpdatePlusMinusArt(button)

	button.IsSkinned = true
end

local function DetailPane_Update(frame)
	frame:ForEachFrame(HandleChallenge)
end

-- Clear the gradient instead of ClearEdgeFade(taint)
local function ClearEdgeGradient(scrollBox)
	scrollBox:ClearAlphaGradient()
end

local function Category_RefreshCardArt(button)
	button.selectedTex:SetShown(not button.collapsable and button.selected)
end

-- LegacyChallengeCategoryTemplate (ListHeaderVisualTemplate), keep the Blizzard plus / minus
local function HandleCategory(button)
	if button.IsSkinned then return end

	button:GetNormalTexture():SetAlpha(0)
	button:GetHighlightTexture():SetAlpha(0)

	button:CreateBackdrop()
	button.backdrop:SetInside(button, 0, 1)

	local r, g, b = unpack(E.media.rgbvaluecolor)
	local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	highlight:SetColorTexture(r, g, b, 0.25)
	highlight:SetInside(button.backdrop)
	button.highlight = highlight

	local selectedTex = button:CreateTexture(nil, 'ARTWORK')
	selectedTex:SetColorTexture(r, g, b, 0.25)
	selectedTex:SetInside(button.backdrop)
	button.selectedTex = selectedTex

	hooksecurefunc(button, 'RefreshCardArt', Category_RefreshCardArt)
	Category_RefreshCardArt(button)

	button.IsSkinned = true
end

local function CategoryList_Update(frame)
	frame:ForEachFrame(HandleCategory)
end

local function TalentButton_UpdateStateBorder(button, visualState)
	button.StateBorderHover:SetAlpha(0)

	local color = _G.TalentButtonUtil.GetColorForBaseVisualState(visualState)
	button.Icon.backdrop:SetBackdropBorderColor(color:GetRGB())
end

local function HandleTalentButton(button)
	button.Shadow:SetAlpha(0)
	button.StateBorder:SetAlpha(0)
	button.Icon:RemoveMaskTexture(button.IconMask)
	button.DisabledOverlay:RemoveMaskTexture(button.DisabledOverlayMask)

	S:HandleIcon(button.Icon, true)

	local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	highlight:SetColorTexture(1, 1, 1, 0.25)
	highlight:SetInside(button.Icon.backdrop)

	hooksecurefunc(button, 'UpdateStateBorder', TalentButton_UpdateStateBorder)

	-- The state was applied before the hook existed
	local visualState = button:GetVisualState()
	if visualState then
		TalentButton_UpdateStateBorder(button, visualState)
	end
end

local function TraitPanel_UpdateButtonFrameLevel(_, button)
	if not button.StateBorder or button.Icon2 then return end

	if not button.IsSkinned then
		HandleTalentButton(button)

		button.IsSkinned = true
	end

	button.Icon.backdrop:OffsetFrameLevel(-1, button)
end

local function RefreshTreeButtons(panel)
	for _, button in next, panel.treeButtons do
		button.Background:SetAlpha(0)
	end
end

function S:Blizzard_LegacySystem()
	local LegacySystemFrame = _G.LegacySystemFrame
	S:HandlePortraitFrame(LegacySystemFrame)

	for _, tab in next, LegacySystemFrame.Tabs do
		S:HandleLargeSideTab(tab)
	end

	S:LayoutLargeSideTabs(LegacySystemFrame, LegacySystemFrame.Tabs)

	-- Reward Track
	local RewardTrackPage = LegacySystemFrame.RewardTrackPage
	local RewardProgressBar = RewardTrackPage.LegacyRewardProgressBar
	local ProgressBarBackground = RewardTrackPage.ProgressBarBackground
	HandleProgressBar(RewardProgressBar, ProgressBarBackground)

	-- Line the bar ends up with the cards below
	RewardProgressBar:Point('TOPLEFT', ProgressBarBackground, 6, 0)
	RewardProgressBar:Point('BOTTOMRIGHT', ProgressBarBackground, -6, 3)

	RewardTrackPage.Points:FontTemplate(nil, 26)
	RewardTrackPage.PointsLabel:FontTemplate(nil, 16)

	local RewardProgressFrame = RewardTrackPage.LegacyRewardProgressFrame
	S:HandleNextPrevButton(RewardProgressFrame.LeftButton, 'left', nil, true)
	S:HandleNextPrevButton(RewardProgressFrame.RightButton, 'right', nil, true)
	S:HandleNextPrevButton(RewardProgressFrame.JumpLeftButton, 'left', nil, true)
	S:HandleNextPrevButton(RewardProgressFrame.JumpRightButton, 'right', nil, true)

	local parchmentRemover = E.private.skins.parchmentRemoverEnable
	if parchmentRemover then
		RewardTrackPage.Background:SetAlpha(0)

		hooksecurefunc(RewardProgressFrame, 'Init', RewardTrack_Init)
	end

	-- Challenges
	local ChallengesPage = LegacySystemFrame.ChallengesPage
	local ChallengePointSummary = ChallengesPage.LegacyChallengePointSummary
	HandleProgressBar(ChallengePointSummary.PointsBar, ChallengePointSummary.ProgressBarBackground)

	local CategoryList = ChallengesPage.CategoryList
	S:HandleEditBox(CategoryList.SearchBox)
	S:HandleButton(CategoryList.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleTrimScrollBar(CategoryList.ScrollBar)
	hooksecurefunc(CategoryList.ScrollBox, 'Update', CategoryList_Update)

	local DetailPane = ChallengesPage.DetailPane
	S:HandleTrimScrollBar(DetailPane.ScrollBar)
	hooksecurefunc(DetailPane.ScrollBox, 'Update', DetailPane_Update)
	hooksecurefunc(DetailPane.ScrollBox, 'ApplyEdgeFade', ClearEdgeGradient)

	ChallengesPage.VerticalDivider:Hide()

	if parchmentRemover then
		ChallengesPage.Background:SetAlpha(0)

		CategoryList:CreateBackdrop('Transparent')
		CategoryList.backdrop:Point('TOPLEFT', 0, 8)
		CategoryList.backdrop:Point('BOTTOMRIGHT', -3, 0)

		DetailPane:CreateBackdrop('Transparent')
		DetailPane.backdrop:Point('TOPLEFT', 1, 5)
		DetailPane.backdrop:Point('BOTTOMRIGHT', 18, 0)
	end

	-- Tree
	local TreePage = LegacySystemFrame.TreePage
	local LegacyPointSummary = TreePage.LegacyTreePointSummary
	LegacyPointSummary.AvailablePointsLabel:FontTemplate(nil, 16)

	local TraitPanel = TreePage.LegacyTreeTraitPanel
	S:HandleButton(TraitPanel.ApplyButton)

	local TraitSearch = TraitPanel.SearchBox
	S:HandleEditBox(TraitSearch)

	TraitSearch.backdrop:Point('TOPLEFT', -4, -5)
	TraitSearch.backdrop:Point('BOTTOMRIGHT', 0, 5)

	TraitPanel.SearchPreviewContainer:StripTextures()
	TraitPanel.SearchPreviewContainer:CreateBackdrop('Transparent')

	hooksecurefunc(TraitPanel, 'UpdateButtonFrameLevel', TraitPanel_UpdateButtonFrameLevel)

	TreePage.VerticalDivider:Hide()
	LegacyPointSummary.Border:SetAlpha(0)

	if parchmentRemover then
		TreePage.Background:SetAlpha(0)

		local SelectionPanel = TreePage.LegacyTreeSelectionPanel
		RefreshTreeButtons(SelectionPanel)
		hooksecurefunc(SelectionPanel, 'RefreshTreeButtons', RefreshTreeButtons)

		SelectionPanel:CreateBackdrop('Transparent')
		SelectionPanel.backdrop:Point('TOPLEFT', TreePage, 'TOPLEFT', 6, -72)
		SelectionPanel.backdrop:Point('BOTTOMRIGHT', TraitPanel, 'BOTTOMLEFT', -4, 0)

		TraitPanel:CreateBackdrop('Transparent')
		TraitPanel.backdrop:Point('TOPLEFT', 0, -55)
		TraitPanel.backdrop:Point('BOTTOMRIGHT', 0, 0)
	end
end
