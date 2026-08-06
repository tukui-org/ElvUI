local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SkinFrame(frame)
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 1, 0)
end

function S:Blizzard_GenericTraitUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.genericTrait) then return end

	local GenericTrait = _G.GenericTraitFrame

	hooksecurefunc(GenericTrait, 'ApplyLayout', SkinFrame)
end

S:AddCallbackForAddon('Blizzard_GenericTraitUI')
