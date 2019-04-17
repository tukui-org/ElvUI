local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G

function B:KillBlizzard()
	if E.global.general.disableTutorialButtons then
		_G.HelpOpenTicketButtonTutorial:Kill()
		_G.HelpPlate:Kill()
		_G.HelpPlateTooltip:Kill()
	end

	_G.EJMicroButtonAlert:Kill()
	_G.Advanced_UIScaleSlider:Kill()
	_G.Advanced_UseUIScale:Kill()
end
