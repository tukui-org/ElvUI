local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function AbilitiesList_Layout(list)
	for frame in list.abilityPool:EnumerateActive() do
		if not frame.IsSkinned then
			S:HandleIcon(frame.Icon)
			frame.IsSkinned = true
		end
	end
end

function S:Blizzard_StableUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

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

S:AddCallbackForAddon('Blizzard_StableUI')
