--[[
		This is the file where all options is available for Tukui
		You don't need do relaunch wow.exe after a change, just save the file and /rl in game
--]]

-- this var is used when we want to set specific settings to a unique character
local myname, _ = UnitName("player")

-------------------------------------------------------------------------------------------------------------------------------
-- Layout (if you want a different layout)
-------------------------------------------------------------------------------------------------------------------------------

Tukui4BarsBottom = false					-- Automatically configure 4 bars at the bottom instead of 2

-------------------------------------------------------------------------------------------------------------------------------
-- Features we want to enable or disable in Tukui! Useful if you want to use something else!
-------------------------------------------------------------------------------------------------------------------------------

TukuiBags = true							-- enable or disable bags
TukuiBars = true							-- enable or disable action bars
TukuiUF = true								-- enable or disable unit frames
TukuiChat = true							-- enable or disable tukui chat
TukuiTooltip = true							-- enable or disable tukui tooltip
TukuiLootWindow = true						-- enable or disable tukui loot windows
TukuiRollLoot = true						-- enable or disable tukui roll frame
TukuiComboText = true						-- enable or disable middle screen combo text
TukuiAutoAcceptInvite = true				-- enable auto accept invite with guildmate or friendlist onlyT
TukuiAutoInvite = true						-- enable auto invite when someone whisper you "invite" or "inv"
TukuiNamePlates = true						-- enable skinned nameplates
TukuiSellGray = true						-- enable auto sell via vendors for gray shitty item
TukuiAutoRepair = true						-- enable auto repair because i always forget to repair, lol!
TukuiErrorHide = true						-- hide this fucking red frame spamming my middle screen for nothing.
TukuiMap = true								-- reskinned map for tukui
TukuiCombatFont = true						-- enable tukui combat font for sct, damage text, etc. (require a restart of wow)

-------------------------------------------------------------------------------------------------------------------------------
-- UnitFrame options
-------------------------------------------------------------------------------------------------------------------------------

unitcastbar = true 							-- enable castbar
cblatency = false 							-- castbar latency
cbicons = true 								-- castbar icons
auratimer = false 							-- true to enable timer aura on player or target
auratextscale = 11 							-- set font size on aura
PlayerDebuffs = false						-- enable debuff on playerframe (it was a request) :x
TargetBuffs = true 							-- false to disable oUF buffs on the target frame
lowThreshold = 20 							-- low mana threshold for all mana classes
highThreshold = 80 							-- high mana treshold for hunters
targetpowerpvponly = true 					-- mana text on pvp enemy target only
totdebuffs = false 							-- show tot debuff (if true, you need to move pet frame)
playerdebuffsonly = false 					-- my debuff only on target, arena and bossframe.
showfocustarget = false 					-- show focus target
showtotalhpmp = false						-- show total mana / total hp text on player and target.
debuffcolorbytype = true					-- debuff by color type
showrange = true							-- show range on raid unit
showsmooth = true							-- smooth bar animation
showthreat = true							-- show target threat via tpanels left info bar
charportrait = false						-- enable portrait
raidalphaoor = 0.3							-- set alpha opacity when unit is out of range (between 0.0 <-> 1.0)

-- raid layout (healer mode)
gridposX = 18								-- horizontal unit #1 position value
gridposY = -290								-- vertical unit #1 position value
gridposZ = "TOPLEFT"						-- position grid X,Y values from
gridonly = false							-- Replace 10, 15 mans default layout by grid layout 
showsymbols = true 							-- for grid mode only (healer layout only)
gridaggro = true							-- show "aggro" text on grid unit if a player have aggro from a creature.
raidunitdebuffwatch = true					-- show "dangerous unit debuff" in raid on different encounter. (note: PVE SUX LOL)
gridhealthvertical = true					-- set health bar vertically on 25/40 mans layout
showplayerinparty = false					-- show player frame on party layout

-- priest only plugin
ws_show_time = false 						-- show time remaining on weakened soul bar
ws_show_player = true 						-- show a weakened soul debuff on you
if_warning = true							-- innerfire warning icon when not active and in combat

-------------------------------------------------------------------------------------------------------------------------------
-- PVE : MAIN TANK & MAIN ASSIST (this feature is implemented by Dors)
-------------------------------------------------------------------------------------------------------------------------------

t_mt = false								-- enable main tank & main assist frame
t_mt_power = false							-- enable power bar on main assist frame

-------------------------------------------------------------------------------------------------------------------------------
-- ARENA OPTIONS
-------------------------------------------------------------------------------------------------------------------------------

arenatracker = true							-- enemy cooldown tracker in arena (mostly interrupt by default, see tukui.aurawatch.lua and TrakerIDs section)							
t_arena = true								-- enable arena enemy unitframe, Alpha, feel free to complete finnish it if you want

-- set mouseover focus keybind
arenamodifier = "shift" 					-- shift, alt or ctrl
arenamouseButton = "3" 						-- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any

-- set focus with a specific key on mouseover (disabled by default because it override spell key)
if myname == "Tukz" or myname == "Tùkz" then
	focuskey = true
else
	focuskey = false
end

-------------------------------------------------------------------------------------------------------------------------------
-- Chat & Panels config (you can't have more than 8 active panels)
-------------------------------------------------------------------------------------------------------------------------------
-- position legend : [0=disabled] [1=leftbar, left] [2=leftbar, middle] [3=leftbar, right]
-- position legend : [4=rightbar, left] [5=rightbar, middle] [6=rightbar, right]
-- position legend : [7=minimap, left] [8=minimap, right]
-------------------------------------------------------------------------------------------------------------------------------

-- alternative setup on specific character name
if myname == "Tukz" or myname == "Tùkz" or myname == "putyourname" then
	fps_ms = 5	
	mem = 4	
	armor = 2	
	gold = 6	
	wowtime = 8	
	friends = 1	
	guild = 3	
	bags = 0	
	playerap = 0	
	playersp = 7	
	playerhaste = 0	
	dps_text = 0	
	hps_text = 0	
	playerarp = 0	
	
	-- default config on all characters
else 
	fps_ms = 5	
	mem = 4	
	armor = 2	
	gold = 6	
	wowtime = 8	
	friends = 1	
	guild = 3	
	bags = 0	
	playerap = 0	
	playersp = 0	
	playerhaste = 0	
	dps_text = 7	
	hps_text = 0	
	playerarp = 0
end

tfontsize = 12							-- font size of stats 
bar345rightpanels = true				-- show panels background on buttons, right side
time24 = false 							-- set the local or server time in 12h or 24h mode
localtime = true 						-- set local or server time 
tinfowidth = 370						-- set de width of left and right infos bars + chatframe width

-------------------------------------------------------------------------------------------------------------------------------
-- Tukz Action bars options
-------------------------------------------------------------------------------------------------------------------------------

-- number of bars you want to show on the right side?
rightbarnumber = 0 	-- (original layout = 0, 1, 2 or 3, second layout with 4 bars at the bottom = 0 or 1)

-- right bars and pet on mouseover ?
rightbars_on_mouseover = false

-- shapeshift / totem
if select(2, UnitClass("Player")) == "SHAMAN" then
	-- these settings is for totembar only
	move_shapeshift = true
	lock_shapeshift = false
	hide_shapeshift = false -- set to true if you use another totem mod
else
	-- these settings is for stancebar (druid, paladin, warrior, deathknight)
	move_shapeshift = true
	lock_shapeshift = false
	hide_shapeshift = false
end

-- button skin ?
buttonskin = true

-- hide hot key?
hide_hotkey = true

-------------------------------------------------------------------------------------------------------------------------------
-- Tooltip options
-------------------------------------------------------------------------------------------------------------------------------

cursortooltip = false					-- tooltip on cursor instead of fix position
hide_units = false						-- always hide only units (npc, players, etc)
hide_units_combat = true				-- hide units if in combat (useful when cursortooltip is active)
hide_all_tooltips = false 				-- i don't recommend enabling this, this was a only request for a friend
hide_uf_tooltip = true					-- hide tooltip on unitframe cause it sux!

-- setting for fixed position
ttposX = -32 							-- LEFT(-) and RIGHT(+) position via posZ anchor
ttposY = 48 							--  UP(+) and DOWN(-) position via posZ anchor
ttposZ = "BOTTOMRIGHT" 					-- align to

-------------------------------------------------------------------------------------------------------------------------------
-- Minimap options
-------------------------------------------------------------------------------------------------------------------------------

minimapposition = "TOPRIGHT"
minimapposition_x = -22
minimapposition_y = -22

-------------------------------------------------------------------------------------------------------------------------------
-- Chat options
-------------------------------------------------------------------------------------------------------------------------------

ChatTime = false						-- enable time on chat msg
ChatFontSize = 12						-- set the default fontsize of chat

-------------------------------------------------------------------------------------------------------------------------------
-- General options
-------------------------------------------------------------------------------------------------------------------------------
PixelPerfect = true           			-- enable pixel perfect on Tukui! Warning: if set false, tukui borders can look shitty!
LoginMsg = true               			-- enable login msg of tukui
AutoRepairGuildFund = false				-- ninja gold from guild bank for repair.
AutoLFDpress = true						-- accept automaticaly LFD invitation


