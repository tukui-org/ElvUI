local E, L, V, P, G = unpack(ElvUI)

local CopyTable = CopyTable -- Our function doesn't exist yet.
local next = next

P.gridSize = 64
P.hideTutorial = true
P.dbConverted = nil -- use this to let DBConversions run once per profile

--Core
P.general = {
	messageRedirect = _G.DEFAULT_CHAT_FRAME:GetName(),
	smoothingAmount = 0.33, -- AMOUNT should match in general/smoothie file
	stickyFrames = true,
	loginmessage = true,
	interruptAnnounce = 'NONE',
	autoRepair = 'NONE',
	autoTrackReputation = false,
	autoAcceptInvite = false,
	hideErrorFrame = true,
	hideZoneText = false,
	enhancedPvpMessages = true,
	objectiveFrameHeight = 480,
	objectiveFrameAutoHide = true,
	objectiveFrameAutoHideInKeystone = false,
	bonusObjectivePosition = 'LEFT',
	talkingHeadFrameScale = 0.9,
	talkingHeadFrameBackdrop = false,
	vehicleSeatIndicatorSize = 128,
	resurrectSound = false,
	questRewardMostValueIcon = true,
	questXPPercent = true,
	durabilityScale = 1,
	gameMenuScale = 1,
	lockCameraDistanceMax = true,
	cameraDistanceMax = E.Retail and 2.6 or 4,
	afk = true,
	afkChat = true,
	afkSpin = true,
	afkAnimation = 'dance',
	cropIcon = 2,
	objectiveTracker = true,
	numberPrefixStyle = 'ENGLISH',
	tagUpdateRate = 0.2, -- eventTimerThreshold
	decimalLength = 1,
	fontSize = 12,
	font = 'PT Sans Narrow',
	fontStyle = 'OUTLINE',
	topPanel = false,
	bottomPanel = true,
	bottomPanelSettings = {
		transparent = true,
		height = 22,
		width = 0
	},
	topPanelSettings = {
		transparent = true,
		height = 22,
		width = 0
	},
	raidUtility = {
		modifier = 'SHIFT',
		modifierSwap = 'world',
		showTooltip = true
	},
	fonts = {
		cooldown = { enable = true, font = 'Expressway', size = 20, outline = 'SHADOWOUTLINE' },
		errortext = { enable = true, font = 'Expressway', size = 18, outline = 'SHADOW' },
		worldzone = { enable = false, font = 'Expressway', size = 26, outline = 'OUTLINE' },
		worldsubzone = { enable = false, font = 'Expressway', size = 24, outline = 'OUTLINE' },
		pvpzone = { enable = false, font = 'Expressway', size = 26, outline = 'OUTLINE' },
		pvpsubzone = { enable = false, font = 'Expressway', size = 24, outline = 'OUTLINE' },
		objective = { enable = false, font = 'Expressway', size = 14, outline = 'SHADOW' },
		mailbody = { enable = false, font = 'Expressway', size = 14, outline = 'SHADOW' },
		questtitle = { enable = false, font = 'Expressway', size = 18, outline = 'NONE' },
		questtext = { enable = false, font = 'Expressway', size = 14, outline = 'NONE' },
		questsmall = { enable = false, font = 'Expressway', size = 13, outline = 'NONE' },
		talkingtitle = { enable = false, font = 'Expressway', size = 20, outline = 'SHADOW' },
		talkingtext = { enable = false, font = 'Expressway', size = 18, outline = 'SHADOW' }
	},
	classColors = {
		HUNTER = { b = 0.44, g = 0.82, r = 0.66 },
		WARRIOR = { b = 0.42, g = 0.60, r = 0.77 },
		ROGUE = { b = 0.40, g = 0.95, r = 1 },
		MAGE = { b = 0.92, g = 0.78, r = 0.24 },
		PRIEST = { b = 1, g = 1, r = 1 },
		EVOKER = { b = 0.49, g = 0.57, r = 0.20 },
		SHAMAN = { b = 0.86, g = 0.43, r = 0 },
		WARLOCK = { b = 0.93, g = 0.53, r = 0.52 },
		DEMONHUNTER = { b = 0.78, g = 0.18, r = 0.63 },
		DEATHKNIGHT = { b = 0.22, g = 0.11, r = 0.76 },
		DRUID = { b = 0.03, g = 0.48, r = 1 },
		MONK = { b = 0.59, g = 1, r = 0 },
		PALADIN = { b = 0.72, g = 0.54, r = 0.95 }
	},
	debuffColors = { -- handle colors of LibDispel
		None = { r = 0.9, g = 0.2, b = 0.2 },
		Magic = { r = 0.2, g = 0.6, b = 1 },
		Curse = { r = 0.6, g = 0, b = 1 },
		Disease = { r = 0.6, g = 0.4, b = 0 },
		Poison = { r = 0, g = 0.6, b = 0 },
		Enrage = { r = 1, g = 0.5, b = 0 },

		-- These dont exist in Blizzards color table
		Bleed = { r = 1, g = 0.2, b = 0.6 },
		EnemyNPC = { r = 1, g = 0.85, b = 0.2 },
		BadDispel = { r = 0.05, g = 0.85, b = 0.94 },
		Stealable = { r = 0.93, g = 0.91, b = 0.55 },
	},
	bordercolor = { r = 0, g = 0, b = 0 }, -- updated in E.Initialize
	backdropcolor = { r = 0.1, g = 0.1, b = 0.1 },
	backdropfadecolor = { r = .06, g = .06, b = .06, a = 0.8 },
	valuecolor = { r = 0.09, g = 0.52, b = 0.82 },
	itemLevel = {
		displayCharacterInfo = true,
		displayInspectInfo = true,
		enchantAbbrev = true,
		showItemLevel = true,
		showEnchants = true,
		showOnItem = not E.Retail,
		showGems = true,
		itemLevelRarity = true,
		itemLevelFont = 'PT Sans Narrow',
		itemLevelFontSize = 12,
		itemLevelFontOutline = 'OUTLINE',
		totalLevelFont = 'PT Sans Narrow',
		totalLevelFontSize = E.Retail and 20 or 18,
		totalLevelFontOutline = 'OUTLINE',
		textPosition = 'BOTTOM',
		textOffsetX = 0,
		textOffsetY = 2
	},
	rotationAssist = {
		nextcast = { r = 0.20, g = 0.60, b = 0.95, a = 0.9 },
		alternative = { r = 0.40, g = 0.99, b = 0.20, a = 0.9 }
	},
	customGlow = {
		style = 'Pixel Glow',
		color = { r = 0.95, g = 0.95, b = 0, a = 0.9 },
		startAnimation = true,
		useColor = false,
		duration = 1,
		speed = 0.3,
		lines = 8,
		size = 1,
	},
	altPowerBar = {
		enable = true,
		width = 250,
		height = 20,
		font = 'PT Sans Narrow',
		fontSize = 12,
		fontOutline = 'OUTLINE',
		statusBar = 'ElvUI Norm',
		textFormat = 'NAMECURMAX',
		statusBarColorGradient = false,
		statusBarColor = { r = 0.2, g = 0.4, b = 0.8 },
		smoothbars = true,
	},
	minimap = {
		size = 175,
		scale = 1,
		circle = false,
		rotate = false,
		clusterDisable = true,
		clusterBackdrop = true,
		locationText = 'MOUSEOVER',
		locationFontSize = 14,
		locationFontOutline = 'OUTLINE',
		locationFont = 'Expressway',
		timeFontSize = 14,
		timeFontOutline = 'OUTLINE',
		timeFont = 'Expressway',
		resetZoom = {
			enable = false,
			time = 3,
		},
		icons = {
			classHall = {
				scale = 0.8,
				position = 'BOTTOMLEFT',
				xOffset = 0,
				yOffset = 0,
				hide = false,
			},
			tracking = {
				scale = E.Retail and 1.2 or 0.65,
				position = 'BOTTOMLEFT',
				xOffset = 3,
				yOffset = 3,
			},
			calendar = {
				scale = E.Retail and 1.2 or 1,
				position = 'TOPRIGHT',
				xOffset = 0,
				yOffset = 0,
				hide = true,
			},
			crafting = {
				scale = 1,
				position = 'TOPRIGHT',
				xOffset = -23,
				yOffset = -3,
			},
			mail = {
				scale = 1,
				texture = 'Mail3',
				position = 'TOPRIGHT',
				xOffset = 3,
				yOffset = 4,
			},
			battlefield = {
				scale = 1.1,
				position = 'BOTTOMRIGHT',
				xOffset = 4,
				yOffset = -4,
			},
			difficulty = {
				scale = 1,
				position = 'TOPLEFT',
				xOffset = 10,
				yOffset = 1,
			}
		}
	},
	lootRoll = {
		width = 325,
		height = 30,
		spacing = 4,
		maxBars = 5,
		buttonSize = 20,
		leftButtons = false,
		qualityName = false,
		qualityItemLevel = false,
		qualityStatusBar = true,
		qualityStatusBarBackdrop = true,
		statusBarColor = { r = 0, g = .4, b = 1 },
		statusBarTexture = 'ElvUI Norm',
		style = 'halfbar',
		nameFont = 'Expressway',
		nameFontSize = 12,
		nameFontOutline = 'OUTLINE',
	},
	totems = { -- totem tracker
		growthDirection = 'VERTICAL',
		sortDirection = (E.Wrath or E.Mists) and 'DESCENDING' or 'ASCENDING',
		size = 40,
		height = 40,
		spacing = 4,
		keepSizeRatio = true,
	},
	addonCompartment = {
		size = 18,
		hide = false,
		font = 'Expressway',
		fontSize = 13,
		fontOutline = 'SHADOW',
		frameStrata = 'MEDIUM',
		frameLevel = 20
	},
	privateRaidWarning = {
		scale = 1,
	},
	privateAuras = {
		enable = true,
		countdownFrame = true,
		countdownNumbers = true,
		icon = {
			offset = 3,
			point = 'LEFT',
			amount = 2,
			size = 32
		},
		duration = {
			enable = true,
			point = 'BOTTOM',
			offsetX = 0,
			offsetY = -1
		},
		parent = {
			point = 'TOP',
			offsetX = 0,
			offsetY = 0
		}
	},
	queueStatus = {
		enable = true,
		scale = 0.5,
		position = 'BOTTOMRIGHT',
		xOffset = -2,
		yOffset = 2,
		font = 'Expressway',
		fontSize = 11,
		fontOutline = 'OUTLINE',
		frameStrata = 'MEDIUM',
		frameLevel = 20
	},
	guildBank = {
		itemQuality = true,
		itemLevel = true,
		itemLevelThreshold = 1,
		itemLevelFont = 'Homespun',
		itemLevelFontSize = 10,
		itemLevelFontOutline = 'MONOCHROMEOUTLINE',
		itemLevelCustomColorEnable = false,
		itemLevelCustomColor = { r = 1, g = 1, b = 1 },
		itemLevelPosition = 'BOTTOMRIGHT',
		itemLevelxOffset = 0,
		itemLevelyOffset = 2,
		countFont = 'Homespun',
		countFontSize = 10,
		countFontOutline = 'MONOCHROMEOUTLINE',
		countFontColor = { r = 1, g = 1, b = 1 },
		countPosition = 'BOTTOMRIGHT',
		countxOffset = 0,
		countyOffset = 2,
	},
	cooldownManager = {
		swipeColorSpell = { r = 0, g = 0, b = 0, a = 0.6 },
		swipeColorAura = { r = 0, g = 1, b = 0.9, a = 0.6 },
		nameFont = 'Expressway',
		nameFontSize = 14,
		nameFontOutline = 'OUTLINE',
		nameFontColor = { r = 1, g = 1, b = 1 },
		namePosition = 'LEFT',
		namexOffset = 4,
		nameyOffset = 0,
		durationFont = 'Expressway',
		durationFontSize = 14,
		durationFontOutline = 'OUTLINE',
		durationFontColor = { r = 1, g = 1, b = 1 },
		durationPosition = 'RIGHT',
		durationxOffset = -3,
		durationyOffset = 0,
		countFont = 'Expressway',
		countFontSize = 11,
		countFontOutline = 'OUTLINE',
		countFontColor = { r = 1, g = 1, b = 1 },
		countPosition = 'BOTTOMRIGHT',
		countxOffset = 0,
		countyOffset = 0,
	}
}

-- NOTE: Remaining P.databars, P.bags, P.chat, etc. sections continue as normal...
-- The key addition is in P.unitframe below

P.unitframe = {
	statusbar = 'ElvUI Norm',
	font = 'Homespun',
	fontSize = 10,
	fontOutline = 'MONOCHROMEOUTLINE',
	debuffHighlighting = 'FILL',
	targetOnMouseDown = false,
	maxAllowedGroups = true,
	modifiers = {
		SHIFT = 'NONE',
		CTRL = 'NONE',
		ALT = 'NONE',
	},
	altManaPowers = {
		DRUID = { Energy = true, Rage = true, LunarPower = true },
		MONK = { Energy = true, Stagger = true }
	},
	thinBorders = true,
	targetSound = false,

	-- MIDNIGHT API CONFIG
	midnight = {
		hideSecretAuras = true,
		showDurationBars = false, -- false = presence-only mode
		maxAuraChecks = 100,
	},

	colors = {
		borderColor = {r = 0, g = 0, b = 0}, -- updated in E.Initialize
		healthclass = false,
		healthBreak = {
			enabled = false,
			high = 0.7,
			low = 0.3,
			onlyFriendly = false,
			colorBackdrop = false,
			good = {r = 0.2, g = 0.8, b = 0.2},
			neutral = {r = 0.85, g = 0.85, b = 0.15},
			bad = {r = 0.8, g = 0.2, b = 0.2},
			threshold = {
				bad = true,
				neutral = true,
				good = true
			},
		},
	},
}

P.actionbar = {
	-- MIDNIGHT API CONFIG
	midnight = {
		enableSafeGlow = true,
		skipSecretBuffs = true,
		maxBuffChecks = 100,
	},
}