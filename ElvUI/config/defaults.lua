local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


C["media"] = {
	-- fonts
	["font"] = [=[Interface\Addons\ElvUI\media\fonts\PT_Sans_Narrow.ttf]=], -- general font of Elvui
	["uffont"] = [[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], -- general font of unitframes
	["dmgfont"] = [[Interface\AddOns\ElvUI\media\fonts\Action_Man.ttf]], -- general font of dmg / sct
	
	-- textures
	["normTex"] = [[Interface\AddOns\ElvUI\media\textures\normTex]], -- texture used for Elvui healthbar/powerbar/etc
	["glowTex"] = [[Interface\AddOns\ElvUI\media\textures\glowTex]], -- the glow text around some frame.
	["blank"] = [[Interface\BUTTONS\WHITE8X8]], -- the main texture for all borders/panels
	["bordercolor"] = { .3,.3,.3,1 }, -- border color of Elvui panels
	["altbordercolor"] = { .3,.3,.3,1 }, -- alternative border color, mainly for unitframes text panels.
	["backdropcolor"] = { .1,.1,.1,1 }, -- background color of Elvui panels
	["backdropfadecolor"] = { .1,.1,.1,0.8 }, --this is always the same as the backdrop color with an alpha of 0.8, see colors.lua
	["valuecolor"] = {23/255,132/255,209/255}, -- color for values of datatexts
	["raidicons"] = [[Interface\AddOns\ElvUI\media\textures\raidicons.blp]], -- new raid icon textures by hankthetank
	
	-- sound
	["whisper"] = [[Interface\AddOns\ElvUI\media\sounds\whisper.mp3]],
	["warning"] = [[Interface\AddOns\ElvUI\media\sounds\warning.mp3]],
	["glossyTexture"] = true,	-- Use a glossy texture for all frames
}

C["general"] = {
	["autoscale"] = true,                  -- mainly enabled for users that don't want to mess with the config file
	["uiscale"] = 0.78,                    -- set your value (between 0.64 and 1) of your uiscale if autoscale is off
	["multisampleprotect"] = true,         -- i don't recommend this because of shitty border but, voila!
	["classcolortheme"] = false,			--class colored theme for panels
	["fontscale"] = 12,					--Master font
}

C["skin"] = {	--Skin addons by Darth Android
	["recount"] = true,
	["skada"] = true,
	["omen"] = true,
	["kle"] = true,
	["hookkleright"] = true,			-- force KLE's top bar anchor to be hooked onto the right chat window
	["embedright"] = "NONE",				-- Addon to embed to the right frame ("Omen", "Recount", "Skada")
}

C["unitframes"] = {
	-- general options
	["enable"] = true,                     -- do i really need to explain this?
	["fontsize"] = 12,						-- default font height for unitframes
	["lowThreshold"] = 20,                 -- global low threshold, for low mana warning.
	["targetpowerplayeronly"] = true,         -- enable power text on pvp target only
	["showfocustarget"] = false,           -- show focus's target
	["pettarget"] = true,					-- show player's pet's target (DPS)
	["showtotalhpmp"] = false,             -- change the display of info text on player and target with XXXX/Total.
	["showsmooth"] = true,                 -- enable smooth bar
	["showthreat"] = true,                 -- enable the threat bar anchored to info left panel.
	["charportrait"] = false,              -- enable character portrait
	["classcolor"] = false,                  -- color unitframes by class
	["healthcolor"] = C["media"].bordercolor, --color of the unitfram
	["healthbackdropcolor"] = C["media"].backdropcolor, --backdropcolor of the unitframe
	["healthcolorbyvalue"] = true,			-- color health by current health remaining
	["combatfeedback"] = false,             -- enable combattext on player and target.
	["playeraggro"] = true,                -- color player border to red if you have aggro on current target.
	["positionbychar"] = true,             -- save X, Y position with /uf (movable frame) per character instead of per account.
	["swingbar"] = false,					--enables swingbar (dps layout only)
	["debuffhighlight"] = true,				--highlight frame with the debuff color if the frame is dispellable
	["showsymbols"] = true,	               -- show symbol.
	["aggro"] = true,                      -- show aggro
	["poweroffset"] = 0,					--powerbar offset
	["classbar"] = true,                    -- enable runebar/totembar/holypowerbar/soulshardbar/eclipsebar
	["combat"] = false,						-- only show main unitframes when in combat/havetarget/or mouseover
}

C["framesizes"] = {
	["playtarwidth"] = 220,					--width of player/target frame
	["playtarheight"] = 28,					--height of player/target frame
	["smallwidth"] = 100,					--Width of TargetTarget, Focus, FocusTarget, Player's Pet frames
	["smallheight"] = 23,					--Height of TargetTarget, Focus, FocusTarget, Player's Pet frames
	["arenabosswidth"] = 180,				--Width of Arena/Boss Frames
	["arenabossheight"] = 28,				--Height of Arena/Boss Frames
	["assisttankwidth"] = 100,				--Width of MainTank/MainAssist frames
	["assisttankheight"] = 20,				--Height of MainTank/MainAssist frames
}

C["raidframes"] = {
	["enable"] = true,						-- enable raid frames
	["fontsize"] = 12,						-- default font height for raidframes
	["scale"] = 1,							-- for smaller use a number less than one (0.73), for higher use a number larger than one
	["showrange"] = true,                  -- show range opacity on raidframes
	["hidenonmana"] = true,					-- hide non mana on party/raid frames
	["healcomm"] = true,                  -- enable healcomm4 support on healer layout.
	["raidalphaoor"] = 0.3,                -- alpha of raidframes when unit is out of range
	["gridonly"] = false,                  -- enable grid only mode for all raid layout. TEMP
	["gridhealthvertical"] = true,         -- enable vertical grow on health bar for healer layout
	["showplayerinparty"] = true,          -- show my player frame in party
	["maintank"] = true,                  -- enable maintank
	["mainassist"] = true,                -- enable mainassist
	["showboss"] = true,                   -- enable boss unit frames for PVELOL encounters.
	["partypets"] = true,					-- enable party pets for the healer layout
	["disableblizz"] = true,				-- fuck fuck fuckin fuck
	["healthdeficit"] = false,			-- show the health deficit on the raidframes
	["griddps"] = true,					-- show dps layout in grid style
	["role"] = false,					--display role on raidframe
	["partytarget"]	= false,				--display party members targets (DPS ONLY)
}

C["auras"] = {
	["auratimer"] = true,                  -- enable timers on buffs/debuffs
	["auratextscale"] = 11,                -- the font size of buffs/debuffs timers on unitframes
	["playerauras"] = true,               -- enable auras
	["playershowonlydebuffs"] = true, 		-- only show the players debuffs over the player frame, not buffs (playerauras must be true)
	["playerdebuffsonly"] = true,			-- show the players debuffs on target, and any debuff in the whitelist (see debuffFilter.lua)
	["targetauras"] = true,                -- enable auras on target unit frame
	["minimapauras"] = true,				-- enable minimap auras
	["arenadebuffs"] = true, 				-- enable debuff filter for arena frames
	["raidunitbuffwatch"] = true,       -- track important spell to watch in pve for grid mode.
	["totdebuffs"] = true,                -- enable tot debuffs (high reso only)
	["focusdebuffs"] = true,              -- enable focus debuffs 
	["playtarbuffperrow"] = 8,				-- buffs/debuffs per row on player/target frames
	["smallbuffperrow"] = 4,				-- debuffs per row on targettarget/focus frames
	["buffindicatorsize"] = 6,				-- size of the buff indicator on raid/party frames
}

C["castbar"] = {
	["unitcastbar"] = true, -- enable Elvui castbar
		["cblatency"] = false, -- enable castbar latency
		["cbicons"] = true, -- enable icons on castbar
		["castermode"] = false, -- makes castbar larger and puts it above the actionbar frame
		["classcolor"] = false, -- classcolor
		["castbarcolor"] = { 0.3, 0.3, 0.3, 1 }, -- Color of player castbar
		["nointerruptcolor"] = { 0.78, 0.25, 0.25, 0.5 }, -- Color of target castbar
}

C["classtimer"] = {
	["enable"] = true,
		["bar_height"] = 17,
		["bar_spacing"] = 1,
		["icon_position"] = 2, -- 0 = left, 1 = right, 2 = Outside left, 3 = Outside Right
		["layout"] = 4, --1 - both player and target auras in one frame right above player frame, 2 - player and target auras separated into two frames above player frame, 3 - player, target and trinket auras separated into three frames above player frame, 4 - player and trinket auras are shown above player frame and target auras are shown above target frame, 5 - Everything above player frame, no target debuffs.
		["showspark"] = true,
		["cast_suparator"] = true,
		
		["classcolor"] = false,
		["buffcolor"] = {0.3, 0.3, 0.3, 1}, -- if classcolor isnt true
		["debuffcolor"] = {0.78, 0.25, 0.25, 1},
		["proccolor"] = {0.84, 0.75, 0.65, 1},
}

C["arena"] = {
	["unitframes"] = true,                 -- enable elvui arena unitframes (requirement : Elvui unitframes enabled)
	["spelltracker"] = false,               -- enable elvui enemy spell tracker (an afflicted3 or interruptbar alternative)
}

C["actionbar"] = {
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
}

C["nameplate"] = {
	["enable"] = true,                     -- enable nice skinned nameplates that fit into Elvui
		["showhealth"] = true,					-- show health text on nameplate
		["enhancethreat"] = true,				-- threat features based on if your a tank or not
		["overlap"] = false,				--allow nameplates to overlap
		["combat"] = false,					--only show enemy nameplates in-combat.
		["goodcolor"] = {75/255,  175/255, 76/255},			--good threat color (tank shows this with threat, everyone else without)
		["badcolor"] = {0.78, 0.25, 0.25},			--bad threat color (opposite of above)
		["transitioncolor"] = {218/255, 197/255, 92/255},	--threat color when gaining threat
		["trackauras"] = false,		--track players debuffs only (debuff list derived from classtimer spell list)
		["trackccauras"] = false,			--track all CC debuffs
}

C["loot"] = {
	["lootframe"] = true,                  -- reskin the loot frame to fit Elvui
	["rolllootframe"] = true,              -- reskin the roll frame to fit Elvui
	["autogreed"] = true,                  -- auto-dez or auto-greed item at max level.
}

C["cooldown"] = {
	["enable"] = true,                     -- do i really need to explain this?
		["treshold"] = 3,                      -- show decimal under X seconds and text turn red
		["expiringcolor"] = { 1, 0, 0 },		--color of expiring seconds turns to 
		["secondscolor"] = { 1, 1, 0 },			--seconds color
		["minutescolor"] = { 1, 1, 1 },			-- minutes color
		["hourscolor"] = { 0.4, 1, 1 },			-- hours color
		["dayscolor"] = { 0.4, 0.4, 1 },		-- days color
}

C["datatext"] = {
	["stat1"] = 1,						   -- Stat Based on your Role (Avoidance-Tank, AP-Melee, SP/HP-Caster)
	["dur"] = 2,                           -- show your equipment durability on panels.
	["stat2"] = 3, 						   -- Stat Based on your Role (Armor-Tank, Crit-Melee, Crit-Caster)
	["system"] = 4,                        -- show fps and ms on panels, and total addon memory in tooltip
	["wowtime"] = 5,                       -- show time on panels
	["gold"] = 6,                          -- show your current gold on panels
	["guild"] = 7,                         -- show number on guildmate connected on panels
	["friends"] = 8,                       -- show number of friends connected.
	["bags"] = 0,							-- show ammount of bag space available
	["dps_text"] = 0,						-- show current dps
	["hps_text"] = 0,						-- show current hps
	["currency"] = 0,						-- show watched items in backpack
	["specswitch"] = 0,
	["battleground"] = true,               -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	["time24"] = false,                     -- set time to 24h format.
	["localtime"] = true,                 -- set time to local time instead of server time.
	["fontsize"] = 12,                     -- font size for panels.
}

C["chat"] = {
	["enable"] = true,                     -- blah
		["whispersound"] = true,               -- play a sound when receiving whisper
		["showbackdrop"] = true,				-- show a backdrop on the chat panels
		["chatwidth"] = 348,					-- width of chat frame
		["chatheight"] = 111,					-- height of chat frame
		["fadeoutofuse"] = true,				-- fade chat text when out of use
		["sticky"] = true,						-- when opening the chat edit box resort to previous channel
		["combathide"] = "NONE",			-- Set to "Left", "Right", "Both", or "NONE"
	["bubbles"] = true,							--skin blizzard chat bubbles
}

C["tooltip"] = {
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

C["buffreminder"] = {
	["enable"] = true,                     -- this is now the new innerfire warning script for all armor/aspect class.
		["sound"] = true,                      -- enable warning sound notification for reminder.
		["raidbuffreminder"] = true,			-- buffbar below the minimap, important missing buffs
}

C["others"] = {
	["pvpautorelease"] = false,            -- enable auto-release in bg or wintergrasp.
	["sellgrays"] = true,                  -- automaticly sell grays?
	["autorepair"] = true,                 -- automaticly repair?
	["errorenable"] = true,                     -- true to enable this mod, false to disable
	["autoacceptinv"] = true,                 -- auto-accept invite from guildmate and friends.
	["enablemap"] = true,                     -- reskin the map to fit Elvui
	["enablebag"] = true,                     -- enable an all in one bag mod that fit Elvui perfectly
}

C["debug"] = {--don't recommend turning this on
	["enabled"] = false,				
	["events"] = false,
}

C["media"].normTex2 = C["media"].normTex