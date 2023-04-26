local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local wipe, next = wipe, next
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

-- Blizzard_TutorialManager: sort of similar to NPE
local tutorialFrames = {
	'TutorialSingleKey_Frame',
	'TutorialMainFrame_Frame',

	-- dead on PTR (10.1)
	'TutorialKeyboardMouseFrame_Frame',
	'TutorialWalk_Frame'
}

local function ShutdownTM()
	local TM = _G.TutorialManager
	if TM and TM:GetIsActive() then
		TM:Shutdown()

		-- these aren't hidden by the shutdown
		for _, name in next, tutorialFrames do
			local frame = _G[name]
			if frame then
				frame:Kill()
			end
		end
	end

	return TM
end

-- Blizzard_Tutorials: implemented kinda weird, imo tbh
local gameTutorials = {
	-- Blizzard_Tutorials_Professions
	'Class_ProfessionInventoryWatcher',
	'Class_ProfessionGearCheckingService',
	'Class_EquipProfessionGear',
	'Class_FirstProfessionWatcher',
	'Class_FirstProfessionTutorial',

	-- Blizzard_Tutorials_Dracthyr
	'Class_DracthyrEssenceWatcher',

	-- Blizzard_Tutorials_Classes
	'Class_StarterTalentWatcher',
	'Class_TalentPoints',
	'Class_ChangeSpec'
}

local GT_Shutdown = false
local function ShutdownGT()
	local GT = _G.GameTutorials
	if GT and not GT_Shutdown then
		GT_Shutdown = true

		-- shut some down, they are running but not used
		for _, name in next, gameTutorials do
			_G[name]:Complete()
		end
	end

	return GT
end

-- this is the event handler for tutorials, maybe other stuff later?
-- it seems shutdown is not unregistering events for stuff so..
local function ShutdownTD() -- Blizzard_TutorialDispatcher
	local TD = _G.Dispatcher
	if TD then
		wipe(TD.Events)
		wipe(TD.Scripts)
	end

	return TD
end

local function ShutdownTutorials(event)
	local NPE, GT, TM, TD = ShutdownNPE(), ShutdownGT(), ShutdownTM(), ShutdownTD()
	if NPE and GT and TM and TD then -- they exist unregister this
		B:UnregisterEvent(event)
	end
end

-- disable new player experience stuff
function B:DisableTutorials()
	local NPE, GT, TM, TD = ShutdownNPE(), ShutdownGT(), ShutdownTM(), ShutdownTD()
	if not NPE or not GT or not TM or not TD then -- wait for them to exist
		B:RegisterEvent('ADDON_LOADED', ShutdownTutorials)
	end
end
