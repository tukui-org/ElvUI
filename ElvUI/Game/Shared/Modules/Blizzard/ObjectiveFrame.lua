local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local min = min
local hooksecurefunc = hooksecurefunc

local UIParent = UIParent
local CreateFrame = CreateFrame
local ShowUIPanel = ShowUIPanel
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

local C_TalkingHead_SetConversationsDeferred = C_TalkingHead and C_TalkingHead.SetConversationsDeferred

function BL:ObjectiveTracker_GetTracker()
	return ((E.Wrath or E.Mists) and _G.WatchFrame) or _G.ObjectiveTrackerFrame
end

function BL:ObjectiveTracker_HasQuestTracker()
	return E.OtherAddons.KalielsTracker or E.OtherAddons.DugisGuideViewerZ
end

function BL:ObjectiveTracker_IsCollapsed(frame)
	return frame:GetParent() == E.HiddenFrame
end

function BL:ObjectiveTracker_Collapse(frame)
	frame:SetParent(E.HiddenFrame)
end

function BL:ObjectiveTracker_Expand(frame)
	frame:SetParent(_G.UIParent)
end

function BL:ObjectiveTracker_AutoHide()
	if E.OtherAddons.BigWigs or E.OtherAddons.DBM then return end

	local tracker = BL:ObjectiveTracker_GetTracker()
	if not tracker then return end

	local autoHider = BL.ObjectiveTrackerAutoHider
	if not autoHider then
		autoHider = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
		autoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
		autoHider:SetScript('OnHide', BL.ObjectiveTracker_AutoHideOnHide)
		autoHider:SetScript('OnShow', BL.ObjectiveTracker_AutoHideOnShow)

		BL.ObjectiveTrackerAutoHider = autoHider
	end

	if E.db.general.objectiveFrameAutoHide then
		RegisterStateDriver(autoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
	else
		UnregisterStateDriver(autoHider, 'objectiveHider')

		BL:ObjectiveTracker_AutoHideOnShow() -- reshow it when needed
	end
end

function BL:ObjectiveTracker_AutoHideOnShow()
	local tracker = BL:ObjectiveTracker_GetTracker()
	if not tracker then return end

	if E.Wrath then
		if tracker.collapsed then
			tracker.userCollapsed = nil

			_G.WatchFrame_Expand(tracker)
		end
	elseif BL:ObjectiveTracker_IsCollapsed(tracker) then
		BL:ObjectiveTracker_Expand(tracker)
	end
end

function BL:ObjectiveTracker_AutoHideOnHide()
	local tracker = BL:ObjectiveTracker_GetTracker()
	if not tracker then return end

	if E.Wrath then
		if not tracker.collapsed then
			tracker.userCollapsed = true

			_G.WatchFrame_Collapse(tracker)
		end
	else
		if BL:ObjectiveTracker_IsCollapsed(tracker) then
			return -- dont hide twice
		end

		if E.Retail then
			if E.db.general.objectiveFrameAutoHideInKeystone then
				BL:ObjectiveTracker_Collapse(tracker)
			else
				local _, _, difficultyID = GetInstanceInfo()
				if difficultyID ~= 8 then -- ignore hide in keystone runs
					BL:ObjectiveTracker_Collapse(tracker)
				end
			end
		else
			BL:ObjectiveTracker_Collapse(tracker)
		end
	end
end

function BL:SplashFrame_OnHide() -- Clone of SplashFrameMixin:OnHide() to remove Objective Update to prevent taint on the Quest Button
	local fromGameMenu = self.screenInfo and self.screenInfo.gameMenuRequest
	self.screenInfo = nil

	C_TalkingHead_SetConversationsDeferred(false)

	_G.AlertFrame:SetAlertsEnabled(true, 'splashFrame')

	if fromGameMenu and not self.showingQuestDialog and not InCombatLockdown() then
		ShowUIPanel(_G.GameMenuFrame)
	end

	self.showingQuestDialog = nil
end

function BL:ObjectiveTracker_SetPoint(_, parent)
	if parent ~= self.holder then
		self:ClearAllPoints()
		self:SetPoint('TOP', self.holder)
	end
end

function BL:ObjectiveTracker_SetHeight()
	local tracker = BL:ObjectiveTracker_GetTracker()
	local top = tracker:GetTop() or 0
	local gapFromTop = E.screenHeight - top
	local maxHeight = E.screenHeight - gapFromTop
	local frameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)

	tracker:Height(frameHeight)
end

function BL:ObjectiveTracker_SetupModern()
	BL:ObjectiveTracker_AutoHide()

	local splash = _G.SplashFrame
	if splash then
		splash:SetScript('OnHide', BL.SplashFrame_OnHide)
	end
end

function BL:ObjectiveTracker_SetupLegacy()
	local holder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	holder:Point('TOPRIGHT', -135, -300)
	holder:Size(130, 22)

	E:CreateMover(holder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,blizzardImprovements')
	holder:SetAllPoints(_G.ObjectiveFrameMover)

	-- prevent it from being moved by blizzard (the hook below will most likely do nothing now)
	local tracker = BL:ObjectiveTracker_GetTracker()
	tracker:SetMovable(true)
	tracker:SetUserPlaced(true)
	tracker:SetDontSavePosition(true)
	tracker:SetClampedToScreen(false)
	tracker:ClearAllPoints()
	tracker:SetPoint('TOP', holder)

	tracker.holder = holder
	hooksecurefunc(tracker, 'SetPoint', BL.ObjectiveTracker_SetPoint)

	BL:ObjectiveTracker_AutoHide() -- supported but no boss frames, only works for arena
	BL:ObjectiveTracker_SetHeight()
end

function BL:HandleObjectiveTracker()
	if E.Classic or E.TBC then
		if E.db.general.objectiveTracker then
			BL:QuestWatch_CreateMover(_G.QuestWatchFrame, 'QuestWatchFrameMover')

			hooksecurefunc('QuestWatch_Update', BL.QuestWatch_AddQuestClick)
		end
	elseif not BL:ObjectiveTracker_HasQuestTracker() then
		if E.Wrath or E.Mists then
			BL:ObjectiveTracker_SetupLegacy()
		else
			BL:ObjectiveTracker_SetupModern()
		end
	end
end
