-- List of nameplate names we want to hide nameplates of
TukuiDB.NPCList = {
	--Gundrak
	["Fanged Pit Viper"] = true,
	["Crafty Snake"] = true,
	
	--Shaman Totems
	["Earth Elemental Totem"] = true, 
	["Fire Elemental Totem"] = true, 
	["Fire Resistance Totem"] = true, 
	["Flametongue Totem"] = true, 
	["Frost Resistance Totem"] = true, 
	["Healing Stream Totem"] = true, 
	["Magma Totem"] = true, 
	["Mana Spring Totem"] = true, 
	["Nature Resistance Totem"] = true, 
	["Searing Totem"] = true,
	["Stoneclaw Totem"] = true,
	["Stoneskin Totem"] = true,
	["Strength of Earth Totem"] = true,
	["Windfury Totem"] = true,
	["Totem of Wrath"] = true,
	["Wrath of Air Totem"] = true,
	
	--The gayest ability in the game
	["Army of the Dead Ghoul"] = true,
	
	--Hunter Trap
	["Venomous Snake"] = true,
	["Viper"] = true,
	
	--Test
	--["Unbound Seer"] = true,  
}

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
			{974, "TOPRIGHT", {221/255, 117/255, 0}}, -- Earth Shield
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
end

--List of buffs to watch for on arena frames
ArenaBuffWhiteList = {
	-- Buffs
		[GetSpellInfo(1022)] = true, --hop
		[GetSpellInfo(12051)] = true, --evoc
		[GetSpellInfo(2825)] = true, --BL
		[GetSpellInfo(32182)] = true, --Heroism
		[GetSpellInfo(33206)] = true, --Pain Suppression
		[GetSpellInfo(29166)] = true, --Innervate
		[GetSpellInfo(18708)] = true, --"Fel Domination"
		[GetSpellInfo(54428)] = true, --divine plea
		[GetSpellInfo(31821)] = true, -- aura mastery

	-- Turtling abilities
		[GetSpellInfo(871)] = true, --Shield Wall
		[GetSpellInfo(48707)] = true, --"Anti-Magic Shell"
		[GetSpellInfo(31224)] = true, -- cloak of shadows
		[GetSpellInfo(19263)] = true, -- deterance
		[GetSpellInfo(47585)] = true, --  Dispersion

	-- Immunities
		[GetSpellInfo(45438)] = true, -- ice Brock
		[GetSpellInfo(642)] = true, -- pally bubble from hell
		
	-- Offensive Shit
		[GetSpellInfo(31884)] = true, -- Avenging Wrath
		[GetSpellInfo(34471)] = true, -- beast within
		[GetSpellInfo(85696)] = true, -- Zealotry
		[GetSpellInfo(467)] = true, -- Thorns
}

-------------------------------------------------------------
-- Debuff Filters
-------------------------------------------------------------

-- Debuffs to always hide
-- Raid frames use this when not inside a BG/Arena. Player, TargetTarget, Focus always use it.
DebuffBlacklist = {
	[GetSpellInfo(57724)] = true, --Sated
	[GetSpellInfo(25771)] = true, --forbearance
	[GetSpellInfo(36032)] = true, --arcane blast
	[GetSpellInfo(58539)] = true, --watchers corpse
	[GetSpellInfo(26013)] = true, --deserter
	[GetSpellInfo(6788)] = true, --weakended soul
	[GetSpellInfo(71041)] = true, --dungeon deserter
	[GetSpellInfo(41425)] = true, --"Hypothermia"
	[GetSpellInfo(55711)] = true, --Weakened Heart
	[GetSpellInfo(28531)] = true, --frost aura (naxx)
	[GetSpellInfo(67604)] = true, --Powering Up toc
	[GetSpellInfo(8326)] = true, --ghost
	[GetSpellInfo(20584)] = true, --ghost
	[GetSpellInfo(23445)] = true, --evil twin
	[GetSpellInfo(24755)] = true, --gay homosexual tricked or treated debuff
	[GetSpellInfo(25163)] = true, --fucking annoying pet debuff oozeling disgusting aura
	
	--Blood Princes
	[GetSpellInfo(71911)] = true, --shadow resonance
	
	--Festergut
	[GetSpellInfo(72144)] = true, --"Orange Blight Residue"
	[GetSpellInfo(73034)] = true, --Blighted Spores
	[GetSpellInfo(70852)] = true, --Malleable Goo
	
	--Rotface
	[GetSpellInfo(72145)] = true, --"Green Blight Residue"
	
	--Putricide
	[GetSpellInfo(72511)] = true, --Mutated Transformation
	
	[GetSpellInfo(72460)] = true, --Choking Gas
}

-- Debuffs to Show
-- Only works on raid frames when inside a BG/Arena. Target frame will always show these
DebuffWhiteList = {
	-- Death Knight
		[GetSpellInfo(51209)] = true, --hungering cold
		[GetSpellInfo(47476)] = true, --strangulate
	-- Druid
		[GetSpellInfo(33786)] = true, --Cyclone
		[GetSpellInfo(2637)] = true, --Hibernate
		[GetSpellInfo(339)] = true, --Entangling Roots
		[GetSpellInfo(80964)] = true, --Skull Bash Bear
		[GetSpellInfo(80965)] = true, --Skull Bash Cat
	-- Hunter
		[GetSpellInfo(3355)] = true, --Freezing Trap Effect
		--[GetSpellInfo(60210)] = true, --Freezing Arrow Effect
		[GetSpellInfo(1513)] = true, --scare beast
		[GetSpellInfo(19503)] = true, --scatter shot
		[GetSpellInfo(34490)] = true, --silence shot
	-- Mage
		[GetSpellInfo(31661)] = true, --Dragon's Breath
		[GetSpellInfo(61305)] = true, --Polymorph
		[GetSpellInfo(31589)] = true, --Slow
		[GetSpellInfo(18469)] = true, --Silenced - Improved Counterspell
		[GetSpellInfo(122)] = true, --Frost Nova
		[GetSpellInfo(55080)] = true, --Shattered Barrier
	-- Paladin
		[GetSpellInfo(20066)] = true, --Repentance
		[GetSpellInfo(10326)] = true, --Turn Evil
		[GetSpellInfo(853)] = true, --Hammer of Justice
	-- Priest
		[GetSpellInfo(605)] = true, --Mind Control
		[GetSpellInfo(64044)] = true, --Psychic Horror
		[GetSpellInfo(8122)] = true, --Psychic Scream
		[GetSpellInfo(9484)] = true, --Shackle Undead
		[GetSpellInfo(15487)] = true, --Silence
	-- Rogue
		[GetSpellInfo(2094)] = true, --Blind
		[GetSpellInfo(1776)] = true, --Gouge
		[GetSpellInfo(6770)] = true, --Sap
		[GetSpellInfo(18425)] = true, --Silenced - Improved Kick
	-- Shaman
		[GetSpellInfo(51514)] = true, --Hex
		[GetSpellInfo(3600)] = true, --Earthbind
		[GetSpellInfo(8056)] = true, --Frost Shock
		[GetSpellInfo(63685)] = true, --Freeze
		[GetSpellInfo(39796)] = true, --Stoneclaw Stun
	-- Warlock
		[GetSpellInfo(710)] = true, --Banish
		[GetSpellInfo(6789)] = true, --Death Coil
		[GetSpellInfo(5782)] = true, --Fear
		[GetSpellInfo(5484)] = true, --Howl of Terror
		[GetSpellInfo(6358)] = true, --Seduction
		[GetSpellInfo(30283)] = true, --Shadowfury
		[GetSpellInfo(89605)] = true, --Aura of Foreboding
	-- Warrior
		[GetSpellInfo(20511)] = true, --Intimidating Shout
	-- Racial
		[GetSpellInfo(25046)] = true, --Arcane Torrent
		
	--PVE Debuffs
		
	-- Lich King
		[GetSpellInfo(73787)] = true, --Necrotic Plague
}

--List of debuffs for targetframe for pvp only (when inside a bg/arena
--We do this because in PVE Situations we don't want to see these debuffs on our target frame
TargetPVPOnly = {
	[GetSpellInfo(34438)] = true, --UA
	[GetSpellInfo(34914)] = true, --VT
	[GetSpellInfo(31935)] = true, --avengers shield
	[GetSpellInfo(63529)] = true, --shield of the templar
	[GetSpellInfo(19386)] = true, --wyvern sting
	[GetSpellInfo(116)] = true, --frostbolt
	[GetSpellInfo(58179)] = true, --infected wounds
	[GetSpellInfo(18223)] = true, -- curse of exhaustion
	[GetSpellInfo(18118)] = true, --aftermath
	--not sure if this one belongs here but i do know frost pve uses this
	[GetSpellInfo(44572)] = true, --deep freeze
}

--This list is used by the healerlayout when center layout is true (When not inside a bg/arena)
DebuffHealerWhiteList = {
	-- Naxxramas
		[GetSpellInfo(27808)] = true, -- Frost Blast
		[GetSpellInfo(32407)] = true, -- Strange Aura
		[GetSpellInfo(28408)] = true, -- Chains of Kel'Thuzad

	-- Ulduar
		[GetSpellInfo(66313)] = true, -- Fire Bomb
		[GetSpellInfo(63134)] = true, -- Sara's Blessing
		[GetSpellInfo(62717)] = true, -- Slag Pot
		[GetSpellInfo(63018)] = true, -- Searing Light
		[GetSpellInfo(64233)] = true, -- Gravity Bomb
		[GetSpellInfo(63495)] = true, -- Static Disruption

	-- Trial of the Crusader
		[GetSpellInfo(66406)] = true, -- Snobolled!
		[GetSpellInfo(67574)] = true, -- Pursued by Anub'arak
		[GetSpellInfo(68509)] = true, -- Penetrating Cold
		[GetSpellInfo(67651)] = true, -- Arctic Breath
		[GetSpellInfo(68127)] = true, -- Legion Flame
		[GetSpellInfo(67049)] = true, -- Incinerate Flesh
		[GetSpellInfo(66869)] = true, -- Burning Bile
		[GetSpellInfo(66823)] = true, -- Paralytic Toxin

	-- Icecrown Citadel
		[GetSpellInfo(71224)] = true, -- Mutated Infection
		[GetSpellInfo(71822)] = true, -- Shadow Resonance
		[GetSpellInfo(70447)] = true, -- Volatile Ooze Adhesive
		[GetSpellInfo(72293)] = true, -- Mark of the Fallen Champion
		[GetSpellInfo(72448)] = true, -- Rune of Blood
		[GetSpellInfo(71473)] = true, -- Essence of the Blood Queen
		[GetSpellInfo(71624)] = true, -- Delirious Slash
		[GetSpellInfo(70923)] = true, -- Uncontrollable Frenzy
		[GetSpellInfo(70588)] = true, -- Suppression
		[GetSpellInfo(71738)] = true, -- Corrosion
		[GetSpellInfo(71733)] = true, -- Acid Burst
		[GetSpellInfo(72108)] = true, -- Death and Decay
		[GetSpellInfo(71289)] = true, -- Dominate Mind
		[GetSpellInfo(69762)] = true, -- Unchained Magic
		[GetSpellInfo(69651)] = true, -- Wounding Strike
		[GetSpellInfo(69065)] = true, -- Impaled
		[GetSpellInfo(71218)] = true, -- Vile Gas
		[GetSpellInfo(72442)] = true, -- Boiling Blood
		[GetSpellInfo(72769)] = true, -- Scent of Blood (heroic)
		[GetSpellInfo(69279)] = true, -- Gas Spore
		[GetSpellInfo(70949)] = true, -- Essence of the Blood Queen (hand icon)
		[GetSpellInfo(72151)] = true, -- Frenzied Bloodthirst (bite icon)
		[GetSpellInfo(71474)] = true, -- Frenzied Bloodthirst (red bite icon)
		[GetSpellInfo(71340)] = true, -- Pact of the Darkfallen
		[GetSpellInfo(72985)] = true, -- Swarming Shadows (pink icon)
		[GetSpellInfo(71267)] = true, -- Swarming Shadows (black purple icon)
		[GetSpellInfo(71264)] = true, -- Swarming Shadows (swirl icon)
		[GetSpellInfo(71807)] = true, -- Glittering Sparks
		[GetSpellInfo(70873)] = true, -- Emerald Vigor
		[GetSpellInfo(71283)] = true, -- Gut Spray
		[GetSpellInfo(69766)] = true, -- Instability
		[GetSpellInfo(70126)] = true, -- Frost Beacon
		[GetSpellInfo(70157)] = true, -- Ice Tomb
		[GetSpellInfo(71056)] = true, -- Frost Breath
		[GetSpellInfo(70106)] = true, -- Chilled to the Bone
		[GetSpellInfo(70128)] = true, -- Mystic Buffet
		[GetSpellInfo(73785)] = true, -- Necrotic Plague
		[GetSpellInfo(73779)] = true, -- Infest
		[GetSpellInfo(73800)] = true, -- Soul Shriek
		[GetSpellInfo(73797)] = true, -- Soul Reaper
		[GetSpellInfo(73708)] = true, -- Defile
		[GetSpellInfo(74322)] = true, -- Harvested Soul
			
	--Ruby Sanctum
		[GetSpellInfo(74502)] = true, --Enervating Brand
		[GetSpellInfo(75887)] = true, --Blazing Aura  
		[GetSpellInfo(74562)] = true, --Fiery Combustion
		[GetSpellInfo(74567)] = true, --Mark of Combustion (Fire)
		[GetSpellInfo(74792)] = true, --Soul Consumption
		[GetSpellInfo(74795)] = true, --Mark Of Consumption (Soul)

	-- Other debuff
		[GetSpellInfo(67479)] = true, -- Impale
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
