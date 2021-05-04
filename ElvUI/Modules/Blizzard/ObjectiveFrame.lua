local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local min = min
local CreateFrame = CreateFrame
local GetScreenHeight = GetScreenHeight
local GetInstanceInfo = GetInstanceInfo
local GetScreenWidth = GetScreenWidth
local hooksecurefunc = hooksecurefunc
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local IsInJailersTower = IsInJailersTower

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
	if not _G.ObjectiveTrackerFrame.AutoHider then return end --Kaliel's Tracker prevents B:MoveObjectiveFrame() from executing

	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists] 1;0')
	else
		UnregisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, 'objectiveHider')
	end
end

function B:SetupTorghastBuffFrame()
	if not IsInJailersTower() then return end

	local container = _G.ScenarioBlocksFrame.MawBuffsBlock.Container
	container.List:ClearAllPoints()

	local buffsPos = E.db.general.torghastBuffsPosition or 'AUTO'
	if buffsPos == 'RIGHT' or (buffsPos == 'AUTO' and IsFramePositionedLeft(_G.ScenarioBlocksFrame)) then
		container.List:Point('TOPLEFT', container, 'TOPRIGHT', 15, 1)

		container.List:SetScript('OnShow', function(self)
			self.button:SetHighlightAtlas('jailerstower-animapowerbutton-highlight', true)
			self.button:SetPushedAtlas('jailerstower-animapowerbutton-normalpressed', true)
			self.button:SetButtonState('NORMAL')
			self.button:SetButtonState('PUSHED', true)
		end)
	else
		container.List:Point('TOPRIGHT', container, 'TOPLEFT', 15, 1)
	end
end

function B:MoveObjectiveFrame()
	local ObjectiveFrameHolder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	ObjectiveFrameHolder:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)
	ObjectiveFrameHolder:Size(130, 22)

	E:CreateMover(ObjectiveFrameHolder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, B.SetupTorghastBuffFrame, nil, nil, 'general,blizzUIImprovements')
	ObjectiveFrameHolder:SetAllPoints(_G.ObjectiveFrameMover)

	local ObjectiveTrackerFrame = _G.ObjectiveTrackerFrame
	ObjectiveTrackerFrame:SetClampedToScreen(false)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:Point('TOP', ObjectiveFrameHolder, 'TOP')
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true) -- UIParent.lua line 3090 stops it from being moved <3
	B:SetObjectiveFrameHeight()

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = _G.ObjectiveTrackerBonusRewardsFrame
		rewardsFrame:ClearAllPoints()
		if E.db.general.bonusObjectivePosition == 'RIGHT' or (E.db.general.bonusObjectivePosition == 'AUTO' and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
			rewardsFrame:Point('TOPLEFT', block, 'TOPRIGHT', -10, -4)
		else
			rewardsFrame:Point('TOPRIGHT', block, 'TOPLEFT', 10, -4)
		end
	end
	hooksecurefunc('BonusObjectiveTracker_AnimateReward', RewardsFrame_SetPosition)

	-- objectiveFrameAutoHide
	ObjectiveTrackerFrame.AutoHider = CreateFrame('Frame', nil, ObjectiveTrackerFrame, 'SecureHandlerStateTemplate')
	ObjectiveTrackerFrame.AutoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
	ObjectiveTrackerFrame.AutoHider:SetScript('OnHide', function()
		if not ObjectiveTrackerFrame.collapsed then
			if E.db.general.objectiveFrameAutoHideInKeystone then
				_G.ObjectiveTracker_Collapse()
			else
				local _, _, difficultyID = GetInstanceInfo()
				if difficultyID and difficultyID ~= 8 then -- ignore hide in keystone runs
					_G.ObjectiveTracker_Collapse()
				end
			end
		end
	end)

	ObjectiveTrackerFrame.AutoHider:SetScript('OnShow', function()
		if ObjectiveTrackerFrame.collapsed then
			_G.ObjectiveTracker_Expand()
		end
	end)

	B:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'SetupTorghastBuffFrame')
	B:SetupTorghastBuffFrame()

	self:SetObjectiveFrameAutoHide()
end
