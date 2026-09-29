local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local select = select
local unpack = unpack
local bitband = bit.band
local hooksecurefunc = hooksecurefunc

local CreateColor = CreateColor
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo

local FLAG_PROGRESS_BAR = EVALUATION_TREE_FLAG_PROGRESS_BAR

local blueAchievement = { r = 0.1, g = 0.2, b = 0.3, a = 1 }

local data = S:AddCallbackForAddon('Blizzard_AchievementUI')
data.toggle = 'achievement'

local function SetupButtonHighlight(button, backdrop)
	button:SetHighlightTexture(E.media.normTex)

	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(0.8, 0.8, 0.8, .25)
	hl:SetInside(backdrop)
end

local function StyleSearchButton(button)
	S:HandleFrame(button, true)

	local icon = button.Icon
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
	for _, bar in next, objectives.progressBars do
		if not bar.IsSkinned then
			S:HandleStatusBar(bar)
			bar.IsSkinned = true
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

local function SkinStatusBar(bar)
	S:HandleStatusBar(bar)
	bar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))

	local name = bar:GetName()
	_G[name..'Title']:Point('LEFT', 4, 0)
	_G[name..'Text']:Point('RIGHT', -4, 0)
end

local function HandleSummaryBar(frame)
	frame:StripTextures()
	local bar = E.Modern and frame.StatusBar or frame.statusBar
	S:HandleStatusBar(bar)
	bar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))

	local title = E.Modern and bar.Title or bar.title
	title:SetTextColor(1, 1, 1)
	title:Point('LEFT', bar, 'LEFT', 6, 0)

	local text = E.Modern and bar.Text or bar.text
	text:Point('RIGHT', bar, 'RIGHT', -5, 0)
end

local function HandleCompareCategory(button)
	button:DisableDrawLayer('BORDER')
	button.NineSlice:SetAlpha(0)
	button.Background:Hide()
	button:CreateBackdrop('Transparent')
	button.backdrop:SetInside(button, 2, 2)

	button.TitleBar:Hide()
	button.Glow:Hide()
	button.Icon.frame:Hide()
	S:HandleIcon(button.Icon.texture)
end

local function ResultScrollUpdateChild(child)
	if not child.IsSkinned then
		child:StripTextures()
		S:HandleIcon(child.Icon)
		child:CreateBackdrop('Transparent')
		child.backdrop:SetInside()
		SetupButtonHighlight(child, child.backdrop)

		child.IsSkinned = true
	end
end

local function ResultScrollUpdate(frame)
	frame:ForEachFrame(ResultScrollUpdateChild)
end

local function AchievementFrameCategoriesScrollUpdateChild(child)
	local button = child.Button
	if not button.IsSkinned then
		S:HandleFrame(button, true, nil, 0, -1)
		button.Background:Hide()
		SetupButtonHighlight(button, button.backdrop)

		button.IsSkinned = true
	end
end

local function AchievementFrameCategoriesScrollUpdate(frame)
	frame:ForEachFrame(AchievementFrameCategoriesScrollUpdateChild)
end

local function AchievementFrameStatsScrollUpdateChild(child)
	if not child.IsSkinned then
		S:HandleFrame(child, true, nil, 2, -E.mult, 4, E.mult)
		SetupButtonHighlight(child, child.backdrop)

		child.IsSkinned = true
	end
end

local function AchievementFrameStatsScrollUpdate(frame)
	frame:ForEachFrame(AchievementFrameStatsScrollUpdateChild)
end

local function ComparisonContainerScrollUpdateChild(child)
	if not child.IsSkinned then
		HandleCompareCategory(child.Player)
		child.Player.Description:SetTextColor(.9, .9, .9)
		child.Player.Description.SetTextColor = E.noop
		HandleCompareCategory(child.Friend)

		child.IsSkinned = true
	end
end

local function ComparisonContainerScrollUpdate(frame)
	frame:ForEachFrame(ComparisonContainerScrollUpdateChild)
end

local function ComparisonStatContainerScrollUpdateChild(child)
	if not child.IsSkinned then
		S:HandleFrame(child, true, nil, 2, -E.mult, 6, E.mult)

		child.IsSkinned = true
	end
end

local function ComparisonStatContainerScrollUpdate(frame)
	frame:ForEachFrame(ComparisonStatContainerScrollUpdateChild)
end

local function AchievementFrameAchievementsScrollUpdateChild(child)
	if not child.IsSkinned then
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

		child.IsSkinned = true
	end

end

local function AchievementFrameAchievementsScrollUpdate(frame)
	frame:ForEachFrame(AchievementFrameAchievementsScrollUpdateChild)
end

local function UpdateTabs()
	for i = 1, 3 do
		local tab = _G['AchievementFrameTab'..i]
		tab.Text:ClearAllPoints()
		tab.Text:Point('CENTER', tab)
	end
end

-- Mists anchors the statistics tab again on every open, next to the guild tab only while that one is shown
local function SetTabs()
	local tab = _G.AchievementFrameTab3
	tab:ClearAllPoints()
	tab:Point('TOPLEFT', _G.AchievementFrameTab2:IsShown() and _G.AchievementFrameTab2 or _G.AchievementFrameTab1, 'TOPRIGHT', -19, 0)
end

local function UpdateAchievements()
	for i = 1, _G.ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
		local bu = _G['AchievementFrameSummaryAchievement'..i]
		if bu.accountWide then
			bu.Label:SetTextColor(0, .6, 1)
		else
			bu.Label:SetTextColor(.9, .9, .9)
		end

		if not bu.IsSkinned then
			bu:StripTextures(true)
			bu:DisableDrawLayer('BORDER')
			bu.NineSlice:SetAlpha(0)

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

			bu.IsSkinned = true
		end

		bu.Description:SetTextColor(.9, .9, .9)
	end
end

local function BlueBackdrop(frame)
	frame:SetBackdropColor(blueAchievement.r, blueAchievement.g, blueAchievement.b)
end

local function DescriptionTextColor(text, r, g, b)
	if r == 0 and g == 0 and b == 0 then
		text:SetTextColor(0.6, 0.6, 0.6)
	end
end

local function AchievementOnEnter(frame)
	frame.backdrop:SetBackdropBorderColor(1, 1, 0)
end

local function AchievementOnLeave(frame)
	frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function SkinAch(Achievement, BiggerIcon)
	if Achievement.IsSkinned then return end

	Achievement:OffsetFrameLevel(2)
	Achievement:StripTextures(true)
	Achievement:CreateBackdrop(nil, true)
	Achievement.backdrop:SetInside()

	Achievement.icon:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
	Achievement.icon:Size(BiggerIcon and 54 or 36, BiggerIcon and 54 or 36)
	Achievement.icon:ClearAllPoints()
	Achievement.icon:Point('TOPLEFT', 8, -8)
	Achievement.icon.bling:Kill()
	Achievement.icon.frame:Kill()
	Achievement.icon.texture:SetTexCoords()
	Achievement.icon.texture:SetInside()

	if Achievement.highlight then
		Achievement.highlight:StripTextures()
		Achievement:HookScript('OnEnter', AchievementOnEnter)
		Achievement:HookScript('OnLeave', AchievementOnLeave)
	end

	if Achievement.label then
		Achievement.label:SetTextColor(1, 1, 1)
	end

	if Achievement.description then
		Achievement.description:SetTextColor(.6, .6, .6)
		hooksecurefunc(Achievement.description, 'SetTextColor', DescriptionTextColor)
	end

	if Achievement.hiddenDescription then
		Achievement.hiddenDescription:SetTextColor(1, 1, 1)
	end

	if Achievement.tracked then
		Achievement.tracked:GetRegions():SetTextColor(1, 1, 1)
		S:HandleCheckBox(Achievement.tracked)
		Achievement.tracked:Size(18)
		Achievement.tracked:ClearAllPoints()
		Achievement.tracked:Point('TOPLEFT', Achievement.icon, 'BOTTOMLEFT', 0, -2)
	end

	Achievement.IsSkinned = true
end

local function PlayerSaturate(frame) -- frame is Achievement.player
	local Achievement = frame:GetParent()

	local r, g, b = unpack(E.media.backdropcolor)
	Achievement.player.backdrop.callbackBackdropColor = nil
	Achievement.friend.backdrop.callbackBackdropColor = nil

	if Achievement.player.accountWide then
		r, g, b = blueAchievement.r, blueAchievement.g, blueAchievement.b
		Achievement.player.backdrop.callbackBackdropColor = BlueBackdrop
		Achievement.friend.backdrop.callbackBackdropColor = BlueBackdrop
	end

	Achievement.player.backdrop:SetBackdropColor(r, g, b)
	Achievement.friend.backdrop:SetBackdropColor(r, g, b)
end

local function SkinAchievementButton(button)
	if button.IsSkinned then return end

	SkinAch(button.player)
	SkinAch(button.friend)

	hooksecurefunc(button.player, 'Saturate', PlayerSaturate)

	button.IsSkinned = true
end

local function SetAchievementColor(frame)
	if frame and frame.backdrop then
		if frame.accountWide then
			frame.backdrop.callbackBackdropColor = BlueBackdrop
			frame.backdrop:SetBackdropColor(blueAchievement.r, blueAchievement.g, blueAchievement.b)
		else
			frame.backdrop.callbackBackdropColor = nil
			frame.backdrop:SetBackdropColor(unpack(E.media.backdropcolor))
		end
	end
end

local function ScrollCreateButtons(frame, template)
	local parchmentRemover = E.private.skins.parchmentRemoverEnable
	if template == 'AchievementCategoryTemplate' and parchmentRemover then
		for _, category in next, frame.buttons do
			if not category.IsSkinned then
				category:StripTextures(true)
				category:StyleButton()

				category.IsSkinned = true
			end
		end
	elseif template == 'StatTemplate' and parchmentRemover then
		for _, stats in next, frame.buttons do
			if not stats.IsSkinned then
				stats:StyleButton()

				stats.IsSkinned = true
			end
		end
	elseif template == 'AchievementTemplate' then
		for _, achievement in next, frame.buttons do
			if not achievement.IsSkinned then
				SkinAch(achievement, true)
			end
		end
	elseif template == 'ComparisonTemplate' and parchmentRemover then
		for _, comparison in next, frame.buttons do
			if not comparison.IsSkinned then
				SkinAchievementButton(comparison)
			end
		end
	end
end

local function HookHybridScrollButtons()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.achievement) then return end

	hooksecurefunc('HybridScrollFrame_CreateButtons', ScrollCreateButtons)

	-- if AchievementUI was loaded by another addon before us, these buttons won't exist when Blizzard_AchievementUI is called.
	-- however, it can also be too late to hook HybridScrollFrame_CreateButtons, so we need to skin them here, weird...
	local parchmentRemover = E.private.skins.parchmentRemoverEnable
	for i = 1, 20 do
		local category = _G['AchievementFrameCategoriesContainerButton'..i]
		if parchmentRemover and category and not category.IsSkinned then
			category:StripTextures(true)
			category:StyleButton()

			category.IsSkinned = true
		end

		local stats = _G['AchievementFrameStatsContainerButton'..i]
		if parchmentRemover and stats and not stats.IsSkinned then
			stats:StyleButton()

			stats.IsSkinned = true
		end

		if i <= 10 then
			local achievement = _G['AchievementFrameAchievementsContainerButton'..i]
			if achievement and not achievement.IsSkinned then
				SkinAch(achievement, true)

			end

			local comparison = _G['AchievementFrameComparisonContainerButton'..i]
			if parchmentRemover and comparison and not comparison.IsSkinned then
				SkinAchievementButton(comparison)
			end
		end
	end
end

local function UpdateClassicAchievements()
	for i = 1, _G.ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
		local frame = _G['AchievementFrameSummaryAchievement'..i]
		if not frame.IsSkinned then
			SkinAch(frame)
		end

		--The backdrop borders tend to overlap so add a little more space between summary achievements
		local prevFrame = _G['AchievementFrameSummaryAchievement'..i-1]
		if i ~= 1 then
			frame:ClearAllPoints()
			frame:Point('TOPLEFT', prevFrame, 'BOTTOMLEFT', 0, 1)
			frame:Point('TOPRIGHT', prevFrame, 'BOTTOMRIGHT', 0, 1)
		end

		SetAchievementColor(frame)
	end
end

local function GetProgressBar(index)
	local frame = _G['AchievementFrameProgressBar'..index]
	if frame and not frame.IsSkinned then
		S:HandleStatusBar(frame)
		frame.IsSkinned = true
	end
end

local function DisplayCriteria(objectivesFrame, id)
	local numCriteria = GetAchievementNumCriteria(id)
	local textStrings, metas, criteria, object = 0, 0
	for i = 1, numCriteria do
		local _, criteriaType, completed, _, _, _, flags, assetID = GetAchievementCriteriaInfo(id, i)
		if assetID and criteriaType == _G.CRITERIA_TYPE_ACHIEVEMENT then
			metas = metas + 1

			if E.Modern then
				criteria, object = objectivesFrame:GetMeta(metas), 'Label'
			else
				criteria, object = _G.AchievementButton_GetMeta(metas), 'label'
			end
		elseif bitband(flags, FLAG_PROGRESS_BAR) == FLAG_PROGRESS_BAR then
			criteria, object = nil, nil
		else
			textStrings = textStrings + 1

			if E.Modern then
				criteria, object = objectivesFrame:GetCriteria(textStrings), 'Name'
			else
				criteria, object = _G.AchievementButton_GetCriteria(textStrings), 'name'
			end
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
end

function S:Blizzard_AchievementUI()
	local AchievementFrame = _G.AchievementFrame
	if E.Modern then
		S:HandleFrame(AchievementFrame)
	else -- the classic filter dropdown sits above the frame
		S:HandleFrame(AchievementFrame, true, nil, 0, 7)
		_G.AchievementFrameCloseButton:Point('TOPRIGHT', AchievementFrame.backdrop, 'TOPRIGHT', 2, 2)
	end

	local header = E.Modern and AchievementFrame.Header or _G.AchievementFrameHeader
	header:StripTextures()

	local headerTitle = E.Modern and header.Title or _G.AchievementFrameHeaderTitle
	headerTitle:Hide()

	local headerPoints = E.Modern and header.Points or _G.AchievementFrameHeaderPoints
	headerPoints:Point('TOP', AchievementFrame, 0, -3)

	if E.Modern then
		local headerDetails = AchievementFrame.HeaderDetails
		headerDetails.TopTileStreaks:SetAlpha(0)
		S:HandleButton(headerDetails.Back)
		local searchBox = headerDetails.Filters.SearchBox
		S:HandleEditBox(searchBox)
		local filterDropdown = headerDetails.Filters.FilterDropdown
		S:HandleButton(filterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')

		local PreviewContainer = searchBox.SearchPreviewContainer
		local ShowAllSearchResults = PreviewContainer.ShowAllSearchResults
		S:HandleFrame(PreviewContainer, true, nil, -3, 3)
		PreviewContainer.backdrop:Point('BOTTOMRIGHT', ShowAllSearchResults, 3, -3)

		for i = 1, 5 do
			StyleSearchButton(PreviewContainer['SearchPreview'..i])
		end
		StyleSearchButton(ShowAllSearchResults)

		local Result = AchievementFrame.SearchResults
		Result:Point('BOTTOMLEFT', AchievementFrame, 'BOTTOMRIGHT', 15, -1)
		S:HandleFrame(Result, true, nil, -8)
		S:HandleTrimScrollBar(Result.ScrollBar)

		hooksecurefunc(Result.ScrollBox, 'Update', ResultScrollUpdate)

		S:HandleTrimScrollBar(_G.AchievementFrameCategories.ScrollBar)
		S:HandleTrimScrollBar(_G.AchievementFrameAchievements.ScrollBar)
		S:HandleTrimScrollBar(_G.AchievementFrameStats.ScrollBar)

		hooksecurefunc(_G.AchievementFrameAchievements.ScrollBox, 'Update', AchievementFrameAchievementsScrollUpdate)
	else
		-- reset by AchievementFrame_LoadTextures on show
		_G.AchievementFrameHeaderLeft:Hide()
		_G.AchievementFrameHeaderRight:Hide()
		_G.AchievementFrameHeaderPointBorder:Hide()
		_G.AchievementFrameCategoriesBG:SetAlpha(0)

		local filterDropdown = _G.AchievementFrameFilterDropdown
		S:HandleButton(filterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
		filterDropdown:ClearAllPoints()
		filterDropdown:Point('TOPLEFT', _G.AchievementFrameAchievements, 'TOPLEFT', -18, 24)

		_G.AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)

		for _, scrollbar in next, {
			_G.AchievementFrameCategoriesContainerScrollBar,
			_G.AchievementFrameAchievementsContainerScrollBar,
			_G.AchievementFrameStatsContainerScrollBar,
			_G.AchievementFrameComparisonContainerScrollBar,
			_G.AchievementFrameComparisonStatsContainerScrollBar,
		} do
			S:HandleScrollBar(scrollbar)
		end

		hooksecurefunc('AchievementButton_DisplayAchievement', SetAchievementColor)
		hooksecurefunc('AchievementButton_GetProgressBar', GetProgressBar)
	end

	-- Bottom Tabs
	for i = 1, E.Wrath and 2 or 3 do -- no guild tab on Wrath
		local tab = _G['AchievementFrameTab'..i]
		S:HandleTab(tab)
		tab:ClearAllPoints()
	end

	-- Reposition Tabs
	_G.AchievementFrameTab1:Point('TOPLEFT', _G.AchievementFrame, 'BOTTOMLEFT', E.Modern and -3 or -10, 0)
	_G.AchievementFrameTab2:Point('TOPLEFT', _G.AchievementFrameTab1, 'TOPRIGHT', E.Modern and -5 or -19, 0)

	if E.Modern then
		_G.AchievementFrameTab3:Point('TOPLEFT', _G.AchievementFrameTab2, 'TOPRIGHT', -5, 0)

		-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_AchievementUI/Mainline/Blizzard_AchievementUI.lua#L337-L343
		hooksecurefunc('AchievementFrame_UpdateTabs', UpdateTabs)
	elseif E.Mists then
		hooksecurefunc('AchievementFrame_SetTabs', SetTabs)
		SetTabs()
	end

	_G.AchievementFrameSummaryAchievementsHeaderHeader:SetVertexColor(1, 1, 1, .25)
	_G.AchievementFrameSummaryCategoriesHeaderTexture:SetVertexColor(1, 1, 1, .25)
	_G.AchievementFrameWaterMark:SetAlpha(0)

	hooksecurefunc('AchievementFrameSummary_UpdateAchievements', E.Modern and UpdateAchievements or UpdateClassicAchievements)

	if not E.private.skins.parchmentRemoverEnable then
		local r, g, b, a = unpack(E.media.backdropfadecolor)
		_G.AchievementFrameCategories.NineSlice:SetCenterColor(r, g, b, a)
		select(3, _G.AchievementFrameAchievements:GetRegions()):Hide()
	else
		_G.AchievementFrameAchievements:StripTextures()
		select(E.Modern and 3 or 2, _G.AchievementFrameAchievements:GetChildren()):Hide()

		_G.AchievementFrameCategories:StripTextures()

		_G.AchievementFrameSummary:StripTextures()
		_G.AchievementFrameSummary:GetChildren():Hide()

		_G.AchievementFrameStatsBG:Hide()
		select(E.Modern and 4 or 3, _G.AchievementFrameStats:GetChildren()):Hide()

		local Comparison = _G.AchievementFrameComparison
		Comparison:StripTextures()
		select(5, Comparison:GetChildren()):Hide()

		if E.Modern then
			hooksecurefunc(_G.AchievementFrameCategories.ScrollBox, 'Update', AchievementFrameCategoriesScrollUpdate)
			hooksecurefunc(_G.AchievementFrameStats.ScrollBox, 'Update', AchievementFrameStatsScrollUpdate)
			hooksecurefunc(Comparison.AchievementContainer.ScrollBox, 'Update', ComparisonContainerScrollUpdate)
			hooksecurefunc(Comparison.StatContainer.ScrollBox, 'Update', ComparisonStatContainerScrollUpdate)
		else
			-- reset by AchievementFrame_LoadTextures on show
			_G.AchievementFrameAchievementsBackground:Hide()
			_G.AchievementFrameSummaryBackground:Hide()
			_G.AchievementFrameComparisonBackground:Hide()
			_G.AchievementFrameComparisonWatermark:SetAlpha(0)

			_G.AchievementFrameCategoriesContainer:CreateBackdrop('Transparent')
			_G.AchievementFrameCategoriesContainer.backdrop:Point('TOPLEFT', 0, 4)
			_G.AchievementFrameCategoriesContainer.backdrop:Point('BOTTOMRIGHT', -2, -3)

			_G.AchievementFrameAchievementsContainer:CreateBackdrop('Transparent')
			_G.AchievementFrameAchievementsContainer.backdrop:Point('TOPLEFT', -2, 2)
			_G.AchievementFrameAchievementsContainer.backdrop:Point('BOTTOMRIGHT', -2, -3)

			_G.AchievementFrameStatsContainer:CreateBackdrop('Transparent')

			for i = 1, 20 do
				local frame = _G['AchievementFrameStatsContainerButton'..i]
				frame:StyleButton()

				_G['AchievementFrameStatsContainerButton'..i..'BG']:SetColorTexture(1, 1, 1, 0.2)
				_G['AchievementFrameStatsContainerButton'..i..'HeaderLeft']:Kill()
				_G['AchievementFrameStatsContainerButton'..i..'HeaderRight']:Kill()
				_G['AchievementFrameStatsContainerButton'..i..'HeaderMiddle']:Kill()

				frame = 'AchievementFrameComparisonStatsContainerButton'..i
				_G[frame]:StripTextures()
				_G[frame]:StyleButton()

				_G[frame..'BG']:SetColorTexture(1, 1, 1, 0.2)
				_G[frame..'HeaderLeft']:Kill()
				_G[frame..'HeaderRight']:Kill()
				_G[frame..'HeaderMiddle']:Kill()
			end
		end
	end

	for i = 1, E.Modern and 12 or 8 do -- category bars
		local name = 'AchievementFrameSummaryCategoriesCategory'..i

		local bu = _G[name]
		S:HandleStatusBar(bu)
		bu:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))

		local label = E.Modern and bu.Label or _G[name..'Label']
		label:SetTextColor(1, 1, 1)
		label:Point('LEFT', bu, 'LEFT', 6, 0)
		_G[name..'Text']:Point('RIGHT', bu, 'RIGHT', -5, 0)

		_G[name..'ButtonHighlight']:SetAlpha(0)
	end

	hooksecurefunc('AchievementObjectives_DisplayCriteria', DisplayCriteria)

	SkinStatusBar(_G.AchievementFrameSummaryCategoriesStatusBar)
	_G.AchievementFrameSummaryAchievementsEmptyText:SetText('')
	_G.AchievementFrameStatsBG:SetInside(E.Modern and _G.AchievementFrameStats.ScrollBox or _G.AchievementFrameStatsContainer, 1, 1)

	-- Comparison
	local Comparison = _G.AchievementFrameComparison
	_G.AchievementFrameComparisonHeaderBG:Hide()
	_G.AchievementFrameComparisonHeaderPortrait:Hide()
	if not E.Wrath then _G.AchievementFrameComparisonHeaderPortraitBg:Hide() end
	_G.AchievementFrameComparisonHeader:Point('BOTTOMRIGHT', Comparison, 'TOPRIGHT', 39, 26)
	_G.AchievementFrameComparisonHeader:CreateBackdrop('Transparent')
	_G.AchievementFrameComparisonHeader.backdrop:Point('TOPLEFT', 20, -20)
	_G.AchievementFrameComparisonHeader.backdrop:Point('BOTTOMRIGHT', -28, -5)

	HandleSummaryBar(E.Modern and Comparison.Summary.Player or _G.AchievementFrameComparisonSummaryPlayer)
	HandleSummaryBar(E.Modern and Comparison.Summary.Friend or _G.AchievementFrameComparisonSummaryFriend)

	if E.Modern then
		S:HandleTrimScrollBar(Comparison.AchievementContainer.ScrollBar)
		S:HandleTrimScrollBar(Comparison.StatContainer.ScrollBar)
	end
end

if not E.Modern then
	E:Delay(0.1, HookHybridScrollButtons)
end
