local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local format = string.format

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end
	GuildFrame:StripTextures(true)
	GuildFrame:SetTemplate("Transparent")
	--GuildLevelFrame:Kill()

	S:HandleCloseButton(GuildMemberDetailCloseButton)
	S:HandleCloseButton(GuildFrameCloseButton)
	S:HandleScrollBar(GuildInfoFrameApplicantsContainerScrollBar)
	local striptextures = {
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
			S:HandleButton(_G[button])
		else
			S:HandleButton(_G[button], true)
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
		S:HandleCheckBox(_G["GuildRecruitment"..frame.."Button"])
	end

	S:HandleCheckBox(GuildRecruitmentTankButton:GetChildren())
	S:HandleCheckBox(GuildRecruitmentHealerButton:GetChildren())
	S:HandleCheckBox(GuildRecruitmentDamagerButton:GetChildren())

	for i=1,5 do
		S:HandleTab(_G["GuildFrameTab"..i])
	end

	S:HandleScrollBar(GuildPerksContainerScrollBar, 4)

	GuildFactionBar:StripTextures()
	GuildFactionBar.progress:SetTexture(E["media"].normTex)
	GuildFactionBar:CreateBackdrop("Default")
	GuildFactionBar.backdrop:Point("TOPLEFT", GuildFactionBar.progress, "TOPLEFT", -E.Border, E.Border)
	GuildFactionBar.backdrop:Point("BOTTOMRIGHT", GuildFactionBar, "BOTTOMRIGHT", E.Spacing, E.PixelMode and 1 or 0)


	--Roster
	S:HandleScrollBar(GuildRosterContainerScrollBar, 5)
	S:HandleCheckBox(GuildRosterShowOfflineButton)


	for i=1, 4 do
		_G["GuildRosterColumnButton"..i]:StripTextures(true)
	end

	S:HandleDropDownBox(GuildRosterViewDropdown, 200)

	for i=1, 14 do
		S:HandleButton(_G["GuildRosterContainerButton"..i.."HeaderButton"], true)
	end

	--Detail Frame
	GuildMemberDetailFrame:SetTemplate("Transparent")
	GuildMemberNoteBackground:SetTemplate("Transparent")
	GuildMemberOfficerNoteBackground:SetTemplate("Transparent")
	GuildMemberRankDropdown:SetFrameLevel(GuildMemberRankDropdown:GetFrameLevel() + 5)
	S:HandleDropDownBox(GuildMemberRankDropdown, 175)

	--News
	GuildNewsFrame:StripTextures()
	for i=1, 17 do
		if _G["GuildNewsContainerButton"..i] then
			_G["GuildNewsContainerButton"..i].header:Kill()
		end
	end

	GuildNewsFiltersFrame:StripTextures()
	GuildNewsFiltersFrame:SetTemplate("Transparent")
	S:HandleCloseButton(GuildNewsFiltersFrameCloseButton)

	for i=1, 6 do
		S:HandleCheckBox(_G["GuildNewsFilterButton"..i])
	end

	GuildNewsFiltersFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -20)
	S:HandleScrollBar(GuildNewsContainerScrollBar, 4)

	--Info Frame
	S:HandleScrollBar(GuildInfoDetailsFrameScrollBar, 4)

	for i=1, 3 do
		_G["GuildInfoFrameTab"..i]:StripTextures()
	end

	local backdrop1 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop1:SetTemplate("Transparent")
	backdrop1:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop1:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -22)
	backdrop1:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 200)

	local backdrop2 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop2:SetTemplate("Transparent")
	backdrop2:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop2:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -158)
	backdrop2:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 118)

	local backdrop3 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop3:SetTemplate("Transparent")
	backdrop3:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop3:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -233)
	backdrop3:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 3)

	GuildRecruitmentCommentInputFrame:SetTemplate("Transparent")

	for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
		button.selectedTex:Kill()
		button:GetHighlightTexture():Kill()
		button:SetBackdrop(nil)
	end

	--Text Edit Frame
	GuildTextEditFrame:SetTemplate("Transparent")
	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar, 5)
	GuildTextEditContainer:SetTemplate("Transparent")
	for i=1, GuildTextEditFrame:GetNumChildren() do
		local child = select(i, GuildTextEditFrame:GetChildren())
		if child:GetName() == "GuildTextEditFrameCloseButton" and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif child:GetName() == "GuildTextEditFrameCloseButton" then
			S:HandleButton(child, true)
		end
	end

	--Guild Log
	S:HandleScrollBar(GuildLogScrollFrameScrollBar, 4)
	GuildLogFrame:SetTemplate("Transparent")

	--Blizzard has two buttons with the same name, this is a fucked up way of determining that it isn't the other button
	for i=1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())
		if child:GetName() == "GuildLogFrameCloseButton" and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif child:GetName() == "GuildLogFrameCloseButton" then
			S:HandleButton(child, true)
		end
	end

	--Perks
	for i=1, 9 do
		local button = _G["GuildPerksContainerButton"..i]
		button:DisableDrawLayer("BACKGROUND")
		button:DisableDrawLayer("BORDER")

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)
	end

	--Rewards
	S:HandleScrollBar(GuildRewardsContainerScrollBar, 5)

	for i=1, 8 do
		local button = _G["GuildRewardsContainerButton"..i]
		button:StripTextures()

		if button.icon then
			button.icon:SetTexCoord(unpack(E.TexCoords))
			button.icon:ClearAllPoints()
			button.icon:Point("TOPLEFT", 2, -2)
			button:CreateBackdrop("Default")
			button.backdrop:SetOutside(button.icon)
			button.icon:SetParent(button.backdrop)
		end
	end
end

S:RegisterSkin("Blizzard_GuildUI", LoadSkin)