local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

--Lua functions
local _G = _G
local min = math.min
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local hooksecurefunc = hooksecurefunc
local RegisterStateDriver = RegisterStateDriver

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
		positionedLeft = true
	end

	return positionedLeft
end

function B:SetObjectiveFrameAutoHide()
	if not _G.ObjectiveTrackerFrame.AutoHider then return; end --Kaliel's Tracker prevents B:MoveObjectiveFrame() from executing
	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists] 1;0")
	else
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider", "0")
	end
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

	ObjectiveTrackerFrame:SetMovable(true)

	if ObjectiveTrackerFrame:IsMovable() then
		ObjectiveTrackerFrame:SetUserPlaced(true) -- UIParent.lua line 3090 stops it from being moved <3
	end

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:Point('TOP', ObjectiveFrameHolder, 'TOP')


	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = _G.ObjectiveTrackerBonusRewardsFrame
		rewardsFrame:ClearAllPoints()
		if E.db.general.bonusObjectivePosition == "RIGHT" or (E.db.general.bonusObjectivePosition == "AUTO" and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
			rewardsFrame:Point("TOPLEFT", block, "TOPRIGHT", -10, -4)
		else
			rewardsFrame:Point("TOPRIGHT", block, "TOPLEFT", 10, -4)
		end
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)

	ObjectiveTrackerFrame.AutoHider = CreateFrame('Frame', nil, _G.ObjectiveTrackerFrame, 'SecureHandlerStateTemplate')
	ObjectiveTrackerFrame.AutoHider:SetAttribute("_onstate-objectiveHider", [[
		if newstate == 1 then
			self:Hide()
		else
			self:Show()
		end
	]])

	ObjectiveTrackerFrame.AutoHider:SetScript("OnHide", function()
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID and difficultyID ~= 8 then
			_G.ObjectiveTracker_Collapse()
		end
	end)

	ObjectiveTrackerFrame.AutoHider:SetScript("OnShow", _G.ObjectiveTracker_Expand)

	self:SetObjectiveFrameAutoHide()
end
