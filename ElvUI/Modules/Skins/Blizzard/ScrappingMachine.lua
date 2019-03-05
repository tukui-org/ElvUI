local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs = pairs
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Scrapping ~= true then return end

	local MachineFrame = _G.ScrappingMachineFrame
	S:HandlePortraitFrame(MachineFrame, true)
	S:HandleButton(MachineFrame.ScrapButton)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		button:StripTextures()
		button:SetTemplate()
		S:HandleIcon(button.Icon)
		button.IconBorder:SetAlpha(0)
		hooksecurefunc(button.IconBorder, 'SetVertexColor', function(_, r, g, b) button:SetBackdropBorderColor(r, g, b) end)
		hooksecurefunc(button.IconBorder, 'Hide', function() button:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	end

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag("LeftButton")
	MachineFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	MachineFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI', "ScrappingMachine", LoadSkin)
