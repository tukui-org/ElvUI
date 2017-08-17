local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local selectedNameplateFilter
local filters

local pairs, type, strsplit, match, gsub = pairs, type, strsplit, string.match, string.gsub
local LEVEL = LEVEL
local OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS = OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS
local NONE = NONE

local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

local positionValues = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
	CENTER = 'CENTER',
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
};

local function filterValue(value)
	return gsub(value,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function filterPriority(auraType, unit, value, remove)
	if not auraType or not value then return end
	local filter = E.db.nameplates.units[unit] and E.db.nameplates.units[unit][auraType] and E.db.nameplates.units[unit][auraType].filters and E.db.nameplates.units[unit][auraType].filters.priority
	if not filter then return end
	local found = filterMatch(filter, filterValue(value))
	if found and remove then
		E.db.nameplates.units[unit][auraType].filters.priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.nameplates.units[unit][auraType].filters.priority = (filter == '' and value) or (filter..","..value)
	end
end

local function UpdateFilterGroup()
	if not selectedNameplateFilter or not E.global.nameplate.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = nil
		E.Options.args.nameplate.args.filters.args.actions = nil
		E.Options.args.nameplate.args.filters.args.triggers = nil
	end
	if selectedNameplateFilter and E.global.nameplate.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = {
			order = 4,
			type = "header",
			name = selectedNameplateFilter,
		}
		E.Options.args.nameplate.args.filters.args.triggers = {
			type = "group",
			name = L["Triggers"],
			order = 5,
			args = {
				enable = {
					name = L["Enable"],
					order = 0,
					type = 'toggle',
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.enable
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.enable = value
						NP:ConfigureAll()
					end,
				},
				inCombat = {
					name = L["In Combat"],
					desc = L["If in or out of combat state, pass filter."],
					order = 1,
					type = 'toggle',
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.inCombat
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.inCombat = value
						NP:ConfigureAll()
					end,
				},
				outOfCombat = {
					name = L["Out Of Combat"],
					desc = L["If in or out of combat state, pass filter."],
					order = 2,
					type = 'toggle',
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.outOfCombat
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.outOfCombat = value
						NP:ConfigureAll()
					end,
				},
				spacer1 = {
					order = 3,
					type = 'description',
					name = '',
				},
				name = {
					order = 4,
					type = 'input',
					name = L["Name"],
					desc = L["Name must but this in order to trigger, set to blank to turn off."],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.name or ""
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.name = value
						NP:ConfigureAll()
					end,
				},
				npcid = {
					order = 5,
					type = 'input',
					name = L["NPC ID"],
					desc = L["NPC ID must but this in order to trigger, set to blank to turn off."],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.npcid or ""
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.npcid = value
						NP:ConfigureAll()
					end,
				},
				spacer2 = {
					order = 6,
					type = 'description',
					name = '',
				},
				levels = {
					order = 7,
					type = 'group',
					name = LEVEL,
					guiInline = true,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.level
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.level = value
								NP:ConfigureAll()
							end,
						},
						matchLevel = {
							type = 'toggle',
							order = 2,
							name = L["Match my level"],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = L["LEVEL_BOSS"],
						},
						minLevel = {
							order = 4,
							type = 'range',
							name = L["Minimum Level"],
							min = -1, max = MAX_PLAYER_LEVEL, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel = value
								NP:ConfigureAll()
							end,
						},
						maxLevel = {
							order = 5,
							type = 'range',
							name = L["Maximum Level"],
							min = -1, max = MAX_PLAYER_LEVEL, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel = value
								NP:ConfigureAll()
							end,
						},
						currentLevel = {
							name = L["Current Level"],
							order = 6,
							type = "range",
							min = -1, max = MAX_PLAYER_LEVEL, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel = value
								NP:ConfigureAll()
							end,
						},
					},
				},
				buffs = {
					name = L["Buffs"],
					order = 8,
					type = "group",
					guiInline = true,
					args = {
						addBuff = {
							order = 1,
							name = L["Add Buff"],
							desc = L["Add a buff/debuff to the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								if tonumber(value) then
									local spellName = GetSpellInfo(value)
									if spellName then
										value = spellName
									end
								end
								if not E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs then
									E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs = {
										mustHaveAll = false,
										names = {},
									}
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[value] = true,
								UpdateFilterGroup();
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeBuff = {
							order = 2,
							name = L["Remove Buff"],
							desc = L["Remove a buff/debuff from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if tonumber(value) then
									local spellName = GetSpellInfo(value)
									if spellName then
										value = spellName
									end
								end

								if E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs then
									E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[value] = nil;
								end
								UpdateFilterGroup();
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						mustHaveAll = {
							order = 3,
							name = L["Must Have All"],
							type = "toggle",
							desc = L["Must have all of the buffs/debuffs listed in order to pass filter."],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll = value
								NP:ConfigureAll()
							end,
						},
						names = {
							order = 4,
							type = "group",
							name = "",
							guiInline = true,
							args = {},
						}
					},
				},
				debuffs = {
					name = L["Debuffs"],
					order = 9,
					type = "group",
					guiInline = true,
					args = {
						addDebuff = {
							order = 1,
							name = L["Add Debuff"],
							desc = L["Add a buff/debuff to the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								if tonumber(value) then
									local spellName = GetSpellInfo(value)
									if spellName then
										value = spellName
									end
								end

								if not E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs then
									E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs = {
											mustHaveAll = false,
											names = {},
									}
								end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[value] = true,
								UpdateFilterGroup();
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeDebuff = {
							order = 2,
							name = L["Remove Debuff"],
							desc = L["Remove a buff/debuff from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if tonumber(value) then
									local spellName = GetSpellInfo(value)
									if spellName then
										value = spellName
									end
								end

								if E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs then
									E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[value] = nil;
								end
								UpdateFilterGroup();
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						mustHaveAll = {
							order = 3,
							name = L["Must Have All"],
							type = "toggle",
							desc = L["Must have all of the buffs/debuffs listed in order to pass filter."],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll = value
								NP:ConfigureAll()
							end,
						},
						names = {
							order = 4,
							type = "group",
							name = "",
							guiInline = true,
							args = {},
						}
					},
				},
				nameplateType = {
					name = L["Nameplate Type"],
					order = 10,
					type = "group",
					guiInline = true,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType and E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable = value
								NP:ConfigureAll()
							end,
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 1,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable end,
							args = {
								friendlyPlayer = {
									name = L["FRIENDLY_PLAYER"],
									order = 1,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer = value
										NP:ConfigureAll()
									end,
								},
								friendlyNPC = {
									name = L["FRIENDLY_NPC"],
									order = 2,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC = value
										NP:ConfigureAll()
									end,
								},
								healer = {
									name = L["HEALER"],
									order = 3,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.healer
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.healer = value
										NP:ConfigureAll()
									end,
								},
								enemyPlayer = {
									name = L["ENEMY_PLAYER"],
									order = 4,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer = value
										NP:ConfigureAll()
									end,
								},
								enemyNPC = {
									name = L["ENEMY_NPC"],
									order = 5,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC = value
										NP:ConfigureAll()
									end,
								},
								player = {
									name = L["PLAYER"],
									order = 6,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.player
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.player = value
										NP:ConfigureAll()
									end,
								},
							},
						},
					},
				},
			},
		}
		E.Options.args.nameplate.args.filters.args.actions = {
			type = "group",
			name = L["Actions"],
			order = 6,
			args = {
				hide = {
					name = L["Hide Frame"],
					order = 0,
					type = 'toggle',
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.hide = value
						NP:ConfigureAll()
					end,
				},
				scale = {
					name = L["Scale"],
					order = 2,
					type = "range",
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.scale or 1
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.scale = value
						NP:ConfigureAll()
					end,
					min=0.35, max = 1.5, step = 0.01,
				},
				color = {
					name = L["Color"],
					type = "group",
					guiInline = true,
					order = 3,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.color.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.color.enable = value
								NP:ConfigureAll()
							end,
						},
						color = {
							name = L["Color"],
							type = 'color',
							order = 1,
							hasAlpha = true,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.color
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.color
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
					},
				},
			},
		}

		if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names then
			for name, _ in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) do
				E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names.args[name] = {
					name = name,
					type = "toggle",
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name] = value
						NP:ConfigureAll()
					end,
				}
			end
		end

		if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names then
			for name, _ in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) do
				E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names.args[name] = {
					name = name,
					type = "toggle",
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name] = value
						NP:ConfigureAll()
					end,
				}
			end
		end
	end
end

local ORDER = 100
local function GetUnitSettings(unit, name)
	local copyValues = {}
	for x, y in pairs(NP.db.units) do
		if(type(y) == "table" and x ~= unit) then
			copyValues[x] = L[x]
		end
	end
	local group = {
		type = "group",
		order = ORDER,
		name = name,
		childGroups = "tab",
		get = function(info) return E.db.nameplates.units[unit][ info[#info] ] end,
		set = function(info, value) E.db.nameplates.units[unit][ info[#info] ] = value; NP:ConfigureAll() end,
		args = {
			copySettings = {
				order = -10,
				name = L["Copy Settings From"],
				desc = L["Copy settings from another unit."],
				type = "select",
				values = copyValues,
				get = function() return '' end,
				set = function(info, value)
					NP:CopySettings(value, unit)
					NP:ConfigureAll()
				end,
			},
			defaultSettings = {
				order = -9,
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				type = "execute",
				func = function(info, value)
					NP:ResetSettings(unit)
					NP:ConfigureAll()
				end,
			},
			healthGroup = {
				order = 1,
				name = L["Health"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].healthbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].healthbar[ info[#info] ] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Health"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						disabled = function() return unit == "PLAYER" end,
						hidden = function() return unit == "PLAYER" end,
					},
					height = {
						order = 2,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					width = {
						order = 3,
						name = L["Width"],
						type = "range",
						min = 50, max = 200, step = 1,
					},
					textGroup = {
						order = 100,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].healthbar.text[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].healthbar.text[ info[#info] ] = value; NP:ConfigureAll() end,
						args = {
							enable = {
								order = 1,
								name = L["Enable"],
								type = "toggle",
							},
							format = {
								order = 2,
								name = L["Format"],
								type = "select",
								values = {
									['CURRENT'] = L["Current"],
									['CURRENT_MAX'] = L["Current / Max"],
									['CURRENT_PERCENT'] =  L["Current - Percent"],
									['CURRENT_MAX_PERCENT'] = L["Current - Max | Percent"],
									['PERCENT'] = L["Percent"],
									['DEFICIT'] = L["Deficit"],
								},
							},
						},
					},
				},
			},
			powerGroup = {
				order = 2,
				name = L["Power"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].powerbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].powerbar[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Power"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					hideWhenEmpty = {
						order = 2,
						name = L["Hide When Empty"],
						type = "toggle",
					},
					height = {
						order = 3,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					textGroup = {
						order = 100,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].powerbar.text[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].powerbar.text[ info[#info] ] = value; NP:ConfigureAll() end,
						args = {
							enable = {
								order = 1,
								name = L["Enable"],
								type = "toggle",
							},
							format = {
								order = 2,
								name = L["Format"],
								type = "select",
								values = {
									['CURRENT'] = L["Current"],
									['CURRENT_MAX'] = L["Current / Max"],
									['CURRENT_PERCENT'] =  L["Current - Percent"],
									['CURRENT_MAX_PERCENT'] = L["Current - Max | Percent"],
									['PERCENT'] = L["Percent"],
									['DEFICIT'] = L["Deficit"],
								},
							},
						},
					},
				},
			},
			castGroup = {
				order = 3,
				name = L["Cast Bar"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].castbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Cast Bar"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					hideSpellName = {
						order = 2,
						name = L["Hide Spell Name"],
						type = "toggle",
					},
					hideTime = {
						order = 3,
						name = L["Hide Time"],
						type = "toggle",
					},
					height = {
						order = 4,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					castTimeFormat = {
						order = 5,
						type = "select",
						name = L["Cast Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"],
						},
					},
					channelTimeFormat = {
						order = 6,
						type = "select",
						name = L["Channel Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"],
						},
					},
					timeToHold = {
						order = 7,
						type = "range",
						name = L["Time To Hold"],
						desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
						min = 0, max = 4, step = 0.1,
					},
				},
			},
			buffsGroup = {
				order = 4,
				name = L["Buffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].buffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].buffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Buffs"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					baseHeight = {
						order = 3,
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						type = "range",
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = L["Filters"],
						order = 4,
						type = "group",
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							jumpToFilter = {
								order = 3,
								name = L["Filters Page"],
								desc = L["Shortcut to global filters page"],
								type = "execute",
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " ",
							},
							defaultFilter = {
								order = 5,
								type = "select",
								name = L["Add default filter into Priority"],
								values = function()
									local filters = {}
									for filter, value in pairs(E.global.nameplate['defaultFilters']) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('buffs', unit, value)
								end
							},
							filter = {
								order = 6,
								type = "select",
								name = L["Add global filter into Priority"],
								values = function()
									local filters = {}
									for filter in pairs(E.global.unitframe['aurafilters']) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('buffs', unit, value)
								end
							},
							resetPriority = {
								order = 7,
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								type = "execute",
								func = function()
									E.db.nameplates.units[unit].buffs.filters.priority = P.nameplates.units[unit].buffs.filters.priority
								end,
							},
							spacer3 = {
								order = 8,
								type = "description",
								name = " ",
							},
							filterPriority = {
								order = 9,
								type = "multiselect",
								name = L["Filter Priority"],
								values = function()
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function(info, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									filterPriority('buffs', unit, tbl[value], true)
								end,
							},
						},
					},
				},
			},
			debuffsGroup = {
				order = 5,
				name = L["Debuffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Debuffs"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					baseHeight = {
						order = 3,
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						type = "range",
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = L["Filters"],
						order = 4,
						type = "group",
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							jumpToFilter = {
								order = 3,
								name = L["Filters Page"],
								desc = L["Shortcut to global filters page"],
								type = "execute",
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " ",
							},
							defaultFilter = {
								order = 5,
								type = "select",
								name = L["Add default filter into Priority"],
								values = function()
									local filters = {}
									for filter, value in pairs(E.global.nameplate['defaultFilters']) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('debuffs', unit, value)
								end
							},
							filter = {
								order = 6,
								type = "select",
								name = L["Add global filter into Priority"],
								values = function()
									local filters = {}
									for filter in pairs(E.global.unitframe['aurafilters']) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('debuffs', unit, value)
								end
							},
							resetPriority = {
								order = 7,
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								type = "execute",
								func = function()
									E.db.nameplates.units[unit].debuffs.filters.priority = P.nameplates.units[unit].debuffs.filters.priority
								end,
							},
							spacer3 = {
								order = 8,
								type = "description",
								name = " ",
							},
							filterPriority = {
								order = 9,
								type = "multiselect",
								name = L["Filter Priority"],
								values = function()
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function(info, value)
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									filterPriority('debuffs', unit, tbl[value], true)
								end,
							},
						},
					},
				},
			},
			levelGroup = {
				order = 6,
				name = LEVEL,
				type = "group",
				args = {
					header = {
						order = 0,
						type = "header",
						name = LEVEL,
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showLevel end,
						set = function(info, value) E.db.nameplates.units[unit].showLevel = value; NP:ConfigureAll() end,
					},
				},
			},
			nameGroup = {
				order = 7,
				name = L["Name"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].name[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].name[ info[#info] ] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Name"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showName end,
						set = function(info, value) E.db.nameplates.units[unit].showName = value; NP:ConfigureAll() end,
					},
				},
			},
		},
	}

	if unit == "PLAYER" then
		group.args.enable = {
			order = -15,
			name = L["Enable"],
			type = "toggle",
		}
		group.args.general = {
			order = 0,
			type = "group",
			name = L["General"],
			args = {
				useStaticPosition = {
					order = 1,
					type = "toggle",
					name = L["Use Static Position"],
					desc = L["When enabled the nameplate will stay visible in a locked position."],
					get = function(info) return E.db.nameplates.units[unit].useStaticPosition end,
					set = function(info, value) E.db.nameplates.units[unit].useStaticPosition = value; NP:ConfigureAll() end,
				},
				visibility = {
					order = 10,
					type = "group",
					guiInline = true,
					name = L["Visibility"],
					args = {
						showAlways = {
							order = 1,
							type = "toggle",
							name = L["Always Show"],
							get = function(info) return E.db.nameplates.units[unit].visibility.showAlways end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.showAlways = value; NP:ConfigureAll() end,
						},
						showInCombat = {
							order = 2,
							type = "toggle",
							name = L["Show In Combat"],
							get = function(info) return E.db.nameplates.units[unit].visibility.showInCombat end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.showInCombat = value; NP:ConfigureAll() end,
							disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
						},
						showWithTarget = {
							order = 2,
							type = "toggle",
							name = L["Show With Target"],
							get = function(info) return E.db.nameplates.units[unit].visibility.showWithTarget end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.showWithTarget = value; NP:ConfigureAll() end,
							disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
						},
						hideDelay = {
							order = 4,
							type = "range",
							name = L["Hide Delay"],
							min = 0, max = 20, step = 0.5,
							get = function(info) return E.db.nameplates.units[unit].visibility.hideDelay end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.hideDelay = value; NP:ConfigureAll() end,
							disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
						},
					},
				},
			},
		}
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"],
		}
	elseif unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" then
		group.args.minions = {
			order = 0,
			name = L["Display Minions"],
			desc = unit == "FRIENDLY_PLAYER" and OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS or OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS,
			type = "toggle",
		}
		if unit == "ENEMY_PLAYER" then
			group.args.markHealers = {
				type = "toggle",
				order = 10,
				name = L["Healer Icon"],
				desc = L["Display a healer icon over known healers inside battlegrounds or arenas."],
				set = function(info, value) E.db.nameplates.units.ENEMY_PLAYER[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:ConfigureAll() end,
			}
		end
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"],
		}
	elseif unit == "ENEMY_NPC" then
		group.args.minors = {
			order = 0,
			name = L["Display Minor Units"],
			desc = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS,
			type = "toggle",
		}
		group.args.eliteIcon = {
			order = 10,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[ info[#info] ] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[ info[#info] ] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Elite Icon"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"],
					},
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
				},
				xOffset = {
					order = 4,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 5,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
			},
		}
		group.args.detection = {
			order = 11,
			name = L["Detection"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].detection[ info[#info] ] end,
			set = function(info, value) E.db.nameplates.units[unit].detection[ info[#info] ] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Suramar Detection"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
			},
		}
	elseif unit == "FRIENDLY_NPC" then
		group.args.eliteIcon = {
			order = 10,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[ info[#info] ] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[ info[#info] ] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Elite Icon"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"],
					},
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
				},
				xOffset = {
					order = 4,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 5,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
			},
		}
	elseif unit == "HEALER" then
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"],
		}
	end


	ORDER = ORDER + 100
	return group
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplates[ info[#info] ] end,
	set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:ConfigureAll() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[ info[#info] ] end,
			set = function(info, value) E.private.nameplates[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		intro = {
			order = 2,
			type = "description",
			name = L["NAMEPLATE_DESC"],
		},
		header = {
			order = 3,
			type = "header",
			name = L["Shortcuts"],
		},
		spacer1 = {
			order = 4,
			type = "description",
			name = " ",
		},
		generalShortcut = {
			order = 5,
			type = "execute",
			name = L["General"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "general") end,
		},
		fontsShortcut = {
			order = 6,
			type = "execute",
			name = L["Fonts"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "fontGroup") end,
		},
		classBarShortcut = {
			order = 7,
			type = "execute",
			name = L["Classbar"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "classBarGroup") end,
		},
		spacer2 = {
			order = 8,
			type = "description",
			name = " ",
		},
		threatShortcut = {
			order = 9,
			type = "execute",
			name = L["Threat"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "threatGroup") end,
		},
		castBarShortcut = {
			order = 10,
			type = "execute",
			name = L["Cast Bar"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "castGroup") end,
		},
		reactionShortcut = {
			order = 11,
			type = "execute",
			name = L["Reaction Colors"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "reactions") end,
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " ",
		},
		playerShortcut = {
			order = 13,
			type = "execute",
			name = L["Player Frame"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "playerGroup") end,
		},
		healerShortcut = {
			order = 14,
			type = "execute",
			name = L["Healer Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "healerGroup") end,
		},
		friendlyPlayerShortcut = {
			order = 15,
			type = "execute",
			name = L["Friendly Player Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
		},
		spacer4 = {
			order = 16,
			type = "description",
			name = " ",
		},
		enemyPlayerShortcut = {
			order = 17,
			type = "execute",
			name = L["Enemy Player Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
		},
		friendlyNPCShortcut = {
			order = 18,
			type = "execute",
			name = L["Friendly NPC Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
		},
		enemyNPCShortcut = {
			order = 19,
			type = "execute",
			name = L["Enemy NPC Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
		},
		spacer5 = {
			order = 20,
			type = "description",
			name = " ",
		},
		filtersShortcut = {
			order = 21,
			type = "execute",
			name = L["Filters"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "filter") end,
		},
		generalGroup = {
			order = 22,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates; end,
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					args = {
						statusbar = {
							order = 0,
							type = "select",
							dialogControl = 'LSM30_Statusbar',
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
						},
						motionType = {
							type = "select",
							order = 1,
							name = UNIT_NAMEPLATES_TYPES,
							desc = L["Set to either stack nameplates vertically or allow them to overlap."],
							values = {
								['STACKED'] = UNIT_NAMEPLATES_TYPE_2,
								['OVERLAP'] = UNIT_NAMEPLATES_TYPE_1,
							},
						},
						displayStyle = {
							type = "select",
							order = 2,
							name = L["Display Style"],
							desc = L["Controls which nameplates will be displayed."],
							values = {
								["ALL"] = ALL,
								["BLIZZARD"] = L["Target, Quest, Combat"],
								["TARGET"] = L["Only Show Target"],
							},
						},
						showNPCTitles = {
							order = 3,
							type = "toggle",
							name = L["Show NPC Titles"],
							desc = L["Display NPC Titles whenever healthbars arent displayed and names are."]
						},
						clampToScreen = {
							order = 4,
							type = "toggle",
							name = L["Clamp Nameplates"],
							desc = L["Clamp nameplates to the top of the screen when outside of view."],
						},
						lowHealthThreshold = {
							order = 5,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, max = 1, step = 0.01,
						},
						showEnemyCombat = {
							order = 6,
							type = "select",
							name = L["Enemy Combat Toggle"],
							desc = L["Control enemy nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["Disabled"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[ info[#info] ] = value;
								NP:PLAYER_REGEN_ENABLED()
							end,
						},
						showFriendlyCombat = {
							order = 7,
							type = "select",
							name = L["Friendly Combat Toggle"],
							desc = L["Control friendly nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["Disabled"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:PLAYER_REGEN_ENABLED() end,
						},
						loadDistance = {
							order = 8,
							type = "range",
							name = L["Load Distance"],
							desc = L["Only load nameplates for units within this range."],
							min = 10, max = 100, step = 1,
						},
						clickableWidth = {
							order = 9,
							type = "range",
							name = L["Clickable Width"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 50, max = 200, step = 1,
							set = function(info, value) E.db.nameplates.clickableWidth = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						clickableHeight = {
							order = 10,
							type = "range",
							name = L["Clickable Height"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 10, max = 75, step = 1,
							set = function(info, value) E.db.nameplates.clickableHeight = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						targetedNamePlate = {
							order = 11,
							type = "group",
							guiInline = true,
							name = L["Targeted Nameplate"],
							get = function(info) return E.db.nameplates[ info[#info] ] end,
							set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:ConfigureAll() end,
							args = {
								alwaysShowTargetHealth = {
									order = 1,
									type = "toggle",
									name = L["Always Show Target Health"],
									width = "double",
								},
								useTargetGlow = {
									order = 2,
									type = "toggle",
									name = L["Use Target Glow"],
								},
								useTargetScale = {
									order = 3,
									type = "toggle",
									name = L["Use Target Scale"],
									desc = L["Enable/Disable the scaling of targetted nameplates."],
								},
								targetScale = {
									order = 4,
									type = "range",
									isPercent = true,
									name = L["Target Scale"],
									desc = L["Scale of the nameplate that is targetted."],
									min = 0.3, max = 2, step = 0.01,
									disabled = function() return E.db.nameplates.useTargetScale ~= true end,
								},
								nonTargetTransparency = {
									order = 5,
									type = "range",
									isPercent = true,
									name = L["Non-Target Transparency"],
									desc = L["Set the transparency level of nameplates that are not the target nameplate."],
									min = 0, max = 1, step = 0.01,
								},
							},
						},
						clickThrough = {
							order = 12,
							type = "group",
							guiInline = true,
							name = L["Click Through"],
							get = function(info) return E.db.nameplates.clickThrough[ info[#info] ] end,
							args = {
								personal = {
									order = 1,
									type = "toggle",
									name = L["Personal"],
									set = function(info, value) E.db.nameplates.clickThrough.personal = value; NP:SetNamePlateSelfClickThrough() end,
								},
								friendly = {
									order = 2,
									type = "toggle",
									name = L["Friendly"],
									set = function(info, value) E.db.nameplates.clickThrough.friendly = value; NP:SetNamePlateFriendlyClickThrough() end,
								},
								enemy = {
									order = 3,
									type = "toggle",
									name = L["Enemy"],
									set = function(info, value) E.db.nameplates.clickThrough.enemy = value; NP:SetNamePlateEnemyClickThrough() end,
								},
							},
						},
					},
				},
				fontGroup = {
					order = 100,
					type = 'group',
					name = L["Fonts"],
					args = {
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 4,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 5,
							name = L["Font Size"],
							type = "range",
							min = 4, max = 212, step = 1,
						},
						fontOutline = {
							order = 6,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								['NONE'] = L["None"],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},
					},
				},
				classBarGroup = {
					order = 125,
					type = "group",
					name = L["Classbar"],
					get = function(info) return E.db.nameplates.classbar[ info[#info] ] end,
					set = function(info, value) E.db.nameplates.classbar[ info[#info] ] = value; NP:ConfigureAll() end,
					args = {
						enable = {
							type = "toggle",
							order = 1,
							name = L["Enable"]
						},
						attachTo = {
							type = "select",
							order = 2,
							name = L["Attach To"],
							values = {
								PLAYER = L["Player Nameplate"],
								TARGET = L["Targeted Nameplate"],
							},
						},
						position = {
							type = "select",
							order = 3,
							name = L["Position"],
							values = {
								ABOVE = L["Above"],
								BELOW = L["Below"],
							},
						},
					},
				},
				threatGroup = {
					order = 150,
					type = "group",
					name = L["Threat"],
					get = function(info)
						local t = E.db.nameplates.threat[ info[#info] ]
						local d = P.nameplates.threat[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.threat[ info[#info] ]
						t.r, t.g, t.b = r, g, b
					end,
					args = {
						useThreatColor = {
							order = 1,
							type = "toggle",
							name = L["Use Threat Color"],
							get = function(info) return E.db.nameplates.threat.useThreatColor end,
							set = function(info, value) E.db.nameplates.threat.useThreatColor = value; end,
						},
						goodColor = {
							type = "color",
							order = 2,
							name = L["Good Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						badColor = {
							name = L["Bad Color"],
							order = 3,
							type = 'color',
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						goodTransition = {
							type = "color",
							order = 4,
							name = L["Good Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						badTransition = {
							name = L["Bad Transition Color"],
							order = 5,
							type = 'color',
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						beingTankedByTank = {
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							order = 6,
							type = "toggle",
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						beingTankedByTankColor = {
							name = L["Tanked Color"],
							order = 7,
							type = 'color',
							hasAlpha = false,
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end,
						},
						goodScale = {
							name = L["Good Scale"],
							order = 8,
							type = 'range',
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
						},
						badScale = {
							name = L["Bad Scale"],
							order = 9,
							type = 'range',
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
						},
					},
				},
				castGroup = {
					order = 175,
					type = "group",
					name = L["Cast Bar"],
					get = function(info)
						local t = E.db.nameplates[ info[#info] ]
						local d = P.nameplates[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:ForEachPlate("ConfigureElement_CastBar")
					end,
					args = {
						castColor = {
							type = "color",
							order = 1,
							name = L["Cast Color"],
							hasAlpha = false,
						},
						castNoInterruptColor = {
							name = L["Cast No Interrupt Color"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
					},
				},
				reactions = {
					order = 200,
					type = "group",
					name = L["Reaction Colors"],
					get = function(info)
						local t = E.db.nameplates.reactions[ info[#info] ]
						local d = P.nameplates.reactions[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.reactions[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:ForEachPlate("UpdateElement_HealthColor", true)
						NP:ForEachPlate("UpdateElement_Name", true)
					end,
					args = {
						--[[offline = {
							type = "color",
							order = 1,
							name = L["Offline"],
							hasAlpha = false,
						},]]
						bad = {
							name = L["Enemy"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
						neutral = {
							name = L["Neutral"],
							order = 3,
							type = 'color',
							hasAlpha = false,
						},
						good = {
							name = L["Friendly"],
							order = 4,
							type = 'color',
							hasAlpha = false,
						},
						tapped = {
							name = L["Tagged NPC"],
							order = 5,
							type = 'color',
							hasAlpha = false,
						},
					},
				},
			},
		},
		playerGroup = GetUnitSettings("PLAYER", L["Player Frame"]),
		healerGroup = GetUnitSettings("HEALER", L["Healer Frames"]),
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["Friendly Player Frames"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["Enemy Player Frames"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["Friendly NPC Frames"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["Enemy NPC Frames"]),
		filters = {
			type = "group",
			order = -99,
			name = L["Style Filter"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates; end,
			args = {
				addFilter = {
					order = 1,
					name = L["Add Nameplate Filter"],
					desc = L["Add a nameplate filter."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if match(value, "^[%s%p]-$") then
							return
						end

						if E.global['nameplate']['filters'][value] then
							E:Print(L["Filter already exists!"])
							return
						end

						E.global.nameplate.filters[value] = {
							['enable'] = true,
							['triggers'] = {
								['nameplateType'] = {},
							},
							['actions'] = {
								['color'] = {
									['color'] = {r = 104/255, g = 138/255, b = 217/255}
								},
							},
						}

						UpdateFilterGroup();
						NP:ConfigureAll()
					end,
				},
				removeFilter = {
					order = 2,
					name = L["Remove Nameplate Filter"],
					desc = L["Remove a nameplate filter."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if G.nameplate.filters[value] then
							E.global.nameplate.filters[value].triggers.enable = false;
							E:Print(L["You can't remove a default name from the filter, disabling the name."])
						else
							E.global.nameplate.filters[value] = nil;
							selectedNameplateFilter = nil;
						end
						UpdateFilterGroup();
						NP:ConfigureAll()
					end,
				},
				selectFilter = {
					name = L["Select Nameplate Filter"],
					type = 'select',
					order = 3,
					--guiInline = true,
					get = function(info) return selectedNameplateFilter end,
					set = function(info, value) selectedNameplateFilter = value; UpdateFilterGroup() end,
					values = function()
						local filters = {}
						for filter in pairs(E.global.nameplate.filters) do
							filters[filter] = filter
						end
						return filters
					end,
				},
			},
		},
	},
}
