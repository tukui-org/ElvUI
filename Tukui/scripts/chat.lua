if TukuiCF["chat"].enable ~= true then return end

-----------------------------------------------------------------------
-- SETUP TUKUI CHATS
-----------------------------------------------------------------------

local TukuiChat = CreateFrame("Frame")
local tabalpha = 1
local tabnoalpha = 0
local _G = _G
local origs = {}
local type = type

-- function to rename channel and other stuff
local AddMessage = function(self, text, ...)
	if(type(text) == "string") then
		text = text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h')
	end
	return origs[self](self, text, ...)
end

-- localize this later k tukz? DON'T FORGET!
_G.CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|h"..tukuilocal.chat_BATTLEGROUND_GET.."|h %s:\32"
_G.CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|h"..tukuilocal.chat_BATTLEGROUND_LEADER_GET.."|h %s:\32"
_G.CHAT_BN_WHISPER_GET = tukuilocal.chat_BN_WHISPER_GET.." %s:\32"
_G.CHAT_GUILD_GET = "|Hchannel:Guild|h"..tukuilocal.chat_GUILD_GET.."|h %s:\32"
_G.CHAT_OFFICER_GET = "|Hchannel:o|h"..tukuilocal.chat_OFFICER_GET.."|h %s:\32"
_G.CHAT_PARTY_GET = "|Hchannel:Party|h"..tukuilocal.chat_PARTY_GET.."|h %s:\32"
_G.CHAT_PARTY_GUIDE_GET = "|Hchannel:party|h"..tukuilocal.chat_PARTY_GUIDE_GET.."|h %s:\32"
_G.CHAT_PARTY_LEADER_GET = "|Hchannel:party|h"..tukuilocal.chat_PARTY_LEADER_GET.."|h %s:\32"
_G.CHAT_RAID_GET = "|Hchannel:raid|h"..tukuilocal.chat_RAID_GET.."|h %s:\32"
_G.CHAT_RAID_LEADER_GET = "|Hchannel:raid|h"..tukuilocal.chat_RAID_LEADER_GET.."|h %s:\32"
_G.CHAT_RAID_WARNING_GET = tukuilocal.chat_RAID_WARNING_GET.." %s:\32"
_G.CHAT_SAY_GET = "%s:\32"
_G.CHAT_WHISPER_GET = tukuilocal.chat_WHISPER_GET.." %s:\32"
_G.CHAT_YELL_GET = "%s:\32"
 
_G.CHAT_FLAG_AFK = "|cffFF0000"..tukuilocal.chat_FLAG_AFK.."|r "
_G.CHAT_FLAG_DND = "|cffE7E716"..tukuilocal.chat_FLAG_DND.."|r "
_G.CHAT_FLAG_GM = "|cff4154F5"..tukuilocal.chat_FLAG_GM.."|r "
 
_G.ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h "..tukuilocal.chat_ERR_FRIEND_ONLINE_SS.."!"
_G.ERR_FRIEND_OFFLINE_S = "%s "..tukuilocal.chat_ERR_FRIEND_OFFLINE_S.."!"

-- Hide friends micro button (added in 3.3.5)
TukuiDB.Kill(FriendsMicroButton)

-- hide chat bubble menu button
TukuiDB.Kill(ChatFrameMenuButton)

-- set the chat style
local function SetChatStyle(frame)
	local id = frame:GetID()
	local chat = frame:GetName()
	local tab = _G[chat.."Tab"]
	
	-- always set alpha to 1, don't fade it anymore
	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame
	
	-- hide text when setting chat
	_G[chat.."TabText"]:Hide()
	
	-- now show text if mouse is found over tab.
	tab:HookScript("OnEnter", function() _G[chat.."TabText"]:Show() end)
	tab:HookScript("OnLeave", function() _G[chat.."TabText"]:Hide() end)
	
	-- yeah baby
	_G[chat]:SetClampRectInsets(0,0,0,0)
	
	-- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen.
	_G[chat]:SetClampedToScreen(false)
			
	-- Stop the chat chat from fading out
	_G[chat]:SetFading(false)
	
	-- move the chat edit box
	_G[chat.."EditBox"]:ClearAllPoints();
	_G[chat.."EditBox"]:SetPoint("TOPLEFT", TukuiInfoLeft, TukuiDB.Scale(2), TukuiDB.Scale(-2))
	_G[chat.."EditBox"]:SetPoint("BOTTOMRIGHT", TukuiInfoLeft, TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	-- Hide textures
	for j = 1, #CHAT_FRAME_TEXTURES do
		_G[chat..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
	end

	-- Removes Default ChatFrame Tabs texture				
	TukuiDB.Kill(_G[format("ChatFrame%sTabLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabRight", id)])

	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedRight", id)])
	
	TukuiDB.Kill(_G[format("ChatFrame%sTabHighlightLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabHighlightMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabHighlightRight", id)])

	-- Killing off the new chat tab selected feature
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedRight", id)])

	-- Kills off the new method of handling the Chat Frame scroll buttons as well as the resize button
	-- Note: This also needs to include the actual frame textures for the ButtonFrame onHover
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameUpButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameDownButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameBottomButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameMinimizeButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrame", id)])

	-- Kills off the retarded new circle around the editbox
	TukuiDB.Kill(_G[format("ChatFrame%sEditBoxFocusLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sEditBoxFocusMid", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sEditBoxFocusRight", id)])

	-- Kill off editbox artwork
	local a, b, c = select(6, _G[chat.."EditBox"]:GetRegions()); TukuiDB.Kill (a); TukuiDB.Kill (b); TukuiDB.Kill (c)
				
	-- Disable alt key usage
	_G[chat.."EditBox"]:SetAltArrowKeyMode(false)
	
	-- hide editbox on login
	_G[chat.."EditBox"]:Hide()

	-- script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
	_G[chat.."EditBox"]:HookScript("OnEditFocusLost", function(self) self:Hide() end)
	
	-- hide edit box every time we click on a tab
	_G[chat.."Tab"]:HookScript("OnClick", function() _G[chat.."EditBox"]:Hide() end)
			
	-- rename combag log to log
	if _G[chat] == _G["ChatFrame2"] then
		FCF_SetWindowName(_G[chat], "Log")
	end
			
	-- create our own texture for edit box
	local EditBoxBackground = CreateFrame("frame", "TukuiChatchatEditBoxBackground", _G[chat.."EditBox"])
	TukuiDB.CreatePanel(EditBoxBackground, 1, 1, "LEFT", _G[chat.."EditBox"], "LEFT", 0, 0)
	EditBoxBackground:ClearAllPoints()
	EditBoxBackground:SetAllPoints(TukuiInfoLeft)
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
				colorize(unpack(TukuiCF.media.bordercolor))
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
end

-- Setup chatframes 1 to 10 on login.
local function SetupChat(self)	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
		FCFTab_UpdateAlpha(frame)
	end
				
	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
end

local function SetupChatPosAndFont(self)	
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local name = FCF_GetChatWindowInfo(id)
		local point = GetChatWindowSavedPosition(id)
		local _, fontSize = FCF_GetChatWindowInfo(id)
		
		-- well... tukui font under fontsize 12 is unreadable.
		if fontSize < 12 then		
			FCF_SetChatWindowFontSize(nil, chat, 12)
		else
			FCF_SetChatWindowFontSize(nil, chat, fontSize)
		end
		
		-- force chat position on #1 and #4, needed if we change ui scale or resolution
		-- also set original width and height of chatframes 1 and 4 if first time we run tukui.
		-- doing resize of chat also here for users that hit "cancel" when default installation is show.
		if i == 1 then
			chat:ClearAllPoints()
			chat:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", TukuiDB.Scale(-1), TukuiDB.Scale(6))
			FCF_SavePositionAndDimensions(chat)
		elseif i == 4 and name == "Loot" then
			if not chat.isDocked then
				chat:ClearAllPoints()
				chat:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB.Scale(6))
				chat:SetJustifyH("RIGHT") 
				FCF_SavePositionAndDimensions(chat)
			end
		end
	end
			
	-- reposition battle.net popup over chat #1
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, TukuiDB.Scale(5))
	end)
end

TukuiChat:RegisterEvent("ADDON_LOADED")
TukuiChat:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiChat:SetScript("OnEvent", function(self, event, ...)
	local addon = ...
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			self:UnregisterEvent("ADDON_LOADED")
			SetupChat(self)
			--return CombatLogQuickButtonFrame_Custom:SetAlpha(.4)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetupChatPosAndFont(self)
	end
end)

-- Setup temp chat (BN, WHISPER) when needed.
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
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
			 ChatFrame_SendTell((unitname or tukuilocal.chat_invalidtarget), ChatFrame1)
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

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	frame:SetBackdrop({
			bgFile = TukuiCF["media"].blank, 
			edgeFile = TukuiCF["media"].blank, 
			tile = 0, tileSize = 0, edgeSize = TukuiDB.mult, 
			insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult }
	})
	frame:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	frame:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
	if TukuiDB.lowversion == true then
		frame:SetWidth(TukuiDB.Scale(410))
	else
		frame:SetWidth(TukuiDB.Scale(710))
	end
	frame:SetHeight(TukuiDB.Scale(200))
	frame:SetScale(1)
	frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(10))
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", TukuiDB.Scale(8), TukuiDB.Scale(-30))
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", TukuiDB.Scale(-30), TukuiDB.Scale(8))

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	if TukuiDB.lowversion == true then
		editBox:SetWidth(TukuiDB.Scale(410))
	else
		editBox:SetWidth(TukuiDB.Scale(710))
	end
	editBox:SetHeight(TukuiDB.Scale(200))
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

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

function TukuiDB.ChatCopyButtons()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[format("ChatFrame%d",  i)]
		local button = CreateFrame("Button", format("ButtonCF%d", i), cf)
		button:SetPoint("TOPRIGHT", 0, 0)
		button:SetHeight(TukuiDB.Scale(20))
		button:SetWidth(TukuiDB.Scale(20))
		button:SetAlpha(0)
		TukuiDB.SetTemplate(button)
		
		local buttontext = button:CreateFontString(nil,"OVERLAY",nil)
		buttontext:SetFont(TukuiCF.media.font,12,"OUTLINE")
		buttontext:SetText("C")
		buttontext:SetPoint("CENTER", TukuiDB.Scale(1), 0)
		buttontext:SetJustifyH("CENTER")
		buttontext:SetJustifyV("CENTER")
				
		button:SetScript("OnMouseUp", function(self)
			Copy(cf)
		end)
		button:SetScript("OnEnter", function() 
			button:SetAlpha(1) 
		end)
		button:SetScript("OnLeave", function() button:SetAlpha(0) end)
	end
end
TukuiDB.ChatCopyButtons()


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

if TukuiCF.chat.whispersound then
	local SoundSys = CreateFrame("Frame")
	SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
	SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
	SoundSys:HookScript("OnEvent", function(self, event, ...)
		if event == "CHAT_MSG_WHISPER" or "CHAT_MSG_BN_WHISPER" then
			PlaySoundFile(TukuiCF["media"].whisper)
		end
	end)
end