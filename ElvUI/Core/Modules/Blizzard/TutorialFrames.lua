local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
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

-- ActionBars heavily conflicts with NPE
local function ShutdownNPE()
	local NPE = _G.NewPlayerExperience
	if NPE and NPE:GetIsActive() then
		NPE:Shutdown()
	end

	return NPE
end

-- similar to NPE but not NPE
local function ShutdownTM()
	local TM = _G.TutorialManager
	if TM and TM:GetIsActive() then
		TM:Shutdown()

		-- these aren't hidden by the shutdown
		_G.TutorialWalk_Frame:Kill()
		_G.TutorialSingleKey_Frame:Kill()
		_G.TutorialMainFrame_Frame:Kill()
		_G.TutorialKeyboardMouseFrame_Frame:Kill()
	end

	return TM
end

local function ShutdownTutorials(event)
	local TM, NPE = ShutdownTM(), ShutdownNPE()
	if TM and NPE then -- they exist unregister this
		B:UnregisterEvent(event)
	end
end

-- disable new player experience stuff
function B:DisableTutorials()
	local TM, NPE = ShutdownTM(), ShutdownNPE()
	if not TM or not NPE then -- wait for them to exist
		B:RegisterEvent('ADDON_LOADED', ShutdownTutorials)
	end
end
