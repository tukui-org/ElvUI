local E, _, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local MC = E:GetModule('ModuleCopy')
local D = E:GetModule('Distributor')
local S = E:GetModule('Skins')

-- GLOBALS: ElvDB

local ACH = E.Libs.ACH
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')
local C = {
	version = E:ParseVersionString('ElvUI_Options'),
	Blank = function() return '' end,
	SearchCache = {},
	SearchText = '',
}

E.Config = select(2, ...)
E.Config[1] = C
E.Config[2] = L

local _G = _G
local next, sort, strmatch, strsplit = next, sort, strmatch, strsplit
local tconcat, tinsert, tremove, wipe = table.concat, tinsert, tremove, wipe
local format, gsub, ipairs, pairs, type = format, gsub, ipairs, pairs, type

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local IsValidFilterString = AuraUtil and AuraUtil.IsValidFilterString

local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local NUM_CLASSES = #CLASS_SORT_ORDER

C.Values = {
	GrowthDirection = {
		DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
		DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
		UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
		UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
		RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
		RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
		LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
		LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
	},
	MAX_BOSS_FRAMES = 5,
	NUM_CLASSES = NUM_CLASSES,
	FontFlags = ACH.FontValues,
	FontSize = { softMin = 10, min = 4, softMax = 64, max = 80, step = 1 },
	Roman = { 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX' }, -- 1 to 20
	TooltipAnchors = { ANCHOR_TOP = L["TOP"], ANCHOR_RIGHT = L["RIGHT"], ANCHOR_BOTTOM = L["BOTTOM"], ANCHOR_LEFT = L["LEFT"], ANCHOR_TOPRIGHT = L["TOPRIGHT"], ANCHOR_BOTTOMRIGHT = L["BOTTOMRIGHT"], ANCHOR_TOPLEFT = L["TOPLEFT"], ANCHOR_BOTTOMLEFT = L["BOTTOMLEFT"], ANCHOR_CURSOR = L["CURSOR"], ANCHOR_CURSOR_LEFT = L["CURSOR_LEFT"], ANCHOR_CURSOR_RIGHT = L["CURSOR_RIGHT"] },
	AllPositions = { LEFT = L["LEFT"], RIGHT = L["RIGHT"], TOP = L["TOP"], BOTTOM = L["BOTTOM"], CENTER = L["CENTER"] },
	EdgePositions = { LEFT = L["LEFT"], RIGHT = L["RIGHT"], TOP = L["TOP"], BOTTOM = L["BOTTOM"] },
	SidePositions = { LEFT = L["LEFT"], RIGHT = L["RIGHT"] },
	TextPositions = { BOTTOMRIGHT = L["BOTTOMRIGHT"], BOTTOMLEFT = L["BOTTOMLEFT"], TOPRIGHT = L["TOPRIGHT"], TOPLEFT = L["TOPLEFT"], BOTTOM = L["BOTTOM"], TOP = L["TOP"] },
	AllPoints = { TOPLEFT = L["TOPLEFT"], LEFT = L["LEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], RIGHT = L["RIGHT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"], TOP = L["TOP"], BOTTOM = L["BOTTOM"], CENTER = L["CENTER"] },
	Anchors = { TOPLEFT = L["TOPLEFT"], LEFT = L["LEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], RIGHT = L["RIGHT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"], TOP = L["TOP"], BOTTOM = L["BOTTOM"] },
	Strata = { BACKGROUND = L["BACKGROUND"], LOW = L["LOW"], MEDIUM = L["MEDIUM"], HIGH = L["HIGH"], DIALOG = L["DIALOG"], TOOLTIP = L["TOOLTIP"] },
	SmartAuraPositions = {
		DISABLED = L["Disable"],
		BUFFS_ON_DEBUFFS = L["Buffs on Debuffs"],
		DEBUFFS_ON_BUFFS = L["Debuffs on Buffs"],
		FLUID_BUFFS_ON_DEBUFFS = L["Fluid Buffs on Debuffs"],
		FLUID_DEBUFFS_ON_BUFFS = L["Fluid Debuffs on Buffs"],
	}
}

do
	C.ClassTable = {}

	for _, info in next, E.ClassInfoByID do
		C.ClassTable[info.classFile] = info.className
	end
end

do
	C.DragGetTitle = function(_, text)
		local real, friend, enemy, block, allow = UF:GetFilterNameInfo(text)
		local title = L[real] or real
		local filterText = ((block or allow) and format(block and '|cFF999999%s|r %s' or '|cFFcccccc%s|r %s', block and L["Block"] or L["Allow"], title)) or title
		return (friend and format('|cFF33FF33%s|r %s', _G.FRIEND, filterText)) or (enemy and format('|cFFFF3333%s|r %s', _G.ENEMY, filterText)) or filterText
	end

	local specialOldNames = { -- also in UF Auras
		nonPersonal = 'NonPersonal',
		notCastByUnit = 'NotCastByUnit',
		notDispellable = 'NotDispellable'
	}

	local specialLocales = {
		Boss = L["Auras cast by a boss unit."],
		Mount = L["Auras which are classified as mounts."],
		MyPet = L["Auras which were from the pet unit."],
		OtherPet = L["Auras which were from another pet unit."],
		Personal = L["Auras cast by yourself."],
		NoDuration = L["Auras with no duration."],
		NonPersonal = L["Auras cast by anyone other than yourself."],
		CastByUnit = L["Auras cast by the unit of the unitframe or nameplate (so on target frame it only shows auras cast by the target unit)."],
		NotCastByUnit = L["Auras cast by anyone other than the unit of the unitframe or nameplate."],
		Dispellable = L["Auras you can either dispel or spellsteal."],
		NotDispellable = L["Auras you cannot dispel or spellsteal."],
		CastByNPC = L["Auras cast by any NPC."],
		CastByPlayers = L["Auras cast by any player-controlled unit (so no NPCs)."],
		BlizzardNameplate = L["Auras that fall under the conditions to be a nameplate aura."]
	}

	C.DragGetDesc = function(_, text)
		local real = UF:GetFilterNameInfo(text)

		local special = specialLocales[specialOldNames[real] or real]
		if special then
			return special
		end

		local custom = E.global.unitframe.aurafilters[real]
		if custom then
			return custom.desc
		end
	end

	local function FilterMatch(s,v)
		local m1, m2, m3, m4 = '^'..v..'$', '^'..v..',', ','..v..'$', ','..v..','
		return (strmatch(s, m1) and m1) or (strmatch(s, m2) and m2) or (strmatch(s, m3) and m3) or (strmatch(s, m4) and v..',')
	end

	C.SetFilterPriority = function(db, groupName, auraType, value, remove, movehere, friendState, typeOverride)
		if not auraType or not value then return end

		local filter = db[groupName] and db[groupName][auraType] and db[groupName][auraType].priority
		if not filter then return end

		local found = FilterMatch(filter, E:EscapeString(value))
		if found and movehere then
			local tbl, sv, sm = {strsplit(',',filter)}
			for i in ipairs(tbl) do
				if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
				if sv and sm then break end
			end
			tremove(tbl, sm)
			tinsert(tbl, sv, movehere)
			db[groupName][auraType].priority = tconcat(tbl,',')
		elseif found and (friendState or typeOverride) then
			local real, friend, enemy, block, allow = UF:GetFilterNameInfo(value)

			local state
			if friendState then
				state = (friend and not enemy and format('Enemy:%s',real))		--[x] friend [ ] enemy > enemy
				or (not enemy and not friend and format('Friendly:%s',real))	--[ ] friend [ ] enemy > friendly
				or (enemy and not friend and real)								--[ ] friend [x] enemy > reset
			else
				state = (friend and format('Friendly:%s',real)) or (enemy and format('Enemy:%s',real)) or real
			end

			if typeOverride then
				state = (allow and not block and format('block%s',state))	--[x] allow [ ] block > block
				or (not block and not allow and format('allow%s',state))	--[ ] allow [ ] block > allow
				or (block and not allow and state)							--[ ] allow [x] block > reset
			else -- changing friend state but need to keep the type state
				state = (allow and format('allow%s',state)) or (block and format('block%s',state)) or state
			end

			if state ~= value then
				local stateFound = FilterMatch(filter, E:EscapeString(state))
				if not stateFound then
					local tbl, sv = {strsplit(',',filter)}
					for i in ipairs(tbl) do
						if tbl[i] == value then
							sv = i
							break
						end
					end

					tinsert(tbl, sv, state)
					tremove(tbl, sv+1)

					db[groupName][auraType].priority = tconcat(tbl,',')
				end
			end
		elseif found and remove then
			db[groupName][auraType].priority = gsub(filter, found, '')
		elseif not found and not remove then
			db[groupName][auraType].priority = (filter == '' and value) or (filter..','..value)
		end
	end
end

if E.private.skins.ace3Enable then
	S:Ace3_ColorizeEnable(L)
end

--Function we can call on profile change to update GUI
function E:RefreshGUI()
	C:RefreshCustomTexts()
	E.Libs.AceConfigRegistry:NotifyChange('ElvUI')
end

E.Libs.AceConfig:RegisterOptionsTable('ElvUI', E.Options)
E.Libs.AceConfigDialog:SetDefaultSize('ElvUI', E:Config_GetDefaultSize())
E.Options.name = format('%s: |cff99ff33%s|r', L["Version"], E.versionString)

local function SetupProfile(opt, name, order, confirmText)
	opt.name = name
	opt.order = order
	opt.args.reset.confirm = true
	opt.args.reset.confirmText = confirmText
end

local DEVELOPERS = {
	'Tukz',
	'Haste',
	'Nightcracker',
	'Omega1970',
	'Blazeflack',
	'|cFFAAD372Crum|r',
	'|cffFFC44DHydra|r',
	'|cff0070DEAzilroka|r',
	'|cff9482c9Darth Predator|r',
	'|T134297:15:15:0:0:64:64:5:59:5:59|t |cffff7d0aMerathilis|r',
	'|cffff2020Nihilistzsche|r',
	'|TInterface/AddOns/ElvUI/Game/Shared/Media/ChatLogos/Beer:15:15:0:0:64:64:5:59:5:59|t |cfff48cbaRepooc|r',
	'|TInterface/AddOns/ElvUI/Game/Shared/Media/ChatLogos/Clover:15:15:0:0:64:64:5:59:5:59|t |cff4beb2cLuckyone|r',
	E:TextGradient('Simpy but my name needs to be longer.', 0.28,0.79,0.96, 0.50,0.77,0.38, 1.00,0.95,0.38, 0.96,0.53,0.37, 0.80,0.51,0.72, 0.34,0.80,0.96)
}

local TESTERS = {
	'Modarch',
	'Tirain',
	'Phima',
	'Veiled',
	'Alex',
	E:TextGradient('Eltreum', 0.50, 0.70, 1, 0.67, 0.95, 1),
	'|cFFAAD372Tsxy|r',
	'|cFFff75ddFlamanis|r',
	'|cFFb8bb26Thurin|r',
	'Nidra',
	'Kurhyus',
	'Shrom',
	'BuG',
	'Kringel',
	'|cFF08E8DEBotanica|r',
	'Yachanay',
	'Catok',
	'Caedis',
	'|cff00c0faBenik|r',
	'|T136012:15:15:0:0:64:64:5:59:5:59|t |cff006fdcRubgrsch|r',
	'|TInterface/AddOns/ElvUI/Game/Shared/Media/ChatLogos/Gem:15:15:-1:2:64:64:6:60:8:60|t AcidWeb',
	'|T135167:15:15:0:0:64:64:5:59:5:59|t Loon - For being right',
	'|T134297:15:15:0:0:64:64:5:59:5:59|t |cffFF7D0ABladesdruid|r - AKA SUPERBEAR',
}

-- Automated by Discord Bot
local DONATORS = {
	'A.L.K',
	'Admiral Adonis',
	'agaeon',
	'agirun',
	'Alebringer',
	'Amenitra',
	'Amialla',
	'Arganox',
	'Axiom / Mac',
	'Azcath',
	'Azoth',
	'Baraius',
	'Barbs / Cheresnish',
	'Baturios',
	'Big_Neil',
	'Bigity',
	'Blackbriar',
	'boots',
	'Boroak',
	'Brian',
	'Bryan',
	'bugX3D',
	'Busi',
	'Caedis',
	'Celd',
	'Chay',
	'chomptrelle',
	'Churi',
	'Clack',
	'Daldis',
	'dalla',
	'Darken',
	'Deb Null',
	'Demona',
	'Dodgen',
	'Dwake',
	'Eazi',
	'enny',
	'Exuperjun',
	'eXxe',
	'Fafnyir',
	'Fleathulhu',
	'Fliipsy',
	'Garrek_',
	'Gelb',
	'Gina',
	'Hauke',
	'Helleron',
	'Hurtrus',
	'Hyakume',
	'IHealDrunk',
	'Ivikatasha',
	'Jiberish',
	'Jimfro',
	'Kaadan',
	'Kaizers',
	'Kathelylaise',
	'knetik',
	'Knowledge',
	'Laevy',
	'LeThumper',
	'Lis',
	'Liue',
	'Lufifi',
	'Lyfa',
	'Malus',
	'mental1082',
	'Method',
	'MollyRazor',
	'Moranir',
	'mrkhaglund',
	'Mynty',
	'Naerstie',
	'Naina',
	'Navallax',
	'Nec',
	'nKr',
	'Ogion',
	'Ohno',
	'Papi Grande',
	'Paulus',
	'peppermint',
	'pk',
	'Praeses',
	'Rage',
	'Raven',
	'Rhyster',
	'riccochet',
	'Rolfrudiger',
	'Saisen',
	'Seajay',
	'Sean',
	'Seanability',
	'Sentox',
	'Shak',
	'Sherrie',
	'Shikarr',
	'Skewter the Tooter',
	'Slabic',
	'Smazo',
	'Smilezhi',
	'Smoxx',
	'Spectre',
	'Stoned',
	'Tergl',
	'Tieglin / Konstantina',
	'Tinowar',
	'Trenchy',
	'ultramatt',
	'Vdera',
	'Verex',
	'Vex',
	'Vuhnylla',
	'Vyn',
	'Wonder',
	'Wulfsie',
	'Xengeance',
	'Xiang yama',
	'Zeek',
	'zetsubou',
	'zodiAken',
}
-- End of automation

local CREDITS_OVERRIDE = {
	['Simpy but my name needs to be longer.'] = 'Simpy',
	['Bladesdruid - AKA SUPERBEAR'] = 'Bladesdruid',
	['Thomas B. aka Pitschiqüü'] = 'Pitschiqüü',
	['Karsten Lumbye Thomsen'] = 'Karsten',
	['Loon - For being right'] = 'Loon'
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end

sort(DEVELOPERS, SortList)
sort(TESTERS, SortList)

local DEVELOPER_STRING = tconcat(DEVELOPERS, '|n')
local TESTER_STRING = tconcat(TESTERS, '|n')
local DONATOR_STRING = tconcat(DONATORS, '|n')

for _, names in next, { DEVELOPERS, TESTERS, DONATORS } do
	for _, name in next, names do
		local full = E:StripString(name)
		local override = CREDITS_OVERRIDE[full]
		tinsert(E.CreditsList, override or full)
	end
end

E.Options.args.info = ACH:Group(L["Information"], nil, 4, 'tab')

E.Options.args.info.args.debug = ACH:Execute(L["Debug"], L["DEBUG_DESC"], 1, function() local state = next(ElvDB.DisabledAddOns) E:LuaError(state and 'off' or 'on') end, nil, nil, 120)
E.Options.args.info.args.colors = ACH:Execute(L["Color Picker"], nil, 2, function() _G.ColorPickerFrame:Show() _G.ColorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG') _G.ColorPickerFrame:SetClampedToScreen(true) _G.ColorPickerFrame:Raise() end, nil, nil, 120)

E.Options.args.info.args.main = ACH:Group(L["ELVUI_DESC"], nil, 5)
E.Options.args.info.args.main.inline = true

for index, data in next, {
	{ key = 'discord',		name = L["Discord"],				url = 'https://discord.tukui.org' },
	{ key = 'issues',		name = L["Ticket Tracker"],			url = 'https://github.com/tukui-org/ElvUI/issues' },
	{ key = 'wiki',			name = L["Wiki"],					url = 'https://github.com/tukui-org/ElvUI/wiki' },
	{ key = 'dev',			name = L["Development Version"],	url = 'https://api.tukui.org/v1/download/dev/elvui/main' },
	{ key = 'ptr',			name = L["PTR Version"],			url = 'https://api.tukui.org/v1/download/dev/elvui/ptr' },
	{ key = 'changelog',	name = L["Changelog"],				url = 'https://github.com/tukui-org/ElvUI/blob/main/CHANGELOG.md' },
	{ key = 'customTexts',	name = L["Custom Texts"],			url = 'https://github.com/tukui-org/ElvUI/wiki/custom-texts' },
	{ key = 'paging',		name = L["Action Paging"],			url = 'https://github.com/tukui-org/ElvUI/wiki/paging' },
	{ key = 'performance',	name = L["Performance"],			url = 'https://github.com/tukui-org/ElvUI/wiki/performance-optimization' },
} do
	E.Options.args.info.args.main.args[data.key] = ACH:Input(data.name, nil, index, nil, 255, function() return data.url end)
	E.Options.args.info.args.main.args[data.key].focusSelect = true
end

local credits = (L["*%s|r|cFFffffff below.  Made with|r |cFFff75dd<3|r |cFFffffffby the Tukui Community.|r"]):gsub('*', E.InfoColor)
E.Options.args.info.args.credits = ACH:Group(format(credits, L["Credits"]), nil, 10)
E.Options.args.info.args.credits.inline = true
E.Options.args.info.args.credits.args.string = ACH:Description(L["ELVUI_CREDITS"], 1, 'medium')

E.Options.args.info.args.credits.args.coding = ACH:Group(L["Coding:"], nil, 6)
E.Options.args.info.args.credits.args.coding.inline = true
E.Options.args.info.args.credits.args.coding.args.string = ACH:Description(DEVELOPER_STRING, 1, 'medium')

E.Options.args.info.args.credits.args.testers = ACH:Group(L["Testing:"], nil, 7)
E.Options.args.info.args.credits.args.testers.inline = true
E.Options.args.info.args.credits.args.testers.args.string = ACH:Description(TESTER_STRING, 1, 'medium')

E.Options.args.info.args.credits.args.donators = ACH:Group(L["Donations:"], nil, 8)
E.Options.args.info.args.credits.args.donators.inline = true
E.Options.args.info.args.credits.args.donators.args.string = ACH:Description(DONATOR_STRING, 1, 'medium')

--Create Profiles Table
E.Options.args.profiles = ACH:Group(L["Profiles"], nil, 4, 'tab')
E.Options.args.profiles.args.desc = ACH:Description(L["This feature will allow you to transfer settings to other characters."], 0)
E.Options.args.profiles.args.distributeProfile = ACH:Execute(L["Share Profile"], L["Sends your current profile to your target."], 1, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or E:UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name) elseif server then D:Distribute(name, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.distributePrivate = ACH:Execute(L["Share Private"], nil, 2, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or E:UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name, false, 'private') elseif server then D:Distribute(name, true, 'private') end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.distributeGlobal = ACH:Execute(L["Share Global"], nil, 3, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or E:UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name, false, 'global') elseif server then D:Distribute(name, true, 'global') end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.allowDistributor = ACH:Toggle(L["Allow Sharing"], L["Both users will need this option enabled."], 4, nil, nil, nil, function() return E.global.general.allowDistributor end, function(_, value) E.global.general.allowDistributor = value; D:UpdateSettings() end)
E.Options.args.profiles.args.spacer = ACH:Spacer(10)

E.Options.args.profiles.args.profile = E.Libs.AceDBOptions:GetOptionsTable(E.data)
E.Options.args.profiles.args.private = E.Libs.AceDBOptions:GetOptionsTable(E.charSettings)

SetupProfile(E.Options.args.profiles.args.profile, L["Profile"], 1, L["Are you sure you want to reset all the settings on this profile?"])
SetupProfile(E.Options.args.profiles.args.private, L["Private"], 2, L["Are you sure you want to reset all the settings on this profile?"])

E.Libs.AceConfig:RegisterOptionsTable('ElvProfiles', E.Options.args.profiles.args.profile)

if E.Retail or E.Mists or E.TBC or E.ClassicSOD or E.ClassicAnniv or E.ClassicAnnivHC then
	E.Libs.DualSpec:EnhanceOptions(E.Options.args.profiles.args.profile, E.data)
end

E.Libs.AceConfig:RegisterOptionsTable('ElvPrivates', E.Options.args.profiles.args.private)

E.Options.args.profiles.args.private.args.choose.confirm = function(info, value)
	if info[#info-1] == 'private' then
		return format(L["Choosing Settings %s. This will reload the UI.\n\n Are you sure?"], value)
	else
		return false
	end
end

E.Options.args.profiles.args.private.args.copyfrom.confirm = function(info, value)
	return format(L["Copy settings from %s. This will overwrite %s profile.\n\n Are you sure?"], value, info.handler:GetCurrentProfile())
end

do -- Import and Export
	local function ValidateString(_, value) return value and not strmatch(value, '^[%s%p]-$') end
	local profileTypeItems = { profile = L["Profile"], private = L["Private (Character Settings)"], global = L["Global (Account Settings)"], filters = L["Aura Filters"] }

	local function DecodeString(text, plugin)
		local profileType, profileKey, profileData = D:Decode(text)

		if plugin then
			return E:ProfileTableToPluginFormat(profileData, profileType)
		else
			local decodedString = (profileData and E:TableToLuaString(profileData)) or nil
			return D:CreateProfileExport(profileType, profileKey, decodedString)
		end
	end

	local function DecodeLabel(label, text, plugin)
		if not ValidateString(nil, text) then
			label.name = ''
			return text
		end

		local decode = DecodeString(text, plugin)
		if decode then
			return decode
		else
			label.name = L["Error decoding data. Import string may be corrupted!"]
			return text
		end
	end

	local function BuildEditboxes(config, get, set, hidden, importTexts)
		local count = 0
		for _ in next, profileTypeItems do
			count = count + 1

			local offset = count * 2
			local textKey = 'text'..count
			local input = ACH:Input('', nil, 51 + offset, 5, 'full', get, set, nil, hidden)
			input.disableButton = true
			input.focusSelect = true
			config.args[textKey] = input

			if importTexts then
				input.textChanged = function(value)
					if textKey ~= value then
						importTexts[textKey] = value
					end
				end
			end

			local label = ACH:Description('', 50 + offset)
			config.args['label'..count] = label
		end
	end

	do
		local importTexts = {}
		local import = ACH:Group(L["Import"], nil, 3, 'tab')
		E.Options.args.profiles.args.import = import

		local function Import(which)
			local count = 1
			for _ in next, profileTypeItems do
				local textKey = 'text'..count
				local importText = importTexts[textKey]
				local label = import.args['label'..count]

				count = count + 1 -- keep this after the count usage

				if which == 'text' and ValidateString(nil, importText) then
					local profileType = D:Decode(importText)
					local imported = profileType and D:ImportProfile(importText)
					label.name = (imported and L["Profile imported successfully!"]) or L["Error decoding data. Import string may be corrupted!"]
				else
					if which == 'luaTable' then
						importTexts[textKey] = DecodeLabel(label, importText)
					elseif which == 'clear' then
						importTexts[textKey] = nil
					end

					label.name = ''
				end
			end
		end

		local function Import_Set() end
		local function Import_Get(info) return importTexts[info[#info]] end
		BuildEditboxes(import, Import_Get, Import_Set, false, importTexts)

		import.args.importButton = ACH:Execute(L["Import"], nil, 1, function() Import('text') end, nil, nil, 120)
		import.args.decodeButton = ACH:Execute(L["Decode"], nil, 2, function() Import('luaTable') end, nil, nil, 120)
		import.args.clearButton = ACH:Execute(L["Clear"], nil, 3, function() Import('clear') end, nil, nil, 120)
	end

	do
		local exportList = { profile = true }
		local exportTexts = {}
		local export = ACH:Group(L["Export"], nil, 4, 'tab')
		E.Options.args.profiles.args.export = export

		local function Export_Get(info) return exportTexts[info[#info]] end
		local function Export_Set() end
		BuildEditboxes(export, Export_Get, Export_Set, true)

		local function HandleExporting(which)
			local count = 1
			for profileType in next, profileTypeItems do
				local textKey = 'text'..count
				local input = export.args[textKey]
				local label = export.args['label'..count]
				count = count + 1

				local exporting = exportList[profileType]
				input.hidden = not exporting

				if exporting then
					local profileKey, profileExport = D:ExportProfile(profileType, nil, which)
					if not profileKey or not profileExport then
						label.name = L["Error exporting profile!"]
					else
						label.name = format('%s: %s%s|r', L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType])
					end

					exportTexts[textKey] = profileExport or nil
				else
					label.name = ''
				end
			end
		end

		local function Filters_Empty() return not next(exportList) end
		local function Filters_Get(_, key)
			if Filters_Empty() then
				HandleExporting()
			end

			return exportList[key]
		end

		local function Filters_Set(_, key, value) exportList[key] = value or nil end
		local function Export(which)
			if Filters_Empty() then return end

			wipe(exportTexts)

			HandleExporting(which)
		end

		export.args.exportButton = ACH:Execute(L["Export"], nil, 1, function() Export('text') end, nil, nil, 120)
		export.args.decodeButton = ACH:Execute(L["Table"], nil, 2, function() Export('luaTable') end, nil, nil, 120)
		export.args.pluginButton = ACH:Execute(L["Plugin"], nil, 3, function() Export('luaPlugin') end, nil, nil, 120)
		export.args.profileTye = ACH:MultiSelect(L["Choose What To Export"], nil, 10, profileTypeItems, nil, 225, Filters_Get, Filters_Set)
	end
end

do -- Module Copy
	local function DefaultOptions(tbl, section, subSection, option)
		if tbl[section] then
			if subSection then
				if not tbl[section][subSection] then
					tbl[section][subSection] = {}
				end

				if tbl[section][subSection][option] == nil then
					tbl[section][subSection][option] = false
				end
			elseif tbl[section][option] == nil then
				tbl[section][option] = false
			end
		end
	end

	function MC:AddConfigOptions(settings, config, section, subSection)
		for option, tbl in pairs(settings) do
			if type(tbl) == 'table' and not (tbl.r and tbl.g and tbl.b) then
				config.args[option] = ACH:Toggle(option)

				DefaultOptions(G.profileCopy, section, subSection, option) -- defaults
				DefaultOptions(E.global.profileCopy, section, subSection, option) -- from profile
			end
		end
	end

	--Actionbars
	local function CreateActionbarsConfig()
		local config = MC:CreateModuleConfigGroup(L["ActionBars"], 'actionbar')
		local order = 3

		MC:AddConfigOptions(P.actionbar, config, 'actionbar')

		for i = 1, 10 do
			local bar = config.args['bar'..i]
			bar.name = L["Bar "]..i
			bar.order = order
			order = order + 1
		end

		for i = 13, 15 do
			local bar = config.args['bar'..i]
			bar.name = L["Bar "]..i
			bar.order = order
			order = order + 1
		end

		config.args.barPet.name = L["Pet Bar"]
		config.args.stanceBar.name = L["Stance Bar"]
		config.args.microbar.name = L["Micro Bar"]
		config.args.totemBar.name = L["Totem Bar"]
		config.args.extraActionButton.name = L["Boss Button"]
		config.args.vehicleExitButton.name = L["Vehicle Exit"]
		config.args.zoneActionButton.name = L["Zone Ability"]

		return config
	end

	--Auras
	local function CreateAurasConfig()
		local config = MC:CreateModuleConfigGroup(L["Auras"], 'auras')

		MC:AddConfigOptions(P.auras, config, 'auras')

		config.args.buffs.name = L["Buffs"]
		config.args.debuffs.name = L["Debuffs"]

		return config
	end

	--Bags
	local function CreateBagsConfig()
		local config = MC:CreateModuleConfigGroup(L["Bags"], 'bags')

		MC:AddConfigOptions(P.bags, config, 'bags')

		config.args.ignoredItems = nil
		config.args.shownBags = nil

		config.args.colors.name = L["Colors"]
		config.args.bagBar.name = L["Bag Bar"]
		config.args.split.name = L["Split"]
		config.args.spinner.name = L["Sort Spinner"]
		config.args.autoToggle.name = L["Auto Toggle"]
		config.args.vendorGrays.name = L["Vendor Grays"]

		return config
	end

	--Chat
	local function CreateChatConfig()
		local config = MC:CreateModuleConfigGroup(L["Chat"], 'chat')

		MC:AddConfigOptions(P.chat, config, 'chat')

		config.args.channelAlerts.name = L["Channel Alerts"]
		config.args.showHistory.name = L["Display Types"]

		return config
	end

	--Cooldowns
	local function CreateCooldownConfig()
		local config = MC:CreateModuleConfigGroup(L["Cooldown & Duration"], 'cooldown')

		MC:AddConfigOptions(P.cooldown, config, 'cooldown')

		config.args.global.name = L["Global"]
		config.args.auras.name = L["BUFFOPTIONS_LABEL"]
		config.args.actionbar.name = L["ActionBars"]
		config.args.bags.name = L["Bags"]
		config.args.nameplates.name = L["Nameplates"]
		config.args.unitframe.name = L["UnitFrames"]
		config.args.aurabars.name = L["Aura Bars"]
		config.args.auraindicator.name = L["Aura Indicator"]
		config.args.cdmanager.name = L["Cooldown Manager"]
		config.args.totemtracker.name = L["Totem Tracker"]
		config.args.bossbutton.name = L["Boss Button"]
		config.args.zonebutton.name = L["Zone Button"]

		return config
	end

	--DataBars
	local function CreateDatatbarsConfig()
		local config = MC:CreateModuleConfigGroup(L["DataBars"], 'databars')

		MC:AddConfigOptions(P.databars, config, 'databars')

		config.args.colors.name = L["Colors"]
		config.args.experience.name = L["Experience"]
		config.args.reputation.name = L["Reputation"]
		config.args.honor.name = L["Honor"]
		config.args.threat.name = L["Threat"]
		config.args.azerite.name = L["Azerite"]
		config.args.petExperience.name = L["Pet Experience"]

		return config
	end

	--DataTexts
	local function CreateDatatextsConfig()
		local config = MC:CreateModuleConfigGroup(L["DataTexts"], 'datatexts')

		MC:AddConfigOptions(P.datatexts, config, 'datatexts')

		config.args.panels = ACH:Toggle(L["Panels"], nil, 2)
		config.args.battlePanel.name = L["Battlegrounds"]

		return config
	end

	--General
	local function CreateGeneralConfig()
		local config = MC:CreateModuleConfigGroup(L["General"], 'general')

		MC:AddConfigOptions(P.general, config, 'general')

		config.args.altPowerBar.name = L["Alternative Power"]
		config.args.minimap.name = L["Minimap"]
		config.args.totems.name = L["Class Totems"]
		config.args.itemLevel.name = L["Item Level"]
		config.args.addonCompartment.name = L["Addon Compartment"]
		config.args.bottomPanelSettings.name = L["Bottom Panel"]
		config.args.classColors.name = L["Custom Class Colors"]
		config.args.cooldownManager.name = L["Cooldown Manager"]
		config.args.customGlow.name = L["Custom Glow"]
		config.args.fonts.name = L["Fonts"]
		config.args.guildBank.name = L["Guild Bank"]
		config.args.lootRoll.name = L["Loot Roll"]
		config.args.privateRaidWarning.name = L["Raid Warning"]
		config.args.queueStatus.name = L["Queue Status"]
		config.args.raidUtility.name = L["RAID_CONTROL"]
		config.args.rotationAssist.name = L["Rotation Assist"]
		config.args.topPanelSettings.name = L["Top Panel"]
		config.args.debuffColors.name = L["Debuff Colors"]

		return config
	end

	--NamePlates
	local function CreateNamePlatesConfig()
		local config = MC:CreateModuleConfigGroup(L["Nameplates"], 'nameplates')

		MC:AddConfigOptions(P.nameplates, config, 'nameplates')

		-- Locales
		config.args.threat.name = L["Threat"]
		config.args.cutaway.name = L["Cutaway Bars"]
		config.args.clickThrough.name = L["Click Through"]
		config.args.clickSize.name = L["Clickable Size"]
		config.args.colors.name = L["Colors"]
		config.args.visibility.name = L["Visibility"]
		config.args.enviromentConditions.name = L["Environment Conditions"]
		config.args.widgets.name = L["Widget"]

		-- Modify Tables
		config.args.filters = nil
		config.args.units = ACH:Group(L["Nameplates"], nil, -10, nil, function(info) return E.global.profileCopy.nameplates[info[#info-1]][info[#info]] end, function(info, value) E.global.profileCopy.nameplates[info[#info-1]][info[#info]] = value; end)
		config.args.units.inline = true

		MC:AddConfigOptions(P.nameplates.units, config.args.units, 'nameplates', 'units')

		-- Locales
		config.args.units.args.PLAYER.name = L["Player"]
		config.args.units.args.TARGET.name = L["Target"]
		config.args.units.args.FRIENDLY_PLAYER.name = L["FRIENDLY_PLAYER"]
		config.args.units.args.ENEMY_PLAYER.name = L["ENEMY_PLAYER"]
		config.args.units.args.FRIENDLY_NPC.name = L["FRIENDLY_NPC"]
		config.args.units.args.ENEMY_NPC.name = L["ENEMY_NPC"]

		return config
	end

	--Tooltip
	local function CreateTooltipConfig()
		local config = MC:CreateModuleConfigGroup(L["Tooltip"], 'tooltip')

		MC:AddConfigOptions(P.tooltip, config, 'tooltip')

		config.args.visibility.name = L["Visibility"]
		config.args.healthBar.name = L["Health Bar"]
		config.args.factionColors.name = L["Custom Faction Colors"]
		config.args.itemCount.name = L["Item Count"]

		return config
	end

	--UnitFrames
	local function CreateUnitframesConfig()
		local config = MC:CreateModuleConfigGroup(L["UnitFrames"], 'unitframe')

		MC:AddConfigOptions(P.unitframe, config, 'unitframe')

		config.args.altManaPowers.name = L["Additional Power"]
		config.args.modifiers.name = L["Filter Modifiers"]
		config.args.filters.name = L["Filters"]

		config.args.colors = ACH:Group(L["Colors"], nil, -9, nil, function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end, function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end)
		config.args.colors.inline = true

		MC:AddConfigOptions(P.unitframe.colors, config.args.colors, 'unitframe', 'colors')

		config.args.colors.args.power.name = L["Power"]
		config.args.colors.args.reaction.name = L["Reactions"]
		config.args.colors.args.healPrediction.name = L["Heal Prediction"]
		config.args.colors.args.classResources.name = L["Class Resources"]
		config.args.colors.args.frameGlow.name = L["Frame Glow"]
		config.args.colors.args.debuffHighlight.name = L["Debuff Highlighting"]
		config.args.colors.args.powerPrediction.name = L["Power Prediction"]
		config.args.colors.args.empoweredCast.name = L["Empower Stages"]
		config.args.colors.args.happiness.name = L["Pet Happiness"]
		config.args.colors.args.healthBreak.name = L["Health Breakpoint"]
		config.args.colors.args.selection.name = L["Selection"]
		config.args.colors.args.threat.name = L["Threat"]

		config.args.units = ACH:Group(L["UnitFrames"], nil, -10, nil, function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end, function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end)
		config.args.units.inline = true

		MC:AddConfigOptions(P.unitframe.units, config.args.units, 'unitframe', 'units')

		config.args.units.args.player.name = L["Player"]
		config.args.units.args.target.name = L["Target"]
		config.args.units.args.targettarget.name = L["TargetTarget"]
		config.args.units.args.targettargettarget.name = L["TargetTargetTarget"]
		config.args.units.args.focus.name = L["Focus"]
		config.args.units.args.focustarget.name = L["FocusTarget"]
		config.args.units.args.pet.name = L["Pet"]
		config.args.units.args.pettarget.name = L["PetTarget"]
		config.args.units.args.boss.name = L["Boss"]
		config.args.units.args.arena.name = L["Arena"]
		config.args.units.args.party.name = L["Party"]

		for i = 1, 3 do
			config.args.units.args['raid'..i].name = L[format("Raid %s", i)]
		end

		config.args.units.args.raidpet.name = L["Raid Pet"]
		config.args.units.args.tank.name = L["Tank"]
		config.args.units.args.assist.name = L["Assist"]

		return config
	end

	E.Options.args.profiles.args.modulecopy = ACH:Group(L["Module Copy"], nil, 5, 'tab')
	E.Options.args.profiles.args.modulecopy.handler = E.Options.args.profiles.handler
	E.Options.args.profiles.args.modulecopy.args.intro = ACH:Description(L["This section will allow you to copy settings to a select module from or to a different profile."], 1, 'medium')
	E.Options.args.profiles.args.modulecopy.args.pluginInfo = ACH:Description(L["If you have any plugins supporting this feature installed you can find them in the selection dropdown to the right."], 2, 'medium')
	E.Options.args.profiles.args.modulecopy.args.profile = ACH:Select(L["Profile"], L["Select a profile to copy from/to."], 3, function() local tbl = {} for profile in pairs(E.data.profiles) do tbl[profile] = profile end return tbl end, nil, nil, function() return E.global.profileCopy.selected end, function(_, value) E.global.profileCopy.selected = value end)
	E.Options.args.profiles.args.modulecopy.args.clear = ACH:Execute(L["Clear All"], nil, 4, nil, nil, nil, 120)
	E.Options.args.profiles.args.modulecopy.args.select = ACH:Execute(L["Select All"], nil, 5, nil, nil, nil, 120)
	E.Options.args.profiles.args.modulecopy.args.import = ACH:Execute(L["Import"], nil, 6, nil, nil, nil, 120)
	E.Options.args.profiles.args.modulecopy.args.export = ACH:Execute(L["Export"], nil, 7, nil, nil, nil, 120)

	E.Options.args.profiles.args.modulecopy.args.elvui = ACH:Group('ElvUI', L["Core |cff1784d1ElvUI|r options."], 10, 'tree')
	E.Options.args.profiles.args.modulecopy.args.elvui.args.actionbar = CreateActionbarsConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.auras = CreateAurasConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.bags = CreateBagsConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.chat = CreateChatConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.cooldown = CreateCooldownConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.databars = CreateDatatbarsConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.datatexts = CreateDatatextsConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.general = CreateGeneralConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.nameplates = CreateNamePlatesConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.tooltip = CreateTooltipConfig()
	E.Options.args.profiles.args.modulecopy.args.elvui.args.uniframes = CreateUnitframesConfig()

	E.Options.args.profiles.args.modulecopy.args.movers = ACH:Group(L["Movers"], L["On screen positions for different elements."], 20, 'tree')
	E.Options.args.profiles.args.modulecopy.args.movers.args = MC:CreateMoversConfigGroup()

	E.Options.args.profiles.args.modulereset = ACH:Group(L["Module Reset"], nil, 6, 'tab', nil, nil, nil, nil, function(info) E:CopyTable(E.db[info[#info]], P[info[#info]]) end)
	E.Options.args.profiles.args.modulereset.args.intro = ACH:Description(L["This section will help reset specific settings back to default."], 1)
	E.Options.args.profiles.args.modulereset.args.space1 = ACH:Spacer(2)
	E.Options.args.profiles.args.modulereset.args.general = ACH:Execute(L["General"], nil, 3, nil, nil, L["Are you sure you want to reset General settings?"])
	E.Options.args.profiles.args.modulereset.args.actionbar = ACH:Execute(L["ActionBars"], nil, 4, nil, nil, L["Are you sure you want to reset ActionBars settings?"])
	E.Options.args.profiles.args.modulereset.args.bags = ACH:Execute(L["Bags"], nil, 5, nil, nil, L["Are you sure you want to reset Bags settings?"])
	E.Options.args.profiles.args.modulereset.args.auras = ACH:Execute(L["Auras"], nil, 6, nil, nil, L["Are you sure you want to reset Auras settings?"])
	E.Options.args.profiles.args.modulereset.args.chat = ACH:Execute(L["Chat"], nil, 7, nil, nil, L["Are you sure you want to reset Chat settings?"])
	E.Options.args.profiles.args.modulereset.args.cooldown = ACH:Execute(L["Cooldown & Duration"], nil, 8, nil, nil, L["Are you sure you want to reset Cooldown settings?"])
	E.Options.args.profiles.args.modulereset.args.databars = ACH:Execute(L["DataBars"], nil, 9, nil, nil, L["Are you sure you want to reset DataBars settings?"])
	E.Options.args.profiles.args.modulereset.args.datatexts = ACH:Execute(L["DataTexts"], nil, 10, nil, nil, L["Are you sure you want to reset DataTexts settings?"])
	E.Options.args.profiles.args.modulereset.args.nameplates = ACH:Execute(L["Nameplates"], nil, 11, nil, nil, L["Are you sure you want to reset NamePlates settings?"])
	E.Options.args.profiles.args.modulereset.args.tooltip = ACH:Execute(L["Tooltip"], nil, 12, nil, nil, L["Are you sure you want to reset Tooltip settings?"])
	E.Options.args.profiles.args.modulereset.args.uniframes = ACH:Execute(L["UnitFrames"], nil, 13, function() E:CopyTable(E.db.unitframe, P.unitframe); UF:Update_AllFrames() end, nil, L["Are you sure you want to reset UnitFrames settings?"])
end

do -- shared filters
	local filters = {}
	function C:VerifyFilter(value)
		return IsValidFilterString(value)
	end

	function C:GetOptionsTable_AuraGroup(index, enable, mainGet, mainSet, candidateGet, candidateSet)
		local group = ACH:Group(function() return format('|cFF%s%s|r', enable() and '33ff33' or 'ff3333', C.Values.Roman[index]) end, nil, index, nil, mainGet, mainSet, nil, not E.Retail)

		group.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.filter = ACH:Input(L["Filter String"], nil, 2, nil, 'full', nil, nil, nil, nil, C.VerifyFilter)

		group.args.lists = ACH:Group(' ', nil, 10)
		group.args.lists.args.allowList = ACH:Select(L["Allow List"], nil, 1, function() wipe(filters) local list = E.global.unitframe.aurafilters if not list then return end for filter in pairs(list) do filters[filter] = filter end return filters end)
		group.args.lists.args.blockList = ACH:Select(L["Block List"], nil, 2, function() wipe(filters) local list = E.global.unitframe.aurafilters if not list then return end for filter in pairs(list) do filters[filter] = filter end return filters end)
		group.args.lists.args.maxDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 3, { min = 0, max = 10800, step = 1 })
		group.args.lists.inline = true

		group.args.candidates = ACH:Group(' ', nil, 20, nil, candidateGet, candidateSet)
		group.args.candidates.args.useAllowlist = ACH:Toggle(L["Use: Allow"], L["Activate the allowlist filter."], 1, nil, nil, nil, mainGet, mainSet)
		group.args.candidates.args.useBlocklist = ACH:Toggle(L["Use: Block"], L["Activate the blocklist filter."], 2, nil, nil, nil, mainGet, mainSet)
		group.args.candidates.args.isStealable = ACH:Toggle(L["Stealable"], L["Stealable"], 3, true)
		group.args.candidates.args.nameplateShowAll = ACH:Toggle(L["NP: All"], L["Nameplate: Show all"], 4, true)
		group.args.candidates.args.nameplateShowPersonal = ACH:Toggle(L["NP: Personal"], L["Nameplate: Personal"], 5, true)
		group.args.candidates.args.isFromPlayerOrPlayerPet = ACH:Toggle(L["Player or Pet"], L["From unit: player or pet"], 6, true)
		group.args.candidates.args.isRoleAura = ACH:Toggle(L["Role"], L["Role aura - tank/heal/dps?"], 7, true)
		group.args.candidates.args.isPriorityAura = ACH:Toggle(L["Priority"], L["Priority aura"], 8, true)
		group.args.candidates.args.canApplyAura = ACH:Toggle(L["Can Apply"], L["Can apply aura"], 9, true)
		group.args.candidates.args.isBossAura = ACH:Toggle(L["Boss"], L["Boss aura - important stuff, was used on last boss this season"], 10, true)
		group.args.candidates.args.isBossOrRoleAura = ACH:Toggle(L["Boss or Role"], L["the either-or between isRoleAura and isBossAura"], 11, true)
		group.args.candidates.inline = true

		return group
	end

	-- filters: help section
	local listExamples = {
		buffsPlayer			= { order = 1, desc = L["FILTER_EXAMPLE_1_DESC"], text = L["FILTER_EXAMPLE_1_TEXT"], value = 'HELPFUL|PLAYER' },
		buffsWhitelist		= { order = 2, desc = L["FILTER_EXAMPLE_2_DESC"], text = L["FILTER_EXAMPLE_2_TEXT"], value = 'HELPFUL' },
		debuffsPlayer		= { order = 3, desc = L["FILTER_EXAMPLE_3_DESC"], text = L["FILTER_EXAMPLE_3_TEXT"], value = 'HARMFUL|PLAYER|!CROWD_CONTROL' },
		hotsShields			= { order = 4, desc = L["FILTER_EXAMPLE_4_DESC"], text = L["FILTER_EXAMPLE_4_TEXT"], value = 'HELPFUL|RAID_IN_COMBAT|PLAYER' },
		debuffsDispel		= { order = 5, desc = L["FILTER_EXAMPLE_5_DESC"], text = L["FILTER_EXAMPLE_5_TEXT"], value = 'HARMFUL|RAID|PLAYER' },
		debuffsRaidDispel	= { order = 6, desc = L["FILTER_EXAMPLE_6_DESC"], text = L["FILTER_EXAMPLE_6_TEXT"], value = 'HARMFUL|RAID_PLAYER_DISPELLABLE' },
	}

	local listFilters = {
		HELPFUL					= { order = 1,	desc = L["FILTER_STRING_HELPFUL_DESC"],					text = nil },
		HARMFUL					= { order = 2,	desc = L["FILTER_STRING_HARMFUL_DESC"],					text = nil },
		PLAYER					= { order = 3,	desc = L["FILTER_STRING_PLAYER_DESC"],					text = nil },
		RAID					= { order = 4,	desc = L["FILTER_STRING_RAID_DESC"],					text = L["FILTER_STRING_RAID_TEXT"] },
		RAID_PLAYER_DISPELLABLE = { order = 5,	desc = L["FILTER_STRING_RAID_PLAYER_DISPELLABLE_DESC"],	text = L["FILTER_STRING_RAID_PLAYER_DISPELLABLE_TEXT"] },
		RAID_IN_COMBAT			= { order = 6,	desc = L["FILTER_STRING_RAID_IN_COMBAT_DESC"],			text = L["FILTER_STRING_RAID_IN_COMBAT_TEXT"] },
		CANCELABLE				= { order = 7,	desc = L["FILTER_STRING_CANCELABLE_DESC"],				text = nil },
		INCLUDE_NAME_PLATE_ONLY = { order = 8,	desc = L["FILTER_STRING_INCLUDE_NAME_PLATE_ONLY_DESC"],	text = nil },
		EXTERNAL_DEFENSIVE		= { order = 9,	desc = L["FILTER_STRING_EXTERNAL_DEFENSIVE_DESC"],		text = L["FILTER_STRING_EXTERNAL_DEFENSIVE_TEXT"],	testCommand = '/dump C_Spell.IsExternalDefensive(ID)' },
		CROWD_CONTROL			= { order = 10,	desc = L["FILTER_STRING_CROWD_CONTROL_DESC"],			text = L["FILTER_STRING_CROWD_CONTROL_TEXT"],		testCommand = '/dump C_Spell.IsSpellCrowdControl(ID)' },
		BIG_DEFENSIVE			= { order = 11,	desc = L["FILTER_STRING_BIG_DEFENSIVE_DESC"],			text = L["FILTER_STRING_BIG_DEFENSIVE_TEXT"],		testCommand = '/dump C_UnitAuras.AuraIsBigDefensive(ID)' },
		IMPORTANT				= { order = 12,	desc = L["FILTER_STRING_IMPORTANT_DESC"],				text = L["FILTER_STRING_IMPORTANT_TEXT"],			testCommand = '/dump C_Spell.IsSpellImportant(ID)' },
		DISPELLABLE				= { order = 13,	desc = L["FILTER_STRING_DISPELLABLE_DESC"],				text = nil },
	}

	local function AddGuideInput(group, key, order, text, desc, value, width)
		local input = ACH:Input(desc or '', text or ' ', order, nil, width or 'full', function() return (value:gsub('|', '||')) end)
		input.focusSelect = true
		group.args[key] = input
	end

	local function AddGuideRow(parent, key, order, text, desc, value, cmd, width)
		local pair = ACH:Group(desc or ' ', nil, order)
		pair.args.desc = ACH:Description(text or '', 1, 'medium', nil, nil, nil, nil, width or 'full')
		pair.inline = true

		AddGuideInput(pair, 'input', 2, '', nil, value, width)

		if cmd then
			AddGuideInput(pair, 'testCommand', 3, L["FILTER_TEST_COMMAND_TEXT"], L["FILTER_TEST_COMMAND_DESC"], cmd, width)
		end

		parent.args[key] = pair
	end

	function C:GetOptionsTable_FiltersGuide(order)
		local config = ACH:Group(L["Filters Guide"], nil, order or 100, 'tab', nil, nil, nil, not E.Retail)
		config.args.howToFilter = ACH:Group(L["How to filter"], nil, 1)
		config.args.howToFilter.args.desc = ACH:Description(L["HOW_TO_FILTER"], 1, 'medium', nil, nil, nil, nil, 'full')

		local examples = ACH:Group(L["Filter examples"], nil, 2)
		examples.args.header = ACH:Description(L["FILTER_EXAMPLES"], 0, 'medium', nil, nil, nil, nil, 'full')
		config.args.filterExamples = examples

		for key, data in next, listExamples do
			AddGuideRow(examples, key, data.order, data.text, data.desc, data.value, nil, 300)
		end

		local available = ACH:Group(L["Available Filters"], nil, 3)
		available.args.header = ACH:Description(L["AVAILABLE_FILTERS"], 0, 'medium', nil, nil, nil, nil, 'full')
		config.args.availableFilter = available

		for key, data in next, listFilters do
			AddGuideRow(available, key, data.order, data.text, data.desc, key, data.testCommand, 300)
		end

		config.args.filterCheckboxes = ACH:Group(L["Filter checkboxes"], nil, 4)
		config.args.filterCheckboxes.args.desc = ACH:Description(L["FILTER_CHECKBOXES"], 1, 'medium', nil, nil, nil, nil, 'full')

		return config
	end
end

do -- shared cooldown
	local function GetThresholds(name, order, db, profile, private, category)
		local thresholds = ACH:Group(name, nil, order, nil, function(info) local t = profile[category].colors[info[#info]] local d = private[category].colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a; end, function(info, r, g, b, a) local t = profile[category].colors[info[#info]]; t.r, t.g, t.b, t.a = r, g, b, a; E:CooldownSettings(db); end)
		if category ~= 'thresholdText' then
			thresholds.args.override = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return profile[category][info[#info]] end, function(info, value) profile[category][info[#info]] = value; E:CooldownSettings(db); end)
		end

		local hidden = thresholds.args.override and function() return not profile[category].override end
		thresholds.args.expiring = ACH:Color(L["Expiring"], L["Color when the text is about to expire."], 20, nil, nil, nil, nil, nil, hidden)
		thresholds.args.seconds = ACH:Color(L["Seconds"], L["Color when the text is in the seconds format."], 21, nil, nil, nil, nil, nil, hidden)
		thresholds.args.minutes = ACH:Color(L["Minutes"], L["Color when the text is in the minutes format."], 22, nil, nil, nil, nil, nil, hidden)
		thresholds.args.hours = ACH:Color(L["Hours"], L["Color when the text is in the hours format."], 23, nil, nil, nil, nil, nil, hidden)
		thresholds.args.days = ACH:Color(L["Days"], L["Color when the text is in the days format."], 24, nil, nil, nil, nil, nil, hidden)

		thresholds.args.expireThreshold = ACH:Range(L["Expiring Threshold"], L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"], 1, { min = -1, max = 20, step = 1 }, nil, function(info) return profile[category][info[#info]] end, function(info, value) profile[category][info[#info]] = value; E:CooldownSettings(db); end, nil, hidden)
		thresholds.args.secondsThreshold = ACH:Range(L["Seconds Threshold"], nil, 2, { min = -1, max = 50, step = 1 }, nil, function(info) return profile[category][info[#info]] end, function(info, value) profile[category][info[#info]] = value; E:CooldownSettings(db); end, nil, hidden)
		thresholds.args.spacer1 = ACH:Spacer(10, 'full')

		return thresholds
	end

	function C:GetCooldownConfig(db, profile, private, charges, lossOfControl)
		local enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function() return profile.enable end, function(_, value) profile.enable = value; E:CooldownSettings(db); end)

		local text = ACH:Group(L["Text"], nil, 10, nil, function(info) return profile[info[#info]] end, function(info, value) profile[info[#info]] = value; E:CooldownSettings(db); end, nil, function() return not profile.enable end)
		local fonts = ACH:Group(L["Fonts"], nil, 1)
		fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
		fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
		fonts.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
		fonts.inline = true
		text.args.fontGroup = fonts

		local position = ACH:Group(L["Text Position"], nil, 2)
		position.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPositions)
		position.args.offsetX = ACH:Range(L["X-Offset"], nil, 2, { min = -50, max = 50, step = 1 })
		position.args.offsetY = ACH:Range(L["Y-Offset"], nil, 3, { min = -50, max = 50, step = 1 })
		position.inline = true
		text.args.positionGroup = position

		local colors = ACH:Group(L["Color"], nil, 3, nil, function(info) local t = profile.colors[info[#info]] local d = private.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a; end, function(info, r, g, b, a) local t = profile.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a; E:CooldownSettings(db); end)
		colors.args.text = ACH:Color(L["Text Color"], nil, 1)
		colors.args.edge = ACH:Color(L["Edge Color"], nil, 2, true, nil, nil, nil, nil, db == 'aurabars')
		colors.args.swipe = ACH:Color(L["Swipe Color"], nil, 3, true, nil, nil, nil, nil, db == 'aurabars')
		colors.args.spacer1 = ACH:Spacer(4, 'full')
		colors.args.swipeCharge = ACH:Color(L["Swipe: Charge"], nil, 10, true, nil, nil, nil, nil, charges)
		colors.args.edgeCharge = ACH:Color(L["Edge: Charge"], nil, 11, true, nil, nil, nil, nil, charges)
		colors.args.edgeLOC = ACH:Color(L["Edge: Loss of Control"], nil, 12, true, nil, nil, nil, nil, lossOfControl)
		colors.args.swipeLOC = ACH:Color(L["Swipe: Loss of Control"], nil, 13, true, nil, nil, nil, nil, lossOfControl)
		colors.inline = true
		text.args.colorGroup = colors

		local thresholds = ACH:Group(L["Thresholds"], nil, 20, 'tab', nil, nil, nil, function() return not profile.enable end)
		thresholds.args.colorsTime = GetThresholds(L["Threshold: Text"], 10, db, profile, private, 'thresholdText')

		if db == 'actionbar' then
			thresholds.args.colorsCharge = GetThresholds(L["Threshold: Charge"], 20, db, profile, private, 'thresholdCharge')
			thresholds.args.colorsLoc = GetThresholds(L["Threshold: Loss of Control"], 30, db, profile, private, 'thresholdLoc')
		end

		return enable, text, thresholds
	end
end
