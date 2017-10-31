local E, L, V, P, G, _ = unpack(select(2, ...)) --Import: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

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
	S:HandleNextPrevButton(PetStablePrevPageButton)
	S:HandleNextPrevButton(PetStableNextPageButton)
	S:HandleRotateButton(PetStableModelRotateRightButton)
	S:HandleRotateButton(PetStableModelRotateLeftButton)

	for i = 1, NUM_PET_ACTIVE_SLOTS do
		S:HandleItemButton(_G['PetStableActivePet' .. i], true)
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G['PetStableStabledPet' .. i], true)
	end

	PetStableSelectedPetIcon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallback("Stable", LoadSkin)