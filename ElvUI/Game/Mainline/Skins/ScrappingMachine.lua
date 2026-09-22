local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_ScrappingMachineUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.scrapping) then return end

	local MachineFrame = _G.ScrappingMachineFrame
	S:HandlePortraitFrame(MachineFrame)
	S:HandleButton(MachineFrame.ScrapButton)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()
	ItemSlots:CreateBackdrop('Transparent')
	ItemSlots.backdrop:SetOutside(nil, 30, 10)

	for button in ItemSlots.scrapButtons:EnumerateActive() do
		button:StripTextures()

		S:HandleIcon(button.Icon, true)
		S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)

		local r, g, b = unpack(E.media.bordercolor)
		button.Icon.backdrop:SetBackdropBorderColor(r, g, b)
	end

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag('LeftButton')
	MachineFrame:SetScript('OnDragStart', function(frame) frame:StartMoving() end)
	MachineFrame:SetScript('OnDragStop', function(frame) frame:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI')
