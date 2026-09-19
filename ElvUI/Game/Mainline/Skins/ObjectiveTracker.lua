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

local function SkinOjectiveTrackerHeaders(header)
	header.Background:SetAtlas(nil)
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
	local bar = tracker.usedProgressBars[key].Bar
	ReskinBarTemplate(bar)

	local _, maxValue = bar:GetMinMaxValues()
	S:StatusBarColorGradient(bar, bar:GetValue(), maxValue)

	local icon = bar.Icon -- only the scenario and bonus bar templates have one
	if icon and icon:IsShown() and not icon.backdrop then
		icon:SetMask('') -- This needs to be before S:HandleIcon
		S:HandleIcon(icon, true)

		icon:ClearAllPoints()
		icon:Point('LEFT', bar, 'RIGHT', E.PixelMode and 3 or 7, 0)
	end

	local label = bar.Label
	label:ClearAllPoints()
	label:Point('CENTER', bar)
	label:FontTemplate(nil, E.db.general.fontSize, E.db.general.fontStyle)
end

local function HandleTimers(tracker, key)
	ReskinBarTemplate(tracker.usedTimerBars[key].Bar)
end

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

function S:Blizzard_ObjectiveTracker()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.objectiveTracker) then return end

	local TrackerFrame = _G.ObjectiveTrackerFrame
	local TrackerHeader = TrackerFrame.Header
	SkinOjectiveTrackerHeaders(TrackerHeader)
	TrackerHeader.MinimizeButton:Size(15)
	SetCollapsed(TrackerHeader, TrackerFrame.isCollapsed)
	hooksecurefunc(TrackerHeader, 'SetCollapsed', SetCollapsed)

	for _, tracker in next, trackers do
		hooksecurefunc(tracker, 'AddBlock', HandleQuestIcons)
		hooksecurefunc(tracker, 'GetProgressBar', HandleProgressBar)
		hooksecurefunc(tracker, 'GetTimerBar', HandleTimers)

		local header = tracker.Header
		SkinOjectiveTrackerHeaders(header)
		header.MinimizeButton:Size(15)
		header.MinimizeButton:SetHighlightAtlas('UI-QuestTrackerButton-Red-Highlight', 'ADD')
		SetCollapsed(header, header.isCollapsed)
		hooksecurefunc(header, 'SetCollapsed', SetCollapsed)
	end
end

S:AddCallbackForAddon('Blizzard_ObjectiveTracker')
