local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local GetInstanceInfo = GetInstanceInfo

function BL:ObjectiveTracker_AutoHideOnHide()
	local tracker = _G.ObjectiveTrackerFrame
	if tracker and tracker.autoHidden then return end

	if E.db.general.objectiveFrameAutoHideInKeystone then
		BL:ObjectiveTracker_Collapse(tracker)
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			BL:ObjectiveTracker_Collapse(tracker)
		end
	end
end

function BL:ObjectiveTracker_Setup()
	BL:ObjectiveTracker_AutoHide()
end
