--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(select(2, ...)); --Engine

G["nameplate"]["filters"] = {
	["Boss"] = {
		["triggers"] = {
			["level"] = true,
			["curlevel"] = -1,
			["nameplateType"] = {
				["enable"] = true,
				["enemyNPC"] = true,
			},
		},
		["actions"] = {
			["usePortrait"] = true,
			["scale"] = 1.15,
		},
	},
}

E["StyleFilterDefaults"] = {
	["triggers"] = {
		["priority"] = 1,
		["targetMe"] = false,
		["isTarget"] = false,
		["notTarget"] = false,
		["questBoss"] = false,
		["level"] = false,
		["casting"] = {
			["interruptible"] = false,
			["spells"] = {},
		},
		["role"] = {
			["tank"] = false,
			["healer"] = false,
			["damager"] = false,
		},
		["classification"] = {
			["worldboss"] = false,
			["rareelite"] = false,
			["elite"] = false,
			["rare"] = false,
			["normal"] = false,
			["trivial"] = false,
			["minus"] = false,
		},
		["class"] = {}, --this can stay empty we only will accept values that exist
		["talent"] = {
			["type"] = "normal",
			["enabled"] = false,
			["requireAll"] = false,
			["tier1enabled"] = false,
			["tier1"] = {
				["missing"] = false,
				["column"] = 0,
			},
			["tier2enabled"] = false,
			["tier2"] = {
				["missing"] = false,
				["column"] = 0,
			},
			["tier3enabled"] = false,
			["tier3"] = {
				["missing"] = false,
				["column"] = 0,
			},
			["tier4enabled"] = false,
			["tier4"] = {
				["missing"] = false,
				["column"] = 0,
			},
			["tier5enabled"] = false,
			["tier5"] = {
				["missing"] = false,
				["column"] = 0,
			},
			["tier6enabled"] = false,
			["tier6"] = {
				["missing"] = false,
				["column"] = 0,
			},
			["tier7enabled"] = false,
			["tier7"] = {
				["missing"] = false,
				["column"] = 0,
			},
		},
		["curlevel"] = 0,
		["maxlevel"] = 0,
		["minlevel"] = 0,
		["healthThreshold"] = false,
		["healthUsePlayer"] = false,
		["underHealthThreshold"] = 0,
		["overHealthThreshold"] = 0,
		["powerThreshold"] = false,
		["powerUsePlayer"] = false,
		["underPowerThreshold"] = 0,
		["overPowerThreshold"] = 0,
		["names"] = {},
		["nameplateType"] = {
			["enable"] = false,
			["friendlyPlayer"] = false,
			["friendlyNPC"] = false,
			["healer"] = false,
			["enemyPlayer"] = false,
			["enemyNPC"] = false,
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
		["instanceType"] = {
			["none"] = false,
			["scenario"] = false,
			["party"] = false,
			["raid"] = false,
			["arena"] = false,
			["pvp"] = false,
		},
		["instanceDifficulty"] = {
			["dungeon"] = {
				["normal"] = false,
				["heroic"] = false,
				["mythic"] = false,
				["mythic+"] = false,
				["timewalking"] = false,
			},
			["raid"] = {
				["lfr"] = false,
				["normal"] = false,
				["heroic"] = false,
				["mythic"] = false,
				["timewalking"] = false,
				["legacy10normal"] = false,
				["legacy25normal"] = false,
				["legacy10heroic"] = false,
				["legacy25heroic"] = false,
			}
		},
		["cooldowns"] = {
			["names"] = {},
			["mustHaveAll"] = false,
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
			["power"] = false,
			["border"] = false,
			["name"] = false,
			["healthColor"] = {r=1,g=1,b=1,a=1},
			["powerColor"] = {r=1,g=1,b=1,a=1},
			["borderColor"] = {r=1,g=1,b=1,a=1},
			["nameColor"] = {r=1,g=1,b=1,a=1}
		},
		["texture"] = {
			["enable"] = false,
			["texture"] = "ElvUI Norm",
		},
		["flash"] = {
			["enable"] = false,
			["color"] = {r=1,g=1,b=1,a=1},
			["speed"] = 4,
		},
		["hide"] = false,
		["usePortrait"] = false,
		["nameOnly"] = false,
		["frameLevel"] = 0,
		["scale"] = 1.0,
		["alpha"] = -1,
	},
}
