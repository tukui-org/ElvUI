local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List -- 1:priority, 2:enable, 3:stackThreshold
local Aura = E.Filters.Aura -- 1:auraID, 2:includeIDs, 3:enabled, 4:point, 5:color, 6:anyUnit, 7:onlyShowMissing, 8:displayText, 9:xOffset, 10:yOffset

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

G.unitframe.aurafilters.RaidCDs = {
	type = 'Whitelist',
	desc = L["Defensive raid-wide cooldowns."],
	spells = {}
}

-- Aura indicators on UnitFrames (Hots, Shields, Externals)
G.unitframe.aurawatch = {
	PRIEST = {},
	DRUID = {},
	PALADIN = {},
	SHAMAN = {},
	MAGE = {},
	WARRIOR = {},
	-- Not used for now
	ROGUE = {},
	HUNTER = {},
	PET = {},
	GLOBAL = {},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {}

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
