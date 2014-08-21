local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')


local cos, sin, rad = math.cos, math.sin, math.rad;
function SetAngledTexture(t, A, B, C, D, E, F)
	local det = A*E - B*D;
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
	
	ULx, ULy = ( B*F - C*E ) / det, ( -(A*F) + C*D ) / det;
	LLx, LLy = ( -B + B*F - C*E ) / det, ( A - A*F + C*D ) / det;
	URx, URy = ( E + B*F - C*E ) / det, ( -D - A*F + C*D ) / det;
	LRx, LRy = ( E - B + B*F - C*E ) / det, ( -D + A -(A*F) + C*D ) / det;

	t:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end


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
	WorldMapLevelDropDown:SetPoint("TOPLEFT", -17, 0)

	WorldMapFrame.BorderFrame:CreateBackdrop("Transparent")
	WorldMapFrame.BorderFrame.Inset:CreateBackdrop("Default")
	WorldMapFrame.BorderFrame.Inset.backdrop:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame.Inset, "TOPLEFT", 3, -3)
	WorldMapFrame.BorderFrame.Inset.backdrop:SetPoint("BOTTOMRIGHT", WorldMapFrame.BorderFrame.Inset, "BOTTOMRIGHT", -3, 2)

	S:HandleScrollBar(QuestScrollFrameScrollBar)
	S:HandleButton(QuestScrollFrame.ViewAll)

	WorldMapFrameTutorialButton:Kill()

	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton)	
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)	
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton)

	S:HandleCloseButton(WorldMapFrameCloseButton)
	S:HandleButton(WorldMapFrameSizeDownButton, true)
	WorldMapFrameSizeDownButton:SetSize(16, 16)
	WorldMapFrameSizeDownButton:SetPoint("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeDownButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeDownButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeDownButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")


	local angle = rad(180);
	S:HandleButton(WorldMapFrameSizeUpButton, true)
	WorldMapFrameSizeUpButton:SetSize(16, 16)
	WorldMapFrameSizeUpButton:SetPoint("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeUpButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	SetAngledTexture(WorldMapFrameSizeUpButton:GetNormalTexture(), cos(angle), sin(angle), 1, -sin(angle), cos(angle), 1);
	SetAngledTexture(WorldMapFrameSizeUpButton:GetPushedTexture(), cos(angle), sin(angle), 1, -sin(angle), cos(angle), 1);
	SetAngledTexture(WorldMapFrameSizeUpButton:GetHighlightTexture(), cos(angle), sin(angle), 1, -sin(angle), cos(angle), 1);

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
		frame.Count:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)
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