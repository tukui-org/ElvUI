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
				['npcid'] = "", --leave blank to not check
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
				['reactionType'] = {
					['enabled'] = false,
					['reputation'] = false,
					['hated'] = false,
					['hostile'] = false,
					['unfriendly'] = false,
					['neutral'] = false,
					['friendly'] = false,
					['honored'] = false,
					['revered'] = false,
					['exalted'] = false
				},
				['buffs'] = {
					['mustHaveAll'] = false,
					['missingAll'] = false,
					['names'] = {
						['Divine Protection'] = true
					},
				},
				['debuffs'] = {
					['mustHaveAll'] = false,
					['missingAll'] = false,
					['names'] = {
						['Forbearance'] = true,
					},
				},
				['inCombat'] = true, -- check for incombat to run
				['outOfCombat'] = true, -- check for out of combat to run
				['inCombatUnit'] = true, -- check if a unit is affecting combat
				['outOfCombatUnit'] = true, -- check if a unit is not affecting combat
			},
			['actions'] = {
				['color'] = {
					['enable'] = true,
					['color'] = {r=1,g=1,b=1,a=1},
					['borderColor'] = {r=1,g=1,b=1,a=1}
				},
				['texture'] = {
					['enable'] = false,
					['texture'] = "ElvUI Norm",
				},
				['hide'] = true,
				['scale'] = 1.0,
			},
		},
	}
}