local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local type, ipairs, pairs, select = type, ipairs, pairs, select
local sort, next, wipe, tremove, tinsert = sort, next, wipe, tremove, tinsert
local format, gsub, strfind, strjoin, strmatch = format, gsub, strfind, strjoin, strmatch

local BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
local GetMouseFocus = GetMouseFocus
local BNGetInfo = BNGetInfo
local BNGetNumFriends = BNGetNumFriends
local BNInviteFriend = BNInviteFriend
local BNRequestInviteFriend = BNRequestInviteFriend
local BNSetCustomMessage = BNSetCustomMessage
local GetDisplayedInviteType = GetDisplayedInviteType
local GetQuestDifficultyColor = GetQuestDifficultyColor
local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local IsAltKeyDown = IsAltKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local SendChatMessage = SendChatMessage
local SetItemRef = SetItemRef
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local ChatFrame_SendBNetTell = ChatFrame_SendBNetTell
local InCombatLockdown = InCombatLockdown
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_PartyInfo_RequestInviteFromUnit = C_PartyInfo.RequestInviteFromUnit
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

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

local function inviteClick(_, name, guid)
	DT.EasyMenu:Hide()

	if not (name and name ~= '') then return end
	local isBNet = type(name) == 'number'

	if guid then
		local inviteType = GetDisplayedInviteType(guid)
		if inviteType == 'INVITE' or inviteType == 'SUGGEST_INVITE' then
			if isBNet then
				BNInviteFriend(name)
			else
				C_PartyInfo_InviteUnit(name)
			end
		elseif inviteType == 'REQUEST_INVITE' then
			if isBNet then
				BNRequestInviteFriend(name)
			else
				C_PartyInfo_RequestInviteFromUnit(name)
			end
		end
	else
		-- if for some reason guid isnt here fallback and just try to invite them
		-- this is unlikely but having a fallback doesnt hurt
		if isBNet then
			BNInviteFriend(name)
		else
			C_PartyInfo_InviteUnit(name)
		end
	end
end

local function whisperClick(_, name, battleNet)
	DT.EasyMenu:Hide()

	if battleNet then
		ChatFrame_SendBNetTell(name)
	else
		SetItemRef( 'player:'..name, format('|Hplayer:%1$s|h[%1$s]|h',name), 'LeftButton' )
	end
end

local levelNameString = '|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r'
local levelNameClassString = '|cff%02x%02x%02x%d|r %s%s%s'
local characterFriend = _G.CHARACTER_FRIEND
local battleNetString = _G.BATTLENET_OPTIONS_LABEL
local totalOnlineString = strjoin('', _G.FRIENDS_LIST_ONLINE, ': %s/%s')
local tthead = {r=0.4, g=0.78, b=1}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = ''
local friendTable, BNTable, tableList = {}, {}, {}
local friendOnline, friendOffline = gsub(_G.ERR_FRIEND_ONLINE_SS,'\124Hplayer:%%s\124h%[%%s%]\124h',''), gsub(_G.ERR_FRIEND_OFFLINE_S,'%%s','')
local wowString = _G.BNET_CLIENT_WOW
local retailID = _G.WOW_PROJECT_ID
local WOW_CLASSIC = _G.BNET_FRIEND_TOOLTIP_WOW_CLASSIC
local dataValid, lastPanel = false
local statusTable = {
	AFK = ' |cffFFFFFF[|r|cffFF9900'..L["AFK"]..'|r|cffFFFFFF]|r',
	DND = ' |cffFFFFFF[|r|cffFF3333'..L["DND"]..'|r|cffFFFFFF]|r'
}

-- Makro for get the client: /run for i,v in pairs(_G) do if type(i)=='string' and i:match('BNET_CLIENT_') then print(i,'=',v) end end
local clientSorted = {}
local clientTags = {
	[_G.BNET_CLIENT_WOW] = 'WoW',
	[_G.BNET_CLIENT_WTCG] = 'HS',
	[_G.BNET_CLIENT_HEROES] = 'HotS',
	[_G.BNET_CLIENT_OVERWATCH] = 'OW',
	[_G.BNET_CLIENT_D2] = 'D2',
	[_G.BNET_CLIENT_D3] = 'D3',
	[_G.BNET_CLIENT_SC] = 'SC',
	[_G.BNET_CLIENT_SC2] = 'SC2',
	[_G.BNET_CLIENT_WC3] = 'WC3',
	[_G.BNET_CLIENT_ARCADE] = 'AC',
	[_G.BNET_CLIENT_CRASH4] = 'CB4',
	[_G.BNET_CLIENT_COD] = 'BO4',
	[_G.BNET_CLIENT_COD_MW] = 'MW',
	[_G.BNET_CLIENT_COD_MW2] = 'MW2',
	[_G.BNET_CLIENT_COD_BOCW] = 'CW',
	BSAp = L["Mobile"],
}

local clientIndex = {
	[_G.BNET_CLIENT_WOW] = 1,
	[_G.BNET_CLIENT_WTCG] = 2,
	[_G.BNET_CLIENT_HEROES] = 3,
	[_G.BNET_CLIENT_OVERWATCH] = 4,
	[_G.BNET_CLIENT_D2] = 5,
	[_G.BNET_CLIENT_D3] = 6,
	[_G.BNET_CLIENT_SC] = 7,
	[_G.BNET_CLIENT_SC2] = 8,
	[_G.BNET_CLIENT_WC3] = 9,
	[_G.BNET_CLIENT_ARCADE] = 10,
	[_G.BNET_CLIENT_CRASH4] = 11,
	[_G.BNET_CLIENT_COD] = 12,
	[_G.BNET_CLIENT_COD_MW] = 13,
	[_G.BNET_CLIENT_COD_MW2] = 14,
	[_G.BNET_CLIENT_COD_BOCW] = 15,
	App = 16,
	BSAp = 17,
}

local clientFullName = {
	[_G.BNET_CLIENT_WOW] = "World of Warcraft",
	[_G.BNET_CLIENT_WTCG] = "Hearthstone",
	[_G.BNET_CLIENT_HEROES] = "Heroes of the Storm",
	[_G.BNET_CLIENT_OVERWATCH] = "Overwatch",
	[_G.BNET_CLIENT_D2] = "Diablo 2: Resurrected",
	[_G.BNET_CLIENT_D3] = "Diablo 3",
	[_G.BNET_CLIENT_SC] = "Starcraft",
	[_G.BNET_CLIENT_SC2] = "Starcraft 2",
	[_G.BNET_CLIENT_WC3] = "Warcraft 3: Reforged",
	[_G.BNET_CLIENT_ARCADE] = "Arcade Collection",
	[_G.BNET_CLIENT_CRASH4] = "Crash Bandicoot 4",
	[_G.BNET_CLIENT_COD] = "COD: Black Ops 4",
	[_G.BNET_CLIENT_COD_MW] = "COD: Modern Warfare",
	[_G.BNET_CLIENT_COD_MW2] = "COD: Modern Warfare 2",
	[_G.BNET_CLIENT_COD_BOCW] = "COD: Cold War",
	App = "App",
	BSAp = L["Mobile"],
}

DT.clientFullName = clientFullName

local function inGroup(name, realmName)
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
local function clientSort(a, b)
	if a and b then
		if clientIndex[a] and clientIndex[b] then
			return clientIndex[a] < clientIndex[b]
		end
		return a < b
	end
end

local function AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, className, zoneName, level, guid, gameText)
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
		gameText = gameText				--19
	}

	if strmatch(gameText, WOW_CLASSIC) then
		obj.classicText, obj.realmName = strmatch(gameText, '(.-)%s%-%s(.+)')
	end

	BNTable[bnIndex] = obj

	if tableList[client] then
		tableList[client][#tableList[client]+1] = BNTable[bnIndex]
	else
		tableList[client] = {}
		tableList[client][1] = BNTable[bnIndex]
	end
end

local function PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus)
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
			AddToBNTable(i, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, class, zoneName, level, guid, gameText)
		end
		if isAdded ~= 0 then
			return bnIndex
		end
	end

	bnIndex = bnIndex + 1 --bump the index one for a new addition
	AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, class, zoneName, level, guid, gameText)

	return bnIndex
end

local function BuildBNTable(total)
	for _, v in pairs(tableList) do wipe(v) end
	wipe(BNTable)
	wipe(clientSorted)

	local bnIndex = 0

	for i = 1, total do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
			local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
			if numGameAccounts and numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, y)
					bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, gameAccountInfo.characterName, gameAccountInfo.gameAccountID, gameAccountInfo.clientProgram, gameAccountInfo.isOnline, accountInfo.isAFK or gameAccountInfo.isGameAFK, accountInfo.isDND or gameAccountInfo.isGameBusy, accountInfo.note, accountInfo.gameAccountInfo.wowProjectID, gameAccountInfo.realmName, gameAccountInfo.factionName, gameAccountInfo.raceName, gameAccountInfo.className, gameAccountInfo.areaName, gameAccountInfo.characterLevel, gameAccountInfo.playerGuid, gameAccountInfo.richPresence, gameAccountInfo.hasFocus)
				end
			else
				bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isOnline, accountInfo.isAFK, accountInfo.isDND, accountInfo.note, accountInfo.gameAccountInfo.wowProjectID)
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
		sort(clientSorted, clientSort)
	end
end

local function Click(self, btn)
	if btn == 'RightButton' then
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		if not E.global.datatexts.settings.Friends.hideWoW then
			for _, info in ipairs(friendTable) do
				if info.online then
					local shouldSkip = false
					if (info.status == statusTable.AFK) and E.global.datatexts.settings.Friends.hideAFK then
						shouldSkip = true
					elseif (info.status == statusTable.DND) and E.global.datatexts.settings.Friends.hideDND then
						shouldSkip = true
					end
					if not shouldSkip then
						local classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
						if not classc then classc = levelc end

						menuCountWhispers = menuCountWhispers + 1
						menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.name), arg1 = info.name, notCheckable=true, func = whisperClick}

						if inGroup(info.name) == '' then
							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.name), arg1 = info.name, arg2 = info.guid, notCheckable=true, func = inviteClick}
						end
					end
				end
			end
		end

		for _, info in ipairs(BNTable) do
			if info.isOnline then
				local shouldSkip = false
				if (info.isBnetAFK == true) and E.global.datatexts.settings.Friends.hideAFK then
					shouldSkip = true
				elseif (info.isBnetDND == true) and E.global.datatexts.settings.Friends.hideDND then
					shouldSkip = true
				end
				if info.client and E.global.datatexts.settings.Friends['hide'..info.client] then
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
						menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID, arg2 = true, notCheckable=true, func = whisperClick}
					end

					if (info.client and info.client == wowString) and (E.myfaction == info.faction) and inGroup(info.characterName, info.realmName) == '' then
						local classc, levelc = E:ClassColor(info.className), GetQuestDifficultyColor(info.level)
						if not classc then classc = levelc end

						if info.wowProjectID == retailID then
							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.characterName), arg1 = info.gameID, arg2 = info.guid, notCheckable=true, func = inviteClick}
						end
					end
				end
			end
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menuList, DT.EasyMenu, nil, nil, nil, 'MENU')
	elseif InCombatLockdown() then
		_G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT)
	else
		ToggleFriendsFrame(1)
	end
end

local lastTooltipXLineHeader
local function TooltipAddXLine(X, header, ...)
	X = (X == true and 'AddDoubleLine') or 'AddLine'
	if lastTooltipXLineHeader ~= header then
		DT.tooltip[X](DT.tooltip, ' ')
		DT.tooltip[X](DT.tooltip, header)
		lastTooltipXLineHeader = header
	end
	DT.tooltip[X](DT.tooltip, ...)
end

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
		if totalBNet > 0 then BuildBNTable(totalBNet) end
		dataValid = true
	end

	local totalfriends = numberOfFriends + totalBNet
	local zonec, classc, levelc, realmc
	local shiftDown = IsShiftKeyDown()

	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if (onlineFriends > 0) and not E.global.datatexts.settings.Friends.hideWoW then
		for _, info in ipairs(friendTable) do
			if info.online then
				local shouldSkip = false
				if (info.status == statusTable.AFK) and E.global.datatexts.settings.Friends.hideAFK then
					shouldSkip = true
				elseif (info.status == statusTable.DND) and E.global.datatexts.settings.Friends.hideDND then
					shouldSkip = true
				end
				if not shouldSkip then
					if E.MapInfo.zoneText and (E.MapInfo.zoneText == info.zone) then zonec = activezone else zonec = inactivezone end
					classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
					if not classc then classc = levelc end

					TooltipAddXLine(true, characterFriend, format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,info.name,inGroup(info.name),info.status),info.zone,classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
				end
			end
		end
	end

	if numBNetOnline > 0 then
		local status
		for _, client in ipairs(clientSorted) do
			local Table = tableList[client]
			local shouldSkip = E.global.datatexts.settings.Friends['hide'..client]
			if not shouldSkip then
				for _, info in ipairs(Table) do
					if info.isOnline then
						shouldSkip = false
						if info.isBnetAFK == true then
							if E.global.datatexts.settings.Friends.hideAFK then
								shouldSkip = true
							end
							status = statusTable.AFK
						elseif info.isBnetDND == true then
							if E.global.datatexts.settings.Friends.hideDND then
								shouldSkip = true
							end
							status = statusTable.DND
						else
							status = ''
						end

						if not shouldSkip then
							local header = format('%s (%s)', battleNetString, info.classicText or clientTags[client] or client)
							if info.client and info.client == wowString then
								classc = E:ClassColor(info.className)
								if info.level and info.level ~= '' then
									levelc = GetQuestDifficultyColor(info.level)
								else
									classc, levelc = PRIEST_COLOR, PRIEST_COLOR
								end

								--Sometimes the friend list is fubar with level 0 unknown friends
								if not classc then classc = PRIEST_COLOR end

								TooltipAddXLine(true, header, format(levelNameString..'%s%s',levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.characterName,inGroup(info.characterName, info.realmName),status),info.accountName,238,238,238,238,238,238)
								if shiftDown then
									if E.MapInfo.zoneText and (E.MapInfo.zoneText == info.zoneName) then zonec = activezone else zonec = inactivezone end
									if E.myrealm == info.realmName then realmc = activezone else realmc = inactivezone end
									TooltipAddXLine(true, header, info.zoneName, info.realmName, zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
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

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the
	-- datatext information
	if event == 'CHAT_MSG_SYSTEM' then
		if not (strfind(message, friendOnline) or strfind(message, friendOffline)) then return end
	end
	-- force update when showing tooltip
	dataValid = false

	if not IsAltKeyDown() and event == 'MODIFIER_STATE_CHANGED' and GetMouseFocus() == self then
		OnEnter(self)
	end

	if E.global.datatexts.settings.Friends.NoLabel then
		self.text:SetFormattedText(displayString, onlineFriends + numBNetOnline)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Friends.Label ~= '' and E.global.datatexts.settings.Friends.Label or _G.FRIENDS..': ', onlineFriends + numBNetOnline)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Friends.NoLabel and '' or '%s', hex, '%d|r')

	if lastPanel then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Friends', _G.SOCIAL_LABEL, {'BN_FRIEND_ACCOUNT_ONLINE', 'BN_FRIEND_ACCOUNT_OFFLINE', 'BN_FRIEND_INFO_CHANGED', 'FRIENDLIST_UPDATE', 'CHAT_MSG_SYSTEM', 'MODIFIER_STATE_CHANGED'}, OnEvent, nil, Click, OnEnter, nil, _G.FRIENDS, nil, ValueColorUpdate)
