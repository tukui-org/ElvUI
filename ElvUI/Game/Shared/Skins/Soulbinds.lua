local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_Soulbinds')
data.toggle = 'soulbinds'

-- Credits: siweia - Aurora Classic
function S:Blizzard_Soulbinds()
	local frame = _G.SoulbindViewer
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.CommitConduitsButton)
	frame.CommitConduitsButton:SetFrameLevel(10)
	S:HandleButton(frame.ActivateSoulbindButton)
	frame.ActivateSoulbindButton:SetFrameLevel(10)
end
