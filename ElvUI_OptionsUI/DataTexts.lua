local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local DT = E:GetModule('DataTexts')
local Layout = E:GetModule('Layout')
local Chat = E:GetModule('Chat')
local Minimap = E:GetModule('Minimap')
local ACH = E.Libs.ACH

local _G = _G
local type, pairs, ipairs = type, pairs, ipairs
local gsub, next, wipe, ceil = gsub, next, wipe, ceil
local format, tostring, tonumber = format, tostring, tonumber

-- GLOBALS: AceGUIWidgetLSMlists
local currencyList, DTPanelOptions = {}, {}

DTPanelOptions.numPoints = ACH:Range(L["Number of DataTexts"], nil, 2, { min = 1, softMax = 20, step = 1})
DTPanelOptions.growth = ACH:Select(L["Growth"], nil, 3, { HORIZONTAL = 'HORIZONTAL', VERTICAL = 'VERTICAL' })
DTPanelOptions.width = ACH:Range(L["Width"], nil, 4, { min = 24, max = ceil(E.screenWidth), step = 1})
DTPanelOptions.height = ACH:Range(L["Height"], nil, 5, { min = 12, max = ceil(E.screenHeight), step = 1})
DTPanelOptions.textJustify = ACH:Select(L["Text Justify"], L["Sets the font instance's horizontal text alignment style."], 6, { CENTER = L["Center"], LEFT = L["Left"], RIGHT = L["Right"] })

DTPanelOptions.templateGroup = ACH:MultiSelect(L["Template"], nil, 10, { backdrop = L["Backdrop"], panelTransparency = L["Backdrop Transparency"], mouseover = L["Mouseover"], border = L["Show Border"] })
DTPanelOptions.templateGroup.sortByValue = true

DTPanelOptions.strataAndLevel = ACH:Group(L["Strata and Level"], nil, 15)
DTPanelOptions.strataAndLevel.inline = true

DTPanelOptions.strataAndLevel.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 1, C.Values.Strata)
DTPanelOptions.strataAndLevel.args.frameLevel = ACH:Range(L["Frame Level"], nil, 2, {min = 1, max = 128, step = 1})

DTPanelOptions.tooltip = ACH:Group(L["Tooltip"], nil, 20)
DTPanelOptions.tooltip.inline = true

DTPanelOptions.tooltip.args.tooltipAnchor = ACH:Select(L["Anchor"], nil, 0, { ANCHOR_TOP = L["TOP"], ANCHOR_RIGHT = L["RIGHT"], ANCHOR_BOTTOM = L["BOTTOM"], ANCHOR_LEFT = L["LEFT"], ANCHOR_TOPRIGHT = L["TOPRIGHT"], ANCHOR_BOTTOMRIGHT = L["BOTTOMRIGHT"], ANCHOR_TOPLEFT = L["TOPLEFT"], ANCHOR_BOTTOMLEFT = L["BOTTOMLEFT"], ANCHOR_CURSOR = L["CURSOR"], ANCHOR_CURSOR_LEFT = L["CURSOR_LEFT"], ANCHOR_CURSOR_RIGHT = L["CURSOR_RIGHT"] })
DTPanelOptions.tooltip.args.tooltipXOffset = ACH:Range(L["X-Offset"], nil, 1, { min = -30, max = 30, step = 1 })
DTPanelOptions.tooltip.args.tooltipYOffset = ACH:Range(L["Y-Offset"], nil, 2, { min = -30, max = 30, step = 1 })

DTPanelOptions.visibility = ACH:Input(L["Visibility State"], L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"], 25, nil, 'full')

local function ColorizeName(name, color)
	return format('|cFF%s%s|r', color or 'ffd100', name)
end

local function PanelGroup_Delete(panel)
	E.Options.args.datatexts.args.panels.args[panel] = nil
	E.db.datatexts.panels[panel] = nil
	E.global.datatexts.customPanels[panel] = nil

	DT:ReleasePanel(panel)
	E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'datatexts', 'panels', 'newPanel')
end

local function PanelGroup_Create(panel)
	local opts = E.Options.args.datatexts.args.panels.args[panel]
	if not opts then
		opts = ACH:Group(ColorizeName(panel), nil, nil, nil, function(info) return E.db.datatexts.panels[panel][info[#info]] end, function(info, value) E.db.datatexts.panels[panel][info[#info]] = value DT:UpdatePanelAttributes(panel, E.global.datatexts.customPanels[panel]) end)
		opts.args.enable = ACH:Toggle(L["Enable"], nil, 0)

		opts.args.panelOptions = ACH:Group(L["Panel Options"], nil, 2, nil, function(info) return E.global.datatexts.customPanels[panel][info[#info]] end, function(info, value) E.global.datatexts.customPanels[panel][info[#info]] = value DT:UpdatePanelAttributes(panel, E.global.datatexts.customPanels[panel]) end)
		opts.args.panelOptions.inline = true

		opts.args.panelOptions.args.delete = ACH:Execute(L["Delete"], nil, -1, function() PanelGroup_Delete(panel) end, nil, true, 'full')

		opts.args.panelOptions.args.fonts = ACH:Group(L["Fonts"], nil, 10, nil, function(info) local settings = E.global.datatexts.customPanels[panel] if not settings.fonts then settings.fonts = E:CopyTable({}, G.datatexts.newPanelInfo.fonts) end return settings.fonts[info[#info]] end, function(info, value) E.global.datatexts.customPanels[panel].fonts[info[#info]] = value DT:UpdatePanelAttributes(panel, E.global.datatexts.customPanels[panel]) end, function() return not (E.global.datatexts.customPanels[panel] and E.global.datatexts.customPanels[panel].fonts and E.global.datatexts.customPanels[panel].fonts.enable) end)
		opts.args.panelOptions.args.fonts.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, false)
		opts.args.panelOptions.args.fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
		opts.args.panelOptions.args.fonts.args.fontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
		opts.args.panelOptions.args.fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)

		local panelOpts = E:CopyTable(opts.args.panelOptions.args, DTPanelOptions)
		panelOpts.numPoints.set = function(info, value) E.global.datatexts.customPanels[panel][info[#info]] = value DT:UpdatePanelAttributes(panel, E.global.datatexts.customPanels[panel]) DT:SetupPanelOptions(panel) end
		panelOpts.tooltip.args.tooltipYOffset.disabled = function() return E.global.datatexts.customPanels[panel].tooltipAnchor == 'ANCHOR_CURSOR' end
		panelOpts.tooltip.args.tooltipXOffset.disabled = function() return E.global.datatexts.customPanels[panel].tooltipAnchor == 'ANCHOR_CURSOR' end
		panelOpts.templateGroup.get = function(_, key) return E.global.datatexts.customPanels[panel][key] end
		panelOpts.templateGroup.set = function(_, key, value) E.global.datatexts.customPanels[panel][key] = value; DT:UpdatePanelAttributes(panel, E.global.datatexts.customPanels[panel]) end

		E.Options.args.datatexts.args.panels.args[panel] = opts
	end

	opts.args.dts = ACH:Group(L["DataTexts"], nil, 1)
	opts.args.dts.inline = true

	return opts
end

local dts = { [''] = L["None"] }

function DT:SetupPanelOptions(name)
	local options = PanelGroup_Create(name)

	if P.datatexts.panels[name] and P.datatexts.panels[name].numPoints then
		for i in ipairs(E.db.datatexts.panels[name]) do
			if i > E.db.datatexts.panels[name].numPoints then
				DT.db.panels[name][i] = nil
			end
		end

		for i = 1, E.db.datatexts.panels[name].numPoints do
			if not DT.db.panels[name][i] then
				DT.db.panels[name][i] = P.datatexts.panels[name][i] or ''
			end
		end
	end

	for dtSlot in ipairs(DT.db.panels[name]) do
		if E.global.datatexts.customPanels[name] and dtSlot > E.global.datatexts.customPanels[name].numPoints then
			DT.db.panels[name][dtSlot] = nil
		else
			options.args.dts.args[tostring(dtSlot)] = ACH:Select('', nil, dtSlot, function() return E:CopyTable(dts, DT.DataTextList) end, nil, nil, function(info) return E.db.datatexts.panels[name][tonumber(info[#info])] end, function(info, value) E.db.datatexts.panels[name][tonumber(info[#info])] = value DT:UpdatePanelInfo(name) end)
		end
	end
end

function DT:PanelLayoutOptions()
	local options = E.Options.args.datatexts.args.panels.args

	-- Custom Panels
	for panel in pairs(E.global.datatexts.customPanels) do
		DT:SetupPanelOptions(panel)
	end

	-- This will mixin the options for the Custom Panels.
	for name, tab in pairs(DT.db.panels) do
		if type(tab) == 'table' then
			if not options[name] then
				options[name] = ACH:Group(ColorizeName(name, 'ffffff'), nil, nil, nil, function(info) return E.db.datatexts.panels[name][info[#info]] end, function(info, value) E.db.datatexts.panels[name][info[#info]] = value DT:UpdatePanelInfo(name) end)
			end

			if not P.datatexts.panels[name] and not E.global.datatexts.customPanels[name] then
				options[name].args.delete = ACH:Execute(L["Delete"], nil, 2, function() PanelGroup_Delete(name) end)
				options[name].args.rebuild = ACH:Execute(L["Rebuild"], nil, 1, function() E.global.datatexts.customPanels[name] = E:CopyTable({}, G.datatexts.newPanelInfo) local infoType = type(E.db.datatexts.panels[name]) if infoType == 'string' then E.db.datatexts.panels[name] = { enable = true } for i = 1, G.datatexts.newPanelInfo.numPoints do E.db.datatexts.panels[name][i] = '' end elseif infoType == 'table' then E.db.datatexts.panels[name].enable = true E.global.datatexts.customPanels[name].numPoints = #E.db.datatexts.panels[name] end DT:SetupPanelOptions(name) DT:BuildPanelFrame(name) E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'datatexts', 'panels', name) end)
			else
				for option in ipairs(tab) do
					if E.global.datatexts.customPanels[name] and option > E.global.datatexts.customPanels[name].numPoints then
						tab[option] = nil
					else
						if not options[name].args.dts then
							options[name].args.dts = ACH:Group(L["DataTexts"], nil, 1)
							options[name].args.dts.inline = true
						end

						options[name].args.dts.args[tostring(option)] = ACH:Select('', nil, option, function() return E:CopyTable(dts, DT.DataTextList) end, nil, nil, function(info) return E.db.datatexts.panels[name][tonumber(info[#info])] end, function(info, value) E.db.datatexts.panels[name][tonumber(info[#info])] = value DT:UpdatePanelInfo(name) end)
					end
				end
			end
		end
	end
end

local function CreateCustomCurrencyOptions(currencyID)
	local currency = E.global.datatexts.customCurrencies[currencyID]
	if currency then
		local options = ACH:Group(currency.NAME, nil, 1, nil, function(info) return E.global.datatexts.customCurrencies[currencyID][info[#info]] end, function(info, value) E.global.datatexts.customCurrencies[currencyID][info[#info]] = value DT:UpdateCustomCurrencySettings(currency.NAME, info[#info], value) DT:LoadDataTexts() end)

		options.args.DISPLAY_STYLE = ACH:Select(L["Display Style"], nil, 1, { ICON = L["Icons Only"], ICON_TEXT = L["Icons and Text"], ICON_TEXT_ABBR = L["Icons and Text (Short)"] })
		options.args.SHOW_MAX = ACH:Toggle(L["Current / Max"], nil, 2)
		options.args.USE_TOOLTIP = ACH:Toggle(L["Tooltip"], nil, 3)
		options.args.DISPLAY_IN_MAIN_TOOLTIP = ACH:Toggle(L["Display In Main Tooltip"], L["If enabled, then this currency will be displayed in the main Currencies datatext tooltip."], 4, nil, nil, nil, nil, nil, nil, DT.CurrencyList[tostring(currencyID)] and true)

		E.Options.args.datatexts.args.customCurrency.args[currency.NAME] = options
	end
end

local function SetupCustomCurrencies()
	for currencyID in pairs(E.global.datatexts.customCurrencies) do
		CreateCustomCurrencyOptions(currencyID)
	end
end

local function escapeString(str, get)
	return get == gsub(str, '|', '||') or gsub(str, '||', '|')
end

local function CreateDTOptions(name, data)
	local settings = E.global.datatexts.settings[name]
	if not settings then return end

	local optionTable = ACH:Group(data.localizedName or name, nil, nil, nil, function(info) return settings[info[#info]] end, function(info, value) settings[info[#info]] = value DT:ForceUpdate_DataText(name) end)

	E.Options.args.datatexts.args.settings.args[name] = optionTable

	for key in pairs(settings) do
		if key == 'Label' then
			optionTable.args[key] = ACH:Input(L["Label"], nil, 2, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:ForceUpdate_DataText(name) end)
		elseif key == 'NoLabel' then
			optionTable.args[key] = ACH:Toggle(L["No Label"], nil, 3)
		elseif key == 'ShowOthers' then
			optionTable.args[key] = ACH:Toggle(L["Other AddOns"], nil, 4)
		elseif key == 'decimalLength' then
			optionTable.args[key] = ACH:Range(L["Decimal Length"], nil, 20, { min = 0, max = 5, step = 1 })
		elseif key == 'goldFormat' then
			optionTable.args[key] = ACH:Select(L["Gold Format"], L["The display format of the money text that is shown in the gold datatext and its tooltip."], 10, { SMART = L["Smart"], FULL = L["Full"], SHORT = L["SHORT"], SHORTSPACED = L["Short (Whole Numbers Spaced)"], SHORTINT = L["Short (Whole Numbers)"], CONDENSED = L["Condensed"], CONDENSED_SPACED = L["Condensed (Spaced)"], BLIZZARD = L["Blizzard Style"], BLIZZARD2 = L["Blizzard Style"].." 2" })
		elseif key == 'goldCoins' then
			optionTable.args[key] = ACH:Toggle(L["Show Coins"], L["Use coin icons instead of colored text."], 5)
		elseif key == 'textFormat' then
			optionTable.args[key] = ACH:Select(L["Text Format"], nil, 20, nil, nil, 'double', function(info) return settings[info[#info]] end, function(info, value) settings[info[#info]] = value; DT:ForceUpdate_DataText(name) end)
		elseif key == 'latency' then
			optionTable.args[key] = ACH:Select(L["Latency"], nil, 20, { WORLD = L["World Latency"], HOME = L["Home Latency"] })
		elseif key == 'school' then
			optionTable.args[key] = ACH:Select(L["School"], nil, 20, { [0] = "Default", [1] = "Physical", [2] = "Holy", [3] = "Fire", [4] = "Nature", [5] = "Frost", [6] = "Shadow", [7] = "Arcane" })
		end
	end

	if name == 'Combat' then
		optionTable.args.TimeFull = ACH:Toggle(L["Full Time"], nil, 5)
	elseif name == "CombatIndicator" then
		optionTable.args.OutOfCombat = ACH:Input(L["Out of Combat Label"], nil, 1, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:ForceUpdate_DataText(name) end)
		optionTable.args.OutOfCombatColor = ACH:Color('', nil, 2, nil, nil, function(info) local c, d = settings[info[#info]], G.datatexts.settings[name][info[#info]] return c.r, c.g, c.b, nil, d.r, d.g, d.b end, function(info, r, g, b) local c = settings[info[#info]] c.r, c.g, c.b = r, g, b DT:ForceUpdate_DataText(name) end)
		optionTable.args.Spacer = ACH:Spacer(3, 'full')
		optionTable.args.InCombat = ACH:Input(L["In Combat Label"], nil, 4, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:ForceUpdate_DataText(name) end)
		optionTable.args.InCombatColor = ACH:Color('', nil, 5, nil, nil, function(info) local c, d = settings[info[#info]], G.datatexts.settings[name][info[#info]] return c.r, c.g, c.b, nil, d.r, d.g, d.b end, function(info, r, g, b) local c = settings[info[#info]] c.r, c.g, c.b = r, g, b DT:ForceUpdate_DataText(name) end)
	elseif name == 'Currencies' then
		optionTable.args.displayedCurrency = ACH:Select(L["Displayed Currency"], nil, 10, function() local list = E:CopyTable({}, DT.CurrencyList) for _, info in pairs(E.global.datatexts.customCurrencies) do local id = tostring(info.ID) if info and not DT.CurrencyList[id] then list[id] = info.NAME end end return list end)
		optionTable.args.displayedCurrency.sortByValue = true

		optionTable.args.displayStyle = ACH:Select(L["Display Style"], nil, 1, { ICON = L["Icons Only"], ICON_TEXT = L["Icons and Text"], ICON_TEXT_ABBR = L["Icons and Text (Short)"] }, nil, nil, nil, nil, nil, function() return (settings.displayedCurrency == "GOLD") or (settings.displayedCurrency == "BACKPACK") end)
		optionTable.args.headers = ACH:Toggle(L["Headers"], nil, 5)
		optionTable.args.maxCurrency = ACH:Toggle(L["Show Max Currency"], nil, 5)
		optionTable.args.tooltipLines = ACH:Group(L["Tooltip Lines"], nil, -1)
		optionTable.args.tooltipLines.inline = true

		for i, info in ipairs(G.datatexts.settings.Currencies.tooltipData) do
			if not info[2] then
				local Group = ACH:Group(info[1], nil, i)
				Group.inline = true

				optionTable.args.tooltipLines.args[tostring(i)] = Group
			elseif info[3] then
				optionTable.args.tooltipLines.args[tostring(info[3])].args[tostring(i)] = ACH:Toggle(info[1], nil, i, nil, nil, nil, function() return settings.idEnable[info[2]] end, function(_, value) settings.idEnable[info[2]] = value end)
			end
		end
	elseif name == 'Time' then
		optionTable.args.time24 = ACH:Toggle(L["24-Hour Time"], L["Toggle 24-hour mode for the time datatext."], 5)
		optionTable.args.localTime = ACH:Toggle(L["Local Time"], L["If not set to true then the server time will be displayed instead."], 6)
		optionTable.args.flashInvite = ACH:Toggle(L["Flash Invites"], L["This will allow you to toggle flashing of the time datatext when there are calendar invites."], 7, nil, nil, nil, nil, nil, nil, E.Classic or E.TBC)
	elseif name == 'Durability' then
		optionTable.args.percThreshold = ACH:Range(L["Flash Threshold"], L["The durability percent that the datatext will start flashing.  Set to -1 to disable"], 5, { min = -1, max = 99, step = 1 }, nil, function(info) return settings[info[#info]] end, function(info, value) settings[info[#info]] = value; DT:ForceUpdate_DataText(name) end)
	elseif name == 'Friends' then
		optionTable.args.description = ACH:Description(L["Hide specific sections in the datatext tooltip."], 1)
		optionTable.args.hideGroup1 = ACH:MultiSelect(L["Hide by Status"], nil, 5, { hideAFK = L["AFK"], hideDND = L["DND"] }, nil, nil, function(_, key) return settings[key] end, function(_, key, value) settings[key] = value; DT:ForceUpdate_DataText(name) end)
		optionTable.args.hideGroup2 = ACH:MultiSelect(L["Hide by Application"], nil, 6, DT.clientFullName, nil, nil, function(_, key) return settings['hide'..key] end, function(_, key, value) settings['hide'..key] = value; DT:ForceUpdate_DataText(name) end)
		optionTable.args.hideGroup2.sortByValue = true
	elseif name == 'Reputation' or name == 'Experience' then
		optionTable.args.textFormat.values = { PERCENT = L["Percent"], CUR = L["Current"], REM = L["Remaining"], CURMAX = L["Current - Max"], CURPERC = L["Current - Percent"], CURREM = L["Current - Remaining"], CURPERCREM = L["Current - Percent (Remaining)"] }
	elseif name == 'Bags' then
		optionTable.args.textFormat.values = { FREE = L["Only Free Slots"], USED = L["Only Used Slots"], FREE_TOTAL = L["Free/Total"], USED_TOTAL = L["Used/Total"] }
	end
end

local function SetupDTCustomization()
	local currencyTable = {}
	for name, data in pairs(DT.RegisteredDataTexts) do
		currencyTable[name] = data
	end

	if E.Retail then
		for _, info in pairs(E.global.datatexts.customCurrencies) do
			local name = info.NAME
			if currencyTable[name] then
				currencyTable[name] = nil
			end
		end
	end

	for name, data in pairs(currencyTable) do
		if not data.isLibDataBroker then
			CreateDTOptions(name, data)
		end
	end
end

local defaultTemplateGroup = ACH:Group(' ', nil, 2)
defaultTemplateGroup.inline = true
defaultTemplateGroup.args.backdrop = ACH:Toggle(L["Backdrop"], nil, 1)
defaultTemplateGroup.args.border = ACH:Toggle(L["Border"], nil, 2, nil, nil, nil, nil, nil, function(info) return not E.db.datatexts.panels[info[#info - 2]].backdrop end)
defaultTemplateGroup.args.panelTransparency = ACH:Toggle(L["Panel Transparency"], nil, 3, nil, nil, nil, nil, nil, function(info) return not E.db.datatexts.panels[info[#info - 2]].backdrop end)

local DataTexts = ACH:Group(L["DataTexts"], nil, 2, 'tab', function(info) return E.db.datatexts[info[#info]] end, function(info, value) E.db.datatexts[info[#info]] = value; DT:LoadDataTexts() end)
E.Options.args.datatexts = DataTexts

DataTexts.args.intro = ACH:Description(L["DATATEXT_DESC"], 1)
DataTexts.args.spacer = ACH:Spacer(2)
DataTexts.args.general = ACH:Group(L["General"], nil, 3)

DataTexts.args.general.args.generalGroup = ACH:Group(L["General"], nil, 2)
DataTexts.args.general.args.generalGroup.inline = true
DataTexts.args.general.args.generalGroup.args.battleground = ACH:Toggle(L["Battleground Texts"], L["When inside a battleground display personal scoreboard information on the main datatext bars."], 1)
DataTexts.args.general.args.generalGroup.args.noCombatClick = ACH:Toggle(L["Block Combat Click"], L["Blocks all click events while in combat."], 2)
DataTexts.args.general.args.generalGroup.args.noCombatHover = ACH:Toggle(L["Block Combat Hover"], L["Blocks datatext tooltip from showing in combat."], 3)

DataTexts.args.general.args.fontGroup = ACH:Group(L["Font Group"], nil, 3)
DataTexts.args.general.args.fontGroup.inline = true

DataTexts.args.general.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
DataTexts.args.general.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
DataTexts.args.general.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
DataTexts.args.general.args.fontGroup.args.wordWrap = ACH:Toggle(L["Word Wrap"], nil, 4)

DataTexts.args.panels = ACH:Group(L["Panels"], nil, 4)

DataTexts.args.panels.args.newPanel = ACH:Group(ColorizeName(L["New Panel"], '33ff33'), nil, 0, nil, function(info) return E.global.datatexts.newPanelInfo[info[#info]] end, function(info, value) E.global.datatexts.newPanelInfo[info[#info]] = value end)
DataTexts.args.panels.args.newPanel.args.name = ACH:Input(L["Name"], nil, 0, nil, 'full', nil, nil, nil, nil, function(_, value) return E.global.datatexts.customPanels[value] and L["Name Taken"] or true end)
DataTexts.args.panels.args.newPanel.args.add = ACH:Execute(L["Add"], nil, 1, function() local name = E.global.datatexts.newPanelInfo.name E.global.datatexts.customPanels[name] = E:CopyTable({}, E.global.datatexts.newPanelInfo) E.db.datatexts.panels[name] = { enable = true } for i = 1, E.global.datatexts.newPanelInfo.numPoints do E.db.datatexts.panels[name][i] = '' end DT:SetupPanelOptions(name) DT:BuildPanelFrame(name) E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'datatexts', 'panels', name) E.global.datatexts.newPanelInfo = E:CopyTable({}, G.datatexts.newPanelInfo) end, nil, nil, 'full', nil, nil, function() local name = E.global.datatexts.newPanelInfo.name return not name or name == '' end)

DataTexts.args.panels.args.LeftChatDataPanel = ACH:Group(ColorizeName(L["Datatext Panel (Left)"], 'cccccc'), L["Display data panels below the chat, used for datatexts."], 1, nil, function(info) return E.db.datatexts.panels.LeftChatDataPanel[info[#info]] end, function(info, value) E.db.datatexts.panels.LeftChatDataPanel[info[#info]] = value DT:UpdatePanelInfo('LeftChatDataPanel') Layout:SetDataPanelStyle() end)
DataTexts.args.panels.args.LeftChatDataPanel.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, function(info, value) E.db.datatexts.panels[info[#info - 1]][info[#info]] = value if E.db.LeftChatPanelFaded then E.db.LeftChatPanelFaded = true; _G.HideLeftChat() end if E.private.chat.enable then Chat:UpdateEditboxAnchors() end Layout:ToggleChatPanels() Layout:SetDataPanelStyle() DT:UpdatePanelInfo(info[#info - 1]) end)
DataTexts.args.panels.args.LeftChatDataPanel.args.templateGroup = CopyTable(defaultTemplateGroup)

DataTexts.args.panels.args.RightChatDataPanel = ACH:Group(ColorizeName(L["Datatext Panel (Right)"], 'cccccc'), L["Display data panels below the chat, used for datatexts."], 1, nil, function(info) return E.db.datatexts.panels.RightChatDataPanel[info[#info]] end, function(info, value) E.db.datatexts.panels.RightChatDataPanel[info[#info]] = value DT:UpdatePanelInfo('RightChatDataPanel') Layout:SetDataPanelStyle() end)
DataTexts.args.panels.args.RightChatDataPanel.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, function(info, value) E.db.datatexts.panels[info[#info - 1]][info[#info]] = value if E.db.RightChatPanelFaded then E.db.RightChatPanelFaded = true; _G.HideRightChat() end if E.private.chat.enable then Chat:UpdateEditboxAnchors() end Layout:ToggleChatPanels() Layout:SetDataPanelStyle() DT:UpdatePanelInfo(info[#info - 1]) end)
DataTexts.args.panels.args.RightChatDataPanel.args.templateGroup = CopyTable(defaultTemplateGroup)

DataTexts.args.panels.args.MinimapPanel = ACH:Group(ColorizeName(L["Minimap Panels"], 'cccccc'), L["Display minimap panels below the minimap, used for datatexts."], 3, nil, function(info) return E.db.datatexts.panels.MinimapPanel[info[#info]] end, function(info, value) E.db.datatexts.panels.MinimapPanel[info[#info]] = value DT:UpdatePanelInfo('MinimapPanel') end, function() return not E.private.general.minimap.enable end)
DataTexts.args.panels.args.MinimapPanel.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, function(info, value) E.db.datatexts.panels[info[#info - 1]][info[#info]] = value DT:UpdatePanelInfo(info[#info - 1]) if E.private.general.minimap.enable then Minimap:UpdateSettings() end end)
DataTexts.args.panels.args.MinimapPanel.args.numPoints = ACH:Range(L["Number of DataTexts"], nil, 1, { min = 1, max = 2, step = 1 }, nil, nil, function(info, value) E.db.datatexts.panels.MinimapPanel[info[#info]] = value DT:UpdatePanelInfo('MinimapPanel') DT:SetupPanelOptions('MinimapPanel') end)
DataTexts.args.panels.args.MinimapPanel.args.templateGroup = CopyTable(defaultTemplateGroup)

DataTexts.args.customCurrency = ACH:Group(L["Custom Currency"], nil, 6, nil, nil, nil, nil, not (E.Retail or E.Wrath))
DataTexts.args.customCurrency.args.description = ACH:Description(L["This allows you to create a new datatext which will track the currency with the supplied currency ID. The datatext can be added to a panel immediately after creation."], 0)
DataTexts.args.customCurrency.args.add = ACH:Select(L["Add Currency"], nil, 1, function() local list = E:CopyTable({}, DT.CurrencyList) list.GOLD = nil list.BACKPACK = nil return list end, nil, 'double', nil, function(_, value) local currencyID = tonumber(value) if not currencyID then return; end DT:RegisterCustomCurrencyDT(currencyID) CreateCustomCurrencyOptions(currencyID) DT:LoadDataTexts() end)
DataTexts.args.customCurrency.args.addID = ACH:Input(L["Add Currency by ID"], nil, 2, nil, 'double', C.Blank, function(_, value) local currencyID = tonumber(value) if not currencyID then return; end DT:RegisterCustomCurrencyDT(currencyID) CreateCustomCurrencyOptions(currencyID) DT:LoadDataTexts() end)
DataTexts.args.customCurrency.args.delete = ACH:Select(L["Delete"], nil, 2, function() wipe(currencyList) for currencyID, table in pairs(E.global.datatexts.customCurrencies) do currencyList[currencyID] = table.NAME end return currencyList end, nil, 'double', nil, function(_, value) local currencyName = E.global.datatexts.customCurrencies[value].NAME DT:RemoveCustomCurrency(currencyName) E.Options.args.datatexts.args.customCurrency.args[currencyName] = nil DT.RegisteredDataTexts[currencyName] = nil E.global.datatexts.customCurrencies[value] = nil dts[currencyName] = nil DT:LoadDataTexts() end, function() return not next(E.global.datatexts.customCurrencies) end)
DataTexts.args.customCurrency.args.spacer = ACH:Spacer(4)

DataTexts.args.settings = ACH:Group(L["Customization"], nil, 7)

E:CopyTable(E.Options.args.datatexts.args.panels.args.newPanel.args, DTPanelOptions)
E.Options.args.datatexts.args.panels.args.newPanel.args.templateGroup.get = function(_, key) return E.global.datatexts.newPanelInfo[key] end
E.Options.args.datatexts.args.panels.args.newPanel.args.templateGroup.set = function(_, key, value) E.global.datatexts.newPanelInfo[key] = value end

DT:PanelLayoutOptions()
if E.Retail or E.Wrath then
	SetupCustomCurrencies()
end
SetupDTCustomization()
