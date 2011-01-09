local TukuiDB = TukuiDB
local TukuiCF = TukuiCF

if not TukuiCF["unitframes"].enable == true and not TukuiCF["raidframes"].enable == true and not TukuiCF["nameplate"].enable == true then return end
------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------
local TukuiDB = TukuiDB

TukuiDB.oUF_colors = setmetatable({
	tapped = TukuiDB.colors.tapped,
	disconnected = TukuiDB.colors.disconnected,
	power = setmetatable({
		["MANA"] = TukuiDB.colors.power.MANA,
		["RAGE"] = TukuiDB.colors.power.RAGE,
		["FOCUS"] = TukuiDB.colors.power.FOCUS,
		["ENERGY"] = TukuiDB.colors.power.ENERGY,
		["RUNES"] = TukuiDB.colors.power.RUNES,
		["RUNIC_POWER"] = TukuiDB.colors.power.RUNIC_POWER,
		["AMMOSLOT"] = TukuiDB.colors.power.AMMOSLOT,
		["FUEL"] = TukuiDB.colors.power.FUEL,
		["POWER_TYPE_STEAM"] = TukuiDB.colors.power.POWER_TYPE_STEAM,
		["POWER_TYPE_PYRITE"] = TukuiDB.colors.power.POWER_TYPE_PYRITE,
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = TukuiDB.colors.happiness[1],
		[2] = TukuiDB.colors.happiness[2],
		[3] = TukuiDB.colors.happiness[3],
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
			[1] = TukuiDB.colors.runes[1],
			[2] = TukuiDB.colors.runes[2],
			[3] = TukuiDB.colors.runes[3],
			[4] = TukuiDB.colors.runes[4],
	}, {__index = oUF.colors.runes}),
	reaction = setmetatable({
		[1] = TukuiDB.colors.reaction[1], -- Hated
		[2] = TukuiDB.colors.reaction[2], -- Hostile
		[3] = TukuiDB.colors.reaction[3], -- Unfriendly
		[4] = TukuiDB.colors.reaction[4], -- Neutral
		[5] = TukuiDB.colors.reaction[5], -- Friendly
		[6] = TukuiDB.colors.reaction[6], -- Honored
		[7] = TukuiDB.colors.reaction[7], -- Revered
		[8] = TukuiDB.colors.reaction[8], -- Exalted	
	}, {__index = oUF.colors.reaction}),
	class = setmetatable({
		["DEATHKNIGHT"] = TukuiDB.colors.class.DEATHKNIGHT,
		["DRUID"]       = TukuiDB.colors.class.DRUID,
		["HUNTER"]      = TukuiDB.colors.class.HUNTER,
		["MAGE"]        = TukuiDB.colors.class.MAGE,
		["PALADIN"]     = TukuiDB.colors.class.PALADIN,
		["PRIEST"]      = TukuiDB.colors.class.PRIEST,
		["ROGUE"]       = TukuiDB.colors.class.ROGUE,
		["SHAMAN"]      = TukuiDB.colors.class.SHAMAN,
		["WARLOCK"]     = TukuiDB.colors.class.WARLOCK,
		["WARRIOR"]     = TukuiDB.colors.class.WARRIOR,
	}, {__index = oUF.colors.class}),
}, {__index = oUF.colors})