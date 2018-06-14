local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteRespec ~= true then return end

	local AzeriteRespecFrame = _G["AzeriteRespecFrame"]
	--AzeriteRespecFrame:StripTextures()
	--AzeriteRespecFrame:CreateBackdrop("Transparent")
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespec", LoadSkin)