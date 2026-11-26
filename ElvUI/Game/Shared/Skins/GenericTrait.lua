local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_GenericTraitUI', nil, nil, nil, nil, nil, 'genericTrait')

function S:Blizzard_GenericTraitUI()
	local genericTrait = _G.GenericTraitFrame
	if E.private.skins.parchmentRemoverEnable then
		genericTrait.Background:SetAlpha(0)
		genericTrait.BorderOverlay:SetAlpha(0)
		genericTrait.NineSlice:SetAlpha(0)
	end

	genericTrait:SetTemplate('Transparent')
	S:HandleCloseButton(genericTrait.CloseButton)

	local unspentCount = genericTrait.Currency.UnspentPointsCount
	S.ReplaceIconString(unspentCount)

	hooksecurefunc(unspentCount, 'SetText', S.ReplaceIconString)
end
