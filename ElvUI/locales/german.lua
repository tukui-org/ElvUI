local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "deDE" then
	elvuilocal.chat_BATTLEGROUND_GET = "[B]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[B]"
	elvuilocal.chat_BN_WHISPER_GET = "From"
	elvuilocal.chat_GUILD_GET = "[G]"
	elvuilocal.chat_OFFICER_GET = "[O]"
	elvuilocal.chat_PARTY_GET = "[P]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[P]"
	elvuilocal.chat_PARTY_LEADER_GET = "[P]"
	elvuilocal.chat_RAID_GET = "[R]"
	elvuilocal.chat_RAID_LEADER_GET = "[R]"
	elvuilocal.chat_RAID_WARNING_GET = "[W]"
	elvuilocal.chat_WHISPER_GET = "From"
	elvuilocal.chat_FLAG_AFK = "[AFK]"
	elvuilocal.chat_FLAG_DND = "[DND]"
	elvuilocal.chat_FLAG_GM = "[GM]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = "ist nun |cff298F00online|r"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = "ist nun |cffff0000offline|r"
 
	elvuilocal.disband = "Gruppe wird aufgelöst."
	elvuilocal.raidbufftoggler = "Schlachtzugs-Buff Erinnerung: "	
	elvuilocal.datatext_download = "Herunterladen: "
	elvuilocal.datatext_bandwidth = "Bandbreite: "
	elvuilocal.datatext_guild = "Gilde"
	elvuilocal.datatext_noguild = "Keine Gilde"
	elvuilocal.datatext_bags = "Taschen: "
	elvuilocal.datatext_friends = "Freunde"
	elvuilocal.datatext_online = "Online: "
	elvuilocal.datatext_earned = "Erhalten:"
	elvuilocal.datatext_spent = "Ausgegeben:"
	elvuilocal.datatext_deficit = "Differenz:"
	elvuilocal.datatext_profit = "Gewinn:"
	elvuilocal.datatext_wg = "Zeit bis Tausendwinter:"
	elvuilocal.datatext_friendlist = "Freundesliste:"
	elvuilocal.datatext_playersp = "SP: "
	elvuilocal.datatext_playerap = "AP: "
	elvuilocal.datatext_session = "Sitzung: "
	elvuilocal.datatext_character = "Charakter: "
	elvuilocal.datatext_server = "Server: "
	elvuilocal.datatext_totalgold = "Gesamt: "
	elvuilocal.datatext_savedraid = "Instanz ID(s)"
	elvuilocal.datatext_currency = "Abzeichen:"
	elvuilocal.datatext_playercrit = "Crit: "
	elvuilocal.datatext_playerheal = "Heal"
	elvuilocal.datatext_avoidancebreakdown = "Vermeidungsübersicht"
	elvuilocal.datatext_lvl = "lvl"
	elvuilocal.datatext_boss = "Boss"
	elvuilocal.datatext_playeravd = "AVD: "
	elvuilocal.datatext_servertime = "Serverzeit: "
	elvuilocal.datatext_localtime = "Ortszeit: "
	elvuilocal.datatext_mitigation = "Schadensverringerung nach Level: "
	elvuilocal.datatext_healing = "Heilung: "
	elvuilocal.datatext_damage = "Schaden: "
	elvuilocal.datatext_honor = "Ehre: "
	elvuilocal.datatext_killingblows = "Todesstöße: "
	elvuilocal.datatext_ttstatsfor = "Stats für"
	elvuilocal.datatext_ttkillingblows = "Todesstöße: "
	elvuilocal.datatext_tthonorkills = "Ehrenhafte Siege: "
	elvuilocal.datatext_ttdeaths = "Tode: "
	elvuilocal.datatext_tthonorgain = "Ehre erhalten: "
	elvuilocal.datatext_ttdmgdone = "Schaden verursacht: "
	elvuilocal.datatext_tthealdone = "Heilung verursacht:"
	elvuilocal.datatext_basesassaulted = "Basen angegriffen:"
	elvuilocal.datatext_basesdefended = "Basen verteidigt:"
	elvuilocal.datatext_towersassaulted = "Türme angegriffen:"
	elvuilocal.datatext_towersdefended = "Türme verteidigt:"
	elvuilocal.datatext_flagscaptured = "Flaggen erobert:"
	elvuilocal.datatext_flagsreturned = "Flaggen zurückgebracht:"
	elvuilocal.datatext_graveyardsassaulted = "Friedhöfe angegriffen:"
	elvuilocal.datatext_graveyardsdefended = "Friedhöfe verteidigt:"
	elvuilocal.datatext_demolishersdestroyed = "Verwüster zerstört:"
	elvuilocal.datatext_gatesdestroyed = "Tore zerstört:"
	elvuilocal.datatext_totalmemusage = "Gesamte Speichernutzung:"
	elvuilocal.datatext_control = "Kontrolliert von:"
 
	elvuilocal.Slots = {
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
 
	elvuilocal.popup_disableui = "Elvui funktioniert nicht mit deiner Auflösung, möchtest du Elvui ausschalten? (Drücke Abbrechen, falls du eine andere Auflösung testen willst.)"
	elvuilocal.popup_install = "Dies ist das erste mal mit Elvui V12 mit diesem Charakter. Du musst dein UI neuladen, um Aktionsleisten, Variabeln und den Chat einzustellen."
	elvuilocal.popup_2raidactive = "2 Raid Layouts sind aktiv, wähle bitte eines aus."
	elvuilocal.popup_rightchatwarn = "Du hast wahrscheinlich aus Versehen das rechte Chatfenster entfernt, momentan benötigt Elvui dies. Zum deaktivieren musst du es in  den Einstellungen ausschalten, ansonsten drücke annehmen um die Chatfenster zurückzusetzen."
	elvuilocal.merchant_repairnomoney = "Du hast nicht genügend Gold zum Reparieren!"
	elvuilocal.merchant_repaircost = "Deine Rüstung wurde repariert für"
	elvuilocal.merchant_trashsell = "Dein Abfall wurde verkauft und du erhälst"
 
	elvuilocal.goldabbrev = "|cffffd700g|r"
	elvuilocal.silverabbrev = "|cffc7c7cfs|r"
	elvuilocal.copperabbrev = "|cffeda55fc|r"
 
	elvuilocal.error_noerror = "Keine Fehler bis jetzt."
 
	elvuilocal.unitframes_ouf_offline = "Offline"
	elvuilocal.unitframes_ouf_dead = "Tot"
	elvuilocal.unitframes_ouf_ghost = "Geist"
	elvuilocal.unitframes_ouf_lowmana = "WENIG MANA"
	elvuilocal.unitframes_ouf_threattext = "Bedrohung:"
	elvuilocal.unitframes_ouf_offlinedps = "Offline"
	elvuilocal.unitframes_ouf_deaddps = "TOT"
	elvuilocal.unitframes_ouf_ghostheal = "GEIST"
	elvuilocal.unitframes_ouf_deadheal = "TOT"
	elvuilocal.unitframes_ouf_gohawk = "LOS FALKE"
	elvuilocal.unitframes_ouf_goviper = "LOS VIPER"
	elvuilocal.unitframes_disconnected = "D/C"
 
	elvuilocal.tooltip_count = "Anzahl"
 
	elvuilocal.bags_noslots = "Kann keine weiteren Taschenplätze kaufen!"
	elvuilocal.bags_costs = "Kosten: %.2f Gold"
	elvuilocal.bags_buyslots = "Kaufe neuen Platz mit /bags purchase yes"
	elvuilocal.bags_openbank = "Du musst erst das Bankfach öffnen.."
	elvuilocal.bags_sort = "Sortiert deine Taschen oder die Bank, falls geöffnet.."
	elvuilocal.bags_stack = "Stapelt Items neu in deinen Taschen und der Bank, falls geöffnet.."
	elvuilocal.bags_buybankslot = "Kaufe Bankplatz. (Bank muss geöffnet sein)"
	elvuilocal.bags_search = "Suchen"
	elvuilocal.bags_sortmenu = "Sortieren"
	elvuilocal.bags_sortspecial = "Sortieren Spezialtasche"
	elvuilocal.bags_stackmenu = "Stapeln"
	elvuilocal.bags_stackspecial = "Stapeln Spezialtasche"
	elvuilocal.bags_showbags = "Zeige Taschen"
	elvuilocal.bags_sortingbags = "Sortieren abgeschlossen."
	elvuilocal.bags_nothingsort= "Nichts zu sortieren."
	elvuilocal.bags_bids = "Benutze Taschen: "
	elvuilocal.bags_stackend = "Neu stapeln abgeschlossen."
	elvuilocal.bags_rightclick_search = "Rechtsklick um zu suchen."
 
	elvuilocal.chat_invalidtarget = "Falsches Ziel"
 
	elvuilocal.core_autoinv_enable = "Autoinvite AN: invite"
	elvuilocal.core_autoinv_enable_c = "Autoinvite AN: "
	elvuilocal.core_autoinv_disable = "Autoinvite AUS"
	elvuilocal.core_welcome1 = "Willkommen zu |cffFF6347Elv's Edit von Elvui|r, version "
	elvuilocal.core_welcome2 = "Tippe |cff00FFFF/uihelp|r für mehr Informationen, Tippe |cff00FFFF/Elvui|r zum Konfigurieren, oder besuche http://www.tukui.org/v2/forums/forum.php?id=31"
 
	elvuilocal.core_uihelp1 = "|cff00ff00Allgemeine Slash Befehle|r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Gegner Abklingzeiten Anzeige - Low-memory Gegner PVP Abkling Anzeige. (Nur Icons)"
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - Benutzer Interface neu laden."
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - Schicke GM Tickets oder öffnet die WoW Ingame Hilfe."
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - Zeigt im Chat den Namen des Fensters über dem sich die Maus befindet. (Hilfreich für Lua Editoren)"
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - Aktiviert Heiler Raid Layout."
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - Aktiviert DPS/Tank Raid Layout."
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - Aktiviert oder deaktiviert das Bewegen der Einheitenfenster."
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - Zum Sortieren, Kaufen von Bankplätzen oder neu Stapeln von Gegenständen in deiner Tasche."
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - Wiederherstellung der ursprünglichen Elvui Einstellungen."
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - Raid auflösen."
	elvuilocal.core_uihelp12 = "|cffFF0000/hb|r - Setzte Tastaturbelegung auf die Aktionsleisten"
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - Befehl, um die Haltungs-(Krieger), Präsenz-(Todesritter), Auren-(Paladin), Formen-(Druide), Schattengestalt-(Priester) und Totem-(Schamane) Leisten zu bewegen."
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - Aktiviere autoinvite per Flüsterschlüsselwort. Du kannst durch Tippen von <code>/ainv meinwort</code> dein eigenes Schlüsselwort setzen."
	elvuilocal.core_uihelp16 = "|cffFF0000/resetgold|r - Gold im Infotext zurücksetzen"
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - Entsperrt diverse Einheitenfeatures(Castbars/Buffs/Debuffs/ComboBar)."
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r -  Resettet alle geänderten Einheitenfeatures(Castbars/Buffs/Debuffs/ComboBar). Ein bestimmtes Element kann man mit dem Befehl /resetele <elementname> resetten."
	elvuilocal.core_uihelp14 = "Scrolle hoch für mehr Befehle ...)"
 
	elvuilocal.bind_combat = "Du kannst keine Tasten im Kampf belegen."
	elvuilocal.bind_saved = "Alle Tastenbelegungen wurden gespeichert."
	elvuilocal.bind_discard = "Alle grade neu belegten Tastenbelegungen wurden verworfen."
	elvuilocal.bind_instruct = "Bewege deine Maus über einen Aktionsbutton um ihn mit einem Hotkey zu belegen. Drücke Escape oder Rechte Maustaste um die aktuelle Tastenbelegeung des Buttons zu löschen."
	elvuilocal.bind_save = "Tastenbelegung speichern"
	elvuilocal.bind_discardbind = "Tastenbelegung verwerfen"
 
	elvuilocal.core_raidutil = "Raid Utility"
	elvuilocal.core_raidutil_disbandgroup = "Gruppe auflösen"
	elvuilocal.core_raidutil_blue = "Blau"
	elvuilocal.core_raidutil_green = "Grün"
	elvuilocal.core_raidutil_purple = "Lila"
	elvuilocal.core_raidutil_red = "Rot"
	elvuilocal.core_raidutil_white = "Weiß"
	elvuilocal.core_raidutil_clear = "Zurücksetzen"
 
	elvuilocal.hunter_unhappy = "Dein Begleiter ist unzufrieden!"
	elvuilocal.hunter_content = "Dein Begleiter ist zufrieden!"
	elvuilocal.hunter_happy = "Dein Begleiter ist glücklich!"
 
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