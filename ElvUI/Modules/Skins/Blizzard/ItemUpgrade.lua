local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ItemUpgradeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemUpgrade) then return end

	local ItemUpgradeFrame = _G.ItemUpgradeFrame
	S:HandlePortraitFrame(ItemUpgradeFrame)

	local UpgradeDropDown = ItemUpgradeFrame.ItemInfo.Dropdown
	S:HandleDropDownBox(UpgradeDropDown, 130)

	local UpgradeButton = ItemUpgradeFrame.UpgradeButton
	S:HandleButton(UpgradeButton, true)

	local ButtonFrame = ItemUpgradeFrame.UpgradeItemButton.ButtonFrame
	ButtonFrame:StripTextures()

	local CurrenciesBorder = ItemUpgradeFramePlayerCurrenciesBorder
	CurrenciesBorder:StripTextures()

	local BGTex = ItemUpgradeFrame.UpgradeCostFrame.BGTex
	BGTex:StripTextures()
end

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI')
