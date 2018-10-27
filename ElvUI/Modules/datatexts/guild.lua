local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local select, unpack, sort, wipe, ceil = select, unpack, table.sort, wipe, math.ceil
local format, find, join, split = string.format, string.find, string.join, string.split
--WoW API / Variables
local GetDisplayedInviteType = GetDisplayedInviteType
local GetGuildFactionInfo = GetGuildFactionInfo
local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetMouseFocus = GetMouseFocus
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GuildRoster = GuildRoster
local InviteToGroup = InviteToGroup
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local LoadAddOn = LoadAddOn
local RequestInviteFromUnit = RequestInviteFromUnit
local SetItemRef = SetItemRef
local ToggleGuildFrame = ToggleGuildFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local COMBAT_FACTION_CHANGE = COMBAT_FACTION_CHANGE
local GUILD = GUILD
local GUILD_MOTD = GUILD_MOTD
local REMOTE_CHAT = REMOTE_CHAT

local EasyMenu = EasyMenu

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GuildFrame, LookingForGuildFrame, GuildFrame_LoadUI, LookingForGuildFrame_LoadUI
-- GLOBALS: CUSTOM_CLASS_COLORS

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
local standingString = E:RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b).."%s:|r |cFFFFFFFF%s/%s (%s%%)"
local moreMembersOnlineString = join("", "+ %d ", FRIENDS_LIST_ONLINE, "...")
local noteString = join("", "|cff999999   ", LABEL_NOTE, ":|r %s")
local officerNoteString = join("", "|cff999999   ", GUILD_RANK1_DESC, ":|r %s")
local guildTable, guildMotD = {}, ""
local lastPanel

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

local function BuildGuildTable()
	wipe(guildTable)
	local statusInfo
	local _, name, rank, rankIndex, level, zone, note, officernote, connected, memberstatus, class, isMobile, guid

	local totalMembers = GetNumGuildMembers()
	for i = 1, totalMembers do
		name, rank, rankIndex, level, _, zone, note, officernote, connected, memberstatus, class, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
		if not name then return end

		statusInfo = isMobile and mobilestatus[memberstatus] or onlinestatus[memberstatus]
		zone = (isMobile and not connected) and REMOTE_CHAT or zone

		if connected or isMobile then
			guildTable[#guildTable + 1] = { name, rank, level, zone, note, officernote, connected, statusInfo, class, rankIndex, isMobile, guid }
		end
	end
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local FRIEND_ONLINE = select(2, split(" ", ERR_FRIEND_ONLINE_SS, 2))
local resendRequest = false
local eventHandlers = {
	['CHAT_MSG_SYSTEM'] = function(self, arg1)
		if(FRIEND_ONLINE ~= nil and arg1 and find(arg1, FRIEND_ONLINE)) then
			resendRequest = true
		end
	end,
	-- when we enter the world and guildframe is not available then
	-- load guild frame, update guild message and guild xp
	["PLAYER_ENTERING_WORLD"] = function()
		if not GuildFrame and IsInGuild() then
			LoadAddOn("Blizzard_GuildUI")
			GuildRoster()
		end
	end,
	-- Guild Roster updated, so rebuild the guild table
	["GUILD_ROSTER_UPDATE"] = function(self)
		if(resendRequest) then
			resendRequest = false;
			return GuildRoster()
		else
			BuildGuildTable()
			UpdateGuildMessage()
			if GetMouseFocus() == self then
				self:GetScript("OnEnter")(self, nil, true)
			end
		end
	end,
	["PLAYER_GUILD_UPDATE"] = GuildRoster,
	-- our guild message of the day changed
	["GUILD_MOTD"] = function (self, arg1)
		guildMotD = arg1
	end,
	["ELVUI_FORCE_RUN"] = E.noop,
	["ELVUI_COLOR_UPDATE"] = E.noop,
}

local function OnEvent(self, event, ...)
	lastPanel = self

	if IsInGuild() then
		eventHandlers[event](self, ...)

		self.text:SetFormattedText(displayString, #guildTable)
	else
		self.text:SetText(noGuildString)
	end
end

local menuFrame = CreateFrame("Frame", "GuildDatatTextRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = INVITE, hasArrow = true, notCheckable=true,},
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true,}
}

local function inviteClick(self, name, guid)
	menuFrame:Hide()

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

local function whisperClick(self, playerName)
	menuFrame:Hide()
	SetItemRef( "player:"..playerName, format("|Hplayer:%1$s|h[%1$s]|h",playerName), "LeftButton" )
end

local function Click(self, btn)
	if btn == "RightButton" and IsInGuild() then
		DT.tooltip:Hide()

		local classc, levelc, grouped, info
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for i = 1, #guildTable do
			info = guildTable[i]
			if info[7] and info[1] ~= E.myname then
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]], GetQuestDifficultyColor(info[3])
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

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		ToggleGuildFrame()
	end
end

local function OnEnter(self, _, noUpdate)
	if not IsInGuild() then return end

	DT:SetupTooltip(self)

	local total, _, online = GetNumGuildMembers()
	if #guildTable == 0 then BuildGuildTable() end

	SortGuildTable(IsShiftKeyDown())

	local guildName, guildRank = GetGuildInfo('player')

	if guildName and guildRank then
		DT.tooltip:AddDoubleLine(format(guildInfoString, guildName), format(guildInfoString2, online, total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
		DT.tooltip:AddLine(guildRank, unpack(tthead))
	end

	if guildMotD ~= "" then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1)
	end

	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	if standingID ~= 8 then -- Not Max Rep
		barMax = barMax - barMin
		barValue = barValue - barMin
		DT.tooltip:AddLine(format(standingString, COMBAT_FACTION_CHANGE, E:ShortValue(barValue), E:ShortValue(barMax), ceil((barValue / barMax) * 100)))
	end

	local zonec, classc, levelc, info, grouped
	local shown = 0

	DT.tooltip:AddLine(' ')
	for i = 1, #guildTable do
		-- if more then 30 guild members are online, we don't Show any more, but inform user there are more
		if 30 - shown <= 1 then
			if online - 30 > 1 then DT.tooltip:AddLine(format(moreMembersOnlineString, online - 30), ttsubh.r, ttsubh.g, ttsubh.b) end
			break
		end

		info = guildTable[i]

		if E.MapInfo.zoneText and (E.MapInfo.zoneText == info[4]) then zonec = activezone else zonec = inactivezone end

		classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]], GetQuestDifficultyColor(info[3])

		if (UnitInParty(info[1]) or UnitInRaid(info[1])) then grouped = 1 else grouped = 2 end

		if IsShiftKeyDown() then
			DT.tooltip:AddDoubleLine(format(nameRankString, info[1], info[2]), info[4], classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
			if info[5] ~= "" then DT.tooltip:AddLine(format(noteString, info[5]), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
			if info[6] ~= "" then DT.tooltip:AddLine(format(officerNoteString, info[6]), ttoff.r, ttoff.g, ttoff.b, 1) end
		else
			DT.tooltip:AddDoubleLine(format(levelNameStatusString, levelc.r*255, levelc.g*255, levelc.b*255, info[3], split("-", info[1]), groupedTable[grouped], info[8]), info[4], classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
		end
		shown = shown + 1
	end

	DT.tooltip:Show()

	if not noUpdate then
		GuildRoster()
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", GUILD, ": ", hex, "%d|r")
	noGuildString = hex..L["No Guild"]

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Guild', {'PLAYER_ENTERING_WORLD', 'CHAT_MSG_SYSTEM', "GUILD_ROSTER_UPDATE", "PLAYER_GUILD_UPDATE", "GUILD_MOTD"}, OnEvent, nil, Click, OnEnter, nil, GUILD)
