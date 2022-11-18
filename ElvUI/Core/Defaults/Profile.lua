local E, L, V, P, G = unpack(ElvUI)

local CopyTable = CopyTable -- Our function doesn't exist yet.
local next = next

P.gridSize = 64
P.layoutSetting = 'tank'
P.hideTutorial = true
P.dbConverted = nil -- use this to let DBConversions run once per profile

--Core
P.general = {
	messageRedirect = _G.DEFAULT_CHAT_FRAME:GetName(),
	smoothingAmount = 0.33,
	taintLog = false,
	stickyFrames = true,
	loginmessage = true,
	interruptAnnounce = 'NONE',
	autoRepair = 'NONE',
	autoTrackReputation = false,
	autoAcceptInvite = false,
	topPanel = false,
	customGlow = {
		style = 'Pixel Glow',
		color = { r = 0.09, g = 0.52, b = 0.82, a = 0.9 },
		useColor = false,
		speed = 0.3,
		lines = 8,
		size = 1,
	},
	topPanelSettings = {
		transparent = true,
		height = 22,
		width = 0
	},
	bottomPanel = true,
	bottomPanelSettings = {
		transparent = true,
		height = 22,
		width = 0
	},
	hideErrorFrame = true,
	hideZoneText = false,
	enhancedPvpMessages = true,
	objectiveFrameHeight = 480,
	objectiveFrameAutoHide = true,
	objectiveFrameAutoHideInKeystone = false,
	bonusObjectivePosition = 'LEFT',
	torghastBuffsPosition = 'LEFT',
	talkingHeadFrameScale = 0.9,
	talkingHeadFrameBackdrop = false,
	vehicleSeatIndicatorSize = 128,
	resurrectSound = false,
	questRewardMostValueIcon = true,
	questXPPercent = true,
	itemLevel = {
		displayCharacterInfo = true,
		displayInspectInfo = true,
		itemLevelFont = 'PT Sans Narrow',
		itemLevelFontSize = 12,
		itemLevelFontOutline = 'OUTLINE',
	},
	durabilityScale = 1,
	lockCameraDistanceMax = true,
	cameraDistanceMax = E.Retail and 2.6 or 4,
	afk = true,
	afkChat = true,
	numberPrefixStyle = 'ENGLISH',
	decimalLength = 1,
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
		smoothbars = false,
	},
	fontSize = 12,
	font = 'PT Sans Narrow',
	fontStyle = 'OUTLINE',
	bordercolor = { r = 0, g = 0, b = 0 }, -- updated in E.Initialize
	backdropcolor = { r = 0.1, g = 0.1, b = 0.1 },
	backdropfadecolor = { r = .06, g = .06, b = .06, a = 0.8 },
	valuecolor = { r = 0.09, g = 0.52, b = 0.82 },
	cropIcon = 2,
	minimap = {
		size = 175,
		scale = 1,
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
			mail = {
				scale = 1,
				texture = 'Mail3',
				position = 'TOPRIGHT',
				xOffset = 3,
				yOffset = 4,
			},
			lfgEye = {
				scale = E.Retail and 0.6 or 1,
				position = 'BOTTOMRIGHT',
				xOffset = 3,
				yOffset = -3
			},
			queueStatus = {
				enable = true,
				position = 'BOTTOMRIGHT',
				xOffset = -2,
				yOffset = 2,
				font = 'Expressway',
				fontSize = 11,
				fontOutline = 'OUTLINE',
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
				xOffset = 0,
				yOffset = 0,
			},
			challengeMode = {
				scale = 1,
				position = 'TOPLEFT',
				xOffset = 8,
				yOffset = -8,
			}
		}
	},
	lootRoll = {
		width = 325,
		height = 30,
		spacing = 4,
		buttonSize = 20,
		style = 'halfbar',
		statusBarTexture = 'ElvUI Norm',
		leftButtons = false,
		qualityName = false,
		qualityItemLevel = false,
		qualityStatusBar = true,
		qualityStatusBarBackdrop = true,
		statusBarColor = { r = 0, g = .4, b = 1 },
		nameFont = 'Expressway',
		nameFontSize = 12,
		nameFontOutline = 'OUTLINE',
	},
	objectiveTracker = true,
	totems = { -- totem tracker
		growthDirection = 'VERTICAL',
		sortDirection = (E.Wrath and 'DESCENDING') or 'ASCENDING',
		size = 40,
		spacing = 4,
	},
	kittys = false
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
		fontOutline = 'NONE',
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

P.databars.experience.hideAtMaxLevel = true
P.databars.experience.showLevel = false
P.databars.experience.width = 348
P.databars.experience.fontSize = 12
P.databars.experience.showQuestXP = true
P.databars.experience.questTrackedOnly = false
P.databars.experience.questCompletedOnly = false
P.databars.experience.questCurrentZoneOnly = false

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
	bagSize = 34,
	bagButtonSpacing = 1,
	bankButtonSpacing = 1,
	bankSize = 34,
	bagWidth = 406,
	bankWidth = 406,
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
	strata = 'HIGH',
	qualityColors = true,
	specialtyColors = true,
	showBindType = false,
	transparent = false,
	showAssignedIcon = true,
	colors = {
		profession = {
			reagent = { r = 0.53, g = 0.26, b = 1 },
			ammoPouch = { r = 1, g = 0.69, b = 0.41 },
			cooking = { r = .87, g = .05, b = .25 },
			enchanting = { r = .76, g = .02, b = .8 },
			engineering = { r = .91, g = .46, b = .18 },
			fishing = { r = .42, g = .59, b = 1 },
			gems = { r = .03, g = .71, b = .81 },
			herbs = { r = .07, g = .71, b = .13 },
			inscription = { r = .29, g = .30, b = .88 },
			keyring = { r = 1, g = .96, b = .41 },
			leatherworking = { r = .88, g = .73, b = .29 },
			mining = { r = .54, g = .40, b = .04 },
			quiver = { r = 1, g = 0.69, b = 0.41 },
			soulBag = { r = 1, g = 0.69, b = 0.41 },
		},
		assignment = {
			equipment = { r = 0, g = .50, b = .47 },
			consumables = { r = .57, g = .95, b = .66 },
			tradegoods = { r = 1, g = .32, b = .66 },
			quest = { r = 0.6, g = 0.2, b = 0.2 },
			junk = { r = 0.26, g = 0.26, b = 0.26 },
		},
		items = {
			questStarter = { r = 1, g = .96, b = .41 },
			questItem = { r = 0.9, g = 0.3, b = 0.3 },
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
		player = false,
		bank = false,
	},
	shownBags = {},
	autoToggle = {
		bank = true,
		mail = true,
		vendor = true,
		soulBind = true,
		auctionHouse = true,
		professions = false,
		guildBank = false,
		trade = false,
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
		visibility = E.Retail and '[petbattle] hide; show' or 'show',
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
	priority = ''
}

local NP_Health = {
	enable = true,
	healPrediction = true,
	height = 10,
	useClassColor = true,
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
	classColor = false,
	hideWhenEmpty = false,
	costPrediction = true,
	width = 150,
	height = 8,
	xOffset = 0,
	yOffset = -10,
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
	classicon = true,
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
	displayTarget = false,
	hideSpellName = false,
	hideTime = false,
	sourceInterrupt = true,
	sourceInterruptClassColor = true,
	castTimeFormat = 'CURRENT',
	channelTimeFormat = 'CURRENT',
	timeToHold = 0,
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
	textPosition = 'BOTTOMRIGHT',
	size = 20,
	xOffset = 0,
	yOffset = 0,
	font = 'PT Sans Narrow',
	fontOutline = 'OUTLINE',
	fontSize = 12
}

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
	smoothbars = false,
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
	},
	filters = {
		ElvUI_Boss = {triggers = {enable = false}},
		ElvUI_Target = {triggers = {enable = true}},
		ElvUI_NonTarget = {triggers = {enable = true}},
		ElvUI_Explosives = {triggers = {enable = true}},
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
			goodColor = {r = 0.20, g = 0.71, b = 0.00},
			badColor = {r = 1.00, g = 0.18, b = 0.18},
			goodTransition = {r = 1.00, g = 0.85, b = 0.20},
			badTransition ={r = 1.00, g = 0.51, b = 0.20},
			offTankColor = {r = 0.73, g = 0.20, b = 1.00},
			offTankColorGoodTransition = {r = .31, g = .45, b = .63},
			offTankColorBadTransition = {r = 0.71, g = 0.43, b = 0.27},
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
			MAGE = {r = 0, g = 0.62, b = 1.00},
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
				{r = .23, g = .45, b = .13}, -- earth
				{r = .58, g = .23, b = .10}, -- fire
				{r = .19, g = .48, b = .60}, -- water
				{r = .42, g = .18, b = .74}, -- air
			},
			WARLOCK = {r = 0.58, g = 0.51, b = 0.79}
		},
	},
	visibility = {
		showAll = true,
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
			enable = false,
			showTitle = true,
			smartAuraPosition = 'DISABLED',
			nameOnly = false,
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
			buffs = CopyTable(NP_Auras),
			castbar = CopyTable(NP_Castbar),
			debuffs = CopyTable(NP_Auras),
			health = CopyTable(NP_Health),
			level = CopyTable(NP_Level),
			name = CopyTable(NP_Name),
			portrait = CopyTable(NP_Portrait),
			power = CopyTable(NP_Power),
			pvpclassificationindicator = CopyTable(NP_PvPClassificationIndicator),
			pvpindicator = CopyTable(NP_PvPIcon),
			raidTargetIndicator = CopyTable(NP_RaidTargetIndicator),
			title = CopyTable(NP_Title),
		},
		TARGET = {
			enable = true,
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
			enable = true,
			showTitle = true,
			smartAuraPosition = 'DISABLED',
			nameOnly = false,
			markHealers = true,
			markTanks = true,
			buffs = CopyTable(NP_Auras),
			castbar = CopyTable(NP_Castbar),
			debuffs = CopyTable(NP_Auras),
			health = CopyTable(NP_Health),
			level = CopyTable(NP_Level),
			name = CopyTable(NP_Name),
			portrait = CopyTable(NP_Portrait),
			power = CopyTable(NP_Power),
			pvpclassificationindicator = CopyTable(NP_PvPClassificationIndicator),
			pvpindicator = CopyTable(NP_PvPIcon),
			raidTargetIndicator = CopyTable(NP_RaidTargetIndicator),
			title = CopyTable(NP_Title),
		},
		ENEMY_PLAYER = {
			enable = true,
			showTitle = true,
			smartAuraPosition = 'DISABLED',
			nameOnly = false,
			markHealers = true,
			markTanks = true,
			buffs = CopyTable(NP_Auras),
			castbar = CopyTable(NP_Castbar),
			debuffs = CopyTable(NP_Auras),
			health = CopyTable(NP_Health),
			level = CopyTable(NP_Level),
			name = CopyTable(NP_Name),
			portrait = CopyTable(NP_Portrait),
			power = CopyTable(NP_Power),
			pvpclassificationindicator = CopyTable(NP_PvPClassificationIndicator),
			pvpindicator = CopyTable(NP_PvPIcon),
			raidTargetIndicator = CopyTable(NP_RaidTargetIndicator),
			title = CopyTable(NP_Title),
		},
		FRIENDLY_NPC = {
			enable = true,
			showTitle = true,
			smartAuraPosition = 'DISABLED',
			nameOnly = true,
			buffs = CopyTable(NP_Auras),
			castbar = CopyTable(NP_Castbar),
			debuffs = CopyTable(NP_Auras),
			eliteIcon = CopyTable(NP_EliteIcon),
			health = CopyTable(NP_Health),
			level = CopyTable(NP_Level),
			name = CopyTable(NP_Name),
			portrait = CopyTable(NP_Portrait),
			power = CopyTable(NP_Power),
			pvpindicator = CopyTable(NP_PvPIcon),
			questIcon = CopyTable(NP_QuestIcon),
			raidTargetIndicator = CopyTable(NP_RaidTargetIndicator),
			title = CopyTable(NP_Title),
		},
		ENEMY_NPC = {
			enable = true,
			showTitle = true,
			smartAuraPosition = 'DISABLED',
			nameOnly = false,
			buffs = CopyTable(NP_Auras),
			castbar = CopyTable(NP_Castbar),
			debuffs = CopyTable(NP_Auras),
			eliteIcon = CopyTable(NP_EliteIcon),
			health = CopyTable(NP_Health),
			level = CopyTable(NP_Level),
			name = CopyTable(NP_Name),
			portrait = CopyTable(NP_Portrait),
			power = CopyTable(NP_Power),
			pvpindicator = CopyTable(NP_PvPIcon),
			questIcon = CopyTable(NP_QuestIcon),
			raidTargetIndicator = CopyTable(NP_RaidTargetIndicator),
			title = CopyTable(NP_Title),
		},
	},
}

P.nameplates.units.PLAYER.buffs.maxDuration = 300
P.nameplates.units.PLAYER.buffs.priority = 'Blacklist,blockNoDuration,Personal,TurtleBuffs,PlayerBuffs'
P.nameplates.units.PLAYER.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.PLAYER.debuffs.growthX = 'LEFT'
P.nameplates.units.PLAYER.debuffs.growthY = 'UP'
P.nameplates.units.PLAYER.debuffs.yOffset = 35
P.nameplates.units.PLAYER.debuffs.priority = 'Blacklist,blockNoDuration,Personal,Boss,CCDebuffs,RaidDebuffs,Dispellable'
P.nameplates.units.PLAYER.name.enable = false
P.nameplates.units.PLAYER.name.format = '[name]'
P.nameplates.units.PLAYER.level.enable = false
P.nameplates.units.PLAYER.power.enable = true
P.nameplates.units.PLAYER.castbar.yOffset = -20

P.nameplates.units.FRIENDLY_PLAYER.buffs.priority = 'Blacklist,blockNoDuration,Personal,TurtleBuffs'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.growthX = 'LEFT'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.growthY = 'UP'
P.nameplates.units.FRIENDLY_PLAYER.debuffs.yOffset = 35
P.nameplates.units.FRIENDLY_PLAYER.debuffs.priority = 'Blacklist,Dispellable,blockNoDuration,Personal,CCDebuffs'

P.nameplates.units.ENEMY_PLAYER.buffs.priority = 'Blacklist,Dispellable,PlayerBuffs,TurtleBuffs'
P.nameplates.units.ENEMY_PLAYER.buffs.maxDuration = 300
P.nameplates.units.ENEMY_PLAYER.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.ENEMY_PLAYER.debuffs.growthX = 'LEFT'
P.nameplates.units.ENEMY_PLAYER.debuffs.growthY = 'UP'
P.nameplates.units.ENEMY_PLAYER.debuffs.yOffset = 35
P.nameplates.units.ENEMY_PLAYER.debuffs.priority = 'Blacklist,blockNoDuration,Personal,CCDebuffs'
P.nameplates.units.ENEMY_PLAYER.name.format = '[classcolor][name:abbrev:long]'

P.nameplates.units.FRIENDLY_NPC.buffs.priority = 'Blacklist,blockNoDuration,Personal,TurtleBuffs'
P.nameplates.units.FRIENDLY_NPC.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.FRIENDLY_NPC.debuffs.growthX = 'LEFT'
P.nameplates.units.FRIENDLY_NPC.debuffs.growthY = 'UP'
P.nameplates.units.FRIENDLY_NPC.debuffs.yOffset = 35
P.nameplates.units.FRIENDLY_NPC.debuffs.priority = 'Blacklist,Dispellable,CCDebuffs,RaidDebuffs'
P.nameplates.units.FRIENDLY_NPC.level.format = '[difficultycolor][level][shortclassification]'
P.nameplates.units.FRIENDLY_NPC.title.format = '[npctitle]'

P.nameplates.units.ENEMY_NPC.buffs.priority = 'Blacklist,RaidBuffsElvUI,Dispellable,blockNoDuration,CastByUnit'
P.nameplates.units.ENEMY_NPC.debuffs.anchorPoint = 'TOPRIGHT'
P.nameplates.units.ENEMY_NPC.debuffs.growthX = 'LEFT'
P.nameplates.units.ENEMY_NPC.debuffs.growthY = 'UP'
P.nameplates.units.ENEMY_NPC.debuffs.yOffset = 35
P.nameplates.units.ENEMY_NPC.debuffs.priority = 'Blacklist,Personal,CCDebuffs'
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
	sortDir = '-',
	sortMethod = 'TIME',
	verticalSpacing = 16,
	wrapAfter = 12,
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
	fontOutline = 'NONE',
	fontSize = 10,
	sticky = true,
	emotionIcons = true,
	keywordSound = 'None',
	noAlertInCombat = false,
	flashClientIcon = true,
	chatHistory = true,
	lfgIcons = true,
	maxLines = 100,
	channelAlerts = {
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
	tabFontOutline = 'NONE',
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
	fontOutline = 'NONE',
	wordWrap = false,
	panels = {
		LeftChatDataPanel = {
			enable = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			E.Retail and 'Talent/Loot Specialization' or 'ElvUI',
			'Durability',
			E.Retail and 'Missions' or 'Mail'
		},
		RightChatDataPanel = {
			enable = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			'System',
			'Time',
			'Gold'
		},
		MinimapPanel = {
			enable = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			numPoints = 2,
			'Guild',
			'Friends'
		}
	},
	battleground = true,
	noCombatClick = false,
	noCombatHover = false,
}

--Tooltip
P.tooltip = {
	showElvUIUsers = false,
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
	itemCount = 'BAGS_ONLY',
	modifierCount = true,
	showMount = true,
	modifierID = 'SHOW',
	role = true,
	gender = false,
	font = 'PT Sans Narrow',
	fontOutline = 'NONE',
	textFontSize = 12, -- is fontSize (has old name)
	headerFont = 'PT Sans Narrow',
	headerFontOutline = 'NONE',
	headerFontSize = 13,
	smallTextFontSize = 12,
	colorAlpha = 0.8,
	fadeOut = true,
	visibility = {
		bags = 'SHOW',
		unitFrames = 'SHOW',
		actionbars = 'SHOW',
		combatOverride = 'SHOW',
	},
	healthBar = {
		text = true,
		height = 7,
		font = 'Homespun',
		fontSize = 10,
		fontOutline = 'OUTLINE',
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
}

local UF_AuraBars = {
	anchorPoint = 'ABOVE',
	attachTo = 'DEBUFFS',
	detachedWidth = 270,
	enable = true,
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
	clickThrough = false,
	reverseFill = false,
	abbrevName = false,
}

local UF_AuraWatch = {
	enable = false,
	profileSpecific = false,
	size = 8,
	countFontSize = 12,
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
	hidetext = false,
	icon = true,
	iconAttached = true,
	iconAttachedTo = 'Frame',
	iconPosition = 'LEFT',
	iconSize = 42,
	iconXOffset = -10,
	iconYOffset = 0,
	insideInfoPanel = true,
	overlayOnFrame = 'None',
	displayTarget = false,
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
	scale = 1,
	position = 'TOPLEFT',
	xOffset = 0,
	yOffset = 4,
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
	colorOverride = 'USE_DEFAULT',
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

--UnitFrame
P.unitframe = {
	smoothbars = false,
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
		DRUID = { Rage = true, LunarPower = true },
		SHAMAN = { Maelstrom = true },
		PRIEST = { Insanity = true }
	},
	thinBorders = true,
	targetSound = false,
	colors = {
		borderColor = {r = 0, g = 0, b = 0}, -- updated in E.Initialize
		healthclass = false,
		--healththreat = false,
		healthselection = false,
		forcehealthreaction = false,
		powerclass = false,
		--powerthreat = false,
		powerselection = false,
		colorhealthbyvalue = true,
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
			additional = {r = 1, g = 1, b = 1, a = 1},
			color = {r = 1, g = 1, b = 1, a = 1},
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
			stagger = {
				enable = true,
				width = 10,
			},
			aurabar = CopyTable(UF_AuraBars),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
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
		},
		target = {
			enable = true,
			width = 270,
			height = 54,
			orientation = 'RIGHT',
			threatStyle = 'GLOW',
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			middleClickFocus = true,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			CombatIcon = CopyTable(UF_CombatIcon),
			aurabar = CopyTable(UF_AuraBars),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
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
		},
		targettarget = {
			enable = true,
			threatStyle = 'NONE',
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
			debuffs = CopyTable(UF_Auras),
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
			orientation = 'MIDDLE',
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			width = 190,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = true,
			aurabar = CopyTable(UF_AuraBars),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			cutaway = CopyTable(UF_Cutaway),
			CombatIcon = CopyTable(UF_CombatIcon),
			debuffs = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
		},
		pet = {
			enable = true,
			orientation = 'MIDDLE',
			threatStyle = 'GLOW',
			smartAuraPosition = 'DISABLED',
			colorOverride = 'USE_DEFAULT',
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			aurabar = CopyTable(UF_AuraBars),
			buffIndicator = CopyTable(UF_AuraWatch),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			strataAndLevel = CopyTable(UF_StrataAndLevel),
		},
		boss = {
			enable = true,
			threatStyle = 'NONE',
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
			buffIndicator = CopyTable(UF_AuraWatch),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			fader = CopyTable(UF_Fader),
			power = CopyTable(UF_Power),
			portrait = CopyTable(UF_Portrait),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			buffs = CopyTable(UF_Auras),
			debuffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			raidicon = CopyTable(UF_RaidIcon),
			cutaway = CopyTable(UF_Cutaway),
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
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			pvpclassificationindicator = CopyTable(UF_PvPClassificationIndicator),
		},
		party = {
			enable = true,
			threatStyle = 'GLOW',
			orientation = 'LEFT',
			visibility = '[@raid6,exists][nogroup] hide;show',
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
			buffIndicator = CopyTable(UF_AuraWatch),
			CombatIcon = CopyTable(UF_CombatIcon),
			buffs = CopyTable(UF_Auras),
			castbar = CopyTable(UF_Castbar),
			classbar = CopyTable(UF_ClassBar),
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			healPrediction = CopyTable(UF_HealthPrediction),
			health = CopyTable(UF_Health),
			infoPanel = CopyTable(UF_InfoPanel),
			name = CopyTable(UF_Name),
			petsGroup = CopyTable(UF_SubGroup),
			phaseIndicator = CopyTable(UF_PhaseIndicator),
			portrait = CopyTable(UF_Portrait),
			power = CopyTable(UF_Power),
			raidicon = CopyTable(UF_RaidIcon),
			raidRoleIcons = CopyTable(UF_RaidRoles),
			rdebuffs = CopyTable(UF_RaidDebuffs),
			readycheckIcon = CopyTable(UF_ReadyCheckIcon),
			resurrectIcon = CopyTable(UF_Ressurect),
			roleIcon = CopyTable(UF_RoleIcon),
			summonIcon = CopyTable(UF_SummonIcon),
			targetsGroup = CopyTable(UF_SubGroup),
			pvpclassificationindicator = CopyTable(UF_PvPClassificationIndicator),
		},
		tank = {
			enable = true,
			orientation = 'LEFT',
			threatStyle = 'GLOW',
			colorOverride = 'USE_DEFAULT',
			middleClickFocus = false,
			width = 120,
			height = 28,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			verticalSpacing = 7,
			targetsGroup = CopyTable(UF_SubGroup),
			buffIndicator = CopyTable(UF_AuraWatch),
			healPrediction = CopyTable(UF_HealthPrediction),
			buffs = CopyTable(UF_Auras),
			cutaway = CopyTable(UF_Cutaway),
			debuffs = CopyTable(UF_Auras),
			fader = CopyTable(UF_Fader),
			health = CopyTable(UF_Health),
			name = CopyTable(UF_Name),
			raidicon = CopyTable(UF_RaidIcon),
			rdebuffs = CopyTable(UF_RaidDebuffs),
		},
	},
}

P.unitframe.colors.classResources = CopyTable(P.nameplates.colors.classResources)
P.unitframe.colors.empoweredCast = CopyTable(P.nameplates.colors.empoweredCast)

P.unitframe.units.player.aurabar.enemyAuraType = 'HARMFUL'
P.unitframe.units.player.aurabar.friendlyAuraType = 'HELPFUL'
P.unitframe.units.player.aurabar.maxDuration = 120
P.unitframe.units.player.aurabar.priority = 'Blacklist,blockNoDuration,Personal,Boss,RaidDebuffs,PlayerBuffs'
P.unitframe.units.player.buffs.attachTo = 'DEBUFFS'
P.unitframe.units.player.buffs.priority = 'Blacklist,Personal,PlayerBuffs,Whitelist,blockNoDuration,nonPersonal'
P.unitframe.units.player.debuffs.enable = true
P.unitframe.units.player.debuffs.priority = 'Blacklist,Personal,nonPersonal'
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
P.unitframe.units.target.aurabar.priority = 'Blacklist,blockNoDuration,Personal,Boss,RaidDebuffs,PlayerBuffs'
P.unitframe.units.target.buffs.enable = true
P.unitframe.units.target.buffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.target.buffs.growthX = 'LEFT'
P.unitframe.units.target.buffs.growthY = 'UP'
P.unitframe.units.target.buffs.priority = 'Blacklist,Personal,nonPersonal'
P.unitframe.units.target.debuffs.enable = true
P.unitframe.units.target.debuffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.target.debuffs.growthX = 'LEFT'
P.unitframe.units.target.debuffs.growthY = 'UP'
P.unitframe.units.target.debuffs.attachTo = 'BUFFS'
P.unitframe.units.target.debuffs.maxDuration = 300
P.unitframe.units.target.debuffs.priority = 'Blacklist,Personal,RaidDebuffs,CCDebuffs,Friendly:Dispellable'
P.unitframe.units.target.healPrediction.enable = true
P.unitframe.units.target.health.text_format = '[healthcolor][health:current-percent:shortvalue]'
P.unitframe.units.target.name.text_format = '[classcolor][name:medium] [difficultycolor][smartlevel] [shortclassification]'
P.unitframe.units.target.power.text_format = '[powercolor][power:current:shortvalue]'

P.unitframe.units.targettarget.buffs.anchorPoint = 'BOTTOMLEFT'
P.unitframe.units.targettarget.buffs.maxDuration = 300
P.unitframe.units.targettarget.buffs.numrows = 1
P.unitframe.units.targettarget.buffs.perrow = 7
P.unitframe.units.targettarget.buffs.priority = 'Blacklist,Personal,PlayerBuffs,Dispellable'
P.unitframe.units.targettarget.debuffs.enable = true
P.unitframe.units.targettarget.debuffs.anchorPoint = 'BOTTOMRIGHT'
P.unitframe.units.targettarget.debuffs.growthX = 'LEFT'
P.unitframe.units.targettarget.debuffs.attachTo = 'BUFFS'
P.unitframe.units.targettarget.debuffs.maxDuration = 300
P.unitframe.units.targettarget.debuffs.numrows = 1
P.unitframe.units.targettarget.debuffs.perrow = 5
P.unitframe.units.targettarget.debuffs.priority = 'Blacklist,Personal,Boss,RaidDebuffs,CCDebuffs,Dispellable,Whitelist'
P.unitframe.units.targettarget.infoPanel.height = 14
P.unitframe.units.targettarget.name.text_format = '[classcolor][name:medium]'
P.unitframe.units.targettarget.power.text_format = ''

P.unitframe.units.targettargettarget = CopyTable(P.unitframe.units.targettarget)
P.unitframe.units.targettargettarget.enable = false
P.unitframe.units.targettargettarget.buffs.priority = 'Blacklist,Personal,nonPersonal'
P.unitframe.units.targettargettarget.debuffs.attachTo = 'FRAME'
P.unitframe.units.targettargettarget.debuffs.priority = 'Blacklist,Personal,nonPersonal'
P.unitframe.units.targettargettarget.infoPanel.height = 12

P.unitframe.units.focus.aurabar.enable = false
P.unitframe.units.focus.aurabar.detachedWidth = 190
P.unitframe.units.focus.aurabar.maxBars = 3
P.unitframe.units.focus.aurabar.maxDuration = 120
P.unitframe.units.focus.aurabar.priority = 'Blacklist,blockNoDuration,Personal,Boss,RaidDebuffs,PlayerBuffs'
P.unitframe.units.focus.buffs.anchorPoint = 'BOTTOMLEFT'
P.unitframe.units.focus.buffs.maxDuration = 300
P.unitframe.units.focus.buffs.numrows = 1
P.unitframe.units.focus.buffs.perrow = 7
P.unitframe.units.focus.buffs.priority = 'Blacklist,Personal,PlayerBuffs,CastByUnit,Dispellable,RaidBuffsElvUI'
P.unitframe.units.focus.castbar.width = 190
P.unitframe.units.focus.debuffs.enable = true
P.unitframe.units.focus.debuffs.anchorPoint = 'TOPRIGHT'
P.unitframe.units.focus.debuffs.growthX = 'LEFT'
P.unitframe.units.focus.debuffs.growthY = 'UP'
P.unitframe.units.focus.debuffs.maxDuration = 300
P.unitframe.units.focus.debuffs.numrows = 1
P.unitframe.units.focus.debuffs.perrow = 5
P.unitframe.units.focus.debuffs.priority = 'Blacklist,Personal,Boss,RaidDebuffs,Dispellable,Whitelist'
P.unitframe.units.focus.healPrediction.enable = true
P.unitframe.units.focus.infoPanel.height = 14
P.unitframe.units.focus.name.text_format = '[classcolor][name:medium]'

P.unitframe.units.focustarget = CopyTable(P.unitframe.units.focus)
P.unitframe.units.focustarget.enable = false
P.unitframe.units.focustarget.aurabar = nil
P.unitframe.units.focustarget.buffs.priority = 'Blacklist,Personal,PlayerBuffs,Dispellable,CastByUnit,RaidBuffsElvUI'
P.unitframe.units.focustarget.debuffs.enable = false
P.unitframe.units.focustarget.debuffs.anchorPoint = 'BOTTOMRIGHT'
P.unitframe.units.focustarget.debuffs.growthX = 'LEFT'
P.unitframe.units.focustarget.debuffs.priority = 'Blacklist,Personal,Boss,RaidDebuffs,Dispellable,Whitelist'
P.unitframe.units.focustarget.height = 26
P.unitframe.units.focustarget.infoPanel.height = 12
P.unitframe.units.focustarget.threatStyle = 'NONE'

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
P.unitframe.units.pet.buffs.priority = 'Blacklist,Personal,PlayerBuffs'
P.unitframe.units.pet.debuffs.anchorPoint = 'BOTTOMRIGHT'
P.unitframe.units.pet.debuffs.growthX = 'LEFT'
P.unitframe.units.pet.debuffs.maxDuration = 300
P.unitframe.units.pet.debuffs.numrows = 1
P.unitframe.units.pet.debuffs.perrow = 5
P.unitframe.units.pet.debuffs.priority = 'Blacklist,Personal,Boss,RaidDebuffs'
P.unitframe.units.pet.healPrediction.enable = true
P.unitframe.units.pet.health.colorHappiness = true
P.unitframe.units.pet.infoPanel.height = 12
P.unitframe.units.pet.name.text_format = '[classcolor][name:medium]'

P.unitframe.units.pettarget = CopyTable(P.unitframe.units.pet)
P.unitframe.units.pettarget.enable = false
P.unitframe.units.pettarget.buffs.maxDuration = 300
P.unitframe.units.pettarget.buffs.priority = 'Blacklist,PlayerBuffs,CastByUnit,Whitelist,RaidBuffsElvUI'
P.unitframe.units.pettarget.debuffs.maxDuration = 300
P.unitframe.units.pettarget.debuffs.priority = 'Blacklist,Boss,RaidDebuffs,Dispellable,Whitelist'
P.unitframe.units.pettarget.height = 26
P.unitframe.units.pettarget.threatStyle = 'NONE'

P.unitframe.units.boss.buffs.enable = true
P.unitframe.units.boss.buffs.anchorPoint = 'LEFT'
P.unitframe.units.boss.buffs.numrows = 1
P.unitframe.units.boss.buffs.perrow = 3
P.unitframe.units.boss.buffs.priority = 'Blacklist,CastByUnit,Dispellable,Whitelist,RaidBuffsElvUI'
P.unitframe.units.boss.buffs.sizeOverride = 22
P.unitframe.units.boss.buffs.yOffset = 20
P.unitframe.units.boss.buffIndicator.enable = true
P.unitframe.units.boss.castbar.width = 215
P.unitframe.units.boss.debuffs.enable = true
P.unitframe.units.boss.debuffs.anchorPoint = 'LEFT'
P.unitframe.units.boss.debuffs.numrows = 1
P.unitframe.units.boss.debuffs.perrow = 3
P.unitframe.units.boss.debuffs.priority = 'Blacklist,Boss,Personal,RaidDebuffs,CastByUnit,Whitelist'
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
P.unitframe.units.arena.buffs.priority = 'Blacklist,TurtleBuffs,PlayerBuffs,Dispellable'
P.unitframe.units.arena.buffs.sizeOverride = 27
P.unitframe.units.arena.buffs.yOffset = 16
P.unitframe.units.arena.castbar.width = 256
P.unitframe.units.arena.castbar.positionsGroup = {anchorPoint = 'BOTTOM', xOffset = 0, yOffset = 0}
P.unitframe.units.arena.debuffs.enable = true
P.unitframe.units.arena.debuffs.anchorPoint = 'LEFT'
P.unitframe.units.arena.debuffs.maxDuration = 300
P.unitframe.units.arena.debuffs.numrows = 1
P.unitframe.units.arena.debuffs.perrow = 3
P.unitframe.units.arena.debuffs.priority = 'Blacklist,blockNoDuration,Personal,CCDebuffs,Whitelist'
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
P.unitframe.units.party.castbar.enable = false
P.unitframe.units.party.castbar.width = 256
P.unitframe.units.party.castbar.positionsGroup = {anchorPoint = 'BOTTOM', xOffset = 0, yOffset = 0}
P.unitframe.units.party.CombatIcon.enable = false
P.unitframe.units.party.debuffs.enable = true
P.unitframe.units.party.debuffs.anchorPoint = 'RIGHT'
P.unitframe.units.party.debuffs.maxDuration = 300
P.unitframe.units.party.debuffs.priority = 'Blacklist,Boss,RaidDebuffs,CCDebuffs,Dispellable,Whitelist'
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
P.unitframe.units.raid1.castbar = nil
P.unitframe.units.raid1.CombatIcon = nil
P.unitframe.units.raid1.debuffs.enable = false
P.unitframe.units.raid1.debuffs.numrows = 1
P.unitframe.units.raid1.debuffs.perrow = 3
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
P.unitframe.units.raidpet.buffs.priority = 'Blacklist,Personal,Boss,PlayerBuffs,blockNoDuration,nonPersonal'
P.unitframe.units.raidpet.debuffs.numrows = 1
P.unitframe.units.raidpet.debuffs.perrow = 3
P.unitframe.units.raidpet.debuffs.priority = 'Blacklist,Personal,Boss,Whitelist,RaidDebuffs,blockNoDuration,nonPersonal'
P.unitframe.units.raidpet.growthDirection = 'DOWN_RIGHT'
P.unitframe.units.raidpet.height = 30
P.unitframe.units.raidpet.numGroups = 8
P.unitframe.units.raidpet.visibility = '[group:raid] show; hide'

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
	addNewSpells = false,
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
	totemBar = {
		enable = true,
		alpha = 1,
		spacing = 4,
		buttonSize = 32,
		flyoutDirection = 'UP',
		flyoutSize = 28,
		flyoutSpacing = 2,
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 12,
		mouseover = false,
		visibility = '[vehicleui] hide;show'
	},
	microbar = {
		enabled = false,
		mouseover = false,
		buttonsPerRow = 11,
		buttonSize = 20,
		keepSizeRatio = false,
		point = 'TOPLEFT',
		buttonHeight = 28,
		buttonSpacing = 2,
		alpha = 1,
		visibility = E.Retail and '[petbattle] hide; show' or 'show',
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
if E.Retail then
	P.actionbar.barPet.visibility = '[petbattle] hide; [novehicleui,pet,nooverridebar,nopossessbar] show; hide'
	P.actionbar.stanceBar.visibility = '[vehicleui][petbattle] hide; show'
elseif E.Wrath then
	P.actionbar.barPet.visibility = '[novehicleui,pet,nooverridebar,nopossessbar] show; hide'
	P.actionbar.stanceBar.visibility = '[vehicleui] hide; show'
else
	P.actionbar.barPet.visibility = '[nooverridebar,nopossessbar] show; hide'
	P.actionbar.stanceBar.visibility = 'show'
end

for i = 1, 10 do
	local bar = {
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
	}

	if E.Retail then
		bar.visibility = '[vehicleui][petbattle][overridebar] hide; show'
	elseif E.Wrath then
		bar.visibility = '[vehicleui][overridebar] hide; show'
	else
		bar.visibility = '[overridebar] hide; show'
	end

	P.actionbar['bar'..i] = bar
end

if E.Retail then
	P.actionbar.bar13 = CopyTable(P.actionbar.bar1)
	P.actionbar.bar14 = CopyTable(P.actionbar.bar1)
	P.actionbar.bar15 = CopyTable(P.actionbar.bar1)
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
P.actionbar.bar1.visibility = E.Retail and '[petbattle] hide; show' or 'show'

P.actionbar.bar1.paging.ROGUE = '[bonusbar:1] 7;'..(E.Wrath and ' [bonusbar:2] 8;' or '')
P.actionbar.bar1.paging.WARLOCK = E.Wrath and '[form:1] 7;' or nil
P.actionbar.bar1.paging.DRUID = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10;'
P.actionbar.bar1.paging.EVOKER = '[bonusbar:1] 7;'
P.actionbar.bar1.paging.PRIEST = '[bonusbar:1] 7;'
P.actionbar.bar1.paging.WARRIOR = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;'

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

	P.WeakAuras = {} -- native cooldown support with our module
	P.WeakAuras.cooldown = CopyTable(P.actionbar.cooldown)
	P.WeakAuras.cooldown.override = false

	-- color override
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

--Mover positions that are set inside the installation process. ALL is used still to prevent people from getting pissed off
--This allows movers positions to be reset to whatever profile is being used
E.LayoutMoverPositions = {
	ALL = {
		BelowMinimapContainerMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274',
		BNETMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274',
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,95',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,243',
		LossControlMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,507',
		MirrorTimer1Mover = 'TOP,ElvUIParent,TOP,-1,-96',
		ObjectiveFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-163,-325',
		SocialMenuMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-187',
		VehicleSeatMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-4',
		DurabilityFrameMover = "TOPLEFT,ElvUIParent,TOPLEFT,141,-4",
		ThreatBarMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4",
		PetAB = "RIGHT,ElvUIParent,RIGHT,-4,0",
		ShiftAB = "BOTTOM,ElvUIParent,BOTTOM,0,58",
		ElvUF_Raid3Mover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269",
		ElvUF_Raid2Mover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269",
		ElvUF_Raid1Mover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269",
		ElvUF_PartyMover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269",
		HonorBarMover = "TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-251",
		ReputationBarMover = "TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-243"
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
	}
}
