local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs, pairs, select = ipairs, pairs, select
local sort, next, wipe, tremove, tinsert = sort, next, wipe, tremove, tinsert
local format, gsub, strfind, strjoin, strmatch = format, gsub, strfind, strjoin, strmatch

local MouseIsOver = MouseIsOver
local BNConnected = BNConnected
local BNGetInfo = BNGetInfo
local BNGetNumFriends = BNGetNumFriends
local BNSetCustomMessage = BNSetCustomMessage
local GetQuestDifficultyColor = GetQuestDifficultyColor
local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local IsAltKeyDown = IsAltKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid

local GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local SendChatMessage = C_ChatInfo.SendChatMessage or SendChatMessage
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local TIMERUNNING_ATLAS = '|A:timerunning-glues-icon-small:%s:%s:0:0|a'
local TIMERUNNING_SMALL = format(TIMERUNNING_ATLAS, 12, 10)
local EXPANSION_NAME0 = EXPANSION_NAME0

local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local WOW_PROJECT_ID = WOW_PROJECT_ID

-- create a popup
E.PopupDialogs.SET_BN_BROADCAST = {
	text = _G.BN_BROADCAST_TOOLTIP,
	button1 = _G.ACCEPT,
	button2 = _G.CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
	OnShow = function(self) self.editBox:SetText(select(4, BNGetInfo()) ) self.editBox:SetFocus() end,
	OnHide = _G.ChatEdit_FocusActiveWindow,
	EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3
}

local menuList = {
	{ text = _G.OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = _G.INVITE, hasArrow = true, notCheckable=true, },
	{ text = _G.CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true, },
	{ text = _G.PLAYER_STATUS, hasArrow = true, notCheckable=true,
		menuList = {
			{ text = '|cff2BC226'.._G.AVAILABLE..'|r', notCheckable=true, func = function() if IsChatAFK() then SendChatMessage('', 'AFK') elseif IsChatDND() then SendChatMessage('', 'DND') end end },
			{ text = '|cffE7E716'.._G.DND..'|r', notCheckable=true, func = function() if not IsChatDND() then SendChatMessage('', 'DND') end end },
			{ text = '|cffFF0000'.._G.AFK..'|r', notCheckable=true, func = function() if not IsChatAFK() then SendChatMessage('', 'AFK') end end },
		},
	},
	{ text = _G.BN_BROADCAST_TOOLTIP, notCheckable=true, func = function() E:StaticPopup_Show('SET_BN_BROADCAST') end },
}

local levelNameString = '|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r'
local levelNameClassString = '|cff%02x%02x%02x%d|r %s%s%s'
local characterFriend = _G.CHARACTER_FRIEND
local battleNetString = _G.BATTLENET_OPTIONS_LABEL
local totalOnlineString = strjoin('', _G.FRIENDS_LIST_ONLINE, ': %s/%s')
local tthead = {r=0.4, g=0.78, b=1}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString, db = ''
local friendTable, BNTable, tableList = {}, {}, {}
local friendOnline, friendOffline = gsub(_G.ERR_FRIEND_ONLINE_SS,'|Hplayer:%%s|h%[%%s%]|h',''), gsub(_G.ERR_FRIEND_OFFLINE_S,'%%s','')
local wowString = _G.BNET_CLIENT_WOW
local dataValid = false
local statusTable = {
	AFK = ' |cffFFFFFF[|r|cffFF9900'..L["AFK"]..'|r|cffFFFFFF]|r',
	DND = ' |cffFFFFFF[|r|cffFF3333'..L["DND"]..'|r|cffFFFFFF]|r'
}

-- Makro for get the client: /run for i,v in pairs(_G) do if type(i)=='string' and i:match('BNET_CLIENT_') then print(i,'=',v) end end
local clientSorted = {}
local clientList = {
	WoW =	{ index = 1, tag = 'WoW',	name = 'World of Warcraft'},
	WTCG =	{ index = 2, tag = 'HS',	name = 'Hearthstone'},
	Hero =	{ index = 3, tag = 'HotS',	name = 'Heroes of the Storm'},
	Pro =	{ index = 4, tag = 'OW',	name = 'Overwatch'},
	OSI =	{ index = 5, tag = 'D2',	name = 'Diablo 2: Resurrected'},
	D3 =	{ index = 6, tag = 'D3',	name = 'Diablo 3'},
	Fen =	{ index = 7, tag = 'D4',	name = 'Diablo 4'},
	ANBS =	{ index = 8, tag = 'DI',	name = 'Diablo Immortal'},
	S1 =	{ index = 9, tag = 'SC',	name = 'Starcraft'},
	S2 =	{ index = 10, tag = 'SC2',	name = 'Starcraft 2'},
	W3 =	{ index = 11, tag = 'WC3',	name = 'Warcraft 3: Reforged'},
	RTRO =	{ index = 12, tag = 'AC',	name = 'Arcade Collection'},
	WLBY =	{ index = 13, tag = 'CB4',	name = 'Crash Bandicoot 4'},
	VIPR =	{ index = 14, tag = 'BO4',	name = 'COD: Black Ops 4'},
	ODIN =	{ index = 15, tag = 'WZ',	name = 'COD: Warzone'},
	AUKS =	{ index = 16, tag = 'WZ2',	name = 'COD: Warzone 2'},
	LAZR =	{ index = 17, tag = 'MW2',	name = 'COD: Modern Warfare 2'},
	ZEUS =	{ index = 18, tag = 'CW',	name = 'COD: Cold War'},
	FORE =	{ index = 19, tag = 'VG',	name = 'COD: Vanguard'},
	GRY = 	{ index = 20, tag = 'AR',	name = 'Warcraft Arclight Rumble'},
	App =	{ index = 21, tag = 'App',	name = 'App'},
	BSAp =	{ index = 22, tag = L["Mobile"], name = L["Mobile"]}
}

DT.clientFullName = {}
for key, data in next, clientList do
	DT.clientFullName[key] = data.name
end

local function InGroup(name, realmName)
	if realmName and realmName ~= '' and realmName ~= E.myrealm then
		name = name..'-'..realmName
	end

	return (UnitInParty(name) or UnitInRaid(name)) and '|cffaaaaaa*|r' or ''
end

local function SortAlphabeticName(a, b)
	if a.name and b.name then
		return a.name < b.name
	end
end

local function BuildFriendTable(total)
	wipe(friendTable)
	for i = 1, total do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local className = E:UnlocalizedClassName(info.className) or ''
			local status = (info.afk and statusTable.AFK) or (info.dnd and statusTable.DND) or ''
			friendTable[i] = {
				name = info.name,			--1
				level = info.level,			--2
				class = className,			--3
				zone = info.area,			--4
				online = info.connected,	--5
				status = status,			--6
				notes = info.notes,			--7
				guid = info.guid			--8
			}
		end
	end
	if next(friendTable) then
		sort(friendTable, SortAlphabeticName)
	end
end

--Sort: client-> (WoW: project-> faction-> name) ELSE:btag
local function Sort(a, b)
	if a.client and b.client then
		if (a.client == b.client) then
			if (a.client == wowString) and a.wowProjectID and b.wowProjectID then
				if (a.wowProjectID == b.wowProjectID) and a.faction and b.faction then
					if (a.faction == b.faction) and a.characterName and b.characterName then
						return a.characterName < b.characterName
					end
					return a.faction < b.faction
				end
				return a.wowProjectID < b.wowProjectID
			elseif (a.battleTag and b.battleTag) then
				return a.battleTag < b.battleTag
			end
		end
		return a.client < b.client
	end
end

--Sort client by statically given index (this is a `pairs by keys` sorting method)
local function ClientSort(a, b)
	if a and b then
		local A, B = clientList[a], clientList[b]
		if A and B then
			return A.index < B.index
		end
		return a < b
	end
end

local function AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, timerunningID, realmName, faction, race, className, zoneName, level, guid, gameText)
	className = E:UnlocalizedClassName(className) or ''
	characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ''

	local obj = {
		accountID = bnetIDAccount,		--1
		accountName = accountName,		--2
		battleTag = battleTag,			--3
		characterName = characterName,	--4
		gameID = bnetIDGameAccount,		--5
		client = client,				--6
		isOnline = isOnline,			--7
		isBnetAFK = isBnetAFK,			--8
		isBnetDND = isBnetDND,			--9
		noteText = noteText,			--10
		wowProjectID = wowProjectID,	--11
		realmName = realmName,			--12
		faction = faction,				--13
		race = race,					--14
		className = className,			--15
		zoneName = zoneName,			--16
		level = level,					--17
		guid = guid,					--18
		gameText = gameText,			--19
		timerunningID = timerunningID	--20
	}

	if wowProjectID and wowProjectID ~= WOW_PROJECT_MAINLINE then
		obj.classicText, obj.realmName = strmatch(gameText, '(.-)%s%-%s(.+)')

		if obj.classicText and obj.classicText ~= '' and obj.classicText ~= EXPANSION_NAME0 then
			obj.classicText = gsub(obj.classicText, '%s?'..EXPANSION_NAME0..'%s?', '')
		end
	end

	BNTable[bnIndex] = obj

	if tableList[client] then
		tableList[client][#tableList[client]+1] = BNTable[bnIndex]
	else
		tableList[client] = {}
		tableList[client][1] = BNTable[bnIndex]
	end
end

local function PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, timerunningID, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus)
	-- `hasFocus` is not added to BNTable[i]; we only need this to keep our friends datatext in sync with the friends list
	for i = 1, bnIndex do
		local isAdded, bnInfo = 0, BNTable[i]
		if bnInfo and (bnInfo.accountID == bnetIDAccount) then
			if bnInfo.client == 'BSAp' then
				if client == 'BSAp' then -- unlikely to happen
					isAdded = 1
				elseif client == 'App' then
					isAdded = (hasFocus and 2) or 1
				else -- Mobile -> Game
					isAdded = 2 --swap data
				end
			elseif bnInfo.client == 'App' then
				if client == 'App' then -- unlikely to happen
					isAdded = 1
				elseif client == 'BSAp' then
					isAdded = (hasFocus and 2) or 1
				else -- App -> Game
					isAdded = 2 --swap data
				end
			elseif bnInfo.client then -- Game
				if client == 'BSAp' or client == 'App' then -- ignore Mobile and App
					isAdded = 1
				end
			end
		end
		if isAdded == 2 then -- swap data
			if bnInfo.client and tableList[bnInfo.client] then
				for n, y in ipairs(tableList[bnInfo.client]) do
					if y == bnInfo then
						tremove(tableList[bnInfo.client], n)
						break -- remove the old one from tableList
					end
				end
			end
			AddToBNTable(i, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, timerunningID, realmName, faction, race, class, zoneName, level, guid, gameText)
		end
		if isAdded ~= 0 then
			return bnIndex
		end
	end

	bnIndex = bnIndex + 1 --bump the index one for a new addition
	AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, timerunningID, realmName, faction, race, class, zoneName, level, guid, gameText)

	return bnIndex
end

local function BuildBNTable(total)
	for _, v in pairs(tableList) do wipe(v) end
	wipe(BNTable)
	wipe(clientSorted)

	local bnIndex = 0

	for i = 1, total do
		local accountInfo = GetFriendAccountInfo(i)
		local gameInfo = accountInfo and accountInfo.gameAccountInfo
		if gameInfo and gameInfo.isOnline then
			local numGameAccounts = GetFriendNumGameAccounts(i)
			if numGameAccounts and numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					local gameOther = GetFriendGameAccountInfo(i, y)
					bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, gameOther.characterName, gameOther.gameAccountID, gameOther.clientProgram, gameOther.isOnline, accountInfo.isAFK or gameOther.isGameAFK, accountInfo.isDND or gameOther.isGameBusy, accountInfo.note, gameOther.wowProjectID, gameOther.timerunningSeasonID, gameOther.realmName, gameOther.factionName, gameOther.raceName, gameOther.className, gameOther.areaName, gameOther.characterLevel, gameOther.playerGuid, gameOther.richPresence, gameOther.hasFocus)
				end
			else
				bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, gameInfo.characterName, gameInfo.gameAccountID, gameInfo.clientProgram, gameInfo.isOnline, accountInfo.isAFK, accountInfo.isDND, accountInfo.note, gameInfo.wowProjectID, gameInfo.timerunningSeasonID)
			end
		end
	end

	if next(BNTable) then
		sort(BNTable, Sort)
	end
	for c, v in pairs(tableList) do
		if next(v) then
			sort(v, Sort)
		end
		tinsert(clientSorted, c)
	end
	if next(clientSorted) then
		sort(clientSorted, ClientSort)
	end
end

local function Click(self, btn)
	if btn == 'RightButton' then
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		if not db.hideWoW then
			for _, info in ipairs(friendTable) do
				if info.online then
					local shouldSkip = false
					if (info.status == statusTable.AFK) and db.hideAFK then
						shouldSkip = true
					elseif (info.status == statusTable.DND) and db.hideDND then
						shouldSkip = true
					end
					if not shouldSkip then
						local classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
						if not classc then classc = levelc end

						menuCountWhispers = menuCountWhispers + 1
						menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.name), arg1 = info.name, notCheckable=true, func = DT.SendWhisper}

						if InGroup(info.name) == '' then
							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.name), arg1 = info.name, arg2 = info.guid, notCheckable=true, func = DT.InviteFriend}
						end
					end
				end
			end
		end

		for _, info in ipairs(BNTable) do
			if info.isOnline then
				local shouldSkip = false
				if (info.isBnetAFK == true) and db.hideAFK then
					shouldSkip = true
				elseif (info.isBnetDND == true) and db.hideDND then
					shouldSkip = true
				end
				if info.client and db['hide'..info.client] then
					shouldSkip = true
				end
				if not shouldSkip then
					local realID, hasBnet = info.accountName, false

					for _, z in ipairs(menuList[3].menuList) do
						if z and z.text and (z.text == realID) then
							hasBnet = true
							break
						end
					end

					if not hasBnet then -- hasBnet will make sure only one is added to whispers but still allow us to add multiple into invites
						menuCountWhispers = menuCountWhispers + 1
						menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID, arg2 = true, notCheckable=true, func = DT.SendWhisper}
					end

					if (info.client and info.client == wowString) and InGroup(info.characterName, info.realmName) == '' then
						local classc, levelc = E:ClassColor(info.className), GetQuestDifficultyColor(info.level)
						if not classc then classc = levelc end

						if info.wowProjectID == WOW_PROJECT_ID then
							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.characterName), arg1 = info.gameID, arg2 = info.guid, notCheckable=true, func = DT.InviteFriend}
						end
					end
				end
			end
		end

		E:SetEasyMenuAnchor(E.EasyMenu, self)
		E:ComplicatedMenu(menuList, E.EasyMenu, nil, nil, nil, 'MENU')
	elseif not E:AlertCombat() then
		ToggleFriendsFrame(1)
	end
end

local lastTooltipXLineHeader
local function TooltipAddXLine(doubleLine, header, ...)
	local tt = DT.tooltip
	local func = doubleLine and tt.AddDoubleLine or tt.AddLine
	if lastTooltipXLineHeader ~= header then
		tt:AddLine(' ')

		func(tt, header)

		lastTooltipXLineHeader = header
	end

	func(tt, ...)
end

local isBNOnline
local function OnEnter()
	DT.tooltip:ClearLines()
	lastTooltipXLineHeader = nil

	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local numberOfFriends = C_FriendList_GetNumFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
	local totalonline = onlineFriends + numBNetOnline

	-- no friends online, quick exit
	if totalonline == 0 then return end

	if not dataValid then
		-- only retrieve information for all on-line members when we actually view the tooltip
		if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
		if totalBNet > 0 and isBNOnline then BuildBNTable(totalBNet) end
		dataValid = true
	end

	local totalfriends = numberOfFriends + totalBNet
	local zonec, classc, levelc, realmc
	local shiftDown = IsShiftKeyDown()

	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if (onlineFriends > 0) and not db.hideWoW then
		for _, info in ipairs(friendTable) do
			if info.online then
				local shouldSkip = false
				if (info.status == statusTable.AFK) and db.hideAFK then
					shouldSkip = true
				elseif (info.status == statusTable.DND) and db.hideDND then
					shouldSkip = true
				end
				if not shouldSkip then
					if E.MapInfo.zoneText and (E.MapInfo.zoneText == info.zone) then zonec = activezone else zonec = inactivezone end
					classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
					if not classc then classc = levelc end

					TooltipAddXLine(true, characterFriend, format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,info.name,InGroup(info.name),info.status),info.zone,classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
				end
			end
		end
	end

	if numBNetOnline > 0 then
		local status
		for _, client in ipairs(clientSorted) do
			local Table = tableList[client]
			local shouldSkip = db['hide'..client]
			if not shouldSkip then
				for _, info in ipairs(Table) do
					if info.isOnline then
						shouldSkip = false
						if info.isBnetAFK == true then
							if db.hideAFK then
								shouldSkip = true
							end
							status = statusTable.AFK
						elseif info.isBnetDND == true then
							if db.hideDND then
								shouldSkip = true
							end
							status = statusTable.DND
						else
							status = ''
						end

						if not shouldSkip then
							local clientInfo = clientList[client]
							local header = format('%s (%s)', battleNetString, info.classicText or (clientInfo and clientInfo.tag) or client)
							if info.client and info.client == wowString then
								classc = E:ClassColor(info.className)
								if info.level and info.level ~= '' then
									levelc = GetQuestDifficultyColor(info.level)
								else
									classc, levelc = PRIEST_COLOR, PRIEST_COLOR
								end

								--Sometimes the friend list is fubar with level 0 unknown friends
								if not classc then classc = PRIEST_COLOR end

								TooltipAddXLine(true, header, format(levelNameString..'%s%s%s',levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.characterName,InGroup(info.characterName, info.realmName),status,info.timerunningID and TIMERUNNING_SMALL or ''),info.accountName,238,238,238,238,238,238)
								if shiftDown then
									if E.MapInfo.zoneText and (E.MapInfo.zoneText == info.zoneName) then zonec = activezone else zonec = inactivezone end
									if E.myrealm == info.realmName then realmc = activezone else realmc = inactivezone end
									if info.zoneName or info.realmName then
										TooltipAddXLine(true, header, info.zoneName or ' ', info.realmName or ' ', zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
									end
								end
							else
								TooltipAddXLine(true, header, info.characterName..status, info.accountName, .9, .9, .9, .9, .9, .9)
								if shiftDown and (info.gameText and info.gameText ~= '') and (info.client and info.client ~= 'App' and info.client ~= 'BSAp') then
									TooltipAddXLine(false, header, info.gameText, inactivezone.r, inactivezone.g, inactivezone.b)
								end
							end
						end
					end
				end
			end
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event, message)
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	isBNOnline = BNConnected()

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the
	-- datatext information
	if event == 'CHAT_MSG_SYSTEM' then
		if not (strfind(message, friendOnline) or strfind(message, friendOffline)) then return end
	end
	-- force update when showing tooltip
	dataValid = false

	if not IsAltKeyDown() and event == 'MODIFIER_STATE_CHANGED' and MouseIsOver(self) then
		OnEnter(self)
	end

	if db.NoLabel then
		self.text:SetFormattedText(displayString, onlineFriends + numBNetOnline)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or _G.FRIENDS..': ', onlineFriends + numBNetOnline)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Friends', _G.SOCIAL_LABEL, { 'BN_FRIEND_ACCOUNT_ONLINE', 'BN_FRIEND_ACCOUNT_OFFLINE', 'BN_FRIEND_INFO_CHANGED', 'FRIENDLIST_UPDATE', 'CHAT_MSG_SYSTEM', 'MODIFIER_STATE_CHANGED' }, OnEvent, nil, Click, OnEnter, nil, _G.FRIENDS, nil, ApplySettings)
