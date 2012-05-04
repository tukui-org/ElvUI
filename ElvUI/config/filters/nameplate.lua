--[[
	Nameplate Filter
	
	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(select(2, ...)); --Engine

G["nameplate"]["filter"] = {
	--Army of the Dead
	["Army of the Dead Ghoul"] = {
		['enable'] = true,
		['hide'] = true,
		['customColor'] = false,
		['color'] = {r = 104/255, g = 138/255, b = 217/255},
		['customScale'] = 1,
	},

	--Hunter Trap
	["Venomous Snake"] = {
		['enable'] = true,
		['hide'] = true,
		['customColor'] = false,
		['color'] = {r = 104/255, g = 138/255, b = 217/255},
		['customScale'] = 1,
	},
	["Viper"] = {
		['enable'] = true,
		['hide'] = true,
		['customColor'] = false,
		['color'] = {r = 104/255, g = 138/255, b = 217/255},
		['customScale'] = 1,
	},
	
	--Magmaw
	["Lava Parasite"] = {
		['enable'] = true,
		['hide'] = true,
		['customColor'] = false,
		['color'] = {r = 104/255, g = 138/255, b = 217/255},
		['customScale'] = 1,
	},
	
	--Lord Rhyolith
	['Liquid Obsidian'] = {
		['enable'] = true,
		['hide'] = true,
		['customColor'] = false,
		['color'] = {r = 104/255, g = 138/255, b = 217/255},
		['customScale'] = 1,
	},
	['Spark of Rhyolith'] = {
		['enable'] = true,
		['hide'] = false,
		['customColor'] = true,
		['color'] = {r = 255/255, g = 140/255, b = 200/255},
		['customScale'] = 1,
	},
	
	--Test
	--[[['Bloodtalon Scythemaw'] = {
		['enable'] = true,
		['hide'] = false,
		['customColor'] = true,
		['color'] = {r = 255/255, g = 140/255, b = 200/255},
		['customScale'] = 1.2,
	},]]
}