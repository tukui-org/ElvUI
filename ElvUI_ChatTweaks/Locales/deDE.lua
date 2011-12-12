-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI_ChatTweaks", "deDE")
if not L then return end

--[==[ L[ [=[

|cffff0000NOTE:|r  If this addon starts to use a substantial amount of memory, simply reset the name data and it will return to a normal level.

Addon Usage: |cff00ff00%s|r]=] ] = "" ]==]
-- L["   |cff00ff00%s|r - %s"] = ""
-- L["   |cff00ff00%s|r or |cff00ff00%s|r - %s"] = ""
-- L["   |cff00ff00/ct %s|r - %s"] = ""
L[ [=[ is designed to add a lot of the functionality of full fledged chat addons like Prat or Chatter, but without a lot of the unneeded bloat.  I wrote it to be as lightweight as possible, while still powerful enough to accomplish it's intended function.
]=] ] = "wurde entwickelt um einen Großteil der Funktionen von vollwertigen Chat-Addons wie Prat oder Chatter hinzuzufügen ohne unnötig aufgeblasen zu wirken. Ich schieb es so leichtgewichtig wie möglich, trotzdem leistungsfähig genug um die beabsichtigen Funktionen zu erfüllen" -- Needs review
-- L[" |cffffff00%d|r Total Modules (|cff00ff00%d|r Enabled, |cffff0000%d|r Disabled)"] = ""
-- L["$$EMPTY$$"] = ""
L["Achievement hyperlinks."] = "Erfolgs-Hyperlinks" -- Needs review
L["Achievements"] = "Erfolge"
-- L["Add Space"] = ""
-- L["Add Word"] = ""
-- L["Add a space after the channel name."] = ""
-- L["Add surrounding brackets to own charname in messages."] = ""
-- L["Add word to your invite trigger list"] = ""
-- L["Adds a timestamp to each line of text."] = ""
--[==[ L[ [=[Adds chat commands to clear the chat windows.

]=] ] = "" ]==]
-- L["After"] = ""
-- L["Allow people in your guild to whisper you, regardless of their level."] = ""
-- L["Allow people on your friends list to whisper you, regardless of their level."] = ""
--[==[ L[ [=[Allows you to change the default font settings for the chat frames.

|cffff0000Using another addon to do this will break this functionality.|r]=] ] = "" ]==]
-- L["Alt-click name to invite"] = ""
-- L["Alternate command to kick someone from guild."] = ""
-- L["Are you sure you want to delete all your saved class/level data?"] = ""
-- L["Are you sure you want to reset the chat fonts to defaults?"] = ""
-- L["Auction Expired"] = ""
-- L["Auction Message Filtering"] = ""
-- L["Auction Outbid"] = ""
-- L["Auction Removed"] = ""
-- L["Auction Sold"] = ""
-- L["Auction Won"] = ""
-- L["Auto Scroll"] = ""
L["Auto report anyone reaching the spam threshold (3 points)."] = "Melde automatisch jeden, der die Spam-Schwelle (3 Punkte) überschreitet." -- Needs review
L["Automatic Chat Logging"] = "automatische Chat-Aufzeichnung"
-- L["Automatically enables chat logging."] = ""
-- L["Automatically scroll to the bottom of the chat window after |cff00ff00X|r seconds."] = ""
-- L["Available Chat Command Arguments"] = ""
-- L["Battle.Net Options"] = ""
L["Battleground"] = "Schlachtfeld"
L["Battleground Channel"] = "Schlachtfeld-Kanal"
L["Battleground Leader"] = "Schlachfeldleiter"
L["Battleground Leader Channel"] = "Schlachtfeldleiter-Kanal"
L["Battleground Leader Text"] = "Schlachtfeldleiter-Text"
L["Battleground Text"] = "Schlachtfeld-Text"
-- L["Before"] = ""
-- L["Bid Accepted"] = ""
L["Center"] = "Mitte"
L["Channel Colors"] = "Kanal Farben"
-- L["Channel Names"] = ""
L["Channel Sounds"] = "Kanal-Sounds"
-- L["Character to use between the name and level"] = ""
-- L["Character to use for the left bracket"] = ""
-- L["Character to use for the right bracket"] = ""
L["Chat Fonts"] = "Chat-Schriftarten"
L["Chat Frame "] = "Chat-Fenster"
-- L["Chat Frame Settings"] = ""
-- L["ChatFrame %d"] = ""
-- L["Choose which chat frames display timestamps"] = ""
L["Class"] = "Klasse"
-- L["Clear Chat Commands"] = ""
-- L["Clear all chat windows."] = ""
L["Clear current chat."] = "Leere aktuellen Chat." -- Needs review
-- L["Color Player Names By..."] = ""
-- L["Color level by difficulty"] = ""
-- L["Color own charname in messages."] = ""
-- L["Color self in messages"] = ""
-- L["Color timestamps the same as the channel they appear in."] = ""
--[==[ L[ [=[Color to change the spam to.

|cffff0000Only works when Filtering Mode is set to |cff00ff00Colorize|r.]=] ] = "" ]==]
-- L["Colorize"] = ""
L["Confirm Report?"] = "Meldung bestätigen?"
L["Confirm reporting before actually reporting them."] = "Meldungen bestätigen bevor sie gesendet wird."
-- L["Creates a button to click that will return you to the bottom of the chat frame."] = ""
-- L["Custom format (advanced)"] = ""
L["Death Knight"] = "Todesritter" -- Needs review
-- L["Default Name Color"] = ""
-- L["Default font face for the chat frames."] = ""
-- L["Default font outline for the chat frames."] = ""
-- L["Default font size for the chat frames."] = ""
-- L["Destroys all your saved class/level data"] = ""
-- L["Disable in Combat"] = ""
L["Disable the hovering while in combat."] = "Mouseover im Kampfmodus deaktivieren" -- Needs review
-- L["Disabled"] = ""
L["Druid"] = "Druide" -- Needs review
L["Dungeon Guide"] = "Dungeonführer" -- Needs review
L["Dungeon Guide Channel"] = "Dungeonführer-Kanal" -- Needs review
L["Dungeon Guide Text"] = "Dungeonführer-Text" -- Needs review
L["Editbox History"] = "Eingabefeld Verlauf"
-- L["ElvUI ChatTweaks"] = ""
-- L["Emote"] = ""
L["Emphasize Self"] = "Eigenes hervorheben" -- Needs review
-- L["Enable "] = ""
-- L["Enabled"] = ""
-- L["Enables you to replace channel names with your own names. You can use '%s' to force an empty string."] = ""
L["Enchant hyperlinks."] = "Verzauberungs-Hyperlinks" -- Needs review
L["Enchants"] = "Verzauberungen" -- Needs review
-- L["Enter a custom time format. See http://www.lua.org/pil/22.1.html for a list of valid formatting symbols."] = ""
-- L["Exceptions"] = ""
-- L["Exclude level display for max level characters"] = ""
-- L["Exclude max levels"] = ""
-- L["Filter Color"] = ""
-- L["Filter Interval"] = ""
L[ [=[Filter certain words or phrases according to your settings.

|cffff0000DOES NOT REPORT THEM!|r]=] ] = [=[Filtere bestimmte Wörter und Phrasen gemäß den eigenen Einstellungen.

|cffff0000ERZEUGT KEINE MELDUNG!|r]=] -- Needs review
--[==[ L[ [=[Filter the Auction Expired message.

|cffffff00%s|r]=] ] = "" ]==]
--[==[ L[ [=[Filter the Auction Outbid message.

|cffffff00%s|r]=] ] = "" ]==]
--[==[ L[ [=[Filter the Auction Removed message.

|cffffff00%s|r]=] ] = "" ]==]
--[==[ L[ [=[Filter the Auction Sold message.

|cffffff00%s|r]=] ] = "" ]==]
--[==[ L[ [=[Filter the Auction Won message.

|cffffff00%s|r]=] ] = "" ]==]
--[==[ L[ [=[Filter the Bid Accepted message.

|cffffff00%s|r]=] ] = "" ]==]
-- L["Filtering Mode"] = ""
L["Filters gold selling, powerleveling, and other services that are against Blizzard's EULA."] = "Filtere Goldverkauf, Powerleveling, und andere Dienste die gegen Blizzard's EULA verstoßen." -- Needs review
L[ [=[Filters guild recruitment messages.

|cffff0000DOES NOT REPORT THEM!|r]=] ] = [=[Filtert Gildenrekrutierungsnachrichten.

|cffff0000ERZEUGT KEINE MELDUNG!|r]=] -- Needs review
-- L["Filters out Auction House system messages."] = ""
-- L["Filters text based on numerous triggers, with the ability to automatically report the offender."] = ""
-- L["Filters whispers if the sender does not meet the level requirement.  Useful for gold seller spam."] = ""
L["Font Face"] = "Schriftschnitt" -- Needs review
L["Font Size"] = "Schriftgröße"
L["Friends"] = "Freunde"
-- L["GKick Command"] = ""
-- L["Gives you more flexibility in how you invite people to your group."] = ""
L["Glyph hyperlinks."] = "Glyphen-Hyperlinks."
L["Glyphs"] = "Glyphen"
L["Gold Selling"] = "Goldverkauf"
L["Group"] = "Gruppe" -- Needs review
-- L["Group Say Command"] = ""
L["Guild"] = "Gilde" -- Needs review
L["Guild Channel"] = "Gilden-Kanal" -- Needs review
-- L["Guild Chat"] = ""
L["Guild Recruitment"] = "Gildenrekrutierung" -- Needs review
L["Guild Text"] = "Gilden-Text" -- Needs review
-- L["Guildies"] = ""
-- L["HH:MM (12-hour)"] = ""
-- L["HH:MM (24-hour)"] = ""
-- L["HH:MM:SS (24-hour)"] = ""
-- L["HH:MM:SS AM (12-hour)"] = ""
-- L["Here you can select which channels this module will scan for the keywords to trigger the invite."] = ""
-- L["Hovering over a hyperlink in chat will display it's tooltip."] = ""
--[==[ L[ [=[How to throttle the spam.

|cff00ff00Colorize|r changes the spam to a different color.
|cff00ff00Remove|r removes the line all together.]=] ] = "" ]==]
L["Hunter"] = "Jäger" -- Needs review
-- L["Hyperlink Hover"] = ""
-- L["Include level"] = ""
-- L["Include the player's level"] = ""
L["Instance Locks"] = "Instanz-Sperren"
L["Instance lock hyperlinks."] = "Instanz-Sperren-Hyperlinks." -- Needs review
-- L["Interval"] = ""
-- L["Invite Links"] = ""
L["Item hyperlinks."] = "Gegenstands-Hyperlinks." -- Needs review
L["Items"] = "Gegenstände"
-- L["Keeps your channel colors by name rather than by number."] = ""
L["Keyword Filtering"] = "Schlüsselwort Filterung"
L["Keywords or Phrases"] = "Schlüsselwörter oder Ausdrücke"
L["Left"] = "Links"
-- L["Left Bracket"] = ""
-- L["Lets you alt-click player names to invite them to your party."] = ""
-- L["Lets you set the justification of text in your chat frames."] = ""
-- L["Level Location"] = ""
-- L["MM:SS"] = ""
L["Mage"] = "Magier"
-- L["Minimum DK Level"] = ""
-- L["Minimum Level"] = ""
-- L["Minimum level of a Death Knight to be able to whisper you."] = ""
-- L["Minimum level of the sender to able to whisper you."] = ""
-- L["Module"] = ""
-- L["Monster Emote"] = ""
-- L["Monster Say"] = ""
L["Name"] = "Name"
-- L["No RealNames"] = ""
L["None"] = "Keiner" -- Needs review
L["Officer"] = "Offizier"
L["Officer Channel"] = "Offiziers-Kanal" -- Needs review
-- L["Officer Chat"] = ""
L["Officer Text"] = "Offiziers-Text" -- Needs review
-- L["Opens configuration window."] = ""
L["Other Channels"] = "Andere Kanäle"
L["Outline"] = "Kontur"
L["Paladin"] = "Paladin"
L["Party"] = "Gruppe"
L["Party Channel"] = "Gruppen-Kanal" -- Needs review
L["Party Leader"] = "Gruppenleiter"
L["Party Leader Channel"] = "Gruppenleiter-Kanal"
L["Party Leader Text"] = "Gruppenleiter-Text"
L["Party Text"] = "Gruppen-Text"
-- L["Place the level before or after the player's name."] = ""
-- L["Player Level"] = ""
-- L["Player Names"] = ""
-- L["Player level display options."] = ""
-- L["Plays a sound, of your choosing (via LibSharedMedia-3.0), whenever a message is received in a given channel."] = ""
L["Priest"] = "Priester" -- Needs review
-- L["Print this again."] = ""
-- L["Prints module status."] = ""
-- L["Profiles"] = ""
-- L["Provides a /gr slash command to let you speak in your group (raid, party, or battleground) automatically."] = ""
-- L["Provides a |cff00ff00/gkick|r command, as it should be."] = ""
-- L["Provides options to color player names, add player levels, and add tab completion of player names."] = ""
L["Quest hyperlinks."] = "Quest-Hyperlinks." -- Needs review
L["Quests"] = "Quests" -- Needs review
L["Raid"] = "Schlachtzug" -- Needs review
-- L["Raid Boss Emote"] = ""
L["Raid Channel"] = "Schlachtzug-Kanal" -- Needs review
L["Raid Leader"] = "Schlachtzugsleiter" -- Needs review
L["Raid Leader Channel"] = "Schlachtzugsleiter-Kanal" -- Needs review
L["Raid Leader Text"] = "Schlachtzugsleiter-Text" -- Needs review
L["Raid Text"] = "Schlachtzug-Text" -- Needs review
L["Raid Warning"] = "Schlachtzugwarnung" -- Needs review
L["Raid Warning Channel"] = "Schlachtzugwarnung-Kanal" -- Needs review
L["Raid Warning Text"] = "Schlachtzugwarnung-Text" -- Needs review
-- L["RealID Brackets"] = ""
L["RealID Conversation"] = "RealID Unterhaltung" -- Needs review
L["RealID Whisper"] = "RealID Flüstern" -- Needs review
-- L["Really remove this word from your trigger list?"] = ""
-- L["Remembers the history of the editbox across sessions."] = ""
-- L["Remove"] = ""
L["Remove Icons"] = "Entferne Symbole" -- Needs review
-- L["Remove Word"] = ""
-- L["Remove a word from your invite trigger list"] = ""
L["Removes icons from messages to prevent the various objects people try to make."] = "Entfernt Symbole aus Nachrichten als Präventivmaßnahme gegen Kunstkonstrukte." -- Needs review
L["Report"] = "Meldung" -- Needs review
L["Reporting Options"] = "Meldungs-Einstellungen" -- Needs review
-- L["Reset ChatFrame text justifications to defaults (left)."] = ""
L["Reset Data"] = "Daten zurücksetzen"
-- L["Reset Font Data"] = ""
-- L["Reset Text Justitification"] = ""
-- L["Resets all chat frames to their original font settings."] = ""
L["Right"] = "Rechts"
-- L["Right Bracket"] = ""
L["Rogue"] = "Schurke" -- Needs review
-- L["Save Data"] = ""
-- L["Save all /who data"] = ""
-- L["Save class data from /who queries between sessions."] = ""
-- L["Save class data from friends between sessions."] = ""
-- L["Save class data from groups between sessions."] = ""
-- L["Save class data from guild between sessions."] = ""
-- L["Save class data from target/mouseover between sessions."] = ""
-- L["Save data between sessions. Will increase memory usage"] = ""
L["Say"] = "Sagen" -- Needs review
-- L["Say Chat"] = ""
-- L["Scroll Reminder"] = ""
-- L["Select a color for this channel."] = ""
-- L["Select a method for coloring player names"] = ""
-- L["Send Response"] = ""
-- L["Send a reponse when a whisper is filtered."] = ""
-- L["Separator"] = ""
-- L["Settings"] = ""
L["Shaman"] = "Schamane" -- Needs review
-- L["Show toon names instead of real names"] = ""
-- L["Silent Report"] = ""
--[==[ L[ [=[Sound to play when a message in %s is received.

|cff00ff00To disable set to "None"|r.]=] ] = "" ]==]
L["Spam Filter"] = "Spam-Filter" -- Needs review
-- L["Spam Throttle"] = ""
L["Spell hyperlinks."] = "Zauber-Hyperlinks." -- Needs review
L["Spells"] = "Zauber" -- Needs review
-- L["Strip RealID brackets"] = ""
L["Surpress the reporting system message."] = "Verstecke die Meldungs-Systemnachricht" -- Needs review
L["Talent hyperlinks."] = "Talent-Hyperlinks."
L["Talents"] = "Talente"
-- L["Talk to your group based on party/raid status."] = ""
L["Target/Mouseover"] = "Ziel/Mouseover"
L["Text Justification"] = "Textausrichtung" -- Needs review
-- L["Text for battleground chat."] = ""
-- L["Text for battleground leader chat."] = ""
-- L["Text for dungeon guide text."] = ""
-- L["Text for guild chat."] = ""
-- L["Text for officer chat."] = ""
-- L["Text for party chat."] = ""
-- L["Text for party leader chat."] = ""
-- L["Text for raid chat."] = ""
-- L["Text for raid leader chat."] = ""
-- L["Text for raid warning chat."] = ""
-- L["Text justification for ChatFrame %d."] = ""
-- L["The default color to use to color names."] = ""
L["Thick Outline"] = "Dicke Kontur" -- Needs review
-- L["Throttle messages from being displayed (spammed) in chat channels."] = ""
-- L["Time, in seconds, in between throttleed message being allowed."] = ""
-- L["Time, in seconds, to allow to pass before automatically scrolling to the bottom of a chat window."] = ""
-- L["Timestamp color"] = ""
-- L["Timestamp format"] = ""
-- L["Timestamps"] = ""
L["Triggers"] = "Auslöser" -- Needs review
L["Unit hyperlinks."] = "Einheiten-Hyperlinks" -- Needs review
L["Units"] = "Einheiten" -- Needs review
-- L["Use Tab Complete"] = ""
-- L["Use channel color"] = ""
-- L["Use tab key to automatically complete character names."] = ""
L["Warlock"] = "Hexenmeister" -- Needs review
-- L["Warrior"] = ""
-- L["Whisper"] = ""
-- L["Whisper Filter"] = ""
-- L["Whispers"] = ""
-- L["Who"] = ""
-- L["Will save all data for large /who queries"] = ""
-- L["Words or phrases that will trigger the filter."] = ""
-- L["Yell"] = ""
-- L["Yell Chat"] = ""
-- L["You have reached the maximum amount of friends, remove 2 for this module to function properly."] = ""
-- L["You need to be at least level %d to whisper me."] = ""
-- L["[Battleground Leader]"] = ""
-- L["[Battleground]"] = ""
-- L["[Dungeon Guide]"] = ""
-- L["[Guild]"] = ""
-- L["[Officer]"] = ""
-- L["[Party Leader]"] = ""
-- L["[Party]"] = ""
-- L["[Raid Leader]"] = ""
-- L["[Raid Warning]"] = ""
-- L["[Raid]"] = ""
-- L["inv"] = ""
-- L["invite"] = ""
-- L["|cff00ff00%s|r or |cff00ff00%s|r %s"] = ""
-- L["|cff00ff00Enabled|r"] = ""
-- L["|cffff0000Disabled|r"] = ""
-- L["|cffff0000No modules found.|r"] = ""
-- L["|cffffff00Usage: /gkick <name>|r"] = ""
