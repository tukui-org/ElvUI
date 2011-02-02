--And so it begins..
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--Constants
E.dummy = function() return end
E.myname, _ = UnitName("player")
E.myrealm = GetRealmName()
_, E.myclass = UnitClass("player")
E.version = GetAddOnMetadata("ElvUI", "Version")
E.patch = GetBuildInfo()
E.level = UnitLevel("player")
E.IsElvsEdit = true

--Keybind Header
BINDING_HEADER_ELVUI = GetAddOnMetadata("ElvUI", "Title") --Header name inside keybinds menu

--Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local tree = GetPrimaryTalentTree()
	local resilience
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() then
		resilience = true
	else
		resilience = false
	end
	if ((E.myclass == "PALADIN" and tree == 2) or 
	(E.myclass == "WARRIOR" and tree == 3) or 
	(E.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(E.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		E.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (E.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or E.myclass == "ROGUE" or E.myclass == "HUNTER" or (E.myclass == "SHAMAN" and tree == 2) then
			E.Role = "Melee"
		else
			E.Role = "Caster"
		end
	end
end	
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

--Install UI
function E.Install()
	SetCVar("buffDurations", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("scriptErrors", 0)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 3.4)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "classic")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("ConversationMode", "inline")
	SetCVar("showTutorials", 0)
	SetCVar("showNewbieTips", 0)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("showLootSpam", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("gxTextureCacheSize", 512)
	
	-- Var ok, now setting chat frames if using Elvui chats.	
	if (C.chat.enable == true) and (not IsAddOnLoaded("Prat") or not IsAddOnLoaded("Chatter")) then					
		FCF_ResetChatWindows()
		FCF_SetLocked(ChatFrame1, 1)
		FCF_DockFrame(ChatFrame2)
		FCF_SetLocked(ChatFrame2, 1)
		
		if C["chat"].rightchat == true then
			FCF_OpenNewWindow(LOOT)
			FCF_UnDockFrame(ChatFrame3)
			FCF_SetLocked(ChatFrame3, 1)
			ChatFrame3:Show()			
		end
				
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)
			
			_G["ChatFrame"..i]:SetSize(E.Scale(C["chat"].chatwidth - 5), E.Scale(C["chat"].chatheight))
			
			-- this is the default width and height of Elvui chats.
			SetChatWindowSavedDimensions(chatFrameId, E.Scale(C["chat"].chatwidth + -4), E.Scale(C["chat"].chatheight))
			
			-- move general bottom left
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", ChatLBackground, "BOTTOMLEFT", E.Scale(2), 0)
			elseif i == 3 and C["chat"].rightchat == true then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", ChatRBackground, "BOTTOMLEFT", E.Scale(2), 0)			
			end
					
			-- save new default position and dimension
			FCF_SavePositionAndDimensions(frame)
			
			-- set default Elvui font size
			FCF_SetChatWindowFontSize(nil, frame, 12)
			
			-- rename windows general because moved to chat #3
			if i == 1 then
				FCF_SetWindowName(frame, GENERAL)
			elseif i == 2 then
				FCF_SetWindowName(frame, GUILD_EVENT_LOG)
			elseif i == 3 and C["chat"].rightchat == true then 
				FCF_SetWindowName(frame, LOOT.." / "..TRADE) 
			end
		end
		
		ChatFrame_RemoveAllMessageGroups(ChatFrame1)
		ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
		ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
		ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
		ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
		ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
		ChatFrame_AddMessageGroup(ChatFrame1, "DND")
		ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
		ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")
		
		if C["chat"].rightchat == true then
			ChatFrame_RemoveAllMessageGroups(ChatFrame3)	
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
			ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
			ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
			ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
			ChatFrame_AddChannel(ChatFrame1, GENERAL)
			ChatFrame_RemoveChannel(ChatFrame1, L.chat_trade)
			ChatFrame_AddChannel(ChatFrame3, L.chat_trade)
		else
			ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")
			ChatFrame_AddMessageGroup(ChatFrame1, "MONEY")	
			ChatFrame_AddMessageGroup(ChatFrame1, "SKILL")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_GUILD_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_HONOR_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
			ChatFrame_AddChannel(ChatFrame1, GENERAL)
			ChatFrame_RemoveChannel(ChatFrame3, L.chat_trade)
			ChatFrame_AddChannel(ChatFrame1, L.chat_trade)
		end
		
		if E.myname == "Elv" then
			--keep losing my god damn channels everytime i resetui
			ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "tystank")
			ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "tys")
			ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "crusaderaura")
			ChangeChatColor("CHANNEL5", 147/255, 112/255, 219/255)
			ChangeChatColor("CHANNEL6", 139/255, 115/255, 85/255)
			ChangeChatColor("CHANNEL7", RAID_CLASS_COLORS["PALADIN"].r, RAID_CLASS_COLORS["PALADIN"].g, RAID_CLASS_COLORS["PALADIN"].b)
			SetCVar("scriptErrors", 1)
		end	
		
		-- enable classcolor automatically on login and on each character without doing /configure each time.
		ToggleChatColorNamesByClassGroup(true, "SAY")
		ToggleChatColorNamesByClassGroup(true, "EMOTE")
		ToggleChatColorNamesByClassGroup(true, "YELL")
		ToggleChatColorNamesByClassGroup(true, "GUILD")
		ToggleChatColorNamesByClassGroup(true, "OFFICER")
		ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "WHISPER")
		ToggleChatColorNamesByClassGroup(true, "PARTY")
		ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID")
		ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")	
		ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL11")
		
		--Adjust Chat Colors
			--General
			ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
			--Trade
			ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
			--Local Defense
			ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)
	end
		   
	ElvUIInstalled = true

	-- reset unitframe position
	if C["unitframes"].positionbychar == true then
		ElvuiUFpos = {}
	else
		ElvuiData.ufpos = {}
	end
	
	StaticPopup_Show("RELOAD_UI")
end

local function DisableElvui()
	DisableAddOn("ElvUI"); 
	ReloadUI()
end

local ElvuiOnLogon = CreateFrame("Frame")
ElvuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if E.getscreenresolution == "800x600"
		or E.getscreenresolution == "1024x768"
		or E.getscreenresolution == "720x576"
		or E.getscreenresolution == "1024x600" -- eeepc reso
		or E.getscreenresolution == "1152x864" then
			SetCVar("useUiScale", 0)
			StaticPopup_Show("DISABLE_UI")
	else
		SetCVar("useUiScale", 1)
		if C["general"].multisampleprotect == true then
			SetMultisampleFormat(1)
		end
		SetCVar("uiScale", C["general"].uiscale)
		if (ElvuiData == nil) then ElvuiData = {} end

		if ElvUIInstalled ~= true then
			StaticPopup_Show("INSTALL_UI")
		end
	end
	
	if (IsAddOnLoaded("ElvUI_Dps_Layout") and IsAddOnLoaded("ElvUI_Heal_Layout")) then
		StaticPopup_Show("DISABLE_RAID")
	end
		
	if C["arena"].unitframes == true then
		SetCVar("showArenaEnemyFrames", 0)
	end
	
	E.ChatLIn = true
	E.ChatRIn = true
	

	local chatrightfound = false
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local name = FCF_GetChatWindowInfo(id)
		local point = GetChatWindowSavedPosition(id)
		local _, fontSize = FCF_GetChatWindowInfo(id)
		local button = _G[format("ButtonCF%d", i)]
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		
		if point == "BOTTOMRIGHT" and C["chat"].rightchat == true and chat:IsShown() and docked == nil then
			chatrightfound = true
			tab:SetParent(ChatRBackground)
		end
		
		if C["chat"].rightchat ~= true then chatrightfound = true end
		
		if i == NUM_CHAT_WINDOWS and chatrightfound == false and not StaticPopup1:IsShown() then
			StaticPopup_Show("CHAT_WARN")
		end

	end
	GeneralDockManager:SetParent(ChatLBackground)
	
	--Fixing fucked up border on right chat button, really do not understand why this is happening
	if C["chat"].rightchat == true and C["chat"].showbackdrop == true then
		if not ButtonCF3 then return end
		local x = CreateFrame("Frame", nil, ChatFrame3Tab)
		x:SetAllPoints(ButtonCF3)
		x:SetTemplate("Default")
		x:SetBackdropColor(0,0,0,0)
	end
	
	print(L.core_welcome2)
end)

local eventcount = 0
local ElvuiInGame = CreateFrame("Frame")
ElvuiInGame:RegisterAllEvents()
ElvuiInGame:SetScript("OnEvent", function(self, event)
	eventcount = eventcount + 1
	if InCombatLockdown() then return end

	if eventcount > 6000 then
		collectgarbage("collect")
		eventcount = 0
	end
end)

------------------------------------------------------------------------
--	UI HELP
------------------------------------------------------------------------

-- Print Help Messages
function E.UIHelp()
	print(" ")
	print(L.core_uihelp1)
	print(L.core_uihelp2)
	print(L.core_uihelp3)
	print(L.core_uihelp4)
	print(L.core_uihelp5)
	print(L.core_uihelp6)
	print(L.core_uihelp7)
	print(L.core_uihelp9)
	print(L.core_uihelp10)
	print(L.core_uihelp11)
	print(L.core_uihelp12)
	print(L.core_uihelp15)
	print(L.core_uihelp16)
	print(L.core_uihelp17)
	print(L.core_uihelp18)
	print(L.core_uihelp19)
	print(L.core_uihelp21)
	print(L.core_uihelp22)
	print(" ")
	print(L.core_uihelp14)
end

-- convert datatext E.ValColor from rgb decimal to hex DO NOT TOUCH
local r, g, b = unpack(C["media"].valuecolor)
E.ValColor = ("|cff%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)