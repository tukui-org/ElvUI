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
		['Attack Power'] = { Label = '', NoLabel = false },
		Avoidance = { Label = '', NoLabel = false, decimalLength = 1 },
		Bags = { textFormat = 'USED_TOTAL', Label = '', NoLabel = false, includeReagents = false },
		CallToArms = { Label = '', NoLabel = false },
		Combat = { TimeFull = true, NoLabel = false },
		CombatIndicator = { OutOfCombat = '', InCombat = '', OutOfCombatColor = {r = 0, g = 0.8, b = 0}, InCombatColor = {r = 0.8, g = 0, b = 0} },
		Currencies = { goldFormat = 'BLIZZARD', goldCoins = true, displayedCurrency = 'BACKPACK', displayStyle = 'ICON', tooltipData = {}, idEnable = {}, headers = true, maxCurrency = false },
		Crit = { Label = '', NoLabel = false, decimalLength = 1 },
		Durability = { Label = '', NoLabel = false, percThreshold = 30, goldFormat = 'BLIZZARD', goldCoins = true },
		DualSpecialization = { NoLabel = false },
		ElvUI = { Label = '' },
		['Equipment Sets'] = { Label = '', NoLabel = false, NoIcon = false },
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
		Gold = { goldFormat = 'BLIZZARD', maxLimit = 30, goldCoins = true },
		Guild = { Label = '', NoLabel = false, maxLimit = 30 },
		Haste = { Label = '', NoLabel = false, decimalLength = 1 },
		Hit = { Label = '', NoLabel = false, decimalLength = 1 },
		Intellect = { Label = '', NoLabel = false},
		['Item Level'] = { onlyEquipped = false, rarityColor = true },
		Leech = { Label = '', NoLabel = false, decimalLength = 1 },
		Location = { showZone = true, showSubZone = true, showContinent = false, color = 'REACTION', customColor = {r = 1, g = 1, b = 1} },
		Mastery = { Label = '', NoLabel = false, decimalLength = 1 },
		MovementSpeed = { Label = '', NoLabel = false, decimalLength = 1 },
		QuickJoin = { Label = '', NoLabel = false },
		Reputation = { textFormat = 'CUR' },
		['Talent/Loot Specialization'] = { displayStyle = 'BOTH', showBoth = false, iconSize = 16, iconOnly = false },
		SpellPower = { school = 0 },
		['Spell Crit Chance'] = { school = 0 },
		Speed = { Label = '', NoLabel = false, decimalLength = 1 },
		Stamina = { Label = '', NoLabel = false },
		Strength = { Label = '', NoLabel = false },
		System = { NoLabel = false, ShowOthers = true, latency = 'WORLD', showTooltip = true },
		Time = { time24 = _G.GetCurrentRegion() ~= 1, localTime = true, flashInvite = true, savedInstances = true },
		Versatility = { Label = '', NoLabel = false, decimalLength = 1 },
		Dodge = { decimalLength = 1 },
		Parry = { decimalLength = 1 },
		Block = { decimalLength = 1 },
		['Mana Regen'] = { Label = '', NoLabel = false, decimalLength = 1 },
		HealPower = { Label = '', NoLabel = false },
		['Spell Hit'] = { Label = '', NoLabel = false, decimalLength = 0 }
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
	aurawatch = {},
	aurafilters = {},
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
	},
	rangeCheck = {
		FRIENDLY = {
			DEATHKNIGHT = {
				['47541'] = 'Death Coil'
			},
			DEMONHUNTER = {},
			DRUID = {
				['8936'] = 'Regrowth'
			},
			EVOKER = {
				['355913'] = 'Emerald Blossom'
			},
			HUNTER = {},
			MAGE = {
				['1459'] = 'Arcane Intellect'
			},
			MONK = {
				['116670'] = 'Vivify'
			},
			PALADIN = {
				['85673'] = 'Word of Glory'
			},
			PRIEST = {
				['17'] = E.Retail and 'Power Word: Shield' or nil,
				['2050'] = not E.Retail and 'Lesser Heal' or nil
			},
			ROGUE = {
				['36554'] = E.Retail and 'Shadowstep' or nil,
				['921'] = E.Retail and 'Pick Pocket' or nil
			},
			SHAMAN = {
				['8004'] = 'Healing Surge'
			},
			WARLOCK = {
				['5697'] = 'Unending Breath'
			},
			WARRIOR = {}
		},
		ENEMY = {
			DEATHKNIGHT = {
				['49576'] = 'Death Grip'
			},
			DEMONHUNTER = {
				['278326'] = 'Consume Magic'
			},
			DRUID = {
				['8921'] = 'Moonfire'
			},
			EVOKER = {
				['362969'] = 'Azure Strike'
			},
			HUNTER = {
				['19503'] = not E.Retail and 'Scatter Shot' or nil,
				['2974'] = not E.Retail and 'Wing Clip' or nil,
				['2973'] = E.Mists and 'Raptor Strike' or nil,
				['75'] = 'Auto Shot'
			},
			MAGE = {
				['2139'] = 'Counterspell'
			},
			MONK = {
				['115546'] = 'Provoke'
			},
			PALADIN = {
				['20473'] = 'Holy Shock',
				['20271'] = 'Judgement'
			},
			PRIEST = {
				['589'] = 'Shadow Word: Pain'
			},
			ROGUE = {
				['36554'] = 'Shadowstep'
			},
			SHAMAN = {
				['8042'] = 'Earth Shock',
				['188196'] = E.Retail and 'Lightning Bolt' or nil,
				['403'] = not E.Retail and 'Lightning Bolt' or nil
			},
			WARLOCK = {
				['234153'] = E.Retail and 'Drain Life' or nil,
				['348'] = not E.Retail and 'Immolate' or nil,
			},
			WARRIOR = {
				['355'] = 'Taunt'
			}
		},
		RESURRECT = {
			DEATHKNIGHT = {
				['61999'] = 'Raise Ally'
			},
			DEMONHUNTER = {},
			DRUID = {
				['50769'] = 'Revive'
			},
			EVOKER = {
				['361227'] = 'Return'
			},
			HUNTER = {},
			MAGE = {},
			MONK = {
				['115178'] = 'Resuscitate'
			},
			PALADIN = {
				['7328'] = 'Redemption'
			},
			PRIEST = {
				['2006'] = 'Resurrection'
			},
			ROGUE = {},
			SHAMAN = {
				['2008'] = 'Ancestral Spirit'
			},
			WARLOCK = {
				['20707'] = not E.Classic and 'Soulstone' or nil
			},
			WARRIOR = {}
		},
		PET = {
			DEATHKNIGHT = {
				['47541'] = 'Death Coil'
			},
			DEMONHUNTER = {},
			DRUID = {},
			EVOKER = {},
			HUNTER = {
				['136'] = 'Mend Pet'
			},
			MAGE = {},
			MONK = {},
			PALADIN = {},
			PRIEST = {},
			ROGUE = {},
			SHAMAN = {},
			WARLOCK = {
				['755'] = 'Health Funnel'
			},
			WARRIOR = {}
		}
	}
}

G.profileCopy = {
	selected = 'Default'
}
