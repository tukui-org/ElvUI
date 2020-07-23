local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
function B:KillBlizzard()
	if E.global.general.disableTutorialButtons then
		_G.HelpPlate:Kill()
		_G.HelpPlateTooltip:Kill()

		hooksecurefunc(_G.HelpTip, "Show", function(self, parent, info, relativeRegion)
			_G.HelpTip.Hide(self, parent, info.text)
		end)
	end
end
