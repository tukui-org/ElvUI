local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

--Lua functions

function S:Blizzard_ItemInteractionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.ItemInteraction) then return end

end

S:AddCallbackForAddon('Blizzard_ItemInteractionUI')
