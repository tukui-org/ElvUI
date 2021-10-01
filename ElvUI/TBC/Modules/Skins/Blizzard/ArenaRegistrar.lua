local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select

local MAX_TEAM_BORDERS = MAX_TEAM_BORDERS

function S:SkinArenaRegistrar()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.arenaRegistrar) then return end

	local ArenaRegistrarFrame = _G.ArenaRegistrarFrame
	ArenaRegistrarFrame:CreateBackdrop('Transparent')
	ArenaRegistrarFrame.backdrop:Point('TOPLEFT', 14, -18)
	ArenaRegistrarFrame.backdrop:Point('BOTTOMRIGHT', -30, 67)

	ArenaRegistrarFrame:StripTextures(true)

	local ArenaRegistrarFrameCloseButton = _G.ArenaRegistrarFrameCloseButton
	S:HandleCloseButton(ArenaRegistrarFrameCloseButton)

	local ArenaRegistrarGreetingFrame = _G.ArenaRegistrarGreetingFrame
	ArenaRegistrarGreetingFrame:StripTextures()

	select(1, ArenaRegistrarGreetingFrame:GetRegions()):SetTextColor(1, 0.80, 0.10)
	_G.RegistrationText:SetTextColor(1, 0.80, 0.10)

	local ArenaRegistrarFrameGoodbyeButton = _G.ArenaRegistrarFrameGoodbyeButton
	S:HandleButton(ArenaRegistrarFrameGoodbyeButton)

	for i = 1, MAX_TEAM_BORDERS do
		local button = _G['ArenaRegistrarButton'..i]
		local obj = select(3, button:GetRegions())

		S:HandleButtonHighlight(button)

		obj:SetTextColor(1, 1, 1)
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

	local customization, customizationLeft, customizationRight
	for i = 1, 2 do
		customization = _G['PVPBannerFrameCustomization'..i]
		customizationLeft = _G['PVPBannerFrameCustomization'..i..'LeftButton']
		customizationRight = _G['PVPBannerFrameCustomization'..i..'RightButton']

		customization:StripTextures()
		S:HandleNextPrevButton(customizationLeft)
		S:HandleNextPrevButton(customizationRight)
	end

	local pickerButton
	for i = 1, 3 do
		pickerButton = _G['PVPColorPickerButton'..i]
		S:HandleButton(pickerButton)
		if i == 2 then
			pickerButton:Point('TOP', _G.PVPBannerFrameCustomization2, 'BOTTOM', 0, -33)
		elseif i == 3 then
			pickerButton:Point('TOP', _G.PVPBannerFrameCustomization2, 'BOTTOM', 0, -59)
		end
	end

	S:HandleButton(_G.PVPBannerFrameAcceptButton)
	S:HandleButton(_G.PVPBannerFrameCancelButton)
	S:HandleButton(select(4, PVPBannerFrame:GetChildren()))
	S:HandleCloseButton(_G.PVPBannerFrameCloseButton)
end

S:AddCallback('SkinArenaRegistrar')
