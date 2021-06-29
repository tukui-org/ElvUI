local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
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
	achievement = L["ACHIEVEMENTS"],
	addonManager = L["AddOn Manager"],
	adventureMap = L["ADVENTURE_MAP_TITLE"],
	alertframes = L["Alert Frames"],
	alliedRaces = L["Allied Races"],
	animaDiversion = L["Anima Diversion"],
	archaeology = L["Archaeology Frame"],
	artifact = L["ITEM_QUALITY6_DESC"],
	auctionhouse = L["AUCTIONS"],
	azeriteEssence = L["Azerite Essence"],
	azeriteRespec = L["AZERITE_RESPEC_TITLE"],
	azerite = L["Azerite"],
	bags = L["Bags"],
	barber = L["BARBERSHOP"],
	bgmap = L["BG Map"],
	bgscore = L["BG Score"],
	binding = L["KEY_BINDINGS"],
	blizzardOptions = L["INTERFACE_OPTIONS"],
	bmah = L["BLACK_MARKET_AUCTION_HOUSE"],
	calendar = L["Calendar Frame"],
	channels  = L["CHANNELS"],
	character = L["Character Frame"],
	chromieTime = L["Chromie Time Frame"],
	collections = L["COLLECTIONS"],
	communities = L["COMMUNITIES"],
	contribution = L["Contribution"],
	covenantPreview = L["Covenant Preview"],
	covenantRenown = L["Covenant Renown"],
	covenantSanctum = L["Covenant Sanctum"],
	deathRecap = L["DEATH_RECAP_TITLE"],
	debug = L["Debug Tools"],
	dressingroom = L["DRESSUP_FRAME"],
	encounterjournal = L["ENCOUNTER_JOURNAL"],
	eventLog = L["Event Log"],
	friends = L["FRIENDS"],
	garrison = L["GARRISON_LOCATION_TOOLTIP"],
	gbank = L["GUILD_BANK"],
	gmChat = L["GM Chat"],
	gossip = L["Gossip Frame"],
	guide = L["Guide Frame"],
	guild = L["GUILD"],
	guildcontrol = L["Guild Control Frame"],
	guildregistrar = L["Guild Registrar"],
	help = L["Help Frame"],
	inspect = L["INSPECT"],
	islandQueue = L["ISLANDS_HEADER"],
	islandsPartyPose = L["Island Party Pose"],
	itemInteraction = L["Item Interaction"],
	itemUpgrade = L["Item Upgrade"],
	lfg = L["LFG_TITLE"],
	lfguild = L["LF Guild Frame"],
	loot = L["Loot Frames"],
	losscontrol = L["LOSS_OF_CONTROL"],
	macro = L["MACROS"],
	mail = L["Mail Frame"],
	merchant = L["Merchant Frame"],
	mirrorTimers = L["Mirror Timers"],
	misc = L["Misc Frames"],
	nonraid = L["Non-Raid Frame"],
	objectiveTracker = L["OBJECTIVES_TRACKER_LABEL"],
	obliterum = L["OBLITERUM_FORGE_TITLE"],
	orderhall = L["Orderhall"],
	petbattleui = L["Pet Battle"],
	petition = L["Petition Frame"],
	playerChoice = L["Player Choice Frame"],
	pvp = L["PvP Frames"],
	quest = L["Quest Frames"],
	questChoice = L["Quest Choice"],
	raid = L["Raid Frame"],
	runeforge = L["Runeforge"],
	scrapping = L["SCRAP_BUTTON"],
	socket = L["Socket Frame"],
	spellbook = L["SPELLBOOK"],
	stable = L["Stable"],
	soulbinds = L["Soulbinds"],
	tabard = L["Tabard Frame"],
	talent = L["TALENTS"],
	talkinghead = L["TalkingHead"],
	taxi = L["FLIGHT_MAP"],
	timemanager = L["TIMEMANAGER_TITLE"],
	tooltip = L["Tooltip"],
	torghastLevelPicker = L["Torghast Level Picker"],
	trade = L["TRADE"],
	tradeskill = L["TRADESKILLS"],
	trainer = L["Trainer Frame"],
	transmogrify = L["TRANSMOGRIFY"],
	tutorials = L["Tutorials"],
	voidstorage = L["VOID_STORAGE"],
	weeklyRewards = L["Weekly Rewards"],
	worldmap = L["WORLD_MAP"],
}
