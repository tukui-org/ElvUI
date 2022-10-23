local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local select = select

local CreateColor = CreateColor
local hooksecurefunc = hooksecurefunc

local function SetupButtonHighlight(button, backdrop)
	if not button then return end

	button:SetHighlightTexture(E.media.normTex)

	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(0.8, 0.8, 0.8, .25)
	hl:SetInside(backdrop)
end

local function StyleSearchButton(button)
	if not button then return end

	button:StripTextures()
	button:CreateBackdrop('Transparent')
	local icon = button.icon or button.Icon
	if icon then
		S:HandleIcon(icon)
	end

	button:SetHighlightTexture(E.media.normTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(0.8, 0.8, 0.8, .25)
	hl:SetInside()
end

local function UpdateAccountString(button)
	if button.DateCompleted:IsShown() then
		if button.accountWide then
			button.Label:SetTextColor(0, .6, 1)
		else
			button.Label:SetTextColor(.9, .9, .9)
		end
	elseif button.accountWide then
		button.Label:SetTextColor(0, .3, .5)
	else
		button.Label:SetTextColor(.65, .65, .65)
	end
end

local function HideBackdrop(frame)
	if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
	if frame.SetBackdrop then frame:SetBackdrop(nil) end
end

local function SkinStatusBar(bar)
	bar:StripTextures()
	bar:SetStatusBarTexture(E.media.normTex)
	bar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
	bar:CreateBackdrop()
	E:RegisterStatusBar(bar)

	local StatusBarName = bar:GetName()

	local title = _G[StatusBarName..'Title']
	if title then title:Point('LEFT', 4, 0) end

	local label = _G[StatusBarName..'Label']
	if label then label:Point('LEFT', 4, 0) end

	local text = _G[StatusBarName..'Text']
	if text then text:Point('RIGHT', -4, 0) end
end

local function HandleSummaryBar(frame)
	frame:StripTextures()
	local bar = frame.StatusBar
	bar:StripTextures()
	bar:SetStatusBarTexture(E.media.normTex)
	bar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
	bar.Title:SetTextColor(1, 1, 1)
	bar.Title:SetPoint('LEFT', bar, 'LEFT', 6, 0)
	bar.Text:SetPoint('RIGHT', bar, 'RIGHT', -5, 0)
	bar:CreateBackdrop('Transparent')
end

local function HandleCompareCategory(button)
	button:DisableDrawLayer('BORDER')
	HideBackdrop(button)
	button.Background:Hide()
	button:CreateBackdrop('Transparent')
	button.backdrop:SetInside(button, 2, 2)

	button.TitleBar:Hide()
	button.Glow:Hide()
	button.Icon.frame:Hide()
	S:HandleIcon(button.Icon.texture)
end

function S:Blizzard_AchievementUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.achievement) then return end

	local AchievementFrame = _G.AchievementFrame
	AchievementFrame:StripTextures()
	AchievementFrame:SetTemplate('Transparent')
	_G.AchievementFrameWaterMark:SetAlpha(0)
	S:HandleCloseButton(_G.AchievementFrameCloseButton)

	AchievementFrame.Header:StripTextures()
	AchievementFrame.Header.Title:Hide()
	AchievementFrame.Header.Points:SetPoint('TOP', AchievementFrame, 0, -3)

	for i = 1, 3 do
		local tab = _G['AchievementFrameTab'..i]
		if tab then
			S:HandleTab(tab)
		end
	end

	S:HandleEditBox(AchievementFrame.SearchBox)
	AchievementFrame.SearchBox:ClearAllPoints()
	AchievementFrame.SearchBox:SetPoint('TOPRIGHT', AchievementFrame, 'TOPRIGHT', -25, -5)
	AchievementFrame.SearchBox:SetPoint('BOTTOMLEFT', AchievementFrame, 'TOPRIGHT', -130, -25)

	S:HandleDropDownBox(_G.AchievementFrameFilterDropDown)
	_G.AchievementFrameFilterDropDown:ClearAllPoints()
	_G.AchievementFrameFilterDropDown:SetPoint('RIGHT', AchievementFrame.SearchBox, 'LEFT', 5, -4)

	local PreviewContainer = AchievementFrame.SearchPreviewContainer
	local ShowAllSearchResults = PreviewContainer.ShowAllSearchResults
	PreviewContainer:StripTextures()
	PreviewContainer:ClearAllPoints()
	PreviewContainer:SetPoint('TOPLEFT', AchievementFrame, 'TOPRIGHT', 7, -2)
	PreviewContainer:CreateBackdrop('Transparent')
	PreviewContainer.backdrop:SetPoint('TOPLEFT', -3, 3)
	PreviewContainer.backdrop:SetPoint('BOTTOMRIGHT', ShowAllSearchResults, 3, -3)

	for i = 1, 5 do
		StyleSearchButton(PreviewContainer['SearchPreview'..i])
	end
	StyleSearchButton(ShowAllSearchResults)

	local Result = AchievementFrame.SearchResults
	Result:SetPoint('BOTTOMLEFT', AchievementFrame, 'BOTTOMRIGHT', 15, -1)
	Result:StripTextures()
	Result:CreateBackdrop('Transparent')
	Result.backdrop:SetPoint('TOPLEFT', -10, 0)
	Result.backdrop:SetPoint('BOTTOMRIGHT')
	S:HandleCloseButton(Result.CloseButton)
	S:HandleTrimScrollBar(Result.ScrollBar)

	hooksecurefunc(Result.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				child:StripTextures()
				S:HandleIcon(child.Icon)
				child:CreateBackdrop('Transparent')
				child.backdrop:SetInside()
				SetupButtonHighlight(child, child.backdrop)

				child.isSkinned = true
			end
		end
	end)

	_G.AchievementFrameCategories:StripTextures()
	S:HandleTrimScrollBar(_G.AchievementFrameCategories.ScrollBar)
	hooksecurefunc(_G.AchievementFrameCategories.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			local button = child.Button
			if button and not button.styled then
				button:StripTextures()
				button.Background:Hide()
				button:CreateBackdrop('Transparent')
				button.backdrop:SetPoint('TOPLEFT', 0, -1)
				button.backdrop:SetPoint('BOTTOMRIGHT')
				SetupButtonHighlight(button, button.backdrop)

				button.styled = true
			end
		end
	end)

	_G.AchievementFrameAchievements:StripTextures()
	S:HandleTrimScrollBar(_G.AchievementFrameAchievements.ScrollBar)
	select(3, _G.AchievementFrameAchievements:GetChildren()):Hide()

	hooksecurefunc(_G.AchievementFrameAchievements.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				child:StripTextures(true)
				child.Background:SetAlpha(0)
				child.Highlight:SetAlpha(0)
				child.Icon.frame:Hide()
				child.Description:SetTextColor(.9, .9, .9)
				child.Description.SetTextColor = E.noop

				child:CreateBackdrop('Transparent')
				child.backdrop:SetPoint('TOPLEFT', 1, -1)
				child.backdrop:SetPoint('BOTTOMRIGHT', 0, 2)
				S:HandleIcon(child.Icon.texture)

				S:HandleCheckBox(child.Tracked)
				child.Tracked:SetSize(20, 20)
				child.Check:SetAlpha(0)

				hooksecurefunc(child, 'UpdatePlusMinusTexture', UpdateAccountString)

				child.isSkinned = true
			end
		end
	end)

	_G.AchievementFrameSummary:StripTextures()
	_G.AchievementFrameSummary:GetChildren():Hide()
	_G.AchievementFrameSummaryAchievementsHeaderHeader:SetVertexColor(1, 1, 1, .25)
	_G.AchievementFrameSummaryCategoriesHeaderTexture:SetVertexColor(1, 1, 1, .25)

	hooksecurefunc('AchievementFrameSummary_UpdateAchievements', function()
		for i = 1, _G.ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local bu = _G['AchievementFrameSummaryAchievement'..i]
			if bu.accountWide then
				bu.Label:SetTextColor(0, .6, 1)
			else
				bu.Label:SetTextColor(.9, .9, .9)
			end

			if not bu.isSkinned then
				bu:StripTextures(true)
				bu:DisableDrawLayer('BORDER')
				HideBackdrop(bu)

				local bd = bu.Background
				bd:SetTexture(E.media.normTex)
				bd:SetVertexColor(0, 0, 0, .25)

				bu.TitleBar:Hide()
				bu.Glow:Hide()
				bu.Highlight:SetAlpha(0)
				bu.Icon.frame:Hide()
				S:HandleIcon(bu.Icon.texture)

				bu:CreateBackdrop('Transparent')
				bu.backdrop:SetPoint('TOPLEFT', 2, -2)
				bu.backdrop:SetPoint('BOTTOMRIGHT', -2, 2)

				bu.isSkinned = true
			end

			bu.Description:SetTextColor(.9, .9, .9)
		end
	end)

	for i = 1, 12 do
		local name = 'AchievementFrameSummaryCategoriesCategory'..i

		local bu = _G[name]
		bu:StripTextures()
		bu:SetStatusBarTexture(E.media.normTex)
		bu:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
		bu:CreateBackdrop('Transparent')

		bu.Label:SetTextColor(1, 1, 1)
		bu.Label:SetPoint('LEFT', bu, 'LEFT', 6, 0)
		bu.Text:SetPoint('RIGHT', bu, 'RIGHT', -5, 0)

		_G[name..'ButtonHighlight']:SetAlpha(0)
	end

	SkinStatusBar(_G.AchievementFrameSummaryCategoriesStatusBar)

	_G.AchievementFrameSummaryAchievementsEmptyText:SetText('')

	-- Summary
	_G.AchievementFrameStatsBG:Hide()
	select(4, _G.AchievementFrameStats:GetChildren()):Hide()
	S:HandleTrimScrollBar(_G.AchievementFrameStats.ScrollBar)

	hooksecurefunc(_G.AchievementFrameStats.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.IsSkinned then
				child:StripTextures()
				child:CreateBackdrop('Transparent')
				child.backdrop:SetPoint('TOPLEFT', 2, -E.mult)
				child.backdrop:SetPoint('BOTTOMRIGHT', 4, E.mult)
				SetupButtonHighlight(child, child.backdrop)

				child.IsSkinned = true
			end
		end
	end)

	-- Comparison
	local Comparison = _G.AchievementFrameComparison
	_G.AchievementFrameComparisonHeaderBG:Hide()
	_G.AchievementFrameComparisonHeaderPortrait:Hide()
	_G.AchievementFrameComparisonHeaderPortraitBg:Hide()
	_G.AchievementFrameComparisonHeader:SetPoint('BOTTOMRIGHT', Comparison, 'TOPRIGHT', 39, 26)
	_G.AchievementFrameComparisonHeader:CreateBackdrop('Transparent')
	_G.AchievementFrameComparisonHeader.backdrop:SetPoint('TOPLEFT', 20, -20)
	_G.AchievementFrameComparisonHeader.backdrop:SetPoint('BOTTOMRIGHT', -28, -5)

	Comparison:StripTextures()
	select(5, Comparison:GetChildren()):Hide()
	S:HandleTrimScrollBar(Comparison.AchievementContainer.ScrollBar)

	HandleSummaryBar(Comparison.Summary.Player)
	HandleSummaryBar(Comparison.Summary.Friend)

	hooksecurefunc(Comparison.AchievementContainer.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				HandleCompareCategory(child.Player)
				child.Player.Description:SetTextColor(.9, .9, .9)
				child.Player.Description.SetTextColor = E.noop
				HandleCompareCategory(child.Friend)

				child.isSkinned = true
			end
		end
	end)

	hooksecurefunc(Comparison.StatContainer.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				child:StripTextures()
				child:CreateBackdrop('Transparent')
				child.backdrop:SetPoint('TOPLEFT', 2, -E.mult)
				child.backdrop:SetPoint('BOTTOMRIGHT', 6, E.mult)

				child.isSkinned = true
			end
		end
	end)

	S:HandleTrimScrollBar(Comparison.StatContainer.ScrollBar)

	-- The section below is usually handled in our hook but another addon
	-- may have loaded the AchievementUI before we were ready. <Categories>
	local index = 1
	local button = _G['AchievementFrameCategoriesContainerButton'..index]
	while button do
		if not button.isSkinned then
			button:StripTextures(true)
			button:StyleButton()

			button.isSkinned = true
		end

		index = 1
		button = _G['AchievementFrameCategoriesContainerButton'..index]
	end
end

S:AddCallbackForAddon('Blizzard_AchievementUI')
