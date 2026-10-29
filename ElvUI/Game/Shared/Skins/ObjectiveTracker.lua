local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
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
	_G.InitiativeTasksObjectiveTracker
}

S:AddCallbackForAddon('Blizzard_ObjectiveTracker', nil, nil, nil, nil, nil, 'objectiveTracker')

local function SetCollapsed(header, collapsed)
	local MinimizeButton = header.MinimizeButton
	local normalTexture = MinimizeButton:GetNormalTexture()
	local pushedTexture = MinimizeButton:GetPushedTexture()

	if collapsed then
		normalTexture:SetTexture(E.Media.Textures.PlusButton)
		pushedTexture:SetTexture(E.Media.Textures.PlusButton)
	else
		normalTexture:SetTexture(E.Media.Textures.MinusButton)
		pushedTexture:SetTexture(E.Media.Textures.MinusButton)
	end
end

local function SkinOjectiveTrackerHeaders(header, frame)
	header.Background:SetAtlas(nil)
	header.MinimizeButton:Size(15)

	if frame then
		SetCollapsed(header, frame.isCollapsed)
	else
		SetCollapsed(header, header.isCollapsed)

		header.MinimizeButton:SetHighlightAtlas('UI-QuestTrackerButton-Red-Highlight', 'ADD')
	end

	hooksecurefunc(header, 'SetCollapsed', SetCollapsed)
end

local function HandleQuestIcons(_, block)
	local button = block.ItemButton -- only quests with a usable item get one
	if not button or button.IsSkinned then return end

	button:SetSize(24, 24)
	button:SetNormalTexture(E.ClearTexture)
	button:SetPushedTexture(E.ClearTexture)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

	S:HandleIcon(button.icon, true)
	button.icon:SetInside()

	button.IsSkinned = true
end

local function ReskinBarTemplate(bar)
	if bar.backdrop then return end

	bar:StripTextures()
	bar:CreateBackdrop('Transparent')
	bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar)
end

local function HandleProgressBar(tracker, key)
	local progress = tracker.usedProgressBars[key]
	if not progress then return end

	local bar = progress.Bar
	ReskinBarTemplate(bar)

	local _, maxValue = bar:GetMinMaxValues()
	S:StatusBarColorGradient(bar, bar:GetValue(), maxValue)

	local icon = bar.Icon -- only the scenario and bonus bar templates have one
	if icon and icon:IsShown() and not icon.backdrop then
		icon:SetMask('') -- This needs to be before S:HandleIcon
		icon:ClearAllPoints()
		icon:Point('LEFT', bar, 'RIGHT', E.PixelMode and 3 or 7, 0)

		S:HandleIcon(icon, true)
	end

	local label = bar.Label
	label:ClearAllPoints()
	label:Point('CENTER', bar)
	label:FontTemplate(nil, E.db.general.fontSize, E.db.general.fontStyle)
end

local function HandleTimers(tracker, key)
	local progress = tracker.usedTimerBars[key]
	if not progress then return end

	ReskinBarTemplate(progress.Bar)
end

function S:Blizzard_ObjectiveTracker()
	local TrackerFrame = _G.ObjectiveTrackerFrame
	local TrackerHeader = TrackerFrame.Header

	SkinOjectiveTrackerHeaders(TrackerHeader, TrackerFrame)
	SetCollapsed(TrackerHeader, TrackerFrame.isCollapsed)
	hooksecurefunc(TrackerHeader, 'SetCollapsed', SetCollapsed)

	for _, tracker in next, trackers do
		hooksecurefunc(tracker, 'AddBlock', HandleQuestIcons)
		hooksecurefunc(tracker, 'GetProgressBar', HandleProgressBar)
		hooksecurefunc(tracker, 'GetTimerBar', HandleTimers)

		local header = tracker.Header
		SkinOjectiveTrackerHeaders(header)
		SetCollapsed(header, header.isCollapsed)
		hooksecurefunc(header, 'SetCollapsed', SetCollapsed)
	end
end
