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

	},
}

G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {

	},
}

G.unitframe.aurafilters['DebuffBlacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {

	},
}

--RAID DEBUFFS
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Test
		--[SpellName(25771)] = true, --Forbearance

	},
}

E.ReverseTimer = {

}

--BuffWatch

local function ClassBuff(id, point, color, anyUnit, onlyShowMissing)
	local r, g, b = unpack(color)
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, ["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing}
end

G.unitframe.buffwatch = {
	PRIEST = {

	},
	DRUID = {

	},
	PALADIN = {

	},
	ROGUE = {

	},
	DEATHKNIGHT = {

	},
	MAGE = {

	},
	WARRIOR = {

	},
	SHAMAN = {

	},	
}

--List of spells to display ticks
G.unitframe.ChannelTicks = {

}

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {

}

