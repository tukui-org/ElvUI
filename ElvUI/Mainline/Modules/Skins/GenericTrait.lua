local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub

local hooksecurefunc = hooksecurefunc

local function ReplaceIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == '' then return end

	local newText, count = gsub(text, '24:24:0:%-2', '14:14:0:0:64:64:5:59:5:59')
	if count > 0 then self:SetFormattedText('%s', newText) end
end

function S:Blizzard_GenericTraitUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.genericTrait) then return end

	local GenericTrait = _G.GenericTraitFrame
	if E.private.skins.parchmentRemoverEnable then
		GenericTrait:StripTextures()
	end

	GenericTrait:CreateBackdrop('Transparent')
	S:HandleCloseButton(GenericTrait.CloseButton)

	ReplaceIconString(GenericTrait.Currency.UnspentPointsCount)
	hooksecurefunc(GenericTrait.Currency.UnspentPointsCount, 'SetText', ReplaceIconString)
end

S:AddCallbackForAddon('Blizzard_GenericTraitUI')
