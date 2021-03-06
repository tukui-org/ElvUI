--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(select(2, ...)) --Engine

G.nameplate.filters = {
	ElvUI_Boss = {
		triggers = {
			level = true,
			curlevel = -1,
			priority = 2
		},
		actions = {
			usePortrait = true,
			scale = 1.15
		}
	},
	ElvUI_Target = {
		triggers = {
			isTarget = true
		},
		actions = {
			scale = 1.2
		}
	},
	ElvUI_NonTarget = {
		triggers = {
			notTarget = true,
			requireTarget = true,
			nameplateType = {
				enable = true,
				friendlyPlayer = true,
				friendlyNPC = true,
				enemyPlayer = true,
				enemyNPC = true
			}
		},
		actions = {
			alpha = 50
		}
	},
	ElvUI_Explosives = {
		triggers = {
			priority = 2,
			nameplateType = {
				enable = true,
				enemyNPC = true
			},
			names = {
				['120651'] = true
			}
		},
		actions = {
			usePortrait = true,
			scale = 1.15,
			color = {
				health = true,
				healthColor = {r = 0, g = 255, b = 255}
			}
		}
	}
}

E.StyleFilterDefaults = {
	triggers = {
		priority = 1,
		targetMe = false,
		isTarget = false,
		notTarget = false,
		requireTarget = false,
		level = false,
		casting = {
			isCasting = false,
			isChanneling = false,
			notCasting = false,
			notChanneling = false,
			interruptible = false,
			notSpell = false,
			spells = {}
		},
		role = {
			tank = false,
			healer = false,
			damager = false
		},
		unitRole = {
			tank = false,
			healer = false,
			damager = false
		},
		classification = {
			worldboss = false,
			rareelite = false,
			elite = false,
			rare = false,
			normal = false,
			trivial = false,
			minus = false
		},
		class = {}, -- this can stay empty we only will accept values that exist
		raidTarget = {
			star = false,
			circle = false,
			diamond = false,
			triangle = false,
			moon = false,
			square = false,
			cross = false,
			skull = false
		},
		talent = {
			type = 'normal',
			enabled = false,
			requireAll = false,
			tier1enabled = false,
			tier1 = {missing = false, column = 0},
			tier2enabled = false,
			tier2 = {missing = false, column = 0},
			tier3enabled = false,
			tier3 = {missing = false, column = 0},
			tier4enabled = false,
			tier4 = {missing = false, column = 0},
			tier5enabled = false,
			tier5 = {missing = false, column = 0},
			tier6enabled = false,
			tier6 = {missing = false, column = 0},
			tier7enabled = false,
			tier7 = {missing = false, column = 0}
		},
		threat = {
			enable = false,
			good = false,
			goodTransition = false,
			badTransition = false,
			bad = false,
			offTank = false,
			offTankGoodTransition = false,
			offTankBadTransition = false
		},
		curlevel = 0,
		maxlevel = 0,
		minlevel = 0,
		healthThreshold = false,
		healthUsePlayer = false,
		underHealthThreshold = 0,
		overHealthThreshold = 0,
		powerThreshold = false,
		powerUsePlayer = false,
		underPowerThreshold = 0,
		overPowerThreshold = 0,
		names = {},
		creatureType = {
			enable = false,
			Aberration = false,
			Beast = false,
			Critter = false,
			Demon = false,
			Dragonkin = false,
			Elemental = false,
			['Gas Cloud'] = false,
			Giant = false,
			Humanoid = false,
			Mechanical = false,
			['Not specified'] = false,
			Totem = false,
			Undead = false,
			['Wild Pet'] = false,
			['Non-combat Pet'] = false
		},
		nameplateType = {
			enable = false,
			friendlyPlayer = false,
			friendlyNPC = false,
			enemyPlayer = false,
			enemyNPC = false,
			player = false
		},
		reactionType = {
			enabled = false,
			reputation = false,
			hated = false,
			hostile = false,
			unfriendly = false,
			neutral = false,
			friendly = false,
			honored = false,
			revered = false,
			exalted = false
		},
		instanceType = {
			none = false,
			scenario = false,
			party = false,
			raid = false,
			arena = false,
			pvp = false
		},
		location = {
			mapIDEnabled = false,
			mapIDs = {},
			instanceIDEnabled = false,
			instanceIDs = {},
			zoneNamesEnabled = false,
			zoneNames = {},
			subZoneNamesEnabled = false,
			subZoneNames = {},
		},
		keyMod = {
			enable = false,
			Modifier = false,
			Shift = false,
			Alt = false,
			Control = false,
			LeftShift = false,
			LeftAlt = false,
			LeftControl = false,
			RightShift = false,
			RightAlt = false,
			RightControl = false
		},
		instanceDifficulty = {
			dungeon = {
				normal = false,
				heroic = false,
				mythic = false,
				['mythic+'] = false,
				timewalking = false
			},
			raid = {
				lfr = false,
				normal = false,
				heroic = false,
				mythic = false,
				timewalking = false,
				legacy10normal = false,
				legacy25normal = false,
				legacy10heroic = false,
				legacy25heroic = false
			}
		},
		cooldowns = {
			names = {},
			mustHaveAll = false
		},
		buffs = {
			mustHaveAll = false,
			missing = false,
			names = {},
			minTimeLeft = 0,
			maxTimeLeft = 0,
			hasStealable = false,
			hasNoStealable = false
		},
		debuffs = {
			mustHaveAll = false,
			missing = false,
			names = {},
			minTimeLeft = 0,
			maxTimeLeft = 0
		},
		isResting = false,
		isPet = false,
		isNotPet = false,
		isPlayerControlled = false,
		isNotPlayerControlled = false,
		isOwnedByPlayer = false,
		isNotOwnedByPlayer = false,
		isPvP = false,
		isNotPvP = false,
		isTapDenied = false,
		isNotTapDenied = false,
		playerCanAttack = false,
		playerCanNotAttack = false,
		hasTitleNPC = false,
		noTitleNPC = false,
		isQuest = false,
		notQuest = false,
		questBoss = false,
		-- combat
		inCombat = false,
		outOfCombat = false,
		inCombatUnit = false,
		outOfCombatUnit = false,
		-- vehicle
		inVehicle = false,
		outOfVehicle = false,
		inVehicleUnit = false,
		outOfVehicleUnit = false
	},
	actions = {
		color = {
			health = false,
			power = false,
			border = false,
			healthColor = {r = 1, g = 1, b = 1, a = 1},
			powerColor = {r = 1, g = 1, b = 1, a = 1},
			borderColor = {r = 1, g = 1, b = 1, a = 1}
		},
		texture = {
			enable = false,
			texture = 'ElvUI Norm'
		},
		flash = {
			enable = false,
			color = {r = 1, g = 1, b = 1, a = 1},
			speed = 4
		},
		tags = {
			name = '',
			level = '',
			title = '',
			health = '',
			power = ''
		},
		hide = false,
		usePortrait = false,
		nameOnly = false,
		scale = 1,
		alpha = -1
	}
}
