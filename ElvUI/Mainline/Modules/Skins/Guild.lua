local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, pairs, unpack = next, pairs, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_GuildInfo_CanViewOfficerNote = C_GuildInfo.CanViewOfficerNote

function S:Blizzard_GuildUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guild) then return end

	local GuildFrame = _G.GuildFrame
	S:HandlePortraitFrame(GuildFrame)
	S:HandleCloseButton(_G.GuildMemberDetailCloseButton)

	local striptextures = {
		'GuildFrameInset',
		'GuildFrameBottomInset',
		'GuildAllPerksFrame',
		'GuildMemberDetailFrame',
		'GuildMemberNoteBackground',
		'GuildInfoFrameInfo',
		'GuildLogFrame',
		'GuildRewardsFrame',
		'GuildMemberOfficerNoteBackground',
		'GuildTextEditFrame',
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
		'GuildTextEditFrameAcceptButton',
	}

	for i, button in pairs(buttons) do
		if i == 1 then
			S:HandleButton(_G[button])
		else
			S:HandleButton(_G[button], true)
		end
	end

	for i = 1, 5 do
		S:HandleTab(_G['GuildFrameTab'..i])
	end

	S:HandleScrollBar(_G.GuildPerksContainerScrollBar)

	local GuildFactionBar = _G.GuildFactionBar
	GuildFactionBar:StripTextures()
	GuildFactionBar.progress:SetTexture(E.media.normTex)
	E:RegisterStatusBar(GuildFactionBar.progress)
	GuildFactionBar:CreateBackdrop()
	GuildFactionBar.backdrop:Point('TOPLEFT', GuildFactionBar.progress, 'TOPLEFT', -E.Border, E.Border)
	GuildFactionBar.backdrop:Point('BOTTOMRIGHT', GuildFactionBar, 'BOTTOMRIGHT', E.Spacing, E.PixelMode and 1 or 0)

	--Roster
	S:HandleScrollBar(_G.GuildRosterContainerScrollBar)
	S:HandleCheckBox(_G.GuildRosterShowOfflineButton)

	for i = 1, 4 do
		_G['GuildRosterColumnButton'..i]:StripTextures(true)
	end

	S:HandleDropDownBox(_G.GuildRosterViewDropdown, 200)

	for i = 1, 14 do
		local button = _G['GuildRosterContainerButton'..i]
		local header = button and button.header
		if header then
			S:HandleButton(header, true)
		end
	end

	--Detail Frame
	_G.GuildMemberDetailFrame:SetTemplate('Transparent')
	_G.GuildMemberNoteBackground.NineSlice:SetTemplate('Transparent')
	_G.GuildMemberOfficerNoteBackground.NineSlice:SetTemplate('Transparent')
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
	for i = 1, 17 do
		local button = _G['GuildNewsContainerButton'..i]
		if button and button.header then
			button.header:Kill()
		end
	end

	_G.GuildNewsFiltersFrame:StripTextures()
	_G.GuildNewsFiltersFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.GuildNewsFiltersFrameCloseButton)

	for i = 1, #_G.GuildNewsFiltersFrame.GuildNewsFilterButtons do
		S:HandleCheckBox(_G.GuildNewsFiltersFrame.GuildNewsFilterButtons[i])
	end

	_G.GuildNewsFiltersFrame:Point('TOPLEFT', GuildFrame, 'TOPRIGHT', 4, -20)
	S:HandleScrollBar(_G.GuildNewsContainerScrollBar)

	--Info Frame
	S:HandleTrimScrollBar(_G.GuildInfoDetailsFrameScrollBar)
	S:HandleTrimScrollBar(_G.GuildInfoFrameInfoMOTDScrollFrameScrollBar)

	_G.GuildInfoFrameTab1:StripTextures()
	_G.GuildInfoFrameTab1:SetTemplate('Transparent')

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

	--Text Edit Frame
	_G.GuildTextEditFrame:SetTemplate('Transparent')
	_G.GuildLogContainer.NineSlice:SetTemplate('Transparent')
	_G.GuildTextEditContainer.NineSlice:SetTemplate('Transparent')
	S:HandleScrollBar(_G.GuildTextEditScrollFrameScrollBar)

	for _, child in next, { _G.GuildTextEditFrame:GetChildren() } do
		local name = child:GetName()
		if name == 'GuildTextEditFrameCloseButton' and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif name == 'GuildTextEditFrameCloseButton' then
			S:HandleButton(child, true)
		end
	end

	--Guild Log
	local GuildLogFrame = _G.GuildLogFrame
	S:HandleScrollBar(_G.GuildLogScrollFrameScrollBar)
	GuildLogFrame:SetTemplate('Transparent')

	--Blizzard has two buttons with the same name, this is a fucked up way of determining that it isn't the other button
	for _, child in next, { GuildLogFrame:GetChildren() } do
		local name = child:GetName()
		if name == 'GuildLogFrameCloseButton' and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif name == 'GuildLogFrameCloseButton' then
			S:HandleButton(child, true)
		end
	end

	--Perks
	for i = 1, 9 do
		local button = _G['GuildPerksContainerButton'..i]
		button:StripTextures()
		button:SetTemplate('Transparent')

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Point('LEFT', 3, 0)
	end

	--Rewards
	S:HandleScrollBar(_G.GuildRewardsContainerScrollBar)

	for i = 1, 8 do
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
