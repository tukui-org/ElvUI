local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local ObjectiveTrackerFrame = ObjectiveTrackerFrame
local hooksecurefunc = hooksecurefunc

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	return x and x < (E.screenWidth * 0.5) -- positioned on left side
end

local function RewardsFrame_SetPosition(block)
	local rewards = _G.ObjectiveTrackerBonusRewardsFrame
	rewards:ClearAllPoints()

	if E.db.general.bonusObjectivePosition == 'RIGHT' or (E.db.general.bonusObjectivePosition == 'AUTO' and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
		rewards:Point('TOPLEFT', block, 'TOPRIGHT', -10, -4)
	else
		rewards:Point('TOPRIGHT', block, 'TOPLEFT', 10, -4)
	end
end

-- Clone from Blizzard_ObjectiveTracker.lua modified by Simpy to protect against errors
local function ObjectiveTracker_UpdateBackground()
	local modules, lastBlock = ObjectiveTrackerFrame.MODULES_UI_ORDER
	if modules then
		for i = #modules, 1, -1 do
			local module = modules[i]
			if module.topBlock then
				lastBlock = module.lastBlock
				break
			end
		end
	end

	if lastBlock and not ObjectiveTrackerFrame.collapsed then
		ObjectiveTrackerFrame.NineSlice:Show()
		ObjectiveTrackerFrame.NineSlice:SetPoint('BOTTOM', lastBlock, 'BOTTOM', 0, -10)
	else
		ObjectiveTrackerFrame.NineSlice:Hide()
	end
end

local function ObjectiveTracker_Collapse()
	ObjectiveTrackerFrame.collapsed = true
	ObjectiveTrackerFrame.BlocksFrame:Hide()
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetCollapsed(true)
	ObjectiveTrackerFrame.HeaderMenu.Title:Show()
	ObjectiveTracker_UpdateBackground()
end

local function ObjectiveTracker_Expand()
	ObjectiveTrackerFrame.collapsed = nil
	ObjectiveTrackerFrame.BlocksFrame:Show()
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetCollapsed(false)
	ObjectiveTrackerFrame.HeaderMenu.Title:Hide()
	ObjectiveTracker_UpdateBackground()
end
-- end clone

local function AutoHider_OnHide()
	if not ObjectiveTrackerFrame.collapsed then
		if E.db.general.objectiveFrameAutoHideInKeystone then
			ObjectiveTracker_Collapse()
		else
			local _, _, difficultyID = GetInstanceInfo()
			if difficultyID ~= 8 then -- ignore hide in keystone runs
				ObjectiveTracker_Collapse()
			end
		end
	end
end

local function AutoHider_OnShow()
	if ObjectiveTrackerFrame.collapsed then
		ObjectiveTracker_Expand()
	end
end

function B:SetObjectiveFrameAutoHide()
	if not ObjectiveTrackerFrame.AutoHider then
		return -- Kaliel's Tracker prevents B:MoveObjectiveFrame() from executing
	end

	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(ObjectiveTrackerFrame.AutoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
	else
		UnregisterStateDriver(ObjectiveTrackerFrame.AutoHider, 'objectiveHider')
	end
end

-- keeping old name, not used to move just to handle the objective things
-- wrath has it's own file, which actually has the mover on that client
function B:MoveObjectiveFrame()
	ObjectiveTrackerFrame.AutoHider = CreateFrame('Frame', nil, ObjectiveTrackerFrame, 'SecureHandlerStateTemplate')
	ObjectiveTrackerFrame.AutoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
	ObjectiveTrackerFrame.AutoHider:SetScript('OnHide', AutoHider_OnHide)
	ObjectiveTrackerFrame.AutoHider:SetScript('OnShow', AutoHider_OnShow)
	B:SetObjectiveFrameAutoHide()

	-- force this never case, to fix a taint when actionbars in use
	if E.private.actionbar.enable then
		ObjectiveTrackerFrame.IsInDefaultPosition = E.noop
	end

	hooksecurefunc('BonusObjectiveTracker_AnimateReward', RewardsFrame_SetPosition)
end
