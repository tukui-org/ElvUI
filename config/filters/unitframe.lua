local E, L = unpack(select(2, ...)); --Engine
local DF = E.DF["profile"]['unitframe']['aurafilters']

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id) 	
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

DF['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		-- Death Knight
			[SpellName(47476)] = true, --strangulate
			[SpellName(49203)] = true, --hungering cold
		-- Druid
			[SpellName(33786)] = true, --Cyclone
			[SpellName(2637)] = true, --Hibernate
			[SpellName(339)] = true, --Entangling Roots
			[SpellName(80964)] = true, --Skull Bash
			[SpellName(78675)] = true, --Solar Beam
		-- Hunter
			[SpellName(3355)] = true, --Freezing Trap Effect
			--[SpellName(60210)] = true, --Freezing Arrow Effect
			[SpellName(1513)] = true, --scare beast
			[SpellName(19503)] = true, --scatter shot
			[SpellName(34490)] = true, --silence shot
		-- Mage
			[SpellName(31661)] = true, --Dragon's Breath
			[SpellName(61305)] = true, --Polymorph
			[SpellName(18469)] = true, --Silenced - Improved Counterspell
			[SpellName(122)] = true, --Frost Nova
			[SpellName(55080)] = true, --Shattered Barrier
			[SpellName(82691)] = true, --Ring of Frost
		-- Paladin
			[SpellName(20066)] = true, --Repentance
			[SpellName(10326)] = true, --Turn Evil
			[SpellName(853)] = true, --Hammer of Justice
		-- Priest
			[SpellName(605)] = true, --Mind Control
			[SpellName(64044)] = true, --Psychic Horror
			[SpellName(8122)] = true, --Psychic Scream
			[SpellName(9484)] = true, --Shackle Undead
			[SpellName(15487)] = true, --Silence
		-- Rogue
			[SpellName(2094)] = true, --Blind
			[SpellName(1776)] = true, --Gouge
			[SpellName(6770)] = true, --Sap
			[SpellName(18425)] = true, --Silenced - Improved Kick
		-- Shaman
			[SpellName(51514)] = true, --Hex
			[SpellName(3600)] = true, --Earthbind
			[SpellName(8056)] = true, --Frost Shock
			[SpellName(63685)] = true, --Freeze
			[SpellName(39796)] = true, --Stoneclaw Stun
		-- Warlock
			[SpellName(710)] = true, --Banish
			[SpellName(6789)] = true, --Death Coil
			[SpellName(5782)] = true, --Fear
			[SpellName(5484)] = true, --Howl of Terror
			[SpellName(6358)] = true, --Seduction
			[SpellName(30283)] = true, --Shadowfury
			[SpellName(89605)] = true, --Aura of Foreboding
		-- Warrior
			[SpellName(20511)] = true, --Intimidating Shout
			[SpellName(12809)] = true, --Concussion Blow
		-- Racial
			[SpellName(25046)] = true, --Arcane Torrent
			[SpellName(20549)] = true, --War Stomp		
	},
}

DF['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(33206)] = true, -- Pain Suppression
		[SpellName(47788)] = true, -- Guardian Spirit	
		[SpellName(1044)] = true, -- Hand of Freedom
		[SpellName(1022)] = true, -- Hand of Protection
		[SpellName(1038)] = true, -- Hand of Salvation
		[SpellName(6940)] = true, -- Hand of Sacrifice
		[SpellName(62618)] = true, --Power Word: Barrier
		[SpellName(70940)] = true, -- Divine Guardian 	
		[SpellName(53480)] = true, -- Roar of Sacrifice
	},
}

DF['DebuffBlacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[SpellName(8733)] = true, --Blessing of Blackfathom
		[SpellName(57724)] = true, --Sated
		[SpellName(25771)] = true, --forbearance
		[SpellName(57723)] = true, --Exhaustion
		[SpellName(36032)] = true, --arcane blast
		[SpellName(58539)] = true, --watchers corpse
		[SpellName(26013)] = true, --deserter
		[SpellName(6788)] = true, --weakended soul
		[SpellName(71041)] = true, --dungeon deserter
		[SpellName(41425)] = true, --"Hypothermia"
		[SpellName(55711)] = true, --Weakened Heart
		[SpellName(8326)] = true, --ghost
		[SpellName(23445)] = true, --evil twin
		[SpellName(24755)] = true, --gay homosexual tricked or treated debuff
		[SpellName(25163)] = true, --fucking annoying pet debuff oozeling disgusting aura
		[SpellName(80354)] = true, --timewarp debuff
		[SpellName(95223)] = true, --group res debuff
	},
}

--RAID DEBUFFS
DF['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Test
		--[SpellName(25771)] = true, --Forbearance

	-- Other debuff
		[SpellName(67479)] = true, -- Impale

	--Blackwing Descent
		--Magmaw
		[SpellName(91911)] = true, -- Constricting Chains
		[SpellName(94679)] = true, -- Parasitic Infection
		[SpellName(94617)] = true, -- Mangle
		[SpellName(78199)] = true, -- Sweltering Armor

		--Omintron Defense System
		[SpellName(91433)] = true, --Lightning Conductor
		[SpellName(91521)] = true, --Incineration Security Measure
		[SpellName(80094)] = true, --Fixate 

		--Maloriak
		[SpellName(77699)] = true, -- Flash Freeze
		[SpellName(77760)] = true, -- Biting Chill

		--Atramedes
		[SpellName(92423)] = true, -- Searing Flame
		[SpellName(92485)] = true, -- Roaring Flame
		[SpellName(92407)] = true, -- Sonic Breath

		--Chimaeron
		[SpellName(82881)] = true, -- Break
		[SpellName(89084)] = true, -- Low Health

		--Nefarian

		--Sinestra
		[SpellName(92956)] = true, --Wrack

	--The Bastion of Twilight
		--Valiona & Theralion
		[SpellName(92878)] = true, -- Blackout
		[SpellName(86840)] = true, -- Devouring Flames
		[SpellName(95639)] = true, -- Engulfing Magic
		[SpellName(92886)] = true, -- Twilight Zone
		[SpellName(88518)] = true, -- Twilight Meteorite

		--Halfus Wyrmbreaker
		[SpellName(39171)] = true, -- Malevolent Strikes

		--Twilight Ascendant Council
		[SpellName(92511)] = true, -- Hydro Lance
		[SpellName(82762)] = true, -- Waterlogged
		[SpellName(92505)] = true, -- Frozen
		[SpellName(92518)] = true, -- Flame Torrent
		[SpellName(83099)] = true, -- Lightning Rod
		[SpellName(92075)] = true, -- Gravity Core
		[SpellName(92488)] = true, -- Gravity Crush

		--Cho'gall
		[SpellName(86028)] = true, -- Cho's Blast
		[SpellName(86029)] = true, -- Gall's Blast

	--Throne of the Four Winds
		--Conclave of Wind
			--Nezir <Lord of the North Wind>
			[SpellName(93131)] = true, --Ice Patch
			--Anshal <Lord of the West Wind>
			[SpellName(86206)] = true, --Soothing Breeze
			[SpellName(93122)] = true, --Toxic Spores
			--Rohash <Lord of the East Wind>
			[SpellName(93058)] = true, --Slicing Gale
			
		--Al'Akir
		[SpellName(93260)] = true, -- Ice Storm
		[SpellName(93295)] = true, -- Lightning Rod
		
	--Firelands	
		--Beth'tilac
		[SpellName(99506)] = true, -- Widows Kiss
		
		--Alysrazor
		[SpellName(101296)] = true, -- Fiero Blast
		[SpellName(100723)] = true, -- Gushing Wound
		
		--Shannox
		[SpellName(99837)] = true, -- Crystal Prison
		[SpellName(99937)] = true, -- Jagged Tear
		
		--Baleroc
		[SpellName(99403)] = true, -- Tormented
		[SpellName(99256)] = true, -- Torment
		
		--Lord Rhyolith
			--<< NONE KNOWN YET >>
		
		--Majordomo Staghelm
		[SpellName(98450)] = true, -- Searing Seeds
		[SpellName(98565)] = true, -- Burning Orb
		
		--Ragnaros
		[SpellName(99399)] = true, -- Burning Wound
			
		--Trash
		[SpellName(99532)] = true, -- Melt Armor	
		
	--Baradin Hold
		--Occu'thar
		[SpellName(96913)] = true, -- Searing Shadows
		--Alizabal
		[SpellName(104936)] = true, -- Skewer
		
	--Dragon Soul
	    --Morchok
		[SpellName(103541)] = true, -- Safe
		[SpellName(103536)] = true, -- Warning
		[SpellName(103534)] = true, -- Danger
		[SpellName(108570)] = true, -- Black Blood of the Earth

		--Warlord Zon'ozz
		[SpellName(103434)] = true, -- Disrupting Shadows

		--Yor'sahj the Unsleeping
		[SpellName(105171)] = true, -- Deep Corruption

		--Hagara the Stormbinder
		[SpellName(105465)] = true, -- Lighting Storm
		[SpellName(104451)] = true, -- Ice Tomb
		[SpellName(109325)] = true, -- Frostflake
		[SpellName(105289)] = true, -- Shattered Ice
		[SpellName(105285)] = true, -- Target

		--Ultraxion
		[SpellName(110079)] = true, -- Fading Light
		[SpellName(109075)] = true, -- Fading Light

		--Warmaster Blackhorn
		[SpellName(108043)] = true, -- Sunder Armor
		[SpellName(107558)] = true, -- Degeneration
		[SpellName(107567)] = true, -- Brutal Strike
		[SpellName(108046)] = true, -- Shockwave

		--Spine of Deathwing
		[SpellName(105479)] = true, -- Searing Plasma
		[SpellName(105490)] = true, -- Fiery Grip

		--Madness of Deathwing
		[SpellName(105445)] = true, -- Blistering Heat
		[SpellName(105841)] = true, -- Degenerative Bite
		[SpellName(106385)] = true, -- Crush
		[SpellName(106730)] = true, -- Tetanus
		[SpellName(106444)] = true, -- Impale
		[SpellName(106794)] = true, -- Shrapnel (target)		
	},
}

E.ReverseTimer = {
	[92956] = true, -- Sinestra (Wrack)
	[89435] = true, -- Sinestra (Wrack)
	[92955] = true, -- Sinestra (Wrack)
	[89421] = true, -- Sinestra (Wrack)
}

--BuffWatch
local DF = E.DF["profile"]['unitframe']

local function ClassBuff(id, point, color, anyUnit, onlyShowMissing)
	local r, g, b = unpack(color)
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, ["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing}
end

DF.buffwatch = {
	PRIEST = {
		ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Weakened Soul
		ClassBuff(33076, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Prayer of Mending
		ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		ClassBuff(17, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Power Word: Shield
		ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		ClassBuff(33206, "LEFT", {227/255, 23/255, 13/255}, true), -- Pain Suppression
		ClassBuff(47788, "LEFT", {221/255, 117/255, 0}, true), -- Guardian Spirit
	},
	DRUID = {
		ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Rejuvenation
		ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Regrowth
		ClassBuff(94447, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom
		ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Wild Growth
	},
	PALADIN = {
		ClassBuff(53563, "RIGHT", {0.7, 0.3, 0.7}), -- Beacon of Light
		ClassBuff(1022, "TOPRIGHT", {0.2, 0.2, 1}, true), -- Hand of Protection
		ClassBuff(1044, "TOPRIGHT", {221/255, 117/255, 0}, true), -- Hand of Freedom
		ClassBuff(6940, "TOPRIGHT", {227/255, 23/255, 13/255}, true), -- Hand of Sacrafice
		ClassBuff(1038, "TOPRIGHT", {238/255, 201/255, 0}, true), -- Hand of Salvation
	},
	ROGUE = {
		ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Tricks of the Trade
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Hysteria
	},
	MAGE = {
		ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Focus Magic
	},
	WARRIOR = {
		ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Vigilance
		ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene
	},
	SHAMAN = {
		ClassBuff(61295, "TOPLEFT", {0.7, 0.3, 0.7}), -- Riptide 
		ClassBuff(16236, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Ancestral Fortitude
		ClassBuff(51945, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Earthliving
		ClassBuff(974, "TOPRIGHT", {221/255, 117/255, 0}, true), -- Earth Shield
	},	
}

--List of spells to display ticks
DF.ChannelTicks = {
	--Warlock
	[SpellName(1120)] = 5, --"Drain Soul"
	[SpellName(689)] = 3, -- "Drain Life"
	[SpellName(5740)] = 4, -- "Rain of Fire"
	[SpellName(755)] = 3, -- Health Funnel
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
	[SpellName(10)] = 5, -- "Blizzard"
	[SpellName(12051)] = 4, -- "Evocation"
}

--Spells Effected By Haste
DF.HastedChannelTicks = {
	[SpellName(64901)] = true, -- Hymn of Hope
	[SpellName(64843)] = true, -- Divine Hymn
	[SpellName(1120)] = true, -- Drain Soul
}

