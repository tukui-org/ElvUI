--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

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

	["Healing Tide Totem"] = {
		enable = true,
		hide = false,
		customColor = true,
		customScale = 1.1,
		color = {r = 104/255, g = 138/255, b = 217/255}
	},
	["Dragonmaw War Banner"] = {
		enable = true,
		hide = false,
		customColor = true,
		customScale = 1.1,
		color = {r = 255/255, g = 140/255, b = 200/255}
	}
}