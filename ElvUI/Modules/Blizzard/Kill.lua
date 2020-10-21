local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

local function AcknowledgeTips()
	if InCombatLockdown() then return end -- just incase cause this code path will call SetCVar

	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function B:ShutdownNPE()
	local NPE = _G.NewPlayerExperience
	if NPE and NPE:GetIsActive() then
		NPE:Shutdown()
	end
end

function B:DisableHelpTip()
	if not E.global.general.disableTutorialButtons then return end

	-- auto complete helptips
	AcknowledgeTips()
	hooksecurefunc(_G.HelpTip, 'Show', AcknowledgeTips)

	-- disable new player experience
	if _G.NewPlayerExperience then
		B:ShutdownNPE()
	else
		B:RegisterEvent('ADDON_LOADED', 'ShutdownNPE')
	end
end

function B:KillBlizzard()
	_G.Display_UIScaleSlider:Kill()
	_G.Display_UseUIScale:Kill()
end
