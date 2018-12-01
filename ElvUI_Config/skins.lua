local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.Options.args.skins = {
	type = "group",
	name = L["Skins"],
	childGroups = "tree",
	args = {
		intro = {
			order = 0,
			type = "description",
			name = L["SKINS_DESC"],
		},
		blizzardEnable = {
			order = 1,
			type = 'toggle',
			name = L["Blizzard"],
			get = function(info) return E.private.skins.blizzard.enable end,
			set = function(info, value) E.private.skins.blizzard.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
		},
		ace3 = {
			order = 2,
			type = 'toggle',
			name = L["Ace3"],
			get = function(info) return E.private.skins.ace3.enable end,
			set = function(info, value) E.private.skins.ace3.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
		},
		parchmentRemover = {
			order = 3,
			type = 'toggle',
			name = L["Parchment Remover"],
			get = function(info) return E.private.skins.parchmentRemover.enable end,
			set = function(info, value) E.private.skins.parchmentRemover.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
		},
		blizzard = {
			order = 300,
			type = 'group',
			name = L["Blizzard"],
			get = function(info) return E.private.skins.blizzard[ info[#info] ] end,
			set = function(info, value) E.private.skins.blizzard[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				deathRecap = {
					type = 'toggle',
					name = DEATH_RECAP_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				garrison = {
					type = 'toggle',
					name = GARRISON_LOCATION_TOOLTIP,
					desc = L["TOGGLESKIN_DESC"],
				},
				bmah = {
					type = 'toggle',
					name = BLACK_MARKET_AUCTION_HOUSE,
					desc = L["TOGGLESKIN_DESC"],
				},
				transmogrify = {
					type = 'toggle',
					name = TRANSMOGRIFY,
					desc = L["TOGGLESKIN_DESC"],
				},
				encounterjournal = {
					type = "toggle",
					name = ENCOUNTER_JOURNAL,
					desc = L["TOGGLESKIN_DESC"],
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				achievement = {
					type = "toggle",
					name = ACHIEVEMENTS,
					desc = L["TOGGLESKIN_DESC"],
				},
				lfguild = {
					type = "toggle",
					name = L["LF Guild Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				inspect = {
					type = "toggle",
					name = INSPECT,
					desc = L["TOGGLESKIN_DESC"],
				},
				binding = {
					type = "toggle",
					name = KEY_BINDING,
					desc = L["TOGGLESKIN_DESC"],
				},
				gbank = {
					type = "toggle",
					name = GUILD_BANK,
					desc = L["TOGGLESKIN_DESC"],
				},
				archaeology = {
					type = "toggle",
					name = L["Archaeology Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				guildcontrol = {
					type = "toggle",
					name = L["Guild Control Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				guild = {
					type = "toggle",
					name = GUILD,
					desc = L["TOGGLESKIN_DESC"],
				},
				tradeskill = {
					type = "toggle",
					name = TRADESKILLS,
					desc = L["TOGGLESKIN_DESC"],
				},
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				talent = {
					type = "toggle",
					name = TALENTS,
					desc = L["TOGGLESKIN_DESC"],
				},
				auctionhouse = {
					type = "toggle",
					name = AUCTIONS,
					desc = L["TOGGLESKIN_DESC"],
				},
				timemanager = {
					type = "toggle",
					name = TIMEMANAGER_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				barber = {
					type = "toggle",
					name = BARBERSHOP,
					desc = L["TOGGLESKIN_DESC"],
				},
				macro = {
					type = "toggle",
					name = MACROS,
					desc = L["TOGGLESKIN_DESC"],
				},
				debug = {
					type = "toggle",
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"],
				},
				trainer = {
					type = "toggle",
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				socket = {
					type = "toggle",
					name = L["Socket Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				alertframes = {
					type = "toggle",
					name = L["Alert Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				loot = {
					type = "toggle",
					name = L["Loot Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				bgscore = {
					type = "toggle",
					name = L["BG Score"],
					desc = L["TOGGLESKIN_DESC"],
				},
				merchant = {
					type = "toggle",
					name = L["Merchant Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				mail = {
					type = "toggle",
					name = L["Mail Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				help = {
					type = "toggle",
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				trade = {
					type = "toggle",
					name = TRADE,
					desc = L["TOGGLESKIN_DESC"],
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				worldmap = {
					type = "toggle",
					name = WORLD_MAP,
					desc = L["TOGGLESKIN_DESC"],
				},
				taxi = {
					type = "toggle",
					name = FLIGHT_MAP,
					desc = L["TOGGLESKIN_DESC"],
				},
				tooltip = {
					type = "toggle",
					name = L["Tooltip"],
					desc = L["TOGGLESKIN_DESC"],
				},
				lfg = {
					type = "toggle",
					name = LFG_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				collections = {
					type = "toggle",
					name = COLLECTIONS,
					desc = L["TOGGLESKIN_DESC"],
				},
				quest = {
					type = "toggle",
					name = L["Quest Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				petition = {
					type = "toggle",
					name = L["Petition Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				dressingroom = {
					type = "toggle",
					name = DRESSUP_FRAME,
					desc = L["TOGGLESKIN_DESC"],
				},
				pvp = {
					type = "toggle",
					name = L["PvP Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				nonraid = {
					type = "toggle",
					name = L["Non-Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				friends = {
					type = "toggle",
					name = FRIENDS,
					desc = L["TOGGLESKIN_DESC"],
				},
				spellbook = {
					type = "toggle",
					name = SPELLBOOK,
					desc = L["TOGGLESKIN_DESC"],
				},
				character = {
					type = "toggle",
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				misc = {
					type = "toggle",
					name = L["Misc Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				tabard = {
					type = "toggle",
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				guildregistrar = {
					type = "toggle",
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"],
				},
				bags = {
					type = "toggle",
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],
				},
				stable = {
					type = "toggle",
					name = L["Stable"],
					desc = L["TOGGLESKIN_DESC"],
				},
				bgmap = {
					type = "toggle",
					name = L["BG Map"],
					desc = L["TOGGLESKIN_DESC"],
				},
				petbattleui = {
					type = "toggle",
					name = L["Pet Battle"],
					desc = L["TOGGLESKIN_DESC"],
				},
				losscontrol = {
					type = "toggle",
					name = LOSS_OF_CONTROL,
					desc = L["TOGGLESKIN_DESC"],
				},
				voidstorage = {
					type = "toggle",
					name = VOID_STORAGE,
					desc = L["TOGGLESKIN_DESC"],
				},
				itemUpgrade = {
					type = "toggle",
					name = L["Item Upgrade"],
					desc = L["TOGGLESKIN_DESC"],
				},
				questChoice = {
					type = "toggle",
					name = L["Quest Choice"],
					desc = L["TOGGLESKIN_DESC"],
				},
				addonManager = {
					type = "toggle",
					name = L["AddOn Manager"],
					desc = L["TOGGLESKIN_DESC"],
				},
				mirrorTimers = {
					type = "toggle",
					name = L["Mirror Timers"],
					desc = L["TOGGLESKIN_DESC"],
				},
				objectiveTracker = {
					type = "toggle",
					name = OBJECTIVES_TRACKER_LABEL,
					desc = L["TOGGLESKIN_DESC"],
				},
				orderhall = {
					type = "toggle",
					name = L["Orderhall"],
					desc = L["TOGGLESKIN_DESC"],
				},
				artifact = {
					type = "toggle",
					name = ITEM_QUALITY6_DESC,
					desc = L["TOGGLESKIN_DESC"],
				},
				talkinghead = {
					type = "toggle",
					name = L["TalkingHead"],
					desc = L["TOGGLESKIN_DESC"],
				},
				AdventureMap = {
					type = "toggle",
					name = ADVENTURE_MAP_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				Obliterum = {
					type = "toggle",
					name = OBLITERUM_FORGE_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				Contribution = {
					type = "toggle",
					name = L["Contribution"],
					desc = L["TOGGLESKIN_DESC"],
				},
				BlizzardOptions = {
					type = "toggle",
					name = INTERFACE_OPTIONS,
					desc = L["TOGGLESKIN_DESC"],
				},
				Warboard = {
					type = "toggle",
					name = L["Warboard"],
					desc = L["TOGGLESKIN_DESC"],
				},
				AlliedRaces = {
					type = "toggle",
					name = L["Allied Races"],
					desc = L["TOGGLESKIN_DESC"],
				},
				Channels  = {
					type = "toggle",
					name = CHANNELS,
					desc = L["TOGGLESKIN_DESC"],
				},
				AzeriteUI = {
					type = "toggle",
					name = L["AzeriteUI"],
					desc = L["TOGGLESKIN_DESC"],
				},
				Communities = {
					type = "toggle",
					name = COMMUNITIES,
					desc = L["TOGGLESKIN_DESC"],
				},
				Scrapping = {
					type = "toggle",
					name = SCRAP_BUTTON,
					desc = L["TOGGLESKIN_DESC"],
				},
				IslandsPartyPose = {
					type = "toggle",
					name = L["Island Party Pose"],
					desc = L["TOGGLESKIN_DESC"],
				},
				IslandQueue = {
					type = "toggle",
					name = ISLANDS_HEADER,
					desc = L["TOGGLESKIN_DESC"],
				},
				AzeriteRespec = {
					type = "toggle",
					name = AZERITE_RESPEC_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
			},
		},
	},
}
