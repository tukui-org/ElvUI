local E, L, V, P, G, _ = unpack(select(2, ...)) --Import: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.stable ~= true then return end

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

S:RegisterSkin('ElvUI', LoadSkin)