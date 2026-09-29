local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

-- /run ToggleLegacySystemUI()

local function HandleProgressBar(bar, background)
	S:HandleStatusBar(bar)
	bar.Text:FontTemplate()
	background:SetAlpha(0)
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
	local backdrop = overlay:GetParent().backdrop
	if shown then
		backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		backdrop:SetBackdropBorderColor(r, g, b)
	end
end

-- LegacyChallengeTemplate, achievement style cards in the detail pane
local function HandleChallenge(button)
	if button.IsSkinned then return end

	button.Background:SetAlpha(0)
	button.BackgroundTop:SetAlpha(0)
	button.BackgroundMiddle:SetAlpha(0)
	button.BackgroundBottom:SetAlpha(0)
	button.TitleBar:SetAlpha(0)
	button.SelectedOverlay:SetAlpha(0)

	button:CreateBackdrop('Transparent')

	button.Icon.frame:Hide()
	button.Icon.texture:RemoveMaskTexture(button.Icon.TextureMask)
	S:HandleIcon(button.Icon.texture, true)

	button.Shield.CheckBackground:SetAlpha(0)

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

-- LegacyChallengeCategoryTemplate (ListHeaderVisualTemplate), keep the Blizzard plus / minus
local function HandleCategory(button)
	if button.IsSkinned then return end

	S:HandleButton(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetHighlightTexture():SetAlpha(0)

	button.IsSkinned = true
end

local function CategoryList_Update(frame)
	frame:ForEachFrame(HandleCategory)
end

local function RefreshTreeButtons(panel)
	for _, button in next, panel.treeButtons do
		button.Background:SetAlpha(0)
	end
end

function S:Blizzard_LegacySystem()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.legacySystem) then return end

	local LegacySystemFrame = _G.LegacySystemFrame
	S:HandlePortraitFrame(LegacySystemFrame)

	for _, tab in next, LegacySystemFrame.Tabs do
		S:HandleLargeSideTab(tab)
	end

	S:LayoutLargeSideTabs(LegacySystemFrame, LegacySystemFrame.Tabs)

	-- Reward Track
	local RewardTrackPage = LegacySystemFrame.RewardTrackPage
	HandleProgressBar(RewardTrackPage.LegacyRewardProgressBar, RewardTrackPage.ProgressBarBackground)
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

	if parchmentRemover then
		ChallengesPage.Background:SetAlpha(0)
		ChallengesPage.VerticalDivider:Hide()
	end

	-- Tree
	local TreePage = LegacySystemFrame.TreePage
	local LegacyPointSummary = TreePage.LegacyTreePointSummary
	LegacyPointSummary.AvailablePointsLabel:FontTemplate(nil, 16)

	local TraitPanel = TreePage.LegacyTreeTraitPanel
	S:HandleButton(TraitPanel.ApplyButton)
	S:HandleEditBox(TraitPanel.SearchBox)
	TraitPanel.SearchBox.backdrop:Point('TOPLEFT', -4, -5)
	TraitPanel.SearchBox.backdrop:Point('BOTTOMRIGHT', 0, 5)
	TraitPanel.SearchPreviewContainer:StripTextures()
	TraitPanel.SearchPreviewContainer:CreateBackdrop('Transparent')

	if parchmentRemover then
		TreePage.Background:SetAlpha(0)
		TreePage.VerticalDivider:Hide()
		LegacyPointSummary.Border:SetAlpha(0)

		local SelectionPanel = TreePage.LegacyTreeSelectionPanel
		RefreshTreeButtons(SelectionPanel)
		hooksecurefunc(SelectionPanel, 'RefreshTreeButtons', RefreshTreeButtons)
	end
end

S:AddCallbackForAddon('Blizzard_LegacySystem')
