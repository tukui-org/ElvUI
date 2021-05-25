local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

function S:LookingForGuildFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfguild) then return end

	local LookingForGuildFrame = _G.LookingForGuildFrame
	S:HandlePortraitFrame(LookingForGuildFrame)

	local checkbox = {
		'LookingForGuildPvPButton',
		'LookingForGuildWeekendsButton',
		'LookingForGuildWeekdaysButton',
		'LookingForGuildRPButton',
		'LookingForGuildRaidButton',
		'LookingForGuildQuestButton',
		'LookingForGuildDungeonButton',
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

	_G.LookingForGuildCommentInputFrame:StripTextures()
	_G.LookingForGuildCommentInputFrame:SetTemplate()

	-- skin container buttons on browse and request page
	for i = 1, 5 do
		_G['LookingForGuildBrowseFrameContainerButton'..i]:SetBackdrop()
		_G['LookingForGuildAppsFrameContainerButton'..i]:SetBackdrop()
	end

	-- skin tabs
	for i= 1, 3 do
		S:HandleTab(_G['LookingForGuildFrameTab'..i])
	end

	_G.GuildFinderRequestMembershipFrame:StripTextures(true)
	_G.GuildFinderRequestMembershipFrame:SetTemplate('Transparent')
	S:HandleButton(_G.GuildFinderRequestMembershipFrameAcceptButton)
	S:HandleButton(_G.GuildFinderRequestMembershipFrameCancelButton)
	_G.GuildFinderRequestMembershipFrameInputFrame:StripTextures()
	_G.GuildFinderRequestMembershipFrameInputFrame:SetTemplate()
end

function S:Blizzard_LookingForGuildUI()
	if _G.LookingForGuildFrame then -- frame exists
		S:LookingForGuildFrame()
	else -- not yet, wait until it is exists
		hooksecurefunc('LookingForGuildFrame_CreateUIElements', S.LookingForGuildFrame)
	end
end

S:AddCallbackForAddon('Blizzard_LookingForGuildUI')
