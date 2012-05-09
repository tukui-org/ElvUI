local E, L, V, P, G = unpack(select(2, ...)); --Engine

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id) 	
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end
G.unitframe.aurafilters = {};

G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		-- Death Knight
			[SpellName(47476)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --strangulate
			[SpellName(49203)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --hungering cold
		-- Druid
			[SpellName(33786)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Cyclone
			[SpellName(2637)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Hibernate
			[SpellName(339)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Entangling Roots
			[SpellName(80964)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Skull Bash
			[SpellName(78675)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Solar Beam
		-- Hunter
			[SpellName(3355)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Freezing Trap Effect
			--[[[SpellName(60210)] = { 
				['enable'] = true,
				['priority'] = 0,
			},]] --Freezing Arrow Effect
			[SpellName(1513)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --scare beast
			[SpellName(19503)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --scatter shot
			[SpellName(34490)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --silence shot
		-- Mage
			[SpellName(31661)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Dragon's Breath
			[SpellName(61305)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Polymorph
			[SpellName(18469)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Silenced - Improved Counterspell
			[SpellName(122)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Frost Nova
			[SpellName(55080)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Shattered Barrier
			[SpellName(82691)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Ring of Frost
		-- Paladin
			[SpellName(20066)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Repentance
			[SpellName(10326)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Turn Evil
			[SpellName(853)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Hammer of Justice
		-- Priest
			[SpellName(605)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Mind Control
			[SpellName(64044)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Psychic Horror
			[SpellName(8122)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Psychic Scream
			[SpellName(9484)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Shackle Undead
			[SpellName(15487)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Silence
		-- Rogue
			[SpellName(2094)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Blind
			[SpellName(1776)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Gouge
			[SpellName(6770)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Sap
			[SpellName(18425)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Silenced - Improved Kick
		-- Shaman
			[SpellName(51514)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Hex
			[SpellName(3600)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Earthbind
			[SpellName(8056)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Frost Shock
			[SpellName(63685)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Freeze
			[SpellName(39796)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Stoneclaw Stun
		-- Warlock
			[SpellName(710)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Banish
			[SpellName(6789)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Death Coil
			[SpellName(5782)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Fear
			[SpellName(5484)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Howl of Terror
			[SpellName(6358)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Seduction
			[SpellName(30283)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Shadowfury
			[SpellName(89605)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Aura of Foreboding
		-- Warrior
			[SpellName(20511)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Intimidating Shout
			[SpellName(12809)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Concussion Blow
		-- Racial
			[SpellName(25046)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --Arcane Torrent
			[SpellName(20549)] = { 
				['enable'] = true,
				['priority'] = 0,
			}, --War Stomp		
	},
}

G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(33206)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Pain Suppression
		[SpellName(47788)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Guardian Spirit	
		[SpellName(1044)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Hand of Freedom
		[SpellName(1022)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Hand of Protection
		[SpellName(1038)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Hand of Salvation
		[SpellName(6940)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Hand of Sacrifice
		[SpellName(62618)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Power Word: Barrier
		[SpellName(70940)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Divine Guardian 	
		[SpellName(53480)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Roar of Sacrifice
	},
}

G.unitframe.aurafilters['DebuffBlacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[SpellName(8733)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Blessing of Blackfathom
		[SpellName(57724)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Sated
		[SpellName(25771)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --forbearance
		[SpellName(57723)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Exhaustion
		[SpellName(36032)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --arcane blast
		[SpellName(58539)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --watchers corpse
		[SpellName(26013)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --deserter
		[SpellName(6788)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --weakended soul
		[SpellName(71041)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --dungeon deserter
		[SpellName(41425)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --"Hypothermia"
		[SpellName(55711)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Weakened Heart
		[SpellName(8326)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --ghost
		[SpellName(23445)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --evil twin
		[SpellName(24755)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --gay homosexual tricked or treated debuff
		[SpellName(25163)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --fucking annoying pet debuff oozeling disgusting aura
		[SpellName(80354)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --timewarp debuff
		[SpellName(95223)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --group res debuff
	},
}

--RAID DEBUFFS
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {

	-- Other debuff
		[SpellName(67479)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Impale

	--Blackwing Descent
		--Magmaw
		[SpellName(91911)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Constricting Chains
		[SpellName(94679)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Parasitic Infection
		[SpellName(94617)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Mangle
		[SpellName(78199)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Sweltering Armor

		--Omintron Defense System
		[SpellName(91433)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Lightning Conductor
		[SpellName(91521)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Incineration Security Measure
		[SpellName(80094)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Fixate 

		--Maloriak
		[SpellName(77699)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Flash Freeze
		[SpellName(77760)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Biting Chill

		--Atramedes
		[SpellName(92423)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Searing Flame
		[SpellName(92485)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Roaring Flame
		[SpellName(92407)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Sonic Breath

		--Chimaeron
		[SpellName(82881)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Break
		[SpellName(89084)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Low Health

		--Nefarian

		--Sinestra
		[SpellName(92956)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Wrack

	--The Bastion of Twilight
		--Valiona & Theralion
		[SpellName(92878)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Blackout
		[SpellName(86840)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Devouring Flames
		[SpellName(95639)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Engulfing Magic
		[SpellName(92886)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Twilight Zone
		[SpellName(88518)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Twilight Meteorite

		--Halfus Wyrmbreaker
		[SpellName(39171)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Malevolent Strikes

		--Twilight Ascendant Council
		[SpellName(92511)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Hydro Lance
		[SpellName(82762)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Waterlogged
		[SpellName(92505)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Frozen
		[SpellName(92518)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Flame Torrent
		[SpellName(83099)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Lightning Rod
		[SpellName(92075)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Gravity Core
		[SpellName(92488)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Gravity Crush

		--Cho'gall
		[SpellName(86028)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Cho's Blast
		[SpellName(86029)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Gall's Blast

	--Throne of the Four Winds
		--Conclave of Wind
			--Nezir <Lord of the North Wind>
			[SpellName(93131)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Ice Patch
			--Anshal <Lord of the West Wind>
			[SpellName(86206)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Soothing Breeze
			[SpellName(93122)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Toxic Spores
			--Rohash <Lord of the East Wind>
			[SpellName(93058)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, --Slicing Gale
			
		--Al'Akir
		[SpellName(93260)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Ice Storm
		[SpellName(93295)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Lightning Rod
		
	--Firelands	
		--Beth'tilac
		[SpellName(99506)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Widows Kiss
		
		--Alysrazor
		[SpellName(101296)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Fiero Blast
		[SpellName(100723)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Gushing Wound
		
		--Shannox
		[SpellName(99837)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Crystal Prison
		[SpellName(99937)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Jagged Tear
		
		--Baleroc
		[SpellName(99403)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Tormented
		[SpellName(99256)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Torment
		
		--Lord Rhyolith
			--<< NONE KNOWN YET >>
		
		--Majordomo Staghelm
		[SpellName(98450)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Searing Seeds
		[SpellName(98565)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Burning Orb
		
		--Ragnaros
		[SpellName(99399)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Burning Wound
			
		--Trash
		[SpellName(99532)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Melt Armor	
		
	--Baradin Hold
		--Occu'thar
		[SpellName(96913)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Searing Shadows
		--Alizabal
		[SpellName(104936)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Skewer
		
	--Dragon Soul
	    --Morchok
		[SpellName(103541)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Safe
		[SpellName(103536)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Warning
		[SpellName(103534)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Danger
		[SpellName(108570)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Black Blood of the Earth

		--Warlord Zon'ozz
		[SpellName(103434)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Disrupting Shadows

		--Yor'sahj the Unsleeping
		[SpellName(105171)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Deep Corruption

		--Hagara the Stormbinder
		[SpellName(105465)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Lighting Storm
		[SpellName(104451)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Ice Tomb
		[SpellName(109325)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Frostflake
		[SpellName(105289)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Shattered Ice
		[SpellName(105285)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Target

		--Ultraxion
		[SpellName(109075)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Fading Light

		--Warmaster Blackhorn
		[SpellName(108043)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Sunder Armor
		[SpellName(107558)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Degeneration
		[SpellName(107567)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Brutal Strike
		[SpellName(108046)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Shockwave

		--Spine of Deathwing
		[SpellName(105479)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Searing Plasma
		[SpellName(105490)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Fiery Grip
		[SpellName(106199)] = { 
			['enable'] = true,
			['priority'] = 5,
		}, -- Blood Corruption: Death
		--Madness of Deathwing
		[SpellName(105841)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Degenerative Bite
		[SpellName(106385)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Crush
		[SpellName(106730)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Tetanus
		[SpellName(106444)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Impale
		[SpellName(106794)] = { 
			['enable'] = true,
			['priority'] = 0,
		}, -- Shrapnel (target)		
	},
}

E.ReverseTimer = {
	[92956] = true, -- Sinestra (Wrack)
	[89435] = true, -- Sinestra (Wrack)
	[92955] = true, -- Sinestra (Wrack)
	[89421] = true, -- Sinestra (Wrack)
}

--BuffWatch

local function ClassBuff(id, point, color, anyUnit, onlyShowMissing)
	local r, g, b = unpack(color)
	return {["enabled"] = { 
			['enable'] = true,
			['priority'] = 0,
		}, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, ["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing}
end

G.unitframe.buffwatch = {
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
G.unitframe.ChannelTicks = {
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
G.unitframe.HastedChannelTicks = {
	[SpellName(64901)] = true, -- Hymn of Hope
	[SpellName(64843)] = true, -- Divine Hymn
	[SpellName(1120)] = true, -- Drain Soul
}

