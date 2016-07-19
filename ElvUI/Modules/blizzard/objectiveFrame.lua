local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ObjectiveTrackerFrame, ObjectiveFrameMover, ObjectiveTrackerBonusRewardsFrame

local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", E.UIParent)
ObjectiveFrameHolder:Width(130)
ObjectiveFrameHolder:Height(22)
ObjectiveFrameHolder:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

function B:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:Height(E.db.general.objectiveFrameHeight)
end

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true;
	end

	return positionedLeft;
end

function B:MoveObjectiveFrame()
	E:CreateMover(ObjectiveFrameHolder, 'ObjectiveFrameMover', L["Objective Frame"])
	ObjectiveFrameHolder:SetAllPoints(ObjectiveFrameMover)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:Point('TOP', ObjectiveFrameHolder, 'TOP')
	B:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	local function ObjectiveTrackerFrame_SetPosition(_,_, parent)
		if parent ~= ObjectiveFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint('TOP', ObjectiveFrameHolder, 'TOP')
		end
	end
	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint", ObjectiveTrackerFrame_SetPosition)

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = ObjectiveTrackerBonusRewardsFrame;
		rewardsFrame:ClearAllPoints();
		if E.db.general.bonusObjectivePosition == "RIGHT" or (E.db.general.bonusObjectivePosition == "AUTO" and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
			rewardsFrame:Point("TOPLEFT", block, "TOPRIGHT", -10, -4);
		else
			rewardsFrame:Point("TOPRIGHT", block, "TOPLEFT", 10, -4);
		end
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)
end