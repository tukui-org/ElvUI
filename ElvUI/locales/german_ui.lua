-- German localization file for deDE.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "deDE")
if not L then return end

--TEMP
L["A taint has occured that is preventing you from using the queue system. Please reload your user interface and try again."] = "Ein Fehler der dich daran hindert das Warteschlangensystem zu nutzen ist aufgetreten. Bitte lade dein Interface neu und versuche es nochmal."

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "Das Addon %s ist nicht mit dem ElvUI %s Modul kompatibel. Bitte deaktiviere entweder das Addon oder deaktiviere das ElvUI Modul."

--*_MSG locales
L["LOGIN_MSG"] = "Willkommen zu %sElvUI|r Version %s%s|r, Tippe /ec um das Konfigurationsmenü aufzurufen. Für technische Hilfe, besuche das Supportforum unter http://www.tukui.org"

--ActionBars
L["Binding"] = "Belegung"
L["Key"] = "Taste"
L["KEY_ALT"] = "A"
L["KEY_CTRL"] = "C"
L["KEY_DELETE"] = "Del"
L["KEY_HOME"] = "Hm"
L["KEY_INSERT"] = "Ins"
L["KEY_MOUSEBUTTON"] = "M"
L["KEY_MOUSEWHEELDOWN"] = "MwD"
L["KEY_MOUSEWHEELUP"] = "MwU"
L["KEY_NUMPAD"] = "N"
L["KEY_PAGEDOWN"] = "PD"
L["KEY_PAGEUP"] = "PU"
L["KEY_SHIFT"] = "S"
L["KEY_SPACE"] = "SpB"
L["No bindings set."] = "Keine Belegungen gesetzt."
L["Remove Bar %d Action Page"] = "Entferne Leiste %d Aktion Seite"
L["Trigger"] = "Auslöser"

--Bags
L["Bank"] = true;
L["Deposit Reagents"] = "Reagenzien einlagern"
L["Hold Control + Right Click:"] = "Halte Steuerung + Rechtsklick:"
L["Hold Shift + Drag:"] = "Halte Shift + Bewege die Maus:"
L["Purchase Bags"] = "Taschen kaufen"
L["Purchase"] = "Kaufen"
L["Reagent Bank"] = "Reagenzien Bank"
L["Reset Position"] = "Position zurücksetzen"
L["Show/Hide Reagents"] = "Reagenzien anzeigen/ausblenden"
L["Sort Tab"] = "Tab sortieren" --Not used, yet?
L["Temporary Move"] = "Temporäres Bewegen"
L["Toggle Bags"] = "Taschen umschalten"
L["Vendor Grays"] = "Graue Gegenstände verkaufen"

--Chat
L["AFK"] = "AFK" --Also used in datatexts and tooltip
L["DND"] = "DND" --Also used in datatexts and tooltip
L["G"] = "G"
L["I"] = "I"
L["IL"] = "IL"
L["Invalid Target"] = "Ungültiges Ziel"
L["O"] = "O"
L["P"] = "P"
L["PL"] = "PL"
L["R"] = "R"
L["RL"] = "RL"
L["RW"] = "RW"
L["says"] = "sagen"
L["whispers"] = "flüstern"
L["yells"] = "schreien"

--DataTexts
L["(Hold Shift) Memory Usage"] = "(Shift gedrückt) Speichernutzung"
L["AP"] = "AP"
L["App"] = true;
L["Arena"] = "Arena"
L["AVD: "] = "AVD: "
L["Avoidance Breakdown"] = "Vermeidung Aufgliederung"
L["Bandwidth"] = "Bandbreite"
L["Building(s) Report:"] = "Gebäude Bericht:"
L["Character: "] = "Charakter: "
L["Chest"] = "Brust"
L["Combat"] = "Kampf"
L["copperabbrev"] = "|cffeda55fc|r" --Also used in Bags
L["Defeated"] = "Besiegt"
L["Deficit:"] = "Defizit:"
L["Download"] = "Download"
L["DPS"] = "DPS"
L["Earned:"] = "Verdient:"
L["Feet"] = "Füße"
L["Friends List"] = "Freundesliste"
L["Friends"] = "Freunde" --Also in Skins
L["goldabbrev"] = "|cffffd700g|r" --Also used in gold datatext
L["Hands"] = "Hände"
L["Head"] = "Kopf"
L["Hit"] = "Hit"
L["Hold Shift + Right Click:"] = "Halte Umschalt + Rechts Klick:"
L["Home Latency:"] = "Standort Latenz"
L["HP"] = "HP"
L["HPS"] = "HPS"
L["Legs"] = "Beine"
L["lvl"] = "lvl"
L["Main Hand"] = "Waffenhand"
L["Mission(s) Report:"] = "Missionsbericht";
L["Mitigation By Level: "] = "Milderung durch Stufe:"
L["Multistrike"] = "Mehrfachschlag"
L["Naval Mission(s) Report:"] = "Marine Missionsbericht:"
L["No Guild"] = "Keine Gilde"
L["Offhand"] = "Schildhand"
L["Profit:"] = "Gewinn:"
L["Reset Data: Hold Shift + Right Click"] = "Daten zurücksetzen: Halte Shift + Rechtsklick"
L["Saved Raid(s)"] = "Gespeicherte Schlachtzüge"
L["Server: "] = "Server: "
L["Session:"] = "Sitzung:"
L["Shoulder"] = "Schulter"
L["silverabbrev"] = "|cffc7c7cfs|r" --Also used in Bags
L["SP"] = "SP"
L["Spec"] = "Spec"
L["Spent:"] = "Ausgegeben:"
L["Stats For:"] = "Stats Für:"
L["Total CPU:"] = "Gesamt CPU:"
L["Total Memory:"] = "Gesamte Speichernutzung:"
L["Total: "] = "Gesamt: "
L["Unhittable:"] = "Unhittable:"
L["Waist"] = "Taille"
L["Wrist"] = "Handgelenke"
L["|cffFFFFFFLeft Click:|r Change Talent Specialization"] = "|cffFFFFFFRechtsklick:|r Talentspezialisierung ändern"
L["|cffFFFFFFRight Click:|r Change Loot Specialization"] = "|cffFFFFFFRechtsklick:|r Beutespezialisierung ändern"

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = "%s: %s versucht die geschützte Funktion aufrufen '%s'."
L["No locals to dump"] = "Keine Lokalisierung zum verwerfen"

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = "%s möchte seine Filter Einstellungen mit dir teilen. Möchtest du die Anfrage annehmen?"
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = "%s versucht das Profil %s mit dir zu teilen. Möchtest du die Anfrage annehmen?"
L["Data From: %s"] = "Datei von: %s"
L["Filter download complete from %s, would you like to apply changes now?"] = "Filter komplett heruntergeladen von %s, möchtest du die Änderungen nun vornehmen?"
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = "Herr! Es ist ein Wunder! Der Download verschwand wie ein Furz im Wind! Versuche es nochmal!"
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = "Profil komplett heruntergeladen von %s, allerdings ist das Profil %s bereits vorhanden. Ändere den Namen oder das bereits existierende Profil wird überschrieben."
L["Profile download complete from %s, would you like to load the profile %s now?"] = "Profil komplett heruntergeladen von %s, möchtest du das Profil %s nun laden?"
L["Profile request sent. Waiting for response from player."] = "Profil Anfrage gesendet. Warte auf die Antwort des Spielers."
L["Request was denied by user."] = "Die Anfrage wurde vom Benutzer abgelehnt."
L["Your profile was successfully recieved by the player."] = "Dein Profil wurde erfolgreich von dem Spieler empfangen."

--Install
L["Aura Bars & Icons"] = "Aurenleiste & Symbole"
L["Auras Set"] = "Auren gesetzt"
L["Auras"] = "Auren"
L["Caster DPS"] = "Fernkampf DD"
L["Chat Set"] = "Chat gesetzt"
L["Chat"] = "Chat"
L["Choose a theme layout you wish to use for your initial setup."] = "Wähle ein Layout, welches du bei deinem ersten Setup verwenden möchtest."
L["Classic"] = "Klassisch"
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = "Klicke auf die Taste unten um die Größe deiner Chatfenster, Einheitenfenster und die Umpositionierung deiner Aktionsleisten durchzuführen."
L["Config Mode:"] = "Konfigurationsmodus:"
L["CVars Set"] = "CVars gesetzt"
L["CVars"] = "CVars"
L["Dark"] = "Dunkel"
L["Disable"] = "Deaktivieren"
L["ElvUI Installation"] = "ElvUI Installation"
L["Finished"] = "Beendet"
L["Grid Size:"] = "Rastergröße:"
L["Healer"] = "Heiler"
L["High Resolution"] = "Hohe Auflösung"
L["high"] = "hoch"
L["Icons Only"] = "Nur Symbole" --Also used in Bags
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = "Wenn du ein Symbol oder eine Aurenleiste nicht angezeigt haben möchtest, dann halte Shift gedrückt und klicke mit Rechtsklick auf das Symbol um es auszublenden."
L["Importance: |cff07D400High|r"] = "Bedeutung: |cff07D400Hoch|r"
L["Importance: |cffD3CF00Medium|r"] = "Bedeutung: |cffD3CF00Mittel|r"
L["Importance: |cffFF0000Low|r"] = "Bedeutung: |cffD3CF00Niedrig|r"
L["Installation Complete"] = "Installation komplett"
L["Layout Set"] = "Layout gesetzt"
L["Layout"] = "Layout"
L["Lock"] = "Sperren"
L["Low Resolution"] = "Niedrige Auflösung"
L["low"] = "niedrig"
L["Movers unlocked. Move them now and click Lock when you are done."] = "Ankerpunkte entriegelt. Bewege die Ankerpunkte und klicke 'sperren', wenn du fertig bist."
L["Nudge"] = "Stoß"
L["Physical DPS"] = "Physische DPS"
L["Pixel Perfect"] = "Pixel Perfekt"
L["Please click the button below so you can setup variables and ReloadUI."] = "Bitte klicke die Taste unten um den Installationsprozess abzuschließen und das Benutzerinterface neu zu laden."
L["Please click the button below to setup your CVars."] = "Klicke 'Installiere CVars' um die CVars einzurichten."
L["Please press the continue button to go onto the next step."] = "Bitte drücke die Weiter-Taste um zum nächsten Schritt zu gelangen."
L["Resolution Style Set"] = "Auflösungsart gesetzt"
L["Resolution"] = "Auflösung"
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = "Wähle für die ElvUI Einheitenfenster ob das Auren-System Aurenleisten und Symbole, oder nur Symbole anzeigt."
L["Setup Chat"] = "Chateinstellungen"
L["Setup CVars"] = "Installiere CVars"
L["Skip Process"] = "Schritt überspringen"
L["Sticky Frames"] = "Anheftende Fenster"
L["Tank"] = "Tank"
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "Die Chatfensterfunktionen sind die gleichen, wie die Chatfenster von Blizzard. Du kannst auf die Tabs rechtsklicken und sie z.B. neu zu positionieren, umzubenennen, etc. Bitte klicke den Button unten um das Chatfenster einzurichten."
L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "Das ElvUI-Konfigurationsmenü kannst du entweder mit /ec oder durch das Anklicken der 'C' Taste an der Minimap aufrufen. Drücke 'Schritt überspringen' um zum nächsten Schritt zu gelangen."
L["The Pixel Perfect option will change the overall apperance of your UI. Using Pixel Perfect is a slight performance increase over the traditional layout."] = "Die Pixel-Perfekt-Option wird das allgemeine Erscheinungsbild verändern. Das Verwenden von Pixel Perfekt bringt eine kleine Leistungssteigerung gegenüber dem Standard Layout"
L["Theme Set"] = "Thema gesetzt"
L["Theme Setup"] = "Thema Setup"
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "Dieser Installationsprozess wird dir helfen, die Funktionen von ElvUI für deine Benutzeroberfläche besser kennenzulernen."
L["This is completely optional."] = "Das ist komplett Optional."
L["This part of the installation process sets up your chat windows names, positions and colors."] = "Dieser Abschnitt der Installation stellt die Chat Fenster Namen, Positionen und Farben ein."
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "Dieser Installationsprozess richtet alle wichtigen Cvars deines World of Warcrafts ein, um eine problemlose Nutzung zu ermöglichen."
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = "Diese Auflösung benötigt keine Änderungen um mit der Benutzeroberfläche zu funktionieren."
L["This resolution requires that you change some settings to get everything to fit on your screen."] = "Diese Auflösung benötigt Änderungen um mit der Benutzeroberfläche zu funktionieren."
L["This will change the layout of your unitframes and actionbars."] = "Dies wird das Layout der Einheitenfenster und Aktionsleisten ändern."
L["Trade"] = "Handel"
L["Welcome to ElvUI version %s!"] = "Willkommen bei ElvUI Version %s!"
L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."] = "Du hast den Installationsprozess abgeschlossen. Solltest du technische Hilfe benötigen, besuche uns auf http://www.tukui.org."
L["You can always change fonts and colors of any element of elvui from the in-game configuration."] = "Du kannst jederzeit in der Ingame-Konfiguration Schriften und Farben von jedem Element des Interfaces ändern."
L["You can now choose what layout you wish to use based on your combat role."] = "Du kannst nun auf Basis deiner Rolle im Kampf ein Layout wählen."
L["You may need to further alter these settings depending how low you resolution is."] = "Unter Umständen musst du, je nachdem wie niedrig deine Auflösung ist, diese Einstellungen ändern."
L["Your current resolution is %s, this is considered a %s resolution."] = "Deine Aktuelle Auflösung ist %s, diese wird als eine %s Auflösung angesehen."

--Misc
L["ABOVE_THREAT_FORMAT"] = "%s: %.0f%% [%.0f%% above |cff%02x%02x%02x%s|r]"
L["Average Group iLvl:"] = "Durchschnittliches Gruppen iLvl:"
L["Bars"] = "Leisten" --Also used in UnitFrames
L["Calendar"] = "Kalender"
L["Can't Roll"] = "Es kann nicht gewürfelt werden."
L["Disband Group"] = "Gruppe auflösen"
L["Enable"] = "Eingeschaltet" --Doesn't fit a section since it's used a lot of places
L["Experience"] = "Erfahrung"
L["Farm Mode"] = "Farmmodus" -- Minimap middle click menu
L["Fishy Loot"] = "Faule Beute"
L["iLvl"] = "iLvl" --Column header in raidbrowse
L["Important Group Members:"] = "Wichtige Gruppenmitglieder:"
L["Left Click:"] = "Linksklick:" --layout\layout.lua
L["Raid Browser"] = "Schlachtzugsbrowser" -- Minimap middle click menu
L["Raid Menu"] = "Schlachtzugsmenü"
L["Remaining:"] = "Verbleibend:"
L["Rested:"] = "Ausgeruht:"
L["Right Click:"] = "Rechtsklick:" --layout\layout.lua
L["Show BG Texts"] = "Zeige Schlachtfeldtexte" --layout\layout.lua
L["Talent Spec"] = "Talent Spec" --Column header in raidbrowser
L["Toggle Chat Frame"] = "Chatfenster an-/ausschalten" --layout\layout.lua
L["Toggle Configuration"] = "Konfiguration umschalten" --layout\layout.lua
L["XP:"] = "EP:"
L["You don't have permission to mark targets."] = "Du hast keine Rechte um ein Ziel zu markieren."

--Movers
L["Alternative Power"] = "Alternative Energie"
L["Archeology Progress Bar"] = "Archeologie Fortschrittsleiste"
L["Arena Frames"] = "Arena Fenster" --Also used in UnitFrames
L["Bags"] = "Taschen" --Also in DataTexts
L["Bar "] = "Leiste " --Also in ActionBars
L["BNet Frame"] = "BNet-Fenster"
L["BodyGuard Frame"] = "Leibwächter Fenster"
L["Boss Button"] = "Boss Button"
L["Boss Frames"] = "Boss Fenster" --Also used in UnitFrames
L["Class Bar"] = "Klassenleiste"
L["Classbar"] = "Klassenleiste"
L["Experience Bar"] = "Erfahrungsleiste"
L["Focus Castbar"] = "Fokus Zauberbalken"
L["Focus Frame"] = "Fokusfenster" --Also used in UnitFrames
L["FocusTarget Frame"] = "Fokus-Ziel Fenster" --Also used in UnitFrames
L["GM Ticket Frame"] = "GM-Ticket-Fenster"
L["Left Chat"] = "Linker Chat"
L["Loot / Alert Frames"] = "Beute-/Alarmfenster"
L["Loot Frame"] = "Beute-Fenster"
L["Loss Control Icon"] = "Kontrollverlustsymbol"
L["MA Frames"] = "MA-Fenster"
L["Micro Bar"] = "Mikroleiste" --Also in ActionBars
L["Minimap"] = "Minimap"
L["MirrorTimer"] = "Spiegel Zeitgeber"
L["MT Frames"] = "MT-Fenster"
L["Objective Frame"] = "Questfenster"
L["Party Frames"] = "Gruppenfenster" --Also used in UnitFrames
L["Pet Bar"] = "Begleisterleiste" --Also in ActionBars
L["Pet Castbar"] = "Begleiter Zauberleiste"
L["Pet Frame"] = "Begleiterfenster" --Also used in UnitFrames
L["PetTarget Frame"] = "Begleiter-Ziel Fenster" --Also used in UnitFrames
L["Player Buffs"] = "Spieler Buffs"
L["Player Castbar"] = "Spieler Zauberbalken"
L["Player Debuffs"] = "Spieler Debuffs"
L["Player Frame"] = "Spielerfenster" --Also used in UnitFrames
L["Player Powerbar"] = "Spieler Kraftleiste"
L["Raid Frames"] = "Schlachtzugsfenster" --Also used in UnitFrames
L["Raid Pet Frames"] = "Schlachtzugspets-Fenster"
L["Raid-40 Frames"] = "40er Schlachtzugsfenster" --Also used in UnitFrames
L["Reputation Bar"] = "Rufleiste"
L["Right Chat"] = "Rechter Chat"
L["Stance Bar"] = "Haltungsleiste" --Also in ActionBars
L["Target Castbar"] = "Ziel Zauberbalken"
L["Target Frame"] = "Zielfenster" --Also used in UnitFrames
L["Target Powerbar"] = "Ziel Kraftleiste"
L["TargetTarget Frame"] = "Ziel des Ziels Fenster" --Also used in UnitFrames
L["TargetTargetTarget Frame"] = "Ziel des Ziels des Ziels Fenster"
L["Tooltip"] = "Tooltip"
L["Vehicle Seat Frame"] = "Fahrzeugfenster"

--NamePlates
L["Discipline"] = "Disziplin"
L["Holy"] = "Heilig"
L["Mistweaver"] = "Nebelwirker"
L["Restoration"] = "Wiederherstellung"

--Prints
L[" |cff00ff00bound to |r"] = " |cff00ff00gebunden zu |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = "Es liegt ein Konflikt bei den Ankerpunkten des Rahmens %s vor. Bitte ändere entweder den Ankerpunkt des Stärkungs- oder Schwächungszaubers, damit diese nicht länger mit einander verbunden sind. Verbinde die Schwächungszauber mit dem Hauptrahmen, damit dieses Problem behoben wird."
L["All keybindings cleared for |cff00ff00%s|r."] = "Alle Tastaturbelegungen gelöscht für |cff00ff00%s|r."
L["Already Running.. Bailing Out!"] = "Bereits ausgeführt.. Warte ab!"
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = "Schlachtfeld-Infotexte sind kurzzeitig versteckt, um sie wieder anzuzeigen tippe /bgstats oder rechtsklicke auf das 'C' Symbol nahe der Minimap."
L["Battleground datatexts will now show again if you are inside a battleground."] = "Schlachtfeld-Infotexte werden wieder angezeigt, solange du dich in einem Schlachtfeld befindest."
L["Binds Discarded"] = "Tastaturbelegungen verworfen"
L["Binds Saved"] = "Tastaturbelegungen gespeichert"
L["Confused.. Try Again!"] = "Verwirrt.. Versuche es erneut!"
L["No gray items to delete."] = "Es sind keine grauen Gegenstände zum Löschen vorhanden."
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = "Der Zauber '%s' wurde zur schwarzen Liste der Einheitenfenster hinzugefügt."
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = "Diese Einstellungen haben einen Konflikt mit einem Ankerpunkt, wo '%s' an sich selbst angehaftet sein soll. Bitte kontrolliere deine Ankerpunkte. Einstellung '%s' angehaftet an '%s'."
L["Vendored gray items for:"] = "Graue Gegenstände verkauft für:"
L["You don't have enough money to repair."] = "Du hast nicht genügend Gold für die Reparatur."
L["You must be at a vendor."] = "Du musst bei einem Händler sein."
L["Your items have been repaired for: "] = "Deine Gegenstände wurden repariert für: "
L["Your items have been repaired using guild bank funds for: "] = "Deine Gegenstände wurden repariert. Die Gildenbank kostete das: "
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = "|cFFE30000Lua Fehler erhalten. Du kannst die Fehlermeldung ansehen, wenn du den Kampf verlässt."

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = "Eine Einstellung, die du geändert hast, betrifft nur einen Charakter. Diese Einstellung, die du verändert hast, wird die Benutzerprofile unbeeinflusst lassen. Eine Änderung dieser Einstellung erfordert, dass du dein Interface neu laden musst."
L["Are you sure you want to delete all your gray items?"] = "Bist du sicher, dass du alle grauen Gegenstände löschen willst?"
L["Are you sure you want to disband the group?"] = "Bist du dir sicher, dass du die Gruppe auflösen willst?"
L["Are you sure you want to reset all the settings on this profile?"] = "Bist du dir sicher dass du alle Einstellungen dieses Profils zurücksetzen willst?"
L["Are you sure you want to reset every mover back to it's default position?"] = "Bist du dir sicher, dass du jeden Beweger an die Standard-Position zurücksetzen möchtest?"
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = "Aufgrund der großen Verwirrung, die durch das neue Auren-System verursacht wurde, habe ich einen neuen Schritt zum Installationsprozess hinzugefügt. Dieser ist optional. Wenn du deine Auren so eingestellt lassen willst, wie sie sind, gehe einfach zum letzten Schritt und klicke auf fertig um nicht erneut aufgefordert zu werden. Wirst du, aus welchen Grund auch immer, öfter aufgefordert, starte bitte dein Spiel neu"
L["Can't buy anymore slots!"] = "Kann keine Slots mehr kaufen"
L["Detected that your ElvUI Config addon is out of date. This may be a result of your Tukui Client being out of date. Please visit our download page and update your Tukui Client, then reinstall ElvUI. Not having your ElvUI Config addon up to date will result in missing options."] = "Es wurde erkannt dass dein ElvUI Konfigurations-Addon veraltet ist. Dies kann das Ergebnis eines veralteten Tukui Clients sein. Bitte besuche unsere Downloadseite und update deinen Tukui Client, dann installiere ElvUI neu. Das nicht auf dem neuesten Stand haben des ElvUI Konfigurations-Addons wird in fehlenden Optionen resultieren."
L["Disable Warning"] = "Deaktiviere Warnung"
L["Discard"] = "Verwerfen"
L["Do you enjoy the new ElvUI?"] = "Gefällt dir das neue ElvUI?"
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = "Schwörst du, dass du keinen Beitrag im Supportforum posten wirst, ohne vorher alle anderen Addons/Module zu deaktivieren?"
L["ElvUI is five or more revisions out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = "ElvUI ist seit fünf oder mehr Revisionen nicht aktuell. Du kannst die neuste Version bei www.tukui.org herunterladen. Hol dir die Premium-Mitgliedschaft und ElvUI wird durch den Tukui-Client automatisch aktualisiert!"
L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = "ElvUI ist nicht aktuell. Du kannst die neuste Version bei www.tukui.org herunterladen. Hol dir die Premium-Mitgliedschaft und ElvUI wird durch den Tukui-Client automatisch aktualisiert!"
L["ElvUI needs to perform database optimizations please be patient."] = "ElvUI muss eine Datenbank Optimierung durchführen. Bitte warte eine Moment."
L["Enabling/Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"] = "Aktivieren/Deaktivieren der Leiste #6 wird eine Option für die Seitennummerierung deine Hauptaktionsleiste hervorrufen um doppelte Leisten zu verhindern, bist du dir sich das du das tun willst?"
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "Bewege deine Maus über einen Aktionsbutton oder dein Zauberbuch um ihn mit einem Hotkey zu belegen. Drücke Escape oder rechte Maustaste um die aktuelle Tastenbelegung des Buttons zu löschen."
L["I Swear"] = "Ich schwöre"
L["It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled."] = "Es sieht so aus, als würde eines deiner Addons die Blizzard_CompactRaidFrames deaktivieren. Dass kann zu Fehlern oder anderen Problemen führen. Das Addon wird wieder aktiviert."
L["No, Revert Changes!"] = "Nein, Änderungen verwerfen!"
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = "Oh Gott, du hast ElvUI und Tukui zur gleichen Zeit aktiviert. Wähle ein Addon um es zu deaktivieren."
L["One or more of the changes you have made require a ReloadUI."] = "Eine oder mehrere Einstellungen, die du vorgenommen hast, benötigen ein Neuladen des Benutzerinterfaces um in Effekt zu treten."
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "Eine oder mehrere Änderungen, die du getroffen hast, betrifft alle Charaktere die dieses Addon benutzen. Du musst das Benutzerinterface neu laden um die Änderungen, die du durchgeführt hast, zu sehen."
L["Save"] = "Speichern"
L["Type /hellokitty to revert to old settings."] = "Tippe /hellokitty um die alten Einstellungen zu verwenden."
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = "Wenn du das Heiler Layout benutzt ist es sehr empfohlen das Addon Clique zu downloaden wenn du die Klick-zum-Heilen Funktion haben willst."
L["Yes, Keep Changes!"] = "Ja, Änderungen behalten!"
L["You have changed the pixel perfect option. You will have to complete the installation process to remove any graphical bugs."] = "Du hast die Pixel-Perfekt-Option geändert. Du solltest nun den Installationsprozess beenden um mögliche grafische Fehler zu beseitigen."
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = "Du hast die Skalierung des benutzerinterfaces geändert, während du die automatische Skalierung in ElvUI aktiv hast. Drücke Annehmen um die automatische Skalierung zu deaktivieren."
L["You must purchase a bank slot first!"] = "Du musst erst ein Bankfach kaufen!"

--Tooltip
L["Count"] = "Zähler"
L["Item Level:"] = "Itemlevel"
L["Talent Specialization:"] = "Talentspezialisierung"
L["Targeted By:"] = "Ziel von:"

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = "Ein Feature für Schlachtzugsmarkierung ist verfügbar, wenn du Escape drückst und Tastaturbelegung wählst, scrolle anschließend bis unter die Kategorie ElvUI und wähle eine Tastenbelegung für die Schlachtzugsmarkierung."
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = "ElvUI hat ein Feature für Dualspezialisierungen, welches dich abhängig von deiner momentanen Spezialisierung verschiedene Profile laden lässt. Dieses Feature kannst du im Abschnitt Profil aktivieren."
L["For technical support visit us at http://www.tukui.org."] = "Für technische Hilfe besuche uns unter http://www.tukui.org."
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = "Wenn du ausversehen das Chatfenster entfernen solltest, kannst du ganz einfach in die Ingame-Konfiguration gehen und den Installationsprozess erneut aufrufen. Drücke Installieren und gehe zu den Chateinstellungen und setze diese zurück."
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = "Wenn du Probleme mit ElvUI hast, deaktiviere alle Addons außer ElvUI. Denke auch daran, dass ElvUI die komplette Benutzeroberfläche ersetzt, d.h. du kannst kein Addon verwenden, welches die gleichen Funktionen wie ElvUI nutzt."
L["The buff panel to the right of minimap is a list of your consolidated buffs. You can disable it in Buffs and Debuffs options of ElvUI."] = "Die Stärkungszauberleiste rechts neben der Minimap ist eine Liste der zusammengefassten Stärkungszauber. Du kannst diese in den Stärkungs- und Schwachungszauber-Optionen in ElvUI deaktivieren."
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = "Du kannst, während du ein Ziel hast, das Fokusfenster durch die Eingabe von /fokus setzen. Es wird empfohlen ein Makro dafür zu nutzen."
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = "Um Fähigkeiten auf der Aktionsleiste zu verschieben nutze Shift und bewege zeitgleich die Maus. Du kannst die Modifier-Taste im Aktionsleistenmenü umstellen."
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = "Um einzustellen welcher Kanal im welchem Chatfenster angezeigt werden soll, klicke rechts auf das Chattab und gehe auf Einstellungen."
L["Using the /farmmode <size> command will spawn a larger minimap on your screen that can be moved around, very useful when farming."] = "Benutze das /farmmode <Größe> Kommando um eine größere Minimap auf dem Bildschirm erscheinen zu lassen, die sich verschieben lässt. Sehr nützlich zum Farmen."
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = "Du kannst die Funktionen Chat Kopieren und Chatmenü aufrufen, wenn du die Maus in die obere rechte Ecke des Chatfensters bewegst und links-/rechtsklickst."
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = "Du kannst die durchschnittliche Gegenstandsstufe von jemanden sehen, wenn du bei gedrückter Shift-Taste mit der Maus über ihn fährst. Die Gegenstandsstufe wird dann im Tooltip angezeigt."
L["You can set your keybinds quickly by typing /kb."] = "Du kannst deine Tastaturbelegung schnell ändern, wenn du /kb eintippst."
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = "Du kannst die Mikroleiste durch mittleren Mausklick auf der Minimap aufrufen oder auch die tatsächliche Mikroleiste in den Aktionsleisten Optionen aktivieren."
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = "Du kannst durch benutzen von /resetui alle Ankerpunkte zurücksetzen. Du kannst das Kommando auch benutzen um spezielle Anker zurückzusetzen, /resetui <Anker Name>.\nBeispiel: /resetui Player Frame"

--UnitFrames
L["Ghost"] = "Geist"
L["Offline"] = "Offline"
