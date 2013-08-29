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
		set = function(info, value) E.global["nameplate"]['filter'][selectedFilter][ info[#info] ] = value; NP:ForEachPlate("CheckFilter"); NP:UpdateAllPlates(); UpdateFilterGroup() end,		
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
						NP:ForEachPlate("CheckFilter")
						NP:UpdateAllPlates()
					end
				end,
			},
			customScale = {
				type = 'range',
				name = L['Custom Scale'],
				desc = L['Set the scale of the nameplate.'],
				min = 0.67, max = 2, step = 0.01,			
			},
		},	
	}
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "select",
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
			order = 1,
			type = "group",
			name = L["General"],
			disabled = function() return not E.NamePlates; end,
			args = {
				smallPlates = {
					type = "toggle",
					order = 1,
					name = L["Small Plates"],
					desc = L["Adjust nameplate size on smaller mobs to scale down. This will only adjust the health bar width not the actual nameplate hitbox you click on."],
				},		
				combatHide = {
					type = "toggle",
					order = 2,
					name = L["Combat Toggle"],
					desc = L["Toggle the nameplates to be visible outside of combat and visible inside combat."],
					set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:CombatToggle() end,
				},						
				comboPoints = {
					type = "toggle",
					order = 3,
					name = L["Combo Points"],
					desc = L["Display combo points on nameplates."],
				},				
				nonTargetAlpha = {
					type = 'range',
					order = 4,
					name = L['Non-Target Alpha'],
					desc = L['Alpha of nameplates that are not your current target.'],
					min = 0, max = 1, step = 0.01, isPercent = true,
				},
				fontGroup = {
					order = 100,
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
								
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},							
					},
				},	
				reactions = {
					order = 200,
					type = "group",
					name = L["Reaction Coloring"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate.reactions[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						E.db.nameplate.reactions[ info[#info] ] = {}
						local t = E.db.nameplate.reactions[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:UpdateAllPlates()
					end,				
					args = {
						friendlyNPC = {
							type = "color",
							order = 1,
							name = L["Friendly NPC"],
							hasAlpha = false,
						},
						friendlyPlayer = {
							name = L["Friendly Player"],
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
						enemy = {
							name = L["Enemy"],
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
		healthBar = {
			type = "group",
			order = 2,
			name = L["Health Bar"],
			disabled = function() return not E.NamePlates; end,
			get = function(info) return E.db.nameplate.healthBar[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.healthBar[ info[#info] ] = value; NP:UpdateAllPlates() end,			
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
				lowThreshold = {
					type = 'range',
					order = 3,
					name = L['Low Health Threshold'],
					desc = L['Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value.'],
					isPercent = true,
					min = 0, max = 1, step = 0.01, 			
				},
				fontGroup = {
					order = 4,
					type = "group",
					name = L["Fonts"],
					guiInline = true,
					get = function(info) return E.db.nameplate.healthBar.text[ info[#info] ] end,
					set = function(info, value) E.db.nameplate.healthBar.text[ info[#info] ] = value; NP:UpdateAllPlates() end,			
					args = {
						enable = {
							type = "toggle",
							name = L["Enable"],
							order = 1,
						},
						format = {
							type = "select",
							order = 2,
							name = L['Format'],
							values = {
								['CURRENT_MAX_PERCENT'] = L['Current - Max | Percent'],
								['CURRENT_PERCENT'] = L['Current - Percent'],
								['CURRENT_MAX'] = L['Current - Max'],
								['CURRENT'] = L['Current'],
								['PERCENT'] = L['Percent'],
								['DEFICIT'] = L['Deficit'],
							},
						},
					},
				}
			},
		},
		castBar = {
			type = "group",
			order = 3,
			name = L["Cast Bar"],
			disabled = function() return not E.NamePlates; end,
			get = function(info) return E.db.nameplate.castBar[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.castBar[ info[#info] ] = value; NP:UpdateAllPlates() end,			
			args = {
				height = {
					type = "range",
					order = 1,
					name = L["Height"],
					type = "range",
					min = 4, max = 30, step = 1,					
				},
				colors = {
					order = 100,
					type = "group",
					name = L["Colors"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate.castBar[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						E.db.nameplate.castBar[ info[#info] ] = {}
						local t = E.db.nameplate.castBar[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:UpdateAllPlates()
					end,				
					args = {
						color = {
							type = "color",
							order = 1,
							name = L["Can Interrupt"],
							hasAlpha = false,
						},
						noInterrupt = {
							name = "No Interrupt",
							order = 2,
							type = 'color',
							hasAlpha = false,
						},						
					},		
				},				
			},
		},
		raidHealIcon = {
			type = "group",
			order = 5,
			name = L["Raid/Healer Icon"],
			get = function(info) return E.db.nameplate.raidHealIcon[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.raidHealIcon[ info[#info] ] = value; NP:UpdateAllPlates() end,	
			args = {
				markHealers = {
					type = 'toggle',
					order = 1,
					name = L['Healer Icon'],
					desc = L['Display a healer icon over known healers inside battlegrounds or arenas.'],
					set = function(info, value) E.db.nameplate.raidHealIcon[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:UpdateAllPlates() end,
				},			
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					min = 10, max = 200, step = 1,
				},
				attachTo = {
					type = "select",
					order = 3,
					name = L["Attach To"],
					values = positionValues,
				},
				xOffset = {
					type = "range",
					order = 4,
					name = L["X-Offset"],
					min = -150, max = 150, step = 1,
				},
				yOffset = {
					type = "range",
					order = 5,
					name = L["Y-Offset"],
					min = -150, max = 150, step = 1,
				},									
			},	
		},
		auras = {
			type = "group",
			order = 4,
			name = L["Auras"],
			get = function(info) return E.db.nameplate.auras[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.auras[ info[#info] ] = value; NP:UpdateAllPlates() end,	
			args = {
				numAuras = {
					type = "range",
					order = 1,
					name = L["Number of Auras"],
					type = "range",
					min = 2, max = 8, step = 1,		
				},	
				stretchTexture = {
					type = "toggle",
					name = L["Stretch Texture"],
					desc = L["Stretch the icon texture, intended for icons that don't have the same width/height."],
					order = 2,
				},
				showPersonal = {
					order = 3,
					type = "toggle",
					name = L["Show Personal Auras"],
				},					
				additionalFilter = {
					type = "select",
					order = 5,
					name = L['Additional Filter'],
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
					order = 6,
					name = L['Filter Type'],
					values = {
						['BUFFS'] = L['Buffs'],
						['DEBUFFS'] = L['Debuffs']
					},
				},	
				configureButton = {
					order = 7,
					name = L['Configure Selected Filter'],
					type = 'execute',
					width = 'full',
					func = function() E:SetToFilterConfig(E.db.nameplate.auras.additionalFilter) end,
				},	
				fontGroup = {
					order = 100,
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
								
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},							
					},
				},					
			},
		},	
		threat = {
			type = "group",
			order = 6,
			name = L["Threat"],
			get = function(info) return E.db.nameplate.threat[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.threat[ info[#info] ] = value; NP:UpdateAllPlates() end,	
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				scaling = {
					type = 'group',
					name = L['Scaling'],
					guiInline = true,
					order = 2,
					args = {
						goodScale = {
							type = 'range',
							name = L['Good'],
							order = 1,
							min = 0.5, max = 1.5, step = 0.01, isPercent = true,
						},
						badScale = {
							type = 'range',
							name = L['Bad'],
							order = 1,
							min = 0.5, max = 1.5, step = 0.01, isPercent = true,
						},						
					},
				},
				colors = {
					order = 3,
					type = "group",
					name = L["Colors"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate.threat[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						E.db.nameplate.castBar[ info[#info] ] = {}
						local t = E.db.nameplate.threat[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:UpdateAllPlates()
					end,				
					args = {
						goodColor = {
							type = "color",
							order = 1,
							name = L["Good"],
							hasAlpha = false,
						},
						badColor = {
							name = L["Bad"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
						goodTransitionColor = {
							name = L["Good Transition"],
							order = 3,
							type = 'color',
							hasAlpha = false,
						},		
						badTransitionColor = {
							name = L["Bad Transition"],
							order = 4,
							type = 'color',
							hasAlpha = false,
						},								
					},		
				},				
			},
		},
		filters = {
			type = "group",
			order = 200,
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
