local DB, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales


if not C["unitframes"].enable == true and not C["raidframes"].enable == true and not C["nameplate"].enable == true then return end
------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------
local DB, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales

DB.oUF_colors = setmetatable({
	tapped = DB.colors.tapped,
	disconnected = DB.colors.disconnected,
	power = setmetatable({
		["MANA"] = DB.colors.power.MANA,
		["RAGE"] = DB.colors.power.RAGE,
		["FOCUS"] = DB.colors.power.FOCUS,
		["ENERGY"] = DB.colors.power.ENERGY,
		["RUNES"] = DB.colors.power.RUNES,
		["RUNIC_POWER"] = DB.colors.power.RUNIC_POWER,
		["AMMOSLOT"] = DB.colors.power.AMMOSLOT,
		["FUEL"] = DB.colors.power.FUEL,
		["POWER_TYPE_STEAM"] = DB.colors.power.POWER_TYPE_STEAM,
		["POWER_TYPE_PYRITE"] = DB.colors.power.POWER_TYPE_PYRITE,
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = DB.colors.happiness[1],
		[2] = DB.colors.happiness[2],
		[3] = DB.colors.happiness[3],
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
			[1] = DB.colors.runes[1],
			[2] = DB.colors.runes[2],
			[3] = DB.colors.runes[3],
			[4] = DB.colors.runes[4],
	}, {__index = oUF.colors.runes}),
	reaction = setmetatable({
		[1] = DB.colors.reaction[1], -- Hated
		[2] = DB.colors.reaction[2], -- Hostile
		[3] = DB.colors.reaction[3], -- Unfriendly
		[4] = DB.colors.reaction[4], -- Neutral
		[5] = DB.colors.reaction[5], -- Friendly
		[6] = DB.colors.reaction[6], -- Honored
		[7] = DB.colors.reaction[7], -- Revered
		[8] = DB.colors.reaction[8], -- Exalted	
	}, {__index = oUF.colors.reaction}),
	class = setmetatable({
		["DEATHKNIGHT"] = DB.colors.class.DEATHKNIGHT,
		["DRUID"]       = DB.colors.class.DRUID,
		["HUNTER"]      = DB.colors.class.HUNTER,
		["MAGE"]        = DB.colors.class.MAGE,
		["PALADIN"]     = DB.colors.class.PALADIN,
		["PRIEST"]      = DB.colors.class.PRIEST,
		["ROGUE"]       = DB.colors.class.ROGUE,
		["SHAMAN"]      = DB.colors.class.SHAMAN,
		["WARLOCK"]     = DB.colors.class.WARLOCK,
		["WARRIOR"]     = DB.colors.class.WARRIOR,
	}, {__index = oUF.colors.class}),
}, {__index = oUF.colors})