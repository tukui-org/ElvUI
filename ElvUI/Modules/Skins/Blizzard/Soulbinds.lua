local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select

-- SHADOWLANDS
function S:Blizzard_Soulbinds()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.soulbinds) then return end

	local frame = _G.SoulbindViewer
	frame:StripTextures()
	select(2, frame.ConduitList.ScrollBox:GetChildren()):Hide() -- Weird shadow on the ScrollBox
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.CommitConduitsButton)
	S:HandleButton(frame.ActivateSoulbindButton)
end

S:AddCallbackForAddon('Blizzard_Soulbinds')
