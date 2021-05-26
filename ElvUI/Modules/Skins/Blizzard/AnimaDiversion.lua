local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_AnimaDiversionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.animaDiversion) then return end

	local frame = _G.AnimaDiversionFrame
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 4, 4) --default is -5, -5
	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)

	S:HandleButton(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end

S:AddCallbackForAddon('Blizzard_AnimaDiversionUI')
