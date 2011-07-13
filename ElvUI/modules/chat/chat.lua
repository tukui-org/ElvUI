-----------------------------------------------------------------------
-- SETUP ELVUI CHATS
-----------------------------------------------------------------------

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["chat"].enable ~= true then return end

local ElvuiChat = CreateFrame("Frame")
local _G = _G
local origs = {}
local type = type
local CreatedFrames = 0

-- function to rename channel and other stuff
local AddMessage = function(self, text, ...)
	if(type(text) == "string") then
		text = text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h')
	end
	return origs[self](self, text, ...)
end

-- don't replace this with custom colors, since many addons
-- use these strings to detect if friends come on-line or go off-line 
--_G.ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h "..L.chat_ERR_FRIEND_ONLINE_SS.."!"
--_G.ERR_FRIEND_OFFLINE_S = "%s "..L.chat_ERR_FRIEND_OFFLINE_S.."!"

-- Hide friends micro button (added in 3.3.5)
FriendsMicroButton:Kill()

-- hide chat bubble menu button
ChatFrameMenuButton:Kill()

local EditBoxDummy = CreateFrame("Frame", "EditBoxDummy", E.UIParent)
EditBoxDummy:SetAllPoints(ElvuiInfoLeft)

-- set the chat style
local function SetChatStyle(frame)
	local id = frame:GetID()
	local chat = frame:GetName()
	local tab = _G[chat.."Tab"]
	frame.skinned = true
	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame	
	
	-- always set alpha to 1, don't fade it anymore
	if C["chat"].showbackdrop ~= true then
		-- hide text when setting chat
		_G[chat.."TabText"]:Hide()

		-- now show text if mouse is found over tab.
		tab:HookScript("OnEnter", function() _G[chat.."TabText"]:Show() end)
		tab:HookScript("OnLeave", function() _G[chat.."TabText"]:Hide() end)
	end
	
	_G[chat.."TabText"]:SetTextColor(unpack(C["media"].valuecolor))
	_G[chat.."TabText"]:SetFont(C["media"].font,C["general"].fontscale,"THINOUTLINE")
	_G[chat.."TabText"]:SetShadowColor(0, 0, 0, 0.4)
	_G[chat.."TabText"]:SetShadowOffset(E.mult, -E.mult)
	_G[chat.."TabText"].SetTextColor = E.dummy
	local originalpoint = select(2, _G[chat.."TabText"]:GetPoint())
	_G[chat.."TabText"]:SetPoint("LEFT", originalpoint, "RIGHT", 0, -E.mult*2)
	_G[chat]:SetMinResize(250,70)
	
	--Reposition the "New Message" orange glow so its aligned with the bottom of the chat tab
	for i=1, tab:GetNumRegions() do
		local region = select(i, tab:GetRegions())
		if region:GetObjectType() == "Texture" then
			if region:GetTexture() == "Interface\\ChatFrame\\ChatFrameTab-NewMessage" then
				if C["chat"].showbackdrop == true then
					region:ClearAllPoints()
					region:SetPoint("BOTTOMLEFT", 0, E.Scale(4))
					region:SetPoint("BOTTOMRIGHT", 0, E.Scale(4))
				else
					region:Kill()
				end
				if region:GetParent():GetName() == "ChatFrame1Tab" then
					region:Kill()
				end
			end
		end
	end
	-- yeah baby
	_G[chat]:SetClampRectInsets(0,0,0,0)
	
	-- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen.
	_G[chat]:SetClampedToScreen(false)
			
	-- Stop the chat chat from fading out
	_G[chat]:SetFading(C["chat"].fadeoutofuse)
	
	-- move the chat edit box
	_G[chat.."EditBox"]:ClearAllPoints();
	_G[chat.."EditBox"]:SetPoint("TOPLEFT", EditBoxDummy, E.Scale(2), E.Scale(-2))
	_G[chat.."EditBox"]:SetPoint("BOTTOMRIGHT", EditBoxDummy, E.Scale(-2), E.Scale(2))
	
	-- Hide textures
	for j = 1, #CHAT_FRAME_TEXTURES do
		_G[chat..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
	end

	-- Removes Default ChatFrame Tabs texture				
	_G[format("ChatFrame%sTabLeft", id)]:Kill()
	_G[format("ChatFrame%sTabMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabRight", id)]:Kill()

	_G[format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedRight", id)]:Kill()
	
	_G[format("ChatFrame%sTabHighlightLeft", id)]:Kill()
	_G[format("ChatFrame%sTabHighlightMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabHighlightRight", id)]:Kill()

	-- Killing off the new chat tab selected feature
	_G[format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedRight", id)]:Kill()

	-- Kills off the new method of handling the Chat Frame scroll buttons as well as the resize button
	-- Note: This also needs to include the actual frame textures for the ButtonFrame onHover
	_G[format("ChatFrame%sButtonFrameUpButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameDownButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameBottomButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameMinimizeButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrame", id)]:Kill()

	-- Kills off the retarded new circle around the editbox
	_G[format("ChatFrame%sEditBoxFocusLeft", id)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusMid", id)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusRight", id)]:Kill()

	-- Kill off editbox artwork
	local a, b, c = select(6, _G[chat.."EditBox"]:GetRegions()); a:Kill(); b:Kill(); c:Kill()
				
	-- Disable alt key usage
	_G[chat.."EditBox"]:SetAltArrowKeyMode(false)
	
	-- hide editbox on login
	_G[chat.."EditBox"]:Hide()
	
	-- script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
	_G[chat.."EditBox"]:HookScript("OnEditFocusGained", function(self) self:Show() end)
	_G[chat.."EditBox"]:HookScript("OnEditFocusLost", function(self) self:Hide() end)
	
	-- rename combag log to log
	if _G[chat] == _G["ChatFrame2"] then
		FCF_SetWindowName(_G[chat], "Log")
	end

	-- create our own texture for edit box
	local EditBoxBackground = CreateFrame("frame", "ElvuiChatchatEditBoxBackground", _G[chat.."EditBox"])
	EditBoxBackground:CreatePanel("Default", 1, 1, "LEFT", _G[chat.."EditBox"], "LEFT", 0, 0)
	EditBoxBackground:SetTemplate("Default", true)
	EditBoxBackground:ClearAllPoints()
	EditBoxBackground:SetAllPoints(EditBoxDummy)
	EditBoxBackground:SetFrameStrata("LOW")
	EditBoxBackground:SetFrameLevel(1)
	
	local function colorize(r,g,b)
		EditBoxBackground:SetBackdropBorderColor(r, g, b)
	end
	
	-- update border color according where we talk
	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = _G[chat.."EditBox"]:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
		local id = GetChannelName(_G[chat.."EditBox"]:GetAttribute("channelTarget"))
			if id == 0 then
				colorize(unpack(C.media.bordercolor))
			else
				colorize(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		else
			colorize(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
		end
	end)
		
	if _G[chat] ~= _G["ChatFrame2"] then
		origs[_G[chat]] = _G[chat].AddMessage
		_G[chat].AddMessage = AddMessage
	end
	CreatedFrames = id
	E.ChatCopyButtons(id)
end

-- Setup chatframes 1 to 10 on login.
local function SetupChat(self)	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
		FCFTab_UpdateAlpha(frame)
	end
	
	local var
	if C["chat"].sticky == true then
		var = 1
	else
		var = 0
	end
	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = var
	ChatTypeInfo.BN_WHISPER.sticky = var
	ChatTypeInfo.OFFICER.sticky = var
	ChatTypeInfo.RAID_WARNING.sticky = var
	ChatTypeInfo.CHANNEL.sticky = var
end

local insidetab = false
local function SetupChatFont(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local name = FCF_GetChatWindowInfo(id)
		local point = GetChatWindowSavedPosition(id)
		local button = _G[format("ButtonCF%d", i)]
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		
		chat:SetFrameStrata("LOW")
		
		local _, fontSize = FCF_GetChatWindowInfo(id)
		
		--font under fontsize 12 is unreadable.
		if fontSize < 12 then		
			FCF_SetChatWindowFontSize(nil, chat, 12)
		else
			FCF_SetChatWindowFontSize(nil, chat, fontSize)
		end
		
		tab:HookScript("OnEnter", function() insidetab = true end)
		tab:HookScript("OnLeave", function() insidetab = false end)	
	end
end
hooksecurefunc("FCF_OpenNewWindow", SetupChatFont)
hooksecurefunc("FCF_DockFrame", SetupChatFont)

ElvuiChat:RegisterEvent("ADDON_LOADED")
ElvuiChat:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiChat:SetScript("OnEvent", function(self, event, ...)
	local addon = ...
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			self:UnregisterEvent("ADDON_LOADED")
			SetupChat(self)
			--return CombatLogQuickButtonFrame_Custom:SetAlpha(.4)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetupChatFont(self)
		GeneralDockManager:SetParent(ChatLBG)
	end
end)

local chat, tab, id, point, button, docked, chatfound
E.RightChat = true
ElvuiChat:SetScript("OnUpdate", function(self, elapsed)
	if(self.elapsed and self.elapsed > 1) then
		if insidetab == true or IsMouseButtonDown("LeftButton") then self.elapsed = 0 return end
		chatfound = false
		for i = 1, NUM_CHAT_WINDOWS do
			chat = _G[format("ChatFrame%d", i)]
			id = chat:GetID()
			point = GetChatWindowSavedPosition(id)
			
			if point == "BOTTOMRIGHT" and chat:IsShown() then
				chatfound = true
				break
			end
		end
		
		E.RightChat = chatfound
		if chatfound == true then
			if ChatRBG then ChatRBG:SetAlpha(1) end
			E.RightChatWindowID = id
		else
			if ChatRBG then ChatRBG:SetAlpha(0) end
			E.RightChatWindowID = nil
		end

		
		for i = 1, CreatedFrames do
			chat = _G[format("ChatFrame%d", i)]
			local bg = format("ChatFrame%dBackground", i)
			button = _G[format("ButtonCF%d", i)]
			id = chat:GetID()
			tab = _G[format("ChatFrame%sTab", i)]
			point = GetChatWindowSavedPosition(id)
			_, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)	
			
			if id > NUM_CHAT_WINDOWS then
				if point == nil then
					point = select(1, chat:GetPoint())
				end
				if select(2, tab:GetPoint()):GetName() ~= bg then
					docked = true
				else
					docked = false
				end	
			end
						
			if point == "BOTTOMRIGHT" and chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == E.RightChatWindowID then
				if id ~= 2 then
					chat:ClearAllPoints()
					chat:SetPoint("BOTTOMLEFT", ChatRPlaceHolder, "BOTTOMLEFT", E.Scale(2), E.Scale(4))
					chat:SetSize(E.Scale(C["chat"].chatwidth - 4), E.Scale(C["chat"].chatheight))
				else
					chat:ClearAllPoints()
					chat:SetPoint("BOTTOMLEFT", ChatRPlaceHolder, "BOTTOMLEFT", E.Scale(2), E.Scale(4))
					chat:SetSize(E.Scale(C["chat"].chatwidth - 4), E.Scale(C["chat"].chatheight - CombatLogQuickButtonFrame_Custom:GetHeight()))				
				end
				FCF_SavePositionAndDimensions(chat)			
				
				tab:SetParent(ChatRBG)
				chat:SetParent(tab)
			elseif not docked and chat:IsShown() then
				tab:SetParent(E.UIParent)
				chat:SetParent(E.UIParent)
			else
				if chat:GetID() ~= 2 and not (id > NUM_CHAT_WINDOWS) then
					chat:ClearAllPoints()
					chat:SetPoint("BOTTOMLEFT", ChatLPlaceHolder, "BOTTOMLEFT", E.Scale(2), E.Scale(4))
					chat:SetSize(E.Scale(C["chat"].chatwidth - 4), E.Scale(C["chat"].chatheight))
					FCF_SavePositionAndDimensions(chat)		
				end
				chat:SetParent(ChatLBG)
				tab:SetParent(GeneralDockManager)
			end
		end
		
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)

-- Setup temp chat (BN, WHISPER) when needed.
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	
	-- do a check if we already did a skinning earlier for this temp chat frame
	if frame.skinned then return end

	-- style it
	SetChatStyle(frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

-- /tt - tell your current target.
for i = 1, NUM_CHAT_WINDOWS do
	local editBox = _G["ChatFrame"..i.."EditBox"]
	editBox:HookScript("OnTextChanged", function(self)
	   local text = self:GetText()
	   if text:len() < 5 then
		  if text:sub(1, 4) == "/tt " then
			 local unitname, realm
			 unitname, realm = UnitName("target")
			 if unitname then unitname = gsub(unitname, " ", "") end
			 if unitname and not UnitIsSameServer("player", "target") then
				unitname = unitname .. "-" .. gsub(realm, " ", "")
			 end
			 ChatFrame_SendTell((unitname or L.chat_invalidtarget), ChatFrame1)
		  end
	   end
	end)
end

-----------------------------------------------------------------------------
-- Copy on chatframes feature
-----------------------------------------------------------------------------

local lines = {}
local frame = nil
local editBox = nil
local isf = nil


local sizes = {
	":14:14",
	":16:16",
	":12:20",
	":14",
}

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", E.UIParent)
	frame:SetTemplate('Transparent')
	frame:SetHeight(E.Scale(200))
	frame:SetScale(1)
	frame:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", 0, 0)
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")


	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", E.Scale(8), E.Scale(-30))
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", E.Scale(-30), E.Scale(8))
	
	E.SkinScrollBar(CopyScrollScrollBar)

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(E.Scale(200))
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	
	--EXTREME HACK..
	editBox:SetScript("OnTextSet", function(self)
		local text = self:GetText()
		
		for _, size in pairs(sizes) do
			if string.find(text, size) then
				self:SetText(string.gsub(text, size, ":12:12"))
			end		
		end
	end)

	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	close:EnableMouse(true)
	close:SetScript("OnMouseUp", function()
		frame:Hide()
	end)
	
	E.SkinCloseButton(close)
	
	isf = true
end

local function GetLines(...)
	--[[		Grab all those lines		]]--
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

local function Copy(cf)
	local _, size = cf:GetFont()
	FCF_SetChatWindowFontSize(cf, cf, 0.01)
	local lineCt = GetLines(cf:GetRegions())
	local text = table.concat(lines, "\n", 1, lineCt)
	FCF_SetChatWindowFontSize(cf, cf, size)
	if not isf then CreatCopyFrame() end
	if frame:IsShown() then frame:Hide() return end
	frame:Show()
	editBox:SetText(text)
end

function E.ChatCopyButtons(id)
	local cf = _G[format("ChatFrame%d",  id)]
	local tab = _G[format("ChatFrame%dTab", id)]
	local name = FCF_GetChatWindowInfo(id)
	local point = GetChatWindowSavedPosition(id)
	local _, fontSize = FCF_GetChatWindowInfo(id)
	local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
	local button = _G[format("ButtonCF%d", id)]
	
	if not button then
		local button = CreateFrame("Button", format("ButtonCF%d", id), cf)
		button:SetHeight(E.Scale(22))
		button:SetWidth(E.Scale(20))
		button:SetAlpha(0)
		button:SetPoint("TOPRIGHT", 0, 0)
		button:SetTemplate("Default", true)
		
		local buttontex = button:CreateTexture(nil, 'OVERLAY')
		buttontex:SetPoint('TOPLEFT', button, 'TOPLEFT', 2, -2)
		buttontex:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2)
		buttontex:SetTexture([[Interface\AddOns\ElvUI\media\textures\copy.tga]])
		
		if id == 1 then
			button:SetScript("OnMouseUp", function(self, btn)
				if btn == "RightButton" then
					ToggleFrame(ChatMenu)
				else
					Copy(cf)
				end
			end)
		else
			button:SetScript("OnMouseUp", function(self, btn)
				Copy(cf)
			end)		
		end
		
		button:SetScript("OnEnter", function() 
			button:SetAlpha(1) 
		end)
		button:SetScript("OnLeave", function() button:SetAlpha(0) end)
	end

end

------------------------------------------------------------------------
--	Enhance/rewrite a Blizzard feature, chatframe mousewheel.
------------------------------------------------------------------------

local ScrollLines = 3 -- set the jump when a scroll is done !
function FloatingChatFrame_OnMouseScroll(self, delta)
	if delta < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			for i = 1, ScrollLines do
				self:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			for i = 1, ScrollLines do
				self:ScrollUp()
			end
		end
	end
end

------------------------------------------------------------------------
--	Play sound files system
------------------------------------------------------------------------

if C.chat.whispersound then
	local SoundSys = CreateFrame("Frame")
	SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
	SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
	SoundSys:HookScript("OnEvent", function(self, event, ...)
		if event == "CHAT_MSG_WHISPER" or "CHAT_MSG_BN_WHISPER" then
			PlaySoundFile(C["media"].whisper)
		end
	end)
end

----------------------------------------------------------------------
-- Setup animating chat during combat
----------------------------------------------------------------------

local ChatCombatHider = CreateFrame("Frame")
ChatCombatHider:RegisterEvent("PLAYER_REGEN_ENABLED")
ChatCombatHider:RegisterEvent("PLAYER_REGEN_DISABLED")
ChatCombatHider:SetScript("OnEvent", function(self, event)
	if C["chat"].combathide ~= "Left" and C["chat"].combathide ~= "Right" and C["chat"].combathide ~= "Both" then self:UnregisterAllEvents() return end
	if (C["chat"].combathide == "Right" or C["chat"].combathide == "Both") and E.RightChat ~= true then return end
	
	if event == "PLAYER_REGEN_DISABLED" then
		if C["chat"].combathide == "Both" then	
			if E.ChatRIn ~= false then
				ChatRBG:Hide()			
				E.ChatRightShown = false
				E.ChatRIn = false
				ElvuiInfoRightRButton.text:SetTextColor(unpack(C["media"].valuecolor))			
			end
			if E.ChatLIn ~= false then
				ChatLBG:Hide()	
				E.ChatLIn = false
				ElvuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].valuecolor))
			end
		elseif C["chat"].combathide == "Right" then
			if E.ChatRIn ~= false then
				ChatRBG:Hide()				
				E.ChatRightShown = false
				E.ChatRIn = false
				ElvuiInfoRightRButton.text:SetTextColor(unpack(C["media"].valuecolor))			
			end		
		elseif C["chat"].combathide == "Left" then
			if E.ChatLIn ~= false then
				ChatLBG:Hide()
				E.ChatLIn = false
				ElvuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].valuecolor))
			end		
		end
	else
		if C["chat"].combathide == "Both" then
			if E.ChatRIn ~= true then
				ChatRBG:Show()							
				E.ChatRightShown = true
				E.ChatRIn = true
				ElvuiInfoRightRButton.text:SetTextColor(1,1,1)			
			end
			if E.ChatLIn ~= true then
				ChatLBG:Show()
				E.ChatLIn = true
				ElvuiInfoLeftLButton.text:SetTextColor(1,1,1)
			end
		elseif C["chat"].combathide == "Right" then
			if E.ChatRIn ~= true then
				ChatRBG:Show()					
				E.ChatRightShown = true
				E.ChatRIn = true
				ElvuiInfoRightRButton.text:SetTextColor(1,1,1)			
			end		
		elseif C["chat"].combathide == "Left" then
			if E.ChatLIn ~= true then
				ChatLBG:Show()
				E.ChatLIn = true
				ElvuiInfoLeftLButton.text:SetTextColor(1,1,1)
			end		
		end	
	end
end)

E.SetUpAnimGroup(ElvuiInfoLeft.shadow)
E.SetUpAnimGroup(ElvuiInfoRight.shadow)
local function CheckWhisperWindows(self, event)
	local chat = self:GetName()
	if chat == "ChatFrame1" and E.ChatLIn == false then
		if event == "CHAT_MSG_WHISPER" then
			ElvuiInfoLeft.shadow:SetBackdropBorderColor(ChatTypeInfo["WHISPER"].r,ChatTypeInfo["WHISPER"].g,ChatTypeInfo["WHISPER"].b, 1)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			ElvuiInfoLeft.shadow:SetBackdropBorderColor(ChatTypeInfo["BN_WHISPER"].r,ChatTypeInfo["BN_WHISPER"].g,ChatTypeInfo["BN_WHISPER"].b, 1)
		end
		ElvuiInfoLeft:SetScript("OnUpdate", function(self)
			if not E.ChatLIn then
				E.Flash(self.shadow, 0.5)
			else
				E.StopFlash(self.shadow)
				self:SetScript('OnUpdate', nil)				
				E.Delay(1, function()
					if C["chat"].style ~= "ElvUI" then
						self.shadow:SetBackdropBorderColor(0,0,0,0.9) 	
					else
						self.shadow:SetBackdropBorderColor(0,0,0,0) 
					end
				end)
			end
		end)
	elseif E.RightChatWindowID and chat == _G[format("ChatFrame%s", E.RightChatWindowID)]:GetName() and E.RightChat == true and E.ChatRIn == false then
		if event == "CHAT_MSG_WHISPER" then
			ElvuiInfoRight.shadow:SetBackdropBorderColor(ChatTypeInfo["WHISPER"].r,ChatTypeInfo["WHISPER"].g,ChatTypeInfo["WHISPER"].b, 1)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			ElvuiInfoRight.shadow:SetBackdropBorderColor(ChatTypeInfo["BN_WHISPER"].r,ChatTypeInfo["BN_WHISPER"].g,ChatTypeInfo["BN_WHISPER"].b, 1)
		end
		ElvuiInfoRight:SetScript("OnUpdate", function(self)
			if E.RightChatWindowID and chat == _G[format("ChatFrame%s", E.RightChatWindowID)]:GetName() and E.RightChat == true and E.ChatRIn == false then
				E.Flash(self.shadow, 0.5)
			else
				E.StopFlash(self.shadow)
				self:SetScript('OnUpdate', nil)				
				E.Delay(1, function()
					if C["chat"].style ~= "ElvUI" then
						self.shadow:SetBackdropBorderColor(0,0,0,0.9) 
					else
						self.shadow:SetBackdropBorderColor(0,0,0,0) 	
					end
				end)
			end
		end)	
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CheckWhisperWindows)	
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CheckWhisperWindows)