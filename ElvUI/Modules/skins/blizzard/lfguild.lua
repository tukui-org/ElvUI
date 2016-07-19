local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfguild ~= true then return end
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
		S:HandleCheckBox(_G[v])
	end


	-- have to skin these checkboxes seperate for some reason o_O
	S:HandleCheckBox(LookingForGuildTankButton.checkButton)
	S:HandleCheckBox(LookingForGuildHealerButton.checkButton)
	S:HandleCheckBox(LookingForGuildDamagerButton.checkButton)

	-- skinning other frames
	LookingForGuildFrameInset:StripTextures(false)
	LookingForGuildFrame:StripTextures()
	LookingForGuildFrame:SetTemplate("Transparent")
	LookingForGuildBrowseButton_LeftSeparator:Kill()
	LookingForGuildRequestButton_RightSeparator:Kill()
	S:HandleScrollBar(LookingForGuildBrowseFrameContainerScrollBar)
	S:HandleButton(LookingForGuildBrowseButton)
	S:HandleButton(LookingForGuildRequestButton)
	S:HandleCloseButton(LookingForGuildFrameCloseButton)
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
		S:HandleTab(_G["LookingForGuildFrameTab"..i])
	end

	GuildFinderRequestMembershipFrame:StripTextures(true)
	GuildFinderRequestMembershipFrame:SetTemplate("Transparent")
	S:HandleButton(GuildFinderRequestMembershipFrameAcceptButton)
	S:HandleButton(GuildFinderRequestMembershipFrameCancelButton)
	GuildFinderRequestMembershipFrameInputFrame:StripTextures()
	GuildFinderRequestMembershipFrameInputFrame:SetTemplate("Default")
end

S:RegisterSkin("Blizzard_LookingForGuildUI", LoadSkin)