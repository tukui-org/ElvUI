local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local unpack = unpack

function S:Blizzard_ScrappingMachineUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.scrapping) then return end

	local MachineFrame = _G.ScrappingMachineFrame
	S:HandlePortraitFrame(MachineFrame)
	S:HandleButton(MachineFrame.ScrapButton)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		button:StripTextures()
		S:HandleIcon(button.Icon, true)
		S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
		button.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag('LeftButton')
	MachineFrame:SetScript('OnDragStart', function(s) s:StartMoving() end)
	MachineFrame:SetScript('OnDragStop', function(s) s:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI')
