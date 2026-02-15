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

-- Recovery for ObjectiveTracker not restoring after scenario/Nemesis transitions with ElvUI.
function BL:ObjectiveTracker_RecoverVisibility()
	if InCombatLockdown() then return end

	local isInstance, instanceType = IsInInstance()
	if not (isInstance and instanceType == 'scenario') then return end

	local tracker = _G.ObjectiveTrackerFrame
	if tracker and not tracker:IsShown() then
		if _G.ObjectiveTracker_Update then
			_G.ObjectiveTracker_Update()
		end
		tracker:Show()

		local scenarioTracker = _G.ScenarioObjectiveTracker
		if scenarioTracker then
			scenarioTracker:Show()
		end
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
