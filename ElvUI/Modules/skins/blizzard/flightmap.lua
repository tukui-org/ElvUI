local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS, OrderHallCommandBar, OrderHallMissionFrame

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local FlightMapFrame = _G["FlightMapFrame"]
	_G["FlightMapFramePortrait"]:Kill()
	FlightMapFrame:StripTextures()
	FlightMapFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(FlightMapFrameCloseButton)
end

S:AddCallbackForAddon('Blizzard_FlightMap', "FlightMap", LoadSkin)
