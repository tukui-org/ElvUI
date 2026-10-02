local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_ItemUpgradeUI', nil, nil, nil, nil, nil, 'itemUpgrade')

local function Update(frame)
	if frame.upgradeInfo then
		frame.UpgradeItemButton:GetPushedTexture():SetColorTexture(0.9, 0.8, 0.1, 0.3)
	else
		frame.UpgradeItemButton:GetNormalTexture():SetInside()
	end
end

local function SkinMainline(frame)
	_G.ItemUpgradeFrameBg:Hide()
	_G.ItemUpgradeFramePortrait:Hide()
	_G.ItemUpgradeFramePlayerCurrenciesBorder:StripTextures()

	frame:CreateBackdrop('Transparent')
	frame.backdrop.Center:SetDrawLayer('BACKGROUND', -2)
	frame.UpgradeCostFrame.BGTex:StripTextures()

	frame.NineSlice:Hide()
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

	--hooksecurefunc(frame, 'Update', Update) -- FIX ME 11.0

	S:HandleIconBorder(button.IconBorder)
	S:HandleButton(frame.UpgradeButton, true)
	S:HandleDropDownBox(frame.ItemInfo.Dropdown, 130)
end

local function SkinMists(frame)
	-- Main Frame
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	local ItemButton = frame.ItemButton
	ItemButton:StripTextures()
	ItemButton:SetTemplate(nil, true)
	ItemButton:StyleButton()

	frame.ButtonFrame:StripTextures()

	-- Upgrade Button
	S:HandleButton(_G.ItemUpgradeFrameUpgradeButton)

	-- Remaining Artwork
	local MoneyFrame = _G.ItemUpgradeFrameMoneyFrame
	MoneyFrame:StripTextures()
	MoneyFrame:SetTemplate('Default')
end

function S:Blizzard_ItemUpgradeUI()
	local frame = _G.ItemUpgradeFrame
	if E.Modern then
		SkinMainline(frame)
	else
		SkinMists(frame)
	end

	S:HandleCloseButton(_G.ItemUpgradeFrameCloseButton)
end
