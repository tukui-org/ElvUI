local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteUI ~= true then return end

	AzeriteEmpoweredItemUI:StripTextures()
	AzeriteEmpoweredItemUIPortrait:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()

	AzeriteEmpoweredItemUI:CreateBackdrop("Transparent")

	S:HandleCloseButton(AzeriteEmpoweredItemUICloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteUI", "AzeriteUI", LoadSkin)
