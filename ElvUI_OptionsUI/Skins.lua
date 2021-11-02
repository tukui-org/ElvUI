local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(E.OptionsUI)
local B = E:GetModule('Blizzard')
local ACH = E.Libs.ACH

local pairs = pairs

local Skins = ACH:Group(L["Skins"], nil, 2, 'tab')
E.Options.args.skins = Skins

Skins.args.intro = ACH:Description(L["SKINS_DESC"], 0)
Skins.args.general = ACH:MultiSelect(L["General"], nil, 1, nil, nil, nil, function(_, key) if key == 'blizzardEnable' then return E.private.skins.blizzard.enable else return E.private.skins[key] end end, function(_, key, value) if key == 'blizzardEnable' then E.private.skins.blizzard.enable = value else E.private.skins[key] = value end E:StaticPopup_Show('PRIVATE_RL') end)
Skins.args.general.sortByValue = true
Skins.args.general.values = { ace3Enable = 'Ace3', blizzardEnable = L["Blizzard"], checkBoxSkin = L["CheckBox Skin"], parchmentRemoverEnable = L["Parchment Remover"] }

Skins.args.talkingHead = ACH:Group(L["TalkingHead"], nil, 2, nil, function(info) return E.db.general[info[#info]] end, nil, nil, not E.Retail)
Skins.args.talkingHead.inline = true
Skins.args.talkingHead.args.talkingHeadFrameScale = ACH:Range(L["Talking Head Scale"], nil, 1, { min = .5, max = 2, step = .01, isPercent = true }, nil, nil, function(_, value) E.db.general.talkingHeadFrameScale = value; B:ScaleTalkingHeadFrame() end)
Skins.args.talkingHead.args.talkingHeadFrameBackdrop = ACH:Toggle(L["Talking Head Backdrop"], nil, 2, nil, nil, nil, nil, function(_, value) E.db.general.talkingHeadFrameBackdrop = value; E:StaticPopup_Show('CONFIG_RL') end)

local function ToggleSkins(value)
	for key in pairs(E.private.skins.blizzard) do
		if key ~= 'enable' then
			E.private.skins.blizzard[key] = value
		end
	end
end

Skins.args.disableBlizzardSkins = ACH:Execute(L["Disable Blizzard Skins"], nil, 3, function() ToggleSkins(false); E:StaticPopup_Show('PRIVATE_RL') end)
Skins.args.enableBlizzardSkins = ACH:Execute(L["Enable Blizzard Skins"], nil, 4, function() ToggleSkins(true); E:StaticPopup_Show('PRIVATE_RL') end)
Skins.args.blizzard = ACH:MultiSelect(L["Blizzard"], L["TOGGLESKIN_DESC"], -1, nil, nil, nil, function(_, key) return E.private.skins.blizzard[key] end, function(_, key, value) E.private.skins.blizzard[key] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.private.skins.blizzard.enable end)
Skins.args.blizzard.sortByValue = true
Skins.args.blizzard.values = {
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
	gbank = L["GUILD_BANK"],
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
	Skins.args.blizzard.values.achievement = L["ACHIEVEMENTS"]
	Skins.args.blizzard.values.adventureMap = L["ADVENTURE_MAP_TITLE"]
	Skins.args.blizzard.values.alertframes = L["Alert Frames"]
	Skins.args.blizzard.values.alliedRaces = L["Allied Races"]
	Skins.args.blizzard.values.animaDiversion = L["Anima Diversion"]
	Skins.args.blizzard.values.artifact = L["ITEM_QUALITY6_DESC"]
	Skins.args.blizzard.values.archaeology = L["Archaeology Frame"]
	Skins.args.blizzard.values.azeriteEssence = L["Azerite Essence"]
	Skins.args.blizzard.values.azeriteRespec = L["AZERITE_RESPEC_TITLE"]
	Skins.args.blizzard.values.azerite = L["Azerite"]
	Skins.args.blizzard.values.barber = L["BARBERSHOP"]
	Skins.args.blizzard.values.bmah = L["BLACK_MARKET_AUCTION_HOUSE"]
	Skins.args.blizzard.values.calendar = L["Calendar Frame"]
	Skins.args.blizzard.values.chromieTime = L["Chromie Time Frame"]
	Skins.args.blizzard.values.collections = L["COLLECTIONS"]
	Skins.args.blizzard.values.contribution = L["Contribution"]
	Skins.args.blizzard.values.covenantPreview = L["Covenant Preview"]
	Skins.args.blizzard.values.covenantRenown = L["Covenant Renown"]
	Skins.args.blizzard.values.covenantSanctum = L["Covenant Sanctum"]
	Skins.args.blizzard.values.deathRecap = L["DEATH_RECAP_TITLE"]
	Skins.args.blizzard.values.encounterjournal = L["ENCOUNTER_JOURNAL"]
	Skins.args.blizzard.values.garrison = L["GARRISON_LOCATION_TOOLTIP"]
	Skins.args.blizzard.values.gmChat = L["GM Chat"]
	Skins.args.blizzard.values.guide = L["Guide Frame"]
	Skins.args.blizzard.values.islandQueue = L["ISLANDS_HEADER"]
	Skins.args.blizzard.values.islandsPartyPose = L["Island Party Pose"]
	Skins.args.blizzard.values.itemInteraction = L["Item Interaction"]
	Skins.args.blizzard.values.itemUpgrade = L["Item Upgrade"]
	Skins.args.blizzard.values.lfguild = L["LF Guild Frame"]
	Skins.args.blizzard.values.losscontrol = L["LOSS_OF_CONTROL"]
	Skins.args.blizzard.values.nonraid = L["Non-Raid Frame"]
	Skins.args.blizzard.values.objectiveTracker = L["OBJECTIVES_TRACKER_LABEL"]
	Skins.args.blizzard.values.obliterum = L["OBLITERUM_FORGE_TITLE"]
	Skins.args.blizzard.values.orderhall = L["Orderhall"]
	Skins.args.blizzard.values.petbattleui = L["Pet Battle"]
	Skins.args.blizzard.values.playerChoice = L["Player Choice Frame"]
	Skins.args.blizzard.values.pvp = L["PvP Frames"]
	Skins.args.blizzard.values.runeforge = L["Runeforge"]
	Skins.args.blizzard.values.scrapping = L["SCRAP_BUTTON"]
	Skins.args.blizzard.values.soulbinds = L["Soulbinds"]
	Skins.args.blizzard.values.talkinghead = L["TalkingHead"]
	Skins.args.blizzard.values.torghastLevelPicker = L["Torghast Level Picker"]
	Skins.args.blizzard.values.transmogrify = L["TRANSMOGRIFY"]
	Skins.args.blizzard.values.voidstorage = L["VOID_STORAGE"]
	Skins.args.blizzard.values.weeklyRewards = L["Weekly Rewards"]
elseif E.TBC then
	Skins.args.blizzard.values.arena = L["Arena"]
	Skins.args.blizzard.values.arenaRegistrar = L["Arena Registrar"]
	Skins.args.blizzard.values.battlefield = L["Battlefield"]
	Skins.args.blizzard.values.craft = L["Craft"]
elseif E.Classic then
	Skins.args.blizzard.values.battlefield = L["Battlefield"]
	Skins.args.blizzard.values.craft = L["Craft"]
end
