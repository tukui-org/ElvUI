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
	-- Monk
		[116706] = List(),	-- Disable
		[117368] = List(),	-- Grapple Weapon
		[115078] = List(),	-- Paralysis
		[122242] = List(),	-- Clash
		[119392] = List(),	-- Charging Ox Wave
		[119381] = List(),	-- Leg Sweep
		[120086] = List(),	-- Fists of Fury
		[116709] = List(),	-- Spear Hand Strike
		[123407] = List(),	-- Spinning Fire Blossom
		[140023] = List(),	-- Ring of Peace
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
	-- Monk
		[120954] = List(),	-- Fortifying Brew
		[131523] = List(),	-- Zen Meditation
		[122783] = List(),	-- Diffuse Magic
		[122278] = List(),	-- Dampen Harm
		[115213] = List(),	-- Avert Harm
		[116849] = List(),	-- Life Cocoon
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
	-- Monk
		[120954] = List(),	-- Fortifying Brew
		[131523] = List(),	-- Zen Meditation
		[122783] = List(),	-- Diffuse Magic
		[122278] = List(),	-- Dampen Harm
		[115213] = List(),	-- Avert Harm
		[116849] = List(),	-- Life Cocoon
		[125174] = List(),	-- Touch of Karma
		[116841] = List(),	-- Tiger's Lust
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
	-- Scholomance
	-- Scarlet Halls
	-- Mogu'shan Palace
	-- Stormstout Brewery
	-- Siege of Niuzao Temple
	-- Scarlet Monastery
	-- Temple of the Jade Serpent
	-- Gate of the Setting Sun
	-- Shado-Pan Monastery
	-------------------------------------------------
	--------------------- Raids ---------------------
	-------------------------------------------------
	-- Mogu'shan Vaults
		-- The Stone Guard
		[125206] = List(),	-- Rend Flesh
		[130395] = List(),	-- Jasper Chains
		[116281] = List(),	-- Cobalt Mine Blast
		-- Feng the Accursed
		[131788] = List(),	-- Lightning Lash
		[116942] = List(),	-- Flaming Spear
		[131790] = List(),	-- Arcane Shock
		[131792] = List(),	-- Shadowburn
		[116374] = List(),	-- Lightning Charge
		[116784] = List(),	-- Wildfire Spark
		[116417] = List(),	-- Arcane Resonance
		-- Gara'jal the Spiritbinder
		[122151] = List(),	-- Voodoo Doll
		[117723] = List(),	-- Frail Soul
		-- The Spirit Kings
		[117708] = List(),	-- Maddening Shout
		[118303] = List(),	-- Fixate
		[118048] = List(),	-- Pillaged
		[118135] = List(),	-- Pinned Down
		[118163] = List(),	-- Robbed Blind
		-- Elegon
		[117878] = List(),	-- Overcharged
		[117949] = List(),	-- Closed Circuit
		[132222] = List(),	-- Destabilizing Energies
		-- Will of the Emperor
		[116835] = List(),	-- Devastating Arc
		[116778] = List(),	-- Focused Defense
		[116525] = List(),	-- Focused Assault
	-- Heart of Fear
		-- Imperial Vizier Zor'lok
		[122761] = List(),	-- Exhale
		[122760] = List(),	-- Exhale
		[122740] = List(),	-- Convert
		[123812] = List(),	-- Pheromones of Zeal
		-- Blade Lord Ta'yak
		[123180] = List(),	-- Wind Step
		[123474] = List(),	-- Overwhelming Assault
		-- Garalon
		[122835] = List(),	-- Pheromones
		[123081] = List(),	-- Pungency
		-- Wind Lord Mel'jarak
		[129078] = List(),	-- Amber Prison
		[122055] = List(),	-- Residue
		[122064] = List(),	-- Corrosive Resin
		[123963] = List(),	-- Kor'thik Strike
		-- Amber-Shaper Un'sok
		[121949] = List(),	-- Parasitic Growth
		[122370] = List(),	-- Reshape Life
	-- Terrace of Endless Spring
		-- Protectors of the Endless
		[117436] = List(),	-- Lightning Prison
		[118091] = List(),	-- Defiled Ground
		[117519] = List(),	-- Touch of Sha
		-- Tsulong
		[122752] = List(),	-- Shadow Breath
		[123011] = List(),	-- Terrorize
		[116161] = List(),	-- Crossed Over
		[122777] = List(),	-- Nightmares
		[123036] = List(),	-- Fright
		-- Lei Shi
		[123121] = List(),	-- Spray
		[123705] = List(),	-- Scary Fog
		-- Sha of Fear
		[119985] = List(),	-- Dread Spray
		[119086] = List(),	-- Penetrating Bolt
		[119775] = List(),	-- Reaching Attack
		[120669] = List(),	-- Naked and Afraid
		[120629] = List(),	-- Huddle in Terror
	-- Throne of Thunder
		-- Trash
		[138349] = List(),	-- Static Wound
		[137371] = List(),	-- Thundering Throw
		-- Jin'rokh the Breaker
		[137162] = List(),	-- Static Burst
		[138732] = List(),	-- Ionization
		[137422] = List(),	-- Focused Lightning
		-- Horridon
		[136767] = List(),	-- Triple Puncture
		[136708] = List(),	-- Stone Gaze
		[136654] = List(),	-- Rending Charge
		[136719] = List(),	-- Blazing Sunlight
		[136587] = List(),	-- Venom Bolt Volley
		[136710] = List(),	-- Deadly Plague
		[136512] = List(),	-- Hex of Confusion
		-- Council of Elders
		[137641] = List(),	-- Soul Fragment
		[137359] = List(),	-- Shadowed Loa Spirit Fixate
		[137972] = List(),	-- Twisted Fate
		[136903] = List(),	-- Frigid Assault
		[136922] = List(),	-- Frostbite
		[136992] = List(),	-- Biting Cold
		[136857] = List(),	-- Entrapped
		-- Tortos
		[136753] = List(),	-- Slashing Talons
		[137633] = List(),	-- Crystal Shell
		[140701] = List(),	-- Crystal Shell: Full Capacity! (Heroic)
		-- Megaera
		[137731] = List(),	-- Ignite Flesh
		[139843] = List(),	-- Arctic Freeze
		[139840] = List(),	-- Rot Armor
		[134391] = List(),	-- Cinder
		[139857] = List(),	-- Torrent of Ice
		[140179] = List(),	-- Suppression (Heroic)
		-- Ji-Kun
		[134366] = List(),	-- Talon Rake
		[140092] = List(),	-- Infected Talons
		[134256] = List(),	-- Slimed
		-- Durumu the Forgotten
		[133767] = List(),	-- Serious Wound
		[133768] = List(),	-- Arterial Cut
		[133798] = List(),	-- Life Drain
		[133597] = List(),	-- Dark Parasite (Heroic)
		-- Primordius
		[136050] = List(),	-- Malformed Blood
		[136228] = List(),	-- Volatile Pathogen
		-- Dark Animus
		[138569] = List(),	-- Explosive Slam
		[138609] = List(),	-- Matter Swap
		[138659] = List(),	-- Touch of the Animus
		-- Iron Qon
		[134691] = List(),	-- Impale
		[136192] = List(),	-- Lightning Storm
		[136193] = List(),	-- Arcing Lightning
		-- Twin Consorts
		[137440] = List(),	-- Icy Shadows
		[137408] = List(),	-- Fan of Flames
		[137360] = List(),	-- Corrupted Healing
		[136722] = List(),	-- Slumber Spores
		[137341] = List(),	-- Beast of Nightmares
		-- Lei Shen
		[135000] = List(),	-- Decapitate
		[136478] = List(),	-- Fusion Slash
		[136914] = List(),	-- Electrical Shock
		[135695] = List(),	-- Static Shock
		[136295] = List(),	-- Overcharged
		[139011] = List(),	-- Helm of Command (Heroic)
		-- Ra-den
		[138297] = List(),	-- Unstable Vita
		[138329] = List(),	-- Unleashed Anima
		[138372] = List(),	-- Vita Sensitivity
	-- Siege of Orgrimmar
		-- Immerseus
		[143436] = List(),	-- Corrosive Blast
		[143579] = List(),	-- Sha Corruption(Heroic)
		-- Fallen Protectors
		[143434] = List(),	-- Shadow Word: Bane
		[143198] = List(),	-- Garrote
		[143840] = List(),	-- Mark of Anguish
		[147383] = List(),	-- Debilitation
		-- Norushen
		[146124] = List(),	-- Self Doubt
		[144851] = List(),	-- Test of Confidence
		[144514] = List(),	-- Lingering Corruption
		-- Sha of Pride
		[144358] = List(),	-- Wounded Pride
		[144774] = List(),	-- Reaching Attacks
		[147207] = List(),	-- Weakened Resolve(Heroic)
		[144351] = List(),	-- Mark of Arrogance
		[146594] = List(),	-- Gift of the Titans
		-- Galakras
		[147029] = List(),	-- Flames of Galakrond
		[146902] = List(),	-- Poison-Tipped Blades
		-- Iron Juggernaut
		[144467] = List(),	-- Ignite Armor
		[144459] = List(),	-- Laser Burn
		-- Kor'kron Dark Shaman
		[144215] = List(),	-- Froststorm Strike
		[143990] = List(),	-- Foul Geyser
		[144330] = List(),	-- Iron Prison(Heroic)
		[144089] = List(),	-- Toxic Mist
		-- General Nazgrim
		[143494] = List(),	-- Sundering Blow
		[143638] = List(),	-- Bonecracker
		[143431] = List(),	-- Magistrike
		[143480] = List(),	-- Assassin's Mark
		-- Malkorok
		[142990] = List(),	-- Fatal Strike
		[143919] = List(),	-- Languish(Heroic)
		[142864] = List(),	-- Ancient Barrier
		[142865] = List(),	-- Strong Ancient Barrier
		[142913] = List(),	-- Displaced Energy
		-- Spoils of Pandaria
		[145218] = List(),	-- Harden Flesh
		[146235] = List(),	-- Breath of Fire
		-- Thok the Bloodthirsty
		[143766] = List(),	-- Panic
		[143773] = List(),	-- Freezing Breath
		[146589] = List(),	-- Skeleton Key
		[143777] = List(),	-- Frozen Solid
		[143780] = List(),	-- Acid Breath
		[143800] = List(),	-- Icy Blood
		[143767] = List(),	-- Scorching Breath
		[143791] = List(),	-- Corrosive Blood
		-- Siegecrafter Blackfuse
		[143385] = List(),	-- Electrostatic Charge
		[144236] = List(),	-- Pattern Recognition
		-- Paragons of the Klaxxi
		[143974] = List(),	-- Shield Bash
		[142315] = List(),	-- Caustic Blood
		[143701] = List(),	-- Whirling
		[142948] = List(),	-- Aim
		-- Garrosh Hellscream
		[145183] = List(),	-- Gripping Despair
		[145195] = List(),	-- Empowered Gripping Despair
		[145065] = List(),	-- Touch of Y'Shaarj
		[145171] = List(),	-- Empowered Touch of Y'Shaarj
	},
}

-- Buffs applied by bosses, adds or trash
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	spells = {
	-------------------------------------------------
	-------------------- Dungeons -------------------
	-------------------------------------------------
	-- Scholomance
	-- Scarlet Halls
	-- Mogu'shan Palace
	-- Stormstout Brewery
	-- Siege of Niuzao Temple
	-- Scarlet Monastery
	-- Temple of the Jade Serpent
	-- Gate of the Setting Sun
	-- Shado-Pan Monastery
	-------------------------------------------------
	--------------------- Raids ---------------------
	-------------------------------------------------
	-- Mogu'shan Vaults
	-- Heart of Fear
	-- Terrace of Endless Spring
	-- Throne of Thunder
	-- Siege of Orgrimmar
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	MONK = {
		[119611] = Aura(119611, nil, 'TOPLEFT', {0.8, 0.4, 0.8}), -- Renewing Mist
		[116849] = Aura(116849, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Life Cocoon
		[124081] = Aura(124081, nil, 'BOTTOMRIGHT', {0.7, 0.4, 0}), -- Zen Sphere
		[132120] = Aura(132120, nil, 'BOTTOMLEFT', {0.4, 0.8, 0.2}) -- Enveloping Mist
	},
	DEATHKNIGHT = {
		[49016] = Aura(49016, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}) -- Unholy Frenzy
	},
	DRUID = {
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
	},
	ROGUE = {
		[57933] = Aura(57933, nil, 'TOPRIGHT', {0.17, 1.00, 0.45}) -- Tricks of the Trade
	},
	SHAMAN = {
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
	[1120]		= 6, -- Drain Soul
	[689]		= 6, -- Drain Life
	[5740]		= 6, -- Rain of Fire
	[755]		= 6, -- Health Funnel
	[1949]		= 14, -- Hellfire
	[103103] 	= 4, -- Malefic Grasp
	-- Druid
	[44203]		= 4, -- Tranquility
	[16914]		= 10, -- Hurricane
	-- Priest
	[15407]		= 3, -- Mind Flay
	[129197] 	= 3, -- Mind Flay (Insanity)
	[48045]		= 5, -- Mind Sear
	[47758]		= 3, -- Penance
	[64901]		= 4, -- Hymn of Hope
	[64843]		= 4, -- Divine Hymn
	-- Mage
	[5143]		= 5, -- Arcane Missiles
	[10]		= 8, -- Blizzard
	[12051]		= 4, -- Evocation
	-- Death Knight
	[42650]		= 8, -- Army of the Dead
	-- First Aid
	[102695] 	= 8, -- Heavy Windwool Bandage
    [102694] 	= 8, -- Windwool Bandage
    [74555] 	= 8, -- Dense Embersilk Bandage
    [74554] 	= 8, -- Heavy Embersilk Bandage
    [74553]		= 8, -- Embersilk Bandage
	[45544]		= 8, -- Heavy Frostweave Bandage
	[45543]		= 8, -- Frostweave Bandage
	[27031]		= 8, -- Heavy Netherweave Bandage
	[27030]		= 8, -- Netherweave Bandage
	[23567]		= 8, -- Warsong Gulch Runecloth Bandage
	[23696]		= 8, -- Alterac Heavy Runecloth Bandage
	[24414]		= 8, -- Arathi Basin Runecloth Bandage
	[18610]		= 8, -- Heavy Runecloth Bandage
	[18608]		= 8, -- Runecloth Bandage
	[10839]		= 8, -- Heavy Mageweave Bandage
	[10838]		= 8, -- Mageweave Bandage
	[7927]		= 8, -- Heavy Silk Bandage
	[7926]		= 8, -- Silk Bandage
	[3268]		= 7, -- Heavy Wool Bandage
	[3267]		= 7, -- Wool Bandage
	[1159]		= 6, -- Heavy Linen Bandage
	[746]		= 6 -- Linen Bandage
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
G.unitframe.HastedChannelTicks = {}

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
