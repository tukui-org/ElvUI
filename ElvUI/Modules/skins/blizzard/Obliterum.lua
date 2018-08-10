local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ObliterumForgeFrame, ObliterumForgeFramePortrait, ObliterumForgeFramePortraitFrame, ObliterumForgeFrameBg
-- GLOBALS: ObliterumForgeFrameCloseButton

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Obliterum ~= true then return end

	-- Obliterum Forge UI (Legion)
	-- The frame looks really good, just set the template to transparent.
	local ObliterumForgeFrame = _G["ObliterumForgeFrame"]
	ObliterumForgeFrame:SetTemplate("Transparent")
	ObliterumForgeFrameInset:Hide()
	ObliterumForgeFramePortrait:Hide()
	ObliterumForgeFramePortraitFrame:Hide()
	ObliterumForgeFrameTitleBg:Hide()
	ObliterumForgeFrameBg:Hide()
	ObliterumForgeFrameTopBorder:Hide()
	ObliterumForgeFrameTopRightCorner:Hide()
	ObliterumForgeFrameRightBorder:Hide()
	ObliterumForgeFrameLeftBorder:Hide()
	ObliterumForgeFrameBtnCornerRight:Hide()
	ObliterumForgeFrameBotRightCorner:Hide()
	ObliterumForgeFrameBtnCornerLeft:Hide()
	ObliterumForgeFrameBotLeftCorner:Hide()
	ObliterumForgeFrameBottomBorder:Hide()
	ObliterumForgeFrameButtonBottomBorder:Hide()
	ObliterumForgeFrame.ObliterateButton.RightSeparator:Hide()
	ObliterumForgeFrame.ObliterateButton.LeftSeparator:Hide()

	S:HandleCloseButton(ObliterumForgeFrameCloseButton)
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end

S:AddCallbackForAddon('Blizzard_ObliterumUI', "Obliterum", LoadSkin)
