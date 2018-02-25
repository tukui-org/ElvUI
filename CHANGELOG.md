**Version 10.73 [  ]**

**New Additions:**  
Added color options for Debuff Highlighting.  
Added mover for BonusRollFrame.  
Added option to Enable/Disable individual Custom Texts.  
Added individual font size options to duration and count text on Buffs and Debuffs (the ones near the minimap).  


**Bug Fixes:**   
Fixed rare tooltip error (attempt to index local 'color').  
Fixed error trying to copy settings between nameplate units (#305).  


**Misc. Changes:**  
Skinned the new Allied Races frame.  
Skinned a few more tutorial frame close buttons.  
Skinned the Expand/Collapse buttons on various frames.  
Skinned the reward and bonus icons on the PvP Skin.  
Adjusted the Flight Map's font to match the general media font (#306).  
Added the combat and resting icon texture from Supervillain UI and Azilroka.  
Changed the click needed to reset current session in the gold datatext from Shift+LeftClick to Ctrl+RightClick.  

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
Fixed issue (#282) which prevented some Style Filter actions from taking affect.  
Fixed issue (#288) which caused items in the bag to not update correctly (after sorting).  
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
Fixed issue which made it impossible to target raid members in vehicles in the new raid instance. This is a temporary workaround until Blizzard fixes the issue. Until then you need to use Raid-Pet Frames if you need to see vehicles (Malygos, Ulduar etc.).  


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