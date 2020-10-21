local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

local function AcknowledgeTips()
	if E.mylevel > 10 then -- Exiles Reach breaks when this is running
		if InCombatLockdown() then return end -- just incase cause this code path will call SetCVar

		for frame in _G.HelpTip.framePool:EnumerateActive() do
			frame:Acknowledge()
		end
	end
end

function B:DisableHelpTip()
	if not E.global.general.disableTutorialButtons then return end

	if E.mylevel > 10 then
		AcknowledgeTips()
	end

	hooksecurefunc(_G.HelpTip, 'Show', AcknowledgeTips)
end

function B:KillBlizzard()
	_G.Display_UIScaleSlider:Kill()
	_G.Display_UseUIScale:Kill()
end
