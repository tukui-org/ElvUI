local E, _, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local MC = E:GetModule('ModuleCopy')
local D = E:GetModule('Distributor')
local S = E:GetModule('Skins')

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
-- GLOBALS: ElvDB

local ACH = E.Libs.ACH
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale)
local C = {
	version = tonumber(GetAddOnMetadata('ElvUI_Options', 'Version')),
	Blank = function() return '' end,
	SearchCache = {},
	SearchText = '',
}

E.Config = select(2, ...)
E.Config[1] = C
E.Config[2] = L

local _G = _G
local next, sort, strmatch, strsplit, strsub = next, sort, strmatch, strsplit, strsub
local tconcat, tinsert, tremove, wipe = table.concat, tinsert, tremove, wipe
local format, gsub, ipairs, pairs, type = format, gsub, ipairs, pairs, type

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer

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
	FontFlags = ACH.FontValues,
	FontSize = { min = 8, max = 64, step = 1 },
	Roman = { 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX' }, -- 1 to 20
	AllPositions = { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' },
	EdgePositions = { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM' },
	SidePositions = { LEFT = 'LEFT', RIGHT = 'RIGHT' },
	TextPositions = { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' },
	AllPoints = { TOPLEFT = 'TOPLEFT', LEFT = 'LEFT', BOTTOMLEFT = 'BOTTOMLEFT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' },
	Anchors = { TOPLEFT = 'TOPLEFT', LEFT = 'LEFT', BOTTOMLEFT = 'BOTTOMLEFT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM' },
	Strata = { BACKGROUND = 'BACKGROUND', LOW = 'LOW', MEDIUM = 'MEDIUM', HIGH = 'HIGH', DIALOG = 'DIALOG', TOOLTIP = 'TOOLTIP' },
	SmartAuraPositions = {
		DISABLED = L["Disable"],
		BUFFS_ON_DEBUFFS = L["Buffs on Debuffs"],
		DEBUFFS_ON_BUFFS = L["Debuffs on Buffs"],
		FLUID_BUFFS_ON_DEBUFFS = L["Fluid Buffs on Debuffs"],
		FLUID_DEBUFFS_ON_BUFFS = L["Fluid Debuffs on Buffs"],
	}
}

do
	C.StateSwitchGetText = function(_, TEXT)
		local friend, enemy = strmatch(TEXT, '^Friendly:([^,]*)'), strmatch(TEXT, '^Enemy:([^,]*)')
		local text, blockB, blockS, blockT = friend or enemy or TEXT
		local SF, localized = E.global.unitframe.specialFilters[text], L[text]
		if SF and localized and text:match('^block') then blockB, blockS, blockT = localized:match('^%[(.-)](%s?)(.+)') end
		local filterText = (blockB and format('|cFF999999%s|r%s%s', blockB, blockS, blockT)) or localized or text
		return (friend and format('|cFF33FF33%s|r %s', _G.FRIEND, filterText)) or (enemy and format('|cFFFF3333%s|r %s', _G.ENEMY, filterText)) or filterText
	end

	local function filterMatch(s,v)
		local m1, m2, m3, m4 = '^'..v..'$', '^'..v..',', ','..v..'$', ','..v..','
		return (strmatch(s, m1) and m1) or (strmatch(s, m2) and m2) or (strmatch(s, m3) and m3) or (strmatch(s, m4) and v..',')
	end

	C.SetFilterPriority = function(db, groupName, auraType, value, remove, movehere, friendState)
		if not auraType or not value then return end
		local filter = db[groupName] and db[groupName][auraType] and db[groupName][auraType].priority
		if not filter then return end
		local found = filterMatch(filter, E:EscapeString(value))
		if found and movehere then
			local tbl, sv, sm = {strsplit(',',filter)}
			for i in ipairs(tbl) do
				if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
				if sv and sm then break end
			end
			tremove(tbl, sm)
			tinsert(tbl, sv, movehere)
			db[groupName][auraType].priority = tconcat(tbl,',')
		elseif found and friendState then
			local realValue = strmatch(value, '^Friendly:([^,]*)') or strmatch(value, '^Enemy:([^,]*)') or value
			local friend = filterMatch(filter, E:EscapeString('Friendly:'..realValue))
			local enemy = filterMatch(filter, E:EscapeString('Enemy:'..realValue))
			local default = filterMatch(filter, E:EscapeString(realValue))

			local state =
				(friend and (not enemy) and format('%s%s','Enemy:',realValue))					--[x] friend [ ] enemy: > enemy
			or	((not enemy and not friend) and format('%s%s','Friendly:',realValue))			--[ ] friend [ ] enemy: > friendly
			or	(enemy and (not friend) and default and format('%s%s','Friendly:',realValue))	--[ ] friend [x] enemy: (default exists) > friendly
			or	(enemy and (not friend) and strmatch(value, '^Enemy:') and realValue)			--[ ] friend [x] enemy: (no default) > realvalue
			or	(friend and enemy and realValue)												--[x] friend [x] enemy: > default

			if state then
				local stateFound = filterMatch(filter, E:EscapeString(state))
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
E.Options.name = format('%s: |cff99ff33%.2f|r', L["Version"], E.version)

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
	'|TInterface/AddOns/ElvUI/Core/Media/ChatLogos/Beer:15:15:0:0:64:64:5:59:5:59|t |cfff48cbaRepooc|r',
	'|TInterface/AddOns/ElvUI/Core/Media/ChatLogos/Clover:15:15:0:0:64:64:5:59:5:59|t |cff4beb2cLuckyone|r',
	E:TextGradient('Simpy but my name needs to be longer.', 0.18,1.00,0.49, 0.32,0.85,1.00, 0.55,0.38,0.85, 1.00,0.55,0.71, 1.00,0.68,0.32)
}

local TESTERS = {
	'Affinity',
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
	'AcidWeb |TInterface/AddOns/ElvUI/Core/Media/ChatLogos/Gem:15:15:-1:2:64:64:6:60:8:60|t',
	'|T135167:15:15:0:0:64:64:5:59:5:59|t Loon - For being right',
	'|T134297:15:15:0:0:64:64:5:59:5:59|t |cffFF7D0ABladesdruid|r - AKA SUPERBEAR',
}

local DONATORS = {
	'Dandruff',
	'Tobur/Tarilya',
	'Netu',
	'Alluren',
	'Thorgnir',
	'Emalal',
	'Bendmeova',
	'Curl',
	'Zarac',
	'Emmo',
	'Oz',
	'Hawké',
	'Aynya',
	'Tahira',
	'Karsten Lumbye Thomsen',
	'Thomas B. aka Pitschiqüü',
	'Sea Garnet',
	'Paul Storry',
	'Azagar',
	'Archury',
	'Donhorn',
	'Woodson Harmon',
	'Phoenyx',
	'Feat',
	'Konungr',
	'Leyrin',
	'Dragonsys',
	'Tkalec',
	'Paavi',
	'Giorgio',
	'Bearscantank',
	'Eidolic',
	'Cosmo',
	'Adorno',
	'Domoaligato',
	'Smorg',
	'Pyrokee',
	'Portable',
	'Ithilyn'
}

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

sort(DONATORS, SortList)
sort(DEVELOPERS, SortList)
sort(TESTERS, SortList)

local DEVELOPER_STRING = tconcat(DEVELOPERS, '|n')
local TESTER_STRING = tconcat(TESTERS, '|n')
local DONATOR_STRING = tconcat(DONATORS, '|n')

for _, names in next, { DEVELOPERS, TESTERS, DONATORS } do
	for _, name in next, names do
		local full = E:StripString(name)
		local override = CREDITS_OVERRIDE[full]
		tinsert(E.CreditsList, strsub(override or full, 0, 25))
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
	{ key = 'dev',			name = L["Development Version"],	url = 'https://github.com/tukui-org/ElvUI/archive/refs/heads/development.zip' },
	{ key = 'ptr',			name = L["PTR Version"],			url = 'https://github.com/tukui-org/ElvUI/archive/refs/heads/ptr.zip' },
	{ key = 'changelog',	name = L["Changelog"],				url = 'https://github.com/tukui-org/ElvUI/blob/development/CHANGELOG.md' },
	{ key = 'customTexts',	name = L["Custom Texts"],			url = 'https://github.com/tukui-org/ElvUI/wiki/custom-texts' },
	{ key = 'paging',		name = L["Action Paging"],			url = 'https://github.com/tukui-org/ElvUI/wiki/paging' },
	{ key = 'performance',	name = L["Performance"],			url = 'https://github.com/tukui-org/ElvUI/wiki/performance-optimization' },
} do
	E.Options.args.info.args.main.args[data.key] = ACH:Input(data.name, nil, index, nil, 255, function() return data.url end)
	E.Options.args.info.args.main.args[data.key].focusSelect = true
end

local credits = ('*%s|r|cFFffffff below.  Made with|r |cFFff75dd<3|r |cFFffffffby the Tukui Community.|r'):gsub('*', E.InfoColor)
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
E.Options.args.profiles.args.distributeProfile = ACH:Execute(L["Share Current Profile"], L["Sends your current profile to your target."], 1, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name) elseif server then D:Distribute(name, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.distributeGlobal = ACH:Execute(L["Share Filters"], L["Sends your filter settings to your target."], 2, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name, false, true) elseif server then D:Distribute(name, true, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.allowDistributor = ACH:Toggle(L["Allow Sharing"], L["Both users will need this option enabled."], 3, nil, nil, nil, function() return E.global.general.allowDistributor end, function(_, value) E.global.general.allowDistributor = value; D:UpdateSettings() end)
E.Options.args.profiles.args.spacer = ACH:Spacer(10)

E.Options.args.profiles.args.profile = E.Libs.AceDBOptions:GetOptionsTable(E.data)
E.Options.args.profiles.args.private = E.Libs.AceDBOptions:GetOptionsTable(E.charSettings)

E.Options.args.profiles.args.profile.name = L["Profile"]
E.Options.args.profiles.args.profile.order = 1
E.Options.args.profiles.args.private.name = L["Private"]
E.Options.args.profiles.args.private.order = 2

E.Libs.AceConfig:RegisterOptionsTable('ElvProfiles', E.Options.args.profiles.args.profile)

if E.Retail or E.Wrath then
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
	local function validateString(_, value) return value and not strmatch(value, '^[%s%p]-$') end
	local profileTypeItems = { profile = L["Profile"], private = L["Private (Character Settings)"], global = L["Global (Account Settings)"], filters = L["Aura Filters"], styleFilters = L["NamePlate Style Filters"] }

	local function DecodeString(text, plugin)
		local profileType, profileKey, profileData = D:Decode(text)

		if plugin then
			return E:ProfileTableToPluginFormat(profileData, profileType)
		else
			local decodedText = (profileData and E:TableToLuaString(profileData)) or nil
			return D:CreateProfileExport(decodedText, profileType, profileKey)
		end
	end

	local function DecodeLabel(label, text, plugin)
		if not validateString(nil, text) then
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

				if which == 'text' and validateString(nil, importText) then
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
					local profileKey, profileExport = D:ExportProfile(profileType, which)
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
		export.args.profileTye = ACH:MultiSelect(L["Choose What To Export"], nil, 10, profileTypeItems, nil, nil, Filters_Get, Filters_Set)
		export.args.profileTye.customWidth = 225
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

		config.args.cooldown.name = L["Cooldown Text"]
		config.args.cooldown.order = 2

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
		config.args.extraActionButton.name = L["Boss Button"]
		config.args.vehicleExitButton.name = L["Vehicle Exit"]
		config.args.zoneActionButton.name = L["Zone Ability"]

		return config
	end

	--Auras
	local function CreateAurasConfig()
		local config = MC:CreateModuleConfigGroup(L["Auras"], 'auras')

		MC:AddConfigOptions(P.auras, config, 'auras')

		config.args.cooldown.name = L["Cooldown Text"]
		config.args.cooldown.order = 2

		config.args.buffs.name = L["Buffs"]
		config.args.debuffs.name = L["Debuffs"]

		return config
	end

	--Bags
	local function CreateBagsConfig()
		local config = MC:CreateModuleConfigGroup(L["Bags"], 'bags')

		MC:AddConfigOptions(P.bags, config, 'bags')

		config.args.cooldown.name = L["Cooldown Text"]
		config.args.cooldown.order = 2

		config.args.ignoredItems = nil
		config.args.colors.name = L["Colors"]
		config.args.bagBar.name = L["Bag Bar"]
		config.args.split.name = L["Split"]
		config.args.vendorGrays.name = L["Vendor Grays"]

		return config
	end

	--Chat
	local function CreateChatConfig()
		local config = MC:CreateModuleConfigGroup(L["Chat"], 'chat')

		MC:AddConfigOptions(P.chat, config, 'chat')

		return config
	end

	--Cooldowns
	local function CreateCooldownConfig()
		local config = MC:CreateModuleConfigGroup(L["Cooldown Text"], 'cooldown')

		MC:AddConfigOptions(P.cooldown, config, 'cooldown')

		config.args.fonts = ACH:Toggle(L["Fonts"], nil, 2)

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

		return config
	end

	--DataTexts
	local function CreateDatatextsConfig()
		local config = MC:CreateModuleConfigGroup(L["DataTexts"], 'datatexts')

		MC:AddConfigOptions(P.datatexts, config, 'datatexts')

		config.args.panels = ACH:Toggle(L["Panels"], nil, 2)

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

		return config
	end

	--NamePlates
	local function CreateNamePlatesConfig()
		local config = MC:CreateModuleConfigGroup(L["Nameplates"], 'nameplates')

		MC:AddConfigOptions(P.nameplates, config, 'nameplates')

		-- Locales
		config.args.cooldown.name = L["Cooldown Text"]
		config.args.cooldown.order = 2

		config.args.threat.name = L["Threat"]
		config.args.cutaway.name = L["Cutaway Bars"]
		config.args.clickThrough.name = L["Click Through"]
		config.args.plateSize.name = L["Clickable Size"]
		config.args.colors.name = L["Colors"]
		config.args.visibility.name = L["Visibility"]

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

		return config
	end

	--UnitFrames
	local function CreateUnitframesConfig()
		local config = MC:CreateModuleConfigGroup(L["UnitFrames"], 'unitframe')

		MC:AddConfigOptions(P.unitframe, config, 'unitframe')

		config.args.cooldown = ACH:Toggle(L["Cooldown Text"], nil, 2, nil, nil, nil, function(info) return E.global.profileCopy.unitframe[info[#info]] end, function(info, value) E.global.profileCopy.unitframe[info[#info]] = value; end)
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
	E.Options.args.profiles.args.modulereset.args.intro = ACH:Description(L["This section will help reset specfic settings back to default."], 1)
	E.Options.args.profiles.args.modulereset.args.space1 = ACH:Spacer(2)
	E.Options.args.profiles.args.modulereset.args.general = ACH:Execute(L["General"], nil, 3, nil, nil, L["Are you sure you want to reset General settings?"])
	E.Options.args.profiles.args.modulereset.args.actionbar = ACH:Execute(L["ActionBars"], nil, 4, nil, nil, L["Are you sure you want to reset ActionBars settings?"])
	E.Options.args.profiles.args.modulereset.args.bags = ACH:Execute(L["Bags"], nil, 5, nil, nil, L["Are you sure you want to reset Bags settings?"])
	E.Options.args.profiles.args.modulereset.args.auras = ACH:Execute(L["Auras"], nil, 6, nil, nil, L["Are you sure you want to reset Auras settings?"])
	E.Options.args.profiles.args.modulereset.args.chat = ACH:Execute(L["Chat"], nil, 7, nil, nil, L["Are you sure you want to reset Chat settings?"])
	E.Options.args.profiles.args.modulereset.args.cooldown = ACH:Execute(L["Cooldown Text"], nil, 8, nil, nil, L["Are you sure you want to reset Cooldown settings?"])
	E.Options.args.profiles.args.modulereset.args.databars = ACH:Execute(L["DataBars"], nil, 9, nil, nil, L["Are you sure you want to reset DataBars settings?"])
	E.Options.args.profiles.args.modulereset.args.datatexts = ACH:Execute(L["DataTexts"], nil, 10, nil, nil, L["Are you sure you want to reset DataTexts settings?"])
	E.Options.args.profiles.args.modulereset.args.nameplates = ACH:Execute(L["Nameplates"], nil, 11, nil, nil, L["Are you sure you want to reset NamePlates settings?"])
	E.Options.args.profiles.args.modulereset.args.tooltip = ACH:Execute(L["Tooltip"], nil, 12, nil, nil, L["Are you sure you want to reset Tooltip settings?"])
	E.Options.args.profiles.args.modulereset.args.uniframes = ACH:Execute(L["UnitFrames"], nil, 13, function() E:CopyTable(E.db.unitframe, P.unitframe); UF:Update_AllFrames() end, nil, L["Are you sure you want to reset UnitFrames settings?"])
end
