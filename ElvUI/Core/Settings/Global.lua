local E, L, V, P, G = unpack(ElvUI)

--Global Settings
G.general = {
	UIScale = 0.64,
	locale = E:GetLocale(),
	eyefinity = false,
	ultrawide = false,
	smallerWorldMap = true,
	allowDistributor = false,
	smallerWorldMapScale = 0.9,
	fadeMapWhenMoving = true,
	mapAlphaWhenMoving = 0.2,
	fadeMapDuration = 0.2,
	WorldMapCoordinates = {
		enable = true,
		position = 'BOTTOMLEFT',
		xOffset = 0,
		yOffset = 0
	},
	AceGUI = {
		width = 1024,
		height = 768
	},
	disableTutorialButtons = true,
	commandBarSetting = 'ENABLED_RESIZEPARENT'
}

G.classtimer = {}

G.chat = {
	classColorMentionExcludedNames = {}
}

G.bags = {
	ignoredItems = {}
}

G.datatexts = {
	customPanels = {},
	customCurrencies = {},
	settings = {
		Agility = { Label = '', NoLabel = false },
		Armor = { Label = '', NoLabel = false },
		Avoidance = { Label = '', NoLabel = false, decimalLength = 1 },
		Bags = { textFormat = 'USED_TOTAL', Label = '', NoLabel = false },
		CallToArms = { Label = '', NoLabel = false },
		Combat = { TimeFull = true, NoLabel = false },
		Crit = { Label = '', NoLabel = false, decimalLength = 1 },
		Currencies = { goldFormat = 'BLIZZARD', goldCoins = true, displayedCurrency = 'BACKPACK', displayStyle = 'ICON', tooltipData = {}, idEnable = {}, headers = true, maxCurrency = false },
		Durability = { Label = '', NoLabel = false, percThreshold = 30 },
		ElvUI = { Label = '' },
		Experience = { textFormat = 'CUR' },
		Friends = {
			Label = '', NoLabel = false,
			--status
			hideAFK = false,
			hideDND = false,
			--clients
			hideWoW = false,
			hideD3 = false,
			hideVIPR = false,
			hideWTCG = false, --Hearthstone
			hideHero = false, --Heros of the Storm
			hidePro = false, --Overwatch
			hideS1 = false,
			hideS2 = false,
			hideBSAp = false, --Mobile
			hideApp = false, --Launcher
		},
		Gold = { goldFormat = 'BLIZZARD', goldCoins = true },
		Guild = { Label = '', NoLabel = false },
		Haste = { Label = '', NoLabel = false, decimalLength = 1 },
		Hit = { Label = '', NoLabel = false, decimalLength = 1 },
		Intellect = { Label = '', NoLabel = false},
		Mastery = { Label = '', NoLabel = false, decimalLength = 1 },
		MovementSpeed = { Label = '', NoLabel = false, decimalLength = 1 },
		QuickJoin = { Label = '', NoLabel = false },
		Reputation = { textFormat = 'CUR' },
		SpellPower = { school = 0 },
		Speed = { Label = '', NoLabel = false, decimalLength = 1 },
		Stamina = { Label = '', NoLabel = false },
		Strength = { Label = '', NoLabel = false },
		System = { NoLabel = false, ShowOthers = true, latency = 'WORLD' },
		Time = { time24 = _G.GetCurrentRegion() ~= 1, localTime = true, flashInvite = true },
		Versatility = { Label = '', NoLabel = false, decimalLength = 1 },
	},
	newPanelInfo = {
		growth = 'HORIZONTAL',
		width = 300,
		height = 22,
		frameStrata = 'LOW',
		numPoints = 3,
		frameLevel = 1,
		backdrop = true,
		panelTransparency = false,
		mouseover = false,
		border = true,
		textJustify = 'CENTER',
		visibility = '[petbattle] hide;show',
		tooltipAnchor = 'ANCHOR_TOPLEFT',
		tooltipXOffset = -17,
		tooltipYOffset = 4,
		fonts = {
			enable = false,
			font = 'PT Sans Narrow',
			fontSize = 12,
			fontOutline = 'OUTLINE',
		}
	},
}

G.nameplates = {}

G.unitframe = {
	aurafilters = {},
	aurawatch = {},
	raidDebuffIndicator = {
		instanceFilter = 'RaidDebuffs',
		otherFilter = 'CCDebuffs'
	},
	newCustomText = {
		text_format = '',
		size = 10,
		font = 'Homespun',
		fontOutline = 'MONOCHROMEOUTLINE',
		xOffset = 0,
		yOffset = 0,
		justifyH = 'CENTER',
		attachTextTo = 'Health'
	}
}

G.profileCopy = {
	--Specific values
	selected = 'Default',
	movers = {},
	--Modules
	actionbar = {
		general = true,
		bar1 = true,
		bar2 = true,
		bar3 = true,
		bar4 = true,
		bar5 = true,
		bar6 = true,
		barPet = true,
		stanceBar = true,
		microbar = true,
		extraActionButton = true,
		cooldown = true
	},
	auras = {
		general = true,
		buffs = true,
		debuffs = true,
		cooldown = true
	},
	bags = {
		general = true,
		split = true,
		vendorGrays = true,
		bagBar = true,
		cooldown = true
	},
	chat = {
		general = true
	},
	cooldown = {
		general = true,
		fonts = true
	},
	databars = {
		experience = true,
		reputation = true,
		honor = true,
		azerite = true
	},
	datatexts = {
		general = true,
		panels = true
	},
	general = {
		general = true,
		minimap = true,
		threat = true,
		totems = true,
		itemLevel = true,
		altPowerBar = true
	},
	nameplates = {
		general = true,
		cooldown = true,
		threat = true,
		units = {
			PLAYER = true,
			TARGET = true,
			FRIENDLY_PLAYER = true,
			ENEMY_PLAYER = true,
			FRIENDLY_NPC = true,
			ENEMY_NPC = true
		}
	},
	tooltip = {
		general = true,
		visibility = true,
		healthBar = true
	},
	unitframe = {
		general = true,
		cooldown = true,
		colors = {
			general = true,
			power = true,
			reaction = true,
			healPrediction = true,
			classResources = true,
			frameGlow = true,
			debuffHighlight = true
		},
		units = {
			player = true,
			target = true,
			targettarget = true,
			targettargettarget = true,
			focus = true,
			focustarget = true,
			pet = true,
			pettarget = true,
			boss = true,
			arena = true,
			party = true,
			raid1 = true,
			raid2 = true,
			raid3 = true,
			raidpet = true,
			tank = true,
			assist = true
		}
	}
}
