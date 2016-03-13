-- Italian localization file for itIT.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "itIT");
if not L then return; end

--TEMP
L["A taint has occured that is preventing you from using the queue system. Please reload your user interface and try again."] = true;

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "The addon %s is not compatible with ElvUI's %s module. Please select either the addon or the ElvUI module to disable."

--*_MSG locales
L["LOGIN_MSG"] = "Welcome to %sElvUI|r version %s%s|r, type /ec to access the in-game configuration menu. If you are in need of technical support you can visit us at http://www.tukui.org"

--ActionBars
L["Binding"] = true;
L["Key"] = true;
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
L["No bindings set."] = true;
L["Remove Bar %d Action Page"] = true;
L["Trigger"] = true;

--Bags
L["Bank"] = true;
L["Deposit Reagents"] = true;
L["Hold Control + Right Click:"] = true;
L["Hold Shift + Drag:"] = true;
L["Purchase Bags"] = true;
L["Purchase"] = true;
L["Reagent Bank"] = true;
L["Reset Position"] = true;
L["Show/Hide Reagents"] = true;
L["Sort Tab"] = true; --Not used, yet?
L["Temporary Move"] = true;
L["Toggle Bags"] = true;
L["Vendor Grays"] = true;

--Chat
L["AFK"] = true; --Also used in datatexts and tooltip
L["DND"] = true; --Also used in datatexts and tooltip
L["G"] = true;
L["I"] = true;
L["IL"] = true;
L["Invalid Target"] = true;
L["O"] = true;
L["P"] = true;
L["PL"] = true;
L["R"] = true;
L["RL"] = true;
L["RW"] = true;
L["says"] = true;
L["whispers"] = true;
L["yells"] = true;

--DataTexts
L["(Hold Shift) Memory Usage"] = true;
L["AP"] = true;
L["App"] = true;
L["Arena"] = true;
L["AVD: "] = true;
L["Avoidance Breakdown"] = true;
L["Bandwidth"] = true;
L["Building(s) Report:"] = true;
L["Character: "] = true
L["Chest"] = true;
L["Combat"] = true;
L["copperabbrev"] = "|cffeda55fc|r" --Also used in Bags
L["Defeated"] = true;
L["Deficit:"] = true;
L["Download"] = true;
L["DPS"] = true;
L["Earned:"] = true;
L["Feet"] = true;
L["Friends List"] = true;
L["Friends"] = true; --Also in Skins
L["goldabbrev"] = "|cffffd700g|r" --Also used in Bags
L["Hands"] = true;
L["Head"] = true;
L["Hit"] = true;
L["Hold Shift + Right Click:"] = true;
L["Home Latency:"] = true;
L["HP"] = true;
L["HPS"] = true;
L["Legs"] = true;
L["lvl"] = true;
L["Main Hand"] = true;
L["Mission(s) Report:"] = true;
L["Mitigation By Level: "] = true;
L["Multistrike"] = true;
L["Naval Mission(s) Report:"] = true;
L["No Guild"] = true;
L["Offhand"] = true;
L["Profit:"] = true;
L["Reset Data: Hold Shift + Right Click"] = true;
L["Saved Raid(s)"] = true;
L["Server: "] = true;
L["Session:"] = true;
L["Shoulder"] = true;
L["silverabbrev"] = "|cffc7c7cfs|r" --Also used in Bags
L["SP"] = true;
L["Spec"] = true;
L["Spent:"] = true;
L["Stats For:"] = true;
L["Total CPU:"] = true;
L["Total Memory:"] = true;
L["Total: "] = true;
L["Unhittable:"] = true;
L["Waist"] = true;
L["Wrist"] = true;
L["|cffFFFFFFLeft Click:|r Change Talent Specialization"] = true;
L["|cffFFFFFFRight Click:|r Change Loot Specialization"] = true;

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = true;
L["No locals to dump"] = true;

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = true;
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = true;
L["Data From: %s"] = true;
L["Filter download complete from %s, would you like to apply changes now?"] = true;
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = true;
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = true;
L["Profile download complete from %s, would you like to load the profile %s now?"] = true;
L["Profile request sent. Waiting for response from player."] = true;
L["Request was denied by user."] = true;
L["Your profile was successfully recieved by the player."] = true;

--Install
L["Aura Bars & Icons"] = true;
L["Auras Set"] = true;
L["Auras"] = true;
L["Caster DPS"] = true;
L["Chat Set"] = true;
L["Chat"] = true;
L["Choose a theme layout you wish to use for your initial setup."] = true;
L["Classic"] = true;
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = true;
L["Config Mode:"] = true;
L["CVars Set"] = true;
L["CVars"] = true;
L["Dark"] = true;
L["Disable"] = true;
L["ElvUI Installation"] = true;
L["Finished"] = true;
L["Grid Size:"] = true;
L["Healer"] = true;
L["High Resolution"] = true;
L["high"] = true;
L["Icons Only"] = true; --Also used in Bags
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = true;
L["Importance: |cff07D400High|r"] = true;
L["Importance: |cffD3CF00Medium|r"] = true;
L["Importance: |cffFF0000Low|r"] = true;
L["Installation Complete"] = true;
L["Layout Set"] = true;
L["Layout"] = true;
L["Lock"] = true;
L["Low Resolution"] = true;
L["low"] = true;
L["Movers unlocked. Move them now and click Lock when you are done."] = true;
L["Nudge"] = true;
L["Physical DPS"] = true;
L["Please click the button below so you can setup variables and ReloadUI."] = true;
L["Please click the button below to setup your CVars."] = true;
L["Please press the continue button to go onto the next step."] = true;
L["Resolution Style Set"] = true;
L["Resolution"] = true;
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = true;
L["Setup Chat"] = true;
L["Setup CVars"] = true;
L["Skip Process"] = true;
L["Sticky Frames"] = true;
L["Tank"] = true;
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = true;
L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = true;
L["Theme Set"] = true;
L["Theme Setup"] = true;
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = true;
L["This is completely optional."] = true;
L["This part of the installation process sets up your chat windows names, positions and colors."] = true;
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = true;
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = true;
L["This resolution requires that you change some settings to get everything to fit on your screen."] = true;
L["This will change the layout of your unitframes and actionbars."] = true;
L["Trade"] = true;
L["Welcome to ElvUI version %s!"] = true;
L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."] = true;
L["You can always change fonts and colors of any element of elvui from the in-game configuration."] = true;
L["You can now choose what layout you wish to use based on your combat role."] = true;
L["You may need to further alter these settings depending how low you resolution is."] = true;
L["Your current resolution is %s, this is considered a %s resolution."] = true;

--Misc
L["ABOVE_THREAT_FORMAT"] = '%s: %.0f%% [%.0f%% above |cff%02x%02x%02x%s|r]'
L["Average Group iLvl:"] = true;
L["Bars"] = true; --Also used in UnitFrames
L["Calendar"] = true;
L["Can't Roll"] = true;
L["Disband Group"] = true;
L["Enable"] = true; --Doesn't fit a section since it's used a lot of places
L["Experience"] = true;
L["Farm Mode"] = true; -- Minimap middle click menu
L["Fishy Loot"] = true;
L["iLvl"] = true; --Column header in raidbrowser
L["Important Group Members:"] = true;
L["Left Click:"] = true; --layout\layout.lua
L["Raid Browser"] = true; -- Minimap middle click menu
L["Raid Menu"] = true;
L["Remaining:"] = true;
L["Rested:"] = true;
L["Right Click:"] = true; --layout\layout.lua
L["Show BG Texts"] = true; --layout\layout.lua
L["Talent Spec"] = true; --Column header in raidbrowser
L["Toggle Chat Frame"] = true; --layout\layout.lua
L["Toggle Configuration"] = true; --layout\layout.lua
L["XP:"] = true;
L["You don't have permission to mark targets."] = true;

--Movers
L["Alternative Power"] = true;
L["Archeology Progress Bar"] = true;
L["Arena Frames"] = true; --Also used in UnitFrames
L["Bags"] = true; --Also in DataTexts
L["Bar "] = true; --Also in ActionBars
L["BNet Frame"] = true;
L["BodyGuard Frame"] = true;
L["Boss Button"] = true;
L["Boss Frames"] = true; --Also used in UnitFrames
L["Class Bar"] = true;
L["Classbar"] = true;
L["Experience Bar"] = true;
L["Focus Castbar"] = true;
L["Focus Frame"] = true; --Also used in UnitFrames
L["FocusTarget Frame"] = true; --Also used in UnitFrames
L["GM Ticket Frame"] = true;
L["Left Chat"] = true;
L["Loot / Alert Frames"] = true;
L["Loot Frame"] = true;
L["Loss Control Icon"] = true;
L["MA Frames"] = true;
L["Micro Bar"] = true; --Also in ActionBars
L["Minimap"] = true;
L["MirrorTimer"] = true;
L["MT Frames"] = true;
L["Objective Frame"] = true;
L["Party Frames"] = true; --Also used in UnitFrames
L["Pet Bar"] = true; --Also in ActionBars
L["Pet Castbar"] = true;
L["Pet Frame"] = true; --Also used in UnitFrames
L["PetTarget Frame"] = true; --Also used in UnitFrames
L["Player Buffs"] = true;
L["Player Castbar"] = true;
L["Player Debuffs"] = true;
L["Player Frame"] = true; --Also used in UnitFrames
L["Player Powerbar"] = true;
L["Raid Frames"] = true;
L["Raid Pet Frames"] = true;
L["Raid-40 Frames"] = true;
L["Reputation Bar"] = true;
L["Right Chat"] = true;
L["Stance Bar"] = true; --Also in ActionBars
L["Target Castbar"] = true;
L["Target Frame"] = true; --Also used in UnitFrames
L["Target Powerbar"] = true;
L["TargetTarget Frame"] = true; --Also used in UnitFrames
L["TargetTargetTarget Frame"] = true;
L["Tooltip"] = true;
L["Vehicle Seat Frame"] = true;

--NamePlates
L["Discipline"] = true;
L["Holy"] = true;
L["Mistweaver"] = true;
L["Restoration"] = true;

--Prints
L[" |cff00ff00bound to |r"] = true;
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = true;
L["All keybindings cleared for |cff00ff00%s|r."] = true;
L["Already Running.. Bailing Out!"] = true;
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = true;
L["Battleground datatexts will now show again if you are inside a battleground."] = true;
L["Binds Discarded"] = true;
L["Binds Saved"] = true;
L["Confused.. Try Again!"] = true;
L["No gray items to delete."] = true;
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = true;
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = true;
L["Vendored gray items for:"] = true;
L["You don't have enough money to repair."] = true;
L["You must be at a vendor."] = true;
L["Your items have been repaired for: "] = true;
L["Your items have been repaired using guild bank funds for: "] = true;
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = true;

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = true;
L["Are you sure you want to delete all your gray items?"] = true;
L["Are you sure you want to disband the group?"] = true;
L["Are you sure you want to reset all the settings on this profile?"] = true;
L["Are you sure you want to reset every mover back to it's default position?"] = true;
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = true;
L["Can't buy anymore slots!"] = true;
L["Detected that your ElvUI Config addon is out of date. This may be a result of your Tukui Client being out of date. Please visit our download page and update your Tukui Client, then reinstall ElvUI. Not having your ElvUI Config addon up to date will result in missing options."] = true;
L["Disable Warning"] = true;
L["Discard"] = true;
L["Do you enjoy the new ElvUI?"] = true;
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = true;
L["ElvUI is five or more revisions out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = true;
L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = true;
L["ElvUI needs to perform database optimizations please be patient."] = true;
L["Enabling/Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"] = true;
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = true;
L["I Swear"] = true;
L["It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled."] = true;
L["No, Revert Changes!"] = true;
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = true;
L["One or more of the changes you have made require a ReloadUI."] = true;
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = true;
L["Save"] = true;
L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."] = true;
L["Type /hellokitty to revert to old settings."] = true;
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = true;
L["Yes, Keep Changes!"] = true;
L["You have changed the Thin Border Theme option. You will have to complete the installation process to remove any graphical bugs."] = true;
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = true;
L["You have imported settings which may require a UI reload to take effect. Reload now?"] = true;
L["You must purchase a bank slot first!"] = true;

--Tooltip
L["Count"] = true;
L["Item Level:"] = true;
L["Talent Specialization:"] = true;
L["Targeted By:"] = true;

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = true;
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = true;
L["For technical support visit us at http://www.tukui.org."] = true;
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = true
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = true;
L["The buff panel to the right of minimap is a list of your consolidated buffs. You can disable it in Buffs and Debuffs options of ElvUI."] = true;
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = true;
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = true;
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = true;
L["Using the /farmmode <size> command will spawn a larger minimap on your screen that can be moved around, very useful when farming."] = true;
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = true;
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = true;
L["You can set your keybinds quickly by typing /kb."] = true;
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = true;
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = true;

--UnitFrames
L["Ghost"] = true;
L["Offline"] = true;