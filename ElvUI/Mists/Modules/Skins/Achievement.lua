local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local unpack = unpack
local select = select
local bitband = bit.band

local hooksecurefunc = hooksecurefunc
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local IsInGuild = IsInGuild

local FLAG_PROGRESS_BAR = EVALUATION_TREE_FLAG_PROGRESS_BAR

local blueAchievement = { r = 0.1, g = 0.2, b = 0.3 }
local function BlueBackdrop(frame)
	frame:SetBackdropColor(blueAchievement.r, blueAchievement.g, blueAchievement.b)
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
	Achievement.icon.texture:SetTexCoord(unpack(E.TexCoords))
	Achievement.icon.texture:SetInside()

	if Achievement.highlight then
		Achievement.highlight:StripTextures()
		Achievement:HookScript('OnEnter', function(frame) frame.backdrop:SetBackdropBorderColor(1, 1, 0) end)
		Achievement:HookScript('OnLeave', function(frame) frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	end

	if Achievement.label then
		Achievement.label:SetTextColor(1, 1, 1)
	end

	if Achievement.description then
		Achievement.description:SetTextColor(.6, .6, .6)
		hooksecurefunc(Achievement.description, 'SetTextColor', function(_, r, g, b)
			if r == 0 and g == 0 and b == 0 then
				Achievement.description:SetTextColor(.6, .6, .6)
			end
		end)
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

local function SkinStatusBar(bar)
	bar:StripTextures()
	bar:SetStatusBarTexture(E.media.normTex)
	bar:SetStatusBarColor(0.02, 0.70, 0.12)
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

local function HookHybridScrollButtons()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.achievement) then return end

	hooksecurefunc('HybridScrollFrame_CreateButtons', function(frame, template)
		if template == 'AchievementCategoryTemplate' then
			for _, category in pairs(frame.buttons) do
				if not category.IsSkinned then
					category:StripTextures(true)
					category:StyleButton()

					category.IsSkinned = true
				end
			end
		elseif template == 'StatTemplate' then
			for _, stats in pairs(frame.buttons) do
				if not stats.IsSkinned then
					stats:StyleButton()

					stats.IsSkinned = true
				end
			end
		elseif template == 'AchievementTemplate' then
			for _, achievement in pairs(frame.buttons) do
				if not achievement.IsSkinned then
					SkinAch(achievement, true)
				end
			end
		elseif template == 'ComparisonTemplate' then
			for _, comparison in pairs(frame.buttons) do
				if not comparison.IsSkinned then
					SkinAchievementButton(comparison)
				end
			end
		end
	end)

	-- if AchievementUI was loaded by another addon before us, these buttons won't exist when Blizzard_AchievementUI is called.
	-- however, it can also be too late to hook HybridScrollFrame_CreateButtons, so we need to skin them here, weird...
	for i = 1, 20 do
		local category = _G['AchievementFrameCategoriesContainerButton'..i]
		if category and not category.IsSkinned then
			category:StripTextures(true)
			category:StyleButton()

			category.IsSkinned = true
		end

		local stats = _G['AchievementFrameStatsContainerButton'..i]
		if stats and not stats.IsSkinned then
			stats:StyleButton()

			stats.IsSkinned = true
		end

		if i <= 10 then
			local achievement = _G['AchievementFrameAchievementsContainerButton'..i]
			if achievement and not achievement.IsSkinned then
				SkinAch(achievement, true)

			end

			local comparison = _G['AchievementFrameComparisonContainerButton'..i]
			if comparison and not comparison.IsSkinned then
				SkinAchievementButton(comparison)
			end
		end
	end
end

function S:Blizzard_AchievementUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.achievement) then return end

	_G.AchievementFrameSummary:StripTextures()
	_G.AchievementFrameSummaryBackground:Hide()
	_G.AchievementFrameSummary:GetChildren():Hide()

	for i = 1, 4 do
		select(i, _G.AchievementFrameHeader:GetRegions()):Hide()
	end

	_G.AchievementFrameHeaderRightDDLInset:SetAlpha(0)
	select(2, _G.AchievementFrameAchievements:GetChildren()):Hide()
	_G.AchievementFrameAchievementsBackground:Hide()
	select(3, _G.AchievementFrameAchievements:GetRegions()):Hide()
	_G.AchievementFrameStatsBG:Hide()
	_G.AchievementFrameStatsContainer:CreateBackdrop('Transparent')
	_G.AchievementFrameSummaryAchievementsHeaderHeader:Hide()
	_G.AchievementFrameSummaryCategoriesHeaderTexture:Hide()
	select(3, _G.AchievementFrameStats:GetChildren()):Hide()
	select(5, _G.AchievementFrameComparison:GetChildren()):Hide()
	_G.AchievementFrameComparisonHeader:ClearAllPoints()
	_G.AchievementFrameComparisonHeader:Point('BOTTOMRIGHT', _G.AchievementFrameComparison, 'TOPRIGHT', 35, -15)
	_G.AchievementFrameComparisonHeaderBG:Hide()
	_G.AchievementFrameComparisonHeaderPortrait:Hide()
	_G.AchievementFrameComparisonHeaderName:Width(90)
	_G.AchievementFrameComparisonBackground:Hide()
	_G.AchievementFrameComparisonWatermark:SetAlpha(0)
	_G.AchievementFrameComparisonDark:SetAlpha(0)
	_G.AchievementFrameComparisonSummaryPlayerBackground:Hide()
	_G.AchievementFrameComparisonSummaryFriendBackground:Hide()

	_G.AchievementFrameComparisonSummaryPlayer.NineSlice:SetTemplate('Transparent')
	_G.AchievementFrameComparisonSummaryFriend.NineSlice:SetTemplate('Transparent')

	SkinStatusBar(_G.AchievementFrameComparisonSummaryPlayerStatusBar)
	SkinStatusBar(_G.AchievementFrameComparisonSummaryFriendStatusBar)
	_G.AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	_G.AchievementFrameComparisonSummaryFriendStatusBar.text:Point('CENTER')

	_G.AchievementFrameMetalBorderTopLeft:Hide()
	_G.AchievementFrameWoodBorderTopLeft:Hide()
	_G.AchievementFrameMetalBorderTopRight:Hide()
	_G.AchievementFrameWoodBorderTopRight:Hide()
	_G.AchievementFrameMetalBorderBottomRight:Hide()
	_G.AchievementFrameWoodBorderBottomRight:Hide()
	_G.AchievementFrameMetalBorderBottomLeft:Hide()
	_G.AchievementFrameWoodBorderBottomLeft:Hide()

	local AchievementFrame = _G.AchievementFrame
	AchievementFrame:StripTextures()
	AchievementFrame:CreateBackdrop('Transparent')
	AchievementFrame.backdrop:Point('TOPLEFT', 0, 7)
	AchievementFrame.backdrop:Point('BOTTOMRIGHT')

	_G.AchievementFrameHeaderTitle:ClearAllPoints()
	_G.AchievementFrameHeaderTitle:Point('TOP', AchievementFrame.backdrop, 'TOP', 0, -8)

	_G.AchievementFrameHeaderPoints:ClearAllPoints()
	_G.AchievementFrameHeaderPoints:Point('CENTER', _G.AchievementFrameHeaderTitle, 'CENTER', 0, 0)

	-- Backdrops
	_G.AchievementFrameCategories:StripTextures()
	_G.AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)
	_G.AchievementFrameCategoriesContainer:CreateBackdrop('Transparent')
	_G.AchievementFrameCategoriesContainer.backdrop:Point('TOPLEFT', 0, 4)
	_G.AchievementFrameCategoriesContainer.backdrop:Point('BOTTOMRIGHT', -2, -3)
	_G.AchievementFrameCategoriesBG:SetAlpha(0)
	_G.AchievementFrameWaterMark:SetAlpha(0)

	_G.AchievementFrameAchievementsContainer:CreateBackdrop('Transparent')
	_G.AchievementFrameAchievementsContainer.backdrop:Point('TOPLEFT', -2, 2)
	_G.AchievementFrameAchievementsContainer.backdrop:Point('BOTTOMRIGHT', -2, -3)

	S:HandleCloseButton(_G.AchievementFrameCloseButton, AchievementFrame.backdrop)

	S:HandleDropDownBox(_G.AchievementFrameFilterDropdown)
	_G.AchievementFrameFilterDropdown:ClearAllPoints()
	_G.AchievementFrameFilterDropdown:Point('TOPLEFT', _G.AchievementFrameAchievements, 'TOPLEFT', -18, 24)

	-- ScrollBars
	local scrollBars = {
		_G.AchievementFrameCategoriesContainerScrollBar,
		_G.AchievementFrameAchievementsContainerScrollBar,
		_G.AchievementFrameStatsContainerScrollBar,
		_G.AchievementFrameComparisonContainerScrollBar,
		_G.AchievementFrameComparisonStatsContainerScrollBar,
	}

	for _, scrollbar in pairs(scrollBars) do
		if scrollbar then
			S:HandleScrollBar(scrollbar)
		end
	end

	-- Tabs
	for i = 1, 3 do
		S:HandleTab(_G['AchievementFrameTab'..i])
		_G['AchievementFrameTab'..i]:OffsetFrameLevel(2)
	end

	-- Reposition Tabs
	_G.AchievementFrameTab1:ClearAllPoints()
	_G.AchievementFrameTab1:Point('TOPLEFT', _G.AchievementFrame, 'BOTTOMLEFT', -10, 0)
	_G.AchievementFrameTab2:Point('TOPLEFT', _G.AchievementFrameTab1, 'TOPRIGHT', -19, 0)
	_G.AchievementFrameTab3:Point('TOPLEFT', IsInGuild() and _G.AchievementFrameTab2 or _G.AchievementFrameTab1, 'TOPRIGHT', -19, 0)

	SkinStatusBar(_G.AchievementFrameSummaryCategoriesStatusBar)

	for i = 1, 8 do
		local frame = _G['AchievementFrameSummaryCategoriesCategory'..i]
		local button = _G['AchievementFrameSummaryCategoriesCategory'..i..'Button']
		local highlight = _G['AchievementFrameSummaryCategoriesCategory'..i..'ButtonHighlight']

		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()

		_G[highlight:GetName()..'Middle']:SetColorTexture(1, 1, 1, 0.3)
		_G[highlight:GetName()..'Middle']:SetAllPoints(frame)
	end

	hooksecurefunc('AchievementButton_DisplayAchievement', SetAchievementColor)

	hooksecurefunc('AchievementFrameSummary_UpdateAchievements', function()
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
	end)

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

	hooksecurefunc('AchievementButton_GetProgressBar', function(index)
		local frame = _G['AchievementFrameProgressBar'..index]
		if frame and not frame.skinned then
			frame:StripTextures()
			frame:SetStatusBarTexture(E.media.normTex)
			E:RegisterStatusBar(frame)

			frame:SetStatusBarColor(0.02, 0.70, 0.12)
			frame:CreateBackdrop('Transparent')
			frame:OffsetFrameLevel(3)
			frame:Height(frame:GetHeight() - 2)

			frame.text:ClearAllPoints()
			frame.text:Point('CENTER', frame, 'CENTER', 0, -1)
			frame.text:SetJustifyH('CENTER')

			if index > 1 then
				frame:ClearAllPoints()
				frame:Point('TOP', _G['AchievementFrameProgressBar'..index-1], 'BOTTOM', 0, -5)
				frame.SetPoint = E.noop
				frame.ClearAllPoints = E.noop
			end

			frame.skinned = true
		end
	end)

	hooksecurefunc('AchievementObjectives_DisplayCriteria', function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas, criteria, object = 0, 0
		for i = 1, numCriteria do
			local _, criteriaType, completed, _, _, _, flags, assetID = GetAchievementCriteriaInfo(id, i)
			if assetID and criteriaType == _G.CRITERIA_TYPE_ACHIEVEMENT then
				metas = metas + 1
				criteria, object = _G.AchievementButton_GetMeta(metas), 'label'
			elseif bitband(flags, FLAG_PROGRESS_BAR) == FLAG_PROGRESS_BAR then
				criteria, object = nil, nil
			else
				textStrings = textStrings + 1
				criteria, object = _G.AchievementButton_GetCriteria(textStrings), 'name'
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
end

E:Delay(0.1, HookHybridScrollButtons)

S:AddCallbackForAddon('Blizzard_AchievementUI')
