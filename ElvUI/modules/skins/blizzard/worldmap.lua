local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	WorldMapFrame.BorderFrame.Inset:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrameNavBar:StripTextures()
	WorldMapFrameNavBarOverlay:StripTextures()

	WorldMapFrameNavBarHomeButton:StripTextures()
	WorldMapFrameNavBarHomeButton:SetTemplate("Default", true)
	WorldMapFrameNavBarHomeButton:SetFrameLevel(1)
	WorldMapFrameNavBarHomeButton.text:FontTemplate()

	S:HandleDropDownBox(WorldMapLevelDropDown)
	WorldMapLevelDropDown:Point("TOPLEFT", -17, 0)

	WorldMapFrame.BorderFrame:CreateBackdrop("Transparent")
	WorldMapFrame.BorderFrame.Inset:CreateBackdrop("Default")
	WorldMapFrame.BorderFrame.Inset.backdrop:Point("TOPLEFT", WorldMapFrame.BorderFrame.Inset, "TOPLEFT", 3, -3)
	WorldMapFrame.BorderFrame.Inset.backdrop:Point("BOTTOMRIGHT", WorldMapFrame.BorderFrame.Inset, "BOTTOMRIGHT", -3, 2)

	S:HandleScrollBar(QuestScrollFrameScrollBar)
	S:HandleButton(QuestScrollFrame.ViewAll)

	if E.global.general.disableTutorialButtons then
		WorldMapFrameTutorialButton:Kill()
	end

	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton)
	QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate("Transparent")

	S:HandleCloseButton(WorldMapFrameCloseButton)
	S:HandleButton(WorldMapFrameSizeDownButton, true)
	WorldMapFrameSizeDownButton:SetSize(16, 16)
	WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeDownButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeDownButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeDownButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")

	S:HandleButton(WorldMapFrameSizeUpButton, true)
	WorldMapFrameSizeUpButton:SetSize(16, 16)
	WorldMapFrameSizeUpButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeUpButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:GetNormalTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017)
	WorldMapFrameSizeUpButton:GetPushedTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017)
	WorldMapFrameSizeUpButton:GetHighlightTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017)


	local rewardFrames = {
		['MoneyFrame'] = true,
		['XPFrame'] = true,
		['SpellFrame'] = true,
		['SkillPointFrame'] = true, -- this may have extra textures.. need to check on it when possible
	}

	local function HandleReward(frame)
		frame.NameFrame:SetAlpha(0)
		frame.Icon:SetTexCoord(unpack(E.TexCoords))
		frame:CreateBackdrop()
		frame.backdrop:SetOutside(frame.Icon)
		frame.Name:FontTemplate()
		frame.Count:ClearAllPoints()
		frame.Count:Point("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)
		if(frame.CircleBackground) then
			frame.CircleBackground:SetAlpha(0)
			frame.CircleBackgroundGlow:SetAlpha(0)
		end
	end

	for frame, _ in pairs(rewardFrames) do
		HandleReward(MapQuestInfoRewardsFrame[frame])
	end


	hooksecurefunc('QuestInfo_GetRewardButton', function(rewardsFrame, index)
		local button = MapQuestInfoRewardsFrame.RewardButtons[index]
		if(button) then
			HandleReward(button)
		end
	end)

	S:HandleNextPrevButton(WorldMapFrame.UIElementsFrame.OpenQuestPanelButton)
	S:HandleNextPrevButton(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton)
	SquareButton_SetIcon(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton, 'LEFT')
end

S:RegisterSkin('ElvUI', LoadSkin)