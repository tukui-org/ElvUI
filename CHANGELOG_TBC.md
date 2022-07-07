### Version 2.48 [ July 7th 2022 ]

Optimizations: Fixed an issue when using ElvUI and WeakAuras together, which caused  
increased loading screens and some auras to disappear. (Script ran too long error)  

ActionBars: Fixed bar backdrop multiplier (ticket #245)  
DataTexts: Added Diablo Immortal and Warcraft Arclight Rumble support for Friends  
DataTexts: Added NoLabel option for Intellect  

___
### Version 2.47 [ May 31th 2022 ]

ActionBars: Stance bar fixes (issue #163)  
DataTexts: Added noLabel option for combat timer text  
DataTexts: Added spell haste (ticket #176)  
DataTexts: Fixed spell hit  
Filters: Added SSC, TK, MH, BT, SWP RaidBuffs  
Filters: Added SWP RaidDebuffs  
Locales: Updated deDE (Credits: Dlarge)  
NamePlates: Fixed class color source option for interrupts  
UnitFrames: Added option to color health based on pet happiness  
UnitFrames: Fixed overlapping master looter icon on RaidFrames  
UnitFrames: Fixed power text getting misplaced onto health if power is hidden (issue #15)  

___
### Version 2.46 [ May 8th 2022 ]

NamePlates: fixed target indicator displaying many arrows  
DataTexts: added label / no label for durability and bags  
DataTexts: custom labels can be colorized with color tags  

___
### Version 2.45 [ May 6th 2022 ]

StyleFilter: fix a couple import and export bugs  
Chat: block other secure commands like /focus from being saved to editbox history  
NamePlates: fixed debuffs being able to attach to debuffs in options  
NamePlates: block widget tooltips on forbidden nameplates  
NamePlates: added new Prefer Target Color option along with Low Health Color and Low Health Half color settings  
Cooldowns: fixed Rogue Stealth displaying as nan and flashing too often  
Skins: Chat Config Toggle button is now skinned  
ActionBars: fixed microbar LFG icon being sized incorrectly  

___
### Version 2.44 [ May 1st 2022 ]

Aurabars: Fixed alignment with size override setting  
Locales: Updated deDE (Credits: Dlarge)  
Locales: Updated zhTW (Credits: fang2hou)  
Misc: Fixed Raid Utility not saving position correctly  
Nameplates: Added ability to export and import selected style filters  
Tooltip: Added font options for tooltip header  
UnitFrames: Readded "Start Near Center" option for party  

___
### Version 2.43 [ April 20th 2022 ]

UnitFrames: Add ability to change pet happiness colors  
UnitFrames: Add ability to hide Rest Icon at max level  
UnitFrames: Add ability to scale the Raid Role Icon  
UnitFrames: Readd missing option to Show/Hide Spec Icon on Arena frames  
Skins: Adjusted the 2 tabs on the Macro skin to accommodate larger toon names  
Tooltips: Fix tooltip count on Enchant crafting window when mousing over the reagents  

___
### Version 2.42 [ April 9th 2022 ]

NamePlates: Add missing Style Filter defaults for party/raid  
NamePlates: Add Not Resting, No Target style filter condition  

___
### Version 2.41 [ April 5th 2022 ]

Chat: Repaired gold text will now match Vendored Grays gold format  
Skins: Fixed guild information skin border  
Skins: Updated EventTrace  
Skins: Updated tradeskill searchbox skin  
Tags: Added [group:raid] which displays current group number only while in a raid  

___
### Version 2.40 [ March 29th 2022 ]

Skins: Fix mailbox skin when attachments exceeded the first row  
StyleFilter: Added several Unit Condition triggers: Another Players Pet, Guild, Trivial, Connected, Conscious, Possessed, Charmed states, Dead / Alive, and Being Resurrected   
UnitFrames: Fix castbar custom backdrop color if set to a class color from not displaying other class colors properly if using the same profile that originally set the option  
UnitFrames: Fix castbar custom backdrop when using reverse option  
UnitFrames: Fixed range (again)  

___
### Version 2.39 [ March 23rd 2022 ]

Auras: Re enabled top auras, blizzard pushed a hotfix  

___
### Version 2.38 [ March 23rd 2022 ]

Auras: Turned off ElvUI top auras until Blizzard fixes the bug (Untick "Disable Blizzard" if you want to see default auras)  
Chat: Updated chat installer (Requires you to re-run the chat installer)  
Skins: Fixed mailbox skin and errors  
UnitFrames: Fixed aura rows overlapping  
UnitFrames: Paladins can now always see magic dispells  

___
### Version 2.37 [ March 20th 2022 ]

General: Fixed error in the loot skin  
Libraries: Fixed another HealComm error  
Locales: Updated Chinese (thanks to Loukky!)  
Locales: Updated German (thanks DlargeX)  
MiniMap: Fixed LFG in middle click minimap menu  
Options-AuraBars: Fixed custom backdrop color setting  
Options-Nameplate: Fixed clickable size not updating height slider max values  
Options-StyleFilter: Allowed lower scale options  
Options-StyleFilter: Fixed error about triggers  
Tags: [classification] is localized now  
UnitFrames: Clique to handle mousedown state if enabled  
UnitFrames: Fixed an issue with middle click focus  
UnitFrames: Fixed AuraBars sorting  
UnitFrames: Fixed text color flickering on aura watch indicators  
UnitFrames: Updated code for AuraBars anchoring (Works better attached to centered elements)  
UnitFrames: Updated oUF to fix arena units not updating properly  

___
### Version 2.36 [ February 22nd 2022 ]

**Important**  
Another overall performance update  
Please post feedback in the elvui-performance channel on our Discord  

**Changes**  
Chat: Fixed chat alerts playing on chat history  
General: Minimap mover will match Minimap that has a scale other than one  
Locales: Updated Russian translation (Credits Enkaf)  
NamePlates: Fixed Aura Style Filters not triggering because of the element being disabled  
NamePlates: Fixed errors when deleting a Style Filter  
UnitFrames: Aura Bars will now work with Fluid Smart Aura positioning  
UnitFrames: PVP Indicator working again  
UnitFrames: Raid Role Indicator now supports Main Assist and Main Tank  

___
### Version 2.35 [ February 12th 2022 ]

**Important**  
Increased overall performance (should be noticable in raids and battlegrounds).  
Please post feedback in the elvui-performance channel on our Discord  

**Changes**  
Bank: Improved bank performance, fixed items not updating  
Chat: Fixed Copy Chat Lines  
Cosmetic: Fixed AutoCast Shine custom glow  
Skins: Updated materials checkbox skin (first aid/enchant)  
UnitFrames: Added additional power options  
UnitFrames: Added heal prediction to frames missing it  
UnitFrames: Classbar in Druid Bear Form can now display Mana  
UnitFrames: Fixed aura bar flickering  
UnitFrames: Improved aura positioning and performance  

___
### Version 2.34 [ January 24th 2022 ]

Auras: Added color toggles for enchants & debuffs  
Skins: Fixed another Raid.lua skin error  
UnitFrames: LibHealComm fixes for Warlock & Hunter  

___
### Version 2.33 [ January 18th 2022 ]

Skins: Fixed errors in Raid.lua  
Libraries: Adjusted LibClassicSpecs to not break VuhDo  
UnitFrames: Fixed AuraBars font issue  

___
### Version 2.32 [ January 18th 2022 ]

**Important**  
ActionBars: Swapped to Custom Glow (General -> Cosmetic)  
Config: Added Search section (with Whats New button)  

**Changes**  
Auras: Tooltip fixes for top auras  
Config: Fixed some options displaying in russian  
DataTexts: Fixes for party invites  
Filters: Updated RaidDebuffs for phase 3 raids  
General: Added an option to load max camera distance on login  
Libraries: Added LibClassicSpecs for roles and specs  
Minimap: Scaling and Font fixes  
Misc: LootRoll has several new options  
NamePlates: Fixed error when deleting a StyleFilter  
Skins: Updated Raid Manager  
UnitFrames: Added an option to toggle Blizzards default Castbar  
UnitFrames: Adjusted spark for EnergyManaRegen ticks  
UnitFrames: Fixed "attach to" option for Ready Check Icon  
UnitFrames: Fixed non attached Castbar Icon  
UnitFrames: Fixed sort by class  
UnitFrames: LibHealComm-4.0 for HoTs  

___
### Version 2.31 [ December 4th 2021 ]

ActionBars: Fixed layering issue (Keybinds on Pet Bar)  
Bags: Added an option to hide Gold  
Bags: Fixed an issue with mouseover tooltip  
Chat: Added an option to hide channel names  
DataTexts: Fixed Bags DataText  
Minimap: Added option to scale the Minimap  
Misc: Reworked LootRoll and added options  
NamePlates: Updated StyleFilter config  
Skins: Fixed button hover glow in GuildBank  
UnitFrames: Added reverse fill option for Aura Bars  
UnitFrames: Updated spark for EnergyManaRegen ticks  

___
### Version 2.30 [ November 24th 2021 ]

DataTexts: Updated Friends  
NamePlates: Updates for StyleFilter config  
Skins: Updated trade window  
UnitFrames: Fixed an issue with transparent power color  
UnitFrames: Smart Raid Filter defaults to 5 groups for "Raid" now (8 for Raid40)  

___
### Version 2.29 [ November 19th 2021 ]

UnitFrames: Castbar color hotfix  
UnitFrames: ChannelTicks hotfix  

___
### Version 2.28 [ November 19th 2021 ]

Map: Fixes for the fade while moving option  
Minimap: Updated middle-mouse dropdown  
NamePlates: Reset CVar fix for non-selected unit alpha (Fixes Setup CVar step in the installer as well.)  
Tags: Fixed threatcolor  

___
### Version 2.27 [ November 16th 2021 ]

ActionBars: Fixed Microbar bugs  

___
### Version 2.26 [ November 16th 2021 ]

Cooldown Text: Updates for Bag CD text  
DataTexts: Fixed Spell Hit lua error  
DataTexts: Fixed Haste Datatext Customization Settings  
DataTexts: Readded the Haste DT Tooltip  
Tooltips: Fixed an error with item quality  
UnitFrames: Fixed castbar/custom colors  

___
### Version 2.25 [ November 14th 2021 ]

ActionBars: Fixed quick keybind mode for Pet Bar  
Bags: Fixed bank not updating correctly  
Cooldown Text: Added a global option for rounding  
DataBars: Fixed "Show Bubbles" for Pet Experience  
DataTexts: Fixed MovementSpeed not updating  
Nameplates: Fixed scaling issue which broke default friendly plates in dungeons  
Tooltips: Added an option to display Item Count while using the Modifier for ids  

___
### Version 2.24 [ November 12th 2021 ]

Chat: Fixes for overflowing chat tabs  
Cooldown Text: Fixed issues with HH:MM and MM:SS  
Locales: Updated Russian translation (Credits Hollicsh)  
Minimap: Added back options for Battlefield icon  
Minimap: Slightly adjusted defaults and size for lfg/tracking/battlefield  
Skins: Updated Enchanting skin  
Skins: Updated estatus  
UnitFrames: Fixed Focus and FocusTarget  
UnitFrames: Fixed Rogue fading issue finally  

___
### Version 2.23 [ November 11th 2021 ]

Bags: Added Auto toggle options to open bags with specific frames  
Bags: Fix main bag icon when bag module is off (Bag skin)  
DataBars: Fixed an error in experience bar when entering a dungeon  
DataBars: Fixed issues in PetExperience and show only on Hunters  
DataTexts: Fixed Battlestats  
DataTexts: Updated Movementspeed  
Filters: Fixed AuraBar colors not setting the selected color  
General: Fixed interrupt announce for real  
Locales: Updated Russian translation (Credits Hollicsh)  
Minimap: Added back Quest Log to middle-mouse dropdown  
Misc: Added back chat print for vendor grays  
Tags: Added back pvp tags  

___
### Version 2.22 [ November 9th 2021 ]

Bags: Added an option to enable/disable Quest icons  
Bags: Use Blizzards new coin icons  
DataBars: Added Quest XP in Experience bar  
DataBars: Fixed / Re-added Threat bar  
DataTexts: Fixed invite function for guild datatext  
Libraries: LibClassicDurations Minor 69  
Locales: Updated russian translation (Credits Hollicsh)  
Skins: Fixed an error in Battleground Score  
Skins: Fixed an error in Blizzard Options  
Tooltips: Fixed an error if ElvUI skin was disabled  
UnitFrames: Fixed an error in power bars  
UnitFrames: Master Looter indicator fixes  
UnitFrames: Out of range fader fixes  
UnitFrames: Raid Debuffs position fixes  

___
### Version 2.21 [ November 5th 2021 ]

ActionBars: Added keybind mode for Stance Bar  
Bags: Added back quest icon for quest items  
Bags: Special color fixes (Soul Shards)  
DataTexts: Added left panel defaults ([1] and [3] were empty)  
General: Updated RaidUtility  
Locales: Updated russian translation (Credits Hollicsh)  
Minimap: Fixes for minimap addon icons  
Nameplates: Added back offset options for power  
Nameplates: Fixed an issue which broke the "Add Filter" dropdown  
UnitFrames: Added back Master Looter indicator  
UnitFrames: Fixed resurrect icon for real  
UnitFrames: Updated out of range fader  

___
### Version 2.20 [ November 4th 2021 ]

Bags: Fixed BagBar backdrop for only backpack option  
Bags: Fixed BagBar bags not toggling bags  
Bags: Protect reagent from firing  
Chat: Fixed class color chat names cvar  
Chat: Fixed voice chat buttons  
DataTexts: Guild text now toggles guild roster  
General: Added back quest movers and option in Blizz UI Improvements  
General: Added back widget movers  
General: Announce interrupts fixed  
Nameplates: Add aura sorting  
Tooltips: Fixed item quality color  
UnitFrames (Arena): fixed pvp spec error  
UnitFrames (Arena): fixed spec error  
UnitFrames: Added back tank & assist heal prediction  
UnitFrames: Adjust smart visibility  
UnitFrames: Classbar fixed  
UnitFrames: Dispell list fixed  
UnitFrames: Fixed class sort order  
UnitFrames: Fixed combo points when target changing  
UnitFrames: Re-add Resurrect/Summon Icons  

___
### Version 2.19 [ November 2nd 2021 ]

Added guild option for auto repair  
Added phase 2 support for our custom RaidDebuffs list  
Fixed combo points not updating correctly on target switch  
Master Looter & Loot Roll fixes  
Updated color picker skin  
Updated threat for NamePlates  
