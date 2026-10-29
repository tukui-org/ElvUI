local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local MAX_TEAM_BORDERS = MAX_TEAM_BORDERS

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'SkinArenaRegistrar', nil, nil, nil, nil, 'arenaRegistrar')

function S:SkinArenaRegistrar()
	local ArenaRegistrarFrame = _G.ArenaRegistrarFrame
	ArenaRegistrarFrame:CreateBackdrop('Transparent')
	ArenaRegistrarFrame.backdrop:Point('TOPLEFT', 14, -18)
	ArenaRegistrarFrame.backdrop:Point('BOTTOMRIGHT', -30, 67)

	ArenaRegistrarFrame:StripTextures(true)

	S:HandleButton(_G.ArenaRegistrarFrameGoodbyeButton)
	S:HandleCloseButton(_G.ArenaRegistrarFrameCloseButton)

	local arenaGreetingFrame = _G.ArenaRegistrarGreetingFrame
	arenaGreetingFrame:StripTextures()

	local greetingRegion1 = arenaGreetingFrame:GetRegions()
	greetingRegion1:SetTextColor(1, 0.80, 0.10)

	_G.RegistrationText:SetTextColor(1, 0.80, 0.10)

	for i = 1, MAX_TEAM_BORDERS do
		local button = _G['ArenaRegistrarButton'..i]

		S:HandleButtonHighlight(button)

		local text = button:GetFontString()
		text:SetTextColor(1, 1, 1)
	end

	_G.ArenaRegistrarPurchaseText:SetTextColor(1, 1, 1)

	S:HandleButton(_G.ArenaRegistrarFrameCancelButton)
	S:HandleButton(_G.ArenaRegistrarFramePurchaseButton)

	S:HandleEditBox(_G.ArenaRegistrarFrameEditBox)
	_G.ArenaRegistrarFrameEditBox:Height(18)

	local PVPBannerFrame = _G.PVPBannerFrame
	PVPBannerFrame:CreateBackdrop('Transparent')
	PVPBannerFrame.backdrop:Point('TOPLEFT', 10, -12)
	PVPBannerFrame.backdrop:Point('BOTTOMRIGHT', -33, 73)

	PVPBannerFrame:StripTextures()

	_G.PVPBannerFramePortrait:Kill()
	_G.PVPBannerFrameCustomizationFrame:StripTextures()

	for i = 1, 2 do
		_G['PVPBannerFrameCustomization'..i]:StripTextures()

		S:HandleNextPrevButton(_G['PVPBannerFrameCustomization'..i..'LeftButton'])
		S:HandleNextPrevButton(_G['PVPBannerFrameCustomization'..i..'RightButton'])
	end

	for i = 1, 3 do
		local pickerButton = _G['PVPColorPickerButton'..i]
		S:HandleButton(pickerButton)

		if i == 2 then
			pickerButton:Point('TOP', _G.PVPBannerFrameCustomization2, 'BOTTOM', 0, -33)
		elseif i == 3 then
			pickerButton:Point('TOP', _G.PVPBannerFrameCustomization2, 'BOTTOM', 0, -59)
		end
	end

	S:HandleButton(_G.PVPBannerFrameAcceptButton)
	S:HandleButton(_G.PVPBannerFrameCancelButton)
	S:HandleCloseButton(_G.PVPBannerFrameCloseButton)
end
