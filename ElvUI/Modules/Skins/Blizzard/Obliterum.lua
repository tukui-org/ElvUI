local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Obliterum ~= true then return end

	local ObliterumForgeFrame = _G.ObliterumForgeFrame
	S:HandlePortraitFrame(ObliterumForgeFrame, true)
	ObliterumForgeFrame.ItemSlot:CreateBackdrop()
	ObliterumForgeFrame.ItemSlot.Icon:SetTexCoord(unpack(E.TexCoords))
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end

S:AddCallbackForAddon('Blizzard_ObliterumUI', "Obliterum", LoadSkin)
