local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:SkinBattlefield()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.battlefield) then return end

	-- TODO: Wrath
end

S:AddCallback('SkinBattlefield')
