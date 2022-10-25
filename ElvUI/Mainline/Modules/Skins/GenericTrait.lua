local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_GenericTraitUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.genericTrait) then return end

	local GenericTrait = _G.GenericTraitFrame

	if E.private.skins.parchmentRemoverEnable then
		GenericTrait:StripTextures()
	end

	GenericTrait:SetTemplate('Transparent')
	S:HandleCloseButton(GenericTrait.CloseButton)
end

S:AddCallbackForAddon('Blizzard_GenericTraitUI')
