local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local trackers = { -- the other modules load but never get content on Forever
	_G.UIWidgetObjectiveTracker,
	_G.QuestObjectiveTracker,
	_G.AchievementObjectiveTracker,
	_G.ProfessionsRecipeTracker,
}

local function SkinOjectiveTrackerHeaders(header)
	header.Background:SetAtlas(nil)
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

		check.IsSkinned = true
	end
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

	local icon = bar.Icon
	if icon:IsShown() and not icon.backdrop then
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
