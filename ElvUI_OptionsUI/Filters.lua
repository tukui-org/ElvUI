local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, L = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames')
local ACH = E.Libs.ACH

local gsub = gsub
local wipe = wipe
local next = next
local pairs = pairs
local format = format
local strmatch = strmatch
local tonumber = tonumber
local tostring = tostring
local GetSpellInfo = GetSpellInfo

-- GLOBALS: MAX_PLAYER_LEVEL

local quickSearchText, selectedSpell, selectedFilter, filterList, spellList = '', nil, nil, {}, {}
local defaultFilterList = {	['Aura Indicator (Global)'] = 'Aura Indicator (Global)', ['Aura Indicator (Class)'] = 'Aura Indicator (Class)', ['Aura Indicator (Pet)'] = 'Aura Indicator (Pet)',  ['Aura Indicator (Profile)'] = 'Aura Indicator (Profile)', ['AuraBar Colors'] = 'AuraBar Colors', ['Aura Highlight'] = 'Aura Highlight' }
local auraBarDefaults = { enable = true, color = { r = 1, g = 1, b = 1 } }

local function GetSelectedFilters()
	local class = selectedFilter == 'Aura Indicator (Class)'
	local pet = selectedFilter == 'Aura Indicator (Pet)'
	local profile = selectedFilter == 'Aura Indicator (Profile)'
	local selected = (profile and E.db.unitframe.filters.aurawatch) or (pet and (E.global.unitframe.aurawatch.PET or {})) or class and (E.global.unitframe.aurawatch[E.myclass] or {}) or E.global.unitframe.aurawatch.GLOBAL
	local default = (profile and P.unitframe.filters.aurawatch) or (pet and G.unitframe.aurawatch.PET) or class and G.unitframe.aurawatch[E.myclass] or G.unitframe.aurawatch.GLOBAL
	return selected, default
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
	wipe(filterList)

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

		local spellName = tonumber(filter) and GetSpellInfo(filter)
		local name = (spellName and format('%s |cFF888888(%s)|r', spellName, filter)) or tostring(filter)

		if name:lower():find(searchText) then
			spellList[filter] = name
		end
	end

	if not next(spellList) then
		spellList[''] = L["NONE"]
	end

	return spellList
end

E.Options.args.filters = {
	type = 'group',
	name = L["FILTERS"],
	order = 3,
	childGroups = 'tab',
	args = {
		mainOptions = {
			type = 'group',
			name = 'Main Options',
			order = 1,
			args = {
				createFilter = {
					order = 1,
					name = L["Create Filter"],
					desc = L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."],
					type = 'input',
					get = function(info) return '' end,
					set = function(info, value)
						if strmatch(value, '^[%s%p]-$') then
							return
						end
						if strmatch(value, ',') then
							E:Print(L["Filters are not allowed to have commas in their name. Stripping commas from filter name."])
							value = gsub(value, ',', '')
						end
						if strmatch(value, '^Friendly:') or strmatch(value, '^Enemy:') then
							return --dont allow people to create Friendly: or Enemy: filters
						end
						if G.unitframe.specialFilters[value] or E.global.unitframe.aurafilters[value] then
							E:Print(L["Filter already exists!"])
							return
						end
						E.global.unitframe.aurafilters[value] = { spells = {} }
						selectedFilter = value
					end,
				},
				selectFilter = {
					order = 2,
					type = 'select',
					name = L["Select Filter"],
					get = function(info) return selectedFilter end,
					set = function(info, value)
						selectedFilter, selectedSpell, quickSearchText = nil, nil, ''
						if value ~= '' then
							selectedFilter = value
						end
					end,
					values = SetFilterList,
				},
				deleteFilter = {
					type = 'select',
					order = 3,
					name = L["Delete Filter"],
					desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
					confirm = function(info, value)
						return 'Remove Filter - '..value
					end,
					set = function(info, value)
						E.global.unitframe.aurafilters[value] = nil
						selectedFilter, selectedSpell, quickSearchText = nil, nil, ''

						removePriority(value) --This will wipe a filter from the new aura system profile settings.
					end,
					disabled = DeleteFilterListDisable,
					values = DeleteFilterList,
				},
				resetGroup = {
					type = 'select',
					name = L["Reset Filter"],
					order = 4,
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					confirm = function(info, value)
						return 'Reset Filter - '..value
					end,
					set = function(info, value)
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

						selectedFilter, selectedSpell, quickSearchText = nil, nil, ''

						UF:Update_AllFrames()
					end,
					values = ResetFilterList,
				},
				filterGroup = {
					type = 'group',
					name = function() return selectedFilter end,
					hidden = function() return not selectedFilter end,
					inline = true,
					order = 10,
					args = {
						selectSpellheader = ACH:Description(L["|cffFF0000Warning:|r Click the arrow on the dropdown box to see a list of spells."], 0, 'medium'),
						selectSpell = {
							name = L["Select Spell"],
							type = 'select',
							order = 1,
							customWidth = 350,
							get = function(info) return selectedSpell or '' end,
							set = function(info, value)
								selectedSpell = (value ~= '' and value) or nil
							end,
							values = SetSpellList,
						},
						quickSearch = {
							order = 2,
							name = L["Filter Search"],
							desc = L["Search for a spell name inside of a filter."],
							type = 'input',
							customWidth = 200,
							get = function() return quickSearchText end,
							set = function(info,value) quickSearchText = value end,
						},
						filterType = {
							order = 3,
							name = L["Filter Type"],
							desc = L["Set the filter type. Blacklist will hide any auras in the list and show all others. Whitelist will show any auras in the filter and hide all others."],
							type = 'select',
							values = {
								Whitelist = L["Whitelist"],
								Blacklist = L["Blacklist"],
							},
							get = function() return E.global.unitframe.aurafilters[selectedFilter].type end,
							set = function(info, value) E.global.unitframe.aurafilters[selectedFilter].type = value; UF:Update_AllFrames() end,
							hidden = function() return (selectedFilter == 'Aura Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)' or selectedFilter == 'Whitelist' or selectedFilter == 'Blacklist') or G.unitframe.aurafilters[selectedFilter] end,
						},
						removeSpell = {
							order = 4,
							name = L["Remove Spell"],
							desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
							type = 'select',
							confirm = function(info, value)
								local spellName = tonumber(value) and GetSpellInfo(value)
								local name = (spellName and format('%s |cFF888888(%s)|r', spellName, value)) or tostring(value)
								return 'Remove Spell - '..name
							end,
							customWidth = 350,
							get = function(info) return '' end,
							set = function(info, value)
								if not value then return end
								selectedSpell = nil

								if selectedFilter == 'Aura Highlight' then
									E.global.unitframe.AuraHighlightColors[value] = nil
								elseif selectedFilter == 'AuraBar Colors' then
									if G.unitframe.AuraBarColors[value] then
										E.global.unitframe.AuraBarColors[value].enable = false
									else
										E.global.unitframe.AuraBarColors[value] = nil
									end
								elseif selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)' then
									local selectedTable, defaultTable = GetSelectedFilters()

									if defaultTable[value] then
										selectedTable[value].enabled = false
									else
										selectedTable[value] = nil
									end
								elseif G.unitframe.aurafilters[selectedFilter] and G.unitframe.aurafilters[selectedFilter].spells[value] then
									E.global.unitframe.aurafilters[selectedFilter].spells[value].enable = false
								else
									E.global.unitframe.aurafilters[selectedFilter].spells[value] = nil
								end

								UF:Update_AllFrames()
							end,
							values = SetSpellList,
						},
						addSpell = {
							order = 5,
							name = L["Add SpellID"],
							desc = L["Add a spell to the filter."],
							type = 'input',
							customWidth = 200,
							get = function(info) return '' end,
							set = function(info, value)
								value = tonumber(value)
								if not value then return end

								local spellName = GetSpellInfo(value)
								selectedSpell = (spellName and value) or nil
								if not selectedSpell then return end

								if selectedFilter == 'Aura Highlight' then
									if not E.global.unitframe.AuraHighlightColors[value] then
										E.global.unitframe.AuraHighlightColors[value] = { enable = true, style = 'GLOW', color = {r = 0.8, g = 0, b = 0, a = 0.85}, ownOnly = false }
									end
								elseif selectedFilter == 'AuraBar Colors' then
									if not E.global.unitframe.AuraBarColors[value] then
										E.global.unitframe.AuraBarColors[value] = E:CopyTable({}, auraBarDefaults)
									end
								elseif selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)' then
									local selectedTable = GetSelectedFilters()
									if not selectedTable[value] then
										selectedTable[value] = UF:AuraWatch_AddSpell(value, 'TOPRIGHT')
									end
								elseif not E.global.unitframe.aurafilters[selectedFilter].spells[value] then
									E.global.unitframe.aurafilters[selectedFilter].spells[value] = { enable = true, priority = 0, stackThreshold = 0 }
								end

								UF:Update_AllFrames()
							end,
						},
					},
				},
				buffIndicator = {
					type = 'group',
					name = function()
						local spell = GetSelectedSpell()
						local spellName = spell and GetSpellInfo(spell)
						return (spellName and spellName..' |cFF888888('..spell..')|r') or spell or ' '
					end,
					hidden = function() return not selectedSpell or (selectedFilter ~= 'Aura Indicator (Pet)' and selectedFilter ~= 'Aura Indicator (Profile)' and selectedFilter ~= 'Aura Indicator (Class)' and selectedFilter ~= 'Aura Indicator (Global)') end,
					get = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end

						local selectedTable = GetSelectedFilters()
						return selectedTable[spell][info[#info]]
					end,
					set = function(info, value)
						local spell = GetSelectedSpell()
						if not spell then return end

						local selectedTable = GetSelectedFilters()
						selectedTable[spell][info[#info]] = value
						UF:Update_AllFrames()
					end,
					order = -10,
					inline = true,
					args = {
						enabled = {
							name = L["Enable"],
							order = 1,
							type = 'toggle',
						},
						point = {
							name = L["Anchor Point"],
							order = 2,
							type = 'select',
							values = {
								TOPLEFT = 'TOPLEFT',
								LEFT = 'LEFT',
								BOTTOMLEFT = 'BOTTOMLEFT',
								RIGHT = 'RIGHT',
								TOPRIGHT = 'TOPRIGHT',
								BOTTOMRIGHT = 'BOTTOMRIGHT',
								CENTER = 'CENTER',
								TOP = 'TOP',
								BOTTOM = 'BOTTOM',
							}
						},
						style = {
							name = L["Style"],
							order = 3,
							type = 'select',
							values = {
								timerOnly = L["Timer Only"],
								coloredIcon = L["Colored Icon"],
								texturedIcon = L["Textured Icon"],
							},
						},
						color = {
							name = L["COLOR"],
							type = 'color',
							order = 4,
							get = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end
								local selectedTable = GetSelectedFilters()
								local t = selectedTable[spell][info[#info]]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								local spell = GetSelectedSpell()
								if not spell then return end
								local selectedTable = GetSelectedFilters()
								local t = selectedTable[spell][info[#info]]
								t.r, t.g, t.b = r, g, b

								UF:Update_AllFrames()
							end,
							disabled = function()
								local spell = GetSelectedSpell()
								if not spell then return end
								local selectedTable = GetSelectedFilters()
								return selectedTable[spell].style == 'texturedIcon'
							end,
						},
						sizeOffset = {
							order = 5,
							type = 'range',
							name = L["Size Offset"],
							desc = L["This changes the size of the Aura Icon by this value."],
							min = -25, max = 25, step = 1,
						},
						xOffset = {
							order = 6,
							type = 'range',
							name = L["X-Offset"],
							min = -75, max = 75, step = 1,
						},
						yOffset = {
							order = 7,
							type = 'range',
							name = L["Y-Offset"],
							min = -75, max = 75, step = 1,
						},
						textThreshold = {
							name = L["Text Threshold"],
							desc = L["At what point should the text be displayed. Set to -1 to disable."],
							type = 'range',
							order = 8,
							min = -1, max = 60, step = 1,
						},
						anyUnit = {
							name = L["Show Aura From Other Players"],
							order = 9,
							customWidth = 205,
							type = 'toggle',
						},
						onlyShowMissing = {
							name = L["Show When Not Active"],
							order = 10,
							type = 'toggle',
						},
						displayText = {
							name = L["Display Text"],
							type = 'toggle',
							order = 11,
							get = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end

								local selectedTable = GetSelectedFilters()
								return (selectedTable[spell].style == 'timerOnly') or selectedTable[spell][info[#info]]
							end,
							disabled = function()
								local spell = GetSelectedSpell()
								if not spell then return end
								local selectedTable = GetSelectedFilters()
								return selectedTable[spell].style == 'timerOnly'
							end
						},
					},
				},
				spellGroup = {
					type = 'group',
					name = function()
						local spell = GetSelectedSpell()
						local spellName = spell and GetSpellInfo(spell)
						return (spellName and spellName..' |cFF888888('..spell..')|r') or spell or ' '
					end,
					hidden = function() return not selectedSpell or (selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') end,
					order = -15,
					inline = true,
					args = {
						enabled = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							hidden = function() return (selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') end,
							get = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end

								if selectedFilter == 'Aura Highlight' then
									return E.global.unitframe.AuraHighlightColors[spell].enable
								elseif selectedFilter == 'AuraBar Colors' then
									return E.global.unitframe.AuraBarColors[spell].enable
								else
									return E.global.unitframe.aurafilters[selectedFilter].spells[spell].enable
								end
							end,
							set = function(info, value)
								local spell = GetSelectedSpell()
								if not spell then return end

								if selectedFilter == 'Aura Highlight' then
									E.global.unitframe.AuraHighlightColors[spell].enable = value
								elseif selectedFilter == 'AuraBar Colors' then
									E.global.unitframe.AuraBarColors[spell].enable = value
								else
									E.global.unitframe.aurafilters[selectedFilter].spells[spell].enable = value
								end

								UF:Update_AllFrames()
							end,
						},
						style = {
							name = L["Style"],
							type = 'select',
							order = 1,
							values = { GLOW = L["Glow"], FILL = L["Fill"] },
							hidden = function() return selectedFilter ~= 'Aura Highlight' end,
							get = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end

								return E.global.unitframe.AuraHighlightColors[spell].style
							end,
							set = function(info, value)
								local spell = GetSelectedSpell()
								if not spell then return end

								E.global.unitframe.AuraHighlightColors[spell].style = value
								UF:Update_AllFrames()
							end,
						},
						color = {
							name = L["COLOR"],
							type = 'color',
							order = 2,
							hasAlpha = function() return selectedFilter ~= 'AuraBar Colors' end,
							hidden = function() return (selectedFilter ~= 'Aura Highlight' and selectedFilter ~= 'AuraBar Colors' and selectedFilter ~= 'Aura Indicator (Pet)' and selectedFilter ~= 'Aura Indicator (Profile)' and selectedFilter ~= 'Aura Indicator (Class)' and selectedFilter ~= 'Aura Indicator (Global)') end,
							get = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end

								local t
								if selectedFilter == 'Aura Highlight' then
									t = E.global.unitframe.AuraHighlightColors[spell].color
								elseif selectedFilter == 'AuraBar Colors' then
									t = E.global.unitframe.AuraBarColors[spell].color
								end

								if t then
									return t.r, t.g, t.b, t.a
								end
							end,
							set = function(info, r, g, b, a)
								local spell = GetSelectedSpell()
								if not spell then return end

								local t
								if selectedFilter == 'Aura Highlight' then
									t = E.global.unitframe.AuraHighlightColors[spell].color
								elseif selectedFilter == 'AuraBar Colors' then
									t = E.global.unitframe.AuraBarColors[spell].color
								end

								if t then
									t.r, t.g, t.b, t.a = r, g, b, a
									UF:Update_AllFrames()
								end
							end,
						},
						removeColor = {
							type = 'execute',
							order = 3,
							name = L["Restore Defaults"],
							hidden = function() return selectedFilter ~= 'AuraBar Colors' end,
							func = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end

								if G.unitframe.AuraBarColors[spell] then
									E.global.unitframe.AuraBarColors[spell] = E:CopyTable({}, G.unitframe.AuraBarColors[spell])
								else
									E.global.unitframe.AuraBarColors[spell] = E:CopyTable({}, auraBarDefaults)
								end

								UF:Update_AllFrames()
							end,
						},
						forDebuffIndicator = {
							order = 4,
							type = 'group',
							name = L["Used as RaidDebuff Indicator"],
							inline = true,
							hidden = function() return (selectedFilter == 'Aura Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Aura Indicator (Pet)' or selectedFilter == 'Aura Indicator (Profile)' or selectedFilter == 'Aura Indicator (Class)' or selectedFilter == 'Aura Indicator (Global)') end,
							args = {
								priority = {
									order = 1,
									type = 'range',
									name = L["Priority"],
									desc = L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."],
									min = 0, max = 99, step = 1,
									get = function()
										local spell = GetSelectedSpell()
										if not spell then
											return 0
										else
											return E.global.unitframe.aurafilters[selectedFilter].spells[spell].priority
										end
									end,
									set = function(info, value)
										local spell = GetSelectedSpell()
										if not spell then return end

										E.global.unitframe.aurafilters[selectedFilter].spells[spell].priority = value
										UF:Update_AllFrames()
									end,
								},
								stackThreshold = {
									order = 2,
									type = 'range',
									name = L["Stack Threshold"],
									desc = L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."],
									min = 0, max = 99, step = 1,
									get = function()
										local spell = GetSelectedSpell()
										if not spell then
											return 0
										else
											return E.global.unitframe.aurafilters[selectedFilter].spells[spell].stackThreshold
										end
									end,
									set = function(info, value)
										local spell = GetSelectedSpell()
										if not spell then return end

										E.global.unitframe.aurafilters[selectedFilter].spells[spell].stackThreshold = value
										UF:Update_AllFrames()
									end,
								},
							},
						},
						ownOnly = {
							name = L["Casted by Player Only"],
							desc = L["Only highlight the aura that originated from you and not others."],
							order = 5,
							type = 'toggle',
							hidden = function() return selectedFilter ~= 'Aura Highlight' end,
							get = function(info)
								local spell = GetSelectedSpell()
								if not spell then return end

								if selectedFilter == 'Aura Highlight' then
									return E.global.unitframe.AuraHighlightColors[spell].ownOnly or false
								end
							end,
							set = function(info, value)
								local spell = GetSelectedSpell()
								if not spell then return end

								if selectedFilter == 'Aura Highlight' then
									E.global.unitframe.AuraHighlightColors[spell].ownOnly = value
								end

								UF:Update_AllFrames()
							end,
						},
					},
				}
			},
		},
	}
}

E.Options.args.filters.args.help = ACH:Group('Help', nil, 2)

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
	E.Options.args.filters.args.help.args['help'..i] = ACH:Description(text:gsub('*', COLOR1):gsub('%^', COLOR2), i, 'medium')
end

function E:SetToFilterConfig(filter)
	selectedSpell = nil
	quickSearchText = ''
	selectedFilter = filter or ''
	E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'filters')
end
