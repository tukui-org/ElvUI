local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CH = E:NewModule('Chat', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local _G = _G
local wipe, time, difftime = wipe, time, difftime
local pairs, unpack, select, tostring, pcall, next, tonumber, type = pairs, unpack, select, tostring, pcall, next, tonumber, type
local tinsert, tremove, tconcat = table.insert, table.remove, table.concat
local gsub, find, gmatch, format, split = string.gsub, string.find, string.gmatch, string.format, string.split
local strlower, strsub, strlen, strupper, strtrim, strmatch = strlower, strsub, strlen, strupper, strtrim, strmatch
--WoW API / Variables
local Ambiguate = Ambiguate
local BetterDate = BetterDate
local BNet_GetClientEmbeddedTexture = BNet_GetClientEmbeddedTexture
local BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
local BNGetFriendGameAccountInfo = BNGetFriendGameAccountInfo
local BNGetFriendInfo = BNGetFriendInfo
local BNGetFriendInfoByID = BNGetFriendInfoByID
local BNGetGameAccountInfo = BNGetGameAccountInfo
local BNGetNumFriendGameAccounts = BNGetNumFriendGameAccounts
local BNGetNumFriendInvites = BNGetNumFriendInvites
local BNGetNumFriends = BNGetNumFriends
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget
local ChatFrame_CanChatGroupPerformExpressionExpansion = ChatFrame_CanChatGroupPerformExpressionExpansion
local ChatFrame_ConfigEventHandler = ChatFrame_ConfigEventHandler
local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture
local ChatFrame_SendTell = ChatFrame_SendTell
local ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local Chat_GetChatCategory = Chat_GetChatCategory
local CreateFrame = CreateFrame
local CreateAnimationGroup = CreateAnimationGroup
local C_LFGList_GetActivityInfo = C_LFGList.GetActivityInfo
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_SocialGetLastItem = C_Social.GetLastItem
local C_SocialIsSocialEnabled = C_Social.IsSocialEnabled
local C_SocialQueue_GetGroupMembers = C_SocialQueue.GetGroupMembers
local C_SocialQueue_GetGroupQueues = C_SocialQueue.GetGroupQueues
local C_VoiceChat_SetPortraitTexture = C_VoiceChat.SetPortraitTexture
local C_VoiceChat_GetMemberName = C_VoiceChat.GetMemberName
local Voice_GetVoiceChannelNotificationColor = Voice_GetVoiceChannelNotificationColor
local FCFManager_ShouldSuppressMessage = FCFManager_ShouldSuppressMessage
local FCFManager_ShouldSuppressMessageFlash = FCFManager_ShouldSuppressMessageFlash
local FCFTab_UpdateAlpha = FCFTab_UpdateAlpha
local FCF_Close = FCF_Close
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_StartAlertFlash = FCF_StartAlertFlash
local FlashClientIcon = FlashClientIcon
local FloatingChatFrame_OnEvent = FloatingChatFrame_OnEvent
local GetAchievementInfo = GetAchievementInfo
local GetAchievementInfoFromHyperlink = GetAchievementInfoFromHyperlink
local GetBNPlayerLink = GetBNPlayerLink
local GetChannelName = GetChannelName
local GetCursorPosition = GetCursorPosition
local GetCVar, GetCVarBool = GetCVar, GetCVarBool
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetItemInfoFromHyperlink = GetItemInfoFromHyperlink
local GetMouseFocus = GetMouseFocus
local GetNumGroupMembers = GetNumGroupMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetPlayerLink = GetPlayerLink
local GetRaidRosterInfo = GetRaidRosterInfo
local GetTime = GetTime
local GMChatFrame_IsGM = GMChatFrame_IsGM
local GMError = GMError
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsInInstance, IsInRaid, IsInGroup = IsInInstance, IsInRaid, IsInGroup
local IsMouseButtonDown = IsMouseButtonDown
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local PlaySoundFile = PlaySoundFile
local RemoveExtraSpaces = RemoveExtraSpaces
local RemoveNewlines = RemoveNewlines
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local SocialQueueUtil_GetRelationshipInfo = SocialQueueUtil_GetRelationshipInfo
local SocialQueueUtil_GetQueueName = SocialQueueUtil_GetQueueName
local SocialQueueUtil_SortGroupMembers = SocialQueueUtil_SortGroupMembers
local Social_GetShareAchievementLink = Social_GetShareAchievementLink
local Social_GetShareItemLink = Social_GetShareItemLink
local StaticPopup_Visible = StaticPopup_Visible
local ToggleFrame = ToggleFrame
local ToggleQuickJoinPanel = ToggleQuickJoinPanel
local UnitExists, UnitIsUnit = UnitExists, UnitIsUnit
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitName = UnitName
local UnitRealmRelationship = UnitRealmRelationship
local Chat_ShouldColorChatByClass = Chat_ShouldColorChatByClass
local C_Club_GetInfoFromLastCommunityChatLine = C_Club.GetInfoFromLastCommunityChatLine
local ChatFrame_ResolvePrefixedChannelName = ChatFrame_ResolvePrefixedChannelName
local GetBNPlayerCommunityLink = GetBNPlayerCommunityLink
local GetPlayerCommunityLink = GetPlayerCommunityLink
local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local LE_REALM_RELATION_SAME = LE_REALM_RELATION_SAME
local LFG_LIST_AND_MORE = LFG_LIST_AND_MORE
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local SOCIAL_QUEUE_QUEUED_FOR = gsub(SOCIAL_QUEUE_QUEUED_FOR, ':%s?$', '') --some language have `:` on end
local SOUNDKIT = SOUNDKIT
local UNKNOWN = UNKNOWN

--Variables that are only used in ChatFrame_MessageEventHandler
--Store them in a table as we would otherwise hit the "max 60 upvalues" limit
local GlobalStrings = {
	["AFK"] = AFK,
	["BN_INLINE_TOAST_BROADCAST"] = BN_INLINE_TOAST_BROADCAST,
	["BN_INLINE_TOAST_BROADCAST_INFORM"] = BN_INLINE_TOAST_BROADCAST_INFORM,
	["BN_INLINE_TOAST_FRIEND_PENDING"] = BN_INLINE_TOAST_FRIEND_PENDING,
	["CHAT_FILTERED"] = CHAT_FILTERED,
	["CHAT_IGNORED"] = CHAT_IGNORED,
	["CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE"] = CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE,
	["CHAT_RESTRICTED_TRIAL"] = CHAT_RESTRICTED_TRIAL,
	["CHAT_TELL_ALERT_TIME"] = CHAT_TELL_ALERT_TIME,
	["CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL"] = CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL,
	["DND"] = DND,
	["ERR_CHAT_PLAYER_NOT_FOUND_S"] = ERR_CHAT_PLAYER_NOT_FOUND_S,
	["ERR_FRIEND_OFFLINE_S"] = ERR_FRIEND_OFFLINE_S,
	["ERR_FRIEND_ONLINE_SS"] = ERR_FRIEND_ONLINE_SS,
	["PLAYER_LIST_DELIMITER"] = PLAYER_LIST_DELIMITER,
	["RAID_WARNING"] = RAID_WARNING,
}

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LeftChatDataPanel, ElvCharacterDB, GeneralDockManager
-- GLOBALS: LeftChatPanel, LeftChatToggleButton, ChatFrame1, ChatTypeInfo, ChatMenu
-- GLOBALS: CopyChatFrame, CopyChatFrameEditBox, CHAT_FRAMES, LeftChatTab, RightChatPanel
-- GLOBALS: CopyChatScrollFrame, CopyChatScrollFrameScrollBar, RightChatDataPanel
-- GLOBALS: GeneralDockManagerOverflowButton, CombatLogQuickButtonFrame_Custom
-- GLOBALS: UIParent, GeneralDockManagerScrollFrameChild, GameTooltip, CHAT_OPTIONS
-- GLOBALS: LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE
-- GLOBALS: ICON_TAG_LIST, ICON_LIST, GROUP_TAG_LIST, DEFAULT_CHAT_FRAME, ChatFrameMenuButton
-- GLOBALS: WIM, ChatTypeGroup, GeneralDockManagerOverflowButtonList, GeneralDockManagerScrollFrame
-- GLOBALS: CombatLogQuickButtonFrame_CustomAdditionalFilterButton, UISpecialFrames, ChatFontNormal
-- GLOBALS: ChatFrame_AddMessageEventFilter, ChatFrame_GetMessageEventFilters, QuickJoinFrame
-- GLOBALS: CombatLogQuickButtonFrame_CustomTexture, CUSTOM_CLASS_COLORS

local CreatedFrames = 0;
local lines = {};
local lfgRoles = {};
local msgList, msgCount, msgTime = {}, {}, {}

local PLAYER_REALM = gsub(E.myrealm,'[%s%-]','')
local PLAYER_NAME = E.myname.."-"..PLAYER_REALM

local DEFAULT_STRINGS = {
	GUILD = L["G"],
	PARTY = L["P"],
	RAID = L["R"],
	OFFICER = L["O"],
	PARTY_LEADER = L["PL"],
	RAID_LEADER = L["RL"],
	INSTANCE_CHAT = L["I"],
	INSTANCE_CHAT_LEADER = L["IL"],
	PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG,
}

local hyperlinkTypes = {
	['item'] = true,
	['spell'] = true,
	['unit'] = true,
	['quest'] = true,
	['enchant'] = true,
	['achievement'] = true,
	['instancelock'] = true,
	['talent'] = true,
	['glyph'] = true,
	["currency"] = true,
}

local tabTexs = {
	'',
	'Selected',
	'Highlight'
}

CH.Smileys = {}
function CH:RemoveSmiley(key)
	if key and (type(key) == 'string') then
		CH.Smileys[key] = nil
	end
end

function CH:AddSmiley(key, texture)
	if key and (type(key) == 'string') and texture then
		CH.Smileys[key] = texture
	end
end

local rolePaths = {
	TANK = [[|TInterface\AddOns\ElvUI\media\textures\tank:15:15:0:0:64:64:2:56:2:56|t]],
	HEALER = [[|TInterface\AddOns\ElvUI\media\textures\healer:15:15:0:0:64:64:2:56:2:56|t]],
	DAMAGER = [[|TInterface\AddOns\ElvUI\media\textures\dps:15:15|t]]
}

local specialChatIcons
do --this can save some main file locals
	local IconPath		= "|TInterface\\AddOns\\ElvUI\\media\\textures\\chatLogos\\"
	--local ElvPink		= IconPath.."elvui_pink:13:25|t"
	local ElvPurple		= IconPath.."elvui_purple:13:25|t"
	local ElvBlue		= IconPath.."elvui_blue:13:25|t"
	local ElvGreen		= IconPath.."elvui_green:13:25|t"
	local ElvOrange		= IconPath.."elvui_orange:13:25|t"
	local ElvRed		= IconPath.."elvui_red:13:25|t"
	local ElvRainbow	= IconPath.."elvui_rainbow:13:25|t"
	local Bathrobe		= IconPath.."bathrobe:15:15|t"
	local MrHankey		= IconPath.."mr_hankey:16:18|t"
	specialChatIcons = {
		-- Elv --
		["Illidelv-Area52"]		= ElvBlue,
		["Elvz-Kil'jaeden"]		= ElvBlue,
		["Elv-Spirestone"]		= ElvBlue,
		-- Tirain --
		["Tierone-Spirestone"] = "Dr. ", -- lol
		["Tirain-Spirestone"]	= MrHankey,
		["Sinth-Spirestone"]	= MrHankey,
		-- Whiro --
		["Zistraeti-WyrmrestAccord"]	= ElvPurple, -- Warlock
		-- Merathilis Toons --
		["Asragoth-Shattrath"]		= ElvPurple,	-- Warlock [Alliance]
		["Damará-Shattrath"]		= ElvRed,		-- Paladin [Alliance]
		["Jazira-Shattrath"]		= ElvBlue,		-- Priest [Alliance]
		["Maithilis-Shattrath"]		= ElvGreen,		-- Monk [Alliance]
		["Mattdemôn-Shattrath"]		= ElvPurple,	-- Demon Hunter [Alliance]
		["Melisendra-Shattrath"]	= ElvBlue,		-- Mage [Alliance]
		["Merathilis-Garrosh"]		= ElvOrange,	-- Druid [Horde]
		["Merathilis-Shattrath"]	= ElvOrange,	-- Druid [Alliance]
		["Merathilîs-Shattrath"]	= ElvBlue,		-- Shaman [Alliance]
		-- Affinity's Toons --
		["Affinichi-Illidan"]	= Bathrobe,
		["Affinitii-Illidan"]	= Bathrobe,
		["Affinity-Illidan"]	= Bathrobe,
		["Uplift-Illidan"]		= Bathrobe,
		-- Blazeflack's Toons --
		["Blazii-Silvermoon"]	= ElvBlue, -- Priest
		["Chazii-Silvermoon"]	= ElvBlue, -- Shaman
		-- Simpy's Toons --
		["Arieva-Cenarius"]		= ElvRainbow, -- Hunter
		["Buddercup-Cenarius"]	= ElvRainbow, -- Rogue
		["Cutepally-Cenarius"]	= ElvRainbow, -- Paladin
		["Ezek-Cenarius"]		= ElvRainbow, -- DK
		["Glice-Cenarius"]		= ElvRainbow, -- Warrior
		["Kalline-Cenarius"]	= ElvRainbow, -- Shaman
		["Puttietat-Cenarius"]	= ElvRainbow, -- Druid
		["Simpy-Cenarius"]		= ElvRainbow, -- Warlock
		["Twigly-Cenarius"]		= ElvRainbow, -- Monk
		["Imsojelly-Cenarius"]	= ElvRainbow, -- [Horde] DK
		["Imsojuicy-Cenarius"]	= ElvRainbow, -- [Horde] Druid
		["Imsopeachy-Cenarius"]	= ElvRainbow, -- [Horde] DH
		["Imsosalty-Cenarius"]	= ElvRainbow, -- [Horde] Paladin
		["Imsospicy-Cenarius"]	= ElvRainbow, -- [Horde] Mage
		["Bunne-CenarionCircle"]		= ElvRainbow, -- Warrior
		["Loppybunny-CenarionCircle"]	= ElvRainbow, -- Mage
		["Rubee-CenarionCircle"]		= ElvRainbow, -- DH
		["Wennie-CenarionCircle"]		= ElvRainbow, -- Priest
	}
end

CH.Keywords = {}
CH.ClassNames = {}

local numScrollMessages
local function ChatFrame_OnMouseScroll(frame, delta)
	numScrollMessages = CH.db.numScrollMessages or 3
	if delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		elseif IsAltKeyDown() then
			frame:ScrollDown()
		else
			for i = 1, numScrollMessages do
				frame:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		elseif IsAltKeyDown() then
			frame:ScrollUp()
		else
			for i = 1, numScrollMessages do
				frame:ScrollUp()
			end
		end

		if CH.db.scrollDownInterval ~= 0 then
			if frame.ScrollTimer then
				CH:CancelTimer(frame.ScrollTimer, true)
			end

			frame.ScrollTimer = CH:ScheduleTimer('ScrollToBottom', CH.db.scrollDownInterval, frame)
		end
	end
end

function CH:GetGroupDistribution()
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp") then
		return "/bg "
	end
	if IsInRaid() then
		return "/ra "
	end
	if IsInGroup() then
		return "/p "
	end
	return "/s "
end

function CH:InsertEmotions(msg)
	local emoji, pattern
	for word in gmatch(msg, "%s-%S+%s*") do
		pattern = gsub(strtrim(word), '([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
		emoji = CH.Smileys[pattern]
		if emoji and strmatch(msg, '[%s%p]-'..pattern..'[%s%p]*') then
			msg = gsub(msg, '([%s%p]-)'..pattern..'([%s%p]*)', '%1'..emoji..'%2');
		end
	end

	return msg
end

function CH:GetSmileyReplacementText(msg)
	if not msg or not self.db.emotionIcons or find(msg, '/run') or find(msg, '/dump') or find(msg, '/script') then return msg end
	local outstr = "";
	local origlen = strlen(msg);
	local startpos = 1;
	local endpos, _;

	while(startpos <= origlen) do
		endpos = origlen;
		local pos = find(msg,"|H",startpos,true);
		if(pos ~= nil) then
			endpos = pos;
		end
		outstr = outstr .. CH:InsertEmotions(strsub(msg,startpos,endpos)); --run replacement on this bit
		startpos = endpos + 1;
		if(pos ~= nil) then
			_, endpos = find(msg,"|h.-|h",startpos);
			endpos = endpos or origlen;
			if(startpos < endpos) then
				outstr = outstr .. strsub(msg,startpos,endpos); --don't run replacement on this bit
				startpos = endpos + 1;
			end
		end
	end

	return outstr;
end

function CH:StyleChat(frame)
	local name = frame:GetName()
	_G[name.."TabText"]:FontTemplate(LSM:Fetch("font", self.db.tabFont), self.db.tabFontSize, self.db.tabFontOutline)

	if frame.styled then return end

	frame:SetFrameLevel(4)

	local id = frame:GetID()

	local tab = _G[name..'Tab']
	local editbox = _G[name..'EditBox']
	local scroll = frame.ScrollBar
	local scrollToBottom = frame.ScrollToBottomButton
	local scrollTex = _G[name.."ThumbTexture"]

	for _, texName in pairs(tabTexs) do
		_G[tab:GetName()..texName..'Left']:SetTexture(nil)
		_G[tab:GetName()..texName..'Middle']:SetTexture(nil)
		_G[tab:GetName()..texName..'Right']:SetTexture(nil)
	end

	if scroll then
		scroll:Kill()
		scrollToBottom:Kill()
		scrollTex:Kill()
	end

	hooksecurefunc(tab, "SetAlpha", function(t, alpha)
		if alpha ~= 1 and (not t.isDocked or GeneralDockManager.selected:GetID() == t:GetID()) then
			t:SetAlpha(1)
		elseif alpha < 0.6 then
			t:SetAlpha(0.6)
		end
	end)

	tab.text = _G[name.."TabText"]
	tab.text:SetTextColor(unpack(E.media.rgbvaluecolor))
	hooksecurefunc(tab.text, "SetTextColor", function(self, r, g, b)
		local rR, gG, bB = unpack(E.media.rgbvaluecolor)
		if r ~= rR or g ~= gG or b ~= bB then
			self:SetTextColor(rR, gG, bB)
		end
	end)

	if tab.conversationIcon then
		tab.conversationIcon:ClearAllPoints()
		tab.conversationIcon:Point('RIGHT', tab.text, 'LEFT', -1, 0)
	end

	frame:SetClampRectInsets(0,0,0,0)
	frame:SetClampedToScreen(false)
	frame:StripTextures(true)
	_G[name..'ButtonFrame']:Kill()

	local function OnTextChanged(self)
		local text = self:GetText()

		if InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = E.db.chat.numAllowedCombatRepeat
			if (strlen(text) > MIN_REPEAT_CHARACTERS) then
			local repeatChar = true;
			for i=1, MIN_REPEAT_CHARACTERS, 1 do
				if ( strsub(text,(0-i), (0-i)) ~= strsub(text,(-1-i),(-1-i)) ) then
					repeatChar = false;
					break;
				end
			end
				if ( repeatChar ) then
					self:Hide()
					return;
				end
			end
		end

		if strlen(text) < 5 then
			if strsub(text, 1, 4) == "/tt " then
				local unitname, realm = UnitName("target")
				if unitname then unitname = gsub(unitname, " ", "") end
				if unitname and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
					unitname = format("%s-%s", unitname, gsub(realm, " ", ""))
				end
				ChatFrame_SendTell((unitname or L["Invalid Target"]), ChatFrame1)
			end

			if strsub(text, 1, 4) == "/gr " then
				self:SetText(CH:GetGroupDistribution() .. strsub(text, 5));
				ChatEdit_ParseText(self, 0)
			end
		end
	end

	--Work around broken SetAltArrowKeyMode API. Code from Prat
	local function OnArrowPressed(self, key)
		if #self.historyLines == 0 then
			return
		end

		if key == "DOWN" then
			self.historyIndex = self.historyIndex - 1

			if self.historyIndex < 1 then
				self.historyIndex = 0
				self:SetText("")
				return
			end
		elseif key == "UP" then
			self.historyIndex = self.historyIndex + 1

			if self.historyIndex > #self.historyLines then
				self.historyIndex = #self.historyLines
			end
		else
			return
		end
		self:SetText(self.historyLines[#self.historyLines - (self.historyIndex - 1)])
	end

	local a, b, c = select(6, editbox:GetRegions()); a:Kill(); b:Kill(); c:Kill()
	_G[format(editbox:GetName().."Left", id)]:Kill()
	_G[format(editbox:GetName().."Mid", id)]:Kill()
	_G[format(editbox:GetName().."Right", id)]:Kill()
	editbox:SetTemplate('Default', true)
	editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	editbox:SetAllPoints(LeftChatDataPanel)
	self:SecureHook(editbox, "AddHistoryLine", "ChatEdit_AddHistory")
	editbox:HookScript("OnTextChanged", OnTextChanged)

	--Work around broken SetAltArrowKeyMode API
	editbox.historyLines = ElvCharacterDB.ChatEditHistory
	editbox.historyIndex = 0
	editbox:HookScript("OnArrowPressed", OnArrowPressed)
	editbox:Hide()

	editbox:HookScript("OnEditFocusGained", function(self) self:Show(); if not LeftChatPanel:IsShown() then LeftChatPanel.editboxforced = true; LeftChatToggleButton:GetScript('OnEnter')(LeftChatToggleButton) end end)
	editbox:HookScript("OnEditFocusLost", function(self) if LeftChatPanel.editboxforced then LeftChatPanel.editboxforced = nil; if LeftChatPanel:IsShown() then LeftChatToggleButton:GetScript('OnLeave')(LeftChatToggleButton) end end self.historyIndex = 0; self:Hide() end)

	for _, text in pairs(ElvCharacterDB.ChatEditHistory) do
		editbox:AddHistoryLine(text)
	end

	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local chatType = editbox:GetAttribute("chatType")
		if not chatType then return end

		local chanTarget = editbox:GetAttribute("channelTarget")
		local chanName = chanTarget and GetChannelName(chanTarget)
		if chanName and (chatType == "CHANNEL") then
			if chanName == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				editbox:SetBackdropBorderColor(ChatTypeInfo[chatType..chanName].r,ChatTypeInfo[chatType..chanName].g,ChatTypeInfo[chatType..chanName].b)
			end
		else
			editbox:SetBackdropBorderColor(ChatTypeInfo[chatType].r,ChatTypeInfo[chatType].g,ChatTypeInfo[chatType].b)
		end
	end)

	if id ~= 2 then --Don't add timestamps to combat log, they don't work.
		--This usually taints, but LibChatAnims should make sure it doesn't.
		frame.OldAddMessage = frame.AddMessage
		frame.AddMessage = CH.AddMessage
	end

	--copy chat button
	frame.button = CreateFrame('Frame', format("CopyChatButton%d", id), frame)
	frame.button:EnableMouse(true)
	frame.button:SetAlpha(0.35)
	frame.button:Size(20, 22)
	frame.button:Point('TOPRIGHT')
	frame.button:SetFrameLevel(frame:GetFrameLevel() + 5)

	frame.button.tex = frame.button:CreateTexture(nil, 'OVERLAY')
	frame.button.tex:SetInside()
	frame.button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\copy]])

	frame.button:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" and id == 1 then
			ToggleFrame(ChatMenu)
		else
			CH:CopyChat(frame)
		end
	end)

	frame.button:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	frame.button:SetScript("OnLeave", function(self)
		if _G[self:GetParent():GetName().."TabText"]:IsShown() then
			self:SetAlpha(0.35)
		else
			self:SetAlpha(0)
		end
	end)

	CreatedFrames = id
	frame.styled = true
end

function CH:AddMessage(msg, infoR, infoG, infoB, infoID, accessID, typeID, isHistory, historyTime)
	local historyTimestamp --we need to extend the arguments on AddMessage so we can properly handle times without overriding
	if isHistory == "ElvUI_ChatHistory" then historyTimestamp = historyTime end

	if (CH.db.timeStampFormat and CH.db.timeStampFormat ~= 'NONE' ) then
		local timeStamp = BetterDate(CH.db.timeStampFormat, historyTimestamp or time());
		timeStamp = gsub(timeStamp, ' ', '')
		timeStamp = gsub(timeStamp, 'AM', ' AM')
		timeStamp = gsub(timeStamp, 'PM', ' PM')
		if CH.db.useCustomTimeColor then
			local color = CH.db.customTimeColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			msg = format("%s[%s]|r %s", hexColor, timeStamp, msg)
		else
			msg = format("[%s] %s", timeStamp, msg)
		end
	end

	if CH.db.copyChatLines then
		msg = format('|Hcpl:%s|h%s|h %s', self:GetID(), [[|TInterface\AddOns\ElvUI\media\textures\ArrowRight:14|t]], msg)
	end

	self.OldAddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID)
end

function CH:UpdateSettings()
	for i = 1, CreatedFrames do
		local chat = _G[format("ChatFrame%d", i)]
		local name = chat:GetName()
		local editbox = _G[name..'EditBox']
		editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	end
end

local removeIconFromLine
do
	local raidIconFunc = function(x) x = x~="" and _G["RAID_TARGET_"..x];return x and ("{"..strlower(x).."}") or "" end
	local stripTextureFunc = function(w, x, y) if x=="" then return (w~="" and w) or (y~="" and y) or "" end end
	local hyperLinkFunc = function(x, y) if x=="" then return y end end
	removeIconFromLine = function(text)
		text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d+):0|t", raidIconFunc) --converts raid icons into {star} etc, if possible.
		text = gsub(text, "(%s?)(|?)|T.-|t(%s?)", stripTextureFunc) --strip any other texture out but keep a single space from the side(s).
		text = gsub(text, "(|?)|H.-|h(.-)|h", hyperLinkFunc) --strip hyperlink data only keeping the actual text.
		return text
	end
end

local function colorizeLine(text, r, g, b)
	local hexCode = E:RGBToHex(r, g, b)
	local hexReplacement = format("|r%s", hexCode)

	text = gsub(text, "|r", hexReplacement) --If the message contains color strings then we need to add message color hex code after every "|r"
	text = format("%s%s|r", hexCode, text) --Add message color

	return text
end

function CH:GetLines(frame)
	local index = 1
	for i = 1, frame:GetNumMessages() do
		local message, r, g, b = frame:GetMessageInfo(i)

		--Set fallback color values
		r = r or 1
		g = g or 1
		b = b or 1

		--Remove icons
		message = removeIconFromLine(message)

		--Add text color
		message = colorizeLine(message, r, g, b)

		lines[index] = message
		index = index + 1
	end

	return index - 1
end

function CH:CopyChat(frame)
	if not CopyChatFrame:IsShown() then
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID());
		if fontSize < 10 then fontSize = 12 end
		FCF_SetChatWindowFontSize(frame, frame, 0.01)
		CopyChatFrame:Show()
		local lineCt = self:GetLines(frame)
		local text = tconcat(lines, " \n", 1, lineCt)
		FCF_SetChatWindowFontSize(frame, frame, fontSize)
		CopyChatFrameEditBox:SetText(text)
	else
		CopyChatFrame:Hide()
	end
end

function CH:OnEnter(frame)
	_G[frame:GetName().."Text"]:Show()

	if frame.conversationIcon then
		frame.conversationIcon:Show()
	end
end

function CH:OnLeave(frame)
	_G[frame:GetName().."Text"]:Hide()

	if frame.conversationIcon then
		frame.conversationIcon:Hide()
	end
end

function CH:SetupChatTabs(frame, hook)
	if hook and (not self.hooks or not self.hooks[frame] or not self.hooks[frame].OnEnter) then
		self:HookScript(frame, 'OnEnter')
		self:HookScript(frame, 'OnLeave')
	elseif not hook and self.hooks and self.hooks[frame] and self.hooks[frame].OnEnter then
		self:Unhook(frame, 'OnEnter')
		self:Unhook(frame, 'OnLeave')
	end

	if not hook then
		_G[frame:GetName().."Text"]:Show()

		if frame.owner and frame.owner.button and GetMouseFocus() ~= frame.owner.button then
			frame.owner.button:SetAlpha(0.35)
		end
		if frame.conversationIcon then
			frame.conversationIcon:Show()
		end
	elseif GetMouseFocus() ~= frame then
		_G[frame:GetName().."Text"]:Hide()

		if frame.owner and frame.owner.button and GetMouseFocus() ~= frame.owner.button then
			frame.owner.button:SetAlpha(0)
		end

		if frame.conversationIcon then
			frame.conversationIcon:Hide()
		end
	end
end

function CH:UpdateAnchors()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName..'EditBox']
		if not frame then break; end
		local noBackdrop = (self.db.panelBackdrop == "HIDEBOTH" or self.db.panelBackdrop == "RIGHT")
		frame:ClearAllPoints()
		if not E.db.datatexts.leftChatPanel and E.db.chat.editBoxPosition == 'BELOW_CHAT' then
			frame:Point("TOPLEFT", ChatFrame1, "BOTTOMLEFT", noBackdrop and -1 or -4, noBackdrop and -1 or -4)
			frame:Point("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", noBackdrop and 10 or 7, -LeftChatTab:GetHeight()-(noBackdrop and 1 or 4))
		elseif E.db.chat.editBoxPosition == 'BELOW_CHAT' then
			frame:SetAllPoints(LeftChatDataPanel)
		else
			frame:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", noBackdrop and -1 or -1, noBackdrop and 1 or 4)
			frame:Point("TOPRIGHT", ChatFrame1, "TOPRIGHT", noBackdrop and 10 or 4, LeftChatTab:GetHeight()+(noBackdrop and 1 or 4))
		end
	end

	CH:PositionChat(true)
end

local function FindRightChatID()
	local rightChatID

	for _, frameName in pairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		local id = chat:GetID()

		if E:FramesOverlap(chat, RightChatPanel) and not E:FramesOverlap(chat, LeftChatPanel) then
			rightChatID = id
			break
		end
	end

	return rightChatID
end

function CH:UpdateChatTabs()
	local fadeUndockedTabs = E.db.chat.fadeUndockedTabs
	local fadeTabsNoBackdrop = E.db.chat.fadeTabsNoBackdrop

	for i = 1, CreatedFrames do
		local chat = _G[format("ChatFrame%d", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local isDocked = chat.isDocked
		local chatbg = format("ChatFrame%dBackground", i)
		if id > NUM_CHAT_WINDOWS then
			if select(2, tab:GetPoint()):GetName() ~= chatbg then
				isDocked = true
			else
				isDocked = false
			end
		end

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and (id == self.RightChatWindowID) then
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'LEFT' then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not isDocked and chat:IsShown() then
			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'RIGHT' then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end
end

function CH:PositionChat(override)
	if ((InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override)) then return end
	if not RightChatPanel or not LeftChatPanel then return; end
	RightChatPanel:SetSize(E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth, E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight)
	LeftChatPanel:SetSize(E.db.chat.panelWidth, E.db.chat.panelHeight)

	self.RightChatWindowID = FindRightChatID()

	if not self.db.lockPositions or E.private.chat.enable ~= true then return end

	local chat, chatbg, tab, id, isDocked
	local fadeUndockedTabs = E.db.chat.fadeUndockedTabs
	local fadeTabsNoBackdrop = E.db.chat.fadeTabsNoBackdrop

	for i=1, CreatedFrames do
		local BASE_OFFSET = 57 + E.Spacing*3

		chat = _G[format("ChatFrame%d", i)]
		chatbg = format("ChatFrame%dBackground", i)
		id = chat:GetID()
		tab = _G[format("ChatFrame%sTab", i)]
		isDocked = chat.isDocked
		tab.isDocked = chat.isDocked
		tab.owner = chat

		if id > NUM_CHAT_WINDOWS then
			if select(2, tab:GetPoint()):GetName() ~= chatbg then
				isDocked = true
			else
				isDocked = false
			end
		end

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == self.RightChatWindowID then
			chat:ClearAllPoints()
			if E.db.datatexts.rightChatPanel then
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
			else
				BASE_OFFSET = BASE_OFFSET - 24
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "BOTTOMLEFT", 1, 1)
			end
			if id ~= 2 then
				chat:SetSize((E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth) - 11, (E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight) - BASE_OFFSET)
			else
				chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - BASE_OFFSET) - CombatLogQuickButtonFrame_Custom:GetHeight())
			end

			--Pass a 2nd argument which prevents an infinite loop in our ON_FCF_SavePositionAndDimensions function
			if chat:GetLeft() then
				FCF_SavePositionAndDimensions(chat, true)
			end

			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)

			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'LEFT' then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not isDocked and chat:IsShown() then
			tab:SetParent(UIParent)
			chat:SetParent(UIParent)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				chat:ClearAllPoints()
				if E.db.datatexts.leftChatPanel then
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
				else
					BASE_OFFSET = BASE_OFFSET - 24
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "BOTTOMLEFT", 1, 1)
				end
				chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - BASE_OFFSET))

				--Pass a 2nd argument which prevents an infinite loop in our ON_FCF_SavePositionAndDimensions function
				if chat:GetLeft() then
					FCF_SavePositionAndDimensions(chat, true)
				end
			end
			chat:SetParent(LeftChatPanel)
			if i > 2 then
				tab:SetParent(GeneralDockManagerScrollFrameChild)
			else
				tab:SetParent(GeneralDockManager)
			end
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end

			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'RIGHT' then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end

	E.Layout:RepositionChatDataPanels() --Bugfix: #686

	self.initialMove = true;
end

function CH:Panels_ColorUpdate()
	local panelColor = E.db.chat.panelColor
	LeftChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
	RightChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
end

local function UpdateChatTabColor(_, r, g, b)
	for i=1, CreatedFrames do
		_G['ChatFrame'..i..'TabText']:SetTextColor(r, g, b)
	end
end
E.valueColorUpdateFuncs[UpdateChatTabColor] = true

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()

	self:CancelTimer(frame.ScrollTimer, true)
end

function CH:PrintURL(url)
	return "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
end

function CH:FindURL(event, msg, ...)
	if (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER") and (CH.db.whisperSound ~= 'None') and not CH.SoundTimer then
		if (strsub(msg,1,3) == "OQ,") then return false, msg, ... end
		if (CH.db.noAlertInCombat and not InCombatLockdown()) or not CH.db.noAlertInCombat then
			PlaySoundFile(LSM:Fetch("sound", CH.db.whisperSound), "Master")
		end

		CH.SoundTimer = E:Delay(1, CH.ThrottleSound)
	end

	if not CH.db.url then
		msg = CH:CheckKeyword(msg);
		msg = CH:GetSmileyReplacementText(msg);
		return false, msg, ...
	end

	local text, tag = msg, strmatch(msg, '{(.-)}')
	if tag and ICON_TAG_LIST[strlower(tag)] then
		text = gsub(gsub(text, "(%S)({.-})", '%1 %2'), "({.-})(%S)", '%1 %2')
	end

	text = gsub(gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", '%1 %2'), "(|c.-|H.-|h.-|h|r)(%S)", '%1 %2')
	-- http://example.com
	local newMsg, found = gsub(text, "(%a+)://(%S+)%s?", CH:PrintURL("%1://%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- www.example.com
	newMsg, found = gsub(text, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", CH:PrintURL("www.%1.%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- example@example.com
	newMsg, found = gsub(text, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", CH:PrintURL("%1@%2%3%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- IP address with port 1.1.1.1:1
	newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", CH:PrintURL("%1.%2.%3.%4%5"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- IP address 1.1.1.1
	newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", CH:PrintURL("%1.%2.%3.%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end

	msg = CH:CheckKeyword(msg)
	msg = CH:GetSmileyReplacementText(msg)

	return false, msg, ...
end

local function SetChatEditBoxMessage(message)
	local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
	local editBoxShown = ChatFrameEditBox:IsShown()
	local editBoxText = ChatFrameEditBox:GetText()
	if not editBoxShown then
		ChatEdit_ActivateChat(ChatFrameEditBox)
	end
	if editBoxText and editBoxText ~= "" then
		ChatFrameEditBox:SetText('')
	end
	ChatFrameEditBox:Insert(message)
	ChatFrameEditBox:HighlightText()
end

local function HyperLinkedCPL(data)
	if strsub(data, 1, 3) == "cpl" then
		local chatID = strsub(data, 5)
		local chat = _G[format("ChatFrame%d", chatID)]
		if not chat then return end
		local scale = chat:GetEffectiveScale() --blizzard does this with `scale = UIParent:GetScale()`
		local cursorX, cursorY = GetCursorPosition()
		cursorX, cursorY = (cursorX / scale), (cursorY / scale)
		local _, lineIndex = chat:FindCharacterAndLineIndexAtCoordinate(cursorX, cursorY)
		if lineIndex then
			local visibleLine = chat.visibleLines and chat.visibleLines[lineIndex]
			local message = visibleLine and visibleLine.messageInfo and visibleLine.messageInfo.message
			if message and message ~= "" then
				message = gsub(message, '|c%x%x%x%x%x%x%x%x(.-)|r', '%1')
				message = strtrim(removeIconFromLine(message))
				SetChatEditBoxMessage(message)
			end
		end
		return
	end
end

local function HyperLinkedSQU(data)
	if strsub(data, 1, 3) == "squ" then
		if not QuickJoinFrame:IsShown() then
			ToggleQuickJoinPanel()
		end
		local guid = strsub(data, 5)
		if guid and guid ~= '' then
			QuickJoinFrame:SelectGroup(guid)
			QuickJoinFrame:ScrollToGroup(guid)
		end
		return
	end
end

local function HyperLinkedURL(data)
	if strsub(data, 1, 3) == "url" then
		local currentLink = strsub(data, 5)
		if currentLink and currentLink ~= "" then
			SetChatEditBoxMessage(currentLink)
		end
		return
	end
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(data, ...)
	if strsub(data, 1, 3) == "cpl" then
		HyperLinkedCPL(data)
	elseif strsub(data, 1, 3) == "squ" then
		HyperLinkedSQU(data)
	elseif strsub(data, 1, 3) == "url" then
		HyperLinkedURL(data)
	else
		SetHyperlink(self, data, ...)
	end
end

local hyperLinkEntered
function CH:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return; end
	local linkToken = strmatch(refString, "^([^:]+)")
	if hyperlinkTypes[linkToken] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(refString)
		hyperLinkEntered = frame;
		GameTooltip:Show()
	end
end

function CH:OnHyperlinkLeave(frame, refString)
	-- local linkToken = refString:match("^([^:]+)")
	-- if hyperlinkTypes[linkToken] then
		-- HideUIPanel(GameTooltip)
		-- hyperLinkEntered = nil;
	-- end

	if hyperLinkEntered then
		HideUIPanel(GameTooltip)
		hyperLinkEntered = nil;
	end
end

-- function CH:OnMessageScrollChanged(frame)
	-- if hyperLinkEntered == frame then
		-- HideUIPanel(GameTooltip)
		-- hyperLinkEntered = false;
	-- end
-- end

function CH:EnableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if (not self.hooks or not self.hooks[frame] or not self.hooks[frame].OnHyperlinkEnter) then
			self:HookScript(frame, 'OnHyperlinkEnter')
			self:HookScript(frame, 'OnHyperlinkLeave')
			-- self:HookScript(frame, 'OnMessageScrollChanged')
		end
	end
end

function CH:DisableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if self.hooks and self.hooks[frame] and self.hooks[frame].OnHyperlinkEnter then
			self:Unhook(frame, 'OnHyperlinkEnter')
			self:Unhook(frame, 'OnHyperlinkLeave')
			-- self:Unhook(frame, 'OnMessageScrollChanged')
		end
	end
end

function CH:DisableChatThrottle()
	wipe(msgList)
	wipe(msgCount)
	wipe(msgTime)
end

function CH:ShortChannel()
	return format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[strupper(self)] or gsub(self, "channel:", ""))
end

function CH:GetBNFirstToonClassColor(id)
	if not id then return end
	local bnetIDAccount, isOnline, numGameAccounts, client, Class, _
	local total = BNGetNumFriends();
	for i = 1, total do
		bnetIDAccount, _, _, _, _, _, _, isOnline = BNGetFriendInfo(i);
		if isOnline and (bnetIDAccount == id) then
			numGameAccounts = BNGetNumFriendGameAccounts(i);
			if numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					_, _, client, _, _, _, _, Class = BNGetFriendGameAccountInfo(i, y);
					if (client == BNET_CLIENT_WOW) and Class and Class ~= '' then
						return Class --return the first toon's class
					end
				end
			end
			break
		end
	end
end

function CH:GetBNFriendColor(name, id, useBTag)
	local _, _, battleTag, isBattleTagPresence, _, bnetIDGameAccount = BNGetFriendInfoByID(id)
	local BATTLE_TAG = battleTag and strmatch(battleTag,'([^#]+)')
	local TAG = (useBTag or CH.db.useBTagName) and BATTLE_TAG
	local Class

	if not bnetIDGameAccount then --dont know how this is possible
		local firstToonClass = CH:GetBNFirstToonClassColor(id)
		if firstToonClass then
			Class = firstToonClass
		else
			return TAG or name, isBattleTagPresence and BATTLE_TAG
		end
	end

	if not Class then
		_, _, _, _, _, _, _, Class = BNGetGameAccountInfo(bnetIDGameAccount)
	end

	if Class and Class ~= '' then --other non-english locales require this
		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if Class == v then Class = k;break end end
		for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if Class == v then Class = k;break end end
	end

	local CLASS = Class and Class ~= '' and gsub(strupper(Class),'%s','')
	local COLOR = CLASS and (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CLASS] or RAID_CLASS_COLORS[CLASS])

	return (COLOR and format('|c%s%s|r', COLOR.colorStr, TAG or name)) or TAG or name, isBattleTagPresence and BATTLE_TAG
end

local PluginIconsCalls = {}
function CH:AddPluginIcons(func)
	tinsert(PluginIconsCalls, func)
end

function CH:GetPluginIcon(sender)
	local icon
	for i = 1, #PluginIconsCalls do
		icon = PluginIconsCalls[i](sender)
		if icon and icon ~= "" then break end
	end
	return icon
end

--Copied from FrameXML ChatFrame.lua and modified to add CUSTOM_CLASS_COLORS
function CH:GetColoredName(event, _, arg2, _, _, _, _, _, arg8, _, _, _, arg12)
	local chatType = strsub(event, 10);
	if ( strsub(chatType, 1, 7) == "WHISPER" ) then
		chatType = "WHISPER";
	end
	if ( strsub(chatType, 1, 7) == "CHANNEL" ) then
		chatType = "CHANNEL"..arg8;
	end
	local info = ChatTypeInfo[chatType];

	--ambiguate guild chat names
	if (chatType == "GUILD") then
		arg2 = Ambiguate(arg2, "guild")
	else
		arg2 = Ambiguate(arg2, "none")
	end

	if ( arg12 and info and Chat_ShouldColorChatByClass(info) ) then
		local _, englishClass = GetPlayerInfoByGUID(arg12)

		if ( englishClass ) then
			local classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[englishClass] or RAID_CLASS_COLORS[englishClass];
			if ( not classColorTable ) then
				return arg2;
			end
			return format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..arg2.."\124r"
		end
	end

	return arg2;
end

--Copied from FrameXML ChatFrame.lua and modified to add CUSTOM_CLASS_COLORS
local seenGroups = {};
function CH:ChatFrame_ReplaceIconAndGroupExpressions(message, noIconReplacement, noGroupReplacement)
	wipe(seenGroups);

	for tag in gmatch(message, "%b{}") do
		local term = strlower(gsub(tag, "[{}]", ""));
		if ( not noIconReplacement and ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
			message = gsub(message, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
		elseif ( not noGroupReplacement and GROUP_TAG_LIST[term] ) then
			local groupIndex = GROUP_TAG_LIST[term];
			if not seenGroups[groupIndex] then
				seenGroups[groupIndex] = true;
				local groupList = "[";
				for i=1, GetNumGroupMembers() do
					local name, rank, subgroup, level, class, classFileName = GetRaidRosterInfo(i);
					if ( name and subgroup == groupIndex ) then
						local classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName];
						if ( classColorTable ) then
							name = format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, name);
						end
						groupList = groupList..(groupList == "[" and "" or GlobalStrings.PLAYER_LIST_DELIMITER)..name;
					end
				end
				if groupList ~= "[" then
					groupList = groupList.."]";
					message = gsub(message, tag, groupList, 1);
				end
			end
		end
	end

	return message;
end

E.NameReplacements = {}
function CH:ChatFrame_MessageEventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
	-- ElvUI Chat History Note: isHistory, historyTime, historyName, and historyBTag are passed from CH:DisplayChatHistory() and need to be on the end to prevent issues in other addons that listen on ChatFrame_MessageEventHandler.
	-- we also send isHistory and historyTime into CH:AddMessage so that we don't have to override the timestamp.
	if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		if (arg16) then
			-- hiding sender in letterbox: do NOT even show in chat window (only shows in cinematic frame)
			return true;
		end

		local historySavedName --we need to extend the arguments on CH.ChatFrame_MessageEventHandler so we can properly handle saved names without overriding
		if isHistory == "ElvUI_ChatHistory" then
			if historyBTag then arg2 = historyBTag end -- swap arg2 (which is a |k string) to btag name
			historySavedName = historyName
		end

		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		local chatFilters = ChatFrame_GetMessageEventFilters(event)
		if chatFilters then
			local filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
			for _, filterFunc in next, chatFilters do
				filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14 = filterFunc(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
				if ( filter ) then
					return true;
				elseif ( newarg1 ) then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
				end
			end
		end

		arg2 = E.NameReplacements[arg2] or arg2

		local _, _, englishClass, _, _, _, name, realm = pcall(GetPlayerInfoByGUID, arg12)
		local coloredName = historySavedName or CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
		local nameWithRealm -- we also use this lower in function to correct mobile to link with the realm as well

		--Cache name->class
		realm = (realm and realm ~= '') and gsub(realm,'[%s%-]','') -- also used similar to nameWithRealm except for emotes to link the realm
		if name and name ~= '' then
			CH.ClassNames[name:lower()] = englishClass
			nameWithRealm = (realm and name.."-"..realm) or name.."-"..PLAYER_REALM
			CH.ClassNames[nameWithRealm:lower()] = englishClass
		end

		local channelLength = strlen(arg4);
		local infoType = type;
		if ( (type == "COMMUNITIES_CHANNEL") or ((strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER"))) ) then
			if ( arg1 == "WRONG_PASSWORD" ) then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""];
				if ( staticPopup and strupper(staticPopup.data) == strupper(arg9) ) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return;
				end
			end

			local found = 0;
			for index, value in pairs(self.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (self.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = 1;
						infoType = "CHANNEL"..arg8;
						info = ChatTypeInfo[infoType];
						if ( (type == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") ) then
							self.channelList[index] = nil;
							self.zoneChannelList[index] = nil;
						end
						break;
					end
				end
			end
			if ( (found == 0) or not info ) then
				return true;
			end
		end

		local chatGroup = Chat_GetChatCategory(type);
		local chatTarget;
		if ( chatGroup == "CHANNEL" ) then
			chatTarget = tostring(arg8);
		elseif ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if(not(strsub(arg2, 1, 2) == "|K")) then
				chatTarget = strupper(arg2);
			else
				chatTarget = arg2;
			end
		end

		if ( FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) ) then
			return true;
		end

		if ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if ( self.privateMessageList and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			elseif ( self.excludePrivateMessageList and self.excludePrivateMessageList[strlower(arg2)]
				and ( (chatGroup == "WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") or (chatGroup == "BN_WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") ) ) then
				return true;
			end
		end

		if (self.privateMessageList) then
			-- Dedicated BN whisper windows need online/offline messages for only that player
			if ( (chatGroup == "BN_INLINE_TOAST_ALERT" or chatGroup == "BN_WHISPER_PLAYER_OFFLINE") and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			end

			-- HACK to put certain system messages into dedicated whisper windows
			if ( chatGroup == "SYSTEM") then
				local matchFound = false;
				local message = strlower(arg1);
				for playerName in pairs(self.privateMessageList) do
					local playerNotFoundMsg = strlower(format(GlobalStrings.ERR_CHAT_PLAYER_NOT_FOUND_S, playerName));
					local charOnlineMsg = strlower(format(GlobalStrings.ERR_FRIEND_ONLINE_SS, playerName, playerName));
					local charOfflineMsg = strlower(format(GlobalStrings.ERR_FRIEND_OFFLINE_S, playerName));
					if ( message == playerNotFoundMsg or message == charOnlineMsg or message == charOfflineMsg) then
						matchFound = true;
						break;
					end
				end

				if (not matchFound) then
					return true;
				end
			end
		end

		if ( type == "SYSTEM" or type == "SKILL" or type == "CURRENCY" or type == "MONEY" or
			type == "OPENING" or type == "TRADESKILLS" or type == "PET_INFO" or type == "TARGETICONS" or type == "BN_WHISPER_PLAYER_OFFLINE") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif (type == "LOOT") then
			-- Append [Share] hyperlink if this is a valid social item and you are the looter.
			-- arg5 contains the name of the player who looted
			if (C_SocialIsSocialEnabled() and UnitName("player") == arg5) then
				local itemID, creationContext = GetItemInfoFromHyperlink(arg1);
				if (itemID and C_SocialGetLastItem() == itemID) then
					arg1 = arg1 .. " " .. Social_GetShareItemLink(itemID, creationContext, true);
				end
			end
			self:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( strsub(type,1,11) == "ACHIEVEMENT" ) then
			-- Append [Share] hyperlink
			if (arg12 == E.myguid and C_SocialIsSocialEnabled()) then
				local achieveID = GetAchievementInfoFromHyperlink(arg1);
				if (achieveID) then
					arg1 = arg1 .. " " .. Social_GetShareAchievementLink(achieveID, true);
				end
			end
			self:AddMessage(format(arg1, GetPlayerLink(arg2, ("[%s]"):format(coloredName))), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( strsub(type,1,18) == "GUILD_ACHIEVEMENT" ) then
			local message = format(arg1, GetPlayerLink(arg2, ("[%s]"):format(coloredName)));
			if (C_SocialIsSocialEnabled()) then
				local achieveID = GetAchievementInfoFromHyperlink(arg1);
				if (achieveID) then
					local isGuildAchievement = select(12, GetAchievementInfo(achieveID));
					if (isGuildAchievement) then
						message = message .. " " .. Social_GetShareAchievementLink(achieveID, true);
					end
				end
			end
			self:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( type == "IGNORED" ) then
			self:AddMessage(format(GlobalStrings.CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( type == "FILTERED" ) then
			self:AddMessage(format(GlobalStrings.CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( type == "RESTRICTED" ) then
			self:AddMessage(GlobalStrings.CHAT_RESTRICTED_TRIAL, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				self:AddMessage(format(_G["CHAT_"..type.."_GET"]..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			else
				self:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if not globalstring then
				GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE_BN"));
				return;
			end
			if(arg5 ~= "") then
				-- TWO users in this notice (E.G. x kicked y)
				self:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			elseif ( arg1 == "INVITE" ) then
				self:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			else
				self:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			end
			if ( arg1 == "INVITE" and GetCVarBool("blockChannelInvites") ) then
				self:AddMessage(GlobalStrings.CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			end
		elseif (type == "CHANNEL_NOTICE") then
			local globalstring;
			if ( arg1 == "TRIAL_RESTRICTED" ) then
				globalstring = GlobalStrings.CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL;
			else
				globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
				if ( not globalstring ) then
					globalstring = _G["CHAT_"..arg1.."_NOTICE"];
					if not globalstring then
						GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE"));
						return;
					end
				end
			end
			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8, arg12);
			self:AddMessage(format(globalstring, arg8, ChatFrame_ResolvePrefixedChannelName(arg4)), info.r, info.g, info.b, info.id, accessID, typeID, isHistory, historyTime);
		elseif ( type == "BN_INLINE_TOAST_ALERT" ) then
			local globalstring = _G["BN_INLINE_TOAST_"..arg1];
			if not globalstring then
				GMError(("Missing global string for %q"):format("BN_INLINE_TOAST_"..arg1));
				return;
			end
			local message;
			if ( arg1 == "FRIEND_REQUEST" ) then
				message = globalstring;
			elseif ( arg1 == "FRIEND_PENDING" ) then
				message = format(GlobalStrings.BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites());
			elseif ( arg1 == "FRIEND_REMOVED" or arg1 == "BATTLETAG_FRIEND_REMOVED" ) then
				message = format(globalstring, arg2);
			elseif ( arg1 == "FRIEND_ONLINE" or arg1 == "FRIEND_OFFLINE" ) then
				local _, _, _, _, characterName, _, client = BNGetFriendInfoByID(arg13);
				if (client and client ~= "") then
					local _, _, battleTag = BNGetFriendInfoByID(arg13);
					characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or "";
					local characterNameText = BNet_GetClientEmbeddedTexture(client, 14)..characterName;
					local linkDisplayText = ("[%s] (%s)"):format(arg2, characterNameText);
					local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
					message = format(globalstring, playerLink);
				else
					local linkDisplayText = ("[%s]"):format(arg2);
					local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
					message = format(globalstring, playerLink);
				end
			else
				local linkDisplayText = ("[%s]"):format(arg2);
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
				message = format(globalstring, playerLink);
			end
			self:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
		elseif ( type == "BN_INLINE_TOAST_BROADCAST" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveNewlines(RemoveExtraSpaces(arg1));
				local linkDisplayText = ("[%s]"):format(arg2);
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
				self:AddMessage(format(GlobalStrings.BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			end
		elseif ( type == "BN_INLINE_TOAST_BROADCAST_INFORM" ) then
			if ( arg1 ~= "" ) then
				self:AddMessage(GlobalStrings.BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime);
			end
		else
			local body;

			if ( type == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) ) then
				return;
			end

			local showLink = 1;
			if ( strsub(type, 1, 7) == "MONSTER" or strsub(type, 1, 9) == "RAID_BOSS") then
				showLink = nil;
			else
				arg1 = gsub(arg1, "%%", "%%%%");
			end

			-- Search for icon links and replace them with texture links.
			arg1 = CH:ChatFrame_ReplaceIconAndGroupExpressions(arg1, arg17, not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup)); -- If arg17 is true, don't convert to raid icons

			--Remove groups of many spaces
			arg1 = RemoveExtraSpaces(arg1);

			--ElvUI: Get class colored name for BattleNet friend
			if ( type == "BN_WHISPER" or type == "BN_WHISPER_INFORM" ) then
				coloredName = historySavedName or CH:GetBNFriendColor(arg2, arg13)
			end

			local playerLink;
			local playerLinkDisplayText = coloredName;
			local relevantDefaultLanguage = self.defaultLanguage;
			if ( (type == "SAY") or (type == "YELL") ) then
				relevantDefaultLanguage = self.alternativeDefaultLanguage;
			end
			local usingDifferentLanguage = (arg3 ~= "") and (arg3 ~= relevantDefaultLanguage);
			local usingEmote = (type == "EMOTE") or (type == "TEXT_EMOTE");

			if ( usingDifferentLanguage or not usingEmote ) then
				playerLinkDisplayText = ("[%s]"):format(coloredName);
			end

			local isCommunityType = type == "COMMUNITIES_CHANNEL";
			local playerName, lineID, bnetIDAccount = arg2, arg11, arg13;
			if ( isCommunityType ) then
				local isBattleNetCommunity = bnetIDAccount ~= nil and bnetIDAccount ~= 0;
				local messageInfo, clubId, streamId, clubType = C_Club_GetInfoFromLastCommunityChatLine();

				if (messageInfo ~= nil) then
					if ( isBattleNetCommunity ) then
						playerLink = GetBNPlayerCommunityLink(playerName, playerLinkDisplayText, bnetIDAccount, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position);
					else
						playerLink = GetPlayerCommunityLink(playerName, playerLinkDisplayText, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position);
					end
				else
					playerLink = playerLinkDisplayText;
				end
			else
				if ( type == "TEXT_EMOTE" and realm ) then
					-- make sure emote has realm link correct
					playerName = playerName.."-"..realm
					playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
				elseif ( arg14 and nameWithRealm and nameWithRealm ~= playerName ) then
					-- make sure mobile has realm link correct
					playerName = nameWithRealm
					playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
				elseif ( type == "BN_WHISPER" or type == "BN_WHISPER_INFORM" ) then
					playerLink = GetBNPlayerLink(playerName, playerLinkDisplayText, bnetIDAccount, lineID, chatGroup, chatTarget);
				elseif ( type == "GUILD" and nameWithRealm and nameWithRealm ~= playerName ) then
					playerName = nameWithRealm
					playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
				else
					playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
				end
			end

			local message = arg1;
			if ( arg14 ) then --isMobile
				message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message;
			end

			-- Player Flags
			local pflag, chatIcon, pluginChatIcon = "", specialChatIcons[playerName], CH:GetPluginIcon(playerName)
			if arg6 ~= "" then -- Blizzard Flags
				if arg6 == "GM" or arg6 == "DEV" then -- Blizzard Icon, this was sent by a GM or Dev.
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t";
				else -- Away/Busy
					pflag = _G["CHAT_FLAG_"..arg6] or ""
				end
			end
			-- LFG Role Flags
			local lfgRole = lfgRoles[playerName]
			if lfgRole and (type == "PARTY_LEADER" or type == "PARTY" or type == "RAID" or type == "RAID_LEADER" or type == "INSTANCE_CHAT" or type == "INSTANCE_CHAT_LEADER") then
				pflag = pflag..lfgRole
			end
			-- Special Chat Icon
			if chatIcon then
				pflag = pflag..chatIcon
			end
			-- Plugin Chat Icon
			if pluginChatIcon then
				pflag = pflag..pluginChatIcon
			end

			if ( usingDifferentLanguage ) then
				local languageHeader = "["..arg3.."] ";
				if ( showLink and (arg2 ~= "") ) then
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..message, pflag..playerLink);
				else
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..message, pflag..arg2);
				end
			else
				if ( not showLink or arg2 == "" ) then
					if ( type == "TEXT_EMOTE" ) then
						body = message;
					else
						body = format(_G["CHAT_"..type.."_GET"]..message, pflag..arg2, arg2);
					end
				else
					if ( type == "EMOTE" ) then
						body = format(_G["CHAT_"..type.."_GET"]..message, pflag..playerLink);
					elseif ( type == "TEXT_EMOTE" and realm ) then
						-- make sure emote has realm link correct
						if info.colorNameByClass then
							body = gsub(message, arg2.."%-"..realm, pflag..gsub(playerLink, "(|h|c.-)|r|h$","%1-"..realm.."|r|h"), 1);
						else
							body = gsub(message, arg2.."%-"..realm, pflag..gsub(playerLink, "(|h.-)|h$","%1-"..realm.."|h"), 1);
						end
					elseif (type == "TEXT_EMOTE") then
						body = gsub(message, arg2, pflag..playerLink, 1);
					elseif (type == "GUILD_ITEM_LOOTED") then
						body = gsub(message, "$s", GetPlayerLink(arg2, playerLinkDisplayText));
					else
						body = format(_G["CHAT_"..type.."_GET"]..message, pflag..playerLink);
					end
				end
			end

			-- Add Channel
			if (channelLength > 0) then
				body = "|Hchannel:channel:"..arg8.."|h["..ChatFrame_ResolvePrefixedChannelName(arg4).."]|h "..body;
			end

			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12 or arg13);
			if CH.db.shortChannels and type ~= "EMOTE" and type ~= "TEXT_EMOTE" then
				body = gsub(body, "|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel)
				body = gsub(body, 'CHANNEL:', '')
				body = gsub(body, "^(.-|h) "..L["whispers"], "%1")
				body = gsub(body, "^(.-|h) "..L["says"], "%1")
				body = gsub(body, "^(.-|h) "..L["yells"], "%1")
				body = gsub(body, "<"..GlobalStrings.AFK..">", "[|cffFF0000"..L["AFK"].."|r] ")
				body = gsub(body, "<"..GlobalStrings.DND..">", "[|cffE7E716"..L["DND"].."|r] ")
				body = gsub(body, "^%["..GlobalStrings.RAID_WARNING.."%]", '['..L["RW"]..']')
			end
			self:AddMessage(body, info.r, info.g, info.b, info.id, accessID, typeID, isHistory, historyTime);
		end

		if ( isHistory ~= "ElvUI_ChatHistory" ) and ( type == "WHISPER" or type == "BN_WHISPER" ) then
			--BN_WHISPER FIXME
			ChatEdit_SetLastTellTarget(arg2, type);
			if ( self.tellTimer and (GetTime() > self.tellTimer) ) then
				PlaySound(SOUNDKIT.TELL_MESSAGE);
			end
			self.tellTimer = GetTime() + GlobalStrings.CHAT_TELL_ALERT_TIME;
			--FCF_FlashTab(self);
			FlashClientIcon();
		end

		if ( isHistory ~= "ElvUI_ChatHistory" ) and ( not self:IsShown() ) then
			if ( (self == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (self ~= DEFAULT_CHAT_FRAME and info.flashTab) ) then
				if ( not CHAT_OPTIONS.HIDE_FRAME_ALERTS or type == "WHISPER" or type == "BN_WHISPER" ) then --BN_WHISPER FIXME
					if not FCFManager_ShouldSuppressMessageFlash(self, chatGroup, chatTarget) then
						FCF_StartAlertFlash(self); --This would taint if we were not using LibChatAnims
					end
				end
			end
		end

		return true;
	end
end

function CH:ChatFrame_ConfigEventHandler(...)
	return ChatFrame_ConfigEventHandler(...)
end

function CH:ChatFrame_SystemEventHandler(...)
	return ChatFrame_SystemEventHandler(...)
end

function CH:ChatFrame_OnEvent(...)
	if CH:ChatFrame_ConfigEventHandler(...) then return end
	if CH:ChatFrame_SystemEventHandler(...) then return end
	if CH:ChatFrame_MessageEventHandler(...) then return end
end

function CH:FloatingChatFrame_OnEvent(...)
	CH:ChatFrame_OnEvent(...);
	FloatingChatFrame_OnEvent(...);
end

local function FloatingChatFrameOnEvent(...)
	CH:FloatingChatFrame_OnEvent(...)
end

function CH:SetupChat()
	if E.private.chat.enable ~= true then return end
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		local id = frame:GetID();
		local _, fontSize = FCF_GetChatWindowInfo(id);
		self:StyleChat(frame)
		FCFTab_UpdateAlpha(frame)
		frame:SetFont(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)
		if self.db.fontOutline ~= 'NONE' then
			frame:SetShadowColor(0, 0, 0, 0.2)
		else
			frame:SetShadowColor(0, 0, 0, 1)
		end
		frame:SetTimeVisible(100)
		frame:SetShadowOffset((E.mult or 1), -(E.mult or 1))
		frame:SetFading(self.db.fade)

		if not frame.scriptsSet then
			frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)

			if id ~= 2 then
				frame:SetScript("OnEvent", FloatingChatFrameOnEvent)
			end

			hooksecurefunc(frame, "SetScript", function(f, script, func)
				if script == "OnMouseWheel" and func ~= ChatFrame_OnMouseScroll then
					f:SetScript(script, ChatFrame_OnMouseScroll)
				end
			end)
			frame.scriptsSet = true
		end
	end

	if self.db.hyperlinkHover then
		self:EnableHyperlink()
	end

	GeneralDockManager:SetParent(LeftChatPanel)
	-- self:ScheduleRepeatingTimer('PositionChat', 1)
	self:PositionChat(true)

	if not self.HookSecured then
		self:SecureHook('FCF_OpenTemporaryWindow', 'SetupChat')
		self.HookSecured = true;
	end
end

local function PrepareMessage(author, message)
	return format("%s%s", strupper(author), message)
end

function CH:ChatThrottleHandler(event, ...)
	local arg1, arg2 = ...

	if arg2 ~= "" then
		local message = PrepareMessage(arg2, arg1)
		if msgList[message] == nil then
			msgList[message] = true
			msgCount[message] = 1
			msgTime[message] = time()
		else
			msgCount[message] = msgCount[message] + 1
		end
	end
end

function CH:CHAT_MSG_CHANNEL(event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)

	-- ignore player messages
	if author == PLAYER_NAME then return CH.FindURL(self, event, message, author, ...) end
	if msgList[msg] and CH.db.throttleInterval ~= 0 then
		if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
			blockFlag = true
		end
	end

	if blockFlag then
		return true;
	else
		if CH.db.throttleInterval ~= 0 then
			msgTime[msg] = time()
		end

		return CH.FindURL(self, event, message, author, ...)
	end
end

function CH:CHAT_MSG_YELL(event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)

	if msg == nil then return CH.FindURL(self, event, message, author, ...) end

	-- ignore player messages
	if author == PLAYER_NAME then return CH.FindURL(self, event, message, author, ...) end
	if msgList[msg] and msgCount[msg] > 1 and CH.db.throttleInterval ~= 0 then
		if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
			blockFlag = true
		end
	end

	if blockFlag then
		return true;
	else
		if CH.db.throttleInterval ~= 0 then
			msgTime[msg] = time()
		end

		return CH.FindURL(self, event, message, author, ...)
	end
end

function CH:CHAT_MSG_SAY(event, message, author, ...)
	return CH.FindURL(self, event, message, author, ...)
end

function CH:ThrottleSound()
	CH.SoundTimer = nil
end

local protectLinks = {}
function CH:CheckKeyword(message)
	for hyperLink in gmatch(message, "|%x+|H.-|h.-|h|r") do
		protectLinks[hyperLink]=gsub(hyperLink,'%s','|s')
		for keyword in pairs(CH.Keywords) do
			if hyperLink == keyword then
				if (self.db.keywordSound ~= 'None') and not self.SoundTimer then
					if (self.db.noAlertInCombat and not InCombatLockdown()) or not self.db.noAlertInCombat then
						PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
					end

					self.SoundTimer = E:Delay(1, CH.ThrottleSound)
				end
			end
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		message = gsub(message, gsub(hyperLink, '([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1'), tempLink)
	end

	local classColorTable, tempWord, rebuiltString, lowerCaseWord, wordMatch, classMatch
	local isFirstWord = true
	for word in gmatch(message, "%s-%S+%s*") do
		if not next(protectLinks) or not protectLinks[gsub(gsub(word,"%s",""),"|s"," ")] then
			tempWord = gsub(word, "[%s%p]", "")
			lowerCaseWord = tempWord:lower()
			for keyword in pairs(CH.Keywords) do
				if lowerCaseWord == keyword:lower() then
					word = gsub(word, tempWord, format("%s%s|r", E.media.hexvaluecolor, tempWord))
					if (self.db.keywordSound ~= 'None') and not self.SoundTimer then
						if (self.db.noAlertInCombat and not InCombatLockdown()) or not self.db.noAlertInCombat then
							PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
						end

						self.SoundTimer = E:Delay(1, CH.ThrottleSound)
					end
				end
			end

			if self.db.classColorMentionsChat then
				tempWord = gsub(word,"^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$","%1%2")
				lowerCaseWord = tempWord:lower()

				classMatch = CH.ClassNames[lowerCaseWord]
				wordMatch = classMatch and lowerCaseWord

				if(wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch]) then
					classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classMatch] or RAID_CLASS_COLORS[classMatch];
					word = gsub(word, gsub(tempWord, "%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
				end
			end
		end

		if isFirstWord then
			rebuiltString = word
			isFirstWord = false
		else
			rebuiltString = format("%s%s", rebuiltString, word)
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		rebuiltString = gsub(rebuiltString, gsub(tempLink, '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'), hyperLink)
		protectLinks[hyperLink] = nil
	end

	return rebuiltString
end

function CH:AddLines(lines, ...)
	for i=select("#", ...),1,-1 do
	local x = select(i, ...)
		if x:GetObjectType() == "FontString" and not x:GetName() then
			tinsert(lines, x:GetText())
		end
	end
end

function CH:ChatEdit_OnEnterPressed(editBox)
	local chatType = editBox:GetAttribute("chatType")
	if not chatType then return end

	local chatFrame = editBox:GetParent()
	if chatFrame and (not chatFrame.isTemporary) and (ChatTypeInfo[chatType].sticky == 1) then
		if not self.db.sticky then chatType = 'SAY' end
		editBox:SetAttribute("chatType", chatType)
	end
end

function CH:SetChatFont(dropDown, chatFrame, fontSize)
	if ( not chatFrame ) then
		chatFrame = FCF_GetCurrentChatFrame();
	end
	if ( not fontSize ) then
		fontSize = dropDown.value;
	end
	chatFrame:SetFont(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)
	if self.db.fontOutline ~= 'NONE' then
		chatFrame:SetShadowColor(0, 0, 0, 0.2)
	else
		chatFrame:SetShadowColor(0, 0, 0, 1)
	end
	chatFrame:SetShadowOffset((E.mult or 1), -(E.mult or 1))
end

function CH:ChatEdit_AddHistory(editBox, line)
	if find(line, "/rl") then return end

	if ( strlen(line) > 0 ) then
		for _, text in pairs(ElvCharacterDB.ChatEditHistory) do
			if text == line then
				return
			end
		end

		tinsert(ElvCharacterDB.ChatEditHistory, #ElvCharacterDB.ChatEditHistory + 1, line)
		if #ElvCharacterDB.ChatEditHistory > 20 then
			tremove(ElvCharacterDB.ChatEditHistory, 1)
		end
	end
end

function CH:UpdateChatKeywords()
	wipe(CH.Keywords)

	local keywords = self.db.keywords
	keywords = gsub(keywords,',%s',',')

	for i=1, #{split(',', keywords)} do
		local stringValue = select(i, split(',', keywords));
		if stringValue ~= '' then
			CH.Keywords[stringValue] = true;
		end
	end
end

function CH:PET_BATTLE_CLOSE()
	if not self.db.autoClosePetBattleLog then
		return
	end

	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame then
			local text = _G[frameName.."Tab"]:GetText()
			if strmatch(text, DEFAULT_STRINGS.PET_BATTLE_COMBAT_LOG) then
				FCF_Close(frame)
			end
		end
	end
end

function CH:UpdateFading()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame then
			frame:SetFading(self.db.fade)
		end
	end
end

function CH:DisplayChatHistory()
	local data, d = ElvCharacterDB.ChatHistoryLog
	if not (data and next(data)) then return end

	if not GetPlayerInfoByGUID(E.myguid) then
		E:Delay(0.1, CH.DisplayChatHistory)
		return
	end

	CH.SoundTimer = true
	for _, chat in pairs(CHAT_FRAMES) do
		for i=1, #data do
			d = data[i]
			if type(d) == 'table' then
				for _, messageType in pairs(_G[chat].messageTypeList) do
					if gsub(strsub(d[50],10),'_INFORM','') == messageType then
						CH:ChatFrame_MessageEventHandler(_G[chat],d[50],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14],d[15],d[16],d[17],"ElvUI_ChatHistory",d[51],d[52],d[53])
					end
				end
			end
		end
	end
	CH.SoundTimer = nil
end

tremove(ChatTypeGroup.GUILD, 2)
function CH:DelayGuildMOTD()
	local delay, checks, delayFrame, chat = 0, 0, CreateFrame('Frame')
	tinsert(ChatTypeGroup.GUILD, 2, 'GUILD_MOTD')
	delayFrame:SetScript('OnUpdate', function(df, elapsed)
		delay = delay + elapsed
		if delay < 5 then return end
		local msg = GetGuildRosterMOTD()
		if msg and strlen(msg) > 0 then
			for _, frame in pairs(CHAT_FRAMES) do
				chat = _G[frame]
				if chat and chat:IsEventRegistered('CHAT_MSG_GUILD') then
					CH:ChatFrame_SystemEventHandler(chat, 'GUILD_MOTD', msg)
					chat:RegisterEvent('GUILD_MOTD')
				end
			end
			df:SetScript('OnUpdate', nil)
		else -- 5 seconds can be too fast for the API response. let's try once every 5 seconds (max 5 checks).
			delay, checks = 0, checks + 1
			if checks >= 5 then
				df:SetScript('OnUpdate', nil)
			end
		end
	end)
end

function CH:SaveChatHistory(event, ...)
	if not self.db.chatHistory then return end
	local data = ElvCharacterDB.ChatHistoryLog

	if self.db.throttleInterval ~= 0 and (event == 'CHAT_MSG_SAY' or event == 'CHAT_MSG_YELL' or event == 'CHAT_MSG_CHANNEL') then
		self:ChatThrottleHandler(event, ...)

		local message, author = ...
		local msg = PrepareMessage(author, message)
		if author ~= PLAYER_NAME and msgList[msg] then
			if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
				return;
			end
		end
	end

	local temp = {}
	for i = 1, select('#', ...) do
		temp[i] = select(i, ...) or false
	end

	if #temp > 0 then
		temp[50] = event
		temp[51] = time()

		local coloredName, battleTag
		if temp[13] > 0 then coloredName, battleTag = CH:GetBNFriendColor(temp[2], temp[13], true) end
		if battleTag then temp[53] = battleTag end -- store the battletag, only when the person is known by battletag, so we can replace arg2 later in the function
		temp[52] = coloredName or CH:GetColoredName(event, ...)

		tinsert(data, temp)
		while #data >= 128 do
			tremove(data, 1)
		end
	end
	temp = nil -- Destory!
end

function CH:FCF_SetWindowAlpha(frame, alpha)
	frame.oldAlpha = alpha or 1;
end

function CH:CheckLFGRoles()
	local isInGroup, isInRaid = IsInGroup(), IsInRaid()
	local unit, name, realm = (isInRaid and "raid" or "party")

	wipe(lfgRoles)

	if(not isInGroup or not self.db.lfgIcons) then return end

	local role = UnitGroupRolesAssigned("player")
	if(role) then
		lfgRoles[PLAYER_NAME] = rolePaths[role]
	end

	for i=1, GetNumGroupMembers() do
		if(UnitExists(unit..i) and not UnitIsUnit(unit..i, "player")) then
			role = UnitGroupRolesAssigned(unit..i)
			name, realm = UnitName(unit..i)

			if(role and name) then
				name = (realm and realm ~= '' and name..'-'..realm) or name..'-'..PLAYER_REALM;
				lfgRoles[name] = rolePaths[role]
			end
		end
	end
end

function CH:ON_FCF_SavePositionAndDimensions(_, noLoop)
	if not noLoop then
		CH:PositionChat()
	end

	if not E.db.chat.lockPositions then
		CH:UpdateChatTabs() --It was not done in PositionChat, so do it now
	end
end

function CH:SocialQueueIsLeader(playerName, leaderName)
	if leaderName == playerName then
		return true
	end

	local numGameAccounts, accountName, isOnline, gameCharacterName, gameClient, realmName, _
	for i = 1, BNGetNumFriends() do
		_, accountName, _, _, _, _, _, isOnline = BNGetFriendInfo(i);
		if isOnline then
			numGameAccounts = BNGetNumFriendGameAccounts(i);
			if numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					_, gameCharacterName, gameClient, realmName = BNGetFriendGameAccountInfo(i, y);
					if (gameClient == BNET_CLIENT_WOW) and (accountName == playerName) then
						playerName = gameCharacterName
						if realmName ~= E.myrealm then
							playerName = format('%s-%s', playerName, gsub(realmName,'[%s%-]',''))
						end
						if leaderName == playerName then
							return true
						end
					end
				end
			end
		end
	end
end

local socialQueueCache = {}
local function RecentSocialQueue(TIME, MSG)
	local previousMessage = false
	if next(socialQueueCache) then
		for guid, tbl in pairs(socialQueueCache) do
			-- !dont break this loop! its used to keep the cache updated
			if TIME and (difftime(TIME, tbl[1]) >= 300) then
				socialQueueCache[guid] = nil --remove any older than 5m
			elseif MSG and (MSG == tbl[2]) then
				previousMessage = true --dont show any of the same message within 5m
				-- see note for `message` in `SocialQueueMessage` about `MSG` content
			end
		end
	end
	return previousMessage
end

function CH:SocialQueueMessage(guid, message)
	if not (guid and message) then return end
	-- `guid` is something like `Party-1147-000011202574` and appears to update each time for solo requeue, otherwise on new group creation.
	-- `message` is something like `|cff82c5ff|Kf58|k000000000000|k|r queued for: |cff00CCFFRandom Legion Heroic|r `

	-- prevent duplicate messages within 5 minutes
	local TIME = time()
	if RecentSocialQueue(TIME, message) then return end
	socialQueueCache[guid] = {TIME, message}

	--UI_71_SOCIAL_QUEUEING_TOAST = 79739; appears to have no sound?
	PlaySound(7355) --TUTORIAL_POPUP

	E:Print(format('|Hsqu:%s|h%s|h', guid, strtrim(message)))
end

function CH:SocialQueueEvent(event, guid, numAddedItems)
	if not self.db.socialQueueMessages then return end
	if numAddedItems == 0 or not guid then return end

	local coloredName, players = UNKNOWN, C_SocialQueue_GetGroupMembers(guid)
	local members = players and SocialQueueUtil_SortGroupMembers(players)
	local playerName, nameColor

	if members then
		local firstMember, numMembers, extraCount = members[1], #members, ''
		playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
		if numMembers > 1 then
			extraCount = format(' +%s', numMembers - 1)
		end
		if playerName then
			coloredName = format('%s%s|r%s', nameColor, playerName, extraCount)
		else
			coloredName = format('{%s%s}', UNKNOWN, extraCount)
		end
	end

	local isLFGList, firstQueue
	local queues = C_SocialQueue_GetGroupQueues(guid)
	firstQueue = queues and queues[1]
	isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == 'lfglist'

	if isLFGList and firstQueue and firstQueue.eligible then
		local activityID, name, comment, leaderName, fullName, isLeader, _

		if firstQueue.queueData.lfgListID then
			_, activityID, name, comment, _, _, _, _, _, _, _, _, leaderName = C_LFGList_GetSearchResultInfo(firstQueue.queueData.lfgListID)
			isLeader = self:SocialQueueIsLeader(playerName, leaderName)
		end

		-- ignore groups created by the addon World Quest Group Finder/World Quest Tracker/World Quest Assistant/HandyNotes_Argus to reduce spam
		if comment and (find(comment, "World Quest Group Finder") or find(comment, "World Quest Tracker") or find(comment, "World Quest Assistant") or find(comment, "HandyNotes_Argus")) then return end

		if activityID or firstQueue.queueData.activityID then
			fullName = C_LFGList_GetActivityInfo(activityID or firstQueue.queueData.activityID)
		end

		if name then
			self:SocialQueueMessage(guid, format('%s %s: [%s] |cff00CCFF%s|r', coloredName, (isLeader and L["is looking for members"]) or L["joined a group"], fullName or UNKNOWN, name))
		else
			self:SocialQueueMessage(guid, format('%s %s: |cff00CCFF%s|r', coloredName, (isLeader and L["is looking for members"]) or L["joined a group"], fullName or UNKNOWN))
		end
	elseif firstQueue then
		local output, outputCount, queueCount, queueName = '', '', 0
		for _, queue in pairs(queues) do
			if type(queue) == 'table' and queue.eligible then
				queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ''
				if queueName ~= '' then
					if output == '' then
						output = gsub(queueName, '\n.+','') -- grab only the first queue name
						queueCount = queueCount + select(2, gsub(queueName, '\n','')) -- collect additional on single queue
					else
						queueCount = queueCount + 1 + select(2, gsub(queueName, '\n','')) -- collect additional on additional queues
					end
				end
			end
		end
		if output ~= '' then
			if queueCount > 0 then
				outputCount = format(LFG_LIST_AND_MORE, queueCount)
			end
			self:SocialQueueMessage(guid, format('%s %s: |cff00CCFF%s|r %s', coloredName, SOCIAL_QUEUE_QUEUED_FOR, output, outputCount))
		end
	end
end

local FindURL_Events = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND",
	"CHAT_MSG_COMMUNITIES_CHANNEL",
}

function CH:DefaultSmileys()
	if next(CH.Smileys) then
		wipe(CH.Smileys)
	end

	local t = "|TInterface\\AddOns\\ElvUI\\media\\textures\\chatEmojis\\%s:16:16|t"

	-- new keys
	CH:AddSmiley(':angry:',			format(t,'angry'))
	CH:AddSmiley(':blush:',			format(t,'blush'))
	CH:AddSmiley(':broken_heart:',	format(t,'broken_heart'))
	CH:AddSmiley(':call_me:',		format(t,'call_me'))
	CH:AddSmiley(':cry:',			format(t,'cry'))
	CH:AddSmiley(':facepalm:',		format(t,'facepalm'))
	CH:AddSmiley(':grin:',			format(t,'grin'))
	CH:AddSmiley(':heart:',			format(t,'heart'))
	CH:AddSmiley(':heart_eyes:',	format(t,'heart_eyes'))
	CH:AddSmiley(':joy:',			format(t,'joy'))
	CH:AddSmiley(':kappa:',			format(t,'kappa'))
	CH:AddSmiley(':middle_finger:',	format(t,'middle_finger'))
	CH:AddSmiley(':murloc:',		format(t,'murloc'))
	CH:AddSmiley(':ok_hand:',		format(t,'ok_hand'))
	CH:AddSmiley(':open_mouth:',	format(t,'open_mouth'))
	CH:AddSmiley(':poop:',			format(t,'poop'))
	CH:AddSmiley(':rage:',			format(t,'rage'))
	CH:AddSmiley(':sadkitty:',		format(t,'sadkitty'))
	CH:AddSmiley(':scream:',		format(t,'scream'))
	CH:AddSmiley(':scream_cat:',	format(t,'scream_cat'))
	CH:AddSmiley(':slight_frown:',	format(t,'slight_frown'))
	CH:AddSmiley(':smile:',			format(t,'smile'))
	CH:AddSmiley(':smirk:',			format(t,'smirk'))
	CH:AddSmiley(':sob:',			format(t,'sob'))
	CH:AddSmiley(':sunglasses:',	format(t,'sunglasses'))
	CH:AddSmiley(':thinking:',		format(t,'thinking'))
	CH:AddSmiley(':thumbs_up:',		format(t,'thumbs_up'))
	CH:AddSmiley(':semi_colon:',	format(t,'semi_colon'))
	CH:AddSmiley(':wink:',			format(t,'wink'))
	CH:AddSmiley(':zzz:',			format(t,'zzz'))
	CH:AddSmiley(':stuck_out_tongue:',				format(t,'stuck_out_tongue'))
	CH:AddSmiley(':stuck_out_tongue_closed_eyes:',	format(t,'stuck_out_tongue_closed_eyes'))

	-- Darth's keys
	CH:AddSmiley(':meaw:',	format(t,'meaw'))

	-- Simpy's keys
	CH:AddSmiley('>:%(',	format(t,'rage'))
	CH:AddSmiley(':%$',		format(t,'blush'))
	CH:AddSmiley('<\\3',	format(t,'broken_heart'))
	CH:AddSmiley(':\'%)',	format(t,'joy'))
	CH:AddSmiley(';\'%)',	format(t,'joy'))
	CH:AddSmiley(',,!,,',	format(t,'middle_finger'))
	CH:AddSmiley('D:<',		format(t,'rage'))
	CH:AddSmiley(':o3',		format(t,'scream_cat'))
	CH:AddSmiley('XP',		format(t,'stuck_out_tongue_closed_eyes'))
	CH:AddSmiley('8%-%)',	format(t,'sunglasses'))
	CH:AddSmiley('8%)',		format(t,'sunglasses'))
	CH:AddSmiley(':%+1:',	format(t,'thumbs_up'))
	CH:AddSmiley(':;:',		format(t,'semi_colon'))
	CH:AddSmiley(';o;',		format(t,'sob'))

	-- old keys
	CH:AddSmiley(':%-@',	format(t,'angry'))
	CH:AddSmiley(':@',		format(t,'angry'))
	CH:AddSmiley(':%-%)',	format(t,'smile'))
	CH:AddSmiley(':%)',		format(t,'smile'))
	CH:AddSmiley(':D',		format(t,'grin'))
	CH:AddSmiley(':%-D',	format(t,'grin'))
	CH:AddSmiley(';%-D',	format(t,'grin'))
	CH:AddSmiley(';D',		format(t,'grin'))
	CH:AddSmiley('=D',		format(t,'grin'))
	CH:AddSmiley('xD',		format(t,'grin'))
	CH:AddSmiley('XD',		format(t,'grin'))
	CH:AddSmiley(':%-%(',	format(t,'slight_frown'))
	CH:AddSmiley(':%(',		format(t,'slight_frown'))
	CH:AddSmiley(':o',		format(t,'open_mouth'))
	CH:AddSmiley(':%-o',	format(t,'open_mouth'))
	CH:AddSmiley(':%-O',	format(t,'open_mouth'))
	CH:AddSmiley(':O',		format(t,'open_mouth'))
	CH:AddSmiley(':%-0',	format(t,'open_mouth'))
	CH:AddSmiley(':P',		format(t,'stuck_out_tongue'))
	CH:AddSmiley(':%-P',	format(t,'stuck_out_tongue'))
	CH:AddSmiley(':p',		format(t,'stuck_out_tongue'))
	CH:AddSmiley(':%-p',	format(t,'stuck_out_tongue'))
	CH:AddSmiley('=P',		format(t,'stuck_out_tongue'))
	CH:AddSmiley('=p',		format(t,'stuck_out_tongue'))
	CH:AddSmiley(';%-p',	format(t,'stuck_out_tongue_closed_eyes'))
	CH:AddSmiley(';p',		format(t,'stuck_out_tongue_closed_eyes'))
	CH:AddSmiley(';P',		format(t,'stuck_out_tongue_closed_eyes'))
	CH:AddSmiley(';%-P',	format(t,'stuck_out_tongue_closed_eyes'))
	CH:AddSmiley(';%-%)',	format(t,'wink'))
	CH:AddSmiley(';%)',		format(t,'wink'))
	CH:AddSmiley(':S',		format(t,'smirk'))
	CH:AddSmiley(':%-S',	format(t,'smirk'))
	CH:AddSmiley(':,%(',	format(t,'cry'))
	CH:AddSmiley(':,%-%(',	format(t,'cry'))
	CH:AddSmiley(':\'%(',	format(t,'cry'))
	CH:AddSmiley(':\'%-%(',	format(t,'cry'))
	CH:AddSmiley(':F',		format(t,'middle_finger'))
	CH:AddSmiley('<3',		format(t,'heart'))
	CH:AddSmiley('</3',		format(t,'broken_heart'))
end

function CH:Initialize()
	if ElvCharacterDB.ChatHistory then
		ElvCharacterDB.ChatHistory = nil --Depreciated
	end
	if ElvCharacterDB.ChatLog then
		ElvCharacterDB.ChatLog = nil --Depreciated
	end

	self.db = E.db.chat

	self:DelayGuildMOTD() --Keep this before `is Chat Enabled` check
	if E.private.chat.enable ~= true then return end

	if not ElvCharacterDB.ChatEditHistory then
		ElvCharacterDB.ChatEditHistory = {};
	end

	if not ElvCharacterDB.ChatHistoryLog or not self.db.chatHistory then
		ElvCharacterDB.ChatHistoryLog = {};
	end

	self:DefaultSmileys()
	self:UpdateChatKeywords()
	self:UpdateFading()

	E.Chat = self
	self:SecureHook('ChatEdit_OnEnterPressed')

	if WIM then
		WIM.RegisterWidgetTrigger("chat_display", "whisper,chat,w2w,demo", "OnHyperlinkClick", function(self) CH.clickedframe = self end);
		WIM.RegisterItemRefHandler('url', HyperLinkedURL)
		WIM.RegisterItemRefHandler('squ', HyperLinkedSQU)
		WIM.RegisterItemRefHandler('cpl', HyperLinkedCPL)
	end

	self:SecureHook('FCF_SetChatWindowFontSize', 'SetChatFont')
	self:SecureHook("FCF_SavePositionAndDimensions", "ON_FCF_SavePositionAndDimensions")
	self:RegisterEvent('UPDATE_CHAT_WINDOWS', 'SetupChat')
	self:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'SetupChat')
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'CheckLFGRoles')
	self:RegisterEvent('SOCIAL_QUEUE_UPDATE', 'SocialQueueEvent')
	self:RegisterEvent('PET_BATTLE_CLOSE')

	if E.private.general.voiceOverlay then
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED", "VoiceOverlay");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED", "VoiceOverlay");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED", "VoiceOverlay");
		self:RegisterEvent("VOICE_CHAT_COMMUNICATION_MODE_CHANGED", "VoiceOverlay");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_REMOVED", "VoiceOverlay");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED", "VoiceOverlay");
		self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED", "VoiceOverlay");
	end

	self:SetupChat()
	self:UpdateAnchors()
	if not E.db.chat.lockPositions then
		CH:UpdateChatTabs() --It was not done in PositionChat, so do it now
	end

	self:SecureHook("FCF_SetWindowAlpha")

	GeneralDockManagerOverflowButton:ClearAllPoints()
	GeneralDockManagerOverflowButton:Point('BOTTOMRIGHT', LeftChatTab, 'BOTTOMRIGHT', -2, 2)
	GeneralDockManagerOverflowButtonList:SetTemplate('Transparent')
	hooksecurefunc(GeneralDockManagerScrollFrame, 'SetPoint', function(self, point, anchor, attachTo, x, y)
		if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
			self:Point(point, anchor, attachTo, -2, -6)
		end
	end)

	for _, event in pairs(FindURL_Events) do
		ChatFrame_AddMessageEventFilter(event, CH[event] or CH.FindURL)
		local nType = strsub(event, 10)
		if nType ~= 'AFK' and nType ~= 'DND' and nType ~= 'COMMUNITIES_CHANNEL' then
			self:RegisterEvent(event, 'SaveChatHistory')
		end
	end

	if self.db.chatHistory then
		self:DisplayChatHistory()
	end

	local S = E:GetModule('Skins')
	S:HandleNextPrevButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton, true)
	local frame = CreateFrame("Frame", "CopyChatFrame", E.UIParent)
	tinsert(UISpecialFrames, "CopyChatFrame")
	frame:SetTemplate('Transparent')
	frame:Size(700, 200)
	frame:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 3)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetResizable(true)
	frame:SetMinResize(350, 100)
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving();
			self.isMoving = true;
		elseif button == "RightButton" and not self.isSizing then
			self:StartSizing();
			self.isSizing = true;
		end
	end)
	frame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		elseif button == "RightButton" and self.isSizing then
			self:StopMovingOrSizing();
			self.isSizing = false;
		end
	end)
	frame:SetScript("OnHide", function(self)
		if ( self.isMoving or self.isSizing) then
			self:StopMovingOrSizing();
			self.isMoving = false;
			self.isSizing = false;
		end
	end)
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	S:HandleScrollBar(CopyChatScrollFrameScrollBar)
	scrollArea:SetScript("OnSizeChanged", function(self)
		CopyChatFrameEditBox:Width(self:GetWidth())
		CopyChatFrameEditBox:Height(self:GetHeight())
	end)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (CopyChatFrameEditBox:GetHeight() - offset - self:GetHeight()))
	end)

	local editBox = CreateFrame("EditBox", "CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function() CopyChatFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	CopyChatFrameEditBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then return end
		local _, max = CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for i=1, max do
			ScrollFrameTemplate_OnMouseWheel(CopyChatScrollFrame, -1)
		end
	end)

	local close = CreateFrame("Button", "CopyChatFrameCloseButton", frame, "UIPanelCloseButton")
	close:Point("TOPRIGHT")
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:EnableMouse(true)

	S:HandleCloseButton(close)

	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(20, 22)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Point("TOPRIGHT", CombatLogQuickButtonFrame_Custom, "TOPRIGHT", 0, -1)

	ChatFrameMenuButton:Kill() -- We have it on your CopyChatButton via right click

	-- The width got changed in Bfa
	CombatLogQuickButtonFrame_CustomTexture:Hide()

	--Chat Heads Frame
	self.ChatHeadFrame = CreateFrame("Frame", "ElvUIChatHeadFrame", E.UIParent)
	self.ChatHeadFrame:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", 4, -80)
	self.ChatHeadFrame:Height(20)
	self.ChatHeadFrame:Width(200)
	E:CreateMover(self.ChatHeadFrame, 'VOICECHAT', L["Voice Overlay"]);
	self.maxHeads = 5
	self.volumeBarHeight = 3

	local CHAT_HEAD_HEIGHT = 40
	for i=1, self.maxHeads do
		self.ChatHeadFrame[i] = CreateFrame("Frame", "ElvUIChatHeadFrame"..i, self.ChatHeadFrame)
		self.ChatHeadFrame[i]:SetWidth(self.ChatHeadFrame:GetWidth())
		self.ChatHeadFrame[i]:SetHeight(CHAT_HEAD_HEIGHT)

		self.ChatHeadFrame[i].Portrait = CreateFrame("Frame", nil, self.ChatHeadFrame[i])
		self.ChatHeadFrame[i].Portrait:Width(CHAT_HEAD_HEIGHT - self.volumeBarHeight)
		self.ChatHeadFrame[i].Portrait:Height(CHAT_HEAD_HEIGHT - self.volumeBarHeight - E.Border*2)
		self.ChatHeadFrame[i].Portrait:SetPoint("TOPLEFT", self.ChatHeadFrame[i], "TOPLEFT")
		self.ChatHeadFrame[i].Portrait:SetTemplate()
		self.ChatHeadFrame[i].Portrait.texture = self.ChatHeadFrame[i].Portrait:CreateTexture(nil, "OVERLAY")
		self.ChatHeadFrame[i].Portrait.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.ChatHeadFrame[i].Portrait.texture:SetInside(self.ChatHeadFrame[i].Portrait)

		self.ChatHeadFrame[i].Name = self.ChatHeadFrame[i]:CreateFontString(nil, "OVERLAY")
		self.ChatHeadFrame[i].Name:FontTemplate(nil, 20)
		self.ChatHeadFrame[i].Name:SetPoint("LEFT", self.ChatHeadFrame[i].Portrait, "RIGHT", 2, 0)

		self.ChatHeadFrame[i].StatusBar = CreateFrame("StatusBar", nil, self.ChatHeadFrame[i])
		self.ChatHeadFrame[i].StatusBar:SetPoint("TOPLEFT", self.ChatHeadFrame[i].Portrait, "BOTTOMLEFT", E.Border, -E.Spacing*3)
		self.ChatHeadFrame[i].StatusBar:SetWidth(CHAT_HEAD_HEIGHT - E.Border*2 - self.volumeBarHeight)
		self.ChatHeadFrame[i].StatusBar:SetHeight(self.volumeBarHeight)
		self.ChatHeadFrame[i].StatusBar:CreateBackdrop()
		self.ChatHeadFrame[i].StatusBar:SetStatusBarTexture(E.media.normTex)
		self.ChatHeadFrame[i].StatusBar:SetMinMaxValues(0, 1)

		self.ChatHeadFrame[i].StatusBar.anim = CreateAnimationGroup(self.ChatHeadFrame[i].StatusBar)
		self.ChatHeadFrame[i].StatusBar.anim.progress = self.ChatHeadFrame[i].StatusBar.anim:CreateAnimation("Progress")
		self.ChatHeadFrame[i].StatusBar.anim.progress:SetSmoothing("Out")
		self.ChatHeadFrame[i].StatusBar.anim.progress:SetDuration(.3)

		self.ChatHeadFrame[i]:Hide()
	end

	self:SetChatHeadOrientation("TOP")
	self:Panels_ColorUpdate()
end

CH.TalkingList = {}
function CH:GetAvailableHead()
	for i=1, self.maxHeads do
		if not self.ChatHeadFrame[i]:IsShown() then
			return self.ChatHeadFrame[i]
		end
	end
end

function CH:GetHeadByID(memberID)
	for i=1, self.maxHeads do
		if self.ChatHeadFrame[i].memberID == memberID then
			return self.ChatHeadFrame[i]
		end
	end
end

function CH:ConfigureHead(memberID, channelID)
	local frame = self:GetAvailableHead()
	if not frame then return end

	frame.memberID = memberID
	frame.channelID = channelID

	C_VoiceChat_SetPortraitTexture(frame.Portrait.texture, memberID, channelID);

	local memberName = C_VoiceChat_GetMemberName(memberID, channelID);
	local r, g, b = Voice_GetVoiceChannelNotificationColor(channelID);
	frame.Name:SetText(memberName or "")
	frame.Name:SetVertexColor(r, g, b, 1);
	frame:Show()
end

function CH:DeconfigureHead(memberID, channelID)
	local frame = self:GetHeadByID(memberID)
	if not frame then return end

	frame.memberID = nil
	frame.channelID = nil
	frame:Hide()
end

function CH:VoiceOverlay(event, ...)
	if event == "VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED" then
		local memberID, channelID, isTalking = ...

		if isTalking then
			CH.TalkingList[memberID] = channelID
			self:ConfigureHead(memberID, channelID)
		else
			CH.TalkingList[memberID] = nil
			self:DeconfigureHead(memberID, channelID)
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED" then
		local memberID, channelID, volume = ...
		local frame = CH:GetHeadByID(memberID)
		if frame and channelID == frame.channelID then
			frame.StatusBar.anim.progress:SetChange(volume)
			frame.StatusBar.anim.progress:Play()

			frame.StatusBar:SetStatusBarColor(E:ColorGradient(volume, 1, 0, 0, 1, 1, 0, 0, 1, 0))
		end
	--[[elseif event == "VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED" then
		local channelID, isTransmitting = ...
		local localPlayerMemberID = C_VoiceChat.GetLocalPlayerMemberID(channelID);
		if isTransmitting and not CH.TalkingList[localPlayerMemberID] then
			CH.TalkingList[localPlayerMemberID] = channelID
			self:ConfigureHead(localPlayerMemberID, channelID)
		end]]
	end
end

function CH:SetChatHeadOrientation(position)

	if position == "TOP" then
		for i=1, self.maxHeads do
			self.ChatHeadFrame[i]:ClearAllPoints()
			if i == 1 then
				self.ChatHeadFrame[i]:SetPoint("TOP", self.ChatHeadFrame, "BOTTOM", 0, -E.Border*3)
			else
				self.ChatHeadFrame[i]:SetPoint("TOP", self.ChatHeadFrame[i - 1], "BOTTOM", 0, -E.Border*3)
			end
		end
	else
		for i=1, self.maxHeads do
			self.ChatHeadFrame[i]:ClearAllPoints()
			if i == 1 then
				self.ChatHeadFrame[i]:SetPoint("BOTTOM", self.ChatHeadFrame, "TOP", 0, E.Border*3)
			else
				self.ChatHeadFrame[i]:SetPoint("BOTTOM", self.ChatHeadFrame[i - 1], "TOP", 0, E.Border*3)
			end
		end
	end
end

local function InitializeCallback()
	CH:Initialize()
end

E:RegisterModule(CH:GetName(), InitializeCallback)
