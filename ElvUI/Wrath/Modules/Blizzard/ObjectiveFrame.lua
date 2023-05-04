local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local min = min
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

function B:SetObjectiveFrameHeight()
	local top = _G.WatchFrame:GetTop() or 0
	local gapFromTop = E.screenHeight - top
	local maxHeight = E.screenHeight - gapFromTop
	local watchFrameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)

	_G.WatchFrame:Height(watchFrameHeight)
end

function B:SetObjectiveFrameAutoHide()
	if not _G.WatchFrame.AutoHider then
		return -- Kaliel's Tracker prevents B:MoveObjectiveFrame() from executing
	end

	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(_G.WatchFrame.AutoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
	else
		UnregisterStateDriver(_G.WatchFrame.AutoHider, 'objectiveHider')
	end
end

function B:MoveObjectiveFrame()
	local holder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	holder:Point('TOPRIGHT', E.UIParent, -135, -300)
	holder:Size(130, 22)

	E:CreateMover(holder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')
	holder:SetAllPoints(_G.ObjectiveFrameMover)

	local tracker = _G.WatchFrame
	tracker:SetClampedToScreen(false)
	tracker:ClearAllPoints()
	tracker:SetPoint('TOP', holder)

	hooksecurefunc(tracker, 'SetPoint', function(_, _, parent)
		if parent ~= holder then
			tracker:ClearAllPoints()
			tracker:SetPoint('TOP', holder)
		end
	end)

	B:SetObjectiveFrameHeight()
end
