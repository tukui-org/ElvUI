local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local selectedFilter
local filters

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
		set = function(info, value) E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] = value; NP:UpdateAllPlates(); UpdateFilterGroup() end,		
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
				desc = L['Use this filter.'],
			},
			hide = {
				type = 'toggle',
				order = 2,
				name = L['Hide'],
				desc = L['Prevent any nameplate with this unit name from showing.'],
			},
			customColor = {
				type = 'toggle',
				order = 3,
				name = L['Custom Color'],
				desc = L['Disable threat coloring for this plate and use the custom color.'],			
			},
			color = {
				type = 'color',
				order = 4,
				name = L['Color'],
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
					end
				end,
			},
			customScale = {
				type = 'range',
				name = L['Custom Scale'],
				desc = L['Set the scale of the nameplate.'],
				min = 0.67, max = 2, step = 0.01,
				get = function(info) return E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] end,
				set = function(info, value) E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] = value; UpdateFilterGroup() end,						
			},
		},	
	}
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplate[ info[#info] ] end,
	set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:UpdateAllPlates() end,
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
			get = function(info) return E.global.nameplate[ info[#info] ] end,
			set = function(info, value) E.global.nameplate[ info[#info] ] = value; StaticPopup_Show("GLOBAL_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			guiInline = true,
			disabled = function() return not E.NamePlates; end,
			args = {
				width = {
					type = "range",
					order = 1,
					name = L["Width"],
					desc = L["Controls the width of the nameplate"],
					type = "range",
					min = 50, max = 125, step = 1,		
				},	
				height = {
					type = "range",
					order = 2,
					name = L["Height"],
					desc = L["Controls the height of the nameplate"],
					type = "range",
					min = 4, max = 30, step = 1,					
				},
				cbheight = {
					type = "range",
					order = 3,
					name = L["Castbar Height"],
					desc = L["Controls the height of the nameplate's castbar"],
					type = "range",
					min = 4, max = 30, step = 1,						
				},
				showhealth = {
					type = "toggle",
					order = 4,
					name = L["Health Text"],
					desc = L["Toggles health text display"],
				},	
				showlevel = {
					type = "toggle",
					order = 5,
					name = LEVEL,
					desc = L["Display level text on nameplate for nameplates that belong to units that aren't your level."],	
				},		
				combat = {
					type = "toggle",
					order = 6,
					name = L["Combat Toggle"],
					desc = L["Toggles the nameplates off when not in combat."],							
				},	
				markBGHealers = {
					type = 'toggle',
					order = 7,
					name = L['Healer Icon'],
					desc = L['Display a healer icon over known healers inside battlegrounds.'],
					set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:UpdateAllPlates() end,
				},
				auras = {
					order = 8,
					type = "group",
					name = L["Auras"],
					guiInline = true,	
					args = {
						trackauras = {
							type = "toggle",
							order = 1,
							name = L["Personal Debuffs"],
							desc = L["Display your personal debuffs over the nameplate."],
						},
						trackfilter = {
							type = "select",
							order = 2,
							name = L['Use Filter'],
							desc = L['Select a filter to use. These are imported from the unitframe aura filter.'],
							values = function()
								filters = {}
								filters[''] = ''
								for filter in pairs(E.global['unitframe']['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},
				reactions = {
					order = 9,
					type = "group",
					name = L["Reactions"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						E.db.nameplate[ info[#info] ] = {}
						local t = E.db.nameplate[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:UpdateAllPlates()
					end,				
					args = {
						friendlynpc = {
							type = "color",
							order = 1,
							name = L["Friendly NPC"],
							hasAlpha = false,
						},
						friendlyplayer = {
							type = "color",
							order = 2,
							name = L["Friendly Player"],
							hasAlpha = false,
						},
						neutral = {
							type = "color",
							order = 3,
							name = L["Neutral"],
							hasAlpha = false,
						},
						enemy = {
							type = "color",
							order = 4,
							name = L["Enemy"],
							hasAlpha = false,
						},						
					},		
				},				
				threat = {
					order = 10,
					type = "group",
					name = L["Threat"],
					guiInline = true,
					args = {
						enhancethreat = {
							type = "toggle",
							order = 1,
							name = L["Enhance Threat"],
							desc = L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."],
						},
						goodscale = {
							type = 'range',
							order = 2,
							name = L['Good Scale'],
							desc = L['Set the scale of the nameplate.'],
							min = 0.67, max = 2, step = 0.01,					
						},	
						badscale = {
							type = 'range',
							order = 3,
							name = L['Bad Scale'],
							desc = L['Set the scale of the nameplate.'],
							min = 0.67, max = 2, step = 0.01,					
						},							
						goodcolor = {
							type = "color",
							order = 4,
							name = L["Good Color"],
							desc = L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.nameplate[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.nameplate[ info[#info] ] = {}
								local t = E.db.nameplate[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								NP:UpdateAllPlates()
							end,								
						},		
						badcolor = {
							type = "color",
							order = 5,
							name = L["Bad Color"],
							desc = L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.nameplate[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.nameplate[ info[#info] ] = {}
								local t = E.db.nameplate[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								NP:UpdateAllPlates()
							end,							
						},
						goodtransitioncolor = {
							type = "color",
							order = 6,
							name = L["Good Transition Color"],
							desc = L["This color is displayed when gaining/losing threat, for a tank it would be displayed when gaining threat, for a dps/healer it would be displayed when losing threat"],
							hasAlpha = false,	
							get = function(info)
								local t = E.db.nameplate[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.nameplate[ info[#info] ] = {}
								local t = E.db.nameplate[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								NP:UpdateAllPlates()
							end,							
						},
						badtransitioncolor = {
							type = "color",
							order = 7,
							name = L["Bad Transition Color"],
							desc = L["This color is displayed when gaining/losing threat, for a tank it would be displayed when losing threat, for a dps/healer it would be displayed when gaining threat"],
							hasAlpha = false,	
							get = function(info)
								local t = E.db.nameplate[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.nameplate[ info[#info] ] = {}
								local t = E.db.nameplate[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								NP:UpdateAllPlates()
							end,							
						},						
					},
				},				
			},
		},
		filters = {
			type = "group",
			order = 5,
			name = L["Filters"],
			disabled = function() return not E.NamePlates; end,
			args = {
				addname = {
					type = 'input',
					order = 1,
					name = L['Add Name'],
					get = function(info) return "" end,
					set = function(info, value) 
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
					name = L['Remove Name'],
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
					name = L['Select Filter'],
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
