local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local HasPetUI = HasPetUI
local UnitExists = UnitExists
local GetPetHappiness = GetPetHappiness
local hooksecurefunc = hooksecurefunc

function S:PetStableFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

	local PetStableFrame = _G.PetStableFrame
	S:HandleFrame(PetStableFrame, true, nil, 10, -11, -32, 71)

	S:HandleButton(_G.PetStablePurchaseButton)
	S:HandleCloseButton(_G.PetStableFrameCloseButton)
	S:HandleRotateButton(_G.PetStableModelRotateRightButton)
	S:HandleRotateButton(_G.PetStableModelRotateLeftButton)

	S:HandleItemButton(_G.PetStableCurrentPet, true)
	_G.PetStableCurrentPetIconTexture:SetDrawLayer('ARTWORK')

	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G['PetStableStabledPet'..i], true)
		_G['PetStableStabledPet'..i..'IconTexture']:SetDrawLayer('ARTWORK')
	end

	local PetStablePetInfo = _G.PetStablePetInfo
	PetStablePetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetStablePetInfo:SetFrameLevel(_G.PetModelFrame:GetFrameLevel() + 2)
	PetStablePetInfo:CreateBackdrop('Default')
	PetStablePetInfo:Size(22)

	hooksecurefunc('PetStable_Update', function()
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and not isHunterPet and UnitExists('pet') then return end

		local happiness = GetPetHappiness()
		local texture = PetStablePetInfo:GetRegions()

		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end)
end

S:AddCallback('PetStableFrame')
