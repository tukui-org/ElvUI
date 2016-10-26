local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local selectedFilter
local filters

local pairs, type = pairs, type
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

--[[This has not been implemented (yet?)
local function UpdateFilterGroup()
	if not selectedFilter or not E.global['nameplate']['filter'][selectedFilter] then
		E.Options.args.nameplate.args.filters.args.filterGroup = nil
		return
	end

	E.Options.args.nameplate.args.filters.args.filterGroup = {
		type = 'group',
		name = selectedFilter,
		guiInline = true,
		order = -10,
		get = function(info) return E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] end,
		set = function(info, value) E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] = value; NP:ForEachPlate("CheckFilterAndHealers"); NP:UpdateAllPlates(); UpdateFilterGroup() end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
				desc = L["Use this filter."],
			},
			hide = {
				type = 'toggle',
				order = 2,
				name = L["Hide"],
				desc = L["Prevent any nameplate with this unit name from showing."],
			},
			customColor = {
				type = 'toggle',
				order = 3,
				name = L["Custom Color"],
				desc = L["Disable threat coloring for this plate and use the custom color."],
			},
			color = {
				type = 'color',
				order = 4,
				name = L["Color"],
				get = function(info)
					local t = E.global["nameplate"]['filter'][selectedFilter][ info[#info] ]
					if t then
						return t.r, t.g, t.b, t.a
					end
				end,
				set = function(info, r, g, b)
					E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] = {}
					local t = E.global["nameplate"]['filter'][selectedFilter][ info[#info] ]
					if t then
						t.r, t.g, t.b = r, g, b
						UpdateFilterGroup()
						NP:ForEachPlate("CheckFilterAndHealers")
						NP:UpdateAllPlates()
					end
				end,
			},
			customScale = {
				type = 'range',
				name = L["Custom Scale"],
				desc = L["Set the scale of the nameplate."],
				min = 0.67, max = 2, step = 0.01,
			},
		},
	}
end
]]

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
					height = {
						order = 2,
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
							personal = {
								order = 1,
								type = "toggle",
								name = L["Personal Auras"],
							},
							boss = {
								order = 2,
								type = "toggle",
								name = L["Boss Auras"],
							},
							maxDuration = {
								order = 3,
								type = "range",
								name = L["Maximum Duration"],
								min = 5, max = 3000, step = 1,
							},
							-- filter = {
								-- order = 4,
								-- type = "select",
								-- name = L["Filter"],
								-- values = function()
									-- local filters = {}
									-- filters[''] = NONE
									-- for filter in pairs(E.global.unitframe['aurafilters']) do
										-- filters[filter] = filter
									-- end
									-- return filters
								-- end,
							-- },
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
							personal = {
								order = 1,
								type = "toggle",
								name = L["Personal Auras"],
							},
							boss = {
								order = 2,
								type = "toggle",
								name = L["Boss Auras"],
							},
							maxDuration = {
								order = 3,
								type = "range",
								name = L["Maximum Duration"],
								min = 5, max = 3000, step = 1,
							},
							-- filter = {
								-- order = 4,
								-- type = "select",
								-- name = L["Filter"],
								-- values = function()
									-- local filters = {}
									-- filters[''] = NONE
									-- for filter in pairs(E.global.unitframe['aurafilters']) do
										-- filters[filter] = filter
									-- end
									-- return filters
								-- end,
							-- },
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
		group.args.spacer = {
			order = -14,
			type = "description",
			name = ""
		}
		group.args.alwaysShow = {
			order = -13,
			name = L["Use Static Position"],
			desc = L["When enabled the nameplate will stay visible in a locked position."],
			type = "toggle"
		}
		group.args.clickthrough = {
			order = -12,
			name = L["Click Through"],
			type = "toggle",
			set = function(info, value) E.db.nameplates.units[unit][ info[#info] ] = value; NP:TogglePlayerMouse() end,
			disabled = function() return not E.db.nameplates.units[unit].alwaysShow end,
		}
		group.args.combatFade = {
			order = -11,
			name = L["Combat Fade"],
			desc = L["Hide the nameplate unless you are in combat, you are not on full health or have a target you can attack."],
			type = "toggle",
			set = function(info, value) E.db.nameplates.units[unit][ info[#info] ] = value; NP:UpdateVisibility() end,
			disabled = function() return not E.db.nameplates.units[unit].alwaysShow end,
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
		intro = {
			order = 1,
			type = "description",
			name = L["NAMEPLATE_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[ info[#info] ] end,
			set = function(info, value) E.private.nameplates[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
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
			name = L["General Options"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup") end,
		},
		playerShortcut = {
			order = 6,
			type = "execute",
			name = L["Player Frame"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "playerGroup") end,
		},
		healerShortcut = {
			order = 7,
			type = "execute",
			name = L["Healer Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "healerGroup") end,
		},
		spacer2 = {
			order = 8,
			type = "description",
			name = " ",
		},
		friendlyPlayerShortcut = {
			order = 9,
			type = "execute",
			name = L["Friendly Player Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
		},
		enemyPlayerShortcut = {
			order = 10,
			type = "execute",
			name = L["Enemy Player Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
		},
		friendlyNPCShortcut = {
			order = 11,
			type = "execute",
			name = L["Friendly NPC Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " ",
		},
		enemyNPCShortcut = {
			order = 13,
			type = "execute",
			name = L["Enemy NPC Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
		},
		
		generalGroup = {
			order = 20,
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
						useTargetGlow = {
							order = 5,
							type = "toggle",
							name = L["Use Target Glow"],
						},
						useTargetScale = {
							order = 6,
							type = "toggle",
							name = L["Use Target Scale"],
							desc = L["Enable/Disable the scaling of targetted nameplates."],
						},
						targetScale = {
							name = L["Target Scale"],
							desc = L["Scale of the nameplate that is targetted."],
							type = "range",
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
							order = 7,
							disabled = function() return E.db.nameplates.useTargetScale ~= true end,
						},
						nonTargetTransparency = {
							name = L["Non-Target Transparency"],
							desc = L["Set the transparency level of nameplates that are not the target nameplate."],
							type = "range",
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							order = 8,
						},
						lowHealthThreshold = {
							order = 9,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, max = 1, step = 0.01,
						},
						showEnemyCombat = {
							order = 10,
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
							order = 11,
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
							order = 12,
							type = "range",
							name = L["Load Distance"],
							desc = L["Only load nameplates for units within this range."],
							min = 10, max = 100, step = 1,
						},
						clickableWidth = {
							order = 13,
							type = "range",
							name = L["Clickable Width"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 50, max = 200, step = 1,
							set = function(info, value) E.db.nameplates.clickableWidth = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						clickableHeight = {
							order = 14,
							type = "range",
							name = L["Clickable Height"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 10, max = 75, step = 1,
							set = function(info, value) E.db.nameplates.clickableHeight = value; E:StaticPopup_Show("CONFIG_RL") end,
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
						E.db.nameplates[ info[#info] ] = {}
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
						E.db.nameplates[ info[#info] ] = {}
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
						E.db.nameplates.reactions[ info[#info] ] = {}
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
		--[[Not implemented (yet?)
		filters = {
			type = "group",
			order = -100,
			name = L["Filters"],
			disabled = function() return not E.NamePlates; end,
			args = {
				addname = {
					type = 'input',
					order = 1,
					name = L["Add Name"],
					get = function(info) return "" end,
					set = function(info, value)
						if E.global['nameplate']['filter'][value] then
							E:Print(L["Filter already exists!"])
							return
						end

						E.global['nameplate']['filter'][value] = {
							['enable'] = true,
							['hide'] = false,
							['customColor'] = false,
							['customScale'] = 1,
							['color'] = {r = 104/255, g = 138/255, b = 217/255},
						}
						UpdateFilterGroup()
						NP:UpdateAllPlates()
					end,
				},
				deletename = {
					type = 'input',
					order = 2,
					name = L["Remove Name"],
					get = function(info) return "" end,
					set = function(info, value)
						if G['nameplate']['filter'][value] then
							E.global['nameplate']['filter'][value].enable = false;
							E:Print(L["You can't remove a default name from the filter, disabling the name."])
						else
							E.global['nameplate']['filter'][value] = nil;
							E.Options.args.nameplate.args.filters.args.filterGroup = nil;
						end
						UpdateFilterGroup()
						NP:UpdateAllPlates();
					end,
				},
				selectFilter = {
					order = 3,
					type = 'select',
					name = L["Select Filter"],
					get = function(info) return selectedFilter end,
					set = function(info, value) selectedFilter = value; UpdateFilterGroup() end,
					values = function()
						filters = {}
						for filter in pairs(E.global['nameplate']['filter']) do
							filters[filter] = filter
						end
						return filters
					end,
				},
			},
		},
		]]
	},
}
