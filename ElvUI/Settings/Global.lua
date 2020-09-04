local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Global Settings
G.general = {
	UIScale = 0.64,
	version = 11.52,
	locale = E:GetLocale(),
	eyefinity = false,
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
		width = 960,
		height = 730
	},
	disableTutorialButtons = true,
	showMissingTalentAlert = false,
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

G.nameplate = {
	effectiveHealth = false,
	effectivePower = false,
	effectiveAura = false,
	effectiveHealthSpeed = 0.3,
	effectivePowerSpeed = 0.3,
	effectiveAuraSpeed = 0.3,
	widgetMap = {
		[149805] = 1940, -- Farseer Ori
		[149804] = 1613, -- Hunter Akana
		[149803] = 1966, -- Bladesman Inowari
		[149904] = 1621, -- Neri Sharpfin
		[149902] = 1622, -- Poen Gillbrack
		[149906] = 1920, -- Vim Brineheart

		[154304] = 1940, -- Farseer Ori
		[150202] = 1613, -- Hunter Akana
		[154297] = 1966, -- Bladesman Inowari
		[151300] = 1621, -- Neri Sharpfin
		[151310] = 1622, -- Poen Gillbrack
		[151309] = 1920, -- Vim Brineheart

		[163541] = 2342, -- Voidtouched Egg
		[163592] = 2342, -- Yu'gaz
		[163593] = 2342, -- Bitey McStabface
		[163595] = 2342, -- Reginald
		[163596] = 2342, -- Picco
		[163648] = 2342, -- Bitey McStabface
		[163651] = 2342, -- Yu'gaz
	}
}

G.unitframe = {
	aurafilters = {},
	buffwatch = {},
	effectiveHealth = false,
	effectivePower = false,
	effectiveAura = false,
	effectiveHealthSpeed = 0.3,
	effectivePowerSpeed = 0.3,
	effectiveAuraSpeed = 0.3,
	raidDebuffIndicator = {
		instanceFilter = 'RaidDebuffs',
		otherFilter = 'CCDebuffs'
	},
	spellRangeCheck = {
		PRIEST = {
			enemySpells = {
				[585] = true, -- Smite (40 yards)
				[589] = true -- Shadow Word: Pain (40 yards)
			},
			longEnemySpells = {},
			friendlySpells = {
				[2061] = true, -- Flash Heal (40 yards)
				[17] = true -- Power Word: Shield (40 yards)
			},
			resSpells = {
				[2006] = true -- Resurrection (40 yards)
			},
			petSpells = {}
		},
		DRUID = {
			enemySpells = {
				[8921] = true -- Moonfire (40 yards, all specs, lvl 3)
			},
			longEnemySpells = {},
			friendlySpells = {
				[8936] = true -- Regrowth (40 yards, all specs, lvl 5)
			},
			resSpells = {
				[50769] = true -- Revive (40 yards, all specs, lvl 14)
			},
			petSpells = {}
		},
		PALADIN = {
			enemySpells = {
				[62124] = true, -- Hand of Reckoning (30 yards)
				[183218] = true, -- Hand of Hindrance (30 yards)
				[20271] = true, -- Judgement (30 yards) Retribution, (does not work for retribution below lvl 78)
				[275779] = true, -- Judgement (30 yards) Tank
				[275773] = true -- Judgement (30 yards) Heal
			},
			longEnemySpells = {
				[20473] = true -- Holy Shock (40 yards)
			},
			friendlySpells = {
				[19750] = true -- Flash of Light (40 yards)
			},
			resSpells = {
				[7328] = true -- Redemption (40 yards)
			},
			petSpells = {}
		},
		SHAMAN = {
			enemySpells = {
				[188196] = true, -- Lightning Bolt (Elemental) (40 yards)
				[187837] = true, -- Lightning Bolt (Enhancement) (40 yards)
				[403] = true -- Lightning Bolt (Resto) (40 yards)
			},
			longEnemySpells = {},
			friendlySpells = {
				[8004] = true, -- Healing Surge (Resto/Elemental) (40 yards)
				[188070] = true -- Healing Surge (Enhancement) (40 yards)
			},
			resSpells = {
				[2008] = true -- Ancestral Spirit (40 yards)
			},
			petSpells = {}
		},
		WARLOCK = {
			enemySpells = {
				[5782] = true -- Fear (30 yards)
			},
			longEnemySpells = {
				[234153] = true, -- Drain Life (40 yards)
				[198590] = true, --Drain Soul (40 yards)
				[232670] = true, --Shadow Bolt (40 yards, lvl 1 spell)
				[686] = true --Shadow Bolt (Demonology) (40 yards, lvl 1 spell)
			},
			friendlySpells = {
				[20707] = true -- Soulstone (40 yards)
			},
			resSpells = {},
			petSpells = {
				[755] = true -- Health Funnel (45 yards)
			}
		},
		MAGE = {
			enemySpells = {
				[118] = true -- Polymorph (30 yards)
			},
			longEnemySpells = {
				[116] = true, -- Frostbolt (Frost) (40 yards)
				[44425] = true, -- Arcane Barrage (Arcane) (40 yards)
				[133] = true -- Fireball (Fire) (40 yards)
			},
			friendlySpells = {
				[130] = true -- Slow Fall (40 yards)
			},
			resSpells = {},
			petSpells = {}
		},
		HUNTER = {
			enemySpells = {
				[75] = true -- Auto Shot (40 yards)
			},
			longEnemySpells = {},
			friendlySpells = {},
			resSpells = {},
			petSpells = {
				[982] = true -- Mend Pet (45 yards)
			}
		},
		DEATHKNIGHT = {
			enemySpells = {
				[49576] = true -- Death Grip
			},
			longEnemySpells = {
				[47541] = true -- Death Coil (Unholy) (40 yards)
			},
			friendlySpells = {},
			resSpells = {
				[61999] = true -- Raise Ally (40 yards)
			},
			petSpells = {}
		},
		ROGUE = {
			enemySpells = {
				[185565] = true, -- Poisoned Knife (Assassination) (30 yards)
				[185763] = true, -- Pistol Shot (Outlaw) (20 yards)
				[114014] = true, -- Shuriken Toss (Sublety) (30 yards)
				[1725] = true -- Distract (30 yards)
			},
			longEnemySpells = {},
			friendlySpells = {
				[57934] = true -- Tricks of the Trade (100 yards)
			},
			resSpells = {},
			petSpells = {}
		},
		WARRIOR = {
			enemySpells = {
				[5246] = true, -- Intimidating Shout (Arms/Fury) (8 yards)
				[100] = true -- Charge (Arms/Fury) (8-25 yards)
			},
			longEnemySpells = {
				[355] = true -- Taunt (30 yards)
			},
			friendlySpells = {},
			resSpells = {},
			petSpells = {}
		},
		MONK = {
			enemySpells = {
				[115546] = true -- Provoke (30 yards)
			},
			longEnemySpells = {
				[117952] = true -- Crackling Jade Lightning (40 yards)
			},
			friendlySpells = {
				[116670] = true -- Vivify (40 yards)
			},
			resSpells = {
				[115178] = true -- Resuscitate (40 yards)
			},
			petSpells = {}
		},
		DEMONHUNTER = {
			enemySpells = {
				[183752] = true -- Consume Magic (20 yards)
			},
			longEnemySpells = {
				[185123] = true, -- Throw Glaive (Havoc) (30 yards)
				[204021] = true -- Fiery Brand (Vengeance) (30 yards)
			},
			friendlySpells = {},
			resSpells = {},
			petSpells = {}
		}
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
			raid = true,
			raid40 = true,
			raidpet = true,
			tank = true,
			assist = true
		}
	}
}
