local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- these have a block frame until you do the little tutorial
local allowTipsFrom = {
	GarrisonMissionTutorialFrame = true,
	VoidStorageFrame = true
}

function B:KillBlizzard()
	if E.global.general.disableTutorialButtons then
		_G.HelpPlate:Kill()
		_G.HelpPlateTooltip:Kill()

		hooksecurefunc(_G.HelpTip, 'Show', function(tip, parent, info)
			local parentName = parent.GetName and parent:GetName()
			if not allowTipsFrom[parentName] then
				tip:Hide(parent, info.text)
			end
		end)
	end
end
