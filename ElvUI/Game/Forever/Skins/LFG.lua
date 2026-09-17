local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

-- /run GroupFinderVanillaStyle_LoadUI() _G.LFGParentFrame:Show()

function S:Blizzard_GroupFinder_VanillaStyle()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end
end

S:AddCallbackForAddon('Blizzard_GroupFinder_VanillaStyle')
