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

local function DefaultsID(spellID, priorityOverride)
	return {['enable'] = true, ['spellID'] = spellID, ['priority'] = priorityOverride or 0}
end
G.unitframe.aurafilters = {};

--[[
	These are debuffs that are some form of CC
]]
G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		-- Death Knight
			[SpellName(47476)] = Defaults(), --Strangulate
			[SpellName(91800)] = Defaults(), --Gnaw (Pet)
			[SpellName(91807)] = Defaults(), --Shambling Rush (Pet)
			[SpellName(91797)] = Defaults(), --Monstrous Blow (Pet)
			[SpellName(108194)] = Defaults(), --Asphyxiate
			[SpellName(115001)] = Defaults(), --Remorseless Winter
		-- Druid
			[SpellName(33786)] = Defaults(), --Cyclone
			--[SpellName(2637)] = Defaults(), --Hibernate
			[SpellName(339)] = Defaults(), --Entangling Roots
			[SpellName(78675)] = Defaults(), --Solar Beam
			[SpellName(22570)] = Defaults(), --Maim
			[SpellName(5211)] = Defaults(), --Mighty Bash
			--[SpellName(9005)] = Defaults(), --Pounce
			[SpellName(102359)] = Defaults(), --Mass Entanglement
			[SpellName(99)] = Defaults(), --Disorienting Roar
			[SpellName(127797)] = Defaults(), --Ursol's Vortex
			[SpellName(45334)] = Defaults(), --Immobilized
			--[SpellName(102795)] = Defaults(), --Bear Hug
			[SpellName(114238)] = Defaults(), --Fae Silence
			--[SpellName(113004)] = Defaults(), --Intimidating Roar (Warrior Symbiosis)
		-- Hunter
			[SpellName(3355)] = Defaults(), --Freezing Trap
			--[SpellName(1513)] = Defaults(), --Scare Beast
			--[SpellName(19503)] = Defaults(), --Scatter Shot
			--[SpellName(34490)] = Defaults(), --Silencing Shot
			[SpellName(24394)] = Defaults(), --Intimidation
			[SpellName(64803)] = Defaults(), --Entrapment
			[SpellName(19386)] = Defaults(), --Wyvern Sting
			[SpellName(117405)] = Defaults(), --Binding Shot
			[SpellName(128405)] = Defaults(), --Narrow Escape
			--[SpellName(50519)] = Defaults(), --Sonic Blast (Bat)
			--[SpellName(91644)] = Defaults(), --Snatch (Bird of Prey)
			--[SpellName(90337)] = Defaults(), --Bad Manner (Monkey)
			--[SpellName(54706)] = Defaults(), --Venom Web Spray (Silithid)
			--[SpellName(4167)] = Defaults(), --Web (Spider)
			--[SpellName(90327)] = Defaults(), --Lock Jaw (Dog)
			--[SpellName(56626)] = Defaults(), --Sting (Wasp)
			--[SpellName(50245)] = Defaults(), --Pin (Crab)
			--[SpellName(50541)] = Defaults(), --Clench (Scorpid)
			--[SpellName(96201)] = Defaults(), --Web Wrap (Shale Spider)
			--[SpellName(96201)] = Defaults(), --Lullaby (Crane)
		-- Mage
			[SpellName(31661)] = Defaults(), --Dragon's Breath
			[SpellName(118)] = Defaults(), --Polymorph
			--[SpellName(55021)] = Defaults(), --Silenced - Improved Counterspell
			[SpellName(122)] = Defaults(), --Frost Nova
			[SpellName(82691)] = Defaults(), --Ring of Frost
			--[SpellName(118271)] = Defaults(), --Combustion Impact
			[SpellName(44572)] = Defaults(), --Deep Freeze
			[SpellName(33395)] = Defaults(), --Freeze (Water Ele)
			[SpellName(102051)] = Defaults(), --Frostjaw
		-- Paladin
			[SpellName(20066)] = Defaults(), --Repentance
			[SpellName(10326)] = Defaults(), --Turn Evil
			[SpellName(853)] = Defaults(), --Hammer of Justice
			[SpellName(105593)] = Defaults(), --Fist of Justice
			[SpellName(31935)] = Defaults(), --Avenger's Shield
			[SpellName(105421)] = Defaults(), --Blinding Light
		-- Priest
			[SpellName(605)] = Defaults(), --Dominate Mind
			[SpellName(64044)] = Defaults(), --Psychic Horror
			--[SpellName(64058)] = Defaults(), --Psychic Horror (Disarm)
			[SpellName(8122)] = Defaults(), --Psychic Scream
			[SpellName(9484)] = Defaults(), --Shackle Undead
			[SpellName(15487)] = Defaults(), --Silence
			[SpellName(114404)] = Defaults(), --Void Tendrils
			[SpellName(88625)] = Defaults(), --Holy Word: Chastise
			--[SpellName(113792)] = Defaults(), --Psychic Terror (Psyfiend)
			[SpellName(87194)] = Defaults(), --Sin and Punishment
		-- Rogue
			[SpellName(2094)] = Defaults(), --Blind
			[SpellName(1776)] = Defaults(), --Gouge
			[SpellName(6770)] = Defaults(), --Sap
			[SpellName(1833)] = Defaults(), --Cheap Shot
			--[SpellName(51722)] = Defaults(), --Dismantle
			[SpellName(1330)] = Defaults(), --Garrote - Silence
			[SpellName(408)] = Defaults(), --Kidney Shot
			[SpellName(88611)] = Defaults(), --Smoke Bomb
			--[SpellName(115197)] = Defaults(), --Partial Paralytic
			--[SpellName(113953)] = Defaults(), --Paralysis
		-- Shaman
			[SpellName(51514)] = Defaults(), --Hex
			[SpellName(64695)] = Defaults(), --Earthgrab
			[SpellName(63685)] = Defaults(), --Freeze (Frozen Power)
			--[SpellName(76780)] = Defaults(), --Bind Elemental
			[SpellName(118905)] = Defaults(), --Static Charge
			[SpellName(118345)] = Defaults(), --Pulverize (Earth Elemental)
		-- Warlock
			[SpellName(710)] = Defaults(), --Banish
			[SpellName(6789)] = Defaults(), --Mortal Coil
			[SpellName(118699)] = Defaults(), --Fear
			[SpellName(5484)] = Defaults(), --Howl of Terror
			[SpellName(6358)] = Defaults(), --Seduction
			[SpellName(30283)] = Defaults(), --Shadowfury
			--[SpellName(24259)] = Defaults(), --Spell Lock (Felhunter)
			--[SpellName(115782)] = Defaults(), --Optical Blast (Observer)
			[SpellName(115268)] = Defaults(), --Mesmerize (Shivarra)
			--[SpellName(118093)] = Defaults(), --Disarm (Voidwalker)
			[SpellName(89766)] = Defaults(), --Axe Toss (Felguard)
			[SpellName(137143)] = Defaults(), --Blood Horror
		-- Warrior
			--[SpellName(20511)] = Defaults(), --Intimidating Shout
			[SpellName(7922)] = Defaults(), --Charge Stun
			--[SpellName(676)] = Defaults(), --Disarm
			[SpellName(105771)] = Defaults(), --Warbringer
			[SpellName(107566)] = Defaults(), --Staggering Shout
			[SpellName(132168)] = Defaults(), --Shockwave
			[SpellName(107570)] = Defaults(), --Storm Bolt
			[SpellName(118895)] = Defaults(), --Dragon Roar
			[SpellName(18498)] = Defaults(), --Gag Order
		-- Monk
			[SpellName(116706)] = Defaults(), --Disable
			--[SpellName(117368)] = Defaults(), --Grapple Weapon
			[SpellName(115078)] = Defaults(), --Paralysis
			--[SpellName(122242)] = Defaults(), --Clash
			[SpellName(119392)] = Defaults(), --Charging Ox Wave
			[SpellName(119381)] = Defaults(), --Leg Sweep
			[SpellName(120086)] = Defaults(), --Fists of Fury
			--[SpellName(116709)] = Defaults(), --Spear Hand Strike
			--[SpellName(123407)] = Defaults(), --Spinning Fire Blossom
			[SpellName(140023)] = Defaults(), --Ring of Peace
		-- Racial
			[SpellName(25046)] = Defaults(), --Arcane Torrent
			[SpellName(20549)] = Defaults(), --War Stomp
			[SpellName(107079)] = Defaults(), --Quaking Palm
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
			[SpellName(61336)] = Defaults(), -- Survival Instincts
		--Hunter
			[SpellName(19263)] = Defaults(5), -- Deterrence
			[SpellName(53480)] = Defaults(), -- Roar of Sacrifice (Cunning)
		--Rogue
			[SpellName(1966)] = Defaults(), -- Feint
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
			[SpellName(1022)] = Defaults(5), -- Hand of Protection
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
			--[SpellName(131523)] = Defaults(5), -- Zen Meditation
			[SpellName(122783)] = Defaults(), -- Diffuse Magic
			[SpellName(122278)] = Defaults(), -- Dampen Harm
			--[SpellName(115213)] = Defaults(), -- Avert Harm
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
			--[SpellName(49016)] = Defaults(), -- Unholy Frenzy
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
			[SpellName(61336)] = Defaults(), -- Survival Instincts
			[SpellName(117679)] = Defaults(), -- Incarnation (Tree of Life)
			[SpellName(102543)] = Defaults(), -- Incarnation: King of the Jungle
			[SpellName(102558)] = Defaults(), -- Incarnation: Son of Ursoc
			[SpellName(102560)] = Defaults(), -- Incarnation: Chosen of Elune
			--[SpellName(16689)] = Defaults(), -- Nature's Grasp
			[SpellName(132158)] = Defaults(), -- Nature's Swiftness
			[SpellName(106898)] = Defaults(), -- Stampeding Roar
			[SpellName(1850)] = Defaults(), -- Dash
			[SpellName(106951)] = Defaults(), -- Berserk
			--[SpellName(29166)] = Defaults(), -- Innervate
			[SpellName(52610)] = Defaults(), -- Savage Roar
			[SpellName(69369)] = Defaults(), -- Predatory Swiftness
			[SpellName(112071)] = Defaults(), -- Celestial Alignment
			[SpellName(124974)] = Defaults(), -- Nature's Vigil
		--Hunter
			[SpellName(19263)] = Defaults(), -- Deterrence
			[SpellName(53480)] = Defaults(), -- Roar of Sacrifice (Cunning)
			[SpellName(51755)] = Defaults(), -- Camouflage
			[SpellName(54216)] = Defaults(), -- Master's Call
			--[SpellName(34471)] = Defaults(), -- The Beast Within
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
			--[SpellName(121471)] = Defaults(), -- Shadow Blades
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
			--[SpellName(16191)] = Defaults(), -- Mana Tide
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
			--[SpellName(54428)] = Defaults(), -- Divine Plea
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
			--[SpellName(131523)] = Defaults(), -- Zen Meditation
			[SpellName(122783)] = Defaults(), -- Diffuse Magic
			[SpellName(122278)] = Defaults(), -- Dampen Harm
			--[SpellName(115213)] = Defaults(), -- Avert Harm
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
		[SpellName(36900)] = Defaults(), --Soul Split: Evil!
		[SpellName(36901)] = Defaults(), --Soul Split: Good
		[SpellName(36893)] = Defaults(), --Transporter Malfunction
		[SpellName(114216)] = Defaults(), --Angelic Bulwark
		[SpellName(97821)] = Defaults(), --Void-Touched
		[SpellName(36032)] = Defaults(), -- Arcane Charge
		--[SpellName(132365)] = Defaults(), -- Vengeance
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
		[SpellName(95809)] = Defaults(), --Insanity debuff (Hunter Pet heroism)
		[SpellName(95223)] = Defaults(), --group res debuff
		[SpellName(124275)] = Defaults(), -- Stagger
		[SpellName(124274)] = Defaults(), -- Stagger
		[SpellName(124273)] = Defaults(), -- Stagger
		[SpellName(117870)] = Defaults(), -- Touch of The Titans
		[SpellName(123981)] = Defaults(), -- Perdition
		[SpellName(15007)] = Defaults(), -- Ress Sickness
		[SpellName(113942)] = Defaults(), -- Demonic: Gateway
		[SpellName(89140)] = Defaults(), -- Demonic Rebirth: Cooldown
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc.. 
]]

G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(31821)] = Defaults(), -- Devotion Aura
		[SpellName(2825)] = Defaults(), -- Bloodlust
		[SpellName(32182)] = Defaults(), -- Heroism	
		[SpellName(80353)] = Defaults(), --Time Warp
		[SpellName(90355)] = Defaults(), --Ancient Hysteria		
		[SpellName(47788)] = Defaults(), --Guardian Spirit
		[SpellName(33206)] = Defaults(), --Pain Suppression
		[SpellName(116849)] = Defaults(), --Life Cocoon
		[SpellName(22812)] = Defaults(), --Barkskin
		--[SpellName(1490)] = Defaults(), --Curse of the Elements (5% magic damage taken debuff)
		--[SpellName(116202)] = Defaults(), --Aura of the Elements (5% magic damage taken debuff)
		[SpellName(123059)] = Defaults(), --Destabilize (Amber-Shaper Un'sok)
		[SpellName(136431)] = Defaults(), --Shell Concussion (Tortos)
		[SpellName(137332)] = Defaults(), --Beast of Nightmares (Twin Consorts)
		[SpellName(137375)] = Defaults(), --Beast of Nightmares (Twin Consorts)
		[SpellName(144351)] = Defaults(), --Mark of Arrogance (Norushen)
		[SpellName(142863)] = Defaults(), --Weak Ancient Barrier (Malkorok)
		[SpellName(142864)] = Defaults(), --Ancient Barrier (Malkorok)
		[SpellName(142865)] = Defaults(), --Strong Ancient Barrier (Malkorok)
		[SpellName(143198)] = Defaults(), --Garrote (Fallen Protectors)
	},
}

G.unitframe.aurafilters['Whitelist (Strict)'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(123059)] = DefaultsID(123059), --Destabilize (Amber-Shaper Un'sok)
		[SpellName(136431)] = DefaultsID(136431), --Shell Concussion (Tortos)
		[SpellName(137332)] = DefaultsID(137332), --Beast of Nightmares (Twin Consorts)
		[SpellName(137375)] = DefaultsID(137375), --Beast of Nightmares (Twin Consorts)
		[SpellName(144351)] = DefaultsID(144351), --Mark of Arrogance (Norushen)
		[SpellName(142863)] = DefaultsID(142863), --Weak Ancient Barrier (Malkorok)
		[SpellName(142864)] = DefaultsID(142864), --Ancient Barrier (Malkorok)
		[SpellName(142865)] = DefaultsID(142865), --Strong Ancient Barrier (Malkorok)
		[SpellName(143198)] = DefaultsID(143198), --Garrote (Fallen Protectors)
	},
}

--RAID DEBUFFS
--[[
	This should be pretty self explainitory
]]
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
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
		-- Throne of Thunder
			--Trash
			[SpellName(138349)] = Defaults(), -- Static Wound
			[SpellName(137371)] = Defaults(), -- Thundering Throw
			
			--Horridon
			[SpellName(136767)] = Defaults(), --Triple Puncture
			
			--Council of Elders
			[SpellName(137641)] = Defaults(), --Soul Fragment
			[SpellName(137359)] = Defaults(), --Shadowed Loa Spirit Fixate
			[SpellName(137972)] = Defaults(), --Twisted Fate
			[SpellName(136903)] = Defaults(), --Frigid Assault
			
			--Tortos
			[SpellName(136753)] = Defaults(), --Slashing Talons
			[SpellName(137633)] = Defaults(), --Crystal Shell
			
			--Megaera
			[SpellName(137731)] = Defaults(), --Ignite Flesh
			
			
			--Durumu the Forgotten
			[SpellName(133767)] = Defaults(), --Serious Wound
			[SpellName(133768)] = Defaults(), --Arterial Cut
			
			--Primordius
			[SpellName(136050)] = Defaults(), --Malformed Blood
			
			--Dark Animus
			[SpellName(138569)] = Defaults(), --Explosive Slam
			
			--Iron Qon
			[SpellName(134691)] = Defaults(), --Impale
			
			--Twin Consorts
			[SpellName(137440)] = Defaults(), --Icy Shadows
			[SpellName(137408)] = Defaults(), --Fan of Flames
			[SpellName(137360)] = Defaults(), --Corrupted Healing
			
			--Lei Shen
			[SpellName(135000)] = Defaults(), --Decapitate
			
			--Ra-den
		--Siege of Orgrimmar
			--Immerseus
				[SpellName(143436)] = Defaults(), -- Corrosive Blast
				[SpellName(143579)] = Defaults(), --Sha Corruption(Heroic)
			
			--Fallen Protectors
				[SpellName(147383)] = Defaults(), --Debilitation
				
			--Norushen
				[SpellName(146124)] = Defaults(), --Self Doubt
				[SpellName(144851)] = Defaults(), --Test of Confidence
				
			--Sha of Pride
				[SpellName(144358)] = Defaults(), --Wounded Pride
				[SpellName(144774)] = Defaults(), --Reaching Attacks
				[SpellName(147207)] = Defaults(), --Weakened Resolve(Heroic)
			
			--Galakras
			
			--Iron Juggernaut
				[SpellName(144467)] = Defaults(), --Ignite Armor
			
			--Kor'kron Dark Shaman
				[SpellName(144215)] = Defaults(), --Froststorm Strike
				[SpellName(143990)] = Defaults(), --Foul Geyser
				[SpellName(144330)] = Defaults(), --Iron Prison(Heroic)
				
			--General Nazgrim
				[SpellName(143494)] = Defaults(), --Sundering Blow
				
			--Malkorok
				[SpellName(142990)] = Defaults(), --Fatal Strike
				[SpellName(143919)] = Defaults(), --Languish(Heroic)
				
			--Thok the Bloodthirsty
				[SpellName(143766)] = Defaults(), --Panic
				[SpellName(143773)] = Defaults(), --Freezing Breath
				[SpellName(146589)] = Defaults(), --Skeleton Key
				[SpellName(143777)] = Defaults(), --Frozen Solid
				
			--Siegecrafter Blackfuse
				[SpellName(143385)] = Defaults(), --Electrostatic Charge
				
			--Paragons of the Klaxxi
				[SpellName(143974)] = Defaults(), --Shield Bash
				
			--Garrosh Hellscream
				[SpellName(145183)] = Defaults(), --Gripping Despair
				[SpellName(145195)] = Defaults(), --Empowered Gripping Despair
	},
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset)
	local r, g, b = unpack(color)
	
	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end
	
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, 
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ['style'] = style or 'coloredIcon', ['displayText'] = displayText or false, ['decimalThreshold'] = decimalThreshold or 5,
	['textColor'] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ['textThreshold'] = textThreshold or -1, ['xOffset'] = xOffset or 0, ['yOffset'] = yOffset or 0}
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
		ClassBuff(148039, 'TOPLEFT', {0.93, 0.75, 0}), -- Sacred Shield
		ClassBuff(156322, 'BOTTOMLEFT', {0.87, 0.7, 0.03}), -- Eternal Flame
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
	--[SpellName(1120)] = 6, --"Drain Soul"
	[SpellName(689)] = 6, -- "Drain Life"
	[SpellName(108371)] = 6, -- "Harvest Life"
	[SpellName(5740)] = 4, -- "Rain of Fire"
	[SpellName(755)] = 6, -- Health Funnel
	[SpellName(103103)] = 4, --Malefic Grasp
	--Druid
	--[SpellName(44203)] = 4, -- "Tranquility"
	[SpellName(16914)] = 10, -- "Hurricane"
	--Priest
	[SpellName(48045)] = 5, -- "Mind Sear"
	[SpellName(47540)] = 2, -- "Penance"
	--[SpellName(64901)] = 4, -- Hymn of Hope
	[SpellName(64843)] = 4, -- Divine Hymn
	--Mage
	[SpellName(5143)] = 5, -- "Arcane Missiles"
	[SpellName(10)] = 8, -- "Blizzard"
	[SpellName(12051)] = 4, -- "Evocation"
	
	--Monk
	[SpellName(115175)] = 9, -- "Smoothing Mist"
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local mfTicks = 3
	if string.lower((UnitClass("player"))) == "priest" and IsSpellKnown(157223) then --Enhanced Mind Flay
		mfTicks = 4
	end

	E.global.unitframe.ChannelTicks[SpellName(15407)] = mfTicks -- "Mind Flay"
	E.global.unitframe.ChannelTicks[SpellName(129197)] = mfTicks -- "Mind Flay (Insanity)"
end)

G.unitframe.ChannelTicksSize = {
    --Warlock
   --[SpellName(1120)] = 2, --"Drain Soul"
    [SpellName(689)] = 1, -- "Drain Life"
	[SpellName(108371)] = 1, -- "Harvest Life"
	[SpellName(103103)] = 1, -- "Malefic Grasp"
}

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	--[SpellName(64901)] = true, -- Hymn of Hope
	[SpellName(64843)] = true, -- Divine Hymn
}

--This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	--Bloodlust
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255}, --Heroism
	[SpellName(80353)] = {r = 250/255, g = 146/255, b = 27/255}, --Time Warp
	[SpellName(90355)] = {r = 250/255, g = 146/255, b = 27/255}, --Ancient Hysteria
}

G.unitframe.InvalidSpells = {
	[65148] = true, --Sacred Shield
}