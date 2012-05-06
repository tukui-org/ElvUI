--[[
	Nameplate Filter
	
	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(select(2, ...)); --Engine

G["nameplate"]["filter"] = {

	--Test
	--[[['Bloodtalon Scythemaw'] = {
		['enable'] = true,
		['hide'] = false,
		['customColor'] = true,
		['color'] = {r = 255/255, g = 140/255, b = 200/255},
		['customScale'] = 1.2,
	},]]
}