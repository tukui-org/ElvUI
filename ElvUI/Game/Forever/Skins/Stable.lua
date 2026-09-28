local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function UpdateHappiness(diet)
	local texture = diet.texture
	if not texture then return end

	local left = texture:GetTexCoord()

	if left == 0.375 then
		texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
	elseif left == 0.1875 then
		texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
	elseif left == 0 then
		texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
	end
end

function S:Blizzard_StableUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

	local PetStableFrame = _G.PetStableFrame
	S:HandlePortraitFrame(PetStableFrame)
	S:HandleButton(PetStableFrame.purchaseButton)

	for _, slot in next, { _G.PetStableCurrentPet, _G.PetStableStabledPet1, _G.PetStableStabledPet2 } do
		S:HandleItemButton(slot, true)
		_G[slot:GetName()..'IconTexture']:SetDrawLayer('ARTWORK')
	end

	local modelScene = PetStableFrame.modelScene
	modelScene.PetModelSceneShadow:SetInside()
	modelScene.Inset.NineSlice:SetTemplate()
	modelScene.Inset.Bg:Hide()
	S:HandleModelSceneControlButtons(modelScene.ControlFrame)

	local diet = modelScene.diet
	diet:CreateBackdrop()
	diet:Size(24)
	hooksecurefunc(diet, 'UpdateHappiness', UpdateHappiness)

	local expBar = PetStableFrame.expBar
	S:HandleStatusBar(expBar.StatusBar)
	expBar.overlay:StripTextures()

	local loyaltyLevel = PetStableFrame.loyaltyLevel
	loyaltyLevel:StripTextures()
	loyaltyLevel:CreateBackdrop()
	loyaltyLevel:Size(24)

	_G.PetStableMoneyFrame.Border:StripTextures()
end

S:AddCallbackForAddon('Blizzard_StableUI')
