local ElvDB = ElvDB
local ElvCF = ElvCF

if not ElvCF["unitframes"].enable == true and not ElvCF["raidframes"].enable == true and not ElvCF["nameplate"].enable == true then return end
------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------
local ElvDB = ElvDB

ElvDB.oUF_colors = setmetatable({
	tapped = ElvDB.colors.tapped,
	disconnected = ElvDB.colors.disconnected,
	power = setmetatable({
		["MANA"] = ElvDB.colors.power.MANA,
		["RAGE"] = ElvDB.colors.power.RAGE,
		["FOCUS"] = ElvDB.colors.power.FOCUS,
		["ENERGY"] = ElvDB.colors.power.ENERGY,
		["RUNES"] = ElvDB.colors.power.RUNES,
		["RUNIC_POWER"] = ElvDB.colors.power.RUNIC_POWER,
		["AMMOSLOT"] = ElvDB.colors.power.AMMOSLOT,
		["FUEL"] = ElvDB.colors.power.FUEL,
		["POWER_TYPE_STEAM"] = ElvDB.colors.power.POWER_TYPE_STEAM,
		["POWER_TYPE_PYRITE"] = ElvDB.colors.power.POWER_TYPE_PYRITE,
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = ElvDB.colors.happiness[1],
		[2] = ElvDB.colors.happiness[2],
		[3] = ElvDB.colors.happiness[3],
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
			[1] = ElvDB.colors.runes[1],
			[2] = ElvDB.colors.runes[2],
			[3] = ElvDB.colors.runes[3],
			[4] = ElvDB.colors.runes[4],
	}, {__index = oUF.colors.runes}),
	reaction = setmetatable({
		[1] = ElvDB.colors.reaction[1], -- Hated
		[2] = ElvDB.colors.reaction[2], -- Hostile
		[3] = ElvDB.colors.reaction[3], -- Unfriendly
		[4] = ElvDB.colors.reaction[4], -- Neutral
		[5] = ElvDB.colors.reaction[5], -- Friendly
		[6] = ElvDB.colors.reaction[6], -- Honored
		[7] = ElvDB.colors.reaction[7], -- Revered
		[8] = ElvDB.colors.reaction[8], -- Exalted	
	}, {__index = oUF.colors.reaction}),
	class = setmetatable({
		["DEATHKNIGHT"] = ElvDB.colors.class.DEATHKNIGHT,
		["DRUID"]       = ElvDB.colors.class.DRUID,
		["HUNTER"]      = ElvDB.colors.class.HUNTER,
		["MAGE"]        = ElvDB.colors.class.MAGE,
		["PALADIN"]     = ElvDB.colors.class.PALADIN,
		["PRIEST"]      = ElvDB.colors.class.PRIEST,
		["ROGUE"]       = ElvDB.colors.class.ROGUE,
		["SHAMAN"]      = ElvDB.colors.class.SHAMAN,
		["WARLOCK"]     = ElvDB.colors.class.WARLOCK,
		["WARRIOR"]     = ElvDB.colors.class.WARRIOR,
	}, {__index = oUF.colors.class}),
}, {__index = oUF.colors})