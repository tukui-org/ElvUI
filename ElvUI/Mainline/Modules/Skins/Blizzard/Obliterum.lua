local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_ObliterumUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.obliterum) then return end

	local ObliterumForgeFrame = _G.ObliterumForgeFrame
	S:HandlePortraitFrame(ObliterumForgeFrame)
	ObliterumForgeFrame.ItemSlot:SetTemplate()
	ObliterumForgeFrame.ItemSlot.Icon:SetTexCoord(unpack(E.TexCoords))
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end

S:AddCallbackForAddon('Blizzard_ObliterumUI')
