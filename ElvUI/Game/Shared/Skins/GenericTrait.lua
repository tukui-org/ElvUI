local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local data = S:AddCallbackForAddon('Blizzard_GenericTraitUI')
data.toggle = 'genericTrait'

function S:Blizzard_GenericTraitUI()
	local GenericTrait = _G.GenericTraitFrame
	if E.private.skins.parchmentRemoverEnable then
		GenericTrait.Background:SetAlpha(0)
		GenericTrait.BorderOverlay:SetAlpha(0)
		GenericTrait.NineSlice:SetAlpha(0)

		-- should we also handle these?
		--GenericTrait.Header.TitleDivider:SetAlpha(0)
		--GenericTrait.Inset:StripTextures()
		--GenericTrait.Currency.CurrencyBackground:SetAlpha(0)
	end

	GenericTrait:SetTemplate('Transparent')
	S:HandleCloseButton(GenericTrait.CloseButton)

	local unspentCount = GenericTrait.Currency.UnspentPointsCount
	S.ReplaceIconString(unspentCount)
	hooksecurefunc(unspentCount, 'SetText', S.ReplaceIconString)
end
