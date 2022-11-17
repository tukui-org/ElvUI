local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local select = select
local unpack = unpack

local CreateColor = CreateColor
local hooksecurefunc = hooksecurefunc

local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo

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

local function UpdateDisplayObjectives(frame)
	local objectives = frame:GetObjectiveFrame()
	if objectives and objectives.progressBars then
		for _, bar in next, objectives.progressBars do
			if not bar.isSkinned then
				S:HandleStatusBar(bar)
				bar.isSkinned = true
			end
		end
	end
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
	bar.Title:Point('LEFT', bar, 'LEFT', 6, 0)
	bar.Text:Point('RIGHT', bar, 'RIGHT', -5, 0)
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

	S:HandleCloseButton(_G.AchievementFrameCloseButton)

	AchievementFrame.Header:StripTextures()
	AchievementFrame.Header.Title:Hide()
	AchievementFrame.Header.Points:Point('TOP', AchievementFrame, 0, -3)

	S:HandleEditBox(AchievementFrame.SearchBox)
	AchievementFrame.SearchBox:ClearAllPoints()
	AchievementFrame.SearchBox:Point('TOPRIGHT', AchievementFrame, 'TOPRIGHT', -25, -2)
	AchievementFrame.SearchBox:Point('BOTTOMLEFT', AchievementFrame, 'TOPRIGHT', -130, -20)

	S:HandleDropDownBox(_G.AchievementFrameFilterDropDown)
	_G.AchievementFrameFilterDropDown:ClearAllPoints()
	_G.AchievementFrameFilterDropDown:Point('RIGHT', AchievementFrame.SearchBox, 'LEFT', 5, -5)

	-- Bottom Tabs
	for i = 1, 3 do
		local tab = _G['AchievementFrameTab'..i]
		if tab then
			S:HandleTab(tab)
		end
	end

	-- Reposition Tabs
	_G.AchievementFrameTab1:ClearAllPoints()
	_G.AchievementFrameTab2:ClearAllPoints()
	_G.AchievementFrameTab3:ClearAllPoints()
	_G.AchievementFrameTab1:Point('TOPLEFT', _G.AchievementFrame, 'BOTTOMLEFT', -3, 0)
	_G.AchievementFrameTab2:Point('TOPLEFT', _G.AchievementFrameTab1, 'TOPRIGHT', -5, 0)
	_G.AchievementFrameTab3:Point('TOPLEFT', _G.AchievementFrameTab2, 'TOPRIGHT', -5, 0)

	local PreviewContainer = AchievementFrame.SearchPreviewContainer
	local ShowAllSearchResults = PreviewContainer.ShowAllSearchResults
	PreviewContainer:StripTextures()
	PreviewContainer:ClearAllPoints()
	PreviewContainer:Point('TOPLEFT', AchievementFrame, 'TOPRIGHT', 7, -2)
	PreviewContainer:CreateBackdrop('Transparent')
	PreviewContainer.backdrop:Point('TOPLEFT', -3, 3)
	PreviewContainer.backdrop:Point('BOTTOMRIGHT', ShowAllSearchResults, 3, -3)

	for i = 1, 5 do
		StyleSearchButton(PreviewContainer['SearchPreview'..i])
	end
	StyleSearchButton(ShowAllSearchResults)

	local Result = AchievementFrame.SearchResults
	Result:Point('BOTTOMLEFT', AchievementFrame, 'BOTTOMRIGHT', 15, -1)
	Result:StripTextures()
	Result:CreateBackdrop('Transparent')
	Result.backdrop:Point('TOPLEFT', -10, 0)
	Result.backdrop:Point('BOTTOMRIGHT')
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

	S:HandleTrimScrollBar(_G.AchievementFrameCategories.ScrollBar)
	S:HandleTrimScrollBar(_G.AchievementFrameAchievements.ScrollBar)

	_G.AchievementFrameSummaryAchievementsHeaderHeader:SetVertexColor(1, 1, 1, .25)
	_G.AchievementFrameSummaryCategoriesHeaderTexture:SetVertexColor(1, 1, 1, .25)
	_G.AchievementFrameWaterMark:SetAlpha(0)

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
				S:HandleIcon(bu.Icon.texture, true)

				bu:CreateBackdrop('Transparent')
				bu.backdrop:Point('TOPLEFT', 2, -2)
				bu.backdrop:Point('BOTTOMRIGHT', -2, 2)

				bu.isSkinned = true
			end

			bu.Description:SetTextColor(.9, .9, .9)
		end
	end)

	if not E.private.skins.parchmentRemoverEnable then
		local r, g, b, a = unpack(E.media.backdropfadecolor)
		_G.AchievementFrameCategories.NineSlice:SetCenterColor(r, g, b, a)
		select(3, _G.AchievementFrameAchievements:GetRegions()):Hide()
	else
		_G.AchievementFrameAchievements:StripTextures()
		select(3, _G.AchievementFrameAchievements:GetChildren()):Hide()

		_G.AchievementFrameCategories:StripTextures()

		_G.AchievementFrameSummary:StripTextures()
		_G.AchievementFrameSummary:GetChildren():Hide()

		hooksecurefunc(_G.AchievementFrameCategories.ScrollBox, 'Update', function(frame)
			for _, child in next, { frame.ScrollTarget:GetChildren() } do
				local button = child.Button
				if button and not button.IsSkinned then
					button:StripTextures()
					button.Background:Hide()
					button:CreateBackdrop('Transparent')
					button.backdrop:Point('TOPLEFT', 0, -1)
					button.backdrop:Point('BOTTOMRIGHT')
					SetupButtonHighlight(button, button.backdrop)

					button.IsSkinned = true
				end
			end
		end)

		_G.AchievementFrameStatsBG:Hide()

		select(4, _G.AchievementFrameStats:GetChildren()):Hide()
		hooksecurefunc(_G.AchievementFrameStats.ScrollBox, 'Update', function(frame)
			for _, child in next, { frame.ScrollTarget:GetChildren() } do
				if not child.IsSkinned then
					child:StripTextures()
					child:CreateBackdrop('Transparent')
					child.backdrop:Point('TOPLEFT', 2, -E.mult)
					child.backdrop:Point('BOTTOMRIGHT', 4, E.mult)
					SetupButtonHighlight(child, child.backdrop)

					child.IsSkinned = true
				end
			end
		end)

		local Comparison = _G.AchievementFrameComparison
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

		Comparison:StripTextures()
		select(5, Comparison:GetChildren()):Hide()

		hooksecurefunc(Comparison.StatContainer.ScrollBox, 'Update', function(frame)
			for _, child in next, { frame.ScrollTarget:GetChildren() } do
				if not child.isSkinned then
					child:StripTextures()
					child:CreateBackdrop('Transparent')
					child.backdrop:Point('TOPLEFT', 2, -E.mult)
					child.backdrop:Point('BOTTOMRIGHT', 6, E.mult)

					child.isSkinned = true
				end
			end
		end)
	end

	for i = 1, 12 do
		local name = 'AchievementFrameSummaryCategoriesCategory'..i

		local bu = _G[name]
		bu:StripTextures()
		bu:SetStatusBarTexture(E.media.normTex)
		bu:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
		bu:CreateBackdrop('Transparent')

		bu.Label:SetTextColor(1, 1, 1)
		bu.Label:Point('LEFT', bu, 'LEFT', 6, 0)
		bu.Text:Point('RIGHT', bu, 'RIGHT', -5, 0)

		_G[name..'ButtonHighlight']:SetAlpha(0)
	end

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
				child.backdrop:Point('TOPLEFT', 1, -1)
				child.backdrop:Point('BOTTOMRIGHT', 0, 2)
				S:HandleIcon(child.Icon.texture, true)

				S:HandleCheckBox(child.Tracked)
				child.Tracked:SetSize(20, 20)
				child.Check:SetAlpha(0)

				hooksecurefunc(child, 'UpdatePlusMinusTexture', UpdateAccountString)
				hooksecurefunc(child, 'DisplayObjectives', UpdateDisplayObjectives)

				child.isSkinned = true
			end
		end
	end)

	hooksecurefunc('AchievementObjectives_DisplayCriteria', function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas, criteria, object = 0, 0
		for i = 1, numCriteria do
			local _, criteriaType, completed, _, _, _, _, assetID = GetAchievementCriteriaInfo(id, i)
			if assetID and criteriaType == _G.CRITERIA_TYPE_ACHIEVEMENT then
				metas = metas + 1
				criteria, object = objectivesFrame:GetMeta(metas), 'Label'
			elseif criteriaType ~= 1 then
				textStrings = textStrings + 1
				criteria, object = objectivesFrame:GetCriteria(textStrings), 'Name'
			end

			local text = criteria and criteria[object]
			if text then
				local r, g, b, x, y
				if completed then
					if objectivesFrame.completed then
						r, g, b, x, y = 1, 1, 1, 0, 0
					else
						r, g, b, x, y = 0, 1, 0, 1, -1
					end
				else
					r, g, b, x, y = .6, .6, .6, 1, -1
				end

				text:SetTextColor(r, g, b)
				text:SetShadowOffset(x, y)
			end
		end
	end)

	SkinStatusBar(_G.AchievementFrameSummaryCategoriesStatusBar)
	_G.AchievementFrameSummaryAchievementsEmptyText:SetText('')
	_G.AchievementFrameStatsBG:SetInside(_G.AchievementFrameStats.ScrollBox, 1, 1)
	S:HandleTrimScrollBar(_G.AchievementFrameStats.ScrollBar)

	-- Comparison
	local Comparison = _G.AchievementFrameComparison
	_G.AchievementFrameComparisonHeaderBG:Hide()
	_G.AchievementFrameComparisonHeaderPortrait:Hide()
	_G.AchievementFrameComparisonHeaderPortraitBg:Hide()
	_G.AchievementFrameComparisonHeader:Point('BOTTOMRIGHT', Comparison, 'TOPRIGHT', 39, 26)
	_G.AchievementFrameComparisonHeader:CreateBackdrop('Transparent')
	_G.AchievementFrameComparisonHeader.backdrop:Point('TOPLEFT', 20, -20)
	_G.AchievementFrameComparisonHeader.backdrop:Point('BOTTOMRIGHT', -28, -5)

	S:HandleTrimScrollBar(Comparison.AchievementContainer.ScrollBar)

	HandleSummaryBar(Comparison.Summary.Player)
	HandleSummaryBar(Comparison.Summary.Friend)

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
