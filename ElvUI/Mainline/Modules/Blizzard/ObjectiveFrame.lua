local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local GetInstanceInfo = GetInstanceInfo

local function ObjectiveTracker_IsLeft()
	local x = _G.ObjectiveTrackerFrame:GetCenter()
	return x and x < (E.screenWidth * 0.5) -- positioned on left side
end

local function BonusRewards_SetPosition(block)
	local rewards = _G.ObjectiveTrackerBonusRewardsFrame
	if not rewards then return end

	rewards:ClearAllPoints()

	if E.db.general.bonusObjectivePosition == 'RIGHT' or (E.db.general.bonusObjectivePosition == 'AUTO' and ObjectiveTracker_IsLeft()) then
		rewards:Point('TOPLEFT', block, 'TOPRIGHT', -10, -4)
	else
		rewards:Point('TOPRIGHT', block, 'TOPLEFT', 10, -4)
	end
end

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
	-- FIX ME 11.0 mostly not there anymore
	--hooksecurefunc(_G.ObjectiveTrackerRewardsToastMixin, 'AnimateReward', BonusRewards_SetPosition)

	BL:ObjectiveTracker_AutoHide()
end
