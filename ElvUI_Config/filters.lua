local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local type = type
local next = next
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local gsub = string.gsub
local match = string.match
local format = string.format
local COLOR = COLOR
local NONE = NONE
local GetSpellInfo = GetSpellInfo

-- GLOBALS: MAX_PLAYER_LEVEL
-- GLOBALS: selectedFolder
--  what is selectedFolder?

local selectedSpell;
local selectedFilter;
local quickSearchText = ""

local function filterValue(value)
	return gsub(value,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function removePriority(value)
	if not value then return end
	local x,y,z=E.db.unitframe.units,E.db.nameplates.units;
	for n, t in pairs(x) do
		if t and t.buffs and t.buffs.priority and t.buffs.priority ~= "" then
			z = filterMatch(t.buffs.priority, filterValue(value))
			if z then E.db.unitframe.units[n].buffs.priority = gsub(t.buffs.priority, z, "") end
		end
		if t and t.debuffs and t.debuffs.priority and t.debuffs.priority ~= "" then
			z = filterMatch(t.debuffs.priority, filterValue(value))
			if z then E.db.unitframe.units[n].debuffs.priority = gsub(t.debuffs.priority, z, "") end
		end
		if t and t.aurabar and t.aurabar.priority and t.aurabar.priority ~= "" then
			z = filterMatch(t.aurabar.priority, filterValue(value))
			if z then E.db.unitframe.units[n].aurabar.priority = gsub(t.aurabar.priority, z, "") end
		end
	end
	for n, t in pairs(y) do
		if t and t.buffs and t.buffs.priority and t.buffs.priority ~= "" then
			z = filterMatch(t.buffs.priority, filterValue(value))
			if z then E.db.nameplates.units[n].buffs.priority = gsub(t.buffs.priority, z, "") end
		end
		if t and t.debuffs and t.debuffs.priority and t.debuffs.priority ~= "" then
			z = filterMatch(t.debuffs.priority, filterValue(value))
			if z then E.db.nameplates.units[n].debuffs.priority = gsub(t.debuffs.priority, z, "") end
		end
	end
end

local FilterResetState = {}

local function UpdateFilterGroup()
	--Prevent errors when choosing a new filter, by doing a reset of the groups
	E.Options.args.filters.args.filterGroup = nil
	E.Options.args.filters.args.spellGroup = nil
	E.Options.args.filters.args.resetGroup = nil
	E.Options.args.filters.childGroups = nil

	if selectedFilter == 'Debuff Highlight' then
		E.Options.args.filters.args.filterGroup = {
			type = 'group',
			name = selectedFilter,
			guiInline = true,
			order = 10,
			args = {
				addSpell = {
					order = 1,
					name = L["Add Spell ID or Name"],
					desc = L["Add a spell to the filter. Use spell ID if you don't want to match all auras which share the same name."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if tonumber(value) then value = tonumber(value) end
						E.global.unitframe.DebuffHighlightColors[value] = {enable = true, style = 'GLOW', color = {r = 0.8, g = 0, b = 0, a = 0.85}}
						UpdateFilterGroup();
						UF:Update_AllFrames();
					end,
				},
				removeSpell = {
					order = 2,
					name = L["Remove Spell"],
					desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
					buttonElvUI = true,
					type = 'execute',
					func = function()
						local value = selectedSpell:match(" %((%d+)%)$") or selectedSpell
						if tonumber(value) then value = tonumber(value) end
						E.global.unitframe.DebuffHighlightColors[value] = nil;
						selectedSpell = nil;
						UpdateFilterGroup();
						UF:Update_AllFrames();
					end,
					disabled = function() return not (selectedSpell and selectedSpell ~= "") end,
				},
				quickSearch = {
					order = 3,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = 'select',
					order = 10,
					width = "double",
					guiInline = true,
					get = function(info) return selectedSpell end,
					set = function(info, value) selectedSpell = value; UpdateFilterGroup() end,
					values = function()
						local filters = {}
						local list = E.global.unitframe.DebuffHighlightColors
						if not list then return end
						local searchText = quickSearchText:lower()
						for filter in pairs(list) do
							if tonumber(filter) then
								local spellName = GetSpellInfo(filter)
								if spellName then
									filter = format("%s (%s)", spellName, filter)
								else
									filter = tostring(filter)
								end
							end
							if filter:lower():find(searchText) then filters[filter] = filter end
						end
						if not next(filters) then filters[''] = NONE end
						return filters
					end,
				},
			},
		}

		E.Options.args.filters.args.resetGroup = {
			type = "group",
			name = L["Reset Filter"],
			order = 25,
			guiInline = true,
			args = {
				enableReset = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return FilterResetState[selectedFilter] end,
					set = function(info, value)
						FilterResetState[selectedFilter] = value
						E.Options.args.filters.args.resetGroup.args.resetFilter.disabled = (not value)
					end,
				},
				resetFilter = {
					order = 2,
					type = "execute",
					buttonElvUI = true,
					name = L["Reset Filter"],
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					disabled = function() return not FilterResetState[selectedFilter] end,
					func = function(info)
						E.global.unitframe.DebuffHighlightColors = E:CopyTable({}, G.unitframe.DebuffHighlightColors)
						selectedSpell = nil
						UpdateFilterGroup()
						UF:Update_AllFrames()
					end,
				},
			},
		}

		local spellID = selectedSpell and match(selectedSpell, "(%d+)")
		if spellID then spellID = tonumber(spellID) end

		if not selectedSpell or E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)] == nil then
			E.Options.args.filters.args.spellGroup = nil
			return
		end

		E.Options.args.filters.args.spellGroup = {
			type = "group",
			name = selectedSpell,
			order = 15,
			guiInline = true,
			args = {
				enabled = {
					name = L["Enable"],
					order = 0,
					type = 'toggle',
					get = function(info)
						return E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)].enable
					end,
					set = function(info, value)
						E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)].enable = value
						UF:Update_AllFrames();
					end,
				},
				style = {
					name = L["Style"],
					type = 'select',
					order = 3,
					values = {
						['GLOW'] = L["Glow"],
						['FILL'] = L["Fill"]
					},
					get = function(info)
						return E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)].style
					end,
					set = function(info, value)
						E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)].style = value
						UF:Update_AllFrames();
					end,
				},
				color = {
					name = COLOR,
					type = 'color',
					order = 1,
					hasAlpha = true,
					get = function(info)
						local t = E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)].color
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b, a)
						local t = E.global.unitframe.DebuffHighlightColors[(spellID or selectedSpell)].color
						t.r, t.g, t.b, t.a = r, g, b, a
						UF:Update_AllFrames();
					end,
				},
			},
		}
	elseif selectedFilter == 'AuraBar Colors' then
		E.Options.args.filters.args.filterGroup = {
			type = 'group',
			name = selectedFilter,
			guiInline = true,
			order = 10,
			args = {
				addSpell = {
					order = 1,
					name = L["Add Spell ID or Name"],
					desc = L["Add a spell to the filter. Use spell ID if you don't want to match all auras which share the same name."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if tonumber(value) then value = tonumber(value) end
						if not E.global.unitframe.AuraBarColors[value] then
							E.global.unitframe.AuraBarColors[value] = false
						end
						UpdateFilterGroup();
						UF:CreateAndUpdateUF('player')
						UF:CreateAndUpdateUF('target')
						UF:CreateAndUpdateUF('focus')
					end,
				},
				removeSpell = {
					order = 2,
					name = L["Remove Spell"],
					desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
					type = 'execute',
					buttonElvUI = true,
					func = function()
						local value = selectedSpell:match(" %((%d+)%)$") or selectedSpell
						if tonumber(value) then value = tonumber(value) end
						if G['unitframe'].AuraBarColors[value] then
							E.global.unitframe.AuraBarColors[value] = false;
							E:Print(L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."])
						else
							E.global.unitframe.AuraBarColors[value] = nil;
						end
						selectedSpell = nil;
						UpdateFilterGroup();
						UF:CreateAndUpdateUF('player')
						UF:CreateAndUpdateUF('target')
						UF:CreateAndUpdateUF('focus')
					end,
					disabled = function() return not (selectedSpell and selectedSpell ~= "") end,
				},
				quickSearch = {
					order = 3,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = 'select',
					order = 10,
					width = "double",
					guiInline = true,
					get = function(info) return selectedSpell end,
					set = function(info, value)
						selectedSpell = value;
						UpdateFilterGroup()
					end,
					values = function()
						local filters = {}
						local list = E.global.unitframe.AuraBarColors
						if not list then return end
						local searchText = quickSearchText:lower()
						for filter in pairs(list) do
							if tonumber(filter) then
								local spellName = GetSpellInfo(filter)
								if spellName then
									filter = format("%s (%s)", spellName, filter)
								else
									filter = tostring(filter)
								end
							end
							if filter:lower():find(searchText) then filters[filter] = filter end
						end
						if not next(filters) then filters[''] = NONE end
						return filters
					end,
				},
			},
		}

		E.Options.args.filters.args.resetGroup = {
			type = "group",
			name = L["Reset Filter"],
			order = 25,
			guiInline = true,
			args = {
				enableReset = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return FilterResetState[selectedFilter] end,
					set = function(info, value)
						FilterResetState[selectedFilter] = value
						E.Options.args.filters.args.resetGroup.args.resetFilter.disabled = (not value)
					end,
				},
				resetFilter = {
					order = 2,
					type = "execute",
					buttonElvUI = true,
					name = L["Reset Filter"],
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					disabled = function() return not FilterResetState[selectedFilter] end,
					func = function(info)
						E.global.unitframe.AuraBarColors = E:CopyTable({}, G.unitframe.AuraBarColors)
						selectedSpell = nil
						UpdateFilterGroup()
						UF:Update_AllFrames()
					end,
				},
			},
		}

		local spellID = selectedSpell and match(selectedSpell, "(%d+)")
		if spellID then spellID = tonumber(spellID) end

		if not selectedSpell or E.global.unitframe.AuraBarColors[(spellID or selectedSpell)] == nil then
			E.Options.args.filters.args.spellGroup = nil
			return
		end

		E.Options.args.filters.args.spellGroup = {
			type = "group",
			name = selectedSpell,
			order = 15,
			guiInline = true,
			args = {
				color = {
					name = COLOR,
					type = 'color',
					order = 1,
					get = function(info)
						local t = E.global.unitframe.AuraBarColors[(spellID or selectedSpell)]
						if type(t) == 'boolean' then
							return 0, 0, 0, 1
						else
							return t.r, t.g, t.b, t.a
						end
					end,
					set = function(info, r, g, b)
						local spell = (spellID or selectedSpell)
						if type(E.global.unitframe.AuraBarColors[spell]) ~= 'table' then
							E.global.unitframe.AuraBarColors[spell] = {}
						end
						local t = E.global.unitframe.AuraBarColors[spell]
						t.r, t.g, t.b = r, g, b
						UF:CreateAndUpdateUF('player')
						UF:CreateAndUpdateUF('target')
						UF:CreateAndUpdateUF('focus')
					end,
				},
				removeColor = {
					type = 'execute',
					order = 2,
					name = L["Restore Defaults"],
					func = function(info)
						E.global.unitframe.AuraBarColors[(spellID or selectedSpell)] = false;
						UF:CreateAndUpdateUF('player')
						UF:CreateAndUpdateUF('target')
						UF:CreateAndUpdateUF('focus')
					end,
				},
			},
		}
	elseif selectedFilter == 'Buff Indicator (Pet)' then
		if not E.global.unitframe.buffwatch.PET then
			E.global.unitframe.buffwatch.PET = {};
		end

		E.Options.args.filters.args.filterGroup = {
			type = 'group',
			name = selectedFilter,
			guiInline = true,
			order = 15,
			childGroups = "select",
			args = {
				addSpellID = {
					order = 1,
					name = L["Add SpellID"],
					desc = L["Add a spell to the filter."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if not tonumber(value) then
							E:Print(L["Value must be a number"])
						elseif not GetSpellInfo(value) then
							E:Print(L["Not valid spell id"])
						else
							E.global.unitframe.buffwatch.PET[tonumber(value)] = {["enabled"] = true, ["id"] = tonumber(value), ["point"] = "TOPRIGHT", ["color"] = {["r"] = 1, ["g"] = 0, ["b"] = 0}, ["anyUnit"] = true, ['style'] = 'coloredIcon', ["xOffset"] = 0, ["yOffset"] = 0}
							selectedSpell = nil;
							UpdateFilterGroup();
							UF:CreateAndUpdateUF('pet');
						end
					end,
				},
				removeSpellID = {
					order = 2,
					name = L["Remove SpellID"],
					desc = L["Remove a spell from the filter."],
					type = 'execute',
					buttonElvUI = true,
					func = function()
						if G.unitframe.buffwatch.PET[selectedSpell] then
							E.global.unitframe.buffwatch.PET[selectedSpell].enabled = false
							E:Print(L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."])
						else
							E.global.unitframe.buffwatch.PET[selectedSpell] = nil
						end

						selectedSpell = nil;
						UpdateFilterGroup();
						UF:CreateAndUpdateUF('pet')
					end,
					disabled = function() return not selectedSpell end,
				},
				quickSearch = {
					order = 3,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = "select",
					order = 10,
					width = "double",
					values = function()
						local values = {}
						local list = E.global.unitframe.buffwatch.PET
						if not list then return end
						local searchText = quickSearchText:lower()
						for _, spell in pairs(list) do
							if spell.id then
								local name = GetSpellInfo(spell.id)
								if name and name:lower():find(searchText) then values[spell.id] = name end
							end
						end
						return values
					end,
					get = function(info) return selectedSpell end,
					set = function(info, value)
						selectedSpell = value;
						UpdateFilterGroup()
					end,
				},
			},
		}

		E.Options.args.filters.args.resetGroup = {
			type = "group",
			name = L["Reset Filter"],
			order = 25,
			guiInline = true,
			args = {
				enableReset = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return FilterResetState[selectedFilter] end,
					set = function(info, value)
						FilterResetState[selectedFilter] = value
						E.Options.args.filters.args.resetGroup.args.resetFilter.disabled = (not value)
					end,
				},
				resetFilter = {
					order = 2,
					type = "execute",
					buttonElvUI = true,
					name = L["Reset Filter"],
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					disabled = function() return not FilterResetState[selectedFilter] end,
					func = function(info)
						E.global.unitframe.buffwatch.PET = E:CopyTable({}, G.unitframe.buffwatch.PET)
						selectedSpell = nil
						UpdateFilterGroup()
						UF:Update_AllFrames()
					end,
				},
			},
		}

		if selectedSpell then
			local name = GetSpellInfo(selectedSpell)
			if name then
				E.Options.args.filters.args.filterGroup.args[name] = {
					name = name..' ('..selectedSpell..')',
					type = 'group',
					get = function(info) return E.global.unitframe.buffwatch.PET[selectedSpell][ info[#info] ] end,
					set = function(info, value) E.global.unitframe.buffwatch.PET[selectedSpell][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
					order = -10,
					args = {
						enabled = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
						},
						point = {
							name = L["Anchor Point"],
							order = 1,
							type = 'select',
							values = {
								['TOPLEFT'] = 'TOPLEFT',
								['TOPRIGHT'] = 'TOPRIGHT',
								['BOTTOMLEFT'] = 'BOTTOMLEFT',
								['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
								['LEFT'] = 'LEFT',
								['RIGHT'] = 'RIGHT',
								['TOP'] = 'TOP',
								['BOTTOM'] = 'BOTTOM',
							}
						},
						sizeOverride = {
							order = 2,
							type = "range",
							name = L["Size Override"],
							min = 0, max = 50, step = 1,
						},
						xOffset = {
							order = 3,
							type = 'range',
							name = L["xOffset"],
							min = -75, max = 75, step = 1,
						},
						yOffset = {
							order = 4,
							type = 'range',
							name = L["yOffset"],
							min = -75, max = 75, step = 1,
						},
						style = {
							name = L["Style"],
							order = 5,
							type = 'select',
							values = {
								['coloredIcon'] = L["Colored Icon"],
								['texturedIcon'] = L["Textured Icon"],
								['NONE'] = NONE,
							},
						},
						color = {
							name = COLOR,
							type = 'color',
							order = 6,
							get = function(info)
								local t = E.global.unitframe.buffwatch.PET[selectedSpell][ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								local t = E.global.unitframe.buffwatch.PET[selectedSpell][ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:CreateAndUpdateUF('pet')
							end,
						},
						displayText = {
							name = L["Display Text"],
							type = 'toggle',
							order = 7,
						},
						textColor = {
							name = L["Text Color"],
							type = 'color',
							order = 8,
							get = function(info)
								local t = E.global.unitframe.buffwatch.PET[selectedSpell][ info[#info] ]
								if t then
									return t.r, t.g, t.b, t.a
								else
									return 1, 1, 1, 1
								end
							end,
							set = function(info, r, g, b)
								local t = E.global.unitframe.buffwatch.PET[selectedSpell][ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:CreateAndUpdateUF('pet')
							end,
						},
						decimalThreshold = {
							name = L["Decimal Threshold"],
							desc = L["Threshold before text goes into decimal form. Set to -1 to disable decimals."],
							type = 'range',
							order = 9,
							min = -1, max = 10, step = 1,
						},
						textThreshold = {
							name = L["Text Threshold"],
							desc = L["At what point should the text be displayed. Set to -1 to disable."],
							type = 'range',
							order = 10,
							min = -1, max = 60, step = 1,
						},
						anyUnit = {
							name = L["Show Aura From Other Players"],
							order = 11,
							type = 'toggle',
						},
						onlyShowMissing = {
							name = L["Show When Not Active"],
							order = 12,
							type = 'toggle',
						},
					},
				}
			else
				E:Print(L["Not valid spell id"])
			end
		end
	elseif selectedFilter == 'Buff Indicator' then
		if not E.global.unitframe.buffwatch[E.myclass] then
			E.global.unitframe.buffwatch[E.myclass] = {}
		end

		E.Options.args.filters.args.filterGroup = {
			type = 'group',
			name = selectedFilter,
			guiInline = true,
			order = 15,
			childGroups = "select",
			args = {
				addSpellID = {
					order = 1,
					name = L["Add SpellID"],
					desc = L["Add a spell to the filter."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if not tonumber(value) then
							E:Print(L["Value must be a number"])
						elseif not GetSpellInfo(value) then
							E:Print(L["Not valid spell id"])
						else
							E.global.unitframe.buffwatch[E.myclass][tonumber(value)] = {["enabled"] = true, ["id"] = tonumber(value), ["point"] = "TOPRIGHT", ["color"] = {["r"] = 1, ["g"] = 0, ["b"] = 0}, ["anyUnit"] = false, ['style'] = 'coloredIcon', ["xOffset"] = 0, ["yOffset"] = 0}
							selectedSpell = nil;
							UpdateFilterGroup();

							UF:UpdateAuraWatchFromHeader('raid')
							UF:UpdateAuraWatchFromHeader('raid40')
							UF:UpdateAuraWatchFromHeader('party')
							UF:UpdateAuraWatchFromHeader('raidpet', true)
						end
					end,
				},
				removeSpellID = {
					order = 2,
					name = L["Remove SpellID"],
					desc = L["Remove a spell from the filter."],
					type = 'execute',
					buttonElvUI = true,
					func = function()
						if G.unitframe.buffwatch[E.myclass][selectedSpell] then
							E.global.unitframe.buffwatch[E.myclass][selectedSpell].enabled = false
							E:Print(L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."])
						else
							E.global.unitframe.buffwatch[E.myclass][selectedSpell] = nil
						end

						selectedSpell = nil;
						UpdateFilterGroup();
						UF:UpdateAuraWatchFromHeader('raid')
						UF:UpdateAuraWatchFromHeader('raid40')
						UF:UpdateAuraWatchFromHeader('party')
						UF:UpdateAuraWatchFromHeader('raidpet', true)
					end,
					disabled = function() return not selectedSpell end,
				},
				quickSearch = {
					order = 3,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = "select",
					order = 10,
					width = "double",
					values = function()
						local values = {}
						local list = E.global.unitframe.buffwatch[E.myclass]
						if not list then return end
						local searchText = quickSearchText:lower()
						for _, spell in pairs(list) do
							if spell.id then
								local name = GetSpellInfo(spell.id)
								if name and name:lower():find(searchText) then values[spell.id] = name end
							end
						end
						return values
					end,
					get = function(info) return selectedSpell end,
					set = function(info, value)
						selectedSpell = value;
						UpdateFilterGroup()
					end,
				},
			},
		}

		E.Options.args.filters.args.resetGroup = {
			type = "group",
			name = L["Reset Filter"],
			order = 25,
			guiInline = true,
			args = {
				enableReset = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return FilterResetState[selectedFilter] end,
					set = function(info, value)
						FilterResetState[selectedFilter] = value
						E.Options.args.filters.args.resetGroup.args.resetFilter.disabled = (not value)
					end,
				},
				resetFilter = {
					order = 2,
					type = "execute",
					buttonElvUI = true,
					name = L["Reset Filter"],
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					disabled = function() return not FilterResetState[selectedFilter] end,
					func = function(info)
						E.global.unitframe.buffwatch[E.myclass] = E:CopyTable({}, G.unitframe.buffwatch[E.myclass])
						selectedSpell = nil
						UpdateFilterGroup()
						UF:Update_AllFrames()
					end,
				},
			},
		}

		if selectedSpell then
			local name = GetSpellInfo(selectedSpell)
			E.Options.args.filters.args.filterGroup.args[name] = {
				name = name..' ('..selectedSpell..')',
				type = 'group',
				get = function(info) return E.global.unitframe.buffwatch[E.myclass][selectedSpell][ info[#info] ] end,
				set = function(info, value)
					E.global.unitframe.buffwatch[E.myclass][selectedSpell][ info[#info] ] = value;

					UF:UpdateAuraWatchFromHeader('raid')
					UF:UpdateAuraWatchFromHeader('raid40')
					UF:UpdateAuraWatchFromHeader('party')
					UF:UpdateAuraWatchFromHeader('raidpet', true)
				end,
				order = -10,
				args = {
					enabled = {
						name = L["Enable"],
						order = 0,
						type = 'toggle',
					},
					point = {
						name = L["Anchor Point"],
						order = 1,
						type = 'select',
						values = {
							['TOPLEFT'] = 'TOPLEFT',
							['TOPRIGHT'] = 'TOPRIGHT',
							['BOTTOMLEFT'] = 'BOTTOMLEFT',
							['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
							['LEFT'] = 'LEFT',
							['RIGHT'] = 'RIGHT',
							['TOP'] = 'TOP',
							['BOTTOM'] = 'BOTTOM',
						}
					},
					sizeOverride = {
						order = 2,
						type = "range",
						name = L["Size Override"],
						min = 0, max = 50, step = 1,
					},
					xOffset = {
						order = 3,
						type = 'range',
						name = L["xOffset"],
						min = -75, max = 75, step = 1,
					},
					yOffset = {
						order = 4,
						type = 'range',
						name = L["yOffset"],
						min = -75, max = 75, step = 1,
					},
					style = {
						name = L["Style"],
						order = 5,
						type = 'select',
						values = {
							['coloredIcon'] = L["Colored Icon"],
							['texturedIcon'] = L["Textured Icon"],
							['NONE'] = NONE,
						},
					},
					color = {
						name = COLOR,
						type = 'color',
						order = 6,
						get = function(info)
							local t = E.global.unitframe.buffwatch[E.myclass][selectedSpell][ info[#info] ]
							return t.r, t.g, t.b, t.a
						end,
						set = function(info, r, g, b)
							local t = E.global.unitframe.buffwatch[E.myclass][selectedSpell][ info[#info] ]
							t.r, t.g, t.b = r, g, b
							UF:UpdateAuraWatchFromHeader('raid')
							UF:UpdateAuraWatchFromHeader('raid40')
							UF:UpdateAuraWatchFromHeader('party')
							UF:UpdateAuraWatchFromHeader('raidpet', true)
						end,
					},
					displayText = {
						name = L["Display Text"],
						type = 'toggle',
						order = 7,
					},
					textColor = {
						name = L["Text Color"],
						type = 'color',
						order = 8,
						get = function(info)
							local t = E.global.unitframe.buffwatch[E.myclass][selectedSpell][ info[#info] ]
							if t then
								return t.r, t.g, t.b, t.a
							else
								return 1, 1, 1, 1
							end
						end,
						set = function(info, r, g, b)
							E.global.unitframe.buffwatch[E.myclass][selectedSpell].textColor = E.global.unitframe.buffwatch[E.myclass][selectedSpell].textColor or {}
							local t = E.global.unitframe.buffwatch[E.myclass][selectedSpell].textColor
							t.r, t.g, t.b = r, g, b
							UF:UpdateAuraWatchFromHeader('raid')
							UF:UpdateAuraWatchFromHeader('raid40')
							UF:UpdateAuraWatchFromHeader('party')
							UF:UpdateAuraWatchFromHeader('raidpet', true)
						end,
					},
					decimalThreshold = {
						name = L["Decimal Threshold"],
						desc = L["Threshold before text goes into decimal form. Set to -1 to disable decimals."],
						type = 'range',
						order = 9,
						min = -1, max = 10, step = 1,
					},
					textThreshold = {
						name = L["Text Threshold"],
						desc = L["At what point should the text be displayed. Set to -1 to disable."],
						type = 'range',
						order = 10,
						min = -1, max = 60, step = 1,
					},
					anyUnit = {
						name = L["Show Aura From Other Players"],
						order = 11,
						type = 'toggle',
					},
					onlyShowMissing = {
						name = L["Show When Not Active"],
						order = 12,
						type = 'toggle',
					},
				},
			}
		end
	elseif selectedFilter == 'Buff Indicator (Profile)' then
		E.Options.args.filters.args.filterGroup = {
			type = 'group',
			name = selectedFilter,
			guiInline = true,
			order = 15,
			childGroups = "select",
			args = {
				addSpellID = {
					order = 1,
					name = L["Add SpellID"],
					desc = L["Add a spell to the filter."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if not tonumber(value) then
							E:Print(L["Value must be a number"])
						elseif not GetSpellInfo(value) then
							E:Print(L["Not valid spell id"])
						else
							E.db.unitframe.filters.buffwatch[tonumber(value)] = {["enabled"] = true, ["id"] = tonumber(value), ["point"] = "TOPRIGHT", ["color"] = {["r"] = 1, ["g"] = 0, ["b"] = 0}, ["anyUnit"] = false, ['style'] = 'coloredIcon', ["xOffset"] = 0, ["yOffset"] = 0}
							selectedSpell = nil;
							UpdateFilterGroup();

							UF:UpdateAuraWatchFromHeader('raid')
							UF:UpdateAuraWatchFromHeader('raid40')
							UF:UpdateAuraWatchFromHeader('party')
						end
					end,
				},
				removeSpellID = {
					order = 2,
					name = L["Remove SpellID"],
					desc = L["Remove a spell from the filter."],
					type = 'execute',
					buttonElvUI = true,
					func = function()
						if P.unitframe.filters.buffwatch[selectedSpell] then
							E.db.unitframe.filters.buffwatch[selectedSpell].enabled = false
							E:Print(L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."])
						else
							E.db.unitframe.filters.buffwatch[selectedSpell] = nil
						end

						selectedSpell = nil;
						UpdateFilterGroup();
						UF:UpdateAuraWatchFromHeader('raid')
						UF:UpdateAuraWatchFromHeader('raid40')
						UF:UpdateAuraWatchFromHeader('party')
					end,
					disabled = function() return not selectedSpell end,
				},
				quickSearch = {
					order = 3,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = "select",
					order = 10,
					width = "double",
					values = function()
						local values = {}
						local list = E.db.unitframe.filters.buffwatch
						if not list then return end
						local searchText = quickSearchText:lower()
						for _, spell in pairs(list) do
							if spell.id then
								local name = GetSpellInfo(spell.id)
								if name:lower():find(searchText) then values[spell.id] = name end
							end
						end
						return values
					end,
					get = function(info) return selectedSpell end,
					set = function(info, value)
						selectedSpell = value;
						UpdateFilterGroup()
					end,
				},
			},
		}

		E.Options.args.filters.args.resetGroup = {
			type = "group",
			name = L["Reset Filter"],
			order = 25,
			guiInline = true,
			args = {
				enableReset = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return FilterResetState[selectedFilter] end,
					set = function(info, value)
						FilterResetState[selectedFilter] = value
						E.Options.args.filters.args.resetGroup.args.resetFilter.disabled = (not value)
					end,
				},
				resetFilter = {
					order = 2,
					type = "execute",
					buttonElvUI = true,
					name = L["Reset Filter"],
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					disabled = function() return not FilterResetState[selectedFilter] end,
					func = function(info)
						E.db.unitframe.filters.buffwatch = {}
						selectedSpell = nil
						UpdateFilterGroup()
						UF:Update_AllFrames()
					end,
				},
			},
		}

		if selectedSpell then
			local name = GetSpellInfo(selectedSpell)
			E.Options.args.filters.args.filterGroup.args[name] = {
				name = name..' ('..selectedSpell..')',
				type = 'group',
				hidden = function() return not E.db.unitframe.filters.buffwatch[selectedSpell] end,
				get = function(info)
					if E.db.unitframe.filters.buffwatch[selectedSpell] then
						return E.db.unitframe.filters.buffwatch[selectedSpell][ info[#info] ]
					end
				end,
				set = function(info, value)
					E.db.unitframe.filters.buffwatch[selectedSpell][ info[#info] ] = value;

					UF:UpdateAuraWatchFromHeader('raid')
					UF:UpdateAuraWatchFromHeader('raid40')
					UF:UpdateAuraWatchFromHeader('party')
				end,
				order = -10,
				args = {
					enabled = {
						name = L["Enable"],
						order = 0,
						type = 'toggle',
					},
					point = {
						name = L["Anchor Point"],
						order = 1,
						type = 'select',
						values = {
							['TOPLEFT'] = 'TOPLEFT',
							['TOPRIGHT'] = 'TOPRIGHT',
							['BOTTOMLEFT'] = 'BOTTOMLEFT',
							['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
							['LEFT'] = 'LEFT',
							['RIGHT'] = 'RIGHT',
							['TOP'] = 'TOP',
							['BOTTOM'] = 'BOTTOM',
						}
					},
					sizeOverride = {
						order = 2,
						type = "range",
						name = L["Size Override"],
						min = 0, max = 50, step = 1,
					},
					xOffset = {
						order = 3,
						type = 'range',
						name = L["xOffset"],
						min = -75, max = 75, step = 1,
					},
					yOffset = {
						order = 4,
						type = 'range',
						name = L["yOffset"],
						min = -75, max = 75, step = 1,
					},
					style = {
						name = L["Style"],
						order = 5,
						type = 'select',
						values = {
							['coloredIcon'] = L["Colored Icon"],
							['texturedIcon'] = L["Textured Icon"],
							['NONE'] = NONE,
						},
					},
					color = {
						name = COLOR,
						type = 'color',
						order = 6,
						get = function(info)
							if E.db.unitframe.filters.buffwatch[selectedSpell] then
								local t = E.db.unitframe.filters.buffwatch[selectedSpell][ info[#info] ]
								return t.r, t.g, t.b, t.a
							end
						end,
						set = function(info, r, g, b)
							local t = E.db.unitframe.filters.buffwatch[selectedSpell][ info[#info] ]
							t.r, t.g, t.b = r, g, b
							UF:UpdateAuraWatchFromHeader('raid')
							UF:UpdateAuraWatchFromHeader('raid40')
							UF:UpdateAuraWatchFromHeader('party')
						end,
					},
					displayText = {
						name = L["Display Text"],
						type = 'toggle',
						order = 7,
					},
					textColor = {
						name = L["Text Color"],
						type = 'color',
						order = 8,
						get = function(info)
							if E.db.unitframe.filters.buffwatch[selectedSpell] then
								local t = E.db.unitframe.filters.buffwatch[selectedSpell][ info[#info] ]
								if t then
									return t.r, t.g, t.b, t.a
								else
									return 1, 1, 1, 1
								end
							end
						end,
						set = function(info, r, g, b)
							local t = E.db.unitframe.filters.buffwatch[selectedSpell][ info[#info] ]
							t.r, t.g, t.b = r, g, b
							UF:UpdateAuraWatchFromHeader('raid')
							UF:UpdateAuraWatchFromHeader('raid40')
							UF:UpdateAuraWatchFromHeader('party')
						end,
					},
					decimalThreshold = {
						name = L["Decimal Threshold"],
						desc = L["Threshold before text goes into decimal form. Set to -1 to disable decimals."],
						type = 'range',
						order = 9,
						min = -1, max = 10, step = 1,
					},
					textThreshold = {
						name = L["Text Threshold"],
						desc = L["At what point should the text be displayed. Set to -1 to disable."],
						type = 'range',
						order = 10,
						min = -1, max = 60, step = 1,
					},
					anyUnit = {
						name = L["Show Aura From Other Players"],
						order = 11,
						type = 'toggle',
					},
					onlyShowMissing = {
						name = L["Show When Not Active"],
						order = 12,
						type = 'toggle',
					},
				},
			}
		end
	else
		if not selectedFilter or not E.global.unitframe.aurafilters[selectedFilter] then
			E.Options.args.filters.args.filterGroup = nil
			E.Options.args.filters.args.spellGroup = nil
			E.Options.args.filters.args.resetGroup = nil
			return
		end

		E.Options.args.filters.args.filterGroup = {
			type = 'group',
			name = selectedFilter,
			guiInline = true,
			order = 10,
			args = {
				addSpell = {
					order = 1,
					name = L["Add Spell ID or Name"],
					desc = L["Add a spell to the filter. Use spell ID if you don't want to match all auras which share the same name."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if tonumber(value) then	value = tonumber(value) end
						if not E.global.unitframe.aurafilters[selectedFilter].spells[value] then
							E.global.unitframe.aurafilters[selectedFilter].spells[value] = {
								['enable'] = true,
								['priority'] = 0,
								["stackThreshold"] = 0,
							}
						end
						UpdateFilterGroup();
						UF:Update_AllFrames();
					end,
				},
				removeSpell = {
					order = 2,
					name = L["Remove Spell"],
					desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
					type = 'execute',
					buttonElvUI = true,
					func = function()
						local value = selectedSpell:match(" %((%d+)%)$") or selectedSpell
						if tonumber(value) then value = tonumber(value) end
						if G['unitframe'].aurafilters[selectedFilter] then
							if G['unitframe'].aurafilters[selectedFilter].spells[value] then
								E.global.unitframe.aurafilters[selectedFilter].spells[value].enable = false;
								E:Print(L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."])
							else
								E.global.unitframe.aurafilters[selectedFilter].spells[value] = nil;
							end
						else
							E.global.unitframe.aurafilters[selectedFilter].spells[value] = nil;
						end

						UpdateFilterGroup();
						UF:Update_AllFrames();
					end,
					disabled = function() return not (selectedSpell and selectedSpell ~= "") end,
				},
				filterType = {
					order = 3,
					name = L["Filter Type"],
					desc = L["Set the filter type. Blacklist will hide any auras in the list and show all others. Whitelist will show any auras in the filter and hide all others."],
					type = 'select',
					values = {
						['Whitelist'] = L["Whitelist"],
						['Blacklist'] = L["Blacklist"],
					},
					get = function() return E.global.unitframe.aurafilters[selectedFilter].type end,
					set = function(info, value) E.global.unitframe.aurafilters[selectedFilter].type = value; UF:Update_AllFrames(); end,
				},
				quickSearch = {
					order = 4,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = 'select',
					order = 10,
					guiInline = true,
					width = "double",
					get = function(info) return selectedSpell end,
					set = function(info, value)
						selectedSpell = value;
						UpdateFilterGroup()
					end,
					values = function()
						local filters = {}
						local list = E.global.unitframe.aurafilters[selectedFilter].spells
						if not list then return end
						local searchText = quickSearchText:lower()
						for filter in pairs(list) do
							if tonumber(filter) then
								local spellName = GetSpellInfo(filter)
								if spellName then
									filter = format("%s (%s)", spellName, filter)
								else
									filter = tostring(filter)
								end
							end
							if filter:lower():find(searchText) then filters[filter] = filter end
						end
						if not next(filters) then filters[''] = NONE end
						return filters
					end,
				},
			},
		}

		if (E.DEFAULT_FILTER[selectedFilter]) then
			--Disable and hide filter type option for default filters
			E.Options.args.filters.args.filterGroup.args.filterType.disabled = true
			E.Options.args.filters.args.filterGroup.args.filterType.hidden = true

			--Add button to reset content of the filter back to default
			E.Options.args.filters.args.resetGroup = {
				type = "group",
				name = L["Reset Filter"],
				order = 25,
				guiInline = true,
				args = {
					enableReset = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return FilterResetState[selectedFilter] end,
						set = function(info, value)
							FilterResetState[selectedFilter] = value
							E.Options.args.filters.args.resetGroup.args.resetFilter.disabled = (not value)
						end,
					},
					resetFilter = {
						order = 2,
						type = "execute",
						buttonElvUI = true,
						name = L["Reset Filter"],
						desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
						disabled = function() return not FilterResetState[selectedFilter] end,
						func = function()
							E.global.unitframe.aurafilters[selectedFilter].spells = E:CopyTable({}, G.unitframe.aurafilters[selectedFilter].spells)
							selectedSpell = nil
							UpdateFilterGroup()
							UF:Update_AllFrames()
						end,
					},
				},
			}
		end

		local spellID = selectedSpell and match(selectedSpell, "(%d+)")
		if spellID then spellID = tonumber(spellID) end

		if not selectedSpell or not E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)] then
			E.Options.args.filters.args.spellGroup = nil
			return
		end

		E.Options.args.filters.args.spellGroup = {
			type = "group",
			name = selectedSpell,
			order = 15,
			guiInline = true,
			args = {
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
					get = function()
						if selectedFolder or not (spellID or selectedSpell) then
							return false
						else
							return E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)].enable
						end
					end,
					set = function(info, value) E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)].enable = value; UpdateFilterGroup(); UF:Update_AllFrames(); end
				},
				forDebuffIndicator = {
					order = 2,
					type = "group",
					name = L["Used as RaidDebuff Indicator"],
					guiInline = true,
					args = {
						priority = {
							order = 1,
							type = "range",
							name = L["Priority"],
							desc = L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."],
							min = 0, max = 99, step = 1,
							get = function()
								if selectedFolder or not selectedSpell then
									return 0
								else
									return E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)].priority
								end
							end,
							set = function(info, value) E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)].priority = value; UpdateFilterGroup(); UF:Update_AllFrames(); end,
						},
						stackThreshold = {
							order = 2,
							type = "range",
							name = L["Stack Threshold"],
							desc = L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."],
							min = 0, max = 99, step = 1,
							get = function()
								if selectedFolder or not selectedSpell then
									return 0
								else
									return E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)].stackThreshold
								end
							end,
							set = function(info, value) E.global.unitframe.aurafilters[selectedFilter].spells[(spellID or selectedSpell)].stackThreshold = value; UpdateFilterGroup(); UF:Update_AllFrames(); end,
						},
					},
				},
			},
		}
	end

	UF:Update_AllFrames();
end

E.Options.args.filters = {
	type = 'group',
	name = FILTERS,
	order = -10, --Always Last Hehehe
	args = {
		createFilter = {
			order = 1,
			name = L["Create Filter"],
			desc = L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."],
			type = 'input',
			get = function(info) return "" end,
			set = function(info, value)
				if match(value, "^[%s%p]-$") then
					return
				end
				if match(value, ",") then
					E:Print(L["Filters are not allowed to have commas in their name. Stripping commas from filter name."])
					value = gsub(value, ",", "")
				end
				if match(value, "^Friendly:") or match(value, "^Enemy:") then
					return --dont allow people to create Friendly: or Enemy: filters
				end
				if G.unitframe.specialFilters[value] or E.global.unitframe.aurafilters[value] then
					E:Print(L["Filter already exists!"])
					return
				end
				E.global.unitframe.aurafilters[value] = {};
				E.global.unitframe.aurafilters[value].spells = {};
			end,
		},
		selectFilter = {
			order = 2,
			type = 'select',
			name = L["Select Filter"],
			get = function(info) return selectedFilter end,
			set = function(info, value)
				if value == '' then
					selectedFilter = nil;
					selectedSpell = nil;
				else
					selectedSpell = nil;
					if FilterResetState[selectedFilter] then
						FilterResetState[selectedFilter] = nil
					end
					selectedFilter = value
				end;
				quickSearchText = ""
				UpdateFilterGroup()
			end,
			values = function()
				local filters = {}
				filters[''] = NONE
				local list = E.global.unitframe.aurafilters
				if not list then return end
				for filter in pairs(list) do
					filters[filter] = filter
				end

				filters['Buff Indicator'] = 'Buff Indicator'
				filters['Buff Indicator (Pet)'] = 'Buff Indicator (Pet)'
				filters['Buff Indicator (Profile)'] = 'Buff Indicator (Profile)'
				filters['AuraBar Colors'] = 'AuraBar Colors'
				filters['Debuff Highlight'] = 'Debuff Highlight'
				return filters
			end,
		},
		deleteFilter = {
			type = 'execute',
			order = 3,
			buttonElvUI = true,
			name = L["Delete Filter"],
			desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
			func = function()
				E.global.unitframe.aurafilters[selectedFilter] = nil
				removePriority(selectedFilter) --This will wipe a filter from the new aura system profile settings.
				selectedFilter = nil
				selectedSpell = nil
				quickSearchText = ""
				E.Options.args.filters.args.filterGroup = nil
			end,
			disabled = function() return G.unitframe.aurafilters[selectedFilter] end,
			hidden = function() return selectedFilter == nil end,
		},
	},
}

local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
function E:SetToFilterConfig(filter)
	selectedFilter = filter or 'Buff Indicator'
	UpdateFilterGroup()
	ACD:SelectGroup("ElvUI", "filters")
end
