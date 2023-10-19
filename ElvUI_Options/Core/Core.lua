local E = unpack(ElvUI)
local D = E:GetModule('Distributor')
local S = E:GetModule('Skins')

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

local ACH = E.Libs.ACH
local GUI = E.Libs.AceGUI
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale)
local C = {
	version = tonumber(GetAddOnMetadata('ElvUI_Options', 'Version')),
	Blank = function() return '' end
}

E.Config = select(2, ...)
E.Config[1] = C
E.Config[2] = L

local _G = _G
local sort, strmatch, strsplit = sort, strmatch, strsplit
local format, gsub, ipairs, pairs = format, gsub, ipairs, pairs
local tconcat, tinsert, tremove = table.concat, tinsert, tremove

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local GameTooltip_Hide = GameTooltip_Hide

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

local DEVELOPERS = {
	'Tukz',
	'Haste',
	'Nightcracker',
	'Omega1970',
	'Blazeflack',
	'Crum',
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
	'Tukui Community',
	'Affinity',
	'Modarch',
	'Tirain',
	'Phima',
	'Veiled',
	'Alex',
	'Nidra',
	'Kurhyus',
	'Shrom',
	'BuG',
	'Kringel',
	'Botanica',
	'Yachanay',
	'Catok',
	'Caedis',
	'|cff00c0faBenik|r',
	'|T136012:15:15:0:0:64:64:5:59:5:59|t |cff006fdcRubgrsch|r',
	'AcidWeb |TInterface/AddOns/ElvUI/Core/Media/ChatLogos/Gem:15:15:-1:2:64:64:6:60:8:60|t',
	'|T135167:15:15:0:0:64:64:5:59:5:59|t Loon - For being right',
	'|T134297:15:15:0:0:64:64:5:59:5:59|t |cffFF7D0ABladesdruid|r - AKA SUPERBEAR',
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end

sort(DONATORS, SortList)
sort(DEVELOPERS, SortList)
sort(TESTERS, SortList)

for _, name in pairs(DONATORS) do
	tinsert(E.CreditsList, name)
end
local DONATOR_STRING = table.concat(DONATORS, '|n')
for _, name in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, name)
end
local DEVELOPER_STRING = table.concat(DEVELOPERS, '|n')
for _, name in pairs(TESTERS) do
	tinsert(E.CreditsList, name)
end
local TESTER_STRING = table.concat(TESTERS, '|n')

E.Options.args.info = ACH:Group(L["Information"], nil, 4)
E.Options.args.info.args.header = ACH:Description(L["ELVUI_DESC"], 1, 'medium')
E.Options.args.info.args.spacer = ACH:Spacer(2)

E.Options.args.info.args.support = ACH:Group(L["Support"], nil, 3)
E.Options.args.info.args.support.inline = true
E.Options.args.info.args.support.args.git = ACH:Execute(L["Ticket Tracker"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/tukui-org/ElvUI/issues') end, nil, nil, 140)
E.Options.args.info.args.support.args.discord = ACH:Execute(L["Discord"], nil, 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://discord.tukui.org') end, nil, nil, 140)

E.Options.args.info.args.download = ACH:Group(L["Download"], nil, 4)
E.Options.args.info.args.download.inline = true
E.Options.args.info.args.download.args.development = ACH:Execute(L["Development Version"], L["Link to the latest development version."], 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/tukui-org/ElvUI/archive/refs/heads/development.zip') end, nil, nil, 140)
E.Options.args.info.args.download.args.ptr = ACH:Execute(L["PTR Version"], L["Link to the latest PTR version."], 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/tukui-org/ElvUI/archive/refs/heads/ptr.zip') end, nil, nil, 140)
E.Options.args.info.args.download.args.changelog = ACH:Execute(L["Changelog"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/tukui-org/ElvUI/blob/development/CHANGELOG.md') end, nil, nil, 140)

E.Options.args.info.args.credits = ACH:Group(L["Credits"], nil, 5)
E.Options.args.info.args.credits.inline = true
E.Options.args.info.args.credits.args.string = ACH:Description(L["ELVUI_CREDITS"], 1, 'medium')

E.Options.args.info.args.coding = ACH:Group(L["Coding:"], nil, 6)
E.Options.args.info.args.coding.inline = true
E.Options.args.info.args.coding.args.string = ACH:Description(DEVELOPER_STRING, 1, 'medium')

E.Options.args.info.args.testers = ACH:Group(L["Testing:"], nil, 7)
E.Options.args.info.args.testers.inline = true
E.Options.args.info.args.testers.args.string = ACH:Description(TESTER_STRING, 1, 'medium')

E.Options.args.info.args.donators = ACH:Group(L["Donations:"], nil, 8)
E.Options.args.info.args.donators.inline = true
E.Options.args.info.args.donators.args.string = ACH:Description(DONATOR_STRING, 1, 'medium')

local profileTypeItems = { profile = L["Profile"], private = L["Private (Character Settings)"], global = L["Global (Account Settings)"], filters = L["Aura Filters"], styleFilters = L["NamePlate Style Filters"] }
local profileTypeListOrder = { 'profile', 'private', 'global', 'filters', 'styleFilters' }
local exportTypeItems = { text = L["Text"], luaTable = L["Table"], luaPlugin = L["Plugin"] }
local exportTypeListOrder = { 'text', 'luaTable', 'luaPlugin' }

local exportString = ''
local function ExportButton_OnClick(button)
	local widget = button.widget
	widget.Label1:SetText('')
	widget.Label2:SetText('')

	local profileType, exportFormat = widget.ProfileTypeDropdown:GetValue(), widget.ExportFormatDropdown:GetValue()
	local profileKey, profileExport = D:ExportProfile(profileType, exportFormat)
	if not profileKey or not profileExport then
		widget.Label1:SetText(L["Error exporting profile!"])
	else
		widget.Label1:SetText(format('%s: %s%s|r', L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]))

		if profileType == 'profile' then
			widget.Label2:SetText(format('%s: %s%s|r', L["Profile Name"], E.media.hexvaluecolor, profileKey))
		end
	end

	widget.editBox:SetText(profileExport)
	widget.editBox:HighlightText()
	widget.editBox:SetFocus()

	exportString = profileExport
end

local function EditBox_OnChar(editbox)
	editbox.parent:SetText(exportString)
	editbox:HighlightText()
end

local function Export_EditBox_OnTextChanged(editbox, userInput)
	if userInput then --Prevent user from changing export string
		editbox.parent:SetText(exportString)
		editbox:HighlightText()
	else --Scroll frame doesn't scroll to the bottom by itself, so let's do that now
		editbox.parent.scrollFrame:SetVerticalScroll(editbox.parent.scrollFrame:GetVerticalScrollRange())
	end
end

local function ImportButton_OnClick(button)
	local widget = button.widget
	widget.Label1:SetText('')
	widget.Label2:SetText('')

	local success = D:ImportProfile(widget.editBox:GetText())
	widget.Label1:SetText((success and L["Profile imported successfully!"]) or L["Error decoding data. Import string may be corrupted!"])
end

local function DecodeButton_OnClick(button)
	local widget = button.widget
	widget.Label1:SetText('')
	widget.Label2:SetText('')

	local profileType, profileKey, profileData = D:Decode(widget.editBox:GetText())
	local decodedText = (profileData and E:TableToLuaString(profileData)) or nil
	local importText = D:CreateProfileExport(decodedText, profileType, profileKey)
	widget.editBox:SetText(importText)
end

local Import_OldText = ''
local function Import_EditBox_OnTextChanged(editbox)
	local widget = editbox.widget

	local text = editbox:GetText()
	if text == '' then
		widget.Label1:SetText('')
		widget.Label2:SetText('')
		widget.importButton:SetDisabled(true)
		widget.decodeButton:SetDisabled(true)
	elseif Import_OldText ~= text then
		local stringType = D:GetImportStringType(text)
		widget.decodeButton:SetDisabled(stringType == 'Table')

		local profileType, profileKey = D:Decode(text)
		if not profileType or (profileType and profileType == 'profile' and not profileKey) then
			widget.Label1:SetText(L["Error decoding data. Import string may be corrupted!"])
			widget.Label2:SetText('')
			widget.importButton:SetDisabled(true)
			widget.decodeButton:SetDisabled(true)
		else
			widget.Label1:SetText(format('%s: %s%s|r', L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ''))
			if profileType == 'profile' then
				widget.Label2:SetText(format('%s: %s%s|r', L["Profile Name"], E.media.hexvaluecolor, profileKey))
			end

			--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
			editbox.parent.scrollFrame:UpdateScrollChildRect()
			editbox.parent.scrollFrame:SetVerticalScroll(editbox.parent.scrollFrame:GetVerticalScrollRange())

			widget.importButton:SetDisabled(false)
		end

		Import_OldText = text
	end
end

local function Widget_OnClose(widget)
	--Restore changed scripts
	widget.editBox:SetScript('OnChar', nil)
	widget.editBox:SetScript('OnTextChanged', widget.editBox.OnTextChangedOrig)
	widget.editBox:SetScript('OnCursorChanged', widget.editBox.OnCursorChangedOrig)
	widget.editBox.OnTextChangedOrig = nil
	widget.editBox.OnCursorChangedOrig = nil

	--Clear stored export string
	exportString = ''

	GUI:Release(widget)
	E:Config_OpenWindow()
end

local function AddChild(widget, child, key)
	widget[key] = child

	child.widget = widget

	widget:AddChild(child)
end

local function ExportImport_Open(mode)
	local widget = GUI:Create('Frame')
	widget:SetTitle('')
	widget:EnableResize(false)
	widget:SetWidth(800)
	widget:SetHeight(600)
	widget.frame:SetFrameStrata('FULLSCREEN_DIALOG')
	widget:SetLayout('flow')
	widget:SetCallback('OnClose', Widget_OnClose)

	local Box = GUI:Create('MultiLineEditBox-ElvUI')
	Box:SetNumLines(30)
	Box:DisableButton(true)
	Box:SetWidth(800)
	Box:SetLabel('')
	AddChild(widget, Box, 'Box')

	local editbox = Box.editBox
	--Save original script so we can restore it later
	editbox.OnTextChangedOrig = editbox:GetScript('OnTextChanged')
	editbox.OnCursorChangedOrig = editbox:GetScript('OnCursorChanged')

	--Remove OnCursorChanged script as it causes weird behaviour with long text
	editbox:SetScript('OnCursorChanged', nil)
	Box.scrollFrame:UpdateScrollChildRect()

	local Label1 = GUI:Create('Label')
	Label1:SetFontObject('GameFontHighlightMedium')
	Label1:SetText('.') --Set temporary text so height is set correctly
	Label1:SetWidth(800)
	AddChild(widget, Label1, 'Label1')

	local Label2 = GUI:Create('Label')
	Label2:SetFontObject('GameFontHighlightMedium')
	Label2:SetText('.|n.')
	Label2:SetWidth(800)
	AddChild(widget, Label2, 'Label2')

	-- link references
	editbox.parent = Box
	editbox.widget = widget
	widget.editBox = editbox -- Box.editBox
	widget.Label1 = Label1
	widget.Label2 = Label2
	widget.box = Box

	if mode == 'export' then
		widget:SetTitle(L["Export Profile"])

		local exportButton = GUI:Create('Button-ElvUI')
		exportButton:SetText(L["Export Now"])
		exportButton:SetAutoWidth(true)
		exportButton:SetCallback('OnClick', ExportButton_OnClick)
		AddChild(widget, exportButton, 'exportButton')

		local profileType = GUI:Create('Dropdown')
		profileType:SetMultiselect(false)
		profileType:SetLabel(L["Choose What To Export"])
		profileType:SetList(profileTypeItems, profileTypeListOrder)
		profileType:SetValue('profile') --Default export
		AddChild(widget, profileType, 'ProfileTypeDropdown')

		local exportFormat = GUI:Create('Dropdown')
		exportFormat:SetMultiselect(false)
		exportFormat:SetLabel(L["Choose Export Format"])
		exportFormat:SetList(exportTypeItems, exportTypeListOrder)
		exportFormat:SetValue('text') --Default format
		exportFormat:SetWidth(150)
		AddChild(widget, exportFormat, 'ExportFormatDropdown')

		--Set scripts
		editbox:SetScript('OnChar', EditBox_OnChar)
		editbox:SetScript('OnTextChanged', Export_EditBox_OnTextChanged)
	elseif mode == 'import' then
		widget:SetTitle(L["Import Profile"])
		local importButton = GUI:Create('Button-ElvUI') --This version changes text color on SetDisabled
		importButton:SetDisabled(true)
		importButton:SetText(L["Import Now"])
		importButton:SetAutoWidth(true)
		importButton:SetCallback('OnClick', ImportButton_OnClick)
		AddChild(widget, importButton, 'importButton')

		local decodeButton = GUI:Create('Button-ElvUI')
		decodeButton:SetDisabled(true)
		decodeButton:SetText(L["Decode Text"])
		decodeButton:SetAutoWidth(true)
		decodeButton:SetCallback('OnClick', DecodeButton_OnClick)
		AddChild(widget, decodeButton, 'decodeButton')

		editbox:SetFocus()
		editbox:SetScript('OnChar', nil)
		editbox:SetScript('OnTextChanged', Import_EditBox_OnTextChanged)
	end

	--Clear default text
	Label1:SetText('')
	Label2:SetText('')

	--Close ElvUI Options
	E.Libs.AceConfigDialog:Close('ElvUI')

	GameTooltip_Hide() --The tooltip from the Export/Import button stays on screen, so hide it
end

--Create Profiles Table
E.Options.args.profiles = ACH:Group(L["Profiles"], nil, 4, 'tab')
E.Options.args.profiles.args.desc = ACH:Description(L["This feature will allow you to transfer settings to other characters."], 0)
E.Options.args.profiles.args.distributeProfile = ACH:Execute(L["Share Current Profile"], L["Sends your current profile to your target."], 1, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name) elseif server then D:Distribute(name, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.distributeGlobal = ACH:Execute(L["Share Filters"], L["Sends your filter settings to your target."], 1, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name, false, true) elseif server then D:Distribute(name, true, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.exportProfile = ACH:Execute(L["Export Profile"], nil, 4, function() ExportImport_Open('export') end)
E.Options.args.profiles.args.importProfile = ACH:Execute(L["Import Profile"], nil, 5, function() ExportImport_Open('import') end)
E.Options.args.profiles.args.allowDistributor = ACH:Toggle(L["Allow Sharing"], L["Both users will need this option enabled."], 6, nil, nil, nil, function() return E.global.general.allowDistributor end, function(_, value) E.global.general.allowDistributor = value; D:UpdateSettings() end)
E.Options.args.profiles.args.spacer = ACH:Spacer(6)

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
