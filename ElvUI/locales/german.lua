local ElvL = ElvL
local ElvDB = ElvDB

if ElvDB.client == "deDE" then
	ElvL.chat_BATTLEGROUND_GET = "[B]"
	ElvL.chat_BATTLEGROUND_LEADER_GET = "[B]"
	ElvL.chat_BN_WHISPER_GET = "From"
	ElvL.chat_GUILD_GET = "[G]"
	ElvL.chat_OFFICER_GET = "[O]"
	ElvL.chat_PARTY_GET = "[P]"
	ElvL.chat_PARTY_GUIDE_GET = "[P]"
	ElvL.chat_PARTY_LEADER_GET = "[P]"
	ElvL.chat_RAID_GET = "[R]"
	ElvL.chat_RAID_LEADER_GET = "[R]"
	ElvL.chat_RAID_WARNING_GET = "[W]"
	ElvL.chat_WHISPER_GET = "From"
	ElvL.chat_FLAG_AFK = "[AFK]"
	ElvL.chat_FLAG_DND = "[DND]"
	ElvL.chat_FLAG_GM = "[GM]"
	ElvL.chat_ERR_FRIEND_ONLINE_SS = "ist nun |cff298F00online|r"
	ElvL.chat_ERR_FRIEND_OFFLINE_S = "ist nun |cffff0000offline|r"
 
	ElvL.disband = "Gruppe wird aufgelöst."
	ElvL.raidbufftoggler = "Schlachtzugs-Buff Erinnerung: "	
	ElvL.datatext_download = "Herunterladen: "
	ElvL.datatext_bandwidth = "Bandbreite: "
	ElvL.datatext_guild = "Gilde"
	ElvL.datatext_noguild = "Keine Gilde"
	ElvL.datatext_bags = "Taschen: "
	ElvL.datatext_friends = "Freunde"
	ElvL.datatext_online = "Online: "
	ElvL.datatext_earned = "Erhalten:"
	ElvL.datatext_spent = "Ausgegeben:"
	ElvL.datatext_deficit = "Differenz:"
	ElvL.datatext_profit = "Gewinn:"
	ElvL.datatext_wg = "Zeit bis Tausendwinter:"
	ElvL.datatext_friendlist = "Freundesliste:"
	ElvL.datatext_playersp = "SP: "
	ElvL.datatext_playerap = "AP: "
	ElvL.datatext_session = "Sitzung: "
	ElvL.datatext_character = "Charakter: "
	ElvL.datatext_server = "Server: "
	ElvL.datatext_totalgold = "Gesamt: "
	ElvL.datatext_savedraid = "Instanz ID(s)"
	ElvL.datatext_currency = "Abzeichen:"
	ElvL.datatext_playercrit = "Crit: "
	ElvL.datatext_playerheal = "Heal"
	ElvL.datatext_avoidancebreakdown = "Vermeidungsübersicht"
	ElvL.datatext_lvl = "lvl"
	ElvL.datatext_boss = "Boss"
	ElvL.datatext_playeravd = "AVD: "
	ElvL.datatext_servertime = "Serverzeit: "
	ElvL.datatext_localtime = "Ortszeit: "
	ElvL.datatext_mitigation = "Schadensverringerung nach Level: "
	ElvL.datatext_healing = "Heilung: "
	ElvL.datatext_damage = "Schaden: "
	ElvL.datatext_honor = "Ehre: "
	ElvL.datatext_killingblows = "Todesstöße: "
	ElvL.datatext_ttstatsfor = "Stats für"
	ElvL.datatext_ttkillingblows = "Todesstöße: "
	ElvL.datatext_tthonorkills = "Ehrenhafte Siege: "
	ElvL.datatext_ttdeaths = "Tode: "
	ElvL.datatext_tthonorgain = "Ehre erhalten: "
	ElvL.datatext_ttdmgdone = "Schaden verursacht: "
	ElvL.datatext_tthealdone = "Heilung verursacht:"
	ElvL.datatext_basesassaulted = "Basen angegriffen:"
	ElvL.datatext_basesdefended = "Basen verteidigt:"
	ElvL.datatext_towersassaulted = "Türme angegriffen:"
	ElvL.datatext_towersdefended = "Türme verteidigt:"
	ElvL.datatext_flagscaptured = "Flaggen erobert:"
	ElvL.datatext_flagsreturned = "Flaggen zurückgebracht:"
	ElvL.datatext_graveyardsassaulted = "Friedhöfe angegriffen:"
	ElvL.datatext_graveyardsdefended = "Friedhöfe verteidigt:"
	ElvL.datatext_demolishersdestroyed = "Verwüster zerstört:"
	ElvL.datatext_gatesdestroyed = "Tore zerstört:"
	ElvL.datatext_totalmemusage = "Gesamte Speichernutzung:"
	ElvL.datatext_control = "Kontrolliert von:"
 
	ElvL.Slots = {
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
 
	ElvL.popup_disableui = "Elvui funktioniert nicht mit deiner Auflösung, möchtest du Elvui ausschalten? (Drücke Abbrechen, falls du eine andere Auflösung testen willst.)"
	ElvL.popup_install = "Dies ist das erste mal mit Elvui V12 mit diesem Charakter. Du musst dein UI neuladen, um Aktionsleisten, Variabeln und den Chat einzustellen."
	ElvL.popup_2raidactive = "2 Raid Layouts sind aktiv, wähle bitte eines aus."
	ElvL.popup_rightchatwarn = "Du hast wahrscheinlich aus Versehen das rechte Chatfenster entfernt, momentan benötigt Elvui dies. Zum deaktivieren musst du es in  den Einstellungen ausschalten, ansonsten drücke annehmen um die Chatfenster zurückzusetzen."
	ElvL.merchant_repairnomoney = "Du hast nicht genügend Gold zum Reparieren!"
	ElvL.merchant_repaircost = "Deine Rüstung wurde repariert für"
	ElvL.merchant_trashsell = "Dein Abfall wurde verkauft und du erhälst"
 
	ElvL.goldabbrev = "|cffffd700g|r"
	ElvL.silverabbrev = "|cffc7c7cfs|r"
	ElvL.copperabbrev = "|cffeda55fc|r"
 
	ElvL.error_noerror = "Keine Fehler bis jetzt."
 
	ElvL.unitframes_ouf_offline = "Offline"
	ElvL.unitframes_ouf_dead = "Tot"
	ElvL.unitframes_ouf_ghost = "Geist"
	ElvL.unitframes_ouf_lowmana = "WENIG MANA"
	ElvL.unitframes_ouf_threattext = "Bedrohung:"
	ElvL.unitframes_ouf_offlinedps = "Offline"
	ElvL.unitframes_ouf_deaddps = "TOT"
	ElvL.unitframes_ouf_ghostheal = "GEIST"
	ElvL.unitframes_ouf_deadheal = "TOT"
	ElvL.unitframes_ouf_gohawk = "LOS FALKE"
	ElvL.unitframes_ouf_goviper = "LOS VIPER"
	ElvL.unitframes_disconnected = "D/C"
 
	ElvL.tooltip_count = "Anzahl"
 
	ElvL.bags_noslots = "Kann keine weiteren Taschenplätze kaufen!"
	ElvL.bags_costs = "Kosten: %.2f Gold"
	ElvL.bags_buyslots = "Kaufe neuen Platz mit /bags purchase yes"
	ElvL.bags_openbank = "Du musst erst das Bankfach öffnen.."
	ElvL.bags_sort = "Sortiert deine Taschen oder die Bank, falls geöffnet.."
	ElvL.bags_stack = "Stapelt Items neu in deinen Taschen und der Bank, falls geöffnet.."
	ElvL.bags_buybankslot = "Kaufe Bankplatz. (Bank muss geöffnet sein)"
	ElvL.bags_search = "Suchen"
	ElvL.bags_sortmenu = "Sortieren"
	ElvL.bags_sortspecial = "Sortieren Spezialtasche"
	ElvL.bags_stackmenu = "Stapeln"
	ElvL.bags_stackspecial = "Stapeln Spezialtasche"
	ElvL.bags_showbags = "Zeige Taschen"
	ElvL.bags_sortingbags = "Sortieren abgeschlossen."
	ElvL.bags_nothingsort= "Nichts zu sortieren."
	ElvL.bags_bids = "Benutze Taschen: "
	ElvL.bags_stackend = "Neu stapeln abgeschlossen."
	ElvL.bags_rightclick_search = "Rechtsklick um zu suchen."
 
	ElvL.chat_invalidtarget = "Falsches Ziel"
 
	ElvL.core_autoinv_enable = "Autoinvite AN: invite"
	ElvL.core_autoinv_enable_c = "Autoinvite AN: "
	ElvL.core_autoinv_disable = "Autoinvite AUS"
	ElvL.core_welcome1 = "Willkommen zu |cffFF6347Elv's Edit von Elvui|r, version "
	ElvL.core_welcome2 = "Tippe |cff00FFFF/uihelp|r für mehr Informationen, Tippe |cff00FFFF/Elvui|r zum Konfigurieren, oder besuche http://www.tukui.org/v2/forums/forum.php?id=31"
 
	ElvL.core_uihelp1 = "|cff00ff00Allgemeine Slash Befehle|r"
	ElvL.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Gegner Abklingzeiten Anzeige - Low-memory Gegner PVP Abkling Anzeige. (Nur Icons)"
	ElvL.core_uihelp3 = "|cffFF0000/rl|r - Benutzer Interface neu laden."
	ElvL.core_uihelp4 = "|cffFF0000/gm|r - Schicke GM Tickets oder öffnet die WoW Ingame Hilfe."
	ElvL.core_uihelp5 = "|cffFF0000/frame|r - Zeigt im Chat den Namen des Fensters über dem sich die Maus befindet. (Hilfreich für Lua Editoren)"
	ElvL.core_uihelp6 = "|cffFF0000/heal|r - Aktiviert Heiler Raid Layout."
	ElvL.core_uihelp7 = "|cffFF0000/dps|r - Aktiviert DPS/Tank Raid Layout."
	ElvL.core_uihelp8 = "|cffFF0000/uf|r - Aktiviert oder deaktiviert das Bewegen der Einheitenfenster."
	ElvL.core_uihelp9 = "|cffFF0000/bags|r - Zum Sortieren, Kaufen von Bankplätzen oder neu Stapeln von Gegenständen in deiner Tasche."
	ElvL.core_uihelp10 = "|cffFF0000/installui|r - Wiederherstellung der ursprünglichen Elvui Einstellungen."
	ElvL.core_uihelp11 = "|cffFF0000/rd|r - Raid auflösen."
	ElvL.core_uihelp12 = "|cffFF0000/hb|r - Setzte Tastaturbelegung auf die Aktionsleisten"
	ElvL.core_uihelp13 = "|cffFF0000/mss|r - Befehl, um die Haltungs-(Krieger), Präsenz-(Todesritter), Auren-(Paladin), Formen-(Druide), Schattengestalt-(Priester) und Totem-(Schamane) Leisten zu bewegen."
	ElvL.core_uihelp15 = "|cffFF0000/ainv|r - Aktiviere autoinvite per Flüsterschlüsselwort. Du kannst durch Tippen von <code>/ainv meinwort</code> dein eigenes Schlüsselwort setzen."
	ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - Gold im Infotext zurücksetzen"
	ElvL.core_uihelp17 = "|cffFF0000/moveele|r - Entsperrt diverse Einheitenfeatures(Castbars/Buffs/Debuffs/ComboBar)."
	ElvL.core_uihelp18 = "|cffFF0000/resetele|r -  Resettet alle geänderten Einheitenfeatures(Castbars/Buffs/Debuffs/ComboBar). Ein bestimmtes Element kann man mit dem Befehl /resetele <elementname> resetten."
	ElvL.core_uihelp14 = "Scrolle hoch für mehr Befehle ...)"
 
	ElvL.bind_combat = "Du kannst keine Tasten im Kampf belegen."
	ElvL.bind_saved = "Alle Tastenbelegungen wurden gespeichert."
	ElvL.bind_discard = "Alle grade neu belegten Tastenbelegungen wurden verworfen."
	ElvL.bind_instruct = "Bewege deine Maus über einen Aktionsbutton um ihn mit einem Hotkey zu belegen. Drücke Escape oder Rechte Maustaste um die aktuelle Tastenbelegeung des Buttons zu löschen."
	ElvL.bind_save = "Tastenbelegung speichern"
	ElvL.bind_discardbind = "Tastenbelegung verwerfen"
 
	ElvL.core_raidutil = "Raid Utility"
	ElvL.core_raidutil_disbandgroup = "Gruppe auflösen"
	ElvL.core_raidutil_blue = "Blau"
	ElvL.core_raidutil_green = "Grün"
	ElvL.core_raidutil_purple = "Lila"
	ElvL.core_raidutil_red = "Rot"
	ElvL.core_raidutil_white = "Weiß"
	ElvL.core_raidutil_clear = "Zurücksetzen"
 
	ElvL.hunter_unhappy = "Dein Begleiter ist unzufrieden!"
	ElvL.hunter_content = "Dein Begleiter ist zufrieden!"
	ElvL.hunter_happy = "Dein Begleiter ist glücklich!"
 
	function ElvDB.UpdateHotkey(self, actionButtonType)
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