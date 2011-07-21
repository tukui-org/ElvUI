local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["skin"].enable ~= true or C["skin"].guild ~= true then return end

local function LoadSkin()
	GuildFrame:StripTextures(true)
	GuildFrame:SetTemplate("Transparent")
	GuildFrame:CreateShadow("Default")
	GuildLevelFrame:Kill()
	
	E.SkinCloseButton(GuildMemberDetailCloseButton)
	E.SkinCloseButton(GuildFrameCloseButton)
	
	local striptextures = {
		"GuildNewPerksFrame",
		"GuildFrameInset",
		"GuildFrameBottomInset",
		"GuildAllPerksFrame",
		"GuildMemberDetailFrame",
		"GuildMemberNoteBackground",
		"GuildInfoFrameInfo",
		"GuildLogContainer",
		"GuildLogFrame",
		"GuildRewardsFrame",
		"GuildMemberOfficerNoteBackground",
		"GuildTextEditContainer",
		"GuildTextEditFrame",
		"GuildRecruitmentRolesFrame",
		"GuildRecruitmentAvailabilityFrame",
		"GuildRecruitmentInterestFrame",
		"GuildRecruitmentLevelFrame",
		"GuildRecruitmentCommentFrame",
		"GuildRecruitmentCommentInputFrame",
		"GuildInfoFrameApplicantsContainer",
		"GuildInfoFrameApplicants",
		"GuildNewsBossModel",
		"GuildNewsBossModelTextFrame",
	}
	GuildRewardsFrameVisitText:ClearAllPoints()
	GuildRewardsFrameVisitText:SetPoint("TOP", GuildRewardsFrame, "TOP", 0, 30)
	for _, frame in pairs(striptextures) do
		_G[frame]:StripTextures()
	end
	
	GuildNewsBossModel:CreateBackdrop("Transparent")
	GuildNewsBossModelTextFrame:CreateBackdrop("Default")
	GuildNewsBossModelTextFrame.backdrop:Point("TOPLEFT", GuildNewsBossModel.backdrop, "BOTTOMLEFT", 0, -1)
	GuildNewsBossModel:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -43)
	
	local buttons = {
		"GuildPerksToggleButton",
		"GuildMemberRemoveButton",
		"GuildMemberGroupInviteButton",
		"GuildAddMemberButton",
		"GuildViewLogButton",
		"GuildControlButton",
		"GuildRecruitmentListGuildButton",
		"GuildTextEditFrameAcceptButton",
		"GuildRecruitmentInviteButton",
		"GuildRecruitmentMessageButton",
		"GuildRecruitmentDeclineButton",
	}
	
	for i, button in pairs(buttons) do
		if i == 1 then
			E.SkinButton(_G[button])
		else
			E.SkinButton(_G[button], true)
		end
	end
	
	local checkbuttons = {
		"Quest", 
		"Dungeon",
		"Raid",
		"PvP",
		"RP",
		"Weekdays",
		"Weekends",
		"LevelAny",
		"LevelMax",
	}
	
	for _, frame in pairs(checkbuttons) do
		E.SkinCheckBox(_G["GuildRecruitment"..frame.."Button"])
	end
	
	E.SkinCheckBox(GuildRecruitmentTankButton:GetChildren())
	E.SkinCheckBox(GuildRecruitmentHealerButton:GetChildren())
	E.SkinCheckBox(GuildRecruitmentDamagerButton:GetChildren())
	
	for i=1,5 do
		E.SkinTab(_G["GuildFrameTab"..i])
	end
	GuildXPFrame:ClearAllPoints()
	GuildXPFrame:Point("TOP", GuildFrame, "TOP", 0, -40)
	
	E.SkinScrollBar(GuildPerksContainerScrollBar, 4)
	
	GuildFactionBar:StripTextures()
	GuildFactionBar.progress:SetTexture(C["media"].normTex)
	GuildFactionBar:CreateBackdrop("Default")
	GuildFactionBar.backdrop:Point("TOPLEFT", GuildFactionBar.progress, "TOPLEFT", -2, 2)
	GuildFactionBar.backdrop:Point("BOTTOMRIGHT", GuildFactionBar, "BOTTOMRIGHT", -2, 0)
	
	GuildXPBarLeft:Kill()
	GuildXPBarRight:Kill()
	GuildXPBarMiddle:Kill()
	GuildXPBarBG:Kill()
	GuildXPBarShadow:Kill()
	GuildXPBarCap:Kill()
	GuildXPBar.progress:SetTexture(C["media"].normTex)
	GuildXPBar:CreateBackdrop("Default")
	GuildXPBar.backdrop:Point("TOPLEFT", GuildXPBar.progress, "TOPLEFT", -2, 2)
	GuildXPBar.backdrop:Point("BOTTOMRIGHT", GuildXPBar, "BOTTOMRIGHT", -2, 4)
	
	GuildLatestPerkButton:StripTextures()
	GuildLatestPerkButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	GuildLatestPerkButtonIconTexture:ClearAllPoints()
	GuildLatestPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
	GuildLatestPerkButton:CreateBackdrop("Default")
	GuildLatestPerkButton.backdrop:Point("TOPLEFT", GuildLatestPerkButtonIconTexture, "TOPLEFT", -2, 2)
	GuildLatestPerkButton.backdrop:Point("BOTTOMRIGHT", GuildLatestPerkButtonIconTexture, "BOTTOMRIGHT", 2, -2)
	
	GuildNextPerkButton:StripTextures()
	GuildNextPerkButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	GuildNextPerkButtonIconTexture:ClearAllPoints()
	GuildNextPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
	GuildNextPerkButton:CreateBackdrop("Default")
	GuildNextPerkButton.backdrop:Point("TOPLEFT", GuildNextPerkButtonIconTexture, "TOPLEFT", -2, 2)
	GuildNextPerkButton.backdrop:Point("BOTTOMRIGHT", GuildNextPerkButtonIconTexture, "BOTTOMRIGHT", 2, -2)
	
	--Guild Perk buttons list
	for i=1, 8 do
		local button = _G["GuildPerksContainerButton"..i]
		button:StripTextures()
		
		if button.icon then
			button.icon:SetTexCoord(.08, .92, .08, .92)
			button.icon:ClearAllPoints()
			button.icon:Point("TOPLEFT", 2, -2)
			button:CreateBackdrop("Default")
			button.backdrop:Point("TOPLEFT", button.icon, "TOPLEFT", -2, 2)
			button.backdrop:Point("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 2, -2)
			button.icon:SetParent(button.backdrop)
		end
	end
	
	--Roster
	E.SkinScrollBar(GuildRosterContainerScrollBar, 5)
	E.SkinCheckBox(GuildRosterShowOfflineButton)
	
	
	for i=1, 4 do
		_G["GuildRosterColumnButton"..i]:StripTextures(true)
	end
	
	E.SkinDropDownBox(GuildRosterViewDropdown, 200)
	
	for i=1, 14 do
		E.SkinButton(_G["GuildRosterContainerButton"..i.."HeaderButton"], true)
	end
	
	--Detail Frame
	GuildMemberDetailFrame:SetTemplate("Transparent")
	GuildMemberNoteBackground:SetTemplate("Default")
	GuildMemberOfficerNoteBackground:SetTemplate("Default")
	GuildMemberRankDropdown:SetFrameLevel(GuildMemberRankDropdown:GetFrameLevel() + 5)
	E.SkinDropDownBox(GuildMemberRankDropdown, 175)

	--News
	GuildNewsFrame:StripTextures()
	for i=1, 17 do
		_G["GuildNewsContainerButton"..i].header:Kill()
	end
	
	GuildNewsFiltersFrame:StripTextures()
	GuildNewsFiltersFrame:SetTemplate("Transparent")
	E.SkinCloseButton(GuildNewsFiltersFrameCloseButton)
	
	for i=1, 7 do
		E.SkinCheckBox(_G["GuildNewsFilterButton"..i])
	end
	
	GuildNewsFiltersFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -20)
	E.SkinScrollBar(GuildNewsContainerScrollBar, 4)
	
	--Info Frame
	E.SkinScrollBar(GuildInfoDetailsFrameScrollBar, 4)
	
	for i=1, 3 do
		_G["GuildInfoFrameTab"..i]:StripTextures()
	end
	
	local backdrop1 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop1:SetTemplate("Default")
	backdrop1:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop1:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -22)
	backdrop1:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 200)
	
	local backdrop2 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop2:SetTemplate("Default")
	backdrop2:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop2:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -158)
	backdrop2:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 118)	

	local backdrop3 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop3:SetTemplate("Default")
	backdrop3:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop3:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -233)
	backdrop3:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 3)	
	
	GuildRecruitmentCommentInputFrame:SetTemplate("Default")
	
	for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
		button.selectedTex:Kill()
		button:GetHighlightTexture():Kill()
		button:SetBackdrop(nil)
	end
	
	--Text Edit Frame
	GuildTextEditFrame:SetTemplate("Transparent")
	E.SkinScrollBar(GuildTextEditScrollFrameScrollBar, 5)
	GuildTextEditContainer:SetTemplate("Default")
	for i=1, GuildTextEditFrame:GetNumChildren() do
		local child = select(i, GuildTextEditFrame:GetChildren())
		if child:GetName() == "GuildTextEditFrameCloseButton" and child:GetWidth() < 33 then
			E.SkinCloseButton(child)
		elseif child:GetName() == "GuildTextEditFrameCloseButton" then
			E.SkinButton(child, true)
		end
	end
	
	--Guild Log
	E.SkinScrollBar(GuildLogScrollFrameScrollBar, 4)
	GuildLogFrame:SetTemplate("Transparent")

	--Blizzard has two buttons with the same name, this is a fucked up way of determining that it isn't the other button
	for i=1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())
		if child:GetName() == "GuildLogFrameCloseButton" and child:GetWidth() < 33 then
			E.SkinCloseButton(child)
		elseif child:GetName() == "GuildLogFrameCloseButton" then
			E.SkinButton(child, true)
		end
	end
	
	--Rewards
	E.SkinScrollBar(GuildRewardsContainerScrollBar, 5)
	
	for i=1, 8 do
		local button = _G["GuildRewardsContainerButton"..i]
		button:StripTextures()
		
		if button.icon then
			button.icon:SetTexCoord(.08, .92, .08, .92)
			button.icon:ClearAllPoints()
			button.icon:Point("TOPLEFT", 2, -2)
			button:CreateBackdrop("Default")
			button.backdrop:Point("TOPLEFT", button.icon, "TOPLEFT", -2, 2)
			button.backdrop:Point("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 2, -2)
			button.icon:SetParent(button.backdrop)
		end
	end
end

E.SkinFuncs["Blizzard_GuildUI"] = LoadSkin