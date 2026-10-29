local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_Soulbinds', nil, nil, nil, nil, nil, 'soulbinds')

-- Credits: siweia - Aurora Classic
function S:Blizzard_Soulbinds()
	local frame = _G.SoulbindViewer
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	frame.CommitConduitsButton:SetFrameLevel(10)
	frame.ActivateSoulbindButton:SetFrameLevel(10)

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.CommitConduitsButton)
	S:HandleButton(frame.ActivateSoulbindButton)
end
