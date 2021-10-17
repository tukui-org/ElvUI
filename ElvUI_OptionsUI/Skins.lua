local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(E.OptionsUI)
local B = E:GetModule('Blizzard')
local ACH = E.Libs.ACH

local pairs = pairs

E.Options.args.skins = ACH:Group(L["Skins"], nil, 2, 'tab')
E.Options.args.skins.args.intro = ACH:Description(L["SKINS_DESC"], 0)
E.Options.args.skins.args.general = ACH:MultiSelect(L["General"], nil, 1, nil, nil, nil, function(_, key) if key == 'blizzardEnable' then return E.private.skins.blizzard.enable else return E.private.skins[key] end end, function(_, key, value) if key == 'blizzardEnable' then E.private.skins.blizzard.enable = value else E.private.skins[key] = value end E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.skins.args.general.sortByValue = true
E.Options.args.skins.args.general.values = { ace3Enable = 'Ace3', blizzardEnable = L["Blizzard"], checkBoxSkin = L["CheckBox Skin"], parchmentRemoverEnable = L["Parchment Remover"] }

E.Options.args.skins.args.talkingHead = ACH:Group(L["TalkingHead"], nil, 2, nil, function(info) return E.db.general[info[#info]] end)
E.Options.args.skins.args.talkingHead.inline = true
E.Options.args.skins.args.talkingHead.args.talkingHeadFrameScale = ACH:Range(L["Talking Head Scale"], nil, 1, { min = .5, max = 2, step = .01, isPercent = true }, nil, nil, function(_, value) E.db.general.talkingHeadFrameScale = value; B:ScaleTalkingHeadFrame() end)
E.Options.args.skins.args.talkingHead.args.talkingHeadFrameBackdrop = ACH:Toggle(L["Talking Head Backdrop"], nil, 2, nil, nil, nil, nil, function(_, value) E.db.general.talkingHeadFrameBackdrop = value; E:StaticPopup_Show('CONFIG_RL') end)

local function ToggleSkins(value)
	for key in pairs(E.private.skins.blizzard) do
		if key ~= 'enable' then
			E.private.skins.blizzard[key] = value
		end
	end
end

E.Options.args.skins.args.disableBlizzardSkins = ACH:Execute(L["Disable Blizzard Skins"], nil, 3, function() ToggleSkins(false); E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.skins.args.enableBlizzardSkins = ACH:Execute(L["Enable Blizzard Skins"], nil, 4, function() ToggleSkins(true); E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.skins.args.blizzard = ACH:MultiSelect(L["Blizzard"], L["TOGGLESKIN_DESC"], -1, nil, nil, nil, function(_, key) return E.private.skins.blizzard[key] end, function(_, key, value) E.private.skins.blizzard[key] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.private.skins.blizzard.enable end)
E.Options.args.skins.args.blizzard.sortByValue = true
E.Options.args.skins.args.blizzard.values = {
	addonManager = L["AddOn Manager"],
	auctionhouse = L["AUCTIONS"],
	bags = L["Bags"],
	bgmap = L["BG Map"],
	bgscore = L["BG Score"],
	binding = L["KEY_BINDINGS"],
	blizzardOptions = L["INTERFACE_OPTIONS"],
	channels = L["CHANNELS"],
	character = L["Character Frame"],
	communities = L["COMMUNITIES"],
	debug = L["Debug Tools"],
	dressingroom = L["DRESSUP_FRAME"],
	eventLog = L["Event Log"],
	friends = L["FRIENDS"],
	gossip = L["Gossip Frame"],
	guild = L["GUILD"],
	guildcontrol = L["Guild Control Frame"],
	guildregistrar = L["Guild Registrar"],
	help = L["Help Frame"],
	inspect = L["INSPECT"],
	lfg = L["LFG_TITLE"],
	loot = L["Loot Frames"],
	macro = L["MACROS"],
	mail = L["Mail Frame"],
	merchant = L["Merchant Frame"],
	mirrorTimers = L["Mirror Timers"],
	misc = L["Misc Frames"],
	petition = L["Petition Frame"],
	quest = L["Quest Frames"],
	questChoice = L["Quest Choice"],
	raid = L["Raid Frame"],
	socket = L["Socket Frame"],
	spellbook = L["SPELLBOOK"],
	stable = L["Stable"],
	tabard = L["Tabard Frame"],
	talent = L["TALENTS"],
	taxi = L["FLIGHT_MAP"],
	timemanager = L["TIMEMANAGER_TITLE"],
	tooltip = L["Tooltip"],
	trade = L["TRADE"],
	tradeskill = L["TRADESKILLS"],
	trainer = L["Trainer Frame"],
	tutorials = L["Tutorials"],
	worldmap = L["WORLD_MAP"],
}

if E.Retail then
	E.Options.args.skins.args.blizzard.values.achievement = L["ACHIEVEMENTS"]
	E.Options.args.skins.args.blizzard.values.adventureMap = L["ADVENTURE_MAP_TITLE"]
	E.Options.args.skins.args.blizzard.values.alertframes = L["Alert Frames"]
	E.Options.args.skins.args.blizzard.values.alliedRaces = L["Allied Races"]
	E.Options.args.skins.args.blizzard.values.animaDiversion = L["Anima Diversion"]
	E.Options.args.skins.args.blizzard.values.artifact = L["ITEM_QUALITY6_DESC"]
	E.Options.args.skins.args.blizzard.values.archaeology = L["Archaeology Frame"]
	E.Options.args.skins.args.blizzard.values.azeriteEssence = L["Azerite Essence"]
	E.Options.args.skins.args.blizzard.values.azeriteRespec = L["AZERITE_RESPEC_TITLE"]
	E.Options.args.skins.args.blizzard.values.azerite = L["Azerite"]
	E.Options.args.skins.args.blizzard.values.barber = L["BARBERSHOP"]
	E.Options.args.skins.args.blizzard.values.bmah = L["BLACK_MARKET_AUCTION_HOUSE"]
	E.Options.args.skins.args.blizzard.values.calendar = L["Calendar Frame"]
	E.Options.args.skins.args.blizzard.values.chromieTime = L["Chromie Time Frame"]
	E.Options.args.skins.args.blizzard.values.collections = L["COLLECTIONS"]
	E.Options.args.skins.args.blizzard.values.contribution = L["Contribution"]
	E.Options.args.skins.args.blizzard.values.covenantPreview = L["Covenant Preview"]
	E.Options.args.skins.args.blizzard.values.covenantRenown = L["Covenant Renown"]
	E.Options.args.skins.args.blizzard.values.covenantSanctum = L["Covenant Sanctum"]
	E.Options.args.skins.args.blizzard.values.deathRecap = L["DEATH_RECAP_TITLE"]
	E.Options.args.skins.args.blizzard.values.encounterjournal = L["ENCOUNTER_JOURNAL"]
	E.Options.args.skins.args.blizzard.values.garrison = L["GARRISON_LOCATION_TOOLTIP"]
	E.Options.args.skins.args.blizzard.values.gbank = L["GUILD_BANK"]
	E.Options.args.skins.args.blizzard.values.gmChat = L["GM Chat"]
	E.Options.args.skins.args.blizzard.values.guide = L["Guide Frame"]
	E.Options.args.skins.args.blizzard.values.islandQueue = L["ISLANDS_HEADER"]
	E.Options.args.skins.args.blizzard.values.islandsPartyPose = L["Island Party Pose"]
	E.Options.args.skins.args.blizzard.values.itemInteraction = L["Item Interaction"]
	E.Options.args.skins.args.blizzard.values.itemUpgrade = L["Item Upgrade"]
	E.Options.args.skins.args.blizzard.values.lfguild = L["LF Guild Frame"]
	E.Options.args.skins.args.blizzard.values.losscontrol = L["LOSS_OF_CONTROL"]
	E.Options.args.skins.args.blizzard.values.nonraid = L["Non-Raid Frame"]
	E.Options.args.skins.args.blizzard.values.objectiveTracker = L["OBJECTIVES_TRACKER_LABEL"]
	E.Options.args.skins.args.blizzard.values.obliterum = L["OBLITERUM_FORGE_TITLE"]
	E.Options.args.skins.args.blizzard.values.orderhall = L["Orderhall"]
	E.Options.args.skins.args.blizzard.values.petbattleui = L["Pet Battle"]
	E.Options.args.skins.args.blizzard.values.playerChoice = L["Player Choice Frame"]
	E.Options.args.skins.args.blizzard.values.pvp = L["PvP Frames"]
	E.Options.args.skins.args.blizzard.values.runeforge = L["Runeforge"]
	E.Options.args.skins.args.blizzard.values.scrapping = L["SCRAP_BUTTON"]
	E.Options.args.skins.args.blizzard.values.soulbinds = L["Soulbinds"]
	E.Options.args.skins.args.blizzard.values.talkinghead = L["TalkingHead"]
	E.Options.args.skins.args.blizzard.values.torghastLevelPicker = L["Torghast Level Picker"]
	E.Options.args.skins.args.blizzard.values.transmogrify = L["TRANSMOGRIFY"]
	E.Options.args.skins.args.blizzard.values.voidstorage = L["VOID_STORAGE"]
	E.Options.args.skins.args.blizzard.values.weeklyRewards = L["Weekly Rewards"]
elseif E.TBC then
	E.Options.args.skins.args.blizzard.values.arena = L["Arena"]
	E.Options.args.skins.args.blizzard.values.arenaRegistrar = L["Arena Registrar"]
	E.Options.args.skins.args.blizzard.values.battlefield = L["Battlefield"]
	E.Options.args.skins.args.blizzard.values.craft = L["Craft"]
	E.Options.args.skins.args.blizzard.values.guildBank = L["GUILD_BANK"]
	E.Options.args.skins.args.blizzard.values.socket = L["Socket Frame"]
	E.Options.args.skins.args.blizzard.values.trainer = L["Trainer Frame"]
	E.Options.args.skins.args.blizzard.values.tutorials = L["Tutorials"]
elseif E.Classic then
	-- Beep Boop
end
