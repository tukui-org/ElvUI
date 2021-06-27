local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local GetItemUpgradeItemInfo = GetItemUpgradeItemInfo
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS

function S:Blizzard_ItemUpgradeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemUpgrade) then return end

	local ItemUpgradeFrame = _G.ItemUpgradeFrame
	S:HandlePortraitFrame(ItemUpgradeFrame)

	local ItemButton = ItemUpgradeFrame.ItemButton
	ItemButton:SetTemplate()
	ItemButton.Frame:SetTexture('')
	ItemButton:SetPushedTexture('')
	S:HandleItemButton(ItemButton)

	local Highlight = ItemButton:GetHighlightTexture()
	Highlight:SetColorTexture(1, 1, 1, .25)

	hooksecurefunc('ItemUpgradeFrame_Update', function()
		local icon, _, quality = GetItemUpgradeItemInfo()
		if icon then
			ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			ItemButton.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			ItemButton.IconTexture:SetTexture('')
			ItemButton.backdrop:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	local UpgradeDropDown = ItemUpgradeFrame.UpgradeLevelDropDown.DropDownMenu
	S:HandleDropDownBox(UpgradeDropDown, 115)

	local TextFrame = ItemUpgradeFrame.TextFrame
	TextFrame:StripTextures()
	TextFrame:CreateBackdrop('Transparent')
	TextFrame.backdrop:Point('TOPLEFT', ItemButton.IconTexture, 'TOPRIGHT', 3, 1)
	TextFrame.backdrop:Point('BOTTOMRIGHT', -6, 2)

	_G.ItemUpgradeFrameMoneyFrame:StripTextures()
	S:HandleIcon(_G.ItemUpgradeFrameMoneyFrame.Currency.icon)
	S:HandleButton(_G.ItemUpgradeFrameUpgradeButton, true)
	ItemUpgradeFrame.FinishedGlow:Kill()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI')
