local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

function B:KillBlizzard()
	_G.Display_UIScaleSlider:Kill()
	_G.Display_UseUIScale:Kill()
end

local function AcknowledgeTips()
	if InCombatLockdown() then return end -- just incase cause this code path will call SetCVar

	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function B:DisableHelpTip() -- auto complete helptips
	if not E.global.general.disableTutorialButtons then return end

	hooksecurefunc(_G.HelpTip, 'Show', AcknowledgeTips)
	E:Delay(1, AcknowledgeTips)
end

-- NOTE: ActionBars heavily conflicts with NPE
local function ShutdownNPE()
	local NPE = _G.NewPlayerExperience
	if NPE and NPE:GetIsActive() then
		NPE:Shutdown()
	end
end

function B:DisableNPE() -- disable new player experience
	if _G.NewPlayerExperience then
		ShutdownNPE()
	else
		B:RegisterEvent('ADDON_LOADED', ShutdownNPE)
	end
end
