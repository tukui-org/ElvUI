local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ItemInteractionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemInteraction) then return end

	local mainFrame = _G.ItemInteractionFrame
	S:HandlePortraitFrame(mainFrame)

	local itemSlot = mainFrame.ItemSlot
	itemSlot:StripTextures()
	itemSlot:SetTemplate()
	itemSlot:Size(58)
	itemSlot:ClearAllPoints()
	itemSlot:Point('TOPLEFT', 143, -97)

	itemSlot.GlowOverlay:SetAlpha(0)

	itemSlot.Icon:ClearAllPoints()
	itemSlot.Icon:Point('TOPLEFT', 1, -1)
	itemSlot.Icon:Point('BOTTOMRIGHT', -1, 1)
	S:HandleIcon(itemSlot.Icon)

	local ButtonFrame = mainFrame.ButtonFrame
	ButtonFrame:StripTextures()
	ButtonFrame.ButtonBorder:Hide()
	ButtonFrame.ButtonBottomBorder:Hide()
	ButtonFrame.MoneyFrameEdge:SetAlpha(0)
	ButtonFrame.BlackBorder:SetAlpha(0)

	S:HandleIcon(ButtonFrame.Currency.icon)
	S:HandleButton(ButtonFrame.ActionButton)
end

S:AddCallbackForAddon('Blizzard_ItemInteractionUI')
