-- Setup the UI when the user types /configure
-- This will include:
---------------------
-- Fix UI Variables
-- Setup Chat Frames
-- Print the current resolution to chat

BLANK_TEXTURE			= "Interface\\AddOns\\Tukui\\media\\WHITE64X64"
TUKUI_BORDER_COLOR		= { .6,.6,.6,1 }
TUKUI_BACKDROP_COLOR	= { .1,.1,.1,1 }

local L = GetLocale()
local index = GetCurrentResolution();
local resolution = select(index, GetScreenResolutions());

-- Function to create "Panels" with the standard color scheme
function CreatePanel(height, width, x, y, anchorPoint, anchorPointRel, anchor, level, parent, strata)
	local Panel = CreateFrame("Frame", _, parent)
	Panel:SetFrameLevel(level)
	Panel:SetFrameStrata(strata)
	Panel:SetHeight(height)
	Panel:SetWidth(width)
	Panel:SetPoint(anchorPoint, anchor, anchorPointRel, x, y)
	Panel:SetBackdrop( { 
	  bgFile = BLANK_TEXTURE, 
	  edgeFile = BLANK_TEXTURE, 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	Panel:SetBackdropColor(unpack(TUKUI_BACKDROP_COLOR))
	Panel:SetBackdropBorderColor(unpack(TUKUI_BORDER_COLOR))
	return Panel
end 


-- we look if tukui can run on your current reso, if not, a popup is show
local tukuicheck = CreateFrame("Frame")
tukuicheck:RegisterEvent("PLAYER_LOGIN")
tukuicheck:SetScript("OnEvent", function()
	if not (resolution == "1680x945" or resolution == "2560x1440" or resolution == "1680x1050" or resolution == "1920x1080" or resolution == "1920x1200" or resolution == "1600x900" or resolution == "2048x1152" or resolution == "1776x1000" or resolution == "2560x1600" or resolution == "1600x1200") then
		print(resolution);
        SetCVar("useUiScale", 0)
		StaticPopup_Show("DISABLE_UI")
    end
	if(LoginMsg==true) then
			if(L=="ruRU") then
				print(" ")
				print("Добро пожаловать в Tukui V9 под патч 3.3!  www.tukui.org")
				print(" ")
				print("Текущее разрешение:", resolution);
				print(" ")
				print("Разрешение вашего экрана поддерживается.. Наслаждайтесь!")
				print(" ")
				print("Введите |cffFF0000/uihelp|r для большей информации!")
				print(" ")					
			elseif(L=="frFR") then
				print("Bienvenue sur Tukui V9 pour le patch 3.3 ! www.tukui.org")
				print(" ")
				print("Votre résolution:", resolution);
				print(" ")
				print("Votre résolution est bonne ... bon jeu !")
				print(" ")
				print("Pour plus d'informations, tapez /uihelp")
				print(" ")
			elseif(L=="deDE") then	
				print(" ")
				print("Willkommen bei Tukui V9 für Patch 3.3 !  www.tukui.org")
				print(" ")
				print("Aktuelle Auflösung:", resolution);
				print(" ")
				print("Deine Auflösung wird unterstützt... Viel Spass !")
				print(" ")
				print("Für mehr Infos |cffFF0000/uihelp|r eintippen!")
				print(" ")						
			else
				print(" ")
				print("Welcome on Tukui V9 for patch 3.3 !  www.tukui.org")
				print(" ")
				print("Current resolution:", resolution);
				print(" ")
				print("Your screen resolution is supported... Enjoy !")
				print(" ")
				print("Type |cffFF0000/uihelp|r for more infos!")
				print(" ")
			end
	end
	if(PixelPerfect==true) then
		SetCVar("useUiScale", 1)
		SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"));
		SetMultisampleFormat(1)
	end

	-- yeah, because tukui already have this shit so we disable some blizzard ugly frame.
	SetCVar("showClock", 0)
	SetCVar("showArenaEnemyFrames", 0)
	
	if TukuiMap == true and not IsAddOnLoaded("Mapster") then
		WorldMap_ToggleSizeDown()
	end
			
	-- we don't need this anymore :)
	tukuicheck:UnregisterEvent("PLAYER_LOGIN")
end)


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
		   
			t9install = true
			
			ReloadUI()
end

if(L=="ruRU") then
	StaticPopupDialogs["Tukui"] = {
	text = "Это первый запуск Tukui V9 для этого персонажа. Необходимо перезагрузить интерфейс для настройки панелей действий, переменных и чата.",
        button1 = "OK",
        OnAccept = install,
        timeout = 0,
        whileDead = 1,
	}
elseif(L=="frFR") then
	StaticPopupDialogs["Tukui"] = {
	text = "Première fois sur Tukui V9 avec ce personnage. Vous devez recharger l'interface utilisateur afin de configurer les barres d'action, les variables et les cadres de Chat.",
        button1 = "OK",
        OnAccept = install,
        timeout = 0,
        whileDead = 1,
	}
elseif(L=="deDE") then
	StaticPopupDialogs["Tukui"] = {
	text = "Dies ist das erste mal, dass du Tukui V9 mit diesem Charakter verwendest. Du must das Interface neuladen, damit der Chat, die Aktionsleisten und die Variablen eingestellt werden können.",
        button1 = "OK",
        OnAccept = install,
        timeout = 0,
        whileDead = 1,
	}
else
	StaticPopupDialogs["Tukui"] = {
	text = "First time on Tukui V9 with this Character. You must reload UI to set Action Bars, Variables and Chat Frames.",
        button1 = "OK",
        OnAccept = install,
        timeout = 0,
        whileDead = 1,
	}
end

-- command if we want to reset tukui to default
SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("Tukui") end

-- another check for action bars and vars
local tukuicheckinstall = CreateFrame("Frame")
tukuicheckinstall:RegisterEvent("PLAYER_ENTERING_WORLD")
tukuicheckinstall:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        tukuicheckinstall:UnregisterEvent("PLAYER_ENTERING_WORLD")
        tukuicheckinstall:SetScript("OnEvent", nil)
		
		--need a.b. to always be enabled
		SetActionBarToggles( 1, 1, 1, 1, 1 )
		
		-- set default var if tukui not found on that character
        if not (t9install) then
			StaticPopup_Show("Tukui")
		end

		if (IsAddOnLoaded("Tukui_Dps_Layout") and IsAddOnLoaded("Tukui_Heal_Layout")) then
			StaticPopup_Show("DISABLE_RAID")
		end
    end
end)

local function DisableTukui()
        DisableAddOn("Tukui"); 
		ReloadUI()
end

-- some popup shit

if(L=="ruRU") then
	StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui не работает под этим разрешением, отключаем Tukui? (Cancel если желаете попробовать другое разрешение)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
elseif(L=="frFR") then
	StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui ne fonctionne pas avec cette résolution, voulez-vous désactiver Tukui? (Annuler si vous souhaitez essayer une autre résolution)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
elseif(L=="deDE") then
	  StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui läuft nicht auf deiner Auflösung, möchtest du Tukui deaktivieren? (Abbrechen, wenn du eine andere Auflösung testen möchtest)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
else
	StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui doesn't work for this resolution, do you want to disable Tukui? (Cancel if you want to try another resolution)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
end


if(L=="ruRU") then
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 активных раскладки рейдовых фреймов, выберите раскладку.",
	  button1 = "DPS - TANK",
	  button2 = "HEAL",
	  OnAccept = function() DisableAddOn("Tukui_Heal_Layout"); EnableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  OnCancel = function() EnableAddOn("Tukui_Heal_Layout"); DisableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  timeout = 0,
	  whileDead = 1,
	}
elseif(L=="frFR") then
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "Choissisez votre modèle de raid :",
	  button1 = "DPS - TANK",
	  button2 = "HEAL",
	  OnAccept = function() DisableAddOn("Tukui_Heal_Layout"); EnableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  OnCancel = function() EnableAddOn("Tukui_Heal_Layout"); DisableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  timeout = 0,
	  whileDead = 1,
	}
elseif(L=="deDE") then	
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 Raid Layouts sind aktiv, bitte wähle ein Layout aus.",
	  button1 = "DPS - TANK",
	  button2 = "HEAL",
	  OnAccept = function() DisableAddOn("Tukui_Heal_Layout"); EnableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  OnCancel = function() EnableAddOn("Tukui_Heal_Layout"); DisableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  timeout = 0,
	  whileDead = 1,
	}	
else
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 raid layouts are active, please select a layout.",
	  button1 = "DPS - TANK",
	  button2 = "HEAL",
	  OnAccept = function() DisableAddOn("Tukui_Heal_Layout"); EnableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  OnCancel = function() EnableAddOn("Tukui_Heal_Layout"); DisableAddOn("Tukui_Dps_Layout"); ReloadUI(); end,
	  timeout = 0,
	  whileDead = 1,
	}
end

-------------------------------------------------------------------
-- modify position of some frames
-------------------------------------------------------------------

hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent) -- durability frame
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        DurabilityFrame:ClearAllPoints();
		if Tukui4BarsBottom == true then
			DurabilityFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",0,228);		
		else
			DurabilityFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",0,200);
		end
    end
end);

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints();
		if Tukui4BarsBottom == true then
			VehicleSeatIndicator:SetPoint("BOTTOM",UIParent,"BOTTOM",0,228);
		else
			VehicleSeatIndicator:SetPoint("BOTTOM",UIParent,"BOTTOM",0,200);
		end
    end
end);

-- damn watchframe since 3.3 not movable
if not IsAddOnLoaded("Who Framed Watcher Wabbit?") then -- conflict with a seerah mod
	local wf = WatchFrame
	local wfmove = false 

	wf:SetMovable(true);
	wf:SetClampedToScreen(false); 
	wf:ClearAllPoints()
	wf:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -6, -300)
	wf:SetWidth(250)
	wf:SetHeight(700)
	wf:SetUserPlaced(true)
	wf.SetPoint = function() end

	local function WATCHFRAMELOCK()
		if wfmove == false then
			wfmove = true
			print("WatchFrame unlocked for drag")
			wf:EnableMouse(true);
			wf:RegisterForDrag("LeftButton"); 
			wf:SetScript("OnDragStart", wf.StartMoving); 
			wf:SetScript("OnDragStop", wf.StopMovingOrSizing);
		elseif wfmove == true then
			wf:EnableMouse(false);
			wfmove = false
			print("WatchFrame locked")
		end
	end

	SLASH_WATCHFRAMELOCK1 = "/wf"
	SlashCmdList["WATCHFRAMELOCK"] = WATCHFRAMELOCK
end

------------------------------------------------------------------------
--	UI HELP
------------------------------------------------------------------------

-- Print Help Messages
local function UIHelp()
	if (L=="ruRU") then
		print(" ")
		print("|cff00ff00Общие комманды|r")
		print("|cffFF0000/tracker|r - Tukui Arena Enemy Cooldown Tracker - PVP-таймер вражеских перезарядок . (только иконка)")
		print("|cffFF0000/rl|r - Перезагрузить интерфейс.")
		print("|cffFF0000/gm|r - Связь с ГМ-ом и игровая помощь.")
		print("|cffFF0000/frame|r - Показать имя рамки под курсором мыши. (очень удобно для редактирования LUA)")
		print("|cffFF0000/abshow|r - Показать правые панели действий с текущими настройками.")
		print("|cffFF0000/abhide|r - Спрятать правые панели действия.")
		print("|cffFF0000/abconfig|r - Показать скрытые панели для расстановки умений и заклинаний.")
		print("|cffFF0000/setscale|r - Установить оптимальное масштабирования для вашего текущего разрешения экрана.")
		print("|cffFF0000/heal|r - Включить раскладку рейда для лекаря.")
		print("|cffFF0000/dps|r - Включить раскладку рейда для танка/бойца.")
		print("|cffFF0000/uf|r - ВКЛ/ВЫКЛ перемещение рамок юнитов.")
		print("|cffFF0000/bags|r - сортировка, покупка банковских ячеек и складывание предметов в ваших сумках.")
		print("|cffFF0000/resetui|r - сбросить переменные и настройки чата в значения Tukui по умолчанию.")
		print("|cffFF0000/rd|r - распустить рейд.")
		print("|cffFF0000/wf|r - разблокировать окно отслеживания заданий для перемещения.")
		print(" ")
		print("|cff00ff00Общая информация по интерфейсу :|r")
		print("|cffFF0000>|r Правый клик на миникарте для выбора отслеживания.")
		print("|cffFF0000>|r Левый клик на показателе брони для открытия окна персонажа.")
		print("|cffFF0000>|r Левый клик на показателе золота для открытия сумок.")
		print("|cffFF0000>|r Левый клик на показателе времени для открытия календаря. Если у вас есть непринятое приглашение, текст часов будет красным.")
		print("|cffFF0000>|r Левый клик на панели гильдии для открытия окна гильдии.")
		print("|cffFF0000>|r Левый клик на панели друзей для открытия окна друзей.")
		print("|cffFF0000>|r Левый клик на индикаторе УВС для сброса значения УВС.")
		print("|cffFF0000>|r Shift+наведениие мыши на панели гильдии для показа дополнительной информации в подсказке. ")
		print(" ")
		print("(Прокрутка вверх для показа комманд...)")	
	elseif(L=="frFR") then
		print(" ")
		print("|cff00ff00Commandes slash général|r")
		print("|cffFF0000/tracker|r - Suivre le Temps de recharge des sorts de l'ennemi en arène. (Icône seulement)")
		print("|cffFF0000/rl|r - Recharge votre interface utilisateur.")
		print("|cffFF0000/gm|r - Envoyer un message à un Mj ou utiliser de l'aide.")
		print("|cffFF0000/frame|r - Affiche le nom du cadre que vous survolez actuellemement (très utile pour éditer un fichier lua)")
		print("|cffFF0000/abshow|r - Affiche les barres d'actions de droite avec votre configuration actuelle.")
		print("|cffFF0000/abhide|r - Cache les barres d'action droite.")
		print("|cffFF0000/abconfig|r - Affiche toutes les barres cachées pour mettre vos sorts.")
		print("|cffFF0000/setscale|r - Mettez un UIScale parfait pour votre résolution actuelle .")
		print("|cffFF0000/heal|r - Active le mode heal de raid.")
		print("|cffFF0000/dps|r - Active le mode raid Dps/Tank.")
		print("|cffFF0000/uf|r - Active ou désactive le déplacement des cadres d'unité.")
		print("|cffFF0000/bags|r - Pour le tri, l'achat d'emplacement de banque ou d'empilement d'objets dans vos sacs.")
		print("|cffFF0000/resetui|r - réinitalise cVar et les Cadres de Conversation par défaut")
		print("|cffFF0000/rd|r - dissoudre le raid.")
		print("|cffFF0000/wf|r - Débloque le cadre des objectifs de quêtes pour la bouger.")
		print(" ")
		print("|cff00ff00Infos général de l'interface:|r")
		print("|cffFF0000>|r Clic droit sur la minicarte pour choisir votre pistage actuel.")
		print("|cffFF0000>|r Clic gauche sur les stats de votre armure pour voir le cadre de votre personnage.")
		print("|cffFF0000>|r Clic gauche sur votre or pour montrer les sacs.")
		print("|cffFF0000>|r Clic gauche sur l'horloge pour voir le calendrier. Si vous avez obtenu une invitation pour un événement, le temps de texte devient |cffff0000rouge.")
		print("|cffFF0000>|r Clic gauche sur Guilde pour afficher le cadre de la guilde.")
		print("|cffFF0000>|r clic gauche sur Amis pour voir le cadre de la liste des amis.")
		print("|cffFF0000>|r Clic gauche sur les stats dps pour réinitialiser le compteur")
		print("|cffFF0000>|r Maj(Shift) + Passez la souris sur les stats de guilde pour montrer dans une info-bulle des infos supplémentaire.")
		print(" ")
		print("(Défilement vers le haut pour plus de commande ...)")
   elseif(L=="deDE") then
          print(" ")
          print("|cff00ff00Allgemeine slash Befehle|r")
          print("|cffFF0000/tracker|r - Tukui Arena Gegner Cooldown Tracker - Low-memory PVP Gegner Cooldown tracker. (Nur Icons)")
          print("|cffFF0000/rl|r - Läd dein Interface neu.")
          print("|cffFF0000/gm|r - GM Tickets fur die WoW In-Game Hilfe schreiben.")
          print("|cffFF0000/frame|r - Den Frame-Name under deem Mauszeiger ermitteln.")
          print("|cffFF0000/abshow|r - Aktionsleisten auf der rechten Seite mit deinen momentanen Einstellungen zeigen.")
          print("|cffFF0000/abhide|r - Aktionsleisten auf der rechten Seite verstecken.")
          print("|cffFF0000/abconfig|r - Alle versteckten Leisten anzeigen.")
          print("|cffFF0000/setscale|r - Pixel Perfekt UI-Skalierung fur deine aktuelle Auflösung setzen.")
          print("|cffFF0000/heal|r - Heiler Raid Layout aktivieren.")
          print("|cffFF0000/dps|r - Schadens-/Tank-Layout aktivieren.")
          print("|cffFF0000/uf|r - Einheitenfenster bewegen / sperren.")
          print("|cffFF0000/bags|r - zum Taschen sortieren, Bankplätze kaufen oder Gegenstände in den Taschen stapeln.")
          print("|cffFF0000/resetui|r - cVar und Chat Frames auf TukUI Standard zurücksetzen.")
          print("|cffFF0000/rd|r - Schlachtzug auflösen.")
          print("|cffFF0000/wf|r - Quest Log zum Bewegen freigeben.")
          print(" ")
          print("|cff00ff00Allgemeine Infos zum Interface :|r")
          print("|cffFF0000>|r Rechtsklick auf die Minimap um etwas anderes zu verfolgen.")
          print("|cffFF0000>|r Linksklick auf die Haltbarkeitsanzeige um Charakter Infos anzuzeigen.")
          print("|cffFF0000>|r Linksklick auf die Goldanzeige um die Taschen zu öffnen.")
          print("|cffFF0000>|r Linksklick auf die Zeitanzeige um den Kalender zu öffnen. Wenn ihr zu einem Ereignis eingeladen wurded, ist die Zeitanzeige rot.")
          print("|cffFF0000>|r Linksklick auf die Gildenanzeige um die Gilden-Details zu öffnen.")
          print("|cffFF0000>|r Linksklick auf die Freundesanzeige um die Freundes-Liste zu öffnen.")
          print("|cffFF0000>|r Linksknick auf die DPS-Anzeige zum resetten.")
          print("|cffFF0000>|r Shift drücken und mit der Maus über die Gildenanzeige fahren, um einen erweiterten Gildeninfo Tooltip zu zeigen.")
          print(" ")
          print("(Hochscrollen um alle Befehle zu lesen ...)")		
	else
		print(" ")
		print("|cff00ff00General Slash Commands|r")
		print("|cffFF0000/tracker|r - Tukui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Icon only)")
		print("|cffFF0000/rl|r - Reloads your User Interface.")
		print("|cffFF0000/gm|r - Send GM tickets or show WoW in-game help.")
		print("|cffFF0000/frame|r - Detect frame name you currently mouseover. (very useful for lua editor)")
		print("|cffFF0000/abshow|r - Show right action bars with your current setting.")
		print("|cffFF0000/abhide|r - Hide right action bars.")
		print("|cffFF0000/abconfig|r - Show all hidden bars to put your spells.")
		print("|cffFF0000/setscale|r - Set a pixel perfect UIScale for your current resolution.")
		print("|cffFF0000/heal|r - Enable healing raid layout.")
		print("|cffFF0000/dps|r - Enable Dps/Tank raid layout.")
		print("|cffFF0000/uf|r - Enable or disable moving unit frames.")
		print("|cffFF0000/bags|r - for sorting, buying bank slot or stacking items in your bags.")
		print("|cffFF0000/resetui|r - reset cVar and Chat Frames to tukz default.")
		print("|cffFF0000/rd|r - disband raid.")
		print("|cffFF0000/wf|r - unlock quest tracker frame for dragging.")
		print(" ")
		print("|cff00ff00General Interface Infos :|r")
		print("|cffFF0000>|r Rightclick the Minimap to select your current tracking.")
		print("|cffFF0000>|r Leftclick on armor stat to show character frame.")
		print("|cffFF0000>|r Leftclick on gold stat to show bags.")
		print("|cffFF0000>|r Leftclick on time stat to show calendar. If you got an invite for an event, text time turn red.")
		print("|cffFF0000>|r Leftclick on guild stat to show guild frame.")
		print("|cffFF0000>|r Leftclick on friend stat to show friend frame.")
		print("|cffFF0000>|r Leftclick on dps stat to reset the dps meter.")
		print("|cffFF0000>|r Shift+Mouseover on guild stat to show additionnal guild info on tooltip.")
		print(" ")
		print("(Scroll up for more command ...)")
	end
end

SLASH_UIHELP1 = "/UIHelp"
SlashCmdList["UIHELP"] = UIHelp

------------------------------------------------------------------------
--	AUTO SCALING UI
------------------------------------------------------------------------
SlashCmdList["TUKZSETSCALE"] = function(scale1) Tukz_SetScale(scale1); end
SLASH_TUKZSETSCALE1 = "/setscale";
	function Tukz_SetScale(scale1)
	scale1 = tonumber(scale1)
		if (scale1 == nil) then
			SetCVar("useUIScale",1);
			SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"));
		else
			SetCVar("useUIScale",1);
			SetCVar("uiScale",scale1);
		end
	end


local function FRAME()
	ChatFrame1:AddMessage(GetMouseFocus():GetName()) 
end

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = FRAME

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

local function GM()
	ToggleHelpFrame()
end

------------------------------------------------------------------------
--	Game Master command
------------------------------------------------------------------------

SLASH_GM1 = "/gm"
SlashCmdList["GM"] = GM

------------------------------------------------------------------------
--	ReloadUI command
------------------------------------------------------------------------

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

------------------------------------------------------------------------
--	GM ticket fix
------------------------------------------------------------------------
TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 0,0)

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
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s") -- "%2$s %1$d-го уровня"
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
-- Class color friends list(Friend Color by Awbee)
----------------------------------------------------------------------------------------
function Hook_FriendsList_Update()
	if GetNumFriends() > 0 then
		local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame);
		for i=1, GetNumFriends(), 1 do
			local name, level, class, area, connected, status, note = GetFriendInfo(i);
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			if GetLocale() ~= "enUS" then
				for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
			end
			local classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
			if connected then
				local nameString = getglobal("FriendsFrameFriendButton"..(i-friendOffset).."ButtonTextName");
				if nameString then
					nameString:SetTextColor(classc.r, classc.g, classc.b);
				end
			end
		end
	end
end;
hooksecurefunc("FriendsList_Update", Hook_FriendsList_Update);

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
-- ALT+Click to buy a stack (from shestak)
----------------------------------------------------------------------------------------

local savedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick;
function MerchantItemButton_OnModifiedClick(self, ...)
	if ( IsAltKeyDown() ) then
		local maxStack = select(8, GetItemInfo(GetMerchantItemLink(this:GetID())));
		local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(this:GetID());
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(this:GetID(), floor(maxStack / quantity));
		end;
	end;
	savedMerchantItemButton_OnModifiedClick(self, ...);
end;

----------------------------------------------------------------------------------------
-- shorcut to enable or disable an addon (alza)
----------------------------------------------------------------------------------------

SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) end
SLASH_DISABLE_ADDON1 = "/dis"

SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) end
SLASH_ENABLE_ADDON1 = "/en"

----------------------------------------------------------------------------------------
-- auto accept LFD because im lazy or i miss it when i'm on windows desktop
----------------------------------------------------------------------------------------
if AutoLFDpress == true then
	local LFDAutoJoin = CreateFrame('Frame', nil, UIParent)

	LFDAutoJoin:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
	LFDAutoJoin:RegisterEvent('LFG_PROPOSAL_SHOW')

	function LFDAutoJoin:LFG_PROPOSAL_SHOW()
		LFDDungeonReadyDialogEnterDungeonButton:Click()
	end
end

----------------------------------------------------------------------------------------
-- capture bar update position
----------------------------------------------------------------------------------------

local function captureupdate()
	local nexty = 0
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local cb = _G["WorldStateCaptureBar"..i]
		if cb and cb:IsShown() then
			cb:ClearAllPoints()
			cb:SetPoint("TOP", UIParent, "TOP", 0, -120)
			nexty = nexty + cb:GetHeight()
		end
	end
end
hooksecurefunc("WorldStateAlwaysUpFrame_Update", captureupdate)

----------------------------------------------------------------------------------------
-- fix the fucking combatlog after a crash (a wow 2.4 and 3.3.2 bug)
----------------------------------------------------------------------------------------

local function CLFIX()
	CombatLogClearEntries()
end

SLASH_CLFIX1 = "/clfix"
SlashCmdList["CLFIX"] = CLFIX

