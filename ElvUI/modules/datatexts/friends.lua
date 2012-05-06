local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

-- create a popup
StaticPopupDialogs.SET_BN_BROADCAST = {
	text = BN_BROADCAST_TOOLTIP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
	OnShow = function(self) self.editBox:SetText(select(3, BNGetInfo()) ) self.editBox:SetFocus() end,
	OnHide = ChatEdit_FocusActiveWindow,
	EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3
}

-- localized references for global functions (about 50% faster)
local join 			= string.join
local find			= string.find
local format		= string.format
local sort			= table.sort

local menuFrame = CreateFrame("Frame", "FriendDatatextRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true,notCheckable=true},
	{ text = INVITE, hasArrow = true,notCheckable=true, },
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true,notCheckable=true, },
	{ text = PLAYER_STATUS, hasArrow = true, notCheckable=true,
		menuList = {
			{ text = "|cff2BC226"..AVAILABLE.."|r", notCheckable=true, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffE7E716"..DND.."|r", notCheckable=true, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffFF0000"..AFK.."|r", notCheckable=true, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end },
		},
	},
	{ text = BN_BROADCAST_TOOLTIP, notCheckable=true, func = function() StaticPopup_Show("SET_BN_BROADCAST") end },
}

local function inviteClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	
	if type(arg1) ~= 'number' then
		InviteUnit(arg1)
	else
		BNInviteFriend(arg1);
	end
end

local function whisperClick(self,arg1,arg2,checked)
	menuFrame:Hide() 
	SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )		 
end

local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local clientLevelNameString = "%s |cff%02x%02x%02x(%d|r |cff%02x%02x%02x%s|r%s) |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"
local worldOfWarcraftString = WORLD_OF_WARCRAFT
local battleNetString = BATTLENET_OPTIONS_LABEL
local wowString = BNET_CLIENT_WOW
local otherGameInfoString = "%s (%s)"
local otherGameInfoString2 = "%s %s"
local totalOnlineString = join("", FRIENDS_LIST_ONLINE, ": %s/%s")
local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = ''
local statusTable = { "|cffFFFFFF[|r|cffFF0000"..L['AFK'].."|r|cffFFFFFF]|r", "|cffFFFFFF[|r|cffFF0000"..L['DND'].."|r|cffFFFFFF]|r", "" }
local groupedTable = { "|cffaaaaaa*|r", "" } 
local friendTable, BNTable = {}, {}
local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS,"\124Hplayer:%%s\124h%[%%s%]\124h",""), gsub(ERR_FRIEND_OFFLINE_S,"%%s","")
local dataValid = false
local lastPanel

local function BuildFriendTable(total)
	wipe(friendTable)
	local name, level, class, area, connected, status, note
	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i)

		if status == "<"..AFK..">" then
			status = "|cffFFFFFF[|r|cffFF0000"..L['AFK'].."|r|cffFFFFFF]|r"
		elseif status == "<"..DND..">" then
			status = "|cffFFFFFF[|r|cffFF0000"..L['DND'].."|r|cffFFFFFF]|r"
		end
		
		if connected then 
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
			friendTable[i] = { name, level, class, area, connected, status, note }
		end
	end
	sort(friendTable, function(a, b)
		if a[1] and b[1] then
			return a[1] < b[1]
		end
	end)
end

local function BuildBNTable(total)
	wipe(BNTable)
	local presenceID, givenName, surname, toonName, toonID, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level
	for i = 1, total do
		presenceID, givenName, surname, toonName, toonID, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)

		if isOnline then 
			_, _, _, realmName, _, faction, race, class, _, zoneName, level = BNGetToonInfo(presenceID)
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			BNTable[i] = { presenceID, givenName, surname, toonName, toonID, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level }
		end
	end
	sort(BNTable, function(a, b)
		if a[2] and b[2] then
			if a[2] == b[2] then return a[3] < b[3] end
			return a[2] < b[2]
		end
	end)
end

local function OnEvent(self, event, ...)
	local _, onlineFriends = GetNumFriends()
	local _, numBNetOnline = BNGetNumFriends()

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the 
	-- datatext information
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (find(message, friendOnline) or find(message, friendOffline)) then return end
	end

	-- force update when showing tooltip
	dataValid = false

	self.text:SetFormattedText(displayString, L['Friends'], onlineFriends + numBNetOnline)
	lastPanel = self
end

local function Click(self, btn)
	GameTooltip:Hide()

	if btn == "RightButton" then
		local menuCountWhispers = 0
		local menuCountInvites = 0
		local classc, levelc, info
		
		menuList[2].menuList = {}
		menuList[3].menuList = {}
		
		if #friendTable > 0 then
			for i = 1, #friendTable do
				info = friendTable[i]
				if (info[5]) then
					menuCountInvites = menuCountInvites + 1
					menuCountWhispers = menuCountWhispers + 1
		
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					if classc == nil then classc = GetQuestDifficultyColor(info[2]) end
		
					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1],notCheckable=true, func = inviteClick}
					menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1],notCheckable=true, func = whisperClick}
				end
			end
		end
		if #BNTable > 0 then
			local realID, playerFaction, grouped
			for i = 1, #BNTable do
				info = BNTable[i]
				if (info[7]) then
					realID = (BATTLENET_NAME_FORMAT):format(info[2], info[3])
					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID,notCheckable=true, func = whisperClick}
					
					if select(1, UnitFactionGroup("player")) == "Horde" then playerFaction = 0 else playerFaction = 1 end
					if info[6] == wowString and playerFaction == info[12] then
						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[14]], GetQuestDifficultyColor(info[16])
						if classc == nil then classc = GetQuestDifficultyColor(info[16]) end

						if UnitInParty(info[4]) or UnitInRaid(info[4]) then grouped = 1 else grouped = 2 end
						menuCountInvites = menuCountInvites + 1
						
						menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[16],classc.r*255,classc.g*255,classc.b*255,info[4]), arg1 = info[5], notCheckable=true, func = inviteClick}
					end
				end
			end
		end

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)	
	else
		ToggleFriendsFrame(1)
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local numberOfFriends, onlineFriends = GetNumFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
		
	local totalonline = onlineFriends + numBNetOnline
	
	-- no friends online, quick exit
	if totalonline == 0 then return end

	if not dataValid then
		-- only retrieve information for all on-line members when we actually view the tooltip
		if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
		if totalBNet > 0 then BuildBNTable(totalBNet) end
		dataValid = true
	end

	local totalfriends = numberOfFriends + totalBNet
	local zonec, classc, levelc, realmc, info
	GameTooltip:AddDoubleLine(L['Friends List'], format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if onlineFriends > 0 then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(worldOfWarcraftString)
		for i = 1, #friendTable do
			info = friendTable[i]
			if info[5] then
				if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
				if classc == nil then classc = GetQuestDifficultyColor(info[2]) end
				
				if UnitInParty(info[1]) or UnitInRaid(info[1]) then grouped = 1 else grouped = 2 end
				GameTooltip:AddDoubleLine(format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],info[1],groupedTable[grouped]," "..info[6]),info[4],classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
			end
		end
	end

	if numBNetOnline > 0 then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(battleNetString)

		local status = 0
		for i = 1, #BNTable do
			info = BNTable[i]
			if info[7] then
				if info[6] == wowString then
					if (info[8] == true) then status = 1 elseif (info[9] == true) then status = 2 else status = 3 end
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[14]], GetQuestDifficultyColor(info[16])
					
					if classc == nil then classc = GetQuestDifficultyColor(info[16]) end
					
					if UnitInParty(info[4]) or UnitInRaid(info[4]) then grouped = 1 else grouped = 2 end
					GameTooltip:AddDoubleLine(format(clientLevelNameString, info[6],levelc.r*255,levelc.g*255,levelc.b*255,info[16],classc.r*255,classc.g*255,classc.b*255,info[4],groupedTable[grouped], 255, 0, 0, statusTable[status]),info[2].." "..info[3],238,238,238,238,238,238)
					if IsShiftKeyDown() then
						if GetRealZoneText() == info[15] then zonec = activezone else zonec = inactivezone end
						if GetRealmName() == info[11] then realmc = activezone else realmc = inactivezone end
						GameTooltip:AddDoubleLine(info[15], info[11], zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
					end
				else
					GameTooltip:AddDoubleLine(format(otherGameInfoString, info[6], info[4]), format(otherGameInfoString2, info[2], info[3]), .9, .9, .9, .9, .9, .9)
				end
			end
		end
	end	
	
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s: ", hex, "%d|r")
	
	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]

DT:RegisterDatatext('Friends', {'PLAYER_ENTERING_WORLD', "BN_FRIEND_ACCOUNT_ONLINE", "BN_FRIEND_ACCOUNT_OFFLINE", "BN_FRIEND_INFO_CHANGED", "BN_FRIEND_TOON_ONLINE",
"BN_FRIEND_TOON_OFFLINE", "BN_TOON_NAME_UPDATED", "FRIENDLIST_UPDATE", "CHAT_MSG_SYSTEM"}, OnEvent, nil, Click, OnEnter)

