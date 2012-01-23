local E, L, DF = unpack(select(2, ...)); --Engine
local CH = E:NewModule('Chat', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')

local CreatedFrames = 0;
local lines = {};
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

function CH:StyleChat(frame)
	if frame.styled then return end
	local id = frame:GetID()
	local name = frame:GetName()
	local tab = _G[name..'Tab']
	local editbox = _G[name..'EditBox']

	
	tab:StripTextures()
	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame	
	_G[tab:GetName()..'Glow']:SetTexture('Interface\\ChatFrame\\ChatFrameTab-NewMessage')
	
	tab.text = _G[name.."TabText"]
	tab.text:FontTemplate()
	tab.text:SetTextColor(unpack(E["media"].rgbvaluecolor))
	tab.text.OldSetTextColor = tab.text.SetTextColor 
	tab.text.SetTextColor = E.noop
	
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
	editbox:HookScript("OnTextChanged", function(self)
	   local text = self:GetText()
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
	   end
	end)
	
	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = editbox:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
			local id = GetChannelName(editbox:GetAttribute("channelTarget"))
			if id == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				editbox:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		else
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
	frame.button.tex:Point('TOPLEFT', 2, -2)
	frame.button.tex:Point('BOTTOMRIGHT', -2, 2)
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

function CH:SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	if frame.styled then return end
	
	self:StyleChat(frame)
end

function CH:PositionChat(override)
	if (InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override) then return end
	
	local chat, chatbg, tab, id, point, button, isDocked, chatFound
	for i = 1, NUM_CHAT_WINDOWS do
		chat = _G[format("ChatFrame%d", i)]
		id = chat:GetID()
		point = GetChatWindowSavedPosition(id)
		
		if point == "BOTTOMRIGHT" and chat:IsShown() then
			chatFound = true
			break
		end
	end	
	
	RightChatPanel:Size(E.db.core.panelWidth, E.db.core.panelHeight)
	LeftChatPanel:Size(E.db.core.panelWidth, E.db.core.panelHeight)
	
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
		_, _, _, _, _, _, _, _, isDocked, _ = GetChatWindowInfo(id)		
		
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
				chat:SetSize(E.db.core.panelWidth - 11, (E.db.core.panelHeight - 60))
			else
				chat:ClearAllPoints()
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
				chat:Size(E.db.core.panelWidth - 11, (E.db.core.panelHeight - 60) - CombatLogQuickButtonFrame_Custom:GetHeight())				
			end
			
			
			FCF_SavePositionAndDimensions(chat)			
			
			tab:SetParent(RightChatPanel)
			chat:SetParent(tab)
		elseif not isDocked and chat:IsShown() then
			tab:SetParent(E.UIParent)
			chat:SetParent(E.UIParent)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				chat:ClearAllPoints()
				chat:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
				chat:Size(E.db.core.panelWidth - 11, (E.db.core.panelHeight - 60))
				FCF_SavePositionAndDimensions(chat)		
			end
			chat:SetParent(LeftChatPanel)
			tab:SetParent(GeneralDockManager)
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
	end
end

function CH:PrintURL(url)
	return E['media'].hexvaluecolor.."|Hurl:"..url.."|h"..url.."|h|r "
end

function CH:FindURL(event, msg, ...)
	if not CH.db.url then return false, msg, ... end
	local newMsg, found = gsub(msg, "(%a+)://(%S+)%s?", CH:PrintURL("%1://%2"))
	if found > 0 then return false, newMsg, ... end
	
	newMsg, found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", CH:PrintURL("www.%1.%2"))
	if found > 0 then return false, newMsg, ... end

	newMsg, found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", CH:PrintURL("%1@%2%3%4"))
	if found > 0 then return false, newMsg, ... end
end

local OldChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
local function URLChatFrame_OnHyperlinkShow(self, link, ...)
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
		end
		
		text = text:gsub('|Hplayer:Elv:', '|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t|Hplayer:Elv:')
	end
	
	self.OldAddMessage(self, text, ...)
end

if E:IsFoolsDay() then
	local playerName = UnitName('player')
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
			end
			
			text = text:gsub('|Hplayer:'..playerName..':', '|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t|Hplayer:'..playerName..':')
		end
		
		self.OldAddMessage(self, text, ...)
	end
end

function CH:SetupChat(event, ...)	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		self:StyleChat(frame)
		FCFTab_UpdateAlpha(frame)
	end	
	
	GeneralDockManager:SetParent(LeftChatPanel)
	self:ScheduleRepeatingTimer('PositionChat', 1)
	self:PositionChat(true)
	self:SecureHook('FCF_OpenTemporaryWindow', 'SetupTempChat')

	self:UnregisterEvent('UPDATE_CHAT_WINDOWS')
	self:UnregisterEvent('UPDATE_FLOATING_CHAT_WINDOWS')
end

local sizes = {
	":14:14",
	":16:16",
	":12:20",
	":14",
}

function CH:Initialize()
	self.db = E.db.chat
	if self.db.enable ~= true then return end
	E.Chat = self
	
	FriendsMicroButton:Kill()
	ChatFrameMenuButton:Kill()
	ChatFrame_OnHyperlinkShow = URLChatFrame_OnHyperlinkShow
	self:RegisterEvent('UPDATE_CHAT_WINDOWS', 'SetupChat')
	self:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'SetupChat')
	
	self:SetupChat()

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", CH.FindURL)	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", CH.FindURL)
	
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
			if string.find(text, size) then
				self:SetText(string.gsub(text, size, ":12:12"))
			end		
		end
	end)

	local close = CreateFrame("Button", "CopyChatFrameCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT")
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:EnableMouse(true)
	
	S:HandleCloseButton(close)	
end

E:RegisterModule(CH:GetName())