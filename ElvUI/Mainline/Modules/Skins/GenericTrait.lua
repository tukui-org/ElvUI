local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub
local hooksecurefunc = hooksecurefunc

local function ReplaceIconString(frame, text)
	if not text then text = frame:GetText() end
	if not text or text == '' then return end

	local newText, count = gsub(text, '|T(%d+):24:24[^|]*|t', ' |T%1:16:16:0:0:64:64:5:59:5:59|t')
	if count > 0 then frame:SetFormattedText('%s', newText) end
end

function S:Blizzard_GenericTraitUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.genericTrait) then return end

	local GenericTrait = _G.GenericTraitFrame
	if E.private.skins.parchmentRemoverEnable then
		GenericTrait:StripTextures()
	end

	GenericTrait:SetTemplate('Transparent')
	S:HandleCloseButton(GenericTrait.CloseButton)

	ReplaceIconString(GenericTrait.Currency.UnspentPointsCount)
	hooksecurefunc(GenericTrait.Currency.UnspentPointsCount, 'SetText', ReplaceIconString)
end

S:AddCallbackForAddon('Blizzard_GenericTraitUI')
