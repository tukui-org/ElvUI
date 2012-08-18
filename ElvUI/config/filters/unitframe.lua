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
			[SpellName(47476)] = Defaults(), --strangulate
			[SpellName(79092)] = Defaults(), --hungering cold
		-- Druid
			[SpellName(33786)] = Defaults(), --Cyclone
			[SpellName(2637)] = Defaults(), --Hibernate
			[SpellName(339)] = Defaults(), --Entangling Roots
			[SpellName(80964)] = Defaults(), --Skull Bash
			[SpellName(78675)] = Defaults(), --Solar Beam
		-- Hunter
			[SpellName(3355)] = Defaults(), --Freezing Trap Effect
			[SpellName(1513)] = Defaults(), --scare beast
			[SpellName(19503)] = Defaults(), --scatter shot
			[SpellName(34490)] = Defaults(), --silence shot
		-- Mage
			[SpellName(31661)] = Defaults(), --Dragon's Breath
			[SpellName(61305)] = Defaults(), --Polymorph
			[SpellName(55021)] = Defaults(), --Silenced - Improved Counterspell
			[SpellName(122)] = Defaults(), --Frost Nova
			[SpellName(82691)] = Defaults(), --Ring of Frost
		-- Paladin
			[SpellName(20066)] = Defaults(), --Repentance
			[SpellName(10326)] = Defaults(), --Turn Evil
			[SpellName(853)] = Defaults(), --Hammer of Justice
		-- Priest
			[SpellName(605)] = Defaults(), --Mind Control
			[SpellName(64044)] = Defaults(), --Psychic Horror
			[SpellName(8122)] = Defaults(), --Psychic Scream
			[SpellName(9484)] = Defaults(), --Shackle Undead
			[SpellName(15487)] = Defaults(), --Silence
		-- Rogue
			[SpellName(2094)] = Defaults(), --Blind
			[SpellName(1776)] = Defaults(), --Gouge
			[SpellName(6770)] = Defaults(), --Sap
		-- Shaman
			[SpellName(51514)] = Defaults(), --Hex
			[SpellName(3600)] = Defaults(), --Earthbind
			[SpellName(8056)] = Defaults(), --Frost Shock
			[SpellName(63685)] = Defaults(), --Freeze
		-- Warlock
			[SpellName(710)] = Defaults(), --Banish
			[SpellName(6789)] = Defaults(), --Death Coil
			[SpellName(5782)] = Defaults(), --Fear
			[SpellName(5484)] = Defaults(), --Howl of Terror
			[SpellName(6358)] = Defaults(), --Seduction
			[SpellName(30283)] = Defaults(), --Shadowfury
		-- Warrior
			[SpellName(20511)] = Defaults(), --Intimidating Shout
		-- Racial
			[SpellName(25046)] = Defaults(), --Arcane Torrent
			[SpellName(20549)] = Defaults(), --War Stomp		
	},
}

--[[
	These are buffs that can be considered "protection" buffs
]]
G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(33206)] = Defaults(), -- Pain Suppression
		[SpellName(47788)] = Defaults(), -- Guardian Spirit
		[SpellName(62618)] = Defaults(), --Power Word: Barrier
		[SpellName(1044)] = Defaults(), -- Hand of Freedom
		[SpellName(1022)] = Defaults(), -- Hand of Protection
		[SpellName(1038)] = Defaults(), -- Hand of Salvation
		[SpellName(6940)] = Defaults(), -- Hand of Sacrifice
		[SpellName(114039)] = Defaults(), -- Hand of Purity
		[SpellName(53480)] = Defaults(), -- Roar of Sacrifice	
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
	},
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing)
	local r, g, b = unpack(color)
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, ["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing}
end

G.unitframe.buffwatch = {
	PRIEST = {
		ClassBuff(6788, "TOPRIGHT", {1, 0, 0}, true),	 -- Weakened Soul
		ClassBuff(33076, "BOTTOMRIGHT", {0.2, 0.7, 0.2}),	 -- Prayer of Mending
		ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		ClassBuff(17, "TOPLEFT", {0.81, 0.85, 0.1}, true),	 -- Power Word: Shield
		ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		ClassBuff(47788, "LEFT", {221/255, 117/255, 0}, true), -- Guardian Spirit
		ClassBuff(33206, "LEFT", {227/255, 23/255, 13/255}, true), -- Pain Suppression		
	},
	DRUID = {
		ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}),	 -- Rejuvenation
		ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}),	 -- Regrowth
		ClassBuff(94447, "TOPLEFT", {0.4, 0.8, 0.2}),	 -- Lifebloom
		ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}),	 -- Wild Growth
	},
	PALADIN = {
		ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}),	 -- Beacon of Light
		ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),	-- Hand of Protection
		ClassBuff(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true),	-- Hand of Freedom
		ClassBuff(1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true),	-- Hand of Salvation
		ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true),	-- Hand of Sacrifice
	},
	SHAMAN = {
		ClassBuff(61295, "TOPRIGHT", {0.7, 0.3, 0.7}),	 -- Riptide
		ClassBuff(974, "BOTTOMLEFT", {0.2, 0.7, 0.2}, true),	 -- Earth Shield
		ClassBuff(51945, "BOTTOMRIGHT", {0.7, 0.4, 0}),	 -- Earthliving
	},
	MONK = {
		ClassBuff(119611, "TOPLEFT", {0.8, 0.4, 0.8}),	 --Renewing Mist
		ClassBuff(116849, "TOPRIGHT", {0.2, 0.8, 0.2}),	 -- Life Cocoon
		ClassBuff(124682, "BOTTOMLEFT", {0.4, 0.8, 0.2}), -- Enveloping Mist
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
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Unholy Frenzy	
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
	[SpellName(103103)] = 3, --Malefic Grasp
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

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	[SpellName(64901)] = true, -- Hymn of Hope
	[SpellName(64843)] = true, -- Divine Hymn
	[SpellName(1120)] = true, -- Drain Soul
}

--This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {169/255, 98/255, 181/255},
	[SpellName(32182)] = {169/255, 98/255, 181/255},
}