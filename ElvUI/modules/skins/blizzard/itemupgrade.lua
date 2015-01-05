local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.itemUpgrade ~= true then return end

	ItemUpgradeFrame:StripTextures()
	ItemUpgradeFrame:SetTemplate('Transparent')
	--ItemUpgradeFrameShadows:Kill()
	--ItemUpgradeFrameInset:Kill()

	S:HandleCloseButton(ItemUpgradeFrameCloseButton)

	S:HandleItemButton(ItemUpgradeFrame.ItemButton, true)

	hooksecurefunc('ItemUpgradeFrame_Update', function()
		if GetItemUpgradeItemInfo() then
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(1)
			ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
		else
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(0)
		end
	end)

	ItemUpgradeFrameMoneyFrame:StripTextures()
	S:HandleButton(ItemUpgradeFrameUpgradeButton, true)
	ItemUpgradeFrame.FinishedGlow:Kill()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end

S:RegisterSkin("Blizzard_ItemUpgradeUI", LoadSkin)
