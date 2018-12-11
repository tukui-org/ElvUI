local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Scrapping ~= true then return end

	local MachineFrame = _G["ScrappingMachineFrame"]
	MachineFrame:StripTextures()
	ScrappingMachineFrameInset:Hide()

	MachineFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(ScrappingMachineFrameCloseButton)
	S:HandleButton(MachineFrame.ScrapButton)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		button:StripTextures()
		button:SetTemplate()
		S:HandleTexture(button.Icon)
		button.IconBorder:SetAlpha(0)
		hooksecurefunc(button.IconBorder, 'SetVertexColor', function(self, r, g, b) button:SetBackdropBorderColor(r, g, b) end)
		hooksecurefunc(button.IconBorder, 'Hide', function() button:SetBackdropBorderColor(E['media'].bordercolor) end)
	end

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag("LeftButton")
	MachineFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	MachineFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI', "ScrappingMachine", LoadSkin)
