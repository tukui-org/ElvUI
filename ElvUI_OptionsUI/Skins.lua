local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local B = E:GetModule('Blizzard')
local ACH = E.Libs.ACH

local pairs = pairs

local Skins = ACH:Group(L["Skins"], nil, 2, 'tab')
E.Options.args.skins = Skins

Skins.args.intro = ACH:Description(L["SKINS_DESC"], 0)
Skins.args.general = ACH:MultiSelect(L["General"], nil, 1, nil, nil, nil, function(_, key) if key == 'blizzardEnable' then return E.private.skins.blizzard.enable else return E.private.skins[key] end end, function(_, key, value) if key == 'blizzardEnable' then E.private.skins.blizzard.enable = value else E.private.skins[key] = value end E.ShowPopup = true end)
Skins.args.general.sortByValue = true
Skins.args.general.values = { ace3Enable = 'Ace3', blizzardEnable = L["Blizzard"], checkBoxSkin = L["CheckBox Skin"], parchmentRemoverEnable = L["Parchment Remover"] }

Skins.args.talkingHead = ACH:Group(L["TalkingHead"], nil, 2, nil, function(info) return E.db.general[info[#info]] end, nil, nil, not E.Retail)
Skins.args.talkingHead.inline = true
Skins.args.talkingHead.args.talkingHeadFrameScale = ACH:Range(L["Talking Head Scale"], nil, 1, { min = .5, max = 2, step = .01, isPercent = true }, nil, nil, function(_, value) E.db.general.talkingHeadFrameScale = value; B:ScaleTalkingHeadFrame() end)
Skins.args.talkingHead.args.talkingHeadFrameBackdrop = ACH:Toggle(L["Talking Head Backdrop"], nil, 2, nil, nil, nil, nil, function(_, value) E.db.general.talkingHeadFrameBackdrop = value; E.ShowPopup = true end)

local function ToggleSkins(value)
	for key in pairs(E.private.skins.blizzard) do
		if key ~= 'enable' then
			E.private.skins.blizzard[key] = value
		end
	end
end

Skins.args.disableBlizzardSkins = ACH:Execute(L["Disable Blizzard Skins"], nil, 3, function() ToggleSkins(false); E.ShowPopup = true end)
Skins.args.enableBlizzardSkins = ACH:Execute(L["Enable Blizzard Skins"], nil, 4, function() ToggleSkins(true); E.ShowPopup = true end)
Skins.args.blizzard = ACH:MultiSelect(L["Blizzard"], L["TOGGLESKIN_DESC"], -1, nil, nil, nil, function(_, key) return E.private.skins.blizzard[key] end, function(_, key, value) E.private.skins.blizzard[key] = value; E.ShowPopup = true end, function() return not E.private.skins.blizzard.enable end)
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
	friends = L["Friends"],
	gbank = L["Guild Bank"],
	gossip = L["Gossip Frame"],
	guild = L["Guild"],
	guildcontrol = L["Guild Control Frame"],
	guildregistrar = L["Guild Registrar"],
	help = L["Help Frame"],
	inspect = L["Inspect"],
	lfg = L["LFG_TITLE"],
	loot = L["Loot Frame"],
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

local blizzard = Skins.args.blizzard.values
if E.Retail then
	blizzard.adventureMap = L["ADVENTURE_MAP_TITLE"]
	blizzard.alliedRaces = L["Allied Races"]
	blizzard.animaDiversion = L["Anima Diversion"]
	blizzard.archaeology = L["Archaeology Frame"]
	blizzard.artifact = L["ITEM_QUALITY6_DESC"]
	blizzard.azerite = L["Azerite"]
	blizzard.azeriteEssence = L["Azerite Essence"]
	blizzard.azeriteRespec = L["AZERITE_RESPEC_TITLE"]
	blizzard.bmah = L["BLACK_MARKET_AUCTION_HOUSE"]
	blizzard.chromieTime = L["Chromie Time Frame"]
	blizzard.collections = L["COLLECTIONS"]
	blizzard.contribution = L["Contribution"]
	blizzard.covenantPreview = L["Covenant Preview"]
	blizzard.covenantRenown = L["Covenant Renown"]
	blizzard.covenantSanctum = L["Covenant Sanctum"]
	blizzard.deathRecap = L["DEATH_RECAP_TITLE"]
	blizzard.encounterjournal = L["ENCOUNTER_JOURNAL"]
	blizzard.garrison = L["GARRISON_LOCATION_TOOLTIP"]
	blizzard.gmChat = L["GM Chat"]
	blizzard.guide = L["Guide Frame"]
	blizzard.islandQueue = L["ISLANDS_HEADER"]
	blizzard.islandsPartyPose = L["Island Party Pose"]
	blizzard.itemInteraction = L["Item Interaction"]
	blizzard.itemUpgrade = L["Item Upgrade"]
	blizzard.lfguild = L["LF Guild Frame"]
	blizzard.losscontrol = L["LOSS_OF_CONTROL"]
	blizzard.nonraid = L["Non-Raid Frame"]
	blizzard.objectiveTracker = L["OBJECTIVES_TRACKER_LABEL"]
	blizzard.obliterum = L["OBLITERUM_FORGE_TITLE"]
	blizzard.orderhall = L["Orderhall"]
	blizzard.petbattleui = L["Pet Battle"]
	blizzard.playerChoice = L["Player Choice Frame"]
	blizzard.runeforge = L["Runeforge"]
	blizzard.scrapping = L["SCRAP_BUTTON"]
	blizzard.soulbinds = L["Soulbinds"]
	blizzard.talkinghead = L["TalkingHead"]
	blizzard.torghastLevelPicker = L["Torghast Level Picker"]
	blizzard.transmogrify = L["TRANSMOGRIFY"]
	blizzard.voidstorage = L["VOID_STORAGE"]
	blizzard.weeklyRewards = L["Weekly Rewards"]
else
	if not E.Classic then
		blizzard.arena = L["Arena"]
		blizzard.arenaRegistrar = L["Arena Registrar"]
	end

	if not E.Wrath then
		blizzard.craft = L["Craft"]
	end

	blizzard.battlefield = L["Battlefield"]
end

if E.Retail or E.Wrath then
	blizzard.achievement = L["ACHIEVEMENTS"]
	blizzard.alertframes = L["Alert Frames"]
	blizzard.barber = L["BARBERSHOP"]
	blizzard.calendar = L["Calendar Frame"]
	blizzard.pvp = L["PvP Frames"]
end
