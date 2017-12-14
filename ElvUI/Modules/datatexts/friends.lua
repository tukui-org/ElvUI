local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local type, ipairs, pairs, select = type, ipairs, pairs, select
local sort, wipe, tremove = table.sort, wipe, tremove
local format, find, join, gsub = string.format, string.find, string.join, string.gsub
--WoW API / Variables
local BNSetCustomMessage = BNSetCustomMessage
local BNGetInfo = BNGetInfo
local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local SendChatMessage = SendChatMessage
local InviteUnit = InviteUnit
local BNInviteFriend = BNInviteFriend
local ChatFrame_SendSmartTell = ChatFrame_SendSmartTell
local SetItemRef = SetItemRef
local GetFriendInfo = GetFriendInfo
local BNGetFriendInfo = BNGetFriendInfo
local BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
local GetNumFriends = GetNumFriends
local BNGetNumFriends = BNGetNumFriends
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitFactionGroup = UnitFactionGroup
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local ToggleFriendsFrame = ToggleFriendsFrame
local L_EasyMenu = L_EasyMenu
local IsShiftKeyDown = IsShiftKeyDown
local GetRealmName = GetRealmName
local GetCurrentMapAreaID = GetCurrentMapAreaID
local BNGetNumFriendGameAccounts = BNGetNumFriendGameAccounts
local BNGetFriendGameAccountInfo = BNGetFriendGameAccountInfo
local GetDisplayedInviteType = GetDisplayedInviteType
local BNRequestInviteFriend = BNRequestInviteFriend
local FRIENDS = FRIENDS
local AFK = AFK
local DND = DND
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: CUSTOM_CLASS_COLORS

-- create a popup
E.PopupDialogs.SET_BN_BROADCAST = {
	text = BN_BROADCAST_TOOLTIP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
	OnShow = function(self) self.editBox:SetText(select(4, BNGetInfo()) ) self.editBox:SetFocus() end,
	OnHide = ChatEdit_FocusActiveWindow,
	EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3
}

local menuFrame = CreateFrame("Frame", "FriendDatatextRightClickMenu", E.UIParent, "L_UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = INVITE, hasArrow = true, notCheckable=true, },
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true, },
	{ text = PLAYER_STATUS, hasArrow = true, notCheckable=true,
		menuList = {
			{ text = "|cff2BC226"..AVAILABLE.."|r", notCheckable=true, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffE7E716"..DND.."|r", notCheckable=true, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffFF0000"..AFK.."|r", notCheckable=true, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end },
		},
	},
	{ text = BN_BROADCAST_TOOLTIP, notCheckable=true, func = function() E:StaticPopup_Show("SET_BN_BROADCAST") end },
}

local function inviteClick(self, name, guid)
	menuFrame:Hide()

	if not name then return end
	if type(name) ~= 'number' then
		InviteUnit(name)
	elseif guid then
		local inviteType = GetDisplayedInviteType(guid)
		if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
			BNInviteFriend(name)
		elseif inviteType == "REQUEST_INVITE" then
			BNRequestInviteFriend(name)
		end
	end
end

local function whisperClick(self, name, battleNet)
	menuFrame:Hide()

	if battleNet then
		ChatFrame_SendSmartTell(name)
	else
		SetItemRef( "player:"..name, format("|Hplayer:%1$s|h[%1$s]|h",name), "LeftButton" )
	end
end

local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"
local worldOfWarcraftString = WORLD_OF_WARCRAFT
local battleNetString = BATTLENET_OPTIONS_LABEL
local wowString = BNET_CLIENT_WOW
local totalOnlineString = join("", FRIENDS_LIST_ONLINE, ": %s/%s")
local tthead = {r=0.4, g=0.78, b=1}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = ''
local statusTable = { " |cffFFFFFF[|r|cffFF9900"..L["AFK"].."|r|cffFFFFFF]|r", " |cffFFFFFF[|r|cffFF3333"..L["DND"].."|r|cffFFFFFF]|r", "" }
local groupedTable = { "|cffaaaaaa*|r", "" }
local friendTable, BNTable, tableList = {}, {}, {}
local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS,"\124Hplayer:%%s\124h%[%%s%]\124h",""), gsub(ERR_FRIEND_OFFLINE_S,"%%s","")
local dataValid = false
local lastPanel

local clientTags = {
	[BNET_CLIENT_WOW] = "WoW",
	[BNET_CLIENT_SC2] = "SC2",
	[BNET_CLIENT_D3] = "D3",
	[BNET_CLIENT_WTCG] = "HS",
	[BNET_CLIENT_HEROES] = "HotS",
	[BNET_CLIENT_OVERWATCH] = "OW",
	[BNET_CLIENT_SC] = "SC",
	[BNET_CLIENT_DESTINY2] = "Dst2",
	["BSAp"] = L["Mobile"],
}

local function SortAlphabeticName(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function BuildFriendTable(total)
	wipe(friendTable)
	local name, level, class, area, connected, status, note
	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i)

		if status == "<"..AFK..">" then
			status = statusTable[1]
		elseif status == "<"..DND..">" then
			status = statusTable[2]
		else
			status = statusTable[3]
		end

		if connected then
			--other non-english locales require this
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end

			friendTable[i] = { name, level, class, area, connected, status, note }
		end
	end
	sort(friendTable, SortAlphabeticName)
end

--Sort alphabetic by battleTag
local function Sort(a, b)
	if a[3] and b[3] then
		return a[3] < b[3]
	end
end

local function AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText)
	if class and class ~= "" then --other non-english locales require this
		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
		for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
	end

	characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or "";
	BNTable[bnIndex] = { bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText }

	if tableList[client] then
		tableList[client][#tableList[client]+1] = BNTable[bnIndex]
	else
		tableList[client] = {}
		tableList[client][1] = BNTable[bnIndex]
	end
end

local function PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus)
	-- `hasFocus` is not added to BNTable[i]; we only need this to keep our friends datatext in sync with the friends list
	local isAdded, bnInfo = 0
	for i = 1, bnIndex do
		isAdded, bnInfo = 0, BNTable[i]
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
						tremove(tableList[bnInfo[6]], n);
						break -- remove the old one from tableList
					end
				end
			end
			AddToBNTable(i, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText)
		end
		if isAdded ~= 0 then
			break
		end
	end
	if isAdded ~= 0 then
		return bnIndex
	end

	bnIndex = bnIndex + 1 --bump the index one for a new addition
	AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, realmName, faction, race, class, zoneName, level, guid, gameText)

	return bnIndex
end

local function BuildBNTable(total)
	for _, v in pairs(tableList) do wipe(v) end
	wipe(BNTable)

	local bnIndex = 0
	local _, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText
	local hasFocus, gameCharacterName, gameClient, realmName, faction, race, class, zoneName, level, isGameAFK, isGameBusy, guid, gameText
	local numGameAccounts

	for i = 1, total do
		bnetIDAccount, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isBnetAFK, isBnetDND, _, noteText = BNGetFriendInfo(i);
		if isOnline then
			numGameAccounts = BNGetNumFriendGameAccounts(i);
			if numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					hasFocus, gameCharacterName, gameClient, realmName, _, faction, race, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy, guid = BNGetFriendGameAccountInfo(i, y);
					bnIndex = PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, gameCharacterName, bnetIDGameAccount, gameClient, isOnline, isBnetAFK or isGameAFK, isBnetDND or isGameBusy, noteText, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus);
				end
			else
				bnIndex = PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText);
			end
		end
	end

	sort(BNTable, Sort)
	for _, v in pairs(tableList) do sort(v, Sort) end
end

local function OnEvent(self, event, message)
	local _, onlineFriends = GetNumFriends()
	local _, numBNetOnline = BNGetNumFriends()

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the
	-- datatext information
	if event == "CHAT_MSG_SYSTEM" then
		if not (find(message, friendOnline) or find(message, friendOffline)) then return end
	end

	-- force update when showing tooltip
	dataValid = false

	self.text:SetFormattedText(displayString, FRIENDS, onlineFriends + numBNetOnline)
	lastPanel = self
end

local function Click(self, btn)
	DT.tooltip:Hide()

	if btn == "RightButton" then
		local menuCountWhispers = 0
		local menuCountInvites = 0
		local classc, levelc, info

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		if #friendTable > 0 then
			for i = 1, #friendTable do
				info = friendTable[i]
				if info[5] then
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					classc = classc or GetQuestDifficultyColor(info[2]);

					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1], notCheckable=true, func = whisperClick}
					if not (UnitInParty(info[1]) or UnitInRaid(info[1])) then
						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1], notCheckable=true, func = inviteClick}
					end
				end
			end
		end

		if #BNTable > 0 then
			local realID, hasBnet
			for i = 1, #BNTable do
				info = BNTable[i]
				if info[7] then
					realID, hasBnet = info[2], false

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

					if info[6] == wowString and (UnitFactionGroup("player") == info[12]) and not (UnitInParty(info[4]) or UnitInRaid(info[4])) then
						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[14]], GetQuestDifficultyColor(info[16])
						classc = classc or GetQuestDifficultyColor(info[16])

						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[16],classc.r*255,classc.g*255,classc.b*255,info[4]), arg1 = info[5], arg2 = info[17], notCheckable=true, func = inviteClick}
					end
				end
			end
		end

		L_EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		ToggleFriendsFrame()
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
	local zonec, classc, levelc, realmc, info, grouped
	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if onlineFriends > 0 then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(worldOfWarcraftString)
		for i = 1, #friendTable do
			info = friendTable[i]
			if info[5] then
				if E:GetZoneText(GetCurrentMapAreaID()) == info[4] then zonec = activezone else zonec = inactivezone end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])

				classc = classc or GetQuestDifficultyColor(info[2])

				if UnitInParty(info[1]) or UnitInRaid(info[1]) then grouped = 1 else grouped = 2 end
				DT.tooltip:AddDoubleLine(format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],info[1],groupedTable[grouped],info[6]),info[4],classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
			end
		end
	end

	if numBNetOnline > 0 then
		local status
		for client, Table in pairs(tableList) do
			if #Table > 0 then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(format("%s (%s)", battleNetString, clientTags[client] or client))
				for i = 1, #Table do
					info = Table[i]
					if info[7] then
						if info[8] == true then
							status = statusTable[1]
						elseif info[9] == true then
							status = statusTable[2]
						else
							status = statusTable[3]
						end
						if info[6] == wowString then
							classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[14]]
							if info[16] ~= '' then
								levelc = GetQuestDifficultyColor(info[16])
							else
								levelc = RAID_CLASS_COLORS["PRIEST"]
								classc = RAID_CLASS_COLORS["PRIEST"]
							end

							--Sometimes the friend list is fubar with level 0 unknown friends
							if not classc then
								classc = RAID_CLASS_COLORS["PRIEST"]
							end

							if UnitInParty(info[4]) or UnitInRaid(info[4]) then grouped = 1 else grouped = 2 end
							DT.tooltip:AddDoubleLine(format(levelNameString.."%s%s",levelc.r*255,levelc.g*255,levelc.b*255,info[16],classc.r*255,classc.g*255,classc.b*255,info[4],groupedTable[grouped],status),info[2],238,238,238,238,238,238)
							if IsShiftKeyDown() then
								if E:GetZoneText(GetCurrentMapAreaID()) == info[15] then zonec = activezone else zonec = inactivezone end
								if GetRealmName() == info[11] then realmc = activezone else realmc = inactivezone end
								DT.tooltip:AddDoubleLine(info[15], info[11], zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
							end
						else
							DT.tooltip:AddDoubleLine(info[4]..status, info[2], .9, .9, .9, .9, .9, .9)
							if IsShiftKeyDown() and (info[18] and info[18] ~= '') and (info[6] and info[6] ~= "App" and info[6] ~= "BSAp") then
								DT.tooltip:AddLine(info[18], inactivezone.r, inactivezone.g, inactivezone.b)
							end
						end
					end
				end
			end
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Friends', {'PLAYER_ENTERING_WORLD', "BN_FRIEND_ACCOUNT_ONLINE", "BN_FRIEND_ACCOUNT_OFFLINE", "BN_FRIEND_INFO_CHANGED", "BN_FRIEND_TOON_ONLINE",
"BN_FRIEND_TOON_OFFLINE", "BN_TOON_NAME_UPDATED", "FRIENDLIST_UPDATE", "CHAT_MSG_SYSTEM"}, OnEvent, nil, Click, OnEnter, nil, FRIENDS)
