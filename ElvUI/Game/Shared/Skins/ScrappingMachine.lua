local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI', nil, nil, nil, nil, nil, 'scrapping')

function S:Blizzard_ScrappingMachineUI()
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
