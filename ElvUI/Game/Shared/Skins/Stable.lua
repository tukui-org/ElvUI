local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local GetPetHappiness = GetPetHappiness
local UnitExists = UnitExists
local HasPetUI = HasPetUI

if E.Modern then
	S:AddCallbackForAddon('Blizzard_StableUI', nil, nil, nil, nil, nil, 'stable')
else
	S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'PetStableFrame', nil, nil, nil, nil, 'stable')
end

local function AbilitiesList_Layout(list)
	for frame in list.abilityPool:EnumerateActive() do
		if not frame.IsSkinned then
			frame.IsSkinned = true

			S:HandleIcon(frame.Icon)
		end
	end
end

local function SkinStableFrame()
	local stableFrame = _G.StableFrame
	S:HandlePortraitFrame(stableFrame)
	S:HandleButton(stableFrame.StableTogglePetButton)
	S:HandleButton(stableFrame.ReleasePetButton)

	stableFrame.MainHelpButton:Hide()

	local stabledList = stableFrame.StabledList
	S:HandleTrimScrollBar(stabledList.ScrollBar)

	stabledList:StripTextures()
	stabledList.ListName:FontTemplate(nil, 32)
	stabledList.ListCounter:StripTextures()
	stabledList.ListCounter:CreateBackdrop('Transparent')

	local filterBar = stabledList.FilterBar
	S:HandleEditBox(filterBar.SearchBox)
	S:HandleButton(filterBar.FilterDropdown)
	S:HandleCloseButton(filterBar.FilterDropdown.ResetButton)

	local modelScene = stableFrame.PetModelScene
	modelScene.PetModelSceneShadow:SetInside()
	modelScene.Inset.NineSlice:SetTemplate()
	modelScene.Inset.Bg:Hide()

	local modelPetInfo = modelScene.PetInfo
	S:HandleModelSceneControlButtons(modelScene.ControlFrame)
	S:HandleDropDownBox(modelPetInfo.Specialization)

	hooksecurefunc(modelScene.AbilitiesList, 'Layout', AbilitiesList_Layout)
	hooksecurefunc(modelPetInfo.Type, 'SetText', S.ReplaceIconString)
end

local function SkinForeverPetStableFrame()
	local stableFrame = _G.PetStableFrame
	S:HandlePortraitFrame(stableFrame)
	S:HandleButton(stableFrame.purchaseButton)

	for slot, texture in next, {
		[_G.PetStableCurrentPet] = 'PetStableCurrentPetIconTexture',
		[_G.PetStableStabledPet1] = 'PetStableStabledPet1IconTexture',
		[_G.PetStableStabledPet2] = 'PetStableStabledPet2IconTexture'
	} do
		S:HandleItemButton(slot, true)

		texture:SetDrawLayer('ARTWORK')
	end

	local modelScene = stableFrame.modelScene
	S:HandleModelSceneControlButtons(modelScene.ControlFrame)

	modelScene.PetModelSceneShadow:SetInside()
	modelScene.Inset.NineSlice:SetTemplate()
	modelScene.Inset.Bg:Hide()

	local diet = stableFrame.diet
	diet:CreateBackdrop()
	diet:Size(24)

	local expBar = stableFrame.expBar
	S:HandleStatusBar(expBar.StatusBar)
	expBar.overlay:StripTextures()

	local loyaltyLevel = stableFrame.loyaltyLevel
	loyaltyLevel:StripTextures()
	loyaltyLevel:CreateBackdrop()
	loyaltyLevel:Size(24)

	_G.PetStableMoneyFrame.Border:StripTextures()
end

local function PetButtons(btn, offset)
	local button = _G[btn]
	local icon = _G[btn..'IconTexture']
	button:StripTextures()

	local checked = button.Checked
	checked:SetColorTexture(unpack(E.media.rgbvaluecolor))
	checked:SetAllPoints(icon)
	checked:SetAlpha(0.3)

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

local function SkinMistsPetStableFrame()
	local stableFrame = _G.PetStableFrame
	S:HandlePortraitFrame(stableFrame)

	_G.PetStableLeftInset:Hide()
	_G.PetStableBottomInset:Hide()
	_G.PetStableFrameModelBg:Hide()
	_G.PetStableDietTexture:SetTexture(132165)
	_G.PetStableDietTexture:SetTexCoords()
	_G.PetStableFrameInset:SetTemplate('Transparent')

	S:HandleModelSceneControlButtons(_G.PetStableModelScene.ControlFrame)
	S:HandleButton(_G.PetStablePrevPageButton) -- Required to remove graphical glitch from Prev page button
	S:HandleButton(_G.PetStableNextPageButton) -- Required to remove graphical glitch from Next page button

	local selectedIcon = _G.PetStableSelectedPetIcon
	selectedIcon:SetTexCoords()

	local selectedBG = CreateFrame('Frame', nil, selectedIcon:GetParent())
	selectedBG:Point('TOPLEFT', selectedIcon, -E.Border, E.Border)
	selectedBG:Point('BOTTOMRIGHT', selectedIcon, E.Border, -E.Border)
	selectedBG:SetTemplate()

	selectedIcon:Size(37)
	selectedIcon:SetParent(selectedBG)

	for i = 1, _G.NUM_PET_ACTIVE_SLOTS do
		PetButtons('PetStableActivePet' .. i, E.Border)
	end

	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		PetButtons('PetStableStabledPet' .. i, E.Border)
	end
end

local function UpdatePetStable()
	local hasPetUI, isHunterPet = HasPetUI()
	if hasPetUI and not isHunterPet and UnitExists('pet') then return end

	local texture = _G.PetStablePetInfo:GetRegions()
	local happiness = GetPetHappiness()

	if happiness == 1 then
		texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
	elseif happiness == 2 then
		texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
	else
		texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
	end
end

local function SkinClassicPetStableFrame()
	local stableFrame = _G.PetStableFrame
	S:HandleFrame(stableFrame, true, nil, 10, -11, -32, 71)
	S:HandleButton(_G.PetStablePurchaseButton)

	local model = _G.PetStableModel
	local rotationLeft = _G.PetStableModelRotateLeftButton
	rotationLeft:ClearAllPoints()
	rotationLeft:Point('TOPLEFT', model)
	S:HandleRotateButton(rotationLeft)

	local rotationRight = _G.PetStableModelRotateRightButton
	rotationRight:ClearAllPoints()
	rotationRight:Point('LEFT', rotationLeft, 'RIGHT', 1, 0)
	S:HandleRotateButton(rotationRight)

	local petInfo = _G.PetStablePetInfo
	petInfo:ClearAllPoints()
	petInfo:Point('TOPLEFT', rotationLeft, 'BOTTOM', 1, -2)
	petInfo:OffsetFrameLevel(2, model)
	petInfo:CreateBackdrop()
	petInfo:Size(24)

	S:HandleItemButton(_G.PetStableCurrentPet, true)
	_G.PetStableCurrentPetIconTexture:SetDrawLayer('ARTWORK')

	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G['PetStableStabledPet'..i], true)
		_G['PetStableStabledPet'..i..'IconTexture']:SetDrawLayer('ARTWORK')
	end

	UpdatePetStable()

	hooksecurefunc('PetStable_Update', UpdatePetStable)
end

function S:Blizzard_StableUI()
	if E.Forever then -- Forever loads its own PetStableFrame instead of StableFrame
		SkinForeverPetStableFrame()
	else
		SkinStableFrame()
	end
end

function S:PetStableFrame()
	if E.Mists then
		SkinMistsPetStableFrame()
	else
		SkinClassicPetStableFrame()
	end
end
