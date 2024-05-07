local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function AbilitiesList_Layout(list)
	if not list.abilityPool then return end

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
	StabledPetList.ListCounter:StripTextures()
	StabledPetList.ListCounter:CreateBackdrop('Transparent')
	S:HandleEditBox(StabledPetList.FilterBar.SearchBox)
	S:HandleButton(StabledPetList.FilterBar.FilterButton)
	S:HandleTrimScrollBar(StabledPetList.ScrollBar)

	local StableModelScene = StableFrame.PetModelScene
	if StableModelScene then
		local PetInfo = StableModelScene.PetInfo
		if PetInfo then
			hooksecurefunc(PetInfo.Type, 'SetText', S.ReplaceIconString)

			--S:HandleButton(PetInfo.NameBox.EditButton) -- ToDo: 10.2.7: Halp, Fix me
		end

		local AbilitiesList = StableModelScene.AbilitiesList
		if AbilitiesList then
			hooksecurefunc(AbilitiesList, 'Layout', AbilitiesList_Layout)
		end
	end
	S:HandleModelSceneControlButtons(StableModelScene.ControlFrame)
end

S:AddCallbackForAddon('Blizzard_StableUI')
