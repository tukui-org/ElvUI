local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local IsInJailersTower = IsInJailersTower
local hooksecurefunc = hooksecurefunc

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	return x and x < (E.screenWidth * 0.5) -- positioned on left side
end

local function RewardsFrame_SetPosition(block)
	local rewards = _G.ObjectiveTrackerBonusRewardsFrame
	rewards:ClearAllPoints()

	if E.db.general.bonusObjectivePosition == 'RIGHT' or (E.db.general.bonusObjectivePosition == 'AUTO' and IsFramePositionedLeft(_G.ObjectiveTrackerFrame)) then
		rewards:Point('TOPLEFT', block, 'TOPRIGHT', -10, -4)
	else
		rewards:Point('TOPRIGHT', block, 'TOPLEFT', 10, -4)
	end
end

local function AutoHider_OnHide()
	if not _G.ObjectiveTrackerFrame.collapsed then
		if E.db.general.objectiveFrameAutoHideInKeystone then
			_G.ObjectiveTracker_Collapse()
		else
			local _, _, difficultyID = GetInstanceInfo()
			if difficultyID ~= 8 then -- ignore hide in keystone runs
				_G.ObjectiveTracker_Collapse()
			end
		end
	end
end

local function AutoHider_OnShow()
	if _G.ObjectiveTrackerFrame.collapsed then
		_G.ObjectiveTracker_Expand()
	end
end

function B:SetObjectiveFrameAutoHide()
	if not _G.ObjectiveTrackerFrame.AutoHider then
		return -- Kaliel's Tracker prevents B:MoveObjectiveFrame() from executing
	end

	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
	else
		UnregisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, 'objectiveHider')
	end
end

-- keeping old name, not used to move just to handle the objective things
-- wrath has it's own file, which actually has the mover on that client
function B:MoveObjectiveFrame()
	local tracker = _G.ObjectiveTrackerFrame
	tracker.AutoHider = CreateFrame('Frame', nil, tracker, 'SecureHandlerStateTemplate')
	tracker.AutoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
	tracker.AutoHider:SetScript('OnHide', AutoHider_OnHide)
	tracker.AutoHider:SetScript('OnShow', AutoHider_OnShow)
	B:SetObjectiveFrameAutoHide()

	-- force this never case, to fix a taint when actionbars in use
	if E.private.actionbar.enable then
		tracker.IsInDefaultPosition = E.noop
	end

	hooksecurefunc('BonusObjectiveTracker_AnimateReward', RewardsFrame_SetPosition)
end
