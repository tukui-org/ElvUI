local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_GenericTraitUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.genericTrait) then return end

	local GenericTraitFrame = _G.GenericTraitFrame

	if E.private.skins.parchmentRemoverEnable then
		GenericTraitFrame:StripTextures()
	end

	GenericTraitFrame:SetTemplate('Transparent')
	S:HandleCloseButton(GenericTraitFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_GenericTraitUI')
