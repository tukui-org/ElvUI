--[[
	Nameplate Filter
	
	Add the nameplates name that you do NOT want to see.
]]
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.PlateBlacklist = {
	--Shaman Totems
	["Earth Elemental Totem"] = true,
	["Fire Elemental Totem"] = true,
	["Fire Resistance Totem"] = true,
	["Flametongue Totem"] = true,
	["Frost Resistance Totem"] = true,
	["Healing Stream Totem"] = true,
	["Magma Totem"] = true,
	["Mana Spring Totem"] = true,
	["Nature Resistance Totem"] = true,
	["Searing Totem"] = true,
	["Stoneclaw Totem"] = true,
	["Stoneskin Totem"] = true,
	["Strength of Earth Totem"] = true,
	["Windfury Totem"] = true,
	["Totem of Wrath"] = true,
	["Wrath of Air Totem"] = true,

	--Army of the Dead
	["Army of the Dead Ghoul"] = true,

	--Hunter Trap
	["Venomous Snake"] = true,
	["Viper"] = true,
	
	--Misc
	["Lava Parasite"] = true,

	--Test
	--["Unbound Seer"] = true,
}