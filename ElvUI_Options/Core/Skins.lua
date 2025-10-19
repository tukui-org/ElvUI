local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local BL = E:GetModule('Blizzard')
local ACH = E.Libs.ACH

local pairs = pairs
local format = format

local toggles = {
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
	friends = format(E.Retail and '%s' or '%s & %s', L["Friends"], L["Guild"]),
	gossip = L["Gossip Frame"],
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
	worldmap = L["WORLD_MAP"]
}

if E.Mists or E.Retail then
	toggles.achievement = L["ACHIEVEMENTS"]
	toggles.alertframes = L["Alert Frames"]
	toggles.archaeology = L["Archaeology Frame"]
	toggles.barber = L["BARBERSHOP"]
	toggles.bmah = L["BLACK_MARKET_AUCTION_HOUSE"]
	toggles.calendar = L["Calendar Frame"]
	toggles.collections = L["COLLECTIONS"]
	toggles.encounterjournal = L["ENCOUNTER_JOURNAL"]
	toggles.gbank = L["Guild Bank"]
	toggles.itemUpgrade = L["Item Upgrade"]
	toggles.pvp = L["PvP Frames"]
	toggles.petbattleui = L["Pet Battle"]
	toggles.transmogrify = L["TRANSMOGRIFY"]
	toggles.guild = L["Guild"]
end

if not E.Retail then
	toggles.questTimers = L["Quest Timers"]
end

if E.Retail then
	toggles.adventureMap = L["ADVENTURE_MAP_TITLE"]
	toggles.alliedRaces = L["Allied Races"]
	toggles.animaDiversion = L["Anima Diversion"]
	toggles.artifact = L["ITEM_QUALITY6_DESC"]
	toggles.remixArtifact = format('%s %s', L["Remix"], L["ITEM_QUALITY6_DESC"])
	toggles.azerite = L["Azerite"]
	toggles.azeriteEssence = L["Azerite Essence"]
	toggles.azeriteRespec = L["AZERITE_RESPEC_TITLE"]
	toggles.campsites = L["Campsite"]
	toggles.catalogShop = L["BLIZZARD_STORE"]
	toggles.chromieTime = L["Chromie Time Frame"]
	toggles.cooldownManager = L["Cooldown Manager"]
	toggles.contribution = L["Contribution"]
	toggles.covenantPreview = L["Covenant Preview"]
	toggles.covenantRenown = L["Covenant Renown"]
	toggles.covenantSanctum = L["Covenant Sanctum"]
	toggles.deathRecap = L["DEATH_RECAP_TITLE"]
	toggles.editor = L["Editor Manager"]
	toggles.expansionLanding = L["Expansion Landing Page"]
	toggles.garrison = L["GARRISON_LOCATION_TOOLTIP"]
	toggles.genericTrait = L["Generic Trait"]
	toggles.gmChat = L["GM Chat"]
	toggles.guide = L["Guide Frame"]
	toggles.islandQueue = L["ISLANDS_HEADER"]
	toggles.islandsPartyPose = L["Island Party Pose"]
	toggles.itemInteraction = L["Item Interaction"]
	toggles.lfguild = L["LF Guild Frame"]
	toggles.losscontrol = L["LOSS_OF_CONTROL"]
	toggles.majorFactions = L["Major Factions"]
	toggles.nonraid = L["Non-Raid Frame"]
	toggles.objectiveTracker = L["OBJECTIVES_TRACKER_LABEL"]
	toggles.obliterum = L["OBLITERUM_FORGE_TITLE"]
	toggles.orderhall = L["Orderhall"]
	toggles.perks = L["Trading Post"]
	toggles.playerChoice = L["Player Choice Frame"]
	toggles.runeforge = L["Runeforge"]
	toggles.scrapping = L["SCRAP_BUTTON"]
	toggles.soulbinds = L["Soulbinds"]
	toggles.talkinghead = L["Talking Head"]
	toggles.torghastLevelPicker = L["Torghast Level Picker"]
	toggles.weeklyRewards = L["Weekly Rewards"]
elseif E.Mists then
	toggles.arenaRegistrar = L["Arena Registrar"]
	toggles.reforge = L["Reforge"]
elseif E.Classic then
	toggles.engraving = L["Engraving"]
	toggles.battlefield = L["Battlefield"]
	toggles.craft = L["Craft"]
end

local function ToggleSkins(value)
	E.ShowPopup = true

	for key in pairs(E.private.skins.blizzard) do
		if key ~= 'enable' then
			E.private.skins.blizzard[key] = value
		end
	end
end

local Skins = ACH:Group(L["Skins"], nil, 2, 'tab')
E.Options.args.skins = Skins

Skins.args.intro = ACH:Description(L["SKINS_DESC"], 0)
Skins.args.general = ACH:MultiSelect(L["General"], nil, 1, { ace3Enable = 'Ace3', libDropdown = L["Library Dropdown"], blizzardEnable = L["Blizzard"], checkBoxSkin = L["CheckBox Skin"], parchmentRemoverEnable = L["Parchment Remover"] }, nil, 140, function(_, key) if key == 'blizzardEnable' then return E.private.skins.blizzard.enable else return E.private.skins[key] end end, function(_, key, value) if key == 'blizzardEnable' then E.private.skins.blizzard.enable = value else E.private.skins[key] = value end E.ShowPopup = true end, nil, nil, true)

Skins.args.talkingHead = ACH:Group(L["Talking Head"], nil, 2, nil, function(info) return E.db.general[info[#info]] end, nil, nil, not E.Retail)
Skins.args.talkingHead.args.talkingHeadFrameScale = ACH:Range(L["Talking Head Scale"], nil, 1, { min = .5, max = 2, step = .01, isPercent = true }, nil, nil, function(_, value) E.db.general.talkingHeadFrameScale = value; BL:ScaleTalkingHeadFrame() end)
Skins.args.talkingHead.args.talkingHeadFrameBackdrop = ACH:Toggle(L["Talking Head Backdrop"], nil, 2, nil, nil, nil, nil, function(_, value) E.db.general.talkingHeadFrameBackdrop = value; E.ShowPopup = true end)
Skins.args.talkingHead.inline = true

Skins.args.disableBlizzardSkins = ACH:Execute(L["Disable Blizzard Skins"], nil, 3, function() ToggleSkins(false) end)
Skins.args.enableBlizzardSkins = ACH:Execute(L["Enable Blizzard Skins"], nil, 4, function() ToggleSkins(true) end)

Skins.args.blizzard = ACH:MultiSelect(L["Blizzard"], L["TOGGLESKIN_DESC"], -1, toggles, nil, nil, function(_, key) return E.private.skins.blizzard[key] end, function(_, key, value) E.private.skins.blizzard[key] = value; E.ShowPopup = true end, function() return not E.private.skins.blizzard.enable end, nil, true)
