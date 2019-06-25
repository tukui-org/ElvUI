local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetItemUpgradeItemInfo = GetItemUpgradeItemInfo
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.itemUpgrade ~= true then return end

	local ItemUpgradeFrame = _G.ItemUpgradeFrame
	S:HandlePortraitFrame(ItemUpgradeFrame, true)

	local ItemButton = ItemUpgradeFrame.ItemButton
	ItemButton:CreateBackdrop()
	ItemButton.backdrop:SetAllPoints()
	ItemButton.Frame:SetTexture("")
	ItemButton:SetPushedTexture("")
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
			ItemButton.IconTexture:SetTexture("")
			ItemButton.backdrop:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	local TextFrame = ItemUpgradeFrame.TextFrame
	TextFrame:StripTextures()
	TextFrame:CreateBackdrop('Transparent')
	TextFrame.backdrop:SetPoint("TOPLEFT", ItemButton.IconTexture, "TOPRIGHT", 3, E.mult)
	TextFrame.backdrop:SetPoint("BOTTOMRIGHT", -6, 2)

	_G.ItemUpgradeFrameMoneyFrame:StripTextures()
	S:HandleIcon(_G.ItemUpgradeFrameMoneyFrame.Currency.icon)
	S:HandleButton(_G.ItemUpgradeFrameUpgradeButton, true)
	ItemUpgradeFrame.FinishedGlow:Kill()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end

S:AddCallbackForAddon("Blizzard_ItemUpgradeUI", "ItemUpgrade", LoadSkin)
