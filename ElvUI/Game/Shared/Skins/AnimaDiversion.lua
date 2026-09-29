local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_AnimaDiversionUI')
data.toggle = 'animaDiversion'

function S:Blizzard_AnimaDiversionUI()
	local frame = _G.AnimaDiversionFrame
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 4, 4) --default is -5, -5
	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)

	S:HandleButton(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end
