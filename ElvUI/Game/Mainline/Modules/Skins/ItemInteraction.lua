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

	local buttonFrame = mainFrame.ButtonFrame
	buttonFrame:StripTextures()
	buttonFrame.ButtonBorder:Hide()
	buttonFrame.ButtonBottomBorder:Hide()
	buttonFrame.MoneyFrameEdge:SetAlpha(0)
	buttonFrame.BlackBorder:SetAlpha(0)

	if buttonFrame.Currency then
		S:HandleIcon(buttonFrame.Currency.Icon)
	end

	S:HandleButton(buttonFrame.ActionButton)
end

S:AddCallbackForAddon('Blizzard_ItemInteractionUI')
