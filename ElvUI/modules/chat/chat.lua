local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local CH = E:NewModule('Chat', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
local LSM = LibStub("LibSharedMedia-3.0")
local CreatedFrames = 0;
local lines = {};
local msgList, msgCount, msgTime = {}, {}, {}
local good, maybe, filter, login = {}, {}, {}, false

local TIMESTAMP_FORMAT
local DEFAULT_STRINGS = {
	BATTLEGROUND = L['BG'],
	GUILD = L['G'],
	PARTY = L['P'],
	RAID = L['R'],
	OFFICER = L['O'],
	BATTLEGROUND_LEADER = L['BGL'],
	PARTY_LEADER = L['PL'],
	RAID_LEADER = L['RL'],	
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
}

local tabTexs = {
	'',
	'Selected',
	'Highlight'
}

local smileyPack = {
	["Angry"] = [[Interface\AddOns\ElvUI\media\textures\smileys\angry.blp]],
	["Grin"] = [[Interface\AddOns\ElvUI\media\textures\smileys\grin.blp]],
	["Hmm"] = [[Interface\AddOns\ElvUI\media\textures\smileys\hmm.blp]],
	["MiddleFinger"] = [[Interface\AddOns\ElvUI\media\textures\smileys\middle_finger.blp]],
	["Sad"] = [[Interface\AddOns\ElvUI\media\textures\smileys\sad.blp]],
	["Surprise"] = [[Interface\AddOns\ElvUI\media\textures\smileys\surprise.blp]],
	["Tongue"] = [[Interface\AddOns\ElvUI\media\textures\smileys\tongue.blp]],
	["Cry"] = [[Interface\AddOns\ElvUI\media\textures\smileys\weepy.blp]],
	["Wink"] = [[Interface\AddOns\ElvUI\media\textures\smileys\winky.blp]],
	["Happy"] = [[Interface\AddOns\ElvUI\media\textures\smileys\happy.blp]],
	["Heart"] = [[Interface\AddOns\ElvUI\media\textures\smileys\heart.blp]],
	['BrokenHeart'] = [[Interface\AddOns\ElvUI\media\textures\smileys\broken_heart.blp]],
}

local smileyKeys = {
	["%:%-%@"] = "Angry",
	["%:%@"] = "Angry",
	["%:%-%)"]="Happy",
	["%:%)"]="Happy",
	["%:D"]="Grin",
	["%:%-D"]="Grin",
	["%;%-D"]="Grin",
	["%;D"]="Grin",
	["%=D"]="Grin",
	["xD"]="Grin",
	["XD"]="Grin",
	["%:%-%("]="Sad",
	["%:%("]="Sad",
	["%:o"]="Surprise",
	["%:%-o"]="Surprise",
	["%:%-O"]="Surprise",
	["%:O"]="Surprise",
	["%:%-0"]="Surprise",
	["%:P"]="Tongue",
	["%:%-P"]="Tongue",
	["%:p"]="Tongue",
	["%:%-p"]="Tongue",
	["%=P"]="Tongue",
	["%=p"]="Tongue",
	["%;%-p"]="Tongue",
	["%;p"]="Tongue",
	["%;P"]="Tongue",
	["%;%-P"]="Tongue",
	["%;%-%)"]="Wink",
	["%;%)"]="Wink",
	["%:S"]="Hmm",
	["%:%-S"]="Hmm",
	["%:%,%("]="Cry",
	["%:%,%-%("]="Cry",
	["%:%'%("]="Cry",
	["%:%'%-%("]="Cry",
	["%:%F"]="MiddleFinger",
	["<3"]="Heart",
	["</3"]="BrokenHeart",
};

CH.Keywords = {};

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
	for k,v in pairs(smileyKeys) do
		msg = string.gsub(msg,k,"|T"..smileyPack[v]..":16|t");
	end
	return msg;
end

function CH:GetSmileyReplacementText(msg)
	if not self.db.emotionIcons or msg:find('/run') or msg:find('/dump') or msg:find('/script') then return msg end
	local outstr = "";
	local origlen = string.len(msg);
	local startpos = 1;
	local endpos;
	
	while(startpos <= origlen) do
		endpos = origlen;
		local pos = string.find(msg,"|H",startpos,true);
		if(pos ~= nil) then
			endpos = pos;
		end
		outstr = outstr .. CH:InsertEmotions(string.sub(msg,startpos,endpos)); --run replacement on this bit
		startpos = endpos + 1;
		if(pos ~= nil) then
			endpos = string.find(msg,"|h]|r",startpos,-1) or string.find(msg,"|h",startpos,-1);
			if(endpos == nil) then
				endpos = origlen;
			end
			if(startpos < endpos) then
				outstr = outstr .. string.sub(msg,startpos,endpos); --don't run replacement on this bit
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

	local id = frame:GetID()
	
	local tab = _G[name..'Tab']
	local editbox = _G[name..'EditBox']
	
	for _, texName in pairs(tabTexs) do
		_G[tab:GetName()..texName..'Left']:Kill()
		_G[tab:GetName()..texName..'Middle']:Kill()
		_G[tab:GetName()..texName..'Right']:Kill()	
	end

	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame	
	tab.text = _G[name.."TabText"]
	tab.text:SetTextColor(unpack(E["media"].rgbvaluecolor))
	tab.text.OldSetTextColor = tab.text.SetTextColor 
	tab.text.SetTextColor = E.noop
	
	if tab.conversationIcon then
		tab.conversationIcon:ClearAllPoints()
		tab.conversationIcon:Point('RIGHT', tab.text, 'LEFT', -1, 0)
	end
	
	frame:SetClampRectInsets(0,0,0,0)
	frame:SetClampedToScreen(false)
	frame:StripTextures(true)
	_G[name..'ButtonFrame']:Kill()

	local a, b, c = select(6, editbox:GetRegions()); a:Kill(); b:Kill(); c:Kill()
	_G[format(editbox:GetName().."FocusLeft", id)]:Kill()
	_G[format(editbox:GetName().."FocusMid", id)]:Kill()
	_G[format(editbox:GetName().."FocusRight", id)]:Kill()	
	editbox:SetTemplate('Default', true)
	editbox:SetAltArrowKeyMode(false)
	editbox:HookScript("OnEditFocusGained", function(self) self:Show(); if not LeftChatPanel:IsShown() then LeftChatPanel.editboxforced = true; LeftChatToggleButton:GetScript('OnEnter')(LeftChatToggleButton) end end)
	editbox:HookScript("OnEditFocusLost", function(self) if LeftChatPanel.editboxforced then LeftChatPanel.editboxforced = nil; if LeftChatPanel:IsShown() then LeftChatToggleButton:GetScript('OnLeave')(LeftChatToggleButton) end end self:Hide() end)	
	editbox:SetAllPoints(LeftChatDataPanel)
	self:SecureHook(editbox, "AddHistoryLine", "ChatEdit_AddHistory")
	editbox:HookScript("OnTextChanged", function(self)
		local text = self:GetText()
		
		if InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = 5
			if (string.len(text) > MIN_REPEAT_CHARACTERS) then
			local repeatChar = true;
			for i=1, MIN_REPEAT_CHARACTERS, 1 do 
				if ( string.sub(text,(0-i), (0-i)) ~= string.sub(text,(-1-i),(-1-i)) ) then
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
		
		if text:len() < 5 then
			if text:sub(1, 4) == "/tt " then
				local unitname, realm
				unitname, realm = UnitName("target")
				if unitname then unitname = gsub(unitname, " ", "") end
				if unitname and not UnitIsSameServer("player", "target") then
					unitname = unitname .. "-" .. gsub(realm, " ", "")
				end
				ChatFrame_SendTell((unitname or L['Invalid Target']), ChatFrame1)
			end

			if text:sub(1, 4) == "/gr " then
				self:SetText(CH:GetGroupDistribution() .. text:sub(5));
				ChatEdit_ParseText(self, 0)		  
			end
		end

		local new, found = gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
		if found > 0 then
			new = new:gsub('|', '')
			self:SetText(new)
		end
	end)
	
	for i, text in pairs(ElvCharacterData.ChatEditHistory) do
		editbox:AddHistoryLine(text)
	end	
	
	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = editbox:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
			local id = GetChannelName(editbox:GetAttribute("channelTarget"))
			if id == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				editbox:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		elseif type then
			editbox:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
		end
	end)
	
	frame.OldAddMessage = frame.AddMessage
	frame.AddMessage = CH.AddMessage
	
	--copy chat button
	frame.button = CreateFrame('Frame', format("CopyChatButton%d", id), frame)
	frame.button:SetAlpha(0)
	frame.button:SetTemplate('Default', true)
	frame.button:Size(20, 22)
	frame.button:SetPoint('TOPRIGHT')
	
	frame.button.tex = frame.button:CreateTexture(nil, 'OVERLAY')
	frame.button.tex:SetInside()
	frame.button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\copy.tga]])
	
	frame.button:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" and id == 1 then
			ToggleFrame(ChatMenu)
		else
			CH:CopyChat(frame)
		end
	end)
	
	frame.button:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	frame.button:SetScript("OnLeave", function(self) self:SetAlpha(0) end)	
		
	CreatedFrames = id
	frame.styled = true
end

function CH:GetLines(...)
	local ct = 1
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			lines[ct] = tostring(region:GetText())
			ct = ct + 1
		end
	end
	return ct - 1
end

function CH:CopyChat(frame)
	if not CopyChatFrame:IsShown() then
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID());
		FCF_SetChatWindowFontSize(frame, frame, 0.01)
		CopyChatFrame:Show()
		local lineCt = self:GetLines(frame:GetRegions())
		local text = table.concat(lines, "\n", 1, lineCt)
		FCF_SetChatWindowFontSize(frame, frame, fontSize)
		CopyChatFrameEditBox:SetText(text)
	else
		CopyChatFrame:Hide()
	end
end

function CH:OnEnter(frame)
	_G[frame:GetName().."Text"]:Show()
end

function CH:OnLeave(frame)
	_G[frame:GetName().."Text"]:Hide()
end

local x = CreateFrame('Frame')
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
	elseif GetMouseFocus() ~= frame then
		_G[frame:GetName().."Text"]:Hide()
	end
end

function CH:PositionChat(override)
	if (InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override) then return end
	
	RightChatPanel:Size(E.db.chat.panelWidth, E.db.chat.panelHeight)
	LeftChatPanel:Size(E.db.chat.panelWidth, E.db.chat.panelHeight)	
	
	if E.private.chat.enable ~= true then return end
	
	local chat, chatbg, tab, id, point, button, isDocked, chatFound
	for _, frameName in pairs(CHAT_FRAMES) do
		chat = _G[frameName]
		id = chat:GetID()
		point = GetChatWindowSavedPosition(id)
		
		if point == "BOTTOMRIGHT" and chat:IsShown() then
			chatFound = true
			break
		end
	end	

	if chatFound then
		self.RightChatWindowID = id
	else
		self.RightChatWindowID = nil
	end
	
	for i=1, CreatedFrames do
		chat = _G[format("ChatFrame%d", i)]
		chatbg = format("ChatFrame%dBackground", i)
		button = _G[format("ButtonCF%d", i)]
		id = chat:GetID()
		tab = _G[format("ChatFrame%sTab", i)]
		point = GetChatWindowSavedPosition(id)
		isDocked = chat.isDocked
		
		if id > NUM_CHAT_WINDOWS then
			if point == nil then
				point = select(1, chat:GetPoint())
			end
			if select(2, tab:GetPoint()):GetName() ~= bg then
				isDocked = true
			else
				isDocked = false
			end	
		end	
		
		if not chat.isInitialized then return end
		
		if point == "BOTTOMRIGHT" and chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == self.RightChatWindowID then
			if id ~= 2 then
				chat:ClearAllPoints()
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
				chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - 60))
			else
				chat:ClearAllPoints()
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
				chat:Size(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - 60) - CombatLogQuickButtonFrame_Custom:GetHeight())				
			end
			
			
			FCF_SavePositionAndDimensions(chat)			
			
			tab:SetParent(RightChatPanel)
			chat:SetParent(tab)
			
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'LEFT' then
				CH:SetupChatTabs(tab, true)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not isDocked and chat:IsShown() then
			tab:SetParent(E.UIParent)
			chat:SetParent(E.UIParent)
			
			CH:SetupChatTabs(tab, true)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				chat:ClearAllPoints()
				chat:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
				chat:Size(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - 60))
				FCF_SavePositionAndDimensions(chat)		
			end
			chat:SetParent(LeftChatPanel)
			tab:SetParent(GeneralDockManager)
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'RIGHT' then
				CH:SetupChatTabs(tab, true)
			else
				CH:SetupChatTabs(tab, false)
			end			
		end		
	end
	
	self.initialMove = true;
end

local function UpdateChatTabColor(hex, r, g, b)
	for i=1, CreatedFrames do
		_G['ChatFrame'..i..'TabText']:OldSetTextColor(r, g, b)
	end
end
E['valueColorUpdateFuncs'][UpdateChatTabColor] = true

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()
	
	self:CancelTimer(frame.ScrollTimer, true)
end

function FloatingChatFrame_OnMouseScroll(frame, delta)
	if delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		else
			for i = 1, 3 do
				frame:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		else
			for i = 1, 3 do
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

function CH:PrintURL(url)
	return "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
end

function CH:FindURL(event, msg, ...)
	if (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER") and CH.db.whisperSound ~= 'None' and not CH.SoundPlayed then
		PlaySoundFile(LSM:Fetch("sound", CH.db.whisperSound), "Master")
		CH.SoundPlayed = true
		CH.SoundTimer = CH:ScheduleTimer('ThrottleSound', 1)
	end

	if not CH.db.url then 
		msg = CH:CheckKeyword(msg);
		msg = CH:GetSmileyReplacementText(msg);
		return false, msg, ... 
	end
	
	local newMsg, found = gsub(msg, "(%a+)://(%S+)%s?", CH:PrintURL("%1://%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	
	newMsg, found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", CH:PrintURL("www.%1.%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end

	newMsg, found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", CH:PrintURL("%1@%2%3%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	
	msg = CH:CheckKeyword(msg)
	msg = CH:GetSmileyReplacementText(msg)
	
	return false, msg, ...
end

local OldChatFrame_OnHyperlinkShow
local function URLChatFrame_OnHyperlinkShow(self, link, ...)
	CH.clickedframe = self
	if (link):sub(1, 3) == "url" then
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
		local currentLink = (link):sub(5)
		if (not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox)
		end
		ChatFrameEditBox:Insert(currentLink)
		ChatFrameEditBox:HighlightText()
		return
	end
	OldChatFrame_OnHyperlinkShow(self, link, ...)
end

local function WIM_URLLink(link)
	if (link):sub(1, 3) == "url" then
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
		local currentLink = (link):sub(5)
		if (not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox)
		end
		ChatFrameEditBox:Insert(currentLink)
		ChatFrameEditBox:HighlightText()
		return
	end
end

function CH:ShortChannel()
	return string.format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[self] or self:gsub("channel:", ""))
end

function CH:AddMessage(text, ...)
	if type(text) == "string" then		
		if CH.db.shortChannels then
			text = text:gsub("|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel)
			text = text:gsub('CHANNEL:', '')
			text = text:gsub("^(.-|h) "..L['whispers'], "%1")
			text = text:gsub("^(.-|h) "..L['says'], "%1")
			text = text:gsub("^(.-|h) "..L['yells'], "%1")
			text = text:gsub("<"..AFK..">", "[|cffFF0000"..L['AFK'].."|r] ")
			text = text:gsub("<"..DND..">", "[|cffE7E716"..L['DND'].."|r] ")
			text = text:gsub("^%["..RAID_WARNING.."%]", '['..L['RW']..']')	
			text = text:gsub("%[BN_CONVERSATION:", '%['..L["BN:"])
		end

		local timeStamp
		if CHAT_TIMESTAMP_FORMAT ~= nil then
			timeStamp = BetterDate(CHAT_TIMESTAMP_FORMAT, time());
			text = text:gsub(timeStamp, '')
		end
		
		--Add Timestamps
		if ( CH.db.timeStampFormat and CH.db.timeStampFormat ~= 'NONE' ) then
			timeStamp = BetterDate(CH.db.timeStampFormat, CH.timeOverride or time());
			timeStamp = timeStamp:gsub(' ', '')
			timeStamp = timeStamp:gsub('AM', ' AM')
			timeStamp = timeStamp:gsub('PM', ' PM')
			text = '|cffB3B3B3['..timeStamp..'] |r'..text
		end
			
		text = text:gsub('|Hplayer:Elvz:', '|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t|Hplayer:Elvz:')
		text = text:gsub('|Hplayer:Elvz%-', '|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t|Hplayer:Elvz%-')
		CH.timeOverride = nil;
	end

	self.OldAddMessage(self, text, ...)
end

local hyperLinkEntered
function CH:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return; end
	local linkToken = refString:match("^([^:]+)")
	if hyperlinkTypes[linkToken] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(refString)
		hyperLinkEntered = frame;
		GameTooltip:Show()
	end
end

function CH:OnHyperlinkLeave(frame, refString)
	local linkToken = refString:match("^([^:]+)")
	if hyperlinkTypes[linkToken] then
		HideUIPanel(GameTooltip)
		hyperLinkEntered = nil;
	end
end

function CH:OnMessageScrollChanged(frame)
	if hyperLinkEntered == frame then
		HideUIPanel(GameTooltip)
		hyperLinkEntered = false;
	end
end

function CH:EnableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if (not self.hooks or not self.hooks[frame] or not self.hooks[frame].OnHyperlinkEnter) then
			self:HookScript(frame, 'OnHyperlinkEnter')
			self:HookScript(frame, 'OnHyperlinkLeave')
			self:HookScript(frame, 'OnMessageScrollChanged')
		end
	end
end

function CH:DisableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if self.hooks and self.hooks[frame] and self.hooks[frame].OnHyperlinkEnter then
			self:Unhook(frame, 'OnHyperlinkEnter')
			self:Unhook(frame, 'OnHyperlinkLeave')
			self:Unhook(frame, 'OnMessageScrollChanged')
		end
	end
end

function CH:DisableChatThrottle()
	table.wipe(msgList); table.wipe(msgCount); table.wipe(msgTime)
end

function CH:SetupChat(event, ...)
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID());
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
	end	
	
	if self.db.hyperlinkHover then
		self:EnableHyperlink()
	end

	GeneralDockManager:SetParent(LeftChatPanel)
	self:ScheduleRepeatingTimer('PositionChat', 1)
	self:PositionChat(true)
	
	if not self.HookSecured then
		self:SecureHook('FCF_OpenTemporaryWindow', 'SetupChat')
		self.HookSecured = true;
	end
end

local sizes = {
	":14:14",
	":15:15",
	":16:16",
	":12:20",
	":14",
	":16",
}

local function PrepareMessage(author, message)
	return author:upper() .. message
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

local locale = GetLocale()
function CH:CHAT_MSG_CHANNEL(event, message, author, ...)
	
	local isSpam = nil
	if locale == 'enUS' or locale == 'enGB' then
		isSpam = CH.SpamFilter(self, event, message, author, ...)
	end
	
	if isSpam then
		return true;
	else
		local blockFlag = false
		local msg = PrepareMessage(author, message)

		-- ignore player messages
		if author == UnitName("player") then return CH.FindURL(self, event, message, author, ...) end
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
end

function CH:CHAT_MSG_YELL(event, message, author, ...)
	local isSpam = nil
	if locale == 'enUS' or locale == 'enGB' then
		isSpam = CH.SpamFilter(self, event, message, author, ...)
	end
	
	if isSpam then
		return true;
	else
		local blockFlag = false
		local msg = PrepareMessage(author, message)
		
		if msg == nil then return CH.FindURL(self, event, message, author, ...) end	

		-- ignore player messages
		if author == UnitName("player") then return CH.FindURL(self, event, message, author, ...) end
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
end

function CH:CHAT_MSG_SAY(event, message, author, ...)
	local isSpam = nil
	if locale == 'enUS' or locale == 'enGB' then
		isSpam = CH.SpamFilter(self, event, message, author, ...)
	end
	
	if isSpam then
		return true;
	else
		return CH.FindURL(self, event, message, author, ...)
	end
end

function CH:ThrottleSound()
	self.SoundPlayed = nil;
end

function CH:CheckKeyword(message)
	local replaceWords = {};

	for i=1, #{string.split(' ', message)} do
		local word = select(i, string.split(' ', message));
		if not word:find('|') then
			for keyword, _ in pairs(CH.Keywords) do
				if word:lower() == keyword:lower() then
					replaceWords[word] = E.media.hexvaluecolor..word..'|r'
					if self.db.keywordSound ~= 'None' and not self.SoundPlayed  then
						PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
						self.SoundPlayed = true
						self.SoundTimer = CH:ScheduleTimer('ThrottleSound', 1)			
					end
				end	
			end
		end
	end
	
	for word, replaceWord in pairs(replaceWords) do
		if message == word then
			message = message:gsub(word, replaceWord)
		elseif message:find(' '..word) then
			message = message:gsub(' '..word, ' '..replaceWord)
		elseif message:find(word..' ') then
			message = message:gsub(word..' ', replaceWord..' ')
		end
	end
	
	return message
end

function CH:AddLines(lines, ...)
  for i=select("#", ...),1,-1 do
    local x = select(i, ...)
    if x:GetObjectType() == "FontString" and not x:GetName() then
        table.insert(lines, x:GetText())
    end
  end
end


function CH:CopyLineFromPlayerlinkToEdit(origin_frame, ...)
    local frame = (origin_frame and origin_frame:GetObjectType() == "ScrollingMessageFrame" and origin_frame) or self.clickedframe
	if not frame then return; end
	self.lines = {};
	
    for i=1, #self.lines do
        self.lines[i] = nil
    end

    self:AddLines(self.lines, frame:GetRegions())

    local dropdownFrame = UIDROPDOWNMENU_INIT_MENU

    local name = dropdownFrame.name
    local server = dropdownFrame.server  or ""
    local linenum = dropdownFrame.lineID

    local fullname = name;

    if server:len()>0 then
        fullname = name.."-"..server;
    end

    local findname = "|Hplayer:"..fullname..":"..tostring(linenum)
    for i=1, #self.lines do
        if self.lines[i]:find(findname:gsub("%-", "%%-")) then
            local text = self.lines[i]:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h", ""):gsub("|h", "")
			text = text:gsub('|', '')
			
            local editBox = ChatEdit_ChooseBoxForSend(frame);
            if ( editBox ~= ChatEdit_GetActiveWindow() ) then
                ChatFrame_OpenChat(text, frame);
            else
                editBox:SetText(text);
            end
        end
    end
end


function CH:ChatEdit_OnEnterPressed(editBox)
	local type = editBox:GetAttribute("chatType");
	local chatFrame = editBox:GetParent();
	if not chatFrame.isTemporary and ChatTypeInfo[type].sticky == 1 then
		if not self.db.sticky then type = 'SAY'; end
		editBox:SetAttribute("chatType", type);
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
	if line:find("/rl") then return; end
	
	if ( strlen(line) > 0 ) then
		for i, text in pairs(ElvCharacterData.ChatEditHistory) do
			if text == line then
				return
			end
		end
		
		table.insert(ElvCharacterData.ChatEditHistory, #ElvCharacterData.ChatEditHistory + 1, line)
		if #ElvCharacterData.ChatEditHistory > 5 then
			table.remove(ElvCharacterData.ChatEditHistory, 1)
		end
	end
end

function CH:UpdateChatKeywords()
	table.wipe(CH.Keywords)
	local keywords = self.db.keywords
	keywords = keywords:gsub(',%s', ',')

	for i=1, #{string.split(',', keywords)} do
		local stringValue = select(i, string.split(',', keywords));
		if stringValue == '%MYNAME%' then
			stringValue = E.myname;
		end
		
		if stringValue ~= '' then
			CH.Keywords[stringValue] = true;
		end
	end
end

function CH:PET_BATTLE_CLOSE()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame and _G[frameName.."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG) then
			FCF_Close(frame)
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
	local temp, data = {}
	for id, _ in pairs(ElvCharacterData.ChatHistory) do
		table.insert(temp, tonumber(id))
	end
	
	table.sort(temp, function(a, b)
		return a < b
	end)
	
	for i = 1, #temp do
		data = ElvCharacterData.ChatHistory[tostring(temp[i])]

		if type(data) == "table" then
			CH.timeOverride = temp[i]
			ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, data[20], unpack(data))
		end
	end
end

local function GetTimeForSavedMessage()
	local randomTime = select(2, ("."):split(GetTime() or "0."..math.random(1, 999), 2)) or 0
	return time().."."..randomTime
end

function CH:SaveChatHistory(event, ...)
	if self.db.throttleInterval ~= 0 and (event == 'CHAT_MESSAGE_SAY' or event == 'CHAT_MESSAGE_YELL' or event == 'CHAT_MSG_CHANNEL') then	
		self:ChatThrottleHandler(event, ...)		
		
		local message, author = ...
		local msg = PrepareMessage(author, message)
		if author ~= UnitName("player") and msgList[msg] then
			if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
				return;
			end
		end		
	end
	
	local temp = {...}
	if #temp > 0 then
	  temp[20] = event
	  local timeForMessage = GetTimeForSavedMessage()
	  ElvCharacterData.ChatHistory[timeForMessage] = temp
	  
		local c, k = 0
		for id, data in pairs(ElvCharacterData.ChatHistory) do
			c = c + 1
			if (not k) or k > id then
				k = id
			end
		end
		
		if c > 128 then
			ElvCharacterData.ChatHistory[k] = nil
		end	  
	end
end

DEFAULT_CHAT_FRAME:UnregisterEvent("GUILD_MOTD")
function CH:Initialize()
	self.db = E.db.chat
	local msg = GetGuildRosterMOTD() or ""
	if E.private.chat.enable ~= true then 
		DEFAULT_CHAT_FRAME:RegisterEvent("GUILD_MOTD")
		ChatFrame_SystemEventHandler(DEFAULT_CHAT_FRAME, "GUILD_MOTD", msg)
		return 
	end
	if not ElvCharacterData.ChatEditHistory then
		ElvCharacterData.ChatEditHistory = {};
	end
	
	if not ElvCharacterData.ChatHistory or not self.db.chatHistory then
		ElvCharacterData.ChatHistory = {};
	end
	
	self:UpdateChatKeywords()
	
	self:UpdateFading()
	E.Chat = self
	self:SecureHook('ChatEdit_OnEnterPressed')
	FriendsMicroButton:Kill()
	ChatFrameMenuButton:Kill()
	OldChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
	ChatFrame_OnHyperlinkShow = URLChatFrame_OnHyperlinkShow
	
    if WIM then
      WIM.RegisterWidgetTrigger("chat_display", "whisper,chat,w2w,demo", "OnHyperlinkClick", function(self) CH.clickedframe = self end);
	  WIM.RegisterItemRefHandler('url', WIM_URLLink)
    end

	self:SecureHook('FCF_SetChatWindowFontSize', 'SetChatFont')
	self:RegisterEvent('UPDATE_CHAT_WINDOWS', 'SetupChat')
	self:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'SetupChat')
	self:RegisterEvent('PET_BATTLE_CLOSE')
	self:SetupChat()
	
	self:RegisterEvent('CHAT_MSG_BATTLEGROUND', 'SaveChatHistory')
	self:RegisterEvent('CHAT_MSG_BATTLEGROUND_LEADER', 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_BN_WHISPER", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_CHANNEL", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_EMOTE", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_GUILD", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_OFFICER", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_PARTY", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_RAID", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_RAID_WARNING", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_SAY", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_WHISPER", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", 'SaveChatHistory')
	self:RegisterEvent("CHAT_MSG_YELL", 'SaveChatHistory')

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CH.CHAT_MSG_CHANNEL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CH.CHAT_MSG_YELL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CH.CHAT_MSG_SAY)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CH.FindURL)	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", CH.FindURL)	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST", CH.FindURL)
	
	
	if self.db.chatHistory then
		self.SoundPlayed = true;
		self:DisplayChatHistory()
		self.SoundPlayed = nil;
		local f = CreateFrame('Frame')
		local OnUpdate = function(self)
			local msg = GetGuildRosterMOTD()
			if (msg and msg:len() > 0) then
				ChatFrame_SystemEventHandler(DEFAULT_CHAT_FRAME, "GUILD_MOTD", msg)		
				DEFAULT_CHAT_FRAME:RegisterEvent("GUILD_MOTD")
				self:SetScript('OnUpdate', nil)
			end		
		end
		f:SetScript('OnUpdate', OnUpdate)
	end
		
	
	local S = E:GetModule('Skins')
	local frame = CreateFrame("Frame", "CopyChatFrame", E.UIParent)
	frame:SetTemplate('Transparent')
	frame:Size(700, 200)
	frame:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 3)
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")


	local scrollArea = CreateFrame("ScrollFrame", "CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	S:HandleScrollBar(CopyChatScrollFrameScrollBar)

	local editBox = CreateFrame("EditBox", "CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	
	--EXTREME HACK..
	editBox:SetScript("OnTextSet", function(self)
		local text = self:GetText()
		
		for _, size in pairs(sizes) do
			if string.find(text, size) and not string.find(text, size.."]") then
				self:SetText(string.gsub(text, size, ":12:12"))
			end		
		end
	end)

	local close = CreateFrame("Button", "CopyChatFrameCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT")
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:EnableMouse(true)
	
	S:HandleCloseButton(close)	

	--Disable Blizzard
	InterfaceOptionsSocialPanelTimestampsButton:SetAlpha(0)
	InterfaceOptionsSocialPanelTimestampsButton:SetScale(0.000001)
	InterfaceOptionsSocialPanelTimestamps:SetAlpha(0)
	InterfaceOptionsSocialPanelTimestamps:SetScale(0.000001)
end

E:RegisterModule(CH:GetName())