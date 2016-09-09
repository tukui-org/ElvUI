local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
--WoW API / Variables
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ObliterumForgeFrame, ObliterumForgeFramePortrait, ObliterumForgeFramePortraitFrame, ObliterumForgeFrameBg
-- GLOBALS: ObliterumForgeFrameCloseButton

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Obliterum ~= true then return end

	-- Obliterum Forge UI (Legion)
	-- The frame looks really good, just set the template to transparent.
	ObliterumForgeFrame:SetTemplate("Transparent")
	ObliterumForgeFramePortrait:Hide()
	ObliterumForgeFramePortraitFrame:Hide()
	ObliterumForgeFrameBg:Hide()

	S:HandleCloseButton(ObliterumForgeFrameCloseButton)
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end

S:RegisterSkin('Blizzard_ObliterumUI', LoadSkin)