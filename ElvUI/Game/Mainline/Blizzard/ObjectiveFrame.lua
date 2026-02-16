local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local ShowUIPanel = ShowUIPanel
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance

local C_TalkingHead_SetConversationsDeferred = C_TalkingHead.SetConversationsDeferred

function BL:ObjectiveTracker_AutoHideOnHide()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker or BL:ObjectiveTracker_IsCollapsed(tracker) then return end

	if E.db.general.objectiveFrameAutoHideInKeystone then
		BL:ObjectiveTracker_Collapse(tracker)
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			BL:ObjectiveTracker_Collapse(tracker)
		end
	end
end

-- Clone of SplashFrameMixin:OnHide() to remove Objective Update to prevent taint on the Quest Button
local function SplashFrame_OnHide(frame)
	local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
	frame.screenInfo = nil

	C_TalkingHead_SetConversationsDeferred(false)
	_G.AlertFrame:SetAlertsEnabled(true, 'splashFrame')
	-- ObjectiveTrackerFrame:Update()

	if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then
		ShowUIPanel(_G.GameMenuFrame)
	end

	frame.showingQuestDialog = nil
end

-- Recovery for ObjectiveTracker not restoring after scenario transitions.
-- In some cases ElvUI collapses the tracker by re-parenting it to E.HiddenFrame.
-- A simple :Show() will not restore visibility in that state, so we must expand first.
function BL:ObjectiveTracker_RecoverVisibility()
	if InCombatLockdown() then return end

	local isInstance, instanceType = IsInInstance()
	if not (isInstance and instanceType == 'scenario') then return end

	local tracker = _G.ObjectiveTrackerFrame
	if not tracker then return end

	-- If the tracker is collapsed (re-parented to E.HiddenFrame),
	-- expanding it restores the proper parent and visibility state.
	if self.ObjectiveTracker_IsCollapsed and self:ObjectiveTracker_IsCollapsed(tracker) then
		if self.ObjectiveTracker_Expand then
			self:ObjectiveTracker_Expand(tracker)
		end
	end

	-- Fallback: ensure the tracker frame itself is visible.
	-- We intentionally avoid calling ObjectiveTracker_Update()
	-- to prevent potential taint or secure execution issues.
	if not tracker:IsShown() then
		tracker:Show()
	end

	-- Ensure the Scenario sub-tracker is visible as well.
	local scenarioTracker = _G.ScenarioObjectiveTracker
	if scenarioTracker and not scenarioTracker:IsShown() then
		scenarioTracker:Show()
	end
end

function BL:ObjectiveTracker_Setup()
	BL:ObjectiveTracker_AutoHide()

	local splash = _G.SplashFrame
	if splash then
		splash:SetScript('OnHide', SplashFrame_OnHide)
	end

	-- Register events for ObjectiveTracker recovery in scenarios
	BL:RegisterEvent('PLAYER_REGEN_ENABLED', 'ObjectiveTracker_RecoverVisibility')
	BL:RegisterEvent('SCENARIO_UPDATE', 'ObjectiveTracker_RecoverVisibility')
	BL:RegisterEvent('QUEST_LOG_UPDATE', 'ObjectiveTracker_RecoverVisibility')
end
