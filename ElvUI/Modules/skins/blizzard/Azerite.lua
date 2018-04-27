local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

----------
-- TEMP --
----------

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteUI ~= true then return end

	AzeriteEmpoweredItemUI:StripTextures()
	AzeriteEmpoweredItemUIPortrait:Hide()
	AzeriteEmpoweredItemUIPortraitFrame:Hide()
	AzeriteEmpoweredItemUI:CreateBackdrop("Transparent")

	S:HandleCloseButton(AzeriteEmpoweredItemUICloseButton)

	--TODO: Skin the Azerite Tier Icons
	--[[
	local function SkinIcons()
		-- MY ULTIMATE SKINNING FUNCTION
	end
	hooksecurefunc(AzeriteEmpoweredItemUIMixin, "OnShow", SkinIcons)
	AzeriteEmpoweredItemUI:HookScript("OnShow", SkinIcons)
	]]
end

S:AddCallbackForAddon("Blizzard_AzeriteTempUI", "AzeriteUI", LoadSkin)