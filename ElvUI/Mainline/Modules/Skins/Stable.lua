local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local function ReplaceIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == "" then return end

	local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
	if count > 0 then self:SetFormattedText("%s", newText) end
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
			hooksecurefunc(PetInfo.Type, 'SetText', ReplaceIconString)

			--S:HandleButton(PetInfo.NameBox.EditButton) -- ToDo: 10.2.7: Halp, Fix me
		end

		local StableList = StableModelScene.AbilitiesList
		if StableList then
			hooksecurefunc(StableList, 'Layout', function(self)
				for frame in self.abilityPool:EnumerateActive() do
					if not frame.IsSkinned then
						S:HandleIcon(frame.Icon)
						frame.IsSkinned = true
					end
				end
			end)
		end
	end
	S:HandleModelSceneControlButtons(StableModelScene.ControlFrame)
end

S:AddCallbackForAddon('Blizzard_StableUI')
