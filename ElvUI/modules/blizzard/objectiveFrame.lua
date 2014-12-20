local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", E.UIParent)
ObjectiveFrameHolder:SetWidth(130)
ObjectiveFrameHolder:SetHeight(22)
ObjectiveFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

function B:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:Height(E.db.general.objectiveFrameHeight)
end

function B:MoveObjectiveFrame()
	E:CreateMover(ObjectiveFrameHolder, 'ObjectiveFrameMover', L['Objective Frame'])
	ObjectiveFrameHolder:SetAllPoints(ObjectiveFrameMover)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOP', ObjectiveFrameHolder, 'TOP')
	B:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)
	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint",function(_,_,parent)
		if parent ~= ObjectiveFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint('TOP', ObjectiveFrameHolder, 'TOP')
		end
	end)
end