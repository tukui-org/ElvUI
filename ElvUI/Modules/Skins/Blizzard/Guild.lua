local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local next, pairs, select, unpack = next, pairs, select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_GuildInfo_CanViewOfficerNote = C_GuildInfo.CanViewOfficerNote

function S:Blizzard_GuildUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guild) then return end

	local GuildFrame = _G.GuildFrame
	S:HandlePortraitFrame(GuildFrame)

	S:HandleCloseButton(_G.GuildMemberDetailCloseButton)
	S:HandleScrollBar(_G.GuildInfoFrameApplicantsContainerScrollBar)

	local striptextures = {
		'GuildFrameInset',
		'GuildFrameBottomInset',
		'GuildAllPerksFrame',
		'GuildMemberDetailFrame',
		'GuildMemberNoteBackground',
		'GuildInfoFrameInfo',
		'GuildLogContainer',
		'GuildLogFrame',
		'GuildRewardsFrame',
		'GuildMemberOfficerNoteBackground',
		'GuildTextEditContainer',
		'GuildTextEditFrame',
		'GuildRecruitmentRolesFrame',
		'GuildRecruitmentAvailabilityFrame',
		'GuildRecruitmentInterestFrame',
		'GuildRecruitmentLevelFrame',
		'GuildRecruitmentCommentFrame',
		'GuildRecruitmentCommentInputFrame',
		'GuildInfoFrameApplicantsContainer',
		'GuildInfoFrameApplicants',
		'GuildNewsBossModel',
		'GuildNewsBossModelTextFrame',
	}

	_G.GuildRewardsFrameVisitText:ClearAllPoints()
	_G.GuildRewardsFrameVisitText:Point('TOP', _G.GuildRewardsFrame, 'TOP', 0, 30)
	for _, frame in pairs(striptextures) do
		_G[frame]:StripTextures()
	end

	_G.GuildNewsBossModel:SetTemplate('Transparent')
	_G.GuildNewsBossModelTextFrame:CreateBackdrop()
	_G.GuildNewsBossModelTextFrame.backdrop:Point('TOPLEFT', _G.GuildNewsBossModel.backdrop, 'BOTTOMLEFT', 0, -1)
	_G.GuildNewsBossModel:Point('TOPLEFT', GuildFrame, 'TOPRIGHT', 4, -43)

	local buttons = {
		'GuildMemberRemoveButton',
		'GuildMemberGroupInviteButton',
		'GuildAddMemberButton',
		'GuildViewLogButton',
		'GuildControlButton',
		'GuildRecruitmentListGuildButton',
		'GuildTextEditFrameAcceptButton',
		'GuildRecruitmentInviteButton',
		'GuildRecruitmentMessageButton',
		'GuildRecruitmentDeclineButton',
	}

	for i, button in pairs(buttons) do
		if i == 1 then
			S:HandleButton(_G[button])
		else
			S:HandleButton(_G[button], true)
		end
	end

	local checkbuttons = {
		'Quest',
		'Dungeon',
		'Raid',
		'PvP',
		'RP',
		'Weekdays',
		'Weekends',
	}

	for _, frame in pairs(checkbuttons) do
		S:HandleCheckBox(_G['GuildRecruitment'..frame..'Button'])
	end

	S:HandleCheckBox(_G.GuildRecruitmentTankButton:GetChildren())
	S:HandleCheckBox(_G.GuildRecruitmentHealerButton:GetChildren())
	S:HandleCheckBox(_G.GuildRecruitmentDamagerButton:GetChildren())
	S:HandleButton(_G.GuildRecruitmentLevelAnyButton)
	S:HandleButton(_G.GuildRecruitmentLevelMaxButton)

	for i=1,5 do
		S:HandleTab(_G['GuildFrameTab'..i])
	end

	S:HandleScrollBar(_G.GuildPerksContainerScrollBar, 4)

	local GuildFactionBar = _G.GuildFactionBar
	GuildFactionBar:StripTextures()
	GuildFactionBar.progress:SetTexture(E.media.normTex)
	E:RegisterStatusBar(GuildFactionBar.progress)
	GuildFactionBar:CreateBackdrop()
	GuildFactionBar.backdrop:Point('TOPLEFT', GuildFactionBar.progress, 'TOPLEFT', -E.Border, E.Border)
	GuildFactionBar.backdrop:Point('BOTTOMRIGHT', GuildFactionBar, 'BOTTOMRIGHT', E.Spacing, E.PixelMode and 1 or 0)

	--Roster
	S:HandleScrollBar(_G.GuildRosterContainerScrollBar, 5)
	S:HandleCheckBox(_G.GuildRosterShowOfflineButton)

	for i=1, 4 do
		_G['GuildRosterColumnButton'..i]:StripTextures(true)
	end

	S:HandleDropDownBox(_G.GuildRosterViewDropdown, 200)

	for i=1, 14 do
		S:HandleButton(_G['GuildRosterContainerButton'..i..'HeaderButton'], true)
	end

	--Detail Frame
	_G.GuildMemberDetailFrame:SetTemplate('Transparent')
	_G.GuildMemberNoteBackground:SetTemplate('Transparent')
	_G.GuildMemberOfficerNoteBackground:SetTemplate('Transparent')
	_G.GuildMemberRankDropdown:SetFrameLevel(_G.GuildMemberRankDropdown:GetFrameLevel() + 5)
	S:HandleDropDownBox(_G.GuildMemberRankDropdown, 175)

	--Increase height of GuildMemberDetailFrame by changing global variables
	local GuildMemberDetailFrame = _G.GuildMemberDetailFrame
	local GuildMemberDetailName = _G.GuildMemberDetailName
	local GuildMemberDetailRankLabel = _G.GuildMemberDetailRankLabel
	hooksecurefunc(GuildMemberDetailFrame, 'SetHeight', function(_, _, breakLoop)
		if breakLoop then return end
		if C_GuildInfo_CanViewOfficerNote() then
			GuildMemberDetailFrame:Height(_G.GUILD_DETAIL_OFFICER_HEIGHT + 50 + GuildMemberDetailName:GetHeight() + GuildMemberDetailRankLabel:GetHeight(), true)
		else
			GuildMemberDetailFrame:Height(_G.GUILD_DETAIL_NORM_HEIGHT + 50 + GuildMemberDetailName:GetHeight() + GuildMemberDetailRankLabel:GetHeight(), true)
		end
	end)

	--News
	_G.GuildNewsFrame:StripTextures()
	for i=1, 17 do
		if _G['GuildNewsContainerButton'..i] then
			_G['GuildNewsContainerButton'..i].header:Kill()
		end
	end

	_G.GuildNewsFiltersFrame:StripTextures()
	_G.GuildNewsFiltersFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.GuildNewsFiltersFrameCloseButton)

	for i = 1, #_G.GuildNewsFiltersFrame.GuildNewsFilterButtons do
		S:HandleCheckBox(_G.GuildNewsFiltersFrame.GuildNewsFilterButtons[i])
	end

	_G.GuildNewsFiltersFrame:Point('TOPLEFT', GuildFrame, 'TOPRIGHT', 4, -20)
	S:HandleScrollBar(_G.GuildNewsContainerScrollBar, 4)

	--Info Frame
	S:HandleScrollBar(_G.GuildInfoDetailsFrameScrollBar, 4)

	for i=1, 3 do
		_G['GuildInfoFrameTab'..i]:StripTextures()
	end

	local GuildInfoFrameInfo = _G.GuildInfoFrameInfo
	local backdrop1 = CreateFrame('Frame', nil, GuildInfoFrameInfo)
	backdrop1:SetTemplate('Transparent')
	backdrop1:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop1:Point('TOPLEFT', GuildInfoFrameInfo, 'TOPLEFT', 2, -22)
	backdrop1:Point('BOTTOMRIGHT', GuildInfoFrameInfo, 'BOTTOMRIGHT', 0, 200)

	local backdrop2 = CreateFrame('Frame', nil, GuildInfoFrameInfo)
	backdrop2:SetTemplate('Transparent')
	backdrop2:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop2:Point('TOPLEFT', GuildInfoFrameInfo, 'TOPLEFT', 2, -158)
	backdrop2:Point('BOTTOMRIGHT', GuildInfoFrameInfo, 'BOTTOMRIGHT', 0, 118)

	local backdrop3 = CreateFrame('Frame', nil, GuildInfoFrameInfo)
	backdrop3:SetTemplate('Transparent')
	backdrop3:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
	backdrop3:Point('TOPLEFT', GuildInfoFrameInfo, 'TOPLEFT', 2, -233)
	backdrop3:Point('BOTTOMRIGHT', GuildInfoFrameInfo, 'BOTTOMRIGHT', 0, 3)

	_G.GuildRecruitmentCommentInputFrame:SetTemplate('Transparent')

	for _, button in next, _G.GuildInfoFrameApplicantsContainer.buttons do
		button.selectedTex:Kill()
		button:GetHighlightTexture():Kill()
		button:SetBackdrop()
	end

	--Text Edit Frame
	_G.GuildTextEditFrame:SetTemplate('Transparent')
	S:HandleScrollBar(_G.GuildTextEditScrollFrameScrollBar, 5)
	_G.GuildTextEditContainer:SetTemplate('Transparent')
	for i=1, _G.GuildTextEditFrame:GetNumChildren() do
		local child = select(i, _G.GuildTextEditFrame:GetChildren())
		if child:GetName() == 'GuildTextEditFrameCloseButton' and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif child:GetName() == 'GuildTextEditFrameCloseButton' then
			S:HandleButton(child, true)
		end
	end

	--Guild Log
	local GuildLogFrame = _G.GuildLogFrame
	S:HandleScrollBar(_G.GuildLogScrollFrameScrollBar, 4)
	GuildLogFrame:SetTemplate('Transparent')

	--Blizzard has two buttons with the same name, this is a fucked up way of determining that it isn't the other button
	for i=1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())
		if child:GetName() == 'GuildLogFrameCloseButton' and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif child:GetName() == 'GuildLogFrameCloseButton' then
			S:HandleButton(child, true)
		end
	end

	--Perks
	for i=1, 9 do
		local button = _G['GuildPerksContainerButton'..i]
		button:StripTextures()
		button:SetTemplate('Transparent')

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Point('LEFT', 3, 0)
	end

	--Rewards
	S:HandleScrollBar(_G.GuildRewardsContainerScrollBar, 5)

	for i=1, 8 do
		local button = _G['GuildRewardsContainerButton'..i]
		button:StripTextures()

		if button.icon then
			button.icon:SetTexCoord(unpack(E.TexCoords))
			button.icon:ClearAllPoints()
			button.icon:Point('TOPLEFT', 2, -2)
			button:CreateBackdrop()
			button.backdrop:SetOutside(button.icon)
			button.icon:SetParent(button.backdrop)
		end
	end
end

function S:GuildInviteFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guild) then return end

	local GuildInviteFrame = _G.GuildInviteFrame
	GuildInviteFrame:StripTextures()
	GuildInviteFrame:SetTemplate('Transparent')
	GuildInviteFrame.Points:ClearAllPoints()
	GuildInviteFrame.Points:Point('TOP', GuildInviteFrame, 'CENTER', 15, -25)
	S:HandleButton(_G.GuildInviteFrameJoinButton)
	S:HandleButton(_G.GuildInviteFrameDeclineButton)
	GuildInviteFrame:Height(225)
	GuildInviteFrame:HookScript('OnEvent', function()
		GuildInviteFrame:Height(225)
	end)

	_G.GuildInviteFrameWarningText:Kill()
end

S:AddCallbackForAddon('Blizzard_GuildUI')
S:AddCallback('GuildInviteFrame')
