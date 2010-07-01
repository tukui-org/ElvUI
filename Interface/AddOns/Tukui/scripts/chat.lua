if TukuiDB["chat"].enable ~= true then return end

local AddOn = CreateFrame("Frame")
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
AddOn:SetScript("OnEvent", OnEvent)

local _G = _G
local replace = string.gsub
local find = string.find

-- hide Blizzard Chat option that we don't need
InterfaceOptionsSocialPanelChatStyle:Hide()
InterfaceOptionsSocialPanelConversationMode:Hide()

-- disable some chat functions
FCF_MinimizeFrame = TukuiDB.dummy
FCF_RestorePositionAndDimensions = TukuiDB.dummy

local replaceschan = {
	['Гильдия'] = '[Г]',
	['Группа'] = '[Гр]',
	['Рейд'] = '[Р]',
	['Лидер рейда'] = '[ЛР]',
	['Объявление рейду'] = '[ОР]',
	['Офицер'] = '[О]',
	['Поле боя'] = '[ПБ]',
	['Лидер поля боя'] = '[ЛПБ]', 
	['Guilde'] = '[G]',
	['Groupe'] = '[GR]',
	['Chef de raid'] = '[RL]',
	['Avertissement Raid'] = '[AR]',
	['Officier'] = '[O]',
	['Champs de bataille'] = '[CB]',
	['Chef de bataille'] = '[CDB]',
	['Guild'] = '[G]',
	['Party'] = '[P]',
	['Party Leader'] = '[PL]',
	['Dungeon Guide'] = '[DG]',
	['Raid'] = '[R]',
	['Raid Leader'] = '[RL]',
	['Raid Warning'] = '[RW]',
	['Officer'] = '[O]',
	['Battleground'] = '[B]',
	['Battleground Leader'] = '[BL]',
	['Gilde'] = '[G]',
	['Gruppe'] = '[Grp]',
	['Gruppenanführer'] = '[GrpL]',
	['Dungeonführer'] = '[DF]',
	['Schlachtzug'] = '[R]',
	['Schlachtzugsleiter'] = '[RL]',
	['Schlachtzugswarnung'] = '[RW]',
	['Offizier'] = '[O]',
	['Schlachtfeld'] = '[BG]',
	['Schlachtfeldleiter'] = '[BGL]',
	['Hermandad'] = '[H]',
	['Grupo'] = '[G]',
	['Líder del grupo'] = '[LG]',
	['Guía de mazmorra'] = '[GM]',
	['Banda'] = '[B]',
	['Líder de banda'] = '[LB]',
	['Aviso de banda'] = '[AB]',
	['Oficial'] = '[O]',
	['CampoDeBatalla'] = '[CB]',
	['Líder de batalla'] = '[LdB]',
	['(%d+)%. .-'] = '[%1]',
}

-- WoW or battle.net player status
CHAT_FLAG_AFK = "[|cffff0000AFK|r] "
CHAT_FLAG_DND = "[|cffff0000DND|r] "
CHAT_FLAG_GM = "[|cffff0000GM|r] "

-- hide editbox colored round border
for i = 1, 10 do
	local x=({_G["ChatFrame"..i.."EditBox"]:GetRegions()})
	x[9]:SetAlpha(0)
	x[10]:SetAlpha(0)
	x[11]:SetAlpha(0)
end

-- Hide friends micro button (added in 3.3.5)
FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
FriendsMicroButton:Hide()

GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
GeneralDockManagerOverflowButton:Hide()

-- Player entering the world
function TukuiDB.SetupChat()
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton:SetScript("OnShow", function(self) self:Hide() end)
				
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i]:SetClampRectInsets(0,0,0,0)
			
		-- Hide chat buttons
		_G["ChatFrame"..i.."ButtonFrameUpButton"]:Hide()
		_G["ChatFrame"..i.."ButtonFrameDownButton"]:Hide()
		_G["ChatFrame"..i.."ButtonFrameBottomButton"]:Hide()
		_G["ChatFrame"..i.."ButtonFrameMinimizeButton"]:Hide()
		_G["ChatFrame"..i.."ResizeButton"]:Hide()
		_G["ChatFrame"..i.."ButtonFrame"]:Hide()

		_G["ChatFrame"..i.."ButtonFrameUpButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."ButtonFrameDownButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."ButtonFrameBottomButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."ButtonFrameMinimizeButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."ResizeButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."ButtonFrame"]:SetScript("OnShow", function(self) self:Hide() end)
		
		-- Hide chat textures backdrop
		for j = 1, #CHAT_FRAME_TEXTURES do
			_G["ChatFrame"..i..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
		end

		-- Stop the chat frame from fading out
		_G["ChatFrame"..i]:SetFading(false)
		
		-- Change the chat frame font 
		_G["ChatFrame"..i]:SetFont(TukuiDB["chat"].font, TukuiDB["chat"].fontsize)
		
		_G["ChatFrame"..i]:SetFrameStrata("LOW")
		_G["ChatFrame"..i]:SetMovable(true)
		_G["ChatFrame"..i]:SetUserPlaced(true)
		
		-- Texture and align the chat edit box
		local editbox = _G["ChatFrame"..i.."EditBox"]
		local left, mid, right = select(6, editbox:GetRegions())
		left:Hide(); mid:Hide(); right:Hide()
		editbox:ClearAllPoints();
		editbox:SetPoint("TOPLEFT", TukuiInfoLeft, TukuiDB:Scale(2), TukuiDB:Scale(-2))
		editbox:SetPoint("BOTTOMRIGHT", TukuiInfoLeft, TukuiDB:Scale(-2), TukuiDB:Scale(2))
		
		-- Disable alt key usage
		editbox:SetAltArrowKeyMode(false)		
	end
	
	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
				
	-- Position the general chat frame
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", TukuiDB:Scale(-1), TukuiDB:Scale(6))
	ChatFrame1:SetWidth(TukuiDB:Scale(TukuiDB["panels"].tinfowidth + 1))
	ChatFrame1:SetHeight(TukuiDB:Scale(111))
		
	-- Position the chatframe 4
	ChatFrame4:ClearAllPoints()
	ChatFrame4:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB:Scale(6))
	ChatFrame4:SetWidth(TukuiDB:Scale(TukuiDB["panels"].tinfowidth + 1))
	ChatFrame4:SetHeight(TukuiDB:Scale(111))
	
	-- Align the text to the right on cf4
	ChatFrame4:SetJustifyH("RIGHT")
end
AddOn:RegisterEvent("PLAYER_ENTERING_WORLD")
AddOn["PLAYER_ENTERING_WORLD"] = TukuiDB.SetupChat

-- Get colors for player classes
local function ClassColors(class)
	if not class then return end
	class = (replace(class, " ", "")):upper()
	local c = RAID_CLASS_COLORS[class]
	if c then
		return string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
	end
end

-- For Player Logins
function CHAT_MSG_SYSTEM(...)
	local login = select(3, find(arg1, "^|Hplayer:(.+)|h%[(.+)%]|h has come online."))
	local classColor = "999999"
	local foundColor = true
			
	if login then
		local found = false
		if GetNumFriends() > 0 then ShowFriends() end
		
		for friendIndex = 1, GetNumFriends() do
			local friendName, _, class = GetFriendInfo(friendIndex)
			if friendName == login then
				classColor = ClassColors(class)
				found = true
				break
			end
		end
		
		if not found then
			if IsInGuild() then GuildRoster() end
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(guildIndex)
				if guildMemberName == login then
					classColor = ClassColors(class)
					break
				end
			end
		end
		
	end
	
	if login then
		-- Hook the message function
		local AddMessageOriginal = ChatFrame1.AddMessage
		local function AddMessageHook(frame, text, ...)
			text = replace(text, "^|Hplayer:(.+)|h%[(.+)%]|h", "|Hplayer:%1|h|cff"..classColor.."%2|r|h")
			ChatFrame1.AddMessage = AddMessageOriginal
			return AddMessageOriginal(frame, text, ...)
		end
		ChatFrame1.AddMessage = AddMessageHook
	end
end
AddOn:RegisterEvent("CHAT_MSG_SYSTEM")
AddOn["CHAT_MSG_SYSTEM"] = CHAT_MSG_SYSTEM

local function AddMessageHook(frame, text, ...)
	-- chan text smaller or hidden
	for k,v in pairs(replaceschan) do
		text = text:gsub('|h%['..k..'%]|h', '|h'..v..'|h')
	end
	text = replace(text, "has come online.", "is now |cff298F00online|r !")
	text = replace(text, "|Hplayer:(.+)|h%[(.+)%]|h has earned", "|Hplayer:%1|h%2|h has earned")
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h whispers:", "From [|Hplayer:%1:%2|h%3|h]:")
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h says:", "[|Hplayer:%1:%2|h%3|h]:")	
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h yells:", "[|Hplayer:%1:%2|h%3|h]:")
	return AddMessageOriginal(frame, text, ...)
end

function TukuiDB.ChannelsEdits()
	for i = 1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
			AddMessageOriginal = frame.AddMessage
			frame.AddMessage = AddMessageHook
		end
	end
end
TukuiDB.ChannelsEdits()


-- /tt - tell your current target.
for i = 1, 10 do
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
-- copy url
-----------------------------------------------------------------------------

local color = "BD0101"
local pattern = "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]"

function string.color(text, color)
	return "|cff"..color..text.."|r"
end

function string.link(text, type, value, color)
	return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
end

StaticPopupDialogs["LINKME"] = {
	text = "URL COPY",
	button2 = CANCEL,
	hasEditBox = true,
    hasWideEditBox = true,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	whileDead = 1,
	maxLetters = 255,
}

local function f(url)
	return string.link("["..url.."]", "url", url, color)
end

local function hook(self, text, ...)
	self:f(text:gsub(pattern, f), ...)
end

function TukuiDB.LinkMeURL()
	for i = 1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
			frame.f = frame.AddMessage
			frame.AddMessage = hook
		end
	end
end
TukuiDB.LinkMeURL()

local f = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(self, link, text, button)
	local type, value = link:match("(%a+):(.+)")
	if ( type == "url" ) then
		local dialog = StaticPopup_Show("LINKME")
		local editbox = _G[dialog:GetName().."WideEditBox"]  
		editbox:SetText(value)
		editbox:SetFocus()
		editbox:HighlightText()
		local button = _G[dialog:GetName().."Button2"]
            
		button:ClearAllPoints()
           
		button:SetPoint("CENTER", editbox, "CENTER", 0, TukuiDB:Scale(-30))
	else
		f(self, link, text, button)
	end
end

------------------------------------------------------------------------
--	No more click on item chat link
------------------------------------------------------------------------

local orig1, orig2 = {}, {}
local GameTooltip = GameTooltip

local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local function OnHyperlinkEnter(frame, link, ...)
	local linktype = link:match("^([^:]+)")
	if linktype and linktypes[linktype] then
		GameTooltip:SetOwner(frame, "ANCHOR_TOP", 0, 6)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end

	if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function OnHyperlinkLeave(frame, ...)
	GameTooltip:Hide()
	if orig2[frame] then return orig2[frame](frame, ...) end
end

function TukuiDB.HyperlinkMouseover()
	local _G = getfenv(0)
	for i=1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
			orig1[frame] = frame:GetScript("OnHyperlinkEnter")
			frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

			orig2[frame] = frame:GetScript("OnHyperlinkLeave")
			frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
		end
	end
end
TukuiDB.HyperlinkMouseover()
-----------------------------------------------------------------------------
-- Copy Chat (credit: shestak for this version)
-----------------------------------------------------------------------------

local lines = {}
local frame = nil
local editBox = nil
local isf = nil

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	frame:SetBackdrop({
			bgFile = TukuiDB["media"].blank, 
			edgeFile = TukuiDB["media"].blank, 
			tile = 0, tileSize = 0, edgeSize = TukuiDB.mult, 
			insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult }
	})
	frame:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	frame:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
	if TukuiDB.lowversion == true then
		frame:SetWidth(TukuiDB:Scale(410))
	else
		frame:SetWidth(TukuiDB:Scale(710))
	end
	frame:SetHeight(TukuiDB:Scale(200))
	frame:SetScale(1)
	frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB:Scale(10))
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", TukuiDB:Scale(8), TukuiDB:Scale(-30))
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", TukuiDB:Scale(-30), TukuiDB:Scale(8))

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	if TukuiDB.lowversion == true then
		editBox:SetWidth(TukuiDB:Scale(410))
	else
		editBox:SetWidth(TukuiDB:Scale(710))
	end
	editBox:SetHeight(TukuiDB:Scale(200))
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
	frame:Show()
	editBox:SetText(text)
	editBox:HighlightText(0)
end

function TukuiDB.ChatCopyButtons()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[format("ChatFrame%d",  i)]
		local button = CreateFrame("Button", format("ButtonCF%d", i), cf)
		button:SetPoint("BOTTOMRIGHT", 0, 0)
		button:SetHeight(TukuiDB:Scale(20))
		button:SetWidth(TukuiDB:Scale(20))
		button:SetAlpha(0)
		TukuiDB:SetTemplate(button)
		button:SetScript("OnClick", function() Copy(cf) end)
		button:SetScript("OnEnter", function() 
			button:SetAlpha(1) 
		end)
		button:SetScript("OnLeave", function() button:SetAlpha(0) end)
		local tab = _G[format("ChatFrame%dTab", i)]
		tab:SetScript("OnShow", function() button:Show() end)
		tab:SetScript("OnHide", function() button:Hide() end)
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

local SoundSys = CreateFrame("Frame")
SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
SoundSys:HookScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_WHISPER" or "CHAT_MSG_BN_WHISPER" then
		PlaySoundFile(TukuiDB["media"].whisper)
	end
end)