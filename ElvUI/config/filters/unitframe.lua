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

local function Defaults(priorityOverride)
	return {['enable'] = true, ['priority'] = priorityOverride or 0, ['stackThreshold'] = 0}
end

G.unitframe.aurafilters = {};

--[[
	These are debuffs that are some form of CC
]]
G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		-- Death Knight
			[47476] = Defaults(), --Strangulate
			[91800] = Defaults(), --Gnaw (Pet)
			[91807] = Defaults(), --Shambling Rush (Pet)
			[91797] = Defaults(), --Monstrous Blow (Pet)
			[108194] = Defaults(), --Asphyxiate
			[115001] = Defaults(), --Remorseless Winter
		-- Druid
			[33786] = Defaults(), --Cyclone
			[339] = Defaults(), --Entangling Roots
			[78675] = Defaults(), --Solar Beam
			[22570] = Defaults(), --Maim
			[5211] = Defaults(), --Mighty Bash
			[102359] = Defaults(), --Mass Entanglement
			[99] = Defaults(), --Disorienting Roar
			[127797] = Defaults(), --Ursol's Vortex
			[45334] = Defaults(), --Immobilized
			[114238] = Defaults(), --Fae Silence
		-- Hunter
			[3355] = Defaults(), --Freezing Trap
			[24394] = Defaults(), --Intimidation
			[64803] = Defaults(), --Entrapment
			[19386] = Defaults(), --Wyvern Sting
			[117405] = Defaults(), --Binding Shot
			[128405] = Defaults(), --Narrow Escape
		-- Mage
			[31661] = Defaults(), --Dragon's Breath
			[118] = Defaults(), --Polymorph
			[122] = Defaults(), --Frost Nova
			[82691] = Defaults(), --Ring of Frost
			[44572] = Defaults(), --Deep Freeze
			[33395] = Defaults(), --Freeze (Water Ele)
			[102051] = Defaults(), --Frostjaw
		-- Paladin
			[20066] = Defaults(), --Repentance
			[10326] = Defaults(), --Turn Evil
			[853] = Defaults(), --Hammer of Justice
			[105593] = Defaults(), --Fist of Justice
			[31935] = Defaults(), --Avenger's Shield
			[105421] = Defaults(), --Blinding Light
		-- Priest
			[605] = Defaults(), --Dominate Mind
			[64044] = Defaults(), --Psychic Horror
			[8122] = Defaults(), --Psychic Scream
			[9484] = Defaults(), --Shackle Undead
			[15487] = Defaults(), --Silence
			[114404] = Defaults(), --Void Tendrils
			[88625] = Defaults(), --Holy Word: Chastise
			[87194] = Defaults(), --Sin and Punishment
		-- Rogue
			[2094] = Defaults(), --Blind
			[1776] = Defaults(), --Gouge
			[6770] = Defaults(), --Sap
			[1833] = Defaults(), --Cheap Shot
			[1330] = Defaults(), --Garrote - Silence
			[408] = Defaults(), --Kidney Shot
			[88611] = Defaults(), --Smoke Bomb
		-- Shaman
			[51514] = Defaults(), --Hex
			[64695] = Defaults(), --Earthgrab
			[63685] = Defaults(), --Freeze (Frozen Power)
			[118905] = Defaults(), --Static Charge
			[118345] = Defaults(), --Pulverize (Earth Elemental)
		-- Warlock
			[710] = Defaults(), --Banish
			[6789] = Defaults(), --Mortal Coil
			[118699] = Defaults(), --Fear
			[5484] = Defaults(), --Howl of Terror
			[6358] = Defaults(), --Seduction
			[30283] = Defaults(), --Shadowfury
			[115268] = Defaults(), --Mesmerize (Shivarra)
			[89766] = Defaults(), --Axe Toss (Felguard)
			[137143] = Defaults(), --Blood Horror
		-- Warrior
			[7922] = Defaults(), --Charge Stun
			[105771] = Defaults(), --Warbringer
			[107566] = Defaults(), --Staggering Shout
			[132168] = Defaults(), --Shockwave
			[107570] = Defaults(), --Storm Bolt
			[118895] = Defaults(), --Dragon Roar
			[18498] = Defaults(), --Gag Order
		-- Monk
			[116706] = Defaults(), --Disable
			[115078] = Defaults(), --Paralysis
			[119392] = Defaults(), --Charging Ox Wave
			[119381] = Defaults(), --Leg Sweep
			[120086] = Defaults(), --Fists of Fury
			[140023] = Defaults(), --Ring of Peace
		-- Racial
			[25046] = Defaults(), --Arcane Torrent
			[20549] = Defaults(), --War Stomp
			[107079] = Defaults(), --Quaking Palm
	},
}

--[[
	These are buffs that can be considered "protection" buffs
]]
G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mage
			[45438] = Defaults(5), -- Ice Block
			[115610] = Defaults(), -- Temporal Shield
		--Death Knight
			[48797] = Defaults(5), -- Anti-Magic Shell
			[48792] = Defaults(), -- Icebound Fortitude
			[49039] = Defaults(), -- Lichborne
			[87256] = Defaults(4), -- Dancing Rune Weapon
			[55233] = Defaults(), -- Vampiric Blood
			[50461] = Defaults(), -- Anti-Magic Zone
		--Priest
			[33206] = Defaults(3), -- Pain Suppression
			[47788] = Defaults(), -- Guardian Spirit
			[62618] = Defaults(), -- Power Word: Barrier
			[47585] = Defaults(5), -- Dispersion
		--Warlock
			[104773] = Defaults(), -- Unending Resolve
			[110913] = Defaults(), -- Dark Bargain
			[108359] = Defaults(), -- Dark Regeneration
		--Druid
			[22812] = Defaults(2), -- Barkskin
			[102342] = Defaults(2), -- Ironbark
			[61336] = Defaults(), -- Survival Instincts
		--Hunter
			[19263] = Defaults(5), -- Deterrence
			[53480] = Defaults(), -- Roar of Sacrifice (Cunning)
		--Rogue
			[1966] = Defaults(), -- Feint
			[31224] = Defaults(), -- Cloak of Shadows
			[74001] = Defaults(), -- Combat Readiness
			[5277] = Defaults(5), -- Evasion
			[45182] = Defaults(), -- Cheating Death
		--Shaman
			[98007] = Defaults(), -- Spirit Link Totem
			[30823] = Defaults(), -- Shamanistic Rage
			[108271] = Defaults(), -- Astral Shift
		--Paladin
			[1022] = Defaults(5), -- Hand of Protection
			[6940] = Defaults(), -- Hand of Sacrifice
			[114039] = Defaults(), -- Hand of Purity
			[31821] = Defaults(3), -- Devotion Aura
			[498] = Defaults(2), -- Divine Protection
			[642] = Defaults(5), -- Divine Shield
			[86659] = Defaults(4), -- Guardian of the Ancient Kings (Prot)
			[31850] = Defaults(4), -- Ardent Defender
		--Warrior
			[118038] = Defaults(5), -- Die by the Sword
			[55694] = Defaults(), -- Enraged Regeneration
			[97463] = Defaults(), -- Rallying Cry
			[12975] = Defaults(), -- Last Stand
			[114029] = Defaults(2), -- Safeguard
			[871] = Defaults(3), -- Shield Wall
			[114030] = Defaults(), -- Vigilance
		--Monk
			[120954] = Defaults(2), -- Fortifying Brew
			[122783] = Defaults(), -- Diffuse Magic
			[122278] = Defaults(), -- Dampen Harm
			[116849] = Defaults(), -- Life Cocoon
		--Racial
			[20594] = Defaults(), -- Stoneform
	},
}

G.unitframe.aurafilters['PlayerBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		--Mage
			[45438] = Defaults(), -- Ice Block
			[115610] = Defaults(), -- Temporal Shield
			[110909] = Defaults(), -- Alter Time
			[12051] = Defaults(), -- Evocation
			[12472] = Defaults(), -- Icy Veins
			[80353] = Defaults(), -- Time Warp
			[12042] = Defaults(), -- Arcane Power
			[32612] = Defaults(), -- Invisibility
			[110960] = Defaults(), -- Greater Invisibility
			[108839] = Defaults(), -- Ice Flows
			[111264] = Defaults(), -- Ice Ward
			[108843] = Defaults(), -- Blazing Speed
		--Death Knight
			[48797] = Defaults(), -- Anti-Magic Shell
			[48792] = Defaults(), -- Icebound Fortitude
			[49039] = Defaults(), -- Lichborne
			[87256] = Defaults(), -- Dancing Rune Weapon
			[49222] = Defaults(), -- Bone Shield
			[55233] = Defaults(), -- Vampiric Blood
			[50461] = Defaults(), -- Anti-Magic Zone
			[51271] = Defaults(), -- Pillar of Frost
			[96268] = Defaults(), -- Death's Advance
		--Priest
			[33206] = Defaults(), -- Pain Suppression
			[47788] = Defaults(), -- Guardian Spirit
			[62618] = Defaults(), -- Power Word: Barrier
			[47585] = Defaults(), -- Dispersion
			[6346] = Defaults(), -- Fear Ward
			[10060] = Defaults(), -- Power Infusion
			[114239] = Defaults(), -- Phantasm
			[119032] = Defaults(), -- Spectral Guise
			[27827] = Defaults(), -- Spirit of Redemption
		--Warlock
			[104773] = Defaults(), -- Unending Resolve
			[110913] = Defaults(), -- Dark Bargain
			[108359] = Defaults(), -- Dark Regeneration
			[113860] = Defaults(), -- Dark Sould: Misery
			[113861] = Defaults(), -- Dark Soul: Knowledge
			[113858] = Defaults(), -- Dark Soul: Instability
			[88448] = Defaults(), -- Demonic Rebirth
		--Druid
			[22812] = Defaults(), -- Barkskin
			[102342] = Defaults(), -- Ironbark
			[61336] = Defaults(), -- Survival Instincts
			[117679] = Defaults(), -- Incarnation (Tree of Life)
			[102543] = Defaults(), -- Incarnation: King of the Jungle
			[102558] = Defaults(), -- Incarnation: Son of Ursoc
			[102560] = Defaults(), -- Incarnation: Chosen of Elune
			[132158] = Defaults(), -- Nature's Swiftness
			[106898] = Defaults(), -- Stampeding Roar
			[1850] = Defaults(), -- Dash
			[106951] = Defaults(), -- Berserk
			[52610] = Defaults(), -- Savage Roar
			[69369] = Defaults(), -- Predatory Swiftness
			[112071] = Defaults(), -- Celestial Alignment
			[124974] = Defaults(), -- Nature's Vigil
		--Hunter
			[19263] = Defaults(), -- Deterrence
			[53480] = Defaults(), -- Roar of Sacrifice (Cunning)
			[51755] = Defaults(), -- Camouflage
			[54216] = Defaults(), -- Master's Call
			[3045] = Defaults(), -- Rapid Fire
			[3584] = Defaults(), -- Feign Death
			[131894] = Defaults(), -- A Murder of Crows
			[90355] = Defaults(), -- Ancient Hysteria
			[90361] = Defaults(), -- Spirit Mend
		--Rogue
			[31224] = Defaults(), -- Cloak of Shadows
			[74001] = Defaults(), -- Combat Readiness
			[5277] = Defaults(), -- Evasion
			[45182] = Defaults(), -- Cheating Death
			[51713] = Defaults(), -- Shadow Dance
			[114018] = Defaults(), -- Shroud of Concealment
			[2983] = Defaults(), -- Sprint
			[11327] = Defaults(), -- Vanish
			[108212] = Defaults(), -- Burst of Speed
			[57933] = Defaults(), -- Tricks of the Trade
			[79140] = Defaults(), -- Vendetta
			[13750] = Defaults(), -- Adrenaline Rush
		--Shaman
			[98007] = Defaults(), -- Spirit Link Totem
			[30823] = Defaults(), -- Shamanistic Rage
			[108271] = Defaults(), -- Astral Shift
			[16188] = Defaults(), -- Ancestral Swiftness
			[2825] = Defaults(), -- Bloodlust
			[79206] = Defaults(), -- Spiritwalker's Grace
			[8178] = Defaults(), -- Grounding Totem Effect
			[58875] = Defaults(), -- Spirit Walk
			[108281] = Defaults(), -- Ancestral Guidance
			[108271] = Defaults(), -- Astral Shift
			[16166] = Defaults(), -- Elemental Mastery
			[114896] = Defaults(), -- Windwalk Totem
		--Paladin
			[1044] = Defaults(), -- Hand of Freedom
			[1022] = Defaults(), -- Hand of Protection
			[1038] = Defaults(), -- Hand of Salvation
			[6940] = Defaults(), -- Hand of Sacrifice
			[114039] = Defaults(), -- Hand of Purity
			[31821] = Defaults(), -- Devotion Aura
			[498] = Defaults(), -- Divine Protection
			[642] = Defaults(), -- Divine Shield
			[86659] = Defaults(), -- Guardian of the Ancient Kings (Prot)
			[20925] = Defaults(), -- Sacred Shield
			[31850] = Defaults(), -- Ardent Defender
			[31884] = Defaults(), -- Avenging Wrath
			[53563] = Defaults(), -- Beacon of Light
			[31842] = Defaults(), -- Divine Favor
			[105809] = Defaults(), -- Holy Avenger
			[85499] = Defaults(), -- Speed of Light
		--Warrior
			[118038] = Defaults(), -- Die by the Sword
			[55694] = Defaults(), -- Enraged Regeneration
			[97463] = Defaults(), -- Rallying Cry
			[12975] = Defaults(), -- Last Stand
			[114029] = Defaults(), -- Safeguard
			[871] = Defaults(), -- Shield Wall
			[114030] = Defaults(), -- Vigilance
			[18499] = Defaults(), -- Berserker Rage
			[1719] = Defaults(), -- Recklessness
			[23920] = Defaults(), -- Spell Reflection
			[114028] = Defaults(), -- Mass Spell Reflection
			[46924] = Defaults(), -- Bladestorm
			[3411] = Defaults(), -- Intervene
			[107574] = Defaults(), -- Avatar
		--Monk
			[120954] = Defaults(), -- Fortifying Brew
			[122783] = Defaults(), -- Diffuse Magic
			[122278] = Defaults(), -- Dampen Harm
			[116849] = Defaults(), -- Life Cocoon
			[125174] = Defaults(), -- Touch of Karma
			[116841] = Defaults(), -- Tiger's Lust
		--Racial
			[20594] = Defaults(), -- Stoneform
			[59545] = Defaults(), -- Gift of the Naaru
			[20572] = Defaults(), -- Blood Fury
			[26297] = Defaults(), -- Berserking
			[68992] = Defaults(), -- Darkflight
	},
}



--[[
	Buffs that really we dont need to see
]]

G.unitframe.aurafilters['Blacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[36900] = Defaults(), --Soul Split: Evil!
		[36901] = Defaults(), --Soul Split: Good
		[36893] = Defaults(), --Transporter Malfunction
		[114216] = Defaults(), --Angelic Bulwark
		[97821] = Defaults(), --Void-Touched
		[36032] = Defaults(), -- Arcane Charge
		[8733] = Defaults(), --Blessing of Blackfathom
		[57724] = Defaults(), --Sated
		[25771] = Defaults(), --forbearance
		[57723] = Defaults(), --Exhaustion
		[36032] = Defaults(), --arcane blast
		[58539] = Defaults(), --watchers corpse
		[26013] = Defaults(), --deserter
		[6788] = Defaults(), --weakended soul
		[71041] = Defaults(), --dungeon deserter
		[41425] = Defaults(), --"Hypothermia"
		[55711] = Defaults(), --Weakened Heart
		[8326] = Defaults(), --ghost
		[23445] = Defaults(), --evil twin
		[24755] = Defaults(), --gay homosexual tricked or treated debuff
		[25163] = Defaults(), --fucking annoying pet debuff oozeling disgusting aura
		[80354] = Defaults(), --timewarp debuff
		[95223] = Defaults(), --group res debuff
		[124275] = Defaults(), -- Stagger
		[124274] = Defaults(), -- Stagger
		[124273] = Defaults(), -- Stagger
		[117870] = Defaults(), -- Touch of The Titans
		[123981] = Defaults(), -- Perdition
		[15007] = Defaults(), -- Ress Sickness
		[113942] = Defaults(), -- Demonic: Gateway
		[89140] = Defaults(), -- Demonic Rebirth: Cooldown
		[95809] = Defaults(), --Insanity debuff (Hunter Pet heroism)
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[31821] = Defaults(), -- Devotion Aura
		[2825] = Defaults(), -- Bloodlust
		[32182] = Defaults(), -- Heroism
		[80353] = Defaults(), --Time Warp
		[90355] = Defaults(), --Ancient Hysteria
		[47788] = Defaults(), --Guardian Spirit
		[33206] = Defaults(), --Pain Suppression
		[116849] = Defaults(), --Life Cocoon
		[22812] = Defaults(), --Barkskin
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
				[175601] = Defaults(), --Tainted Claws
				[175599] = Defaults(), --Devour
				[172069] = Defaults(), --Radiating Poison
				[172066] = Defaults(), --Radiating Poison
				[166779] = Defaults(), --Staggering Blow
				[56037] = Defaults(), --Rune of Destruction
				[175654] = Defaults(), --Rune of Disintegration
				[166185] = Defaults(), --Rending Slash
				[166175] = Defaults(), --Earth Devastating Slam
				[174404] = Defaults(), --Frozen Core
				[173763] = Defaults(), --Wild Flames
				[174500] = Defaults(), --Rending Throw
				[174939] = Defaults(), --Time Stop
				[172115] = Defaults(), --Earthen Thrust
				[166200] = Defaults(), --Arcane Volatility
				[174473] = Defaults(), --Corrupted Blood

			--Kargath Bladefist
				[158986] = Defaults(), --Berserker Rush
				[159113] = Defaults(), --Impale
				[159178] = Defaults(), --Open Wounds
				[159213] = Defaults(), --Monsters Brawl
				[159410] = Defaults(), --Mauling Brew
				[160521] = Defaults(), --Vile Breath
				[159386] = Defaults(), --Iron Bomb
				[159188] = Defaults(), --Grapple
				[162497] = Defaults(), --On the hunt
				[159202] = Defaults(), --Flame jet

			--The Butcher
				[156152] = Defaults(), --Gushing Wounds
				[156151] = Defaults(), --The Tenderizer
				[156143] = Defaults(), --The Cleaver
				[163046] = Defaults(), --Pale Vitriol

			--Brackenspore
				[159220] = Defaults(), --Necrotic Breath
				[163242] = Defaults(), --Infesting Spores
				[163590] = Defaults(), --Creeping Moss
				[163241] = Defaults(), --Rot
				[160179] = Defaults(), --Mind Fungus
				[159972] = Defaults(), --Flesh Eater

			--Tectus
				[162346] = Defaults(), --Crystalline Barrage
				[162892] = Defaults(), --Petrification
				[162475] = Defaults(), --Tectonic Upheaval

			--Twin Ogrons
				[155569] = Defaults(), --Injured
				[158241] = Defaults(), --Blaze
				[158026] = Defaults(), --Enfeebling Roar
				[167200] = Defaults(), --Arcane Wound
				[159709] = Defaults(), --Weakened Defenses
				[167179] = Defaults(), --Weakened Defenses
				[163374] = Defaults(), --Arcane Volatility
				[158200] = Defaults(), --Quake

			--Ko'ragh
				[163472] = Defaults(), --Dominating Power
				[172895] = Defaults(), --Expel Magic: Fel
				[162185] = Defaults(), --Expel Magic: Fire
				[162184] = Defaults(), --Expel Magic: Shadow
				[161242] = Defaults(), --Caustic Energy
				[161358] = Defaults(), --Suppression Field
				[156803] = Defaults(), --Nullification Barrier

			--Imperator Mar'gok
				[164004] = Defaults(), --Branded: Displacement
				[164005] = Defaults(), --Branded: Fortification
				[164006] = Defaults(), --Branded: Replication
				[158619] = Defaults(), --Fetter
				[164176] = Defaults(), --Mark of Chaos: Displacement
				[164178] = Defaults(), --Mark of Chaos: Fortification
				[164191] = Defaults(), --Mark of Chaos: Replication
				[157349] = Defaults(), --Force Nova
				[164232] = Defaults(), --Force Nova
				[164235] = Defaults(), --Force Nova
				[164240] = Defaults(), --Force Nova
				[158553] = Defaults(), --Crush Armor
				[165102] = Defaults(), --Infinite Darkness
				[157801] = Defaults(), --Slow

		--Blackrock Foundry
			--Trash

			--Blackhand
				[156096] = Defaults(), --Marked for Death
				[156743] = Defaults(), --Impaled
				[156047] = Defaults(), --Slagged
				[156401] = Defaults(), --Molten Slag
				[156404] = Defaults(), --Burned
				[158054] = Defaults(), --Shattering Smash
				[156888] = Defaults(), --Overheated
				[157000] = Defaults(), --Attach Slag Bombs
				[156999] = Defaults(), --Throw Slag Bombs

			--Beastlord Darmac
				[155365] = Defaults(), --Pinned Down
				[155061] = Defaults(), --Rend and Tear
				[155030] = Defaults(), --Seared Flesh
				[155236] = Defaults(), --Crush Armor
				[159044] = Defaults(), --Epicentre
				[162276] = Defaults(), --Unsteady Mythic
				[155657] = Defaults(), --Flame Infusion
				[155222] = Defaults(), --Tantrum
				[155399] = Defaults(), --Conflagration
				[154989] = Defaults(), --Inferno Breath
				[155499] = Defaults(), --Superheated Shrapnel

			--Flamebender Ka'graz
				[155318] = Defaults(), --Lava Slash
				[155277] = Defaults(), --Blazing Radiance
				[154952] = Defaults(), --Fixate
				[155074] = Defaults(), --Charring Breath
				[163284] = Defaults(), --Rising Flame
				[162293] = Defaults(), --Empowered Armament
				[155493] = Defaults(), --Firestorm
				[163633] = Defaults(), --Magma Monsoon

			--Operator Thogar
				[155921] = Defaults(), --Enkindle
				[165195] = Defaults(), --Prototype Pulse Grenade
				[155701] = Defaults(), --Serrated Slash
				[156310] = Defaults(), --Lava Shock
				[164380] = Defaults(), --Burning

			--The Blast Furnace
				[155240] = Defaults(), --Tempered
				[155242] = Defaults(), --Heath
				[176133] = Defaults(), --Bomb
				[156934] = Defaults(), --Rupture
				[175104] = Defaults(), --Melt Armor
				[176121] = Defaults(), --Volatile Fire
				[158702] = Defaults(), --Fixate
				[155225] = Defaults(), --Melt

			--Hans'gar and Franzok
				[157139] = Defaults(), --Shattered Vertebrae
				[161570] = Defaults(), --Searing Plates
				[157853] = Defaults(), --Aftershock

			--Gruul
				[155080] = Defaults(), --Inferno Slice
				[143962] = Defaults(), --Inferno Strike
				[155078] = Defaults(), --Overwhelming Blows
				[36240] = Defaults(), --Cave In
				[155326] = Defaults(), --Petrifying Slam
				[165300] = Defaults(), --Flare Mythic

			--Kromog
				[157060] = Defaults(), --Rune of Grasping Earth
				[156766] = Defaults(), --Warped Armor
				[161839] = Defaults(), --Rune of Crushing Earth
				[156844] = Defaults(), --Stone Breath

			--Oregorger
				[156309] = Defaults(), --ACid Torrent
				[156203] = Defaults(), --Retched Blackrock
				[173471] = Defaults(), --Acidmaw

			--The Iron Maidens
				[164271] = Defaults(), --Penetrating Shot
				[158315] = Defaults(), --Dark hunt
				[156601] = Defaults(), --Sanguine Strikes
				[170395] = Defaults(), --Sorka Sprey
				[170405] = Defaults(), --Maraks Blood Calling
				[158692] = Defaults(), --Deadly Throw
				[158702] = Defaults(), --Fixate
				[158686] = Defaults(), --Expose Armor
				[158683] = Defaults(), --Corrupted Blood
				[159585] = Defaults(), --Deploy Turret
				[156112] = Defaults(), --Convulsive Shadows

		-- Hellfire Citadel
			-- Hellfire Assault
				[184369] = Defaults(), -- Howling Axe (Target)
				[180079] = Defaults(), -- Felfire Munitions

			-- Iron Reaver
				[179897] = Defaults(), -- Blitz
				[185978] = Defaults(), -- Firebomb Vulnerability
				[182373] = Defaults(), -- Flame Vulnerability
				[182280] = Defaults(), -- Artillery (Target)
				[182074] = Defaults(), -- Immolation
				[182001] = Defaults(), -- Unstable Orb

			-- Kormrok
				[187819] = Defaults(), -- Crush
				[181345] = Defaults(), -- Foul Crush

			-- Hellfire High Council
				[184360] = Defaults(), -- Fel Rage
				[184449] = Defaults(), -- Mark of the Necromancer
				[185065] = Defaults(), -- Mark of the Necromancer
				[184450] = Defaults(), -- Mark of the Necromancer
				[185066] = Defaults(), -- Mark of the Necromancer
				[184676] = Defaults(), -- Mark of the Necromancer
				[184652] = Defaults(), -- Reap

			-- Kilrogg Deadeye
				[181488] = Defaults(), -- Vision of Death
				[188929] = Defaults(), -- Heart Seeker (Target)
				[180389] = Defaults(), -- Heart Seeker (DoT)

			-- Gorefiend
				[179867] = Defaults(), -- Gorefiend's Corruption
				[181295] = Defaults(), -- Digest
				[179977] = Defaults(), -- Touch of Doom
				[179864] = Defaults(), -- Shadow of Death
				[179909] = Defaults(), -- Shared Fate (self root)
				[179908] = Defaults(), -- Shared Fate (other players root)

			-- Shadow-Lord Iskar
				[181957] = Defaults(), -- Phantasmal Winds
				[182200] = Defaults(), -- Fel Chakram
				[182178] = Defaults(), -- Fel Chakram
				[182325] = Defaults(), -- Phantasmal Wounds
				[185239] = Defaults(), -- Radiance of Anzu
				[185510] = Defaults(), -- Dark Bindings
				[182600] = Defaults(), -- Fel Fire
				[179219] = Defaults(), -- Phantasmal Fel Bomb
				[181753] = Defaults(), -- Fel Bomb

			-- Soulbound Construct (Socrethar)
				[182038] = Defaults(), -- Shattered Defenses
				[188666] = Defaults(), -- Eternal Hunger (Add fixate, Mythic only)
				[189627] = Defaults(), -- Volatile Fel Orb (Fixated)
				[180415] = Defaults(), -- Fel Prison

			-- Tyrant Velhari
				[185237] = Defaults(), -- Touch of Harm
				[185238] = Defaults(), -- Touch of Harm
				[185241] = Defaults(), -- Edict of Condemnation
				[180526] = Defaults(), -- Font of Corruption

			-- Fel Lord Zakuun
				[181508] = Defaults(), -- Seed of Destruction
				[181653] = Defaults(), -- Fel Crystals (Too Close)
				[179428] = Defaults(), -- Rumbling Fissure (Soak)
				[182008] = Defaults(), -- Latent Energy (Cannot soak)
				[179407] = Defaults(), -- Disembodied (Player in Shadow Realm)

			-- Xhul'horac
				[188208] = Defaults(), -- Ablaze
				[186073] = Defaults(), -- Felsinged
				[186407] = Defaults(), -- Fel Surge
				[186500] = Defaults(), -- Chains of Fel
				[186063] = Defaults(), -- Wasting Void
				[186333] = Defaults(), -- Void Surge

			-- Mannoroth
				[181275] = Defaults(), -- Curse of the Legion
				[181099] = Defaults(), -- Mark of Doom
				[181597] = Defaults(), -- Mannoroth's Gaze
				[182006] = Defaults(), -- Empowered Mannoroth's Gaze
				[181841] = Defaults(), -- Shadowforce
				[182088] = Defaults(), -- Empowered Shadowforce

			-- Archimonde
				[184964] = Defaults(), -- Shackled Torment
				[186123] = Defaults(), -- Wrought Chaos
				[185014] = Defaults(), -- Focused Chaos
				[186952] = Defaults(), -- Nether Banish
				[186961] = Defaults(), -- Nether Banish
				[189891] = Defaults(), -- Nether Tear
				[183634] = Defaults(), -- Shadowfel Burst
				[189895] = Defaults(), -- Void Star Fixate
				[190049] = Defaults(), -- Nether Corruption
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
	[SpellName(689))] = 6, -- "Drain Life"
	[SpellName(108371)] = 6, -- "Harvest Life"
	[SpellName(5740)] = 4, -- "Rain of Fire"
	[SpellName(755)] = 6, -- Health Funnel
	[SpellName(103103)] = 4, --Malefic Grasp
	--Druid
	[SpellName(16914)] = 10, -- "Hurricane"
	--Priest
	[SpellName(48045)] = 5, -- "Mind Sear"
	[SpellName(179338)] = 5, -- "Searing insanity"
	[SpellName(64843)] = 4, -- Divine Hymn
	--Mage
	[SpellName(5143)] = 5, -- "Arcane Missiles"
	[SpellName(10)] = 8, -- "Blizzard"
	[SpellName(12051)] = 3, -- "Evocation"

	--Monk
	[SpellName(115175)] = 9, -- "Smoothing Mist"
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
		E.global.unitframe.ChannelTicks[SpellName(15407)] = mfTicks -- "Mind Flay"
		E.global.unitframe.ChannelTicks[SpellName(129197)] = mfTicks -- "Mind Flay (Insanity)"
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
	E.global.unitframe.ChannelTicks[SpellName(47540)] = penanceTicks --Penance
end)

G.unitframe.ChannelTicksSize = {
	--Warlock
	[SpellName(689)] = 1, -- "Drain Life"
	[SpellName(108371)] = 1, -- "Harvest Life"
	[SpellName(103103)] = 1, -- "Malefic Grasp"
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
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}},
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