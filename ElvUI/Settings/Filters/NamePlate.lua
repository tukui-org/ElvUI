--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

G["nameplate"] = {
	["specialFilters"] = {
		['Boss'] = true,
		['Personal'] = true,
		['nonPersonal'] = true,
		['CastByUnit'] = true,
		['notCastByUnit'] = true,
		['blockNoDuration'] = true,
		['Dispellable'] = true,
	},
	['filters'] = {
		['TestFilter'] = {
			['triggers'] = {
				['priority'] = 1,
				['enable'] = false,
				['isTarget'] = false,
				['notTarget'] = false,
				['level'] = false,
				['curlevel'] = 0,
				['maxlevel'] = 0,
				['minlevel'] = 0,
				['names'] = {},
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
					['missing'] = false,
					['names'] = {
						['Divine Protection'] = true
					},
				},
				['debuffs'] = {
					['mustHaveAll'] = false,
					['missing'] = false,
					['names'] = {
						['Forbearance'] = true,
					},
				},
				['inCombat'] = false, -- check for incombat to run
				['outOfCombat'] = false, -- check for out of combat to run
				['inCombatUnit'] = false, -- check if a unit is affecting combat
				['outOfCombatUnit'] = false, -- check if a unit is not affecting combat
			},
			['actions'] = {
				['color'] = {
					['health'] = true,
					['healthColor'] = {r=1,g=1,b=1,a=1},
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

G.nameplate.populatedSpecialFilters = {}; --populates from `G.nameplate.specialFilters` and `G.unitframe.aurafilters`

for name, table in pairs(G.unitframe.aurafilters) do --add the default unitframe filters too
	G.nameplate.populatedSpecialFilters['Friendly:'..name] = true;
	G.nameplate.populatedSpecialFilters['Enemy:'..name] = true;
end
for name, table in pairs(G.nameplate.specialFilters) do
	G.nameplate.populatedSpecialFilters['Friendly:'..name] = true;
	G.nameplate.populatedSpecialFilters['Enemy:'..name] = true;
	G.nameplate.populatedSpecialFilters[name] = true;
end