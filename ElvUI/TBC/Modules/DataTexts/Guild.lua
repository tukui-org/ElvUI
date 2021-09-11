local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs, select, sort, unpack, wipe, ceil = ipairs, select, sort, unpack, wipe, ceil
local format, strfind, strjoin, strsplit, strmatch = format, strfind, strjoin, strsplit, strmatch

local GetDisplayedInviteType = GetDisplayedInviteType
local GetGuildInfo = GetGuildInfo
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetMouseFocus = GetMouseFocus
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetGuildRosterInfo = GetGuildRosterInfo
local InviteToGroup = InviteToGroup
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local LoadAddOn = LoadAddOn
local RequestInviteFromUnit = RequestInviteFromUnit
local SetItemRef = SetItemRef
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleGuildFrame = ToggleGuildFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local GuildRoster = GuildRoster
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown

local GUILD = GUILD
local GUILD_MOTD = GUILD_MOTD
local REMOTE_CHAT = REMOTE_CHAT
local FRIEND_ONLINE = FRIEND_ONLINE
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local groupedTable = { "|cffaaaaaa*|r", "" }
local displayString = ""
local noGuildString = ""
local guildInfoString = "%s"
local guildInfoString2 = GUILD..": %d/%d"
local guildMotDString = "%s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusString = "|cff%02x%02x%02x%d|r %s%s %s"
local nameRankString = "%s |cff999999-|cffffffff %s"
local moreMembersOnlineString = strjoin("", "+ %d ", _G.FRIENDS_LIST_ONLINE, "...")
local noteString = strjoin("", "|cff999999   ", _G.LABEL_NOTE, ":|r %s")
local officerNoteString = strjoin("", "|cff999999   ", _G.GUILD_RANK1_DESC, ":|r %s")
local guildTable, guildMotD, lastPanel = {}, ""

local function sortByRank(a, b)
	if a and b then
		return a[10] < b[10]
	end
end

local function sortByName(a, b)
	if a and b then
		return a[1] < b[1]
	end
end

local function SortGuildTable(shift)
	if shift then
		sort(guildTable, sortByRank)
	else
		sort(guildTable, sortByName)
	end
end

local onlinestatusstring = "|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF]|r"
local onlinestatus = {
	[0] = '',
	[1] = format(onlinestatusstring, L["AFK"]),
	[2] = format(onlinestatusstring, L["DND"]),
}
local mobilestatus = {
	[0] = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t",
	[1] = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t",
	[2] = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t",
}

local function inGroup(name)
	return (UnitInParty(name) or UnitInRaid(name)) and "|cffaaaaaa*|r" or ""
end

local function BuildGuildTable()
	GuildRoster()
	wipe(guildTable)

	local totalMembers = GetNumGuildMembers()
	for i = 1, totalMembers do
		local name, rank, rankIndex, level, _, zone, note, officernote, connected, memberstatus, class, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
		if not name then return end

		local statusInfo = isMobile and mobilestatus[memberstatus] or onlinestatus[memberstatus]
		zone = (isMobile and not connected) and REMOTE_CHAT or zone

		if connected or isMobile then
			guildTable[#guildTable + 1] = { name, rank, level, zone, note, officernote, connected, statusInfo, class, rankIndex, isMobile, guid }
		end
	end
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local resendRequest = false
local eventHandlers = {
	["CHAT_MSG_SYSTEM"] = function(_, arg1)
		if FRIEND_ONLINE ~= nil and arg1 and strfind(arg1, FRIEND_ONLINE) then
			resendRequest = true
		end
	end,-- when we enter the world and guildframe is not available then
	-- load guild frame, update guild message and guild xp
	["PLAYER_ENTERING_WORLD"] = function()
		if not _G.GuildFrame and IsInGuild() then
			LoadAddOn("Blizzard_GuildUI")
		end
	end,
	-- Guild Roster updated, so rebuild the guild table
	["GUILD_ROSTER_UPDATE"] = function(self)
		if(resendRequest) then
			resendRequest = false
			BuildGuildTable()
		else
			BuildGuildTable()
			UpdateGuildMessage()
			if GetMouseFocus() == self then
				self:GetScript("OnEnter")(self, nil, true)
			end
		end
	end,
	["PLAYER_GUILD_UPDATE"] = function()
		BuildGuildTable()
	end,
	-- our guild message of the day changed
	["GUILD_MOTD"] = function (self, arg1)
		guildMotD = arg1
	end
}

local menuList = {
	{ text = _G.OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = _G.INVITE, hasArrow = true, notCheckable=true,},
	{ text = _G.CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true,}
}

local function inviteClick(_, name, guid)
	DT.EasyMenu:Hide()

	if not (name and name ~= "") then return end

	if guid then
		local inviteType = GetDisplayedInviteType(guid)
		if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
			InviteToGroup(name)
		elseif inviteType == "REQUEST_INVITE" then
			RequestInviteFromUnit(name)
		end
	else
		-- if for some reason guid isnt here fallback and just try to invite them
		-- this is unlikely but having a fallback doesnt hurt
		InviteToGroup(name)
	end
end

local function whisperClick(_, playerName)
	DT.EasyMenu:Hide()
	SetItemRef( "player:"..playerName, format("|Hplayer:%1$s|h[%1$s]|h",playerName), "LeftButton" )
end

local function Click(self, btn)
	if btn == "RightButton" and IsInGuild() then
		DT.tooltip:Hide()

		local grouped
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for _, info in ipairs(guildTable) do
			if info[7] and info[1] ~= E.myname then
				local classc, levelc = E:ClassColor(info[9]) or PRIEST_COLOR, GetQuestDifficultyColor(info[3])
				if UnitInParty(info[1]) or UnitInRaid(info[1]) then
					grouped = "|cffaaaaaa*|r"
				elseif not (info[11] and info[4] == REMOTE_CHAT) then
					menuCountInvites = menuCountInvites + 1
					grouped = ""
					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], ""), arg1 = info[1], arg2 = info[12], notCheckable=true, func = inviteClick}
				end
				menuCountWhispers = menuCountWhispers + 1
				if not grouped then grouped = "" end
				menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], grouped), arg1 = info[1], notCheckable=true, func = whisperClick}
			end
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menuList, DT.EasyMenu, nil, nil, nil, "MENU")
	elseif InCombatLockdown() then
		_G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT)
	else
		--Workaround until blizz fixes ToggleGuildFrame correctly
		if IsInGuild() then
			ToggleFriendsFrame(3)
		else
			ToggleGuildFrame()
		end
	end
end

local function OnEnter()
	if not IsInGuild() then return end
	DT.tooltip:ClearLines()

	local shiftDown = IsShiftKeyDown()

	local total, _, online = GetNumGuildMembers()
	if #guildTable == 0 or #guildTable < online then BuildGuildTable() end

	SortGuildTable(shiftDown)

	local guildName, guildRank = GetGuildInfo('player')

	if guildName and guildRank then
		DT.tooltip:AddDoubleLine(format(guildInfoString, guildName), format(guildInfoString2, online, total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
		DT.tooltip:AddLine(guildRank, unpack(tthead))
	end

	if guildMotD ~= "" then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1)
	end

	local zonec, grouped

	DT.tooltip:AddLine(' ')
	for i, info in ipairs(guildTable) do
		-- if more then 30 guild members are online, we don't Show any more, but inform user there are more
		if 30 - i < 1 then
			if online - 30 > 1 then DT.tooltip:AddLine(format(moreMembersOnlineString, online - 30), ttsubh.r, ttsubh.g, ttsubh.b) end
			break
		end

		if E.MapInfo.zoneText and (E.MapInfo.zoneText == info[4]) then zonec = activezone else zonec = inactivezone end

		local classc, levelc = E:ClassColor(info[9]) or PRIEST_COLOR, GetQuestDifficultyColor(info[3])

		if (UnitInParty(info[1]) or UnitInRaid(info[1])) then grouped = 1 else grouped = 2 end

		if shiftDown then
			DT.tooltip:AddDoubleLine(format(nameRankString, info[1], info[2]), info[4], classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
			if info[5] ~= "" then DT.tooltip:AddLine(format(noteString, info[5]), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
			if info[6] ~= "" then DT.tooltip:AddLine(format(officerNoteString, info[6]), ttoff.r, ttoff.g, ttoff.b, 1) end
		else
			DT.tooltip:AddDoubleLine(format(levelNameStatusString, levelc.r*255, levelc.g*255, levelc.b*255, info[3], strsplit("-", info[1]), groupedTable[grouped], info[8]), info[4], classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event, ...)
	lastPanel = self

	if IsInGuild() then
		local func = eventHandlers[event]
		if func then func(self, ...) end

		if not IsAltKeyDown() and event == 'MODIFIER_STATE_CHANGED' and GetMouseFocus() == self then
			OnEnter(self)
		end

		self.text:SetFormattedText(displayString, #guildTable)
	else
		self.text:SetText(noGuildString)
	end
end

local function ValueColorUpdate(hex)
	displayString = E.global.datatexts.settings.Guild.NoLabel and strjoin("", hex, "%d|r") or strjoin("", GUILD, ": ", hex, "%d|r")
	noGuildString = hex..L["No Guild"]

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Guild', _G.SOCIAL_LABEL, {'CHAT_MSG_SYSTEM', 'GUILD_ROSTER_UPDATE', 'PLAYER_GUILD_UPDATE', 'GUILD_MOTD', 'MODIFIER_STATE_CHANGED'}, OnEvent, nil, Click, OnEnter, nil, GUILD, nil, ValueColorUpdate)
