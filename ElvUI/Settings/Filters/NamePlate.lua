--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

G["nameplate"] = {
	["specialFilters"] = {
		["Boss"] = true,
		["Personal"] = true,
		["nonPersonal"] = true,
		["blockNonPersonal"] = true,
		["CastByUnit"] = true,
		["notCastByUnit"] = true,
		["blockNoDuration"] = true,
		["Dispellable"] = true,
	},
	["filters"] = {
		["Boss"] = {
			["triggers"] = {
				["priority"] = 1,
				["isTarget"] = false,
				["notTarget"] = false,
				["level"] = true,
				["casting"] = {
					["interruptible"] = false,
					["spells"] = {},
				},
				["role"] = {
					["tank"] = false,
					["healer"] = false,
					["damager"] = false,
				},
				["class"] = {}, --this can stay empty we only will accept values that exist
				["curlevel"] = -1,
				["maxlevel"] = 0,
				["minlevel"] = 0,
				["healthThreshold"] = false,
				["underHealthThreshold"] = 0,
				["overHealthThreshold"] = 0,
				["names"] = {},
				["nameplateType"] = {
					["enable"] = true,
					["friendlyPlayer"] = false,
					["friendlyNPC"] = false,
					["healer"] = false,
					["enemyPlayer"] = false,
					["enemyNPC"] = true,
					["neutral"] = false
				},
				["reactionType"] = {
					["enabled"] = false,
					["reputation"] = false,
					["hated"] = false,
					["hostile"] = false,
					["unfriendly"] = false,
					["neutral"] = false,
					["friendly"] = false,
					["honored"] = false,
					["revered"] = false,
					["exalted"] = false
				},
				["buffs"] = {
					["mustHaveAll"] = false,
					["missing"] = false,
					["names"] = {},
					["minTimeLeft"] = 0,
					["maxTimeLeft"] = 0,
				},
				["debuffs"] = {
					["mustHaveAll"] = false,
					["missing"] = false,
					["names"] = {},
					["minTimeLeft"] = 0,
					["maxTimeLeft"] = 0,
				},
				["inCombat"] = false,
				["outOfCombat"] = false,
				["inCombatUnit"] = false,
				["outOfCombatUnit"] = false,
			},
			["actions"] = {
				["color"] = {
					["health"] = false,
					["border"] = false,
					["name"] = false,
					["healthColor"] = {r=1,g=1,b=1,a=1},
					["borderColor"] = {r=1,g=1,b=1,a=1},
					["nameColor"] = {r=1,g=1,b=1,a=1}
				},
				["texture"] = {
					["enable"] = false,
					["texture"] = "ElvUI Norm",
				},
				["hide"] = false,
				["usePortrait"] = true,
				["scale"] = 1.15,
			},
		},
	}
}

G.nameplate.populatedSpecialFilters = {}; --populates from `G.nameplate.specialFilters` and `G.unitframe.aurafilters`

for name, table in pairs(G.unitframe.aurafilters) do --add the default unitframe filters too
	G.nameplate.populatedSpecialFilters["Friendly:"..name] = true;
	G.nameplate.populatedSpecialFilters["Enemy:"..name] = true;
end
for name, table in pairs(G.nameplate.specialFilters) do
	G.nameplate.populatedSpecialFilters["Friendly:"..name] = true;
	G.nameplate.populatedSpecialFilters["Enemy:"..name] = true;
	G.nameplate.populatedSpecialFilters[name] = true;
end