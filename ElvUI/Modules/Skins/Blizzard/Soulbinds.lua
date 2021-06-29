local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

-- Credits: siweia - Aurora Classic
function S:Blizzard_Soulbinds()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.soulbinds) then return end

	local frame = _G.SoulbindViewer
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.CommitConduitsButton)
	frame.CommitConduitsButton:SetFrameLevel(10)
	S:HandleButton(frame.ActivateSoulbindButton)
	frame.ActivateSoulbindButton:SetFrameLevel(10)
end

S:AddCallbackForAddon('Blizzard_Soulbinds')
