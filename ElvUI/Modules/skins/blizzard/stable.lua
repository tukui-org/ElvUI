local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: NUM_PET_ACTIVE_SLOTS, NUM_PET_STABLE_SLOTS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.stable ~= true then return end

	local PetStableFrame = _G["PetStableFrame"]
	PetStableFrame:StripTextures()
	PetStableFrameInset:StripTextures()
	PetStableLeftInset:StripTextures()
	PetStableBottomInset:StripTextures()

	PetStableFrame:SetTemplate('Transparent')
	PetStableFrameInset:SetTemplate('Transparent')

	S:HandleCloseButton(PetStableFrameCloseButton)
	S:HandleButton(PetStablePrevPageButton) -- Required to remove graphical glitch from Prev page button
	S:HandleButton(PetStableNextPageButton) -- Required to remove graphical glitch from Next page button
	S:HandleRotateButton(PetStableModelRotateRightButton)
	S:HandleRotateButton(PetStableModelRotateLeftButton)

	local p = E.PixelMode and 1 or 2
	if PetStableSelectedPetIcon then
		PetStableSelectedPetIcon:SetTexCoord(unpack(E.TexCoords))
		local b = CreateFrame("Frame", nil, PetStableSelectedPetIcon:GetParent())
		b:Point("TOPLEFT", PetStableSelectedPetIcon, -p, p)
		b:Point("BOTTOMRIGHT", PetStableSelectedPetIcon, p, -p)
		PetStableSelectedPetIcon:SetSize(37,37)
		PetStableSelectedPetIcon:SetParent(b)
		b:SetTemplate("Default")
	end

	local function PetButtons(btn)
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
			icon:Point("TOPLEFT", p, -p)
			icon:Point("BOTTOMRIGHT", -p, p)

			button:SetFrameLevel(button:GetFrameLevel() + 2)
			if not button.backdrop then
				button:CreateBackdrop("Default", true)
				button.backdrop:SetAllPoints()
			end
		end
	end

	for i = 1, NUM_PET_ACTIVE_SLOTS do
		PetButtons('PetStableActivePet' .. i)
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		PetButtons('PetStableStabledPet' .. i)
	end
end

S:AddCallback("Stable", LoadSkin)
