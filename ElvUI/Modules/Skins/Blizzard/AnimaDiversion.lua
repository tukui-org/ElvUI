local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub

local hooksecurefunc = hooksecurefunc

local function ReplaceIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == "" then return end

	local newText, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T%1:14:14:0:0:64:64:5:59:5:59|t')
	if count > 0 then self:SetFormattedText('%s', newText) end
end

function S:Blizzard_AnimaDiversionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.animaDiversion) then return end

	local frame = _G.AnimaDiversionFrame
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 4, 4) --default is -5, -5

	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)

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
				ReplaceIconString(currency.Quantity)
				hooksecurefunc(currency.Quantity, 'SetText', ReplaceIconString)

				currency.IsSkinned = true
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_AnimaDiversionUI')
