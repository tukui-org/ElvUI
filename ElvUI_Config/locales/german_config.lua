-- German localization file for deDE.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "deDE")
if not L then return end

-- *_DESC locales
L["AURAS_DESC"] = 'Konfiguriere die Symbole für die Stärkungs- und Schwächungszauber nahe der Minimap.'
L["BAGS_DESC"] = "Konfiguriere die Einstellungen für die Taschen."
L["CHAT_DESC"] = "Anpassen der Chateinstellungen für ElvUI."
L["DATATEXT_DESC"] = "Bearbeite die Anzeige der Infotexte."
L["ELVUI_DESC"] = "ElvUI ist ein komplettes Benutzerinterface für World of Warcraft."
L["NAMEPLATE_DESC"] = "Konfiguriere die Einstellungen für die Namensplaketten."
L["PANEL_DESC"] = "Stellt die Größe der linken und rechten Leisten ein, dies hat auch Einfluss auf den Chat und die Taschen."
L["SKINS_DESC"] = "Passe die Einstellungen für externe Addon Skins/Optionen an."
L["TOGGLESKIN_DESC"] = "Aktiviere/Deaktiviere diesen Skin."
L["TOOLTIP_DESC"] = "Konfiguriere die Einstellungen für Tooltips."
L["SEARCH_SYNTAX_DESC"] = [=[With the new addition of LibItemSearch, you now have access to much more advanced item searches. The following is a documentation of the search syntax. See the full explanation at: https://github.com/Jaliborc/LibItemSearch-1.2/wiki/Search-Syntax.

Specific Searching:
    • q:[quality] or quality:[quality]. For instance, q:epic will find all epic items.
    • l:[level], lvl:[level] or level:[level]. For example, l:30 will find all items with level 30.
    • t:[search], type:[search] or slot:[search]. For instance, t:weapon will find all weapons.
    • n:[name] or name:[name]. For instance, typing n:muffins will find all items with names containing "muffins".
    • s:[set] or set:[set]. For example, s:fire will find all items in equipment sets you have with names that start with fire.
    • tt:[search], tip:[search] or tooltip:[search]. For instance, tt:binds will find all items that can be bound to account, on equip, or on pickup.


Search Operators:
    • ! : Negates a search. For example, !q:epic will find all items that are NOT epic.
    • | : Joins two searches. Typing q:epic | t:weapon will find all items that are either epic OR weapons.
    • & : Intersects two searches. For instance, q:epic & t:weapon will find all items that are epic AND weapons
    • >, <, <=, => : Performs comparisons on numerical searches. For example, typing lvl: >30 will find all items with level HIGHER than 30.


The following search keywords can also be used:
    • soulbound, bound, bop : Bind on pickup items.
    • bou : Bind on use items.
    • boe : Bind on equip items.
    • boa : Bind on account items.
    • quest : Quest bound items.]=];
L["TEXT_FORMAT_DESC"] = [=[Wähle eine Zeichenfolge um das Textformat zu ändern.

Beispiele:
[namecolor][name] [difficultycolor][smartlevel] [shortclassification]
[healthcolor][health:current-max]
[powercolor][power:current]

Leben / Kraft Formate:
'current' - Aktueller Wert
'percent' - Prozentualer Wert
'current-max' - Aktueller Wert gefolgt von dem maximalen Wert. Es wird nur der Maximale Wert anzeigt, wenn der aktuelle Wert auch das Maximum ist
'current-percent' - Aktueller Wert gefolgt von dem prozentualen Wert. Es wird nur der maximale Wert angezeigt, wenn der aktuelle Wert auch das Maximum ist
'current-max-percent' - Aktueller Wert, Maximaler Wert, gefolgt von dem prozentualen Wert. Es wird nur der maximale Wert angezeigt, wenn der aktuelle Wert auch das Maximum ist
'deficit' - Zeigt das Defizit. Es wird nichts angezeigt, wenn kein Defizit vorhanden ist

Namensformate:
'name-short' - Name auf 10 Zeichen beschränkt
'name-medium' - Name auf 15 Zeichen beschränkt
'name-long' - Name auf 20 Zeichen beschränkt

Zum Deaktvieren lasse das Feld leer. Brauchst du mehr Informationen besuche http://www.tukui.org]=];

--ActionBars
L["Action Paging"] = "Seitenwechsel der Aktionsleisten"
L["ActionBars"] = "Aktionsleisten"
L["Alpha"] = 'Alpha'
L["Anchor Point"] = "Ankerpunkt" --also in unitframes
L["Backdrop"] = "Hintergrund"
L["Button Size"] = "Größe der Buttons" --Also used in Bags
L["Button Spacing"] = "Abstand der Buttons" --Also used in Bags
L["Buttons Per Row"] = "Aktionsbuttons pro Zeile"
L["Buttons"] = "Buttons"
L["Change the alpha level of the frame."] = 'Ändere den Alphakanal des Fensters.'
L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."] = 'Die Farbe der Aktionsbuttons, wenn keine Kraft, wie z.B. Mana, Wut, Fokus oder Heilige Kraft, mehr vorhanden ist.'
L["Color of the actionbutton when out of range."] = 'Die Farbe der Aktionsbuttons, wenn das Ziel außer Reichweite ist.'
L["Color when the text is about to expire"] = "Färbe den Text in dieser Farbe, wenn er in Kürze abläuft."
L["Color when the text is in the days format."] = "Färbe den Text in dieser Farbe, wenn er Tagen angezeigt wird."
L["Color when the text is in the hours format."] = "Färbe den Text in dieser Farbe, wenn er in Stunden angezeigt wird."
L["Color when the text is in the minutes format."] = "Färbe den Text in dieser Farbe, wenn er sich im Minutenformat angezeigt wird."
L["Color when the text is in the seconds format."] = "Färbe den Text in dieser Farbe, wenn er in Sekunden angezeigt wird."
L["Cooldown Text"] = "Abklingzeittext"
L["Darken Inactive"] = "Inaktives verdunkeln"
L["Days"] = "Tage"
L["Display bind names on action buttons."] = "Zeige Tastaturbelegungen auf der Aktionsleiste an."
L["Display cooldown text on anything with the cooldown spiral."] = "Zeige die Abklingzeit auf allen Tasten mit Hilfe iner animierten Spirale."
L["Display macro names on action buttons."] = "Zeige Makronamen auf der Aktionsleiste an."
L["Expiring"] = "Auslaufend"
L["Height Multiplier"] = "Höhenmultiplikator"
L["Hours"] = "Stunden"
L["Key Down"] = 'Aktion bei Tastendruck'
L["Keybind Mode"] = "Tastaturbelegung"
L["Keybind Text"] = "Tastaturbelegungstext"
L["Low Threshold"] = "Niedrige CD-Schwelle"
L["Macro Text"] = "Makrotext"
L["Minutes"] = "Minuten"
L["Mouse Over"] = "Mouseover" --Also used in Bags
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "Multipliziere die Höhe und die Breite des Hintergrundes. Das ist nützlich, wenn du mehr als eine Leiste hinter einem Hintergrund haben möchtest."
L["Out of Power"] = 'Keine Kraft'
L["Out of Range"] = 'Außer Reichweite'
L["Restore Bar"] = "Leiste zurücksetzen"
L["Restore the actionbars default settings"] = "Wiederherstellung der vordefinierten Aktionsleisteneinstellung"
L["Seconds"] = "Sekunden"
L["The amount of buttons to display per row."] = "Anzahl der Aktionsbuttons in einer Reihe."
L["The amount of buttons to display."] = "Anzahl der angezeigten Aktionsbuttons."
L["The button you must hold down in order to drag an ability to another action button."] = 'Die Taste, die du gedrückt halten musst, um eine Fähigkeit zu einer anderen Aktionstaste zu ziehen.'
L["The first button anchors itself to this point on the bar."] = "Der erste Aktionsbutton dockt an diesen Punkt in der Leiste an."
L["The size of the action buttons."] = "Die Größe der Aktionsbuttons."
L["This setting will be updated upon changing stances."] = "Diese Einstellungen werden bei Gestaltwandel aktualisiert"
L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"] = "CD-Schwelle bevor der Text rot wird. Setze diesen Wert auf -1, wenn er nie rot werden soll"
L["Toggles the display of the actionbars backdrop."] = "Aktiviere den Hintergrund der Aktionsleisten."
L["Visibility State"] = "Sichbarkeitszustand"
L["Width Multiplier"] = "Breitenmultiplikator"
L[ [=[This works like a macro, you can run different situations to get the actionbar to page differently.
Example: '[combat] 2;']=] ] = "Dies funktioniert wie ein Makro. Du kannst verschiedene Situationen haben um die Aktionsleiste anzuzeigen und zu verbergen.\n Beispiel: '[combat] show;hide'"
L[ [=[This works like a macro, you can run different situations to get the actionbar to show/hide differently.
Example: '[combat] show;hide']=] ] = "Dies funktioniert wie ein Makro, du kannst verschiedene Situationen haben um die Aktionsleiste zu ändern.\n Beispiel: '[combat] 2;'"

--Bags
L["Adjust the width of the bag frame."] = 'Passe die Breite des Taschenfensters an.'
L["Adjust the width of the bank frame."] = 'Passe die Breite des Bankfensters an.'
L["Align the width of the bag frame to fit inside the chat box."] = 'Passt die Breite der Taschenfenster an, damit diese innerhalb des Chatfensters passen.'
L["Align To Chat"] = 'Zum Chat ausrichten'
L["Ascending"] = "Aufsteigend"
L["Bag-Bar"] = "Taschenleiste"
L["Bar Direction"] = "Ausrichtung Leiste"
L["Blizzard Style"] = 'Blizzard Stil'
L["Bottom to Top"] = "Von unten nach oben"
L["Button Size (Bag)"] = 'Buttongröße (Tasche)'
L["Button Size (Bank)"] = 'Buttongröße (Bank)'
L["Condensed"] = 'Gekürzt'
L["Currency Format"] = 'Währungsformat'
L["Descending"] = "Absteigend"
L["Direction the bag sorting will use to allocate the items."] = "Die Richtung, in welche die Gegenstände in den Taschen sortiert werden."
L["Enable/Disable the all-in-one bag."] = "Einschalten/Ausschalten der zusammengefassten Tasche."
L["Enable/Disable the Bag-Bar."] = "Aktiviere/Deaktiviere die Taschenleiste."
L["Full"] = 'Voll'
L["Icons and Text"] = "Symbole und Text"
L["Ignore Items"] = 'Ignoriere Items'
L["List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma."] = 'Liste von Items die beim sortieren ignoriert werden. Wenn du willst kannst du auch mehrere Items hinzufügen du musst nur nachdem Wort ein Komma setzen.'
L["Money Format"] = 'Geldformat'
L["Panel Width (Bags)"] = 'Leistenbreite (Taschen)'
L["Panel Width (Bank)"] = 'Leistenbreite (Bank)'
L["Search Syntax"] = "Suchsyntax"
L["Set the size of your bag buttons."] = "Setze die Größe der Taschenbuttons."
L["Short (Whole Numbers)"] = 'Kurz (ganze Zahlen)'
L["Short"] = 'Kurz'
L["Show Coins"] = 'Währungssymbole anzeigen'
L["Smart"] = 'Elegant'
L["Sort Direction"] = "Sortierrichtung" --Also used in Buffs and Debuffs
L["Sort Inverted"] = 'Umgekehrtes sortieren'
L["The direction that the bag frames be (Horizontal or Vertical)."] = "Die Ausrichtung der Leiste (Horizontal oder Vertikal)."
L["The direction that the bag frames will grow from the anchor."] = "Die Richtung in welche das Fenster vom Ankerpunkt aus wächst (Horizontal oder Vertikal)."
L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"] = 'Das Anzeigeformat für die Währungssymbole, welche unter der Haupttasche angezeigt werden. (Du musst eine Währung beobachten, damit diese angezeigt wird)'
L["The display format of the money text that is shown at the top of the main bag."] = 'Das Anzeigeformat für Gold oben an der Haupttasche.'
L["The frame is not shown unless you mouse over the frame."] = "Das Fenster ist nicht sichtbar, außer man bewegt die Maus darüber."
L["The size of the individual buttons on the bag frame."] = 'Die Größe der einzelnen Buttons auf dem Taschenfenster.'
L["The size of the individual buttons on the bank frame."] = 'Die Größe der einzelnen Buttons auf dem Bankfenster.'
L["The spacing between buttons."] = "Der Abstand zwischen den Taschenbuttons."
L["Top to Bottom"] = "Von oben nach unten"
L["Use coin icons instead of colored text."] = 'Benutze Währungssymbole anstatt von farbigem Text.'
L["X Offset Bags"] = 'X-Versatz Taschen'
L["X Offset Bank"] = 'X-Versatz Bank'
L["Y Offset Bags"] = 'Y-Versatz Taschen'
L["Y Offset Bank"] = 'Y-Versatz Bank'

--Buffs and Debuffs
L["Begin a new row or column after this many auras."] = 'Beginne nach so vielen Stärkungszaubern eine neue Reihe oder Spalte.'
L["Consolidated Buffs"] = 'Zusammengesetzte Stärkungszauber'
L["Count xOffset"] = 'Den Versatz auf der X-Achse zählen'
L["Count yOffset"] = 'Den Versatz auf der Y-Achse zählen'
L["Defines how the group is sorted."] = 'Lege fest, wie die Gruppe sortiert wird.'
L["Defines the sort order of the selected sort method."] = 'Legt die Sortierreihenfolge der ausgewählten Sortiermethode fest.'
L["Disabled Blizzard"] = "Blizzard deaktivieren"
L["Display the consolidated buffs bar."] = 'Zeige die zusammengesetzte Stärkungszauberleiste.'
L["Fade Threshold"] = "Zeit bis zum verblassen"
L["Filter Consolidated"] = 'Nur nützliche Stärkungszauber'
L["Index"] = 'Index'
L["Indicate whether buffs you cast yourself should be separated before or after."] = 'Wenn du einen Stärkungszauber auf dich selber wirkst, zeige diesen zuerst in der Leiste.'
L["Limit the number of rows or columns."] = 'Beschränkung für die Anzahl an Leisten oder Spalten.'
L["Max Wraps"] = 'Maximale Leisten'
L["No Sorting"] = 'Nicht Sortieren'
L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."] = 'Zeige nur zusammengesetzte Symbole auf der zusammengesetzten Leiste die deine Klasse/Spezialisierung interessieren. Das ist hilfreich für die Schlachtzugsleitung.'
L["Other's First"] = "Andere zuerst"
L["Remaining Time"] = 'Verbleibende Zeit anzeigen'
L["Reverse Style"] = "Stil umkehren"
L["Seperate"] = 'Seperat'
L["Set the size of the individual auras."] = 'Lege die Größe der individuellen Stärkungszauber fest.'
L["Sort Method"] = 'Sortiermethode'
L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."] = 'Die Richtung, die Aura wird wachsen wird und dann die Richtung dei Sie wachsen wird, nachdem sie die Grenze nach Wrap erreichen.'
L["Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable."] = 'Die Schwelle bevor der Text rot und das Symbol verblassen wird (in Dezimalform). Setze sie auf -1 um die Schwelle zu deaktivieren.'
L["Time xOffset"] = "Zeit X-Versatz"
L["Time yOffset"] = "Zeit Y-Versatz"
L["Time"] = 'Zeit'
L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."] = "Wenn diese Option aktiviert wird, leuchten die Symbole für aktive Stärkungszauber auf und inaktive Stärkungszauber werden dunkler. Ansonsten leuchten die Symbole für inaktive Stärkungszauber auf und aktive Stärkungszauber werden dunkler."
L["Wrap After"] = 'Neue Reihe/Spalte beginnen'
L["Your Auras First"] = 'Deine Auren zuerst'

--Chat
L["Above Chat"] = 'Über dem Chat'
L["Adjust the height of your right chat panel."] = 'Passe die Höhe des rechten Chatfensters an.'
L["Adjust the width of your right chat panel."] = 'Passe die Breite des rechten Chatfensters an.'
L["Alerts"] = 'Alarme'
L["Attempt to create URL links inside the chat."] = "Eine Möglichkeit um Internet-Links im Chat anzuzeigen."
L["Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish."] = 'Fixiere das rechte und linke Chatfenster. Deaktiviere diese Option um das Hauptchatfenster nach Belieben zu verschieben.'
L["Below Chat"] = 'Unter dem Chat'
L["Chat EditBox Position"] = 'Position der Texteingabeleiste'
L["Chat History"] = 'Chatverlauf'
L["Copy Text"] = "Text kopieren"
L["Display LFG Icons in group chat."] = "LFG Symbole im Gruppenchat anzeigen"
L["Display the hyperlink tooltip while hovering over a hyperlink."] = "Zeigt den Hyperlink Tooltip beim Überfahren eines Hyperlinks."
L["Enable the use of separate size options for the right chat panel."] = 'Benutze getrennte Größenoptionen für das rechte Chatfenster.'
L["Fade Chat"] = 'Chat Verblassen'
L["Fade the chat text when there is no activity."] = 'Lässt den Chat Text verblassen, wenn keine Aktivität besteht.'
L["Font Outline"] = "Kontur der Schriftart" --Also used in UnitFrames section
L["Font"] = "Schriftart"
L["Hide Both"] = "Verstecke Beide"
L["Hyperlink Hover"] = "Hyperlink Hover"
L["Keyword Alert"] = "Stichwort Alarm"
L["Keywords"] = 'Stichwort'
L["Left Only"] = "Nur Links"
L["LFG Icons"] = 'LFG Symbole'
L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"] = 'Liste der Wörter die farblich im Chat erscheinen, wenn sie in einer Nachricht gefunden werden. Wenn du möchtest, kannst du mehrere Wörter hinzufügen. Diese müssen durch ein Komma getrennt werden. Um deinen momentanen Namen zu suchen, benutze %MYNAME%.\n\nBeispiel:\n%MYNAME%, ElvUI, RBGs, Tank'
L["Lock Positions"] = 'Positionen fixieren'
L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."] = 'Sichert den Chatverlauf der Hauptchatfenster. Wenn du dein UI neulädst oder einloggst, siehst du den Chatverlauf der letzten Sitzung.'
L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."] = "Anzahl der Sekunden um im Chatfenster nach unten zu scrollen, wenn du nicht komplett nach unten gescrollt bist."
L["Panel Backdrop"] = "Fensterhintergrund"
L["Panel Height"] = "Fensterhöhe"
L["Panel Texture (Left)"] = "Fenstertextur (Links)"
L["Panel Texture (Right)"] = "Fenstertextur (Rechts)"
L["Panel Width"] = "Leistenbreite"
L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."] = 'Position der Texteingabeleiste. Sind die Infotexte deaktiviert, dann wird diese über dem Chat angebracht.'
L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."] = "Verhindert, dass die gleiche Nachricht im Chat mehr als einmal, innerhalb dieser festgelegten Anzahl von Sekunden, angezeigt wird. Auf Null setzen um diese Option zu deaktivieren."
L["Right Only"] = "Nur Rechts"
L["Right Panel Height"] = 'Rechte Fensterhöhe'
L["Right Panel Width"] = 'Rechte Fensterbreite'
L["Scroll Interval"] = "Scroll-Interval"
L["Separate Panel Sizes"] = 'Getrennte Chatfenster Größenoptionen'
L["Set the font outline."] = "Setzt die Schrift auf Outline." --Also used in UnitFrames section
L["Short Channels"] = "Kurze Kanäle"
L["Shorten the channel names in chat."] = "Kürze Kanalnamen im Chat."
L["Show Both"] = "Zeige Beide"
L["Spam Interval"] = "Spam-Interval"
L["Sticky Chat"] = "Kanal merken"
L["Tab Font Outline"] = "Tab Schriftkontur"
L["Tab Font Size"] = "Tab Schriftgröße"
L["Tab Font"] = "Tab Schriftart"
L["Tab Panel Transparency"] = 'Tableisten Transparenz'
L["Tab Panel"] = "Tableiste anzeigen"
L["Toggle showing of the left and right chat panels."] = "Aktiviere den Hintergrund des linken und rechten Chatfensters"
L["Toggle the chat tab panel backdrop."] = "Aktiviere den Hintergrund der oberen Tableisten der Chatfenster"
L["URL Links"] = "URL Links"
L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."] = "Beim Öffnen der Texteingabeleiste wird dem Kanal beigetreten, in den zu letzt geschrieben wurde. Wenn diese Option deaktiviert ist, wird standardmäßig der SAGEN-Kanal beim öffnen der Texteingabeleiste aufgerufen."
L["Whisper Alert"] = "Flüster Alarm"
L[ [=[Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.

Please Note:
-The image size recommended is 256x128
-You must do a complete game restart after adding a file to the folder.
-The file type must be tga format.

Example: Interface\AddOns\ElvUI\media\textures\copy

Or for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.]=] ] = [=[Gib einen Dateinamen im World of Warcraft Verzeichnis an. Textures Ordner, den du als Fensterhintergrund eingestellt haben willst.

Bitte beachten:
-Als Bildgröße 256x128 wird empfohlen.
-Du musst das Spiel komplett neu starten, nachdem du die Datei hinzugefügt hast.
-Der Dateityp muss im Format tga sein.

Zum Beispiel: Interface\AddOns\ElvUI\media\textures\copy

Für die meisten Anwender ist es allerdigns einfacher, eine tga-Datei in ihren WoW-Ordner abzulegen. Anschließend kann man den Namen der Datei hier eingeben.]=]

--Credits
L["Coding:"] = "Programmierung:"
L["Credits"] = "Danksagung"
L["Donations:"] = "Spenden:"
L["ELVUI_CREDITS"] = "Ich möchte mich hier bei folgenden Personen bedanken, die durch ihre tatkräftige Unterstützung beim Testen und Coden, sowie durch Spenden, sehr geholfen haben. Bitte beachten: Für Spenden poste ich nur die Namen, die mich im Forum via PM angeschrieben haben. Sollte dein Name fehlen und du möchtest deinen Namen hinzugefügt haben, schreib mir bitte eine PM im Forum."
L["Testing:"] = "Tester:"

--DataTexts
L["24-Hour Time"] = "24-Stunden-Format"
L["Battleground Texts"] = 'Schlachtfeld-Infotexte'
L["Change settings for the display of the location text that is on the minimap."] = 'Ändere die Einstellungen für die Anzeige des Umgebungstextes an der Minimap.'
L["Datatext Panel (Left)"] = 'Infotextleiste (Links)'
L["Datatext Panel (Right)"] = 'Infotextleiste (Rechts)'
L["DataTexts"] = "Infotexte"
L["Display data panels below the chat, used for datatexts."] = 'Zeige die Infoleisten unter dem Chat, benutzt für Infotexte.'
L["Display minimap panels below the minimap, used for datatexts."] = 'Zeige Minimap Leisten unter der Minimap, benutzt für Infotexte.'
L["Gold Format"] = 'Gold-Format'
L["If not set to true then the server time will be displayed instead."] = "Wenn nicht ausgewählt, wird stattdessen die Serverzeit angezeigt."
L["left"] = "Links"
L["LeftChatDataPanel"] = "Linker Chat"
L["LeftMiniPanel"] = "Minimap Links"
L["Local Time"] = "Lokale Zeit"
L["middle"] = "Mitte"
L["Minimap Panels"] = 'Minimap Leisten'
L["Panel Transparency"] = 'Panel Transparenz'
L["Panels"] = "Leisten"
L["right"] = "Rechts"
L["RightChatDataPanel"] = "Rechter Chat"
L["RightMiniPanel"] = "Minimap Rechts"
L["The display format of the money text that is shown in the gold datatext and its tooltip."] = 'Das Anzeigeformat für Gold in den Haupt-Infoleisten und Tooltips.'
L["Toggle 24-hour mode for the time datatext."] = "Wählt das 24-Stunden-Format für den Zeit-Infotext."
L["When inside a battleground display personal scoreboard information on the main datatext bars."] = 'Zeige innerhalb eines Schlachtfeldes persönliche Statistiken in den Haupt-Infoleisten.'

--Distributor
L["Must be in group with the player if he isn't on the same server as you."] = "Du musst mit dem Spieler in einer Gruppe sein wenn dieser nicht auf deinem Server ist wie du."
L["Sends your current profile to your target."] = "Sende dein momentanes Profil an dein Ziel."
L["Sends your filter settings to your target."] = "Sende deine Filter Einstellungen an dein Ziel."
L["Share Current Profile"] = "Teile das momentane Profil"
L["Share Filters"] = "Teile Filter"
L["This feature will allow you to transfer, settings to other characters."] = "Dieses Feature erlaubt es dir, Einstellungen an andere Charaktere zu schicken."
L["You must be targeting a player."] = "Du musst einen Spieler anvisiert haben."

--General
L["Accept Invites"] = "Einladungen akzeptieren"
L["Adjust the position of the threat bar to either the left or right datatext panels."] = 'Bestimme die Position der Bedrohungsleiste in den rechten oder linken Infotextleisten.'
L["Adjust the size of the minimap."] = 'Stelle die Größe der Minimap ein.'
L["AFK Mode"] = 'AFK Modus'
L["Announce Interrupts"] = "Unterbrechungen ankündigen"
L["Announce when you interrupt a spell to the specified chat channel."] = "Melde über den angegebenen Chatkanal einen unterbrochenen Zauber."
L["Attempt to support eyefinity/nvidia surround."] = "Versucht Eyefinity/NVIDIA Surround zu unterstützen"
L["Auto Greed/DE"] = 'Auto-Gier/DE'
L["Auto Repair"] = "Auto-Reparatur"
L["Auto Scale"] = "Auto-Skalierung"
L["Auto"] = true;
L["Automatically accept invites from guild/friends."] = "Automatisch Einladungen von Gildenmitgliedern/Freunden akzeptieren"
L["Automatically repair using the following method when visiting a merchant."] = "Repariere automatisch deine Ausrüstungsgegenstände, wenn du eine der folgenden Methoden auswählst."
L["Automatically scale the User Interface based on your screen resolution"] = "Automatische Skalierung des Interfaces, angepasst an deine Bildschirmeinstellung"
L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."] = 'Automatisch Gier oder Entzauberung auf Gegenstände von grüner Qualität wählen (sofern verfügbar). Das funktioniert nur, wenn du die maximale Stufe erreicht hast.'
L["Automatically vendor gray items when visiting a vendor."] = "Automatischer Verkauf von grauen Gegenständen bei einem Händlerbesuch."
L["Bonus Reward Position"] = "Bonusbeute Position"
L["Bottom Panel"] = 'Untere Leiste'
L["Chat Bubbles Style"] = 'Chat-Blasen Stil'
L["Direction the bar moves on gains/losses"] = "Richtung in die der Balken wächst/sinkt"
L["Display a panel across the bottom of the screen. This is for cosmetic only."] = 'Zeige eine Leiste am unterem Bildschirmrand. Das ist rein kosmetisch.'
L["Display a panel across the top of the screen. This is for cosmetic only."] = 'Zeige eine Leiste am oberen Bildschirmrand. Das ist rein kosmetisch.'
L["Display emotion icons in chat."] = 'Zeige Emoticons im Chat.'
L["Emotion Icons"] = 'Emoticons'
L["Enable/Disable the loot frame."] = "Aktiviere/Deaktiviere das Beutefenster."
L["Enable/Disable the loot roll frame."] = "Aktiviere/Deaktiviere das Beutewürfelfenster."
L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"] = 'Aktiviere/Deaktiviere die Minimap. |cffFF0000Warnung: Durch diese Einstellung wird verhindert, dass die zusammengefassten Stärkungszauber, sowie die Infotextleisten, an der Minimap angezeigt werden.|r'
L["General"] = "Allgemein"
L["Height of the objective tracker. Increase size to be able to see more objectives."] = "Höhe des Questfenster. Größe verändern um mehr Ziele zu sehen."
L["Hide Error Text"] = "Fehlertext verstecken"
L["Hides the red error text at the top of the screen while in combat."] = "Den roten Fehlertext im oberen Teil des Bildschirms im Kampf verstecken"
L["Log Taints"] = "Log Fehler"
L["Login Message"] = "Login Nachricht"
L["Loot Roll"] = "Würfelfenster"
L["Loot"] = "Beute"
L["Make the world map smaller."] = "Macht die Weltkarte kleiner."
L["Multi-Monitor Support"] = "Multi-Monitor-Unterstützung"
L["Name Font"] = "Schriftart von Spielernamen"
L["Objective Frame Height"] = "Questfenster Höhe"
L["Position of bonus quest reward frame relative to the objective tracker."] = "Position vom Bonusbeute Fenster, relativ zum Questfenster."
L["Remove Backdrop"] = "Hintergrund entfernen"
L["Reset all frames to their original positions."] = "Setze alle Einheiten an ihre ursprüngliche Position zurück."
L["Reset Anchors"] = "Ankerpunkte zurücksetzen"
L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."] = "Sende ADDON_ACTION_BLOCKED Fehler zum Lua-Fehlerfenster. Diese Fehler sind weniger wichtig und werden deine Spielleistung nicht beeinflussen. Viele dieser Fehler können nicht beseitigt werden. Bitte melde diese Fehler nur, wenn es einen Defekt im Spiel verursacht."
L["Skin Backdrop"] = "Skin für den Hintergrund"
L["Skin the blizzard chat bubbles."] = "Skin die Blizzard Chat Sprechblasen."
L["Smaller World Map"] = "Kleinere Weltkarte"
L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "Die Schrift, die über den Köpfen der Spieler auftaucht. |cffFF0000WARNUNG: Das benötigt einen Neustart des Spiels oder einen Relog um in Effekt zu treten.|r"
L["Toggle Tutorials"] = 'Tutorial starten'
L["Top Panel"] = 'Obere Leiste'
L["When you go AFK display the AFK screen."] = 'AFK Bildschirm anzeigen wenn du AFK bist.'

--Media
L["Backdrop color of transparent frames"] = "Hintergrundfarbe von transparenten Fenstern"
L["Backdrop Color"] = "Hintergrundfarbe"
L["Backdrop Faded Color"] = "Transparente Hintergrundfarbe"
L["Border Color"] = "Rahmenfarbe"
L["Color some texts use."] = "Allgemeine Farbe der meisten Texte"
L["Colors"] = "Farben" --Also used in UnitFrames
L["CombatText Font"] = "Schriftart vom Kampftext"
L["Default Font"] = "Allgemeine Schriftart"
L["Font Size"] = "Schriftgröße" --Also used in UnitFrames
L["Fonts"] = "Schrift"
L["Main backdrop color of the UI."] = "Allgemeine Hintergrundfarbe der Benutzeroberfläche."
L["Main border color of the UI. |cffFF0000This is disabled if you are using the pixel perfect theme.|r"] = "Die Hauptfarbe des UI |cffFF0000ist deaktiviert, wenn du Pixel Perfekt aktiviert hast"
L["Media"] = "Medien"
L["Primary Texture"] = "Primäre Textur"
L["Replace Blizzard Fonts"] = 'Blizzard Schriftarten überschreiben'
L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."] = 'Ersetzt die Standard Blizzard Schriftarten in verschiedenen Fenstern und Leisten mit den im Medienbereich des ElvUI Config gewählten Schriftenarten. (NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this.) Standardmäßig aktiviert.'
L["Secondary Texture"] = "Sekundäre Textur"
L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "Setze die Größe für die Schriftart der gesamten Benutzeroberfläche fest. Notiz: Dies hat keinen Einfluss auf Optionen, die ihre eigenen Einstellungen haben (Einheitenfenster Schrift, Infotext Schrift, ect..)"
L["Textures"] = "Texturen"
L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "Die Schriftart des Kampftextes. |cffFF0000WARNUNG: Nach der änderung dieser Option muss das Spiel neu gestartet werden.|r"
L["The font that the core of the UI will use."] = "Die Schriftart, die hauptsächlich vom UI verwendet wird."
L["The texture that will be used mainly for statusbars."] = "Diese Textur wird vorallem für Statusbars verwendet."
L["This texture will get used on objects like chat windows and dropdown menus."] = "Diese Textur wird für Objekte wie Chatfenster und Dropdown-Menüs benutzt."
L["Value Color"] = "Farbwert"

--Minimap
L["Always Display"] = 'Immer anzeigen'
L["Bottom Left"] = 'Unten links'
L["Bottom Right"] = 'Unten rechts'
L["Bottom"] = 'Unten'
L["Instance Difficulty"] = "Instanz Schwierigkeitsgrad"
L["Left"] = 'Links'
L["LFG Queue"] = "LFG Warteschlange"
L["Location Text"] = 'Umgebungstext'
L["Minimap Buttons"] = 'Minimap Buttons'
L["Minimap Mouseover"] = 'Minimap Mouseover'
L["Right"] = 'Rechts'
L["Scale"] = 'Skalierung'
L["Top Left"] = 'Oben links'
L["Top Right"] = 'Oben rechts'
L["Top"] = 'Oben'

--Misc
L["Enable"] = "Eingeschaltet"
L["Install"] = "Installation"
L["Run the installation process."] = "Startet den Installationsprozess."
L["Toggle Anchors"] = "Ankerpunkte umschalten"
L["Unlock various elements of the UI to be repositioned."] = "Schalte verschiedene Elemente der Benutzeroberfläche frei um sie neu zu positionieren."
L["Version"] = "Version"

--NamePlates
L["Add Name"] = "Name hinzufügen"
L["Adjust nameplate size on low health"] = "Verändere größe der Namensplaketten bei niedriger Gesundheit"
L["Adjust nameplate size on smaller mobs to scale down. This will only adjust the health bar width not the actual nameplate hitbox you click on."] = "Verkleinert die Namensplaketten bei kleineren Monstern. Dies verringert nur die sichtbare Breite der Gesundheitsleiste und nicht die Hitbox auf die du klickst."
L["All"] = "Alle"
L["Alpha of nameplates that are not your current target."] = 'Alpha von Namensschildern, die nicht das aktuelle Ziel sind.'
L["Always display your personal auras over the nameplate."] = "Zeige nur deine persönlichen Auren auf den Namensplaketten."
L["Bad Transition"] = "Schlechter Übergang"
L["Bring nameplate to front on low health"] = "Namensplaketten bei niedriger Gesundheit hervorheben"
L["Bring to front on low health"] = "Hervorheben bei niedriger Gesundheit"
L["Can Interrupt"] = "Kann unterbrechen"
L["Cast Bar"] = "Zauberleiste"
L["Castbar Height"] = "Zauberleistenhöhe"
L["Change color on low health"] = "Farbe ändern bei niedriger Gesundheit"
L["Color By Healthbar"]  = 'Farbe der Gesundheitsbar'
L["Color Name By Health Value"] = 'Farbnamen nach Gesundheitswert'
L["Color on low health"] = "Farbe bei niedriger Gesundheit"
L["Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value."] = 'Färbe den Rand der Namensplaketten gelb, wenn ein Schwelle erreicht wird. Der Rand wird Rot wurde die Hälfte dieses Wertes erreicht.'
L["Combat Toggle"] = "Im Kampf umschalten"
L["Combo Points"] = "Combopunkte"
L["Configure Selected Filter"] = 'Konfiguriere den ausgewählten Filter'
L["Controls the height of the nameplate on low health"] = "Kontrolliert die Höhe der Namensplaketten bei niedriger Gesundheit"
L["Controls the height of the nameplate"] = "Kontrolliert die Höhe der Namensplaketten"
L["Controls the width of the nameplate on low health"] = "Kontrolliert die Breite der Namensplaketten bei niedriger Gesundheit"
L["Controls the width of the nameplate"] = "Kontrolliert die Breite der Namensplaketten"
L["Custom Color"] = "Benutzerdefinierte Farbe"
L["Custom Scale"] = "Benutzerdefinierte Skalierung"
L["Disable threat coloring for this plate and use the custom color."] = "Deaktiviere Bedrohungsfärbung und benutze eine benutzerdefinierte Farbe."
L["Display a healer icon over known healers inside battlegrounds or arenas."] = "Zeige auf Schlachtfeldern oder in Arenen ein Heilersymbol über Heilern an."
L["Display combo points on nameplates."] = "Zeige Combopunkte auf den Namensplaketten an."
L["Enemy"] = "Gegner" --Also used in UnitFrames
L["Filter already exists!"] = "Filter existiert bereits!"
L["Filters"] = "Filter" --Also used in UnitFrames
L["Friendly NPC"] = "Freundlicher NPC"
L["Friendly Player"] = "Freundlicher Spieler"
L["Good Transition"] = "Guter Übergang"
L["Healer Icon"] = "Heilersymbol"
L["Hide"] = "Verstecken" --Also used in DataTexts
L["Horrizontal Arrows (Inverted)"] = "Horizontale Pfeile (invertiert)"
L["Horrizontal Arrows"] = "Horizontale Pfeile"
L["Low Health Threshold"] = 'Niedrige Lebensbedrohung'
L["Low HP Height"] = "Niedrige HP Höhe"
L["Low HP Width"] = "Niedrige HP Breite"
L["Match the color of the healthbar."] = "Die Farbe der Lebensleiste angleichen"
L["NamePlates"] = "Namensplaketten"
L["No Interrupt"] = 'Kein Unterbrechen'
L["Non-Target Alpha"] = 'Nicht-Ziel Alpha'
L["Number of Auras"] = "Nummer der Auren"
L["Prevent any nameplate with this unit name from showing."] = "Verstecke alle Namensplaketten mit diesem Namen."
L["Raid/Healer Icon"] = "Raid/Heiler Icon"
L["Reaction Coloring"] = "Färbung nach Reaktion"
L["Remove Name"] = "Name entfernen"
L["Scale if Low Health"] = "Skaliere bei niedriger Gesundheit"
L["Scaling"] = "Skalierung"
L["Set the scale of the nameplate."] = "Bestimme die Skalierung der Namensplaketten."
L["Show Level"] = 'Stufe anzeigen'
L["Show Name"] = 'Name anzeigen'
L["Show Personal Auras"] = "Persönliche Auren anzeigen"
L["Small Plates"] = "Kleine Namensplaketten"
L["Stretch Texture"] = "Textur strecken"
L["Stretch the icon texture, intended for icons that don't have the same width/height."] = "Textur des Icons für Icons die nicht die gleiche Breite/Höhe haben strecken"
L["Tagged NPC"] = 'Ausgewählter NPC'
L["Target Indicator"] = "Ziel Indikator"
L["Threat"] = "Bedrohung"
L["Toggle the nameplates to be visible outside of combat and visible inside combat."] = 'Schalten Sie die Namensschilder außerhalb und innerhalb des Kampfs sichtbar.'
L["Use this filter."] = "Benutze diesen Filter"
L["Vertical Arrow"] ="Vertikaler Pfeil"
L["Wrap Name"] = "Zeilenumbruch"
L["Wraps name instead of truncating it."] = "Zeilenumbruch anstatt zu kürzen."
L["X-Offset"] = "X-Versatz"
L["Y-Offset"] = "Y-Versatz"
L["You can't remove a default name from the filter, disabling the name."] = "Du kannst keinen Standardnamen entfernen, schalte den Namen aus."

--Skins
L["Achievement Frame"] = "Erfolgsfenster"
L["Alert Frames"] = 'Alarmfenster'
L["Archaeology Frame"] = "Archäologiefenster"
L["Auction Frame"] = "Auktionsfenster"
L["Barbershop Frame"] = "Barbier Fenster"
L["BG Map"] = "Schlachtfeldkarte"
L["BG Score"] = "Schlachtfeldpunkte"
L["Black Market AH"] = 'Schwarzmarkt Auktionshaus'
L["Calendar Frame"] = "Kalender Fenster"
L["Character Frame"] = "Charakterfenster"
L["Death Recap"] = "Todesursache"
L["Debug Tools"] = "Debug Tools"
L["Dressing Room"] = "Ankleideraum"
L["Encounter Journal"] = "Dungeonkompendium"
L["Glyph Frame"] = "Glyphenfenster"
L["Gossip Frame"] = "Chatfenster"
L["Greeting Frame"] = "Begrüßungsfenster"
L["Guild Bank"] = "Gildenbank"
L["Guild Control Frame"] = "Gildenkontrollfenster"
L["Guild Frame"] = "Gildenfenster"
L["Guild Registrar"] = "Gildenregister"
L["Help Frame"] = "Hilfefenster"
L["Inspect Frame"] = "Betrachten Fenster"
L["Item Upgrade"] = "Gegenstandsaufwertung"
L["KeyBinding Frame"] = "Tastenbelegungsfenster"
L["LF Guild Frame"] = "LF Gilde Fenster"
L["LFG Frame"] = "LFG Fenster"
L["Loot Frames"] = "Würfelfenster"
L["Loss Control"] = "Kontrollverlust"
L["Macro Frame"] = "Makro Fenster"
L["Mail Frame"] = "Post Fenster"
L["Merchant Frame"] = "Handelsfenster"
L["Misc Frames"] = "Verschiedene Fenster"
L["Mounts & Pets"] = "Reittiere & Haustiere"
L["Non-Raid Frame"] = "Kein-Raid Fenster"
L["Pet Battle"] = "Haustierkampf"
L["Petition Frame"] = "Abstimmungsfenster"
L["PvP Frames"] = "Pvp Fenster"
L["Quest Choice"] = "Quest Auswahl"
L["Quest Frames"] = "Quest Fenster"
L["Raid Frame"] = "Schlachtzugsfenster"
L["Reforge Frame"] = "Umschmiedefenster"
L["Skins"] = "Skins"
L["Socket Frame"] = "Sockel Fenster"
L["Spellbook"] = "Zauberbuch"
L["Stable"] = "Stall"
L["Tabard Frame"] = "Wappenrockfenster"
L["Talent Frame"] = "Talentfenster"
L["Taxi Frame"] = "Flugroutenfenster"
L["Time Manager"] = "Zeitmanager"
L["Trade Frame"] = "Handelsfenster"
L["TradeSkill Frame"] = "Berufefenster"
L["Trainer Frame"] = "Lehrerfenster"
L["Transmogrify Frame"] = 'Transmogrifikationsfenster'
L["Void Storage"] = "Leerenlager"
L["World Map"] = "Weltkarte"

--Tooltip
L["Always Hide"] = 'Immer verstecken'
L["Bags Only"] = 'Nur Taschen'
L["Bank Only"] = 'Nur Bank'
L["Both"] = 'Beide'
L["Cursor Anchor"] = "Zeigeranker"
L["Custom Faction Colors"] = "Benutzerdefinierte Fraktionsfarben"
L["Display guild ranks if a unit is guilded."] = 'Zeige Gildenränge von Spielern die in einer Gilde sind.'
L["Display how many of a certain item you have in your possession."] = 'Zeige wie viele sich von dem ausgewählten Gegenstand in deinem Besitz befinden.'
L["Display player titles."] = 'Zeige Spielertitel.'
L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."] = "Zeige die Spezialisierung und das Itemlevel des Spielers im Tooltip an, wird vielleicht nicht direkt aktualisiert"
L["Display the spell or item ID when mousing over a spell or item tooltip."] = 'Zeige die ID des Zaubers oder des Gegenstands an, wenn du mit der Maus über einen Zauber oder Fegenstand ziehst.'
L["Don't display the tooltip when mousing over a unitframe."] = "Zeige keinen Tooltip, wenn die Maus über einem Einheitenfenster schwebt."
L["Guild Ranks"] = 'Gildenränge'
L["Health Bar"] = "Lebensleiste"
L["Hide tooltip while in combat."] = "Verstecke den Tooltip während des Kampfes."
L["Inspect Info"] = 'Informationen betrachten'
L["Item Count"] = 'Gegenstandsanzahl'
L["Never Hide"] = 'Niemals verstecken'
L["Player Titles"] = 'Spielertitel'
L["Should tooltip be anchored to mouse cursor"] = "Soll das Tooltip an den Mauszeiger geankert werden"
L["Spell/Item IDs"] = 'Zauber/Gegenstand IDs'
L["Target Info"] = "Ziel Info"
L["Unitframes"] = "Einheitenfenster"
L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."] = "Zeige ob jemand aus deiner Gruppe/Schlachtzug die Tooltip-Einheit ins Ziel genommen hat."

--UnitFrames
L["%s and then %s"] = "%s und dann %s"
L["2D"] = '2D'
L["3D"] = '3D'
L["Above"] = 'Oben'
L["Absorbs"] = "Absorbierungen"
L["Add a spell to the filter."] = "Zauber zum Filter hinzufügen"
L["Add Spell"] = "Zauber hinzufügen"
L["Add SpellID"] = "ZauberID hinzufügen"
L["Additional Filter"] = "Zusätzlicher Filter"
L["Affliction"] = "Gebrechen"
L["Allow auras considered to be part of a boss encounter."] = "Erlaube den Auren als Teil eines Bosskampfes betrachtet zu werden"
L["Allow Boss Encounter Auras"] = "Erlaube Bosskampf Auren"
L["Allow Whitelisted Auras"] = "Erlaube Whitelisted Auren"
L["An X offset (in pixels) to be used when anchoring new frames."] = "X-Versatz (in Pixeln) der verwendet werden soll um neue Fenster zu ankern"
L["An Y offset (in pixels) to be used when anchoring new frames."] = "Y-Versatz (in Pixeln) der verwendet werden soll um neue Fenster zu ankern"
L["Arcane Charges"] = 'Arkane Aufladungen'
L["Assist Frames"] = "Assistent Fenster"
L["Assist Target"] = "Assistent Ziel"
L["At what point should the text be displayed. Set to -1 to disable."] = 'An welchen Punkt sollte der text angezeigt werden. Auf -1 setzen um es zu deaktivieren.'
L["Attach Text to Power"] = 'Text an die Energie anfügen'
L["Attach To"] = "Anpassen an"
L["Aura Bars"] = 'Auren Leisten'
L["Auto-Hide"] = "Automatisch verstecken"
L["Bad"] = "Schlecht"
L["Bars will transition smoothly."] = "Sanfter Übergang der Leisten."
L["Below"] = 'Unten'
L["Blacklist"] = "Schwarze Liste"
L["Block Auras Without Duration"] = "Blocke Auren ohne Laufzeit"
L["Block Blacklisted Auras"] = "Blocke Auren der schwarzen Liste"
L["Block Non-Dispellable Auras"] = 'Blocke Nicht-Bannbare Auren'
L["Block Non-Personal Auras"] = "Blocke Nicht-Persönliche Auren"
L["Block Raid Buffs"] = "Blocke Schlachtzugsstärkungszauber"
L["Blood"] = 'Blut'
L["Borders"] = 'Umrandungen'
L["Buff Indicator"] = "Buff Indikator"
L["Buffs"] = "Stärkungszauber"
L["By Type"] = 'Nach Typ'
L["Camera Distance Scale"] = "Kameradistanz"
L["Castbar"] = "Zauberleiste"
L["Center"] = 'Zentrum'
L["Check if you are in range to cast spells on this specific unit."] = "Überprüfe ob du dich in Reichweite befindest, um einen Zauber auf eine spezifische Einheit zu wirken."
L["Class Backdrop"] = "Klassen Hintergrund"
L["Class Castbars"] = 'Klassen Zauberleisten'
L["Class Color Override"] = "Klassenfarben überschreiben"
L["Class Health"] = "Klassen Gesundheit"
L["Class Power"] = "Klassen Kraft"
L["Class Resources"] = 'Klassenressourcen'
L["Click Through"] = 'Klicke hindurch'
L["Color all buffs that reduce the unit's incoming damage."] = "Färbe alle Stärkungszauber die den einkommenden Schaden der Einheit verringern."
L["Color aurabar debuffs by type."] = 'Färbe Schwächungszauber nach Typ.'
L["Color castbars by the class or reaction type of the unit."] = 'Färbe Zauberleiste nach Klasse oder Reaktionstyp der Einheit.'
L["Color health by amount remaining."] = "Färbe die Gesundheitsleiste entsprechend der aktuell verbleibenden Lebenspunkte"
L["Color health by classcolor or reaction."] = "Gesundheitsfarbe nach Klassenfarbe oder Reaktion."
L["Color power by classcolor or reaction."] = "Färbe die Kraftleiste entsprechend ihrer Klasse."
L["Color the health backdrop by class or reaction."] = "Färbe den Gesundheitshintergrund nach Klasse oder Reaktion."
L["Color the unit healthbar if there is a debuff that can be dispelled by you."] = "Aktiviere die Hervorhebung von Einheitenfenstern, wenn ein von dir bannbarer Schwächungszauber vorhanden ist."
L["Color Turtle Buffs"] = 'Färbe Turtle Stärkungszauber'
L["Color"] = "Farbe"
L["Colored Icon"] = 'Buntes Symbol'
L["Coloring (Specific)"] = 'Färben (Spezifisch)'
L["Coloring"] = 'Färben'
L["Combat Fade"] = "Im Kampf ausblenden"
L["Combobar"] = "Kombopunkte Leiste"
L["Configure Auras"] = 'Konfiguriere Auren'
L["Copy From"] = "Kopieren von"
L["Count Font Size"] = "Schriftart Größe der Anzahl"
L["Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list."] = 'Erstelle einen benutzerdefinierten Anzeigetext. Sobald du einen Namen eingibst, wirst du ihn von der Dropdown-Liste auswählen können.'
L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."] = "Erstelle einen Filter. Ist dieser Filter einmal erstellt, kann er bei jeder Einheit im Bereich Stärkungszauber/Schwächungszauber ausgewählt werden."
L["Create Filter"] = "Filter erstellen"
L["Current - Max | Percent"] = 'Aktuell - Maximal | Prozent'
L["Current - Max"] = "Aktuell - Maximal"
L["Current - Percent"] = "Aktuell - Prozent"
L["Current / Max"] = "Aktuell / Maximal"
L["Current"] = "Aktuell"
L["Custom Health Backdrop"] = "Benutzerdefinierte Hintergrundfarbe"
L["Custom Texts"] = 'Benutzerdefinierte Texte'
L["Death"] = 'Todesrunen'
L["Debuff Highlighting"] = "Hervorhebung von Schwächungszaubern"
L["Debuffs"] = "Schwächungszauber"
L["Decimal Threshold"] = "Dezimaler Schwellenwert"
L["Deficit"] = "Unterschied"
L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."] = "Entferne einen erstellten Filter. Es können nur benutzerdefinierte Filter entfernt werden."
L["Delete Filter"] = "Filter löschen"
L["Demonology"] = "Dämonologie"
L["Destruction"] = "Zerstörung"
L["Detach From Frame"] = "Vom Fenster lösen"
L["Detached Width"] = 'Freistehendes Breite'
L["Direction the health bar moves when gaining/losing health."] = "Richtung in die sich die Lebensleiste aufbaut, wenn man Leben gewinnt oder verliert."
L["Disable Blizzard"] = "Blizzard deaktivieren"
L["Disabled"] = 'Deaktivieren'
L["Disables the blizzard party/raid frames."] = "Deaktiviere das Gruppen/Schlachtzugsfenster von Blizzard"
L["Disconnected"] = "Nicht Verbunden"
L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."] = "Zeigt eine funkelnde Textur am Ende des Zauberbalken um den Unterschied zwischen Zauberbalken und Hintergrund zu verdeutlichen."
L["Display druid mana bar when in cat or bear form and when mana is not 100%."] = "Mana des Druiden anzeigen wenn er in Katzen- oder Bärengestalt ist und das Mana nicht 100% ist"
L["Display Frames"] = 'Zeige Fenster'
L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."] = 'Zeige ein Symbol auf dem Arenafenster, welches innerhalb eines Schlachtfeldes die Talentspezialisierung oder die Fraktion anzeigt.'
L["Display Player"] = "Zeige Spieler"
L["Display Target"] = "Zeige Ziel"
L["Display Text"] = 'Zeige Text'
L["Display the rested icon on the unitframe."] = "Zeige das Ausgeruht-Symbol auf den Einheitenfenstern."
L["Display the target of your current cast. Useful for mouseover casts."] = "Zeige das Ziel deines derzeitigen Zaubers, für Mouseover Zauber nützlich"
L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."] = "Anzeige der Zauberbalkenticks für kanalisierte Zauber. Dies ändert sich automatisch für Zauber wie Seelendieb, wenn zusätzliche Ticks durch einen hohen Tempowert entstehen."
L["Don't display any auras found on the 'Blacklist' filter."] = "Zeige keinerlei Auren die sich im 'Schwarzenlisten' filter befinden."
L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."] = "Keine Auren anzeigen die länger als diese Dauer (in Sekunden) sind"
L["Don't display auras that are not yours."] = "Zeige keine Auren die nicht von dir sind."
L["Don't display auras that cannot be purged or dispelled by your class."] = "Zeige keine Auren die nicht von deiner Klasse entzaubert oder gereinigt werden kann."
L["Don't display auras that have no duration."] = "Zeige keine Auren die keine Laufzeit haben."
L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."] = "Zeige keine Schlachtzugsstärkungszauber wie Segen der Könige oder Mal der Wildnis."
L["Down"] = "Hinunter"
L["Druid Mana"] = "Mana des Druiden"
L["Duration Reverse"] = 'Dauer umkehren'
L["Duration"] = 'Dauer'
L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."] = "Aktivieren dieses Punktes erlaubt Raidweites sortieren, allerdings wirst du nicht zwischen Gruppen unterscheiden können"
L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."] = "Aktivieren dieses Punktes kehrt die Gruppierungsrichtung um wenn der Raid nicht voll ist, die Startrichtung wird ebenfalls umgekehrt"
L["Enemy Aura Type"] = 'Feindlicher Aurentyp'
L["Fade the unitframe when out of combat, not casting, no target exists."] = "Blende die Haupteinheitenfenster aus, wenn du dich nicht im Kampf befindest, keine Zauber wirkst oder kein Ziel anvisierst."
L["Fill"] = "Füllen"
L["Filled"] = "Gefüllt"
L["Filter Type"] = "Filter Typ"
L["Force Off"] = "Gezwungen aus"
L["Force On"] = "Gezwungen an"
L["Force Reaction Color"] = 'Erzwinge Reaktionsfarbe'
L["Force the frames to show, they will act as if they are the player frame."] = 'Zwinge die Fenster sichtbar zu werden. Diese Fenster werden sich wie das Spielerfenster verhalten.'
L["Forces reaction color instead of class color on units controlled by players."] = 'Erzwinge Reaktionsfarbe anstatt Klassenfarbe auf übernommene Einheiten.'
L["Format"] = "Formatierung"
L["Frame"] = "Fenster"
L["Frequent Updates"] = "Häufigkeit der Aktualisierung"
L["Friendly Aura Type"] = 'Freundlicher Aurentyp'
L["Friendly"] = 'Freundlich'
L["Frost"] = 'Frost'
L["Glow"] = 'Glanz'
L["Good"] = "Gut"
L["GPS Arrow"] = "GPS Pfeil"
L["Group By"] = "Gruppiert durch"
L["Grouping & Sorting"] = "Gruppierung und Sortierung"
L["Groups Per Row/Column"] = "Gruppen per Reihe/Spalte"
L["Growth direction from the first unitframe."] = 'Wachstumsrichtung von dem ersten Einheitenfenster.'
L["Growth Direction"] = 'Wachstumsrichtung'
L["Harmony"] = 'Chi'
L["Heal Prediction"] = "Eingehende Heilung"
L["Health Backdrop"] = "Gesundheitshintergrund"
L["Health Border"] = 'Gesundheitsumrandung'
L["Health By Value"] = "Gesundheit nach dem Wert"
L["Health"] = "Leben"
L["Height"] = "Höhe"
L["Holy Power"] = 'Heilige Kraft'
L["Horizontal Spacing"] = "Horizontaler Abstand"
L["Horizontal"] = "Horizontal" --Also used in bags module
L["How far away the portrait is from the camera."] = "Entfernung der Kamera vom Portrait."
L["Icon"] = "Symbol"
L["Icon: BOTTOM"] = 'Symbol: UNTEN'
L["Icon: BOTTOMLEFT"] = 'Symbol: UNTENLINKS'
L["Icon: BOTTOMRIGHT"] = 'Symbol: UNTENRECHTS'
L["Icon: LEFT"] = 'Symbol: LINKS'
L["Icon: RIGHT"] = 'Symbol: RECHTS'
L["Icon: TOP"] = 'Symbol: OBEN'
L["Icon: TOPLEFT"] = 'Symbol: OBENLINKS'
L["Icon: TOPRIGHT"] = 'Symbol: OBENRECHTS'
L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "Wenn du keine anderen Filteroptionen verwendest werden alle Filter blockiert die nicht im 'Weisenfilter' stehen, sonst füge einfach Auren der Weisenliste hinzu zusätzlich zu den anderen Filter Einstellungen."
L["If not set to 0 then override the size of the aura icon to this."] = 'Wenn dieser Wert nicht auf 0 gesetzt wird, dann überschreibt dieser die größe des Aurensymbols.'
L["If the unit is an enemy to you."] = "Wenn die Einheit feindlich zu dir ist."
L["If the unit is friendly to you."] = "Wenn die Einheit freundlich zu dir ist."
L["Ignore mouse events."] = 'Ignoriere Maus Events.'
L["Inset"] = 'Einsatz'
L["Interruptable"] = 'Unterbrechbar'
L["Invert Grouping Order"] = "Gruppierungsreihenfolge umkehren"
L["JustifyH"] = 'RechtfertigenH'
L["Latency"] = "Latenz"
L["Low Mana Threshold"] = "Warnung: Mana niedrig"
L["Lunar"] = 'Lunar'
L["Main statusbar texture."] = "Haupt-Statusleisten Textur"
L["Main Tanks / Main Assist"] = 'Haupt Tank / Haupt Assistent'
L["Make textures transparent."] = 'Mache Texturen transparent.'
L["Match Frame Width"] = "Passende Fensterbreite"
L["Max Bars"] = 'Leisten Anzahl'
L["Maximum Duration"] = "Maximale Dauer"
L["Middle Click - Set Focus"] = 'Mittelklick - Setze Fokus'
L["Middle clicking the unit frame will cause your focus to match the unit."] = 'Mittelklicken des Einheitenfensters passt deinen Fokus an die Einheit an.'
L["Model Rotation"] = "Modellrotation"
L["Mouseover"] = 'Mouseover'
L["Name"] = "Name" --Also used in Buffs and Debuffs
L["Neutral"] = "Neutral"
L["Non-Interruptable"] = 'Nicht-Unterbrechbar'
L["None"] = "Kein" --Also used in chat
L["Not valid spell id"] = "Keine gültige Zauber ID"
L["Num Rows"] = "Anzahl der Reihen"
L["Number of Groups"] = "Nummer der Gruppen"
L["Number of units in a group."] = "Nummer der Einheiten in einer Gruppe"
L["Offset of the powerbar to the healthbar, set to 0 to disable."] = "Versatz der Powerleiste zu der Lebensleiste. Setze es auf 0 um den Versatz zu deaktivieren."
L["Offset position for text."] = 'Versatz Positionen für Texte.'
L["Offset"] = "Versatz"
L["Only show when the unit is not in range."] = 'Nur zeigen wenn die Einheit nicht in Reichweite ist.'
L["Only show when you are mousing over a frame."] = 'Nur zeigen wenn du mit der Maus über dem Fenster bist.'
L["OOR Alpha"] = "Außer Reichweite Alpha"
L["Orientation"] = "Orientierung"
L["Others"] = "Andere"
L["Overlay the healthbar"] = "Überblendung der Gesundheitsleiste"
L["Overlay"] = "Überblenden"
L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."] = "Überschreibe alle benutzerdefinierten Einstellungen für die Sichtbarkeit in bestimmten Situationen. Beispiel: Zeige nur Gruppe 1 und 2 in einer 10er-Instanz."
L["Override the default class color setting."] = "Überschreibe die Standard Klassenfarben Einstellungen"
L["Owners Name"] = "Name des Besitzers"
L["Party Pets"] = "Gruppenbegleiter"
L["Party Targets"] = "Gruppenziele"
L["Per Row"] = "Pro Reihe"
L["Percent"] = "Prozent"
L["Personal"] = 'Persönlich'
L["Pet Name"] = "Name des Pets"
L["Portrait"] = "Portrait"
L["Position the Model horizontally."] = "Positioniere das Model horizontal."
L["Position the Model vertically."] = "Positioniere das Model vertikal."
L["Position"] = "Position"
L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."] = "Der Krafttext wird bei NPC-Zielen automatisch verborgen, zusätzlich wird der Namenstext relativ zu dem Energie/Mana-Ankerpunkt umpositioniert."
L["Power"] = "Kraft"
L["Powers"] = "Kräfte"
L["Priority"] = "Priorität"
L["PVP Trinket"] = 'PVP Schmuck'
L["Raid Icon"] = 'Schlachtzugssymbol'
L["Raid-Wide Sorting"] = "Raidweite Sortierung"
L["Raid40 Frames"] = "40er Schlachtzugsfenster"
L["RaidDebuff Indicator"] = "RaidDebuff Indikator"
L["Range Check"] = "Entfernungcheck"
L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."] = "Schnelle Aktualisierung der Lebensleiste. Benutzt mehr Speicher und Prozessorleistung. Nur für Heiler zu empfehlen."
L["Reactions"] = "Reaktionen"
L["Remaining"] = "Verbleibend"
L["Remove a spell from the filter."] = "Entfernt einen Zauber aus dem Filter."
L["Remove Spell"] = "Zauber entfernen"
L["Remove SpellID"] = "Entferne Zauber ID"
L["Rest Icon"] = "Ausgeruht-Symbol"
L["Restore Defaults"] = "Standard wiederherstellen" --Also used in General and ActionBars sections
L["RL / ML Icons"] = 'RL / ML Symbole'
L["Role Icon"] = "Rollensymbol"
L["Select a filter to use."] = "Wähle einen Filter aus." --Also used in NamePlates
L["Select a unit to copy settings from."] = "Wähle eine Einheit um Einstellungen zu kopieren."
L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = 'Wähle einen Filter zum zusätzlichen verwenden. Wenn der ausgewählte Filter in einer Weisenliste ist und keine anderen Filter verwendet werden (mit Ausnahme von Blocke Nicht- Persönliche Auren), dann wird alles was nicht auf der Weisenliste steht blockiert, sonst füge einfach Auren der Weisenliste hinzu zusäzlich zu den anderen Filter Einstellungen.'
L["Select Filter"] = "Filter auswählen"
L["Select Spell"] = "Zauber auswählen"
L["Select the display method of the portrait."] = 'Wähle das Anzeigemethode für das Portrait.'
L["Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else."] = "Stelle den Filtertypus ein; Filter 'Schwarze Liste' zeigt alle Auren und versteckt jene, die explizit im Filter angegeben wurden; im Gegensatz dazu verbirgt der Filter 'Weiße Liste' alle Auren und zeigt nur jene an, die explizit im Filter angegeben wurden."
L["Set the font size for unitframes."] = "Wähle die Schriftart für die Einheitenfenster."
L["Set the order that the group will sort."] = "Wähle die Richtung in welche die Gruppe sortiert werden soll."
L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."] = "Wähle die Priorität des Zaubers. Bitte beachte, dass sich die Priorität nur auf das Schlachtzugsschwächungszauber-Modul auswirkt und nicht auf das Standard-Stärkungs/Schwächungszauber-Modul. Möchtest du es deaktivieren, dann setze es auf 0."
L["Set the type of auras to show when a unit is a foe."] = 'Wähle den Aurentyp, der angezeigt werden soll, wenn das Ziel feindlich ist.'
L["Set the type of auras to show when a unit is friendly."] = 'Wähle den Aurentyp, der angezeigt werden soll, wenn das Ziel freundlich ist.'
L["Sets the font instance's horizontal text alignment style."] = "Wähle die Schriftart Instanz horizontal zur Ausrichtung des Textes Stils."
L["Shadow Orbs"] = 'Schattenkugeln'
L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."] = "Zeige eingehende Heilung im Einheitenfenster. Zeigt eine etwas anders farbige Leiste für eingehende Überheilung."
L["Show Aura From Other Players"] = "Zeige Auren von anderen Spielern"
L["Show Auras"] = 'Zeige Auren'
L["Show When Not Active"] = "Zeige, wenn nicht aktiv"
L["Size and Positions"] = "Größe und Positionen"
L["Size of the indicator icon."] = "Größe des Anzeigesymbole."
L["Size Override"] = 'Größe überschreiben'
L["Size"] = "Größe"
L["Smart Raid Filter"] = "Intelligenter Raid-Filter"
L["Smooth Bars"] = "Sanfte Leistenübergänge"
L["Solar"] = 'Solar'
L["Spaced"] = "Abgetrennt"
L["Spark"] = "Funken"
L["Spec Icon"] = 'Talentspezialisierungssymbol'
L["Spell not found in list."] = "Zauber in der Liste nicht gefunden."
L["Spells"] = 'Zauber'
L["Stagger Bar"] = 'Staffel Leiste'
L["Start Near Center"] = "Starte nahe der Mitte"
L["StatusBar Texture"] = "Statusleistentextur"
L["Style"] = 'Stil'
L["Tank Frames"] = "Tank Fenster"
L["Tank Target"] = "Tank Ziel"
L["Tapped"] = "Angeschlagen"
L["Target On Mouse-Down"] = "Ziel bei Maus-Runter"
L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."] = "Nimmt die Einheit ins Ziel bei Maus-Runter anstatt bei Maus-Hoch. |cffFF0000Warnung: Wenn du das Addon 'Clique' benutzt musst du das auch in den Clique Einstellungen ändern wenn du das hier benutzt."
L["Text Color"] = 'Text Farbe'
L["Text Format"] = "Textformat"
L["Text Position"] = 'Text Position'
L["Text Threshold"] = 'Text Schwelle'
L["Text Toggle On NPC"] = "Textumschalter auf NPCs"
L["Text xOffset"] = 'Text X-Versatz'
L["Text yOffset"] = 'Text Y-Versatz'
L["Text"] = 'Text'
L["Textured Icon"] = 'Texturiertes Symbol'
L["The alpha to set units that are out of range to."] = "Setzt den Alphabereich für Einheiten, die ausserhalb deiner Reichweite sind."
L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."] = "Das folgende Makro muss wahr sein um die Gruppe anzuzeigen. Dies gilt zusätzlich zu jeglichem Filter der möglicherweise bereits eingestellt ist."
L["The font that the unitframes will use."] = "Die Schriftart, welche die Einheitenfenster benutzen sollen."
L["The initial group will start near the center and grow out."] = "Die anfängliche Gruppe wird nahe der Mitte starten und dann wachsen"
L["The name you have selected is already in use by another element."] = 'Den Namen den du ausgewählt hast, wird bereits von einem anderem Element benutzt.'
L["The object you want to attach to."] = "Das Objekt, das du anhängen willst"
L["This filter is meant to be used when you only want to whitelist specific spellIDs which share names with unwanted spells."] = "Dieser Filter wird verwendet, wenn du spezifische Zauber IDs erlauben möchtest, sollte ein unerwünschter Zauber den gleichen Namen haben."
L["This filter is used for both aura bars and aura icons no matter what. Its purpose is to block out specific spellids from being shown. For example a paladin can have two sacred shield buffs at once, we block out the short one."] = 'Dieser Filter wird für Aurenleisten und Aurensymbole verwendet. Sein Zweck besteht darin spezifische Zauber IDs zu blockieren, bevor diese angezeigt werden. Ein Beispiel für einen Paladin ist, dass du zwei Geheiligter Schild Stärkungszauber auf einmal hast. Es wird dann der Kürzere blockiert.'
L["Threat Display Mode"] = 'Bedrohungs Anzeige Modus'
L["Threshold before text goes into decimal form. Set to -1 to disable decimals."] = "Schwellenwert bevor der Text in die Dezimalform wechselt. Auf -1 setzen, um Dezimalstellen zu deaktivieren."
L["Ticks"] = "Ticks"
L["Time Remaining Reverse"] = 'Zeit verbleibend umkehren'
L["Time Remaining"] = 'Zeit verbleibend'
L["Toggles health text display"] = "Aktiviere den Gesundheitstext"
L["Transparent"] = 'Transparent'
L["Turtle Color"] = 'Turtle Farbe'
L["Unholy"] = 'Unheilig'
L["UnitFrames"] = "Einheitenfenster"
L["Up"] = "Hinauf"
L["Use Default"] = "Benutze Standard"
L["Use the custom health backdrop color instead of a multiple of the main health color."] = "Wähle eine eigene Hintergrundfarbe, andernfalls wird die aktuelle Gesundheitsleistenfarbe verwendet."
L["Value must be a number"] = "Der Wert muss eine Zahl sein"
L["Vertical Spacing"] = "Vertikaler Abstand"
L["Vertical"] = "Vertikal" --Also used in bags section
L["Visibility"] = "Sichtbarkeit"
L["What point to anchor to the frame you set to attach to."] = "Welchen Punkt für das verankern der Fenster möchtest du wählen."
L["What to attach the buff anchor frame to."] = "Wo die Stärkungszauber angehängt werden sollen."
L["What to attach the debuff anchor frame to."] = "Wo die Schwächungszauber angehängt werden sollen."
L["When true, the header includes the player when not in a raid."] = "Wenn aktiv und sich der Spieler nicht in einem Raid befindet, dann wird das angezeigt."
L["When you mana falls below this point, text will flash on the player frame."] = "Wert ab dem wegen niedrigem Manastand gewarnt wird. Der Text wird auf dem Spielerfenster aufblinken"
L["Whitelist"] = "Weiße Liste"
L["Width"] = "Breite" --Also used in NamePlates module
L["xOffset"] = "X-Versatz"
L["yOffset"] = "Y-Versatz" --Another variation in bags section Y Offset
L["You can't remove a pre-existing filter."] = "Du kannst einen vorgefertigten Filter nicht löschen."
L["You cannot copy settings from the same unit."] = "Du kannst keine Einstellungen von der gleichen Einheit kopieren."
L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."] = "Du kannst keinen Filter entfernen, der nicht von dir selbst hinzugefügt wurde. Setzte den Zauber einfach auf deaktiviert."