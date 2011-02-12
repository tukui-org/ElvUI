--------------------------------------------------------------------
-- GUILD ROSTER
--------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].guild or C["datatext"].guild == 0 then return end

local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = string.join("", "%s: ", E.ValColor, "%d|r")
local guildInfoString = "%s [%d]"
local guildInfoString2 = "%s: %d/%d"
local guildMotDString = "  %s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusString = "|cff%02x%02x%02x%d|r %s %s"
local nameRankString = "%s |cff999999-|cffffffff %s"
local noteString = "  '%s'"
local officerNoteString = "  o: '%s'"

local guildTable, guildXP, guildMotD = {}, {}, ""
local totalOnline = 0

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)
Stat.update = false

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
Text:SetShadowColor(0, 0, 0, 0.4)
E.PP(C["datatext"].guild, Text)

local function BuildGuildTable(total)
	totalOnline = 0
	wipe(guildTable)
	local name, rank, level, zone, note, officernote, connected, status, class
	for i = 1, total do
		name, rank, _, level, _, zone, note, officernote, connected, status, class = GetGuildRosterInfo(i)
		guildTable[i] = { name, rank, level, zone, note, officernote, connected, status, class }
		if connected then totalOnline = totalOnline + 1 end
	end
	table.sort(guildTable, function(a, b)
		if a and b then
			return a[1] < b[1]
		end
	end)
end

local function GetGuildMemberIndex(name)
	for k,v in ipairs(guildTable) do
		if v[1] == name then return k end
	end
	return -1
end

local function UpdateGuildTable(total)
	totalOnline = 0
	local index, name, rank, level, zone, note, officernote, connected, status
	for i = 1, #guildTable do
		-- get guild roster information
		name, rank, _, level, _, zone, note, officernote, connected, status = GetGuildRosterInfo(i)
		-- get the correct index in our table		
		index = GetGuildMemberIndex(name)
		-- we cannot find a guild member in our table, so rebuild it
		if index == -1 then
			BuildGuildTable(total)
			break
		end
		-- update on-line status for all members
		guildTable[index][7] = connected
		-- update information only for on-line members
		if connected then
			guildTable[index][2] = rank
			guildTable[index][3] = level
			guildTable[index][4] = zone
			guildTable[index][5] = note
			guildTable[index][6] = officernote
			guildTable[index][8] = status
			totalOnline = totalOnline + 1
		end
	end
end

local function UpdateGuildXP()
	local currentXP, remainingXP, dailyXP, maxDailyXP = UnitGetGuildXP("player")
	local nextLevelXP = currentXP + remainingXP
	local percentTotal = tostring(math.ceil((currentXP / nextLevelXP) * 100))
	local percentDaily = tostring(math.ceil((dailyXP / maxDailyXP) * 100))
	
	guildXP[0] = { currentXP, nextLevelXP, percentTotal }
	guildXP[1] = { dailyXP, maxDailyXP, percentDaily }
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local function Update(self, event, ...)	
	if not GuildFrame then LoadAddOn("Blizzard_GuildUI") UpdateGuildXP() end
	-- our guild xp changed, recalculate it
	if event == "GUILD_XP_UPDATE" then UpdateGuildXP() end
	-- our guild message of the day changed
	if event == "GUILD_MOTD" or event == "PLAYER_ENTERING_WORLD" then UpdateGuildMessage() end
	-- an event occured that could change the guild roster, so request update
	if event ~= "GUILD_ROSTER_UPDATE" then GuildRoster() end
		
	-- received an updated event, but we are already updating the table
	if self.update == true then return end

	-- lock to prevent multiple updates simultaniously
	self.update = true
	if IsInGuild() then
		local total = (GetNumGuildMembers())
		
		if total == #guildTable then
			UpdateGuildTable(total)
		else
			BuildGuildTable(total)
		end
		
		self:SetAllPoints(Text)
		Text:SetFormattedText(displayString, L.datatext_guild, totalOnline)
		
		if not Stat:GetScript("OnMouseDown") then
			Stat:SetScript("OnMouseDown", function(self, btn)
				if btn ~= "LeftButton" then return end
				ToggleGuildFrame()
			end)
		end
	else
		Text:SetText(E.ValColor..L.datatext_noguild)
		Stat:SetScript("OnMouseDown", nil)
	end
	self.update = false
end
	
local menuFrame = CreateFrame("Frame", "ElvuiGuildRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true,notCheckable=true},
	{ text = INVITE, hasArrow = true,notCheckable=true,},
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true,notCheckable=true,}
}

local function inviteClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	InviteUnit(arg1)
end

local function whisperClick(self,arg1,arg2,checked)
	menuFrame:Hide()
	SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )
end

local function ToggleGuildFrame()
	if not GuildFrame and IsInGuild() then LoadAddOn("Blizzard_GuildUI") end
	GuildFrame_Toggle() 
	GuildFrame_TabClicked(GuildFrameTab2)
end

Stat:SetScript("OnMouseUp", function(self, btn)
	if btn ~= "RightButton" then return end
	
	GameTooltip:Hide()

	local classc, levelc, grouped
	local menuCountWhispers = 0
	local menuCountInvites = 0

	menuList[2].menuList = {}
	menuList[3].menuList = {}

	for i = 1, #guildTable do
		if guildTable[i][7] and guildTable[i][1] ~= E.myname then
			local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[guildTable[i][9]], GetQuestDifficultyColor(guildTable[i][3])

			if UnitInParty(guildTable[i][1]) or UnitInRaid(guildTable[i][1]) then
				grouped = "|cffaaaaaa*|r"
			else
				menuCountInvites = menuCountInvites +1
				grouped = ""
				menuList[2].menuList[menuCountInvites] = {text = string.format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, guildTable[i][3], classc.r*255,classc.g*255,classc.b*255, guildTable[i][1], ""), arg1 = guildTable[i][1],notCheckable=true, func = inviteClick}
			end
			menuCountWhispers = menuCountWhispers + 1
			menuList[3].menuList[menuCountWhispers] = {text = string.format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, guildTable[i][3], classc.r*255,classc.g*255,classc.b*255, guildTable[i][1], grouped), arg1 = guildTable[i][1],notCheckable=true, func = whisperClick}
		end
	end

	EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
end)

Stat:SetScript("OnEnter", function(self)
	if InCombatLockdown() or not IsInGuild() then return end
		
	local name, rank, level, zone, note, officernote, connected, status, class
	local zonec, classc, levelc
	local online = totalOnline
		
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(string.format(guildInfoString, GetGuildInfo('player'), GetGuildLevel()), string.format(guildInfoString2, L.datatext_guild, online, #guildTable),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	GameTooltip:AddLine(' ')
	
	if guildMotD ~= "" then GameTooltip:AddLine(string.format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
	
	local col = E.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b)
	GameTooltip:AddLine' '
	if GetGuildLevel() ~= 25 then
		local currentXP, nextLevelXP, percentTotal = unpack(guildXP[0])
		local dailyXP, maxDailyXP, percentDaily = unpack(guildXP[1])
		GameTooltip:AddLine(string.format(col..GUILD_EXPERIENCE_CURRENT, "|r |cFFFFFFFF"..E.ShortValue(currentXP), E.ShortValue(nextLevelXP), percentTotal))
		GameTooltip:AddLine(string.format(col..GUILD_EXPERIENCE_DAILY, "|r |cFFFFFFFF"..E.ShortValue(dailyXP), E.ShortValue(maxDailyXP), percentDaily))
	end
	
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	if standingID ~= 4 then -- Not Max Rep
		barMax = barMax - barMin
		barValue = barValue - barMin
		barMin = 0
		GameTooltip:AddLine(string.format("%s:|r |cFFFFFFFF%s/%s (%s%%)",col..COMBAT_FACTION_CHANGE, E.ShortValue(barValue), E.ShortValue(barMax), math.ceil((barValue / barMax) * 100)))
	end
	
	if online > 1 then
		GameTooltip:AddLine(' ')
		for i = 1, #guildTable do
			if online <= 1 then
				if online > 1 then GameTooltip:AddLine(format("+ %d More...", online - modules.Guild.maxguild),ttsubh.r,ttsubh.g,ttsubh.b) end
				break
			end

			name, rank, level, zone, note, officernote, connected, status, class = unpack(guildTable[i])
			if connected and name ~= E.myname then
				if GetRealZoneText() == zone then zonec = activezone else zonec = inactivezone end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
				
				if IsShiftKeyDown() then
					GameTooltip:AddDoubleLine(string.format(nameRankString, name, rank), zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
					if note ~= "" then GameTooltip:AddLine(string.format(noteString, note), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
					if officernote ~= "" then GameTooltip:AddLine(string.format(officerNoteString, officernote), ttoff.r, ttoff.g, ttoff.b ,1) end
				else
					GameTooltip:AddDoubleLine(string.format(levelNameStatusString, levelc.r*255, levelc.g*255, levelc.b*255, level, name, status), zone, classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
				end
			end
		end
	end
	GameTooltip:Show()
end)

Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)

Stat:RegisterEvent("GUILD_ROSTER_SHOW")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
Stat:RegisterEvent("GUILD_XP_UPDATE")
Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
Stat:RegisterEvent("GUILD_MOTD")
Stat:SetScript("OnEvent", Update)
UpdateGuildMessage()