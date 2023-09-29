local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local next = next
local UIParent = UIParent
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

function B:ObjectiveTracker_HandleDefaultPosition(isDefault)
	local info = Tracker.systemInfo
	if not info then return end

	-- we only need to do something when it was in the default position
	local wasDefault = info.isInDefaultPosition
	info.isInDefaultPosition = isDefault

	-- something in here is magic and lets the Legion Scenario quest button work when actionbar module is on
	-- this lets the first move in edit mode actually work without clicking [Reset To Default Position]
	local parent = wasDefault and Tracker:GetManagedFrameContainer()
	if parent and parent.showingFrames and parent.showingFrames[Tracker] then
		parent:RemoveManagedFrame(Tracker)

		-- now set this to UIParent when its not already the parent
		if Tracker:GetParent() ~= UIParent then
			Tracker:SetParent(UIParent)
		end
	end
end

function B:ObjectiveTracker_CorrectDefaultPositions(manager, default)
	local info = Tracker.systemInfo
	local systemID = info and info.system
	if not systemID then return end

	local managerInfo = manager.layoutInfo
	local layouts = managerInfo and managerInfo.layouts
	if not layouts then return end

	for _, layout in next, layouts do
		local systems = layout.systems
		if systems then
			for _, system in next, systems do
				if system.system == systemID and system.isInDefaultPosition == nil then
					system.isInDefaultPosition = default
				end
			end
		end
	end
end

function B:ObjectiveTracker_SetDefaultPosition()
	local default = not not Tracker:IsInDefaultPosition()
	B:ObjectiveTracker_HandleDefaultPosition(default)

	-- this fixes an error with Make New Layout
	B:ObjectiveTracker_CorrectDefaultPositions(self, default)
end

function B:ObjectiveTracker_ClearDefaultPosition()
	B:ObjectiveTracker_HandleDefaultPosition()
end

function B:ObjectiveTracker_Setup()
	if E.private.actionbar.enable then -- force this never case, to fix a taint when actionbars in use
		hooksecurefunc(Tracker, 'UpdateSystem', B.ObjectiveTracker_ClearDefaultPosition)
		B.ObjectiveTracker_ClearDefaultPosition() -- fake it to not default on loading in

		-- this fixes an error while saving a new layout when `isInDefaultPosition` is sent to the C side
		-- it happens because this var is not nilable but we need it to be nil in order to bypass `UIParent_ManageFramePositions`
		hooksecurefunc(_G.EditModeManagerFrame, 'PrepareSystemsForSave', B.ObjectiveTracker_SetDefaultPosition)
		hooksecurefunc(_G.EditModeManagerFrame, 'SaveLayouts', B.ObjectiveTracker_ClearDefaultPosition)
	end

	hooksecurefunc(_G.BonusObjectiveRewardsFrameMixin, 'AnimateReward', BonusRewards_SetPosition)

	B:ObjectiveTracker_AutoHide()
end
