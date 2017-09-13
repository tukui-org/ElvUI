**Version 10.64 [ ]**

**New Additions:**  
Added Korean option for the "Numer Prefix Style" setting. This will allow unitframe tags to use the Korean number annotations.  
Added "Match SpellID Only" option to individual RaidDebuff Indicator modules. If disabled it will allow it to match by spell name in addition to spell ID.  
Added possibility of setting alpha of the stack and duration text colors on RaidDebuff Indicator modules.  
Added global option to choose which filter is used for the RaidDebuff Indicator modules. This is found in UnitFrames->General Options->RaidDebuff Indicator.  
Added new "CastByNPC" special filter for aura filtering.  


**Bug Fixes:**  
Attempt more fixes towards the unit errors on nameplates.  
Fixed a divide by 0 error in Artifact DataBars.  


**Misc. Changes:**  
Added and updated spell IDs in the RaidDebuffs filter.  
Added Veiled Argunite to the Currencies datatext tooltip.  
Replaced more Blizzard font elements for panels where fonts were mixed.  
Various skin fixes and tweaks.  

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