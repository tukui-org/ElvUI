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
		none = { r = 0.8, g = 0, b = 0 },
		Magic = { r = 0.2, g = 0.6, b = 1 },
		Curse = { r = 0.6, g = 0, b = 1 },
		Disease = { r = 0.6, g = 0.4, b = 0 },
		Poison = { r = 0, g = 0.6, b = 0 },

		-- These dont exist in Blizzards color table
		Bleed = { r = 1, g = 0.2, b = 0.6 },
		EnemyNPC = { r = 0.9, g = 0.1, b = 0.1 },
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
		showGems = true,
		itemLevelRarity = true,
		itemLevelFont = 'PT Sans Narrow',
		itemLevelFontSize = 12,
		itemLevelFontOutline = 'OUTLINE',
		totalLevelFont = 'PT Sans Narrow',
		totalLevelFontSize = E.Retail and 20 or 18,
		totalLevelFontOutline = 'OUTLINE',
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
		sortDirection = (E.Mists and 'DESCENDING') or 'ASCENDING',
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

P.databars = {
	transparent = true,
	statusbar = 'ElvUI Norm',
	customTexture = false,
	colors = {
		reputationAlpha = 1,
		useCustomFactionColors = false,
		petExperience = { r = 1, g = 1, b = .41, a = .8 },
		experience = { r = 0, g = .4, b = 1, a = .8 },
		rested = { r = 1, g = 0, b = 1, a = .4 },
		quest = { r = 0, g = 1, b = 0, a = .4 },
		honor = { r = .94, g = .45, b = .25, a = 1 },
		azerite = { r = .901, g = .8, b = .601, a = 1 },
		factionColors = {
			{ r = .8, g = .3, b = .22 },	-- 1
			{ r = .8, g = .3, b = .22 },	-- 2
			{ r = .75, g = .27, b = 0 },	-- 3
			{ r = .9, g = .7, b = 0 },		-- 4
			{ r = 0, g = .6, b = .1 },		-- 5
			{ r = 0, g = .6, b = .1 },		-- 6
			{ r = 0, g = .6, b = .1 },		-- 7
			{ r = 0, g = .6, b = .1 },		-- 8
			{ r = 0, g = .6, b = .1 },		-- 9 (Paragon)
			{ r = 0, g = 0.74, b = 0.95 },	-- 10 (Renown)
		}
	}
}

for _, databar in next, {'experience', 'reputation', 'honor', 'threat', 'azerite', 'petExperience'} do
	P.databars[databar] = {
		enable = true,
		width = 222,
		height = 10,
		textFormat = 'NONE',
		fontSize = 11,
		font = 'PT Sans Narrow',
		fontOutline = 'SHADOW',
		xOffset = 0,
		yOffset = 0,
		displayText = true,
		anchorPoint = 'CENTER',
		mouseover = false,
		clickThrough = false,
		hideInCombat = false,
		orientation = 'AUTOMATIC',
		reverseFill = false,
		showBubbles = false,
		frameStrata = 'LOW',
		frameLevel = 1
	}
end

P.databars.threat.hideInCombat = nil -- always on in code
P.databars.threat.tankStatus = true
P.databars.threat.smoothbars = true

P.databars.experience.hideAtMaxLevel = true
P.databars.experience.showLevel = false
P.databars.experience.width = 348
P.databars.experience.fontSize = 12
P.databars.experience.showQuestXP = true
P.databars.experience.questTrackedOnly = false
P.databars.experience.questCompletedOnly = false
P.databars.experience.questCurrentZoneOnly = false

P.databars.petExperience.hideAtMaxLevel = true

P.databars.reputation.enable = false
P.databars.reputation.hideBelowMaxLevel = false
P.databars.reputation.showReward = true
P.databars.reputation.rewardPosition = 'LEFT'

P.databars.honor.hideOutsidePvP = false
P.databars.honor.hideBelowMaxLevel = false

P.databars.azerite.hideAtMaxLevel = true

--Bags
P.bags = {
	sortInverted = true,
	bankCombined = false,
	warbandCombined = true,
	warbandSize = 32,
	bagSize = 34,
	bagButtonSpacing = 1,
	bankButtonSpacing = 1,
	warbandButtonSpacing = 1,
	bankSize = 34,
	bagWidth = 600,
	bankWidth = 800,
	warbandWidth = 800,
	currencyFormat = 'ICON_TEXT_ABBR',
	moneyFormat = 'SMART',
	moneyCoins = true,
	questIcon = true,
	junkIcon = false,
	junkDesaturate = false,
	scrapIcon = false,
	upgradeIcon = true,
	newItemGlow = true,
	ignoredItems = {},
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
	itemInfo = true,
	itemInfoFont = 'Homespun',
	itemInfoFontSize = 10,
	itemInfoFontOutline = 'MONOCHROMEOUTLINE',
	itemInfoColor = { r = 0, g = .75, b = .98 },
	countFont = 'Homespun',
	countFontSize = 10,
	countFontOutline = 'MONOCHROMEOUTLINE',
	countFontColor = {r = 1, g = 1, b = 1},
	countPosition = 'BOTTOMRIGHT',
	countxOffset = 0,
	countyOffset = 2,
	reverseLoot = false,
	reverseSlots = false,
	clearSearchOnClose = false,
	disableBagSort = false,
	disableBankSort = false,
	showAssignedColor = true,
	useBlizzardCleanup = false,
	useBlizzardCleanupBank = true,
	useBlizzardJunk = true,
	strata = 'HIGH',
	qualityColors = true,
	specialtyColors = true,
	showBindType = false,
	transparent = false,
	showAssignedIcon = true,
	colors = {
		profession = {
			reagent			= { r = 0.18, g = 0.75, b = 0.50 },
			ammoPouch		= { r = 1.00, g = 0.69, b = 0.41 },
			cooking			= { r = 0.74, g = 0.05, b = 0.21 },
			enchanting		= { r = 0.72, g = 0.22, b = 0.74 },
			engineering		= { r = 0.91, g = 0.46, b = 0.18 },
			fishing			= { r = 0.22, g = 0.46, b = 0.90 },
			gems			= { r = 0.03, g = 0.65, b = 0.75 },
			herbs			= { r = 0.28, g = 0.74, b = 0.07 },
			inscription		= { r = 0.32, g = 0.34, b = 0.98 },
			keyring			= { r = 0.67, g = 0.87, b = 0.37 },
			leatherworking	= { r = 0.74, g = 0.55, b = 0.20 },
			mining			= { r = 0.54, g = 0.40, b = 0.04 },
			quiver			= { r = 1.00, g = 0.69, b = 0.41 },
			soulBag			= { r = 1.00, g = 0.69, b = 0.41 },
		},
		assignment = {
			equipment		= { r = 0.00, g = 0.50, b = 0.47 },
			consumables		= { r = 0.45, g = 0.74, b = 0.52 },
			tradegoods		= { r = 0.74, g = 0.23, b = 0.49 },
			quest			= { r = 0.60, g = 0.20, b = 0.20 },
			junk			= { r = 0.26, g = 0.26, b = 0.26 },
		},
		items = {
			questStarter	= { r = 1.00, g = 0.96, b = 0.41 },
			questItem		= { r = 0.90, g = 0.30, b = 0.30 },
		}
	},
	vendorGrays = {
		enable = false,
		interval = 0.2,
		details = false,
		progressBar = true,
	},
	split = {
		bagSpacing = 5,
		bankSpacing = 5,
		warbandSpacing = 5,
		player = false,
		bank = false,
		warband = false,
		alwaysProfessionBags = false,
		alwaysProfessionBank = false,
	},
	shownBags = {},
	autoToggle = {
		enable = true,
		bank = true,
		mail = true,
		vendor = true,
		soulBind = true,
		auctionHouse = true,
		professions = false,
		guildBank = false,
		trade = false,
	},
	spinner = {
		enable = true,
		size = 48,
		color = { r = 1, g = 0.82, b = 0 }
	},
	bagBar = {
		growthDirection = 'VERTICAL',
		sortDirection = 'ASCENDING',
		size = 30,
		spacing = 4,
		backdropSpacing = 4,
		showBackdrop = false,
		mouseover = false,
		showCount = true,
		justBackpack = false,
		visibility = (E.Retail or E.Mists) and '[petbattle] hide; show' or 'show',
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 12,
	},
}

for i = -3, 12 do
	local name = 'bag'..i
	P.bags.shownBags[name] = true

	if i >= 1 then
		P.bags.split[name] = false
	end
end

for id = 6, 11 do
	P.bags.split['bank'..id] = false
end

for id = 12, 16 do
	P.bags.split['warband'..id] = false
end

local NP_AuraSourceText = {
	enable = false,
	class = true,
	xOffset = 0,
	yOffset = 0,
	length = 0, -- max 12, 0 is off
	position = 'TOP',
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 10,
}

local NP_Auras = {
	enable = true,
	desaturate = true,
	numAuras = 5,
	numRows = 1,
	size = 27,
	height = 23,
	attachTo = 'FRAME',
	keepSizeRatio = true,
	anchorPoint = 'TOPLEFT',
	growthX = 'RIGHT',
	growthY = 'UP',
	onlyShowPlayer = false,
	stackAuras = true,
	filter = 'HELPFUL',
	sortDirection = 'DESCENDING',
	sortMethod = 'TIME_REMAINING',
	spacing = 1,
	yOffset = 5,
	xOffset = 0,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 11,
	countPosition = 'BOTTOMRIGHT',
	countFont = 'PT Sans Narrow',
	countFontOutline = 'OUTLINE',
	countFontSize = 9,
	countXOffset = 0,
	countYOffset = 2,
	durationPosition = 'CENTER',
	minDuration = 0,
	maxDuration = 0,
	tooltipAnchorType = 'ANCHOR_BOTTOMRIGHT',
	tooltipAnchorX = 5,
	tooltipAnchorY = -5,
	sourceText = CopyTable(NP_AuraSourceText),
	priority = ''
}

local NP_Health = {
	enable = true,
	height = 10,
	healPrediction = true,
	useClassColor = true,
	smoothbars = false,
	text = {
		enable = true,
		format = '[health:percent]',
		position = 'CENTER',
		parent = 'Nameplate',
		xOffset = 0,
		yOffset = 0,
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 11,
	},
}

local NP_Power = {
	enable = false,
	smoothbars = false,
	useClassColor = false,
	hideWhenEmpty = false,
	costPrediction = true,
	width = 150,
	height = 8,
	xOffset = 0,
	yOffset = -10,
	anchorPoint = 'CENTER',
	displayAltPower = false,
	useAtlas = false,
	text = {
		enable = false,
		format = '[power:percent]',
		position = 'CENTER',
		parent = 'Nameplate',
		xOffset = 0,
		yOffset = -10,
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 11,
	},
}

local NP_PvPIcon = {
	enable = false,
	showBadge = true,
	position = 'RIGHT',
	size = 36,
	xOffset = 0,
	yOffset = 0,
}

local NP_PvPClassificationIndicator = {
	enable = false,
	position = 'TOPLEFT',
	size = 36,
	xOffset = 0,
	yOffset = 0,
}

local NP_Portrait = {
	enable = false,
	position = 'RIGHT',
	specicon = E.Retail,
	keepSizeRatio = true,
	height = 28,
	width = 28,
	xOffset = 3,
	yOffset = -5,
}

local NP_Name = {
	enable = true,
	format = '[classcolor][name]',
	position = 'TOPLEFT',
	parent = 'Nameplate',
	xOffset = 0,
	yOffset = -7,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 11,
}

local NP_Level = {
	enable = true,
	format = '[difficultycolor][level]',
	position = 'TOPRIGHT',
	parent = 'Nameplate',
	xOffset = 0,
	yOffset = -7,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 11,
}

local NP_RaidTargetIndicator = {
	enable = true,
	size = 24,
	position = 'LEFT',
	xOffset = -4,
	yOffset = 0,
}

local NP_Castbar = {
	enable = true,
	width = 150,
	height = 8,
	nameLength = 0,
	displayTarget = false,
	displayTargetClass = true,
	targetStyle = 'APPEND',
	targetAnchorPoint = 'CENTER',
	targetJustifyH = 'LEFT',
	targetXOffset = 0,
	targetYOffset = 0,
	targetFont = 'PT Sans Narrow',
	targetFontOutline = 'OUTLINE',
	targetFontSize = 11,
	hideSpellName = false,
	hideTime = false,
	smoothbars = false,
	spellRename = true,
	sourceInterrupt = true,
	sourceInterruptClassColor = true,
	castTimeFormat = 'CURRENT',
	channelTimeFormat = 'CURRENT',
	timeToHold = 0,
	anchorPoint = 'CENTER',
	textPosition = 'BELOW',
	iconPosition = 'RIGHT',
	iconSize = 30,
	iconOffsetX = 0,
	iconOffsetY = 0,
	showIcon = true,
	xOffset = 0,
	yOffset = -10,
	timeXOffset = 0,
	timeYOffset = 0,
	textYOffset = 0,
	textXOffset = 0,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 11,
}

local NP_Title = {
	enable = false,
	format = '[guild:brackets]',
	position = 'TOPRIGHT',
	parent = 'Nameplate',
	xOffset = 0,
	yOffset = -7,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 11,
}

local NP_EliteIcon = {
	enable = false,
	size = 20,
	position = 'RIGHT',
	xOffset = 15,
	yOffset = 0,
}

local NP_QuestIcon = {
	enable = true,
	hideIcon = false,
	position = 'RIGHT',
	size = 20,
	xOffset = 0,
	yOffset = 0,
	spacing = 5,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	textPosition = 'BOTTOMRIGHT',
	textXOffset = 2,
	textYOffset = 2,
	fontSize = 12
}

local NP_PrivateAuras = CopyTable(P.general.privateAuras)
NP_PrivateAuras.enable = false
NP_PrivateAuras.icon.size = 20
NP_PrivateAuras.parent.point = 'BOTTOM'
NP_PrivateAuras.duration.enable = false
NP_PrivateAuras.countdownNumbers = false

--NamePlate
P.nameplates = {
	clampToScreen = false,
	fadeIn = true,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 11,
	highlight = true,
	loadDistance = 41, -- TBC only
	lowHealthThreshold = 0.4,
	motionType = 'STACKED',
	nameColoredGlow = false,
	overlapH = 0.8,
	overlapV = 1.1,
	showEnemyCombat = 'DISABLED',
	showFriendlyCombat = 'DISABLED',
	statusbar = 'ElvUI Norm',
	thinBorders = true,
	clickThrough = {
		personal = false,
		friendly = false,
		enemy = false,
	},
	bossMods = {
		enable = true,
		anchorPoint = 'BOTTOM',
		growthX = 'RIGHT',
		growthY = 'DOWN',
		size = 34,
		height = 24,
		spacing = 1,
		yOffset = -5,
		xOffset = 0
	},
	plateSize = {
		personalWidth = 150,
		personalHeight = 30,
		friendlyWidth = 150,
		friendlyHeight = 30,
		enemyWidth = 150,
		enemyHeight = 30,
	},
	threat = {
		enable = true,
		beingTankedByPet = true,
		beingTankedByTank = true,
		goodScale = 1,
		badScale = 1,
		useThreatColor = true,
		indicator = false,
		useSoloColor = false,
	},
	filters = {
		ElvUI_Boss = {triggers = {enable = false}},
		ElvUI_Target = {triggers = {enable = false}},
		ElvUI_NonTarget = {triggers = {enable = true}},
	},
	widgets = {
		below = true,
		xOffset = 0,
		yOffset = -3
	},
	colors = {
		auraByType = true,
		auraByDispels = true,
		preferGlowColor = true,
		glowColor = {r = 1, g = 1, b = 1, a = 1},
		lowHealthColor = {r = 1, g = 1, b = 0.3, a = 1},
		lowHealthHalf = {r = 1, g = 0.3, b = 0.3, a = 1},
		castColor = {r = 1, g = 0.81, b = 0},
		tapped = {r = 0.6, g = 0.6, b = 0.6},
		castNoInterruptColor = {r = 0.78, g = 0.25, b = 0.25},
		castInterruptedColor = {r = 0.30, g = 0.30, b = 0.30},
		castbarDesaturate = true,
		chargingRunes = true,
		runeBySpec = true,
		reactions = {
			good = {r = .29, g = .68, b = .30},
			neutral = {r = .85, g = .77, b = .36},
			bad = {r = 0.78, g = 0.25, b = 0.25},
		},
		healPrediction = {
			personal = {r = 0, g = 1, b = 0.5, a = 0.25},
			others = {r = 0, g = 1, b = 0, a = 0.25},
			absorbs = {r = 1, g = 1, b = 0, a = 0.25},
			healAbsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			--overabsorbs = {r = 1, g = 1, b = 0, a = 0.25},
			--overhealabsorbs = {r = 1, g = 0, b = 0, a = 0.25},
		},
		threat = {
			goodColor = {r = 0.20, g = 0.86, b = 0.20},
			badColor = {r = 1.00, g = 0.20, b = 0.20},
			goodTransition = {r = 1.00, g = 0.86, b = 0.20},
			badTransition ={r = 1.00, g = 0.60, b = 0.20},
			offTankColor = {r = 0.80, g = 0.20, b = 0.80},
			offTankColorGoodTransition = {r = 0.20, g = 0.40, b = 0.80},
			offTankColorBadTransition = {r = 0.40, g = 0.20, b = 0.80},
			soloColor = {r = 0.20, g = 0.86, b = 0.60},
		},
		power = {
			ENERGY = {r = 1, g = 0.96, b = 0.41},
			FOCUS = {r = 1, g = 0.50, b = 0.25},
			FURY = {r = 0.788, g = 0.259, b = 0.992, atlas = '_DemonHunter-DemonicFuryBar'},
			INSANITY = {r = 0.4, g = 0, b = 0.8, atlas = '_Priest-InsanityBar'},
			LUNAR_POWER = {r = 0.3, g = 0.52, b = 0.9, atlas = '_Druid-LunarBar'},
			MAELSTROM = {r = 0, g = 0.5, b = 1, atlas = '_Shaman-MaelstromBar'},
			MANA = {r = 0.31, g = 0.45, b = 0.63},
			PAIN = {r = 1, g = 0.61, b = 0, atlas = '_DemonHunter-DemonicPainBar'},
			RAGE = {r = 0.78, g = 0.25, b = 0.25},
			RUNIC_POWER = {r = 0, g = 0.82, b = 1},
			ALT_POWER = {r = 0.2, g = 0.4, b = 0.8},
		},
		selection = {
			[ 0] = {r = 1.00, g = 0.18, b = 0.18}, -- HOSTILE
			[ 1] = {r = 1.00, g = 0.51, b = 0.20}, -- UNFRIENDLY
			[ 2] = {r = 1.00, g = 0.85, b = 0.20}, -- NEUTRAL
			[ 3] = {r = 0.20, g = 0.71, b = 0.00}, -- FRIENDLY
			[ 5] = {r = 0.40, g = 0.53, b = 1.00}, -- PLAYER_EXTENDED
			[ 6] = {r = 0.40, g = 0.20, b = 1.00}, -- PARTY
			[ 7] = {r = 0.73, g = 0.20, b = 1.00}, -- PARTY_PVP
			[ 8] = {r = 0.20, g = 1.00, b = 0.42}, -- FRIEND
			[ 9] = {r = 0.60, g = 0.60, b = 0.60}, -- DEAD
			[13] = {r = 0.10, g = 0.58, b = 0.28}, -- BATTLEGROUND_FRIENDLY_PVP
		},
		empoweredCast = {
			{r = 1.00, g = 0.26, b = 0.20, a = 0.3}, -- red
			{r = 1.00, g = 0.80, b = 0.26, a = 0.3}, -- orange
			{r = 1.00, g = 1.00, b = 0.26, a = 0.3}, -- yellow
			{r = 0.66, g = 1.00, b = 0.40, a = 0.3}, -- green
			{r = 0.36, g = 0.90, b = 0.80, a = 0.3}, -- turquoise
		},
		classResources = {
			chargedComboPoint = { r = 0.16, g = 0.64, b = 1.0 },
			comboPoints = {
				{r = 0.75, g = 0.31, b = 0.31},
				{r = 0.78, g = 0.56, b = 0.31},
				{r = 0.81, g = 0.81, b = 0.31},
				{r = 0.56, g = 0.78, b = 0.31},
				{r = 0.43, g = 0.76, b = 0.31},
				{r = 0.31, g = 0.75, b = 0.31},
				{r = 0.36, g = 0.81, b = 0.54},
			},
			DEATHKNIGHT = {
				[-1] = {r = 0.5, g = 0.5, b = 0.5},
				[0] = {r = 0.8, g = 0.1, b = 0.28},
				{r = 1, g = 0.25, b = 0.25},
				{r = 0.25, g = 1, b = 1},
				{r = 0.25, g = 1, b = 0.25},
				{r = 0.8, g = 0.4, b = 1}
			},
			PALADIN = {r = 0.89, g = 0.88, b = 0.06},
			MAGE = {
				FROST_ICICLES = {r = 0, g = 0.80, b = 1.00},
				ARCANE_CHARGES = {r = 0, g = 0.40, b = 1.00}
			},
			EVOKER = {
				{r = 0.10, g = 0.92, b = 1.00},
				{r = 0.17, g = 0.94, b = 0.84},
				{r = 0.24, g = 0.96, b = 0.69},
				{r = 0.31, g = 0.98, b = 0.53},
				{r = 0.34, g = 0.99, b = 0.45},
				{r = 0.38, g = 1.00, b = 0.38},
			},
			MONK = {
				{r = 0.71, g = 0.76, b = 0.32},
				{r = 0.58, g = 0.73, b = 0.36},
				{r = 0.49, g = 0.71, b = 0.39},
				{r = 0.39, g = 0.69, b = 0.42},
				{r = 0.27, g = 0.66, b = 0.46},
				{r = 0.14, g = 0.63, b = 0.50}
			},
			SHAMAN = {
				TOTEMS = {
					{r = .23, g = .45, b = .13}, -- earth
					{r = .58, g = .23, b = .10}, -- fire
					{r = .19, g = .48, b = .60}, -- water
					{r = .42, g = .18, b = .74}, -- air
				},
				MAELSTROM = {r = 0.35, g = 0.15, b = 1}
			},
			PRIEST = {r = 0.40, g = 0.00, b = 0.80}, -- shadow orbs
			WARLOCK = {
				SOUL_SHARDS = {r = 0.58, g = 0.51, b = 0.79},
				DEMONIC_FURY = {r = 0.788, g = 0.259, b = 0.992},
				BURNING_EMBERS = {
					{r = 1.00, g = 0.60, b = 0.20},
					{r = 1.00, g = 0.46, b = 0.20},
					{r = 1.00, g = 0.33, b = 0.20},
					{r = 1.00, g = 0.20, b = 0.20}
				},
			},
			DRUID = {
				{r = 0.30, g = 0.52, b = 0.90}, -- negative/lunar
				{r = 0.80, g = 0.82, b = 0.60}, -- positive/solar
			}
		},
	},
	visibility = {
		showAll = true,
		showOnlyNames = false,
		enemy = {
			guardians = false,
			minions = false,
			minus = true,
			pets = false,
			totems = false,
		},
		friendly = {
			guardians = false,
			minions = false,
			npcs = true,
			pets = false,
			totems = false,
		},
	},
	enviromentConditions = {
		enemyEnabled = false,
		enemy = {
			party = true,
			raid = true,
			arena = true,
			pvp = true,
			resting = true,
			world = true,
			scenario = true,
		},
		friendlyEnabled = false,
		friendly = {
			party = false,
			raid = false,
			arena = true,
			pvp = false,
			resting = true,
			world = true,
			scenario = true,
		},
		stackingEnabled = false,
		stackingNameplates = {
			party = true,
			raid = true,
			arena = true,
			pvp = true,
			resting = false,
			world = true,
			scenario = true,
		},
	},
	cutaway = {
		health = {
			enabled = false,
			fadeOutTime = 0.6,
			lengthBeforeFade = 0.3,
			forceBlankTexture = true,
		},
		power = {
			enabled = false,
			fadeOutTime = 0.6,
			lengthBeforeFade = 0.3,
			forceBlankTexture = true,
		},
	},
	units = {
		PLAYER = {
			useStaticPosition = false,
			clickthrough = false,
			classpower = {
				enable = true,
				classColor = false,
				height = 7,
				sortDirection = 'NONE',
				width = 130,
				xOffset = 0,
				yOffset = 10,
			},
			visibility = {
				alphaDelay = 1,
				hideDelay = 3,
				showAlways = false,
				showInCombat = true,
				showWithTarget = false,
			},
		},
		TARGET = {
			arrow = 'Arrow9',
			arrowScale = 0.8,
			arrowSpacing = 3,
			glowStyle = 'style2',
			classpower = {
				enable = false,
				classColor = false,
				height = 7,
				sortDirection = 'NONE',
				width = 125,
				xOffset = 0,
				yOffset = 30,
			},
		},
		FRIENDLY_PLAYER = {
			markHealers = true,
			markTanks = true,
		},
		ENEMY_PLAYER = {
			markHealers = true,
			markTanks = true,
		},
		FRIENDLY_NPC = {},
		ENEMY_NPC = {},
	},
}

for unit, data in next, P.nameplates.units do
	data.enable = unit ~= 'PLAYER'

	if unit ~= 'TARGET' then
		data.auras = CopyTable(NP_Auras)
		data.buffs = CopyTable(NP_Auras)
		data.debuffs = CopyTable(NP_Auras)
		data.castbar = CopyTable(NP_Castbar)
		data.health = CopyTable(NP_Health)
		data.level = CopyTable(NP_Level)
		data.name = CopyTable(NP_Name)
		data.portrait = CopyTable(NP_Portrait)
		data.power = CopyTable(NP_Power)
		data.pvpindicator = CopyTable(NP_PvPIcon)
		data.raidTargetIndicator = CopyTable(NP_RaidTargetIndicator)
		data.privateAuras = CopyTable(NP_PrivateAuras)
		data.title = CopyTable(NP_Title)

		local npcFriendly = unit == 'FRIENDLY_NPC'
		local npcEnemy = unit == 'ENEMY_NPC'

		data.nameOnly = npcFriendly
		data.smartAuraPosition = 'DISABLED'
		data.showTitle = true

		local useCCDebuffs = npcEnemy or (unit == 'ENEMY_PLAYER' or unit == 'FRIENDLY_PLAYER')
		data.auras.enable = useCCDebuffs -- enemy npc and players

		if useCCDebuffs then
			data.auras.priority = 'Blacklist,CCDebuffs'
			data.auras.anchorPoint = 'RIGHT'
			data.auras.filter = 'HARMFUL'
			data.auras.numAuras = 2
			data.auras.xOffset = 2
			data.auras.yOffset = 0
		end

		if npcFriendly or npcEnemy then -- npcs
			data.eliteIcon = CopyTable(NP_EliteIcon)
			data.questIcon = CopyTable(NP_QuestIcon)
		else
			data.pvpclassificationindicator = CopyTable(NP_PvPClassificationIndicator)
		end
	end
end

P.nameplates.units.PLAYER.buffs.maxDuration = 300
P.nameplates.units.PLAYER.buffs.priority = 'Blacklist,Whitelist,blockNoDuration,Personal,TurtleBuffs'
P.nameplates.units.PLAYER.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.PLAYER.debuffs.growthX = 'LEFT'
P.nameplates.units.PLAYER.debuffs.growthY = 'UP'
P.nameplates.units.PLAYER.debuffs.yOffset = 35
P.nameplates.units.PLAYER.debuffs.priority = 'Blacklist,Dispellable,blockNoDuration,CCDebuffs,RaidDebuffs'
P.nameplates.units.PLAYER.name.enable = false
P.nameplates.units.PLAYER.name.format = '[name]'
P.nameplates.units.PLAYER.level.enable = false
P.nameplates.units.PLAYER.power.enable = true
P.nameplates.units.PLAYER.castbar.yOffset = -20

P.nameplates.units.FRIENDLY_PLAYER.buffs.priority = 'Blacklist,Whitelist,blockNoDuration,Personal,TurtleBuffs'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.growthX = 'LEFT'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.growthY = 'UP'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.yOffset = 35
P.nameplates.units.FRIENDLY_PLAYER.debuffs.priority = 'Blacklist,Dispellable'

P.nameplates.units.ENEMY_PLAYER.buffs.priority = 'Blacklist,Whitelist,Dispellable,TurtleBuffs'
P.nameplates.units.ENEMY_PLAYER.buffs.maxDuration = 300
P.nameplates.units.ENEMY_PLAYER.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.ENEMY_PLAYER.debuffs.growthX = 'LEFT'
P.nameplates.units.ENEMY_PLAYER.debuffs.growthY = 'UP'
P.nameplates.units.ENEMY_PLAYER.debuffs.yOffset = 35
P.nameplates.units.ENEMY_PLAYER.debuffs.priority = 'Blacklist,blockNoDuration,Personal'
P.nameplates.units.ENEMY_PLAYER.name.format = '[classcolor][name:abbrev:long]'

P.nameplates.units.FRIENDLY_NPC.buffs.priority = 'Blacklist,Whitelist,blockNoDuration,Personal'
P.nameplates.units.FRIENDLY_NPC.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.FRIENDLY_NPC.debuffs.growthX = 'LEFT'
P.nameplates.units.FRIENDLY_NPC.debuffs.growthY = 'UP'
P.nameplates.units.FRIENDLY_NPC.debuffs.yOffset = 35
P.nameplates.units.FRIENDLY_NPC.debuffs.priority = 'Blacklist,Dispellable,blockNoDuration,CCDebuffs'
P.nameplates.units.FRIENDLY_NPC.level.format = '[difficultycolor][level][shortclassification]'
P.nameplates.units.FRIENDLY_NPC.title.format = '[npctitle]'

P.nameplates.units.ENEMY_NPC.buffs.priority = 'Blacklist,Whitelist,Dispellable,blockNoDuration,RaidBuffsElvUI'
P.nameplates.units.ENEMY_NPC.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.ENEMY_NPC.debuffs.growthX = 'LEFT'
P.nameplates.units.ENEMY_NPC.debuffs.growthY = 'UP'
P.nameplates.units.ENEMY_NPC.debuffs.yOffset = 35
P.nameplates.units.ENEMY_NPC.debuffs.priority = 'Blacklist,blockNoDuration,Personal'
P.nameplates.units.ENEMY_NPC.level.format = '[difficultycolor][level][shortclassification]'
P.nameplates.units.ENEMY_NPC.title.format = '[npctitle]'
P.nameplates.units.ENEMY_NPC.name.format = '[name]'

local TopAuras = {
	barColor = { r = 0, g = .8, b = 0 },
	barColorGradient = false,
	barSize = 2,
	barNoDuration = true,
	barPosition = 'BOTTOM',
	barShow = false,
	barSpacing = 2,
	barTexture = 'ElvUI Norm',
	countFont = 'Homespun',
	countFontOutline = 'MONOCHROMEOUTLINE',
	countFontSize = 10,
	countXOffset = 0,
	countYOffset = 0,
	timeFont = 'Homespun',
	timeFontOutline = 'MONOCHROMEOUTLINE',
	timeFontSize = 10,
	timeXOffset = 0,
	timeYOffset = 0,
	fadeThreshold = 6,
	growthDirection = 'LEFT_DOWN',
	horizontalSpacing = 6,
	maxWraps = 3,
	seperateOwn = 1,
	showDuration = true,
	size = 32,
	height = 32,
	keepSizeRatio = true,
	sortDir = '-',
	sortMethod = 'TIME',
	verticalSpacing = 16,
	wrapAfter = 12,
	smoothbars = false,
	tooltipAnchorType = 'ANCHOR_BOTTOMLEFT',
	tooltipAnchorX = -5,
	tooltipAnchorY = -5
}

--Auras
P.auras = {
	buffs = CopyTable(TopAuras),
	debuffs = CopyTable(TopAuras),
	colorEnchants = true,
	colorDebuffs = true,
}

P.auras.debuffs.maxWraps = 1

--Chat
P.chat = {
	url = true,
	panelSnapLeftID = nil, -- set by the snap code
	panelSnapRightID = nil, -- same deal
	panelSnapping = true,
	shortChannels = true,
	hyperlinkHover = true,
	throttleInterval = 45,
	scrollDownInterval = 15,
	fade = true,
	inactivityTimer = 100,
	font = 'PT Sans Narrow',
	fontOutline = 'SHADOW',
	fontSize = 10,
	sticky = true,
	emotionIcons = true,
	keywordSound = 'None',
	noAlertInCombat = false,
	flashClientIcon = true,
	recentAllyIcon = false,
	timerunningIcon = true,
	mentorshipIcon = true,
	chatHistory = true,
	lfgIcons = true,
	maxLines = 100,
	channelAlerts = {
		CHANNEL = {},
		GUILD = 'None',
		OFFICER = 'None',
		INSTANCE = 'None',
		PARTY = 'None',
		RAID = 'None',
		WHISPER = 'Whisper Alert',
	},
	showHistory = {
		WHISPER = true,
		GUILD = true,
		PARTY = true,
		RAID = true,
		INSTANCE = true,
		CHANNEL = true,
		SAY = true,
		YELL = true,
		EMOTE = true
	},
	historySize = 100,
	editboxHistorySize = 20,
	tabSelector = 'ARROW1',
	tabSelectedTextEnabled = true,
	tabSelectedTextColor = { r = 1, g = 1, b = 1 },
	tabSelectorColor = { r = .3, g = 1, b = .3 },
	timeStampFormat = 'NONE',
	timeStampLocalTime = false,
	keywords = 'ElvUI',
	separateSizes = false,
	panelWidth = 412,
	panelHeight = 180,
	panelWidthRight = 412,
	panelHeightRight = 180,
	panelBackdropNameLeft = '',
	panelBackdropNameRight = '',
	panelBackdrop = 'SHOWBOTH',
	panelTabBackdrop = false,
	panelTabTransparency = false,
	LeftChatDataPanelAnchor = 'BELOW_CHAT',
	RightChatDataPanelAnchor = 'BELOW_CHAT',
	editBoxPosition = 'BELOW_CHAT',
	fadeUndockedTabs = false,
	fadeTabsNoBackdrop = true,
	fadeChatToggles = true,
	hideChatToggles = false,
	hideCopyButton = false,
	useAltKey = false,
	classColorMentionsChat = true,
	enableCombatRepeat = true,
	numAllowedCombatRepeat = 5,
	useCustomTimeColor = true,
	customTimeColor = {r = 0.7, g = 0.7, b = 0.7},
	numScrollMessages = 3,
	autoClosePetBattleLog = true,
	socialQueueMessages = false,
	tabFont = 'PT Sans Narrow',
	tabFontSize = 12,
	tabFontOutline = 'SHADOW',
	copyChatLines = false,
	useBTagName = false,
	panelColor = {r = .06, g = .06, b = .06, a = 0.8},
	pinVoiceButtons = true,
	hideVoiceButtons = false,
	desaturateVoiceIcons = true,
	mouseoverVoicePanel = false,
	voicePanelAlpha = 0.25
}

--Datatexts
P.datatexts = {
	font = 'PT Sans Narrow',
	fontSize = 12,
	fontOutline = 'SHADOW',
	wordWrap = false,
	panels = {
		LeftChatDataPanel = {
			enable = true,
			battleground = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			E.Retail and 'Talent/Loot Specialization' or 'ElvUI',
			'Durability',
			E.Retail and 'Missions' or 'Mail'
		},
		RightChatDataPanel = {
			enable = true,
			battleground = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			'System',
			'Time',
			'Gold'
		},
		MinimapPanel = {
			enable = true,
			battleground = false,
			backdrop = true,
			border = true,
			panelTransparency = false,
			numPoints = 2,
			'Guild',
			'Friends'
		}
	},
	battlePanel = {
		LeftChatDataPanel = {
			'PvP: Kills',
			'PvP: Honorable Kills',
			'PvP: Deaths',
		},
		RightChatDataPanel = {
			'PvP: Damage Done',
			'PvP: Heals',
			'PvP: Honor Gained',
		},
		MinimapPanel = {}
	},
	noCombatClick = false,
	noCombatHover = false,
}

--Tooltip
P.tooltip = {
	xOffset = 0,
	yOffset = 18,
	showElvUIUsers = false,
	anchorToBags = 'TOPRIGHT',
	cursorAnchor = false,
	cursorAnchorType = 'ANCHOR_CURSOR',
	cursorAnchorX = 0,
	cursorAnchorY = 0,
	inspectDataEnable = true,
	mythicDataEnable = true,
	mythicBestRun = true,
	dungeonScore = true,
	dungeonScoreColor = true,
	alwaysShowRealm = false,
	targetInfo = true,
	playerTitles = true,
	guildRanks = true,
	itemQuality = false,
	includeReagents = true,
	includeWarband = true,
	modifierCount = true,
	showMount = true,
	modifierID = 'SHOW',
	role = true,
	gender = false,
	font = 'PT Sans Narrow',
	fontOutline = 'SHADOW',
	textFontSize = 12, -- is fontSize (has old name)
	headerFont = 'PT Sans Narrow',
	headerFontOutline = 'SHADOW',
	headerFontSize = 13,
	smallTextFontSize = 12,
	colorAlpha = 0.8,
	fadeOut = true,
	itemCount = {
		bags = true,
		bank = false,
		stack = false
	},
	visibility = {
		bags = 'SHOW',
		unitFrames = 'SHOW',
		actionbars = 'SHOW',
		combatOverride = 'SHOW',
	},
	healthBar = {
		text = true,
		height = 12,
		font = 'PT Sans Narrow',
		fontSize = 12,
		fontOutline = 'SHADOW',
		statusPosition = 'BOTTOM',
	},
	useCustomFactionColors = false,
	factionColors = {
		{r = 0.8, g = 0.3, b = 0.22},
		{r = 0.8, g = 0.3, b = 0.22},
		{r = 0.75, g = 0.27, b = 0},
		{r = 0.9, g = 0.7, b = 0},
		{r = 0, g = 0.6, b = 0.1},
		{r = 0, g = 0.6, b = 0.1},
		{r = 0, g = 0.6, b = 0.1},
		{r = 0, g = 0.6, b = 0.1},
	}
}

local UF_StrataAndLevel = {
	useCustomStrata = false,
	frameStrata = 'LOW',
	useCustomLevel = false,
	frameLevel = 1,
}

local UF_Auras = {
	anchorPoint = 'TOPLEFT',
	attachTo = 'FRAME',
	clickThrough = false,
	countPosition = 'BOTTOMRIGHT',
	countFont = 'PT Sans Narrow',
	countFontOutline = 'OUTLINE',
	countFontSize = 12,
	countXOffset = 0,
	countYOffset = 2,
	desaturate = true,
	stackAuras = true,
	growthX = 'RIGHT',
	growthY = 'UP',
	durationPosition = 'CENTER',
	enable = false,
	numrows = 1,
	perrow = 8,
	filter = 'HELPFUL',
	sortDirection = 'DESCENDING',
	sortMethod = 'TIME_REMAINING',
	xOffset = 0,
	yOffset = 0,
	minDuration = 0,
	maxDuration = 0,
	priority = '',
	sizeOverride = 0,
	keepSizeRatio = true,
	height = 30,
	spacing = 1,
	tooltipAnchorType = 'ANCHOR_BOTTOMRIGHT',
	tooltipAnchorX = 5,
	tooltipAnchorY = -5,
	strataAndLevel = CopyTable(UF_StrataAndLevel),
	sourceText = CopyTable(NP_AuraSourceText)
}

local UF_DebuffHighlight = {
	enable = true,
}

local UF_AuraBars = {
	enable = true,
	anchorPoint = 'ABOVE',
	attachTo = 'DEBUFFS',
	detachedWidth = 270,
	enemyAuraType = 'HARMFUL',
	friendlyAuraType = 'HELPFUL',
	height = 20,
	maxBars = 6,
	maxDuration = 0,
	minDuration = 0,
	sortDirection = 'DESCENDING',
	sortMethod = 'TIME_REMAINING',
	priority = '',
	spacing = 0,
	yOffset = 0,
	tooltipAnchorType = 'ANCHOR_BOTTOMRIGHT',
	tooltipAnchorX = 5,
	tooltipAnchorY = -5,
	clickThrough = false,
	reverseFill = false,
	abbrevName = false,
	smoothbars = false,
}

local UF_AuraWatch = {
	enable = false,
	petSpecific = E.Retail,
	profileSpecific = false,
	countFont = 'PT Sans Narrow',
	countFontOutline = 'OUTLINE',
	countFontSize = 12,
	size = 8
}

local UF_Castbar = {
	customColor = {
		enable = false,
		transparent = false,
		invertColors = false,
		useClassColor = false,
		useCustomBackdrop = false,
		useReactionColor = false,
		color = { r = .31, g = .31, b = .31 },
		colorNoInterrupt = { r = 0.78, g = 0.25, b = 0.25 },
		colorInterrupted = { r = 0.30, g = 0.30, b = 0.30 },
		colorBackdrop = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
	},
	customTextFont = {
		enable = false,
		font = 'PT Sans Narrow',
		fontSize = 12,
		fontStyle = 'OUTLINE'
	},
	customTimeFont = {
		enable = false,
		font = 'PT Sans Narrow',
		fontSize = 12,
		fontStyle = 'OUTLINE'
	},
	enable = true,
	format = 'REMAINING',
	height = 18,
	hideName = false,
	hideTime = false,
	icon = true,
	iconAttached = true,
	iconAttachedTo = 'Frame',
	iconPosition = 'LEFT',
	iconSize = 42,
	iconXOffset = -10,
	iconYOffset = 0,
	spellRename = true,
	insideInfoPanel = true,
	overlayOnFrame = 'None',
	displayTarget = false,
	displayTargetClass = true,
	nameLength = 0,
	smoothbars = false,
	reverse = false,
	spark = true,
	textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
	tickColor = {r = 0, g = 0, b = 0, a = 0.8},
	ticks = true,
	tickWidth = 1,
	timeToHold = 0,
	width = 270,
	xOffsetText = 4,
	xOffsetTime = -4,
	yOffsetText = 0,
	yOffsetTime = 0,
	strataAndLevel = CopyTable(UF_StrataAndLevel),
}

local UF_CombatIcon = {
	enable = true,
	defaultColor = true,
	color = {r = 1, g = 0.2, b = 0.2, a = 1},
	anchorPoint = 'CENTER',
	xOffset = 0,
	yOffset = 0,
	size = 20,
	texture = 'DEFAULT',
}

local UF_Cutaway = {
	health = {
		enabled = false,
		fadeOutTime = 0.6,
		forceBlankTexture = true,
		lengthBeforeFade = 0.3,
	},
	power = {
		enabled = false,
		fadeOutTime = 0.6,
		forceBlankTexture = true,
		lengthBeforeFade = 0.3,
	},
}

local UF_Health = {
	attachTextTo = 'Health',
	orientation = 'HORIZONTAL',
	position = 'RIGHT',
	reverseFill = false,
	smoothbars = false,
	text_format = '',
	xOffset = -2,
	yOffset = 0,
}

local UF_HealthPrediction = {
	enable = false,
	absorbStyle = 'OVERFLOW',
	anchorPoint = 'BOTTOM',
	height = -1
}

local UF_InfoPanel = {
	enable = false,
	transparent = false,
	height = 20
}

local UF_Fader = {
	casting = false,
	combat = false,
	delay = 0,
	enable = true,
	focus = false,
	health = false,
	hover = false,
	maxAlpha = 1,
	minAlpha = 0.35,
	playertarget = false,
	power = false,
	range = true,
	smooth = 0.33,
	unittarget = false,
	vehicle = false,
	dynamicflight = false,
	instanceDifficulties = {
		none = false,
		timewalking = false,
		dungeonNormal = false,
		dungeonHeroic = false,
		dungeonMythic = false,
		dungeonMythicKeystone = false,
		raidNormal = false,
		raidHeroic = false,
		raidMythic = false,
	}
}

local UF_Name = {
	attachTextTo = 'Health',
	position = 'CENTER',
	text_format = '',
	xOffset = 0,
	yOffset = 0,
}

local UF_PhaseIndicator = {
	anchorPoint = 'CENTER',
	enable = true,
	scale = 0.8,
	xOffset = 0,
	yOffset = 0,
}

local UF_PartyIndicator = {
	anchorPoint = 'TOPRIGHT',
	enable = true,
	scale = 1,
	xOffset = -5,
	yOffset = 10
}

local UF_Portrait = {
	enable = false,
	paused = false,
	fullOverlay = false,
	overlay = false,
	overlayAlpha = 0.5,
	camDistanceScale = 2,
	desaturation = 0,
	rotation = 0,
	style = '3D',
	width = 45,
	xOffset = 0,
	yOffset = 0,
}

local UF_Power = {
	attachTextTo = 'Health',
	autoHide = false,
	onlyHealer = false,
	notInCombat = false,
	detachedWidth = 250,
	detachFromFrame = false,
	enable = true,
	height = 10,
	hideonnpc = false,
	offset = 0,
	parent = 'FRAME',
	position = 'LEFT',
	powerPrediction = false,
	reverseFill = false,
	text_format = '',
	width = 'fill',
	xOffset = 2,
	yOffset = 0,
	smoothbars = false,
	displayAltPower = false,
	strataAndLevel = CopyTable(UF_StrataAndLevel),
	useAtlas = false,
}

local UF_PvPClassificationIndicator = {
	enable = true,
	position = 'CENTER',
	size = 36,
	xOffset = 0,
	yOffset = 0,
}

local UF_PVPIcon = {
	anchorPoint = 'CENTER',
	enable = false,
	scale = 1,
	xOffset = 0,
	yOffset = 0,
}

local UF_RaidRoles = {
	enable = true,
	combatHide = false,
	position = 'TOPLEFT',
	xOffset = 0,
	yOffset = 4,
	scale = 1,
}

local UF_Ressurect = {
	attachTo = 'CENTER',
	attachToObject = 'Frame',
	enable = true,
	size = 30,
	xOffset = 0,
	yOffset = 0,
}

local UF_RaidIcon = {
	attachTo = 'TOP',
	attachToObject = 'Frame',
	enable = true,
	size = 18,
	xOffset = 0,
	yOffset = 8,
}

local UF_RaidDebuffs = {
	enable = true,
	showDispellableDebuff = true,
	onlyMatchSpellID = true,
	fontSize = 10,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	size = 26,
	xOffset = 0,
	yOffset = 0,
	duration = {
		position = 'CENTER',
		xOffset = 0,
		yOffset = 0,
		color = {r = 1, g = 0.9, b = 0, a = 1}
	},
	stack = {
		position = 'BOTTOMRIGHT',
		xOffset = 0,
		yOffset = 2,
		color = {r = 1, g = 0.9, b = 0, a = 1}
	},
}

local UF_RoleIcon = {
	enable = true,
	position = 'BOTTOMRIGHT',
	attachTo = 'Health',
	xOffset = -1,
	yOffset = 1,
	size = 15,
	tank = true,
	healer = true,
	damager = true,
	combatHide = false,
}

local UF_ReadyCheckIcon = {
	enable = true,
	size = 12,
	attachTo = 'Health',
	position = 'BOTTOM',
	xOffset = 0,
	yOffset = 2,
}

local UF_SummonIcon = {
	enable = true,
	size = 30,
	attachTo = 'CENTER',
	attachToObject = 'Frame',
	xOffset = 0,
	yOffset = 0,
}

local UF_SubGroup = {
	enable = false,
	anchorPoint = 'RIGHT',
	xOffset = 1,
	yOffset = 0,
	width = 120,
	height = 28,
	threatStyle = 'GLOW',
	threatPrimary = true,
	colorOverride = 'USE_DEFAULT',
	disableMouseoverGlow = false,
	disableTargetGlow = true,
	disableFocusGlow = true,
	name = CopyTable(UF_Name),
	raidicon = CopyTable(UF_RaidIcon),
	buffIndicator = CopyTable(UF_AuraWatch),
	healPrediction = CopyTable(UF_HealthPrediction),
}

local UF_ClassBar = {
	enable = true,
	fill = 'fill',
	height = 10,
	autoHide = false,
	smoothbars = false,
	sortDirection = 'asc',
	altPowerColor = { r = 0.2, g = 0.4, b = 0.8 },
	altPowerTextFormat = E.Retail and '[altpower:current]' or '',
	detachFromFrame = false,
	detachedWidth = 250,
	parent = 'FRAME',
	verticalOrientation = false,
	orientation = 'HORIZONTAL',
	spacing = 5,
	strataAndLevel = CopyTable(UF_StrataAndLevel),
}

local UF_ClassAdditional = {
	width = 260,
	height = 12,
	autoHide = false,
	orientation = 'HORIZONTAL',
	frameStrata = 'LOW',
	frameLevel = 1,
}

local UF_PrivateAuras = CopyTable(P.general.privateAuras)
UF_PrivateAuras.enable = false
UF_PrivateAuras.icon.size = 24
UF_PrivateAuras.parent.point = 'BOTTOM'
UF_PrivateAuras.duration.enable = false

--UnitFrame
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
	colors = {
		borderColor = {r = 0, g = 0, b = 0}, -- updated in E.Initialize
		healthclass = false,
		healthBreak = {
			enabled = false,
			high = 0.7,
			low = 0.3,
			multiplier = 0,
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
		--healththreat = false,
		healthselection = false,
		forcehealthreaction = false,
		powerclass = false,
		--powerthreat = false,
		powerselection = false,
		colorhealthbyvalue = true,
		healthbackdropbyvalue = false,
		customhealthbackdrop = false,
		custompowerbackdrop = false,
		customcastbarbackdrop = false,
		customaurabarbackdrop = false,
		customclasspowerbackdrop = false,
		useDeadBackdrop = false,
		classbackdrop = false,
		healthMultiplier = 0,
		auraBarByType = true,
		auraByType = true,
		auraByDispels = true,
		auraBarTurtle = true,
		auraBarTurtleColor = {r = 0.56, g = 0.40, b = 0.62},
		transparentHealth = false,
		transparentPower = false,
		transparentCastbar = false,
		transparentAurabars = false,
		transparentClasspower = false,
		chargingRunes = true,
		runeBySpec = true,
		invertCastBar = false,
		invertAurabars = false,
		invertPower = false,
		invertClasspower = false,
		castColor = { r = .31, g = .31, b = .31 },
		castNoInterrupt = { r = 0.78, g = 0.25, b = 0.25 },
		castInterruptedColor = {r = 0.30, g = 0.30, b = 0.30},
		castClassColor = false,
		castReactionColor = false,
		health = { r = .31, g = .31, b = .31 },
		health_backdrop = { r = .8, g = .01, b = .01 },
		health_backdrop_dead = { r = .8, g = .01, b = .01 },
		castbar_backdrop = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
		classpower_backdrop = { r = 0.5, g = 0.5, b = 0.5 },
		aurabar_backdrop = { r = 0.5, g = 0.5, b = 0.5 },
		power_backdrop = { r = 0.5, g = 0.5, b = 0.5 },
		tapped = { r = 0.55, g = 0.57, b = 0.61},
		disconnected = { r = 0.84, g = 0.75, b = 0.65},
		auraBarBuff = { r = .31, g = .31, b = .31 },
		auraBarDebuff = {r = 0.8, g = 0.1, b = 0.1},
		power = {
			ENERGY = {r = 1, g = 0.96, b = 0.41},
			FOCUS = {r = 1, g = 0.50, b = 0.25},
			FURY = {r = 0.788, g = 0.259, b = 0.992, atlas = '_DemonHunter-DemonicFuryBar'},
			INSANITY = {r = 0.4, g = 0, b = 0.8, atlas = '_Priest-InsanityBar'},
			LUNAR_POWER = {r = 0.3, g = 0.52, b = 0.9, atlas = '_Druid-LunarBar'},
			MAELSTROM = {r = 0, g = 0.5, b = 1, atlas = '_Shaman-MaelstromBar'},
			MANA = {r = 0.31, g = 0.45, b = 0.63},
			PAIN = {r = 1, g = 0.61, b = 0, atlas = '_DemonHunter-DemonicPainBar'},
			RAGE = {r = 0.78, g = 0.25, b = 0.25},
			RUNIC_POWER = {r = 0, g = 0.82, b = 1},
			ALT_POWER = {r = 0.2, g = 0.4, b = 0.8},
		},
		happiness = {
			{r = .69, g = .31, b = .31},
			{r = .65, g = .63, b = .35},
			{r = .33, g = .59, b = .33},
		},
		reaction = {
			BAD = { r = 0.78, g = 0.25, b = 0.25 },
			NEUTRAL = { r = 0.85, g = 0.77, b = 0.36 },
			GOOD = { r = 0.29, g = 0.69, b = 0.30 },
		},
		threat = {
			[ 0] = {r = 0.5, g = 0.5, b = 0.5}, -- low
			[ 1] = {r = 1.0, g = 1.0, b = 0.5}, -- overnuking
			[ 2] = {r = 1.0, g = 0.5, b = 0.0}, -- losing threat
			[ 3] = {r = 1.0, g = 0.2, b = 0.2}, -- tanking securely
		},
		selection = {
			[ 0] = {r = 1.00, g = 0.18, b = 0.18}, -- HOSTILE
			[ 1] = {r = 1.00, g = 0.51, b = 0.20}, -- UNFRIENDLY
			[ 2] = {r = 1.00, g = 0.85, b = 0.20}, -- NEUTRAL
			[ 3] = {r = 0.20, g = 0.71, b = 0.00}, -- FRIENDLY
			[ 5] = {r = 0.40, g = 0.53, b = 1.00}, -- PLAYER_EXTENDED
			[ 6] = {r = 0.40, g = 0.20, b = 1.00}, -- PARTY
			[ 7] = {r = 0.73, g = 0.20, b = 1.00}, -- PARTY_PVP
			[ 8] = {r = 0.20, g = 1.00, b = 0.42}, -- FRIEND
			[ 9] = {r = 0.60, g = 0.60, b = 0.60}, -- DEAD
			[13] = {r = 0.10, g = 0.58, b = 0.28}, -- BATTLEGROUND_FRIENDLY_PVP
		},
		healPrediction = {
			personal = {r = 0, g = 1, b = 0.5, a = 0.25},
			others = {r = 0, g = 1, b = 0, a = 0.25},
			absorbs = {r = 1, g = 1, b = 0, a = 0.25},
			healAbsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			overabsorbs = {r = 1, g = 1, b = 0, a = 0.25},
			overhealabsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			maxOverflow = 0,
		},
		powerPrediction = {
			enable = false,
			additional = {r = 1, g = 0.2, b = 0.4, a = 1},
			color = {r = 1, g = 0.2, b = 0.2, a = 1},
		},
		frameGlow = {
			mainGlow = {
				enable = false,
				class = false,
				color = {r=1, g=1, b=1, a=1}
			},
			targetGlow = {
				enable = true,
				class = true,
				color = {r=1, g=1, b=1, a=1}
			},
			focusGlow = {
				enable = false,
				class = false,
				color = {r=1, g=1, b=1, a=1}
			},
			mouseoverGlow = {
				enable = true,
				class = false,
				texture = 'ElvUI Blank',
				color = {r=1, g=1, b=1, a=0.1}
			}
		},
		debuffHighlight = {
			Magic = {r = 0.2, g = 0.6, b = 1, a = 0.45},
			Curse = {r = 0.6, g = 0, b = 1, a = 0.45},
			Disease = {r = 0.6, g = 0.4, b = 0, a = 0.45},
			Poison = {r = 0, g = 0.6, b = 0, a = 0.45},
			Bleed = {r = 1, g = 0.2, b = 0.6, a = 0.45},
			blendMode = 'ADD',
		},
	},
	units = {
		player = {
			enable = true,
			orientation = 'LEFT',
			width = 270,
			height = 54,
			lowmana = 30,
			threatStyle = 'GLOW',
			threatPrimary = true,
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			pvp = {
				position = 'BOTTOM',
				text_format = '||cFFB04F4F[pvptimer][mouseover]||r',
				xOffset = 0,
				yOffset = 0,
			},
			RestIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 1, b = 1, a = 1},
				texture = 'DEFAULT',
				anchorPoint = 'TOPLEFT',
				xOffset = -3,
				yOffset = 6,
				size = 22,
				hideAtMaxLevel = false,
			},
			CombatIcon = CopyTable(UF_CombatIcon),
			classbar = CopyTable(UF_ClassBar),
			classAdditional = CopyTable(UF_ClassAdditional),
			stagger = {
				enable = true,
				width = 10,
			},
			aurabar = CopyTable(UF_AuraBars),
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			partyIndicator = CopyTable(UF_PartyIndicator),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			pvpIcon = CopyTable(UF_PVPIcon),
			raidicon = CopyTable(UF_RaidIcon),
			raidRoleIcons = CopyTable(UF_RaidRoles),
			resurrectIcon = CopyTable(UF_Ressurect),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
		target = {
			enable = true,
			width = 270,
			height = 54,
			orientation = 'RIGHT',
			threatStyle = 'GLOW',
			threatPrimary = true,
			threatPlayer = false,
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			middleClickFocus = true,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			CombatIcon = CopyTable(UF_CombatIcon),
			aurabar = CopyTable(UF_AuraBars),
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			phaseIndicator = CopyTable(UF_PhaseIndicator),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			pvpIcon = CopyTable(UF_PVPIcon),
			raidicon = CopyTable(UF_RaidIcon),
			raidRoleIcons = CopyTable(UF_RaidRoles),
			resurrectIcon = CopyTable(UF_Ressurect),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
		targettarget = {
			enable = true,
			threatStyle = 'NONE',
			threatPrimary = true,
			orientation = 'MIDDLE',
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			buffs = CopyTable(UF_Auras),
			cutaway = CopyTable(UF_Cutaway),
			customTexts = {},
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			health = CopyTable(UF_Health),
			healPrediction = CopyTable(UF_HealthPrediction),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
		},
		focus = {
			enable = true,
			threatStyle = 'GLOW',
			threatPrimary = true,
			threatPlayer = false,
			orientation = 'MIDDLE',
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			width = 190,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = true,
			aurabar = CopyTable(UF_AuraBars),
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			CombatIcon = CopyTable(UF_CombatIcon),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
		pet = {
			enable = true,
			orientation = 'MIDDLE',
			threatStyle = 'GLOW',
			threatPrimary = true,
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			aurabar = CopyTable(UF_AuraBars),
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
		boss = {
			enable = true,
			threatStyle = 'NONE',
			threatPrimary = true,
			growthDirection = 'DOWN',
			orientation = 'RIGHT',
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			middleClickFocus = false,
			width = 216,
			height = 46,
			spacing = 25,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
		arena = {
			enable = true,
			growthDirection = 'DOWN',
			orientation = 'RIGHT',
			smartAuraPosition = 'DISABLED',
			spacing = 25,
			width = 246,
			height = 47,
			pvpSpecIcon = true,
			colorOverride = 'USE_DEFAULT',
			middleClickFocus = false,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			pvpTrinket = {
				enable = true,
				position = 'RIGHT',
				size = 46,
				xOffset = 1,
				yOffset = 0,
			},
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			pvpclassificationindicator = CopyTable(UF_PvPClassificationIndicator),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			raidicon = CopyTable(UF_RaidIcon),
		},
		party = {
			enable = true,
			threatStyle = 'GLOW',
			threatPrimary = true,
			orientation = 'LEFT',
			visibility = '[@raid6,exists][@party1,noexists] hide;show',
			growthDirection = 'UP_RIGHT',
			horizontalSpacing = 0,
			verticalSpacing = 3,
			groupBy = 'INDEX',
			sortDir = 'ASC',
			sortMethod = 'INDEX',
			raidWideSorting = false,
			invertGroupingOrder = false,
			startFromCenter = false,
			showPlayer = true,
			colorOverride = 'USE_DEFAULT',
			width = 184,
			height = 54,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			classbar = CopyTable(UF_ClassBar),
			CombatIcon = CopyTable(UF_CombatIcon),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			petsGroup = CopyTable(UF_SubGroup),
			phaseIndicator = CopyTable(UF_PhaseIndicator),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			pvpclassificationindicator = CopyTable(UF_PvPClassificationIndicator),
			raidicon = CopyTable(UF_RaidIcon),
			raidRoleIcons = CopyTable(UF_RaidRoles),
			rdebuffs = CopyTable(UF_RaidDebuffs),
			readycheckIcon = CopyTable(UF_ReadyCheckIcon),
			resurrectIcon = CopyTable(UF_Ressurect),
			roleIcon = CopyTable(UF_RoleIcon),
			summonIcon = CopyTable(UF_SummonIcon),
			targetsGroup = CopyTable(UF_SubGroup),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
		tank = {
			enable = true,
			orientation = 'LEFT',
			threatStyle = 'GLOW',
			threatPrimary = true,
			colorOverride = 'USE_DEFAULT',
			middleClickFocus = false,
			width = 120,
			height = 28,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			verticalSpacing = 7,
			debuffHighlight = CopyTable(UF_DebuffHighlight),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			customTexts = {},
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			auras = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			name = CopyTable(UF_Name),
			raidicon = CopyTable(UF_RaidIcon),
			rdebuffs = CopyTable(UF_RaidDebuffs),
			targetsGroup = CopyTable(UF_SubGroup),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
			privateAuras = CopyTable(UF_PrivateAuras)
		},
	},
}

P.unitframe.colors.classResources = CopyTable(P.nameplates.colors.classResources)
P.unitframe.colors.empoweredCast = CopyTable(P.nameplates.colors.empoweredCast)

P.unitframe.units.player.aurabar.enemyAuraType = 'HARMFUL'
P.unitframe.units.player.aurabar.friendlyAuraType = 'HELPFUL'
P.unitframe.units.player.aurabar.maxDuration = 120
P.unitframe.units.player.aurabar.priority = 'Blacklist,blockNoDuration,Personal,RaidDebuffs'
P.unitframe.units.player.buffs.attachTo = 'DEBUFFS'
P.unitframe.units.player.buffs.priority = 'Blacklist,Whitelist,blockNoDuration,Personal,NonPersonal'
P.unitframe.units.player.debuffs.enable = true
P.unitframe.units.player.debuffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.player.castbar.latency = true

P.unitframe.units.player.fader.enable = false
P.unitframe.units.player.fader.casting = true
P.unitframe.units.player.fader.combat = true
P.unitframe.units.player.fader.focus = false
P.unitframe.units.player.fader.health = true
P.unitframe.units.player.fader.hover = true
P.unitframe.units.player.fader.unittarget = false
P.unitframe.units.player.fader.playertarget = true
P.unitframe.units.player.fader.power = true
P.unitframe.units.player.fader.range = nil
P.unitframe.units.player.fader.vehicle = true
P.unitframe.units.player.healPrediction.enable = true
P.unitframe.units.player.health.position = 'LEFT'
P.unitframe.units.player.health.text_format = '[healthcolor][health:current-percent:shortvalue]'
P.unitframe.units.player.health.xOffset = 2
P.unitframe.units.player.power.EnergyManaRegen = false
P.unitframe.units.player.power.position = 'RIGHT'
P.unitframe.units.player.power.text_format = (E.Retail and '[classpowercolor][classpower:current:shortvalue]' or '[cpoints]') .. '[powercolor][  >power:current:shortvalue]'
P.unitframe.units.player.power.xOffset = -2

P.unitframe.units.target.aurabar.maxDuration = 120
P.unitframe.units.target.aurabar.priority = 'Blacklist,blockNoDuration,Personal,RaidDebuffs'
P.unitframe.units.target.auras.enable = true
P.unitframe.units.target.auras.priority = 'Blacklist,CCDebuffs'
P.unitframe.units.target.auras.filter = 'HARMFUL'
P.unitframe.units.target.auras.xOffset = 2
P.unitframe.units.target.auras.anchorPoint = 'RIGHT'
P.unitframe.units.target.auras.sizeOverride = 48
P.unitframe.units.target.auras.perrow = 4
P.unitframe.units.target.auras.numRows = 1
P.unitframe.units.target.buffs.enable = true
P.unitframe.units.target.buffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.target.buffs.growthX = 'LEFT'
P.unitframe.units.target.buffs.growthY = 'UP'
P.unitframe.units.target.buffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.target.debuffs.enable = true
P.unitframe.units.target.debuffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.target.debuffs.growthX = 'LEFT'
P.unitframe.units.target.debuffs.growthY = 'UP'
P.unitframe.units.target.debuffs.attachTo = 'BUFFS'
P.unitframe.units.target.debuffs.maxDuration = 300
P.unitframe.units.target.debuffs.priority = 'Blacklist,Friendly:Dispellable,Personal'
P.unitframe.units.target.healPrediction.enable = true
P.unitframe.units.target.health.text_format = '[healthcolor][health:current-percent:shortvalue]'
P.unitframe.units.target.name.text_format = '[classcolor][name:medium] [difficultycolor][smartlevel] [shortclassification]'
P.unitframe.units.target.power.text_format = '[powercolor][power:current:shortvalue]'

P.unitframe.units.targettarget.buffs.anchorPoint = 'BOTTOMLEFT'
P.unitframe.units.targettarget.buffs.maxDuration = 300
P.unitframe.units.targettarget.buffs.numrows = 1
P.unitframe.units.targettarget.buffs.perrow = 7
P.unitframe.units.targettarget.buffs.priority = 'Blacklist,Personal,Dispellable'
P.unitframe.units.targettarget.debuffs.enable = true
P.unitframe.units.targettarget.debuffs.anchorPoint = 'BOTTOMRIGHT'
P.unitframe.units.targettarget.debuffs.growthX = 'LEFT'
P.unitframe.units.targettarget.debuffs.attachTo = 'BUFFS'
P.unitframe.units.targettarget.debuffs.maxDuration = 300
P.unitframe.units.targettarget.debuffs.numrows = 1
P.unitframe.units.targettarget.debuffs.perrow = 5
P.unitframe.units.targettarget.debuffs.priority = 'Blacklist,Friendly:Dispellable,Personal,CCDebuffs'
P.unitframe.units.targettarget.infoPanel.height = 14
P.unitframe.units.targettarget.name.text_format = '[classcolor][name:medium]'
P.unitframe.units.targettarget.power.text_format = ''

P.unitframe.units.targettargettarget = CopyTable(P.unitframe.units.targettarget)
P.unitframe.units.targettargettarget.enable = false
P.unitframe.units.targettargettarget.buffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.targettargettarget.debuffs.attachTo = 'FRAME'
P.unitframe.units.targettargettarget.debuffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.targettargettarget.infoPanel.height = 12

P.unitframe.units.focus.aurabar.enable = false
P.unitframe.units.focus.aurabar.detachedWidth = 190
P.unitframe.units.focus.aurabar.maxBars = 3
P.unitframe.units.focus.aurabar.maxDuration = 120
P.unitframe.units.focus.aurabar.priority = 'Blacklist,blockNoDuration,Personal,RaidDebuffs'
P.unitframe.units.focus.buffs.anchorPoint = 'BOTTOMLEFT'
P.unitframe.units.focus.buffs.maxDuration = 300
P.unitframe.units.focus.buffs.numrows = 1
P.unitframe.units.focus.buffs.perrow = 7
P.unitframe.units.focus.buffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.focus.castbar.width = 190
P.unitframe.units.focus.debuffs.enable = true
P.unitframe.units.focus.debuffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.focus.debuffs.growthX = 'LEFT'
P.unitframe.units.focus.debuffs.growthY = 'UP'
P.unitframe.units.focus.debuffs.maxDuration = 300
P.unitframe.units.focus.debuffs.numrows = 1
P.unitframe.units.focus.debuffs.perrow = 5
P.unitframe.units.focus.debuffs.priority = 'Blacklist,Friendly:Dispellable,Personal,CCDebuffs'
P.unitframe.units.focus.healPrediction.enable = true
P.unitframe.units.focus.infoPanel.height = 14
P.unitframe.units.focus.name.text_format = '[classcolor][name:medium]'

P.unitframe.units.focustarget = CopyTable(P.unitframe.units.focus)
P.unitframe.units.focustarget.enable = false
P.unitframe.units.focustarget.buffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.focustarget.debuffs.enable = false
P.unitframe.units.focustarget.debuffs.anchorPoint = 'BOTTOMRIGHT'
P.unitframe.units.focustarget.debuffs.growthX = 'LEFT'
P.unitframe.units.focustarget.debuffs.priority = 'Blacklist,Friendly:Dispellable,Personal,CCDebuffs'
P.unitframe.units.focustarget.height = 26
P.unitframe.units.focustarget.infoPanel.height = 12
P.unitframe.units.focustarget.threatStyle = 'NONE'
P.unitframe.units.focustarget.aurabar = nil
P.unitframe.units.focustarget.castbar = nil
P.unitframe.units.focustarget.privateAuras = nil
P.unitframe.units.focustarget.buffIndicator = nil
P.unitframe.units.focustarget.debuffHighlight = nil
P.unitframe.units.focustarget.CombatIcon = nil

P.unitframe.units.pet.aurabar.enable = false
P.unitframe.units.pet.aurabar.attachTo = 'FRAME'
P.unitframe.units.pet.aurabar.maxDuration = 120
P.unitframe.units.pet.aurabar.detachedWidth = 130
P.unitframe.units.pet.aurabar.yOffset = 2
P.unitframe.units.pet.aurabar.spacing = 2
P.unitframe.units.pet.buffs.anchorPoint = 'BOTTOMLEFT'
P.unitframe.units.pet.buffs.maxDuration = 300
P.unitframe.units.pet.buffs.numrows = 1
P.unitframe.units.pet.buffs.perrow = 7
P.unitframe.units.pet.buffs.priority = 'Blacklist,Whitelist,Personal'
P.unitframe.units.pet.debuffs.anchorPoint = 'BOTTOMRIGHT'
P.unitframe.units.pet.debuffs.growthX = 'LEFT'
P.unitframe.units.pet.debuffs.maxDuration = 300
P.unitframe.units.pet.debuffs.numrows = 1
P.unitframe.units.pet.debuffs.perrow = 5
P.unitframe.units.pet.debuffs.priority = 'Blacklist,Dispellable,CCDebuffs'
P.unitframe.units.pet.healPrediction.enable = true
P.unitframe.units.pet.health.colorHappiness = true
P.unitframe.units.pet.infoPanel.height = 12
P.unitframe.units.pet.name.text_format = '[classcolor][name:medium]'

P.unitframe.units.pettarget = CopyTable(P.unitframe.units.pet)
P.unitframe.units.pettarget.enable = false
P.unitframe.units.pettarget.buffs.maxDuration = 300
P.unitframe.units.pettarget.buffs.priority = 'Blacklist,Personal,NonPersonal'
P.unitframe.units.pettarget.debuffs.maxDuration = 300
P.unitframe.units.pettarget.debuffs.priority = 'Blacklist,Dispellable,RaidDebuffs'
P.unitframe.units.pettarget.height = 26
P.unitframe.units.pettarget.threatStyle = 'NONE'
P.unitframe.units.pettarget.aurabar = nil
P.unitframe.units.pettarget.castbar = nil
P.unitframe.units.pettarget.privateAuras = nil
P.unitframe.units.pettarget.buffIndicator = nil
P.unitframe.units.pettarget.debuffHighlight = nil

P.unitframe.units.boss.buffs.enable = true
P.unitframe.units.boss.buffs.anchorPoint = 'LEFT'
P.unitframe.units.boss.buffs.numrows = 1
P.unitframe.units.boss.buffs.perrow = 3
P.unitframe.units.boss.buffs.priority = 'Blacklist,Dispellable,RaidBuffsElvUI'
P.unitframe.units.boss.buffs.sizeOverride = 22
P.unitframe.units.boss.buffs.yOffset = 20
P.unitframe.units.boss.buffIndicator.enable = true
P.unitframe.units.boss.privateAuras.enable = true
P.unitframe.units.boss.privateAuras.countdownNumbers = false
P.unitframe.units.boss.privateAuras.icon.size = 20
P.unitframe.units.boss.privateAuras.parent.point = 'CENTER'
P.unitframe.units.boss.castbar.width = 215
P.unitframe.units.boss.castbar.positionsGroup = {anchorPoint = 'BOTTOM', xOffset = 0, yOffset = 0}
P.unitframe.units.boss.debuffs.enable = true
P.unitframe.units.boss.debuffs.anchorPoint = 'LEFT'
P.unitframe.units.boss.debuffs.numrows = 1
P.unitframe.units.boss.debuffs.perrow = 3
P.unitframe.units.boss.debuffs.priority = 'Blacklist,Personal,CCDebuffs'
P.unitframe.units.boss.debuffs.sizeOverride = 22
P.unitframe.units.boss.debuffs.yOffset = -3
P.unitframe.units.boss.health.text_format = '[healthcolor][health:current:shortvalue]'
P.unitframe.units.boss.health.position = 'LEFT'
P.unitframe.units.boss.health.xOffset = 2
P.unitframe.units.boss.infoPanel.height = 16
P.unitframe.units.boss.name.text_format = '[classcolor][name:medium]'
P.unitframe.units.boss.power.position = 'RIGHT'
P.unitframe.units.boss.power.text_format = '[powercolor][power:current:shortvalue]'
P.unitframe.units.boss.power.xOffset = -2

P.unitframe.units.arena.buffs.enable = true
P.unitframe.units.arena.buffs.anchorPoint = 'LEFT'
P.unitframe.units.arena.buffs.maxDuration = 300
P.unitframe.units.arena.buffs.numrows = 1
P.unitframe.units.arena.buffs.perrow = 3
P.unitframe.units.arena.buffs.priority = 'Blacklist,Whitelist,Dispellable,TurtleBuffs'
P.unitframe.units.arena.buffs.sizeOverride = 27
P.unitframe.units.arena.buffs.yOffset = 16
P.unitframe.units.arena.castbar.width = 256
P.unitframe.units.arena.castbar.positionsGroup = {anchorPoint = 'BOTTOM', xOffset = 0, yOffset = 0}
P.unitframe.units.arena.debuffs.enable = true
P.unitframe.units.arena.debuffs.anchorPoint = 'LEFT'
P.unitframe.units.arena.debuffs.maxDuration = 300
P.unitframe.units.arena.debuffs.numrows = 1
P.unitframe.units.arena.debuffs.perrow = 3
P.unitframe.units.arena.debuffs.priority = 'Blacklist,Personal,CCDebuffs'
P.unitframe.units.arena.debuffs.sizeOverride = 27
P.unitframe.units.arena.debuffs.yOffset = -16
P.unitframe.units.arena.debuffs.desaturate = false
P.unitframe.units.arena.healPrediction.enable = true
P.unitframe.units.arena.health.text_format = '[healthcolor][health:current:shortvalue]'
P.unitframe.units.arena.infoPanel.height = 17
P.unitframe.units.arena.name.text_format = '[classcolor][name:medium]'
P.unitframe.units.arena.power.text_format = '[powercolor][power:current:shortvalue]'
P.unitframe.units.arena.health.position = 'LEFT'
P.unitframe.units.arena.health.xOffset = 2
P.unitframe.units.arena.power.position = 'RIGHT'
P.unitframe.units.arena.power.xOffset = -2

P.unitframe.units.party.health.position = 'LEFT'
P.unitframe.units.party.health.xOffset = 2
P.unitframe.units.party.buffs.anchorPoint = 'LEFT'
P.unitframe.units.party.buffs.maxDuration = 300
P.unitframe.units.party.buffs.priority = 'Blacklist,TurtleBuffs'
P.unitframe.units.party.buffIndicator.enable = true
P.unitframe.units.party.privateAuras.enable = true
P.unitframe.units.party.privateAuras.countdownNumbers = false
P.unitframe.units.party.privateAuras.icon.size = 20
P.unitframe.units.party.privateAuras.parent.point = 'CENTER'
P.unitframe.units.party.castbar.enable = false
P.unitframe.units.party.castbar.width = 256
P.unitframe.units.party.castbar.positionsGroup = {anchorPoint = 'BOTTOM', xOffset = 0, yOffset = 0}
P.unitframe.units.party.CombatIcon.enable = false
P.unitframe.units.party.debuffs.enable = true
P.unitframe.units.party.debuffs.anchorPoint = 'RIGHT'
P.unitframe.units.party.debuffs.maxDuration = 300
P.unitframe.units.party.debuffs.priority = 'Blacklist,Dispellable,RaidDebuffs,CCDebuffs'
P.unitframe.units.party.debuffs.sizeOverride = 52
P.unitframe.units.party.debuffs.perrow = 5
P.unitframe.units.party.health.position = 'LEFT'
P.unitframe.units.party.health.xOffset = 2
P.unitframe.units.party.health.text_format = '[healthcolor][health:current-percent:shortvalue]'
P.unitframe.units.party.infoPanel.height = 15
P.unitframe.units.party.name.text_format = '[classcolor][name:medium] [difficultycolor][smartlevel]'
P.unitframe.units.party.petsGroup.name.text_format = '[classcolor][name:short]'
P.unitframe.units.party.power.height = 7
P.unitframe.units.party.power.position = 'RIGHT'
P.unitframe.units.party.power.text_format = '[powercolor][power:current:shortvalue]'
P.unitframe.units.party.power.xOffset = -2
P.unitframe.units.party.targetsGroup.name.text_format = '[classcolor][name:medium] [difficultycolor][smartlevel]'
P.unitframe.units.party.targetsGroup.enable = false
P.unitframe.units.party.targetsGroup.buffIndicator = nil
P.unitframe.units.party.targetsGroup.healPrediction = nil

P.unitframe.units.raid1 = CopyTable(P.unitframe.units.party)
P.unitframe.units.raid1.customName = ''
P.unitframe.units.raid1.groupsPerRowCol = 1
P.unitframe.units.raid1.groupBy = 'GROUP'
P.unitframe.units.raid1.buffs.numrows = 1
P.unitframe.units.raid1.buffs.perrow = 3
P.unitframe.units.raid1.buffIndicator.enable = true
P.unitframe.units.raid1.privateAuras.enable = true
P.unitframe.units.raid1.privateAuras.countdownNumbers = false
P.unitframe.units.raid1.privateAuras.icon.size = 18
P.unitframe.units.raid1.privateAuras.parent.point = 'CENTER'
P.unitframe.units.raid1.castbar = nil
P.unitframe.units.raid1.CombatIcon.enable = false
P.unitframe.units.raid1.debuffs.enable = false
P.unitframe.units.raid1.debuffs.numrows = 1
P.unitframe.units.raid1.debuffs.perrow = 3
P.unitframe.units.raid1.debuffs.priority = 'Blacklist,Dispellable,RaidDebuffs'
P.unitframe.units.raid1.debuffs.sizeOverride = 0
P.unitframe.units.raid1.growthDirection = 'RIGHT_DOWN'
P.unitframe.units.raid1.health.position = 'BOTTOM'
P.unitframe.units.raid1.health.text_format = '[healthcolor][health:deficit:shortvalue]'
P.unitframe.units.raid1.health.yOffset = 2
P.unitframe.units.raid1.height = 44
P.unitframe.units.raid1.horizontalSpacing = 3
P.unitframe.units.raid1.infoPanel.height = 12
P.unitframe.units.raid1.name.text_format = '[classcolor][name:short]'
P.unitframe.units.raid1.numGroups = 5
P.unitframe.units.raid1.orientation = 'MIDDLE'
P.unitframe.units.raid1.petsGroup = nil
P.unitframe.units.raid1.power.position = 'BOTTOMRIGHT'
P.unitframe.units.raid1.power.text_format = ''
P.unitframe.units.raid1.power.xOffset = -2
P.unitframe.units.raid1.power.yOffset = 2
P.unitframe.units.raid1.targetsGroup = nil
P.unitframe.units.raid1.visibility = E.Retail and '[@raid6,noexists][@raid21,exists] hide;show' or '[@raid6,noexists][@raid11,exists] hide;show'
P.unitframe.units.raid1.width = 80

P.unitframe.units.raid2 = CopyTable(P.unitframe.units.raid1)
P.unitframe.units.raid2.debuffs.anchorPoint = 'RIGHT'
P.unitframe.units.raid2.height = 27
P.unitframe.units.raid2.numGroups = 5
P.unitframe.units.raid2.visibility = E.Retail and '[@raid21,noexists][@raid31,exists] hide;show' or '[@raid11,noexists][@raid26,exists] hide;show'
P.unitframe.units.raid2.rdebuffs.enable = false
P.unitframe.units.raid2.power.enable = false
P.unitframe.units.raid2.roleIcon.enable = false

P.unitframe.units.raid3 = CopyTable(P.unitframe.units.raid2)
P.unitframe.units.raid3.numGroups = 8
P.unitframe.units.raid3.visibility = E.Retail and '[@raid31,noexists] hide;show' or '[@raid26,noexists] hide;show'

P.unitframe.units.raidpet = CopyTable(P.unitframe.units.raid1)
P.unitframe.units.raidpet.pvpclassificationindicator = nil
P.unitframe.units.raidpet.buffIndicator.enable = false
P.unitframe.units.raidpet.enable = false
P.unitframe.units.raidpet.raidWideSorting = true
P.unitframe.units.raidpet.buffs.numrows = 1
P.unitframe.units.raidpet.buffs.perrow = 3
P.unitframe.units.raidpet.buffs.priority = 'Blacklist,Whitelist'
P.unitframe.units.raidpet.debuffs.numrows = 1
P.unitframe.units.raidpet.debuffs.perrow = 3
P.unitframe.units.raidpet.debuffs.priority = 'Blacklist,Dispellable,RaidDebuffs'
P.unitframe.units.raidpet.growthDirection = 'DOWN_RIGHT'
P.unitframe.units.raidpet.height = 30
P.unitframe.units.raidpet.numGroups = 8
P.unitframe.units.raidpet.visibility = '[@raid1,exists] show; hide'

P.unitframe.units.tank.buffs.numrows = 1
P.unitframe.units.tank.buffs.perrow = 6
P.unitframe.units.tank.buffs.yOffset = 2
P.unitframe.units.tank.debuffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.tank.debuffs.growthX = 'LEFT'
P.unitframe.units.tank.debuffs.growthY = 'UP'
P.unitframe.units.tank.debuffs.numrows = 1
P.unitframe.units.tank.debuffs.perrow = 6
P.unitframe.units.tank.debuffs.yOffset = 1
P.unitframe.units.tank.name.position = 'CENTER'
P.unitframe.units.tank.name.text_format = '[classcolor][name:medium]'
P.unitframe.units.tank.name.xOffset = 0
P.unitframe.units.tank.privateAuras.enable = true
P.unitframe.units.tank.privateAuras.countdownNumbers = false
P.unitframe.units.tank.privateAuras.icon.size = 18
P.unitframe.units.tank.privateAuras.parent.point = 'CENTER'
P.unitframe.units.tank.targetsGroup.name.position = 'CENTER'
P.unitframe.units.tank.targetsGroup.name.text_format = '[classcolor][name:medium]'
P.unitframe.units.tank.targetsGroup.name.xOffset = 0
P.unitframe.units.tank.targetsGroup.enable = true
P.unitframe.units.tank.targetsGroup.buffIndicator = nil
P.unitframe.units.tank.targetsGroup.healPrediction = nil

P.unitframe.units.assist = CopyTable(P.unitframe.units.tank)

for i, classTag in next, {'DRUID', 'HUNTER', 'MAGE', 'PALADIN', 'PRIEST', 'ROGUE', 'SHAMAN', 'WARLOCK', 'WARRIOR', 'DEATHKNIGHT', 'MONK', 'DEMONHUNTER', 'EVOKER'} do
	P.unitframe.units.party['CLASS'..i] = classTag
	for k = 1, 3 do
		P.unitframe.units['raid'..k]['CLASS'..i] = classTag
	end
	P.unitframe.units.raidpet['CLASS'..i] = classTag
end

for i, role in next, {'TANK', 'HEALER', 'DAMAGER'} do
	P.unitframe.units.party['ROLE'..i] = role
	for k = 1, 3 do
		P.unitframe.units['raid'..k]['ROLE'..i] = role
	end
	P.unitframe.units.raidpet['ROLE'..i] = role
end

--Cooldown
P.cooldown = {
	threshold = 3,
	roundTime = true,
	targetAura = true,
	hideBlizzard = false,
	useIndicatorColor = false,
	showModRate = false,

	expiringColor = { r = 1, g = 0.2, b = 0.2 },
	secondsColor = { r = 1, g = 1, b = 0.2 },
	minutesColor = { r = 1, g = 1, b = 1 },
	hoursColor = { r = 0.4, g = 1, b = 1 },
	daysColor = { r = 0.4, g = 0.4, b = 1 },

	expireIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	secondsIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	minutesIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	hoursIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	daysIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	hhmmColorIndicator = { r = 1, g = 1, b = 1 },
	mmssColorIndicator = { r = 1, g = 1, b = 1 },

	checkSeconds = false,
	targetAuraDuration = 3600,
	modRateColor = { r = 0.6, g = 1, b = 0.4 },
	hhmmColor = { r = 0.43, g = 0.43, b = 0.43 },
	mmssColor = { r = 0.56, g = 0.56, b = 0.56 },
	hhmmThreshold = -1,
	mmssThreshold = -1,

	fonts = {
		enable = false,
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 18,
	},
}

--Actionbar
local ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS or 10
local STANCE_SLOTS = _G.NUM_STANCE_SLOTS or 10

P.actionbar = {
	chargeCooldown = false,
	colorSwipeLOC = { r = 0.25, g = 0, b = 0, a = 0.8 },
	colorSwipeNormal = { r = 0, g = 0, b = 0, a = 0.8 },
	hotkeyTextPosition = 'TOPRIGHT',
	macroTextPosition = 'TOPRIGHT',
	countTextPosition = 'BOTTOMRIGHT',
	countTextXOffset = 0,
	countTextYOffset = 2,
	desaturateOnCooldown = false,
	equippedItem = false,
	equippedItemColor = { r = 0.4, g = 1.0, b = 0.4 },
	targetReticleColor = { r = 0.2, g = 1.0, b = 0.2 },
	flashAnimation = false,
	flyoutSize = 32, -- match buttonsize default, blizz default is 28
	font = 'Homespun',
	fontColor = { r = 1, g = 1, b = 1 },
	fontOutline = 'MONOCHROMEOUTLINE',
	fontSize = 10,
	globalFadeAlpha = 0,
	handleOverlay = true,
	hideCooldownBling = false,
	lockActionBars = true,
	movementModifier = 'SHIFT',
	noPowerColor = { r = 0.5, g = 0.5, b = 1 },
	noRangeColor = { r = 0.8, g = 0.1, b = 0.1 },
	notUsableColor = { r = 0.4, g = 0.4, b = 0.4 },
	checkSelfCast = true,
	checkFocusCast = true,
	rightClickSelfCast = false,
	transparent = false,
	usableColor = { r = 1, g = 1, b = 1 },
	useDrawSwipeOnCharges = false,
	useRangeColorText = false,
	barPet = {
		enabled = true,
		mouseover = false,
		clickThrough = false,
		buttons = ACTION_SLOTS,
		buttonsPerRow = 1,
		point = 'TOPRIGHT',
		backdrop = true,
		heightMult = 1,
		widthMult = 1,
		keepSizeRatio = true,
		buttonSize = 32,
		buttonHeight = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		inheritGlobalFade = false,
	},
	stanceBar = {
		enabled = true,
		style = 'darkenInactive',
		mouseover = false,
		clickThrough = false,
		buttonsPerRow = STANCE_SLOTS,
		buttons = STANCE_SLOTS,
		point = 'TOPLEFT',
		backdrop = false,
		heightMult = 1,
		widthMult = 1,
		keepSizeRatio = true,
		buttonSize = 32,
		buttonHeight = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		inheritGlobalFade = false,
	},
	microbar = {
		enabled = false,
		mouseover = false,
		useIcons = true,
		buttonsPerRow = 12,
		buttonSize = 20,
		keepSizeRatio = false,
		point = 'TOPLEFT',
		buttonHeight = 28,
		buttonSpacing = 2,
		alpha = 1,
		visibility = (E.Retail or E.Mists) and '[petbattle] hide; show' or 'show',
		backdrop = false,
		backdropSpacing = 2,
		heightMult = 1,
		widthMult = 1,
		frameStrata = 'LOW',
		frameLevel = 1,
	},
	extraActionButton = {
		alpha = 1,
		scale = 1,
		clean = false,
		inheritGlobalFade = false,
	},
	zoneActionButton = {
		alpha = 1,
		scale = 1,
		clean = false,
		inheritGlobalFade = false,
	},
	vehicleExitButton = {
		enable = true,
		size = 32,
		level = 1,
		strata = 'MEDIUM',
	}
}

-- Visibility
if E.Retail or E.Mists then
	P.actionbar.barPet.visibility = '[petbattle] hide; [novehicleui,pet,nooverridebar,nopossessbar] show; hide'
	P.actionbar.stanceBar.visibility = '[vehicleui][petbattle] hide; show'
else
	P.actionbar.barPet.visibility = '[pet,nooverridebar] show; hide'
	P.actionbar.stanceBar.visibility = 'show'
end

local AB_Bar = {
	enabled = false,
	mouseover = false,
	clickThrough = false,
	keepSizeRatio = true,
	buttons = 12,
	buttonsPerRow = 12,
	point = 'BOTTOMLEFT',
	backdrop = false,
	heightMult = 1,
	widthMult = 1,
	buttonSize = 32,
	buttonHeight = 32,
	buttonSpacing = 2,
	backdropSpacing = 2,
	alpha = 1,
	inheritGlobalFade = false,
	showGrid = true,
	targetReticle = true,
	flyoutDirection = 'AUTOMATIC',
	paging = {},
	countColor = { r = 1, g = 1, b = 1 },
	countFont = 'Homespun',
	countFontOutline = 'MONOCHROMEOUTLINE',
	countFontSize = 10,
	countFontXOffset = 0,
	countFontYOffset = 2,
	counttext = true,
	countTextPosition = 'BOTTOMRIGHT',
	hotkeyColor = { r = 1, g = 1, b = 1 },
	hotkeyFont = 'Homespun',
	hotkeyFontOutline = 'MONOCHROMEOUTLINE',
	hotkeyFontSize = 10,
	hotkeytext = true,
	hotkeyTextPosition = 'TOPRIGHT',
	hotkeyTextXOffset = 0,
	hotkeyTextYOffset = -3,
	macroColor = { r = 1, g = 1, b = 1 },
	macrotext = false,
	macroFont = 'Homespun',
	macroFontOutline = 'MONOCHROMEOUTLINE',
	macroFontSize = 10,
	macroTextPosition = 'TOPRIGHT',
	macroTextXOffset = 0,
	macroTextYOffset = -3,
	useCountColor = false,
	useHotkeyColor = false,
	useMacroColor = false,
	frameStrata = 'LOW',
	frameLevel = 1,
	professionQuality = {
		enable = true,
		point = 'TOPLEFT',
		xOffset = 14,
		yOffset = -12,
		scale = 0.5,
		alpha = 1
	},
}

for i = 1, 15 do
	if i ~= 11 and i ~= 12 then
		local barN = 'bar'..i
		P.actionbar[barN] = CopyTable(AB_Bar)

		if E.Retail or E.Mists then
			P.actionbar[barN].visibility = '[vehicleui][petbattle][overridebar] hide; show'
		else
			P.actionbar[barN].visibility = '[overridebar] hide; show'
		end
	end
end

for _, bar in next, {'barPet', 'stanceBar', 'vehicleExitButton', 'extraActionButton', 'zoneActionButton'} do
	local db = P.actionbar[bar]
	db.frameStrata = 'LOW'
	db.frameLevel = 1

	if bar == 'barPet' then
		db.countColor = { r = 1, g = 1, b = 1 }
		db.countFont = 'Homespun'
		db.countFontOutline = 'MONOCHROMEOUTLINE'
		db.countFontSize = 10
		db.countFontXOffset = 0
		db.countFontYOffset = 2
		db.counttext = true
		db.countTextPosition = 'BOTTOMRIGHT'
		db.useCountColor = false
	end

	if bar ~= 'zoneActionButton' then
		db.hotkeyColor = { r = 1, g = 1, b = 1 }
		db.hotkeyFont = 'Homespun'
		db.hotkeyFontOutline = 'MONOCHROMEOUTLINE'
		db.hotkeyFontSize = 10
		db.hotkeytext = true
		db.hotkeyTextPosition = 'TOPRIGHT'
		db.hotkeyTextXOffset = 0
		db.hotkeyTextYOffset = -3
		db.useHotkeyColor = false
	end
end

P.actionbar.bar1.enabled = true
P.actionbar.bar1.visibility = (E.Retail or E.Mists) and '[petbattle] hide; show' or 'show'

P.actionbar.bar1.paging.ROGUE = '[bonusbar:1] 7;'..(E.Mists and ' [bonusbar:2] 8;' or '')
P.actionbar.bar1.paging.WARLOCK = E.Mists and '[form:1] 7;' or nil
P.actionbar.bar1.paging.DRUID = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10;'
P.actionbar.bar1.paging.EVOKER = '[bonusbar:1] 7;'
P.actionbar.bar1.paging.PRIEST = (E.Retail and '[form:1, spec:3] 7;') or (E.Classic and '[form:1] 7;') or '[bonusbar:1] 7;'
P.actionbar.bar1.paging.WARRIOR = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;'
if E.Mists then
	P.actionbar.bar1.paging.MONK = '[bonusbar:1] 7; [bonusbar:2] 8;'
end

P.actionbar.bar3.enabled = true
P.actionbar.bar3.buttons = 6
P.actionbar.bar3.buttonsPerRow = 6

P.actionbar.bar4.enabled = true
P.actionbar.bar4.buttonsPerRow = 1
P.actionbar.bar4.point = 'TOPRIGHT'
P.actionbar.bar4.backdrop = true

P.actionbar.bar5.enabled = true
P.actionbar.bar5.buttons = 6
P.actionbar.bar5.buttonsPerRow = 6

do -- cooldown stuff
	P.actionbar.cooldown = CopyTable(P.cooldown)
	P.actionbar.cooldown.expiringColor = { r = 1, g = 0.2, b = 0.2 }
	P.actionbar.cooldown.secondsColor = { r = 1, g = 1, b = 1 }
	P.actionbar.cooldown.hoursColor = { r = 1, g = 1, b = 1 }
	P.actionbar.cooldown.daysColor = { r = 1, g = 1, b = 1 }

	P.actionbar.cooldown.targetAuraColor = { r = 1, g = 0.6, b = 0.1 }
	P.actionbar.cooldown.expiringAuraColor = { r = 1, g = 0.4, b = 0.1 }

	P.actionbar.cooldown.targetAuraIndicator = { r = 0.6, g = 0.6, b = 0.6 }
	P.actionbar.cooldown.expiringAuraIndicator = { r = 0.6, g = 0.6, b = 0.6 }

	P.auras.cooldown = CopyTable(P.actionbar.cooldown)
	P.bags.cooldown = CopyTable(P.actionbar.cooldown)
	P.nameplates.cooldown = CopyTable(P.actionbar.cooldown)
	P.unitframe.cooldown = CopyTable(P.actionbar.cooldown)

	P.cdmanager = {} -- Blizzard's Cooldown Manager
	P.cdmanager.cooldown = CopyTable(P.actionbar.cooldown)

	P.WeakAuras = {} -- native cooldown support with our module
	P.WeakAuras.cooldown = CopyTable(P.actionbar.cooldown)

	-- color override
	P.WeakAuras.cooldown.override = false
	P.cdmanager.cooldown.override = false
	P.auras.cooldown.override = false
	P.bags.cooldown.override = false
	P.actionbar.cooldown.override = true
	P.nameplates.cooldown.override = true
	P.unitframe.cooldown.override = true

	-- auras doesn't have a reverse option
	P.actionbar.cooldown.reverse = false
	P.nameplates.cooldown.reverse = false
	P.unitframe.cooldown.reverse = false
	P.bags.cooldown.reverse = false

	-- auras don't have override font settings
	P.auras.cooldown.fonts = nil

	-- we gonna need this on by default :3
	P.cooldown.enable = true
end

-- This allows movers positions to be reset to whatever profile is being used
E.LayoutMoverPositions = {
	ALL = {
		AddonCompartmentMover = 'RIGHT,ElvUI_MinimapHolder,RIGHT,-5,10',
		AlertFrameMover = 'TOP,ElvUIParent,TOP,0,-20',
		AltPowerBarMover = 'TOP,ElvUIParent,TOP,0,-41',
		ArenaHeaderMover = 'BOTTOMRIGHT,ElvUIParent,RIGHT,-106,-166',
		AzeriteBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-246',
		BelowMinimapContainerMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274',
		BNETMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274',
		BossBannerMover = 'TOP,ElvUIParent,TOP,0,-126',
		BossButton = 'BOTTOM,ElvUIParent,BOTTOM,-150,301',
		BossHeaderMover = 'BOTTOMRIGHT,ElvUIParent,RIGHT,-106,-166',
		BuffsMover = 'TOPRIGHT,ElvUI_MinimapHolder,TOPLEFT,-7,0',
		DebuffsMover = 'BOTTOMRIGHT,ElvUI_MinimapHolder,BOTTOMLEFT,-7,0',
		DurabilityFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,141,-4',
		ElvAB_1 = 'BOTTOM,ElvUIParent,BOTTOM,-1,191',
		ElvAB_2 = 'BOTTOM,ElvUIParent,BOTTOM,0,4',
		ElvAB_3 = 'BOTTOM,ElvUIParent,BOTTOM,-1,139',
		ElvAB_4 = 'RIGHT,ElvUIParent,RIGHT,-4,0',
		ElvAB_6 = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,264',
		ElvUF_AssistMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-249',
		ElvUF_FocusCastbarMover = 'TOPLEFT,ElvUF_Focus,BOTTOMLEFT,0,-1',
		ElvUF_FocusMover = 'BOTTOM,ElvUIParent,BOTTOM,342,60',
		ElvUF_PartyMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		ElvUF_PetCastbarMover = 'TOPLEFT,ElvUF_Pet,BOTTOMLEFT,0,-1',
		ElvUF_PetMover = 'BOTTOM,ElvUIParent,BOTTOM,-342,101',
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,95',
		ElvUF_PlayerMover = 'BOTTOM,ElvUIParent,BOTTOM,-342,139',
		ElvUF_Raid1Mover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		ElvUF_Raid2Mover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		ElvUF_Raid3Mover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		ElvUF_TankMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-187',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,243',
		ElvUF_TargetMover = 'BOTTOM,ElvUIParent,BOTTOM,342,139',
		ElvUF_TargetTargetMover = 'BOTTOM,ElvUIParent,BOTTOM,342,101',
		ElvUIBagMover = 'BOTTOMRIGHT,RightChatPanel,BOTTOMRIGHT,0,26',
		ElvUIBankMover = 'BOTTOMLEFT,LeftChatPanel,BOTTOMLEFT,0,26',
		EventToastMover = 'TOP,ElvUIParent,TOP,0,-150',
		ExperienceBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,44',
		GMMover = 'TOPLEFT,ElvUIParent,TOPLEFT,251,-5',
		HonorBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-251',
		LeftChatMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,4',
		LootFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,419,-187',
		LossControlMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,507',
		MinimapMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-3',
		MirrorTimer1Mover = 'TOP,ElvUIParent,TOP,-1,-96',
		ObjectiveFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-163,-325',
		PetAB = 'RIGHT,ElvUIParent,RIGHT,-4,0',
		PowerBarContainerMover = 'TOP,ElvUIParent,TOP,0,-75',
		PrivateAurasMover = 'TOPRIGHT,ElvUI_MinimapHolder,BOTTOMLEFT,-10,-4',
		PrivateRaidWarningMover = 'TOP,RaidBossEmoteFrame,TOP,0,0',
		QueueStatusMover = 'BOTTOMRIGHT,ElvUI_MinimapHolder,BOTTOMRIGHT,-5,25',
		ReputationBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-243',
		RightChatMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4',
		ShiftAB = 'BOTTOM,ElvUIParent,BOTTOM,0,58',
		SocialMenuMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-187',
		ThreatBarMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4',
		TooltipMover = 'BOTTOMRIGHT,RightChatToggleButton,BOTTOMRIGHT,0,0',
		TopCenterContainerMover = 'TOP,ElvUIParent,TOP,0,-30',
		TotemTrackerMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,491,4',
		VehicleLeaveButton = 'BOTTOM,ElvUIParent,BOTTOM,0,301',
		VehicleSeatMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-4',
		VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,369,-210',
		ZoneAbility = 'BOTTOM,ElvUIParent,BOTTOM,150,301',
	},
	dpsCaster = {
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,243',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,97',
	},
	healer = {
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,243',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,97',
		ElvUF_Raid1Mover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,202,373',
		LootFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,250,-104',
		VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,250,-82'
	},
	anniversary = {
		AdditionalPowerMover = 'BOTTOM,ElvUIParent,BOTTOM,-136,229',
		AlertFrameMover = 'TOP,ElvUIParent,TOP,0,-95',
		AltPowerBarMover = 'TOP,ElvUIParent,TOP,0,-19',
		ArenaHeaderMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-365,-252',
		ArtifactBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,463,21',
		AutoButtonBar1Mover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-127,211',
		AutoButtonBar2Mover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-127,248',
		AutoButtonBar3Mover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-127,286',
		AutoButtonBar4Mover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-279,286',
		AutoButtonBar5Mover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-279,328',
		AzeriteBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,2,12',
		BNETMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,279',
		BagsMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,17',
		BelowMinimapContainerMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-43,17',
		BossButton = 'BOTTOM,ElvUIParent,BOTTOM,0,91',
		BossHeaderMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-365,-252',
		BuffsMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-4',
		ClassBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,80',
		DTPanelBottomMiddlePanelMover = 'BOTTOM,ElvUIParent,BOTTOM,0,0',
		DTPanelQuickJoinMover = 'BOTTOMLEFT,UIParent,BOTTOMLEFT,318,250',
		DTPanelCoordsMover = 'BOTTOMRIGHT,UIParent,BOTTOMRIGHT,-76,49',
		DebuffsMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-4',
		DigSiteProgressBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,315',
		DurabilityFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-167,-215',
		ElvAB_1 = 'BOTTOM,ElvUIParent,BOTTOM,0,44',
		ElvAB_2 = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-522,49',
		ElvAB_3 = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,433,47',
		ElvAB_4 = 'TOPLEFT,ElvUIParent,TOPLEFT,564,-334',
		ElvAB_5 = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-294',
		ElvAB_6 = 'BOTTOM,ElvUIParent,BOTTOM,-271,431',
		ElvUF_AssistMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-260',
		ElvUF_BodyGuardMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,444',
		ElvUF_FocusCastbarMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-572,357',
		ElvUF_FocusMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-572,369',
		ElvUF_FocusTargetMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-513,277',
		ElvUF_PartyMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,279',
		ElvUF_PetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-187,113',
		ElvUF_PetMover = 'BOTTOM,ElvUIParent,BOTTOM,-187,123',
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-136,176',
		ElvUF_PlayerMover = 'BOTTOM,ElvUIParent,BOTTOM,-136,187',
		ElvUF_Raid1Mover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,279',
		ElvUF_Raid2Mover = 'TOPLEFT,ElvUIParent,TOPLEFT,192,-295',
		ElvUF_Raid3Mover = 'TOPLEFT,ElvUIParent,TOPLEFT,129,-276',
		ElvUF_RaidpetMover = 'TOPLEFT,ElvUIParent,BOTTOMLEFT,0,808',
		ElvUF_TankMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-186',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,136,176',
		ElvUF_TargetMover = 'BOTTOM,ElvUIParent,BOTTOM,136,187',
		ElvUF_TargetTargetMover = 'BOTTOM,ElvUIParent,BOTTOM,187,123',
		ElvUIBagMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,49',
		ElvUIBankMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,47',
		EnhancedVehicleBar_Mover = 'BOTTOM,ElvUIParent,BOTTOM,0,245',
		EquipmentSetsBarMover = 'TOPLEFT,ElvUIParent,TOPLEFT,62,-522',
		ExperienceBarMover = 'TOP,ElvUIParent,TOP,0,-4',
		GMMover = 'TOP,ElvUIParent,TOP,-303,-4',
		HonorBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,4',
		LeftChatMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,47',
		LevelUpBossBannerMover = 'TOP,ElvUIParent,TOP,-1,-157',
		LocationLiteMover = 'TOP,ElvUIParent,TOP,0,-7',
		LocationMover = 'TOP,ElvUIParent,TOP,0,-7',
		LootFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,487,-312',
		LossControlMover = 'BOTTOM,ElvUIParent,BOTTOM,0,382',
		MawBuffsBelowMinimapMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-427,-8',
		MicroBarAnchor = 'TOP,ElvUIParent,TOP,1,-19',
		MicrobarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,18',
		MinimapClusterMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,254',
		MinimapMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,49',
		MirrorTimer1Mover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-310,-229',
		MirrorTimer2Mover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-310,-247',
		MirrorTimer3Mover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-310,-265',
		NotificationMover = 'TOP,ElvUIParent,TOP,0,-96',
		ObjectiveFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-79,-293',
		PetAB = 'BOTTOM,ElvUIParent,BOTTOM,0,17',
		PlayerNameplate = 'BOTTOM,ElvUIParent,BOTTOM,0,359',
		PlayerPortraitMover = 'BOTTOM,ElvUIParent,BOTTOM,-365,163',
		PlayerPowerBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,209',
		PowerBarContainerMover = 'TOP,ElvUIParent,TOP,0,-46',
		PrivateAurasMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-177',
		PrivateRaidWarningMover = 'TOP,ElvUIParent,TOP,0,-240',
		ProfessionsMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-184',
		PvPMover = 'TOP,ElvUIParent,TOP,0,-28',
		QueueStatusMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-201,49',
		RaidBuffReminderMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,353,16',
		RaidMarkerBarAnchor = 'BOTTOM,ElvUIParent,BOTTOM,0,57',
		ReputationBarMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4',
		RequestStopButton = 'TOP,ElvUIParent,TOP,0,-161',
		RightChatMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-233,26',
		SalvageCrateMover = 'TOPLEFT,ElvUIParent,TOPLEFT,2,-483',
		ShiftAB = 'BOTTOM,ElvUIParent,BOTTOM,0,17',
		SquareMinimapBar = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-185',
		SquareMinimapButtonBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-280',
		TalkingHeadFrameMover = 'TOP,ElvUIParent,TOP,0,-107',
		TargetPortraitMover = 'BOTTOM,ElvUIParent,BOTTOM,365,163',
		TargetPowerBarMover = 'BOTTOM,ElvUIParent,BOTTOM,231,215',
		ThreatBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,4',
		TooltipMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,255',
		TopCenterContainerMover = 'TOP,ElvUIParent,TOP,0,-72',
		TorghastChoiceToggle = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-419,4',
		TotemBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,560,31',
		TotemTrackerMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,534,4',
		UIErrorsFrameMover = 'TOP,ElvUIParent,TOP,0,-195',
		VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,487,-290',
		VehicleLeaveButton = 'BOTTOM,ElvUIParent,BOTTOM,0,145',
		VehicleSeatMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-587,23',
		WatchFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-122,-292',
		ZoneAbility = 'BOTTOM,ElvUIParent,BOTTOM,-323,139',
		tokenHolderMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-164'
	}
}
