local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List -- 1:priority, 2:enable, 3:stackThreshold
local Aura = E.Filters.Aura -- 1:auraID, 2:includeIDs, 3:enabled, 4:point, 5:color, 6:anyUnit, 7:onlyShowMissing, 8:displayText, 9:xOffset, 10:yOffset

G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	desc = L["Auras you don't want to see on your frames."],
	spells = {
	-- General
		[446720] = List(), -- Stinky: Perma roleplay text after eating Sunken Temple food.
	-- Druid
	-- Hunter
	-- Mage
	-- Paladin
	-- Priest
	-- Rogue
	-- Shaman
	-- Warlock
	-- Warrior
	-- Racial
	}
}

G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	desc = L["Auras which should always be displayed."],
	spells = {}
}

G.unitframe.aurafilters.RaidCDs = {
	type = 'Whitelist',
	desc = L["Defensive raid-wide cooldowns."],
	spells = {}
}

-- Aura indicators on UnitFrames (Hots, Shields, Externals)
G.unitframe.aurawatch = {
	GLOBAL = {},
	ROGUE = {}, -- No buffs
	WARRIOR = {
		[6673]	= Aura(6673, {5242, 6192, 11549, 11550, 11551, 25289, 2048}, true, 'TOPLEFT', {0.2, 0.2, 1}, true), -- Battle Shout
		[469]	= Aura(469, nil, true, 'TOPRIGHT', {0.4, 0.2, 0.8}, true), -- Commanding Shout
	},
	PRIEST = {
		[1243]	= Aura(1243, {1244, 1245, 2791, 10937, 10938, 25389}, true, 'TOPLEFT', {1, 1, 0.66}, true), -- Power Word: Fortitude
		[21562]	= Aura(21562, {21564, 25392}, true, 'TOPLEFT', {1, 1, 0.66}, true), -- Prayer of Fortitude
		[14752]	= Aura(14752, {14818, 14819, 27841, 25312}, true, 'TOPRIGHT', {0.2, 0.7, 0.2}, true), -- Divine Spirit
		[27681]	= Aura(27681, {32999}, true, 'TOPRIGHT', {0.2, 0.7, 0.2}, true), -- Prayer of Spirit
		[976]	= Aura(976, {10957, 10958, 25433}, true, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true), -- Shadow Protection
		[27683]	= Aura(27683, {39374}, true, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true), -- Prayer of Shadow Protection
		[17]	= Aura(17, {592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218}, true, 'BOTTOM', {0.00, 0.00, 1.00}), -- Power Word: Shield
		[139]	= Aura(139, {6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, 25221, 25222}, true, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Renew
	},
	DRUID = {
		[1126]	= Aura(1126, {5232, 6756, 5234, 8907, 9884, 9885, 26990, 21849, 21850, 26991}, true, 'TOPLEFT', {0.2, 0.8, 0.8}, true), -- Mark of the Wild
		[467]	= Aura(467, {782, 1075, 8914, 9756, 9910, 26992}, true, 'TOPRIGHT', {0.4, 0.2, 0.8}, true), -- Thorns
		[774]	= Aura(774, {1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299, 26981, 26982}, true, 'BOTTOMLEFT', {0.83, 1.00, 0.25}), -- Rejuvenation
		[8936]	= Aura(8936, {8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 26980}, true, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Regrowth
		[29166]	= Aura(29166, nil, true, 'CENTER', {0.49, 0.60, 0.55}, true), -- Innervate
		[33763]	= Aura(33763, nil, true, 'BOTTOM', {0.33, 0.37, 0.47}), -- Lifebloom
	},
	PALADIN = {
		[1044]	= Aura(1044, nil, true, 'CENTER', {0.89, 0.45, 0}), -- Blessing of Freedom
		[1038]	= Aura(1038, nil, true, 'TOPLEFT', {0.11, 1.00, 0.45}, true), -- Blessing of Salvation
		[25895] = Aura(25895, nil, true, 'TOPLEFT', {0.11, 1.00, 0.45}, true), -- Greater Blessing of Salvation
		[6940]	= Aura(6940, {20729, 27147, 27148}, true, 'CENTER', {0.89, 0.1, 0.1}), -- Blessing Sacrifice
		[20217] = Aura(20217, nil, true, 'TOPLEFT', {0.89, 0.45, 0}, true), -- Blessing of Kings
		[25898] = Aura(25898, nil, true, 'TOPLEFT', {0.89, 0.45, 0}, true), -- Greater Blessing of Kings
		[19740]	= Aura(19740, {19834, 19835, 19836, 19837, 19838, 25291, 27140}, true, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Blessing of Might
		[19742]	= Aura(19742, {19850, 19852, 19853, 19854, 25290, 27142}, true, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Blessing of Wisdom
		[25782]	= Aura(25782, {25916, 27141}, true, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Greater Blessing of Might
		[25894]	= Aura(25894, {25918, 27143}, true, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Greater Blessing of Wisdom
		[465]	= Aura(465, {10290, 643, 10291, 1032, 10292, 10293, 27149}, true, 'BOTTOMLEFT', {0.58, 1.00, 0.50}), -- Devotion Aura
		[19977]	= Aura(19977, {19978, 19979, 27144}, true, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true), -- Blessing of Light
		[1022]	= Aura(1022, {5599, 10278}, true, 'TOPRIGHT', {0.17, 1.00, 0.75}, true), -- Blessing of Protection
		[19746]	= Aura(19746, nil, true, 'BOTTOMLEFT', {0.83, 1.00, 0.07}), -- Concentration Aura
		[32223]	= Aura(32223, nil, true, 'BOTTOMLEFT', {0.83, 1.00, 0.07}), -- Crusader Aura
	},
	SHAMAN = {
		[29203]	= Aura(29203, nil, true, 'LEFT', {0.7, 0.3, 0.7}), -- Healing Way
		[16237]	= Aura(16237, nil, true, 'RIGHT', {0.2, 0.2, 1}), -- Ancestral Fortitude
		[974]	= Aura(974, {32593, 32594}, true, 'TOP', {0.08, 0.21, 0.43}, true), -- Earth Shield

		-- Fire
		[8182]	= Aura(8182, {10476, 10477, 25559}, true, 'TOPLEFT', {0.58, 0.23, 0.10}), -- Frost Resistance
		[30708] = Aura(30708, nil, true, 'TOPLEFT', {0.58, 0.23, 0.10}), -- Totem of Wrath (Crit/Hit increase)

		-- Earth
		[8072]	= Aura(8072, {8156, 8157, 10403, 10404, 10405, 25506, 25507}, true, 'TOPRIGHT', {0.23, 0.45, 0.13}), -- Stoneskin
		[8076] = Aura(8076, {8162, 8163, 10441, 25362, 25527}, true, 'TOPRIGHT', {0.23, 0.45, 0.13}), -- Strength of Earth (Strength increase)

		-- Air
		[2895] = Aura(2895, nil, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Wrath of Air (Spellpower increase)
		[15108] = Aura(15108, {15109, 15110, 25576}, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Windwall (damage reduction)
		[10596]	= Aura(10596, {10598, 10599, 25573}, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Nature Resistance
		[8178] = Aura(8178, nil, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Grounding Totem (spell redirection)
		[25909] = Aura(25909, nil, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Tranquil Air (Threat reduction)
		[8836] = Aura(8836, {10626, 25360}, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Grace of Air (agility)
		[6495] = Aura(6495, nil, true, 'BOTTOMLEFT', {0.42, 0.18, 0.74}), -- Sentry (vision totem)

		-- Water
		[16191]	= Aura(16191, {17355, 17360}, true, 'BOTTOMRIGHT', {0.19, 0.48, 0.60}), -- Mana Tide
		[8185]	= Aura(8185, {10534, 10535, 25562}, true, 'BOTTOMRIGHT', {0.19, 0.48, 0.60}), -- Fire Resistance
		[5677]	= Aura(5677, {10491, 10493, 10494, 25569}, true, 'BOTTOMRIGHT', {0.19, 0.48, 0.60}), -- Mana Spring
		[5672]	= Aura(5672, {6371, 6372, 10460, 10461, 25566}, true, 'BOTTOMRIGHT', {0.19, 0.48, 0.60}), -- Healing Stream
	},
	MAGE = {
		[1459]	= Aura(1459, {1460, 1461, 10156, 10157, 27126}, true, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Arcane Intellect
		[23028]	= Aura(23028, {27127}, true, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Arcane Brilliance
		[604]	= Aura(604, {8450, 8451, 10173, 10174, 33944}, true, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Dampen Magic
		[1008]	= Aura(1008, {8455, 10169, 10170, 27130, 33946}, true, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Amplify Magic
		[130]	= Aura(130, nil, true, 'CENTER', {0.00, 0.00, 0.50}, true), -- Slow Fall
	},
	HUNTER = {
		[19506]	= Aura(19506, {20905, 20906, 27066}, true, 'TOPLEFT', {0.89, 0.09, 0.05}), -- Trueshot Aura
		[13159]	= Aura(13159, nil, true, 'TOP', {0.00, 0.00, 0.85}, true), -- Aspect of the Pack
		[20043]	= Aura(20043, {20190, 27045}, true, 'TOP', {0.33, 0.93, 0.79}), -- Aspect of the Wild
	},
	WARLOCK = {
		[5597]	= Aura(5597, nil, true, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Unending Breath
		[6512]	= Aura(6512, nil, true, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Lesser Invisibility
		[2970]	= Aura(2970, nil, true, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Invisibility
		[11743]	= Aura(11743, nil, true, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Greater Invisibility
	},
	PET = {
	-- Warlock Imp
		[6307]	= Aura(6307, {7804, 7805, 11766, 11767}, true, 'BOTTOMLEFT', {0.89, 0.09, 0.05}), -- Blood Pact
	-- Warlock Felhunter
		[19480]	= Aura(19480, nil, true, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Paranoia
	-- Hunter Pets
		[24604]	= Aura(24604, {24605, 24603, 24597}, true, 'TOPRIGHT', {0.08, 0.59, 0.41}), -- Furious Howl
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Druid
	[740]	= 5, -- Tranquility (Rank 1)
	[8918]	= 5, -- Tranquility (Rank 2)
	[9862]	= 5, -- Tranquility (Rank 3)
	[9863]	= 5, -- Tranquility (Rank 4)
	[16914]	= 10, -- Hurricane (Rank 1)
	[17401]	= 10, -- Hurricane (Rank 2)
	[17402]	= 10, -- Hurricane (Rank 3)
	-- Hunter
	[1510]	= 6, -- Volley (Rank 1)
	[14294]	= 6, -- Volley (Rank 2)
	[14295]	= 6, -- Volley (Rank 3)
	[136]	= 5, -- Mend Pet (Rank 1)
	[3111]	= 5, -- Mend Pet (Rank 2)
	[3661]	= 5, -- Mend Pet (Rank 3)
	[3662]	= 5, -- Mend Pet (Rank 4)
	[13542]	= 5, -- Mend Pet (Rank 5)
	[13543]	= 5, -- Mend Pet (Rank 6)
	[13544]	= 5, -- Mend Pet (Rank 7)
	-- Mage
	[10]	= 8, -- Blizzard (Rank 1)
	[6141]	= 8, -- Blizzard (Rank 2)
	[8427]	= 8, -- Blizzard (Rank 3)
	[10185]	= 8, -- Blizzard (Rank 4)
	[10186]	= 8, -- Blizzard (Rank 5)
	[10187]	= 8, -- Blizzard (Rank 6)
	[5143]	= 3, -- Arcane Missiles (Rank 1)
	[5144]	= 4, -- Arcane Missiles (Rank 2)
	[5145]	= 5, -- Arcane Missiles (Rank 3)
	[8416]	= 5, -- Arcane Missiles (Rank 4)
	[8417]	= 5, -- Arcane Missiles (Rank 5)
	[10211]	= 5, -- Arcane Missiles (Rank 6)
	[10212]	= 5, -- Arcane Missiles (Rank 7)
	[12051]	= 4, -- Evocation
	-- Priest
	[15407]	= 3, -- Mind Flay (Rank 1)
	[17311]	= 3, -- Mind Flay (Rank 2)
	[17312]	= 3, -- Mind Flay (Rank 3)
	[17313]	= 3, -- Mind Flay (Rank 4)
	[17314]	= 3, -- Mind Flay (Rank 5)
	[18807]	= 3, -- Mind Flay (Rank 6)
	-- Warlock
	[1120]	= 5, -- Drain Soul (Rank 1)
	[8288]	= 5, -- Drain Soul (Rank 2)
	[8289]	= 5, -- Drain Soul (Rank 3)
	[11675]	= 5, -- Drain Soul (Rank 4)
	[755]	= 10, -- Health Funnel (Rank 1)
	[3698]	= 10, -- Health Funnel (Rank 2)
	[3699]	= 10, -- Health Funnel (Rank 3)
	[3700]	= 10, -- Health Funnel (Rank 4)
	[11693]	= 10, -- Health Funnel (Rank 5)
	[11694]	= 10, -- Health Funnel (Rank 6)
	[11695]	= 10, -- Health Funnel (Rank 7)
	[689]	= 5, -- Drain Life (Rank 1)
	[699]	= 5, -- Drain Life (Rank 2)
	[709]	= 5, -- Drain Life (Rank 3)
	[7651]	= 5, -- Drain Life (Rank 4)
	[11699]	= 5, -- Drain Life (Rank 5)
	[11700]	= 5, -- Drain Life (Rank 6)
	[5740]	= 4, -- Rain of Fire (Rank 1)
	[6219]	= 4, -- Rain of Fire (Rank 2)
	[11677]	= 4, -- Rain of Fire (Rank 3)
	[11678]	= 4, -- Rain of Fire (Rank 4)
	[1949]	= 15, -- Hellfire (Rank 1)
	[11683]	= 15, -- Hellfire (Rank 2)
	[11684]	= 15, -- Hellfire (Rank 3)
	[5138]	= 5, -- Drain Mana (Rank 1)
	[6226]	= 5, -- Drain Mana (Rank 2)
	[11703]	= 5, -- Drain Mana (Rank 3)
	[11704]	= 5, -- Drain Mana (Rank 4)
	-- First Aid
	[23567]	= 8, -- Warsong Gulch Runecloth Bandage
	[23696]	= 8, -- Alterac Heavy Runecloth Bandage
	[24414]	= 8, -- Arathi Basin Runecloth Bandage
	[18610]	= 8, -- Heavy Runecloth Bandage
	[18608]	= 8, -- Runecloth Bandage
	[10839]	= 8, -- Heavy Mageweave Bandage
	[10838]	= 8, -- Mageweave Bandage
	[7927]	= 8, -- Heavy Silk Bandage
	[7926]	= 8, -- Silk Bandage
	[3268]	= 7, -- Heavy Wool Bandage
	[3267]	= 7, -- Wool Bandage
	[1159]	= 6, -- Heavy Linen Bandage
	[746]	= 6, -- Linen Bandage
}

-- Spells that chain, ticks to add
G.unitframe.ChainChannelTicks = {}

-- Window to chain time (in seconds); usually the channel duration
G.unitframe.ChainChannelTime = {}

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {}

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
