local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List -- 1:priority, 2:enable, 3:stackThreshold
local Aura = E.Filters.Aura -- 1:auraID, 2:includeIDs, 3:enabled, 4:point, 5:color, 6:anyUnit, 7:onlyShowMissing, 8:displayText, 9:xOffset, 10:yOffset

G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	desc = L["Auras you don't want to see on your frames."],
	spells = {
		-- Class Buffs
		[1126]		= List(nil, false), -- Mark of the Wild
		[1459]		= List(nil, false), -- Arcane Intellect
		[21562]		= List(nil, false), -- Power Word: Fortitude
		[369459]	= List(nil, false), -- Source of Magic
		[381732]	= List(nil, false), -- Blessing of the Bronze
		[381741]	= List(nil, false), -- Blessing of the Bronze
		[381746]	= List(nil, false), -- Blessing of the Bronze
		[381748]	= List(nil, false), -- Blessing of the Bronze
		[381749]	= List(nil, false), -- Blessing of the Bronze
		[381750]	= List(nil, false), -- Blessing of the Bronze
		[381751]	= List(nil, false), -- Blessing of the Bronze
		[381752]	= List(nil, false), -- Blessing of the Bronze
		[381753]	= List(nil, false), -- Blessing of the Bronze
		[381754]	= List(nil, false), -- Blessing of the Bronze
		[381756]	= List(nil, false), -- Blessing of the Bronze
		[381757]	= List(nil, false), -- Blessing of the Bronze
		[381758]	= List(nil, false), -- Blessing of the Bronze
		[462854]	= List(nil, false), -- Skyfury
		[474754]	= List(nil, false), -- Symbiotic Relationship
		[6673]		= List(nil, false), -- Battle Shout
		-- Classes, mostly to fake resources
		[1217607]	= List(nil, false), -- Void Metamorphosis
		[1225789]	= List(nil, false), -- Void Metamorphosis
		[1227702]	= List(nil, false), -- Collapsing Star
		[124255]	= List(nil, false), -- Stagger
		[205473]	= List(nil, false), -- Icicles
		[260286]	= List(nil, false), -- Tip of the Spear
		[344179]	= List(nil, false), -- Maelstrom Weapon
		[405189]	= List(nil, false), -- Overflowing Power | Berserk
		-- Rogue Poisons
		[2823]		= List(nil, false), -- Deadly Poison
		[315584]	= List(nil, false), -- Instant Poison
		[3408]		= List(nil, false), -- Crippling Poison
		[381637]	= List(nil, false), -- Atrophic Poison
		[381664]	= List(nil, false), -- Amplifying Poison
		[8679]		= List(nil, false), -- Wound Poison
		[5761]		= List(nil, false), -- Numbing Poison
		-- Shaman Imbuements
		[319773]	= List(nil, false), -- Windfury Weapon
		[319778]	= List(nil, false), -- Flametongue Weapon
		[382021]	= List(nil, false), -- Earthliving Weapon
		[382022]	= List(nil, false), -- Earthliving Weapon
		[457496]	= List(nil, false), -- Tidecaller's Guard
		[457481]	= List(nil, false), -- Tidecaller's Guard
		[462757]	= List(nil, false), -- Thunderstrike Ward
		[462742]	= List(nil, false), -- Thunderstrike Ward
		-- Paladin Imbuements
		[433568]	= List(), -- Rite of Sanctification
		[433583]	= List(), -- Rite of Adjuration
		-- Skyriding
		[404464]	= List(), -- Flight Style: Skyriding
		[404468]	= List(), -- Flight Style: Steady
		[427490]	= List(), -- Ride Along
		[447959]	= List(), -- Ride Along - Enabled
		[447960]	= List(), -- Ride Along - Inactive
		[377234]	= List(), -- Thrill of the Skies
		[418590]	= List(), -- Static Charge
		-- Bloodlust + Heroism
		[160455]	= List(), -- Fatigued | Netherwinds
		[264689]	= List(), -- Fatigued | Primal Rage
		[390435]	= List(), -- Exhaustion | Fury of the Aspects
		[57723]		= List(), -- Exhaustion | Heroism
		[57724]		= List(), -- Sated | Bloodlust
		[80354]		= List(), -- Temporal Displacement | Time Warp
		[95809]		= List(), -- Insanity | Ancient Hysteria
		-- Social
		[1313593]	= List(), -- Deserter
		[26013]		= List(), -- Deserter | Battlegrounds
		[71041]		= List(), -- Dungeon Deserter | Dungeon Finder or Raid Finder
		-- General Auras
		[308312]	= List(), -- Time Trial Practice
		[369968]	= List(), -- Racing
		[388367]	= List(), -- Ohn'ahra's Gusts
		[1283888]	= List(nil, false), -- [DNT] Aura Never Secret Test Spell
		-- Dungeon Auras
		[1254550]	= List(), -- Arcane Empowerment
		[206151]	= List(), -- Challenger's Burden
	}
}

G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	desc = L["Auras which should always be displayed."],
	spells = {
		-- General
		[160029] = List(), -- Resurrecting | Pending Res
		[225080] = List(), -- Reincarnation | Can use Reincarnate
		[255234] = List(), -- Totemic Revival | Can accept Totem Res
		-- Warlock
		-- Priest
		[10060] = List(), -- Power Infusion
		-- Mage
		-- Rogue
		-- Monk
		-- Druid
		[29166] = List(), -- Innervate
		-- Demon Hunter
		-- Shaman
		-- Hunter
		-- Evoker
		[406789] = List(), -- Spatial Paradox (Others)
		-- Warrior
		-- Paladin
		-- Death Knight
	}
}

-- Aura indicators on UnitFrames (Hots, Shields, Externals)
G.unitframe.aurawatch = {
	EVOKER = {
		-- All
		[381748]	= Aura(381748, {381732, 381741, 381746, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758}, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Blessing of the Bronze
		-- Preservation
		[355941]	= Aura(355941, nil, true, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Dream Breath
		[376788]	= Aura(376788, nil, true, 'TOPRIGHT', {0.25, 0.25, 0.58}, nil, nil, nil, -20), -- Dream Breath (echo)
		[363502]	= Aura(363502, nil, true, 'BOTTOMLEFT', {0.33, 0.33, 0.70}), -- Dream Flight
		[366155]	= Aura(366155, nil, true, 'BOTTOMRIGHT', {0.14, 1.00, 0.88}), -- Reversion
		[367364]	= Aura(367364, nil, true, 'BOTTOMRIGHT', {0.09, 0.69, 0.61}, nil, nil, nil, -20), -- Reversion (echo)
		[373267]	= Aura(373267, nil, true, 'RIGHT', {0.82, 0.29, 0.24}), -- Life Bind (Verdant Embrace)
		[364343]	= Aura(364343, nil, true, 'TOP', {0.13, 0.87, 0.50}), -- Echo
		-- Augmentation
		[360827]	= Aura(360827, nil, true, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Blistering Scales
		[410089]	= Aura(410089, nil, true, 'TOP', {0.13, 0.87, 0.50}), -- Prescience
		[395152]	= Aura(395152, nil, true, 'BOTTOMRIGHT', {0.98, 0.44, 0.00}), -- Ebon Might
		[410263]	= Aura(410263, nil, false, 'TOPLEFT', {0.02, 0.78, 0.43}), -- Inferno's Blessing
		[410686]	= Aura(410686, nil, false, 'TOPLEFT', {0.18, 0.84, 0.78}), -- Symbiotic Bloom
		[413984]	= Aura(413984, nil, false, 'BOTTOM', {0.09, 0.89, 0.86}), -- Shifting Sands
		[369459]	= Aura(369459, nil, false, 'BOTTOMLEFT', {0.59, 0.50, 0.75}, true), -- Source of Magic
	},
	PRIEST = {
		-- All
		[21562]		= Aura(21562, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Power Word: Fortitude
		-- Discipline
		[194384]	= Aura(194384, nil, true, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement
		[17]		= Aura(17, nil, true, 'TOPLEFT', {0.7, 0.7, 0.7}, true), -- Power Word: Shield
		[1253593]	= Aura(1253593, nil, true, 'TOP', {0.71, 0.29, 0.38}), -- Void Shield
		-- Holy
		[41635]		= Aura(41635, nil, true, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		[139]		= Aura(139, nil, true, 'BOTTOMLEFT', {0.4, 0.7, 0.2}), -- Renew
		[77489]		= Aura(77489, nil, true, 'TOP', {0.75, 1.00, 0.30}), -- Echo of Light
	},
	DRUID = {
		-- All
		[1126]		= Aura(1126, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Mark of the Wild
		[474754]	= Aura(474754, nil, false, 'BOTTOM', {0.59, 0.50, 0.75}, true, true), -- Symbiotic Relationship
		-- Restoration
		[774]		= Aura(774, nil, true, 'TOPRIGHT', {0.8, 0.4, 0.8}), -- Rejuvenation
		[33763]		= Aura(33763, nil, true, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom
		[48438]		= Aura(48438, nil, true, 'BOTTOMRIGHT', {0.8, 0.4, 0}), -- Wild Growth
		[8936]		= Aura(8936, nil, true, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Regrowth
		[155777]	= Aura(155777, nil, true, 'RIGHT', {0.8, 0.4, 0.8}), -- Germination
	},
	PALADIN = {
		-- Holy
		[53563]		= Aura(53563, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Light
		[156910]	= Aura(156910, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Faith
		[200025]	= Aura(200025, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Virtue
		[156322]	= Aura(156322, nil, true, 'TOPLEFT', {0.2, 0.8, 0.2}), -- Eternal Flame
		[1244893]	= Aura(1244893, nil, true, 'RIGHT', {0.06, 0.77, 0.34}), -- Beacon of the Savior
	},
	SHAMAN = {
		-- All
		[462854]	= Aura(462854, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Skyfury
		-- Restoration
		[61295]		= Aura(61295, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[974]		= Aura(974, nil, true, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield
		[383648]	= Aura(383648, nil, true, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield (Elemental Orbit)
		[207400]	= Aura(207400, nil, true, 'TOPLEFT', {0.59, 0.23, 0.70}), -- Ancestral Vigor
		[382024]	= Aura(382024, nil, true, 'TOP', {0.87, 0.98, 0.76}), -- Earthliving Weapon
		[444490]	= Aura(444490, nil, false, 'RIGHT', {0.67, 1.00, 0.62}), -- Hydrobubble
	},
	MONK = {
		-- Mistweaver
		[115175]	= Aura(115175, nil, true, 'TOP', {0.6, 0.9, 0.9}), -- Soothing Mist
		[119611]	= Aura(119611, nil, true, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Renewing Mist
		[450769]	= Aura(450769, nil, true, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Aspect of Harmony (Modified version of Renewing Mist)
		[124682]	= Aura(124682, nil, true, 'BOTTOMLEFT', {0.8, 0.8, 0.25}), -- Enveloping Mist
	},
	MAGE = {
		[1459]		= Aura(1459, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Arcane Intellect
	},
	WARRIOR = {
		[6673]		= Aura(6673, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Battle Shout
	},
	-- Not used for now
	ROGUE = {},
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
G.unitframe.AuraChannelTicks = {}

-- Spells Effected By Haste, value is Base Tick Size
G.unitframe.HastedChannelTicks = {
	-- [spellID] = true, -- SpellName
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {}

-- Auras which should change the color of the UnitFrame
G.unitframe.AuraHighlightColors = {}
