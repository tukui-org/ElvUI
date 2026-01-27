local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack

function S:Blizzard_ScrappingMachineUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.scrapping) then return end

	local MachineFrame = _G.ScrappingMachineFrame
	S:HandlePortraitFrame(MachineFrame)
	S:HandleButton(MachineFrame.ScrapButton)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	-- this used to be setup good
	for i, button in next, { ItemSlots:GetChildren() } do
		if button.Icon then
			local holder = i == 1 and button:GetParent()
			if holder and not holder.backdrop then
				holder:CreateBackdrop('Transparent')
				holder.backdrop:SetOutside(nil, 30, 10)
			end

			button:StripTextures()
			S:HandleIcon(button.Icon, true)
			S:HandleIconBorder(button.IconBorder, button.Icon.backdrop)
			button.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag('LeftButton')
	MachineFrame:SetScript('OnDragStart', function(frame) frame:StartMoving() end)
	MachineFrame:SetScript('OnDragStop', function(frame) frame:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ScrappingMachineUI')
