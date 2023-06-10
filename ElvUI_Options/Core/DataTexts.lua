local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local DT = E:GetModule('DataTexts')
local Layout = E:GetModule('Layout')
local Chat = E:GetModule('Chat')
local Minimap = E:GetModule('Minimap')
local ACH = E.Libs.ACH

local _G = _G
local pairs, ipairs = pairs, ipairs
local gsub, next, wipe, ceil = gsub, next, wipe, ceil
local format, tostring, tonumber = format, tostring, tonumber
local CopyTable = CopyTable

local currencyList, DTPanelOptions = {}, {}

DTPanelOptions.numPoints = ACH:Range(L["Number of DataTexts"], nil, 2, { min = 1, softMax = 20, step = 1}) -- softMax is used in the loop
DTPanelOptions.growth = ACH:Select(L["Growth"], nil, 3, { HORIZONTAL = L["Horizontal"], VERTICAL = L["Vertical"] })
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
DTPanelOptions.tooltip.args.tooltipXOffset = ACH:Range(L["X-Offset"], nil, 1, { softMin = -30, softMax = 30, min = -60, max = 60, step = 1 })
DTPanelOptions.tooltip.args.tooltipYOffset = ACH:Range(L["Y-Offset"], nil, 2, { softMin = -30, softMax = 30, min = -60, max = 60, step = 1 })

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

local dts = { [''] = L["None"] }

local function CopyList()
	return E:CopyTable(dts, DT.DataTextList)
end

function DT:SetupPanelOptions(name, data)
	if not data then data = DT.db.panels[name] end

	local db = E.db.datatexts.panels[name]
	local custom = E.global.datatexts.customPanels[name]
	local options = E.Options.args.datatexts.args.panels.args[name]
	if not options then
		options = ACH:Group(ColorizeName(name, not custom and 'ffffff'), nil, nil, nil, function(info) return db[info[#info]] end, function(info, value) db[info[#info]] = value DT:UpdatePanelInfo(name) end)
		E.Options.args.datatexts.args.panels.args[name] = options

		if custom then
			options.set = function(info, value)
				db[info[#info]] = value
				DT:UpdatePanelAttributes(name, custom)
			end

			options.args.enable = ACH:Toggle(L["Enable"], nil, 0)

			options.args.panelOptions = ACH:Group(L["Panel Options"], nil, 5, nil, function(info) return custom[info[#info]] end, function(info, value) custom[info[#info]] = value DT:UpdatePanelAttributes(name, custom) end)
			options.args.panelOptions.inline = true

			options.args.panelOptions.args.delete = ACH:Execute(L["Delete"], nil, -1, function() PanelGroup_Delete(name) end, nil, true, 'full')

			options.args.panelOptions.args.fonts = ACH:Group(L["Fonts"], nil, 10, nil, function(info) return custom.fonts[info[#info]] end, function(info, value) custom.fonts[info[#info]] = value DT:UpdatePanelAttributes(name, custom) end, function() return not custom.fonts.enable end)
			options.args.panelOptions.args.fonts.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, false)
			options.args.panelOptions.args.fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
			options.args.panelOptions.args.fonts.args.fontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
			options.args.panelOptions.args.fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)

			local panelOpts = E:CopyTable(options.args.panelOptions.args, DTPanelOptions)
			panelOpts.tooltip.args.tooltipYOffset.disabled = function() return custom.tooltipAnchor == 'ANCHOR_CURSOR' end
			panelOpts.tooltip.args.tooltipXOffset.disabled = function() return custom.tooltipAnchor == 'ANCHOR_CURSOR' end

			-- we dont need to set the get here
			panelOpts.numPoints.set = function(info, value)
				custom[info[#info]] = value
				DT:UpdatePanelAttributes(name, custom)
				DT:SetupPanelOptions(name)
			end

			panelOpts.templateGroup.get = function(_, key) return custom[key] end
			panelOpts.templateGroup.set = function(_, key, value)
				custom[key] = value
				DT:UpdatePanelAttributes(name, custom)
			end
		elseif not (P.datatexts.panels[name] or custom) then
			options.args.delete = ACH:Execute(L["Delete"], nil, 2, function() PanelGroup_Delete(name) end)
			return
		end
	end

	for i = 1, DTPanelOptions.numPoints.softMax do
		if not options.args.dts then
			options.args.dts = ACH:Group(' ', nil, 3, nil, function(info) return db[tonumber(info[#info])] or '' end, function(info, value) db[tonumber(info[#info])] = value DT:UpdatePanelInfo(name) end)
			options.args.dts.inline = true
		end

		local idx = tostring(i)
		local hasPoint = i <= (custom and custom.numPoints or db.numPoints or 3)
		options.args.dts.args[idx] = hasPoint and ACH:Select('', nil, i, CopyList) or nil

		if data and data.battleground ~= nil then
			options.args.battleground = ACH:Toggle(L["Battleground Texts"], nil, 1)

			if not options.args.battledts then
				options.args.battledts = ACH:Group(L["Battlegrounds"], nil, 4, nil, function(info) return E.db.datatexts.battlePanel[name][tonumber(info[#info])] end, function(info, value) E.db.datatexts.battlePanel[name][tonumber(info[#info])] = value DT:UpdatePanelInfo(name) end, nil, function() return not data.battleground end)
				options.args.battledts.inline = true
			end

			options.args.battledts.args[idx] = hasPoint and ACH:Select('', nil, i, CopyList) or nil
		end
	end
end

local function escapeString(str, get)
	return get == gsub(str, '|', '||') or gsub(str, '||', '|')
end

local function CreateDTOptions(name, data)
	local optionTable, settings

	if data.isCurrency then
		local currency = E.global.datatexts.customCurrencies[name] -- name is actually the currencyID
		optionTable = ACH:Group(format('%s |cFF888888[%s]|r', currency.name, name), nil, 1, nil, function(info) return E.global.datatexts.customCurrencies[name][info[#info]] end, function(info, value) E.global.datatexts.customCurrencies[name][info[#info]] = value DT:LoadDataTexts() end)

		optionTable.args.nameStyle = ACH:Select(L["Name Style"], nil, 1, { full = L["Name"], abbr = L["Abbreviate Name"], none = L["None"] })
		optionTable.args.showIcon = ACH:Toggle(L["Show Icon"], nil, 2)
		optionTable.args.showMax = ACH:Toggle(L["Current / Max"], nil, 3)
		optionTable.args.currencyTooltip = ACH:Toggle(L["Display In Main Tooltip"], L["If enabled, then this currency will be displayed in the main Currencies datatext tooltip."], 4, nil, nil, nil, nil, nil, nil, function() return DT.CurrencyList[tostring(name)] end)

		E.Options.args.datatexts.args.customCurrency.args[currency.name] = optionTable
		return
	else
		settings = E.global.datatexts.settings[name]
		if not settings or (settings and not next(settings)) then return end

		optionTable = ACH:Group(data.localizedName or name, nil, nil, nil, function(info) return settings[info[#info]] end, function(info, value) settings[info[#info]] = value DT:ForceUpdate_DataText(name) end)
		E.Options.args.datatexts.args.settings.args[name] = optionTable
	end

	if data.isLDB then
		optionTable.args.customLabel = ACH:Input(L["Custom Label"], nil, 1, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:LoadDataTexts() end)
		optionTable.args.spacer = ACH:Spacer(2, 'full')
		optionTable.args.label = ACH:Toggle(L["Show Label"], nil, 3)
		optionTable.args.text = ACH:Toggle(L["Show Text"], nil, 4)
		optionTable.args.icon = ACH:Toggle(L["Show Icon"], nil, 5)
		optionTable.args.useValueColor = ACH:Toggle(L["Use Value Color"], nil, 6)
	else
		for key in pairs(settings) do
			if key == 'Label' then
				optionTable.args[key] = ACH:Input(L["Label"], nil, 2, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:ForceUpdate_DataText(name) end)
			elseif key == 'NoLabel' then
				optionTable.args[key] = ACH:Toggle(L["No Label"], nil, 3)
			elseif key == 'NoIcon' then
				optionTable.args[key] = ACH:Toggle(L["No Icon"], nil, 3)
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
		elseif name == 'CombatIndicator' then
			optionTable.args.OutOfCombat = ACH:Input(L["Out of Combat Label"], nil, 1, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:ForceUpdate_DataText(name) end)
			optionTable.args.OutOfCombatColor = ACH:Color('', nil, 2, nil, nil, function(info) local c, d = settings[info[#info]], G.datatexts.settings[name][info[#info]] return c.r, c.g, c.b, nil, d.r, d.g, d.b end, function(info, r, g, b) local c = settings[info[#info]] c.r, c.g, c.b = r, g, b DT:ForceUpdate_DataText(name) end)
			optionTable.args.Spacer = ACH:Spacer(3, 'full')
			optionTable.args.InCombat = ACH:Input(L["In Combat Label"], nil, 4, nil, nil, function(info) return escapeString(settings[info[#info]], true) end, function(info, value) settings[info[#info]] = escapeString(value) DT:ForceUpdate_DataText(name) end)
			optionTable.args.InCombatColor = ACH:Color('', nil, 5, nil, nil, function(info) local c, d = settings[info[#info]], G.datatexts.settings[name][info[#info]] return c.r, c.g, c.b, nil, d.r, d.g, d.b end, function(info, r, g, b) local c = settings[info[#info]] c.r, c.g, c.b = r, g, b DT:ForceUpdate_DataText(name) end)
		elseif name == 'Currencies' then
			optionTable.args.displayedCurrency = ACH:Select(L["Displayed Currency"], nil, 10, function() local list = E:CopyTable({}, DT.CurrencyList) for _, info in pairs(E.global.datatexts.customCurrencies) do local id = tostring(info.ID) if info and not DT.CurrencyList[id] then list[id] = info.name end end return list end)
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
		elseif name == 'Item Level' then
			optionTable.args.rarityColor = ACH:Toggle(L["Rarity Color"], nil, 1)
		elseif name == 'Location' then
			optionTable.args.showContinent = ACH:Toggle(L["Show Continent"], nil, 1)
			optionTable.args.showZone = ACH:Toggle(L["Show Zone"], nil, 2)
			optionTable.args.showSubZone = ACH:Toggle(L["Show Subzone"], nil, 3)
			optionTable.args.spacer1 = ACH:Spacer(5)
			optionTable.args.color = ACH:Select(L["Text Color"], nil, 10, { REACTION = L["Reaction"], CLASS = L["CLASS"], CUSTOM = L["CUSTOM"] })
			optionTable.args.customColor = ACH:Color('', nil, 11, nil, nil, function(info) local c, d = settings[info[#info]], G.datatexts.settings[name][info[#info]] return c.r, c.g, c.b, nil, d.r, d.g, d.b end, function(info, r, g, b) local c = settings[info[#info]] c.r, c.g, c.b = r, g, b DT:ForceUpdate_DataText(name) end, function() return settings.color ~= 'CUSTOM' end, function() return settings.color ~= 'CUSTOM' end)
		elseif name == 'Time' then
			optionTable.args.time24 = ACH:Toggle(L["24-Hour Time"], L["Toggle 24-hour mode for the time datatext."], 5)
			optionTable.args.localTime = ACH:Toggle(L["Local Time"], L["If not set to true then the server time will be displayed instead."], 6)
			optionTable.args.flashInvite = ACH:Toggle(L["Flash Invites"], L["This will allow you to toggle flashing of the time datatext when there are calendar invites."], 7, nil, nil, nil, nil, nil, nil, E.Classic)
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
		elseif name == 'Talent/Loot Specialization' then
			optionTable.args.displayStyle = ACH:Select(L["Display Style"], nil, 1, { SPEC = L["Specializations Only"], LOADOUT = L["Loadout Only"], BOTH = L["Spec/Loadout"] })
			optionTable.args.iconOnly = ACH:Toggle(L["Icons Only"], L["Only show icons instead of specialization names"], 2)
		end
	end
end

local defaultTemplateGroup = ACH:Group(' ', nil, 5)
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
DataTexts.args.panels.args.newPanel.args.add = ACH:Execute(L["Add"], nil, 1, function() local name = E.global.datatexts.newPanelInfo.name E.global.datatexts.customPanels[name] = E:CopyTable({}, E.global.datatexts.newPanelInfo) E.db.datatexts.panels[name] = { enable = true, battleground = false } for i = 1, E.global.datatexts.newPanelInfo.numPoints do E.db.datatexts.panels[name][i] = '' end DT:SetupPanelOptions(name) DT:BuildPanelFrame(name) E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'datatexts', 'panels', name) E.global.datatexts.newPanelInfo = E:CopyTable({}, G.datatexts.newPanelInfo) end, nil, nil, 'full', nil, nil, function() local name = E.global.datatexts.newPanelInfo.name return not name or name == '' end)

E:CopyTable(DataTexts.args.panels.args.newPanel.args, DTPanelOptions)
DataTexts.args.panels.args.newPanel.args.templateGroup.get = function(_, key) return E.global.datatexts.newPanelInfo[key] end
DataTexts.args.panels.args.newPanel.args.templateGroup.set = function(_, key, value) E.global.datatexts.newPanelInfo[key] = value end

DataTexts.args.panels.args.LeftChatDataPanel = ACH:Group(ColorizeName(L["Datatext Panel (Left)"], 'cccccc'), L["Display data panels below the chat, used for datatexts."], 1, nil, function(info) return E.db.datatexts.panels.LeftChatDataPanel[info[#info]] end, function(info, value) E.db.datatexts.panels.LeftChatDataPanel[info[#info]] = value DT:UpdatePanelInfo('LeftChatDataPanel') Layout:SetDataPanelStyle() end)
DataTexts.args.panels.args.LeftChatDataPanel.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, function(info, value) E.db.datatexts.panels[info[#info - 1]][info[#info]] = value if E.db.LeftChatPanelFaded then E.db.LeftChatPanelFaded = true; _G.HideLeftChat() end if E.private.chat.enable then Chat:UpdateEditboxAnchors() end Layout:ToggleChatPanels() Layout:SetDataPanelStyle() DT:UpdatePanelInfo(info[#info - 1]) end)
DataTexts.args.panels.args.LeftChatDataPanel.args.templateGroup = CopyTable(defaultTemplateGroup)

DataTexts.args.panels.args.RightChatDataPanel = ACH:Group(ColorizeName(L["Datatext Panel (Right)"], 'cccccc'), L["Display data panels below the chat, used for datatexts."], 1, nil, function(info) return E.db.datatexts.panels.RightChatDataPanel[info[#info]] end, function(info, value) E.db.datatexts.panels.RightChatDataPanel[info[#info]] = value DT:UpdatePanelInfo('RightChatDataPanel') Layout:SetDataPanelStyle() end)
DataTexts.args.panels.args.RightChatDataPanel.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, function(info, value) E.db.datatexts.panels[info[#info - 1]][info[#info]] = value if E.db.RightChatPanelFaded then E.db.RightChatPanelFaded = true; _G.HideRightChat() end if E.private.chat.enable then Chat:UpdateEditboxAnchors() end Layout:ToggleChatPanels() Layout:SetDataPanelStyle() DT:UpdatePanelInfo(info[#info - 1]) end)
DataTexts.args.panels.args.RightChatDataPanel.args.templateGroup = CopyTable(defaultTemplateGroup)

DataTexts.args.panels.args.MinimapPanel = ACH:Group(ColorizeName(L["Minimap Panels"], 'cccccc'), L["Display minimap panels below the minimap, used for datatexts."], 3, nil, function(info) return E.db.datatexts.panels.MinimapPanel[info[#info]] end, function(info, value) E.db.datatexts.panels.MinimapPanel[info[#info]] = value DT:UpdatePanelInfo('MinimapPanel') end, function() return not E.private.general.minimap.enable end)
DataTexts.args.panels.args.MinimapPanel.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, function(info, value) E.db.datatexts.panels[info[#info - 1]][info[#info]] = value DT:UpdatePanelInfo(info[#info - 1]) if E.private.general.minimap.enable then Minimap:UpdateSettings() end end)
DataTexts.args.panels.args.MinimapPanel.args.numPoints = ACH:Range(L["Number of DataTexts"], nil, 2, { min = 1, max = 2, step = 1 }, nil, nil, function(info, value) E.db.datatexts.panels.MinimapPanel[info[#info]] = value DT:UpdatePanelInfo('MinimapPanel') DT:SetupPanelOptions('MinimapPanel') end)
DataTexts.args.panels.args.MinimapPanel.args.templateGroup = CopyTable(defaultTemplateGroup)

local function addCurrency(_, value)
	local currencyID = tonumber(value)
	if not currencyID then return end
	local data = DT:RegisterCustomCurrencyDT(currencyID)
	if data then
		CreateDTOptions(currencyID, data)
		DT:LoadDataTexts()
	end
end

local function getCurrencyList()
	local list = E:CopyTable({}, DT.CurrencyList)
	list.GOLD = nil
	list.BACKPACK = nil

	for id in next, E.global.datatexts.customCurrencies do
		list[tostring(id)] = nil
	end

	return list
end

DataTexts.args.customCurrency = ACH:Group(L["Custom Currency"], nil, 6, nil, nil, nil, nil, not (E.Retail or E.Wrath))
DataTexts.args.customCurrency.args.description = ACH:Description(L["This allows you to create a new datatext which will track the currency with the supplied currency ID. The datatext can be added to a panel immediately after creation."], 0)
DataTexts.args.customCurrency.args.add = ACH:Select(L["Add Currency"], nil, 1, getCurrencyList, nil, 'double', nil, addCurrency)
DataTexts.args.customCurrency.args.addID = ACH:Input(L["Add Currency by ID"], nil, 2, nil, 'double', C.Blank, addCurrency)
DataTexts.args.customCurrency.args.delete = ACH:Select(L["Delete"], nil, 2, function() wipe(currencyList) for currencyID, info in pairs(E.global.datatexts.customCurrencies) do currencyList[currencyID] = info.name end return currencyList end, nil, 'double', nil, function(_, value) local currencyName = E.global.datatexts.customCurrencies[value].name DT:RemoveCustomCurrency(currencyName) E.Options.args.datatexts.args.customCurrency.args[currencyName] = nil DT.RegisteredDataTexts[currencyName] = nil E.global.datatexts.customCurrencies[value] = nil dts[currencyName] = nil DT:LoadDataTexts() end, function() return not next(E.global.datatexts.customCurrencies) end)
DataTexts.args.customCurrency.args.spacer = ACH:Spacer(4)

DataTexts.args.settings = ACH:Group(L["Customization"], nil, 7)

-- initialize
for name, data in pairs(DT.RegisteredDataTexts) do
	CreateDTOptions(name, data)
end

for name, data in pairs(DT.db.panels) do
	DT:SetupPanelOptions(name, data)
end
