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

	local ObliterumForgeFrame = _G["ObliterumForgeFrame"]
	ObliterumForgeFrame:SetTemplate("Transparent")

	ObliterumForgeFrame.NineSlice:Hide()

	if ObliterumForgeFrame.TitleBg then ObliterumForgeFrame.TitleBg:Hide() end
	if ObliterumForgeFrame.TopTileStreaks then ObliterumForgeFrame.TopTileStreaks:SetTexture("") end
	if ObliterumForgeFramePortrait then ObliterumForgeFramePortrait:Hide() end
	if ObliterumForgeFrameInset then ObliterumForgeFrameInset:Hide() end
	if ObliterumForgeFrameBg then ObliterumForgeFrameBg:Hide() end

	ObliterumForgeFrame.ItemSlot.Icon:SetTexCoord(unpack(E.TexCoords))

	S:HandleCloseButton(ObliterumForgeFrameCloseButton)
	S:HandleButton(ObliterumForgeFrame.ObliterateButton)
end

S:AddCallbackForAddon('Blizzard_ObliterumUI', "Obliterum", LoadSkin)
