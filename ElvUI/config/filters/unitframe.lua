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

G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	},
}

G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	},
}

G.unitframe.aurafilters['Blacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[SpellName(36032)] = Defaults(), -- Arcane Charge
		[SpellName(76691)] = Defaults(), -- Vengeance
	},
}

G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[SpellName(2825)] = Defaults(), -- Bloodlust
		[SpellName(32182)] = Defaults(), -- Heroism	
	},
}

--RAID DEBUFFS
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	},
}

E.ReverseTimer = {

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
		{6788, "TOPRIGHT", {1, 0, 0}, true},	 -- Weakened Soul
		{33076, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},	 -- Prayer of Mending
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true},	 -- Power Word: Shield
	},
	DRUID = {
		{774, "TOPRIGHT", {0.8, 0.4, 0.8}},	 -- Rejuvenation
		{8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}},	 -- Regrowth
		{94447, "TOPLEFT", {0.4, 0.8, 0.2}},	 -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}},	 -- Wild Growth
	},
	PALADIN = {
		{53563, "TOPRIGHT", {0.7, 0.3, 0.7}},	 -- Beacon of Light
		{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true},	-- Hand of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},	-- Hand of Freedom
		{1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true},	-- Hand of Salvation
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},	-- Hand of Sacrifice
	},
	SHAMAN = {
		{61295, "TOPRIGHT", {0.7, 0.3, 0.7}},	 -- Riptide
		{974, "BOTTOMLEFT", {0.2, 0.7, 0.2}, true},	 -- Earth Shield
		{51945, "BOTTOMRIGHT", {0.7, 0.4, 0}},	 -- Earthliving
	},
	MONK = {
		{119611, "TOPLEFT", {0.8, 0.4, 0.8}},	 --Renewing Mist
		{116849, "TOPRIGHT", {0.2, 0.8, 0.2}},	 -- Life Cocoon
		{124682, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Enveloping Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}}, -- Zen Sphere
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