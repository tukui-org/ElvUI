local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local pvpRewards = { 'PVPHonorFrameInfoScrollFrameChildFrameRewardsInfoWinReward', 'PVPHonorFrameInfoScrollFrameChildFrameRewardsInfoLossReward', 'PVPConquestFrameWinReward' }

local honorTexture = [[Interface\Icons\PVPCurrency-Honor-]]..E.myfaction
local conquestTexture = [[Interface\Icons\PVPCurrency-Conquest-]]..E.myfaction
local function PVPFrameTabClicked()
	_G.PVPFrameCurrencyIcon:SetTexture(honorTexture)

	for _, name in next, pvpRewards do
		local honor = (_G[name] ~= _G.PVPConquestFrameWinReward) and _G[name..'HonorSymbol']
		if honor then
			honor:SetTexture(honorTexture)
		end

		local conquest = _G[name..'ArenaSymbol']
		if conquest then
			conquest:SetTexture(conquestTexture)
		end
	end
end

function S:SkinPVPFrame()
	-- Honor, Conquest, War Games Frame
	local PVPFrame = _G.PVPFrame
	S:HandleFrame(PVPFrame)
	PVPFrame:StripTextures()
	PVPFrame:SetTemplate('Transparent')

	local buttons = {
		'PVPFrameLeftButton',
		'PVPFrameRightButton',
		'PVPColorPickerButton1',
		'PVPColorPickerButton2',
		'PVPColorPickerButton3',
		'PVPBannerFrameAcceptButton'
	}

	for _, name in next, buttons do
		local button = _G[name]
		if button then
			button:StripTextures()
			S:HandleButton(button)
		end
	end

	local stripTextures = {
		'PVPFrameInset',
		'PVPHonorFrame',
		'PVPFrameTopInset',
		'PVPConquestFrame'
	}

	for _, name in next, stripTextures do
		local button = _G[name]
		if button then
			button:StripTextures()
		end
	end

	-- Tons of leftover texture crap
	local killTextures = {
		'PVPBannerFramePortrait',
		'PVPConquestFrameInfoButtonInfoBG',
		'PVPConquestFrameInfoButtonInfoBGOff',
		'PVPFrameConquestBarBG',
		'PVPFrameConquestBarLeft',
		'PVPFrameConquestBarMiddle',
		'PVPFrameConquestBarRight',
		'PVPFrameConquestBarShadow',
		'PVPFrameRightButton_LeftSeparator',
		'PVPHonorFrameBGTex',
		'PVPHonorFrameInfoScrollFrameScrollBar',
		'PVPTeamManagementFrameBackground',
		'WarGamesFrameInfoScrollFrameScrollBar',
		'WarGameStartButton_RightSeparator'
	}

	for _, name in next, killTextures do
		local button = _G[name]
		if button then
			button:Kill()
		end
	end

	S:HandleTrimScrollBar(_G.PVPHonorFrame.bgTypeScrollBar)
	S:HandleTrimScrollBar(_G.WarGamesFrame.scrollBar)
	S:HandleScrollBar(_G.PVPHonorFrameInfoScrollFrame.ScrollBar)
	S:HandleScrollBar(_G.WarGamesFrameInfoScrollFrame.ScrollBar)

	local checkButtons = {
		_G.PVPFrame.TankIcon.checkButton,
		_G.PVPFrame.HealerIcon.checkButton,
		_G.PVPFrame.DPSIcon.checkButton
	}

	for _, checkButton in next, checkButtons do
		S:HandleCheckBox(checkButton)
		checkButton:Size(22)
		checkButton:SetFrameLevel(checkButton:GetFrameLevel() + 2)
	end

	_G.PVPHonorFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
	_G.PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1)

	S:HandleButtonHighlight(_G.PVPConquestFrameConquestButtonArena)
	S:HandleButtonHighlight(_G.PVPConquestFrameConquestButtonRated)

	local PVPConquestFrameNoWeekly = _G.PVPConquestFrameNoWeekly
	PVPConquestFrameNoWeekly:StripTextures()
	PVPConquestFrameNoWeekly:CreateBackdrop()
	PVPConquestFrameNoWeekly.backdrop:Point('TOPLEFT', -5, 5)
	PVPConquestFrameNoWeekly.backdrop:Point('BOTTOMRIGHT', 8, -5)
	PVPConquestFrameNoWeekly.backdrop:SetFrameLevel(PVPConquestFrameNoWeekly:GetFrameLevel())

	-- Conquest Bar
	local PVPFrameConquestBar = _G.PVPFrameConquestBar
	PVPFrameConquestBar:StripTextures()
	PVPFrameConquestBar:CreateBackdrop()
	PVPFrameConquestBar.backdrop:Point('TOPLEFT', PVPFrameConquestBar.progress, -1, 1)
	PVPFrameConquestBar.backdrop:Point('BOTTOMRIGHT', PVPFrameConquestBar, 3, 2)
	PVPFrameConquestBar:Point('LEFT', 40, 0)

	PVPFrameConquestBar.progress:SetTexture(E.media.normTex)
	PVPFrameConquestBar.progress:Point('LEFT')

	for i = 1, 2 do
		_G['PVPFrameConquestBarCap'..i]:SetTexture(E.media.normTex)
		_G['PVPFrameConquestBarCap'..i..'Marker']:Size(4, E.PixelMode and 14 or 12)
		_G['PVPFrameConquestBarCap'..i..'MarkerTexture']:SetTexture(1, 1, 1, 0.40)
	end

	PVPFrame:StripTextures()
	PVPFrame:SetTemplate('Transparent')

	local PVPFrameLowLevelFrame = _G.PVPFrameLowLevelFrame
	PVPFrameLowLevelFrame:StripTextures()
	PVPFrameLowLevelFrame:CreateBackdrop()
	PVPFrameLowLevelFrame.backdrop:Point('TOPLEFT', -2, -40)
	PVPFrameLowLevelFrame.backdrop:Point('BOTTOMRIGHT', 5, 80)

	-- PvP Icon
	if _G.PVPFrameCurrency then
		local PVPFrameCurrency = _G.PVPFrameCurrency
		PVPFrameCurrency:CreateBackdrop()
		PVPFrameCurrency:Size(32)
		PVPFrameCurrency:Point('TOP', 0, -26)

		local PVPFrameCurrencyIcon = _G.PVPFrameCurrencyIcon
		PVPFrameCurrencyIcon:SetTexture(honorTexture)
		PVPFrameCurrencyIcon:SetTexCoord(unpack(E.TexCoords))
		PVPFrameCurrencyIcon:SetInside(PVPFrameCurrency.backdrop)

		_G.PVPFrameCurrencyLabel:Hide()
		_G.PVPFrameCurrencyValue:Point('LEFT', PVPFrameCurrencyIcon, 'RIGHT', 6, 0)
	end

	-- Rewards
	for _, name in next, pvpRewards do
		local frame = _G[name]

		local background = frame:GetRegions()
		background:SetTexture(E.Media.Textures.Highlight)

		if (frame == _G.PVPHonorFrameInfoScrollFrameChildFrameRewardsInfoWinReward) or (frame == _G.PVPConquestFrameWinReward) then
			background:SetVertexColor(0, 0.439, 0, 0.5)
		else
			background:SetVertexColor(0.5608, 0, 0, 0.5)
		end

		local honor = (frame ~= _G.PVPConquestFrameWinReward) and _G[name..'HonorSymbol']
		if honor then
			honor:SetTexture(honorTexture)
			honor:SetTexCoord(unpack(E.TexCoords))
			honor:Size(30)
		end

		local conquest = _G[name..'ArenaSymbol']
		if conquest then
			conquest:SetTexture(conquestTexture)
			conquest:SetTexCoord(unpack(E.TexCoords))
			conquest:Size(30)
		end
	end

	hooksecurefunc('PVPFrame_TabClicked', PVPFrameTabClicked)

	-- Team Management
	for i = 1, 3 do
		local top = _G['PVPTeam'..i..'Top']
		local bottom = _G['PVPTeam'..i..'Bottom']
		local left = _G['PVPTeam'..i..'Left']
		local right = _G['PVPTeam'..i..'Right']

		top:StripTextures()
		bottom:StripTextures()
		left:StripTextures()
		right:StripTextures()
	end

	_G.PVPTeamManagementFrameWeeklyDisplay:StripTextures()
	_G.PVPTeamManagementFrameWeeklyDisplay:SetTemplate('Transparent')

	-- War Games
	_G.WarGamesFrame:StripTextures()
	_G.WarGamesFrameDescription:SetTextColor(1, 1, 1)

	-- Create Arena Team
	local PVPBannerFrame = _G.PVPBannerFrame
	PVPBannerFrame:StripTextures()
	PVPBannerFrame:SetTemplate('Transparent')

	_G.PVPBannerFrameCustomizationFrame:StripTextures()

	local PVPBannerFrameCustomization1 = _G.PVPBannerFrameCustomization1
	PVPBannerFrameCustomization1:StripTextures()
	PVPBannerFrameCustomization1:CreateBackdrop()
	PVPBannerFrameCustomization1.backdrop:Point('TOPLEFT', _G.PVPBannerFrameCustomization1LeftButton, 'TOPRIGHT', 2, 0)
	PVPBannerFrameCustomization1.backdrop:Point('BOTTOMRIGHT', _G.PVPBannerFrameCustomization1RightButton, 'BOTTOMLEFT', -2, 0)

	local PVPBannerFrameCustomization2 = _G.PVPBannerFrameCustomization2
	PVPBannerFrameCustomization2:StripTextures()
	PVPBannerFrameCustomization2:CreateBackdrop()
	PVPBannerFrameCustomization2.backdrop:Point('TOPLEFT', _G.PVPBannerFrameCustomization2LeftButton, 'TOPRIGHT', 2, 0)
	PVPBannerFrameCustomization2.backdrop:Point('BOTTOMRIGHT', _G.PVPBannerFrameCustomization2RightButton, 'BOTTOMLEFT', -2, 0)

	S:HandleCloseButton(_G.PVPBannerFrameCloseButton, PVPBannerFrame)
	S:HandleCloseButton(_G.PVPFrameCloseButton, PVPFrame)

	S:HandleNextPrevButton(_G.PVPBannerFrameCustomization1LeftButton)
	_G.PVPBannerFrameCustomization1LeftButton:Height(20)

	S:HandleNextPrevButton(_G.PVPBannerFrameCustomization1RightButton)
	_G.PVPBannerFrameCustomization1RightButton:Height(20)

	S:HandleNextPrevButton(_G.PVPBannerFrameCustomization2LeftButton)
	_G.PVPBannerFrameCustomization2LeftButton:Height(20)

	S:HandleNextPrevButton(_G.PVPBannerFrameCustomization2RightButton)
	_G.PVPBannerFrameCustomization2RightButton:Height(20)

	_G.PVPColorPickerButton1:Height(20)
	_G.PVPColorPickerButton2:Height(20)
	_G.PVPColorPickerButton3:Height(20)

	local PVPBannerFrameCancelButton = _G.PVPBannerFrameCancelButton
	S:HandleButton(PVPBannerFrameCancelButton)
	PVPBannerFrameCancelButton.backdrop = CreateFrame('Frame', nil, PVPBannerFrameCancelButton)
	PVPBannerFrameCancelButton.backdrop:SetTemplate(nil, true)
	PVPBannerFrameCancelButton.backdrop:SetFrameLevel(PVPBannerFrameCancelButton:GetFrameLevel() - 2)
	PVPBannerFrameCancelButton.backdrop:Point('TOPLEFT', _G.PVPBannerFrameAcceptButton, 248, 0)
	PVPBannerFrameCancelButton.backdrop:Point('BOTTOMRIGHT', _G.PVPBannerFrameAcceptButton, 248, 0)

	-- Skin Tabs
	S:HandleTab(_G.PVPFrameTab1)
	S:HandleTab(_G.PVPFrameTab2)
	S:HandleTab(_G.PVPFrameTab3)
	S:HandleTab(_G.PVPFrameTab4)

	-- Reposition Tabs
	_G.PVPFrameTab1:ClearAllPoints()
	_G.PVPFrameTab1:Point('TOPLEFT', PVPFrame, 'BOTTOMLEFT', -10, 0)
	_G.PVPFrameTab2:Point('TOPLEFT', _G.PVPFrameTab1, 'TOPRIGHT', -19, 0)
	_G.PVPFrameTab3:Point('TOPLEFT', _G.PVPFrameTab2, 'TOPRIGHT', -19, 0)
	_G.PVPFrameTab4:Point('TOPLEFT', _G.PVPFrameTab3, 'TOPRIGHT', -19, 0)
end

function S:SkinPVPReadyDialog()
	-- PvP Queue Popup
	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate('Transparent')
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogHideButton)
end

function S:SkinPVP()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	S:SkinPVPFrame()
	S:SkinPVPReadyDialog()
end

S:AddCallback('SkinPVP')
