------------------------------------------------------------------------------------------------------
-- Locked Settings, These settings are stored for your character only regardless of profile options.
------------------------------------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

V.general = {
	loot = true,
	lootRoll = true,
	normTex = 'ElvUI Norm',
	glossTex = 'ElvUI Norm',
	dmgfont = 'PT Sans Narrow',
	namefont = 'PT Sans Narrow',
	chatBubbles = 'backdrop',
	chatBubbleFont = 'PT Sans Narrow',
	chatBubbleFontSize = 14,
	chatBubbleFontOutline = 'NONE',
	chatBubbleName = false,
	pixelPerfect = true,
	replaceNameFont = true,
	replaceCombatFont = true,
	replaceBlizzFonts = true,
	unifiedBlizzFonts = false,
	totemBar = true,
	minimap = {
		enable = true,
		hideClassHallReport = false,
		hideCalendar = true,
	},
	classColorMentionsSpeech = true,
	raidUtility = true,
	voiceOverlay = true,
	worldMap = true,
}

V.bags = {
	enable = true,
	bagBar = false,
}

V.nameplates = {
	enable = true,
}

V.auras = {
	enable = true,
	disableBlizzard = true,
	buffsHeader = true,
	debuffsHeader = true,
	masque = {
		buffs = false,
		debuffs = false,
	}
}

V.chat = {
	enable = true,
}

V.skins = {
	ace3Enable = true,
	checkBoxSkin = true,
	parchmentRemoverEnable = false,
	blizzard = {
		enable = true,

		achievement = true,
		addonManager = true,
		adventureMap = true,
		alertframes = true,
		alliedRaces = true,
		animaDiversion = true,
		archaeology = true,
		artifact = true,
		auctionhouse = true,
		azerite = true,
		azeriteEssence = true,
		azeriteRespec = true,
		bags = true,
		barber = true,
		bgmap = true,
		bgscore = true,
		binding = true,
		blizzardOptions = true,
		bmah = true, --black market
		calendar = true,
		channels = true,
		character = true,
		chromieTime = true,
		collections = true,
		communities = true,
		contribution = true,
		covenantPreview = true,
		covenantRenown = true,
		covenantSanctum = true,
		deathRecap = true,
		debug = true,
		dressingroom = true,
		encounterjournal = true,
		eventLog = true,
		friends = true,
		garrison = true,
		gbank = true,
		gmChat = true,
		gossip = true,
		greeting = true,
		guide = true,
		guild = true,
		guildcontrol = true,
		guildregistrar = true,
		help = true,
		inspect = true,
		islandQueue = true,
		islandsPartyPose = true,
		itemInteraction = true,
		itemUpgrade = true,
		lfg = true,
		lfguild = true,
		loot = true,
		losscontrol = true,
		macro = true,
		mail = true,
		merchant = true,
		mirrorTimers = true,
		misc = true,
		nonraid = true,
		objectiveTracker = true,
		obliterum = true,
		orderhall = true,
		petbattleui = true,
		petition = true,
		playerChoice = true,
		pvp = true,
		quest = true,
		questChoice = true,
		raid = true,
		reforge = true,
		runeforge = true,
		scrapping = true,
		socket = true,
		soulbinds = true,
		spellbook = true,
		stable = true,
		subscriptionInterstitial = true,
		tabard = true,
		talent = true,
		talkinghead = true,
		taxi = true,
		timemanager = true,
		tooltip = true,
		torghastLevelPicker = true,
		trade = true,
		tradeskill = true,
		trainer = true,
		transmogrify = true,
		tutorials = true,
		voidstorage = true,
		weeklyRewards = true,
		worldmap = true,
	}
}

V.tooltip = {
	enable = true,
}

V.unitframe = {
	enable = true,
	disabledBlizzardFrames = {
		player = true,
		target = true,
		focus = true,
		boss = true,
		arena = true,
		party = true,
		raid = true,
	}
}

V.actionbar = {
	enable = true,
	hideCooldownBling = false,
	masque = {
		actionbars = false,
		petBar = false,
		stanceBar = false,
	}
}
