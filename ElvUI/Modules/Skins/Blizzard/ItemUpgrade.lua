local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ItemUpgradeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemUpgrade) then return end

	local ItemUpgradeFrame = _G.ItemUpgradeFrame
	S:HandlePortraitFrame(ItemUpgradeFrame)

	ItemUpgradeFrame.UpgradeCostFrame.BGTex:StripTextures()
	ItemUpgradeFrame.UpgradeItemButton.ButtonFrame:StripTextures()
	ItemUpgradeFrame.UpgradeItemButton.ButtonFrame:CreateBackdrop('Transparent')

	ItemUpgradeFramePlayerCurrenciesBorder:StripTextures()

	S:HandleButton(ItemUpgradeFrame.UpgradeButton, true)

	S:HandleDropDownBox(ItemUpgradeFrame.ItemInfo.Dropdown, 130)
end

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI')
