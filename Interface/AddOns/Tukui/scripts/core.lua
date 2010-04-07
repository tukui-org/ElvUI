
local index = GetCurrentResolution();
local resolution = select(index, GetScreenResolutions());
local tukuiversion = GetAddOnMetadata("Tukui", "Version")

function GetTukuiVersion()
	-- the tukui high reso whitelist
	if not (resolution == "1680x945"
		or resolution == "2560x1440" 
		or resolution == "1680x1050" 
		or resolution == "1920x1080" 
		or resolution == "1920x1200" 
		or resolution == "1600x900" 
		or resolution == "2048x1152" 
		or resolution == "1776x1000" 
		or resolution == "2560x1600" 
		or resolution == "1600x1200") then
			if TukuiDB["general"].overridelowtohigh == true then
				TukuiDB["general"].autoscale = false
				TukuiDB.lowversion = false
			else
				TukuiDB.lowversion = true
			end			
	end

	if TukuiDB["general"].autoscale == true then
		-- i'm putting a autoscale feature mainly for an easy auto install process
		-- we all know that it's not very effective to play via 1024x768 on an 0.64 uiscale :P
		-- with this feature on, it should auto choose a very good value for your current reso!
		TukuiDB["general"].uiscale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
	end

	if TukuiDB.lowversion then
		TukuiDB.raidscale = 0.8
	else
		TukuiDB.raidscale = 1
	end
end
GetTukuiVersion()

local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/TukuiDB["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function TukuiDB:Scale(x) return scale(x) end
TukuiDB.mult = mult

function TukuiDB:CreatePanel(f, w, h, a1, p, a2, x, y)
	sh = scale(h)
	sw = scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)
	f:SetBackdrop({
	  bgFile = TukuiDB["media"].blank, 
	  edgeFile = TukuiDB["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	f:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
end

function TukuiDB:SetTemplate(f)
	f:SetBackdrop({
	  bgFile = TukuiDB["media"].blank, 
	  edgeFile = TukuiDB["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	f:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
end

local function install()			
	SetCVar("buffDurations", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("secureAbilityToggle", 0)
	SetCVar("showItemLevel", 1)
	SetCVar("equipmentManager", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("previewTalents", 1)
	SetCVar("scriptErrors", 0)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 8)
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 3.4)
	SetCVar("chatLocked", 0)
	SetCVar("showClock", 0)
			
	-- Var ok, now setting chat frames.					
	FCF_ResetChatWindows()
	FCF_DockFrame(ChatFrame2)
	FCF_OpenNewWindow("Spam")

	FCF_OpenNewWindow("Loot")
	FCF_UnDockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, 0);
	ChatFrame4:Show();
			
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveChannel(ChatFrame1, "Trade")
	ChatFrame_RemoveChannel(ChatFrame1, "General")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
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
				
	-- Setup the spam chat frame
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddChannel(ChatFrame3, "Trade")
	ChatFrame_AddChannel(ChatFrame3, "General")
	ChatFrame_AddChannel(ChatFrame3, "LookingForGroup")
			
	-- Setup the right chat
	ChatFrame_RemoveAllMessageGroups(ChatFrame4);
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
			
	-- enable classcolor automatically on login and on each character without doing /configure each time.
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "GUILD_OFFICER")
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
		   
	t10installed = true
			
	ReloadUI()
end

local function DisableTukui()
		DisableAddOn("Tukui"); 
		ReloadUI()
end

------------------------------------------------------------------------
--	Popups
------------------------------------------------------------------------

StaticPopupDialogs["DISABLE_UI"] = {
	text = tukuilocal.popup_disableui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableTukui,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["INSTALL_UI"] = {
	text = tukuilocal.popup_install,
    button1 = "OK",
    OnAccept = install,
    timeout = 0,
    whileDead = 1,
}

StaticPopupDialogs["DISABLE_RAID"] = {
	text = tukuilocal.popup_2raidactive,
	button1 = "DPS - TANK",
	button2 = "HEAL",
	OnAccept = function() DisableAddOn("Tukui_Heal_Layout") EnableAddOn("Tukui_Dps_Layout") ReloadUI() end,
	OnCancel = function() EnableAddOn("Tukui_Heal_Layout") DisableAddOn("Tukui_Dps_Layout") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

------------------------------------------------------------------------
--	On login function, look for some infos!
------------------------------------------------------------------------

local TukuiOnLogon = CreateFrame("Frame")
TukuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiOnLogon:SetScript("OnEvent", function()
        TukuiOnLogon:UnregisterEvent("PLAYER_ENTERING_WORLD")
        TukuiOnLogon:SetScript("OnEvent", nil)
		
		--need a.b. to always be enabled
		if TukuiDB["actionbar"].enable == true then
			SetActionBarToggles( 1, 1, 1, 1, 0 )
		end
	
		if resolution == "800x600"
			or resolution == "1024x768"
			or resolution == "720x576"
			or resolution == "1024x600" -- eeepc reso
			or resolution == "1152x864" then
				SetCVar("useUiScale", 0)
				StaticPopup_Show("DISABLE_UI")
		else
			SetCVar("useUiScale", 1)
			if TukuiDB["general"].multisampleprotect == true then
				SetMultisampleFormat(1)
			end
			SetCVar("uiScale", TukuiDB["general"].uiscale)
			if not (t10installed) then
				-- ugly shit
				SetCVar("alwaysShowActionBars", 0)
				StaticPopup_Show("INSTALL_UI")
			end
		end
		
		if (IsAddOnLoaded("Tukui_Dps_Layout") and IsAddOnLoaded("Tukui_Heal_Layout")) then
			StaticPopup_Show("DISABLE_RAID")
		end
		
		SetCVar("showArenaEnemyFrames", 0)
		
		print(tukuilocal.core_welcome1..tukuiversion)
		print(tukuilocal.core_welcome2)
end)

------------------------------------------------------------------------
--	UI HELP
------------------------------------------------------------------------

-- Print Help Messages
local function UIHelp()
	print(" ")
	print(tukuilocal.core_uihelp1)
	print(tukuilocal.core_uihelp2)
	print(tukuilocal.core_uihelp3)
	print(tukuilocal.core_uihelp4)
	print(tukuilocal.core_uihelp5)
	print(tukuilocal.core_uihelp6)
	print(tukuilocal.core_uihelp7)
	print(tukuilocal.core_uihelp8)
	print(tukuilocal.core_uihelp9)
	print(tukuilocal.core_uihelp10)
	print(tukuilocal.core_uihelp11)
	print(tukuilocal.core_uihelp12)
	print(tukuilocal.core_uihelp13)
	print(tukuilocal.core_uihelp15)
	print(" ")
	print(tukuilocal.core_uihelp14)
end

SLASH_UIHELP1 = "/UIHelp"
SlashCmdList["UIHELP"] = UIHelp

------------------------------------------------------------------------
-- move some frames
------------------------------------------------------------------------
if TukuiDB["watchframe"].movable == true then
	local wf = WatchFrame
	local wfmove = false 

	wf:SetMovable(true)
	wf:SetClampedToScreen(false) 
	wf:ClearAllPoints()
	wf:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB:Scale(17), TukuiDB:Scale(-80))
	wf:SetWidth(TukuiDB:Scale(250))
	wf:SetHeight(TukuiDB:Scale(600))
	wf:SetUserPlaced(true)
	wf.SetPoint = function() end
	wf.ClearAllPoints = function() end

	local function WATCHFRAMELOCK()
		if wfmove == false then
			wfmove = true
			print(tukuilocal.core_wf_unlock)
			wf:EnableMouse(true);
			wf:RegisterForDrag("LeftButton"); 
			wf:SetScript("OnDragStart", wf.StartMoving); 
			wf:SetScript("OnDragStop", wf.StopMovingOrSizing);
		elseif wfmove == true then
			wf:EnableMouse(false);
			wfmove = false
			print(tukuilocal.core_wf_lock)
		end
	end

	SLASH_WATCHFRAMELOCK1 = "/wf"
	SlashCmdList["WATCHFRAMELOCK"] = WATCHFRAMELOCK
end

hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent) -- durability frame
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        DurabilityFrame:ClearAllPoints();
		if TukuiDB["actionbar"].bottomrows == true then
			DurabilityFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB:Scale(228));		
		else
			DurabilityFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB:Scale(200));
		end
    end
end);

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints();
		if TukuiDB["actionbar"].bottomrows == true then
			VehicleSeatIndicator:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB:Scale(228));
		else
			VehicleSeatIndicator:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB:Scale(200));
		end
    end
end)

local function captureupdate()
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local cb = _G["WorldStateCaptureBar"..i]
		if cb and cb:IsShown() then
			cb:ClearAllPoints()
			cb:SetPoint("TOP", UIParent, "TOP", 0, TukuiDB:Scale(-120))
		end
	end
end
hooksecurefunc("WorldStateAlwaysUpFrame_Update", captureupdate)

------------------------------------------------------------------------
--	GM ticket fix
------------------------------------------------------------------------

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 0, 0)

------------------------------------------------------------------------
--	achievement micro fix
------------------------------------------------------------------------

AchievementMicroButton_Update = function() end

------------------------------------------------------------------------
--	commands we need
------------------------------------------------------------------------

SLASH_GM1 = "/gm"
SlashCmdList["GM"] = function() ToggleHelpFrame() end
SlashCmdList.DISABLE_ADDON = function(s) DisableAddOn(s) ReloadUI() end
SLASH_DISABLE_ADDON1 = "/disable"
SlashCmdList.ENABLE_ADDON = function(s) EnableAddOn(s) LoadAddOn(s) ReloadUI() end
SLASH_ENABLE_ADDON1 = "/enable"
SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("INSTALL_UI") end

local function HEAL()
	DisableAddOn("Tukui_Dps_Layout"); 
	EnableAddOn("Tukui_Heal_Layout"); 
	ReloadUI();
end

SLASH_HEAL1 = "/heal"
SlashCmdList["HEAL"] = HEAL

local function DPS()
	DisableAddOn("Tukui_Heal_Layout"); 
	EnableAddOn("Tukui_Dps_Layout");
	ReloadUI();
end

SLASH_DPS1 = "/dps"
SlashCmdList["DPS"] = DPS

------------------------------------------------------------------------
--	Raid or party disband command : Idea,Credit,Code -> Shestak, MonoLiT
------------------------------------------------------------------------

SlashCmdList["GROUPDISBAND"] = function()
		local pName = UnitName("player")
		SendChatMessage("Disbanding group.", "RAID" or "PARTY")
		if UnitInRaid("player") then
			for i = 1, GetNumRaidMembers() do
				local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
				if online and name ~= pName then
					UninviteUnit(name)
				end
			end
		else
			for i = MAX_PARTY_MEMBERS, 1, -1 do
				if GetPartyMember(i) then
					UninviteUnit(UnitName("party"..i))
				end
			end
		end
		LeaveParty()
end
SLASH_GROUPDISBAND1 = '/rd'

----------------------------------------------------------------------------------------
-- Class color guild and bg list
----------------------------------------------------------------------------------------

local GUILD_INDEX_MAX = 12
local SMOOTH = {
	1, 0, 0,
	1, 1, 0,
	0, 1, 0,
}
local myName = UnitName"player"

local BC = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	BC[v] = k
end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	BC[v] = k
end

local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

local function Hex(r, g, b)
	if(type(r) == "table") then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	
	if(not r or not g or not b) then
		r, g, b = 1, 1, 1
	end
	
	return format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

-- http://www.wowwiki.com/ColorGradient
local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select("#", ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select("#", ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

--GuildControlGetNumRanks()
--GuildControlGetRankName(index)
local guildRankColor = setmetatable({}, {
	__index = function(t, i)
		if i then
			t[i] = {ColorGradient(i/GUILD_INDEX_MAX, unpack(SMOOTH))}
		end
		return i and t[i] or {1,1,1}
	end
})

local diffColor = setmetatable({}, {
	__index = function(t,i)
		local c = i and GetQuestDifficultyColor(i)
		if not c then return "|cffffffff" end
		t[i] = Hex(c)
		return t[i]
	end
})

local classColorHex = setmetatable({}, {
	__index = function(t,i)
		local c = i and RAID_CLASS_COLORS[BC[i] or i]
		if not c then return "|cffffffff" end
		t[i] = Hex(c)
		return t[i]
	end
})

local classColors = setmetatable({}, {
	__index = function(t,i)
		local c = i and RAID_CLASS_COLORS[BC[i] or i]
		if not c then return {1,1,1} end
		t[i] = {c.r, c.g, c.b}
		return t[i]
	end
})

if CUSTOM_CLASS_COLORS then
	local function callBack()
		wipe(classColorHex)
		wipe(classColors)
	end
	CUSTOM_CLASS_COLORS:RegisterCallback(callBack)
end


--FRIENDS_LEVEL_TEMPLATE = "Level %d %s" -- For "name location" in friends list
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s") -- "%2$s %1$d-?? ??????"
hooksecurefunc("FriendsList_Update", function()
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)
	local friendIndex
	local playerArea = GetRealZoneText()
	
	for i=1, FRIENDS_TO_DISPLAY, 1 do
		friendIndex = friendOffset + i
		local name, level, class, area, connected, status, note, RAF = GetFriendInfo(friendIndex)
		local nameText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextName")
		local LocationText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextLocation")
		local infoText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextInfo")
		if not name then return end
		if connected then
			nameText:SetVertexColor(unpack(classColors[class]))
			if area == playerArea then
				area = format("|cff00ff00%s|r", area)
				LocationText:SetFormattedText(FRIENDS_LIST_TEMPLATE, area, status)
			end
			level = diffColor[level] .. level .. "|r"
			--class = classColorHex[class] .. class
			infoText:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class)
		else
			return
		end
	end
end)


hooksecurefunc("GuildStatus_Update", function()
	local playerArea = GetRealZoneText()
	
	if ( FriendsFrame.playerStatusFrame ) then
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
		local guildIndex
		
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex)
			if not name then return end
			if online then
				local nameText = getglobal("GuildFrameButton"..i.."Name")
				local zoneText = getglobal("GuildFrameButton"..i.."Zone")
				local levelText = getglobal("GuildFrameButton"..i.."Level")
				local classText = getglobal("GuildFrameButton"..i.."Class")
				
				nameText:SetVertexColor(unpack(classColors[class]))
				if playerArea == zone then
					zoneText:SetFormattedText("|cff00ff00%s|r", zone)
				end
				levelText:SetText(diffColor[level] .. level)
			end
		end
	else
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
		local guildIndex
		
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex)
			if not name then return end
			if online then
				local nameText = getglobal("GuildFrameGuildStatusButton"..i.."Name")
				nameText:SetVertexColor(unpack(classColors[class]))
				
				local rankText = getglobal("GuildFrameGuildStatusButton"..i.."Rank")
				rankText:SetVertexColor(unpack(guildRankColor[rankIndex]))
			end
		end
	end
end)


hooksecurefunc("WhoList_Update", function()
	local whoIndex
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
	
	local playerZone = GetRealZoneText()
	local playerGuild = GetGuildInfo"player"
	local playerRace = UnitRace"player"
	
	for i=1, WHOS_TO_DISPLAY, 1 do
		whoIndex = whoOffset + i
		local nameText = getglobal("WhoFrameButton"..i.."Name")
		local levelText = getglobal("WhoFrameButton"..i.."Level")
		local classText = getglobal("WhoFrameButton"..i.."Class")
		local variableText = getglobal("WhoFrameButton"..i.."Variable")
		
		local name, guild, level, race, class, zone, classFileName = GetWhoInfo(whoIndex)
		if not name then return end
		if zone == playerZone then
			zone = "|cff00ff00" .. zone
		end
		if guild == playerGuild then
			guild = "|cff00ff00" .. guild
		end
		if race == playerRace then
			race = "|cff00ff00" .. race
		end
		local columnTable = { zone, guild, race }
		
		nameText:SetVertexColor(unpack(classColors[class]))
		levelText:SetText(diffColor[level] .. level)
		variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
	end
end)


hooksecurefunc("LFRBrowseFrameListButton_SetData", function(button, index)
	local name, level, areaName, className, comment, partyMembers, status, class, encountersTotal, encountersComplete, isLeader, isTank, isHealer, isDamage = SearchLFGGetResults(index)
	
	local c = class and classColors[class]
	if c then
		button.name:SetTextColor(unpack(c))
		button.class:SetTextColor(unpack(c))
	end
	if level then
		button.level:SetText(diffColor[level] .. level)
	end
end)


hooksecurefunc("WorldStateScoreFrame_Update", function()
	local inArena = IsActiveBattlefieldArena()
	for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
		local index = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame) + i
		local name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone = GetBattlefieldScore(index)
		-- faction: Battlegrounds: Horde = 0, Alliance = 1 / Arenas: Green Team = 0, Yellow Team = 1
		if name then
			local n, r = strsplit("-", name, 2)
			n = classColorHex[classToken] .. n .. "|r"
			if n == myName then
				n = "> " .. n .. " <"
			end
			
			if r then
				local color
				if inArena then
					if faction == 1 then
						color = "|cffffd100"
					else
						color = "|cff19ff19"
					end
				else
					if faction == 1 then
						color = "|cff00adf0"
					else
						color = "|cffff1919"
					end
				end
				r = color .. r .. "|r"
				n = n .. "|cffffffff-|r" .. r
			end
			
			local buttonNameText = getglobal("WorldStateScoreButton" .. i .. "NameText")
			buttonNameText:SetText(n)
		end
	end
end)

----------------------------------------------------------------------------------------
-- Quest level(yQuestLevel by yleaf)
----------------------------------------------------------------------------------------

local function update()
	local buttons = QuestLogScrollFrame.buttons
	local numButtons = #buttons
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame)
	local numEntries, numQuests = GetNumQuestLogEntries()
	
	for i = 1, numButtons do
		local questIndex = i + scrollOffset
		local questLogTitle = buttons[i]
		if questIndex <= numEntries then
			local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("[" .. level .. "] " .. title)
				QuestLogTitleButton_Resize(questLogTitle)
			end
		end
	end
end

hooksecurefunc("QuestLog_Update", update)
QuestLogScrollFrameScrollBar:HookScript("OnValueChanged", update)

----------------------------------------------------------------------------------------
-- fix the fucking combatlog after a crash (a wow 2.4 and 3.3.2 bug)
----------------------------------------------------------------------------------------

local function CLFIX()
	CombatLogClearEntries()
end

SLASH_CLFIX1 = "/clfix"
SlashCmdList["CLFIX"] = CLFIX

----------------------------------------------------------------------------------------
-- Script to fix wintergrasp mount, /cast [flyable] Flying Mount Name; Ground Mount Name
-- is not working when wintergrasp is in progress, it return nothing. :(
-- Also can exit vehicule if you are on a friend mechano, mammooth, etc
-- example of use : /mounter Amani War Bear, Relentless Gladiator's Frost Wyrm
----------------------------------------------------------------------------------------

local WINTERGRASP
WINTERGRASP = tukuilocal.mount_wintergrasp

local inFlyableWintergrasp = function()
	return GetZoneText() == WINTERGRASP and not GetWintergraspWaitTime()
end

local creatureCache, creatureId, creatureName
local mountCreatureName = function(name)
	local companionCount = GetNumCompanions("MOUNT")
	
	if not creatureCache or companionCount ~= #creatureCache then
		creatureCache = {}

		for i = 1, companionCount do
			creatureId, creatureName = GetCompanionInfo("MOUNT", i)
			creatureCache[creatureName] = i
		end
	end
	
	local creatureId = creatureCache[name]
	
	if creatureId then
		CallCompanion("MOUNT", creatureId)
		return true
	end
end

local argumentsPattern = "([^,]+),%s*(.+)"

SlashCmdList['MOUNTER'] = function(text, editBox)
	if CanExitVehicle() then
		VehicleExit()
	elseif not IsMounted() and not InCombatLockdown() then
		local groundMount, flyingMount = string.match(text, argumentsPattern)
		
		if not groundMount then
			groundMount = #text > 0 and text or nil
		end
		
		if groundMount then
			local mount = (flyingMount and IsFlyableArea() and not inFlyableWintergrasp()) and flyingMount or groundMount
			local success = mountCreatureName(mount)
			
			if not success then
				print("No such mount: " .. mount)
			end
		else
			print("Usage: /mounter <Ground mount>[, <Flying mount>]")
		end
	else
		Dismount()
	end
end

SLASH_MOUNTER1 = "/mounter"

------------------------------------------------------------------------
--	ReloadUI command
------------------------------------------------------------------------

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

------------------------------------------------------------------------
--	What is this frame ?
------------------------------------------------------------------------
local function FRAME()
	ChatFrame1:AddMessage(GetMouseFocus():GetName()) 
end

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = FRAME



------------------------------------------------------------------------
-- Auto accept invite
------------------------------------------------------------------------

if TukuiDB["invite"].autoaccept == true then
	local tAutoAcceptInvite = CreateFrame("Frame")
	local OnEvent = function(self, event, ...) self[event](self, event, ...) end
	tAutoAcceptInvite:SetScript("OnEvent", OnEvent)

	local function PARTY_MEMBERS_CHANGED()
		StaticPopup_Hide("PARTY_INVITE")
		tAutoAcceptInvite:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	end

	local InGroup = false
	local function PARTY_INVITE_REQUEST()
		local leader = arg1
		InGroup = false
		
		-- Update Guild and Freindlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		
		for friendIndex = 1, GetNumFriends() do
			local friendName = GetFriendInfo(friendIndex)
			if friendName == leader then
				AcceptGroup()
				tAutoAcceptInvite:RegisterEvent("PARTY_MEMBERS_CHANGED")
				tAutoAcceptInvite["PARTY_MEMBERS_CHANGED"] = PARTY_MEMBERS_CHANGED
				InGroup = true
				break
			end
		end
		
		if not InGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = GetGuildRosterInfo(guildIndex)
				if guildMemberName == leader then
					AcceptGroup()
					tAutoAcceptInvite:RegisterEvent("PARTY_MEMBERS_CHANGED")
					tAutoAcceptInvite["PARTY_MEMBERS_CHANGED"] = PARTY_MEMBERS_CHANGED
					InGroup = true
					break
				end
			end
		end
		
		if not InGroup then
			SendWho(leader)
		end
	end

	tAutoAcceptInvite:RegisterEvent("PARTY_INVITE_REQUEST")
	tAutoAcceptInvite["PARTY_INVITE_REQUEST"] = PARTY_INVITE_REQUEST
end

------------------------------------------------------------------------
-- Auto invite by whisper (enabling by slash command by foof)
------------------------------------------------------------------------

local ainvenabled = false
local ainvkeyword = "invite"

local autoinvite = CreateFrame("frame")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:SetScript("OnEvent", function(self,event,arg1,arg2)
	if ((not UnitExists("party1") or IsPartyLeader("player")) and arg1:lower():match(ainvkeyword)) and ainvenabled == true then
		InviteUnit(arg2)
	end
end)

function SlashCmdList.AUTOINVITE(msg, editbox)
	if (msg == 'off') then
		ainvenabled = false
		print(tukuilocal.core_autoinv_disable)
	elseif (msg == '') then
		ainvenabled = true
		print(tukuilocal.core_autoinv_enable)
		ainvkeyword = "invite"
	else
		ainvenabled = true
		print(tukuilocal.core_autoinv_enable_c .. msg)
		ainvkeyword = msg
	end
end
SLASH_AUTOINVITE1 = '/ainv'

------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------

if TukuiDB["actionbar"].bottomrows == 0 or TukuiDB["actionbar"].bottomrows > 2 then
	TukuiDB["actionbar"].bottomrows = 1
end

if TukuiDB["actionbar"].rightbars > 3 then
	TukuiDB["actionbar"].rightbars = 3
end

if not TukuiDB.lowversion and TukuiDB["actionbar"].bottomrows == 2 and TukuiDB["actionbar"].rightbars > 1 then
	TukuiDB["actionbar"].rightbars = 1
end

------------------------------------------------------------------------
-- enable lua error
------------------------------------------------------------------------

function SlashCmdList.LUAERROR(msg, editbox)
	if (msg == 'on') then
		SetCVar("scriptErrors", 1)
		-- because sometime we need to /rl to show error.
		ReloadUI()
	elseif (msg == 'off') then
		SetCVar("scriptErrors", 0)
	else
		print("/luaerror on - /luaerror off")
	end
end
SLASH_LUAERROR1 = '/luaerror'

--------------------------------------------------------------------------
-- vehicule on mouseover because this shit take too much space on screen
--------------------------------------------------------------------------

-- note : there is probably a better way to do this but at least it work
-- this is the only way i found to know how many button we have on VehiculeSeatIndicator :(

local function vehmousebutton(alpha)
	local numSeat

	if VehicleSeatIndicatorButton1 then
		numSeat = 1
	elseif VehicleSeatIndicatorButton2 then
		numSeat = 2
	elseif VehicleSeatIndicatorButton3 then
		numseat = 3
	elseif VehicleSeatIndicatorButton4 then
		numSeat = 4
	elseif VehicleSeatIndicatorButton5 then
		numSeat = 5
	elseif VehicleSeatIndicatorButton6 then
		numSeat = 6
	end

	for i=1, numSeat do
	local pb = _G["VehicleSeatIndicatorButton"..i]
		pb:SetAlpha(alpha)
	end
end

local function vehmouse()
	if VehicleSeatIndicator:IsShown() then
		VehicleSeatIndicator:SetAlpha(0)
		VehicleSeatIndicator:EnableMouse(true)
		VehicleSeatIndicator:HookScript("OnEnter", function() VehicleSeatIndicator:SetAlpha(1) vehmousebutton(1) end)
		VehicleSeatIndicator:HookScript("OnLeave", function() VehicleSeatIndicator:SetAlpha(0) vehmousebutton(0) end)

		local numSeat

		if VehicleSeatIndicatorButton1 then
			numSeat = 1
		elseif VehicleSeatIndicatorButton2 then
			numSeat = 2
		elseif VehicleSeatIndicatorButton3 then
			numseat = 3
		elseif VehicleSeatIndicatorButton4 then
			numSeat = 4
		elseif VehicleSeatIndicatorButton5 then
			numSeat = 5
		elseif VehicleSeatIndicatorButton6 then
			numSeat = 6
		end

		for i=1, numSeat do
			local pb = _G["VehicleSeatIndicatorButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) VehicleSeatIndicator:SetAlpha(1) vehmousebutton(1) end)
			pb:HookScript("OnLeave", function(self) VehicleSeatIndicator:SetAlpha(0) vehmousebutton(0) end)
		end
	end
end
hooksecurefunc("VehicleSeatIndicator_Update", vehmouse)

--------------------------------------------------------------------------
-- modify the frame strata because of buffs
--------------------------------------------------------------------------

WorldStateAlwaysUpFrame:SetFrameStrata("BACKGROUND")
WorldStateAlwaysUpFrame:SetFrameLevel(0)
