local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Scrapping ~= true then return end

	local MachineFrame = _G["ScrappingMachineFrame"]
	MachineFrame:StripTextures()
	ScrappingMachineFrameInset:Hide()
	MachineFrame.ScrapButton.LeftSeparator:Hide()
	MachineFrame.ScrapButton.RightSeparator:Hide()

	MachineFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(ScrappingMachineFrameCloseButton)
	S:HandleButton(MachineFrame.ScrapButton)

	-- TO DO: SKIN THE ITEM SLOTS
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI', "ScrappingMachine", LoadSkin)