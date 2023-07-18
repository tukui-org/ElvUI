local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local min = min
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local Tracker_Collapse = WatchFrame_Collapse
local Tracker_Expand = WatchFrame_Expand
local Tracker = WatchFrame

local function ObjectiveTracker_SetPoint(tracker, _, parent)
	if parent ~= tracker.holder then
		tracker:ClearAllPoints()
		tracker:SetPoint('TOP', tracker.holder)
	end
end

function B:ObjectiveTracker_SetHeight()
	local top = Tracker:GetTop() or 0
	local gapFromTop = E.screenHeight - top
	local maxHeight = E.screenHeight - gapFromTop
	local frameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)

	Tracker:Height(frameHeight)
end

function B:ObjectiveTracker_AutoHideOnHide()
	if not Tracker.collapsed then
		Tracker.userCollapsed = true
		Tracker_Collapse(Tracker)
	end
end

function B:ObjectiveTracker_AutoHideOnShow()
	if Tracker.collapsed then
		Tracker.userCollapsed = nil
		Tracker_Expand(Tracker)
	end
end

function B:ObjectiveTracker_Setup()
	local holder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	holder:Point('TOPRIGHT', E.UIParent, -135, -300)
	holder:Size(130, 22)

	E:CreateMover(holder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')
	holder:SetAllPoints(_G.ObjectiveFrameMover)

	Tracker:SetClampedToScreen(false)
	Tracker:ClearAllPoints()
	Tracker:SetPoint('TOP', holder)

	Tracker.holder = holder
	hooksecurefunc(Tracker, 'SetPoint', ObjectiveTracker_SetPoint)

	B:ObjectiveTracker_AutoHide()
	B:ObjectiveTracker_SetHeight()
end
