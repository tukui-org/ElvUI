local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local type, ipairs, pairs, select = type, ipairs, pairs, select
local sort, next, wipe, tremove, tinsert = sort, next, wipe, tremove, tinsert
local format, gsub, strfind, strjoin = format, gsub, strfind, strjoin

local BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
local BNGetFriendGameAccountInfo = BNGetFriendGameAccountInfo
local BNGetFriendInfo = BNGetFriendInfo
local BNGetInfo = BNGetInfo
local BNGetNumFriendGameAccounts = BNGetNumFriendGameAccounts
local BNGetNumFriends = BNGetNumFriends
local BNInviteFriend = BNInviteFriend
local BNRequestInviteFriend = BNRequestInviteFriend
local BNSetCustomMessage = BNSetCustomMessage
local ChatFrame_SendBNetTell = ChatFrame_SendBNetTell
local GetDisplayedInviteType = GetDisplayedInviteType
local GetMouseFocus = GetMouseFocus
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealmName = GetRealmName
local InCombatLockdown = InCombatLockdown
local InviteToGroup = InviteToGroup
local IsAltKeyDown = IsAltKeyDown
local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local IsShiftKeyDown = IsShiftKeyDown
local RequestInviteFromUnit = RequestInviteFromUnit
local SendChatMessage = SendChatMessage
local SetItemRef = SetItemRef
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
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
			{ text = "|cff2BC226".._G.AVAILABLE.."|r", notCheckable=true, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffE7E716".._G.DND.."|r", notCheckable=true, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffFF0000".._G.AFK.."|r", notCheckable=true, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end },
		},
	},
	{ text = _G.BN_BROADCAST_TOOLTIP, notCheckable=true, func = function() E:StaticPopup_Show("SET_BN_BROADCAST") end },
}

local function inviteClick(_, name, guid)
	DT.EasyMenu:Hide()

	if not (name and name ~= "") then return end
	local isBNet = type(name) == 'number'

	if guid then
		local inviteType = GetDisplayedInviteType(guid)
		if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
			if isBNet then
				BNInviteFriend(name)
			else
				InviteToGroup(name)
			end
		elseif inviteType == "REQUEST_INVITE" then
			if isBNet then
				BNRequestInviteFriend(name)
			else
				RequestInviteFromUnit(name)
			end
		end
	else
		-- if for some reason guid isnt here fallback and just try to invite them
		-- this is unlikely but having a fallback doesnt hurt
		if isBNet then
			BNInviteFriend(name)
		else
			InviteToGroup(name)
		end
	end
end

local function whisperClick(_, name, battleNet)
	DT.EasyMenu:Hide()

	if battleNet then
		ChatFrame_SendBNetTell(name)
	else
		SetItemRef( "player:"..name, format("|Hplayer:%1$s|h[%1$s]|h",name), "LeftButton" )
	end
end

local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"
local characterFriend = _G.CHARACTER_FRIEND
local battleNetString = _G.BATTLENET_OPTIONS_LABEL
local totalOnlineString = strjoin("", _G.FRIENDS_LIST_ONLINE, ": %s/%s")
local tthead = {r=0.4, g=0.78, b=1}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = ''
local statusTable = { " |cffFFFFFF[|r|cffFF9900"..L["AFK"].."|r|cffFFFFFF]|r", " |cffFFFFFF[|r|cffFF3333"..L["DND"].."|r|cffFFFFFF]|r", "" }
local groupedTable = { "|cffaaaaaa*|r", "" }
local friendTable, BNTable, tableList = {}, {}, {}
local friendOnline, friendOffline = gsub(_G.ERR_FRIEND_ONLINE_SS,"\124Hplayer:%%s\124h%[%%s%]\124h",""), gsub(_G.ERR_FRIEND_OFFLINE_S,"%%s","")
local wowString = _G.BNET_CLIENT_WOW
local dataValid, lastPanel = false

local clientSorted = {}
local clientTags = {
	[_G.BNET_CLIENT_WOW] = "WoW",
	[_G.BNET_CLIENT_D3] = "D3",
	[_G.BNET_CLIENT_WTCG] = "HS",
	[_G.BNET_CLIENT_HEROES] = "HotS",
	[_G.BNET_CLIENT_OVERWATCH] = "OW",
	[_G.BNET_CLIENT_SC] = "SC",
	[_G.BNET_CLIENT_SC2] = "SC2",
	[_G.BNET_CLIENT_COD] = "BO4",
	[_G.BNET_CLIENT_COD_MW] = "MW",
	[_G.BNET_CLIENT_COD_MW2] = "MW2",
	["BSAp"] = L["Mobile"],
}

local clientIndex = {
	[_G.BNET_CLIENT_WOW] = 1,
	[_G.BNET_CLIENT_D3] = 2,
	[_G.BNET_CLIENT_WTCG] = 3,
	[_G.BNET_CLIENT_HEROES] = 4,
	[_G.BNET_CLIENT_OVERWATCH] = 5,
	[_G.BNET_CLIENT_SC] = 6,
	[_G.BNET_CLIENT_SC2] = 7,
	[_G.BNET_CLIENT_COD] = 8,
	[_G.BNET_CLIENT_COD_MW] = 9,
	[_G.BNET_CLIENT_COD_MW2] = 10,
	["App"] = 11,
	["BSAp"] = 12,
}

local function SortAlphabeticName(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function BuildFriendTable(total)
	wipe(friendTable)
	for i = 1, total do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local className = E:UnlocalizedClassName(info.className) or ""
			local status = statusTable[(info.afk and 1) or (info.dnd and 2) or 3]
			friendTable[i] = { info.name, info.level, className, info.area, info.connected, status, info.notes, info.guid }
		end
	end
	if next(friendTable) then
		sort(friendTable, SortAlphabeticName)
	end
end

--Sort: client-> (WoW: faction-> name) ELSE:btag
local function Sort(a, b)
	if a[6] and b[6] then
		if (a[6] == b[6]) then
			if (a[6] == wowString) and a[12] and b[12] then
				if (a[12] == b[12]) and a[4] and b[4] then
					return a[4] < b[4] --sort by name
				end
				return a[12] < b[12] --sort by faction
			elseif (a[3] and b[3]) then
				return a[3] < b[3] --sort by battleTag
			end
		end
		return a[6] < b[6] --sort by client
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

local function AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, className, zoneName, level, guid, gameText)
	className = E:UnlocalizedClassName(className) or ""
	characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ""
	BNTable[bnIndex] = { bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, className, zoneName, level, guid, gameText }

	if tableList[client] then
		tableList[client][#tableList[client]+1] = BNTable[bnIndex]
	else
		tableList[client] = {}
		tableList[client][1] = BNTable[bnIndex]
	end
end

local function PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus)
	-- `hasFocus` is not added to BNTable[i]; we only need this to keep our friends datatext in sync with the friends list
	for i = 1, bnIndex do
		local isAdded, bnInfo = 0, BNTable[i]
		if bnInfo and (bnInfo[1] == bnetIDAccount) then
			if bnInfo[6] == "BSAp" then
				if client == "BSAp" then -- unlikely to happen
					isAdded = 1
				elseif client == "App" then
					isAdded = (hasFocus and 2) or 1
				else -- Mobile -> Game
					isAdded = 2 --swap data
				end
			elseif bnInfo[6] == "App" then
				if client == "App" then -- unlikely to happen
					isAdded = 1
				elseif client == "BSAp" then
					isAdded = (hasFocus and 2) or 1
				else -- App -> Game
					isAdded = 2 --swap data
				end
			elseif bnInfo[6] then -- Game
				if client == "BSAp" or client == "App" then -- ignore Mobile and App
					isAdded = 1
				end
			end
		end
		if isAdded == 2 then -- swap data
			if bnInfo[6] and tableList[bnInfo[6]] then
				for n, y in ipairs(tableList[bnInfo[6]]) do
					if y == bnInfo then
						tremove(tableList[bnInfo[6]], n)
						break -- remove the old one from tableList
					end
				end
			end
			AddToBNTable(i, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText)
		end
		if isAdded ~= 0 then
			return bnIndex
		end
	end

	bnIndex = bnIndex + 1 --bump the index one for a new addition
	AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText)

	return bnIndex
end

local function BuildBNTable(total)
	for _, v in pairs(tableList) do wipe(v) end
	wipe(BNTable)
	wipe(clientSorted)

	local bnIndex = 0

	for i = 1, total do
		local bnetIDAccount, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isBnetAFK, isBnetDND, _, noteText = BNGetFriendInfo(i)
		if isOnline then
			local numGameAccounts = BNGetNumFriendGameAccounts(i)
			if numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					local hasFocus, gameCharacterName, gameClient, realmName, _, faction, race, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy, guid = BNGetFriendGameAccountInfo(i, y)
					bnIndex = PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, gameCharacterName, bnetIDGameAccount, gameClient, isOnline, isBnetAFK or isGameAFK, isBnetDND or isGameBusy, noteText, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus)
				end
			else
				bnIndex = PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText)
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
	DT.tooltip:Hide()

	local db = E.global.datatexts.settings.Friends
	if btn == "RightButton" then
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		if not db.hideWoW then
			for _, info in ipairs(friendTable) do
				if info[5] then
					local shouldSkip = false
					if (info[6] == statusTable[1]) and db.hideAFK then
						shouldSkip = true
					elseif (info[6] == statusTable[2]) and db.hideDND then
						shouldSkip = true
					end
					if not shouldSkip then
						local classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info[2])
						classc = classc or GetQuestDifficultyColor(info[2])

						menuCountWhispers = menuCountWhispers + 1
						menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1], notCheckable=true, func = whisperClick}
						if not (UnitInParty(info[1]) or UnitInRaid(info[1])) then
							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1], arg2 = info[8], notCheckable=true, func = inviteClick}
						end
					end
				end
			end
		end

		for _, info in ipairs(BNTable) do
			if info[7] then
				local shouldSkip = false
				if (info[8] == true) and db.hideAFK then
					shouldSkip = true
				elseif (info[9] == true) and db.hideDND then
					shouldSkip = true
				end
				if info[6] and db['hide'..info[6]] then
					shouldSkip = true
				end
				if not shouldSkip then
					local realID, hasBnet = info[2], false

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

					if info[6] == wowString and (E.myfaction == info[12]) and not (UnitInParty(info[4]) or UnitInRaid(info[4])) then
						local classc, levelc = E:ClassColor(info[14]), GetQuestDifficultyColor(info[16])
						classc = classc or GetQuestDifficultyColor(info[16])

						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[16],classc.r*255,classc.g*255,classc.b*255,info[4]), arg1 = info[5], arg2 = info[17], notCheckable=true, func = inviteClick}
					end
				end
			end
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menuList, DT.EasyMenu, nil, nil, nil, "MENU")
	elseif InCombatLockdown() then
		_G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT)
	else
		ToggleFriendsFrame(1) -- Only open the FriendsTab here. Cause stupid Blizz
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

	local db = E.global.datatexts.settings.Friends
	if not dataValid then
		-- only retrieve information for all on-line members when we actually view the tooltip
		if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
		if totalBNet > 0 then BuildBNTable(totalBNet) end
		dataValid = true
	end

	local totalfriends = numberOfFriends + totalBNet
	local zonec, classc, levelc, realmc, grouped
	local shiftDown = IsShiftKeyDown()

	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if (onlineFriends > 0) and not db.hideWoW then
		for _, info in ipairs(friendTable) do
			if info[5] then
				local shouldSkip = false
				if (info[6] == statusTable[1]) and db.hideAFK then
					shouldSkip = true
				elseif (info[6] == statusTable[2]) and db.hideDND then
					shouldSkip = true
				end
				if not shouldSkip then
					if E.MapInfo.zoneText and (E.MapInfo.zoneText == info[4]) then zonec = activezone else zonec = inactivezone end
					classc, levelc = E:ClassColor(info[3]), GetQuestDifficultyColor(info[2])

					classc = classc or GetQuestDifficultyColor(info[2])

					if UnitInParty(info[1]) or UnitInRaid(info[1]) then grouped = 1 else grouped = 2 end
					TooltipAddXLine(true, characterFriend, format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],info[1],groupedTable[grouped],info[6]),info[4],classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
				end
			end
		end
	end

	if numBNetOnline > 0 then
		local status
		for _, client in ipairs(clientSorted) do
			local Table = tableList[client]
			local header = format("%s (%s)", battleNetString, clientTags[client] or client)
			local shouldSkip = db['hide'..client]
			if not shouldSkip then
				for _, info in ipairs(Table) do
					if info[7] then
						shouldSkip = false
						if info[8] == true then
							if db.hideAFK then
								shouldSkip = true
							end
							status = statusTable[1]
						elseif info[9] == true then
							if db.hideDND then
								shouldSkip = true
							end
							status = statusTable[2]
						else
							status = statusTable[3]
						end
						if not shouldSkip then
							if info[6] == wowString then
								classc = E:ClassColor(info[14])
								if info[16] ~= '' then
									levelc = GetQuestDifficultyColor(info[16])
								else
									levelc = PRIEST_COLOR
									classc = PRIEST_COLOR
								end

								--Sometimes the friend list is fubar with level 0 unknown friends
								if not classc then
									classc = PRIEST_COLOR
								end

								if UnitInParty(info[4]) or UnitInRaid(info[4]) then grouped = 1 else grouped = 2 end
								TooltipAddXLine(true, header, format(levelNameString.."%s%s",levelc.r*255,levelc.g*255,levelc.b*255,info[16],classc.r*255,classc.g*255,classc.b*255,info[4],groupedTable[grouped],status),info[2],238,238,238,238,238,238)
								if shiftDown then
									if E.MapInfo.zoneText and (E.MapInfo.zoneText == info[15]) then zonec = activezone else zonec = inactivezone end
									if GetRealmName() == info[11] then realmc = activezone else realmc = inactivezone end
									TooltipAddXLine(true, header, info[15], info[11], zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
								end
							else
								TooltipAddXLine(true, header, info[4]..status, info[2], .9, .9, .9, .9, .9, .9)
								if shiftDown and (info[18] and info[18] ~= '') and (info[6] and info[6] ~= "App" and info[6] ~= "BSAp") then
									TooltipAddXLine(false, header, info[18], inactivezone.r, inactivezone.g, inactivezone.b)
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
	if event == "CHAT_MSG_SYSTEM" then
		if not (strfind(message, friendOnline) or strfind(message, friendOffline)) then return end
	end
	-- force update when showing tooltip
	dataValid = false

	if not IsAltKeyDown() and event == 'MODIFIER_STATE_CHANGED' and GetMouseFocus() == self then
		OnEnter(self)
	end

	self.text:SetFormattedText(displayString, onlineFriends + numBNetOnline)
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = E.global.datatexts.settings.Friends.NoLabel and hex.."%d|r" or strjoin("", _G.FRIENDS, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Friends', _G.SOCIAL_LABEL, {'BN_FRIEND_ACCOUNT_ONLINE', 'BN_FRIEND_ACCOUNT_OFFLINE', 'BN_FRIEND_INFO_CHANGED', 'FRIENDLIST_UPDATE', 'CHAT_MSG_SYSTEM', 'MODIFIER_STATE_CHANGED'}, OnEvent, nil, Click, OnEnter, nil, _G.FRIENDS, nil, ValueColorUpdate)
