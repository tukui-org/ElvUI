--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

G["nameplate"] = {
	["filter"] = {
		["Army of the Dead Ghoul"] = {
			['enable'] = true,
			['hide'] = true,
			['customColor'] = false,
			['color'] = {r = 104/255, g = 138/255, b = 217/255},
			['customScale'] = 1,
		},
		["Venomous Snake"] = {
			['enable'] = true,
			['hide'] = true,
			['customColor'] = false,
			['color'] = {r = 104/255, g = 138/255, b = 217/255},
			['customScale'] = 1,
		},
		["Healing Tide Totem"] = {
			['enable'] = true,
			['hide'] = false,
			['customColor'] = true,
			['customScale'] = 1.1,
			['color'] = {r = 104/255, g = 138/255, b = 217/255}
		},
		["Dragonmaw War Banner"] = {
			['enable'] = true,
			['hide'] = false,
			['customColor'] = true,
			['customScale'] = 1.1,
			['color'] = {r = 255/255, g = 140/255, b = 200/255}
		}
	},
	['filters'] = {
		['TestFilter'] = {
			['triggers'] = {
				['enable'] = true,
				['name'] = "", --leave blank to not check
				['level'] = 0, --set to 0 to disable, set to -1 for bosses
				['nameplateType'] = {
					['enable'] = false,
					['friendlyPlayer'] = false,
					['friendlyNPC'] = false,
					['healer'] = true,
					['enemyPlayer'] = true,
					['enemyNPC'] = true,
					['neutral'] = false
				},
				['buffs'] = {
					['mustHaveAll'] = false,
					['names'] = {
						['Divine Protection'] = true
					},
				},
				['debuffs'] = {
					['mustHaveAll'] = false,
					['names'] = {
						['Forbearance'] = true,
					},
				},
				['inCombat'] = true, -- check for incombat to run
				['outOfCombat'] = true, -- check for out of combat to run
			},
			['actions'] = {
				['color'] = {
					['enable'] = true,
					['color'] = {r=1,g=1,b=1},
				},
				['hide'] = true,
				['scale'] = 1.0,
			},
		},
	}
}