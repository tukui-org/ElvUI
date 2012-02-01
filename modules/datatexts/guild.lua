local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

-- localized references for global functions (about 50% faster)
local join 			= string.join
local format		= string.format
local find			= string.find
local gsub			= string.gsub
local sort			= table.sort
local ceil			= math.ceil

local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = ""
local noGuildString = ""
local guildInfoString = "%s [%d]"
local guildInfoString2 = join("", GUILD, ": %d/%d")
local guildMotDString = "%s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusString = "|cff%02x%02x%02x%d|r %s %s"
local nameRankString = "%s |cff999999-|cffffffff %s"
local guildXpCurrentString = gsub(join("", E:RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b), GUILD_EXPERIENCE_CURRENT), ": ", ":|r |cffffffff", 1)
local guildXpDailyString = gsub(join("", E:RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b), GUILD_EXPERIENCE_DAILY), ": ", ":|r |cffffffff", 1)
local standingString = join("", E:RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b), "%s:|r |cFFFFFFFF%s/%s (%s%%)")
local moreMembersOnlineString = join("", "+ %d ", FRIENDS_LIST_ONLINE, "...")
local noteString = join("", "|cff999999   ", LABEL_NOTE, ":|r %s")
local officerNoteString = join("", "|cff999999   ", GUILD_RANK1_DESC, ":|r %s")
local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS,"\124Hplayer:%%s\124h%[%%s%]\124h",""), gsub(ERR_FRIEND_OFFLINE_S,"%%s","")
local guildTable, guildXP, guildMotD = {}, {}, ""
local lastPanel

local function SortGuildTable(shift)
	sort(guildTable, function(a, b)
		if a and b then
			if shift then
				return a[10] < b[10]
			else
				return a[1] < b[1]
			end
		end
	end)
end

local function BuildGuildTable()
	wipe(guildTable)
	local name, rank, level, zone, note, officernote, connected, status, class
	local count = 0
	for i = 1, GetNumGuildMembers() do
		name, rank, rankIndex, level, _, zone, note, officernote, connected, status, class = GetGuildRosterInfo(i)
		-- we are only interested in online members
		
		if status == 1 then
			status = "|cffFFFFFF[|r|cffFF0000"..L['AFK'].."|r|cffFFFFFF]|r"
		elseif status == 2 then
			status = "|cffFFFFFF[|r|cffFF0000"..L['DND'].."|r|cffFFFFFF]|r"
		else 
			status = '';
		end
		
		if connected then 
			count = count + 1
			guildTable[count] = { name, rank, level, zone, note, officernote, connected, status, class, rankIndex }
		end
	end
	SortGuildTable(IsShiftKeyDown())
end

local function UpdateGuildXP()
	local currentXP, remainingXP, dailyXP, maxDailyXP = UnitGetGuildXP("player")
	local nextLevelXP = currentXP + remainingXP
	local percentTotal
	if currentXP > 0 then
		percentTotal = ceil((currentXP / nextLevelXP) * 100)
	else 
		percentTotal = 0
	end
	
	local percentDaily = 0
	if maxDailyXP > 0 then
		percentDaily = ceil((dailyXP / maxDailyXP) * 100)
	end
	
	guildXP[0] = { currentXP, nextLevelXP, percentTotal }
	guildXP[1] = { dailyXP, maxDailyXP, percentDaily }
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local function OnEvent(self, event, ...)
	lastPanel = self
	
	if IsInGuild() then
		-- special handler to request guild roster updates when guild members come online or go
		-- offline, since this does not automatically trigger the GuildRoster update from the server
		if event == "CHAT_MSG_SYSTEM" then
			local message = select(1, ...)
			if find(message, friendOnline) or find(message, friendOffline) then GuildRoster() end
		end
		-- our guild xp changed, recalculate it
		if event == "GUILD_XP_UPDATE" then UpdateGuildXP() return end
		-- our guild message of the day changed
		if event == "GUILD_MOTD" then UpdateGuildMessage() return end
		-- when we enter the world and guildframe is not available then
		-- load guild frame, update guild message and guild xp
		
		if event == "PLAYER_ENTERING_WORLD" then
			if not GuildFrame and IsInGuild() then LoadAddOn("Blizzard_GuildUI") UpdateGuildMessage() UpdateGuildXP() end
		end
		-- an event occured that could change the guild roster, so request update, and wait for guild roster update to occur
		if (event ~= "GUILD_ROSTER_UPDATE" and event~="PLAYER_GUILD_UPDATE") or event == 'ELVUI_FORCE_RUN' then GuildRoster()  if event ~= 'ELVUI_FORCE_RUN' then return end end

		local _, online = GetNumGuildMembers()
		
		self.text:SetFormattedText(displayString, online)
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

local function inviteClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	InviteUnit(arg1)
end

local function whisperClick(self,arg1,arg2,checked)
	menuFrame:Hide()
	SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )
end

local function ToggleGuildFrame()
	if IsInGuild() then
		if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
		GuildFrame_Toggle()
		GuildFrame_TabClicked(GuildFrameTab2)
	else
		if not LookingForGuildFrame then LoadAddOn("Blizzard_LookingForGuildUI") end
		if LookingForGuildFrame then LookingForGuildFrame_Toggle() end
	end
end

local function Click(self, btn)
	if btn == "RightButton" and IsInGuild() then
		GameTooltip:Hide()

		local classc, levelc, grouped, info
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for i = 1, #guildTable do
			info = guildTable[i]
			if info[7] and info[1] ~= E.myname then
				local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]], GetQuestDifficultyColor(info[3])

				if UnitInParty(info[1]) or UnitInRaid(info[1]) then
					grouped = "|cffaaaaaa*|r"
				else
					menuCountInvites = menuCountInvites +1
					grouped = ""
					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], ""), arg1 = info[1],notCheckable=true, func = inviteClick}
				end
				menuCountWhispers = menuCountWhispers + 1
				menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], grouped), arg1 = info[1],notCheckable=true, func = whisperClick}
			end
		end

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)	
	else
		ToggleGuildFrame()
	end
end

local function OnEnter(self)
	if not IsInGuild() then return end
	
	DT:SetupTooltip(self)
	
	local total, online = GetNumGuildMembers()
	GuildRoster()
	BuildGuildTable()

	local guildName, guildRank = GetGuildInfo('player')
	local guildLevel = GetGuildLevel()
	
	if guildName and guildRank and guildLevel then
		GameTooltip:AddDoubleLine(format(guildInfoString, guildName, guildLevel), format(guildInfoString2, online, total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
		GameTooltip:AddLine(guildRank, unpack(tthead))
	end
	
	if guildMotD ~= "" then 
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1) 
	end
	
	local col = E:RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b)
	if GetGuildLevel() ~= 25 then
		if guildXP[0] and guildXP[1] then
			local currentXP, nextLevelXP, percentTotal = unpack(guildXP[0])
			local dailyXP, maxDailyXP, percentDaily = unpack(guildXP[1])
			
			GameTooltip:AddLine(' ')
			GameTooltip:AddLine(format(guildXpCurrentString, E:ShortValue(currentXP), E:ShortValue(nextLevelXP), percentTotal))
			GameTooltip:AddLine(format(guildXpDailyString, E:ShortValue(dailyXP), E:ShortValue(maxDailyXP), percentDaily))
		end
	end
	
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	if standingID ~= 8 then -- Not Max Rep
		barMax = barMax - barMin
		barValue = barValue - barMin
		barMin = 0
		GameTooltip:AddLine(format(standingString, COMBAT_FACTION_CHANGE, E:ShortValue(barValue), E:ShortValue(barMax), ceil((barValue / barMax) * 100)))
	end
	
	local zonec, classc, levelc, info
	local shown = 0
	
	GameTooltip:AddLine(' ')
	for i = 1, #guildTable do
		-- if more then 30 guild members are online, we don't Show any more, but inform user there are more
		if 30 - shown <= 1 then
			if online - 30 > 1 then GameTooltip:AddLine(format(moreMembersOnlineString, online - 30), ttsubh.r, ttsubh.g, ttsubh.b) end
			break
		end

		info = guildTable[i]
		if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
		classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]], GetQuestDifficultyColor(info[3])
		
		if IsShiftKeyDown() then
			GameTooltip:AddDoubleLine(format(nameRankString, info[1], info[2]), info[4], classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
			if info[5] ~= "" then GameTooltip:AddLine(format(noteString, info[5]), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
			if info[6] ~= "" then GameTooltip:AddLine(format(officerNoteString, info[6]), ttoff.r, ttoff.g, ttoff.b, 1) end
		else
			GameTooltip:AddDoubleLine(format(levelNameStatusString, levelc.r*255, levelc.g*255, levelc.b*255, info[3], info[1], info[8]), info[4], classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
		end
		shown = shown + 1
	end	
	
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", GUILD, ": ", hex, "%d|r")
	noGuildString = join("", hex, NO..' '..GUILD)
	
	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]

DT:RegisterDatatext('Guild', {'PLAYER_ENTERING_WORLD', "GUILD_ROSTER_SHOW", "GUILD_ROSTER_UPDATE", "GUILD_XP_UPDATE", "PLAYER_GUILD_UPDATE", "GUILD_MOTD", "CHAT_MSG_SYSTEM"}, OnEvent, nil, Click, OnEnter)

