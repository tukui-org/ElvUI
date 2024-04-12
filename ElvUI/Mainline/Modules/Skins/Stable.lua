local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_StableUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

	local StableFrame = _G.StableFrame
	S:HandlePortraitFrame(StableFrame)
	StableFrame.MainHelpButton:Hide()
	S:HandleButton(StableFrame.StableTogglePetButton)
	S:HandleButton(StableFrame.ReleasePetButton)

	local StabledPetList = StableFrame.StabledPetList
	StabledPetList:StripTextures()
	StabledPetList.ListCounter:StripTextures()
	StabledPetList.ListCounter:CreateBackdrop('Transparent')
	S:HandleEditBox(StabledPetList.FilterBar.SearchBox)
	S:HandleButton(StabledPetList.FilterBar.FilterButton)
	S:HandleTrimScrollBar(StabledPetList.ScrollBar)

	local StableModelScene = StableFrame.PetModelScene
	--S:HandleButton(StableModelScene.PetInfo.NameBox.EditButton) -- ToDo: 10.2.7: Halp, Fix me
	S:HandleModelSceneControlButtons(StableModelScene.ControlFrame)
end

S:AddCallbackForAddon('Blizzard_StableUI')
