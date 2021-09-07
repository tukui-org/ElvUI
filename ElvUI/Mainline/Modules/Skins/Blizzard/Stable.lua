local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame

local function PetButtons(btn, p)
	local button = _G[btn]
	local icon = _G[btn..'IconTexture']
	local highlight = button:GetHighlightTexture()
	button:StripTextures()

	if button.Checked then
		button.Checked:SetColorTexture(unpack(E.media.rgbvaluecolor))
		button.Checked:SetAllPoints(icon)
		button.Checked:SetAlpha(0.3)
	end

	if highlight then
		highlight:SetColorTexture(1, 1, 1, 0.3)
		highlight:SetAllPoints(icon)
	end

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:ClearAllPoints()
		icon:Point('TOPLEFT', p, -p)
		icon:Point('BOTTOMRIGHT', -p, p)

		button:SetFrameLevel(button:GetFrameLevel() + 2)
		button:SetTemplate(nil, true)
	end
end

function S:PetStableFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

	local PetStableFrame = _G.PetStableFrame
	S:HandlePortraitFrame(PetStableFrame)

	_G.PetStableLeftInset:StripTextures()
	_G.PetStableBottomInset:StripTextures()
	_G.PetStableFrameInset:SetTemplate('Transparent')

	S:HandleButton(_G.PetStablePrevPageButton) -- Required to remove graphical glitch from Prev page button
	S:HandleButton(_G.PetStableNextPageButton) -- Required to remove graphical glitch from Next page button
	S:HandleRotateButton(_G.PetStableModelRotateRightButton)
	S:HandleRotateButton(_G.PetStableModelRotateLeftButton)

	local p = E.PixelMode and 1 or 2
	local PetStableSelectedPetIcon = _G.PetStableSelectedPetIcon
	if PetStableSelectedPetIcon then
		PetStableSelectedPetIcon:SetTexCoord(unpack(E.TexCoords))
		local b = CreateFrame('Frame', nil, PetStableSelectedPetIcon:GetParent())
		b:Point('TOPLEFT', PetStableSelectedPetIcon, -p, p)
		b:Point('BOTTOMRIGHT', PetStableSelectedPetIcon, p, -p)
		PetStableSelectedPetIcon:Size(37,37)
		PetStableSelectedPetIcon:SetParent(b)
		b:SetTemplate()
	end

	for i = 1, _G.NUM_PET_ACTIVE_SLOTS do
		PetButtons('PetStableActivePet' .. i, p)
	end
	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		PetButtons('PetStableStabledPet' .. i, p)
	end
end

S:AddCallback('PetStableFrame')
