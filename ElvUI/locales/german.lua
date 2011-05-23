
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "deDE" then
	L.ElvUIInstall_page1_subtitle = "Willkommen bei ElvUI Version %s!"
	L.ElvUIInstall_page1_desc1 = "Dieser Installationsprozess wird Ihnen helfen, die Funktionen von ElvUI für Ihre Benutzeroberflächebesser kennenzulernen"
	L.ElvUIInstall_page1_desc2 = "Sie können den Befehl /uihelp benutzen, um eine kleine Liste aller Befehle zu erhalten.Die Ingame-Konfiguration können Sie entweder mit /ec oder /elvui aufrufen.Drücken Sie 'Schritt überspringen', um zum nachsten Schritt zu gelangen."
	L.ElvUIInstall_page1_button1 = "Schritt überspringen"

	L.ElvUIInstall_page2_subtitle = "CVars"
	L.ElvUIInstall_page2_desc1 = "Dieser Installationsprozess richtet alle wichtigen Cvars Ihres World of Warcrafts ein,um eine problemlose Nutzung zu ermöglichen.."
	L.ElvUIInstall_page2_desc2 = "Klicke 'Installiere CVars' um die CVars einzurichten."
	L.ElvUIInstall_page2_button1 = "Installiere CVars"

	L.ElvUIInstall_page3_subtitle = "Chat"
	L.ElvUIInstall_page3_desc1 = "Dieser Installationsprozess richtet Ihre Chatfenster, Positionen der Fenster, sowiedie Namen der Chatfenster ein."
	L.ElvUIInstall_page3_desc2 = "Klicke 'Installiere Chateinstellungen' um die Installation der Chatfenster zu beginnen.Sie müssen diesen Schritt ausführen, um eine korrekte Installation der Chatfenster zu erhalten."
	L.ElvUIInstall_page3_button1 = "Installiere Chateinstellungen"

	L.ElvUIInstall_page4_subtitle = "Auflösung"
	L.ElvUIInstall_page4_desc1 = "Ihre derzeitige Auflösung ist: %sElvUI hat automatisch für sie %s gewählt(Basierend auf Ihrer Bildschirmauflösung)."
	L.ElvUIInstall_page4_desc2 = "Dieser Installationsprozess steuert die Einstellung Ihrer Aktionsleisten und Ihrer Einheitenfenster.Sie können diese in der In-Game Konfiguration auch selbst ändern."
	L.ElvUIInstall_Low = "Low"
	L.ElvUIInstall_High = "High"

	L.ElvUIInstall_page5_subtitle = "Aktionsleisten"
	L.ElvUIInstall_page5_desc1 = "Nach der Einrichtung und Installation der Aktionsleisten können Sie diese durch den 'L' Knopf am unteren linken Chatfenster verschieben."
	L.ElvUIInstall_page5_desc2 = "Um schnelle Tastenkürzel setzen zu können, benutzen Sie den Befehl /hb.Um einzelne Aktionsknöpfe verschieben zu könnenhalten Sie die Taste 'SHIFT' gedrückt."

	L.ElvUIInstall_page6_subtitle = "Einheitenfenster"
	L.ElvUIInstall_page6_desc1 = "Nach der Einrichtung und Installation der Einheitenfenster, können Sie diesedurch den 'L' Knopf am unteren linken Chatfenster verschieben."
	L.ElvUIInstall_page6_desc2 = "Sie können mittels der Befehle /dps oder /heal zwischen zwei verschiedenen Layouts wechseln."
	L.ElvUIInstall_page6_desc3 = "Wenn Sie die Einheitenfenster mit den Standard-Einstellungen einrichten wollen, klicken Sie'Positioniere Einheitenfenster'"
	L.ElvUIInstall_page6_button1 = "Positioniere Einheitenfenster"

	L.ElvUIInstall_page7_subtitle = "Installation komplett"
	L.ElvUIInstall_page7_desc1 = "Sie haben die Installation erfolgreich abgeschlossen.Sollten Sie technischen Support benötigen,besuchen Sie uns unterwww.tukui.org."
	L.ElvUIInstall_page7_desc2 = "Bitte klicken Sie 'Abschließen' um die Variablen zu installieren und ein ReloadUI hervorzurufen."
	L.ElvUIInstall_page7_button1 = "Abschließen"
	L.ElvUIInstall_CVarSet = "CVars gesetzt"
	L.ElvUIInstall_ChatSet = "Chat-Positionen gesetzt"
	L.ElvUIInstall_UFSet = "Einheitenfenster-Positionen gesetzt"


	L.chat_BATTLEGROUND_GET = "[B]"
	L.chat_BATTLEGROUND_LEADER_GET = "[B]"
	L.chat_BN_WHISPER_GET = "From"
	L.chat_GUILD_GET = "[G]"
	L.chat_OFFICER_GET = "[O]"
	L.chat_PARTY_GET = "[P]"
	L.chat_PARTY_GUIDE_GET = "[P]"
	L.chat_PARTY_LEADER_GET = "[P]"
	L.chat_RAID_GET = "[R]"
	L.chat_RAID_LEADER_GET = "[R]"
	L.chat_RAID_WARNING_GET = "[W]"
	L.chat_WHISPER_GET = "From"
	L.chat_FLAG_AFK = "[AFK]"
	L.chat_FLAG_DND = "[DND]"
	L.chat_FLAG_GM = "[GM]"
	L.chat_ERR_FRIEND_ONLINE_SS = "ist nun |cff298F00online|r"
	L.chat_ERR_FRIEND_OFFLINE_S = "ist nun |cffff0000offline|r"
 
	L.disband = "Gruppe wird aufgelöst."
	L.chat_trade = "Handel"
	
	L.raidbufftoggler = "Schlachtzugs-Buff Erinnerung: "	
	L.datatext_download = "Herunterladen: "
	L.datatext_bandwidth = "Bandbreite: "
	L.datatext_noguild = "Keine Gilde"
	L.datatext_bags = "Taschen: "
	L.datatext_friends = "Freunde"
	L.datatext_earned = "Erhalten:"
	L.datatext_spent = "Ausgegeben:"
	L.datatext_deficit = "Differenz:"
	L.datatext_profit = "Gewinn:"
	L.datatext_wg = "Zeit bis Tausendwinter:"
	L.datatext_friendlist = "Freundesliste:"
	L.datatext_playersp = "SP: "
	L.datatext_playerap = "AP: "
	L.datatext_session = "Sitzung: "
	L.datatext_character = "Charakter: "
	L.datatext_server = "Server: "
	L.datatext_totalgold = "Gesamt: "
	L.datatext_savedraid = "Instanz ID(s)"
	L.datatext_currency = "Abzeichen:"
	L.datatext_playercrit = "Crit: "
	L.datatext_playerheal = "Heal"
	L.datatext_avoidancebreakdown = "Vermeidungsübersicht"
	L.datatext_lvl = "lvl"
	L.datatext_boss = "Boss"
	L.datatext_playeravd = "AVD: "
	L.datatext_mitigation = "Schadensverringerung nach Level: "
	L.datatext_healing = "Heilung: "
	L.datatext_damage = "Schaden: "
	L.datatext_honor = "Ehre: "
	L.datatext_killingblows = "Todesstöße: "
	L.datatext_ttstatsfor = "Stats für"
	L.datatext_ttkillingblows = "Todesstöße: "
	L.datatext_tthonorkills = "Ehrenhafte Siege: "
	L.datatext_ttdeaths = "Tode: "
	L.datatext_tthonorgain = "Ehre erhalten: "
	L.datatext_ttdmgdone = "Schaden verursacht: "
	L.datatext_tthealdone = "Heilung verursacht:"
	L.datatext_basesassaulted = "Basen angegriffen:"
	L.datatext_basesdefended = "Basen verteidigt:"
	L.datatext_towersassaulted = "Türme angegriffen:"
	L.datatext_towersdefended = "Türme verteidigt:"
	L.datatext_flagscaptured = "Flaggen erobert:"
	L.datatext_flagsreturned = "Flaggen zurückgebracht:"
	L.datatext_graveyardsassaulted = "Friedhöfe angegriffen:"
	L.datatext_graveyardsdefended = "Friedhöfe verteidigt:"
	L.datatext_demolishersdestroyed = "Verwüster zerstört:"
	L.datatext_gatesdestroyed = "Tore zerstört:"
	L.datatext_totalmemusage = "Gesamte Speichernutzung:"
	L.datatext_control = "Kontrolliert von:"
 
	L.Slots = {
		[1] = {1, "Kopf", 1000},
		[2] = {3, "Schulter", 1000},
		[3] = {5, "Brust", 1000},
		[4] = {6, "Taille", 1000},
		[5] = {9, "Handgelenke", 1000},
		[6] = {10, "Hände", 1000},
		[7] = {7, "Beine", 1000},
		[8] = {8, "Füße", 1000},
		[9] = {16, "Waffenhand", 1000},
		[10] = {17, "Schildhand", 1000},
		[11] = {18, "Distanzwaffe", 1000}
	}
 
	L.popup_disableui = "Elvui funktioniert nicht mit deiner Auflösung, möchtest du Elvui ausschalten? (Drücke Abbrechen, falls du eine andere Auflösung testen willst.)"
	L.popup_install = "Dies ist das erste mal mit Elvui V12 mit diesem Charakter. Du musst dein UI neuladen, um Aktionsleisten, Variabeln und den Chat einzustellen."
	L.popup_2raidactive = "2 Raid Layouts sind aktiv, wähle bitte eines aus."
	L.merchant_repairnomoney = "Du hast nicht genügend Gold zum Reparieren!"
	L.merchant_repaircost = "Deine Rüstung wurde repariert für"
	L.merchant_trashsell = "Dein Abfall wurde verkauft und du erhälst"
 
	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"
 
	L.error_noerror = "Keine Fehler bis jetzt."
 
	L.unitframes_ouf_offline = "Offline"
	L.unitframes_ouf_dead = "Tot"
	L.unitframes_ouf_ghost = "Geist"
	L.unitframes_ouf_lowmana = "WENIG MANA"
	L.unitframes_ouf_threattext = "Bedrohung:"
	L.unitframes_ouf_offlinedps = "Offline"
	L.unitframes_ouf_deaddps = "TOT"
	L.unitframes_ouf_ghostheal = "GEIST"
	L.unitframes_ouf_deadheal = "TOT"
	L.unitframes_ouf_gohawk = "LOS FALKE"
	L.unitframes_ouf_goviper = "LOS VIPER"
	L.unitframes_disconnected = "D/C"
 
	L.tooltip_count = "Anzahl"
 
	L.bags_noslots = "Kann keine weiteren Taschenplätze kaufen!"
	L.bags_costs = "Kosten: %.2f Gold"
	L.bags_buyslots = "Kaufe neuen Platz mit /bags purchase yes"
	L.bags_openbank = "Du musst erst das Bankfach öffnen.."
	L.bags_sort = "Sortiert deine Taschen oder die Bank, falls geöffnet.."
	L.bags_stack = "Stapelt Items neu in deinen Taschen und der Bank, falls geöffnet.."
	L.bags_buybankslot = "Kaufe Bankplatz. (Bank muss geöffnet sein)"
	L.bags_search = "Suchen"
	L.bags_sortmenu = "Sortieren"
	L.bags_sortspecial = "Sortieren Spezialtasche"
	L.bags_stackmenu = "Stapeln"
	L.bags_stackspecial = "Stapeln Spezialtasche"
	L.bags_showbags = "Zeige Taschen"
	L.bags_sortingbags = "Sortieren abgeschlossen."
	L.bags_nothingsort= "Nichts zu sortieren."
	L.bags_bids = "Benutze Taschen: "
	L.bags_stackend = "Neu stapeln abgeschlossen."
	L.bags_rightclick_search = "Rechtsklick um zu suchen."
 
	L.chat_invalidtarget = "Falsches Ziel"
 
	L.core_autoinv_enable = "Autoinvite AN: invite"
	L.core_autoinv_enable_c = "Autoinvite AN: "
	L.core_autoinv_disable = "Autoinvite AUS"
	L.core_welcome1 = "Willkommen zu |cff1784d1Elv's Edit von Elvui|r, version "
	L.core_welcome2 = "Tippe |cff00FFFF/uihelp|r für mehr Informationen, Tippe |cff00FFFF/Elvui|r zum Konfigurieren, oder besuche http://www.tukui.org/forums/forum.php?id=84"
 
	L.core_uihelp1 = "|cff00ff00Allgemeine Slash Befehle|r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui Arena Gegner Abklingzeiten Anzeige - Low-memory Gegner PVP Abkling Anzeige. (Nur Icons)"
	L.core_uihelp3 = "|cff1784d1/rl|r - Benutzer Interface neu laden."
	L.core_uihelp4 = "|cff1784d1/gm|r - Schicke GM Tickets oder öffnet die WoW Ingame Hilfe."
	L.core_uihelp5 = "|cff1784d1/frame|r - Zeigt im Chat den Namen des Fensters über dem sich die Maus befindet. (Hilfreich für Lua Editoren)"
	L.core_uihelp6 = "|cff1784d1/heal|r - Aktiviert Heiler Raid Layout."
	L.core_uihelp7 = "|cff1784d1/dps|r - Aktiviert DPS/Tank Raid Layout."
	L.core_uihelp8 = "|cff1784d1/uf|r - Aktiviert oder deaktiviert das Bewegen der Einheitenfenster."
	L.core_uihelp9 = "|cff1784d1/bags|r - Zum Sortieren, Kaufen von Bankplätzen oder neu Stapeln von Gegenständen in deiner Tasche."
	L.core_uihelp10 = "|cff1784d1/installui|r - Wiederherstellung der ursprünglichen Elvui Einstellungen."
	L.core_uihelp11 = "|cff1784d1/rd|r - Raid auflösen."
	L.core_uihelp12 = "|cff1784d1/hb|r - Setzte Tastaturbelegung auf die Aktionsleisten"
	L.core_uihelp13 = "|cff1784d1/mss|r - Befehl, um die Haltungs-(Krieger), Präsenz-(Todesritter), Auren-(Paladin), Formen-(Druide), Schattengestalt-(Priester) und Totem-(Schamane) Leisten zu bewegen."
	L.core_uihelp15 = "|cff1784d1/ainv|r - Aktiviere autoinvite per Flüsterschlüsselwort. Du kannst durch Tippen von <code>/ainv meinwort</code> dein eigenes Schlüsselwort setzen."
	L.core_uihelp16 = "|cff1784d1/resetgold|r - Gold im Infotext zurücksetzen"
	L.core_uihelp17 = "|cff1784d1/moveele|r - Entsperrt diverse Einheitenfeatures(Castbars/Buffs/Debuffs/ComboBar)."
	L.core_uihelp18 = "|cff1784d1/resetele|r -  Resettet alle geänderten Einheitenfeatures(Castbars/Buffs/Debuffs/ComboBar). Ein bestimmtes Element kann man mit dem Befehl /resetele <elementname> resetten."
	L.core_uihelp14 = "Scrolle hoch für mehr Befehle ...)"
 
	L.bind_combat = "Du kannst keine Tasten im Kampf belegen."
	L.bind_saved = "Alle Tastenbelegungen wurden gespeichert."
	L.bind_discard = "Alle grade neu belegten Tastenbelegungen wurden verworfen."
	L.bind_instruct = "Bewege deine Maus über einen Aktionsbutton um ihn mit einem Hotkey zu belegen. Drücke Escape oder Rechte Maustaste um die aktuelle Tastenbelegeung des Buttons zu löschen."
	L.bind_save = "Tastenbelegung speichern"
	L.bind_discardbind = "Tastenbelegung verwerfen"
 
	L.core_raidutil = "Raid Utility"
	L.core_raidutil_disbandgroup = "Gruppe auflösen"
	L.core_raidutil_blue = "Blau"
	L.core_raidutil_green = "Grün"
	L.core_raidutil_purple = "Lila"
	L.core_raidutil_red = "Rot"
	L.core_raidutil_white = "Weiß"
	L.core_raidutil_clear = "Zurücksetzen"
 
	L.hunter_unhappy = "Dein Begleiter ist unzufrieden!"
	L.hunter_content = "Dein Begleiter ist zufrieden!"
	L.hunter_happy = "Dein Begleiter ist glücklich!"
 
	function E.UpdateHotkey(self, actionButtonType)
		local hotkey = _G[self:GetName() .. 'HotKey']
		local text = hotkey:GetText()
 
		text = string.gsub(text, '(s%-)', 'S')
		text = string.gsub(text, '(a%-)', 'A')
		text = string.gsub(text, '(c%-)', 'C')
		text = string.gsub(text, '(Maus Taste )', 'M')
		text = string.gsub(text, '(Mittlere Maustaste)', 'M3')
		text = string.gsub(text, '(Nummernblock )', 'N')
		text = string.gsub(text, '(Bild hoch)', 'PU')
		text = string.gsub(text, '(Bild runter)', 'PD')
		text = string.gsub(text, '(Leertaste)', 'SpB')
		text = string.gsub(text, '(Einfügen)', 'Ins')
		text = string.gsub(text, '(Startseite)', 'Hm')
		text = string.gsub(text, '(Lüschen)', 'Del')
 
		if hotkey:GetText() == _G['RANGE_INDICATOR'] then
			hotkey:SetText('')
		else
			hotkey:SetText(text)
		end
	end
end