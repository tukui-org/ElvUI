--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

G["nameplate"] = {
	["defaultFilters"] = {
		['Boss'] = true,
		['Personal'] = true,
		['nonPersonal'] = true,
		['blockNoDuration'] = true,
		['Dispellable'] = true,
	},
	['filters'] = {
		['TestFilter'] = {
			['triggers'] = {
				['enable'] = true,
				['name'] = "", --leave blank to not check
				['level'] = 0, --set to 0 to disable, set to -1 for bosses
				['npcid'] = 0, --set to 0 to disable
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