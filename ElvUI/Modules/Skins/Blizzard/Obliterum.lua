local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_ObliterumUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.Obliterum) then return end

	local ObliterumForgeFrame = _G.ObliterumForgeFrame
	S:HandlePortraitFrame(ObliterumForgeFrame, true)
	ObliterumForgeFrame.ItemSlot:CreateBackdrop()
	ObliterumForgeFrame.ItemSlot.Icon:SetTexCoord(unpack(E.TexCoords))
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end

S:AddCallbackForAddon('Blizzard_ObliterumUI')
