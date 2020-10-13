local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_AnimaDiversionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.animaDiversion) then return end

	local frame = _G.AnimaDiversionFrame
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 4, 4) --default is -5, -5

	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)
	S:HandleIcon(frame.AnimaDiversionCurrencyFrame.CurrencyFrame.CurrencyIcon)

	S:HandleButton(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)

	-- Tooltip
	local InfoFrame = frame.SelectPinInfoFrame
	InfoFrame:StripTextures()
	InfoFrame:CreateBackdrop()
	S:HandleButton(InfoFrame.SelectButton)
	S:HandleCloseButton(InfoFrame.CloseButton)

	hooksecurefunc(InfoFrame, 'SetupCosts', function(frame)
		for currency in frame.currencyPool:EnumerateActive() do
			if not currency.IsSkinned then
				S:HandleIcon(currency.CurrencyIcon)

				currency.IsSkinned = true
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_AnimaDiversionUI')
