local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local min = min

local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local hooksecurefunc = hooksecurefunc

local WatchFrame_Collapse = WatchFrame_Collapse
local WatchFrame_Expand = WatchFrame_Expand
local WatchFrame = WatchFrame

local function ObjectiveTracker_SetPoint(frame, _, parent)
	if parent ~= frame.holder then
		frame:ClearAllPoints()
		frame:SetPoint('TOP', frame.holder)
	end
end

local function AutoHider_OnHide()
	if not WatchFrame.userCollapsed then
		WatchFrame_Collapse(WatchFrame)
	end
end

local function AutoHider_OnShow()
	if WatchFrame.userCollapsed then
		WatchFrame_Expand(WatchFrame)
	end
end

function B:ObjectiveTracker_SetHeight()
	local top = WatchFrame:GetTop() or 0
	local gapFromTop = E.screenHeight - top
	local maxHeight = E.screenHeight - gapFromTop
	local watchFrameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)

	WatchFrame:Height(watchFrameHeight)
end

function B:ObjectiveTracker_AutoHide()
	if not WatchFrame.AutoHider then
		WatchFrame.AutoHider = CreateFrame('Frame', nil, WatchFrame, 'SecureHandlerStateTemplate')
		WatchFrame.AutoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
		WatchFrame.AutoHider:SetScript('OnHide', AutoHider_OnHide)
		WatchFrame.AutoHider:SetScript('OnShow', AutoHider_OnShow)
	end

	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(WatchFrame.AutoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
	else
		UnregisterStateDriver(WatchFrame.AutoHider, 'objectiveHider')
	end
end

function B:ObjectiveTracker_Setup()
	local holder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	holder:Point('TOPRIGHT', E.UIParent, -135, -300)
	holder:Size(130, 22)

	E:CreateMover(holder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')
	holder:SetAllPoints(_G.ObjectiveFrameMover)

	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint('TOP', holder)

	WatchFrame.holder = holder
	hooksecurefunc(WatchFrame, 'SetPoint', ObjectiveTracker_SetPoint)

	B:ObjectiveTracker_AutoHide()
	B:ObjectiveTracker_SetHeight()
end
