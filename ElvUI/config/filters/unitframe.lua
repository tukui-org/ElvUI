local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

--Cache global variables
--Lua functions
local print, unpack, select, pairs = print, unpack, select, pairs
local lower = string.lower
--WoW API / Variables
local GetSpellInfo, IsSpellKnown = GetSpellInfo, IsSpellKnown
local UnitClass, IsEquippedItem = UnitClass, IsEquippedItem

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

local function Defaults(spellID, priorityOverride)
	return {['enable'] = true, ['priority'] = priorityOverride or 0, ['stackThreshold'] = 0}
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
			[47476] = Defaults(47476), --Strangulate
			[91800] = Defaults(91800), --Gnaw (Pet)
			[91807] = Defaults(91807), --Shambling Rush (Pet)
			[91797] = Defaults(91797), --Monstrous Blow (Pet)
			[108194] = Defaults(108194), --Asphyxiate
			[115001] = Defaults(115001), --Remorseless Winter
		-- Druid
			[33786] = Defaults(33786), --Cyclone
			[339] = Defaults(339), --Entangling Roots
			[78675] = Defaults(78675), --Solar Beam
			[22570] = Defaults(22570), --Maim
			[5211] = Defaults(5211), --Mighty Bash
			[102359] = Defaults(102359), --Mass Entanglement
			[99] = Defaults(99), --Disorienting Roar
			[127797] = Defaults(127797), --Ursol's Vortex
			[45334] = Defaults(45334), --Immobilized
			[114238] = Defaults(114238), --Fae Silence
		-- Hunter
			[3355] = Defaults(3355), --Freezing Trap
			[24394] = Defaults(24394), --Intimidation
			[64803] = Defaults(64803), --Entrapment
			[19386] = Defaults(19386), --Wyvern Sting
			[117405] = Defaults(117405), --Binding Shot
			[128405] = Defaults(128405), --Narrow Escape
		-- Mage
			[31661] = Defaults(31661), --Dragon's Breath
			[118] = Defaults(118), --Polymorph
			[122] = Defaults(122), --Frost Nova
			[82691] = Defaults(82691), --Ring of Frost
			[44572] = Defaults(44572), --Deep Freeze
			[33395] = Defaults(33395), --Freeze (Water Ele)
			[102051] = Defaults(102051), --Frostjaw
		-- Paladin
			[20066] = Defaults(20066), --Repentance
			[10326] = Defaults(10326), --Turn Evil
			[853] = Defaults(853), --Hammer of Justice
			[105593] = Defaults(105593), --Fist of Justice
			[31935] = Defaults(31935), --Avenger's Shield
			[105421] = Defaults(105421), --Blinding Light
		-- Priest
			[605] = Defaults(605), --Dominate Mind
			[64044] = Defaults(64044), --Psychic Horror
			[8122] = Defaults(8122), --Psychic Scream
			[9484] = Defaults(9484), --Shackle Undead
			[15487] = Defaults(15487), --Silence
			[114404] = Defaults(114404), --Void Tendrils
			[88625] = Defaults(88625), --Holy Word: Chastise
			[87194] = Defaults(87194), --Sin and Punishment
		-- Rogue
			[2094] = Defaults(2094), --Blind
			[1776] = Defaults(1776), --Gouge
			[6770] = Defaults(6770), --Sap
			[1833] = Defaults(1833), --Cheap Shot
			[1330] = Defaults(1330), --Garrote - Silence
			[408] = Defaults(408), --Kidney Shot
			[88611] = Defaults(88611), --Smoke Bomb
		-- Shaman
			[51514] = Defaults(51514), --Hex
			[64695] = Defaults(64695), --Earthgrab
			[63685] = Defaults(63685), --Freeze (Frozen Power)
			[118905] = Defaults(118905), --Static Charge
			[118345] = Defaults(118345), --Pulverize (Earth Elemental)
		-- Warlock
			[710] = Defaults(710), --Banish
			[6789] = Defaults(6789), --Mortal Coil
			[118699] = Defaults(118699), --Fear
			[5484] = Defaults(5484), --Howl of Terror
			[6358] = Defaults(6358), --Seduction
			[30283] = Defaults(30283), --Shadowfury
			[115268] = Defaults(115268), --Mesmerize (Shivarra)
			[89766] = Defaults(89766), --Axe Toss (Felguard)
			[137143] = Defaults(137143), --Blood Horror
		-- Warrior
			[7922] = Defaults(7922), --Charge Stun
			[105771] = Defaults(105771), --Warbringer
			[107566] = Defaults(107566), --Staggering Shout
			[132168] = Defaults(132168), --Shockwave
			[107570] = Defaults(107570), --Storm Bolt
			[118895] = Defaults(118895), --Dragon Roar
			[18498] = Defaults(18498), --Gag Order
		-- Monk
			[116706] = Defaults(116706), --Disable
			[115078] = Defaults(115078), --Paralysis
			[119392] = Defaults(119392), --Charging Ox Wave
			[119381] = Defaults(119381), --Leg Sweep
			[120086] = Defaults(120086), --Fists of Fury
			[140023] = Defaults(140023), --Ring of Peace
		-- Racial
			[25046] = Defaults(25046), --Arcane Torrent
			[20549] = Defaults(20549), --War Stomp
			[107079] = Defaults(107079), --Quaking Palm
	},
}

--[[
	These are buffs that can be considered "protection" buffs
]]
G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mage
			[45438] = Defaults(45438, 5), -- Ice Block
			[115610] = Defaults(115610), -- Temporal Shield
		--Death Knight
			[48797] = Defaults(48797, 5), -- Anti-Magic Shell
			[48792] = Defaults(48792), -- Icebound Fortitude
			[49039] = Defaults(49039), -- Lichborne
			[87256] = Defaults(87256, 4), -- Dancing Rune Weapon
			[55233] = Defaults(55233), -- Vampiric Blood
			[50461] = Defaults(50461), -- Anti-Magic Zone
		--Priest
			[33206] = Defaults(33206, 3), -- Pain Suppression
			[47788] = Defaults(47788), -- Guardian Spirit
			[62618] = Defaults(62618), -- Power Word: Barrier
			[47585] = Defaults(47585, 5), -- Dispersion
		--Warlock
			[104773] = Defaults(104773), -- Unending Resolve
			[110913] = Defaults(110913), -- Dark Bargain
			[108359] = Defaults(108359), -- Dark Regeneration
		--Druid
			[22812] = Defaults(22812, 2), -- Barkskin
			[102342] = Defaults(102342, 2), -- Ironbark
			[61336] = Defaults(61336), -- Survival Instincts
		--Hunter
			[19263] = Defaults(19263, 5), -- Deterrence
			[53480] = Defaults(53480), -- Roar of Sacrifice (Cunning)
		--Rogue
			[1966] = Defaults(1966), -- Feint
			[31224] = Defaults(31224), -- Cloak of Shadows
			[74001] = Defaults(74001), -- Combat Readiness
			[5277] = Defaults(5277, 5), -- Evasion
			[45182] = Defaults(45182), -- Cheating Death
		--Shaman
			[98007] = Defaults(98007), -- Spirit Link Totem
			[30823] = Defaults(30823), -- Shamanistic Rage
			[108271] = Defaults(108271), -- Astral Shift
		--Paladin
			[1022] = Defaults(1022, 5), -- Hand of Protection
			[6940] = Defaults(6940), -- Hand of Sacrifice
			[114039] = Defaults(114039), -- Hand of Purity
			[31821] = Defaults(31821, 3), -- Devotion Aura
			[498] = Defaults(498, 2), -- Divine Protection
			[642] = Defaults(642, 5), -- Divine Shield
			[86659] = Defaults(86659, 4), -- Guardian of the Ancient Kings (Prot)
			[31850] = Defaults(31850, 4), -- Ardent Defender
		--Warrior
			[118038] = Defaults(118038, 5), -- Die by the Sword
			[55694] = Defaults(55694), -- Enraged Regeneration
			[97463] = Defaults(97463), -- Rallying Cry
			[12975] = Defaults(12975), -- Last Stand
			[114029] = Defaults(114029, 2), -- Safeguard
			[871] = Defaults(871, 3), -- Shield Wall
			[114030] = Defaults(114030), -- Vigilance
		--Monk
			[120954] = Defaults(120954, 2), -- Fortifying Brew
			[122783] = Defaults(122783), -- Diffuse Magic
			[122278] = Defaults(122278), -- Dampen Harm
			[116849] = Defaults(116849), -- Life Cocoon
		--Racial
			[20594] = Defaults(20594), -- Stoneform
	},
}

G.unitframe.aurafilters['PlayerBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mage
			[45438] = Defaults(45438), -- Ice Block
			[115610] = Defaults(115610), -- Temporal Shield
			[110909] = Defaults(110909), -- Alter Time
			[12051] = Defaults(12051), -- Evocation
			[12472] = Defaults(12472), -- Icy Veins
			[80353] = Defaults(80353), -- Time Warp
			[12042] = Defaults(12042), -- Arcane Power
			[32612] = Defaults(32612), -- Invisibility
			[110960] = Defaults(110960), -- Greater Invisibility
			[108839] = Defaults(108839), -- Ice Flows
			[111264] = Defaults(111264), -- Ice Ward
			[108843] = Defaults(108843), -- Blazing Speed
		--Death Knight
			[48797] = Defaults(48797), -- Anti-Magic Shell
			[48792] = Defaults(48792), -- Icebound Fortitude
			[49039] = Defaults(49039), -- Lichborne
			[87256] = Defaults(87256), -- Dancing Rune Weapon
			[49222] = Defaults(49222), -- Bone Shield
			[55233] = Defaults(55233), -- Vampiric Blood
			[50461] = Defaults(50461), -- Anti-Magic Zone
			[51271] = Defaults(51271), -- Pillar of Frost
			[96268] = Defaults(96268), -- Death's Advance
		--Priest
			[33206] = Defaults(33206), -- Pain Suppression
			[47788] = Defaults(47788), -- Guardian Spirit
			[62618] = Defaults(62618), -- Power Word: Barrier
			[47585] = Defaults(47585), -- Dispersion
			[6346] = Defaults(6346), -- Fear Ward
			[10060] = Defaults(10060), -- Power Infusion
			[114239] = Defaults(114239), -- Phantasm
			[119032] = Defaults(119032), -- Spectral Guise
			[27827] = Defaults(27827), -- Spirit of Redemption
		--Warlock
			[104773] = Defaults(104773), -- Unending Resolve
			[110913] = Defaults(110913), -- Dark Bargain
			[108359] = Defaults(108359), -- Dark Regeneration
			[113860] = Defaults(113860), -- Dark Sould: Misery
			[113861] = Defaults(113861), -- Dark Soul: Knowledge
			[113858] = Defaults(113858), -- Dark Soul: Instability
			[88448] = Defaults(88448), -- Demonic Rebirth
		--Druid
			[22812] = Defaults(22812), -- Barkskin
			[102342] = Defaults(102342), -- Ironbark
			[61336] = Defaults(61336), -- Survival Instincts
			[117679] = Defaults(117679), -- Incarnation (Tree of Life)
			[102543] = Defaults(102543), -- Incarnation: King of the Jungle
			[102558] = Defaults(102558), -- Incarnation: Son of Ursoc
			[102560] = Defaults(102560), -- Incarnation: Chosen of Elune
			[132158] = Defaults(132158), -- Nature's Swiftness
			[106898] = Defaults(106898), -- Stampeding Roar
			[1850] = Defaults(1850), -- Dash
			[106951] = Defaults(106951), -- Berserk
			[52610] = Defaults(52610), -- Savage Roar
			[69369] = Defaults(69369), -- Predatory Swiftness
			[112071] = Defaults(112071), -- Celestial Alignment
			[124974] = Defaults(124974), -- Nature's Vigil
		--Hunter
			[19263] = Defaults(19263), -- Deterrence
			[53480] = Defaults(53480), -- Roar of Sacrifice (Cunning)
			[51755] = Defaults(51755), -- Camouflage
			[54216] = Defaults(54216), -- Master's Call
			[3045] = Defaults(3045), -- Rapid Fire
			[3584] = Defaults(3584), -- Feign Death
			[131894] = Defaults(131894), -- A Murder of Crows
			[90355] = Defaults(90355), -- Ancient Hysteria
			[90361] = Defaults(90361), -- Spirit Mend
		--Rogue
			[31224] = Defaults(31224), -- Cloak of Shadows
			[74001] = Defaults(74001), -- Combat Readiness
			[5277] = Defaults(5277), -- Evasion
			[45182] = Defaults(45182), -- Cheating Death
			[51713] = Defaults(51713), -- Shadow Dance
			[114018] = Defaults(114018), -- Shroud of Concealment
			[2983] = Defaults(2983), -- Sprint
			[11327] = Defaults(11327), -- Vanish
			[108212] = Defaults(108212), -- Burst of Speed
			[57933] = Defaults(57933), -- Tricks of the Trade
			[79140] = Defaults(79140), -- Vendetta
			[13750] = Defaults(13750), -- Adrenaline Rush
		--Shaman
			[98007] = Defaults(98007), -- Spirit Link Totem
			[30823] = Defaults(30823), -- Shamanistic Rage
			[108271] = Defaults(108271), -- Astral Shift
			[16188] = Defaults(16188), -- Ancestral Swiftness
			[2825] = Defaults(2825), -- Bloodlust
			[79206] = Defaults(79206), -- Spiritwalker's Grace
			[8178] = Defaults(8178), -- Grounding Totem Effect
			[58875] = Defaults(58875), -- Spirit Walk
			[108281] = Defaults(108281), -- Ancestral Guidance
			[108271] = Defaults(108271), -- Astral Shift
			[16166] = Defaults(16166), -- Elemental Mastery
			[114896] = Defaults(114896), -- Windwalk Totem
		--Paladin
			[1044] = Defaults(1044), -- Hand of Freedom
			[1022] = Defaults(1022), -- Hand of Protection
			[1038] = Defaults(1038), -- Hand of Salvation
			[6940] = Defaults(6940), -- Hand of Sacrifice
			[114039] = Defaults(114039), -- Hand of Purity
			[31821] = Defaults(31821), -- Devotion Aura
			[498] = Defaults(498), -- Divine Protection
			[642] = Defaults(642), -- Divine Shield
			[86659] = Defaults(86659), -- Guardian of the Ancient Kings (Prot)
			[20925] = Defaults(20925), -- Sacred Shield
			[31850] = Defaults(31850), -- Ardent Defender
			[31884] = Defaults(31884), -- Avenging Wrath
			[53563] = Defaults(53563), -- Beacon of Light
			[31842] = Defaults(31842), -- Divine Favor
			[105809] = Defaults(105809), -- Holy Avenger
			[85499] = Defaults(85499), -- Speed of Light
		--Warrior
			[118038] = Defaults(118038), -- Die by the Sword
			[55694] = Defaults(55694), -- Enraged Regeneration
			[97463] = Defaults(97463), -- Rallying Cry
			[12975] = Defaults(12975), -- Last Stand
			[114029] = Defaults(114029), -- Safeguard
			[871] = Defaults(871), -- Shield Wall
			[114030] = Defaults(114030), -- Vigilance
			[18499] = Defaults(18499), -- Berserker Rage
			[1719] = Defaults(1719), -- Recklessness
			[23920] = Defaults(23920), -- Spell Reflection
			[114028] = Defaults(114028), -- Mass Spell Reflection
			[46924] = Defaults(46924), -- Bladestorm
			[3411] = Defaults(3411), -- Intervene
			[107574] = Defaults(107574), -- Avatar
		--Monk
			[120954] = Defaults(120954), -- Fortifying Brew
			[122783] = Defaults(122783), -- Diffuse Magic
			[122278] = Defaults(122278), -- Dampen Harm
			[116849] = Defaults(116849), -- Life Cocoon
			[125174] = Defaults(125174), -- Touch of Karma
			[116841] = Defaults(116841), -- Tiger's Lust
		--Racial
			[20594] = Defaults(20594), -- Stoneform
			[59545] = Defaults(59545), -- Gift of the Naaru
			[20572] = Defaults(20572), -- Blood Fury
			[26297] = Defaults(26297), -- Berserking
			[68992] = Defaults(68992), -- Darkflight
	},
}



--[[
	Buffs that really we dont need to see
]]

G.unitframe.aurafilters['Blacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[36900] = Defaults(36900), --Soul Split: Evil!
		[36901] = Defaults(36901), --Soul Split: Good
		[36893] = Defaults(36893), --Transporter Malfunction
		[114216] = Defaults(114216), --Angelic Bulwark
		[97821] = Defaults(97821), --Void-Touched
		[36032] = Defaults(36032), -- Arcane Charge
		[8733] = Defaults(8733), --Blessing of Blackfathom
		[57724] = Defaults(57724), --Sated
		[25771] = Defaults(25771), --forbearance
		[57723] = Defaults(57723), --Exhaustion
		[36032] = Defaults(36032), --arcane blast
		[58539] = Defaults(58539), --watchers corpse
		[26013] = Defaults(26013), --deserter
		[6788] = Defaults(6788), --weakended soul
		[71041] = Defaults(71041), --dungeon deserter
		[41425] = Defaults(41425), --"Hypothermia"
		[55711] = Defaults(55711), --Weakened Heart
		[8326] = Defaults(8326), --ghost
		[23445] = Defaults(23445), --evil twin
		[24755] = Defaults(24755), --gay homosexual tricked or treated debuff
		[25163] = Defaults(25163), --fucking annoying pet debuff oozeling disgusting aura
		[80354] = Defaults(80354), --timewarp debuff
		[95223] = Defaults(95223), --group res debuff
		[124275] = Defaults(124275), -- Stagger
		[124274] = Defaults(124274), -- Stagger
		[124273] = Defaults(124273), -- Stagger
		[117870] = Defaults(117870), -- Touch of The Titans
		[123981] = Defaults(123981), -- Perdition
		[15007] = Defaults(15007), -- Ress Sickness
		[113942] = Defaults(113942), -- Demonic: Gateway
		[89140] = Defaults(89140), -- Demonic Rebirth: Cooldown
		[95809] = Defaults(95809), --Insanity debuff (Hunter Pet heroism)
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[31821] = Defaults(31821), -- Devotion Aura
		[2825] = Defaults(2825), -- Bloodlust
		[32182] = Defaults(32182), -- Heroism
		[80353] = Defaults(80353), --Time Warp
		[90355] = Defaults(90355), --Ancient Hysteria
		[47788] = Defaults(47788), --Guardian Spirit
		[33206] = Defaults(33206), --Pain Suppression
		[116849] = Defaults(116849), --Life Cocoon
		[22812] = Defaults(22812), --Barkskin
	},
}

--RAID DEBUFFS
--[[
	This should be pretty self explainitory
]]
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Highmaul
			--Trash
				[175601] = Defaults(175601), --Tainted Claws
				[175599] = Defaults(175599), --Devour
				[172069] = Defaults(172069), --Radiating Poison
				[172066] = Defaults(172066), --Radiating Poison
				[166779] = Defaults(166779), --Staggering Blow
				[56037] = Defaults(56037), --Rune of Destruction
				[175654] = Defaults(175654), --Rune of Disintegration
				[166185] = Defaults(166185), --Rending Slash
				[166175] = Defaults(166175), --Earth Devastating Slam
				[174404] = Defaults(174404), --Frozen Core
				[173763] = Defaults(173763), --Wild Flames
				[174500] = Defaults(174500), --Rending Throw
				[174939] = Defaults(174939), --Time Stop
				[172115] = Defaults(172115), --Earthen Thrust
				[166200] = Defaults(166200), --Arcane Volatility
				[174473] = Defaults(174473), --Corrupted Blood

			--Kargath Bladefist
				[158986] = Defaults(158986), --Berserker Rush
				[159113] = Defaults(159113), --Impale
				[159178] = Defaults(159178), --Open Wounds
				[159213] = Defaults(159213), --Monsters Brawl
				[159410] = Defaults(159410), --Mauling Brew
				[160521] = Defaults(160521), --Vile Breath
				[159386] = Defaults(159386), --Iron Bomb
				[159188] = Defaults(159188), --Grapple
				[162497] = Defaults(162497), --On the hunt
				[159202] = Defaults(159202), --Flame jet

			--The Butcher
				[156152] = Defaults(156152), --Gushing Wounds
				[156151] = Defaults(156151), --The Tenderizer
				[156143] = Defaults(156143), --The Cleaver
				[163046] = Defaults(163046), --Pale Vitriol

			--Brackenspore
				[159220] = Defaults(159220), --Necrotic Breath
				[163242] = Defaults(163242), --Infesting Spores
				[163590] = Defaults(163590), --Creeping Moss
				[163241] = Defaults(163241), --Rot
				[160179] = Defaults(160179), --Mind Fungus
				[159972] = Defaults(159972), --Flesh Eater

			--Tectus
				[162346] = Defaults(162346), --Crystalline Barrage
				[162892] = Defaults(162892), --Petrification
				[162475] = Defaults(162475), --Tectonic Upheaval

			--Twin Ogrons
				[155569] = Defaults(155569), --Injured
				[158241] = Defaults(158241), --Blaze
				[158026] = Defaults(158026), --Enfeebling Roar
				[167200] = Defaults(167200), --Arcane Wound
				[159709] = Defaults(159709), --Weakened Defenses
				[167179] = Defaults(167179), --Weakened Defenses
				[163374] = Defaults(163374), --Arcane Volatility
				[158200] = Defaults(158200), --Quake

			--Ko'ragh
				[163472] = Defaults(163472), --Dominating Power
				[172895] = Defaults(172895), --Expel Magic: Fel
				[162185] = Defaults(162185), --Expel Magic: Fire
				[162184] = Defaults(162184), --Expel Magic: Shadow
				[161242] = Defaults(161242), --Caustic Energy
				[161358] = Defaults(161358), --Suppression Field
				[156803] = Defaults(156803), --Nullification Barrier

			--Imperator Mar'gok
				[164004] = Defaults(164004), --Branded: Displacement
				[164005] = Defaults(164005), --Branded: Fortification
				[164006] = Defaults(164006), --Branded: Replication
				[158619] = Defaults(158619), --Fetter
				[164176] = Defaults(164176), --Mark of Chaos: Displacement
				[164178] = Defaults(164178), --Mark of Chaos: Fortification
				[164191] = Defaults(164191), --Mark of Chaos: Replication
				[157349] = Defaults(157349), --Force Nova
				[164232] = Defaults(164232), --Force Nova
				[164235] = Defaults(164235), --Force Nova
				[164240] = Defaults(164240), --Force Nova
				[158553] = Defaults(158553), --Crush Armor
				[165102] = Defaults(165102), --Infinite Darkness
				[157801] = Defaults(157801), --Slow

		--Blackrock Foundry
			--Trash

			--Blackhand
				[156096] = Defaults(156096), --Marked for Death
				[156743] = Defaults(156743), --Impaled
				[156047] = Defaults(156047), --Slagged
				[156401] = Defaults(156401), --Molten Slag
				[156404] = Defaults(156404), --Burned
				[158054] = Defaults(158054), --Shattering Smash
				[156888] = Defaults(156888), --Overheated
				[157000] = Defaults(157000), --Attach Slag Bombs
				[156999] = Defaults(156999), --Throw Slag Bombs

			--Beastlord Darmac
				[155365] = Defaults(155365), --Pinned Down
				[155061] = Defaults(155061), --Rend and Tear
				[155030] = Defaults(155030), --Seared Flesh
				[155236] = Defaults(155236), --Crush Armor
				[159044] = Defaults(159044), --Epicentre
				[162276] = Defaults(162276), --Unsteady Mythic
				[155657] = Defaults(155657), --Flame Infusion
				[155222] = Defaults(155222), --Tantrum
				[155399] = Defaults(155399), --Conflagration
				[154989] = Defaults(154989), --Inferno Breath
				[155499] = Defaults(155499), --Superheated Shrapnel

			--Flamebender Ka'graz
				[155318] = Defaults(155318), --Lava Slash
				[155277] = Defaults(155277), --Blazing Radiance
				[154952] = Defaults(154952), --Fixate
				[155074] = Defaults(155074), --Charring Breath
				[163284] = Defaults(163284), --Rising Flame
				[162293] = Defaults(162293), --Empowered Armament
				[155493] = Defaults(155493), --Firestorm
				[163633] = Defaults(163633), --Magma Monsoon

			--Operator Thogar
				[155921] = Defaults(155921), --Enkindle
				[165195] = Defaults(165195), --Prototype Pulse Grenade
				[155701] = Defaults(155701), --Serrated Slash
				[156310] = Defaults(156310), --Lava Shock
				[164380] = Defaults(164380), --Burning

			--The Blast Furnace
				[155240] = Defaults(155240), --Tempered
				[155242] = Defaults(155242), --Heath
				[176133] = Defaults(176133), --Bomb
				[156934] = Defaults(156934), --Rupture
				[175104] = Defaults(175104), --Melt Armor
				[176121] = Defaults(176121), --Volatile Fire
				[158702] = Defaults(158702), --Fixate
				[155225] = Defaults(155225), --Melt

			--Hans'gar and Franzok
				[157139] = Defaults(157139), --Shattered Vertebrae
				[161570] = Defaults(161570), --Searing Plates
				[157853] = Defaults(157853), --Aftershock

			--Gruul
				[155080] = Defaults(155080), --Inferno Slice
				[143962] = Defaults(143962), --Inferno Strike
				[155078] = Defaults(155078), --Overwhelming Blows
				[36240] = Defaults(36240), --Cave In
				[155326] = Defaults(155326), --Petrifying Slam
				[165300] = Defaults(165300), --Flare Mythic

			--Kromog
				[157060] = Defaults(157060), --Rune of Grasping Earth
				[156766] = Defaults(156766), --Warped Armor
				[161839] = Defaults(161839), --Rune of Crushing Earth
				[156844] = Defaults(156844), --Stone Breath

			--Oregorger
				[156309] = Defaults(156309), --ACid Torrent
				[156203] = Defaults(156203), --Retched Blackrock
				[173471] = Defaults(173471), --Acidmaw

			--The Iron Maidens
				[164271] = Defaults(164271), --Penetrating Shot
				[158315] = Defaults(158315), --Dark hunt
				[156601] = Defaults(156601), --Sanguine Strikes
				[170395] = Defaults(170395), --Sorka Sprey
				[170405] = Defaults(170405), --Maraks Blood Calling
				[158692] = Defaults(158692), --Deadly Throw
				[158702] = Defaults(158702), --Fixate
				[158686] = Defaults(158686), --Expose Armor
				[158683] = Defaults(158683), --Corrupted Blood
				[159585] = Defaults(159585), --Deploy Turret
				[156112] = Defaults(156112), --Convulsive Shadows

		-- Hellfire Citadel
			-- Hellfire Assault
				[184369] = Defaults(184369), -- Howling Axe (Target)
				[180079] = Defaults(180079), -- Felfire Munitions

			-- Iron Reaver
				[179897] = Defaults(179897), -- Blitz
				[185978] = Defaults(185978), -- Firebomb Vulnerability
				[182373] = Defaults(182373), -- Flame Vulnerability
				[182280] = Defaults(182280), -- Artillery (Target)
				[182074] = Defaults(182074), -- Immolation
				[182001] = Defaults(182001), -- Unstable Orb

			-- Kormrok
				[187819] = Defaults(187819), -- Crush
				[181345] = Defaults(181345), -- Foul Crush

			-- Hellfire High Council
				[184360] = Defaults(184360), -- Fel Rage
				[184449] = Defaults(184449), -- Mark of the Necromancer
				[185065] = Defaults(185065), -- Mark of the Necromancer
				[184450] = Defaults(184450), -- Mark of the Necromancer
				[185066] = Defaults(185066), -- Mark of the Necromancer
				[184676] = Defaults(184676), -- Mark of the Necromancer
				[184652] = Defaults(184652), -- Reap

			-- Kilrogg Deadeye
				[181488] = Defaults(181488), -- Vision of Death
				[188929] = Defaults(188929), -- Heart Seeker (Target)
				[180389] = Defaults(180389), -- Heart Seeker (DoT)

			-- Gorefiend
				[179867] = Defaults(179867), -- Gorefiend's Corruption
				[181295] = Defaults(181295), -- Digest
				[179977] = Defaults(179977), -- Touch of Doom
				[179864] = Defaults(179864), -- Shadow of Death
				[179909] = Defaults(179909), -- Shared Fate (self root)
				[179908] = Defaults(179908), -- Shared Fate (other players root)

			-- Shadow-Lord Iskar
				[181957] = Defaults(181957), -- Phantasmal Winds
				[182200] = Defaults(182200), -- Fel Chakram
				[182178] = Defaults(182178), -- Fel Chakram
				[182325] = Defaults(182325), -- Phantasmal Wounds
				[185239] = Defaults(185239), -- Radiance of Anzu
				[185510] = Defaults(185510), -- Dark Bindings
				[182600] = Defaults(182600), -- Fel Fire
				[179219] = Defaults(179219), -- Phantasmal Fel Bomb
				[181753] = Defaults(181753), -- Fel Bomb

			-- Soulbound Construct (Socrethar)
				[182038] = Defaults(182038), -- Shattered Defenses
				[188666] = Defaults(188666), -- Eternal Hunger (Add fixate, Mythic only)
				[189627] = Defaults(189627), -- Volatile Fel Orb (Fixated)
				[180415] = Defaults(180415), -- Fel Prison

			-- Tyrant Velhari
				[185237] = Defaults(185237), -- Touch of Harm
				[185238] = Defaults(185238), -- Touch of Harm
				[185241] = Defaults(185241), -- Edict of Condemnation
				[180526] = Defaults(180526), -- Font of Corruption

			-- Fel Lord Zakuun
				[181508] = Defaults(181508), -- Seed of Destruction
				[181653] = Defaults(181653), -- Fel Crystals (Too Close)
				[179428] = Defaults(179428), -- Rumbling Fissure (Soak)
				[182008] = Defaults(182008), -- Latent Energy (Cannot soak)
				[179407] = Defaults(179407), -- Disembodied (Player in Shadow Realm)

			-- Xhul'horac
				[188208] = Defaults(188208), -- Ablaze
				[186073] = Defaults(186073), -- Felsinged
				[186407] = Defaults(186407), -- Fel Surge
				[186500] = Defaults(186500), -- Chains of Fel
				[186063] = Defaults(186063), -- Wasting Void
				[186333] = Defaults(186333), -- Void Surge

			-- Mannoroth
				[181275] = Defaults(181275), -- Curse of the Legion
				[181099] = Defaults(181099), -- Mark of Doom
				[181597] = Defaults(181597), -- Mannoroth's Gaze
				[182006] = Defaults(182006), -- Empowered Mannoroth's Gaze
				[181841] = Defaults(181841), -- Shadowforce
				[182088] = Defaults(182088), -- Empowered Shadowforce

			-- Archimonde
				[184964] = Defaults(184964), -- Shackled Torment
				[186123] = Defaults(186123), -- Wrought Chaos
				[185014] = Defaults(185014), -- Focused Chaos
				[186952] = Defaults(186952), -- Nether Banish
				[186961] = Defaults(186961), -- Nether Banish
				[189891] = Defaults(189891), -- Nether Tear
				[183634] = Defaults(183634), -- Shadowfel Burst
				[189895] = Defaults(189895), -- Void Star Fixate
				[190049] = Defaults(190049), -- Nether Corruption
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
		[6788] = ClassBuff(6788, "TOPRIGHT", {1, 0, 0}, true),	 -- Weakened Soul
		[41635] = ClassBuff(41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}),	 -- Prayer of Mending
		[139] = ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		[17] = ClassBuff(17, "TOPLEFT", {0.81, 0.85, 0.1}, true),	 -- Power Word: Shield
		[123258] = ClassBuff(123258, "TOPLEFT", {0.81, 0.85, 0.1}, true),	 -- Power Word: Shield Power Insight
		[10060] = ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		[47788] = ClassBuff(47788, "LEFT", {221/255, 117/255, 0}, true), -- Guardian Spirit
		[33206] = ClassBuff(33206, "LEFT", {227/255, 23/255, 13/255}, true), -- Pain Suppression
	},
	DRUID = {
		[774] = ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}),	 -- Rejuvenation
		[8936] = ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}),	 -- Regrowth
		[33763] = ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}),	 -- Lifebloom
		[48438] = ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}),	 -- Wild Growth
	},
	PALADIN = {
		[53563] = ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}),	 -- Beacon of Light
		[1022] = ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),	-- Hand of Protection
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true),	-- Hand of Freedom
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true),	-- Hand of Salvation
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true),	-- Hand of Sacrifice
		[114039] = ClassBuff(114039, "BOTTOMRIGHT", {164/255, 105/255, 184/255}), -- Hand of Purity
		[148039] = ClassBuff(148039, 'TOPLEFT', {0.93, 0.75, 0}), -- Sacred Shield
		[156322] = ClassBuff(156322, 'BOTTOMLEFT', {0.87, 0.7, 0.03}), -- Eternal Flame
	},
	SHAMAN = {
		[61295] = ClassBuff(61295, "TOPRIGHT", {0.7, 0.3, 0.7}),	 -- Riptide
		[974] = ClassBuff(974, "BOTTOMLEFT", {0.2, 0.7, 0.2}, true),	 -- Earth Shield
		[51945] = ClassBuff(51945, "BOTTOMRIGHT", {0.7, 0.4, 0}),	 -- Earthliving
	},
	MONK = {
		[119611] = ClassBuff(119611, "TOPLEFT", {0.8, 0.4, 0.8}),	 --Renewing Mist
		[116849] = ClassBuff(116849, "TOPRIGHT", {0.2, 0.8, 0.2}),	 -- Life Cocoon
		[132120] = ClassBuff(132120, "BOTTOMLEFT", {0.4, 0.8, 0.2}), -- Enveloping Mist
		[124081] = ClassBuff(124081, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Zen Sphere
	},
	ROGUE = {
		[57934] = ClassBuff(57934, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Tricks of the Trade
	},
	MAGE = {
		[111264] = ClassBuff(111264, "TOPLEFT", {0.2, 0.2, 1}), -- Ice Ward
	},
	WARRIOR = {
		[114030] = ClassBuff(114030, "TOPLEFT", {0.2, 0.2, 1}), -- Vigilance
		[3411] = ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene
		[114029] = ClassBuff(114029, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Safe Guard
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Unholy Frenzy
	},
	PET = {
		[19615] = ClassBuff(19615, 'TOPLEFT', {227/255, 23/255, 13/255}, true), -- Frenzy
		[136] = ClassBuff(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true) --Mend Pet
	},
	HUNTER = {} --Keep even if it's an empty table, so a reference to G.unitframe.buffwatch[E.myclass][SomeValue] doesn't trigger error
}

--Profile specific BuffIndicator
P['unitframe']['filters'] = {
	['buffwatch'] = {},
}

--List of spells to display ticks
G.unitframe.ChannelTicks = {
	--Warlock
	[689] = 6, -- "Drain Life"
	[108371] = 6, -- "Harvest Life"
	[5740] = 4, -- "Rain of Fire"
	[755] = 6, -- Health Funnel
	[103103] = 4, --Malefic Grasp
	--Druid
	[16914] = 10, -- "Hurricane"
	--Priest
	[48045] = 5, -- "Mind Sear"
	[179338] = 5, -- "Searing insanity"
	[64843] = 4, -- Divine Hymn
	--Mage
	[5143] = 5, -- "Arcane Missiles"
	[10] = 8, -- "Blizzard"
	[12051] = 3, -- "Evocation"

	--Monk
	[115175] = 9, -- "Smoothing Mist"
}

local priestTier17 = {115560,115561,115562,115563,115564}
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:SetScript("OnEvent", function(self, event)
	local class = select(2, UnitClass("player"))
	if lower(class) ~= "priest" then return; end

	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		local mfTicks = 3
		if IsSpellKnown(157223) then --Enhanced Mind Flay
			mfTicks = 4
		end
		E.global.unitframe.ChannelTicks[15407] = mfTicks -- "Mind Flay"
		E.global.unitframe.ChannelTicks[129197] = mfTicks -- "Mind Flay (Insanity)"
	end

	local penanceTicks = 2
	local equippedPriestTier17 = 0
	for _, item in pairs(priestTier17) do
		if IsEquippedItem(item) then
			equippedPriestTier17 = equippedPriestTier17 + 1
		end
	end
	if equippedPriestTier17 >= 2 then
		penanceTicks = 3
	end
	E.global.unitframe.ChannelTicks[47540] = penanceTicks --Penance
end)

G.unitframe.ChannelTicksSize = {
	--Warlock
	[689] = 1, -- "Drain Life"
	[108371] = 1, -- "Harvest Life"
	[103103] = 1, -- "Malefic Grasp"
}

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	--[SpellName(64901)] = true, -- Hymn of Hope
	-- [SpellName(64843)] = true, -- Divine Hymn
}

--This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825] = {r = 250/255, g = 146/255, b = 27/255},  --Bloodlust
	[32182] = {r = 250/255, g = 146/255, b = 27/255}, --Heroism
	[80353] = {r = 250/255, g = 146/255, b = 27/255}, --Time Warp
	[90355] = {r = 250/255, g = 146/255, b = 27/255}, --Ancient Hysteria
}

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}

--G.oldBuffWatch is only used for data retrieval by E:DBConversions()
G.oldBuffWatch = {
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
	HUNTER = {} --Keep even if it's an empty table, so a reference to G.unitframe.buffwatch[E.myclass][SomeValue] doesn't trigger error
}