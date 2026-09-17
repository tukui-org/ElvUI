local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

-- ToDo: classic_beta
-- PetStableFrame: PetStableCurrentPet, PetStableStabledPet1-2, purchaseButton, modelScene with ControlFrame and Inset, expBar, loyaltyLevel

function S:Blizzard_StableUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end
end

S:AddCallbackForAddon('Blizzard_StableUI')
