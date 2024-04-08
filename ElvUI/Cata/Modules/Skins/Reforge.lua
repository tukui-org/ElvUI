local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local unpack = unpack

local GetReforgeItemInfo = GetReforgeItemInfo

function S:Blizzard_ReforgingUI()
	if not (E.private.skins.blizzard.enable or not E.private.skins.blizzard.reforge) then return end

	_G.ReforgingFrame:StripTextures()
	_G.ReforgingFrame:SetTemplate('Transparent')

	_G.ReforgingFrameFinishedGlow:Kill()

	_G.ReforgingFrameButtonFrame:StripTextures()

	_G.ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1)

	S:HandleButton(_G.ReforgingFrameRestoreButton, true)

	S:HandleButton(_G.ReforgingFrameReforgeButton, true)
	_G.ReforgingFrameReforgeButton:Point('BOTTOMRIGHT', -3, 3)

	_G.ReforgingFrameItemButton:StripTextures()
	_G.ReforgingFrameItemButton:SetTemplate('Default', true)
	_G.ReforgingFrameItemButton:StyleButton()

	_G.ReforgingFrameItemButtonIconTexture:SetInside()
	_G.ReforgingFrameItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))

	_G.ReforgingFrameItemButton.missingText:SetTextColor(1, 0.80, 0.10)
	_G.ReforgingFrame.missingDescription:SetTextColor(1, 1, 1)

	hooksecurefunc('ReforgingFrame_Update', function(self)
		local _, itemID, _, quality = C_Reforge.GetReforgeItemInfo()

		if itemID then
			local itemTexture = C_Item.GetItemIconByID(itemID)
			_G.ReforgingFrameItemButtonIconTexture:SetTexture(itemTexture)
		end

		-- Blizzard bug / commented out on their end / Blizzard_ReforgingUI.lua:101
		--[[
		if quality then
			_G.ReforgingFrameItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			_G.ReforgingFrameItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
		]]
	end)

	S:HandleCloseButton(_G.ReforgingFrameCloseButton)
end

S:AddCallbackForAddon('Blizzard_ReforgingUI')
