local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ItemUpgradeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemUpgrade) then return end

	-- Main Frame
	local ItemUpgrade = _G.ItemUpgradeFrame
	ItemUpgrade:StripTextures()
	ItemUpgrade:SetTemplate('Transparent')

	local ItemButton = ItemUpgrade.ItemButton
	ItemButton:StripTextures()
	ItemButton:SetTemplate(nil, true)
	ItemButton:StyleButton()

	ItemUpgrade.ButtonFrame:StripTextures()

	-- Close Button
	S:HandleCloseButton(_G.ItemUpgradeFrameCloseButton)

	-- Upgrade Button
	S:HandleButton(_G.ItemUpgradeFrameUpgradeButton)

	-- Remaining Artwork
	_G.ItemUpgradeFrameMoneyFrame:StripTextures()
	_G.ItemUpgradeFrameMoneyFrame:SetTemplate('Default')
end

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI')
