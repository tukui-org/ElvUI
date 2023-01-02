local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

function B:KillBlizzard() -- current not E.Retail
	_G.Advanced_UIScaleSlider:Kill()
	_G.Advanced_UseUIScale:Kill()
end

local function AcknowledgeTips()
	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function B:DisableHelpTip() -- auto complete helptips
	if not E.global.general.disableTutorialButtons then return end

	hooksecurefunc(_G.HelpTip, 'Show', AcknowledgeTips)
	E:Delay(1, AcknowledgeTips)
end

-- Blizzard_NewPlayerExperience: ActionBars heavily conflicts with this
local function ShutdownNPE()
	local NPE = _G.NewPlayerExperience
	if NPE and NPE:GetIsActive() then
		NPE:Shutdown()
	end

	return NPE
end

-- Blizzard_TutorialManager: similar to NPE
local Tutorial_Frames = {
	'TutorialWalk_Frame',
	'TutorialSingleKey_Frame',
	'TutorialMainFrame_Frame',
	'TutorialKeyboardMouseFrame_Frame'
}

local function ShutdownTM()
	local TM = _G.TutorialManager
	if TM and TM:GetIsActive() then
		TM:Shutdown()

		-- these aren't hidden by the shutdown
		for _, name in next, Tutorial_Frames do
			_G[name]:Kill()
		end
	end

	return TM
end

-- Blizzard_Tutorials: implemented kinda weird
local Blizzard_Tutorials = {
	-- Blizzard_Tutorials_Professions.lua
	'Class_ProfessionInventoryWatcher',
	'Class_ProfessionGearCheckingService',
	'Class_EquipProfessionGear',
	'Class_FirstProfessionWatcher',
	'Class_FirstProfessionTutorial',

	-- Blizzard_Tutorials_Classes.lua
	'Class_StarterTalentWatcher'
}

local function ShutdownGT()
	local GT = _G.GameTutorials
	if GT then
		-- shut some down, they are running but not used
		for _, name in next, Blizzard_Tutorials do
			_G[name]:OnComplete()
		end

		-- these are extra annoying because while they have OnComplete
		-- they also call things that will break because TM is shutdown
		local CS = _G.Class_ChangeSpec
		if CS then -- Class_ChangeSpec:OnComplete()
			_G.Dispatcher:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', CS)
			_G.Dispatcher:UnregisterEvent('PLAYER_TALENT_UPDATE', CS)
			_G.Dispatcher:UnregisterEvent('PLAYER_LEVEL_CHANGED', CS)
			_G.EventRegistry:UnregisterCallback('TalentFrame.OpenFrame', CS)
			_G.EventRegistry:UnregisterCallback('TalentFrame.CloseFrame', CS)
			_G.EventRegistry:UnregisterCallback('TalentFrame.SpecTab.ActivateSpec', CS)

			-- CS:CleanUpCallbacks() -- for now this is empty so no reason to do it?
		end

		local TP = _G.Class_TalentPoints
		if TP then -- Class_TalentPoints:OnComplete()
			_G.Dispatcher:UnregisterEvent('PLAYER_TALENT_UPDATE', TP)
			_G.Dispatcher:UnregisterEvent('PLAYER_LEVEL_CHANGED', TP)
			_G.Dispatcher:UnregisterEvent('ACTIVE_COMBAT_CONFIG_CHANGED', TP)
			_G.EventRegistry:UnregisterCallback('TalentFrame.SpecTab.Show', TP)
			_G.EventRegistry:UnregisterCallback('TalentFrame.TalentTab.Show', TP)
			_G.EventRegistry:UnregisterCallback('TalentFrame.OpenFrame', TP)
			_G.EventRegistry:UnregisterCallback('TalentFrame.CloseFrame', TP)
		end
	end

	return GT
end

local function ShutdownTutorials(event)
	local TM, NPE, GT = ShutdownTM(), ShutdownNPE(), ShutdownGT()
	if TM and NPE and GT then -- they exist unregister this
		B:UnregisterEvent(event)
	end
end

-- disable new player experience stuff
function B:DisableTutorials()
	local TM, NPE, GT = ShutdownTM(), ShutdownNPE(), ShutdownGT()
	if not TM or not NPE or not GT then -- wait for them to exist
		B:RegisterEvent('ADDON_LOADED', ShutdownTutorials)
	end
end
