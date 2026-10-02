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
			S:HandleIcon(frame.Icon)
			frame.IsSkinned = true
		end
	end
end

local function SkinStableFrame()
	local StableFrame = _G.StableFrame
	S:HandlePortraitFrame(StableFrame)
	StableFrame.MainHelpButton:Hide()
	S:HandleButton(StableFrame.StableTogglePetButton)
	S:HandleButton(StableFrame.ReleasePetButton)

	local StabledPetList = StableFrame.StabledPetList
	StabledPetList:StripTextures()
	StabledPetList.ListName:FontTemplate(nil, 32)
	StabledPetList.ListCounter:StripTextures()
	StabledPetList.ListCounter:CreateBackdrop('Transparent')

	S:HandleEditBox(StabledPetList.FilterBar.SearchBox)
	S:HandleButton(StableFrame.StabledPetList.FilterBar.FilterDropdown)
	S:HandleCloseButton(StableFrame.StabledPetList.FilterBar.FilterDropdown.ResetButton)

	S:HandleTrimScrollBar(StabledPetList.ScrollBar)

	local modelScene = StableFrame.PetModelScene
	modelScene.PetModelSceneShadow:SetInside()
	modelScene.Inset.NineSlice:SetTemplate()
	modelScene.Inset.Bg:Hide()
	S:HandleModelSceneControlButtons(modelScene.ControlFrame)

	hooksecurefunc(modelScene.AbilitiesList, 'Layout', AbilitiesList_Layout)
	hooksecurefunc(modelScene.PetInfo.Type, 'SetText', S.ReplaceIconString)
	S:HandleDropDownBox(modelScene.PetInfo.Specialization)
end

local function SkinForeverPetStableFrame()
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

	local diet = PetStableFrame.diet
	diet:CreateBackdrop()
	diet:Size(24)

	local expBar = PetStableFrame.expBar
	S:HandleStatusBar(expBar.StatusBar)
	expBar.overlay:StripTextures()

	local loyaltyLevel = PetStableFrame.loyaltyLevel
	loyaltyLevel:StripTextures()
	loyaltyLevel:CreateBackdrop()
	loyaltyLevel:Size(24)

	_G.PetStableMoneyFrame.Border:StripTextures()
end

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

local function SkinMistsPetStableFrame()
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
	local PetStableFrame = _G.PetStableFrame
	S:HandleFrame(PetStableFrame, true, nil, 10, -11, -32, 71)

	S:HandleButton(_G.PetStablePurchaseButton)
	S:HandleRotateButton(_G.PetStableModelRotateRightButton)
	S:HandleRotateButton(_G.PetStableModelRotateLeftButton)

	S:HandleItemButton(_G.PetStableCurrentPet, true)
	_G.PetStableCurrentPetIconTexture:SetDrawLayer('ARTWORK')

	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G['PetStableStabledPet'..i], true)
		_G['PetStableStabledPet'..i..'IconTexture']:SetDrawLayer('ARTWORK')
	end

	local PetStablePetInfo = _G.PetStablePetInfo
	PetStablePetInfo:OffsetFrameLevel(2, _G.PetStableModel)
	PetStablePetInfo:CreateBackdrop()
	PetStablePetInfo:Size(24)

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
