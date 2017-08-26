**Version 10.60 [  ]**

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