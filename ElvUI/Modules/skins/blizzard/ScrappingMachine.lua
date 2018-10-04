local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack

--WoW API / Variables
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local hooksecurefunc = hooksecurefunc
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

	local function refreshIcon(self)
		local quality = 1
		if self.itemLocation and not self.item:IsItemEmpty() and self.item:GetItemName() then
			quality = self.item:GetItemQuality()
		end
		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if color and self.itemLocation and not self.item:IsItemEmpty() and self.item:GetItemName() then
			self.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.backdrop:SetBackdropBorderColor(nil) -- Clear the BackdropBorderColor if no item is in the slot.
		end
	end

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		if not button.styled then
			button:CreateBackdrop("Default")

			button.Icon:SetTexCoord(unpack(E.TexCoords))
			button.IconBorder:SetAlpha(0)

			hooksecurefunc(button, "RefreshIcon", refreshIcon)

			button.styled = true
		end
	end

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag("LeftButton")
	MachineFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	MachineFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI', "ScrappingMachine", LoadSkin)
