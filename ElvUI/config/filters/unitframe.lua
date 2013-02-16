local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id) 	
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {['enable'] = true, ['priority'] = priorityOverride or 0}
end
G.unitframe.aurafilters = {};

--[[
	These are debuffs that are some form of CC
]]
G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		-- Death Knight
			[SpellName(47476)] = Defaults(1), --Strangulate
			[SpellName(91800)] = Defaults(1), --Gnaw (Pet)
			[SpellName(91807)] = Defaults(1), --Shambling Rush (Pet)
			[SpellName(91797)] = Defaults(1), --Monstrous Blow (Pet)
			[SpellName(108194)] = Defaults(1), --Asphyxiate
		-- Druid
			[SpellName(33786)] = Defaults(1), --Cyclone
			[SpellName(2637)] = Defaults(1), --Hibernate
			[SpellName(339)] = Defaults(1), --Entangling Roots
			[SpellName(78675)] = Defaults(1), --Solar Beam
			[SpellName(22570)] = Defaults(1), --Maim
			[SpellName(5211)] = Defaults(1), --Mighty Bash
			[SpellName(9005)] = Defaults(1), --Pounce
			[SpellName(102359)] = Defaults(1), --Mass Entanglement
			[SpellName(99)] = Defaults(1), --Disorienting Roar
			[SpellName(127797)] = Defaults(1), --Ursol's Vortex
		-- Hunter
			[SpellName(3355)] = Defaults(1), --Freezing Trap
			[SpellName(1513)] = Defaults(1), --Scare Beast
			[SpellName(19503)] = Defaults(1), --Scatter Shot
			[SpellName(34490)] = Defaults(1), --Silencing Shot
			[SpellName(24394)] = Defaults(1), --Intimidation
			[SpellName(64803)] = Defaults(1), --Entrapment
			[SpellName(19386)] = Defaults(1), --Wyvern Sting
			[SpellName(117405)] = Defaults(1), --Binding Shot
			[SpellName(50519)] = Defaults(1), --Sonic Blast (Bat)
			[SpellName(91644)] = Defaults(1), --Snatch (Bird of Prey)
			[SpellName(90337)] = Defaults(1), --Bad Manner (Monkey)
			[SpellName(54706)] = Defaults(1), --Venom Web Spray (Silithid)
			[SpellName(4167)] = Defaults(1), --Web (Spider)
			[SpellName(90327)] = Defaults(1), --Lock Jaw (Dog)
			[SpellName(56626)] = Defaults(1), --Sting (Wasp)
			[SpellName(50245)] = Defaults(1), --Pin (Crab)
			[SpellName(50541)] = Defaults(1), --Clench (Scorpid)
			[SpellName(96201)] = Defaults(1), --Web Wrap (Shale Spider)
		-- Mage
			[SpellName(31661)] = Defaults(1), --Dragon's Breath
			[SpellName(118)] = Defaults(1), --Polymorph
			[SpellName(55021)] = Defaults(1), --Silenced - Improved Counterspell
			[SpellName(122)] = Defaults(1), --Frost Nova
			[SpellName(82691)] = Defaults(1), --Ring of Frost
			[SpellName(118271)] = Defaults(1), --Combustion Impact
			[SpellName(44572)] = Defaults(1), --Deep Freeze
			[SpellName(33395)] = Defaults(1), --Freeze (Water Ele)
			[SpellName(102051)] = Defaults(1), --Frostjaw
		-- Paladin
			[SpellName(20066)] = Defaults(1), --Repentance
			[SpellName(10326)] = Defaults(1), --Turn Evil
			[SpellName(853)] = Defaults(1), --Hammer of Justice
			[SpellName(105593)] = Defaults(1), --Fist of Justice
			[SpellName(31935)] = Defaults(1), --Avenger's Shield
		-- Priest
			[SpellName(605)] = Defaults(1), --Dominate Mind
			[SpellName(64044)] = Defaults(1), --Psychic Horror
			--[SpellName(64058)] = Defaults(1), --Psychic Horror (Disarm)
			[SpellName(8122)] = Defaults(1), --Psychic Scream
			[SpellName(9484)] = Defaults(1), --Shackle Undead
			[SpellName(15487)] = Defaults(1), --Silence
			[SpellName(114404)] = Defaults(1), --Void Tendrils
			[SpellName(88625)] = Defaults(1), --Holy Word: Chastise
			[SpellName(113792)] = Defaults(1), --Psychic Terror (Psyfiend)
		-- Rogue
			[SpellName(2094)] = Defaults(1), --Blind
			[SpellName(1776)] = Defaults(1), --Gouge
			[SpellName(6770)] = Defaults(1), --Sap
			[SpellName(1833)] = Defaults(1), --Cheap Shot
			[SpellName(51722)] = Defaults(1), --Dismantle
			[SpellName(1330)] = Defaults(1), --Garrote - Silence
			[SpellName(408)] = Defaults(1), --Kidney Shot
			[SpellName(88611)] = Defaults(1), --Smoke Bomb
			[SpellName(115197)] = Defaults(1), --Partial Paralytic
			[SpellName(113953)] = Defaults(1), --Paralysis
		-- Shaman
			[SpellName(51514)] = Defaults(1), --Hex
			[SpellName(64695)] = Defaults(1), --Earthgrab
			[SpellName(63685)] = Defaults(1), --Freeze (Frozen Power)
			[SpellName(76780)] = Defaults(1), --Bind Elemental
			[SpellName(118905)] = Defaults(1), --Static Charge
		-- Warlock
			[SpellName(710)] = Defaults(1), --Banish
			[SpellName(6789)] = Defaults(1), --Mortal Coil
			[SpellName(118699)] = Defaults(1), --Fear
			[SpellName(5484)] = Defaults(1), --Howl of Terror
			[SpellName(6358)] = Defaults(1), --Seduction
			[SpellName(30283)] = Defaults(1), --Shadowfury
			[SpellName(24259)] = Defaults(1), --Spell Lock (Felhunter)
			[SpellName(115782)] = Defaults(1), --Optical Blast (Observer)
			[SpellName(115268)] = Defaults(1), --Mesmerize (Shivarra)
			[SpellName(118093)] = Defaults(1), --Disarm (Voidwalker)
			[SpellName(89766)] = Defaults(1), --Axe Toss (Felguard)
		-- Warrior
			[SpellName(20511)] = Defaults(1), --Intimidating Shout
			[SpellName(7922)] = Defaults(1), --Charge Stun
			[SpellName(676)] = Defaults(1), --Disarm
			[SpellName(105771)] = Defaults(1), --Warbringer
			[SpellName(107566)] = Defaults(1), --Staggering Shout
			[SpellName(132168)] = Defaults(1), --Shockwave
			[SpellName(107570)] = Defaults(1), --Storm Bolt
			[SpellName(118895)] = Defaults(1), --Dragon Roar
			[SpellName(18498)] = Defaults(1), --Gag Order
		-- Monk
			[SpellName(116706)] = Defaults(1), --Disable
			[SpellName(117368)] = Defaults(1), --Grapple Weapon
			[SpellName(115078)] = Defaults(1), --Paralysis
			[SpellName(122242)] = Defaults(1), --Clash
			[SpellName(119392)] = Defaults(1), --Charging Ox Wave
			[SpellName(119381)] = Defaults(1), --Leg Sweep
			[SpellName(120086)] = Defaults(1), --Fists of Fury
			[SpellName(116709)] = Defaults(1), --Spear Hand Strike
			[SpellName(123407)] = Defaults(1), --Spinning Fire Blossom
		-- Racial
			[SpellName(25046)] = Defaults(1), --Arcane Torrent
			[SpellName(20549)] = Defaults(1), --War Stomp
			[SpellName(107079)] = Defaults(1), --Quaking Palm
	},
}

--[[
	These are buffs that can be considered "protection" buffs
]]
G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mage
			[SpellName(45438)] = Defaults(5), -- Ice Block
			[SpellName(115610)] = Defaults(), -- Temporal Shield
		--Death Knight
			[SpellName(48797)] = Defaults(5), -- Anti-Magic Shell
			[SpellName(48792)] = Defaults(), -- Icebound Fortitude
			[SpellName(49039)] = Defaults(), -- Lichborne
			[SpellName(87256)] = Defaults(4), -- Dancing Rune Weapon
			[SpellName(55233)] = Defaults(), -- Vampiric Blood
			[SpellName(50461)] = Defaults(), -- Anti-Magic Zone
		--Priest
			[SpellName(33206)] = Defaults(3), -- Pain Suppression
			[SpellName(47788)] = Defaults(), -- Guardian Spirit
			[SpellName(62618)] = Defaults(), -- Power Word: Barrier
			[SpellName(47585)] = Defaults(5), -- Dispersion
		--Warlock
			[SpellName(104773)] = Defaults(), -- Unending Resolve
			[SpellName(110913)] = Defaults(), -- Dark Bargain
			[SpellName(108359)] = Defaults(), -- Dark Regeneration
		--Druid
			[SpellName(22812)] = Defaults(2), -- Barkskin
			[SpellName(102342)] = Defaults(2), -- Ironbark
			[SpellName(106922)] = Defaults(), -- Might of Ursoc
			[SpellName(61336)] = Defaults(), -- Survival Instincts
		--Hunter
			[SpellName(19263)] = Defaults(5), -- Deterrence
			[SpellName(53480)] = Defaults(), -- Roar of Sacrifice (Cunning)
		--Rogue
			[SpellName(31224)] = Defaults(), -- Cloak of Shadows
			[SpellName(74001)] = Defaults(), -- Combat Readiness
			--[SpellName(74002)] = Defaults(), -- Combat Insight (stacking buff from CR)
			[SpellName(5277)] = Defaults(5), -- Evasion
			[SpellName(45182)] = Defaults(), -- Cheating Death
		--Shaman
			[SpellName(98007)] = Defaults(), -- Spirit Link Totem
			[SpellName(30823)] = Defaults(), -- Shamanistic Rage
			[SpellName(108271)] = Defaults(), -- Astral Shift
		--Paladin
			[SpellName(1044)] = Defaults(), -- Hand of Freedom
			[SpellName(1022)] = Defaults(5), -- Hand of Protection
			[SpellName(1038)] = Defaults(), -- Hand of Salvation
			[SpellName(6940)] = Defaults(), -- Hand of Sacrifice
			[SpellName(114039)] = Defaults(), -- Hand of Purity
			[SpellName(31821)] = Defaults(3), -- Devotion Aura
			[SpellName(498)] = Defaults(2), -- Divine Protection
			[SpellName(642)] = Defaults(5), -- Divine Shield
			[SpellName(86659)] = Defaults(4), -- Guardian of the Ancient Kings (Prot)
			[SpellName(31850)] = Defaults(4), -- Ardent Defender
		--Warrior
			[SpellName(118038)] = Defaults(5), -- Die by the Sword
			[SpellName(55694)] = Defaults(), -- Enraged Regeneration
			[SpellName(97463)] = Defaults(), -- Rallying Cry
			[SpellName(12975)] = Defaults(), -- Last Stand
			[SpellName(114029)] = Defaults(2), -- Safeguard
			[SpellName(871)] = Defaults(3), -- Shield Wall
			[SpellName(114030)] = Defaults(), -- Vigilance
		--Monk
			[SpellName(120954)] = Defaults(2), -- Fortifying Brew
			[SpellName(131523)] = Defaults(5), -- Zen Meditation
			[SpellName(122783)] = Defaults(), -- Diffuse Magic
			[SpellName(122278)] = Defaults(), -- Dampen Harm
			[SpellName(115213)] = Defaults(), -- Avert Harm
			[SpellName(116849)] = Defaults(), -- Life Cocoon
		--Racial
			[SpellName(20594)] = Defaults(), -- Stoneform
	},
}

G.unitframe.aurafilters['PlayerBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mage
			[SpellName(45438)] = Defaults(), -- Ice Block
			[SpellName(115610)] = Defaults(), -- Temporal Shield
			[SpellName(110909)] = Defaults(), -- Alter Time
			[SpellName(12051)] = Defaults(), -- Evocation
			[SpellName(12472)] = Defaults(), -- Icy Veins
			[SpellName(80353)] = Defaults(), -- Time Warp
			[SpellName(12042)] = Defaults(), -- Arcane Power
			[SpellName(32612)] = Defaults(), -- Invisibility
			[SpellName(110960)] = Defaults(), -- Greater Invisibility
			[SpellName(108839)] = Defaults(), -- Ice Flows
			[SpellName(111264)] = Defaults(), -- Ice Ward
			[SpellName(108843)] = Defaults(), -- Blazing Speed
		--Death Knight
			[SpellName(48797)] = Defaults(), -- Anti-Magic Shell
			[SpellName(48792)] = Defaults(), -- Icebound Fortitude
			[SpellName(49039)] = Defaults(), -- Lichborne
			[SpellName(87256)] = Defaults(), -- Dancing Rune Weapon
			[SpellName(49222)] = Defaults(), -- Bone Shield
			[SpellName(55233)] = Defaults(), -- Vampiric Blood
			[SpellName(50461)] = Defaults(), -- Anti-Magic Zone
			[SpellName(49016)] = Defaults(), -- Unholy Frenzy
			[SpellName(51271)] = Defaults(), -- Pillar of Frost
			[SpellName(96268)] = Defaults(), -- Death's Advance
		--Priest
			[SpellName(33206)] = Defaults(), -- Pain Suppression
			[SpellName(47788)] = Defaults(), -- Guardian Spirit
			[SpellName(62618)] = Defaults(), -- Power Word: Barrier
			[SpellName(47585)] = Defaults(), -- Dispersion
			[SpellName(6346)] = Defaults(), -- Fear Ward
			[SpellName(10060)] = Defaults(), -- Power Infusion
			[SpellName(114239)] = Defaults(), -- Phantasm
			[SpellName(119032)] = Defaults(), -- Spectral Guise
			[SpellName(27827)] = Defaults(), -- Spirit of Redemption
		--Warlock
			[SpellName(104773)] = Defaults(), -- Unending Resolve
			[SpellName(110913)] = Defaults(), -- Dark Bargain
			[SpellName(108359)] = Defaults(), -- Dark Regeneration
			[SpellName(113860)] = Defaults(), -- Dark Sould: Misery
			[SpellName(113861)] = Defaults(), -- Dark Soul: Knowledge
			[SpellName(113858)] = Defaults(), -- Dark Soul: Instability
			[SpellName(88448)] = Defaults(), -- Demonic Rebirth
		--Druid
			[SpellName(22812)] = Defaults(), -- Barkskin
			[SpellName(102342)] = Defaults(), -- Ironbark
			[SpellName(106922)] = Defaults(), -- Might of Ursoc
			[SpellName(61336)] = Defaults(), -- Survival Instincts
			[SpellName(117679)] = Defaults(), -- Incarnation (Tree of Life)
			[SpellName(102543)] = Defaults(), -- Incarnation: King of the Jungle
			[SpellName(102558)] = Defaults(), -- Incarnation: Son of Ursoc
			[SpellName(102560)] = Defaults(), -- Incarnation: Chosen of Elune
			[SpellName(16689)] = Defaults(), -- Nature's Grasp
			[SpellName(132158)] = Defaults(), -- Nature's Swiftness
			[SpellName(106898)] = Defaults(), -- Stampeding Roar
			[SpellName(1850)] = Defaults(), -- Dash
			[SpellName(106951)] = Defaults(), -- Berserk
			[SpellName(29166)] = Defaults(), -- Innervate
			[SpellName(52610)] = Defaults(), -- Savage Roar
			[SpellName(69369)] = Defaults(), -- Predatory Swiftness
			[SpellName(112071)] = Defaults(), -- Celestial Alignment
			[SpellName(124974)] = Defaults(), -- Nature's Vigil
		--Hunter
			[SpellName(19263)] = Defaults(), -- Deterrence
			[SpellName(53480)] = Defaults(), -- Roar of Sacrifice (Cunning)
			[SpellName(51755)] = Defaults(), -- Camouflage
			[SpellName(54216)] = Defaults(), -- Master's Call
			[SpellName(34471)] = Defaults(), -- The Beast Within
			[SpellName(3045)] = Defaults(), -- Rapid Fire
			[SpellName(3584)] = Defaults(), -- Feign Death
			[SpellName(131894)] = Defaults(), -- A Murder of Crows
			[SpellName(90355)] = Defaults(), -- Ancient Hysteria
			[SpellName(90361)] = Defaults(), -- Spirit Mend
		--Rogue
			[SpellName(31224)] = Defaults(), -- Cloak of Shadows
			[SpellName(74001)] = Defaults(), -- Combat Readiness
			--[SpellName(74002)] = Defaults(), -- Combat Insight (stacking buff from CR)
			[SpellName(5277)] = Defaults(), -- Evasion
			[SpellName(45182)] = Defaults(), -- Cheating Death
			[SpellName(51713)] = Defaults(), -- Shadow Dance
			[SpellName(114018)] = Defaults(), -- Shroud of Concealment
			[SpellName(2983)] = Defaults(), -- Sprint
			[SpellName(121471)] = Defaults(), -- Shadow Blades
			[SpellName(11327)] = Defaults(), -- Vanish
			[SpellName(108212)] = Defaults(), -- Burst of Speed
			[SpellName(57933)] = Defaults(), -- Tricks of the Trade
			[SpellName(79140)] = Defaults(), -- Vendetta
			[SpellName(13750)] = Defaults(), -- Adrenaline Rush
		--Shaman
			[SpellName(98007)] = Defaults(), -- Spirit Link Totem
			[SpellName(30823)] = Defaults(), -- Shamanistic Rage
			[SpellName(108271)] = Defaults(), -- Astral Shift
			[SpellName(16188)] = Defaults(), -- Ancestral Swiftness
			[SpellName(2825)] = Defaults(), -- Bloodlust
			[SpellName(79206)] = Defaults(), -- Spiritwalker's Grace
			[SpellName(16191)] = Defaults(), -- Mana Tide
			[SpellName(8178)] = Defaults(), -- Grounding Totem Effect
			[SpellName(58875)] = Defaults(), -- Spirit Walk
			[SpellName(108281)] = Defaults(), -- Ancestral Guidance
			[SpellName(108271)] = Defaults(), -- Astral Shift
			[SpellName(16166)] = Defaults(), -- Elemental Mastery
			[SpellName(114896)] = Defaults(), -- Windwalk Totem
		--Paladin
			[SpellName(1044)] = Defaults(), -- Hand of Freedom
			[SpellName(1022)] = Defaults(), -- Hand of Protection
			[SpellName(1038)] = Defaults(), -- Hand of Salvation
			[SpellName(6940)] = Defaults(), -- Hand of Sacrifice
			[SpellName(114039)] = Defaults(), -- Hand of Purity
			[SpellName(31821)] = Defaults(), -- Devotion Aura
			[SpellName(498)] = Defaults(), -- Divine Protection
			[SpellName(642)] = Defaults(), -- Divine Shield
			[SpellName(86659)] = Defaults(), -- Guardian of the Ancient Kings (Prot)
			[SpellName(20925)] = Defaults(), -- Sacred Shield
			[SpellName(31850)] = Defaults(), -- Ardent Defender
			[SpellName(31884)] = Defaults(), -- Avenging Wrath
			[SpellName(53563)] = Defaults(), -- Beacon of Light
			[SpellName(31842)] = Defaults(), -- Divine Favor
			[SpellName(54428)] = Defaults(), -- Divine Plea
			[SpellName(105809)] = Defaults(), -- Holy Avenger
			[SpellName(85499)] = Defaults(), -- Speed of Light
		--Warrior
			[SpellName(118038)] = Defaults(), -- Die by the Sword
			[SpellName(55694)] = Defaults(), -- Enraged Regeneration
			[SpellName(97463)] = Defaults(), -- Rallying Cry
			[SpellName(12975)] = Defaults(), -- Last Stand
			[SpellName(114029)] = Defaults(), -- Safeguard
			[SpellName(871)] = Defaults(), -- Shield Wall
			[SpellName(114030)] = Defaults(), -- Vigilance
			[SpellName(18499)] = Defaults(), -- Berserker Rage
			--[SpellName(85730)] = Defaults(), -- Deadly Calm
			[SpellName(1719)] = Defaults(), -- Recklessness
			[SpellName(23920)] = Defaults(), -- Spell Reflection
			[SpellName(114028)] = Defaults(), -- Mass Spell Reflection
			[SpellName(46924)] = Defaults(), -- Bladestorm
			[SpellName(3411)] = Defaults(), -- Intervene
			[SpellName(107574)] = Defaults(), -- Avatar
		--Monk
			[SpellName(120954)] = Defaults(), -- Fortifying Brew
			[SpellName(131523)] = Defaults(), -- Zen Meditation
			[SpellName(122783)] = Defaults(), -- Diffuse Magic
			[SpellName(122278)] = Defaults(), -- Dampen Harm
			[SpellName(115213)] = Defaults(), -- Avert Harm
			[SpellName(116849)] = Defaults(), -- Life Cocoon
			[SpellName(125174)] = Defaults(), -- Touch of Karma
			[SpellName(116841)] = Defaults(), -- Tiger's Lust
		--Racial
			[SpellName(20594)] = Defaults(), -- Stoneform
			[SpellName(59545)] = Defaults(), -- Gift of the Naaru
			[SpellName(20572)] = Defaults(), -- Blood Fury
			[SpellName(26297)] = Defaults(), -- Berserking
			[SpellName(68992)] = Defaults(), -- Darkflight
	},
}



--[[
	Buffs that really we dont need to see
]]

G.unitframe.aurafilters['Blacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[SpellName(36032)] = Defaults(), -- Arcane Charge
		[SpellName(76691)] = Defaults(), -- Vengeance
		[SpellName(8733)] = Defaults(), --Blessing of Blackfathom
		[SpellName(57724)] = Defaults(), --Sated
		[SpellName(25771)] = Defaults(), --forbearance
		[SpellName(57723)] = Defaults(), --Exhaustion
		[SpellName(36032)] = Defaults(), --arcane blast
		[SpellName(58539)] = Defaults(), --watchers corpse
		[SpellName(26013)] = Defaults(), --deserter
		[SpellName(6788)] = Defaults(), --weakended soul
		[SpellName(71041)] = Defaults(), --dungeon deserter
		[SpellName(41425)] = Defaults(), --"Hypothermia"
		[SpellName(55711)] = Defaults(), --Weakened Heart
		[SpellName(8326)] = Defaults(), --ghost
		[SpellName(23445)] = Defaults(), --evil twin
		[SpellName(24755)] = Defaults(), --gay homosexual tricked or treated debuff
		[SpellName(25163)] = Defaults(), --fucking annoying pet debuff oozeling disgusting aura
		[SpellName(80354)] = Defaults(), --timewarp debuff
		[SpellName(95223)] = Defaults(), --group res debuff
		[SpellName(124275)] = Defaults(), -- Stagger
		[SpellName(124274)] = Defaults(), -- Stagger
		[SpellName(124273)] = Defaults() -- Stagger
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc.. 
]]

G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(2825)] = Defaults(), -- Bloodlust
		[SpellName(32182)] = Defaults(), -- Heroism	
		[SpellName(80353)] = Defaults(), --Time Warp
		[SpellName(90355)] = Defaults(), --Ancient Hysteria		
	},
}

--RAID DEBUFFS
--[[
	This should be pretty self explainitory
]]
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Blackwing Descent
			--Magmaw
			[SpellName(79589)] = Defaults(), -- Constricting Chains
			[SpellName(78941)] = Defaults(), -- Parasitic Infection
			[SpellName(89773)] = Defaults(), -- Mangle
			[SpellName(78199)] = Defaults(), -- Sweltering Armor

			--Omintron Defense System
			[SpellName(79888)] = Defaults(), --Lightning Conductor
			[SpellName(79035)] = Defaults(), --Incineration Security Measure
			[SpellName(120018)] = Defaults(), --Fixate 

			--Maloriak
			[SpellName(77711)] = Defaults(), -- Flash Freeze
			[SpellName(77760)] = Defaults(), -- Biting Chill

			--Atramedes
			[SpellName(76246)] = Defaults(), -- Searing Flame
			[SpellName(78555)] = Defaults(), -- Roaring Flame
			[SpellName(78098)] = Defaults(), -- Sonic Breath

			--Chimaeron
			[SpellName(82881)] = Defaults(), -- Break
			[SpellName(89084)] = Defaults(), -- Low Health

			--Nefarian

			--Sinestra
			[SpellName(89435)] = Defaults(), --Wrack

		--The Bastion of Twilight
			--Valiona & Theralion
			[SpellName(86825)] = Defaults(), -- Blackout
			[SpellName(86631)] = Defaults(), -- Engulfing Magic
			[SpellName(86214)] = Defaults(), -- Twilight Zone
			[SpellName(88518)] = Defaults(), -- Twilight Meteorite

			--Halfus Wyrmbreaker
			[SpellName(83908)] = Defaults(), -- Malevolent Strikes

			--Twilight Ascendant Council
			[SpellName(125988)] = Defaults(), -- Hydro Lance
			[SpellName(82762)] = Defaults(), -- Waterlogged
			[SpellName(50635)] = Defaults(), -- Frozen
			[SpellName(100795)] = Defaults(), -- Flame Torrent
			[SpellName(105342)] = Defaults(), -- Lightning Rod
			[SpellName(92075)] = Defaults(), -- Gravity Core

			--Cho'gall
			[SpellName(86028)] = Defaults(), -- Cho's Blast
			[SpellName(86029)] = Defaults(), -- Gall's Blast

		--Throne of the Four Winds
			--Conclave of Wind
				--Nezir <Lord of the North Wind>
				[SpellName(86122)] = Defaults(), --Ice Patch
				--Anshal <Lord of the West Wind>
				[SpellName(86206)] = Defaults(), --Soothing Breeze
				[SpellName(86290)] = Defaults(), --Toxic Spores
				--Rohash <Lord of the East Wind>
				[SpellName(86182)] = Defaults(), --Slicing Gale
				
			--Al'Akir
			[SpellName(87470)] = Defaults(), -- Ice Storm
			[SpellName(105342)] = Defaults(), -- Lightning Rod
			
		--Firelands	
			--Beth'tilac
			[SpellName(99506)] = Defaults(), -- Widows Kiss
			
			--Alysrazor
			[SpellName(100024)] = Defaults(), -- Gushing Wound
			
			--Shannox
			[SpellName(99837)] = Defaults(), -- Crystal Prison
			[SpellName(99937)] = Defaults(), -- Jagged Tear
			
			--Baleroc
			[SpellName(99257)] = Defaults(), -- Tormented
			[SpellName(99256)] = Defaults(), -- Torment
			
			--Lord Rhyolith
				--<< NONE KNOWN YET >>
			
			--Majordomo Staghelm
			[SpellName(98450)] = Defaults(), -- Searing Seeds
			[SpellName(98565)] = Defaults(), -- Burning Orb
			
			--Ragnaros
			[SpellName(99399)] = Defaults(), -- Burning Wound
				
			--Trash
			[SpellName(99532)] = Defaults(), -- Melt Armor	
			
		--Baradin Hold
			--Occu'thar
			[SpellName(96913)] = Defaults(), -- Searing Shadows
			--Alizabal
			[SpellName(104936)] = Defaults(), -- Skewer
			
		--Dragon Soul
			--Morchok
			[SpellName(103541)] = Defaults(), -- Safe
			[SpellName(103536)] = Defaults(), -- Warning
			[SpellName(103534)] = Defaults(), -- Danger
			[SpellName(103785)] = Defaults(), -- Black Blood of the Earth

			--Warlord Zon'ozz
			[SpellName(103434)] = Defaults(), -- Disrupting Shadows

			--Yor'sahj the Unsleeping
			[SpellName(105171)] = Defaults(), -- Deep Corruption

			--Hagara the Stormbinder
			[SpellName(105465)] = Defaults(), -- Lighting Storm
			[SpellName(104451)] = Defaults(), -- Ice Tomb
			[SpellName(109325)] = Defaults(), -- Frostflake
			[SpellName(105289)] = Defaults(), -- Shattered Ice
			[SpellName(105285)] = Defaults(), -- Target

			--Ultraxion
			[SpellName(109075)] = Defaults(), -- Fading Light

			--Warmaster Blackhorn
			[SpellName(108043)] = Defaults(), -- Sunder Armor
			[SpellName(107558)] = Defaults(), -- Degeneration
			[SpellName(107567)] = Defaults(), -- Brutal Strike
			[SpellName(108046)] = Defaults(), -- Shockwave

			--Spine of Deathwing
			[SpellName(105479)] = Defaults(), -- Searing Plasma
			[SpellName(105490)] = Defaults(), -- Fiery Grip
			[SpellName(106199)] = { 
				['enable'] = true,
				['priority'] = 5,
			}, -- Blood Corruption: Death
			
			--Madness of Deathwing
			[SpellName(105841)] = Defaults(), -- Degenerative Bite
			[SpellName(106385)] = Defaults(), -- Crush
			[SpellName(106730)] = Defaults(), -- Tetanus
			[SpellName(106444)] = Defaults(), -- Impale
			[SpellName(106794)] = Defaults(), -- Shrapnel (target)			
	
	   -- Mogu'shan Vaults
			-- The Stone Guard
			[SpellName(116281)] = Defaults(), -- Cobalt Mine Blast
			-- Feng the Accursed
			[SpellName(116784)] = Defaults(), -- Wildfire Spark
			[SpellName(116417)] = Defaults(), -- Arcane Resonance
			[SpellName(116942)] = Defaults(), -- Flaming Spear
			-- Gara'jal the Spiritbinder
			[SpellName(116161)] = Defaults(), -- Crossed Over
			-- The Spirit Kings
			[SpellName(117708)] = Defaults(), -- Maddening Shout
			[SpellName(118303)] = Defaults(), -- Fixate
			[SpellName(118048)] = Defaults(), -- Pillaged
			[SpellName(118135)] = Defaults(), -- Pinned Down
			-- Elegon
			[SpellName(117878)] = Defaults(), -- Overcharged
			[SpellName(117949)] = Defaults(), -- Closed Circuit
			-- Will of the Emperor
			[SpellName(116835)] = Defaults(), -- Devastating Arc
			[SpellName(116778)] = Defaults(), -- Focused Defense
			[SpellName(116525)] = Defaults(), -- Focused Assault    
		-- Heart of Fear
			-- Imperial Vizier Zor'lok
			[SpellName(122761)] = Defaults(), -- Exhale
			[SpellName(122760)] = Defaults(), -- Exhale
			[SpellName(122740)] = Defaults(), -- Convert
			[SpellName(123812)] = Defaults(), -- Pheromones of Zeal
			-- Blade Lord Ta'yak
			[SpellName(123180)] = Defaults(), -- Wind Step
			[SpellName(123474)] = Defaults(), -- Overwhelming Assault
			-- Garalon
			[SpellName(122835)] = Defaults(), -- Pheromones
			[SpellName(123081)] = Defaults(), -- Pungency
			-- Wind Lord Mel'jarak
			[SpellName(122125)] = Defaults(), -- Corrosive Resin Pool
			[SpellName(121885)] = Defaults(), -- Amber Prison
			-- Wind Lord Mel'jarak
			[SpellName(121949)] = Defaults(), -- Parasitic Growth
			-- Grand Empress Shek'zeer
		-- Terrace of Endless Spring
			-- Protectors of the Endless
			[SpellName(117436)] = Defaults(), -- Lightning Prison
			[SpellName(118091)] = Defaults(), -- Defiled Ground
			[SpellName(117519)] = Defaults(), -- Touch of Sha
			-- Tsulong
			[SpellName(122752)] = Defaults(), -- Shadow Breath
			[SpellName(123011)] = Defaults(), -- Terrorize
			[SpellName(116161)] = Defaults(), -- Crossed Over
			-- Lei Shi
			[SpellName(123121)] = Defaults(), -- Spray
			-- Sha of Fear
			[SpellName(119985)] = Defaults(), -- Dread Spray
			[SpellName(119086)] = Defaults(), -- Penetrating Bolt
			[SpellName(119775)] = Defaults(), -- Reaching Attack	
			
			
			[SpellName(122151)] = Defaults(), -- Voodoo Doll
	},
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, textColor, textThreshold)
	local r, g, b = unpack(color)
	
	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end
	
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, 
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ['style'] = style or 'coloredIcon', ['displayText'] = displayText or false, 
	['textColor'] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ['textThreshold'] = textThreshold or -1}
end

G.unitframe.buffwatch = {
	PRIEST = {
		ClassBuff(6788, "TOPRIGHT", {1, 0, 0}, true),	 -- Weakened Soul
		ClassBuff(41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}),	 -- Prayer of Mending
		ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		ClassBuff(17, "TOPLEFT", {0.81, 0.85, 0.1}, true),	 -- Power Word: Shield
		ClassBuff(123258, "TOPLEFT", {0.81, 0.85, 0.1}, true),	 -- Power Word: Shield Power Insight
		ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		ClassBuff(47788, "LEFT", {221/255, 117/255, 0}, true), -- Guardian Spirit
		ClassBuff(33206, "LEFT", {227/255, 23/255, 13/255}, true), -- Pain Suppression		
	},
	DRUID = {
		ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}),	 -- Rejuvenation
		ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}),	 -- Regrowth
		ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}),	 -- Lifebloom
		ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}),	 -- Wild Growth
	},
	PALADIN = {
		ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}),	 -- Beacon of Light
		ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),	-- Hand of Protection
		ClassBuff(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true),	-- Hand of Freedom
		ClassBuff(1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true),	-- Hand of Salvation
		ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true),	-- Hand of Sacrifice
		ClassBuff(114039, "BOTTOMRIGHT", {164/255, 105/255, 184/255}), -- Hand of Purity
		ClassBuff(20925, 'TOPLEFT', {0.93, 0.75, 0}), -- Sacred Shield
	},
	SHAMAN = {
		ClassBuff(61295, "TOPRIGHT", {0.7, 0.3, 0.7}),	 -- Riptide
		ClassBuff(974, "BOTTOMLEFT", {0.2, 0.7, 0.2}, true),	 -- Earth Shield
		ClassBuff(51945, "BOTTOMRIGHT", {0.7, 0.4, 0}),	 -- Earthliving
	},
	MONK = {
		ClassBuff(119611, "TOPLEFT", {0.8, 0.4, 0.8}),	 --Renewing Mist
		ClassBuff(116849, "TOPRIGHT", {0.2, 0.8, 0.2}),	 -- Life Cocoon
		ClassBuff(132120, "BOTTOMLEFT", {0.4, 0.8, 0.2}), -- Enveloping Mist
		ClassBuff(124081, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Zen Sphere
	},
	ROGUE = {
		ClassBuff(57934, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Tricks of the Trade
	},
	MAGE = {
		ClassBuff(111264, "TOPLEFT", {0.2, 0.2, 1}), -- Ice Ward
	},
	WARRIOR = {
		ClassBuff(114030, "TOPLEFT", {0.2, 0.2, 1}), -- Vigilance
		ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene	
		ClassBuff(114029, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Safe Guard
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Unholy Frenzy	
	},
	PET = {
		ClassBuff(19615, 'TOPLEFT', {227/255, 23/255, 13/255}, true), -- Frenzy
		ClassBuff(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true) --Mend Pet
	},
}

--List of spells to display ticks
G.unitframe.ChannelTicks = {
	--Warlock
	[SpellName(1120)] = 6, --"Drain Soul"
	[SpellName(689)] = 6, -- "Drain Life"
	[SpellName(108371)] = 6, -- "Harvest Life"
	[SpellName(5740)] = 4, -- "Rain of Fire"
	[SpellName(755)] = 6, -- Health Funnel
	[SpellName(103103)] = 4, --Malefic Grasp
	--Druid
	[SpellName(44203)] = 4, -- "Tranquility"
	[SpellName(16914)] = 10, -- "Hurricane"
	--Priest
	[SpellName(15407)] = 3, -- "Mind Flay"
	[SpellName(48045)] = 5, -- "Mind Sear"
	[SpellName(47540)] = 2, -- "Penance"
	[SpellName(64901)] = 4, -- Hymn of Hope
	[SpellName(64843)] = 4, -- Divine Hymn
	--Mage
	[SpellName(5143)] = 5, -- "Arcane Missiles"
	[SpellName(10)] = 8, -- "Blizzard"
	[SpellName(12051)] = 4, -- "Evocation"
}

G.unitframe.ChannelTicksSize = {
    --Warlock
    [SpellName(1120)] = 2, --"Drain Soul"
    [SpellName(689)] = 1, -- "Drain Life"
	[SpellName(108371)] = 1, -- "Harvest Life"
	[SpellName(103103)] = 1, -- "Malefic Grasp"
}

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	[SpellName(64901)] = true, -- Hymn of Hope
	[SpellName(64843)] = true, -- Divine Hymn
}

--This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	--Bloodlust
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255}, --Heroism
	[SpellName(80353)] = {r = 250/255, g = 146/255, b = 27/255}, --Time Warp
	[SpellName(90355)] = {r = 250/255, g = 146/255, b = 27/255}, --Ancient Hysteria
	[SpellName(84963)] = {r = 250/255, g = 146/255, b = 27/255}, --Inquisition
}

G.unitframe.InvalidSpells = {
	[65148] = true,
}