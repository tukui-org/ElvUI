local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_GenericTraitUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.genericTrait) then return end

	local GenericTrait = _G.GenericTraitFrame
	if E.private.skins.parchmentRemoverEnable then
		GenericTrait.Background:SetAlpha(0)
		GenericTrait.BorderOverlay:SetAlpha(0)
	end

	GenericTrait:SetTemplate('Transparent')
	S:HandleCloseButton(GenericTrait.CloseButton)

	local unspentCount = GenericTrait.Currency.UnspentPointsCount
	if unspentCount then
		S.ReplaceIconString(unspentCount)

		hooksecurefunc(unspentCount, 'SetText', S.ReplaceIconString)
	end
end

S:AddCallbackForAddon('Blizzard_GenericTraitUI')
