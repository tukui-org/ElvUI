local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	return name
end

--[[
		This portion of the file is for adding of deleting a spellID for a specific encounter on Grid layout
		or enemy cooldown in Arena displayed on screen.
		
		The best way to add or delete spell is to go at www.wowhead.com, search for a spell :
		Example : Incinerate Flesh from Lord Jaraxxus -> http://www.wowhead.com/?spell=67049
		Take the number ID at the end of the URL, and add it to the list
		
		That's it, That's all! 
		
		Tukz
]]-- 

--------------------------------------------------------------------------------------------
-- Raid Buff Reminder
--------------------------------------------------------------------------------------------

BuffReminderRaidBuffs = {
	Flask = {
		67016, --"Flask of the North-ING"
		67017, --"Flask of the North-AGI"
		67018, --"Flask of the North-STR"
		53758, --"Flask of Stoneblood"
		53755, --"Flask of the Frost Wyrm",
		54212, --"Flask of Pure Mojo",
		53760, --"Flask of Endless Rage",
		17627, --"Flask of Distilled Wisdom", 
	},
	BattleElixir = {
		33721, --"Spellpower Elixir",
		53746, --"Wrath Elixir",
		28497, --"Elixir of Mighty Agility",
		53748, --"Elixir of Mighty Strength",
		60346, --"Elixir of Lightning Speed",
		60344, --"Elixir of Expertise",
		60341, --"Elixir of Deadly Strikes",
		80532, --"Elixir of Armor Piercing",
		60340, --"Elixir of Accuracy",
		53749, --"Guru's Elixir",
	},
	GuardianElixir = {
		60343, --"Elixir of Mighty Defense",
		53751, --"Elixir of Mighty Fortitude",
		53764, --"Elixir of Mighty Mageblood",
		60347, --"Elixir of Mighty Thoughts",
		53763, --"Elixir of Protection",
		53747, --"Elixir of Spirit",
	},
	Food = {
		57325, -- 80 AP
		57327, -- 46 SP
		57329, -- 40 CS
		57332, -- 40 Haste
		57334, -- 20 MP5
		57356, -- 40 EXP
		57360, -- 40 Hit
		57363, -- Track Humanoids
		57365, -- 40 Spirit
		57367, -- 40 AGI
		57371, -- 40 STR
		57373, -- Track Beasts
		57399, -- 80AP, 46SP (fish feast)
		59230, -- 40 DODGE
		65247, -- Pet 40 STR
	},
}

--------------------------------------------------------------------------------------------
-- Buff Watch (Raid Frame Buff Indicator)
--------------------------------------------------------------------------------------------

if TukuiCF["auras"].raidunitbuffwatch == true then
	-- Classbuffs { spell ID, position [, {r,g,b,a}][, anyUnit] }
	
	--Healer Layout
	TukuiDB.HealerBuffIDs = {
		PRIEST = {
			{6788, "TOPLEFT", {1, 0, 0}, true}, -- Weakened Soul
			{33076, "TOPRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
			{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
			{17, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
			{10060 , "RIGHT", {227/255, 23/255, 13/255}}, -- Power Infusion
			{33206, "LEFT", {227/255, 23/255, 13/255}, true}, -- Pain Suppress
			{47788, "LEFT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
		},
		DRUID = {
			{774, "TOPRIGHT", {0.8, 0.4, 0.8}}, -- Rejuvenation
			{8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}}, -- Regrowth
			{94447, "TOPLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
			{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
		},
		PALADIN = {
			{53563, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Beacon of Light
			{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
			{1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
			{6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true}, -- Hand of Sacrafice
			{1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true} -- Hand of Salvation
		},
		SHAMAN = {
			{61295, "TOPLEFT", {0.7, 0.3, 0.7}}, -- Riptide 
			{16236, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Ancestral Fortitude
			{51945, "BOTTOMRIGHT", {0.7, 0.4, 0}}, -- Earthliving
			{974, "TOPRIGHT", {221/255, 117/255, 0}, true}, -- Earth Shield
		},
		ALL = {
			{23333, "LEFT", {1, 0, 0}}, -- Warsong Flag
		},
	}

	--DPS Layout
	TukuiDB.DPSBuffIDs = {
		PALADIN = {
			{1022, "TOPRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
			{1044, "TOPRIGHT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
			{6940, "TOPRIGHT", {227/255, 23/255, 13/255}, true}, -- Hand of Sacrafice
			{1038, "TOPRIGHT", {238/255, 201/255, 0}, true}, -- Hand of Salvation
		},
		ROGUE = {
			{57933, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Tricks of the Trade
		},
		DEATHKNIGHT = {
			{49016, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Hysteria
		},
		MAGE = {
			{54646, "TOPRIGHT", {0.2, 0.2, 1}}, -- Focus Magic
		},
		WARRIOR = {
			{59665, "TOPLEFT", {0.2, 0.2, 1}}, -- Vigilance
			{3411, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Intervene
		},
		ALL = {
			{23333, "LEFT", {1, 0, 0}}, -- Warsong flag
		},
	}
	
	--Layout for pets
	TukuiDB.PetBuffs = {
		HUNTER = {
			{136, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Mend Pet
		},
		DEATHKNIGHT = {
			{91342, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Shadow Infusion
			{63560, "TOPLEFT", {227/255, 23/255, 13/255}}, --Dark Transformation
		},
		WARLOCK = {
			{47193, "TOPRIGHT", {227/255, 23/255, 13/255}}, --Demonic Empowerment
		},
	}
end

--List of buffs to watch for on arena frames
ArenaBuffWhiteList = {
	-- Buffs
		[SpellName(1022)] = true, --hop
		[SpellName(12051)] = true, --evoc
		[SpellName(2825)] = true, --BL
		[SpellName(32182)] = true, --Heroism
		[SpellName(33206)] = true, --Pain Suppression
		[SpellName(29166)] = true, --Innervate
		[SpellName(18708)] = true, --"Fel Domination"
		[SpellName(54428)] = true, --divine plea
		[SpellName(31821)] = true, -- aura mastery

	-- Turtling abilities
		[SpellName(871)] = true, --Shield Wall
		[SpellName(48707)] = true, --"Anti-Magic Shell"
		[SpellName(31224)] = true, -- cloak of shadows
		[SpellName(19263)] = true, -- deterance
		[SpellName(47585)] = true, --  Dispersion

	-- Immunities
		[SpellName(45438)] = true, -- ice Brock
		[SpellName(642)] = true, -- pally bubble from hell
		
	-- Offensive Shit
		[SpellName(31884)] = true, -- Avenging Wrath
		[SpellName(34471)] = true, -- beast within
		[SpellName(85696)] = true, -- Zealotry
		[SpellName(467)] = true, -- Thorns
}

-------------------------------------------------------------
-- Debuff Filters
-------------------------------------------------------------

-- Debuffs to always hide
-- DPS Raid frames use this when not inside a BG/Arena. Player, TargetTarget, Focus always use it.
DebuffBlacklist = {
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
	[SpellName(28531)] = true, --frost aura (naxx)
	[SpellName(67604)] = true, --Powering Up toc
	[SpellName(8326)] = true, --ghost
	[SpellName(20584)] = true, --ghost
	[SpellName(23445)] = true, --evil twin
	[SpellName(24755)] = true, --gay homosexual tricked or treated debuff
	[SpellName(25163)] = true, --fucking annoying pet debuff oozeling disgusting aura
	
	--Blood Princes
	[SpellName(71911)] = true, --shadow resonance
	
	--Festergut
	[SpellName(72144)] = true, --"Orange Blight Residue"
	[SpellName(73034)] = true, --Blighted Spores
	[SpellName(70852)] = true, --Malleable Goo
	
	--Rotface
	[SpellName(72145)] = true, --"Green Blight Residue"
	
	--Putricide
	[SpellName(72511)] = true, --Mutated Transformation
	
	[SpellName(72460)] = true, --Choking Gas
}


-- Debuffs to Show
-- Only works on raid frames when inside a BG/Arena. Target frame will always show these
DebuffWhiteList = {
	-- Death Knight
		[SpellName(51209)] = true, --hungering cold
		[SpellName(47476)] = true, --strangulate
	-- Druid
		[SpellName(33786)] = true, --Cyclone
		[SpellName(2637)] = true, --Hibernate
		[SpellName(339)] = true, --Entangling Roots
		[SpellName(80964)] = true, --Skull Bash
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
	-- Racial
		[SpellName(25046)] = true, --Arcane Torrent
		
	--PVE Debuffs
		
	-- Lich King
		[SpellName(73787)] = true, --Necrotic Plague
}

--List of debuffs for targetframe for pvp only (when inside a bg/arena
--We do this because in PVE Situations we don't want to see these debuffs on our target frame
TargetPVPOnly = {
	[SpellName(34438)] = true, --UA
	[SpellName(34914)] = true, --VT
	[SpellName(31935)] = true, --avengers shield
	[SpellName(63529)] = true, --shield of the templar
	[SpellName(19386)] = true, --wyvern sting
	[SpellName(116)] = true, --frostbolt
	[SpellName(58179)] = true, --infected wounds
	[SpellName(18223)] = true, -- curse of exhaustion
	[SpellName(18118)] = true, --aftermath
	[SpellName(31589)] = true, --Slow
	--not sure if this one belongs here but i do know frost pve uses this
	[SpellName(44572)] = true, --deep freeze
}

--This list is used by the healerlayout (When not inside a bg/arena)
DebuffHealerWhiteList = {
	-- Naxxramas
		[SpellName(27808)] = true, -- Frost Blast
		[SpellName(32407)] = true, -- Strange Aura
		[SpellName(28408)] = true, -- Chains of Kel'Thuzad

	-- Ulduar
		[SpellName(66313)] = true, -- Fire Bomb
		[SpellName(63134)] = true, -- Sara's Blessing
		[SpellName(62717)] = true, -- Slag Pot
		[SpellName(63018)] = true, -- Searing Light
		[SpellName(64233)] = true, -- Gravity Bomb
		[SpellName(63495)] = true, -- Static Disruption

	-- Trial of the Crusader
		[SpellName(66406)] = true, -- Snobolled!
		[SpellName(67574)] = true, -- Pursued by Anub'arak
		[SpellName(68509)] = true, -- Penetrating Cold
		[SpellName(67651)] = true, -- Arctic Breath
		[SpellName(68127)] = true, -- Legion Flame
		[SpellName(67049)] = true, -- Incinerate Flesh
		[SpellName(66869)] = true, -- Burning Bile
		[SpellName(66823)] = true, -- Paralytic Toxin

	-- Icecrown Citadel
		[SpellName(71224)] = true, -- Mutated Infection
		[SpellName(71822)] = true, -- Shadow Resonance
		[SpellName(70447)] = true, -- Volatile Ooze Adhesive
		[SpellName(72293)] = true, -- Mark of the Fallen Champion
		[SpellName(72448)] = true, -- Rune of Blood
		[SpellName(71473)] = true, -- Essence of the Blood Queen
		[SpellName(71624)] = true, -- Delirious Slash
		[SpellName(70923)] = true, -- Uncontrollable Frenzy
		[SpellName(70588)] = true, -- Suppression
		[SpellName(71738)] = true, -- Corrosion
		[SpellName(71733)] = true, -- Acid Burst
		[SpellName(72108)] = true, -- Death and Decay
		[SpellName(71289)] = true, -- Dominate Mind
		[SpellName(69762)] = true, -- Unchained Magic
		[SpellName(69651)] = true, -- Wounding Strike
		[SpellName(69065)] = true, -- Impaled
		[SpellName(71218)] = true, -- Vile Gas
		[SpellName(72442)] = true, -- Boiling Blood
		[SpellName(72769)] = true, -- Scent of Blood (heroic)
		[SpellName(69279)] = true, -- Gas Spore
		[SpellName(70949)] = true, -- Essence of the Blood Queen (hand icon)
		[SpellName(72151)] = true, -- Frenzied Bloodthirst (bite icon)
		[SpellName(71340)] = true, -- Pact of the Darkfallen
		[SpellName(72985)] = true, -- Swarming Shadows (pink icon)
		[SpellName(71807)] = true, -- Glittering Sparks
		[SpellName(70873)] = true, -- Emerald Vigor
		[SpellName(71283)] = true, -- Gut Spray
		[SpellName(69766)] = true, -- Instability
		[SpellName(70126)] = true, -- Frost Beacon
		[SpellName(70157)] = true, -- Ice Tomb
		[SpellName(71056)] = true, -- Frost Breath
		[SpellName(70106)] = true, -- Chilled to the Bone
		[SpellName(70128)] = true, -- Mystic Buffet
		[SpellName(73785)] = true, -- Necrotic Plague
		[SpellName(73779)] = true, -- Infest
		[SpellName(73800)] = true, -- Soul Shriek
		[SpellName(73797)] = true, -- Soul Reaper
		[SpellName(73708)] = true, -- Defile
		[SpellName(74327)] = true, -- Harvest Soul
			
	--Ruby Sanctum
		[SpellName(74502)] = true, --Enervating Brand
		[SpellName(75887)] = true, --Blazing Aura  
		[SpellName(74562)] = true, --Fiery Combustion
		[SpellName(74567)] = true, --Mark of Combustion (Fire)
		[SpellName(74792)] = true, --Soul Consumption
		[SpellName(74795)] = true, --Mark Of Consumption (Soul)

	-- Other debuff
		[SpellName(67479)] = true, -- Impale
}

--This list is used by the dps layout grid (When not inside a bg/arena)
DebuffDPSWhiteList = {
	-- Naxxramas
		[SpellName(27808)] = true, -- Frost Blast
		[SpellName(32407)] = true, -- Strange Aura
		[SpellName(28408)] = true, -- Chains of Kel'Thuzad

	-- Ulduar
		[SpellName(66313)] = true, -- Fire Bomb
		[SpellName(63134)] = true, -- Sara's Blessing
		[SpellName(62717)] = true, -- Slag Pot
		[SpellName(63018)] = true, -- Searing Light
		[SpellName(64233)] = true, -- Gravity Bomb
		[SpellName(63495)] = true, -- Static Disruption

	-- Trial of the Crusader
		[SpellName(66406)] = true, -- Snobolled!
		[SpellName(67574)] = true, -- Pursued by Anub'arak
		[SpellName(67651)] = true, -- Arctic Breath
		[SpellName(68127)] = true, -- Legion Flame
		[SpellName(67049)] = true, -- Incinerate Flesh
		[SpellName(66869)] = true, -- Burning Bile
		[SpellName(66823)] = true, -- Paralytic Toxin

	-- Icecrown Citadel
		[SpellName(71224)] = true, -- Mutated Infection
		[SpellName(70447)] = true, -- Volatile Ooze Adhesive
		[SpellName(72293)] = true, -- Mark of the Fallen Champion
		[SpellName(72448)] = true, -- Rune of Blood
		[SpellName(71473)] = true, -- Essence of the Blood Queen
		[SpellName(70923)] = true, -- Uncontrollable Frenzy
		[SpellName(71289)] = true, -- Dominate Mind
		[SpellName(69065)] = true, -- Impaled
		[SpellName(71218)] = true, -- Vile Gas
		[SpellName(72769)] = true, -- Scent of Blood
		[SpellName(69279)] = true, -- Gas Spore
		[SpellName(70949)] = true, -- Essence of the Blood Queen
		[SpellName(72151)] = true, -- Frenzied Bloodthirst
		[SpellName(71340)] = true, -- Pact of the Darkfallen
		[SpellName(72985)] = true, -- Swarming Shadows
		[SpellName(71283)] = true, -- Gut Spray
		[SpellName(70126)] = true, -- Frost Beacon
		[SpellName(70157)] = true, -- Ice Tomb
		[SpellName(73785)] = true, -- Necrotic Plague
		[SpellName(73800)] = true, -- Soul Shriek
		[SpellName(73797)] = true, -- Soul Reaper
		[SpellName(73708)] = true, -- Defile
		[SpellName(74327)] = true, -- Harvest Soul
		[SpellName(72553)] = true, -- Gastric Bloat
		[SpellName(72672)] = true, -- Mutated Plague
			
	--Ruby Sanctum
		[SpellName(74502)] = true, --Enervating Brand
		[SpellName(75887)] = true, --Blazing Aura  
		[SpellName(74562)] = true, --Fiery Combustion
		[SpellName(74567)] = true, --Mark of Combustion (Fire)
		[SpellName(74792)] = true, --Soul Consumption
		[SpellName(74795)] = true, --Mark Of Consumption (Soul)

	-- Other debuff
		[SpellName(67479)] = true, -- Impale
}

--------------------------------------------------------------------------------------------
-- Enemy cooldown tracker or Spell Alert list
--------------------------------------------------------------------------------------------

-- the spellIDs to track on screen in arena.
if TukuiCF["arena"].spelltracker == true then
	TukuiDB.spelltracker = {
		[1766] = 10, -- kick
		[6552] = 10, -- pummel
		[80964] = 60, --SkullBash Bear
		[80965] = 60, --SkullBash Cat
		[85285] = 10, --Rebuke
		[2139] = 24, -- counterspell
		[19647] = 24, -- spell lock
		[10890] = 27, -- fear priest
		[47476] = 120, -- strangulate
		[47528] = 10, -- mindfreeze
		[29166] = 180, -- innervate
		[49039] = 120, -- Lichborne
		[54428] = 120, -- Divine Plea
		[10278] = 180, -- Hand of Protection
		[16190] = 180, -- Mana Tide Totem
		[51514] = 45, -- Hex
		[2094] = 120, -- Blind
		[72] = 12, -- fucking prot warrior shield bash
		[33206] = 144, -- pain sup
		[15487] = 45, -- silence priest
		[34490] = 20, -- i hate hunter silencing shot
		[14311] = 30, -- hunter forst trap shit
	}
end
