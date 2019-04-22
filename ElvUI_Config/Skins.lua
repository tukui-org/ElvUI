local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

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
		general = {
			order = 1,
			type = 'group',
			name = L["General"],
			guiInline = true,
			args = {
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
					name = "Ace3",
					get = function(info) return E.private.skins.ace3.enable end,
					set = function(info, value) E.private.skins.ace3.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
				},
				checkBoxSkin = {
					order = 3,
					type = "toggle",
					name = L["CheckBox Skin"],
					get = function(info) return E.private.skins.checkBoxSkin end,
					set = function(info, value) E.private.skins.checkBoxSkin = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				parchmentRemover = {
					order = 4,
					type = 'toggle',
					name = L["Parchment Remover"],
					get = function(info) return E.private.skins.parchmentRemover.enable end,
					set = function(info, value) E.private.skins.parchmentRemover.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
				},
			},
		},
		talkingHead = {
			order = 2,
			type = 'group',
			name = L["TalkingHead"],
			guiInline = true,
			args = {
				talkingHeadFrameScale = {
					order = 24,
					type = "range",
					name = L["Talking Head Scale"],
					isPercent = true,
					min = 0.5, max = 2, step = 0.01,
					get = function(info) return E.db.general.talkingHeadFrameScale end,
					set = function(info, value) E.db.general.talkingHeadFrameScale = value; B:ScaleTalkingHeadFrame() end,
				},
				talkingHeadFrameBackdrop = {
					order = 25,
					type = "toggle",
					name = L["Talking Head Backdrop"],
					get = function(info) return E.db.general.talkingHeadFrameBackdrop end,
					set = function(info, value) E.db.general.talkingHeadFrameBackdrop = value; E:StaticPopup_Show("CONFIG_RL") end
				},
			},
		},
		blizzard = {
			order = 300,
			type = 'group',
			name = L["Blizzard"],
			get = function(info) return E.private.skins.blizzard[info[#info]] end,
			set = function(info, value) E.private.skins.blizzard[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				deathRecap = {
					type = 'toggle',
					name = L.DEATH_RECAP_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				garrison = {
					type = 'toggle',
					name = L.GARRISON_LOCATION_TOOLTIP,
					desc = L["TOGGLESKIN_DESC"],
				},
				bmah = {
					type = 'toggle',
					name = L.BLACK_MARKET_AUCTION_HOUSE,
					desc = L["TOGGLESKIN_DESC"],
				},
				transmogrify = {
					type = 'toggle',
					name = L.TRANSMOGRIFY,
					desc = L["TOGGLESKIN_DESC"],
				},
				encounterjournal = {
					type = "toggle",
					name = L.ENCOUNTER_JOURNAL,
					desc = L["TOGGLESKIN_DESC"],
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				achievement = {
					type = "toggle",
					name = L.ACHIEVEMENTS,
					desc = L["TOGGLESKIN_DESC"],
				},
				lfguild = {
					type = "toggle",
					name = L["LF Guild Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				inspect = {
					type = "toggle",
					name = L.INSPECT,
					desc = L["TOGGLESKIN_DESC"],
				},
				binding = {
					type = "toggle",
					name = L.KEY_BINDINGS,
					desc = L["TOGGLESKIN_DESC"],
				},
				gbank = {
					type = "toggle",
					name = L.GUILD_BANK,
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
					name = L.GUILD,
					desc = L["TOGGLESKIN_DESC"],
				},
				tradeskill = {
					type = "toggle",
					name = L.TRADESKILLS,
					desc = L["TOGGLESKIN_DESC"],
				},
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				talent = {
					type = "toggle",
					name = L.TALENTS,
					desc = L["TOGGLESKIN_DESC"],
				},
				auctionhouse = {
					type = "toggle",
					name = L.AUCTIONS,
					desc = L["TOGGLESKIN_DESC"],
				},
				timemanager = {
					type = "toggle",
					name = L.TIMEMANAGER_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				barber = {
					type = "toggle",
					name = L.BARBERSHOP,
					desc = L["TOGGLESKIN_DESC"],
				},
				macro = {
					type = "toggle",
					name = L.MACROS,
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
					name = L.TRADE,
					desc = L["TOGGLESKIN_DESC"],
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				worldmap = {
					type = "toggle",
					name = L.WORLD_MAP,
					desc = L["TOGGLESKIN_DESC"],
				},
				taxi = {
					type = "toggle",
					name = L.FLIGHT_MAP,
					desc = L["TOGGLESKIN_DESC"],
				},
				tooltip = {
					type = "toggle",
					name = L["Tooltip"],
					desc = L["TOGGLESKIN_DESC"],
				},
				lfg = {
					type = "toggle",
					name = L.LFG_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				collections = {
					type = "toggle",
					name = L.COLLECTIONS,
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
					name = L.DRESSUP_FRAME,
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
					name = L.FRIENDS,
					desc = L["TOGGLESKIN_DESC"],
				},
				spellbook = {
					type = "toggle",
					name = L.SPELLBOOK,
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
					name = L.LOSS_OF_CONTROL,
					desc = L["TOGGLESKIN_DESC"],
				},
				voidstorage = {
					type = "toggle",
					name = L.VOID_STORAGE,
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
					name = L.OBJECTIVES_TRACKER_LABEL,
					desc = L["TOGGLESKIN_DESC"],
				},
				orderhall = {
					type = "toggle",
					name = L["Orderhall"],
					desc = L["TOGGLESKIN_DESC"],
				},
				artifact = {
					type = "toggle",
					name = L.ITEM_QUALITY6_DESC,
					desc = L["TOGGLESKIN_DESC"],
				},
				talkinghead = {
					type = "toggle",
					name = L["TalkingHead"],
					desc = L["TOGGLESKIN_DESC"],
				},
				AdventureMap = {
					type = "toggle",
					name = L.ADVENTURE_MAP_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				Obliterum = {
					type = "toggle",
					name = L.OBLITERUM_FORGE_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				Contribution = {
					type = "toggle",
					name = L["Contribution"],
					desc = L["TOGGLESKIN_DESC"],
				},
				BlizzardOptions = {
					type = "toggle",
					name = L.INTERFACE_OPTIONS,
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
					name = L.CHANNELS,
					desc = L["TOGGLESKIN_DESC"],
				},
				AzeriteUI = {
					type = "toggle",
					name = L["AzeriteUI"],
					desc = L["TOGGLESKIN_DESC"],
				},
				Communities = {
					type = "toggle",
					name = L.COMMUNITIES,
					desc = L["TOGGLESKIN_DESC"],
				},
				Scrapping = {
					type = "toggle",
					name = L.SCRAP_BUTTON,
					desc = L["TOGGLESKIN_DESC"],
				},
				IslandsPartyPose = {
					type = "toggle",
					name = L["Island Party Pose"],
					desc = L["TOGGLESKIN_DESC"],
				},
				IslandQueue = {
					type = "toggle",
					name = L.ISLANDS_HEADER,
					desc = L["TOGGLESKIN_DESC"],
				},
				AzeriteRespec = {
					type = "toggle",
					name = L.AZERITE_RESPEC_TITLE,
					desc = L["TOGGLESKIN_DESC"],
				},
				GMChat = {
					type = "toggle",
					name = L["GM Chat"],
					desc = L["TOGGLESKIN_DESC"],
				},
			},
		},
	},
}
