local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs, select, next, sort, unpack, wipe, ceil = ipairs, select, next, sort, unpack, wipe, ceil
local format, strfind, strjoin, strsplit, strmatch = format, strfind, strjoin, strsplit, strmatch

local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildRosterMOTD = GetGuildRosterMOTD
local MouseIsOver = MouseIsOver
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local ToggleGuildFrame = ToggleGuildFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local IsAltKeyDown = IsAltKeyDown

local LoadAddOn = C_AddOns.LoadAddOn

local COMBAT_FACTION_CHANGE = COMBAT_FACTION_CHANGE
local REMOTE_CHAT = REMOTE_CHAT
local GUILD_MOTD = GUILD_MOTD
local GUILD = GUILD

local GetGuildFactionData = C_Reputation.GetGuildFactionData
local GetAndSortMemberInfo = CommunitiesUtil.GetAndSortMemberInfo
local GetSubscribedClubs = C_Club.GetSubscribedClubs
local CLUBTYPE_GUILD = Enum.ClubType.Guild

local TIMERUNNING_ATLAS = '|A:timerunning-glues-icon-small:%s:%s:0:0|a'
local TIMERUNNING_SMALL = format(TIMERUNNING_ATLAS, 12, 10)

local FACTION_ATLAS = '|A:communities-icon-faction-%s:%s:%s:0:0|a '
local FACTION_ALLIANCE = format(FACTION_ATLAS, 'alliance', 13, 13)
local FACTION_HORDE = format(FACTION_ATLAS, 'horde', 13, 13)

local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString, db = ''
local noGuildString = ''
local guildInfoString = '%s'
local guildInfoString2 = GUILD..': %d/%d'
local guildMotDString = '%s |cffaaaaaa- |cffffffff%s'
local levelNameString = '|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r'
local levelNameStatusString = '%s|cff%02x%02x%02x%d|r %s%s%s %s'
local nameRankString = '%s %s|cff999999-|cffffffff %s'
local standingString = E:RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b)..'%s:|r |cFFFFFFFF%s/%s (%s%%)'
local moreMembersOnlineString = strjoin('', '+%d ', _G.FRIENDS_LIST_ONLINE, '...')
local noteString = strjoin('', '|cff999999   ', _G.LABEL_NOTE, ':|r %s')
local officerNoteString = strjoin('', '|cff999999   ', _G.GUILD_RANK1_DESC, ':|r %s')
local clubTable, guildTable, guildMotD = {}, {}, ''

local function SortByRank(a, b)
	if a and b then
		if a.rankIndex == b.rankIndex then
			return a.name < b.name
		end
		return a.rankIndex < b.rankIndex
	end
end

local function SortByName(a, b)
	if a and b then
		return a.name < b.name
	end
end

local function SortGuildTable(shift)
	if shift then
		sort(guildTable, SortByRank)
	else
		sort(guildTable, SortByName)
	end
end

local onlinestatus = {
	[0] = '',
	[1] = format(' |cffFFFFFF[|r|cffFF9900%s|r|cffFFFFFF]|r', L["AFK"]),
	[2] = format(' |cffFFFFFF[|r|cffFF3333%s|r|cffFFFFFF]|r', L["DND"]),
}

local mobilestatus = {
	[0] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t]],
	[1] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t]],
	[2] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t]],
}

local function InGroup(name)
	return (UnitInParty(name) or UnitInRaid(name)) and '|cffaaaaaa*|r' or ''
end

local function BuildGuildTable()
	wipe(guildTable)
	wipe(clubTable)

	local clubs = E.Retail and GetSubscribedClubs()
	if clubs then -- use this to get the timerunning flag (and other info?)
		local guildClubID
		for _, data in next, clubs do
			if data.clubType == CLUBTYPE_GUILD then
				guildClubID = data.clubId
				break
			end
		end

		local members = guildClubID and GetAndSortMemberInfo(guildClubID)
		if members then
			for _, data in next, members do
				if data.guid then
					clubTable[data.guid] = data
				end
			end
		end
	end

	local totalMembers = GetNumGuildMembers()
	for i = 1, totalMembers do
		local name, rank, rankIndex, level, _, zone, note, officerNote, connected, memberstatus, className, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
		if not name then return end

		local statusInfo = isMobile and mobilestatus[memberstatus] or onlinestatus[memberstatus]
		zone = (isMobile and not connected) and REMOTE_CHAT or zone

		if connected or isMobile then
			local clubMember = clubTable[guid]
			local data = {
				name = E:StripMyRealm(name),	--1
				rank = rank,					--2
				level = level,					--3
				zone = zone,					--4
				note = note,					--5
				officerNote = officerNote,		--6
				online = connected,				--7
				status = statusInfo,			--8
				class = className,				--9
				rankIndex = rankIndex,			--10
				isMobile = isMobile,			--11
				guid = guid						--12
			}

			if clubMember then
				data.timerunningID = clubMember.timerunningSeasonID
				data.faction = clubMember.faction
			end

			guildTable[#guildTable + 1] = data
		end
	end
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local FRIEND_ONLINE = select(2, strsplit(' ', _G.ERR_FRIEND_ONLINE_SS, 2))
local resendRequest = false
local eventHandlers = {
	PLAYER_GUILD_UPDATE = C_GuildInfo_GuildRoster,
	CHAT_MSG_SYSTEM = function(_, arg1)
		if FRIEND_ONLINE ~= nil and arg1 and strfind(arg1, FRIEND_ONLINE) then
			resendRequest = true
		end
	end,
	-- when we enter the world and guildframe is not available then
	-- load guild frame, update guild message and guild xp
	PLAYER_ENTERING_WORLD = function()
		if not _G.GuildFrame and IsInGuild() then
			LoadAddOn('Blizzard_GuildUI')
			C_GuildInfo_GuildRoster()
		end
	end,
	-- Guild Roster updated, so rebuild the guild table
	GUILD_ROSTER_UPDATE = function(self)
		if resendRequest then
			resendRequest = false
			return C_GuildInfo_GuildRoster()
		else
			BuildGuildTable()
			UpdateGuildMessage()
			if MouseIsOver(self) then
				self:GetScript('OnEnter')(self, nil, true)
			end
		end
	end,
	-- our guild message of the day changed
	GUILD_MOTD = function(_, arg1)
		guildMotD = arg1
	end
}

local menuList = {
	{ text = _G.OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = _G.INVITE, hasArrow = true, notCheckable=true,},
	{ text = _G.CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true,}
}

local function Click(self, btn)
	if btn == 'RightButton' and IsInGuild() then
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for _, info in ipairs(guildTable) do
			if (info.online or info.isMobile) and info.name ~= E.myname then
				local classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
				if not classc then classc = levelc end

				local name = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info.level, classc.r*255,classc.g*255,classc.b*255, info.name)
				if InGroup(info.name) ~= '' then
					name = name..' |cffaaaaaa*|r'
				elseif not (info.isMobile and info.zone == REMOTE_CHAT) then
					menuCountInvites = menuCountInvites + 1
					menuList[2].menuList[menuCountInvites] = {text = name, arg1 = info.name, arg2 = info.guid, notCheckable=true, func = DT.InviteFriend}
				end

				menuCountWhispers = menuCountWhispers + 1
				menuList[3].menuList[menuCountWhispers] = {text = name, arg1 = info.name, notCheckable=true, func = DT.SendWhisper}
			end
		end

		E:SetEasyMenuAnchor(E.EasyMenu, self)
		E:ComplicatedMenu(menuList, E.EasyMenu, nil, nil, nil, 'MENU')
	elseif not E:AlertCombat() then
		ToggleGuildFrame()
	end
end

local function OnEnter(_, _, noUpdate)
	if not IsInGuild() then return end
	DT.tooltip:ClearLines()

	local shiftDown = IsShiftKeyDown()
	local total, _, online = GetNumGuildMembers()
	if not total then total = 0 end
	if not online then online = 0 end

	if #guildTable == 0 then BuildGuildTable() end

	SortGuildTable(shiftDown)

	local guildName, guildRank = GetGuildInfo('player')
	if guildName and guildRank then
		DT.tooltip:AddDoubleLine(format(guildInfoString, guildName), format(guildInfoString2, online, total), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
		DT.tooltip:AddLine(guildRank, unpack(tthead))
	end

	if guildMotD ~= '' then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1)
	end

	if E.Retail then
		local info = GetGuildFactionData()
		if info and info.reaction ~= 8 then -- Not Max Rep
			local nextReactionThreshold = info.nextReactionThreshold - info.currentReactionThreshold
			local currentStanding = info.currentStanding - info.currentReactionThreshold
			DT.tooltip:AddLine(format(standingString, COMBAT_FACTION_CHANGE, E:ShortValue(currentStanding), E:ShortValue(nextReactionThreshold), ceil((currentStanding / nextReactionThreshold) * 100)))
		end
	end

	local zonec

	DT.tooltip:AddLine(' ')
	local limit = db.maxLimit
	local useLimit = limit and limit > 0
	for i, info in ipairs(guildTable) do
		-- if more then guild members are online, we don't Show any more, but inform user there are more
		if useLimit and i > limit then
			local count = online - limit
			if count > 1 then
				DT.tooltip:AddLine(format(moreMembersOnlineString, count), ttsubh.r, ttsubh.g, ttsubh.b)
			end

			break
		end

		if E.MapInfo.zoneText and (E.MapInfo.zoneText == info.zone) then zonec = activezone else zonec = inactivezone end

		local classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
		if not classc then classc = levelc end

		local faction = info.faction == 1 and FACTION_ALLIANCE or info.faction == 0 and FACTION_HORDE or ''
		if shiftDown then
			DT.tooltip:AddDoubleLine(format(nameRankString, faction, info.name, info.rank), info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
			if info.note ~= '' then DT.tooltip:AddLine(format(noteString, info.note), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
			if info.officerNote ~= '' then DT.tooltip:AddLine(format(officerNoteString, info.officerNote), ttoff.r, ttoff.g, ttoff.b, 1) end
		else
			DT.tooltip:AddDoubleLine(format(levelNameStatusString, faction, levelc.r*255, levelc.g*255, levelc.b*255, info.level, strmatch(info.name,'([^%-]+).*'), InGroup(info.name), info.status, info.timerunningID and TIMERUNNING_SMALL or ''), info.zone, classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
		end
	end

	if not noUpdate then
		C_GuildInfo_GuildRoster()
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event, ...)
	if IsInGuild() then
		local func = eventHandlers[event]
		if func then func(self, ...) end

		if not IsAltKeyDown() and event == 'MODIFIER_STATE_CHANGED' and MouseIsOver(self) then
			OnEnter(self)
		end

		if db.NoLabel then
			self.text:SetFormattedText(displayString, #guildTable)
		else
			self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or GUILD..': ', #guildTable)
		end
	else
		self.text:SetText(noGuildString)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
	noGuildString = hex..L["No Guild"]
end

DT:RegisterDatatext('Guild', _G.SOCIAL_LABEL, { 'CHAT_MSG_SYSTEM', 'GUILD_ROSTER_UPDATE', 'PLAYER_GUILD_UPDATE', 'GUILD_MOTD', 'MODIFIER_STATE_CHANGED' }, OnEvent, nil, Click, OnEnter, nil, GUILD, nil, ApplySettings)
