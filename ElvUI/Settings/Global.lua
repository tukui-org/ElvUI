local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Global Settings
G['general'] = {
	["autoScale"] = true,
	["eyefinity"] = false,
	['smallerWorldMap'] = true,
	['WorldMapCoordinates'] = {
		["enable"] = true,
		["position"] = "BOTTOMLEFT",
		["mousePos"] = "TOP",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["disableTutorialButtons"] = true,
}

G['classtimer'] = {}

G["nameplate"] = {}

G['unitframe'] = {
	['aurafilters'] = {},
	['buffwatch'] = {},
}
