local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame

local function PetButtons(btn, offset)
	local button = _G[btn]
	local icon = _G[btn..'IconTexture']
	button:StripTextures()

	button.Checked:SetColorTexture(unpack(E.media.rgbvaluecolor))
	button.Checked:SetAllPoints(icon)
	button.Checked:SetAlpha(0.3)

	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, 0.3)
	highlight:SetAllPoints(icon)

	icon:SetTexCoords()
	icon:ClearAllPoints()
	icon:Point('TOPLEFT', offset, -offset)
	icon:Point('BOTTOMRIGHT', -offset, offset)

	button:OffsetFrameLevel(2)
	button:SetTemplate(nil, true)
end

function S:PetStableFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

	local PetStableFrame = _G.PetStableFrame
	S:HandlePortraitFrame(PetStableFrame)

	_G.PetStableLeftInset:Hide()
	_G.PetStableBottomInset:Hide()
	_G.PetStableFrameModelBg:Hide()
	_G.PetStableDietTexture:SetTexture(132165)
	_G.PetStableDietTexture:SetTexCoords()
	_G.PetStableFrameInset:SetTemplate('Transparent')

	S:HandleModelSceneControlButtons(_G.PetStableModelScene.ControlFrame)
	S:HandleButton(_G.PetStablePrevPageButton) -- Required to remove graphical glitch from Prev page button
	S:HandleButton(_G.PetStableNextPageButton) -- Required to remove graphical glitch from Next page button

	local offset = E.PixelMode and 1 or 2
	local SelectedIcon = _G.PetStableSelectedPetIcon
	SelectedIcon:SetTexCoords()

	local SelectedBackground = CreateFrame('Frame', nil, SelectedIcon:GetParent())
	SelectedBackground:Point('TOPLEFT', SelectedIcon, -offset, offset)
	SelectedBackground:Point('BOTTOMRIGHT', SelectedIcon, offset, -offset)
	SelectedBackground:SetTemplate()
	SelectedIcon:Size(37)
	SelectedIcon:SetParent(SelectedBackground)

	for i = 1, _G.NUM_PET_ACTIVE_SLOTS do
		PetButtons('PetStableActivePet' .. i, offset)
	end

	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		PetButtons('PetStableStabledPet' .. i, offset)
	end
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'PetStableFrame')
