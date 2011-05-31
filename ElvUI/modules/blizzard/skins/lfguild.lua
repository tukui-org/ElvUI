local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].lfguild ~= true then return end

local function LoadSkin()
	local checkbox = {
		"LookingForGuildPvPButton",
		"LookingForGuildWeekendsButton",
		"LookingForGuildWeekdaysButton",
		"LookingForGuildRPButton",
		"LookingForGuildRaidButton",
		"LookingForGuildQuestButton",
		"LookingForGuildDungeonButton",
	}
	-- skin checkboxes
	for _, v in pairs(checkbox) do
		E.SkinCheckBox(_G[v])
	end
	

	-- have to skin these checkboxes seperate for some reason o_O
	E.SkinCheckBox(LookingForGuildTankButton.checkButton)
	E.SkinCheckBox(LookingForGuildHealerButton.checkButton)
	E.SkinCheckBox(LookingForGuildDamagerButton.checkButton)
	
	-- skinning other frames
	LookingForGuildFrameInset:StripTextures(false)
	LookingForGuildFrame:StripTextures()
	LookingForGuildFrame:SetTemplate("Default")
	LookingForGuildBrowseButton_LeftSeparator:Kill()
	LookingForGuildRequestButton_RightSeparator:Kill()
	E.SkinScrollBar(LookingForGuildBrowseFrameContainerScrollBar)
	E.SkinButton(LookingForGuildBrowseButton)
	E.SkinButton(LookingForGuildRequestButton)
	E.SkinCloseButton(LookingForGuildFrameCloseButton)
	LookingForGuildCommentInputFrame:CreateBackdrop("Default")
	LookingForGuildCommentInputFrame:StripTextures(false)
	
	-- skin container buttons on browse and request page
	for i = 1, 5 do
		local b = _G["LookingForGuildBrowseFrameContainerButton"..i]
		local t = _G["LookingForGuildAppsFrameContainerButton"..i]
		b:SetBackdrop(nil)
		t:SetBackdrop(nil)
	end
	
	-- skin tabs
	for i= 1, 3 do
		E.SkinTab(_G["LookingForGuildFrameTab"..i])
	end
	
	GuildFinderRequestMembershipFrame:StripTextures(true)
	GuildFinderRequestMembershipFrame:SetTemplate("Transparent")
	E.SkinButton(GuildFinderRequestMembershipFrameAcceptButton)
	E.SkinButton(GuildFinderRequestMembershipFrameCancelButton)
	GuildFinderRequestMembershipFrameInputFrame:StripTextures()
	GuildFinderRequestMembershipFrameInputFrame:SetTemplate("Default")
end

E.SkinFuncs["Blizzard_LookingForGuildUI"] = LoadSkin