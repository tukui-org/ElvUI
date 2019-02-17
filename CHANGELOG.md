### Version 10.88 [  ]

**New Additions:**  
Added new scale options. (/ec - General - Auto Scale | UI Scale)  
Added quality border option for Bag/Bank items. (#869)  
Added BoE/BoA text overlay in our Bag/Bank.  
Added optional mount name for units on tooltips.  
Added a new option to display Inspect Info on the Inspect and Character frames.  

**Bug Fixes:**  
Corrected more Pixel Perfect issues! :D  

**Misc. Changes:**  
Various Skin updates.  
Modified the bag item level code; items might actually show the correct item level now. :o  
Improved the tooltip item level code, it should be far more accurate now! (Thanks AcidWeb and Ls- for helping us with this!) :)  

___
### Version 10.87 [ January 30th 2019 ]

**New Additions:**  


**Bug Fixes:**  
Fixed an issue with the combat log header. (#1013)  
Fixed a bag config error if the bag module was disabled.  
Fixed an error caused by incorrect file loading order.  

**Misc. Changes:**  


___
### Version 10.86 [ January 29th 2019 ]

**New Additions:**  
Added option to toggle on/off the colors on bag slots for bags with assigned items.  
Added option to use the Blizzard cleanup method instead of the ElvUI sorting.  
Added a way to assign types of items to certain bags by right-clicking the bag icon in ElvUI.  
Added a count of remaining available characters to the chat editbox.  
Added the source text for mounts in the tooltip.  
Added Blizzards way to highlight scrappable items if the Scrapping Machine Frame is open.  

**Bug Fixes:**  
Fixed an issue which plays the bag sounds if you open the Game Menu. (#981)  
Fixed issue which caused E:UpdateAll to be called twice, potentially causing errors in plugins.  
Added terrible workaround for the broken events that cause health updates to break down.  

**Misc. Changes:**  
Added a compatibility check for our Garrison Mission skin, if GarrisonMissionManger is loaded.  
Updated gold datatext. Added an indicator for the current character and characters are now in class color.  
Consumable items that disappear when logged out are now sorted last to avoid gaps in the ElvUI bags.  (credit: Belzaru)  
Added a search filter for Mythic Keystone to LibItemSearch. You can search for keystones or ignore them from sorting with the term "keystone".  
Moved the options for the Talking Head to the skin section.  
Added Battle of Dazar'alor raid and M+ Season 2 affix debuffs to the RaidDebuffs filter.  

___
**Version 10.85 [ January 4th 2019 ]**

**New Additions:**  
Added `Weakened Soul` back to our Buff Indicator.  
Added new Currencies to our Currencies Datatext.  
Added NamePlate classbar scale option.  
Added color options for UnitFrame Power Predictions.  

**Bug Fixes:**  
Fixed a possible nil error on our NamePlate auras.  
Fixed nil error in the Obliterum & PvP skin.  
Fixed an issue in Bags skin preventing the "highlight" visual from showing when searching for items.  
Fixed an issue which could result in Quest Icon not showing up on nameplates even if it was enabled.  
Fixed an issue that we accidentally use the general texture for the UnitFrame backdrop instead of the UnitFrame texture.  
Fixed an issue which caused invisible GroupLootContainer frame to intercept mouse clicks. (#824)  
Fixed an issue which caused pixel borders to be double or missing. NOTE: Mostly fixed but config is still strange. (#908)  
Fixed lua error caused in NamePlate Style Filters about `GetSpecializationInfo`. (#926)  
Fixed bad values in incomingheals tags. (#950)  
Fixed Copy Chat Log (and Copy Chat Line) from displaying lines sometimes.  
Fixed minor positioning issue with role indicator on unitframes.  
Fixed issue which caused NamePlate StyleFilter NameOnly option to misplace the ClassBar/Portrait on plates.  
Fixed issue with ClassBar on NamePlates since 8.1 patch, the ClassBar also correctly works on Druids now.  
Fixed issue with NamePlates glow beeing pixelated.  
Fixed issues in bag searching. (#931)  
Fixed Social Queue Datatext and Chat Message.  
Fixed an issue that mostly affected actionbars, where elements would be misplaced after a profile change.  

**Misc. Changes:**  
Changed Health Backdrop Multiplier to be an Override instead.  
Updated oUF tags with recent changes.  
Hid the Recipient Portrait on the TradeFrame.  
ElvUI now staggers the updates that happen when a profile is changed. This should have minimal effect on existing plugins.  

___
**Version 10.84 [ December 11th 2018 ]**

**New Additions:**  
Added option to use health texture also on the backdrop.  
Added a seperate Tooltip option to display the NPC ID. (#873)  
Added a position option (Left or Right) for the Quest Icon on the Nameplates.  
Added option to change the position of the Keybind & Stack Text on the ActionBars. (#361)  
Added option to show an icon on an item in the bags if it's scrappable.  
Added option in our media section to remove the cropping from icons. Mostly used for Custom Texture Packs.  
Added option in our media section to select the 'Font Outline'.  
Added the WoW Token price in our Gold DataText.  

**Bug Fixes:**  
Fixed `realm:dash` tag error. (tags.lua:657: bad argument `#2` to 'format')  
Fixed QuestGreetingPanel & WorldMap skin not take account to Parchment Remover.  
Fixed Masque issues with the AddOn `ElvUI_ExtraActionBars`. (#709)  

**Misc. Changes:**  
Updated LibItemSearch to latest version.  
Updated the Ace3 (ElvUI config) checkbox skin to a permanent color.  
Some Code improvements.  
Various Skin tweaks.  

___
**Version 10.83 [ November 20th 2018 ]**

**New Additions:**  
Added Drain Life to channel ticks.  
Added Island Expedition progress to the BfA Mission Datatext.  
Added NPC Id's to our Tooltip.  
Added Debuff Highlighting on our Focus Frame.  
Added a dropdown menu to the Garrison Minimap Button. (Credits: Foxlit - WarPlan)  
Added a Module Copy option. This allows you to copy module settings to/from your different profiles.  
Added Bag Split (Bags + Bank) and Reverse Slots to the Bags. (#203)  
Added options to change the Item Level color in the Bags. (#764)  
Added options to change the Profession Bags & Bag Assignment color. (#525)  
Added options to change the Quest Item colors in bags. (!79 - Thanks @Alex_White)  
Added Tooltip offsets while using anchor on mouse. (#204)  
Added Tooltip option to alway show the realm name. (#372)  
Added quick search for spells in filters. (#30)  
Added "Display Target" to NamePlate castbars.  
Added "Display Interrupt Source" to NamePlate castbars.  
Added "Display Target" on any UnitFrame castbar, previously it was only available on Player UnitFrame.  
Added option to scale the Vehicle display. (#715)  
Added Tank & Assist Name Placements. (#128)  
Added Pet AuraBars. (Hunters Rejoice)! (#518)  
Added Tooltip Group Role. (#583)  
Added Power Prediction on UnitFrames. (#421)  
Added Raid Icons for Party Targets, Tank & Assist UnitFrames. (#459)  
Added Castbar Strata and Level Options. (#323)  
Added Color options to the UnitFrames to choose the Blizzard Selection Colors.  
Added right-click functionality for the movers in `/moveui` to get to the options. (#843)  
Added NamePlate indicators for Quest Mobs. Works only in the Open World.  
Added a skin option to remove the Parchment from some skins.  


**Bug Fixes:**  
Fixed display castbar for Arena & Boss Frames.  
Fixed Raidmarker spacing. (#791)  
Fixed issue which would sometimes keep Player UnitFrame out of range.  
Fixed error with UnitFrame Tags when enter Arena. (#821)  
Fixed issue which would show a NPC Reputation instead of NPC Title on NamePlates when Colorblind mode was enabled. (#826)  
Fixed Health Backdrop ClassBackdrop multiplier. (#134)  
Fixed DejaCharacterStats and Character Skin conflicts. (#819)  
Fixed `Raid Menu` button in `Raid Control`. (!78 - Thanks @Dimitro)  
Fixed issue which prevented Style Filters from applying to Healthbars of some Nameplates when Healthbar was disabled.  


**Misc. Changes:**  
Updated CCDebuffs list.  
Updated Frenzy buff Id for pets. (#816)  
Updated Zul debuff list.  
Updated the macro text on the ActionBars to use the ActionBar font.  
Optimized Bag Code in various areas. (This should mainly fix the lag reported when opening your bags).  
Removed ArtifactBar from the DataBars.  
Reworked vendor greys code to resolve issues with the previous versions.  
Allow left & right mouse button when using Keybind. (#234)  
Updated collection skin. Credits AddOnSkins.  
Updated Ace3 skin (ElvUI config page)  
Added `ElvUIGVC` chat channel for Version Checking (AddOn Communication) and Voice Chat (off by Default) on realm.  
Time datatext will now use the 24 hour clock by default in non-US regions. (#839 - Credit: @Zucht).  

___
**Version 10.82 [ September 18th 2018 ]**

**New Additions:**  
Added toggle option for the New Item Glow in your bags. (#452)  
Added an option to hide the honor databar below max level. Disabled by default.  
Add width override for nameplate auras. (#142)  


**Bug Fixes:**  
Fixed a rare nil error in the range code.  


**Misc. Changes:**  
Added Infested affix buff to RaidBuffsElvUI filter.  
Updated ArenaPrepFrame functions (Thanks oUF)!  
Updated PvP, LFG & Talent skins.  

___
**Version 10.81 [ September 6th 2018 ]**

**New Additions:**  


**Bug Fixes:**  
Fixed issue with display of Attonement in Buff Indicators when the Trinity talent is active. (#346)  
Fixed issue with "out of range" display on UnitFrames on the Mother encounter in Uldir. (#767)  


**Misc. Changes:**  
Added BfA Dungeon debuffs to RaidDebuff filter. Credit: Dharwin & Rubgrsch.  
Removed T-18 4 PC Bonus from the Druid Buff Indicator.  

___
**Version 10.80 [ September 2nd 2018 ]**

**New Additions:**  
Added toggle option for Cutaway health on Nameplates.  
Added dedicated backdrop color option to chat panels.  
Added backdrop color option to Chat Panels.  
Added Seafarer's Dubloon to the Currency Datatext.  
Added Strata option for the Bags.  
Added a temp mover for the Scrapping Machine Frame.  


**Bug Fixes:**  
Fixed Nameplate Cutaway health not following Style Filter Health Color changes.  
Fixed the AltPowerBar enable toggle not requiring a reload.  
Fixed Blizzard Forbidden Nameplates not spawning in the world when Nameplate module was enabled.  
Fixed the default position for the UIWidgetTopCenter mover.  
Fixed issue with chat frames and data panels disappearing. (#686)  
Fixed statusbars on the ToyBox & Heirloom tab in the collection skin.  
Fixed issue which prevented debuff highlight from working for shadow priests and diseases.  
Fixed channel ticks for Penance with talent 'Castigation'  


**Misc. Changes:**  
Removed Legion debuffs  
Updated BfA consumables buffs  

___
**Version 10.79 [ August 20th 2018 ]**

**New Additions:**  
Added Tranquility channel ticks. (#586)  
Added Phase Indicator for Target, Party and Raid frames (Thanks @ls-).  
Added Cutaway Health to nameplates (part of #331).  
Added BFA Mission Datatext (Thanks @AcidWeb).  
Added ActionBar option to color Keybind Text instead of Button.  
Added Alternative Power Bar. The settings are located under `/ec - General - Alternative Power`.  


**Bug Fixes:**  
Fixed a texture issue on the Talent skin. (#566)  
Fixed bags from being shown over the WorldMapFrame. (#592)  
Fixed an issue which caused the cooldown module to error: `Font not set` (#548)  
Fixed an issue which prevented the frame glow being shown on a UnitFrame with the Frame Orientation set to right. (#558)  
Fixed skin issue with Mission Talent Frame.  
Fixed issue which prevented clicking in the top-right of screen where Minimap is by default (when the Minimap is not actually there).  
Fixed Stagger class bar auto-hide (Thanks to Jimmy Pruitt).  
Fixed Ace3 plus/minus on some scrollbars (#631 - Thanks @sezz).  


**Misc. Changes:**  
Updated spell id for Earth Shield. (#527)  
Updated SpellHighlightTexture in the Spellbook. (#547)  
Updated WarboardUI skin.  
Updated Communities skin.  
Open PVP frame when you click on the Honor bar.  
Updated the Spec Switch Datatext.  
Added a toggle in General for Voice Overlay.  
Allowed Special Aura filters to be localized.  
Skin Ace3 Keybinding Widget (Thanks @sezz).  
Updated `LibActionButton-1.0-ElvUI` to handle #375 (Thanks @sezz).  
Added support for mages in Debuff Highlight, they can once again remove curses.  
Updated code which shows item level in tooltip (Thanks @AcidWeb).  
Auto-Disable ElvUI_EverySecondCounts as it is retired now.  
Aura Special Filters can now be localized.  
Skin the QuickJoinToastButton.  
Updated Chat Emojis.  

___
**Version 10.78 [ July 28th 2018 ]**

**New Additions:**  


**Bug Fixes:**  
Fixed CVar `chatClassColorOverride` not working correctly.  
Fixed errors which occurred in `OrderHallTalentFrame` and `Contribution` skins.  
Fixed memory leaking from `GetPlayerMapPosition` API. (Thanks to Rubgrsch and siweia)!  
Fixed bags not properly showing items when searched.  
Fixed an issue that sometimes the chat scrollBars where not hidden properly.  


**Misc. Changes:**  
Re-enable the old Guild skin back.  
Updated Communities, PVP & Tooltip skins.  

___
**Version 10.77 [ July 20th 2018 ]**

**New Additions:**  
Added a mover for the Chat buttons.  


**Bug Fixes:**  
Reworked the Microbar mouseover handler. (#523)  
Fixed issue which caused community chats to be shown in all chat frames.  


**Misc. Changes:**  
Updated `Setup Chat` part of installer to enable class colors in all channels and communities.  
Updated CommunitiesUI skin.  
Added support for chat filters for community channels displayed in the real chat window.  

___
**Version 10.76 for patch 8.0 [ July 19th 2018 ]**

**New Additions:**  


**Bug Fixes:**  
Fixed issue with backdrop on tooltips turning blue.  
Fixed error when pressing 'Enter' to start typing in the chat. (#485)  


**Misc. Changes:**  
Added skins from Simpy for Artifact Appearance and Orderhall Talents.  
Added support for Load On Demand addons' memory/cpu usage display in tooltips (credit: cqwrteur).  
Fixed a texture issue in the Quest Log skin.  
Updated skinning of the 'TodayFrame' in the calendar. It uses skinning from Azilroka.  

___
**Version 10.75 for patch 8.0 [ July 17th 2018 ]**

**New Additions:**  
New Cooldown settings, they can be found in the Cooldowns category or by typing `/ec cooldown`.  
Added Death Knight Rune sorting option under `/ec - Player Frame - Classbar - Sort Direction`.   
Added new Azerite DataBar (replaces Artifact DataBar).  
Added button size and spacing options to the Micro Bar.  
Added scale option for the smaller world map.  
Added new skins for the new elements in patch 8.0.  
Added the original chat buttons to a dedicated panel which can be toggled by right-clicking the "<" character in the left chat panel.  


**Bug Fixes:**  
Fixed issue with UnitFrame Mouseglow when Portraits was enabled in non-overlay mode.  
Fixed error when attempting to right click a fake unitframe spawned from "Display Frames" by unregistering mouse on these frames.  
Fixed issue with Guild Bank which sometimes prevented icons from being desaturated during a search while swapping between bank tabs. This also corrects the strange delay it appeared to have.  
Fixed issue which caused chat emojis to hijack hyperlinks.  
Fixed icon border on black market auction house items.  
Fixed `[namecolor]` not updating sometimes when it should.  
Fixed skin issue when using a dropdown in the config.  
Fixed friendly nameplates not showing in Garrisons.  
Fixed issue with tooltip compare being activated when it should not. (#471)  
Fixed several issues with the Micro Bar.   
Fixed error in the Spellbook relating to our Vehicle Button on the minimap and position of the Minimap. (#434)  
Fixed various issues with tooltips. (#472)  


**Misc. Changes:**  
In order to improve load times, ElvUI will no longer load `Blizzard_DebugTools`.  
Reworked the Talent frame skin slightly, in order to improve determination of selected talents.  
Simplify how the Chat module handles Chat Filters. (Thanks Ellypse)  
Changed how icons get shadowed in Guild bank and Bags module.  

___
**Version 10.74 [ June 7th 2018 ]**

**New Additions:**  
Added "Group Spacing" option to party/raid frames. This allows you to separate each individual group.  
Added option to move the Resurrect Icon on the party/raid/raid40 frames.  
Added new UnitFrame Glow settings located under `UnitFrame -> General -> Frame Glow`. Each type of UnitFrame (Player, Target, Etc) has new options to disable these settings individually.  
Added an option `Nameplates -> General -> Name Colored Glow` to use the Nameplate Name Color for the Name Glow instead of Glow Color.  
Added options to override the Cooldown Text settings inside of `Bags`, `NamePlates`, `UnitFrames`, and `Buffs and Debuffs`.  


**Bug Fixes:**  
Fixed instance group size for Seething Shore and Arathi Blizzard.  
Fixed issue that prevented the Guild MOTD from being shown in the chat after a `/reload` sometimes.  
Fixed issue that prevented the Loot Spec icon on BonusRollFrame from showing correctly after changing specs.  
Fixed issue which could cause an error in other addons when Chat History was enabled.  
Fixed issue with range checking on retribution paladins below lvl 78. Until lvl 12 the range will only be melee, then you get Hand of Reckoning which we can use to check range.  
Fixed issue preventing the stance bar buttons to be keybound.  
Fixed issue which caused the Chat History to sometimes attempt to reply to the wrong BattleTag friend. This will only fix BattleTag friend history messages to be linked correctly, while Real ID friends history messages will still suffer from this issue. ref: !44 (Thanks @peuuuurnoel)
Fixed tooltips getting skinned while Tooltip Skin option is disabled.  
Fixed issue which prevented a dropdown from being shown in the world map.  
Fixed an error regarding LeaveVehicleButton in battlegrounds.  
Fixed a typo in datatexts which could prevent LDB data texts from loading when entering world.  
Fixed issue which prevented the "new item" glow from hiding on items in bag 0 when closing bags.  
Fixed various issues with the Targeted Glows on NamePlates.  
Fixed issue which made the Friendly Blizzard plates wider than they should be for some users.  
Fixed issue which may have caused the Nameplate Clickable range to be off more than it should.  
Fixed issue which prevented nameplate glow from wrapping around the enemy castbars.  
Fixed error for shapeshifting druids who enter combat when nameplate classbar is attached to player nameplate.  


**Misc. Changes:**  
The Plugin Installer frame is now movable.  
The Chat Module now supports Custom Class Colors a little better now.  
Chat History will now highlight keywords, allow linking of URLs, and will no longer populate Last Tell for replies.  
Reworked the Equipment Flyout skin.  
Unitframe tags will now return nil instead of an empty string when there is nothing to show.  
Made it more clear that the "vendor greys" button also deletes items when not at vendor.  
The system datatext will now display protocol info (IPv4/IPv6) if applicable. (credit: Kopert)  
Resetting a UnitFrame to default will now show a popup confirmation upon clicking the reset button.  
Nameplate NPC Title Text will now show the glow color on mouseover when it's the only thing shown on the nameplate (health and name disabled with show npc titles turned on).  
E:ShortValue will now floor values below 1000.  
Optimized nameplates a bit, by making sure updates on Blizzard plates would not continue firing after we replaced them with our own.  

___
**Version 10.73 [ March 23rd 2018 ]**

**New Additions:**  
Added color options for Debuff Highlighting.  
Added mover for BonusRollFrame.  
Added option to Enable/Disable individual Custom Texts.  
Added individual font size options to duration and count text on Buffs and Debuffs (the ones near the minimap).  
Added spacing option to unitframe Aura Bars.  
Added an option to show the unit name on the chatbubbles.  
Added option to use BattleTag instead of Real ID names in chat.  
Added option to use a vertical classbar on unitframes.  
Added spacing option for classbar on unitframes. It controls the spacing between each "button" when using the "Spaced" fill.  
Added an option for a detailed report for Vendor Grey Items.  
Added Talent Spec Icon on the tooltip.  
Added Instance Icons on the Saved Instances tooltip. (Thanks Kkthnx for the idea)!  


**Bug Fixes:**  
Fixed issue that would allow quest grey items to be vendored via Vendor Grey Items.  
Fixed rare tooltip error (attempt to index local 'color').  
Fixed error trying to copy settings between nameplate units. (#305)  
Fixed various issues with the keybind feature (/kb). Trying to keybind an empty pet action button will now correctly show a tooltip. Trying to keybind a flyout menu will now correctly show a tooltip too.  
Clicking on a player's name who whispered you or messaged into guild chat via Mobile app will now properly link their name with realm attached.  
Corrected issue which made the UI Scale incorrect after alt-tab during combat when using Fullscreen on higher resolutions. (This will now autocorrect itself after combat ends).  
Fixed issue in which class colored names in chat could still hijack the coloring of some hyperlinks. (This will also allow other hyperlinks to be keywords as well).  
Fixed UI-Scale bug for users over 1080p in Fullscreen mode. (Thanks AcidWeb and Nihilith for helping debug).  
Fixed UI-Scale being off for Mac users as well. (Thank you critklepka for helping debug the Mac scale issue).  


**Misc. Changes:**  
Skinned the new Allied Races frame.  
Skinned a few more tutorial frame close buttons.  
Skinned the Expand/Collapse buttons on various frames.  
Skinned the reward and bonus icons on the PvP Skin.  
Skinned the reward icons with a quality border on the quest skin.  
Skinned the Orderhall/Garrison Portraits.  
Adjusted the Flight Map's font to match the general media font. (#306)  
Added the combat and resting icon texture from Supervillain UI and Azilroka.  
Changed the click needed to reset current session in the gold datatext from Shift+LeftClick to Ctrl+RightClick.  
Added automatic handling of "Attach To" setting on unitframe auras. When setting Smart Aura Position, then the "Attach To" setting will automatically be set for the respective aura type, and then the selection box will be disabled.  
Saved Instances will now be sorted by name then difficulty. (Thanks Kelebek for initial work)!  
Saved Instances will now show Raid Finder lockouts correctly and will also allow heroic dungeons to be shown.  
Updated the New Item Glow to the Bag module. (This will flash on the inside of the slot, based on the slots border color).  
Updated the Quest and Upgrade Icon in the Bag module.  
Added Kin's Forging Strike to Raid Debuffs (for normal+ raids).  

___
**Version 10.72 [ January 28th 2018 ]**

**New Additions:**  
None  


**Bug Fixes:**  
Fixed position of the ElvUI Status Report frame (/estatus).  
Fixed issue updating npc titles on NamePlates.  
Fixed placement issue of name and level on NamePlates when "Always Show Target Healthbar" is disabled.  
Improved workaround for vehicle issue on Antoran High Command (credit: ls-@GitHub).  


**Misc. Changes:**  
The Style Filter action "Name Only" will also display the NPC title now.  
Sorted the Dropdown for Style Filters by Priority (rather than by Name).  
Skinned various tutorial frame close buttons.  

___
**Version 10.71 [ January 23rd 2018 ]**

**New Additions:**  
Added toggle option for the new handling of the "Unspent Talent Alert" frame.  
Added option to control the amount of decimals used for values on elements like NamePlates and UnitFrames.  
Added new "Quick Join" datatext.  
Added new style filter action "Power Color".  
Added options to hide specific sections in the Friends datatext tooltip.  
Added the ability to assign items to bags like in blizzard's ui to our big bag (toggle the bags and right click bag -> assign it).  
Added new command "/estatus" which will show a Status Report frame with helpful information for troubleshooting purposes.  


**Bug Fixes:**  
Fixed issue with missing border colors on some elements after a login or reload.  
Fixed issue in Chat Copy which made it unable to copy dumped hyperlinks properly.  
Fixed issue with arena frames displaying wrong unit in PvP Brawls.  
Fixed issue which caused the MicroBar position to be misplaced during combat.  
Fixed issue which caused the Color Picker default color button to be disabled when it should still be active.  
Fixed error when importing style filters via global (account settings).  
Fixed issue which prevented some Style Filter actions from taking affect. (#282)  
Fixed issue which caused items in the bag to not update correctly (after sorting). (#288)  
Fixed issue which caused the invite via Guild and Friend (non-bnet) datatext to not properly request an invite.  


**Misc. Changes:**  
Updated UnitFrame and NamePlate heal prediction based on oUF changes.  
Various tweaks and fixes to skins and skinned: Recap button & Warboard frame.  
Tweaked sorting in the Friends datatext so WoW is always on top.  
Updated some of the Priest, Monk, and Paladin Buff Indicator spells.  
Style Filter border color action now applies to the Power Bar border as well.  
Stacks on nameplate auras will no longer be hidden when they reach 10 or above.  

___
**Version 10.70 [ December 26th 2017 ]**

**New Additions:**  
Added new style filter triggers "Is Targeting Player" and "Is Not Targeting Player".  
Added new style filter trigger "Casting Non-Interruptible".  
Added new style filter action "Frame Level".  
Added ability to Shift+LeftClick the Gold datatext in order to clear session data.  
Added visibility options to the bag-bar.  
Added visibility options to the microbar.  
Added a Combat-Hide option to role icons on party/raid frames.  
Added option to self-cast with a right-click on actionbuttons.  
Added "Desaturate On Cooldown" option to action bars. It will make icons black&white when the action is on cooldown.  


**Bug Fixes:**  
Changed the vehicle fix we put in place previously. It will only affect the Antorus raid instance now. You no longer need pet frames to see vehicles in old raids.  
Fixed issue with stance bar visibility when switching between specs.  
Fixed issue with aura min/max time left settings in style filter actions.  
Fixed position issue with the nameplate target arrow when portrait was hidden.  
Fixed issue where style filter trigger didn't always set the health color properly.  
Fixed issue which required the user to click "Okay" in the Color Picker before colors updated (this was locked down intentionally for performance reasons, but those issues have been resolved in a different way). Colors will now update as you click the wheel.  
Fixed a performance issue with bag sorting. Sorting should seem a lot smoother, especially for low end computers.  
Suppressed error that could happen when you received a whisper from a friend which WoW had not provided data for yet.  
Fixed issue which broke the Aura step in the install guide.  
Fixed a few issues with auto-invite relating to other realms and multiple friends from the same bnet account.  
Fixed a frame level issue with nameplates which caused them to bleed into each other when overlapped.  
Fixed issue which caused the version check for ElvUI and associated 3rd party plugins to get sent to the addon communications channel excessively. It will now send a lot fewer messages in total.  
Fixed issue which could cause the clickable area on nameplates to use an incorrect size.  
Fixed issue with healer icons in battlegrounds when multiple players had the same name.  
Fixed various issues with the Friend datatext relating to multiple characters or games from the same account.  


**Misc. Changes:**  
Cleaned up code in Friend datatext.  
Friend datatext can now show friends who are playing multiple games and show each character that is on WoW with the ability to invite or whisper each toon via right click menu.
Enhanced the display and sorting of the Friend datatext.  
Shortened the text displayed on the movement speed datatext. This is currently only affecting the English client, but can be modified for other localizations by changing the respective localization string.  
Clicking the Currencies datatext will now open the currencies frame in WoW.  
Updated RaidDebuffs filter and added a few from Tiago Azevedo.  
Removed alert and flash in chat tabs when chat history is displayed after a login or reload.  
Removed IconBorder texture on BagBar bag icons.  
Various font and skin tweaks.  
Skinned the "Unspent Talent Point" alert and positioned it near the top of the screen.  
Changed the default value of "Max Duration" for Target Debuffs to 0.  
Included the minimap location text font in the "Apply To All" option.  
Reverted a backdrop color change on the TradeSkill frame.  
Changed the name format used for the ElvUI nameplates. Previously it was "ElvUI_Plate%d_UnitFrame" and now it is "ElvUI_NamePlate%d".  

___
**Version 10.69 [ December 1st 2017 ]**

**New Additions:**  
Added visibility settings to the Stance Bar. By default it will hide in vehicles and pet battles.  
Added options for Combat Icon on the player unitframe.  
Added options for Resting Icon on the player unitframe.  
Added options for Health font on NamePlates.  
Added option to copy a single chat line by clicking a texture on the left side of it.  
Added raid debuffs for the new Antorus, the Burning Throne raid.  This requires testing and feedback by users.  


**Bug Fixes:**  
Fixed issue with Style Filter scale action.  
Fixed pet type in the pet battle UI for non-English clients.  
Fixed pet type in tooltip for non-English clients.  
Fixed issue with nameplates not updating correctly when leaving a Warframe vehicle.  
Fixed issue with chat history showing incorrect name on messages from BNet friends.  
Fixed issue which caused auras to not respect the Max Duration setting when priority list was empty.  
Fixed issue which may have caused weird behaviour with player nameplate hide delay.  
Fixed issue which caused some Quick Join messages in chat to be duplicated.  
Fixed issue which made it impossible to target raid members in vehicles in the new raid instance. This is a temporary workaround until Blizzard fixes the issue. Until then you need to use Raid-Pet Frames if you need to see vehicles (Malygos, Ulduar etc).  


**Misc. Changes:**  
Various tweaks/updates to a lot of the skins.  
Various code clean-up by Rubgrsch.  
Tweaked pixel perfect code.  
Made sure Style Filters can handle alpha with flash action.  
Moved datatext gold format option into the "Currencies" tab.  
Raid icons will now be displayed as text in the Copy Chat window so they can be copied correctly.  
Chat History now supports multiple chat windows and will display the chat history in the correct chat window according to chat settings.  
Holding down the Alt key while scrolling in the chat will now scroll by 1 line.  
Changed Ace3 skin to no longer add border on SimpleGroup widgets.  
The Quest Choice skin is now enabled by default.  

___
**Version 10.68 [ October 26th 2017 ]**

**New Additions:**  
Added option to show Quick Join messages as clickable links in chat.  
Added option to change duration text position on nameplate auras.  
Added option to change castbar icon position on nameplates.  
Added font outline option for the Threat Bar.  


**Bug Fixes:**  
Fixed issue with nameplate scale not following Style Filter settings on target change.  
Fixed issue with placement of microbar within its mover frame.  
Fixed issue which caused player unitframe to bug out when entering invasion point while in a Warframe.  
Fixed error when setting text color on custom buff indicators.  
Fixed issue preventing you from inviting people on remote chat in Guild datatext.  
Fixed issue which caused classbar to disappear from target nameplate.  
Fixed issue which caused enemy nameplates to break after having targeted a friendly unit in an instance and have the classbar appear above that nameplate.  


**Misc. Changes:**  
Added Beacon of Virtue to Buff Indicator filter.  
Changed default fonts on NamePlates to PT Sans Narrow.  
Changed "XP" to "AP" on the Artifact DataBar.  
Added more game clients to the Friends datatext.  
Skinned the "Skip Cinematic" popup frames.  
Added a separate skin setting for Blizzard Interface Options.  
Changed Loot Frame mover to always be visible when movers are toggled.  
Code clean-up by Rubgrsch.  
Updated some aura filters.  

___
**Version 10.67 [ October 2nd 2017 ]**

**New Additions:**  
None


**Bug Fixes:**  
Fixed error with castbar element (for real this time).


**Misc. Changes:**  
None

___
**Version 10.66 [ October 2nd 2017 ]**

**New Additions:**  
None


**Bug Fixes:**  
Fixed error in castbar element.


**Misc. Changes:**  
None

___
**Version 10.65 [ October 1st 2017 ]**

**New Additions:**  
None  


**Bug Fixes:**  
Fixed issue creating new style filters.  


**Misc. Changes:**  
None  

___
**Version 10.64 [ October 1st 2017 ]**

**New Additions:**  
Added Korean option for the "Numer Prefix Style" setting. This will allow unitframe tags to use the Korean number annotations.  
Added "Match SpellID Only" option to individual RaidDebuff Indicator modules. If disabled it will allow it to match by spell name in addition to spell ID.  
Added possibility of setting alpha of the stack and duration text colors on RaidDebuff Indicator modules.  
Added global option to choose which filter is used for the RaidDebuff Indicator modules. This is found in UnitFrames->General Options->RaidDebuff Indicator.  
Added new "CastByNPC" special filter for aura filtering.  
Added talent triggers for nameplate style filters.  
Added instance type triggers to nameplate style filters.  
Added instance difficulty triggers to nameplate style filters.  
Added classification triggers to nameplate style filters.  
Added toggle option for datatext backdrop. Disabling it will remove the backdrop completely and only show text.  
Added option to hide Blizzard nameplates. If enabled then you will no longer see nameplates with the default Blizzard appearance. This option can be found in the NamePlate General Options.  
Added cooldown trigger to nameplate style filters. This allows you to trigger a filter when one of your spells is either on cooldown or ready to use.  
Added font options for the duration and stack text on nameplate auras. These options can be found in the "General Options -> Fonts" section.  
Added alpha action to nameplate style filters.  
Added "name only" action to nameplate style filters.  
Added flash action to nameplate style filters.  
Added tick width option to player unitframe castbar.  
Added tick color option to player unitframe castbar.  
Added "Auto Add New Spells" option to actionbar general options.  
Added "German Number Prefix" to the "Unit Prefix Style".  
Added Power Threshold trigger to nameplate style filters.  
Added ability to match players own health in the "Health Threshold" trigger for nameplate style filters.  
Added role icons to the RaidUtility frame when in a raid.  


**Bug Fixes:**  
Attempt more fixes towards the unit errors on nameplates.  
Fixed a divide by 0 error in Artifact DataBars.  
Fixed issue which broke stealable border color on unitframe auras while in a duel.  
Fixed issue which broke item links and icons in the profile export when using table or plugin format.  
Fixed issue with AP calculation on items in bags. We no longer use tooltip scanning. We have come up with a much better and accurate way of handling it.  
Fixed issue with position of detection icon on nameplates when using "Name Only".  
Fixed issue with healer icon position when portrait is enabled on nameplates.  
Fixed issue which caused the "Hide" action on nameplate style filters to incorrectly show hidden nameplates if "Hide" was disabled.  
Fixed issue with portrait position on nameplates when healthbar is disabled but forced to be shown on targeted nameplate.  
Fixed issue with chat editbox position when backdrop was enabled/disabled.  


**Misc. Changes:**  
Added and updated spell IDs in the RaidDebuffs filter.  
Added Veiled Argunite to the Currencies datatext tooltip.  
Replaced more Blizzard font elements for panels where fonts were mixed.  
Various skin fixes and tweaks.  
Added stealable border color on nameplate auras.  
Changed default position of role icons on unitframes so they don't overlap with name.  
Moved "Reset Filter" button in the Filters section and added requirement of an additional click to execute.  
Renamed "Number Prefix" option to "Unit Prefix Style".  
Changed the default value for "Unit Prefix Style" from Metric to English.  
Optimized handling of events for the nameplate style filters to reduce performance impact.  
Added new library LibArtifactPower-1.0 by Infinitron. We will use this to improve AP calculations.  
Added possibility of hooking into style filter conditions.  
Fixed a few font elements on Blizzard panels that were not getting replaced with chosen ElvUI font.  
Added skin for the CinematicFrameCloseDialog frame.  
Added skin for the TableAttributeDisplay frame.  
Added some additional spells to the RaidDebuffs and RaidBuffsElvUI filters for M+ dungeons.  

___
**Version 10.63 [ September 9th 2017 ]**

**New Additions:**  
Added quest boss trigger to nameplate Style Filters.  
Added a new default filter named "RaidBuffsElvUI". Meant for buffs provided by NPCs in raids or other PvE content. Both for buffs put on enemies and players.  
Added a "Reset Aura Filters" button for all Buffs, Debuffs and Aura Bars modules on both nameplates and unitframes. This will reset the Filter Priority list to the default state.  
Added a "Reset Filter" button to all default filters in the Filters section of the config. This will completely reset the filter to its original state and remove any spells the user added.  
Added 2 new special filters for Aura Filtering: "CastByPlayers" and "blockCastByPlayers". These can either allow or block all auras cast by player units (meaning not NPCs).  


**Bug Fixes:**  
Fixed rare error in nameplates regarding attempt to use a non-unit value as argument for UnitIsUnit API.  
Fixed taint which prevented kicking someone from guild.  
Fixed issue which caused "Fluid Position" option for Player unitframe to go missing. (Abeline)  
Fixed rare error in nameplates when changing target.  
Fixed issue which may have caused some nameplate elements to stay visible when nameplate was not.  
Fixed issue which caused nameplate mouseover highlight to stay visible until you moused over another unit.  


**Misc. Changes:**  
Changed how we control state of filters used in filter priority lists. Now you use Shift+LeftClick to toggle between friendly, enemy and normal state on a filter.  
Tweaked default settings for aura filter priority lists based on feedback from users.  
Added skin for NewPetAlertFrame.  
Removed caching of HandleModifiedItemClick to allow hooks to fire from other addons.  
Fixed spell ID for Consuming Hunger in the RaidDebuffs filter.  

___
**Version 10.62 [ August 30th 2017 ]**

**New Additions:**  
The enabled state of a Style Filter for nameplates is now stored in your profile instead of being global.  
Added "Role" to Style Filter triggers. Your current role has to match this before a filter is activated. If no role is selected then it will ignore this trigger and try to activate.  
Added "Class" to Style Filter triggers. You can select which classes and specs this filter should activate for. Your current class and spec has to match this before a filter is activated. If no spec is selected then it will only match class.  
Added "blockNonPersonal" special filter for aura filtering. Combine this filter with a whitelist in order to only see your own spells from this whitelist.  


**Bug Fixes:**  
Fixed rare error in nameplates regarding attempt to use a non-unit value as argument for UnitIsUnit API.  


**Misc. Changes:**  
Updated Ace3 libraries.  
Values on the Artifact DataBar tooltip will now use the short format provided by ElvUI.  
Changed various default settings for aura filtering in order to lessen the confusion for users.  
Added Veiled Argunite to Currencies datatext.  
Disabled the "Boss" Style Filter by default.  
Updated LibActionButton.  

___
**Version 10.61 [ August 29th 2017 ]**

**New Additions:**  
None  


**Bug Fixes:**  
Fixed issue which broke the Ace3 config of other addons.  


**Misc. Changes:**  
Reverted some changes to Profiles section of ElvUI.  

___
**Version 10.60 [ August 29th 2017 ]**

**New Additions:**  
MAJOR: Added "Style Filters" to NamePlates, allowing you to perform various actions on specific units that match your chosen filter settings.  
MAJOR: Added a new aura filtering system to NamePlates and UnitFrames. This new system is much more advanced and should allow you to set up the filters exactly how you want them.  
Added enhanced target styles for NamePlates. A cool glow and arrows have been added, along with the ability to change their color.  
Added mouseover highlight to the NamePlates.  
Added movement speed datatext. (Rubgrsch)  
Added a "Fluid Position" option to Smart Aura Position settings. This will use the least amount of spacing needed. (Abeline)  
Added a "yOffset" option to Aura Bars on Player, Target and Focus unitframe. (Abeline)  
Added Portrait option to NamePlates. This was also added as an action in style filters.  


**Bug Fixes:**  
Fixed an error when entering combat while game is minimized.  
Fixed scaling of the Leave Vehicle button on the minimap. (Hekili)  
Fixed Bagbar buttons border size. (Rubgrsch)  
Fixed error when switching profile while having player unitframe disabled.  
Fixed issue which caused unitframe tags containing literals to use OnUpdate instead of their assigned events. (Martin)  
Fixed issue which could break actionbar paging when the code contained the new-line character (\n)  


**Misc. Changes:**  
Updated a lot of skins.  
Updated Chinese localization. (Rubgrsch)  
Artifact DataBar tooltip will now show the artifact name and only show points to spend when you can actually spend some. (Kkthnx)  
Updated RaidDebuffs filter with more ToS debuffs.  
Default chat bubbles can now use the ElvUI chat bubble font unless it was disabled.  
Removed "Hide In Instance" option for chat bubbles.  
Changed the max font size for General Font to a softmax. You can manually input a value higher than the slider allows.  
The ElvUI logo has been updated with design by RZ_Digital.  
The default color in ElvUI has been changed to match the new logo.  
Disabled "Text Toggle on NPC" by default, as it caused confusion for new players.  
Restructured the UnitFrame sections of the ingame config. It now uses tabs instead of the often overlooked dropdown.  
Added shortcut buttons to the ActionBars and UnitFrames main pages.  
Added Drag&Drop support to AceConfig buttons for our new aura filtering system.  

___
**Version 10.59 [ June 27th 2017 ]**  

**New Additions:**  
None

**Bug Fixes:**  
Fixed error when having Masque enabled but having ElvUI skinning disabled within Masque settings.  
Fixed rare error in world map coords. (Simpy)  
Fixed "script ran too long" error when jumping from Skyhold to Dalaran.  
Fixed a few "attempt to access forbidden object" errors relating to tooltip. We can't fix them all, Blizzard need to step in here.  
Fixed error in reagent bank caused by trying to index a missing questIcon object.  
  
**Misc. Changes:**  
Invalid tags on unitframes will now display the used tag text instead of [invalid tag].  
Added some spell IDs for ToS to RaidDebuffs filter. Probably not complete, community will need to provide feedback and fill in the blanks. (Merathilis)  
Units in different phases will now always have their unitframe be displayed as out of range.  
Various skin tweaks and fixes.  
