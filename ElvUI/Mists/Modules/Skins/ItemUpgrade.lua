local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ItemUpgradeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemUpgrade) then return end

	-- Main Frame
	local frame = _G.ItemUpgradeFrame
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	local ItemButton = _G.ItemUpgradeFrame.ItemButton
	if ItemButton then
		ItemButton:StripTextures()
		ItemButton:SetTemplate(nil, true)
		ItemButton:StyleButton()
	end

	-- Close Button
	S:HandleCloseButton(_G.ItemUpgradeFrameCloseButton)

	-- Upgrade Button
	S:HandleButton(_G.ItemUpgradeFrameUpgradeButton)

	-- Remaining Artwork
	_G.ItemUpgradeFrameMoneyFrame:StripTextures()
	_G.ItemUpgradeFrameMoneyFrame:SetTemplate('Default')
	_G.ItemUpgradeFrame.ButtonFrame:StripTextures()
end

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI')
