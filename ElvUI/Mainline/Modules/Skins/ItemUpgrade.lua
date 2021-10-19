local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function Update(frame)
	if frame.upgradeInfo then
		frame.UpgradeItemButton:GetPushedTexture():SetColorTexture(0.9, 0.8, 0.1, 0.3)
	else
		frame.UpgradeItemButton:GetNormalTexture():SetInside()
	end
end

function S:Blizzard_ItemUpgradeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.itemUpgrade) then return end

	local frame = _G.ItemUpgradeFrame
	_G.ItemUpgradeFrameBg:Hide()
	_G.ItemUpgradeFramePortrait:Hide()
	_G.ItemUpgradeFramePlayerCurrenciesBorder:StripTextures()

	frame:CreateBackdrop('Transparent')
	frame.backdrop.Center:SetDrawLayer('BACKGROUND', -2)
	frame.UpgradeCostFrame.BGTex:StripTextures()

	frame.NineSlice:Hide()
	frame.TitleBg:Hide()
	frame.TopTileStreaks:Hide()
	frame.BottomBG:CreateBackdrop('Transparent')
	frame.ItemInfo.UpgradeTo:SetFontObject('GameFontHighlightMedium')

	local button = frame.UpgradeItemButton
	button:StripTextures()
	button:SetTemplate()
	button:StyleButton(nil, true)
	button:GetNormalTexture():SetInside()

	button.icon:SetInside(button)
	S:HandleIcon(button.icon)

	if E.private.skins.parchmentRemoverEnable then
		frame.BottomBGShadow:Hide()
		frame.BottomBG:Hide()
		frame.TopBG:Hide()

		local holder = button.ButtonFrame
		holder:StripTextures()
		holder:CreateBackdrop('Transparent')
		holder.backdrop.Center:SetDrawLayer('BACKGROUND', -1)
	else
		frame.TopBG:CreateBackdrop('Transparent')
	end

	hooksecurefunc(frame, 'Update', Update)

	S:HandleIconBorder(button.IconBorder)
	S:HandleButton(frame.UpgradeButton, true)
	S:HandleDropDownBox(frame.ItemInfo.Dropdown, 130)
	S:HandleCloseButton(_G.ItemUpgradeFrameCloseButton)
end

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI')
