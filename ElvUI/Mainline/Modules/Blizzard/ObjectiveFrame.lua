local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local GetInstanceInfo = GetInstanceInfo
local hooksecurefunc = hooksecurefunc

local Tracker = ObjectiveTrackerFrame

local function ObjectiveTracker_IsLeft()
	local x = Tracker:GetCenter()
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

-- Clone from Blizzard_ObjectiveTracker.lua modified by Simpy to protect against errors
local function ObjectiveTracker_UpdateBackground()
	local modules, lastBlock = Tracker.MODULES_UI_ORDER
	if modules then
		for i = #modules, 1, -1 do
			local module = modules[i]
			if module.topBlock then
				lastBlock = module.lastBlock
				break
			end
		end
	end

	if lastBlock and not Tracker.collapsed then
		Tracker.NineSlice:Show()
		Tracker.NineSlice:SetPoint('BOTTOM', lastBlock, 'BOTTOM', 0, -10)
	else
		Tracker.NineSlice:Hide()
	end
end

local function ObjectiveTracker_Collapse()
	Tracker.collapsed = true
	Tracker.BlocksFrame:Hide()
	Tracker.HeaderMenu.MinimizeButton:SetCollapsed(true)
	Tracker.HeaderMenu.Title:Show()
	ObjectiveTracker_UpdateBackground()
end

local function ObjectiveTracker_Expand()
	Tracker.collapsed = nil
	Tracker.BlocksFrame:Show()
	Tracker.HeaderMenu.MinimizeButton:SetCollapsed(false)
	Tracker.HeaderMenu.Title:Hide()
	ObjectiveTracker_UpdateBackground()
end
-- end clone

function B:ObjectiveTracker_AutoHideOnHide()
	if Tracker.collapsed then return end

	if E.db.general.objectiveFrameAutoHideInKeystone then
		ObjectiveTracker_Collapse()
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			ObjectiveTracker_Collapse()
		end
	end
end

function B:ObjectiveTracker_AutoHideOnShow()
	if Tracker.collapsed then
		ObjectiveTracker_Expand()
	end
end

function B:ObjectiveTracker_Setup()
	hooksecurefunc(_G.BonusObjectiveRewardsFrameMixin, 'AnimateReward', BonusRewards_SetPosition)

	B:ObjectiveTracker_AutoHide()
end
