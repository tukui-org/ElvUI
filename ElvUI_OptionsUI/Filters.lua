local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local UF = E:GetModule('UnitFrames')
local ACH = E.Libs.ACH

local gsub = gsub
local wipe = wipe
local next = next
local pairs = pairs
local format = format
local strfind = strfind
local strlower = strlower
local strmatch = strmatch
local tonumber = tonumber
local tostring = tostring
local GetSpellInfo = GetSpellInfo
local GetSpellSubtext = GetSpellSubtext

local quickSearchText, selectedSpell, selectedFilter, filterList, spellList = '', nil, nil, {}, {}
local defaultFilterList = { ['Aura Indicator (Global)'] = 'Aura Indicator (Global)', ['Aura Indicator (Class)'] = 'Aura Indicator (Class)', ['Aura Indicator (Pet)'] = 'Aura Indicator (Pet)', ['Aura Indicator (Profile)'] = 'Aura Indicator (Profile)', ['AuraBar Colors'] = 'AuraBar Colors', ['Aura Highlight'] = 'Aura Highlight' }
local auraBarDefaults = { enable = true, color = { r = 1, g = 1, b = 1 } }

local function GetSelectedFilters()
	local class = selectedFilter == 'Aura Indicator (Class)'
	local pet = selectedFilter == 'Aura Indicator (Pet)'
	local profile = selectedFilter == 'Aura Indicator (Profile)'
	local selected = (profile and E.db.unitframe.filters.aurawatch) or (pet and E.global.unitframe.aurawatch.PET) or (class and E.global.unitframe.aurawatch[E.myclass]) or E.global.unitframe.aurawatch.GLOBAL
	local default = (profile and P.unitframe.filters.aurawatch) or (pet and G.unitframe.aurawatch.PET) or class and G.unitframe.aurawatch[E.myclass] or G.unitframe.aurawatch.GLOBAL
	return selected or {}, default
end

local function GetSelectedSpell()
	if selectedSpell and selectedSpell ~= '' then
		local spell = strmatch(selectedSpell, ' %((%d+)%)$') or selectedSpell
		if spell then
			return tonumber(spell) or spell
		end
	end
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = '^'..v..'$', '^'..v..',', ','..v..'$', ','..v..','
	return (strmatch(s, m1) and m1) or (strmatch(s, m2) and m2) or (strmatch(s, m3) and m3) or (strmatch(s, m4) and v..',')
end

local function removePriority(value)
	if not value then return end
	local x, y, z = E.db.unitframe.units, E.db.nameplates.units
	for n, t in pairs(x) do
		if t and t.buffs and t.buffs.priority and t.buffs.priority ~= '' then
			z = filterMatch(t.buffs.priority, E:EscapeString(value))
			if z then E.db.unitframe.units[n].buffs.priority = gsub(t.buffs.priority, z, '') end
		end
		if t and t.debuffs and t.debuffs.priority and t.debuffs.priority ~= '' then
			z = filterMatch(t.debuffs.priority, E:EscapeString(value))
			if z then E.db.unitframe.units[n].debuffs.priority = gsub(t.debuffs.priority, z, '') end
		end
		if t and t.aurabar and t.aurabar.priority and t.aurabar.priority ~= '' then
			z = filterMatch(t.aurabar.priority, E:EscapeString(value))
			if z then E.db.unitframe.units[n].aurabar.priority = gsub(t.aurabar.priority, z, '') end
		end
	end
	for n, t in pairs(y) do
		if t and t.buffs and t.buffs.priority and t.buffs.priority ~= '' then
			z = filterMatch(t.buffs.priority, E:EscapeString(value))
			if z then E.db.nameplates.units[n].buffs.priority = gsub(t.buffs.priority, z, '') end
		end
		if t and t.debuffs and t.debuffs.priority and t.debuffs.priority ~= '' then
			z = filterMatch(t.debuffs.priority, E:EscapeString(value))
			if z then E.db.nameplates.units[n].debuffs.priority = gsub(t.debuffs.priority, z, '') end
		end
	end
end

local function SetFilterList()
	wipe(filterList)
	E:CopyTable(filterList, defaultFilterList)

	local list = E.global.unitframe.aurafilters
	if list then
		for filter in pairs(list) do
			filterList[filter] = filter
		end
	end

	return filterList
end

local function ResetFilterList()
	wipe(filterList)

	E:CopyTable(filterList, defaultFilterList)

	local list = G.unitframe.aurafilters
	if list then
		for filter in pairs(list) do
			filterList[filter] = filter
		end
	end

	return filterList
end

local function DeleteFilterList()
	wipe(filterList)

	local list = E.global.unitframe.aurafilters
	local defaultList = G.unitframe.aurafilters
	if list then
		for filter in pairs(list) do
			if not defaultList[filter] then
				filterList[filter] = filter
			end
		end
	end

	return filterList
end

local function DeleteFilterListDisable()
	local list = E.global.unitframe.aurafilters
	local defaultList = G.unitframe.aurafilters
	if list then
		for filter in pairs(list) do
			if not defaultList[filter] then
				return false
			end
		end
	end

	return true
end

local function GetSpellNameRank(id)
	if not id then
		return ' '
	end

	local name = tonumber(id) and GetSpellInfo(id)
	if not name then
		return tostring(id)
	end

	local rank = not E.Retail and GetSpellSubtext(id)
	if not rank or not strfind(rank, '%d') then
		return format('%s |cFF888888(%s)|r', name, id)
	end

	local selectedTable = GetSelectedFilters()
	local info = selectedTable[id]

	if info and info.includeIDs then
		return format('%s %s[%s]|r', name, E.media.hexvaluecolor, info and info.includeIDs and L["Multiple Ranks"] or rank)
	end

	return format('%s %s[%s]|r |cFF888888(%s)|r', name, E.media.hexvaluecolor, rank, id)
end

local function SetSpellList()
	local list
	if selectedFilter == 'Aura Highlight' then
		list = E.global.unitframe.AuraHighlightColors
	elseif selectedFilter == 'AuraBar Colors' then
		list = E.global.unitframe.AuraBarColors
	elseif selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)' then
		list = GetSelectedFilters()
	else
		list = E.global.unitframe.aurafilters[selectedFilter].spells
	end

	if not list then return end
	wipe(spellList)

	local searchText = quickSearchText:lower()
	for filter, spell in pairs(list) do
		if spell.id and (selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') then
			filter = spell.id
		end

		local name = GetSpellNameRank(filter)
		if strfind(strlower(name), searchText) then
			spellList[filter] = name
		end
	end

	if not next(spellList) then
		spellList[''] = L["None"]
	end

	return spellList
end

local function FilterSettings(info, ...)
	local spell = GetSelectedSpell()
	if not spell then return end

	local color, value, r, g, b, a
	if info.type == 'color' then
		r, g, b, a = ...
	else
		value = ...
	end

	if selectedFilter == 'Aura Highlight' or selectedFilter == 'AuraBar Colors' then
		local settingTable = selectedFilter == 'Aura Highlight' and 'AuraHighlightColors' or 'AuraBarColors'
		if info.type == 'color' then
			color = E.global.unitframe[settingTable][spell].color
			if r ~= nil then
				color.r, color.g, color.b, color.a = r, g, b, a or 1
			else
				return color.r, color.g, color.b, color.a
			end
		elseif value ~= nil then
			E.global.unitframe[settingTable][spell][info[#info]] = value
		else
			return E.global.unitframe[settingTable][spell][info[#info]]
		end
	elseif selectedFilter then
		if value ~= nil then
			E.global.unitframe.aurafilters[selectedFilter].spells[spell].enable = value
		else
			return E.global.unitframe.aurafilters[selectedFilter].spells[spell].enable
		end
	end

	UF:Update_AllFrames()
end

local function AddOrRemoveSpellID(info, value)
	value = tonumber(value)
	if not value then return end

	if info[#info] == 'removeSpell' then
		selectedSpell = nil
	else
		local spellName = GetSpellInfo(value)
		selectedSpell = (spellName and value)
	end

	if selectedFilter == 'Aura Highlight' then
		if info.type == 'select' then
			E.global.unitframe.AuraHighlightColors[value] = nil
		elseif not E.global.unitframe.AuraHighlightColors[value] then
			E.global.unitframe.AuraHighlightColors[value] = { enable = true, style = 'GLOW', color = { r = 0.8, g = 0, b = 0, a = 0.85 }, ownOnly = false }
		end
	elseif selectedFilter == 'AuraBar Colors' then
		if info.type == 'select' then
			if G.unitframe.AuraBarColors[value] then
				E.global.unitframe.AuraBarColors[value].enable = false
			else
				E.global.unitframe.AuraBarColors[value] = nil
			end
		elseif not E.global.unitframe.AuraBarColors[value] then
			E.global.unitframe.AuraBarColors[value] = E:CopyTable({}, auraBarDefaults)
		end
	elseif selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)' then
		local selectedTable, defaultTable = GetSelectedFilters()
		if info.type == 'select' then
			if defaultTable[value] then
				selectedTable[value].enabled = false
			else
				selectedTable[value] = nil
			end
		elseif not selectedTable[value] then
			local mainID = E.Filters.Included[value]
			if mainID then
				selectedSpell = mainID
			else
				selectedTable[value] = E.Filters.Aura(value, nil, 'TOPRIGHT')
			end
		end
	elseif G.unitframe.aurafilters[selectedFilter] and G.unitframe.aurafilters[selectedFilter].spells[value] then
		if info.type == 'select' then
			E.global.unitframe.aurafilters[selectedFilter].spells[value].enable = false
		end
	else
		if info.type == 'select' then
			E.global.unitframe.aurafilters[selectedFilter].spells[value] = nil
		elseif not E.global.unitframe.aurafilters[selectedFilter].spells[value] then
			E.global.unitframe.aurafilters[selectedFilter].spells[value] = { enable = true, priority = 0, stackThreshold = 0 }
		end
	end

	UF:Update_AllFrames()
end

local function getSelectedFilter() return selectedFilter end

local function resetSelectedFilter(_, value) selectedFilter, selectedSpell, quickSearchText = nil, nil, '' if value ~= '' then selectedFilter = value end end

local function validateCreateFilter(_, value) return not (strmatch(value, '^[%s%p]-$') or strmatch(value, '^Friendly:') or strmatch(value, '^Enemy:') or G.unitframe.specialFilters[value] or E.global.unitframe.aurafilters[value]) end

local function confirmResetFilter(_, value) return value ~= '' and format(L["Reset Filter - %s"], value) end

local function resetFilter(_, value)
	if value == 'Aura Highlight' then
		E.global.unitframe.AuraHighlightColors = E:CopyTable({}, G.unitframe.DebuffHighlightColors)
	elseif value == 'AuraBar Colors' then
		E.global.unitframe.AuraBarColors = E:CopyTable({}, G.unitframe.AuraBarColors)
	elseif value == 'Aura Indicator (Pet)' or value == 'Aura Indicator (Profile)' or value == 'Aura Indicator (Class)' or value == 'Aura Indicator (Global)' then
		local selectedTable, defaultTable = GetSelectedFilters()
		wipe(selectedTable)
		E:CopyTable(selectedTable, defaultTable)
	else
		E.global.unitframe.aurafilters[value].spells = E:CopyTable({}, G.unitframe.aurafilters[value].spells)
	end
	resetSelectedFilter()
	UF:Update_AllFrames()
end

local function auraIndicator(info, ...)
	local spell = GetSelectedSpell()
	if not spell then return end

	local color, value, r, g, b, a
	if info.type == 'color' then
		r, g, b, a = ...
	else
		value = ...
	end

	local selectedTable = GetSelectedFilters()

	if info.type == 'color' then
		color = selectedTable[spell][info[#info]]
		if r ~= nil then
			color.r, color.g, color.b, color.a = r, g, b, a or 1
		else
			return color.r, color.g, color.b, color.a
		end
	elseif value ~= nil then
		selectedTable[spell][info[#info]] = value
	else
		return selectedTable[spell][info[#info]]
	end

	UF:Update_AllFrames()
end

local function debuffIndicator(info, value)
	local spell = GetSelectedSpell()
	if not spell then
		return 0
	else
		if selectedFilter == 'Aura Highlight' then
			if value ~= nil then
				E.global.unitframe.AuraHighlightColors[spell][info[#info]] = value
			else
				return E.global.unitframe.AuraHighlightColors[spell][info[#info]]
			end
		elseif value ~= nil then
			E.global.unitframe.aurafilters[selectedFilter].spells[spell][info[#info]] = value
		else
			return E.global.unitframe.aurafilters[selectedFilter].spells[spell][info[#info]]
		end

		UF:Update_AllFrames()
	end
end

E.Options.args.filters = ACH:Group(L["FILTERS"], nil, 3, 'tab')
local Filters = E.Options.args.filters.args

Filters.mainOptions = ACH:Group(L["Main Options"], nil, 1)
Filters.mainOptions.args.createFilter = ACH:Input(L["Create Filter"], L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."], 1, nil, nil, nil, function(_, value) value = gsub(value, ',', '') E.global.unitframe.aurafilters[value] = { type = 'whitelist', spells = {} } selectedFilter = value end, nil, nil, validateCreateFilter)
Filters.mainOptions.args.selectFilter = ACH:Select(L["Select Filter"], nil, 2, SetFilterList, nil, nil, getSelectedFilter, resetSelectedFilter)
Filters.mainOptions.args.deleteFilter = ACH:Select(L["Delete Filter"], L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."], 3, DeleteFilterList, confirmResetFilter, nil, nil, function(_, value) E.global.unitframe.aurafilters[value] = nil resetSelectedFilter() removePriority(value) end, DeleteFilterListDisable)
Filters.mainOptions.args.resetGroup = ACH:Select(L["Reset Filter"], L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."], 4, ResetFilterList, confirmResetFilter, nil, nil, resetFilter)

Filters.mainOptions.args.filterGroup = ACH:Group(function() return selectedFilter end, nil, 10, nil, nil, nil, nil, function() return not selectedFilter end)
Filters.mainOptions.args.filterGroup.inline = true
Filters.mainOptions.args.filterGroup.args.selectSpellheader = ACH:Description(L["|cffFF3333Warning:|r Click the arrow on the dropdown box to see a list of spells."], 0, 'medium')
Filters.mainOptions.args.filterGroup.args.selectSpell = ACH:Select(L["Select Spell"], nil, 1, SetSpellList, nil, 350, function(_) return selectedSpell or '' end, function(_, value) selectedSpell = (value ~= '' and value) end)
Filters.mainOptions.args.filterGroup.args.selectSpell.sortByValue = true

Filters.mainOptions.args.filterGroup.args.quickSearch = ACH:Input(L["Filter Search"], L["Search for a spell name inside of a filter."], 2, nil, 200, function() return quickSearchText end, function(_, value) quickSearchText = value end)
Filters.mainOptions.args.filterGroup.args.filterType = ACH:Select(L["Filter Type"], L["Set the filter type. Blacklist will hide any auras in the list and show all others. Whitelist will show any auras in the filter and hide all others."], 2, { Whitelist = L["Whitelist"], Blacklist = L["Blacklist"] }, nil, nil, function() return E.global.unitframe.aurafilters[selectedFilter].type end, function(_, value) E.global.unitframe.aurafilters[selectedFilter].type = value UF:Update_AllFrames() end, nil, function() return (selectedFilter == 'Aura Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)' or selectedFilter == 'Whitelist' or selectedFilter == 'Blacklist') or G.unitframe.aurafilters[selectedFilter] end)
Filters.mainOptions.args.filterGroup.args.removeSpell = ACH:Select(L["Remove Spell"], nil, 4, SetSpellList, function(_, value) return value ~= '' and format(L["Remove Spell - %s"], GetSpellNameRank(value)) end, 350, nil, AddOrRemoveSpellID)
Filters.mainOptions.args.filterGroup.args.addSpell = ACH:Input(L["Add SpellID"], L["Add a spell to the filter."], 5, nil, 350, nil, AddOrRemoveSpellID)

Filters.mainOptions.args.auraIndicator = ACH:Group(function() return GetSpellNameRank(GetSelectedSpell()) end, nil, -1, nil, auraIndicator, auraIndicator, nil, function() return not selectedSpell or (selectedFilter ~= 'Aura Indicator (Pet)' and selectedFilter ~= 'Aura Indicator (Profile)' and selectedFilter ~= 'Aura Indicator (Class)' and selectedFilter ~= 'Aura Indicator (Global)') end)
Filters.mainOptions.args.auraIndicator.inline = true
Filters.mainOptions.args.auraIndicator.args.enabled = ACH:Toggle(L["Enable"], nil, 1)
Filters.mainOptions.args.auraIndicator.args.sizeOffset = ACH:Range(L["Size Offset"], L["This changes the size of the Aura Icon by this value."], 2, { min = -25, max = 25, step = 1 })
Filters.mainOptions.args.auraIndicator.args.style = ACH:Select(L["Style"], nil, 3, { timerOnly = L["Timer Only"], coloredIcon = L["Colored Icon"], texturedIcon = L["Textured Icon"] })
Filters.mainOptions.args.auraIndicator.args.color = ACH:Color(' ', nil, 4, true, nil, nil, nil, nil, function() local spell = GetSelectedSpell() if not spell then return end local selectedTable = GetSelectedFilters() return selectedTable[spell].style == 'texturedIcon' end)
Filters.mainOptions.args.auraIndicator.args.spacer = ACH:Spacer(5)
Filters.mainOptions.args.auraIndicator.args.anyUnit = ACH:Toggle(L["Show Aura From Other Players"], nil, 6, nil, nil, 205)
Filters.mainOptions.args.auraIndicator.args.onlyShowMissing = ACH:Toggle(L["Show When Not Active"], nil, 7)
Filters.mainOptions.args.auraIndicator.args.displayText = ACH:Toggle(L["Display Text"], nil, 8, nil, nil, nil, function(info) local spell = GetSelectedSpell() if not spell then return end local selectedTable = GetSelectedFilters() return (selectedTable[spell].style == 'timerOnly') or selectedTable[spell][info[#info]] end, nil, nil, function() local spell = GetSelectedSpell() if not spell then return end local selectedTable = GetSelectedFilters() return selectedTable[spell].style == 'timerOnly' end)
Filters.mainOptions.args.auraIndicator.args.textThreshold = ACH:Range(L["Text Threshold"], L["At what point should the text be displayed. Set to -1 to disable."], 9, { min = -1, max = 60, step = 1 })

Filters.mainOptions.args.auraIndicator.args.positionGroup = ACH:Group(L["Position"], nil, 15)
Filters.mainOptions.args.auraIndicator.args.positionGroup.args.point = ACH:Select(L["Anchor Point"], nil, 5, C.Values.AllPoints)
Filters.mainOptions.args.auraIndicator.args.positionGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -75, max = 75, step = 1 })
Filters.mainOptions.args.auraIndicator.args.positionGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -75, max = 75, step = 1 })

Filters.mainOptions.args.auraIndicator.args.countGroup = ACH:Group(L["Count"], nil, 20)
Filters.mainOptions.args.auraIndicator.args.countGroup.args.countAnchor = ACH:Select(L["Anchor Point"], nil, 1, C.Values.AllPoints)
Filters.mainOptions.args.auraIndicator.args.countGroup.args.countX = ACH:Range(L["X-Offset"], nil, 2, { min = -75, max = 75, step = 1 })
Filters.mainOptions.args.auraIndicator.args.countGroup.args.countY = ACH:Range(L["Y-Offset"], nil, 3, { min = -75, max = 75, step = 1 })

Filters.mainOptions.args.spellGroup = ACH:Group(function() return GetSpellNameRank(GetSelectedSpell()) end, nil, -15, nil, FilterSettings, FilterSettings, nil, function() return not selectedSpell or (selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') end)
Filters.mainOptions.args.spellGroup.inline = true
Filters.mainOptions.args.spellGroup.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, nil, function() return (selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') end)
Filters.mainOptions.args.spellGroup.args.style = ACH:Select(L["Style"], nil, 1, { GLOW = L["Glow"], FILL = L["Fill"] }, nil, nil, nil, nil, nil, function() return selectedFilter ~= 'Aura Highlight' end)
Filters.mainOptions.args.spellGroup.args.color = ACH:Color(L["COLOR"], nil, 2, function() return selectedFilter ~= 'AuraBar Colors' end, nil, nil, nil, nil, function() return (selectedFilter ~= 'Aura Highlight' and selectedFilter ~= 'AuraBar Colors' and selectedFilter ~= 'Aura Indicator (Pet)' and selectedFilter ~= 'Aura Indicator (Profile)' and selectedFilter ~= 'Aura Indicator (Class)' and selectedFilter ~= 'Aura Indicator (Global)') end)
Filters.mainOptions.args.spellGroup.args.removeColor = ACH:Execute(L["Restore Defaults"], nil, 3, function() local spell = GetSelectedSpell() if not spell then return end if G.unitframe.AuraBarColors[spell] then E.global.unitframe.AuraBarColors[spell] = E:CopyTable({}, G.unitframe.AuraBarColors[spell]) else E.global.unitframe.AuraBarColors[spell] = E:CopyTable({}, auraBarDefaults) end UF:Update_AllFrames() end, nil, nil, nil, nil, nil, nil, function() return selectedFilter ~= 'AuraBar Colors' end)

Filters.mainOptions.args.spellGroup.args.forDebuffIndicator = ACH:Group(L["Used as Raid Debuff Indicator"], nil, 4, nil, debuffIndicator, debuffIndicator, nil, function() return (selectedFilter == 'Aura Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') end)
Filters.mainOptions.args.spellGroup.args.forDebuffIndicator.inline = true
Filters.mainOptions.args.spellGroup.args.forDebuffIndicator.args.priority = ACH:Range(L["Priority"], L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."], 1, { min = 0, max = 99, step = 1 })
Filters.mainOptions.args.spellGroup.args.forDebuffIndicator.args.stackThreshold = ACH:Range(L["Stack Threshold"], L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."], 2, { min = 0, max = 99, step = 1 })
Filters.mainOptions.args.spellGroup.args.ownOnly = ACH:Toggle(L["Casted by Player Only"], L["Only highlight the aura that originated from you and not others."], 5, nil, nil, nil, nil, nil, nil, function() return selectedFilter ~= 'Aura Highlight' end)

Filters.help = ACH:Group(L["Help"], nil, 2)

local COLOR = E:ClassColor(E.myclass, true)
local COLOR1 = format('|c%s', COLOR.colorStr)
local COLOR2 = '|cFFFFFFFF'

local FilterHelp = {
	'*Whitelists:|r ^Personal, nonPersonal, Boss, CastByUnit, notCastByUnit, Dispellable (includes steal-able), CastByNPC, CastByPlayers|r',
	'*Blacklists:|r ^blockNonPersonal, blockNoDuration, blockCastByPlayers | A blacklist filter is only effective against filters that come after it in the priority list. It will not block anything from the filters before it.|r',
	'^A blacklist filter is only effective against filters that come after it in the priority list. It will not block anything from the filters before it.',
	' ',
	'*Boss:|r ^Auras (debuffs only?) cast by a boss unit.|r',
	'*Personal:|r ^Auras cast by yourself.|r',
	'*nonPersonal:|r ^Auras cast by anyone other than yourself.|r',
	'*CastByUnit:|r ^Auras cast by the unit of the unitframe or nameplate (so on target frame it only shows auras cast by the target unit).|r',
	'*notCastByUnit:|r ^Auras cast by anyone other than the unit of the unitframe or nameplate.|r',
	'*Dispellable:|r ^Auras you can either dispel or spellsteal.|r',
	'*CastByNPC:|r ^Auras cast by any NPC.|r',
	'*CastByPlayers:|r ^Auras cast by any player-controlled unit (so no NPCs).|r',
	'*blockCastByPlayers:|r ^Blocks any aura that is cast by player-controlled units (so will only show auras cast by NPCs).|r',
	'*blockNoDuration:|r ^Blocks any aura without a duration.|r',
	'*blockNonPersonal:|r ^Blocks any aura that is not cast by yourself.|r',
	' ',
	'*Show Everything:|r ^Set "Max Duration" to 0 & Leave Priority List Empty or (1) Personal | (2) nonPersonal',
	'*Block Blacklisted Auras, Show Everything Else:|r ^(1) Blacklist| (2) Personal | (3) nonPersonal',
	'*Block Auras Without Duration, Show Everything Else:|r ^(1) blockNoDuration | (2) Personal | (3) nonPersonal',
	'*Block Auras Without Duration, Block Blacklisted Auras, Show Everything Else:|r ^(1) blockNoDuration | (2) Blacklist | (3) Personal | (4) nonPersonal',
	'*Block Everything, Except Your Own Auras:|r ^(1) Personal',
	'*Block Everything, Except Whitelisted Auras:|r ^(1) Whitelist',
	'*Block Everything, Except Whitelisted Auras That Are Cast By Yourself:|r ^(1) blockNonPersonal | (2) Whitelist'
}

for i, text in ipairs(FilterHelp) do
	Filters.help.args['help'..i] = ACH:Description(text:gsub('*', COLOR1):gsub('%^', COLOR2), i, 'medium')
end

function C:SetToFilterConfig(filter)
	resetSelectedFilter(_, filter)
	E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'filters')
end
