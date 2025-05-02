local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- This used to be standalone and is now merged into G.unitframe.aurafilters.Whitelist
G.unitframe.aurafilters.PlayerBuffs = nil

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
		[47476] = List(2),	-- Strangulate
		[49203] = List(2),	-- Hungering Cold
	-- Druid
		[339] = List(2),	-- Entangling Roots
		[2637] = List(2),	-- Hibernate
		[33786] = List(2),	-- Cyclone
		[78675] = List(2),	-- Solar Beam
		[80964] = List(2),	-- Skull Bash
	-- Hunter
		[1513] = List(2),	-- Scare Beast
		[3355] = List(2),	-- Freezing Trap Effect
		[19503] = List(2),	-- Scatter Shot
		[34490] = List(2),	-- Silence Shot
		[19306] = List(2),	-- Counterattack
		[19386] = List(2),	-- Wyvern Sting
		[24394] = List(2),	-- Intimidation
	-- Mage
		[122] = List(2),	-- Frost Nova
		[18469] = List(2),	-- Silenced - Improved Counterspell
		[31661] = List(2),	-- Dragon's Breath
		[55080] = List(2),	-- Shattered Barrier
		[61305] = List(2),	-- Polymorph
		[82691] = List(2),	-- Ring of Frost
	-- Paladin
		[853] = List(2),	-- Hammer of Justice
		[2812] = List(2),	-- Holy Wrath
		[10326] = List(2),	-- Turn Evil
		[20066] = List(2),	-- Repentance
	-- Priest
		[605] = List(2),	-- Mind Control
		[8122] = List(2),	-- Psychic Scream
		[9484] = List(2),	-- Shackle Undead
		[15487] = List(2),	-- Silence
		[64044] = List(2),	-- Psychic Horror
		[64058] = List(2),	-- Psychic Horror (Disarm)
	-- Rogue
		[408] = List(2),	-- Kidney Shot
		[1776] = List(2),	-- Gouge
		[1833] = List(2),	-- Cheap Shot
		[2094] = List(2),	-- Blind
		[6770] = List(2),	-- Sap
		[1330] = List(2),	-- Garrote - Silence
		[18425] = List(2),	-- Silenced - Improved Kick (Rank 1)
		[86759] = List(2),	-- Silenced - Improved Kick (Rank 2)
	-- Shaman
		[3600] = List(2),	-- Earthbind
		[8056] = List(2),	-- Frost Shock
		[39796] = List(2),	-- Stoneclaw Stun
		[51514] = List(2),	-- Hex
		[63685] = List(2),	-- Freeze
	-- Warlock
		[710] = List(2),	-- Banish
		[5484] = List(2),	-- Howl of Terror
		[5782] = List(2),	-- Fear
		[6358] = List(2),	-- Seduction
		[6789] = List(2),	-- Death Coil
		[30283] = List(2),	-- Shadowfury
		[54786] = List(2),	-- Demon Leap
		[89605] = List(2),	-- Aura of Foreboding
	-- Warrior
		[12809] = List(2),	-- Concussion Blow
		[20511] = List(2),	-- Intimidating Shout
		[85388] = List(2),	-- Throwdown
		[46968] = List(2),	-- Shockwave
	-- Racial
		[20549]	= List(2), -- War Stomp
		[28730]	= List(2), -- Arcane Torrent (Mana)
		[25046]	= List(2), -- Arcane Torrent (Energy)
		[50613]	= List(2), -- Arcane Torrent (Runic Power)
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Mage
		[45438] = List(5),	-- Ice Block
	-- Death Knight
		[48707] = List(5),	-- Anti-Magic Shell
		[48792] = List(),	-- Icebound Fortitude
		[49039] = List(),	-- Lichborne
		[50461] = List(),	-- Anti-Magic Zone
		[55233] = List(),	-- Vampiric Blood
		[81256] = List(4),	-- Dancing Rune Weapon
	-- Priest
		[33206] = List(3),	-- Pain Suppression
		[47585] = List(5),	-- Dispersion
		[47788] = List(),	-- Guardian Spirit
		[62618] = List(),	-- Power Word: Barrier
	-- Druid
		[22812] = List(2),	-- Barkskin
		[61336] = List(),	-- Survival Instinct
	-- Hunter
		[19263] = List(5),	-- Deterrence
		[53480] = List(),	-- Roar of sacrifice
	-- Rogue
		[1966] = List(),	-- Feint
		[5277] = List(5),	-- Evasion
		[31224] = List(),	-- Cloak of Shadows
		[45182] = List(),	-- Cheating Death
		[74001] = List(),	-- Combat Readiness
	-- Shaman
		[30823] = List(),	-- Shamanistic Rage
		[98007] = List(),	-- Spirit Link Totem
	-- Paladin
		[498] = List(2),	-- Divine protection
		[642] = List(5),	-- Divine shield
		[1022] = List(5),	-- Hand Protection
		[1038] = List(5),	-- Hand of Salvation
		[1044] = List(5),	-- Hand of Freedom
		[6940] = List(),	-- Hand of Sacrifice
		[31821] = List(3),	-- Aura Mastery
		[70940] = List(3),	-- Divine Guardian
	-- Warrior
		[871] = List(3),	-- Shield Wall
		[12976] = List(),	-- Last Stand
		[55694] = List(),	-- Enraged Regeneration
		[97463] = List(),	-- Rallying Cry
	},
}

-- Buffs that we don't really need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	-- General
		[186403] = List(),	-- Sign of Battle
		[377749] = List(),	-- Joyous Journeys
		[6788] = List(),	-- Weakended Soul
		[8326] = List(),	-- Ghost
		[8733] = List(),	-- Blessing of Blackfathom
		[15007] = List(),	-- Resurrection Sickness
		[23445] = List(),	-- Evil Twin
		[24755] = List(),	-- Trick or Treat
		[25163] = List(),	-- Oozeling Disgusting Aura
		[25771] = List(),	-- Forbearance
		[26013] = List(),	-- Deserter
		[36032] = List(),	-- Arcane Blast
		[41425] = List(),	-- Hypothermia
		[46221] = List(),	-- Animal Blood
		[55711] = List(),	-- Weakened Heart
		[57723] = List(),	-- Exhaustion
		[57724] = List(),	-- Sated
		[58539] = List(),	-- Watchers Corpse
		[69438] = List(),	-- Sample Satisfaction
		[71041] = List(),	-- Dungeon Deserter
		[80354] = List(),	-- Timewarp
		[95809] = List(),	-- Insanity
		[95223] = List()	-- Group Res
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	-- General
		[96694] = List(),	-- Reflective Shield
	-- Mage
		[12042] = List(),	-- Arcane Power
		[12051] = List(),	-- Evocation
		[80353] = List(),	-- Time Warp
		[12472] = List(),	-- Steel blood
		[32612] = List(),	-- Invisibility
		[45438] = List(),	-- Ice Block
	-- Death Knight
		[48707] = List(),	-- Anti-Magic Shell
		[48792] = List(),	-- Icebound Fortitude
		[49016] = List(),	-- Unholy Frenzy
		[49039] = List(),	-- Lichborne
		[49222] = List(),	-- Bone shield
		[50461] = List(),	-- Anti-Magic Zone
		[51271] = List(),	-- Pillar of Frost
		[55233] = List(),	-- Vampiric Blood
		[81256] = List(),	-- Dancing Rune Weapon
		[96268] = List(),	-- Death's Advance
	-- Priest
		[6346] = List(),	-- Fear Ward
		[10060] = List(),	-- Power Infusion
		[27827] = List(),	-- Spirit of Redemption
		[33206] = List(),	-- Pain Suppression
		[47585] = List(),	-- Dispersion
		[47788] = List(),	-- Guardian Spirit
		[62618] = List(),	-- Power Word: Barrier
	-- Warlock
		[88448] = List(),	-- Demonic Rebirth
		[1490] = List(),	-- Curse of the elements
		[18708] = List(),	-- Fel Domination
	-- Druid
		[1850] = List(),	-- Dash
		[16689] = List(),	-- Nature's Grasp
		[22812] = List(),	-- Barkskin
		[29166] = List(),	-- Innervate
		[52610] = List(),	-- Savage Roar
		[61336] = List(),	-- Survival Instincts
		[69369] = List(),	-- Predatory Swiftness
		[77761] = List(),	-- Stampeding Roar (Bear Form)
		[77764] = List(),	-- Stampeding Roar (Cat Form)
	-- Hunter
		[3045] = List(),	-- Rapid Fire
		[5384] = List(),	-- Feign Death
		[19263] = List(),	-- Deterrence
		[34471] = List(),	-- The Beast Within
		[51755] = List(),	-- Camouflage
		[53480] = List(),	-- Roar of Sacrifice (Pet Cunning)
		[54216] = List(),	-- Master's Call
		[90355] = List(),	-- Ancient Hysteria
		[90361] = List(),	-- Spirit Mend
	-- Rogue
		[2983] = List(),	-- Sprint
		[5277] = List(),	-- Evasion
		[11327] = List(),	-- Vanish
		[13750] = List(),	-- Adrenaline Rush
		[31224] = List(),	-- Cloak of Shadows
		[45182] = List(),	-- Cheating Death
		[51713] = List(),	-- Shadow Dance
		[57933] = List(),	-- Tricks of the Trade
		[74001] = List(),	-- Combat Readiness
		[79140] = List(),	-- Vendetta
	-- Shaman
		[2825] = List(),	-- Bloodlust
		[8178] = List(),	-- Grounding Totem Effect
		[16166] = List(),	-- Elemental Mastery
		[16188] = List(),	-- Nature's Swiftness
		[16191] = List(),	-- Mana Tide Totem
		[30823] = List(),	-- Shamanistic Rage
		[32182] = List(),	-- Heroism
		[58875] = List(),	-- Spirit Walk
		[79206] = List(),	-- Spiritwalker's Grace
		[98007] = List(),	-- Spirit Link Totem
	-- Paladin
		[498] = List(),		-- Divine Protection
		[642] = List(),		-- Divine Shield
		[1044] = List(),	-- Hand of Freedom
		[1022] = List(),	-- Hand of Protection
		[1038] = List(),	-- Hand of Salvation
		[6940] = List(),	-- Hand of Sacrifice
		[31821] = List(),	-- Aura Mastery
		[86659] = List(),	-- Guardian of the Ancient Kings
		[20925] = List(),	-- Holy Shield
		[31850] = List(),	-- Ardent Defender
		[31884] = List(),	-- Avenging Wrath
		[53563] = List(),	-- Beacon of Light
		[31842] = List(),	-- Divine Favor
		[54428] = List(),	-- Divine Plea
		[85499] = List(),	-- Speed of Light
	-- Warrior
		[871] = List(),		-- Shield Wall
		[1719] = List(),	-- Recklessness
		[3411] = List(),	-- Intervene
		[12975] = List(),	-- Last Stand
		[18499] = List(),	-- Berserker Rage
		[23920] = List(),	-- Spell Reflection
		[46924] = List(),	-- Bladestorm
		[50720] = List(),	-- Vigilance
		[55694] = List(),	-- Enraged Regeneration
		[85730] = List(),	-- Deadly Calm
		[97463] = List(),	-- Rallying Cry
	-- Racial
		[20572] = List(),	-- Blood Fury
		[20594] = List(),	-- Stoneform
		[26297] = List(),	-- Berserking
		[59545] = List(),	-- Gift of the Naaru
	},
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	spells = {
	-------------------------------------------------
	-------------------- Dungeons -------------------
	-------------------------------------------------
	-- Blackrock Caverns
	-- Throne of the Tides
	-- The Stonecore
	-- The Vortex Pinnacle
	-- Grim Batol
	-- Halls of Origination
	-- Deadmines
	-- Shadowfang Keep
	-- Lost City of the Tol'vir
	-------------------------------------------------
	-------------------- Phase 1 --------------------
	-------------------------------------------------
	-- Baradin Hold
		[95173] = List(),	-- Consuming Darkness
		[96913] = List(),	-- Searing Shadows
		[104936] = List(),	-- Skewer
		[105067] = List(),	-- Seething Hate
	-- Blackwing Descent
		[91911] = List(),	-- Constricting Chains
		[94679] = List(),	-- Parasitic Infection
		[94617] = List(),	-- Mangle
		[78199] = List(),	-- Sweltering Armor
		[91433] = List(),	-- Lightning Conductor
		[91521] = List(),	-- Incineration Security Measure
		[80094] = List(),	-- Fixate
		[91535] = List(),	-- Flamethrower
		[80161] = List(),	-- Chemical Cloud
		[92035] = List(),	-- Acquiring Target
		[79835] = List(),	-- Poison Soaked Shell
		[91555] = List(),	-- Power Generator
		[92048] = List(),	-- Shadow Infusion
		[92053] = List(),	-- Shadow Conductor
		[77699] = List(),	-- Flash Freeze
		[77760] = List(),	-- Biting Chill
		[92754] = List(),	-- Engulfing Darkness
		[92971] = List(),	-- Consuming Flames
		[92989] = List(),	-- Rend
		[92423] = List(),	-- Searing Flame
		[92485] = List(),	-- Roaring Flame
		[92407] = List(),	-- Sonic Breath
		[78092] = List(),	-- Tracking
		[82881] = List(),	-- Break
		[89084] = List(),	-- Low Health
		[81114] = List(),	-- Magma
		[94128] = List(),	-- Tail Lash
		[79339] = List(),	-- Explosive Cinders
		[79318] = List(),	-- Dominion
	-- The Bastion of Twilight
		[39171] = List(),	-- Malevolent Strikes
		[83710] = List(),	-- Furious Roar
		[92878] = List(),	-- Blackout
		[86840] = List(),	-- Devouring Flames
		[95639] = List(),	-- Engulfing Magic
		[92886] = List(),	-- Twilight Zone
		[88518] = List(),	-- Twilight Meteorite
		[86505] = List(),	-- Fabulous Flames
		[93051] = List(),	-- Twilight Shift
		[92511] = List(),	-- Hydro Lance
		[82762] = List(),	-- Waterlogged
		[92505] = List(),	-- Frozen
		[92518] = List(),	-- Flame Torrent
		[83099] = List(),	-- Lightning Rod
		[92075] = List(),	-- Gravity Core
		[92488] = List(),	-- Gravity Crush
		[82660] = List(),	-- Burning Blood
		[82665] = List(),	-- Heart of Ice
		[83500] = List(),	-- Swirling Winds
		[83581] = List(),	-- Grounded
		[92067] = List(),	-- Static Overload
		[86028] = List(),	-- Cho's Blast
		[86029] = List(),	-- Gall's Blast
		[93187] = List(),	-- Corrupted Blood
		[82125] = List(),	-- Corruption: Malformation
		[82170] = List(),	-- Corruption: Absolute
		[93200] = List(),	-- Corruption: Sickness
		[82411] = List(),	-- Debilitating Beam
		[91317] = List(),	-- Worshipping
		[92956] = List(),	-- Wrack
	-- Throne of the Four Winds
		[93131] = List(),	-- Ice Patch
		[86206] = List(),	-- Soothing Breeze
		[93122] = List(),	-- Toxic Spores
		[93058] = List(),	-- Slicing Gale
		[93260] = List(),	-- Ice Storm
		[93295] = List(),	-- Lightning Rod
		[87873] = List(),	-- Static Shock
		[87856] = List(),	-- Squall Line
		[88427] = List(),	-- Electrocute
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- Zul'Aman (Dungeon)
	-- Zul'Gurub (Dungeon)
	-- Firelands
		[99506] = List(),	-- Widows Kiss
		[97202] = List(),	-- Fiery Web Spin
		[49026] = List(),	-- Fixate
		[97079] = List(),	-- Seeping Venom
		[99389] = List(),	-- Imprinted
		[101296] = List(),	-- Fiero Blast
		[100723] = List(),	-- Gushing Wound
		[101729] = List(),	-- Blazing Claw
		[100640] = List(),	-- Harsh Winds
		[100555] = List(),	-- Smouldering Roots
		[99837] = List(),	-- Crystal Prison
		[99937] = List(),	-- Jagged Tear
		[99403] = List(),	-- Tormented
		[99256] = List(),	-- Torment
		[99252] = List(),	-- Blaze of Glory
		[99516] = List(),	-- Countdown
		[98450] = List(),	-- Searing Seeds
		[98565] = List(),	-- Burning Orb
		[98313] = List(),	-- Magma Blast
		[99145] = List(),	-- Blazing Heat
		[99399] = List(),	-- Burning Wound
		[99613] = List(),	-- Molten Blast
		[100293] = List(),	-- Lava Wave
		[100675] = List(),	-- Dreadflame
		[100249] = List(),	-- Combustion
		[99532] = List(),	-- Melt Armor
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Dragon Soul
		[103541] = List(),	-- Safe
		[103536] = List(),	-- Warning
		[103534] = List(),	-- Danger
		[103687] = List(),	-- Crush Armor
		[108570] = List(),	-- Black Blood of the Earth
		[103434] = List(),	-- Disrupting Shadows
		[105171] = List(),	-- Deep Corruption
		[105465] = List(),	-- Lighting Storm
		[104451] = List(),	-- Ice Tomb
		[109325] = List(),	-- Frostflake
		[105289] = List(),	-- Shattered Ice
		[105285] = List(),	-- Target
		[105259] = List(),	-- Watery Entrenchment
		[107061] = List(),	-- Ice Lance
		[109075] = List(),	-- Fading Light
		[108043] = List(),	-- Sunder Armor
		[107558] = List(),	-- Degeneration
		[107567] = List(),	-- Brutal Strike
		[108046] = List(),	-- Shockwave
		[110214] = List(),	-- Shockwave
		[105479] = List(),	-- Searing Plasma
		[105490] = List(),	-- Fiery Grip
		[105563] = List(),	-- Grasping Tendrils
		[106199] = List(),	-- Blood Corruption: Death
		[105841] = List(),	-- Degenerative Bite
		[106385] = List(),	-- Crush
		[106730] = List(),	-- Tetanus
		[106444] = List(),	-- Impale
		[106794] = List(),	-- Shrapnel (Target)
		[105445] = List(),	-- Blistering Heat
		[108649] = List()	-- Corrupting Parasite
	},
}

-- Buffs applied by bosses, adds or trash
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	spells = {
	-------------------------------------------------
	-------------------- Dungeons -------------------
	-------------------------------------------------
	-- Blackrock Caverns
	-- Throne of the Tides
	-- The Stonecore
	-- The Vortex Pinnacle
	-- Grim Batol
	-- Halls of Origination
	-- Deadmines
	-- Shadowfang Keep
	-- Lost City of the Tol'vir
	-------------------------------------------------
	-------------------- Phase 1 --------------------
	-------------------------------------------------
	-- Baradin Hold
		[95173] = List(),	-- Consuming Darkness
		[96913] = List(),	-- Searing Shadows
		[104936] = List(),	-- Skewer
		[105067] = List(),	-- Seething Hate
	-- Blackwing Descent
		[91911] = List(),	-- Constricting Chains
		[94679] = List(),	-- Parasitic Infection
		[94617] = List(),	-- Mangle
		[78199] = List(),	-- Sweltering Armor
		[91433] = List(),	-- Lightning Conductor
		[91521] = List(),	-- Incineration Security Measure
		[80094] = List(),	-- Fixate
		[91535] = List(),	-- Flamethrower
		[80161] = List(),	-- Chemical Cloud
		[92035] = List(),	-- Acquiring Target
		[79835] = List(),	-- Poison Soaked Shell
		[91555] = List(),	-- Power Generator
		[92048] = List(),	-- Shadow Infusion
		[92053] = List(),	-- Shadow Conductor
		[77699] = List(),	-- Flash Freeze
		[77760] = List(),	-- Biting Chill
		[92754] = List(),	-- Engulfing Darkness
		[92971] = List(),	-- Consuming Flames
		[92989] = List(),	-- Rend
		[92423] = List(),	-- Searing Flame
		[92485] = List(),	-- Roaring Flame
		[92407] = List(),	-- Sonic Breath
		[78092] = List(),	-- Tracking
		[82881] = List(),	-- Break
		[89084] = List(),	-- Low Health
		[81114] = List(),	-- Magma
		[94128] = List(),	-- Tail Lash
		[79339] = List(),	-- Explosive Cinders
		[79318] = List(),	-- Dominion
	-- The Bastion of Twilight
		[39171] = List(),	-- Malevolent Strikes
		[83710] = List(),	-- Furious Roar
		[92878] = List(),	-- Blackout
		[86840] = List(),	-- Devouring Flames
		[95639] = List(),	-- Engulfing Magic
		[92886] = List(),	-- Twilight Zone
		[88518] = List(),	-- Twilight Meteorite
		[86505] = List(),	-- Fabulous Flames
		[93051] = List(),	-- Twilight Shift
		[92511] = List(),	-- Hydro Lance
		[82762] = List(),	-- Waterlogged
		[92505] = List(),	-- Frozen
		[92518] = List(),	-- Flame Torrent
		[83099] = List(),	-- Lightning Rod
		[92075] = List(),	-- Gravity Core
		[92488] = List(),	-- Gravity Crush
		[82660] = List(),	-- Burning Blood
		[82665] = List(),	-- Heart of Ice
		[83500] = List(),	-- Swirling Winds
		[83581] = List(),	-- Grounded
		[92067] = List(),	-- Static Overload
		[86028] = List(),	-- Cho's Blast
		[86029] = List(),	-- Gall's Blast
		[93187] = List(),	-- Corrupted Blood
		[82125] = List(),	-- Corruption: Malformation
		[82170] = List(),	-- Corruption: Absolute
		[93200] = List(),	-- Corruption: Sickness
		[82411] = List(),	-- Debilitating Beam
		[91317] = List(),	-- Worshipping
		[92956] = List(),	-- Wrack
	-- Throne of the Four Winds
		[93131] = List(),	-- Ice Patch
		[86206] = List(),	-- Soothing Breeze
		[93122] = List(),	-- Toxic Spores
		[93058] = List(),	-- Slicing Gale
		[93260] = List(),	-- Ice Storm
		[93295] = List(),	-- Lightning Rod
		[87873] = List(),	-- Static Shock
		[87856] = List(),	-- Squall Line
		[88427] = List(),	-- Electrocute
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- Zul'Aman (Dungeon)
	-- Zul'Gurub (Dungeon)
	-- Firelands
		[99506] = List(),	-- Widows Kiss
		[97202] = List(),	-- Fiery Web Spin
		[49026] = List(),	-- Fixate
		[97079] = List(),	-- Seeping Venom
		[99389] = List(),	-- Imprinted
		[101296] = List(),	-- Fiero Blast
		[100723] = List(),	-- Gushing Wound
		[101729] = List(),	-- Blazing Claw
		[100640] = List(),	-- Harsh Winds
		[100555] = List(),	-- Smouldering Roots
		[99837] = List(),	-- Crystal Prison
		[99937] = List(),	-- Jagged Tear
		[99403] = List(),	-- Tormented
		[99256] = List(),	-- Torment
		[99252] = List(),	-- Blaze of Glory
		[99516] = List(),	-- Countdown
		[98450] = List(),	-- Searing Seeds
		[98565] = List(),	-- Burning Orb
		[98313] = List(),	-- Magma Blast
		[99145] = List(),	-- Blazing Heat
		[99399] = List(),	-- Burning Wound
		[99613] = List(),	-- Molten Blast
		[100293] = List(),	-- Lava Wave
		[100675] = List(),	-- Dreadflame
		[100249] = List(),	-- Combustion
		[99532] = List(),	-- Melt Armor
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Dragon Soul
		[103541] = List(),	-- Safe
		[103536] = List(),	-- Warning
		[103534] = List(),	-- Danger
		[103687] = List(),	-- Crush Armor
		[108570] = List(),	-- Black Blood of the Earth
		[103434] = List(),	-- Disrupting Shadows
		[105171] = List(),	-- Deep Corruption
		[105465] = List(),	-- Lighting Storm
		[104451] = List(),	-- Ice Tomb
		[109325] = List(),	-- Frostflake
		[105289] = List(),	-- Shattered Ice
		[105285] = List(),	-- Target
		[105259] = List(),	-- Watery Entrenchment
		[107061] = List(),	-- Ice Lance
		[109075] = List(),	-- Fading Light
		[108043] = List(),	-- Sunder Armor
		[107558] = List(),	-- Degeneration
		[107567] = List(),	-- Brutal Strike
		[108046] = List(),	-- Shockwave
		[110214] = List(),	-- Shockwave
		[105479] = List(),	-- Searing Plasma
		[105490] = List(),	-- Fiery Grip
		[105563] = List(),	-- Grasping Tendrils
		[106199] = List(),	-- Blood Corruption: Death
		[105841] = List(),	-- Degenerative Bite
		[106385] = List(),	-- Crush
		[106730] = List(),	-- Tetanus
		[106444] = List(),	-- Impale
		[106794] = List(),	-- Shrapnel (Target)
		[105445] = List(),	-- Blistering Heat
		[108649] = List()	-- Corrupting Parasite
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	DEATHKNIGHT = {
		[49016] = Aura(49016, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}) -- Unholy Frenzy
	},
	DRUID = {
		[467]	= Aura(467, nil, 'TOPRIGHT', {0.4, 0.2, 0.8}, true), -- Thorns
		[774]	= Aura(774, nil, 'BOTTOMLEFT', {0.83, 1.00, 0.25}), -- Rejuvenation
		[8936]	= Aura(8936, nil, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Regrowth
		[29166]	= Aura(29166, nil, 'CENTER', {0.49, 0.60, 0.55}, true), -- Innervate
		[33763]	= Aura(33763, nil, 'BOTTOM', {0.33, 0.37, 0.47}), -- Lifebloom
		[48438]	= Aura(48438, nil, 'BOTTOMRIGHT', {0.8, 0.4, 0}) -- Wild Growth
	},
	HUNTER = {
		[34477] = Aura(34477, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}) -- Misdirection
	},
	MAGE = {
		[130]	= Aura(130, nil, 'CENTER', {0.00, 0.00, 0.50}, true), -- Slow Fall
		[54646] = Aura(54646, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}) -- Focus Magic
	},
	PALADIN = {
		[1044]	= Aura(1044, nil, 'CENTER', {0.89, 0.45, 0}, true), -- Hand of Freedom
		[1038]	= Aura(1038, nil, 'CENTER', {0.11, 1.00, 0.45}, true), -- Hand of Salvation
		[6940]	= Aura(6940, nil, 'CENTER', {0.89, 0.1, 0.1}, true), -- Hand of Sacrifice
		[1022]	= Aura(1022, nil, 'CENTER', {0.17, 1.00, 0.75}, true), -- Hand of Protection
		[53563]	= Aura(53563, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}, true), -- Beacon of Light
	},
	PRIEST = {
		[17]	= Aura(17, nil, 'BOTTOM', {0.00, 0.00, 1.00}), -- Power Word: Shield
		[139]	= Aura(139, nil, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Renew
		[6788]	= Aura(6788, nil, 'TOP', {0.89, 0.1, 0.1}), -- Weakened Soul
		[41635]	= Aura(41635, nil, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		[10060] = Aura(10060, nil, 'TOP', {0.17, 1.00, 0.45}), -- Power Infusion
		[47788] = Aura(47788, nil, 'TOP', {0.17, 1.00, 0.45}), -- Guardian Spirit
		[33206] = Aura(33206, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}), -- Pain Suppression
		[56161] = Aura(56161, nil, 'LEFT', {1.0, 1.0, 1.0}) -- Glyph of Prayer of Healing
	},
	ROGUE = {
		[57933] = Aura(57933, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}) -- Tricks of the Trade
	},
	SHAMAN = {
		[16177]	= Aura(16177, {16236,16237}, 'RIGHT', {0.2, 0.2, 1}), -- Ancestral Fortitude
		[974]	= Aura(974, nil, 'TOP', {0.08, 0.21, 0.43}, true), -- Earth Shield
		[61295] = Aura(61295, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[51945] = Aura(51945, nil, 'LEFT', {0.7, 0.3, 0.7}) -- Earthliving
	},
	WARLOCK = {
		[5697]	= Aura(5697, nil, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Unending Breath
		[20707]	= Aura(20707, nil, 'TOP', {0.00, 0.00, 0.85}, true) -- Soulstone
	},
	WARRIOR = {
		[3411]	= Aura(3411, nil, 'TOPLEFT', {0.2, 0.2, 1}, true), -- Intervene
		[50720]	= Aura(50720, nil, 'TOPRIGHT', {0.4, 0.2, 0.8}, true) -- Vigilance
	},
	PET = {
	-- Hunter Pets
		[136]	= Aura(136, nil, 'TOPRIGHT', {0.08, 0.59, 0.41}) -- Mend Pet
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Warlock
	[1120]	= 5, -- Drain Soul
	[689]	= 5, -- Drain Life
	[5740]	= 4, -- Rain of Fire
	[755]	= 10, -- Health Funnel
	[79268]	= 3, -- Soul Harvest
	[1949]	= 15, -- Hellfire
	-- Druid
	[44203]	= 4, -- Tranquility
	[16914]	= 10, -- Hurricane
	-- Priest
	[15407]	= 3, -- Mind Flay
	[48045]	= 5, -- Mind Sear
	[47540]	= 3, -- Penance
	[64901]	= 4, -- Hymn of Hope
	[64843]	= 4, -- Divine Hymn
	-- Mage
	[5143]	= 5, -- Arcane Missiles
	[10]	= 8, -- Blizzard
	[12051]	= 4, -- Evocation
	-- Death Knight
	[42650]	= 8, -- Army of the Dead
	-- First Aid
	[45544]	= 8, -- Heavy Frostweave Bandage
	[45543]	= 8, -- Frostweave Bandage
	[27031]	= 8, -- Heavy Netherweave Bandage
	[27030]	= 8, -- Netherweave Bandage
	[23567]	= 8, -- Warsong Gulch Runecloth Bandage
	[23696]	= 8, -- Alterac Heavy Runecloth Bandage
	[24414]	= 8, -- Arathi Basin Runecloth Bandage
	[18610]	= 8, -- Heavy Runecloth Bandage
	[18608]	= 8, -- Runecloth Bandage
	[10839]	= 8, -- Heavy Mageweave Bandage
	[10838]	= 8, -- Mageweave Bandage
	[7927]	= 8, -- Heavy Silk Bandage
	[7926]	= 8, -- Silk Bandage
	[3268]	= 7, -- Heavy Wool Bandage
	[3267]	= 7, -- Wool Bandage
	[1159]	= 6, -- Heavy Linen Bandage
	[746]	= 6 -- Linen Bandage
}

-- Spells that chain, second step
G.unitframe.ChainChannelTicks = {}

-- Window to chain time (in seconds); usually the channel duration
G.unitframe.ChainChannelTime = {}

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {}

-- Increase ticks from auras
G.unitframe.AuraChannelTicks = {}

-- Spells Effected By Haste, value is Base Tick Size
G.unitframe.HastedChannelTicks = {
	-- Warlock
	[1120]	= true, -- Drain Soul
	[689]	= true, -- Drain Life
	[5740]	= true, -- Rain of Fire
	[755]	= true, -- Health Funnel
	[79268]	= true, -- Soul Harvest
	[1949]	= true, -- Hellfire
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825] = { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Bloodlust
	[32182] = { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Heroism
	[80353] = {enable = true, color = {r = 0.98, g = 0.57, b = 0.10}}, -- Time Warp
	[90355] = {enable = true, color = {r = 0.98, g = 0.57, b = 0.10}} -- Ancient Hysteria
}

G.unitframe.AuraHighlightColors = {
	[25771]	= {enable = false, style = 'FILL', color = {r = 0.85, g = 0, b = 0, a = 0.85}}, -- Forbearance
}
