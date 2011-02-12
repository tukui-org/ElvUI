--------------------------------------------------------------------
-- FRIEND
--------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].friends or C["datatext"].friends == 0 then return end

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowColor(0, 0, 0, 0.4)
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].friends, Text)

local menuFrame = CreateFrame("Frame", "ElvuiFriendRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true,notCheckable=true},
	{ text = INVITE, hasArrow = true,notCheckable=true, },
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true,notCheckable=true, }
}

local function GetTableIndex(table, fieldIndex, value)
	for k,v in ipairs(table) do
		if v[fieldIndex] == value then return k end
	end
	return -1
end

local function inviteClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	InviteUnit(arg1)
end

local function whisperClick(self,arg1,arg2,checked)
	menuFrame:Hide() 
	SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )		 
end

local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local clientLevelNameString = "%s |cff%02x%02x%02x(%d|r |cff%02x%02x%02x%s|r%s) |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"
local worldOfWarcraftString = "World of Warcraft"
local battleNetString = "Battle.NET"
local wowString = "WoW"
local totalOnlineString = L.datatext_online .. "%s/%s"
local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = string.join("", "%s: ", E.ValColor, "%d|r")
local statusTable = { L.chat_FLAG_AFK, L.chat_FLAG_DND, "" }
local groupedTable = { "|cffaaaaaa*|r", "" } 
local friendTable, BNTable = {}, {}
local totalOnline, BNTotalOnline = 0, 0

local function BuildFriendTable(total)
	totalOnline = 0
	wipe(friendTable)
	local name, level, class, area, connected, status, note
	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i)
		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
		
		friendTable[i] = { name, level, class, area, connected, status, note }
		if connected then totalOnline = totalOnline + 1 end
	end
	table.sort(friendTable, function(a, b)
		if a[1] and b[1] then
			return a[1] < b[1]
		end
	end)
end

local function UpdateFriendTable(total)
	totalOnline = 0
	local name, level, class, area, connected, status, note
	for i = 1, #friendTable do
		name, level, class, area, connected, status, note = GetFriendInfo(i)
		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
		
		-- get the correct index in our table		
		index = GetTableIndex(friendTable, 1, name)
		-- we cannot find a friend in our table, so rebuild it
		if index == -1 then
			BuildFriendTable(total)
			break
		end
		-- update on-line status for all members
		friendTable[index][5] = connected
		-- update information only for on-line members
		if connected then
			friendTable[index][2] = level
			friendTable[index][3] = class
			friendTable[index][4] = area
			friendTable[index][6] = status
			friendTable[index][7] = note
			totalOnline = totalOnline + 1
		end
	end
end

local function BuildBNTable(total)
	BNTotalOnline = 0
	wipe(BNTable)
	local presenceID, givenName, surname, toonName, toonID, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level
	for i = 1, total do
		presenceID, givenName, surname, toonName, toonID, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)
		_, _, _, realmName, faction, race, class, _, zoneName, level = BNGetToonInfo(presenceID)
		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
		
		BNTable[i] = { presenceID, givenName, surname, toonName, toonID, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level }
		if isOnline then BNTotalOnline = BNTotalOnline + 1 end
	end
	table.sort(BNTable, function(a, b)
		if a[2] and b[2] then
			if a[2] == b[2] then return a[3] < b[3] end
			return a[2] < b[2]
		end
	end)
end

local function UpdateBNTable(total)
	BNTotalOnline = 0
	local presenceID, givenName, surname, toonName, toonID, client, isOnline, isAFK, isDND, noteText
	local realmName, faction, race, class, zoneName, level
	for i = 1, #BNTable do
		-- get guild roster information
		presenceID, givenName, surname, toonName, toonID, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)
		_, _, _, realmName, faction, race, class, _, zoneName, level = BNGetToonInfo(presenceID)
		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
		
		-- get the correct index in our table		
		index = GetTableIndex(BNTable, 1, presenceID)
		-- we cannot find a BN member in our table, so rebuild it
		if index == -1 then
			BuildBNTable(total)
			return
		end
		-- update on-line status for all members
		BNTable[index][7] = isOnline
		-- update information only for on-line members
		if isOnline then
			BNTable[index][2] = givenName
			BNTable[index][3] = surname
			BNTable[index][4] = toonName
			BNTable[index][5] = toonID
			BNTable[index][6] = client
			BNTable[index][8] = isAFK
			BNTable[index][9] = isDND
			BNTable[index][10] = noteText
			BNTable[index][11] = realmName
			BNTable[index][12] = faction
			BNTable[index][13] = race
			BNTable[index][14] = class
			BNTable[index][15] = zoneName
			BNTable[index][16] = level
			
			BNTotalOnline = BNTotalOnline + 1
		end
	end
end

Stat:SetScript("OnMouseUp", function(self, btn)
	if btn ~= "RightButton" then return end
	
	GameTooltip:Hide()
	
	local menuCountWhispers = 0
	local menuCountInvites = 0
	local classc, levelc
	
	menuList[2].menuList = {}
	menuList[3].menuList = {}
	
	if totalOnline > 0 then
		for i = 1, #friendTable do
			if (friendTable[i][5]) then
				menuCountInvites = menuCountInvites + 1
				menuCountWhispers = menuCountWhispers + 1

				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[friendTable[i][3]], GetQuestDifficultyColor(friendTable[i][2])
				if classc == nil then classc = GetQuestDifficultyColor(friendTable[i][2]) end

				menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,friendTable[i][2],classc.r*255,classc.g*255,classc.b*255,friendTable[i][1]), arg1 = friendTable[i][1],notCheckable=true, func = inviteClick}
				menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,friendTable[i][2],classc.r*255,classc.g*255,classc.b*255,friendTable[i][1]), arg1 = friendTable[i][1],notCheckable=true, func = whisperClick}
			end
		end
	end
	
	if BNTotalOnline > 0 then
		local realID, playerFaction, grouped
		for i = 1, #BNTable do
			if (BNTable[i][7]) then
				realID = (BATTLENET_NAME_FORMAT):format(BNTable[i][2], BNTable[i][3])
				menuCountWhispers = menuCountWhispers + 1
				menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID,notCheckable=true, func = whisperClick}

				if select(1, UnitFactionGroup("player")) == "Horde" then playerFaction = 0 else playerFaction = 1 end
				if BNTable[i][6] == wowString and BNTable[i][11] == E.myrealm and playerFaction == BNTable[i][12] then
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[BNTable[i][14]], GetQuestDifficultyColor(BNTable[i][16])
					if classc == nil then classc = GetQuestDifficultyColor(BNTable[i][16]) end

					if UnitInParty(BNTable[i][4]) or UnitInRaid(BNTable[i][4]) then grouped = 1 else grouped = 2 end
					menuCountInvites = menuCountInvites + 1
					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,BNTable[i][16],classc.r*255,classc.g*255,classc.b*255,BNTable[i][4]), arg1 = BNTable[i][4],notCheckable=true, func = inviteClick}
				end
			end
		end
	end

	EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
end)

local function Update(self, event)
	if event == "BN_FRIEND_INFO_CHANGED" or "BN_FRIEND_ACCOUNT_ONLINE" or "BN_FRIEND_ACCOUNT_OFFLINE" or "BN_TOON_NAME_UPDATED"
			or "BN_FRIEND_TOON_ONLINE" or "BN_FRIEND_TOON_OFFLINE" or "PLAYER_ENTERING_WORLD" then
		local BNTotal = BNGetNumFriends()
		if BNTotal == #BNTable then
			UpdateBNTable(BNTotal)
		else
			BuildBNTable(BNTotal)
		end
	end
	
	if event == "FRIENDLIST_UPDATE" or "PLAYER_ENTERING_WORLD" then
		local total = GetNumFriends()
		if total == #friendTable then
			UpdateFriendTable(total)
		else
			BuildFriendTable(total)
		end
	end

	Text:SetFormattedText(displayString, L.datatext_friends, totalOnline + BNTotalOnline)
	self:SetAllPoints(Text)
end

Stat:SetScript("OnMouseDown", function(self, btn) if btn == "LeftButton" then ToggleFriendsFrame(1) end end)
Stat:SetScript("OnEnter", function(self)
	if InCombatLockdown() then return end
		
	local totalonline = totalOnline + BNTotalOnline
	local totalfriends = #friendTable + #BNTable
	local zonec, classc, levelc, realmc, grouped
	if totalonline > 0 then
		local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
		GameTooltip:SetOwner(panel, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L.datatext_friendlist, format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
		if totalOnline > 0 then
			GameTooltip:AddLine(' ')
			GameTooltip:AddLine(worldOfWarcraftString)
			for i = 1, #friendTable do
				if friendTable[i][5] then
					if GetRealZoneText() == friendTable[i][4] then zonec = activezone else zonec = inactivezone end
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[friendTable[i][3]], GetQuestDifficultyColor(friendTable[i][2])
					if classc == nil then classc = GetQuestDifficultyColor(friendTable[i][2]) end
					
					if UnitInParty(friendTable[i][1]) or UnitInRaid(friendTable[i][1]) then grouped = 1 else grouped = 2 end
					GameTooltip:AddDoubleLine(format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,friendTable[i][2],friendTable[i][1],groupedTable[grouped]," "..friendTable[i][6]),friendTable[i][4],classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
				end
			end
		end
		if BNTotalOnline > 0 then
			GameTooltip:AddLine(' ')
			GameTooltip:AddLine(battleNetString)

			local status = 0
			for i = 1, #BNTable do
				if BNTable[i][7] then
					if BNTable[i][6] == wowString then
						if (BNTable[i][8] == true) then status = 1 elseif (BNTable[i][9] == true) then status = 2 else status = 3 end
	
						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[BNTable[i][14]], GetQuestDifficultyColor(BNTable[i][16])
						if classc == nil then classc = GetQuestDifficultyColor(BNTable[i][16]) end
						
						if UnitInParty(BNTable[i][4]) or UnitInRaid(BNTable[i][4]) then grouped = 1 else grouped = 2 end
						GameTooltip:AddDoubleLine(format(clientLevelNameString, BNTable[i][6],levelc.r*255,levelc.g*255,levelc.b*255,BNTable[i][16],classc.r*255,classc.g*255,classc.b*255,BNTable[i][4],groupedTable[grouped], 255, 0, 0, statusTable[status]),BNTable[i][2].." "..BNTable[i][3],238,238,238,238,238,238)
						if IsShiftKeyDown() then
							if GetRealZoneText() == BNTable[i][15] then zonec = activezone else zonec = inactivezone end
							if GetRealmName() == BNTable[i][11] then realmc = activezone else realmc = inactivezone end
							GameTooltip:AddDoubleLine("  "..BNTable[i][15], BNTable[i][11], zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
						end
					else
						GameTooltip:AddDoubleLine("|cffeeeeee"..BNTable[i][6].." ("..BNTable[i][4]..")|r", "|cffeeeeee"..BNTable[i][2].." "..BNTable[i][3].."|r")
					end
				end
			end
		end
		GameTooltip:Show()
	else 
		GameTooltip:Hide() 
	end
end)

Stat:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
Stat:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
Stat:RegisterEvent("BN_FRIEND_TOON_ONLINE")
Stat:RegisterEvent("BN_FRIEND_TOON_OFFLINE")
Stat:RegisterEvent("BN_TOON_NAME_UPDATED")
Stat:RegisterEvent("FRIENDLIST_UPDATE")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")

Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
Stat:SetScript("OnEvent", Update)