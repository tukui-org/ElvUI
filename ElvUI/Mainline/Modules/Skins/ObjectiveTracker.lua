local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local trackers = {
	_G.ScenarioObjectiveTracker,
	_G.UIWidgetObjectiveTracker,
	_G.CampaignQuestObjectiveTracker,
	_G.QuestObjectiveTracker,
	_G.AdventureObjectiveTracker,
	_G.AchievementObjectiveTracker,
	_G.MonthlyActivitiesObjectiveTracker,
	_G.ProfessionsRecipeTracker,
	_G.BonusObjectiveTracker,
	_G.WorldQuestObjectiveTracker,
}

local function SkinOjectiveTrackerHeaders(header)
	if not header then return end

	if header.Background then
		header.Background:SetAtlas(nil)
	end

	if header.Text then
		header.Text:FontTemplate()
	end
end

local function ReskinQuestIcon(button)
	if not button then return end

	if not button.IsSkinned then
		button:SetSize(24, 24)
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		local icon = button.icon or button.Icon
		if icon then
			S:HandleIcon(icon, true)
			icon:SetInside()
		end

		button.IsSkinned = true
	end

	if button.backdrop then
		button.backdrop:SetFrameLevel(0)
	end
end

local function HandleQuestIcons(_, block)
	ReskinQuestIcon(block.ItemButton)
	ReskinQuestIcon(block.itemButton)

	local check = block.currentLine and block.currentLine.Check
	if check and not check.IsSkinned then
		check:SetAtlas('checkmark-minimal')
		check:SetDesaturated(true)
		check:SetVertexColor(0, 1, 0)

		check.styled = true
	end
end

local function ReskinBarTemplate(bar)
	if bar.backdrop then return end

	bar:StripTextures()
	bar:CreateBackdrop()
	bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar)
end

local function HandleProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end

	local icon = bar and bar.Icon
	if icon and not icon.backdrop then
		icon:SetMask('') -- This needs to be before S:HandleIcon
		S:HandleIcon(icon, true)

		icon:ClearAllPoints()
		icon:Point('TOPLEFT', bar, 'TOPRIGHT', 5, 0)
		icon:Point('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 25, 0)
	end
end

local function HandleTimers(tracker, key)
	local timerBar = tracker.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end
end

function S:Blizzard_ObjectiveTracker()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.objectiveTracker) then return end

	local MainHeader = _G.ObjectiveTrackerFrame.Header
	SkinOjectiveTrackerHeaders(MainHeader)

	-- FIX ME 11.0: Collapse state got changed
	local MainMinimize = MainHeader.MinimizeButton
	MainMinimize:StripTextures(nil, true)
	MainMinimize:Size(16)
	MainMinimize:SetHighlightTexture(130837, 'ADD') -- Interface\Buttons\UI-PlusButton-Hilight
	MainMinimize.tex = MainMinimize:CreateTexture(nil, 'OVERLAY')
	MainMinimize.tex:SetTexture(E.Media.Textures.MinusButton)
	MainMinimize.tex:SetInside()

	for _, tracker in pairs(trackers) do
		SkinOjectiveTrackerHeaders(tracker.Header)

		hooksecurefunc(tracker, 'AddBlock', HandleQuestIcons)
		hooksecurefunc(tracker, 'GetProgressBar', HandleProgressBar)
		hooksecurefunc(tracker, 'GetTimerBar', HandleTimers)
	end
end

S:AddCallbackForAddon('Blizzard_ObjectiveTracker')
