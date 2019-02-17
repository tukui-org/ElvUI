local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

local _G = _G
--Lua functions
local min = math.min
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight

function B:SetObjectiveFrameHeight()
	local top = _G.ObjectiveTrackerFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local objectiveFrameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)

	_G.ObjectiveTrackerFrame:Height(objectiveFrameHeight)
end

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true;
	end

	return positionedLeft;
end

function B:MoveObjectiveFrame()
	local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", E.UIParent)
	ObjectiveFrameHolder:Width(130)
	ObjectiveFrameHolder:Height(22)
	ObjectiveFrameHolder:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

	E:CreateMover(ObjectiveFrameHolder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')
	local ObjectiveFrameMover = _G.ObjectiveFrameMover
	local ObjectiveTrackerFrame = _G.ObjectiveTrackerFrame
	ObjectiveFrameHolder:SetAllPoints(ObjectiveFrameMover)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:Point('TOP', ObjectiveFrameHolder, 'TOP')
	B:SetObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	local function ObjectiveTrackerFrame_SetPosition(self,_, parent)
		if parent ~= ObjectiveFrameHolder or self:GetNumPoints() ~= 1 then
			self:ClearAllPoints()
			self:SetPoint('TOP', ObjectiveFrameHolder, 'TOP')
		end
	end
	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint", ObjectiveTrackerFrame_SetPosition)

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = _G.ObjectiveTrackerBonusRewardsFrame;
		rewardsFrame:ClearAllPoints();
		if E.db.general.bonusObjectivePosition == "RIGHT" or (E.db.general.bonusObjectivePosition == "AUTO" and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
			rewardsFrame:Point("TOPLEFT", block, "TOPRIGHT", -10, -4);
		else
			rewardsFrame:Point("TOPRIGHT", block, "TOPLEFT", 10, -4);
		end
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)
end
