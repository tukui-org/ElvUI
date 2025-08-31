--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(ElvUI)

local defaults = {
	texture = {
		enable = false,
		texture = 'ElvUI Norm'
	},
	colors = {
		enable = false,
		unitClass = false,
		playerClass = false,
		color = { r = 1, g = 1, b = 1, a = 1 },
	},
	border = {
		enable = false,
		unitClass = false,
		playerClass = false,
		color = { r = 1, g = 1, b = 1, a = 1 }
	},
	flash = {
		enable = false,
		unitClass = false,
		playerClass = false,
		color = { r = 1, g = 1, b = 1, a = 1 },
		speed = 4
	},
	glow = {
		enable = false,
		useColor = true, -- not a real option
		frameLevel = 5, -- not a real option
		color = { 0.09, 0.52, 0.82, 0.9 }, -- lib uses old index table
		style = 'Pixel Glow',
		speed = 0.3,
		lines = 8,
		size = 1
	}
}

G.nameplates.filters = {
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
	}
}

E.StyleFilterDefaults = {
	actions = {
		scale = 1,
		alpha = -1,
		hide = false,
		nameOnly = false,
		usePortrait = false,
		health = CopyTable(defaults),
		power = CopyTable(defaults),
		castbar = CopyTable(defaults),
		sound = {
			enable = false,
			overlap = false,
			soundFile = ''
		},
		tags = {
			name = '',
			level = '',
			title = '',
			health = '',
			power = ''
		},
	},
	triggers = {
		priority = 1,
		targetMe = false,
		isTarget = false,
		notTarget = false,
		requireTarget = false,
		noTarget = false,
		level = false,
		names = {},
		items = {},
		slots = {},
		known = {
			notKnown = false,
			playerSpell = false,
			spells = {} -- new talents
		},
		class = {}, -- this can stay empty we only will accept values that exist
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
		faction = {
			Alliance = false,
			Horde = false,
			Neutral = false,
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
		amountAbove = 0,
		amountBelow = 0,
		healthThreshold = false,
		healthUsePlayer = false,
		underHealthThreshold = 0,
		overHealthThreshold = 0,
		powerThreshold = false,
		powerUsePlayer = false,
		underPowerThreshold = 0,
		overPowerThreshold = 0,
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
			subZoneNames = {}
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
			mustHaveAll = false,
			names = {}
		},
		buffs = {
			mustHaveAll = false,
			missing = false,
			minTimeLeft = 0,
			maxTimeLeft = 0,
			hasStealable = false,
			hasNoStealable = false,
			onMe = false,
			onPet = false,
			fromMe = false,
			fromPet = false,
			names = {}
		},
		debuffs = {
			mustHaveAll = false,
			missing = false,
			minTimeLeft = 0,
			maxTimeLeft = 0,
			hasDispellable = false,
			hasNoDispellable = false,
			onMe = false,
			onPet = false,
			fromMe = false,
			fromPet = false,
			names = {}
		},
		bossMods = {
			hasAura = false,
			missingAura = false,
			missingAuras = false,
			auras = {}
		},
		inRaid = false,
		notInRaid = false,
		inParty = false,
		notInParty = false,
		inMyGuild = false,
		notMyGuild = false,
		isOthersPet = false,
		notOthersPet = false,
		isTrivial = false,
		notTrivial = false,
		isUnconscious = false,
		isConscious = false,
		isPossessed = false,
		notPossessed = false,
		isCharmed = false,
		notCharmed = false,
		isDeadOrGhost = false,
		notDeadOrGhost = false,
		isBeingResurrected = false,
		notBeingResurrected = false,
		isConnected = false,
		notConnected = false,
		inPetBattle = false,
		notPetBattle = false,
		isResting = false,
		notResting = false,
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
	}
}
