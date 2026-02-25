local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- This used to be standalone and is now merged into G.unitframe.aurafilters.Whitelist
G.unitframe.aurafilters.PlayerBuffs = nil

--[[
Long-term Raid Buffs
	1126 - Mark of the Wild
	1459 - Arcane Intellect
	6673 - Battle Shout
	21562 - Power Word: Fortitude
	369459 - Source of Magic
	462854 - Skyfury
	474754 – Symbiotic Relationship

Blessing of the Bronze Auras
	381732 - Death Knight
	381741 - Demon Hunter
	381746 – Druid
	381748 – Evoker
	381749 – Hunter
	381750 – Mage
	381751 – Monk
	381752 – Paladin
	381753 – Priest
	381754 – Rogue
	381756 – Shaman
	381757 – Warlock
	381758 - Warrior

Long-term Self Buffs
	433568 - Rite of Sanctification
	433583 - Rite of Adjuration

Rogue Poisons
	2823 - Deadly Poison
	8679 - Wound Poison
	3408 - Crippling Poison
	5761 - Numbing Poison
	315584 - Instant Poison
	381637 - Atrophic Poison
	381664 - Amplifying Poison

Shaman Imbuements
	319773 – Windfury Weapon
	319778 – Flametongue Weapon
	382021, 382022 – Earthliving Weapon
	457496, 457481 – Tidecaller's Guard
	462757, 462742 – Thunderstrike Ward
]]

G.unitframe.aurafilters.ClassDebuffs = {
	type = 'Whitelist',
	desc = L["Only important debuffs which influence your action priority. Recommended to be paired with 'Non Personal' set to 'Block'."],
	spells = {}
}

G.unitframe.aurafilters.ImportantCC = {
	type = 'Whitelist',
	desc = L["Only important CC debuffs like Polymorph, Hex, Stuns. Also includes important cc-like debuffs, for example Mind Soothe and Solar Beam."],
	spells = {}
}

G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	desc = L["Debuffs that are some form of CC. This can be stuns, roots, slows, etc."],
	spells = {}
}

G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	desc = L["Immunity buffs like Bubble and Ice Block, but also most major defensive class cooldowns."],
	spells = {}
}

G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	desc = L["Auras you don't want to see on your frames."],
	spells = {}
}

G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	desc = L["Auras which should always be displayed."],
	spells = {}
}

G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	desc = L["List of important Dungeon and Raid debuffs. Includes affixes and utility on dead players like pending resurrection and available reincarnation."],
	spells = {}
}

-- Buffs applied by bosses, adds or trash
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	desc = L["List of important Dungeon and Raid buffs."],
	spells = {}
}

-- Aura indicators on UnitFrames (Hots, Shields, Externals)
G.unitframe.aurawatch = {
	-- Args Aura(auraID, includeIDs, point, color, anyUnit, onlyShowMissing, displayText, textThreshold, xOffset, yOffset)
	EVOKER = {
		-- Preservation Evoker
		[355941]	= Aura(355941, nil, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Dream Breath
		[376788]	= Aura(376788, nil, 'TOPRIGHT', {0.25, 0.25, 0.58}, nil, nil, nil, nil, -20), -- Dream Breath (echo)
		[363502]	= Aura(363502, nil, 'BOTTOMLEFT', {0.33, 0.33, 0.70}), -- Dream Flight
		[366155]	= Aura(366155, nil, 'BOTTOMRIGHT', {0.14, 1.00, 0.88}), -- Reversion
		[367364]	= Aura(367364, nil, 'BOTTOMRIGHT', {0.09, 0.69, 0.61}, nil, nil, nil, nil, -20), -- Reversion (echo)
		[373267]	= Aura(373267, nil, 'RIGHT', {0.82, 0.29, 0.24}), -- Life Bind (Verdant Embrace)
		[364343]	= Aura(364343, nil, 'TOP', {0.13, 0.87, 0.50}), -- Echo
		-- Augmentation Evoker
		[360827]	= Aura(360827, nil, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Blistering Scales
		[410089]	= Aura(410089, nil, 'TOP', {0.13, 0.87, 0.50}), -- Prescience
		[395152]	= Aura(395152, nil, 'BOTTOMRIGHT', {0.98, 0.44, 0.00}), -- Ebon Might
		-- ToDo 410263: Inferno's Blessing
		-- ToDo 410686: Symbiotic Bloom
		-- ToDo 413984: Shifting Sands
	},
	PRIEST = {
		-- Disc Priest
		[194384]	= Aura(194384, nil, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement
		[17]		= Aura(17, nil, 'TOPLEFT', {0.7, 0.7, 0.7}, true), -- Power Word: Shield
		-- ToDo 1253593: Void Shield
		-- Holy Priest
		[41635]		= Aura(41635, nil, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		[139]		= Aura(139, nil, 'BOTTOMLEFT', {0.4, 0.7, 0.2}), -- Renew
		[77489]		= Aura(77489, nil, 'TOP', {0.75, 1.00, 0.30}), -- Echo of Light
	},
	DRUID = {
		-- Resto Druid
		[774]		= Aura(774, nil, 'TOPRIGHT', {0.8, 0.4, 0.8}), -- Rejuvenation
		[33763]		= Aura(33763, nil, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom
		[48438]		= Aura(48438, nil, 'BOTTOMRIGHT', {0.8, 0.4, 0}), -- Wild Growth
		[8936]		= Aura(8936, nil, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Regrowth
		[155777]	= Aura(155777, nil, 'RIGHT', {0.8, 0.4, 0.8}), -- Germination
	},
	PALADIN = {
		-- Holy Paladin
		[53563]		= Aura(53563, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Light
		[156910]	= Aura(156910, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Faith
		[200025]	= Aura(200025, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Virtue
		[156322]	= Aura(156322, nil, 'TOPLEFT', {0.2, 0.8, 0.2}), -- Eternal Flame
		-- ToDo 1244893: Beacon of the Savior
	},
	SHAMAN = {
		-- Restoration Shaman
		[61295]		= Aura(61295, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[974]		= Aura(974, nil, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield
		[383648]	= Aura(383648, nil, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield (Elemental Orbit)
	},
	MONK = {
		-- Mistweaver Monk
		[115175]	= Aura(115175, nil, 'TOP', {0.6, 0.9, 0.9}), -- Soothing Mist
		[119611]	= Aura(119611, nil, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Renewing Mist
		[450769]	= Aura(450769, nil, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Aspect of Harmony (Modified version of Renewing Mist)
		[124682]	= Aura(124682, nil, 'BOTTOMLEFT', {0.8, 0.8, 0.25}), -- Enveloping Mist
	},
	-- Not used for now
	ROGUE = {},
	WARRIOR = {},
	HUNTER = {},
	PET = {},
	GLOBAL = {},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Racials
	[291944]	= 6, -- Regeneratin (Zandalari)
	-- Evoker
	[356995]	= 3, -- Disintegrate
	-- Warlock
	[198590]	= 4, -- Drain Soul
	[755]		= 5, -- Health Funnel
	[234153]	= 5, -- Drain Life
	-- Priest
	[64843]		= 4, -- Divine Hymn
	[15407]		= 6, -- Mind Flay
	[48045]		= 6, -- Mind Sear
	[47757]		= 3, -- Penance (heal)
	[47758]		= 3, -- Penance (dps)
	[373129]	= 3, -- Penance (Dark Reprimand, dps)
	[400171]	= 3, -- Penance (Dark Reprimand, heal)
	[64902]		= 5, -- Symbol of Hope (Mana Hymn)
	-- Mage
	[5143]		= 4, -- Arcane Missiles
	[12051]		= 6, -- Evocation
	[205021]	= 5, -- Ray of Frost
	-- Druid
	[740]		= 4, -- Tranquility
	-- DK
	[206931]	= 3, -- Blooddrinker
	-- DH
	[198013]	= 10, -- Eye Beam
	[212084]	= 10, -- Fel Devastation
	-- Hunter
	[120360]	= 15, -- Barrage
	[257044]	= 7, -- Rapid Fire
	-- Monk
	[113656]	= 4, -- Fists of Fury
}

-- Spells that chain, ticks to add
G.unitframe.ChainChannelTicks = {
	-- Evoker
	[356995]	= 1, -- Disintegrate
}

-- Window to chain time (in seconds); usually the channel duration
G.unitframe.ChainChannelTime = {
	-- Evoker
	[356995]	= 3, -- Disintegrate
}

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {
	[356995]	= { [1219723] = 4 }, -- Disintegrate (Azure Celerity)
}

-- Increase ticks from auras
G.unitframe.AuraChannelTicks = {
	-- Priest
	[47757]		= { filter = 'HELPFUL', spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (heal)
	[47758]		= { filter = 'HELPFUL', spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (dps)
}

-- Spells Effected By Haste, value is Base Tick Size
G.unitframe.HastedChannelTicks = {
	-- [spellID] = true, -- SpellName
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {}

-- Auras which should change the color of the UnitFrame
G.unitframe.AuraHighlightColors = {}
