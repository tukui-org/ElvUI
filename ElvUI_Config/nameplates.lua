local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local selectedFilter
local filters

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

local ORDER = 100
local function GetUnitSettings(unit, name)
	local group = {
		type = "group",
		order = ORDER,
		name = name,
		get = function(info) return E.db.nameplate.units[unit][ info[#info] ] end,
		set = function(info, value) E.db.nameplate.units[unit][ info[#info] ] = value; NP:ConfigureAll() end,		
		args = {
			showLevel = {
				order = 1,
				name = L["Display Level"],
				type = "toggle",	
			},
			healthGroup = {
				order = 2,
				name = L["Health"],
				guiInline = true,
				type = "group",
				get = function(info) return E.db.nameplate.units[unit].healthbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplate.units[unit].healthbar[ info[#info] ] = value; NP:ConfigureAll() end,		
				args = {
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
					width = {
						order = 3,
						name = L["Width"],
						type = "range",
						min = 50, max = 200, step = 1,	
					},					
				},			
			},
			powerGroup = {
				order = 3,
				name = L["Power"],
				guiInline = true,
				type = "group",
				get = function(info) return E.db.nameplate.units[unit].powerbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplate.units[unit].powerbar[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplate.units[unit].healthbar.enable end,	
				args = {
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
				},			
			},			
			castGroup = {
				order = 4,
				name = L["Cast Bar"],
				guiInline = true,
				type = "group",
				get = function(info) return E.db.nameplate.units[unit].castbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplate.units[unit].castbar[ info[#info] ] = value; NP:ConfigureAll() end,	
				disabled = function() return not E.db.nameplate.units[unit].healthbar.enable end,		
				args = {
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
				},			
			},	
			buffsGroup = {
				order = 5,
				name = L["Buffs"],
				guiInline = true,
				type = "group",
				get = function(info) return E.db.nameplate.units[unit].buffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplate.units[unit].buffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplate.units[unit].healthbar.enable end,		
				args = {
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",	
						get = function(info) return E.db.nameplate.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplate.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,							
					},
					filtersGroup = {
						name = L["Filters"],
						order = 2,
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
							filter = {
								order = 4,
								type = "select",
								name = L["Filter"],	
								values = function()
									local filters = {}
									filters[''] = NONE
									for filter in pairs(E.global.unitframe['aurafilters']) do
										filters[filter] = filter
									end
									return filters
								end,
							},													
						},
					},
				},			
			},	
			debuffsGroup = {
				order = 6,
				name = L["Debuffs"],
				guiInline = true,
				type = "group",
				get = function(info) return E.db.nameplate.units[unit].debuffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplate.units[unit].debuffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,	
				disabled = function() return not E.db.nameplate.units[unit].healthbar.enable end,	
				args = {
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",	
						get = function(info) return E.db.nameplate.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplate.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,							
					},
					filtersGroup = {
						name = L["Filters"],
						order = 2,
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
							filter = {
								order = 4,
								type = "select",
								name = L["Filter"],	
								values = function()
									local filters = {}
									filters[''] = NONE
									for filter in pairs(E.global.unitframe['aurafilters']) do
										filters[filter] = filter
									end
									return filters
								end,
							},													
						},
					},
				},			
			},									
		},
	}
	
	
	ORDER = ORDER + 100
	return group
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplate[ info[#info] ] end,
	set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:ConfigureAll() end,
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
			get = function(info) return E.private.nameplate[ info[#info] ] end,
			set = function(info, value) E.private.nameplate[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 1,
			type = "group",
			name = L["General"],
			guiInline = true,
			order = 3,
			disabled = function() return not E.NamePlates; end,
			args = {
				threatGroup = {
					order = 150,
					type = "group",
					name = L["Threat"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate.threat[ info[#info] ]
						local d = P.nameplate.threat[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.nameplate[ info[#info] ] = {}
						local t = E.db.nameplate.threat[ info[#info] ]
						t.r, t.g, t.b = r, g, b
					end,
					args = {
						goodColor = {
							type = "color",
							order = 1,
							name = L["Good Color"],
							hasAlpha = false,
						},
						badColor = {
							name = L["Bad Color"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
						goodScale = {
							name = L["Good Scale"],
							order = 3,
							type = 'range',
							get = function(info) return E.db.nameplate.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplate.threat[ info[#info] ] = value; end,	
							min = 0.3, max = 2, step = 0.01,		
							isPercent = true,				
						},
						badScale = {
							name = L["Bad Scale"],
							order = 4,
							type = 'range',
							get = function(info) return E.db.nameplate.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplate.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,		
							isPercent = true,							
						},						
					},
				},	
				fontGroup = {
					order = 100,
					type = 'group',
					guiInline = true,
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
							min = 4, max = 22, step = 1,
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
				castGroup = {
					order = 200,
					type = "group",
					name = L["Cast Bar"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate[ info[#info] ]
						local d = P.nameplate[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.nameplate[ info[#info] ] = {}
						local t = E.db.nameplate[ info[#info] ]
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
					order = 150,
					type = "group",
					name = L["Health Bar"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate.reactions[ info[#info] ]
						local d = P.nameplate.reactions[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.nameplate.reactions[ info[#info] ] = {}
						local t = E.db.nameplate.reactions[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:ForEachPlate("UpdateElement_HealthColor", true)
						NP:ForEachPlate("UpdateElement_Name", true)
					end,
					args = {
						statusbar = {
							order = 0,
							type = "select", 
							dialogControl = 'LSM30_Statusbar',
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
							get = function(info) return E.db.nameplate[ info[#info] ] end,
							set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:ConfigureAll() end,							
						},
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
	},
}
