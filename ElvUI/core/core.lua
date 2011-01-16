--And so it begins..
local ElvDB = ElvDB
local ElvCF = ElvCF

--Vars
ElvDB.dummy = function() return end
ElvDB.myname, _ = UnitName("player")
ElvDB.myrealm = GetRealmName()
_, ElvDB.myclass = UnitClass("player")
ElvDB.version = GetAddOnMetadata("ElvUI", "Version")
ElvDB.patch = GetBuildInfo()
ElvDB.level = UnitLevel("player")
ElvDB.IsElvsEdit = true

--Keybind Header
BINDING_HEADER_ELVUI = GetAddOnMetadata("ElvUI", "Title") --Header name inside keybinds menu

--Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local tree = GetPrimaryTalentTree()
	local resilience
	if GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)*0.02828 > GetDodgeChance() then
		resilience = true
	else
		resilience = false
	end
	if ((ElvDB.myclass == "PALADIN" and tree == 2) or 
	(ElvDB.myclass == "WARRIOR" and tree == 3) or 
	(ElvDB.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(ElvDB.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		ElvDB.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (ElvDB.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or ElvDB.myclass == "ROGUE" or ElvDB.myclass == "HUNTER" or (ElvDB.myclass == "SHAMAN" and tree == 2) then
			ElvDB.Role = "Melee"
		else
			ElvDB.Role = "Caster"
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
function ElvDB.Install()
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
	if (ElvCF.chat.enable == true) and (not IsAddOnLoaded("Prat") or not IsAddOnLoaded("Chatter")) then					
		FCF_ResetChatWindows()
		FCF_SetLocked(ChatFrame1, 1)
		FCF_DockFrame(ChatFrame2)
		FCF_SetLocked(ChatFrame2, 1)
		
		if ElvCF["chat"].rightchat == true then
			FCF_OpenNewWindow(LOOT)
			FCF_UnDockFrame(ChatFrame3)
			FCF_SetLocked(ChatFrame3, 1)
			ChatFrame3:Show()			
		end
				
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)
			
			_G["ChatFrame"..i]:SetSize(ElvDB.Scale(ElvCF["chat"].chatwidth - 5), ElvDB.Scale(ElvCF["chat"].chatheight))
			
			-- this is the default width and height of Elvui chats.
			SetChatWindowSavedDimensions(chatFrameId, ElvDB.Scale(ElvCF["chat"].chatwidth + -4), ElvDB.Scale(ElvCF["chat"].chatheight))
			
			-- move general bottom left
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", ChatLBackground, "BOTTOMLEFT", ElvDB.Scale(2), 0)
			elseif i == 3 and ElvCF["chat"].rightchat == true then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", ChatRBackground, "BOTTOMLEFT", ElvDB.Scale(2), 0)			
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
			elseif i == 3 and ElvCF["chat"].rightchat == true then 
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
		
		if ElvCF["chat"].rightchat == true then
			ChatFrame_RemoveAllMessageGroups(ChatFrame3)	
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
			ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
			ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
			ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
			ChatFrame_AddChannel(ChatFrame1, GENERAL)
			ChatFrame_RemoveChannel(ChatFrame1, TRADE)
			ChatFrame_AddChannel(ChatFrame3, TRADE)
		else
			ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")
			ChatFrame_AddMessageGroup(ChatFrame1, "MONEY")	
			ChatFrame_AddMessageGroup(ChatFrame1, "SKILL")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_GUILD_XP_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_HONOR_GAIN")
			ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
			ChatFrame_AddChannel(ChatFrame1, GENERAL)
			ChatFrame_RemoveChannel(ChatFrame3, TRADE)
			ChatFrame_AddChannel(ChatFrame1, TRADE)
		end
		
		if ElvDB.myname == "Elv" then
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
	if ElvCF["unitframes"].positionbychar == true then
		ElvuiUFpos = {}
	else
		ElvuiData.ufpos = {}
	end
	
	ReloadUI()
end

local function DisableElvui()
	DisableAddOn("ElvUI"); 
	ReloadUI()
end

local ElvuiOnLogon = CreateFrame("Frame")
ElvuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if ElvDB.getscreenresolution == "800x600"
		or ElvDB.getscreenresolution == "1024x768"
		or ElvDB.getscreenresolution == "720x576"
		or ElvDB.getscreenresolution == "1024x600" -- eeepc reso
		or ElvDB.getscreenresolution == "1152x864" then
			SetCVar("useUiScale", 0)
			StaticPopup_Show("DISABLE_UI")
	else
		SetCVar("useUiScale", 1)
		if ElvCF["general"].multisampleprotect == true then
			SetMultisampleFormat(1)
		end
		SetCVar("uiScale", ElvCF["general"].uiscale)
		if (ElvuiData == nil) then ElvuiData = {} end

		if ElvUIInstalled ~= true then
			StaticPopup_Show("INSTALL_UI")
		end
	end
	
	if (IsAddOnLoaded("ElvUI_Dps_Layout") and IsAddOnLoaded("ElvUI_Heal_Layout")) then
		StaticPopup_Show("DISABLE_RAID")
	end
		
	if ElvCF["arena"].unitframes == true then
		SetCVar("showArenaEnemyFrames", 0)
	end
	
	ElvDB.ChatLIn = true
	ElvDB.ChatRIn = true
	

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
		
		if point == "BOTTOMRIGHT" and ElvCF["chat"].rightchat == true and chat:IsShown() and docked == nil then
			chatrightfound = true
			tab:SetParent(ChatRBackground)
		end
		
		if ElvCF["chat"].rightchat ~= true then chatrightfound = true end
		
		if i == NUM_CHAT_WINDOWS and chatrightfound == false and not StaticPopup1:IsShown() then
			StaticPopup_Show("CHAT_WARN")
		end

	end
	GeneralDockManager:SetParent(ChatLBackground)
	
	--Fixing fucked up border on right chat button, really do not understand why this is happening
	if ElvCF["chat"].rightchat == true and ElvCF["chat"].showbackdrop == true then
		if not ButtonCF3 then return end
		local x = CreateFrame("Frame", nil, ChatFrame3Tab)
		x:SetAllPoints(ButtonCF3)
		ElvDB.SetTemplate(x)
		x:SetBackdropColor(0,0,0,0)
	end
	
	print(elvuilocal.core_welcome2)
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
local function UIHelp()
	print(" ")
	print(elvuilocal.core_uihelp1)
	print(elvuilocal.core_uihelp2)
	print(elvuilocal.core_uihelp3)
	print(elvuilocal.core_uihelp4)
	print(elvuilocal.core_uihelp5)
	print(elvuilocal.core_uihelp6)
	print(elvuilocal.core_uihelp7)
	print(elvuilocal.core_uihelp8)
	print(elvuilocal.core_uihelp9)
	print(elvuilocal.core_uihelp10)
	print(elvuilocal.core_uihelp11)
	print(elvuilocal.core_uihelp12)
	print(elvuilocal.core_uihelp13)
	print(elvuilocal.core_uihelp15)
	print(elvuilocal.core_uihelp16)
	print(elvuilocal.core_uihelp17)
	print(elvuilocal.core_uihelp18)
	print(elvuilocal.core_uihelp19)
	print(elvuilocal.core_uihelp20)
	print(" ")
	print(elvuilocal.core_uihelp14)
end

SLASH_UIHELP1 = "/UIHelp"
SlashCmdList["UIHELP"] = UIHelp

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("INSTALL_UI") end

-- convert datatext ElvDB.ValColor from rgb decimal to hex DO NOT TOUCH
local r, g, b = unpack(ElvCF["media"].valuecolor)
ElvDB.ValColor = ("|cff%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)