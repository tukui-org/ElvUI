local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id) 	
	return name
end

--[[
		This file is for adding of deleting a spellID.
		
		The best way to add or delete spell is to go at www.wowhead.com, search for a spell :
		Example : Incinerate Flesh from Lord Jaraxxus -> http://www.wowhead.com/?spell=67049
		Take the number ID at the end of the URL, and add it to the list
		
		That's it, That's all! 
		
		Elv
]]-- 


--List of spells to display ticks
E.ChannelTicks = {
	--Warlock
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
	--Mage
	[SpellName(5143)] = 5, -- "Arcane Missiles"
	[SpellName(10)] = 5, -- "Blizzard"
	[SpellName(12051)] = 4, -- "Evocation"
}

--List of buffs to watch for on arena frames
E.ArenaBuffWhiteList = {
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

-- Target/Arena Frames/ Nameplates use these
E.DebuffWhiteList = {
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
	-- Racial
		[SpellName(25046)] = true, --Arcane Torrent
		[SpellName(20549)] = true, --War Stomp
	--PVE
}

--List of debuffs for targetframe for pvp only (when inside a bg/arena
--We do this because in PVE Situations we don't want to see these debuffs on our target frame, arena frames will always show these.
E.TargetPVPOnly = {
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

-------------------------------------------------------------
-- Debuff Filters
-------------------------------------------------------------

-- Debuffs to always hide
-- DPS Raid vertical frames use this. Player, TargetTarget, Focus always use it.
E.DebuffBlacklist = {
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
}

--RAID DEBUFFS
E.RaidDebuffs = {
	--Test
	--SpellName(25771), --Forbearance
	
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
	[SpellName(93051)] = true, -- Twilight Shift
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
}




E.ReverseTimer = {
	[92956] = true, -- Sinestra (Wrack)
	[89435] = true, -- Sinestra (Wrack)
	[92955] = true, -- Sinestra (Wrack)
	[89421] = true, -- Sinestra (Wrack)
}