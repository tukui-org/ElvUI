local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ItemInteractionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.ItemInteraction) then return end

	local ItemInteractionFrame = _G.ItemInteractionFrame
	S:HandlePortraitFrame(ItemInteractionFrame, true)

	do -- ItemSlot
		local ItemSlot = ItemInteractionFrame.ItemSlot
		ItemSlot:StripTextures()
		ItemSlot:CreateBackdrop()

		ItemSlot:SetSize(58, 58)
		ItemSlot:ClearAllPoints()
		ItemSlot:SetPoint('TOPLEFT', 143, -97)

		ItemSlot.Icon:ClearAllPoints()
		ItemSlot.Icon:SetPoint('TOPLEFT', 1, -1)
		ItemSlot.Icon:SetPoint('BOTTOMRIGHT', -1, 1)
		S:HandleIcon(ItemSlot.Icon)

		ItemSlot.GlowOverlay:SetAlpha(0)
	end

	local ButtonFrame = ItemInteractionFrame.ButtonFrame
	ButtonFrame:StripTextures()
	ButtonFrame.MoneyFrameEdge:SetAlpha(0)
	ButtonFrame.BlackBorder:SetAlpha(0)
	ButtonFrame.ButtonBorder:Hide()
	ButtonFrame.ButtonBottomBorder:Hide()

	ButtonFrame.Currency:SetPoint('BOTTOMRIGHT', ButtonFrame.MoneyFrameEdge, -9, 4)
	ButtonFrame.MoneyFrame:SetPoint('BOTTOMRIGHT', ButtonFrame.MoneyFrameEdge, 7, 5)

	S:HandleIcon(ButtonFrame.Currency.icon)
	S:HandleButton(ButtonFrame.ActionButton)

	-- Temp mover
	ItemInteractionFrame:SetMovable(true)
	ItemInteractionFrame:RegisterForDrag('LeftButton')
	ItemInteractionFrame:SetScript('OnDragStart', function(s) s:StartMoving() end)
	ItemInteractionFrame:SetScript('OnDragStop', function(s) s:StopMovingOrSizing() end)
end

S:AddCallbackForAddon('Blizzard_ItemInteractionUI')
