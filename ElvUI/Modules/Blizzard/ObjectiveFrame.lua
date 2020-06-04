local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
		RegisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists] 1;0")
	else
		UnregisterStateDriver(_G.ObjectiveTrackerFrame.AutoHider, "objectiveHider")
	end
end

function B:MoveObjectiveFrame()
	local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", E.UIParent)
	ObjectiveFrameHolder:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)
	ObjectiveFrameHolder:Size(130, 22)

	E:CreateMover(ObjectiveFrameHolder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')
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
		if E.db.general.bonusObjectivePosition == "RIGHT" or (E.db.general.bonusObjectivePosition == "AUTO" and IsFramePositionedLeft(ObjectiveTrackerFrame)) then
			rewardsFrame:Point("TOPLEFT", block, "TOPRIGHT", -10, -4)
		else
			rewardsFrame:Point("TOPRIGHT", block, "TOPLEFT", 10, -4)
		end
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)

	-- objectiveFrameAutoHide: the states here are managed otherwise by: "ObjectiveTracker_Collapse" and "ObjectiveTracker_Expand"
	ObjectiveTrackerFrame.AutoHider = CreateFrame('Frame', nil, ObjectiveTrackerFrame, 'SecureHandlerStateTemplate')
	ObjectiveTrackerFrame.AutoHider:SetFrameRef('ObjectiveTrackerFrame', ObjectiveTrackerFrame)
	ObjectiveTrackerFrame.AutoHider:SetAttribute('_onstate-objectiveHider', [[
		local frame = self:GetFrameRef('ObjectiveTrackerFrame')
		if newstate == 1 then -- collapse
			if frame.BlocksFrame:IsShown() then
				local _, _, difficultyID = GetInstanceInfo()
				if difficultyID and difficultyID ~= 8 then -- dont touch it in keystone runs
					frame.collapsed = true

					frame.BlocksFrame:Hide()
					frame.HeaderMenu.Title:Show()

					if frame.HeaderMenu.MinimizeButton.tex then
						minimizeButton.tex:SetTexture(E.Media.Textures.PlusButton)
					else
						frame.HeaderMenu.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
						frame.HeaderMenu.MinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
					end
				end
			end
		elseif not frame.BlocksFrame:IsShown() then
			frame.collapsed = nil

			frame.BlocksFrame:Show()
			frame.HeaderMenu.Title:Hide()

			if frame.HeaderMenu.MinimizeButton.tex then
				frame.HeaderMenu.MinimizeButton.tex:SetTexture(E.Media.Textures.MinusButton)
			else
				frame.HeaderMenu.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
				frame.HeaderMenu.MinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
			end
		end
	]])

	self:SetObjectiveFrameAutoHide()
end
