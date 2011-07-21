local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

DB["media"] = {
	-- fonts
	["font"] = "ElvUI Font", -- general font of Elvui
	["uffont"] = "ElvUI Font", -- general font of unitframes
	["dmgfont"] = "ElvUI Combat", -- general font of dmg / sct
		
	-- textures
	["normTex"] = "ElvUI Norm", -- texture used for Elvui healthbar/powerbar/etc
	["glossTex"] = "ElvUI Gloss",
	["glowTex"] = "ElvUI GlowBorder",
	["blank"] = "ElvUI Blank",
	
	["raidicons"] = [[Interface\AddOns\ElvUI\media\textures\raidicons.blp]], -- new raid icon textures by hankthetank
	
	-- sound
	["whisper"] = "ElvUI Whisper",
	["warning"] = "ElvUI Warning",
	["glossyTexture"] = false,	-- Use a glossy texture for all frames
	
	--colors
	["bordercolor"] = { r = .23,g = .23,b = .23 }, -- border color of Elvui panels
	["backdropcolor"] = { r = .07,g = .07,b = .07 }, -- background color of Elvui panels
	["backdropfadecolor"] = { r = .07,g = .07,b = .07, a = 0.9 }, --this is always the same as the backdrop color with an alpha of 0.8, see colors.lua
	["valuecolor"] = {r = 23/255,g = 132/255,b = 209/255}, -- color for values of datatexts
}


DB["general"] = {
	["autoscale"] = true,                  -- mainly enabled for users that don't want to mess with the config file
	["uiscale"] = 0.78,                    -- set your value (between 0.64 and 1) of your uiscale if autoscale is off
	["multisampleprotect"] = true,         -- i don't recommend this because of shitty border but, voila!
	["classcolortheme"] = false,			--class colored theme for panels
	["fontscale"] = 12,					--Master font
	["resolutionoverride"] = "NONE",		--override lowversion (Low, High)
	["layoutoverride"] = "NONE",			--ovverride layout (DPS, Healer)
	["sharpborders"] = true,
	["upperpanel"] = false,
	["lowerpanel"] = false,
	["loginmessage"] = true,
}

DB["skin"] = {
	["enable"] = true,
		["bags"] = true,
		["reforge"] = true,
		["calendar"] = true,
		["achievement"] = true,
		["lfguild"] = true,
		["inspect"] = true,
		["binding"] = true,
		["gbank"] = true,
		["archaeology"] = true,
		["guildcontrol"] = true,
		["guild"] = true,
		["tradeskill"] = true,
		["raid"] = true,
		["talent"] = true,
		["glyph"] = true,
		["auctionhouse"] = true,
		["barber"] = true,
		["macro"] = true,
		["debug"] = true,
		["trainer"] = true,
		["socket"] = true,
		["achievement_popup"] = true,
		["bgscore"] = true,
		["merchant"] = true,
		["mail"] = true,
		["help"] = true,
		["trade"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["worldmap"] = true,
		["taxi"] = true,
		["lfd"] = true,
		["quest"] = true,
		["petition"] = true,
		["dressingroom"] = true,
		["pvp"] = true,
		["nonraid"] = true,
		["friends"] = true,
		["spellbook"] = true,
		["character"] = true,
		["misc"] = true,
		["lfr"] = true,
		["tabard"] = true,
		["guildregistrar"] = true,
		["timemanager"] = true,
		["encounterjournal"] = true,
	["recount"] = true,
	["skada"] = true,
	["omen"] = true,
	["kle"] = true,
	["dxe"] = true,
	["dbm"] = true,
	["ace3"] = true,
	["bigwigs"] = true,
	["clcret"] = true,
	["clcprot"] = true,
	["hookkleright"] = false,			-- force KLE's top bar anchor to be hooked onto the right chat window
	["hookbwright"] = false,			-- force BigWig's bar anchor to be hooked onto the right chat window
	["hookdxeright"] = false,
	["embedright"] = "NONE",				-- Addon to embed to the right frame ("Omen", "Recount", "Skada")
	["embedrighttoggle"] = false,
}

DB["unitframes"] = {
	-- general options
	["enable"] = true,                     -- do i really need to explain this?
	["fontsize"] = 12,						-- default font height for unitframes
	["lowThreshold"] = 20,                 -- global low threshold, for low mana warning.
	["targetpowerplayeronly"] = true,         -- enable power text on pvp target only
	["showfocustarget"] = false,           -- show focus's target
	["pettarget"] = true,					-- show player's pet's target (DPS)
	["showtotalhpmp"] = false,             -- change the display of info text on player and target with XXXX/Total.
	["showsmooth"] = true,                 -- enable smooth bar
	["charportrait"] = false,              -- enable character portrait
	["charportraithealth"] = false,			-- portrait overlay healthbar
	["classcolor"] = false,                  -- color unitframes by class
	["classcolorpower"] = false,
	["classcolorbackdrop"] = false,
	["healthcolor"] = DB["media"].bordercolor, --color of the unitframe
	["healthcolorbyvalue"] = true,			-- color health by current health remaining
	["healthbackdrop"] = false,				-- enable using custom healthbackdrop color
	["healthbackdropcolor"] = DB["media"].backdropcolor,
	["combatfeedback"] = false,             -- enable combattext on player and target.
	["debuffhighlight"] = true,				--highlight frame with the debuff color if the frame is dispellable
	["classbar"] = true,                    -- enable runebar/totembar/holypowerbar/soulshardbar/eclipsebar
	["combat"] = false,						-- only show main unitframes when in combat/havetarget/or mouseover
	["mini_powerbar"] = true,
	["mini_classbar"] = true,
	["powerbar_offset"] = 0,
	["showboss"] = true,                   -- enable boss unit frames for PVELOL encounters.
	["arena"] = true,                 -- enable elvui arena unitframes (requirement : Elvui unitframes enabled)	
	["swing"] = false,
	["displayaggro"] = true,
	["powerbar_height"] = 10,
	["classbar_height"] = 10,
	
	--frame sizes
	["playtarwidth"] = 275,					--width of player/target frame
	["playtarheight"] = 55,					--height of player/target frame
	["smallwidth"] = 130,					--Width of TargetTarget, Focus, FocusTarget, Player's Pet frames
	["smallheight"] = 35,					--Height of TargetTarget, Focus, FocusTarget, Player's Pet frames
	["arenabosswidth"] = 212,				--Width of Arena/Boss Frames
	["arenabossheight"] = 43,				--Height of Arena/Boss Frames
	["assisttankwidth"] = 120,				--Width of MainTank/MainAssist frames
	["assisttankheight"] = 27,				--Height of MainTank/MainAssist frames
	
	--auras
	["auratimer"] = true,                  -- enable timers on buffs/debuffs
	["auratextscale"] = 11,                -- the font size of buffs/debuffs timers on unitframes
	["playerbuffs"] = false,
	["playerdebuffs"] = true,
	["targetbuffs"] = true,
	["targetdebuffs"] = true,
	["arenabuffs"] = true,
	["bossbuffs"] = true,
	["arenadebuffs"] = true,
	["bossdebuffs"] = true,
	["playershowonlydebuffs"] = true, 		-- only show the players debuffs over the player frame, not buffs (playerauras must be true)
	["playerdebuffsonly"] = true,			-- show the players debuffs on target, and any debuff in the whitelist (see debuffFilter.lua)
	["totdebuffs"] = true,                -- enable tot debuffs (high reso only)
	["focusdebuffs"] = true,              -- enable focus debuffs 
	["playeraurasperrow"] = 8,				-- buffs/debuffs per row on player/target frames
	["targetaurasperrow"] = 8,
	["smallaurasperrow"] = 5,				-- debuffs per row on targettarget/focus frames
	["playernumbuffrows"] = 1,
	["playernumdebuffrows"] = 1,	
	["targetnumbuffrows"] = 1,
	["targetnumdebuffrows"] = 1,
	
	
	--castbar
	["unitcastbar"] = true, -- enable Elvui castbar
	["cblatency"] = false, -- enable castbar latency
	["cbicons"] = true, -- enable icons on castbar
	["cbticks"] = true,
	["castplayerwidth"] = 276,
	["castplayerheight"] = 20,
	["casttargetwidth"] = 276,
	["casttargetheight"] = 20,
	["castfocuswidth"] = 276,
	["castfocusheight"] = 20,
	["castbarcolor"] = DB["media"].bordercolor, -- Color of player castbar
	["nointerruptcolor"] = {r = 0.78, g = 0.25, b = 0.25}, -- Color of target castbar
	
	["POWER_MANA"] = {r = 0.31, g = 0.45, b = 0.63},
	["POWER_RAGE"] = {r = 0.78, g = 0.25, b = 0.25},
	["POWER_FOCUS"] = {r = 0.71, g = 0.43, b = 0.27},
	["POWER_ENERGY"] = {r = 0.65, g = 0.63, b = 0.35},
	["POWER_RUNICPOWER"] = {r = 0, g = 0.82, b = 1},	
}

DB["raidframes"] = {
	["enable"] = true,						-- enable raid frames
	["fontsize"] = 12,						-- default font height for raidframes
	["scale"] = 1,							-- for smaller use a number less than one (0.73), for higher use a number larger than one
	["showrange"] = true,                  -- show range opacity on raidframes
	["healcomm"] = true,                  -- enable healcomm4 support on healer layout.
	["raidalphaoor"] = 0.3,                -- alpha of raidframes when unit is out of range
	["gridhealthvertical"] = true,         -- enable vertical grow on health bar for healer layout
	["showplayerinparty"] = true,          -- show my player frame in party
	["maintank"] = true,                  -- enable maintank
	["mainassist"] = true,                -- enable mainassist
	["partypets"] = true,					-- enable party pets for the healer layout
	["disableblizz"] = true,				-- fuck fuck fuckin fuck
	["healthdeficit"] = false,			-- show the health deficit on the raidframes
	["griddps"] = true,					-- show dps layout in grid style
	["role"] = false,					--display role on raidframe
	["partytarget"]	= false,				--display party members targets (DPS ONLY)
	["mouseglow"] = true,					--glow the class/reaction color of the unit that you mouseover
	["raidunitbuffwatch"] = true,       -- track important spell to watch in pve for grid mode.
	["buffindicatorsize"] = 6,				-- size of the buff indicator on raid/party frames
	["buffindicatorcoloricons"] = true,
	["debuffs"] = true,
	["displayaggro"] = true,
	["mini_powerbar"] = true,
	["gridonly"] = false,
}

DB["classtimer"] = {
	["enable"] = true,
	["bar_height"] = 17,
	["bar_spacing"] = 5,
	["icon_position"] = 2, -- 0 = left, 1 = right, 2 = Outside left, 3 = Outside Right
	["layout"] = 4, --1 - both player and target auras in one frame right above player frame, 2 - player and target auras separated into two frames above player frame, 3 - player, target and trinket auras separated into three frames above player frame, 4 - player and trinket auras are shown above player frame and target auras are shown above target frame, 5 - Everything above player frame, no target debuffs.
	["showspark"] = true,
	["cast_suparator"] = true,
	
	["classcolor"] = false,
	["buffcolor"] = DB["media"].bordercolor, -- if classcolor isnt true
	["debuffcolor"] = {r = 0.78, g = 0.25, b = 0.25},
	["proccolor"] = {r = 0.84, g = 0.75, b = 0.65},
}

DB["actionbar"] = {
	["enable"] = true,                     -- enable elvui action bars
	["hotkey"] = true,                     -- enable hotkey display because it was a lot requested
	["rightbarmouseover"] = false,         -- enable right bars on mouse over
	["shapeshiftmouseover"] = false,       -- enable shapeshift or totembar on mouseover
	["hideshapeshift"] = false,            -- hide shapeshift or totembar because it was a lot requested.
	["showgrid"] = true,                   -- show grid on empty button
	["bottompetbar"] = false,				-- position petbar below the actionbars instead of the right side
	["buttonsize"] = 30,					--size of action buttons
	["buttonspacing"] = 4,					--spacing of action buttons
	["petbuttonsize"] = 30,					--size of pet/stance buttons
	["swaptopbottombar"] = false,			--swap the main actionbar position with the bottom actionbar
	["macrotext"] = false,					--show macro text on actionbuttons
	["verticalstance"] = false,				--make stance bar vertical
	["microbar"] = false,					--enable microbar display
	["mousemicro"] = false,					--only show microbar on mouseover
	
	["enablecd"] = true,                     -- do i really need to explain this?
	["treshold"] = 3,                      -- show decimal under X seconds and text turn red
	["expiringcolor"] = { r = 1, g = 0, b = 0 },		--color of expiring seconds turns to 
	["secondscolor"] = { r = 1, g = 1, b = 0 },			--seconds color
	["minutescolor"] = { r = 1, g = 1, b = 1 },			-- minutes color
	["hourscolor"] = { r = 0.4, g = 1, b = 1 },			-- hours color
	["dayscolor"] = { r = 0.4, g = 0.4, b = 1 },		-- days color	
}

DB["nameplate"] = {
	["enable"] = true,                     -- enable nice skinned nameplates that fit into Elvui
	["showlevel"] = true,
	["width"] = 105,
	["showhealth"] = false,					-- show health text on nameplate
	["enhancethreat"] = true,				-- threat features based on if your a tank or not
	["combat"] = false,					--only show enemy nameplates in-combat.
	["goodcolor"] = {r = 75/255,  g = 175/255, b = 76/255},			--good threat color (tank shows this with threat, everyone else without)
	["badcolor"] = {r = 0.78, g = 0.25, b = 0.25},			--bad threat color (opposite of above)
	["goodtransitioncolor"] = {r = 218/255, g = 197/255, b = 92/255},	--threat color when gaining threat
	["badtransitioncolor"] = {r = 240/255, g = 154/255, b = 17/255}, 
	["trackauras"] = false,		--track players debuffs only (debuff list derived from classtimer spell list)
	["trackccauras"] = true,			--track all CC debuffs
}

DB["datatext"] = {
	["stat1"] = 1,						   -- Stat Based on your Role (Avoidance-Tank, AP-Melee, SP/HP-Caster)
	["dur"] = 2,                           -- show your equipment durability on panels.
	["stat2"] = 3, 						   -- Stat Based on your Role (Armor-Tank, Crit-Melee, Crit-Caster)
	["system"] = 4,                        -- show fps and ms on panels, and total addon memory in tooltip
	["wowtime"] = 5,                       -- show time on panels
	["gold"] = 6,                          -- show your current gold on panels
	["guild"] = 7,                         -- show number on guildmate connected on panels
	["friends"] = 8,                       -- show number of friends connected.
	["calltoarms"] = 0,
	["bags"] = 0,							-- show ammount of bag space available
	["dps_text"] = 0,						-- show current dps
	["hps_text"] = 0,						-- show current hps
	["currency"] = 0,						-- show watched items in backpack
	["specswitch"] = 0,
	["hit"] = 0,
	["expertise"] = 0,
	["haste"] = 0,
	["mastery"] = 0,
	["crit"] = 0,
	["manaregen"] = 0,
	["masteryspell"] = false,	
	["battleground"] = true,               -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	["time24"] = false,                     -- set time to 24h format.
	["localtime"] = true,                 -- set time to local time instead of server time.
	["fontsize"] = 12,                     -- font size for panels.
	["classcolor"] = false,
}

DB["chat"] = {
	["enable"] = true,                     -- blah
	["style"] = "ElvUI",
	["whispersound"] = true,               -- play a sound when receiving whisper
	["showbackdrop"] = true,				-- show a backdrop on the chat panels
	["chatwidth"] = 348,					-- width of chat frame
	["chatheight"] = 111,					-- height of chat frame
	["fadeoutofuse"] = true,				-- fade chat text when out of use
	["sticky"] = true,						-- when opening the chat edit box resort to previous channel
	["combathide"] = "NONE",			-- Set to "Left", "Right", "Both", or "NONE"
	["bubbles"] = true,							--skin blizzard chat bubbles
}

DB["tooltip"] = {
	["enable"] = true,                     -- true to enable this mod, false to disable
	["hidecombat"] = true,                -- hide bottom-right tooltip when in combat
	["hidecombatraid"] = true,				-- only hide in combat in a raid instance
	["hidebuttons"] = false,               -- always hide action bar buttons tooltip.
	["hideuf"] = false,                    -- hide tooltip on unitframes
	["cursor"] = false,                    -- show anchored to cursor
	["colorreaction"] = false,				-- always color border of tooltip by unit reaction
	["itemid"] = true,						--display itemid on item tooltips 
	["whotargetting"] = true,				--show who is targetting the unit (in raid or party)
}

DB["others"] = {
	["pvpautorelease"] = false,            -- enable auto-release in bg or wintergrasp.
	["errorenable"] = true,                     -- true to enable this mod, false to disable
	["autoacceptinv"] = true,                 -- auto-accept invite from guildmate and friends.
	["enablebag"] = true,                     -- enable an all in one bag mod that fit Elvui perfectly
	["bagbar"] = false,
	["bagbardirection"] = "VERTICAL",
	["bagbarmouseover"] = true,

	["lootframe"] = true,                  -- reskin the loot frame to fit Elvui
	["rolllootframe"] = true,              -- reskin the roll frame to fit Elvui
	["autogreed"] = true,                  -- auto-dez or auto-greed item at max level.	
	["sellgrays"] = true,                  -- automaticly sell grays?
	["autorepair"] = true,                 -- automaticly repair?
	
	["buffreminder"] = true,                     -- this is now the new innerfire warning script for all armor/aspect class.
	["remindersound"] = true,                      -- enable warning sound notification for reminder.
	["raidbuffreminder"] = true,			-- buffbar below the minimap, important missing buffs	
	["announceinterrupt"] = "PARTY",			-- announce in party/raid when you interrupt
	["showthreat"] = true,                 -- enable the threat bar anchored to info right panel.
	["minimapauras"] = true,				-- enable minimap auras		
}