### Version 13.97 [ August 13th 2025 ]
*   Retail:
    *   Bank purchase tab not working.
    *   Bank now has a toggle for showing the tabs.
    *   Bank tabs now fade other bags during mouseover when in combined mode (similar to the bag frame).
    *   Bank sorting can now use Blizzard Cleanup separate from Bags.
    *   Blizzard Bank frame sometimes showing as a side effect from other addons.
    *   Mistweaver Monks not displaying Poison or Disease in Aura Highlight.
*   Mists:
    *   Black Market Auction house skinned.
    *   Time Datatext now includes proper instance icons and also world boss tracking. (Thanks Donkstronomer)
    *   Friendship status now displays on Reputation Datatext and Databar.
*   Era:
    *   Static popups hiding would cause an error.
    *   Mail auto toggle not closing the bags when unchecked.
    *   Script error frame not having the First and Last button skinned because of an error.
*   Bank default width increased to 800 (up from 600).
*   Bank search and buttons not placed properly.
*   Bags upgrade icon should display properly with Pawn.
*   Chattynator added to incompatibility list with Chat module.
*   Static popups with money input have the backdrops placed better.
*   Static popup code further improved to handle more edge cases.
*   Money input boxes have better placed backdrops too.
*   Style Filter action to play a sound when triggered. (Thanks Eltreum)
*   Friends frame tabs not aligned properly with the skin enabled.

### Version 13.96 [ August 7th 2025 ]
*   Retail:
    *   Bag items not going into Warband bank when selected.
    *   Bag items fade correctly for what can go into Warband.
    *   Bank search box not placed correctly when you purchased all tabs.
    *   Bank and Warband now have new Deposit button.
    *   Bank Include Reagents checkbox moved to Auto Deposit Reagents in options.
    *   Bank tabs now have a selected texture when selected and not combined.
    *   Mastery Datatext not displaying information on mouseover.
    *   Monk stagger bar not showing up ever. oops.
    *   Crest Datatext to show Ethereal currencies now.
*   Mists:
    *   Blizzard Castbar can optionally be used regardless of Player Unitframe Castbar being enabled.
*   StaticPopups not working.
*   Top Auras not playing nicely with Masque.
*   Group Leader Icon not displaying correctly.
*   Error related to Crop Icons functionality.

### Version 13.95 [ August 6th 2025 ]
*   Retail
    *   Priest with Insanity showing is not showing Mana as secondary.
    *   Currently Static Popups are not working for right now.
*   Mists
    *   Quest Icons are now displayed on Nameplates.
    *   Warlock class bar not updating when swapping specs.
    *   Chi still wasn't showing for low level Monks without a specialization.
    *   Chi color settings not displaying.
    *   Druid Eclipse bar not displaying when using Treant form glyph while in Boomkin form.
    *   Vendor greys not working for several items.
    *   Mail box items unable to mouseover with skin active.
    *   Warlock Castbar ticks don't increase by haste anymore.
    *   Priest Penance Castbar ticks show properly now.
    *   Gold Datatext now displays Token price.
    *   Inspect skin was not working after the recent patch.
*   Micro bar acting weird when using vertical button alignment.
*   Micro bar showing incorrect icons when not using Use Icons option.
*   Mage Arcane charges not showing up when switching specs.
*   Static popup for some items wasn't properly skinned.
*   Top Auras has an option to not keep size ratio.
*   Auto Close Pet Battle tabs not working on Chat.
*   Bag item upgrade icon should show again if using Pawn.
*   Always Split Professions option for Bags. (Thanks snowflame0)
*   Custom Text option to attach to Stagger or Energy Regen bars.
*   Combat Font can be changed regardless of Ultrawide.

### Version 13.94 [ July 14th 2025 ]
*   Mists fixes
    *   Absorb Style shows up in options
    *   Actionbars 13, 14, and 15 were not saving keybinds (fixed again on the 11th)
    *   Chi was not showing on early levels and Mana not showing on MW spec with Fierce Stance
    *   Currency was breaking Datatext
    *   Druid Balance Eclipse bar not updating properly
    *   Glyphs were not applying on first attempt
    *   MapInfo was causing an error because Blizzard changed Outlands ID
    *   Monk class icon not appearing on Unitframes or Nameplates
    *   Priest Mind Flay (Insanity) ticks were added to Castbar
    *   Rogues with Shadow Dance was not showing the proper active state on Stance bar
    *   Send Mail item second row behind the backdrop you write in and text sometimes wrong color
    *   SpecSwitch Datatext updated
    *   Tooltips for Battle Pets were not showing correct level
    *   Transmogrify now has a skin toggle
*   Retail fixes
    *   Arena Preparation frames would sometimes error
    *   Bilgewater Cartel was able to break Auto Track Reputation (Thanks Nihilistzsche)
    *   Druids Combo points and Classbar were being mega wonky
    *   Mage arcane charges color option displays again
    *   Mistweaver Monks don't have Chi
    *   Saved Instance icons were not appearing when loading in the first time
    *   Warlock Destruction soul shards were not showing partial amounts
*   Additional Class Bar now has its own auto hide settings separate from the main Class bar toggle
*   Datatext inviting was not listing players from the same game version
*   Debug mode now keeps BugSack and BugGrabber enabled to help get the correct error information
*   Don't color the game menu header if misc blizzard skin isn't enabled (Thanks Pingumania)
*   Objective Tracker Autohide option was removed when DBM is loaded (they have a setting too)
*   Style Filters was causing an error when trying to use known spells
*   Warmode Datatext can't be clicked anymore, as the API is blocked now

### Version 13.93 [ July 1st 2025 ]
*   Mists of Pandaria support.
*   Blizzards One Button Assist and Assisted Highlight now supported (you can toggle spells off in General > Blizzard Improvements > Assisted Highlight and adjust colors in General > Cosmetic > Custom Glow).
*   World and Target markers fixed for non-english language clients.
*   Objective Tracker Autohide option removed when BigWigs is loaded (they provide one under: Options -> Boss Block -> General)
*   SecureAuraHeader_Update taint errors resolved (this needed to be changed because of exploiting).
*   Microbar icons leaving their buttons.
*   Mastery and Critical Datatexts updated.
*   Mount Journal skin errors.

### Version 13.92 [ June 17th 2025 ]
*   Updated LibActionButton, which resolves a taint with flyouts.
*   Quest icon not working properly in bags.
*   Tag added [name:first] (Thanks Zazou89)
*   /guildlist and /guildapply added to help find and apply to active guilds.
*   Classic/Cata Actionbar paging not working correctly on loading in.

### Version 13.90 [ May 9th 2025 ]
*   Raid Debuffs updated for Theater of Pain.
*   Cooldown module option to Force Hide Blizzard Text is always available now.
*   Flyouts called from the Spellbook were causing an error.
*   Trading Post, Auctionhouse, Pet Journal, and Professions skins updated.

### Version 13.89 [ April 22nd 2025 ]
*   Fixed an issue where tags failed to call the global Hex function. Added healer-only power and mana tags.
*   Fixed a chat format error that occurred when playing in French.
*   Objective Tracker text is now customizable.
*   Cooldown Manager skin added, with a dedicated section in Cooldowns and Blizzard Improvements for further customization. Other settings are managed in Blizzard's Edit Mode.

### Version 13.88 [ April 10th 2025 ]
*   Issue with SetupTooltip parameter for LDB plugins with custom tooltip. (Thanks exochron)
*   Removed Log Taints option (BugGrabber is a better alternative for this).
*   Config Datatext button triggers changed.
*   Available Tags can display oUF tags now as well.
*   Classic spell cast interruption display will include spell link.
*   Various older raids causing a below Minimap widget error.
*   Raid Debuffs had a few blocked Cataclysm spells which were removed and the code was updated a bit.
*   Changed the default Role Icons on frames.
*   Classic patch caused an error about OnButtonStateChanged.

### Version 13.87 [ March 14th 2025 ]
*   Crest datatext to no longer show season 1.
*   Player choice skin updated.
*   Minimap icons were in a circle.
*   Role icons not displaying in Unit Frames in SoD/Anniv/AnnivHC. (Thanks skywardpixel)
*   Updated bleed list in Lib Dispel for Evoker and to hopefully fix the Aura Highlight issue, when other addons use a newer version.

### Version 13.86 [ March 4th 2025 ]
*   Auction house skin error.
*   Actionbar Flyout direction not correct.
*   Spellbook Flyouts are skinned again.
*   Datatext Specialization erroring.
*   Renown labels fixed in Databars and Datatexts.
*   Circle Minimap is now a setting.
*   Rotate Minimap can now be set in settings.
*   Start Group Button skinned again finally _(and shouldn't break reporting groups this time)_.
*   Evoker Disintegrate to have 4 ticks when using Azure Celerity.
*   Worldmap skin updated.

### Version 13.85 [ February 25th 2025 ]
*   **Cataclysm fixes:**
    *   Boss Button
    *   Currency Datatext
*   Range options can now accept a dragged spell from the spellbook as the input.
*   Boss unitframe castbar has positioning options similar to party now.
*   Datatext Spell Hit now has a label option.
*   Testing Unitframes with the Show Frames button can now show the dead backdrop and some status tags.
*   Custom Class Colors not working properly when no other addons are enabled.
*   Nameplate Style Filter trigger for Player Role now works again.
*   PVP Capture widget should be skinned correctly again.
*   Nameplate friendly environment condition settings can be changed without exploding.
*   Chat editbox outline will now match the Chat font outline setting.

### Version 13.84 [ February 18th 2025 ]
*   Fallback checking for Range of Unitframes slightly adjusted (should help Hunters and Rogues).
*   Datatexts Mana Regen and Heal Power have a label option now.
*   Castbar won't snap (rubberband) when using Smoothing.
*   Skin errors on Cataclysm.

### Version 13.83 [ January 29th 2025 ]
*   Fists of Fury ticks changed to 4 on Castbars.
*   Roles can be enabled in Tooltip on anniversary realms.
*   Mages receiving an error RegisterUnitEvent on Classic SoD.
*   Aimed Shot and Multishot cause Castbar to appear when disabled.
*   Rapid Fire not adjusting cast time for Aimed Shot and Multishot.
*   Increased the maximum heights for top and bottom cosmetic panels. (Thanks silverwind)
*   Chat Tabs being colored when Chat was disabled. (Thanks silverwind)

### Version 13.82 [ January 25th 2025 ]
*   Working on something to profile the performance of ElvUI and oUF functions.
*   Optimized part of the framework and aura filtering for Unitframes and Nameplates.
*   Range of Unitframes uses a new system; you can now select which spells determine range in options.
*   Range Tags removed because we no longer use the library that provided the range distancing.
*   System Datatext uses a new method to track FPS and holding Shift will show Average FPS, along with Lowest and Highest FPS.
*   Smooth Bar toggles for Top Aura status bars as well as Health, Power, Castbar, Classbar, Aurabars for Unitframe and Nameplates.
*   Multishot and Aimed Shot cast time added to Castbars (for Classic).
*   Stone Bulwark added to Whitelist and Turtle Buff filters.
*   Combat Indicator allowed on raid frames.
*   Equipment Datatext was broken.
*   Chat having a silly little pixel at the bottom center should be gone.
*   Support for CUSTOM_CLASS_COLORS directly, under Blizzard Improvements.
*   Unitframe option Max Allowed Groups is now Retail only.
*   Role icon support for Classic Anniversary realms.
*   Datatext added to track Mythic+ score. (Thanks Rubgrsch)
*   Nameplates can be toggled by conditions (Instance Type or if Resting) for Friendly, Enemy; this also can override the nameplate stacking setting.
*   Dual Spec profiles can be enabled for Classic Anniversary realms.

### Version 13.81 [ November 19th 2024 ]
*   Blacklisted Auras: Well-Honed Instincts
*   Unitframe color options added to set Health Breakpoint, only for Friendly units, and Color Backdrop. (Thanks BeeVa)
*   Chat would error when attempting to move it.
*   Attempted a fix for old Dropdowns from other addons causing a Skin error.
*   Minimap Right Click for Tracking works on Cataclysm.
*   Mover selection uses the new dropdown on Cataclysm.
*   Spellbook Tooltips not working on Cataclysm.

### Version 13.80 [ October 29th 2024 ]
*   Currency Transfer skin updated.
*   Blacklisted Auras: Flight Style, Call of the Elder Druid, DK Blood Draw, WoW's Anniversary, and Warband Mentored Leveling.
*   Shift + Left click ElvUI Menu Datatext to toggle mover mode actually works now.
*   Unitframe Health Dead Backdrop using multiplier when it shouldn't.
*   Guild Datatext error when online members is invalid.
*   Guild Datatext will now show which faction members are on.
*   Tooltip option to hide Stack Size on items.
*   Stylefilter error when Importing Profiles, also reduced wasteful execution of filters.
*   Simplify AddonList skin, which should make it more clear what addons are actually enabled.

### Version 13.79 [ October 22nd 2024 ]
*   Unitframe range issue with Mage resolved.
*   Reorganized Aura Filter priority list for all Unitframes and merged PlayerBuffs filter into Whitelist.
*   Reset All button added for Filters section; this will entirely wipe any custom filters used and reset default filters.  AuraBar Colors, Aura Highlight, and Aura Indicators are excluded from this.
*   Reputation error on Datatext and Databars on Classic or Cataclysm.
*   Range issues resolved on Classic Era (you must have Show All Spell Ranked enabled).
*   Scale option added for Private Raid Warnings (Buffs and Debuffs > Private Auras > Raid Warning > Scale).
*   Tags [dead], [offline], and [status] should update faster now.
*   Shift clicking from SpellBook or Talents into WeakAuras not working.
*   LibDispel breaking on Cataclysm when trying to call SetCVar.
*   Shift + Left click ElvUI Menu Datatext to toggle mover mode.
*   Show the Profession Quality texture on items while looting.
*   Aura Highlight can be toggled off for specific Unitframes.
*   Stack size will also be shown in Tooltips.
*   Improved Trading Post skin.
*   Health Backdrop by Value setting added to Unitframes.

### Version 13.78 [ September 24th 2024 ]
*   Priest and Shaman spells added to help with Range checking.
*   Objective Tracker taint caused from SplashFrame (there are likely more causes).
*   Time Datatext now has an option to toggle Saved Instances.
*   Heal Prediction no longer being goofy.

### Version 13.77 [ September 10th 2024 ]
*   Unitframe range issue with Shaman resolved.
*   Castbar option to allow BigWigs to rename spells to something better to understand (Example: 'Impaling Eruption' becomes 'Frontal').
*   Nameplate Stylefilter that use Spell Cooldown trigger would cause an error.
*   Nameplate Stylefilter ElvUI_Target disabled by default.
*   Priest form paging readjusted on Classic Era.
*   Actionbar Fade updated more for Skyriding.
*   Raid Menu button not working on Classic Era.
*   Button button scaled wrong when displayed during combat.
*   Guild members getting an Achievement would sometimes cause an error.
*   Auction house opening bags when Auto Toggle was unchecked.
*   Cleaned up Zone Map skin.

### Version 13.76 [ August 27th 2024 ]
*   More Unitframe range issues resolved.
*   Fader updated again for Skyriding.
*   Bag module error when equipping a bag with 38 slots.
*   Bank slots offset wrong when using Reverse Slots option.
*   Priest form was unexpectedly paging when using Spirit of Redemption.

### Version 13.75 [ August 22nd 2024 ]
*   **Warband Bank:**
    *   Tabs can be purchased again.
    *   Option exists for combined mode.
    *   Bag module off Warband is now skinned.
*   Unitframe range for Evoker, Rogue, and Mage was broken.
*   Encounter Journal skin error resolved regarding index field reset.
*   Error resolved during combat involving SetPropagateKeyboardInput.
*   Tooltip Item Count now has options Include Reagents and Include Warband.
*   Bag Module can now display WuE (Warband until Equipped) and BoW (Bind on Warbound, may not be fully implemented yet).
*   Blizzard Widgets skinning can be disabled via the Miscellaneous toggle in Skins now.
*   Priest void form on Retail should swap to the correct bar.
*   Objective Tracker and World Map text overrides should work again.
*   Paladin Dawnlight and Eternal Flame added to Aura Indicator.
*   Datatext Custom Currency dropdown not listing all currencies.
*   Archaeology dig site progress bar position was not being set properly.
*   Action bars not properly fading with Skyriding.
*   Gold and Guild Datatext now have a max limit option to reduce the overall size by amount of toons.
*   Reporting a group for Advertisement wasn't working in LFG.
*   Auto track reputation not actually setting the new one.
*   Zone Map skin causing an error on the protected function SetPropagateMouseClicks.
*   CompactRaidGroup causing a protected call error to SetSize when Blizzard raid frames were disabled.
*   Top Auras threshold flashing not ending properly (also they have a new flash curve).
*   Transferring currencies would sometimes cause an error.

### Version 13.74 [ August 14th 2024 ]
*   Changes required for 11.0.2
*   Unitframe Portraits not lined up in thick border mode

### Version 13.73 [ August 7th 2024 ]
*   **Important:**
    *   Unitframe range was a bit messed up.
    *   Better compatibility with DejaCharacterStats.
    *   WeakAura Cooldowns not showing timers for Grow animation Auras.
    *   Share Global Profile and Private Profile added.  Profiles take less time than previous versions to send now.
*   **Datatext issues:**
    *   Reputation would error about GetNumFactions.
    *   Quick switching to another Datatext would cause an error.
    *   Specialization would display incorrectly.
    *   System now has a display Tooltip setting.
    *   Spell Haste incorrect on Cataclysm.
*   **Skin issues:**
    *   Communities skin updated to fix more checkboxes. (Thanks Hopesedge)
    *   Worldmap Questlog categories expand clickable area was terrible.
    *   AdventureMap skin error when no rewards are available.
    *   Quest progress bar to have gradient color again.
*   LibDispel Bleed list updated.
*   Auto Track Reputation would error about GetFactionInfo.
*   Skyriding Fader option wasn't working.
*   Evoker Sense Power added to Aura Watch.
*   Blacklisted Sweltering Heat and Stinky RP buffs.
*   Clamp Nameplates not working properly on Classic and Cataclysm.
*   Raid Utility Assist Promote checkbox misplaced on Classic and Cataclysm.
*   Communities Chat to follow the default Chat font settings.
*   Chat IM Style not using the correct Chat Editbox.
*   Unitframe Class Color Override has a new setting "Always" which will show Class Color ignoring health by value and health breakpoints when set.
*   Blizzard Nameplate Monk Stagger bar being shown on our Player Nameplate.
*   Tag [specialization] erroring on Classic and Cataclysm.
*   Classic Mage Advanced Warding Rune which adds Remove Greater Curse not properly displaying dispels.
*   Classic Mage Channel Ticks for Regeneration and Mass Regeneration. (Thanks Zavoky)

### Version 13.72 [ July 25th 2024 ]
*   Chat error when Battlenet is failing to provide info during Social Queue.
*   Spec Switch Datatext was not opening Talents.
*   Added option to adjust the scaling of the Retail ESC Game Menu in General > Cosmetic
*   Hotkey text was over Cooldowns (this was something Blizzard changed so this fix only applies to our Actionbars).
*   Minimap Middle Click menu has icons again and also has the Profession button like Microbar (on retail).
*   Reimplemented Autohide for Objective Tracker (updated the Autohide Objective Tracker for Cataclysm Arena too).
*   World Markers can be set by holding shift in Raid Control, this mod key can be adjusted in General > BlizzUI Improvements > Raid Control.
*   Spell ID will show up on #showtooltip macros again.
*   Unitframe Fader during Hover not working correctly.
*   Minimap Tracking button hide is reactivated.
*   Party frames were not pingable anymore on Retail.
*   Issue with using Transfer Currencies involving RequestCurrencyFromAccountCharacter.
*   ExpandAllFactionHeaders error resolved.
*   Mover dropdown under the Nudge frame itself.
*   **Skin issues:**
    *   Guild Reputation progress bar was always full.
    *   Dropdown boxes overlapping with zone text in the /who list.
    *   Updated the color for the quest text notice "This quest has been completed on your account already"
    *   Bags/Bank skin in Classic and Cataclysm are fixed when Bags module is disabled.
    *   Great Vault skin error when parchment remover was enabled.
    *   Spellbook skin error when you unlearn a profession.
    *   Scrapping Machine skin erroring on open.
    *   Skinned new Currency Transfer menu.

### Version 13.71 [ July 23rd 2024 ]
*   The War Within patch 11.0 supported.
*   Unitframe Health causing a point error when profiles switch.
*   Friends Datatext erroring when Battlenet is being goofy.
*   Item Level Abbreviation setting for Enchants on Character and Inspect frame.

### Version 13.70 [ July 12th 2024 ]
*   Cooldowns not finishing correctly.
*   Achievement skin error on Cataclysm.

### Version 13.69 [ July 10th 2024 ]
*   SetCooldown error when using vehicles and Loss of Control cooldowns timers work again.
*   Communities frame skin updated and the toggles updated for Minimap and Datatext.
*   Visibility settings for Enchants, Gems, and Item Level for Inspect and Character.
*   Skinned Swim timers on Classic.
*   Blacklisted Evoker lust debuff.

### Version 13.68 [ July 9th 2024 ]
*   Enchant info to display with Item Level on Character and Inspect frames.
*   Player nameplate not obeying Use Class Color option for Power.
*   Translit tags sometimes not returning properly.
*   Frame Level and Strata options for Unitframe power, auras, and frames.
*   Hit Datatext not updating in some situations.
*   Attack Power Datatext now has label options.
*   Role Checkboxes set to the correct level on Guild Finder.
*   New tags [health:percent-with-absorbs:nostatus] and [health:current:name]

### Version 13.67 [ June 26th 2024 ]
*   Skinned LFG and Dressing Room scrollbar.
*   Guild reputation progress bar fixed.
*   Player Alt Power bar not staying connected to its mover.
*   ObjectiveTracker leveling taint  (Retail & Panda Remix).
*   Guild Datatext timer Timerunning icon shows correctly.
*   Mastery & Haste Datatext added for Cataclysm (Thanks Tsxy).
*   Healer only and Auto hide options for Unitframe power.
*   Cataclysm tooltip can now show Item Level.

### Version 13.66 [ May 31st 2024 ]
*   Classic: Combo points appearing on new targets.
*   Cataclysm: Reforge skin toggle not working and PVP skin updated.
*   Raid Utility: Removed the ability to move this in combat because of secure elements.
*   Timerunning icon added for Chat, Guild Datatext, and Friends Datatext.
*   Castbar ticks not working properly when castbars were enabled on group frames.

### Version 13.65 [ May 24th 2024 ]
*   Cataclysm: Druid and Paladin dispel fix.
*   Cataclysm: AuraWatch & Spell Filter updates.
*   Cataclysm: Cabal Zealot chat bug fixed.
*   Cataclysm: Rogue Redirect & Combo Points fixed.
*   Cataclysm: Friends frame skin error fixed.
*   Group frames now show Alternative Power options.
*   Guild Instance Difficulty icon shows correctly.
*   Missing battleground healer/tank icons on some locales.
*   Raid Utility: Target Icons (all), Role Icons (party), World Markers (Cataclysm)
*   Panda Remix: Fixed double character page gem display.
*   Party Pets & Target: Individual Glow settings added.

### Version 13.64 [ May 7th 2024 ]
*   **Cataclysm Hotfixes:**
    *   Shaman dispel conditions fixed. (Thanks Oppzippy)
    *   Bag menu to assign removed as the API doesn't work anymore.
    *   Bag Starter Quest icon not displaying.
    *   Quest NPC Model text too large.
    *   Equipment flyout border colors.
    *   Pet Stable skin updated.

### Version 13.63 [ May 2nd 2024 ]
*   **Cataclysm Hotfixes:**
    *   Color Picker
    *   Battleground Queue
    *   Skinned GhostFrame
    *   Fixed Resilience and Item Level Datatext
    *   Removed Ammo, Pet Happiness, and Primary Stat Datatext

### Version 13.62 [ April 30th 2024 ]
*   Cataclysm Classic ready.
*   DualSpec enabled for SoD.
*   Shadowform paging on Era.
*   Guild Deaths event not existing on Era, causing an error.
*   Range of Unitframes breaking when Spell Ranks unchecked.
*   Aura Indicator option for Pet Frames to use Profile or Global instead (uncheck Pet Specific).
*   Threat option added to allow high threat to be shown without being primary target, also another to display Player threat on Target or Focus frame.
*   Tag [threat:lead] added to display percentage of threat lead.
*   Raid Utility displayed while in a group, regardless of Leader or Assist, with limited functionality.
*   Sunken Temple now on Time Datatext.

### Version 13.61 [ April 2nd 2024 ]
*   Microbar Support Ticket button in middle of screen.
*   Minimap Icons not hiding when using the keybind for Toggle Minimap.
*   No Label, Decimal Length, Custom Label options for the Leech Datatext.
*   Minimap Difficulty icon not respecting offsets on Wrath.
*   Party and RaidPets not spawning until after combat.
*   SoD Mage at low level having incorrect range on friendly NPCs.
*   Wrath Nightelf Shadowmeld causing a taint during combat.
*   LibDispel Bleed list updated again.
*   Chat AFK and DND not displaying on Retail.

### Version 13.60 [ March 19th 2024 ]
*   Difficulty Icon on Minimap improved, resolving an issue with the mouseover tooltip.
*   Pet Battle XP bar overlapped Pass button.
*   Encounter Journal error on open resolved.
*   Text To Speech button added to Chat > Voice Chat.
*   Reputation Databar being clickable during combat.
*   Error when using /tts when Chat Voice buttons were disabled.
*   Classic SoD: Mage runes added to improve Range Fader for lower levels (Regeneration and Mass Regeneration).
*   Classic: Hunter/Rogue/Warrior Range Fader corrected.
*   Classic: Send Mail text color corrected.
*   Classic: Bags Quiver border missing on bags at first login.
*   Classic: Bags Sorting breaking when Quivers tried to sort into other Quivers.

### Version 13.59 [ February 23rd 2024 ]
*   Gnomeregan filters updated.
*   Whitelisted Suspended World Buffs.
*   Toggling spell ranks trigger range display issue.
*   Updated allied races model skin.
*   Currency error when using Better Bags.
*   Season of Discovery Instance IDs added for the Raid Lockouts on Time Datatext.
*   Filter creation error resolved when a filter and spell was selected.
*   Raid Utility button supports boss mod cooldown function. (Wrath/Classic)
*   Closing whisper tab mid-combat no longer causes errors.
*   Blizzard options tooltip issue after displaying the Action Bars section resolved.
*   Bags "itemButton" error fixed when adding a new Bag then reopening.
*   Wrath Fury of Stormrage regen bug fixed. (Thanks ToddSisson)
*   WeakAuras color picker save issue fixed. (Wrath)

### Version 13.58 [ February 11th 2024 ]
*   Updated LibRangeCheck which fixes the CheckInteractDistance error.
*   Color Picker not saving properly on WeakAuras or other addons.
*   The following Phase 2 auras have been added to AuraWatch & Whitelist:
    *   Priest Renew
    *   Priest Meditations
    *   Druid Regrowth and Rejuvenation
    *   Stranglethorn World Event Buff+Stacks
    *   Stranglethorn Opt-Out PvP Buff
    *   Dark Rider Rune discovery Buff
    *   Cozy Sleeping Bag Buff+Stacks
    *   Gnomeregan Raid Buffs+Debuffs

### Version 13.57 [ February 6th 2024 ]
*   Classic: Blizzard fixed Top Auras

### Version 13.56 [ February 6th 2024 ]
*   Style Filter error resolved
*   Group Loot frame backdrop fixed
*   Wrath: Warrior Charge to CCDebuffs
*   Classic SoD: Auras added to Aurawatch and Penance to Castbar Ticks
*   Chat Loot tab not being created during Install
*   Color Picker Alpha input box behaves better
*   Tooltip not showing player names sometimes
*   Updated plugin for Show Healers & Tanks on Nameplates
*   Timewalking instance type added to Unitframe Fader
*   Difficulty IDs updated to include Follower Dungeons

### Version 13.55 [ January 16th 2024 ]
*   Darth finally got enough XP for lvl 36 (happy birthday)
*   Datatext tooltip for Crest Fragments displays correctly
*   Fists of Fury added to Castbar Ticks
*   Minimap Menu updated with Icons
*   Tank Icon setting works again

### Version 13.54 [ December 19th 2023 ]
*   Raid Utility Countdown button works with other addons
*   Dropdown for WIM skinned
*   Missing text from Tags in the Health section for MainTank / MainAssist
*   Removed LibClassicCasterino and LibClassicDurations
*   Updated LibRangeCheck for the new combat check
*   Raid and Party pings should work again
*   Quest Log items tooltip causing an error on Classic and Wrath
*   Totem Bar buttons not positioning correctly when changing Call Totems
*   Bank Bag icons and assignments should show properly again on first open
*   Bank sorting fixed on Classic and Wrath

### Version 13.53 [ December 2nd 2023 ]
*   Updated LibRangeCheck
*   Mail Font defaulting to outline was changed
*   Bag Datatext Include Reagents display updated
*   Item Level Datatext has Only Equipped option now
*   Nameplates no longer showing on Game Objects and Dead NPCs when using interact
*   Totembar cooldown blings on Wrath not following mouseover and hide settings
*   Seconds option for Time Datatext

### Version 13.52 [ November 17th 2023 ]
*   Skinned Model Control buttons on various frames
*   Bags Datatext now has an option to Include Reagents
*   Merchant Buyback Item count text was smaller than intended
*   Evokers' release casting issue when entering an Instance with Dynamic Flying should be resolved
*   Opening Bank with Shift down (to open to Reagent Bank) then placing an item, will go into Reagent Bank
*   Unitframes Range is fixed but less accurate due to Blizzard blocking certain range APIs during combat
*   Display Frames for Unitframes is now a bit more randomized and handled better on fake units
*   Classic Era Unitframe backdrops, Heal prediction, and Absorbs are now working properly
*   Classic Era Aimed Shot and Multi-Shot Castbars work again

### Version 13.51 [ November 14th 2023 ]
*   SetCVar was erroring on keydown in some cases
*   Bleeds list updated for Evokers

### Version 13.50 [ November 14th 2023 ]
*   GetAddOnEnableState was erroring

### Version 13.49 [ November 14th 2023 ]
*   Macro procs were not displaying on Wrath
*   Unitframe Fader option for Dynamic Flight
*   Zone Description not following Zone Text settings
*   Bags stay in Sort mode if closed and reopened during Sorting
*   Display Frames for Party and Raid are a little more fancy (as they once were)
*   Mind Control paging fixed for Priests on Classic Era, it requires "[possessbar] 16;"
*   Actionbars which were disabled but used for keybinds, now need to be enabled and visibility state changed to "hide" to work like before
*   Actionbars to use events to determine the range and usable state of abilities and optimized button flashing
*   Actionbars now have a Target Reticle that shows up when you are holding a spell (same as Default UI)
*   Actionbars conditions adjusted to work with old content
*   Actionbars icon cropping correctly again with Masque
*   Pet Bar erroring on backdrop width multiplier
*   Tags now support new line by using "|n"

### Version 13.48 [ November 9th 2023 ]
*   Unitframe backdrops, Heal prediction, and Absorbs are now working properly.
*   Actionbar Macro Procs and Macro Target Auras are now working.
*   Bags now allow you to track more currencies again and can now be excluded from sell junk.
*   The Fonts menu (General > Fonts) now includes options for adjusting important font settings in the UI, such as the fonts used in Mail, Objective Text, and Blizzard Cooldown text.
*   Instance triggers for Style Filters are now working correctly.
*   The tooltip error for BattlePets has been fixed.
*   Crest Datatext updated for currency change.

### Version 13.47 [ November 7th 2023 ]
*   Skinned role check frame (Wrath).
*   Left buttons for Plugins now highlight again.
*   Blacklisted auras "Tricked or Treated" and "Wicker Men's Curse".
*   Aura Indicators now have Cooldown Text position settings (Filters > Aura Indicator).
*   Aura Indicators now have Count Font and Outline settings (UnitFrame > Units > Frame > Aura Indicator).
*   More fonts follow the Font Size setting. Unified Fonts was removed and Blizzard Font Size added which has different functionality, also an option to not Font Scale (General > Media > Fonts).
*   Mage's Ice Cold and Alter Time added to Player Buffs and Turtle Buffs.
*   Style Filter triggers "Amount Below" and "Amount Above" under Unit Conditions which reacts off the amount of visible Nameplates.
*   Nameplate Portrait now has an option to prefer Specialization Icon instead of Class Icon.
*   Nameplate Portrait Spec and Class Icon not have Keep Size Ratio option.
*   Chat Tab text should be displayed fully when detached from the dock.
*   Chat Tab not being selected after reloading. (Thanks Daenarys)
*   2D Portrait option removed, this was causing performance issues on Nameplates.
*   Quest Icons code was optimized to further reduce strain on Nameplates.
*   Quest Icons now have spacing and text offset options.
*   **Tags**
    *   [permana] for mana added, like health and power tags.
    *   [target:last] and [target:abbrev] with variants for the unit's target.
    *   [spec:icon] and [spec] added which support other units and [specialization] is now the same as [spec].
    *   [classpowercolor] and [classpower] supports other units, limited by Blizzard's API which means, it only works for Stagger.

### Version 13.46 [ October 26th 2023 ]
*   Guild Bank timeout error fixed.
*   Lowered Graveyard button to prevent overlap.
*   Friends game icon uncropped and Recruit summon icon skinned.
*   Assist and Tank would error when setting up Custom Texts.
*   Player Choice Font Color restored with parchment active.
*   Widget's Font Shadows on some frames were restored.
*   PVP Spec Icon and Trinket elements were updated.
*   Voice Chat sliders in dropdown menu reskinned.
*   Ready Dialog for Dungeons and PVP updated.
*   Skinned Select your role frame (Wrath).
*   Pet Target Marker Icons fixed.
*   **Updated Options**
    *   Search bar at the top (type to search).
    *   Toggle Anchors renamed to Movers and moved to top.
    *   Reposition Window now an icon by the close button.
    *   Reset Anchors moved to the mover frame (in Movers).
    *   Debug button added to information section, which easily calls the /edebug command.
    *   Import and Export pages updated (Profiles > Import / Export). Thanks Eltreum for the idea!
    *   Module Copy moved to Profiles section (Profiles > Module Copy) and now has Select and Clear All buttons.

### Version 13.45 [ October 13th 2023 ]
*   Character tabs fixed for pet classes without pets.
*   Collections added to Minimap middle-click dropdown on Wrath.
*   Compare tooltips no longer get stuck in Keybind Mode.
*   Tooltip no longer duplicates creature type on Retail.
*   Priests' Mind Control bar should now be visible again on Classic (nopossessbar removed from visibility).
*   Tooltip Health Bar font defaults changed (Tooltip > General > Health Bar).
*   Missing font shadows on some Blizzard frames.
*   Skinned Queue Status on Wrath.
*   Looking For Group skin toggle readded on Retail.
*   Keybind Mode button closes Settings window again.

### Version 13.44 [ October 10th 2023 ]
*   Shadow outline causing problems.
*   Group Finder option in Minimap middle-click dropdown now works.
*   Math delay function updated to prevent errors due to long-running script.

### Version 13.43 [ October 10th 2023 ]
*   Quest Rewards Complete page border misaligned.
*   Weapon Enchants not updating correctly on Retail.
*   Bags visual sorting added under Bags > Sort Spinner. (Thanks Crum)
*   New Font Outline settings added: Shadow, Shadow Outline, and Shadow Thick. None setting no longer has a shadow.
*   Spellbook skin now handles the profession icon cooldown.
*   Guild Bank Item Quality is now handled on Wrath (General > Blizz Improvements > Guild Bank).
*   Minimap middle-click dropdown not placed to the right of cursor when map on left.
*   Encounter Journal Item Sets skin fixed.
*   Recruit a Friend rewards skin fixed.

### Version 13.42 [ September 29th 2023 ]
*   Saving Edit Mode was a little buggy.

### Version 13.41 [ September 28th 2023 ]
*   Ping support on Unitframes and Nameplates (retail).
*   Mac Meta key support in Keybind mode.
*   Mail skin text color fixed on Classic.
*   Cleaned up Landing Page skin a little.
*   Upgraded the Raid Utility which now includes the Everyone Assist (all) and Restrict Pings (retail).
*   Bag sorting failed when a normal bag attempted to move into a quiver bag: "Only arrows can be placed in that."
*   Transmog Collections invalid slot not showing properly for Evokers.
*   Objective Tracker error complaining about SetHeight.
*   Legion Scenario Quest button not working when Actionbars were enabled.
*   Encounter Journal and World Map taint about xoffset fixed.
*   Quest Frame parchment borders adjusted to look cleaner along with the Model Scene.
*   None option added to Bag Currency Format which lets you hide tracked currencies; however can still be tracked with Currency Datatext.
*   Ready Check frame text is properly aligned.
*   Select your role frame is skinned now.
*   Chat Alerts can now be set for more channels like Trade or custom channels.
*   Item Level for Character and Inspect can now be colored based on the average Item Level (uncheck Rarity Level in Blizz Improvements > Item Level).
*   Border Colors during a Pet Battle will match Pet rarity now and the Dead icon will be borderless.
*   Defense Datatext now includes defense gained from armor as well; Block Parry and Dodge now have the option to set decimal length.
*   Bonus Rolls weren't anchored to the Alert Loot mover.
*   World Map Pin style that fits better with the skin.
*   Prevent an error when switching from Class to 3D portrait.
*   GM Chat skin error on Classic.
*   Guild Bank would error when trying to search using Bag module (wrath).
*   Guild Bank option is displayed again in the skins section (retail).
*   Guild Bank now has the ability to show Item Level on items and Count font settings under (General > Blizz Improvements > Guild Bank).
*   Dispels wouldn't appear when Show All Spell Ranks was unchecked (classic).
*   Attack Power Datatext would error when on Hunter (classic).

### Version 13.40 [ September 5th 2023 ]
*   Reputation Databars not displaying Hated reputation information.
*   Classic HC chat death message having additional brackets.
*   Classic HC dungeon lockouts will appear in Time Datatext.
*   Chat error that was complaining about color not existing.
*   Alerts should work correctly on Trading Post now.
*   Encounter Journal taint error about OnOpen from ToggleEncounterJournal (known: can still happen from Blizzard_MapCanvas).
*   Spellbook taint error about CastSpell.
*   Achievements displaying text when they were collapsed.
*   Cooldowns displaying in days when they shouldn't.
*   Wrath Quest Log error about UNKNOWN.
*   Unitframe spacing options increased slightly.
*   Edit Mode error about Buff Frame when Blizzard's are disabled.
*   Junk icon will show when using the Bag skin for Blizzard Bags.
*   Reimplemented the Sell All Junk to use Blizzard's new API.

### Version 13.39 [ August 22nd 2023 ]
*   Custom Glow: Proc Glow settings are active (custom color, speed, and start animation).
*   Adjusted Scale of LFG Queue checkboxes so that glow looks normal.
*   Aura Indicator protected from missing offsets due to defaults being adjusted.
*   Objective Tracker Auto Hide should work again (also it works on Wrath for Arenas now).
*   Transmogrify Tutorial button wasn't hidden with Disable Tutorials Buttons.
*   Bag Indicator for showing if a Bag is hidden wasn't appearing.
*   Gold can be picked up from the Bags by clicking on the text.
*   Tooltip Level line on Russian client was incorrect.
*   Classic Era: Actionbars to show count for spells that require reagents.
*   Actionbars now handle fading better with Skyriding.
*   Added Evoker Time Dilation to TurtleBuffs (Thanks wing5wong).
*   Added Dawn of the Infinite auras to Raid Buffs and Debuffs.
*   Tag Update Rate default changed to 0.2 and minimum value lowered to 0.05
*   Custom Text max font size increased to 128.
*   Reputation Databars will display Paragon when met instead of Renown.
*   Reputation Databars displaying friendship factions should display their information correctly on the tooltip.
*   Reputation Databars not showing as full when capped.
*   AFK mode now has an option to stop the spinning.
*   **Unitframe Fader:**
    *   Added support being out of an Instance (as None).
    *   Prevented it from failing to trigger properly when reloading in an Instance in some setups.
    *   Difficulty IDs updated, as well on Nameplate StyleFilters.

### Version 13.38 [ July 13th 2023 ]
*   Additional Power Tags should be functioning properly again.
*   Protected plugins from accidently breaking Ready Check icons.
*   Simplified how Aura Indicator handles Ebon Might.
*   Reposition Merchant Frame Sell Arrow Thingy.

### Version 13.37 [ July 12th 2023 ]
*   Removed obsolete bleed spells.
*   Microbar missing it's tooltip.
*   Invite Roll Popup having messed up icon.
*   Private Aura mover size will match icon size.
*   Minimap Tracking not appearing correctly after changes.
*   Loot Rolling should work correctly again on Retail with a new option to set the Max Bars amount in (General > Blizz Improvement > Loot Roll).
*   Ready Check should display on Party and Raid once again.
*   Chat Config tab size should fit a little better.

### Version 13.36 [ July 11th 2023 ]
*   Bleed dispel list updated, it contains about 100 more bleeds.
*   Minimap Tracking button menu will spawn in correct location.
*   Send Mail text color being incorrect after reopening on Wrath.
*   Bag Currencies being displayed under slots when using Reverse Bag Slots was fixed.
*   Hit and Spirit Datatext removed from Retail.
*   Several skin adjustments for Retail patch.
*   Augmentation spells added for filters (including Ebon Might).
*   Aura Indicator will stack Ebon Might on raid frames.
*   Option to prefer using Blizzard Sell Junk method (temporarily disabled while they fix it on their end).
*   Microbar will use the new art on retail when "use icons" is unchecked.
*   Vehicle Seat, Equipment Manager, and Archaeology Bar are controlled by Edit Mode for Retail now.
*   Spec removed from Item Level display on tooltips (Blizzard added it by default).
*   Item Level should stop appearing multiple times on the tooltip. (Thanks Etern213)

### Version 13.35 [ June 20th 2023 ]
*   Skinned a dropdown on the Profession Orders frame.
*   Actionbar for Skyriding fading sometimes didn't work properly on login.
*   Small tweaks to the Profession and Settings skins.
*   Ready for Wrath patch.

### Version 13.34 [ June 10th 2023 ]
*   Azerite Essence skin is fixed.
*   Added a few missing Bleed spells.
*   Nameplate Widgets not appearing for Goblins.
*   Nameplate Widgets now have option to place below, including offsets.
*   Number of Datatexts slider on Custom Panel now functions properly.
*   Global Fade now works properly while Skyriding, various Hide issues are now resolved.
*   Using Spec Datatext to open Talent Frame will no longer cause button issues.
*   Warlock Singe Magic from Grimoire of Sacrifice will trigger dispel highlight.
*   Withering Vulnerability added to Raid Debuff filters.

### Version 13.33 [ May 24th 2023 ]
*   **Evoker bleed dispel is finally supported.**
    *   Ability to change Debuff colors under (Buffs and Debuffs > Debuff Colors) this applies to several things in the UI.
    *   Adjust the Unitframe Bleed Highlight color in (UnitFrames > Colors > Aura Highlight).
*   **Cooldowns updates:**
    *   Color settings will now Class swap properly.
    *   No longer display Modified Rates by default.
    *   Issue with timers showing incorrectly in Days should be resolved.
*   Updated Aura Filters for Freehold, Sarkareth, and Neltharus.
*   Loot roll numbers are removed from Retail.
*   Loot History skin updated further.
*   Nameplate StyleFilter for Incorporeal was added by default.
*   Private Auras for Boss Frames can be toggled without causing an error.

### Version 13.32 [ May 7th 2023 ]
*   Accept Invites was erroring when attempting to accept an invite from a friend while in queue.
*   Blizzard loot frame skin error which caused items to not appear (also improved the look).
*   Equipment Set Datatext has a few more options.
*   Corrected Icon display of the Profession and Crafting skins.
*   Removed ElvUI_Explosives Style Filter; One will most likely be added later for Incorporeal and Afflicted.

### Version 13.31 [ May 4th 2023 ]
*   Actionbars can override certain Vehicle World Quests again.
*   Upgraded LFG Eyeball settings under (General > QueueStatus) and it has a mover now too.
*   Updated ScrollBars for several skins where they were displayed wrong.
*   Guild Bank and Item Socketing skin errors fixed.
*   Addon Compartment has a Hide option now.
*   New method to hide Raid, Party, and Nameplates.
*   Fixed error with Objective Tracker Auto Hide.
*   Working on Loot History skin.
*   Datatext for Crest Fragments added under Currency. (Thanks AcidWeb)
*   Pet bar showing when it shouldn't on Classic Era.

### Version 13.30 [ May 2nd 2023 ]
*   **Patch 10.1:**
    *   Support for Addon Compartment.
    *   Support for Private Auras (including on Unitframes, soon Nameplates).
    *   Private Raid Warning has a mover.
    *   Loot Roll supports Transmog rolling.
    *   Auras for all Season 2 dungeons and the raid are in this release.
*   Blizzard nameplates would appear when they shouldn't. (Thanks LS)
*   Text hard to read when selecting Faction Envoy.
*   Bag Bar Show Count option not working properly.
*   Numpad Divide is now labelled to Actionbars as N/ and Numpad Multiply was changed to N*.
*   Zone Ability and Extra Action Ability will now be hidden during a Pet Battle.
*   Option added to prevent skinning of Library Dropdown Menus. (Skins > Library Dropdown)
*   Totem Bar and Totem Tracker now have Keep Size Ratio options.
*   Nameplate Arrow Spacing range increased.
*   StyleFilters now have two new triggers for Auras: OnMe and OnPet.
*   StyleFilters now have a Heath Glow action for Pixel Glow and Shine. (Thanks Eltreum)
*   Minimap Cluster would cause an error.
*   Tag Update Rate not applying on loading in.
*   Inherit Global fade will not fade during Skyriding.
*   Tag error trying to use [classpowercolor] on Classic Era.

### Version 13.29 [ March 21st 2023 ]
*   Chat error when friends going online or offline on Wrath or Classic.
*   Health not updating properly on Classic.
*   Mission Datatext causing an error.

### Version 13.28 [ March 21st 2023 ]
*   Dracthyr display on tooltips.
*   Add support for Compare Item Tooltips. (Thanks Etern213)
*   Show Empty Buttons will work correctly from Pet Spellbook.
*   Aura Indicator added for Player and Target Unitframes.
*   Display frames now works for Tank and Assist frames.
*   Expertise and Armor Pen Datatexts updated.
*   Totembar is more compatible with Masque again.
*   Close button on Character skin corrected for Wrath.
*   Fallback added for Castbar name on Classic.
*   Flashing fixed for the Texture Swap from StyleFilters (Thanks Eltreum).
*   Instanced Difficulty options for Unitframe Fader (Thanks happenslol).
*   Performance updates to oUF (Thanks LS) and LibRangeCheck (Thanks Irame).
*   Option (General > Tag Update Rate) which controls the amount of updates for Tags in Unitframes and Nameplates.

### Version 13.27 [ February 24th 2023 ]
*   Display Cast Bar in Party section of options was a little broken.
*   Cast Bar Text will get checked by Class Color for shared profiles.
*   CustomTexts added for Tank and Assist frames.
*   Castbar tick color not updating properly sometimes.
*   Totem Tracker on Retail might have spells stuck less.
*   Role Icons in Chat should appear again.
*   Soft values for Datatext Tooltip offset were increased to 60.
*   Datatext LDB icon wasn't showing when toggling the setting.
*   Crit and Hit Datatext were fixed for Classic.
*   Display option for Vehicle Seat Indicator Size on Wrath.
*   Health Breakpoint option added for Unitframes.
*   Actionbars can use different styles of Masque per bar.
*   Iced Phial of Corrupting Rage's debuff added to the blacklist.
*   **Backend Changes for Plugin Authors:**
    *   Plugin Installer now supports functions for StepTitles.

### Version 13.26 [ February 10th 2023 ]
*   Datatext 505 error resolved.

### Version 13.25 [ February 8th 2023 ]
*   Hotfixes for Battlegrounds and Custom Currency Datatexts.

### Version 13.24 [ February 7th 2023 ]
*   Mail Icon was not positioned correctly on Minimap.
*   Readded delete functionality to Vendor Greys on Classic.
*   Crafting order icon was not displayed at all.
*   Bags might open from Gold Datatext again for those it wasn't.
*   Copy Chat Line would cause an error.
*   More adjustments for Data Broker datatexts.
*   Added Battleground Datatext options, including the ability to have them on a custom panel.
*   Blacklisted 7 day Zanzil Debuff.
*   Updated Trading Post and Perks Skin.
*   Attempt to fix compare tooltips not hiding.
*   Item IDs allowed to be ignored in Bag Sorting.

### Version 13.23 [ January 24th 2023 ]
*   Bag slots not updating.

### Version 13.22 [ January 24th 2023 ]
*   Actionbar 13, 14, and 15 added to Wrath.
*   Equipment Manager skin fixed on Wrath.
*   Classic Era Bags error about bankOffset was resolved.
*   Volume Datatext will update text from scroll wheel changes.
*   Chat frames 'Move to New Window' will no longer add duplicate timestamps.
*   Datatexts added for Quests, Micro Bar, and Equipment Sets; also Armor Penetration, Block, Defense, Dodge, Energy Regen, and Parry on Classic.
*   Datatexts Data Broker options for Label, Text, and Icon were added.
*   Removed delete functionality from Vendor Greys on Classic.

### Version 13.21 [ January 18th 2023 ]
*   Wrath Bank and Bags should work properly.
*   Wrath AuctionHouse skin error resolved.
*   Wrath Ulduar RaidDebuffs added. (Credits: Es)

### Version 13.20 [ January 17th 2023 ]
*   Couple hotfixes from last version.
*   Thirteen Nineteen lost in time.

### Version 13.18 [ January 17th 2023 ]
*   Another attempt to prevent issue with RC Loot Auto-pass getting loot frames stuck.
*   Style Filters adds support for Known Spells (replaces old talents).
*   Datatexts added through LibDataBroker will now start with LDB.
*   Evoker Disintegrate chain tick now cleared when cast failed.
*   Encounter Journal skin updated a little bit.
*   Auras size 29 was bugged, whoops.
*   Evoker added to [class:icon] tag.

### Version 13.17 [ January 2nd 2023 ]
*   Resto Shaman Aura Indicators cleaned up.
*   Vendor Greys will stop trying to sell items to Auto Hammers.
*   Attempt to prevent issue with RC Loot Auto-pass getting loot frames stuck.
*   Microbar for Character page was showing the pushed texture even when it was faded out (on Classic).
*   Warlock Drain Soul ticks no longer escape Castbar.
*   Vanquished error about tutorialInstance, hopefully.

### Version 13.16 [ December 31st 2022 ]
*   Top Auras on Classic / Wrath were accepting Key Up and Down instead of only up causing a double click, sometimes double-remove, when clearing an aura.
*   Nameplate Quest Icons would also appear from stale plates when showing a new Soft Target icon.
*   Buffs and Debuffs (top auras) size option minimum is now 10 and allows odd numbers.
*   Disc Priest Penance will tick upgrade from Harsh Discipline.
*   Clicking the Mission Datatext will open the new expansion page (right click menu will still be able to open older ones).
*   Bank's Ignore Bag menu works again.
*   **Actionbars:**
    *   Keyboard Mouse tutorial was blocking clicks in lower mid area of the screen for some characters.
    *   Added Profession Quality icon buttons which hold profession items (settings under AB -> Profession Quality).
    *   Mouseover Spellbook buttons not highlighting spells on Actionbar buttons.
*   **Filters:**
    *   Mage Greater Invisibility swapped to the aura with a duration.
    *   Added Raszageth auras to Raid Filters and cleaned up Mythic+ Affixes.
    *   Added Evoker Nullifying shroud (PvP) to Turtle Buffs. (Thanks shrom)
    *   Blacklisted some annoyance auras: Riding Along (Skyriding extra seat), Silent Lava, Activated Defense Systems, and Surrounding Storm (Strunraan).
*   **Aura Indicator:**
    *   Resto Druid: adds Tranquility and Adaptive Swarm by default and moves Focused Growth (PvP) slightly left to not stack on top of Spring Blossoms.
    *   Priest: Echo of Light from self and Power Infusion from any unit will display as well and moves Pain Supp and Guardian Spirit to the bottom.
    *   Evoker: adds Dream Breath and Reversion's echo variant, also Life Bind (from Verdant Embrace).
    *   Resto Shaman: adds Earth Shield from self (Elemental Orbit), Earthliving Weapon, and Healing Rain.
    *   Holy Pally: adds Barrier of Faith.

### Version 13.15 [ December 22nd 2022 ]
*   Allow more than two chains for Evoker Disintegrate.
*   Update Season 1 Filters: Dungeon (HoV, AV) Raid (Kurog Grimtotem).
*   Updated LibActionButton: action highlight animation not running smoothly. (Thanks Nevcairiel)
*   Loot Roll sometimes failed to display some items and the type of Bind on Pickup properly.
*   Blizzard's Target Interact Icons can now appear on Nameplates.
*   Looking for Group complaining about GetPlaystyleString (Start a Group button is now intentionally unskinned).

### Version 13.14 [ December 17th 2022 ]
*   Evoker Disintegrate readjusted to display correct chain cast tick amount.
*   Unitframe Castbar error on Classic versions was resolved.

### Version 13.13 [ December 17th 2022 ]
*   Specific Actionbar buttons were refusing to do their job.
*   Evoker Disintegrate will display five ticks when chain cast within the time window (3 seconds).
*   Blizzard Raid Control was busted with the Unitframes disabled.

### Version 13.12 [ December 16th 2022 ]
*   Empowered casts were not showing their levels for some profiles.
*   Press and release casts were messed up (again).
*   Default Bag items wouldn't work (again).
*   Pickup for Actionbar buttons was weird, it still is but less.
*   BagBar error about secure thing and it also had a little useless toggle button when Actionbars were disabled.

### Version 13.11 [ December 16th 2022 ]
*   Addonlists first entry checkbox was definitely not the value color.
*   Empowered Casts display more shiny on Friendly Nameplates.
*   Waygate Travel was added to the Blacklist filter.
*   Blizzard settings can hide during combat (using work-around method).
*   Shiny applied to Trait frames, Weekly Rewards frame, and also polished the buttons on Gossip frame.
*   A little parchment exists on the Profession skin again.
*   Some Instance Icons were missing from Time datatext on German clients.
*   Shamans can see Poison as dispellable again.
*   Priest dispel for disease effects (Improved Purify) was not appearing correctly.
*   InfoPanel's level has been adjusted so that Threat Border can be displayed over the power bar.
*   Some progress bar for quests on Objective Tracker were not skinned (Widget Trackers).
*   Adjusted the Profession and Assignment default colors for Bags (most were slightly dimmed).
*   Bag assignments can be sorted now, also work on classic (looting to that bag seems to work as well).
*   3D Portraits can properly fade out again (using a work-around as this is still bugged).
*   Actionbar Auto Add New Spells setting wasn't working correctly (this is handled by a CVar now).
*   Skyriding was messing up Release Cast spells.
*   Microbar has a new option for the art it displays (ActionBars > MicroBar > Use Icons).
*   RaidUtility would still appear as a black boxes when disabled, that is sorted now.
*   MainMenuBar taint involving PetBar and SetPointBase should be resolved finally.
*   LibActionButton plays nicer with IsSpellInRange, IsAttackSpell, and IsAutoRepeatSpell now.

### Version 13.10 [ December 4th 2022 ]
*   Worldmap coordinates are placed better (anchoring on the actual map).
*   Cauterizing Flame (Evoker) now has dispel support.
*   MultiBarRight had an error about scaling, this caused some boxes to appear and messed with the chat appearing to jump.
*   SexyMap is now on the incompatibility list (it will just alert you to disable our minimap).

### Version 13.09 [ December 3rd 2022 ]
*   Removed Torghast from Time Datatext and added Weekly Reset time.
*   More polish to the Profession look.
*   Menu for Datatext switch was displaying results twice.
*   Bag Datatext displays info correctly again.
*   LFG icon should work with other Minimap addons and moving it is possible in (Minimap > Buttons > LFG Queue).
*   Stylefilter sliders were not showing the correct Max Level.
*   AddonList skin was fixed up a bit.

### Version 13.08 [ December 2nd 2022 ]
*   Removed LibHealComm (if you would like to use it, install the standalone library instead).
*   Attempted to fix taint errors involving the beloved Edit Mode, this includes the errors while levelling up.
*   Profession skin tweaks and the Reagent icon borders were fixed.
*   Profession Orders skin was updated quite a bit too.
*   Spec Switch Datatext is 33.33333% more accurate now.
*   PVP Match Scoreboard scrollbar is now shiny again.
*   Priests should be able to see when they can actually dispel Diseases.
*   Reputation bar was sometimes missing it's standing label.

### Version 13.07 [ November 28th 2022 ]
*   TaintLess was updated to help with some taint problems (Thanks foxlit).
*   LibCustomGlow is back, as the license issue was resolved (Thanks Stanzilla).
*   Nameplate power error about SetStatusBarAtlas was fixed.
*   Bindings skin had an error or two.

### Version 13.06 [ November 21st 2022 ]
*   Flyout direction was wrong sometimes.

### Version 13.05 [ November 21st 2022 ]
*   **LibActionButton updated. (Thanks to Nevcairiel)**
    *   This contains a custom workaround method for Flyouts.
*   Keybind mode will work again for Flyouts.
*   Empowered spells breaking when using KeyUp. (Thanks to Caedis)
*   Tooltip sticking around but using another method this time. (Thanks to siweia)
*   Tooltip status bar might stop getting stuck too.
*   Torghast Minimap breaks less often (hopefully).
*   Spec Datatext has improvements for changing and detection of Spec Loadouts.
*   Main Bag can be ignored from sorting again, also the new Reagent bag.
*   **Windwalker Monk:**
    *   Stop unintentionally showing Totem Trackers (Earth and Fire).
    *   Stop displaying Stagger when using Blizzard's Player Unitframe.

### Version 13.04 [ November 18th 2022 ]
*   Spec Switch was messing up Press-and-Release casting.
*   Fader for Unitframes and ActionBars now understands Empowered casts.
*   Cooldown Target Aura now supports Macro spells.
*   Bag sorting when using Blizzard sort fixed for real for real.
*   Minimap Cluster might stay on the mover this time, for sure.
*   Tooltip sticking around while holding mod key. New option called Fade Out, off will hide it instantly.

### Version 13.03 [ November 17th 2022 ]
*   **Important:**
    *   Empowered spells now support Release and Tap casting.
    *   Reagent Bag support (sorting should work, mostly).
*   Essences now have a color setting.
*   Junk, Reagent, Quest color settings added for Bags.
*   Interrupt announcement caused an error sometimes.
*   Tooltip not showing unit's health value properly.
*   Queue Status error when Minimap Cluster was disabled.
*   Minimap Cluster might stay on the mover now.
*   Bags sort error when using Blizzard's sort.
*   Permeating chill stacks from any source now.
*   Currencies on the bag would sometimes just have mind of their own.
*   Battlefield map was causing an error about position not existing.
*   Communities had some skin errors.

### Version 13.02 [ November 15th 2022 ]
*   **Important:**
    *   Retail 10.0.2
    *   Empowered hold-and-release currently does not work; please use press-and-tap for empowered spells instead for the time being.
*   Classic was erroring about MoveObjectiveFrame.
*   Updated the method to handle disabling Blizzard UnitFrames (Thanks oUF <3)
*   Unitframes and Nameplates support Evokers: Essences and Empowered Casting (Thanks oUF <3)
*   LibRangeCheck updated to support Evokers.

### Version 13.01 [ November 11th 2022 ]
*   **Important Changes:**
    *   Export Compression method changed to use LibDeflate.  
        _This renders past exports useless, a plugin will be provided to convert to the new format._
    *   Libraries moved to **ElvUI_Libraries** and **ElvUI_OptionsUI** is now renamed **ElvUI_Options**.  
        _The three folders for ElvUI are now: **ElvUI**, **ElvUI_Libraries**, and **ElvUI_Options**._
    *   Bag search will now be simplified to using the same API Blizzard provides for their bags.
    *   CustomGlow is now back to ButtonGlow for the time being (no settings for this right now. however, it might change in the future).
*   **Smaller Changes:**
    *   Friends DT will now show Modern Warefare II instead of AUKS.
    *   Loot Roll now has Item Quality Color toggle.
    *   Support for 3840x1200 on Ultrawide option.
    *   Issue complaining on MountIDs.
    *   Search was failing to display some things.
    *   Chat couldn't be resized in Edit Mode.

### Version 13.00 [ November 9th 2022 ]
*   Updated **oUF** to version 11, which powers our UnitFrames and Nameplates (Thanks to oUF team and nihilistzsche).
*   Updated **LibActionButton**, which powers our ActionBars (Thanks to nevcairiel).
*   Season 1 Dungeon and Raid auras added by Luckyone.
*   Paragon Rep not displaying correctly (Thanks to DaveA50).
*   Adjusted layer for GameTime on Minimap, again.
*   EXP Databar layering was a getting reset.
*   Stacking Auras count corrected and ignore Rogue Animacharges.
*   Can remove Bags and drop items into the Container Bags again.
*   Auctionhouse scrollbar being misplaced when skinned.
*   Corrected error when trying to adjust Keybinds (via Settings), and when using Blizzard's Editor mode.
*   Paging Actionbar remover fixed and solved issue with Blizzard Bar 5, 6, and 7 appearing.
*   Attempted taint fix for Objective Tracker, Vehicle Seat Indicator, and MainMenuBar.
*   Some Actionbar (also one on Wrath), Grouping, VehicleButton, and PetBar taints fixed.
*   Objective Tracker Auto Hide fixed along with the Maw Buffs positioning.
*   Wrath Pet Bar spells can be adjusted without the grid going away again.
*   Blizzard Arena frames (including Arena pets) being spawned as well.
*   Loot frame error about item not existing.
*   Rune color settings fixed on Wrath.
*   BoE displaying incorrectly on the icon.
*   Combo point and Monk Chi default colors updated.
*   Some items around the UI were not showing Quality colors.
*   Default Bags behave better on this version (when using items).
*   Default Actionbar Bindings were getting destroyed on spec switch (still happens from messing with Blizzard's Edit Mode).
*   Target sound playing rapidly on lost of target.
*   Bag sound triggering on pressing ESC when bags weren't shown.
*   Totem Tracker on Wrath has the options fixed.
*   Added Item Level display for Loot Roll items.
*   Attempted fix for the last Bag would sometimes be disabled.
*   Datatext Audio Switch error resolved.

### Version 12.99 [ October 31st 2022 ]
*   **Known Issues** are posted in pins on Discord: **#elvui-retail-support**
*   Actionbar KeyDown setting has returned.
*   Corrected issue with WeakAura cooldowns blinking the text when using reverse toggle.
*   Incompatibility issue with Masque corrected.
*   Fixed random MicroBar error 142.
*   Adjusted Retail Bag currency position a bit.
*   TalkingHead mover is now set by EditMode correctly.
*   Queue Status Eye layered again (this time hopefully correctly).
*   Color setting for the 7th Combo Point.
*   Further updated the Achievement skin.
*   Adjust Tabs for most frames to look cleaner.
*   Gossip Text will now display correctly.

### Version 12.98 [ October 29th 2022 ]
*   **Known Issues** are posted in pins on Discord: **#elvui-retail-support**
*   Bags can now track more than three currencies (currently up to 20).
*   Fixed a few errors with the new Default Bags skin.
*   Actionbar Cooldown charge swiping should appear correctly again.
*   Battlefield map should now show the player location correctly.
*   Fixed an issue with Masque compatibility (Thanks Barkskin).
*   Reactivated the Queue Status Timer (Minimap Button option).
*   Druid paging on Wrath corrected.

### Version 12.97 [ October 29th 2022 ] - **This log is really for 12.96**, as 12.97 is actually just part of the Editor Mode skin.
*   **Known Issues** are posted in pins on Discord: **#elvui-retail-support**
*   Updated Skins for Class Trainer and Gossip Frame
*   Updated Chinese locales (Thanks Loukky)
*   Battlefield map can show up again
*   Added position options for Arena Castbar
*   Main Chat should behave a little better with Blizzard's mover
*   Rebalanced Minimap layers
*   New method to hide totems on Totem Tracker (hopefully will keep them hidden correctly)
*   New Mirror Timers skin
*   Removed old Talent skin (was causing an error)
*   Player UnitFrame mover will show again when module is off
*   Added Editor mode skin
*   Fixed Exit Vehicle button
*   Fixed Target of Target spawning sometimes
*   Fixed the issue with using items in the default Blizzard Bags and fixed the skin for them (combined and split - also updated bag bar skin)
*   Fixed the Currencies in Bag not updating when they should
*   Fixed Blizzard movers not appearing when UnitFrame module is disabled
*   Fixed LFG Queue Status not showing up when Minimap was disabled and Actionbar was enabled
*   Fixed double Cooldown showing on Actionbars - was missing in the LAB
*   Fixed error when clicking Game Menu from the Minimap
*   Fixed Hit Datatext not working and Currency not showing right
*   Fixed UnitFrame error with SetReverseFill
*   Fixed issue which caused a layer to be over the Bags (making things unclickable)
*   Fixed Audio Datatext opening to settings
*   Fixed Settings Panel skin not showing the correct toggled state on open
*   Fixed the ColorPicker not showing the RGB values on open
*   Fixed issue with aura bars and resting indicator when enabling the Player UnitFrame

### Version 12.95 [ October 26th 2022 ]
*   **Known Issues** are posted in pins on Discord: **#elvui-retail-support**
*   Support for Cooldown module working with WeakAuras _(pending on their side)_.
*   Top Auras can be right clicked canceled again.
*   GuildBank, ReadyCheck, GossipFrame, and BlackMarket skins have been fixed.
*   Blizzard's Chat mover will work when our Panels are set to HideBoth (after reloading).
*   WidgetsUI error fixed relating to StatusBarAtlas.
*   Bag frame tokens should appear again.
*   Adjusted the fix for Blizzard Party frames.
*   Adjusted the fix for Vehicle Mover on Wrath.
*   SetFont error hopefully resolved.

### Version 12.94 [ October 26th 2022 ]
*   This version took a left instead of a right and never found its way home.

### Version 12.93 [ October 26th 2022 ]
*   **Known Issues** are posted in pins on Discord: **#elvui-retail-support**
*   Hotfixes for version **12.92**.
*   Fixed Vehicle Mover not showing up on Wrath.

### Version 12.92 [ October 25th 2022 ]
*   **Known Issues** are posted in pins on Discord: **#elvui-retail-support**
*   Support for **Patch 10.0.0** on Retail.

### Version 12.91 [ September 25th 2022 ]
*   **All:**
    *   Fixed error when Spec Switching involving Raid Role Icons.
    *   Target Aura won't activate unless using our cooldown module.
    *   Style Filters with Aura triggers should preform slightly better.
    *   Fixed the strange issue where two Main Tank or Assists would cause the frames to become very long.
*   **Wrath:**
    *   Fixed Paladin Dispel.
    *   Fixed Battlefield skin error.
    *   Interrupted spells when activate will now link the spell.
    *   Added Cone of Cold ranks to CCDebuffs.

### Version 12.90 [ September 19th 2022 ]
*   Fixed visual issue with cooldowns on Pet bar.
*   Fixed issue with Remove Corruption on Boomkins.
*   Fixed error when trying to add a spell to Aura Highlight.
*   Fixed issue with Target Aura not updating when switching forms on Druid.

### Version 12.89 [ September 18th 2022 ]
*   Added Totem Tracker (General > Totem Tracker) to Wrath (Ghoul, Totems, etc timers).
*   Added Totem Bar settings under (ActionBars > TotemBar) for Wrath.
*   Blacklisted Joyous Journeys (still shows in Buffs by Minimap).
*   Raid Debuffs font defaulted to PT Sans Narrow.
*   Skinned BG Queue Tabs (Wrath).
*   Fixed Rune / Totem colors not appearing how they should.
*   Made Earth Totem first (how Blizzard has it) on Wrath.
*   Adjusted how we skin some Dropdowns.
*   Updated Aura Indicator for Wrath so that ranks are joined (adjusting settings of one spell works on all ranks).
*   Added stack options for Aura Indicator.
*   Implemented fix for Auras not anchoring correctly. (Thanks Zhizhica)

### Version 12.88 [ September 16th 2022 ]
*   Fixed **more** issues with Aura Highlight not working.
*   Fixed issue where Target Aura wasn't working on Classic/Wrath.
*   Added a Flash Client Icon in Chat settings.
*   Totem Bar was renamed to Totem Tracker. This is for future support on Wrath for classes which utilize it. Wrath still has a Totem Bar (for shamans) but will _soon_ have both.

### Version 12.87 [ September 14th 2022 ]
*   **Important changes are in version 12.85 from September 11th.**
*   Fixed issues with Aura Highlight not working.
*   Fixed error with loyalty tag on Wrath.
*   Fixed Restore Defaults button on Raid1-3.
*   Added the rest of the Wild Growth ranks for Druids on Wrath.

### Version 12.86 [ September 12th 2022 ]
*   **Important changes are in version 12.85 from September 11th.**
*   Added Weakened Soul for Wrath to Aura Indicators.
*   Fixed issue with fonts on Raid Frames.
*   Fixed issue with mover on Totem Bar for Wrath.
*   Attempted fix for a rare cooldown error from last version.
*   Attempted fix for Info Panel erroring about backdrops.

### Version 12.85 [ September 11th 2022 ]
*   **Important:**
    *   Raid 1-3 now which has a new "Max Allowed Groups" which replaces Smart Raid Filter (visibility settings reset for the new setup)
    *   Target Auras (action bar cooldowns): This is used to see the Duration of applied Dot or Hot on your target. It can be disabled in Cooldowns > ActionBars > Target Aura
*   **Changes:**
    *   Added delete all and updated Gold Datatext
    *   Added Aura Bar Spell Name Abbrev
    *   Added Combat Indicator for Party
    *   Fixed heal pred erroring on profile change
    *   Fixed AFK mode reseting timer
    *   Fixed Arena portraits (Thanks Paqa)
*   **Style Filters**
    *   Improved Performance of Hide/NameOnly actions as well as improved Is Targeting Me
*   **Retail**
    *   Fixed Outfit Links in chat
*   **Classic/Wrath**
    *   Fixed heal comm errors
    *   Fixed some skins and added pvp skin
    *   Consolidate auras hidden
    *   Boss frames for wrath
    *   Attempted Totem Bar fix for Shamans
    *   Fixed paladins and shamans not seeing dispels
    *   Added wild growth for Aura Watch on Druids
    *   Fixed Quest XP on XP Datatext
    *   Added DualSpec Datatext for wrath

### Version 12.84 [ August 31st 2022 ]
*   Fixed weird chat error on some TW bosses
*   Error on Death Knights while leveling
*   Adjusted Gold Datatext code for performance
*   Fixed issue with Auras not displaying correctly when adjusting it's Filter
*   Monk Stagger class power tag was messed up
*   Fixed not being able to click the Calendar button
*   Updated LibActionButton

### Version 12.83 [ August 16th 2022 ]
*   Includes fixes but Simpy didn't do changelog yet.

### Version 12.81 [ July 6th 2022 ]
*   Optimizations: Fixed an issue when using ElvUI and WeakAuras together, which caused increased loading screens and some auras to disappear. (Script ran too long error)
*   ActionBars: Fixed bar backdrop multiplier (ticket #245)
*   DataTexts: Added Diablo Immortal and Warcraft Arclight Rumble support for Friends
*   DataTexts: Added NoLabel option for Intellect
*   DataTexts: Removed faction restriction from Friends invite
*   Filters: Added support for season 4 Affix and Dungeons
*   Filters: Updated for Castle Nathria and Sanctum of Domination

### Version 12.80 [ May 31st 2022 ]
*   ActionBars: Stance bar fixes (issue #163).
*   DataTexts: Added No Label option for combat timer text.
*   Locales: Updated German (Credits: Dlarge).
*   NamePlates: Fixed class color source option for interrupts.
*   Skins: Updated guild crafters skin.
*   Skins: Updated world map quest skin (issue #128).
*   UnitFrames: Fixed power text getting misplaced onto health if power is hidden (issue #15).

### Version 12.79 [ May 8th 2022 ]
*   NamePlates: fixed target indicator displaying many arrows.
*   DataTexts: added label / no label for durability and bags.
*   DataTexts: custom labels can be colorized with color tags.

### Version 12.78 [ May 6th 2022 ]
*   StyleFilter: fix a couple import and export bugs
*   Chat: block other secure commands like /focus from being saved to editbox history
*   NamePlates: fixed debuffs being able to attach to debuffs in options
*   NamePlates: block widget tooltips on forbidden nameplates
*   NamePlates: added new Prefer Target Color option along with Low Health Color and Low Health Half color settings
*   Cooldowns: fixed Rogue Stealth displaying as nan and flashing too often
*   Filters: blacklisted A Gilded Perspective

### Version 12.77 [ May 1st 2022 ]
*   AuraBars: Fixed alignment with size override setting
*   Cooldown Text: Added support for cooldown reduction buffs (Urh Relic, Faeries, etc) with a color setting under Threshold Colors "Modified Rate"
*   DataTexts: Added option for time DataText to disable flashing for new calendar invites
*   Locales: Updated deDE (Credits: Dlarge)
*   Locales: Updated zhTW (Credits: fang2hou)
*   Misc: Fixed Raid Utility not saving position correctly
*   Nameplates: Added ability to export and import selected style filters
*   Tooltip: Added font options for tooltip header
*   UnitFrames: Player Classbar now have an option to toggle Displaying Mana
*   UnitFrames: Readded "Start Near Center" option for party

### Version 12.76 [ April 20th 2022 ]
*   UnitFrames: Add ability to change pet happiness colors
*   UnitFrames: Add ability to hide Rest Icon at max level
*   UnitFrames: Add ability to scale the Raid Role Icon
*   UnitFrames: Readd missing option to Show/Hide Spec Icon on Arena frames
*   Skins: Adjusted the 2 tabs on the Macro skin to accommodate larger toon names
*   Tooltips: Fix tooltip count on Enchant crafting window when mousing over the reagents

### Version 12.75 [ April 8th 2022 ]
*   StyleFilters: Add missing defaults for in party/raid
*   StyleFilters: Add Not Resting, No Target conditions

### Version 12.74 [ April 4th 2022 ]
*   Tags: Added **[group:raid]** which displays current group number (only while in a raid)
*   StyleFilters: Optimized execution of filters for performance gain
*   UnitFrames: Fixed vehicle not swapping units
*   Added PvP trinket effects: Gladiator's Resolve and Eternal Aegis
*   Repaired gold text will now match Vendored Grays gold format

### Version 12.72 [ March 22nd 2022 ]
*   Filters: Added back Castle Nathria buffs and debuffs
*   UnitFrames: Added support to display all Seeds of the Pantheon fight in Boss Frames
*   UnitFrames: Boon of the Ascended will no longer fade out Raid Frames
*   UnitFrames: Fixed aura rows overlapping

### Version 12.71 [ March 18th 2022 ]
*   Skinned Encounter Journal Item Sets
*   Updated code for AuraBars anchoring (works better attached to centered elements)
*   Fixed Auras not being sorted correctly sometimes
*   Added Unbound Freedom to PlayerBuffs (thanks Shrom)
*   Updated German locales (thanks DlargeX)
*   Optimized Alt Power Bar code a bit

### Version 12.70 [ March 12th 2022 ]
*   **Hotfix:** fixed an issue with middle click focus

### Version 12.69 [ March 11th 2022 ]
*   **Hotfix:** adjust fix for the chat format error, it was causing an issue with colored boss names
*   **Filters:** Aurelid Lure added to RaidBuffs

### Version 12.68 [ March 11th 2022 ]
*   **Hotfix:** better Clique compatibility
*   **Chat:** fixed a Blizzard format error from Charged Constructor

### Version 12.67 [ March 10th 2022 ]
*   **Bags:** let sort ignore bags which are flagged to be ignored
*   **Options, Aura Bar:** fixed custom backdrop color setting
*   **Options, Nameplate:** fixed clickable size not updating height slider max values
*   **Options, StyleFilter:** fixed error about triggers
*   **Options, StyleFilter:** allowed lower scale options
*   **UnitFrames:** fixed text color flickering on aura watch indicators
*   **UnitFrames:** updated oUF to fix vehicle and arena units not updating properly
*   **UnitFrames:** clique to handle mousedown state if enabled
*   **Tags:** [classification] is localized now
*   **Locales:** updated Chinese (thanks to Loukky!)
*   **Filters:** updated for Sepulcher fights

### Version 12.66 [ February 24th 2022 ]
*   **Changes:**
    *   Click Casting: Moved into Actionbar settings (this includes Mouseover Click Key)
    *   Added Zereth Mortis buffs to Raid Buffs
    *   Fixed Chat Error from Monster Emotes on Russian Clients (this patches a Blizzard Issue)
    *   Fixed Macrobook skin not showing the icons you can change to on open
    *   Fixd Quest Interaction text not appearing in the new language
    *   Fixed issues with text on Spellbook and updated the skin a bit
    *   Fixed Spellbook profession buttons triggering a taint
    *   Fixed various issues with Click Binding
    *   Fixed Cosmic Energy Widget
    *   Fixed Barbershop Error

### Version 12.65 [ February 23rd 2022 ]
*   **Hotfixes:**
    *   ActionBars: support for Check Mouseover Cast
    *   Search: some options were hiding from the display (some still are)

### Version 12.64 [ February 22nd 2022 ]
*   **Important:**
    *   Another overall performance update (related to Auras by Minimap)
    *   Please post feedback in the elvui-performance channel on our Discord
*   **Changes:**
    *   Chat: Fixed chat alerts playing on chat history
    *   General: Minimap mover will match Minimap that has a scale other than one
    *   Locales: Updated Russian translation (Credits Enkaf)
    *   NamePlates: Fixed Aura Style Filters not triggering because of the element being disabled
    *   NamePlates: Fixed errors when deleting a Style Filter
    *   UnitFrames: Aura Bars will now work with Fluid Smart Aura positioning
    *   UnitFrames: Raid Role Indicator now supports Main Assist and Main Tank
    *   UnitFrames: Updated filters for Sepulcher of the First Ones and Season 3

### Version 12.63 [ February 12th 2022 ]
*   **Important:**
    *   Increased overall performance (should be noticable in raids and battlegrounds)
    *   Please post feedback in the elvui-performance channel on our Discord
*   **Changes:**
    *   Bank: Improved bank performance, fixed items not updating
    *   Chat: Fixed Copy Chat Lines
    *   General: Fixed Alternative Power options
    *   Skins: Fixed performance issues in our spellbook skin
    *   UnitFrames: Added heal prediction to frames missing it
    *   UnitFrames: Classbar in Druid Bear Form can now display Mana
    *   UnitFrames: Fixed aura bar flickering
    *   UnitFrames: Improved aura positioning and performance

### Version 12.62 [ January 23rd 2022 ]
*   Auras: Added color toggles for Enchants & Debuffs.
*   Unitframes: Added PVP Classification Widget for Party, Raid, Raid40.

### Version 12.61 [ January 19th 2022 ]
*   UnitFrames: Fixed AuraBars font issue

### Version 12.60 [ January 18th 2022 ]
*   **Important:**
    *   ActionBars: Swapped to Custom Glow (General -> Cosmetic)
    *   Config: Added Search section (with Whats New button)
*   **Changes:**
    *   Auras: Top Aurs time will have cooldown time updated properly in Tooltip
    *   Config: Fixed error when deleting a StyleFilter
    *   Config: Fixed some options displaying in Russian
    *   Minimap: Scaling and Font fixes for Location
    *   Misc: LootRoll has several new options
    *   Movers: Added mover for TimeAlertFrame on Korean region
    *   NamePlates: Attempted to fix Widget alpha/scaling issues
    *   NamePlates: Fixed Desaturate Icon option
    *   NamePlates: Fixed Off Tank setting and added an Off Tank (Pets) which shows some off tank pets
    *   NamePlates: Fixed Quest Icon text position option
    *   Skins: Attempted to fix "New Mythic+ Season" overlap issue another way
    *   Skins: Fixed conquest and PVP rating tooltip skin
    *   Tags: Fixed [class:icon] cropping
    *   UnitFrames: Added an option to toggle Blizzards default Castbar
    *   UnitFrames: Fixed "attach to" option for Ready Check Icon
    *   UnitFrames: Fixed "Display Target" as it only works for Player
    *   UnitFrames: Fixed kyrian rogue charged combo points
    *   UnitFrames: Fixed non attached Castbar Icon
    *   UnitFrames: Fixed sort by class option

### Version 12.58 [ December 4th 2021 ]
*   ActionBars: Fixed layering issue with keybind text
*   Bags: Fixed an issue with mouseover tooltip
*   Bags: Added an option to hide Gold
*   Chat: Added an option to hide Channel names
*   DataTexts: Fixed Bags DataText coloring
*   NamePlates: Updated StyleFilters config code
*   Minimap: Added option to scale the Minimap instead of resize (which also adjust map pins)
*   Misc: Reworked LootRoll and added more options for it
*   Skins: Hovering an item will now highlight properly in the Guild Bank
*   UnitFrames: Added reverse fill option for Aura Bars

### Version 12.57 [ November 22nd 2021 ]
*   Bags: Count position was getting stuck
*   UnitFrames: Fixed an issue with transparent power color
*   UnitFrames: Added option to Auto Hide Power out of combat
*   WorldMap: Fixed Coordinates level and a few Fullscreen Map issues
*   Skins: Fixed the Widget Bar not being skinned properly
*   Skins: Error when using Barbershop

### Version 12.56 [ November 16th 2021 ]
*   Datatext: Readded Haste customization settings
*   Skins: Fixed Tooltip skin when they have an embedded statusbar
*   ActionBars: Fixed issue when buttons wouldn't update count after being traded
*   Bags: Corrected the display of Cooldown timers (sometimes they wouldn't appear)
*   Filters: Added Soothing Mist to Monk Aurawatch

### Version 12.55 [ November 13th 2021 ]
*   Tooltip: Fixed Item Quality Color error
*   Datatext: Readded events for several stat datatexts

### Version 12.54 [ November 13th 2021 ]
*   Bags: Adjusted how Bags and Bank are updated
*   Cooldown Text: Added a global option for rounding and improved transition between one minute and seconds
*   Datatexts: Add Leech back in and fixed MovementSpeed not updating properly
*   Tooltips: Add option to display Item Count when using the Modifier for Item IDs

### Version 12.53 [ November 11th 2021 ]
*   Datatext: Fix error with Experience

### Version 12.52 [ November 11th 2021 ]
*   Chat: Fixes for overflowing chat tabs
*   Cooldowns: Fixed issues with HH:MM and MM:SS
*   Locales: Updated Russian translation (Thanks Hollicsh)
*   UnitFrames: Fixed Focus and FocusTarget

### Version 12.51 [ November 10th 2021 ]
*   Bags: Added auto toggle option for vendor and bank
*   DataBars: Fixed an error when switching profiles
*   Datatexts: Fixed BattleStats and Movement Speed
*   Filters: Fixed AuraBar colors not setting the selected color
*   Skins: Fixed Keybind Frame having weird shadows
*   Tooltips: Fixed Mythic+ Score options

### Version 12.50 [ November 9th 2021 ]
*   World Map: Fixed issue which kept the Quest Model Scene shown
*   DataTexts: Fixed errors loading Avoidance and Ammo (they are for Classic)
*   Bags: Fix Main Bag icon when Bag Module is off (Bag skin)

### Version 12.49 [ November 9th 2021 ]
*   ActionBars: Fixed ExtraActionButton hotkey text
*   Bags: Added Auto Toggle options to open bags with specific frames
*   Bags, DataTexts: Use Blizzards new coin icons
*   DataBars: Added an option to flip threat colors on tanks
*   General: Updated RaidUtility (added Main Tank and Main Assist buttons)
*   Locales: Updated Russian translation (Thanks Hollicsh)
*   Minimap: Fixes for MiniMap AddOn icons
*   Nameplates: Added back offset options for power
*   Nameplates: Fixed an issue which broke the "Add Filter" dropdown
*   Skins: Fixed Covenant Follower Tooltip skins
*   Tooltips: Fixed item quality color error with Tooltips skin disabled
*   UnitFrames: Fixed an issue in Boss frames options (Issue #44)
*   UnitFrames: Fixed Castbar Icon settings

### Version 12.48 [ November 4th 2021 ]
*   Options: Fixed Add Filter for Nameplate Debuffs

### Version 12.47 [ November 4th 2021 ]
*   Bags: Fixed Bag Bar bags not toggling bags
*   Bags: Fixed Bag Bar backdrop for only backpack option
*   Nameplates: Added aura sorting
*   Skins: Fixed Guild Roster skin error
*   Skins: Fixed Item Upgrade button
*   Tooltips: Fixed item quality color
*   UnitFrames: Adjusted leader icon frame strata

### Version 12.46 [ November 2nd 2021 ]
*   The text on Popups is now displaying correctly

### Version 12.45 [ November 2nd 2021 ]
*   **Notes:**
    *   Development is now on GitHub (was GitLab)
    *   Unified our codebase to support Retail, TBC and Classic
*   Added an option to hide chat in AFK screensaver mode
*   Added support to toggle single bags
*   Updated available tags and descriptions
*   Added a button in bags and bank to stack items of the same type
*   Added an option to color Tooltip border based on item quality
*   Added support for the new Call of Duty in friends DataText
*   Fixed a bug with the border color on top auras
*   Fixed Arena-Prep frames
*   Fixed AuraWatch sizeOffset Lua error
*   Fixed experience DataBar error on trial accounts
*   Fixed island expedition queue Tooltip
*   Skin fixes and new skins for patch 9.1.5

### Version 12.44 [ August 27th 2021 ]
*   Tags: Added [selectioncolor]
*   Fixed: Charged Combo points for Rogue Legendary
*   StyleFilter: Added triggers for Items, Slots, and Dispellable
*   Datatext: Combat Time will now prefer Encounter Time in instances, rather than own Combat Time
*   Unitframe: Fixed a rare oUF_RaidDebuff error (priority was missing)
*   Unitframe: Raid Pets are now optional with Smart Raid
*   Nameplate: Attempted fix for another GetPoint error
*   Skins: Fixed borders for Blizzard Interface Settings
*   Skins: Fixed Multisell frame on Auction House

### Version 12.43 [ August 17th 2021 ]
*   **Changes:**
    *   Player Choice should be fixed in Torghast when in combat
    *   Added a Mythic+ Best Run tooltip option

### Version 12.42 [ August 16th 2021 ]
*   **Changes:**
    *   Added a mover for Player Choice Toggle
    *   Added Mind Soothe (Priest) to CCDebuffs
    *   Fixed Right / Left anchor for Auras on Unitframes and Nameplates
    *   Fixed an issue which prevented sending secure commands through Chat while in combat
    *   Fixed an issue with Blizzard Effects (which caused them to be incorrect size and placed in wrong location)
    *   Fixed Replaced Chat Bubble Font not working correctly
    *   Fixed Static Player and Test Nameplate Scale
    *   Fixed Aura Spacing on non-thin borders
    *   Fixed Pushed texture on ActionBars
    *   Updated various skins
*   **Commands:**
    *   Deleted **/cleanguild** as it was old and protected for some time
    *   Renamed **/enableblizzard** to **/eblizzard**
    *   Renamed **/luaerror** to **/edebug**
    *   Renamed **/resetui** to **/ereset**
    *   Renamed **/moveui** to **/emove**

### Version 12.41 [ August 6th 2021 ]
*   **Changes:**
    *   Chat Bubbles have their own Replace Font setting (General -> Cosmetic) and have their default font slightly increased to 12
    *   Fixed another Plugin Tag issue from 12.39

### Version 12.40 [ August 5th 2021 ]
*   **Oops:**
    *   Added API for Plugins (which all need to be updated) for recent Tags issue in 12.39

### Version 12.39 [ August 5th 2021 ]
*   **Fixes:**
    *   AuraBars not sorting correctly.
    *   Reduced default Chat Bubble Font size down to 10.
    *   Incompatibility issue with Clique and [mouseover] tags on Unitframes. (Thanks Mitälie!)
    *   Nameplate Boss Mod Auras will now be trimmed when not using Keep Size Ratio.

### Version 12.38 [ August 2nd 2021 ]
*   **Big Aura Update:**
    *   UF/NP: Added Centered Support, Size Ratio, Stack Count offsets, Stackable Auras (Bolstering, Force of Nature, etc)
    *   Nameplate: Added Rows, Attach To, Castbar Text and Time offsets, Smart Aura Position, and Blizzard Plate Font settings
    *   Unitframe: Added GrowthX and GrowthY settings and also improved Smart Aura Position
    _note: The GrowthX and GrowthY may need to be adjusted in your settings, if you are not using default_
*   **Updated:**
    *   Added [classcolor:target] for class color of units [target]
    _note: [classcolor] is the new [namecolor], however [namecolor] will continue to work_*   Added Style Filter trigger for Faction and a [factioncolor] tag
    *   Setup CVars will no longer reset Nameplate CVars if the Nameplate module is disabled
    *   Bank and Bags Quality color setting wasnt working correctly
    *   Reagent and Bank anchor was sometimes off
    *   Unitframe Combat Icon offsets increased
*   **Skins:**
    *   Trade, Communities, and Auction House skins updated
    *   Chat Bubble Border and Guild Control skin issues fixed
    *   Season PVP Reward Icon had checkmark behind it
    *   Orderhall and Garrison mission skin fixes

### Version 12.37 [ July 25th 2021 ]
*   **Nice:**
    *   Added option to hide border colors for NP/UF Auras entirely (Borders by Type and Borders by Dispel)
    *   Event Toast mover actually works (maybe, I think) :o
    *   French Translation update (Thanks @xan2622)

### Version 12.36 [ July 24th 2021 ]
*   **Better:**
    *   Bags :D
    *   Blizzard Bags skin :)
*   **Good:**
    *   Event Toast has a mover now, which is new Level Up display.
    *   Style Filters were messing with Nameplate Highlight texture.
    *   Mythic Challenge icon wont be so faded.
    *   Group Finder had wrong Premade Groups icon.

### Version 12.35 [ July 17th 2021 ]
*   **MegaShiny:**
    *   Added Nameplate support to show DBM or BigWigs auras on nameplates, stuff like Fixate. Settings under (Nameplates > General > Boss Mod Auras).
    *   Added support to Style Filters to trigger based on Boss Mod Auras.
*   **Shiny:**
    *   Improved preformance of Bags module.
    *   Added Season 2 Dungeon Affix Debuffs and Blacklisted Drained debuff.
    *   Added Slider for Reputation Databar alpha when not using custom colors.
    *   Added Unit Class Color action to Style Filters.
*   **Fixed:**
    *   Fixed Guild Bank search not fading the tabs.
    *   Fixed Power Prediction overflowing sometimes.
    *   Fixed Chat Bubble borders when using no border on non-thin borders.
    *   Fixed Chat window could not be closed in combat.
    *   Fixed rare Mover error linked to numpad keys.
    *   Fixed Blanchy mount display on Unit and Aura.
*   **Updated:**
    *   Increased range to scale Minimap icons more.
    *   Updated the shading on Bag items when you search.
    *   Updated the normal Bags skin code a bit, also some of the bank too.
    *   Nameplate Auras now has a "Color by Type" option which will remove the debuff type border color (stealable and bad dispels will still be shown).

### Version 12.34 [ July 8th 2021 ]
*   **Stuff:**
    *   Added mover for the Maw Buffs widget in raid/dungeons.
    *   Removed Guide text from mentor chat, icon will still show.
    *   Added some options for the top and bottom cosmetic panels (under the new cosmetic tab, under general).
    *   Fixed Unitframe Custom Color options for Castbars not properly updating when switching between characters on same profile.
    *   Fixed issue with Ultrawide / Eyefinity not letting you move frames to the left screen.
    *   Fixed Spellbook error in combat (happened when leveling).
    *   Added Mistweaver PVP Buffs (Peaceweaver and Dematerialize) to the Whitelist.
    *   Fixed Player Choice skin in Mythic+

### Version 12.33 [ July 4th 2021 ]
*   **Stuff:**
    *   Chat Module now supports new Text To Speech options (Options > Install > Setup Chat, might be required, do this if you have issues).
    *   Added Korthia buff (Anima Gorged) to Whitelist.
    *   Fixed a couple issues with Trade Skill skin.

### Version 12.32 [ July 3rd 2021 ]
*   **Ok:**
    *   Skinned a few unskinned things.
    *   Added Korthia buff (Rift Veiled) to Whitelist.
    *   Updated Range Check Library.

### Version 12.31 [ July 1st 2021 ]
*   **Hotfixes:**
    *   Fixed Player Choice skin error in tower (once more).
    *   Fixed an issue with the Ace3 skin which caused some buttons to fill the screen.
    *   Fixed an issue which caused some borders to overlap when not using pixel mode.
    *   Allowed Chat Bubbles to be skinned in tower since they seem to not be allowed there.

### Version 12.30 [ June 30th 2021 ]
*   **Hotfixes:**
    *   Fixed Barber skin error.
    *   Fixed Achievement skin error.
    *   Fixed Orderhall Talent skin.
    *   Fixed Player Choice skin while in tower (again).

### Version 12.29 [ June 29th 2021 ]
*   **Hotfixes:**
    *   Readded Item Info options for Bag slots.

### Version 12.28 [ June 29th 2021 ]
*   **Hotfixes:**
    *   Talent spec spell icons slightly larger.
    *   Fixed bag skin (not the all in one bag).
    *   Hide mythic score when its at zero.

### Version 12.27 [ June 29th 2021 ]
*   **Hotfixes:**
    *   Fixed error when Ace3 skin was disabled.

### Version 12.26 [ June 29th 2021 ]
*   **Hotfixes:**
    *   Fixed Toolkit SetBackdrop error.

### Version 12.25 [ June 29th 2021 ]
*   **Added:**
    *   Mythic+ score options in the tooltip section (Based on Blizzards new score API).
    *   Option to enable/disable the Combat Repeat function in Chat.
    *   Position, X-Offset, Y-Offset options for Item Count and Item Level in Bags.
*   **Fixes:**
    *   Fixed interruptible and nonInterruptible colors in castbars.
    *   Fixed rare healprediction lua error.
    *   Fixed rare power prediction lua error.
    *   Fixed rare tempHistory chat lua error.
    *   Fixed skins for patch 9.1
*   **Added:**
    *   Optimized auras code, some players might notice a FPS gain in big mob pulls.
    *   Updated filters for Sanctum of Domination (All difficulties).
    *   Updated filters for Tazavesh, the Veiled Market (Mythic).
    *   Updated range tags.
    *   Updated tooltip options.

### Version 12.24 [ March 19th 2021 ]
*   **Cool:**
    *   Apply to All for Aura Indicator on Pet and Focus now works correctly.
    *   Updated Style Filter code for Casting triggers and fixed a few bugs when using Name Only in nameplate settings.
    *   Fixed an issue which caused the Static and Real Player nameplate to display at the same time.

### Version 12.23 [ March 12th 2021 ]
*   **Hotfix:**
    *   Locale was forcing the Options into English for some languages.

### Version 12.22 [ March 12th 2021 ]
*   **Nice:**
    *   Alter Time for Mages corrected on Player Buffs and Turtle Buffs.
    *   Nameplate Target Classbar should show properly again and play nicely with Style Filters.
    *   Updated Style Filter code a bit, which prevents flickering of Name Only mode Nameplates.
    *   Addon Manager skin can now display addon names in other languages, instead of squares.
    *   Removed Vender Greys display as Blizzard has added one, however we kept our Detailed option to show the price of each.

### Version 12.21 [ March 9th 2021 ]
*   **Important:**
    **This version is for patch 9.0.5.**
*   **Added:**
    *   PowerBar widget now has a mover
    *   Click-Through option for AuraBars
    *   Mouseover and Alpha setting for Voice Chat Panel
    *   Frame Level and Strata options for DataBars and ActionBars
    *   Paragon display for Reputation Bar (optional bag icon when loot is available)
    *   Heal Prediction and Threat options for Party Pets
    *   Threat options for Tank Target and Party Target frames, Raid Icon option for Pet frame
    *   Turtle Buffs and Player Buffs updated (Thanks Shrom)
    *   NamePlate Target Arrow textures (Thanks Releaf) with the option to Scale and Space them
    *   Another Player Resting Icon (Thanks Releaf), along with a few Minimap Mail icon options
    *   New Role Icons displayed when you queue (Thanks Releaf - also, no it doesnt have an option)
    *   StyleFilter triggers for UnitRole, InParty, and InRaid
*   **Fixed:**
    *   Spooky Arena Prep Frame bugs
    *   Trinket bugs on Arena Frames
    *   Actionbar Paging wasnt exporting
    *   Error in ClassPower on NamePlates
    *   Error in Currency and Difficulty Datatexts
    *   Experience DataBar not displaying correctly after toggling
    *   StyleFilter code updated to hopefully correct several issues
    *   Zone and Boss Button code updated (global fade works on them again)
    *   StanceBar options not updating without a reload

### Version 12.20 [ February 3rd 2021 ]
*   **Fixed:**
    *   Paladin Aura Mastery lag issue
    *   Gold format Short (Whole Numbers Spaced) error
    *   Swapped the layout of Available Tags listing for readability
    *   Power Shortvalue will follow the same rules by hiding if 0

### Version 12.19 [ February 2nd 2021 ]
*   **Added:**
    *   Bag Item Info option to change Anima text style
    *   Sort by Index option for Unitframes
    *   Classpower Shortvalue Tags
*   **Fixes:**
    *   Experience Bar Error
    *   Grey Value corrected on Gold Datatext
    *   ActionBar Masque settings were not letting you toggle text
    *   Hotkey Range Color when using text range coloring
    *   Garrison and Island tooltips

### Version 12.18 [ February 1st 2021 ]
*   **Updated Parts:**
    *   **[IMPORTANT]** Action Bar pages will finally match the bar numbers
    *   Text settings for Action Bars: Hotkey, Macro, Count
    *   Arena Trinkets and Arena Prep
    *   Multiple Skins
    *   Raid Auras
*   **Fixed Stuff:**
    *   Delete Grey Items
    *   Quest Experience Bar
    *   Boss Banner Error
    *   Nameplate Widget Error
    *   Rare ILvl error when Inspecting
    *   Auto Repair when not in Guild
    *   Mend Pet (Hunter) in Aura Watch
    *   Stance and Pet buttons were not properly hidden
*   **Added Things:**
    *   Anima in Bags
    *   Just Backpack to Bag Bar
    *   Aura Watch on Focus and Boss Frame
    *   Enveloping Breathing (Monk) to Aura Watch
    *   Charged Combo Point (Rogue) on UnitFrames and NamePlates
    *   Show Max Currency setting for Currency Datatext
    *   Torghast Info onto the Time Datatext
    *   Daily Reset added to Time Datatext
    *   Grey Items Value on Bags Datatext
    *   Condensed (Spaced) and Short (Whole Numbers Spaced) format options added to Gold Datatext
*   **Tag Changes:**
    *   **[health:current]** will now show full value
    *   **[health:current:shortvalue]** will show the short value
    *   **[health:current-percent:shortvalue]** will show the shortvalue of the unit's current hp (% when not full hp)

### Version 12.17 [ January 4th 2021 ]
*   **Hotfixed:**
    *   Updated Ace3 so buttons on the side of Options will not be under the frame.

### Version 12.16 [ November 27th 2020 ]
*   **Happy Holidays:**
    *   The Minimap was fixed for Torghast.
    *   Bag Spacing setting min was lowered to -3.
    *   Added XP Quest Percent toggle in settings under General > BlizzUI Improvements.
    *   Added Volume Datatext (Thanks @Caedis).

### Version 12.15 [ November 24th 2020 ]
*   **Happy Holidays:**
    *   Hotfixed a NamePlate bug, that was causing plate to be broken.

### Version 12.14 [ November 23rd 2020 ]
*   **Happy Holidays:**
    *   Added Hide Keybind for each ActionBar, Pet, and Stance bar.
    *   Corrected skinned Chat Bubble Backdrop level.
    *   Fixed DT Currency Headers being goofy.
    *   Fade Duration option for Map was fixed.
    *   Fixed the Restore Bar button for ActionBars.
    *   Gave ActionBars Count, HotKey, and Macro text color overrides (Thanks @Caedis).
    *   The eyeball for group finder was still hiding. Should do a less hide now.
    *   Fixed the BG Double status bar not skinning right.
    *   Encounter Journal opens correctly with Smaller Map on.
    *   Skinned Equipment Buttons (Thanks @Aftermathhqt).
    *   Added Below and Above (Inside) options for chat editbox (Thanks @Cistara).
    *   Adjusted the skin code to prevent possible errors from other addons involving backdrop not existing.
    *   Updated all the Spell IDs we should need for Shadowlands dungeons and the first raid.
    *   World Quest Alert Frame will be skinned properly again.
    *   Fixed up the Bag Bar skin code.

### Version 12.13 [ November 17th 2020 ]
*   **Early Message:**
    *   Real Change Log coming soon.. Servers went up early. This is for 9.0.2, the main change in this version is the way scaling works in the UI, using any scaling size you prefer should work much, much better. However, this is new and it still needs a little adjusting but overall experience with scaling should be a ton better. Also, the Unified Fonts setting was further adjusted to be exactly as it was pre-font changes.
*   **Epic:**
    *   The new scaling adjustments are in place, which should allow you to select a custom scale that will keep borders intact better. This comes with new Small Medium and Large buttons to quickly adjust the scale _(Reload is required to properly change scale)_.
    *   Unified Font setting is now replicating old behaviour entirely.
    *   Druid multi-crafting CastBar is now fixed.
*   **Rare:**
    *   All Individual UnitFrames were given Detached Power Bar setting.
    *   Currency Icons have a little border of their own now.
    *   Pet bar saturation would sometimes become stuck, it is now unstuck.
    *   Group Finder eye icon was sometimes behind the button itself, we moved the eyeball up some.
    *   Fixed up the Hide Button Glow on ActionBars, it was a bit funky before when implemented.
    *   Time DataText can now be used in multiple areas without getting confused about what time it actually is.
    *   Bags Item Level should be more accurate again.
    *   Chat has a Server Time setting now which can be used instead of Local Time.
    *   Target Aura Bars attached to Player Aura Bars should be offset correctly.
    *   Addon Manager skin was adjusted to allow searching by other addons.
    *   Added Top and Bottom for Custom Text on ActionBars.
    *   Fixed another Quest Skin but which prevented the Parchment from being shown sometimes with Parchment Remover disabled.

### Version 12.12 [ November 10th 2020 ]
*   **Woot:**
    *   Level Locked Spells on Action Bars will display more clearly when doing older instances with friends on a higher level character.
    *   Masque on Action Bars should once again trim correctly (when Keep Aspect Ratio is checked). The logic was a little off before. Should be okay now.
    *   Quest Icons on NamePlates would sometimes show the incorrect Icon on some mobs, this logic has been adjusted.
    *   The Quest Seal Color Text with Parchment Remover enabled should be more visible.
    *   Added custom font count and hotkey text options for Action Bars (Thanks @Caedis).
    *   Added custom color options for Cast Bars on UnitFrames (Thanks @Caedis).
    *   Increased the Cast Bar text offset options on UnitFrames.
    *   A couple Top Aura font issues resolved.

### Version 12.11 [ November 7th 2020 ]
*   **Sweet:**
    *   The Keybinds for disabled ActionBars will work again! Sorry this was overlooked.
    *   Corrected Count Font Outline on Top Auras, along with the border color being incorrect. Also, Apply All Fonts will a work for these again.
    *   Implemented a work around for the Quest Objective Tracker Icon being unusable sometimes in combat.
    *   Added a toggle for Action Button Glow incase you don't want to see procs happening.
    *   Seals were showing when Parchment Remover was enabled, should be hidden again now.
    *   Fixed the Mend Pet spell ID for Aura indicator on Pet.
    *   Added Show Level option for EXP Databar.

### Version 12.10 [ November 6th 2020 ]
*   **Hotfix:**
    *   Petbar wasn't appearing with the Backdrop option selected.
*   **Also:**
    *   Top Aura options were reworked and settings for them were reset.
    *   Added Custom Font options for Unitframe Castbars (Thanks @Caedis).

### Version 12.09 [ November 6th 2020 ]
*   **Sweet:**
    *   Nameplates were reset in the last version for some people who had a newer profile, sorry about that. That problem is corrected now.
    *   **/kb** was upgraded to also work on the microbar and bag items. You can now quickly bind from the Spell (binds by the Spell name) and Macro (binds by the Macro name), on Action buttons (binds to slot), or directly on Bag items (binds by Item ID, not the slot).
*   **Nice:**
    *   Quest Most Expensive Item icon is behaving now.
    *   Shadowed Unitframes wasn't playing nicely, should be okay now.
    *   Masque should play nicely again. However noting that unchecking Keep Aspect Ratio will affect Masque icons, keep it on if you want it to use the one intended for the skin you have selected.
*   **Okay:**
    *   Exp Databar would error sometimes.
    *   Microbar Visibility option would error sometimes.
    *   Adjustments to the Quest Skin to try to keep the text and backgrounds showing properly (again).
    *   Fixed Classbar being tiny when using AutoHide option, also would error when leaving a vehicle.
    *   Actionbar Button Spacing option can once again be set to up to -3.
    *   Added Party Indicator option for Unitframes (Thanks @Caedis).
    *   Backdrop on the Stance bar wasn't using the correct multiplier when less than the amount of buttons available.
    *   Backdrop on the Microbar was a little off, that is sorted.
    *   Added Honor Level to Honor bar text outputs.
    *   Fixed the last tick on castbars.

### Version 12.08 [ November 2nd 2020 ]
*   **Wonderful:**
    *   Ungoofed the Nameplate Thin Border option (under _General > Media > Borders_).
    *   Removed ultra rare hidden error with how we spawn the Talking Head Frame.
    *   Tweaked "Unified Font Sizes" a little more to mimic the older style and disabled it by default.
    *   Supressed the error when you dont have Pawn updated yet, go update it if you use it! :)

### Version 12.07 [ November 1st 2020 ]
*   **Nice:**
    *   Added new "Unified Font Sizes" setting for "Replace Blizzard Fonts" (on by default). A decent amount of you didn't seem to like the change this hopefully will make you love us again. <3
    *   Actionbar Buttons can be sized unproportionally now by unchecking the Keep Size Ratio option. This will let you make an EPIC looking bar.
    *   HelpTips will now be hidden with Hide Tutorials, even while in combat (it was protected for safety but seems okay without it).
    *   Added an option for Ultrawide monitors to be 16:9 like eyefinity would do but on one monitor (Thanks @Gholie).
    *   Microbar can have a backdrop like ActionBars now.
    *   Fixed Item Upgradeable Icon while using Pawn.
    *   Nameplates now also have a Thin Border option.
    *   Added option to hide Health Bar on Tooltips.
*   **Datatext:**
    *   Added Datatext Option to hide friends playing CoD: Cold War.
    *   ElvUI Datatext now has a Custom Label option.
    *   Updated Movement Speed Datatext (Thanks @Caedis).
    *   Gave Mastery and Haste Datatext Decimal Length and Label / No Label option.
    *   Gave Combat Datatext a Full Time option.
    *   Fixed Datatext Gold Tooltip Style.
*   **Yay:**
    *   Fixed unequal Classbar combo points.
    *   Fixed Heirloom Cooldown not fitting the icon.
    *   Fixed Class bar sometimes not showing when it's supposed to.
    *   Party Pets now have an Aura Watch setting.
    *   Maybe fixed the "Most Expensive" icon from getting stuck.
    *   Hotkey text on Stance Bar will show again.
    *   Updated Trinket Spells for Trinket element.
    *   Fixed [altpowercolor] tag.
    *   Added [reactioncolor] back into tags.
    *   Heal Prediction was messing up for Druids but I fixed it.
    *   Updated Castbar Ticks amount, nice Penance btw.
    *   Remove that one Databar Quest EXP error.
    *   Chat Editbox will follow the chats text font and size.
    *   Center piece of Phase Indicator was getting stuck on.
    *   Another attempt to make sure the background/seal background art show correctly on Quest frame.
    *   Fixed Transmog squares turning white when changing spec when your profile changes.
    *   Stopped yoinking the progress bar off the collections appearance sets.
    *   Fixed Auras text from using wrong settings.

### Version 12.06 [ October 22nd 2020 ]
*   **Changes:**
    *   Adjusted fonts to scale a little better to follow what Blizzard intended.
    *   Databars: Fixed EXP mover not showing up, fixed visibility logic for all bars.
    *   Adjusted backdrop color of Account Wide achievements to a soft dark blue.
    *   Updated Phase Indicator to show Chromie Champions and Sharding players.
    *   Attempted to correct Power Prediction not anchoring correctly on Additional Power.
    *   Let tag [name:title] fall back to [name] when phased.

### Version 12.05 [ October 21st 2020 ]
*   **Changes:**
    *   Attempted to fix a taint with opening Spellbook in combat
    *   Shut off the NewPlayerExperience because it conflicts with ActionBars
    *   Small update for Missions and Follower skins (Classhall)
    *   ClassBar when login as kitty was tiny

### Version 12.04 [ October 19th 2020 ]
*   **Nice:**
    *   Boss button should appear as its supposed to now.
    *   Gender display option in tooltip had space on the wrong side.
    *   Adjusted the QuestXP code to not mess with Reward Item Tooltip.
    *   Fixed Additional Power Prediction not anchoring properly when set to vertical fill.
    *   Cleaned up the Equipment flyout skin some.
    *   Movie frame dialog backdrop was missing.

### Version 12.03 [ October 17th 2020 ]
*   **Fancy:**
    *   Fixed taint for Override Action Button Show
    *   Battleground Datatext was showing in Arena where it doesn't work anymore
    *   Objective Tracker button has a range overlay now and the (its grey) should be fixed
    *   Stance bar showing when entering a Battleground on priest and it switching you to healer from Shadow
    *   Databar Quest XP will show green for quests you are on and have completed, unless you have completed enabled
    *   Heal Pred was anchoring incorrectly when absorb style was set to None
    *   Fixed Alternative Power UnitIsUnit error

### Version 12.02 [ October 17th 2020 ]
*   **Fancy:**
    *   Clean Boss Button option wasn't saving properly.
    *   Added a Show Bubbles option for Databars.
    *   Fixed Difficulty Datatext error.
    *   Added two buttons to Quick Toggle Blizzard Skins, in the skin section of config.
    *   Allowed the MicroBar to be shown in Pet Battles by editing the visibility setting.

### Version 12.01 [ October 16th 2020 ]
*   **Nice:**
    *   Unitframe and Nameplate font issues (new method to get them showing properly)
    *   Actionbar Backdrops we reworked to fix them being a little funky, this includes Pet and Stance bar
    *   Boss and Zone Button being jumpy
*   **Good:**
    *   oUF updates
    *   ElvUI_QuestXP is now depreciated and forced off
    *   System DT options: No Label, Other Addons
*   **Fixed:**
    *   Voice Chat Error
    *   NewComer Chat Error
    *   Reagent Bank busted
    *   Status Report Errors
    *   Tooltips breaking other things
    *   Ace3 skin breaking other things
    *   Buffwatch errors (they are Aurawatch now)
    *   Databars not showing properly with combat setting
    *   Databars Show Border option not working properly
    *   Unitframe Additional power works again
    *   Unitframe Heal and Power Prediction
    *   Nameplate Power Bars were weird
    *   Nameplate failing to update
    *   Test Nameplate works a lot better now
    *   Time Datatext showing empty world PVP stuff
*   **Unbroken Skins:**
    *   Pet Battle Tooltip
    *   Scrap Machine
    *   Azerite Respec
    *   AutoComplete backdrop
    *   Bag Bar icons being wrong
    *   Bank Skin with Bag module off
    *   Equipment Flyout was busted

### Version 12.00 [ October 13th 2020 ]
*   **Cool:**
    *   We updated our backdrop code to behave nicely with the backdrop changes Blizzard implemented.
    *   We decided to completely rewrite the DataBars, this includes rewriting the old threat into this new module.
*   **Shiny:**
    *   Even though Shadowlands was delayed, this version will contain the Mythic+ and Raid filter list for the expansion.
    *   NamePlates had the wrong font when loading into the game, should be resolved now (for real finally).
    *   DataTexts have a better options now to allow customizing even further, we will add new options here over time.
    *   New section for Boss Button, Zone Ability, and Vehicle exit in the ActionBars options, which includes adding the ability to enable Inherit Global Fade on the Boss and Zone buttons.
    *   Thin Border Unitframe setting can be toggled separately, regardless of the Thin Border UI setting (both are found under _General > Media > Borders_ now).
    *   Quest reward will show percent of level, also the EXP Bar will show Quest XP if enabled.
    *   Fixed an issue that was causing Aura Statusbars color to become color stuck on auras with no duration.

### Version 11.52 [ September 4th 2020 ]
*   **Shiny:**
    *   Config button borders werent updating when changing border color.
    *   Objective Tracker optional setting to hide while in Mythic Keystone runs.
    *   New option to Allow Profile Sharing (off by default) in profile section.
    *   Updated Font Outline options and fixed it not working when adjusting.
    *   A wild error appeared with [name:health] tag which is resolved now.
    *   Friends Datatext will show characters on connected realms too.
    *   Player Nameplate should behave more often now.. I hope.
    *   SetNamePlateSelfSize error was removed from the code.
    *   Dropdown during Toggle Anchors was busted.
    *   Castbar text was getting cut off.

### Version 11.51 [ August 27th 2020 ]
*   **Changed:**
    *   Chat Panels were not sized correctly when Chat was disabled.
    *   Tooltip was erroring when Minimap was disabled.
    *   Minimap mover wasn't placed correctly.
    *   Shadows were scaling a little strange.

### Version 11.50 [ August 26th 2020 ]
*   **Hopes and Dreams:**
    *   Unitframes and Datatexts were sometimes failing to display their text, hopefully this is corrected now!
    *   Adjusted Nameplate and Aurabars to hopefully better detect mind control, duels, and which the frame type should be.
*   **Datatexts:**
    *   Data Broker tooltips were brokenish.
    *   Bags Datatext is a little less weird now.
    *   Added Text Justify setting, so text can hug left/right if you want.
    *   New datatext for Date, incase you aren't sure.
*   **Config:**
    *   Style Filters and Custom Texts will be automatically selected when created now.
    *   Options Logo was animating a little too much, someone gave it too much candy.
    *   Copy From should update the config to match now.
    *   Skin options are again sorted in order.
*   **UnitFrames:**
    *   Buff Indicator better supports Blizzard Cooldowns when our Cooldown module is disabled.
    *   Added some new Absorb settings (aka one is old but readded now).
    *   Party Pets and Party Targets can now display Aura Highlight.
    *   Added Interrupted Color for castbar on Unitframes.
*   **NamePlates:**
    *   Castbar Time should fit better.
    *   Fixed Player Nameplate being weird half of the time.
    *   Quest Icons also shows the quest ! texture now in some cases, and wont show 1 on the icon anymore.
    *   Quest Icons code was slightly updated to improve locales and pick the correct icon to use, so now it might work on other languages better.
    *   Corrected a Style Filter error, also let entering and leaving combat trigger filters correctly (regardless of unit threat).
*   **Chat:**
    *   Panel Movers will update with the Panel resizing again.
    *   Docked chats werent fading correctly.
    *   Added option to hide the Copy Button.
*   **ActionBars:**
    *   Equipped Item border wasn't updating correctly.
    *   Extra Action Button cooldown was not showing when it should.

### Version 11.49 [ August 6th 2020 ]
*   **Nameplates:**
    *   Added option to show Class Icon as Portrait.
    *   Style filter settings were getting stuck in last version.
    *   Corrected a few issues with Portrait backdrops being shown when they weren't supposed to.
*   **Options:**
    *   Masque options are now clickable again.

### Version 11.48 [ August 5th 2020 ]
*   **Hotfixes:**
    *   Attempted to fix strange nameplate behaviour.

### Version 11.47 [ August 4th 2020 ]
*   **UnitFrames:**
    *   Party Target settings were effecting Party settings, not the Party Target settings. (#1930)
    *   Fixed Smart Raid Filter toggle not applying anchors.
*   **ActionBars:**
    *   Added Flyout Button Size option (for pets and such).
    *   Hidden Pet bar blings were dragged to the depths, unless the bar shows, then they are back (temporarily).
*   **Datatexts:**
    *   Tooltips were hanging around during combat when they weren't supposed to.
    *   Tooltips hopping around like rabbits from one location to another on some datatexts, we fed them some carrot and now they behave.
    *   Mission tooltip display time strangely (aka wrong and broken).
*   **Minimap:**
    *   Datatext bar offset for non-thin border theme corrected. (#1925)
    *   Reset Zoom setting should apply correctly again.
*   **Chat:**
    *   Made sure Voice Icons appear when the Panel is hidden.
    *   Added a Panel Snapping option, which allows you to toggle the snapping into panels.
*   **Stuff:**
    *   Talent tooltips were showing ID, not once but twice, sometimes three or four or five.. maybe six times.
    *   Spellbook spells should work in combat without tainting now, this might fix other taint issues as well.
*   **Config:**
    *   Profile and Private confirmation popup was sometimes displaying incorrectly.
    *   Movers would sometimes get heavily attached to the mouse (and refusing to let go).
    *   Sometimes when adjusting the aura settings for a unit it would bug and not actually update the positioning (mainly targettarget).
*   **Locales:**
    *   Updated Translations for Portuguese (Thanks to @Aleczk) and French (Thanks to @Pristie).

### Version 11.46 [ July 15th 2020 ]
*   **Hotfixes:**
    *   Plugin Installer hiccup.

### Version 11.45 [ July 15th 2020 ]
*   **Unbroken Features:**
    *   Options: (**Ace3 Error**) This might finally stop exploding now with the help of Foxlit! **Thank you, Foxlit!** :D
    *   Options: Copying a **Private Profile** will now reload on accepting.
    *   Chat: **Fade Tabs No Backdrop** will now fade the correct chat tabs, they were hecka confused.
    *   Chat: **Tab Selection Color** can now follow the class color that is selected when switching to another character on the same profile.
    *   UnitFrames: **Power Detatched AutoHide** for units which should hide at zero power, will actually hide now at zero power.
    *   UnitFrames: Tank frames will now use the correct fonts on initial load in.
    *   CustomTexts: Correctly place the text when attached to **AdditionalPower**.
    *   Datatexts: **Custom Panel** settings will actually export now.
    *   Datatexts: One **Currency** error and one **Custom Currency** error have suddenly vanished from the UI.
    *   Tags: **[power:%s]** will work on NPCs again, **[mana:%s]** will return mana always again, **[additionalmana:%s]** was added for the additional mana display.
    *   UI: You can once again move Blizzard's Player Alt Power Bar with our movers.

### Version 11.44 [ July 9th 2020 ]
*   **Hotfixed:**
    *   Chat: Fixed incompatibility with Total RP 3.
    *   Nameplate: Added Castbar Interrupted color setting.
    *   Actionbars: Fixed paging.

### Version 11.43 [ July 9th 2020 ]
*   **Hotfixed:**
    *   Chat: Whisper Sound works again.
    *   Tooltip: Item Count works again.
    *   Aura Highlight: This actually works again too.
    *   Options: Readd the confirmation popup to Reset Profile button.
    *   Movers: Fixed an error while placing PlayerPowerBarAlt with Stick Frames disabled.
    *   ElvUI_DTBars2 is now depreciated and forced off.

### Version 11.42 [ July 8th 2020 ]
*   **DATATEXTS:**
    *   Creativity feature added by allowing you to create and customize **Datatext Panels**!
    *   Added **/hdt** command or pressing ALT while hovering the Datatext will spawn a menu to change the Datatext quickly (original work and code by Nihilist). Thank you for letting us have this! <3
    *   Added **Missions** and removed **Garrison**, **BfA Missions**, and **Orderhall**.
    *   Added **Primary Stat** and removed **Attack Power** and **Spell Power**.
    *   Added new texts **Reputation**, **Experience**, **Item Level**, **Mail**, and **Difficulty**.
    *   Added stat texts **Intellect**, **Agility**, **Stamina**, **Strength**.
    *   Added setting **Flash Threshold** to **Durability**.
    *   Multiple texts were reworked for this update.
*   **UNITFRAMES:**
    *   Smart Filter appears to have finally passed its exams, yay!
    *   Stopped allowing **Custom Backdrop** on **Additional Power** to change the bar color to white.
    *   Made sure Auras wont show on **Tank** or **Assist** frames when the option is disabled.
    *   Debuff Highlight (now **Aura Highlight**) in Glow mode was glowing around the edges of the screen instead of the frame.
    *   **Role Icons** will now appear in Battlegrounds, they were scared of battles; so we gave them invisible sunglasses.
    *   Deleted **Show Absorb Amount** option, as it would often be greater than the units health in some cases.
    *   You can now change the **Frame Level** and **Frame Strata** of Individual frames.
    *   Tags attached to the Power element (including Custom Texts) will be placed correctly with the AutoHide option.
    *   PVP Classification Indicator can now be displayed on Arena Frames.
    *   Castbars were trained to allow the casting backwards.
    *   Target and Focus frames now have a shiny combat icon.
    *   Aura borders color by type can be toggled off now.
    *   Castbar **Display Target** allowed on all frames.
    *   Focus Glow based on if a unit is Focused.
    *   Party Castbars can be positioned now.
*   **NAMEPLATES:**
    *   Added **Show Only Names** option which will put **Blizzard Nameplates** into **Name Only** mode.
    *   Optimized plate load in so the performance will be improved if plates spawn quickly.
    *   Added **Hide Icon** options for **Quest Icons**, also text position was greatly improved.
*   **CHAT:**
    *   Removed **Lock Position** option, the windows will now be snapped to the Panel if within proximity.
    *   Tabs can be customized with color and we added a feature to let you hug the text with arrows.
    *   Editbox now supports Blizzard's **IM Style** and displays the **Character Count** correctly.
    *   Editbox History Size can be adjusted or Reset via a button in the options.
    *   History Size can be adjusted and the history channels can be excluded by type.
    *   Role Icons will appear correctly after a reload.
    *   Alerts can now be set by Channel type.
    *   Max Lines can be adjusted.
*   **TAGS:**
    *   Swapped **[additionalpower:%s]** to **[mana:%s]** and readded **[manacolor]**.
    *   Swapped **[difficultycolor]** to use Blizzard's **Creature Difficulty Color** instead of our custom coloring.
    *   Added **[classpowercolor]** and updated **[classpower:%s]** so it supports (in this order): Special, Combo Points, or Alt Mana.
    *   Added **[name:last]**.
*   **UI:**
    *   Movers should be better at doing their job and also stop appearing on Castbars when the Castbar was disabled.
    *   Cutaway would locate its very own error on initial login or profile change sometimes, that error has been corrected.
    *   Swapped **ElvUI_NonTarget** StyleFilter to use **Alpha 0.5** by default instead of 0.3.
    *   Bags will auto open and close with the **Auction House** and **Scrapping Machine**.
    *   Profile Export is now cleaned of settings which are not considered active. This means if you use a Plugin but it is disabled, when you export your profile the settings from that plugin are **not** included in the export.
    *   Blacklisted the **Experience Eliminated** debuff.

### Version 11.41 [ May 1st 2020 ]
*   **Bug Fixes:**
    *   The font used in **/estatus** and **Addon Manager** on CN/TW/KR should fallback to a font that works instead of trying to use Expressway, which isn't supported.
    *   **Combat Log Skin** and **Combat Time DataText** were misbehaving.
    *   Worked out a couple more weird things with **Smart Raid Filter**.
    *   Cutaway works correctly on Vertical Orientation Health Unitframes. (#1776)
    *   Fixed issue which caused Transparency setting to mess up the health on Unitframes with Vertical and/or Reverse Fill enabled.
    *   Fixed Absorbs display on Unitframes with Reverse fill on (in Vertical or not) when Show Absorbs Amount was off.
    *   Fixed a bug in the new Addon Manager skin (AddOn index must be in the range of 1 to 4).
*   **Misc. Changes:**
    *   Lowered the min value on some Unitframes elements, mainly health. (#1798)
    *   Display Plugins in **/estatus**.

### Version 11.40 [ April 30th 2020 ]
*   **Changes:**
    *   Tiny Update.

### Version 11.39 [ April 30th 2020 ]
*   **New Additions:**
    *   Added a note above Raid / Raid40 / RaidPet which states you can't toggle them or change their number of groups when **Smart Raid Filter** is enabled (under UnitFrames > General).
*   **Bug Fixes:**
    *   Datatexts do their thing even better than before, for real this time, hopefully. **(X doubt)**
*   **Misc. Changes:**
    *   Upgraded **/estatus** with shiny new beautiful colors.
    *   Fresh coat of paint on the Addon Manager too.

### Version 11.38 [ April 28th 2020 ]
*   **New Additions:**
    *   **Smart Raid Visibility** has rejoined the UI **(it's actually reformed now)**.
    *   Added **[name:health]** tag which displays health lost using colors on the name text, neato.
    *   Added **[ElvUI-Users]** tag which displays other cool people than yourself.
    *   Some ultra rare super high tech Mechagon debuffs were added (jk, they are normal).
    *   Added **My Pet** and **Other Pets** to Aura Filtering system.
    *   Borrowed the **[status:text]** and **[status:icon]** tags from Classic.
    *   Show Assigned Icon option now exists for the bags.
    *   Add Echoes of Ny'alotha to Currency DataText.
    *   Tooltip NPC names now adapt to the custom faction colors in tooltip settings.
*   **Bug Fixes:**
    *   The options bottom buttons now use the language selected in the config, nice.
    *   Nazjatar Followers Missions Datatext was doing a goof, which has been ungoofed by a professional ungoofer.
    *   Health and Power prediction has learned new tricks **(which actually doesn't do anything new but we promise they are ten times cooler now)**.
    *   Some Datatexts refused to show information on login, now they are willing to share said info.
    *   Some kind of Alternative Power oops, something about UnitIsUnit; rare bug, big time squashed.
    *   The bottom of letters on the bottom line of the chat will now be visible to all earthlings.
    *   Chat editbox will stay open when you move if it has text in it again and character count will only show if there is text in the editbox.
    *   Add or Remove spell from a filter should now work how it was always meant to.
    *   Threat tags have now leveled up there tag game.
    *   Threat on Unitframes in Border mode would sometimes not update the borders correctly, they behave like good bois now.
    *   Cutaway colors react instantly now, ninja status achieved.
    *   Highlight texture for Items on the Character page are now the old style instead of the Blizzard style.
    *   Stance Bar will now get placed in the correct place, it was rolling a placement dice, we took it away.
    *   Deathknight Runes can use the custom backdrop color now, epic.
    *   Raid Debuffs has unlearned never-appear-unintentionally!
*   **Misc. Changes:**
    *   Style Filters now support changing the Nameplate Tags for Health, Power, Name, Title, and Level because of this Name Color action was removed, you can tag a color onto it and make it do other neat stuff, if you want.
    *   Style Filters threat triggering is now no longer wearing slow shoes.
    *   Someone decided to show Corrupted Icon on Equipment Manager Flyout buttons, cool.
    *   AuraBars using Debuffs type can once again, switch to Class Color, just like magic.
    *   Updated the Death Recap, Combat Log, and Community skins in 2020 style.
    *   Updated the Raid Utility, with nice clean shiny fresh new updates.
    *   Faction gold will hide if its zero on the gold datatext.
    *   Added Traditional Chinese number prefix. (Thanks @mcc)
    *   Added Fade Chat Toggles option which can prevent the toggle buttons from disappearing with the chat. (Thanks @Sirenfal)
    *   Raid-wide-sorting has now evolved, the new way will sort the **Number of Groups** and ignore the ending groups so you can hide benched players. (Thanks @BeeVa)
    *   More N'zoth eyes on the Inspect frame items.
    *   Drain Soul has 5 ticks (not 6 ticks btw).

### Version 11.372 [ March 20th 2020 ]
*   **Hotfixed:**
    *   Community Skin error caused by recent update from Blizzard.

### Version 11.371 [ February 11th 2020 ]
*   **Hotfixed:**
    *   Minor explosion on load with the release, damage has been absorbed by a fancy hotfix shielding mechanism.

### Version 11.37 [ February 11th 2020 ]
*   **New Additions:**
    *   Added option to display **ElvUI Version** of other **ElvUI users** into Tooltip.
*   **Bug Fixes:**
    *   The **Top Auras** were having some trouble deciding what border color to wear, it's now selected for them (once again).
    *   Unitframe **Portrait Style Class** wasn't playing nicely with the **Overlay** option but they are now friends.
    *   Nameplate **Follower XP** was showing on other players followers, it won't do that anymore.
    *   When selecting a **Custom Filter**, there was a **0.3333~%** chance to get an error. That **should** no longer be the case.
    *   It seems unitframes were confused as to whether or not the unit was **disconnected** and can now display the connection color correctly.
*   **Misc. Changes:**
    *   Added 8.3 Affixs into the **Raid Debuffs** filter.
    *   Debuff Highlighting **Blend Mode** MOD was removed, as it's use was very specific and misunderstood.

### Version 11.36 [ February 7th 2020 ]
*   **Bug Fixes:**
    *   Quite sure the **Quick Join Datatext** was being super noisy in the background, so we calmed it's rage with cuddles. This might have caused **Stuttering Issues** for people on high population realms. (#1702)
    *   Profile **Spec Switch** doesn't lawl around your anchors anymore, it should place them nice and neat where they belong.
    *   If you had **AuraBar Colors** that weren't being colorize correctly, recheck the filter and enable it. It was 100% nargles, I just know it.
*   **Misc. Changes:**
    *   Nameplate **Follower XP** has now been properly trained on how to collect IDs all by itself.
    *   Buff Indicator Style **Timer Only** will now use the selected color for the timer.
    *   If you were a bad boi and interrupt yourself with the **Interrupt Announce** on it will now no longer embarrass you.
    *   Spells inside of the **AuraBar Colors** filter which were using **Name** instead of **Spell ID** will be converted to **Spell ID**, if possible.

### Version 11.352 [ February 5th 2020 ]
*   **Hotfixed:**
    *   Boss and Arena frames were casting Stealth on some profiles.

### Version 11.351 [ February 5th 2020 ]
*   **Hotfixed:**
    *   We had to retrain **Reset Anchors** and **Nudge Reset** because they forgot how to do the thing.

### Version 11.35 [ February 5th 2020 ]
*   **Bug Fixes:**
    *   For some reason Style Filters had convinced Portraits into being too clingy on Nameplates.
    *   Reversed Font Explosion Feature on CN, TW, and KR clients _(Azil says he is a badboi and very sorry <3)_.
    *   Party Pets, Party/Assist/Tank Target frames now remember their size setting and don't do updates while they hide anymore.
    *   Convinced the Filters section to Reset Filters when you **SMASH BUTTON**, and you can once again delete old spells from lists.
*   **Misc. Changes:**
    *   General section of Units in Unitframe settings are less of a mess.
    *   Vehicle Exit Button anchor size is now hugging the button like a good boi.
    *   Anchors and Raid Control decided to start using the correct font after about a year or so.

### Version 11.341 [ February 4th 2020 ]
*   **Hotfixed:**
    *   Aura Bar Colors setting was getting spammed into the settings file.

### Version 11.34 [ February 4th 2020 ]
*   **New Additions:**
    *   The options window has been upgraded and sections have been reorganized a bit (Repooc does **NOT** like it tho).
    *   Debuffs inside of **The Sleeping City** [Ny'alotha] will now by shown by Raid Debuffs filter (Thanks Broccoliz).
    *   **Corrupted Mementos** and **Coalescing Visions** are now displayed by the Currency Datatext.
    *   Buff Indicator now has its options reworked.
*   **Bug Fixes:**
    *   Hopefully, Maybe, Perhaps, Possibly corrected the error which caused the Auras trying to attach to themselves on Unitframes (for real this time).
    *   Frame Glow is now cool with hugging the Alt Power Bar on Unitframes too.
    *   Fixed Vehicle Exit options, they were misbehaving unintentionally.
*   **Misc. Changes:**
    *   The **Smart Raid Visibility** option gquit the UI.
    *   Added more IDs to show **Voidtouched Egg** on nameplates (some were hiding but Mera found them).
    *   Debuff Highlight will now not show something when it's added but not enabled (changed so you can blacklist **Grasping Tendrils**).
    *   Intenté completar más del archivo de localización para español. _Si es malo por favor mensaje Simpy en Discord._ >x>

### Version 11.33 [ January 23rd 2020 ]
*   **New Additions:**
    *   Added Swap to Alt Power option to Raid and Raid40.
    *   Added Alternative Power bar option to Raid and Raid40.
    *   Added color option for Swapped Alt Power to Unitframes and Nameplates.
    *   Added an option to disable Buffs or Debuffs specifically for Top Auras.
    *   Added click-through option for Actionbars: Bar 1 through 10, Pet, and Stance bar.
*   **Bug Fixes:**
    *   Attempted to fix Quest Icons on Nameplates which caused one quest to be displayed twice.
    *   Fixed Raid40 Visibility Restore button not applying instantly.
    *   Fixed the background color for Alternative Power bar, sometimes it was not updating to the correct color the first time.
    *   Fixed an error when importing a profile, which complaining about priority not existing for auras.
    *   Fixed the text info on Import and Export of a profile, it would stack the text at the bottom incorrectly before at first open.
    *   Fixed resolution display on /estatus.
*   **Misc. Changes:**
    *   ElvUI_CustomTweaks is now depreciated and forced off.
    *   Let Swapped Alt Power work on all Alt Power types not just raid type ones.
    *   Lowered Minimap minimum size to 40.

### Version 11.32 [ January 21st 2020 ]
*   **New Additions:**
    *   Added Faction info to the Gold Datatext and fixed a possible error with new characters on it.
    *   Added support for Voidtouched Egg in Uldum onto the nameplates, similar to Nazjatar Follower XP.
    *   Added Corrupted Item Icon onto the Character Frame for items with Corruption stat.
    *   Added Color and Text Format option to the Party Alternative Power bar settings.
*   **Bug Fixes:**
    *   Attempted to fix Boss Frame (or other Unitframes) name not being updated correctly.
    *   Fixed error when using the "[health:deficit-percent:nostatus]" tag.
    *   Fixed Reagent Bank Icon borders.
*   **Misc. Changes:**
    *   Removed Nameplate Load Distance Options, until Blizzard decides if they will let us control it again in the future.
    *   Reverted portrait facing and used a correct API to handle the X and Y Offsets.
    *   Stopped letting AFK Mode activate when in a Pet Battle.
    *   Changed the default position for the Alternative Power Bar.
    *   Allow icon size six on the Buff Indicators.

### Version 11.312 [ January 18th 2020 ]
*   **New Additions:**
    *   Show Currency ID on Tooltip for Tracked Currencies on the Bag (if Tooltip settings allow Spell IDs to be shown).
*   **Hotfixed:**
    *   Hide Purchase Bags when all slots are bought.
    *   Revert Portrait Camera positioning.

### Version 11.311 [ January 17th 2020 ]
*   **New Additions:**
    *   Added Coalescing Visions & Corrupted Mementos to the currencies datatext.
    *   Added Class Icon style to portraits, also added Pause and Desaturation setting for 3d portraits.
*   **Bug Fixes:**
    *   Attempted to fix an issue which caused Chat Bubbles to error with Font not set.
    *   Stopped the Unitframes from updating when using Display Frames. This was very noticable with effective updates enabled.
    *   Fixed the Arena and Boss frames from being hidden when changing an option while using Display Frames.
    *   Fixed the title tag for FRIENDLY_NPC Nameplates. They are not in a guild >.>
*   **Misc. Changes:**
    *   Applied Actionbar transparency option on PetBar and StanceBar.
    *   Fixed Vehicle Exit button highlight and added Frame Level and Strata options (found under ActionBars > Vehicle Exit).
    *   Update instance ID from Deepwind Gorge. (Thanks AcidWeb)

### Version 11.301 [ January 15th 2020 ]
*   **New Additions:**
    *   Added an option to Swap to Alt Power on party frames, until we have a widget or something for corruption status of party members.
    *   Removed the Vehicle Exit Button from the Minimap. We added a mover and the new settings can be found in the Actionbar configuration.
*   **Bug Fixes:**
    *   Fixed an issue with Buff Indicators which caused an error because of the setting conversion code.
    *   Fixed an issue that caused some unskinned Blizzard frames to get the edges torn off.
    *   Attempted to fix the Portrait offsets and made the settings display an important note.
*   **Misc. Changes:**
    *   Added the Nzoth eye texture to the Alternative Power Bar, if its Sanity.
    *   When you hover the NZoth eye on Character page, it will now show a highlight around the items with corruption stat.
    *   Set a texture when a submenu is selected in the Auctionhouse skin.
    *   Fix backdrops on empty essences in the Character Frame.
    *   Display an icon on Bag icons for corrupted items.

### Version 11.291 for patch 8.3 [ January 14th 2020 ]
*   **Bug Fixes:**
    *   Fixed barInfo error.
    *   Fixed SetAuraUpdateMethod error.

### Version 11.28 for patch 8.3 [ January 14th 2020 ]
*   **New Additions:**
    *   Added an option to let Unitframe and/or Nameplate frames update their Health, Power, and/or Auras at consistent rate (between 0.1 and 0.5 of a second) rather than using Blizzard's event system for when to update. This is an opt-in method that is less recommended but might solve issues where the update isn't received correctly otherwise.
    *   Added an option to play a sound if you select a unit and/or if you receive a battle resurrect. Both are disabled by default.
    *   Quest Icons, Raid Marker, and Healer Icon on nameplates will now be shown in nameonly mode.
    *   Added Tank Icon, which is similar to Healer Icon in PVP.
*   **Bug Fixes:**
    *   Fixed Reverse fill on Power elements on Unitframes.
    *   Fixed Hovered Hyperlinks when scrolling in the Chat.
    *   Fixed Unitframes (other than Player) which had their Power style set to Offset from being unchangeable.
    *   Fixed Target Buff Default Filters.
    *   Fixed Cooldown Text Defaults.
    *   Fixed an issue where a profile error about 'global' or 'private' not existing would happen from the Skin module.
    *   Fixed the Classification indicator on nameplates.
    *   Fixed (hopefully) a Smart Aura Position setting issue which would cause the Buffs and Debuffs on Unitframes to cause a SetPoint error.
*   **Misc. Changes:**
    *   Added more position values for the Elite Icon on Nameplates.
    *   Added the ability to show Toy ID when Tooltips have the Spell ID setting enabled.
    *   Removed Cooldown Top Aura font override setting as it's not needed, the setting for Buff or Debuffs are in their Aura settings.
    *   Reworked the way we attempt to skin other addon’s options which use the Ace3 library.
    *   Removed some of the excessive options in Buff Indicator which were overrides which were left over from the old code.
    *   Simplified the OrderHall Talent Frame skin (which is also used by the new 8.3 talent frame).
    *   Optimized more of the Bag module code.

### Version 11.27 [ December 14th 2019 ]
*   **New Additions:**
    *   Using "/luaerror off" will restore Addons disabled from "/luaerror on" in testing now (during that session only).
*   **Bug Fixes:**
    *   Made sure the Alternative Power is only shown when it's supposed to be shown.
    *   Fixed a rare error which occurred once on some quest in Blasted Lands.
    *   Fixed the raid marker from not circling (they were stacked, oops).
    *   Fixed a Communities skin error about GetItemInfo.
    *   Fixed the level line on ToolTips in some languages.
    *   Added back Focus Raid Icon options.
*   **Misc. Changes:**
    *   Removed the UI Scale popup for real. Goodbye.
    *   Changed the Focus Aura Bars to off by default.
    *   Changed the Max Duration to 0 in the Aura Priority list.
    *   Changed the Aura Spacing options to use max 20.
    *   Addons which were integrated into the base addon are now disabled automatically on load (VisualAuraTimers, ExtraActionBars, CastBarOverlay, EverySecondCounts, and AuraBarsMovers).

### Version 11.26 [ December 5th 2019 ]
*   **New Additions:**
    *   Added spacing option for unitframe auras.
    *   Added back some options that was eaten by an angry goblin.
*   **Bug Fixes:**
    *   Fixed Actionbar spell highlight, if you mouseover your spells in the Spellbook.
    *   Fixed Darken Inactive on Stance Bar.
    *   Fixed BG Stats tooltip not showing the details.
    *   Fixed the Color Wheel from derping at solid black.
    *   Fixed a rare error from old profiles related to the Gold Datatext and "OldMoney".
    *   Fixed issue which prevented Datatext text being displayed on first game load in.
*   **Misc. Changes:**
    *   Smoothed the Top Aura Status Bars when they are active.
    *   Smoothed all animations created by the animation code.
    *   Recoded some of the Cooldown module code and made it support UnitFrame Buff Indicator better.
    *   Tweaked the way the UI Scale popup shows to prevent it from happening in more cases, when it should not be shown.
    *   Updated the Chat Spam Interval to resolve some issues with it.
    *   Updated Friends and Guild Datatext.

### Version 11.25 [ Novmember 10th 2019 ]
*   **New Additions:**
    *   Nameplate Quest Icons now have the ability to show for multiple quests and have a few new options.
    *   Added Detached Power Bar Auto Hide when empty option (needs better locales).
    *   Added TutorialFrame skin.
    *   Added Visual Aura Timer from Blazeflack. You find it under: ElvUI - Buffs&Debuffs - Statusbar.
    *   Added ExtraActionBars from Blazeflack. Which means, you have now 10 Actionbars.
    *   Added CastBar Overlay from Blazeflack.
    *   Added Aura Bar Movers from Darth Predator.
    *   Added an option to mark the most valuable quest reward with a gold coin.
    *   Added new Tag: [specialization], which shows YOUR current spec as text.
    *   Added new Tag: [faction:icon] shows a texture from your faction.
    *   Added an option for Nameplate Buffs/Debuffs to toggle auras from other players to desatured. Enabled by default.
*   **Bug Fixes:**
    *   Fixed Pet Battle Nameplates, they weren't properly updating Health Bars.
    *   Fixed an issue which would carry over Quest Icons on Nameplates to one without a quest.
    *   Fixed the Map Fading while moving option and added a fade duration setting.
    *   Fixed the issue which was caused by trying to use chat editbox history to queue a slash command to be sent that was secure (such as /target).
    *   Fixed the incompatibility check for other addons.
    *   Fixed issue which caused the Datatexts on the minimap to be shown when the minimap was actually disabled.
    *   Fixed issue which didn't update the enchant info when Character Info was enabled and you changed enchants while the character page was open, also Essences.
*   **Misc. Changes:**
    *   Thanks to Azilroka the Buff Indicator and Aura Bars are now recoded!
    *   Removed the Frequent Updates option, it is now on by default.
    *   Blacklisted Lethargy debuff (fight or flight).
    *   Essences from the Character and Inspect Info will now display the Essence quality color instead of type color.
    *   Updated option layout for Available Tags. Thanks to Luckyone for helping us with this.
    *   Skin the new RecruitAFriend Frame.
    *   Update options layout.
    *   For the german audience: Behebt einige Fehler im Zeit-Infotext, dass die Instanz Symbole nicht richtig angezeigt wurden.
    *   For Plugin Authors: We added a seperator in our Options: <<< Plugins >>> Which means, you should add your options below it. Just change your main option number to: 6

### Version 11.24 [ October 8th 2019 ]
*   **New Additions:**
    *   Available Tags is now available in the Options.
    *   Added an option to Clean Boss Button in skin settings, which removes the texture.
    *   Added an option which you allow to scale the DurabilityFrame.
    *   Added an option to let Cutaway textures follow the statusbar texture.
*   **Bug Fixes:**
    *   Fixed MiniMap icons from being in the center on load! (#1528)
    *   Fixed AuraBar to support the duration slider when the filter list is empty.
    *   Fixed Cutaway feature error on nameplates. (#1491)
    *   Fixed an error from BackpackTokenFrameTokenIcon when our Bags are disabled.
    *   Fixed not showing Quest Icons on NamePlates. For your Info: It will only work, if the Tooltip have a progress line.
    *   Fixed ClassBar frame strata from being applied even if detach from frame is disabled. (#1414)
    *   Fixed issue which caused the gem backdrops on the iLvl stay shown when disabled.
    *   Raised the detached ClassBar to be over health by default.
    *   Corrected visibility for Stance bar.
    *   Fixed bag count color options.
    *   Fixed some skin errors.
*   **Misc. Changes:**
    *   Added back the tag: 'name:abbrev'.
    *   Removed our clipping for UI Scale.
    *   Updated the Chat module & Guild and Friends DataText to use the new API Blizzard switched too, with a few minor bug fixes.

### Version 11.23 [ September 24th 2019 ]
*   **New Additions:**
    *   Added an option to enable a more visible Auto Attack animation on the ActionBars. Disabled by default.
    *   Added options for ActionBars Button / Bag Slot transparency.
    *   Added an overlay alpha option for UnitFrames portraits.
*   **Bug Fixes:**
    *   Fixed a bug where nameplate threat scale wasn't being reset on new units that no threat existed on.
    *   Fixed a Style Filter error: Attempt to compare nil with number.
    *   Fixed an error in Petition Skin.
    *   Fixed black Quest Text if Parchment Remover is enabled. (#1444)
    *   Fixed Penance spellID for castbar ticks.
*   **Misc. Changes:**
    *   Updated Friends DataText to see the difference between retail and classic.
    *   Various Skin updates related for 8.2.5.
    *   Changed the Battle.net status frame. Just click on your Battle.tag to add/edit the status message.
    *   Added "Eye of Leotheras" (PvP Talent) to the PlayerBuffs Filter.

### Version 11.22 [ September 6th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed Style Filter error: attempt to compare nil with number (line 322).
    *   Fixed bug where nameplate threat scale wasn't being reset on new units that no threat existed on.
    *   Fixed (hopefully, take two) the issue which caused the nameplate tags to sometimes be incorrect.
    *   Fixed a skin error on the Petition Frame which hides a button.
    *   Fixed black Objective Text, if Parchment Remover is enabled. (#1444)
    *   Fixed Friends Datatext to show those playing Classic WoW.
*   **Misc. Changes:**
    *   None

### Version 11.21 [ August 17th 2019 ]
*   **New Additions:**
    *   Style Filters: Added a new trigger "Location" that triggers on which Map, Instance, Zone (like "Boralus Harbor") or Subzone (like "Sanctum of the Sages") you are currently in. If enabled the filter will only trigger when you are inside one of the specified maps or instances.
    *   Style Filters: Ability to trigger an aura with at least X number of stacks.
    *   Added an option to color the border of equipped items on ActionBars. (!170)
*   **Bug Fixes:**
    *   Fixed (hopefully) the issue which caused the unitframe and nameplate tags to sometimes be incorrect.
    *   Fixed issue which caused the rune backdrop on nameplates to not hide when in nameonly mode.
    *   Fixed issue which caused the Raid Debuff Indicator icon not being cropped properly.
    *   Fixed issue which caused the options to open with the incorrect size.
    *   Fixed issue on paladins that faded the unitframe by range because the judgement spell.
    *   Fixed the issue that sometimes caused unitframe absorb bars to appear for a second during initial login along the screen (they are now clipped like Cutaway).
    *   Fixed a bug which broke exporting profiles in plugin format.
    *   Fixed a bug in the Plugin library which prevented some plugins from versions being checked correctly.
*   **Misc. Changes:**
    *   Tweaked and updated some of the Cutaway lib again (it now uses clipped textures, so it wont overflow).
    *   Fixed General Dock Manager skin not applying correctly.
    *   Fixed a couple skin issues which would show Blizzard borders on some frames.
    *   Moved the Class Color Override setting for unitframes to the health tab.
    *   Changed a bit the style of the Communities Frame Buttons.
    *   Added EP Boss one debuffs to Raid Debuffs.
    *   Updated our LibAnim by Hydra. <3

### Version 11.20 [ July 29th 2019 ]
*   **New Additions:**
    *   None.
*   **Bug Fixes:**
    *   Tooltip: Fixed an issue which would show the wrong faction for player when battling as a mercenary.
    *   Bag Bar: Fixed Right Click on a bag erroring out when Bags module was disabled.
    *   Bag Bar: Fixed scaling and backdrop weirdness.
    *   Nameplate: Fixed ClassPower SetPoint error.
*   **Misc. Changes:**
    *   Added an API file to Core folder and moved a decent amount of code from the Core file into here.
    *   Updated various parts of Bag, Bag Sort, and Bag Bar code.
    *   Blizzard Bags Skin: Show and skinned the bag icons.
    *   Blizzard Bags Skin: Skinned the Auto Sort button.
    *   Bag Bar: Lowered the min button spacing to -1.
    *   Make sure we only attempt to skin addons with RegisterSkin, which are finished loading.
    *   Rewrote the Cutaway bars to provide a cleaner implementation that works better with various nameplate and unitframe settings.
    *   Tweaked a bit our Spec/Loot DataText.

### Version 11.19 [ July 22nd 2019 ]
*   **New Additions:**
    *   Added Player Can Attack and Player Can Not Attack unit conditions to Nameplate Style Filters.
    *   Added Cutaway Health and Power (when appropriate) to all of the unitframes. It is disabled by default.
*   **Bug Fixes:**
    *   Fixed Essences on Hearth of Azeroth showing incorrectly on the character page (similar to gems).
    *   Fixed Item Level showing incorrectly on the character page when in a gear scaled instance.
    *   Fixed issue which caused the 'Smaller World Map' to not be displayed correctly on initial login.
    *   Fixed Minimap Ping & Blizzard Tracking Menu to show in combat (right and middle is still ignored in combat).
    *   Fixed the displaying of incorrect auras on Nameplates when StyleFilter "Name Only" ended (returning to normal nameplate).
    *   Fixed Battleground map position saving. (#831)
*   **Misc. Changes:**
    *   Module initialization and skin registration is now handled by xpcall providing better debug stacks for us to investigate and fix problems. As such, directly using :Initialize to initialize modules is no longer deprecated, and S:RegisterSkin has returned as the preferred method for registering a skin.

### Version 11.18 [ July 9th 2019 ]
*   **New Additions:**
    *   Added debuffs in Operation: Mechagon.
*   **Bug Fixes:**
    *   Fixed Minimap Coords when Map is zoomed. (Thanks AcidWeb)
*   **Misc. Changes:**
    *   Added Name Only and Show Title options to the Player Nameplate that matches the options for other unit types.
    *   Added Title element to the Player Nameplate.
    *   Don't allow certain DataTexts not be toggled in combat because of Blizzard restriction.
    *   Actually, we might as well just remove ElvUIGVC completely.

### Version 11.17 [ July 8th 2019 ]
*   **Misc Changes:**
    *   Disabled the version reply over the ElvUIGVC channel at Blizzards request.

### Version 11.16 [ July 4th 2019 ]
*   **Fixed Issue:**
    *   Moving the General chat tab should no longer cause any errors and the General tab should snap back to position.

### Version 11.15 [ July 3rd 2019 ]
*   **New Additions:**
    *   Added new consumable buffs.
    *   Added debuffs in Eternal Palace.
    *   Added a new element to Friendly NPC nameplates to display an XP Bar for the Nazjatar Bodyguards.
    *   New Nameplate Style Filter Unit Conditions:
        *   "Not Pet": Activated when the unit is not the player's pet.
        *   "Player Controlled" / "Not Player Controlled": Activated when a unit is controlled by the active player or not.
        *   "Owned by Player" / "Not Owned By Player": Activated when a unit is owned by the active player or not.
        *   "Is PvP" / "Is Not PvP": Activated when a unit is flagged for pvp or not.
*   **Bug Fixes:**
    *   Fixed Minimap colored green when ElvUI Minimap is disabled.
    *   Skinned a missing button on the new PVPMatch skin.
*   **Misc. Changes:**
    *   Added Nazjatar Follower XP to the BfA Missions Datatext when in Nazjatar.
    *   The "Is Pet" and the new "Is Not Pet" Nameplate Style Filter now only activate with regard to the active player's pet unit. Use the new "Player Controlled" / "Not Player Controlled" conditions to match the old behavior.
*   **Known Issues:**
    *   Adjusting the classbar position on nameplates while targeting something throws an error related to the new nameplate restriction (but works after retargeting).
    *   Moving the General chat tab causes an error, please avoid trying to move it while we continue to investigate a fix, hopefully coming in 11.16.

### Version 11.14 [ June 26th 2019 ]
*   **New Additions:**
    *   None.
*   **Bug Fixes:**
    *   Attempted fix for two Toolkit errors (cause by nameplate and bankframe code) and AceConfigDialog restricted regions error.
*   **Misc. Changes:**
    *   Added Prismatic Manapearls to our currencies DataText. (#1372)
    *   Changed the Font Shadow styling around the UI.

### Version 11.13 [ June 25th 2019 ]
*   **New Additions:**
    *   Added option to change the vertical/horizontal overlap of the Nameplates.
    *   Added option to change the Nameplate position: 'Nameplate at Base'.
    *   [Style Filter] Added Triggers- Unit Is Tap Denied, Unit is Not Tap Denied. (!169)
    *   Added new skin for AzeriteEssenceUI. Probably some "new" Skins are missing.
*   **Bug Fixes:**
    *   Fixed nameplate NPC visibility option always on after reload or login.
    *   Fixed an issue with DK runes after vehicle exit. (#1280)
*   **Misc. Changes:**
    *   Added skin support for Objective Tracker timer bars.
    *   Skinned a missing Scrollbar for the GMOTD on the CommunitiesFrame.
    *   Prevented right-aligned Ace3 dropdowns (and SharedMedia dropdowns) cutting off when the text is wider than the box. (!171)
    *   Take account to the new Blizzard-Nameplate system.
    *   Updated existing skins with 8.2 changes.

### Version 11.12 [ May 31st 2019 ]
*   **Important Changes:**
    *   ElvUI_Config has been renamed to ElvUI_OptionsUI.
*   **New Additions:**
    *   Added options to invert the CastBar, AuraBars, and Power colors on UnitFrames status bars when in transparent mode; as well as added custom backdrop options for these status bars.
    *   Added custom backdrop for ClassBars on UnitFrames.
    *   Added nameplate friendly NPC option "always show" this is used to toggle npc nameplates using Blizzards setting; so that they can go into Blizzard name-only mode.
    *   Added new Tags, which allows transliteration. E.g. 'name:medium:translit'. For more tags, visit our Custom Tag Guide on our forum.
    *   Added Glimmer of Light for Paladins to the BuffIndicator.
    *   Added Gale Slash to RaidDebuffs.
*   **Bug Fixes:**
    *   Fixed Style Filter Class Trigger. (#1310)
    *   Fixed error: attempt to index field 'CompactUnitFrameProfilesNewProfileDialog'. (#1314)
    *   Fixed double player nameplate when changing specific settings in the config. (#1316)
    *   Fixed player nameplate not fading in when hovered.
    *   Fixed the portrait and health backdrop bleeding on UnitFrames health when they fade on range, specifically for BuG.
    *   Fixed error: StyleFilter attempt to index locale 'auras' (a nil value).
    *   Fixed error: StyleFilter attempt to index field 'cooldowns' (a nil value).
    *   Fixed error: Nameplates attempt to access forbidden object from code tainted by an AddOn.
    *   Fixed bind mode for extra action button.
    *   Fixed skin for invite role check boxes.
    *   Fixed Nameplates in stacking mode on initial login.
*   **Misc. Changes:**
    *   Added an option to allow the portrait on UnitFrames to truly overlay the health, including the backdrop.
    *   Reworked some of the general Nameplate config settings so it's hopefully more clear and easy to use.
    *   Removed the Nameplate Name Visibility settings because this just caused some confusion.
    *   Disabled Boss Style Filter again by default. (Sorry for this everyone <3)
    *   Tweaked the default ElvUI_NonTarget StyleFilter, so that it will not fade out the player plate when targeting something.
    *   Various minor performance improvements.
    *   Cutaway health on Nameplates is back! :D

### Version 11.11 [ May 14th 2019 ]
*   **New Additions:**
    *   Add debuffs for Crucible of Storms.
    *   Added the ability to swap language in the configuration window to the language of your choice.
    *   Added "Tank, Damage, Healer" sort option to party and raid frames. (Thanks @wing5wong)
    *   Added Debuff Highlight mode options. (#726 - Thanks @wing5wong)
    *   Added skin for RaidProfiles New Profile Popup.
    *   [Style Filter] Added Triggers- Raid Target Marker, Not Name, Is Resting, Is Pet, and Unit/Player In/Out of Vehicle. (#469 #1253 #1278 and #1285 - Thanks @wing5wong)
    *   [Style Filter] Added Triggers- Threat conditions, New Casting (or not Casting; or Casting:NotSpell) triggers, Key Modifiers, and Target: Require Target (used in ElvUI_NonTarget).
    *   [Style Filter] Added Default Filters- ElvUI_NonTarget, ElvUI_Target, ElvUI_Boss, and ElvUI_Explosives. (Note: NonTarget is used to replace the NonTarget Alpha option and Target is used to replace the Target Scale option. The other two have had their names updated, so if you changed settings of them (Boss or Explosives), you can go ahead and delete them yourself now).
    *   Added option to desaturate grey items in bags. (#1305)
    *   Added World Latency to our System Datatext.
*   **Bug Fixes:**
    *   Fixed Nameplate Stagger texture.
    *   Fixed the Charge Cooldown Text not correctly setting Blizzard Cooldown Text.
    *   Fixed Selection Player Color sometimes being incorrect.
    *   Fixed Nameplate Alternative Power Swap.
    *   Fixed Fader from properly fading the Pet Frame out when combat ends.
    *   Fixed "button.db" error in Nameplate Aura code.
    *   Fixed a dropdown text position if the Communities Frame is minimized.
    *   Fixed Nameplate Class Bar error "ClassPower.lua line 133: attempt to index field '?' (a userdata value)".
    *   Fixed Enchant Text on Item Level and Minimap Location Text not clipping properly on non english clients. (Thanks @Bunny67)
    *   Fixed Name Fonts getting replaced even though Replace Blizzard Fonts is checked off. (#1269)
    *   Fixed "Attempt to index local 'threat' (a nil value)". (#1277)
    *   Fixed error when you disable a Custom Text.
    *   Fixed Nameplate Power Use Atlas Textures option.
    *   Fixed Twitter icon not appearing for items in chat. (#1281)
    *   Fixed an issue with Nameplate health coloring in some cases.
    *   Fixed Stagger visibility toggling. (Thanks oUF <3)
    *   Fixed an issue on the Gossip Skin with our Close Button.
    *   Fixed some Nameplate CVar issues.
    *   [Lag Fix] Tweak our oUF_Fader slightly and recoded the UIFrameFade to solve various CPU lags with UpdateRange.
    *   [Lag Fix] Removed a spammy event (UNIT_AURA) from the PetBar as this was causing it to execute far more than needed.
    *   [Lag Fix] Reworked how we send calls to the UpdateAuraCooldownPosition functions and on NamePlate Auras to save on CPU time.
    *   [Lag Fix] Stopped code execution of some functions when our interrupt announce or nameplate auras have been disabled.
    *   [Lag Fix] We believe we have finally resolved the preformance degrade/reaping issue, which was caused from the texts on UnitFrame and NamePlates causing a code stack which eventually would drain FPS.
*   **Misc. Changes:**
    *   Unitframe Status Bars will now sync their textures onto the background space when not using transparent.
    *   Nameplate Class Bar will also sync it's texture to the background.
    *   Attempted to fix PossessBarFrame, MainMenuBar, etc.. taint errors.
    *   Cleaned up some of the code which handles Player Role in the UI, this fixed the Timewalking Threat being backwards.
    *   Tweaked the Tooltips in the Config so it will display the hard limits (min, max, decimal step) and only display a tooltip when it has other information than just name.
    *   Limited the Nameplate Low Health Threshold to '80%'.
    *   Fixed some Ace3 skin weirdness.
    *   Cleaned up some of the Animation code. (Thanks @Grey)
    *   Reworked how ElvUI unsnaps textures, textures will be unsnapped globally now.
    *   Nameplate width is now bound to it's clickable width.
    *   The Bag Bar and Vendor Greys tabs are now again available if the All In One Bag is disabled.
    *   [Style Filter] Fixed Static Player Nameplate to no longer taint from filters.
    *   [Style Filter] Cleaned a decent amount of the trigger condition check code with the help of @wing5wong.
    *   Add shadow instead flash texture for StaticPopup buttons (Thanks @Bunny67)
    *   Fixed an issue and garbage leak with the plugin version checker.
    *   Fixed DataText header text using the Tooltip Header size when it was not supposed too.

### Version 11.10 [ April 9th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed Keybind Mode (/kb) to once again work on Stance and Pet buttons.
    *   Recoded some of the charge cooldown stuff (again!) This should fix Blade Flurry.
*   **Misc. Changes:**
    *   Update GMChat skin.
    *   Disabled Actionbar Charge Cooldown Text by default.

### Version 11.09 [ April 8th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Unsnapped the Totem Bar icon textures.
    *   Fixed Actionbar Masque enabled error "attempt to index field 'pushed' (a nil value)".
    *   Fixed charge cooldown setting not applying correctly. (#1256)
*   **Misc. Changes:**
    *   None

### Version 11.08 [ April 8th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   [Actionbar] Reworked the Show Charge Cooldown a bit so that it won't stack two texts on certain spells.
    *   [Actionbar] Refixed the Desaturation option so that it will recolor as soon as the cooldown finishes.
    *   [Actionbar] Fixed the pushed texture getting stuck on some buttons.
    *   [Nameplate] Name Only ending was preventing the Target Class Power from displaying correctly.
    *   [Nameplate] Option for Target xOffset for Stagger and made sure Stagger bar disables correctly when it should.
    *   [Nameplate] Corrected the Swap to Alt Power setting.
    *   [Nameplate] Made sure Target Class Power gets updated correctly.
*   **Misc. Changes:**
    *   None

### Version 11.07 [ April 7th 2019 ]
*   **New Additions:**
    *   [Nameplate] Added ElvUIPlayerNamePlateAnchor for WeakAuras and other AddOns.
    *   [Nameplate] Added an option to toggle the Nameplates from fading in when shown.
    *   [Nameplate] Added Aura stack position option. (#1140)
    *   [Nameplate / Unitframes] Added NamePlate and UnitFrame Color Selection colors from oUF. (Thanks oUF/LS-)!
    *   [Nameplate / Unitframes] Added a new smoothing method to Unitframes and Nameplates. (Thanks LS-)!
    *   [Nameplate: Style Filter] Add a new Filter: "Explosives" for Explosive Orbs in Mythic plus.
    *   [Nameplate: Style Filter] Added trigger Creature Type.
    *   [Nameplate: Style Filter] Added trigger if the unit is Focused (or not).
    *   [Unitframe] Added Duration option for cooldown text and reworked the cooldown code.
    *   [Actionbar] Added show cooldown text on charges option. (#716)
    *   [Chat] Added options to Desaturate, Pin to Tab Panel, or Hide Voice Buttons.
    *   Added an option to ignore the UI Scale popup when resizing the game window (General -> Ignore UI Scale Popup).
*   **Bug Fixes:**
    *   [Nameplate] Fixed an issue which caused the Targeted and Player Classbar options to not take effect correctly.
    *   [Nameplate: Style Filter] Made Name Color and Alpha action work again.
    *   [Nameplate: Style Filter] Fixed Health Color not working correctly in combat.
    *   [Nameplate: Style Filter] Fixed PVP Talent triggers.
    *   [Nameplate: Style Filter] Fixed Castbar Interruptible triggers.
    *   [Nameplate: Style Filter] Optimized the Name/NPC ID trigger, reaction, classification triggers.
    *   [Nameplate] Fixed Target Indicator showing permanently when Low Health Threshold was set to zero. (!115 - Thanks @wing5wong)
    *   [Nameplate] Fixed a gap at the end of Classbar on Nameplates.
    *   [Nameplate] Fixed Power Hide when Empty.
    *   [Nameplate] Fixed a bug where the Highlight was under the health.
    *   [Nameplate] Fixing Off Tank Color on Nameplates and added transitioning colors.
    *   [Nameplate] Made sure the Classbar appears on the Targeted plate correctly.
    *   [Nameplate] Fixed issue which prevented the Quest Icon from showing in some cases.
    *   [Nameplate] Fixed rune sort order for Deathknights and Classbar color for Monks.
    *   [Nameplate] Fixed Quest Icon on for CN region, some others still need locale update.. :(
    *   [Actionbar] Fixed main bar (bar one) paging issue.
    *   [Actionbar] Fixed Stance Bar Keybinding Text not appearing correctly. (#541)
    *   [Unitframe] Fixed health not updating correctly (again).
    *   [Unitframe] Fixed Castbar hold time not working correctly.
    *   [Chat / Datatext] Finally fixed the 'lhs' error with Quick Join.
    *   [Chat] Fixed an issue which was caused from our Chat file skinning the Combat Log bar when other addons hid it.
    *   [Skin] Fixed an issue which caused the Ace3 skin to add an X on buttons from other addons using our skin. (#1217)
    *   [Datatext] Made sure the LDB Datatext value color updates along with the General Media Value color correctly.
    *   Fixed an issue which prevented border and backdrop color from being updated correctly in some cases.
    *   Fixed spam errors when trying to change Talents when you have non selected yet.
    *   Fixed an issue whiched caused incompatiblity with our config and ColorPickerPlus.
    *   Fixed an error in init.lua: attempt to index local 'ACD'.
    *   Fixed an issue with the Quest Skin which caused the Quest Icon beside the text to sometimes not be shown.
    *   Fixed the DropDown Box text on the Communities Stream Dropdown.
    *   Fixed a tiny visual glitch with the DropDown in the Communities frame.
    *   Fixed an issue which would cause an error if you had the Login messaged enable while the Chat module was disabled.
    *   Fixed an issue which kept healers stored when out of a Battleground. (#1219)
    *   Fixed an issue which prevented Aurabars from correctly handling the Dispellable filters.
    *   Fixed Bag and Bank search from not being cleared consistently. (#1108)
    *   Fixed an issue with the cooldown module which wouldn't correctly set cooldowns when they were started cooldown before you logged into the game.
*   **Misc. Changes:**
    *   [Nameplate: Style Filter] Enabled Hide Frame action.
    *   [Nameplate + Style Filter] Adding Name Only (with Show Title).
    *   [Nameplate] Keep Player nameplate from fading out.
    *   [Nameplate] Reallowed Target and Threat Scale in options.
    *   [Nameplate] Removed Detection as this was used in Legion but is no longer used as much and this would increase preformance further.
    *   [Nameplate] Readded the Visbility settings on Static Player.
    *   [Nameplate] Reworked the cooldown text, so that it matches Unitframes.
    *   [Nameplate] Reworked the Target Alpha so that it shows only while in combat.
    *   [Nameplate] Updated oUF to increase preformance of the new Nameplates further.
    *   [Nameplate] Added backdrop coloring to the classbars.
    *   [Nameplate] Health Prediction defaulted to off except for Player.
    *   [Nameplate] Added xOffsets on Buffs, Debuffs, Castbar, Class Power, and Power bars.
    *   [Unitframe] Cleaned some of the Castbar code, as we believe this is part of the reason for the Unitframes to cause additional lags.
    *   [Unitframe] Replaced the Combat Fade code on the Player frame, with the same code we now use to fade the Player nameplate. (oUF_Fader)
    *   [Unitframe] Replaced the Range check option with the Unitframe Fader settings. (oUF_Fader)
    *   [Actionbar] Stopped allowing Keybinder in combat.
    *   [Bag] Recoded the animation for the New Item Glow so they all glow together instead of seperately, also gave it a fancy new glow texture.
    *   [Bag] Added the Deposit Reagents button to the Bank Tab too.
    *   [Config] Made the Enable Checkboxes in the config colorful, so that they're easier to spot, plus it looks really cool, imo.
    *   [Config] Oganized a bit with help from (@wing5wong).
    *   Updated Module Copy to handle some new cases.
    *   Updated Quest Greeting Frame skin.
    *   Optimized the Color Picker code for better preformance, also it will accept three digit hex values in the hex box but you must you press enter.
    *   Skinned the New Toy Alert.
    *   Skinned the Communities Notification Buttons.
    *   Removed the 'Forcing MaxGroups to' message.
    *   Added smoothing option to the Alternative Power bar.
    *   Blizzard corrected the issue with CVars not saving correctly.
    *   Adjusted all the Power and Classbar backdrop colors to be a little more vivid.
    *   Added dispellable to boss buff filters by default. (#1215)
    *   Added Vehicle support to our new oUF_Fader lib. (#148)
    *   Scaled the Skip frame on the cinematic screen. (#1176)

### Version 11.06 [ March 14th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Actually let the Target Class Bar on Nameplates use Class Color for classes other than Death Knight.
    *   Fixed an issue which made backdrops always appear.
    *   Fixed another case when C-Stack errors could occur from the Toolkit.
    *   Fixed an issue which caused clicking problems in the middle of the screen.
    *   Fixed the non-Target Nameplate transparency option. (Thanks AcidWeb for helping!)
    *   Fixed LFG Ready Popup skin from showing a Blizzard backdrop.
*   **Misc. Changes:**
    *   Allowed the Config to once again leave the screen.

### Version 11.05 [ March 14th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed LFG skin error.
    *   Fixed the C-Stack error (for real).
    *   Fixed issue which caused the chat panel backdrops color to change when updating the normal backdrop color setting.
*   **Misc. Changes:**
    *   None

### Version 11.04 [ March 14th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Attempted to fix a C-Stack error from "Core/Toolkit".
    *   Fixed an issue which caused a hidden frame in the middle of the screen to hijack clicks.
*   **Misc. Changes:**
    *   None

### Version 11.03 [ March 14th 2019 ]
*   **New Additions:**
    *   Added Target Class Bar on Nameplates.
    *   Added Class Color option for Target Class Bar, Player Class Bar, and Nameplate Power Bars.
*   **Bug Fixes:**
    *   Fixed the textures on the Stance bar.
    *   Fixed Masque support for Pet bar and Stance bar.
    *   Fixed the Class Media Value Color from not using the class color on different classes as it should!
    *   Fixed Style Filter for Health Color changing to black when the filter ends.
    *   Fixed issue which caused the Script Profile Popup to be shown twice.
    *   Fixed TargetIndicator glow change the color correctly after switching targets.
    *   Fixed issue which caused the Action bar buttons to not set the "checked" state.
    *   Fixed an issue which caused the Blizzard Castbar to sometimes not be shown when the UnitFrame module was disabled and disable Blizzard Player Frame was unchecked.
    *   Fixed an issue which caused the UI to hide (like Alt-Z) when opening the Bank frame using the non-thin border theme.
*   **Misc. Changes:**
    *   Prevented the Update Popup from being shown while in combat.
    *   Added "Dispellable" to Nameplate Friendly NPC Buffs and Nameplate Enemy Player Debuffs list by default.

### Version 11.02 [ March 12th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue where opening the bank with shift would say you needed to purchase the reagent slots.
    *   Fixed issue on pet bar which may have caused the "auto cast" markers to show in the wrong pet spells.
    *   Fixed error in the config caused from the Nameplate Threat.
    *   Fixed visual issue where the voice channel icon would show on the chat panel even though it was hidden causing it to appear out of place.
    *   Fixed Blizzard Castbar being disabled when Unitframe module was disabled.
    *   Fixed Pet bar issue which sometimes could error about "pushed".
    *   Altered the way the CD module was handling the text on Nameplates, so that the text will always be shown, regardless of it's icon size. (#1094)
*   **Misc. Changes:**
    *   Allowed Test Nameplate to be movable via drag.

### Version 11.01 [ March 12th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed pet bar not displaying the spell textures correctly.
*   **Misc. Changes:**
    *   None

### Version 11.00 [ March 12th 2019 ]

#### Important Information

This release resets the nameplate settings in order to transition to the new nameplates.

Make sure you check out [the post in the news section](https://www.tukui.org/news.php) for the details!

*   **New Additions:**
    *   NamePlates were rewritten from scratch. They now utilize the oUF framework like our UnitFrames. Keep in mind that parts of the new nameplates are still being worked on.
*   **Bug Fixes:**
    *   Fixed our SetTemplate function, which now should finally deal with all (maybe =)) Border issue regarding the Pixel Changes introduced with 8.1.
*   **Misc. Changes:**
    *   We now only use one Font option for the Character-/Inspect Feature.
    *   Put the Voice Chat Buttons in our Left Chat. Now its more intuitive to find it.
    *   Various skin tweaks/changes.

### Version 10.92 [ March 4th 2019 ]

#### Important Information

This release contains a warning popup which informs the user that nameplates will be reset when ElvUI v11 is released with patch 8.1.5 on March 12th.

Make sure you check out [the post in the news section](https://www.tukui.org/news.php) for the details!

*   **New Additions:**
    *   Added option to suppress the "UI Scale Changed" popup for the current session. It is a checkbox on the popup itself.
*   **Bug Fixes:**
    *   Fixed visibility of raid frames in the installer for the healer layout.
*   **Misc. Changes:**
    *   Added warning popup with information about nameplates getting reset with patch 8.1.5.
    *   Added hard cap on min/max values for UI Scale setting.
    *   Added hard cap on max value for general font size setting.
    *   Added support for checkboxes on our static popups.
    *   Reverted some of the recent UI scale changes in an attempt to make it work correctly for more people.
    *   A few skin tweaks.

### Version 10.91 [ February 27th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue with Objective Tracker in Mythics.
*   **Misc. Changes:**
    *   None

### Version 10.90 [ February 25th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue causing UIScale value to be stored as string instead of number, resulting in an error in v10.89.
*   **Misc. Changes:**
    *   Changed UIScale information popup so it will continue to pop up until an action has been taken. This is to make sure the user sees the info in case an error prevented the popup the first time.

### Version 10.89 [ February 25th 2019 ]
*   **New Additions:**
    *   Added options to change font, size and outline on the new itemlevel and enchant info on Character/Inspect frame.
*   **Bug Fixes:**
    *   Fixed an error in the archeology skin.
    *   Fixed incompatibility issue(s) with Kaliel's Tracker due to a moved reference to E.Blizzard.
    *   Fixed rare issue where UIScale had been stored as 0 and would cause the UI to explode.
*   **Misc. Changes:**
    *   None

### Version 10.88 [ February 24th 2019 ]

#### Important Information

With this release we have changed how we handle UI scale in ElvUI.

As a result we no longer set, or rely on, the CVar for UI scale. Because of this your UI scale has to be set again when you first log in with this new version.

We have done our best to make it a graceful transition, and as such you will be presented with a popup on your first log-in, where you can see what your old CVar value was, and choose to use this value. You can also choose to have a UI scale calculated for you, or simply set it manually in the config.

From now on you can choose your UI scale within the ElvUI config, or press the "Auto Scale" button to use the value that was previously considered most optimal for your resolution.

*   **New Additions:**
    *   Added new scale options. (/ec - General - Auto Scale | UI Scale)
    *   Added quality border option for Bag/Bank items. (#869)
    *   Added BoE/BoA text overlay in our Bag/Bank.
    *   Added optional mount name for units on tooltips.
    *   Added a new option to display Inspect Info on the Inspect and Character frames.
    *   Added option to toggle Objective Tracker when boss or arena frames are shown.
*   **Bug Fixes:**
    *   Corrected more Pixel Perfect issues! :D
    *   Fixed taint in CommunitiesUI preventing you from setting notes among other things. Workaround by foxlit.
*   **Misc. Changes:**
    *   Various Skin updates for performance and prettyness.
    *   Modified the bag item level code; items might actually show the correct item level now. :o
    *   Improved the tooltip item level code, it should be far more accurate now! (Thanks AcidWeb and Ls- for helping us with this!) :)
    *   The layout in the installer has been replaced with a new one.

### Version 10.87 [ January 30th 2019 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed an issue with the combat log header. (#1013)
    *   Fixed a bag config error if the bag module was disabled.
    *   Fixed an error caused by incorrect file loading order.
*   **Misc. Changes:**
    *   None

### Version 10.86 [ January 29th 2019 ]
*   **New Additions:**
    *   Added option to toggle on/off the colors on bag slots for bags with assigned items.
    *   Added option to use the Blizzard cleanup method instead of the ElvUI sorting.
    *   Added a way to assign types of items to certain bags by right-clicking the bag icon in ElvUI.
    *   Added a count of remaining available characters to the chat editbox.
    *   Added the source text for mounts in the tooltip.
    *   Added Blizzards way to highlight scrappable items if the Scrapping Machine Frame is open.
*   **Bug Fixes:**
    *   Fixed an issue which plays the bag sounds if you open the Game Menu. (#981)
    *   Fixed issue which caused E:UpdateAll to be called twice, potentially causing errors in plugins.
    *   Added terrible workaround for the broken events that cause health updates to break down.
*   **Misc. Changes:**
    *   Added a compatibility check for our Garrison Mission skin, if GarrisonMissionManger is loaded.
    *   Updated gold datatext. Added an indicator for the current character and characters are now in class color.
    *   Consumable items that disappear when logged out are now sorted last to avoid gaps in the ElvUI bags.
    (credit: Belzaru)*   Added a search filter for Mythic Keystone to LibItemSearch. You can search for keystones or ignore them from sorting with the term "keystone".
    *   Moved the options for the Talking Head to the skin section.
    *   Added Battle of Dazar'alor raid and M+ Season 2 affix debuffs to the RaidDebuffs filter.

### Version 10.85 [ January 4th 2019 ]
*   **New Additions:**
    *   Added "Weakened Soul" back to our Buff Indicator.
    *   Added new Currencies to our Currencies Datatext.
    *   Added NamePlate classbar scale option.
    *   Added color options for UnitFrame Power Predictions.
*   **Bug Fixes:**
    *   Fixed a possible nil error on our NamePlate auras.
    *   Fixed nil error in the Obliterum & PvP skin.
    *   Fixed an issue in Bags skin preventing the "highlight" visual from showing when searching for items.
    *   Fixed an issue which could result in Quest Icon not showing up on nameplates even if it was enabled.
    *   Fixed an issue that we accidentally use the general texture for the UnitFrame backdrop instead of the UnitFrame texture.
    *   Fixed an issue which caused invisible GroupLootContainer frame to intercept mouse clicks. (#824)
    *   Fixed an issue which caused pixel borders to be double or missing. NOTE: Mostly fixed but config is still strange. (#908)
    *   Fixed lua error caused in NamePlate Style Filters about "GetSpecializationInfo". (#926)
    *   Fixed bad values in incomingheals tags. (#950)
    *   Fixed Copy Chat Log (and Copy Chat Line) from displaying lines sometimes.
    *   Fixed minor positioning issue with role indicator on unitframes.
    *   Fixed issue which caused NamePlate StyleFilter NameOnly option to misplace the ClassBar/Portrait on plates.
    *   Fixed issue with ClassBar on NamePlates since 8.1 patch, the ClassBar also correctly works on Druids now.
    *   Fixed issue with NamePlates glow beeing pixelated.
    *   Fixed issues in bag searching. (#931)
    *   Fixed Social Queue Datatext and Chat Message.
    *   Fixed an issue that mostly affected actionbars, where elements would be misplaced after a profile change.
*   **Misc. Changes:**
    *   Changed Health Backdrop Multiplier to be an Override instead.
    *   Updated oUF tags with recent changes.
    *   Hid the Recipient Portrait on the TradeFrame.
    *   ElvUI now staggers the updates that happen when a profile is changed. This should have minimal effect on existing plugins.

### Version 10.84 [ December 11th 2018 ]
*   **New Additions:**
    *   Added option to use health texture also on the backdrop.
    *   Added a seperate Tooltip option to display the NPC ID. (#873)
    *   Added a position option (Left or Right) for the Quest Icon on the Nameplates.
    *   Added option to change the position of the Keybind & Stack Text on the ActionBars. (#361)
    *   Added option to show an icon on an item in the bags if it's scrappable.
    *   Added option in our media section to remove the cropping from icons. Mostly used for Custom Texture Packs.
    *   Added option in our media section to select the 'Font Outline'.
    *   Added the WoW Token price in our Gold DataText.
*   **Bug Fixes:**
    *   Fixed "realm:dash" tag error. (tags.lua:657: bad argument "#2" to 'format')
    *   Fixed QuestGreetingPanel & WorldMap skin not take account to Parchment Remover.
    *   Fixed Masque issues with the AddOn "ElvUI_ExtraActionBars". (#709)
*   **Misc. Changes:**
    *   Updated LibItemSearch to latest version.
    *   Updated the Ace3 (ElvUI config) checkbox skin to a permanent color.
    *   Some Code improvements.
    *   Various Skin tweaks.

### Version 10.83 [ November 20th 2018 ]
*   **New Additions:**
    *   Added Drain Life to channel ticks.
    *   Added Island Expedition progress to the BfA Mission Datatext.
    *   Added NPC Id's to our Tooltip.
    *   Added Debuff Highlighting on our Focus Frame.
    *   Added a dropdown menu to the Garrison Minimap Button. (Credits: Foxlit - WarPlan)
    *   Added a Module Copy option. This allows you to copy module settings to/from your different profiles.
    *   Added Bag Split (Bags + Bank) and Reverse Slots to the Bags. (#203)
    *   Added options to change the Item Level color in the Bags. (#764)
    *   Added options to change the Profession Bags & Bag Assignment color. (#525)
    *   Added options to change the Quest Item colors in bags. (!79 - Thanks @Alex_White)
    *   Added Tooltip offsets while using anchor on mouse. (#204)
    *   Added Tooltip option to alway show the realm name. (#372)
    *   Added quick search for spells in filters. (#30)
    *   Added "Display Interrupt Source" to NamePlate castbars.
    *   Added option to scale the Vehicle display. (#715)
    *   Added Tank & Assist Name Placements. (#128)
    *   Added Pet AuraBars. (Hunters Rejoice)! (#518)
    *   Added Tooltip Group Role. (#583)
    *   Added Power Prediction on UnitFrames. (#421)
    *   Added Raid Icons for Party Targets, Tank & Assist UnitFrames. (#459)
    *   Added Castbar Strata and Level Options. (#323)
    *   Added Color options to the UnitFrames to choose the Blizzard Selection Colors.
    *   Added right-click functionality for the movers in "/moveui" to get to the options. (#843)
    *   Added NamePlate indicators for Quest Mobs. Works only in the Open World.
    *   Added a skin option to remove the Parchment from some skins.
*   **Bug Fixes:**
    *   Fixed display castbar for Arena & Boss Frames.
    *   Fixed Raidmarker spacing. (#791)
    *   Fixed issue which would sometimes keep Player UnitFrame out of range.
    *   Fixed error with UnitFrame Tags when enter Arena. (#821)
    *   Fixed issue which would show a NPC Reputation instead of NPC Title on NamePlates when Colorblind mode was enabled. (#826)
    *   Fixed Health Backdrop ClassBackdrop multiplier. (#134)
    *   Fixed DejaCharacterStats and Character Skin conflicts. (#819)
    *   Fixed "Raid Menu" button in "Raid Control". (!78 - Thanks @Dimitro)
    *   Fixed issue which prevented Style Filters from applying to Healthbars of some Nameplates when Healthbar was disabled.
*   **Misc. Changes:**
    *   Updated CCDebuffs list.
    *   Updated Frenzy buff Id for pets. (#816)
    *   Updated Zul debuff list.
    *   Updated the macro text on the ActionBars to use the ActionBar font.
    *   Optimized Bag Code in various areas. (This should mainly fix the lag reported when opening your bags).
    *   Removed ArtifactBar from the DataBars.
    *   Reworked vendor greys code to resolve issues with the previous versions.
    *   Allow left & right mouse button when using Keybind. (#234)
    *   Updated collection skin. Credits AddOnSkins.
    *   Updated Ace3 skin (ElvUI config page)
    *   Added "ElvUIGVC" chat channel for Version Checking (AddOn Communication) and Voice Chat (off by Default) on realm.
    *   Time datatext will now use the 24 hour clock by default in non-US regions. (#839 - Credit: @Zucht)

### Version 10.82 [ September 18th 2018 ]
*   **New Additions:**
    *   Added toggle option for the New Item Glow in your bags. (#452)
    *   Added an option to hide the honor databar below max level. Disabled by default.
    *   Add width override for nameplate auras. (#142)
*   **Bug Fixes:**
    *   Fixed a rare nil error in the range code.
*   **Misc. Changes:**
    *   Added Infested affix buff to RaidBuffsElvUI filter.
    *   Updated ArenaPrepFrame functions (Thanks oUF!).
    *   Updated PvP, LFG & Talent skins.

### Version 10.81 [ September 6th 2018 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue with display of Attonement in Buff Indicators when the Trinity talent is active (#346).
    *   Fixed issue with "out of range" display on UnitFrames on the Mother encounter in Uldir (#767).
*   **Misc. Changes:**
    *   Added BfA Dungeon debuffs to RaidDebuff filter. Credit: Dharwin & Rubgrsch.
    *   Removed T-18 4 PC Bonus from the Druid Buff Indicator.

### Version 10.80 [ September 2nd 2018 ]
*   **New Additions:**
    *   Added toggle option for Cutaway health on Nameplates.
    *   Added dedicated backdrop color option to chat panels.
    *   Added backdrop color option to Chat Panels.
    *   Added Seafarer's Dubloon to the Currency Datatext.
    *   Added Strata option for the Bags.
    *   Added a temp mover for the Scrapping Machine Frame.
*   **Bug Fixes:**
    *   Fixed Nameplate Cutaway health not following Style Filter Health Color changes.
    *   Fixed the AltPowerBar enable toggle not requiring a reload.
    *   Fixed Blizzard Forbidden Nameplates not spawning in the world when Nameplate module was enabled.
    *   Fixed the default position for the UIWidgetTopCenter mover.
    *   Fixed issue with chat frames and data panels disappearing (#686).
    *   Fixed statusbars on the ToyBox & Heirloom tab in the collection skin.
    *   Fixed issue which prevented debuff highlight from working for shadow priests and diseases.
    *   Fixed channel ticks for Penance with talent 'Castigation'
*   **Misc. Changes:**
    *   Removed Legion debuffs
    *   Updated BfA consumables buffs

### Version 10.79 [ August 20th 2018 ]
*   **New Additions:**
    *   Added Tranquility channel ticks (#586).
    *   Added Phase Indicator for Target, Party and Raid frames (Thanks @ls-).
    *   Added Cutaway Health to nameplates (part of #331).
    *   Added BFA Mission Datatext (Thanks @AcidWeb).
    *   Added ActionBar option to color Keybind Text instead of Button.
    *   Added Alternative Power Bar. The settings are located under "/ec - General - Alternative Power".
*   **Bug Fixes:**
    *   Fixed a texture issue on the Talent skin (#566).
    *   Fixed bags from being shown over the WorldMapFrame (#592).
    *   Fixed an issue which caused the cooldown module to error: "Font not set" (#548).
    *   Fixed an issue which prevented the frame glow being shown on a UnitFrame with the Frame Orientation set to right (#558).
    *   Fixed skin issue with Mission Talent Frame.
    *   Fixed issue which prevented clicking in the top-right of screen where Minimap is by default (when the Minimap is not actually there).
    *   Fixed Stagger class bar auto-hide (Thanks to Jimmy Pruitt).
    *   Fixed Ace3 plus/minus on some scrollbars (#631 - Thanks @sezz).
*   **Misc. Changes:**
    *   Updated spell id for Earth Shield (#527).
    *   Updated SpellHighlightTexture in the Spellbook (#547).
    *   Updated WarboardUI skin.
    *   Updated Communities skin.
    *   Open PVP frame when you click on the Honor bar.
    *   Updated the Spec Switch Datatext.
    *   Added a toggle in General for Voice Overlay.
    *   Allowed Special Aura filters to be localized.
    *   Skin Ace3 Keybinding Widget (Thanks @sezz).
    *   Updated "LibActionButton-1.0-ElvUI" to handle #375 (Thanks @sezz).
    *   Added support for mages in Debuff Highlight, they can once again remove curses.
    *   Updated code which shows item level in tooltip (Thanks @AcidWeb).
    *   Auto-Disable ElvUI_EverySecondCounts as it is retired now.
    *   Aura Special Filters can now be localized.
    *   Skin the QuickJoinToastButton.
    *   Updated Chat Emojis.

### Version 10.78 [ July 28th 2018 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed CVar "chatClassColorOverride" not working correctly.
    *   Fixed errors which occurred in "OrderHallTalentFrame" and "Contribution" skins.
    *   Fixed memory leaking from "GetPlayerMapPosition" API. (Thanks to Rubgrsch and siweia!)
    *   Fixed bags not properly showing items when searched.
    *   Fixed an issue that sometimes the chat scrollBars where not hidden properly.
*   **Misc. Changes:**
    *   Re-enable the old Guild skin back.
    *   Updated Communities, PVP & Tooltip skins.

### Version 10.77 [ July 20th 2018 ]
*   **New Additions:**
    *   Added a mover for the Chat buttons.
*   **Bug Fixes:**
    *   Reworked the Microbar mouseover handler. (#523)
    *   Fixed issue which caused community chats to be shown in all chat frames.
*   **Misc. Changes:**
    *   Updated "Setup Chat" part of installer to enable class colors in all channels and communities.
    *   Updated CommunitiesUI skin.
    *   Added support for chat filters for community channels displayed in the real chat window.

### Version 10.76 for patch 8.0.1 [ July 19th 2018 ]
*   **New Additions:**
    
*   **Bug Fixes:**
    *   Fixed issue with backdrop on tooltips turning blue.
    *   Fixed error when pressing 'Enter' to start typing in the chat (#485).
*   **Misc. Changes:**
    *   Added skins from Simpy for Artifact Appearance and Orderhall Talents.
    *   Added support for Load On Demand addons' memory/cpu usage display in tooltips (credit: cqwrteur).
    *   Fixed a texture issue in the Quest Log skin.
    *   Updated skinning of the 'TodayFrame' in the calendar. It uses skinning from Azilroka.

### Version 10.75 for patch 8.0.1 [ July 17th 2018 ]
*   **New Additions:**
    *   New Cooldown settings, they can be found in the Cooldowns category or by typing "/ec cooldown".
    *   Added Death Knight Rune sorting option under "/ec - Player Frame - Classbar - Sort Direction".
    *   Added new Azerite DataBar (replaces Artifact DataBar).
    *   Added button size and spacing options to the Micro Bar.
    *   Added scale option for the smaller world map.
    *   Added new skins for the new elements in patch 8.0.
    *   Added the original chat buttons to a dedicated panel which can be toggled by right-clicking the "<" character in the left chat panel.
*   **Bug Fixes:**
    *   Fixed issue with UnitFrame Mouseglow when Portraits was enabled in non-overlay mode.
    *   Fixed error when attempting to right click a fake unitframe spawned from "Display Frames" by unregistering mouse on these frames.
    *   Fixed issue with Guild Bank which sometimes prevented icons from being desaturated during a search while swapping between bank tabs. This also corrects the strange delay it appeared to have.
    *   Fixed issue which caused chat emojis to hijack hyperlinks.
    *   Fixed icon border on black market auction house items.
    *   Fixed "namecolor" not updating sometimes when it should.
    *   Fixed skin issue when using a dropdown in the config.
    *   Fixed friendly nameplates not showing in Garrisons.
    *   Fixed issue with tooltip compare being activated when it should not (#471).
    *   Fixed several issues with the Micro Bar.
    *   Fixed error in the Spellbook relating to our Vehicle Button on the minimap and position of the Minimap (#434).
    *   Fixed various issues with tooltips (#472).
*   **Misc. Changes:**
    *   In order to improve load times, ElvUI will no longer load "Blizzard_DebugTools".
    *   Reworked the Talent frame skin slightly, in order to improve determination of selected talents.
    *   Simplify how the Chat module handles Chat Filters. (Thanks Ellypse)
    *   Changed how icons get shadowed in Guild bank and Bags module.

### Version 10.74 [ June 7th 2018 ]
*   **New Additions:**
    *   Added "Group Spacing" option to party/raid frames. This allows you to separate each individual group.
    *   Added option to move the Resurrect Icon on the party/raid/raid40 frames.
    *   Added new UnitFrame Glow settings located under "UnitFrame -> General -> Frame Glow". Each type of UnitFrame (Player, Target, Etc) has new options to disable these settings individually.
    *   Added an option "Nameplates -> General -> Name Colored Glow" to use the Nameplate Name Color for the Name Glow instead of Glow Color.
    *   Added options to override the Cooldown Text settings inside of "Bags", "NamePlates", "UnitFrames", and "Buffs and Debuffs".
*   **Bug Fixes:**
    *   Fixed instance group size for Seething Shore and Arathi Blizzard.
    *   Fixed issue that prevented the Guild MOTD from being shown in the chat after a "/reload" sometimes.
    *   Fixed issue that prevented the Loot Spec icon on BonusRollFrame from showing correctly after changing specs.
    *   Fixed issue which could cause an error in other addons when Chat History was enabled.
    *   Fixed issue with range checking on retribution paladins below lvl 78. Until lvl 12 the range will only be melee, then you get Hand of Reckoning which we can use to check range.
    *   Fixed issue preventing the stance bar buttons to be keybound.
    *   Fixed issue which caused the Chat History to sometimes attempt to reply to the wrong BattleTag friend. This will only fix BattleTag friend history messages to be linked correctly, while Real ID friends history messages will still suffer from this issue. ref: !44 (Thanks @peuuuurnoel)
    *   Fixed tooltips getting skinned while Tooltip Skin option is disabled.
    *   Fixed issue which prevented a dropdown from being shown in the world map.
    *   Fixed an error regarding LeaveVehicleButton in battlegrounds.
    *   Fixed a typo in datatexts which could prevent LDB data texts from loading when entering world.
    *   Fixed issue which prevented the "new item" glow from hiding on items in bag 0 when closing bags.
    *   Fixed various issues with the Targeted Glows on NamePlates.
    *   Fixed issue which made the Friendly Blizzard plates wider than they should be for some users.
    *   Fixed issue which may have caused the Nameplate Clickable range to be off more than it should.
    *   Fixed issue which prevented nameplate glow from wrapping around the enemy castbars.
    *   Fixed error for shapeshifting druids who enter combat when nameplate classbar is attached to player nameplate.
*   **Misc. Changes:**
    *   The Plugin Installer frame is now movable.
    *   The Chat Module now supports Custom Class Colors a little better now.
    *   Chat History will now highlight keywords, allow linking of URLs, and will no longer populate Last Tell for replies.
    *   Reworked the Equipment Flyout skin.
    *   Unitframe tags will now return nil instead of an empty string when there is nothing to show.
    *   Made it more clear that the "vendor greys" button also deletes items when not at vendor.
    *   The system datatext will now display protocol info (IPv4/IPv6) if applicable. (credit: Kopert)
    *   Resetting a UnitFrame to default will now show a popup confirmation upon clicking the reset button.
    *   Nameplate NPC Title Text will now show the glow color on mouseover when it's the only thing shown on the nameplate (health and name disabled with show npc titles turned on).
    *   E:ShortValue will now floor values below 1000.
    *   Optimized nameplates a bit, by making sure updates on Blizzard plates would not continue firing after we replaced them with our own.

### Version 10.73 [ March 23rd 2018 ]
*   **New Additions:**
    *   Added color options for Debuff Highlighting.
    *   Added mover for BonusRollFrame.
    *   Added option to Enable/Disable individual Custom Texts.
    *   Added individual font size options to duration and count text on Buffs and Debuffs (the ones near the minimap).
    *   Added spacing option to unitframe Aura Bars.
    *   Added an option to show the unit name on the chatbubbles.
    *   Added option to use BattleTag instead of Real ID names in chat.
    *   Added option to use a vertical classbar on unitframes.
    *   Added spacing option for classbar on unitframes. It controls the spacing between each "button" when using the "Spaced" fill.
    *   Added an option for a detailed report for Vendor Grey Items.
    *   Added Talent Spec Icon on the tooltip.
    *   Added Instance Icons on the Saved Instances tooltip. (Thanks Kkthnx for the idea!)
*   **Bug Fixes:**
    *   Fixed issue that would allow quest grey items to be vendored via Vendor Grey Items.
    *   Fixed rare tooltip error (attempt to index local 'color').
    *   Fixed error trying to copy settings between nameplate units (#305).
    *   Fixed various issues with the keybind feature (/kb). Trying to keybind an empty pet action button will now correctly show a tooltip. Trying to keybind a flyout menu will now correctly show a tooltip too.
    *   Clicking on a player's name who whispered you or messaged into guild chat via Mobile app will now properly link their name with realm attached.
    *   Corrected issue which made the UI Scale incorrect after alt-tab during combat when using Fullscreen on higher resolutions. (This will now autocorrect itself after combat ends).
    *   Fixed issue in which class colored names in chat could still hijack the coloring of some hyperlinks. (This will also allow other hyperlinks to be keywords as well.)
    *   Fixed UI-Scale bug for users over 1080p in Fullscreen mode. (Thanks AcidWeb and Nihilith for helping debug).
    *   Fixed UI-Scale being off for Mac users as well. (Thank you critklepka for helping debug the Mac scale issue).
*   **Misc. Changes:**
    *   Skinned the new Allied Races frame.
    *   Skinned a few more tutorial frame close buttons.
    *   Skinned the Expand/Collapse buttons on various frames.
    *   Skinned the reward and bonus icons on the PvP Skin.
    *   Skinned the reward icons with a quality border on the quest skin.
    *   Skinned the Orderhall/Garrison Portraits.
    *   Adjusted the Flight Map's font to match the general media font (#306).
    *   Added the combat and resting icon texture from Supervillain UI and Azilroka.
    *   Changed the click needed to reset current session in the gold datatext from Shift+LeftClick to Ctrl+RightClick.
    *   Added automatic handling of "Attach To" setting on unitframe auras. When setting Smart Aura Position, then the "Attach To" setting will automatically be set for the respective aura type, and then the selection box will be disabled.
    *   Saved Instances will now be sorted by name then difficulty. (Thanks Kelebek for initial work!)
    *   Saved Instances will now show Raid Finder lockouts correctly and will also allow heroic dungeons to be shown.
    *   Updated the New Item Glow to the Bag module. (This will flash on the inside of the slot, based on the slots border color.)
    *   Updated the Quest and Upgrade Icon in the Bag module.
    *   Added Kin's Forging Strike to Raid Debuffs (for normal+ raids).

### Version 10.72 [ January 28th 2018 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed position of the ElvUI Status Report frame (/estatus).
    *   Fixed issue updating npc titles on NamePlates.
    *   Fixed placement issue of name and level on NamePlates when "Always Show Target Healthbar" is disabled.
    *   Improved workaround for vehicle issue on Antoran High Command (credit: ls-@GitHub).
*   **Misc. Changes:**
    *   The Style Filter action "Name Only" will also display the NPC title now.
    *   Sorted the Dropdown for Style Filters by Priority (rather than by Name).
    *   Skinned various tutorial frame close buttons.

### Version 10.71 [ January 23rd 2018 ]
*   **New Additions:**
    *   Added toggle option for the new handling of the "Unspent Talent Alert" frame.
    *   Added option to control the amount of decimals used for values on elements like NamePlates and UnitFrames.
    *   Added new "Quick Join" datatext.
    *   Added new style filter action "Power Color".
    *   Added options to hide specific sections in the Friends datatext tooltip.
    *   Added the ability to assign items to bags like in Blizzard's ui to our big bag (toggle the bags and right click bag -> assign it).
    *   Added new command "/estatus" which will show a Status Report frame with helpful information for troubleshooting purposes.
*   **Bug Fixes:**
    *   Fixed issue with missing border colors on some elements after a login or reload.
    *   Fixed issue in Chat Copy which made it unable to copy dumped hyperlinks properly.
    *   Fixed issue with arena frames displaying wrong unit in PvP Brawls.
    *   Fixed issue which caused the MicroBar position to be misplaced during combat.
    *   Fixed issue which caused the Color Picker default color button to be disabled when it should still be active.
    *   Fixed error when importing style filters via global (account settings).
    *   Fixed issue (#282) which prevented some Style Filter actions from taking affect.
    *   Fixed issue (#288) which caused items in the bag to not update correctly (after sorting).
    *   Fixed issue which caused the invite via Guild and Friend (non-bnet) datatext to not properly request an invite.
*   **Misc. Changes:**
    *   Updated UnitFrame and NamePlate heal prediction based on oUF changes.
    *   Various tweaks and fixes to skins and skinned: Recap button & Warboard frame.
    *   Tweaked sorting in the Friends datatext so WoW is always on top.
    *   Updated some of the Priest, Monk, and Paladin Buff Indicator spells.
    *   Style Filter border color action now applies to the Power Bar border as well.
    *   Stacks on nameplate auras will no longer be hidden when they reach 10 or above.

### Version 10.70 [ December 26th 2017 ]
*   **New Additions:**
    *   Added new style filter triggers "Is Targeting Player" and "Is Not Targeting Player".
    *   Added new style filter trigger "Casting Non-Interruptible".
    *   Added new style filter action "Frame Level".
    *   Added ability to Shift+LeftClick the Gold datatext in order to clear session data.
    *   Added visibility options to the bag-bar.
    *   Added visibility options to the microbar.
    *   Added a Combat-Hide option to role icons on party/raid frames.
    *   Added option to self-cast with a right-click on actionbuttons.
    *   Added "Desaturate On Cooldown" option to action bars. It will make icons black&white when the action is on cooldown.
*   **Bug Fixes:**
    *   Changed the vehicle fix we put in place previously. It will only affect the Antorus raid instance now. You no longer need pet frames to see vehicles in old raids.
    *   Fixed issue with stance bar visibility when switching between specs.
    *   Fixed issue with aura min/max time left settings in style filter actions.
    *   Fixed position issue with the nameplate target arrow when portrait was hidden.
    *   Fixed issue where style filter trigger didn't always set the health color properly.
    *   Fixed issue which required the user to click "Okay" in the Color Picker before colors updated (this was locked down intentionally for performance reasons, but those issues have been resolved in a different way). Colors will now update as you click the wheel.
    *   Fixed a performance issue with bag sorting. Sorting should seem a lot smoother, especially for low end computers.
    *   Suppressed error that could happen when you received a whisper from a friend which WoW had not provided data for yet.
    *   Fixed issue which broke the Aura step in the install guide.
    *   Fixed a few issues with auto-invite relating to other realms and multiple friends from the same bnet account.
    *   Fixed a frame level issue with nameplates which caused them to bleed into each other when overlapped.
    *   Fixed issue which caused the version check for ElvUI and associated 3rd party plugins to get sent to the addon communications channel excessively. It will now send a lot fewer messages in total.
    *   Fixed issue which could cause the clickable area on nameplates to use an incorrect size.
    *   Fixed issue with healer icons in battlegrounds when multiple players had the same name.
    *   Fixed various issues with the Friend datatext relating to multiple characters or games from the same account.
*   **Misc. Changes:**
    *   Cleaned up code in Friend datatext.
    *   Friend datatext can now show friends who are playing multiple games and show each character that is on WoW with the ability to invite or whisper each toon via right click menu.
    *   Enhanced the display and sorting of the Friend datatext.
    *   Shortened the text displayed on the movement speed datatext. This is currently only affecting the English client, but can be modified for other localizations by changing the respective localization string.
    *   Clicking the Currencies datatext will now open the currencies frame in WoW.
    *   Updated RaidDebuffs filter and added a few from Tiago Azevedo.
    *   Removed alert and flash in chat tabs when chat history is displayed after a login or reload.
    *   Removed IconBorder texture on BagBar bag icons.
    *   Various font and skin tweaks.
    *   Skinned the "Unspent Talent Point" alert and positioned it near the top of the screen.
    *   Changed the default value of "Max Duration" for Target Debuffs to 0.
    *   Included the minimap location text font in the "Apply To All" option.
    *   Reverted a backdrop color change on the TradeSkill frame.
    *   Changed the name format used for the ElvUI nameplates. Previously it was "ElvUI_Plate%d_UnitFrame" and now it is "ElvUI_NamePlate%d".

### Version 10.69 [ December 1st 2017 ]
*   **New Additions:**
    *   Added visibility settings to the Stance Bar. By default it will hide in vehicles and pet battles.
    *   Added options for Combat Icon on the player unitframe.
    *   Added options for Resting Icon on the player unitframe.
    *   Added options for Health font on NamePlates.
    *   Added option to copy a single chat line by clicking a texture on the left side of it.
    *   Added raid debuffs for the new Antorus, the Burning Throne raid.
    This requires testing and feedback by users.
*   **Bug Fixes:**
    *   Fixed issue with Style Filter scale action.
    *   Fixed pet type in the pet battle UI for non-English clients.
    *   Fixed pet type in tooltip for non-English clients.
    *   Fixed issue with nameplates not updating correctly when leaving a Warframe vehicle.
    *   Fixed issue with chat history showing incorrect name on messages from BNet friends.
    *   Fixed issue which caused auras to not respect the Max Duration setting when priority list was empty.
    *   Fixed issue which may have caused weird behaviour with player nameplate hide delay.
    *   Fixed issue which caused some Quick Join messages in chat to be duplicated.
    *   Fixed issue which made it impossible to target raid members in vehicles in the new raid instance. This is a temporary workaround until Blizzard fixes the issue. Until then you need to use Raid-Pet Frames if you need to see vehicles (Malygos, Ulduar etc.).
*   **Misc. Changes:**
    *   Various tweaks/updates to a lot of the skins.
    *   Various code clean-up by Rubgrsch.
    *   Tweaked pixel perfect code.
    *   Made sure Style Filters can handle alpha with flash action.
    *   Moved datatext gold format option into the "Currencies" tab.
    *   Raid icons will now be displayed as text in the Copy Chat window so they can be copied correctly.
    *   Chat History now supports multiple chat windows and will display the chat history in the correct chat window according to chat settings.
    *   Holding down the Alt key while scrolling in the chat will now scroll by 1 line.
    *   Changed Ace3 skin to no longer add border on SimpleGroup widgets.
    *   The Quest Choice skin is now enabled by default.

### Version 10.68 [ October 26th 2017 ]
*   **New Additions:**
    *   Added option to show Quick Join messages as clickable links in chat.
    *   Added option to change duration text position on nameplate auras.
    *   Added option to change castbar icon position on nameplates.
    *   Added font outline option for the Threat Bar.
*   **Bug Fixes:**
    *   Fixed issue with nameplate scale not following Style Filter settings on target change.
    *   Fixed issue with placement of microbar within its mover frame.
    *   Fixed issue which caused player unitframe to bug out when entering invasion point while in a Warframe.
    *   Fixed error when setting text color on custom buff indicators.
    *   Fixed issue preventing you from inviting people on remote chat in Guild datatext.
    *   Fixed issue which caused classbar to disappear from target nameplate.
    *   Fixed issue which caused enemy nameplates to break after having targeted a friendly unit in an instance and have the classbar appear above that nameplate.
*   **Misc. Changes:**
    *   Added Beacon of Virtue to Buff Indicator filter.
    *   Changed default fonts on NamePlates to PT Sans Narrow.
    *   Changed "XP" to "AP" on the Artifact DataBar.
    *   Added more game clients to the Friends datatext.
    *   Skinned the "Skip Cinematic" popup frames.
    *   Added a separate skin setting for Blizzard Interface Options.
    *   Changed Loot Frame mover to always be visible when movers are toggled.
    *   Code clean-up by Rubgrsch.
    *   Updated some aura filters.

### Version 10.67 [ October 2nd 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed error in castbar element (for real this time).
*   **Misc. Changes:**
    *   None

### Version 10.66 [ October 2nd 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed error in castbar element.
*   **Misc. Changes:**
    *   None

### Version 10.65 [ October 1st 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue creating new style filters.
*   **Misc. Changes:**
    *   None

### Version 10.64 [ October 1st 2017 ]
*   **New Additions:**
    *   Added Korean option for the "Numer Prefix Style" setting. This will allow unitframe tags to use the Korean number annotations.
    *   Added "Match SpellID Only" option to individual RaidDebuff Indicator modules. If disabled it will allow it to match by spell name in addition to spell ID.
    *   Added possibility of setting alpha of the stack and duration text colors on RaidDebuff Indicator modules.
    *   Added global option to choose which filter is used for the RaidDebuff Indicator modules. This is found in UnitFrames->General Options->RaidDebuff Indicator.
    *   Added new "CastByNPC" special filter for aura filtering.
    *   Added talent triggers for nameplate style filters.
    *   Added instance type triggers to nameplate style filters.
    *   Added instance difficulty triggers to nameplate style filters.
    *   Added classification triggers to nameplate style filters.
    *   Added toggle option for datatext backdrop. Disabling it will remove the backdrop completely and only show text.
    *   Added option to hide Blizzard nameplates. If enabled then you will no longer see nameplates with the default Blizzard appearance. This option can be found in the NamePlate General Options.
    *   Added cooldown trigger to nameplate style filters. This allows you to trigger a filter when one of your spells is either on cooldown or ready to use.
    *   Added font options for the duration and stack text on nameplate auras. These options can be found in the "General Options -> Fonts" section.
    *   Added alpha action to nameplate style filters.
    *   Added "name only" action to nameplate style filters.
    *   Added flash action to nameplate style filters.
    *   Added tick width option to player unitframe castbar.
    *   Added tick color option to player unitframe castbar.
    *   Added "Auto Add New Spells" option to actionbar general options.
    *   Added "German Number Prefix" to the "Unit Prefix Style".
    *   Added Power Threshold trigger to nameplate style filters.
    *   Added ability to match players own health in the "Health Threshold" trigger for nameplate style filters.
    *   Added role icons to the RaidUtility frame when in a raid.
*   **Bug Fixes:**
    *   Attempt more fixes towards the unit errors on nameplates.
    *   Fixed a divide by 0 error in Artifact DataBars.
    *   Fixed issue which broke stealable border color on unitframe auras while in a duel.
    *   Fixed issue which broke item links and icons in the profile export when using table or plugin format.
    *   Fixed issue with AP calculation on items in bags. We no longer use tooltip scanning. We have come up with a much better and accurate way of handling it.
    *   Fixed issue with position of detection icon on nameplates when using "Name Only".
    *   Fixed issue with healer icon position when portrait is enabled on nameplates.
    *   Fixed issue which caused the "Hide" action on nameplate style filters to incorrectly show hidden nameplates if "Hide" was disabled.
    *   Fixed issue with portrait position on nameplates when healthbar is disabled but forced to be shown on targeted nameplate.
    *   Fixed issue with chat editbox position when backdrop was enabled/disabled.
*   **Misc. Changes:**
    *   Added and updated spell IDs in the RaidDebuffs filter.
    *   Added Veiled Argunite to the Currencies datatext tooltip.
    *   Replaced more Blizzard font elements for panels where fonts were mixed.
    *   Various skin fixes and tweaks.
    *   Added stealable border color on nameplate auras.
    *   Changed default position of role icons on unitframes so they don't overlap with name.
    *   Moved "Reset Filter" button in the Filters section and added requirement of an additional click to execute.
    *   Renamed "Number Prefix" option to "Unit Prefix Style".
    *   Changed the default value for "Unit Prefix Style" from Metric to English.
    *   Optimized handling of events for the nameplate style filters to reduce performance impact.
    *   Added new library LibArtifactPower-1.0 by Infinitron. We will use this to improve AP calculations.
    *   Added possibility of hooking into style filter conditions.
    *   Fixed a few font elements on Blizzard panels that were not getting replaced with chosen ElvUI font.
    *   Added skin for the CinematicFrameCloseDialog frame.
    *   Added skin for the TableAttributeDisplay frame.
    *   Added some additional spells to the RaidDebuffs and RaidBuffsElvUI filters for M+ dungeons.

### Version 10.63 [ September 9th 2017 ]
*   **New Additions:**
    *   Added quest boss trigger to nameplate Style Filters.
    *   Added a new default filter named "RaidBuffsElvUI". Meant for buffs provided by NPCs in raids or other PvE content. Both for buffs put on enemies and players.
    *   Added a "Reset Aura Filters" button for all Buffs, Debuffs and Aura Bars modules on both nameplates and unitframes. This will reset the Filter Priority list to the default state.
    *   Added a "Reset Filter" button to all default filters in the Filters section of the config. This will completely reset the filter to its original state and remove any spells the user added.
    *   Added 2 new special filters for Aura Filtering: "CastByPlayers" and "blockCastByPlayers". These can either allow or block all auras cast by player units (meaning not NPCs).
*   **Bug Fixes:**
    *   Fixed rare error in nameplates regarding attempt to use a non-unit value as argument for UnitIsUnit API.
    *   Fixed taint which prevented kicking someone from guild.
    *   Fixed issue which caused "Fluid Position" option for Player unitframe to go missing. (Abeline)
    *   Fixed rare error in nameplates when changing target.
    *   Fixed issue which may have caused some nameplate elements to stay visible when nameplate was not.
    *   Fixed issue which caused nameplate mouseover highlight to stay visible until you moused over another unit.
*   **Misc. Changes:**
    *   Changed how we control state of filters used in filter priority lists. Now you use Shift+LeftClick to toggle between friendly, enemy and normal state on a filter.
    *   Tweaked default settings for aura filter priority lists based on feedback from users.
    *   Added skin for NewPetAlertFrame.
    *   Removed caching of HandleModifiedItemClick to allow hooks to fire from other addons.
    *   Fixed spell ID for Consuming Hunger in the RaidDebuffs filter.

### Version 10.62 [ August 30th 2017 ]
*   **New Additions:**
    *   The enabled state of a Style Filter for nameplates is now stored in your profile instead of being global.
    *   Added "Role" to Style Filter triggers. Your current role has to match this before a filter is activated. If no role is selected then it will ignore this trigger and try to activate.
    *   Added "Class" to Style Filter triggers. You can select which classes and specs this filter should activate for. Your current class and spec has to match this before a filter is activated. If no spec is selected then it will only match class.
    *   Added "blockNonPersonal" special filter for aura filtering. Combine this filter with a whitelist in order to only see your own spells from this whitelist.
*   **Bug Fixes:**
    *   Fixed rare error in nameplates regarding attempt to use a non-unit value as argument for UnitIsUnit API.
*   **Misc. Changes:**
    *   Updated Ace3 libraries.
    *   Values on the Artifact DataBar tooltip will now use the short format provided by ElvUI.
    *   Changed various default settings for aura filtering in order to lessen the confusion for users.
    *   Added Veiled Argunite to Currencies datatext.
    *   Disabled the "Boss" Style Filter by default.
    *   Updated LibActionButton.

### Version 10.61 For Patch 7.2.5 and 7.3.0 [ August 29th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue which broke the Ace3 config of other addons.
*   **Misc. Changes:**
    *   Reverted some changes to Profiles section of ElvUI.

### Version 10.60 For Patch 7.2.5 and 7.3.0 [ August 29th 2017 ]
*   **New Additions:**
    *   MAJOR: Added "Style Filters" to NamePlates, allowing you to perform various actions on specific units that match your chosen filter settings.
    *   MAJOR: Added a new aura filtering system to NamePlates and UnitFrames. This new system is much more advanced and should allow you to set up the filters exactly how you want them.
    *   Added enhanced target styles for NamePlates. A cool glow and arrows have been added, along with the ability to change their color.
    *   Added mouseover highlight to the NamePlates.
    *   Added movement speed datatext. (Rubgrsch)
    *   Added a "Fluid Position" option to Smart Aura Position settings. This will use the least amount of spacing needed. (Abeline)
    *   Added a "yOffset" option to Aura Bars on Player, Target and Focus unitframe. (Abeline)
    *   Added Portrait option to NamePlates. This was also added as an action in style filters.
*   **Bug Fixes:**
    *   Fixed an error when entering combat while game is minimized.
    *   Fixed scaling of the Leave Vehicle button on the minimap. (Hekili)
    *   Fixed Bagbar buttons border size. (Rubgrsch)
    *   Fixed error when switching profile while having player unitframe disabled.
    *   Fixed issue which caused unitframe tags containing literals to use OnUpdate instead of their assigned events. (Martin)
    *   Fixed issue which could break actionbar paging when the code contained the new-line character (n)
*   **Misc. Changes:**
    *   Updated a lot of skins.
    *   Updated Chinese localization. (Rubgrsch)
    *   Artifact DataBar tooltip will now show the artifact name and only show points to spend when you can actually spend some. (Kkthnx)
    *   Updated RaidDebuffs filter with more ToS debuffs.
    *   Default chat bubbles can now use the ElvUI chat bubble font unless it was disabled.
    *   Removed "Hide In Instance" option for chat bubbles.
    *   Changed the max font size for General Font to a softmax. You can manually input a value higher than the slider allows.
    *   The ElvUI logo has been updated with design by RZ_Digital.
    *   The default color in ElvUI has been changed to match the new logo.
    *   Disabled "Text Toggle on NPC" by default, as it caused confusion for new players.
    *   Restructured the UnitFrame sections of the ingame config. It now uses tabs instead of the often overlooked dropdown.
    *   Added shortcut buttons to the ActionBars and UnitFrames main pages.
    *   Added Drag&Drop support to AceConfig buttons for our new aura filtering system.

### Version 10.59 [ June 27th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed error when having Masque enabled but having ElvUI skinning disabled within Masque settings.
    *   Fixed rare error in world map coords. (Simpy)
    *   Fixed "script ran too long" error when jumping from Skyhold to Dalaran.
    *   Fixed a few "attempt to access forbidden object" errors relating to tooltip. We can't fix them all, Blizzard need to step in here.
    *   Fixed error in reagent bank caused by trying to index a missing questIcon object.
*   **Misc. Changes:**
    *   Invalid tags on unitframes will now display the used tag text instead of [invalid tag].
    *   Added some spell IDs for ToS to RaidDebuffs filter. Probably not complete, community will need to provide feedback and fill in the blanks. (Merathilis)
    *   Units in different phases will now always have their unitframe be displayed as out of range.
    *   Various skin tweaks and fixes.

### Version 10.58 [ June 18th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue with display of interruptable / non-interruptable colors on the unitframe castbars.
    *   Fixed issue with display of total cast time on the player castbar when crafting multiple of the same item.
    *   Fixed issue which caused ElvUI to re-enable chat bubbles when the user had disabled them in Interface Options.
*   **Misc. Changes:**
    *   Alerts created by other addons (using the WoW alert system) will now follow the growth direction shown on the Alert Frame mover.

### Version 10.57 [ June 17th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue which prevented ready check icons from displaying correctly.
*   **Misc. Changes:**
    *   Updated our DebugTools code to work with the new 7.2.5 changes. (Simpy)

### Version 10.56 [ June 17th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue which broke coloring of Runes.
*   **Misc. Changes:**
    *   None

### Version 10.55 [ June 16th 2017 ]
*   **Important Info:**
    *   This is for developers of plugins for ElvUI. With the oUF update some elements have been renamed. This means your references to these elements need to be renamed in your code too. Please see [http://www.tukui.org/forums/topic.php?id=39605](https://web.archive.org/web/20170710170020/http://www.tukui.org/forums/topic.php?id=39605) for more info.
*   **New Additions:**
    *   Added option to toggle chatbubbles off while in a dungeon or raid instance. (Simpy)
*   **Bug Fixes:**
    *   Fixed issue which prevented the classbar from showing partial soul shards for destruction warlocks.
*   **Misc. Changes:**
    *   Various skin tweaks by Merathilis.
    *   Updated the unitframe framework "oUF" to latest version.

### Version 10.54 [ June 14th 2017 ]
*   **Important Info:**
    *   Blizzard has made chat bubbles in dungeons and raids protected, meaning we cannot modify them at all. This means chat bubbles will have the default look while you are in a dungeon or raid instance (Garrison included). There is nothing we can do about this, addons are no longer able to modify them under those circumstances.
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed error when mousing over the Order Hall datatext.
    *   Prevent weird error in cooldowns.
*   **Misc. Changes:**
    *   Added localization to datatext selection in the config. (Rubgrsch)

### Version 10.53 [ June 12th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed some tooltip taints brought on by patch 7.2.5 changes.
    *   Fixed issue which broke "relic" search keyword.
    *   Fixed some inconsistencies with the ElvUI chat history. (Kelebek)
    *   Fixed issue which could cause an invisible frame to block clicks when the minimap was moved out of the topright corner.
    *   Fixed AP calculation for items with very high values for Asian clients.
    *   Fixed unitframe range check for demonology warlocks between lvl 10 and 13.
*   **Misc. Changes:**
    *   Various skin tweaks.
    *   Simplified skinning of chat bubbles with new API.
    *   Disabled ElvUI modifications to the WoW error frame until it can be re-coded to work with patch 7.2.5 changes.
    *   Added callback system for ElvUI modules in order to preserve stack trace when an error occurs.

### Version 10.52 [ May 12th 2017 ]
*   **New Additions:**
    *   Added option to display custom currencies in the main Currencies datatext tooltip. The option can be found for each individual custom currency added. (NickS)
*   **Bug Fixes:**
    *   Fixed some issues with the updated Objective Tracker skinning.
    *   Fixed issue which prevented some broker addons from being available as datatext in ElvUI.
    *   Fixed AP calculation in bags when Colorblind Mode was enabled in WoW.
*   **Misc. Changes:**
    *   Added Legionfall War Supplies to Currencies datatext. (NickS)

### Version 10.51 [ May 4th 2017 ]
*   **New Additions:**
    *   Added option to exclude names from Class Color Mentions. Options can be found in the Chat section. (credit: Simpy)
    *   Added options for the Ready Check Icon on Party/Raid/Raid-40 Frames.
*   **Bug Fixes:**
    *   Fixed display of the rep DataBar for paragon factions. It will now correctly count from 0.
    *   Fixed issue which caused the unitframe border color to not stick through a reload/relog.
    *   Fixed issue with AP calculation in bags for items which granted less than 100 AP.
    *   Fixed Class Color Mention in emotes. (credit: Simpy)
    *   Fixed issue with Masque Support on Buffs/Debuffs which caused stack text to disappear.
*   **Misc. Changes:**
    *   A few skin fixes by Rubgrsch.
    *   A lot of skin tweaks/fixes by Bunny67.
    *   Various skin tweaks by Merathilis.
    *   Added Cyrillic support to the Expressway font.
    *   Added Prestige level to the Honor DataBar tooltip.
    *   Removed requirement to hold down Shift in order to move the Interface Options frame.

### Version 10.50 [ April 21st 2017 ]
*   **New Additions:**
    *   Added a separate "Border Color" option for UnitFrames.
*   **Bug Fixes:**
    *   Prevent rare error in chat bubbles. (Simpy)
    *   Prevent error in tooltip when changing spec while mousing over something.
    *   Fixed AP calculation in bags for some items that contained a different number in one of the last lines of the tooltip.
*   **Misc. Changes:**
    *   None

### Version 10.49 [ April 16th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed issue which prevented item borders in bags from updating when opening the bank.
    *   Fixed issue which prevented item buttons in bank from updating on first show.
    *   Fixed a potential error in the oUF stagger element by adding a fallback value.
    *   Fixed an issue which caused the power:max tag to display an incorrect value.
    *   Fixed a display issue with the honor reward icon at certain prestige levels. As a downside it will not look as crisp as it used to.
    *   Fixed AP calculation in bags for Korean and Chinese clients.
*   **Misc. Changes:**
    *   Various skin tweaks by Merathilis.
    *   Removed border color restriction when using the Thin Border Theme. (Phatso)

### Version 10.48 [ April 5th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed display issue with the Micro Bar.
    *   Fixed issue with AP calculation in bag. It should now find items that it previously did not.
    *   Fixed a division by zero error in the Reputation DataBar.
    *   Fixed issue which prevented Mythic Keystone from being sorted.
*   **Misc. Changes:**
    *   Various skin tweaks.
    *   Skinned the new Contribution frame.
    *   Added new Time Release spell IDs to RaidDebuffs filter.
    *   The Artifact DataBar tooltip will now display numbers in groupings (1.000.000).

### Version 10.47 [ March 29th 2017 ]
*   **Bug Fixes:**
    *   Fixed error when trying to import invalid profile table.
    *   Fixed issue which prevented actionbutton icons from updating.
    *   Fixed error caused by attempt to skin non-existent options for Mac.
    *   Fixed the "Darken Inactive" setting for stance bar.
*   **Noteworthy Info:**
    *   The friendly nameplates in dungeons and raids are currently broken. While in a dungeon or raid instance the default WoW nameplates are supposed to be active. Unfortunately this is not the case when the ElvUI NamePlates module is enabled. There is no easy fix for it, as the issue is with how the nameplate module was initially written. For the time being you will have to either play without friendly nameplates in those situations, or disable the ElvUI NamePlates module and use a dedicated addon for NamePlates. We apologize for the inconvenience.

### Version 10.46 [ March 28th 2017 ] (for patch 7.1.5 and 7.2)

*   **Misc. Changes:**
    *   Implemented changes to support the new patch 7.2.
    *   Made various skin tweaks according to latest FrameXML changes.
    *   Enhanced the code which calculates Artifact Power in bags for the Artifact DataBar.
*   **Noteworthy Info:**
    *   Because of a change Blizzard made to friendly nameplates in 7.2, it is no longer possible to modify them in dungeons and raid instances. If you use friendly nameplates in those situations then you will notice that they use the default WoW style. There is nothing we can do about that. More info here: [https://eu.battle.net/forums/en/wow/topic/17615133023](https://web.archive.org/web/20170710170020/https://eu.battle.net/forums/en/wow/topic/17615133023)

### Version 10.45 [ March 21st 2017 ]
*   **New Additions:**
    *   Added a "Size Override" option for individual spells in the Buff Indicator filters.
    *   Added a font outline option for chatbubbles.
    *   Added a toggle option for auto-closing of the pet battle combat log.
    *   Added new [target] unitframe tags which will display the name of the target of the unit:
        *   [target]
        *   [target:veryshort]
        *   [target:short]
        *   [target:long]
        *   [target:medium]
    *   Added option to hide the nameplate powerbar when empty.
    *   Added option to hide the ElvUI Raid Control panel.
*   **Bug Fixes:**
    *   Fixed an error that could happen when adding new spells to the Buff Indicator filters.
    *   Fixed non-relic keyword search. The "power" keyword will once again only find items that grant AP.
    *   Fixed friendly unitframe range check for resto druids.
    *   Fixed issue which caused raid icons on nameplates to not update properly unless targeted.
*   **Misc. Changes:**
    *   Updated unitframe range check for druids to use spells that are learned earlier.
    *   Various skin tweaks.
    *   Added some ToV debuffs to the RaidDebuffs filter.

### Version 10.44 [ February 23rd 2017 ]
*   **New Additions:**
    *   Added new visibility options for the Player NamePlate. These options should function the same regardless of whether or not you have "Use Static Position" enabled.
    *   Added ClickThrough options for Personal, Friendly and Enemy type nameplates. They can be found in the NamePlates General Options.
    *   Added "Current - Percent (Remaining)" text format option for DataBars.
    *   Added font and font-outline options to DataBars.
    *   Added font-outline option to tooltip healthbar.
    *   Added toggle option for display of targeted nameplate health bar. If this is disabled then the current targeted nameplate will not display a healthbar if Health is disabled for this unit type.
*   **Bug Fixes:**
    *   Fixed issue with ObjectiveTracker toggle button showing incorrect value.
    *   Fixed issue which caused the Blizzard PartyMemberBackground frame to show up when it should not.
    *   Fixed "relic" keyword search in bags.
    *   Fixed AP calculation display issue for values over 1 million.
    *   Fixed issue which incorrectly caused Debuff Highlighting to be active for mages. (Brendan Clune)
    *   Fixed issue which caused a mover to not respond to a "reset" immediately if it had been enabled/disabled through E:EnableMover or E:DisableMover.
    *   Fixed error when trying to import a profile from another addon (Vuhdo for example). ElvUI will now handle the error gracefully and inform you that the import string is incorrect.
*   **Misc. Changes:**
    *   Various skin tweaks.
    *   You can now open a sub-section of the ElvUI config directly through the /ec command. This requires that you supply the path to the config page as a comma-separated list. The path needs to match the table structure of the config exactly (in code, not as displayed ingame). Example: "/ec unitframe,player,portrait".
    *   Added E:IgnoreCVar(cvarName, ignore) API. This can be used to tell ElvUI that it should not automatically change a specific CVar which had previously been locked in place by ElvUI.

### Version 10.43 [ January 26th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   None
*   **Misc. Changes:**
    *   Inverted heal absorb display and removed option to change it.

### Version 10.42 [ January 25th 2017 ]
*   **New Additions:**
    *   Added heal absorb display to the heal prediction module. Color can be changed in the UnitFrames section of the config.
    *   Added option to control heal prediction overflow. This will allow the textures to grow past the health border.
    *   Added option to invert heal absorb display. This will make heal absorb cover a portion of the health instead of extending it.
*   **Bug Fixes:**
    *   Fixed error when opening fullscreen worldmap while in combat in the Order Hall.
    *   Fixed width of nameplate auras when not using Thin Border style.
    *   Fixed issue which prevented upgrade icons from Pawn to show on items in bags.
*   **Misc. Changes:**
    *   Various skin tweaks.
    *   Added display of upgrade icon in the skinned version of the default bags.
    *   Renamed "Class Bar" in the General section of the config to "Class Totems" to avoid confusion.

### Version 10.41 [ January 11th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed unitframe range check for new warlocks below lvl 13.
*   **Misc. Changes:**
    *   None

### Version 10.40 [ January 11th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   None
*   **Misc. Changes:**
    *   Added support for up to 10 combo points on the player unitframe class bar (Rogues).
    *   Updated all used libraries to latest versions.

### Version 10.39 for patch 7.1.0 and 7.1.5 [ January 9th 2017 ]
*   **New Additions:**
    *   New unitframe tag [health:percent-with-absorbs] which shows health percentage with shield included, eg. 105%. (Jacob Demian)
*   **Bug Fixes:**
    *   Fixed issue which caused editbox position to not update correctly when changing profile.
    *   Fixed issue which caused AFK mode to not update correctly when changing profile.
    *   Fixed issue which may have allowed the AFK screen to re-appear after the option was disabled.
    *   Fixed a compatibility issue with DejaCharacterStats addon.
*   **Misc. Changes:**
    *   The AFK screen should no longer appear if the character is casting something (crafting).

### Version 10.38 [ January 4th 2017 ]
*   **New Additions:**
    *   None
*   **Bug Fixes:**
    *   Fixed error in Garrison skin when the addon GarrisonCommander was enabled.
*   **Misc. Changes:**
    *   The DPS datatext will no longer count overkill damage. Both DPS and HPS datatexts now uses ShortValue for formatting.
