local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function SkinLFGuild()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfguild ~= true then return end

	local LookingForGuildFrame = _G.LookingForGuildFrame
	S:HandlePortraitFrame(LookingForGuildFrame, true)

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
	S:HandleCheckBox(_G.LookingForGuildTankButton.checkButton)
	S:HandleCheckBox(_G.LookingForGuildHealerButton.checkButton)
	S:HandleCheckBox(_G.LookingForGuildDamagerButton.checkButton)

	S:HandleScrollBar(_G.LookingForGuildBrowseFrameContainerScrollBar)
	S:HandleButton(_G.LookingForGuildBrowseButton)
	S:HandleButton(_G.LookingForGuildRequestButton)

	_G.LookingForGuildCommentInputFrame:CreateBackdrop()
	_G.LookingForGuildCommentInputFrame:StripTextures(false)

	-- skin container buttons on browse and request page
	for i = 1, 5 do
		_G["LookingForGuildBrowseFrameContainerButton"..i]:SetBackdrop(nil)
		_G["LookingForGuildAppsFrameContainerButton"..i]:SetBackdrop(nil)
	end

	-- skin tabs
	for i= 1, 3 do
		S:HandleTab(_G["LookingForGuildFrameTab"..i])
	end

	_G.GuildFinderRequestMembershipFrame:StripTextures(true)
	_G.GuildFinderRequestMembershipFrame:SetTemplate("Transparent")
	S:HandleButton(_G.GuildFinderRequestMembershipFrameAcceptButton)
	S:HandleButton(_G.GuildFinderRequestMembershipFrameCancelButton)
	_G.GuildFinderRequestMembershipFrameInputFrame:StripTextures()
	_G.GuildFinderRequestMembershipFrameInputFrame:SetTemplate()
end

local function LoadSkin()
	if _G.LookingForGuildFrame then
		--Frame already created
		SkinLFGuild()
	else
		--Frame not created yet, wait until it is
		hooksecurefunc("LookingForGuildFrame_CreateUIElements", SkinLFGuild)
	end
end

S:AddCallbackForAddon("Blizzard_LookingForGuildUI", "LookingForGuild", LoadSkin)
