local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

E.Options.args.skins = {
	type = "group",
	name = L["Skins"],
	childGroups = "tree",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["SKINS_DESC"],
		},
		blizzardEnable = {
			order = 2,
			type = 'toggle',
			name = 'Blizzard',
			get = function(info) return E.private.skins.blizzard.enable end,
			set = function(info, value) E.private.skins.blizzard.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
		},
		ace3 = {
			order = 3,
			type = 'toggle',
			name = 'Ace3',
			get = function(info) return E.private.skins.ace3.enable end,
			set = function(info, value) E.private.skins.ace3.enable = value; E:StaticPopup_Show("PRIVATE_RL") end,
		},
		blizzard = {
			order = 300,
			type = 'group',
			name = 'Blizzard',
			get = function(info) return E.private.skins.blizzard[ info[#info] ] end,
			set = function(info, value) E.private.skins.blizzard[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				deathRecap = {
					type = 'toggle',
					name = L["Death Recap"],
					desc = L["TOGGLESKIN_DESC"],
				},
				garrison = {
					type = 'toggle',
					name = GARRISON_LOCATION_TOOLTIP,
					desc = L["TOGGLESKIN_DESC"],
				},
				bmah = {
					type = 'toggle',
					name = L["Black Market AH"],
					desc = L["TOGGLESKIN_DESC"],
				},
				transmogrify = {
					type = 'toggle',
					name = L["Transmogrify Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				encounterjournal = {
					type = "toggle",
					name = L["Encounter Journal"],
					desc = L["TOGGLESKIN_DESC"],
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				achievement = {
					type = "toggle",
					name = L["Achievement Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				lfguild = {
					type = "toggle",
					name = L["LF Guild Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				inspect = {
					type = "toggle",
					name = L["Inspect Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				binding = {
					type = "toggle",
					name = L["KeyBinding Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				gbank = {
					type = "toggle",
					name = L["Guild Bank"],
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
					name = L["Guild Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				tradeskill = {
					type = "toggle",
					name = L["TradeSkill Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				talent = {
					type = "toggle",
					name = L["Talent Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				auctionhouse = {
					type = "toggle",
					name = L["Auction Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				timemanager = {
					type = "toggle",
					name = L["Time Manager"],
					desc = L["TOGGLESKIN_DESC"],
				},
				barber = {
					type = "toggle",
					name = L["Barbershop Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				macro = {
					type = "toggle",
					name = L["Macro Frame"],
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
					name = L["Trade Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				greeting = {
					type = "toggle",
					name = L["Greeting Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				worldmap = {
					type = "toggle",
					name = L["World Map"],
					desc = L["TOGGLESKIN_DESC"],
				},
				taxi = {
					type = "toggle",
					name = L["Taxi Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				lfg = {
					type = "toggle",
					name = L["LFG Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				mounts = {
					type = "toggle",
					name = L["Mounts & Pets"],
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
					name = L["Dressing Room"],
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
					name = L["Friends"],
					desc = L["TOGGLESKIN_DESC"],
				},
				spellbook = {
					type = "toggle",
					name = L["Spellbook"],
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
					name = L["Loss Control"],
					desc = L["TOGGLESKIN_DESC"],
				},
				voidstorage = {
					type = "toggle",
					name = L["Void Storage"],
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
			},
		},
	},
}