local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- SHADOWLANDS
function S:Blizzard_AnimaDiversionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.AnimaDiversion) then return end

	local frame = _G.AnimaDiversionFrame
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 4, 4) --default is -5, -5

	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)
	frame.AnimaDiversionCurrencyFrame.Background:CreateBackdrop('Transparent')
	frame.AnimaDiversionCurrencyFrame.Background.backdrop:SetPoint('TOPLEFT', frame.AnimaDiversionCurrencyFrame, 'TOPLEFT', 0, -7)
	frame.AnimaDiversionCurrencyFrame.Background.backdrop:SetPoint('BOTTOMRIGHT', frame.AnimaDiversionCurrencyFrame, 'BOTTOMRIGHT', 0, 7)
	S:HandleIcon(frame.AnimaDiversionCurrencyFrame.CurrencyFrame.CurrencyIcon)
end

S:AddCallbackForAddon('Blizzard_AnimaDiversionUI')
