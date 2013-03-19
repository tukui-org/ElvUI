local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
			get = function(info) return E.private.nameplate[ info[#info] ] end,
			set = function(info, value) E.private.nameplate[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
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
					min = 4, max = 30, step = 1,						
				},
				nameXOffset = {
					type = "range",
					order = 4,
					name = L["Name X-Offset"],
					min = -50, max = 50, step = 1,
				},
				nameYOffset = {
					type = "range",
					order = 5,
					name = L["Name Y-Offset"],
					min = -50, max = 50, step = 1,
				},		
				nameJustifyH = {
					type = 'select',
					order = 6,
					name = L['Name Alignment'],
					values = {
						['LEFT'] = 'LEFT',
						['RIGHT'] = 'RIGHT',
						['CENTER'] = 'CENTER',
					},
				},
				healthtext = {
					type = "select",
					order = 7,
					name = L["Health Text"],
					desc = L["Toggles health text display"],
					values = {
						['CURRENT_MAX_PERCENT'] = L['Current - Max | Percent'],
						['CURRENT_PERCENT'] = L['Current - Percent'],
						['CURRENT_MAX'] = L['Current - Max'],
						['CURRENT'] = L['Current'],
						['PERCENT'] = L['Percent'],
						['DEFICIT'] = L['Deficit'],
						[''] = NONE,					
					},
				},	
				showlevel = {
					type = "toggle",
					order = 8,
					name = LEVEL,
					desc = L["Display level text on nameplate for nameplates that belong to units that aren't your level."],	
				},		
				combat = {
					type = "toggle",
					order = 9,
					name = L["Combat Toggle"],
					desc = L["Toggles the nameplates off when not in combat."],							
				},	
				markHealers = {
					type = 'toggle',
					order = 10,
					name = L['Healer Icon'],
					desc = L['Display a healer icon over known healers inside battlegrounds or arenas.'],
					set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:UpdateAllPlates() end,
				},
				classIcons = {
					type = "toggle",
					order = 11,
					name = L["Class Icons"],
					desc = L["Display a class icon on nameplates."],
					set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:UpdateAllPlates() end,
				},
				smallPlates = {
					type = "toggle",
					order = 12,
					name = L["Small Plates"],
					desc = L["Adjust nameplate size on smaller mobs to scale down. This will only adjust the health bar width not the actual nameplate hitbox you click on."],
				},				
				comboPoints = {
					type = "toggle",
					order = 13,
					name = L["Combo Points"],
					desc = L["Display combo points on nameplates."],
					set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:ToggleCPoints() end,
				},
				offtank = {
					type = "toggle",
					order = 14,
					name = L["Color Tanked/Loose"],
					desc = L["Depending on your role. If you are a tank then it will color mobs being tanked by the offtank. If you are not a tank then it will color mobs not being tanked. This is not 100% accurate and should only be used as a referance."],
				},				
				lowHealthWarning = {
					type = 'select',
					order = 15,
					name = L['Low Health Warning'],
					desc = L['Color the border of the nameplate yellow when it reaches the threshold point on these types of frames.'],
					values = {
						['PLAYERS'] = L['Players'],
						['ALL'] = ALL,
						['NONE'] = NONE,
					},
				},
				lowHealthWarningThreshold = {
					type = 'range',
					order = 16,
					name = L['Low Health Threshold'],
					desc = L['Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value.'],
					isPercent = true,
					min = 0.2, max = 1, step = 0.01, 			
				},
				bgMult = {
					type = 'range',
					order = 17,
					name = L['Background Multiplier'],
					desc = L['The backdrop of the nameplates color is scaled to match the color of the nameplate by this percentage. Set to zero to have no color in the nameplate backdrop.'],
					isPercent = true,
					min = 0, max = 1, step = 0.01, 						
				},
		
				fontGroup = {
					order = 101,
					type = 'group',
					guiInline = true,
					name = L['Fonts'],
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
							min = 6, max = 22, step = 1,
						},	
						fontOutline = {
							order = 6,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = (not E.isMacClient) and 'MONOCHROME' or nil,
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},	
						auraFont = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 7,
							name = L['Aura'].. ' '..L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						auraFontSize = {
							order = 8,
							name = L['Aura'].. ' '..L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,
						},	
						auraFontOutline = {
							order = 9,
							name = L['Aura'].. ' '..L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = (not E.isMacClient) and 'MONOCHROME' or nil,
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},							
					},
				},				
				auras = {
					order = 100,
					type = "group",
					name = L["Auras"],
					guiInline = true,	
					args = {
						trackauras = {
							type = "toggle",
							order = 1,
							name = L["Personal Auras"],
							desc = L["Always display your personal auras over the nameplate."],
						},
						trackfilter = {
							type = "select",
							order = 2,
							name = L['Filter'],
							desc = L['Select a filter to use. These are imported from the unitframe aura filter.'],
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global['unitframe']['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},	
						filterType = {
							type = "select",
							order = 3,
							name = L['Filter Type'],
							values = {
								['BUFFS'] = L['Buffs'],
								['DEBUFFS'] = L['Debuffs']
							},
						},
						configureButton = {
							order = 4,
							name = L['Configure Selected Filter'],
							type = 'execute',
							width = 'full',
							func = function() E:SetToFilterConfig(E.db.nameplate.trackfilter) end,
						},	
					},
				},
				reactions = {
					order = 200,
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
						tappedcolor = {
							type = "color",
							order = 8,
							name = L["Tagged Color"],
							desc = L["Color of a nameplate that is tagged by another person."],
							hasAlpha = false,								
						},							
					},		
				},				
				threat = {
					order = 300,
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
						offtankcolor = {
							type = "color",
							order = 8,
							name = L["Tanked/Loose Color"],
							desc = L["Depending on your role. If you are a tank then its the color of mobs being tanked not by you by an actual tank. If you are not a tank then it is the color of mobs that are not currently being tanked."],
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
						if E.global['nameplate']['filter'][value] then
							E:Print(L['Filter already exists!'])
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
