local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB
local A = E:GetModule('Auras')

E.Options.args.auras = {
	type = 'group',
	name = BUFFOPTIONS_LABEL,
	get = function(info) return E.db.auras[ info[#info] ] end,
	set = function(info, value) E.db.auras[ info[#info] ] = value; A:UpdateAllHeaders() end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L['AURAS_DESC'],
		},
		enable = {
			order = 2,
			type = 'toggle',
			name = L['Enable'],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value) 
				E.private.auras[ info[#info] ] = value; 
				E:StaticPopup_Show("PRIVATE_RL")
			end,		
		},	
		general = {
			order = 5,
			type = 'group',
			guiInline = true,
			name = L['General'],
			args = {
				size = {
					type = 'range',
					name = L['Size'],
					desc = L['Set the size of the individual auras.'],
					min = 16, max = 30, step = 2,
					get = function(info) return E.private.auras[ info[#info] ] end,
					set = function(info, value) 
						E.private.auras[ info[#info] ] = value; 
						E:StaticPopup_Show("PRIVATE_RL")
					end,		
					order = 1,
				},
				wrapAfter = {
					type = 'range',
					name = L['Wrap After'],
					desc = L['Begin a new row or column after this many auras.'],
					min = 1, max = 40, step = 1,
					order = 2,
				},		
				fadeThreshold = {
					type = 'range',
					name = L["Fade Threshold"],
					desc = L['Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable.'],
					min = -1, max = 30, step = 1,
					order = 3,
				},	
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
			},
		},	
		consolidatedBuffs = {
			order = 9,
			type = 'group',
			guiInline = true,
			name = L['Consolidated Buffs'],	
			disabled = function() return not E.private.general.minimap.enable end,				
			get = function(info) return E.db.auras.consolidatedBuffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.consolidatedBuffs[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,			
			args = {
				enable = {
					order = 1,
					type = 'toggle',
					name = L['Enable'],
					set = function(info, value) 
						E.db.auras.consolidatedBuffs[ info[#info] ] = value
						E:GetModule('Minimap'):UpdateSettings()
						A:UpdateAllHeaders()
					end,	
					desc = L['Display the consolidated buffs bar.'],
				},
				filter = {
					order = 2,
					name = L['Filter Consolidated'],
					desc = L['Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading.'],
					type = 'toggle',					
				},
				durations = {
					order = 3,
					type = 'toggle',
					name = L['Remaining Time']
				},
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
			},
		},			
		buffs = {
			order = 10,
			type = 'group',
			guiInline = true,
			name = L['Buffs'],
			get = function(info) return E.db.auras.buffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.buffs[ info[#info] ] = value; A:UpdateAllHeaders() end,			
			args = {
				sortMethod = {
					name = L['Sort Method'],
					desc = L['Defines how the group is sorted.'],
					type = 'select',
					values = {
						['INDEX'] = L['Index'],
						['TIME'] = L['Time'],
						['NAME'] = L['Name'],
					},
				},
				sortDir = {
					name = L['Sort Direction'],
					desc = L['Defines the sort order of the selected sort method.'],
					type = 'select',
					values = {
						['+'] = '+',
						['-'] = '-',
					},				
				},
				maxWraps = {
					name = L['Max Wraps'],
					desc = L['Limit the number of rows or columns.'],
					type = 'range',
					min = 0, max = 3, step = 1,
				},
				seperateOwn = {
					name = L['Seperate'],
					desc = L['Indicate whether buffs you cast yourself should be separated before or after.'],
					type = 'select',
					values = {
						[-1] = L["Other's First"],
						[0] = L['No Sorting'],
						[1] = L['Your Auras First'],
					},
					order = -1,
				},
			},
		},	
		debuffs = {
			order = 20,
			type = 'group',
			guiInline = true,
			name = L['Debuffs'],
			get = function(info) return E.db.auras.debuffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.debuffs[ info[#info] ] = value; A:UpdateAllHeaders() end,				
			args = {
				sortMethod = {
					name = L['Sort Method'],
					desc = L['Defines how the group is sorted.'],
					type = 'select',
					values = {
						['INDEX'] = L['Index'],
						['TIME'] = L['Time'],
						['NAME'] = L['Name'],
					},
				},
				sortDir = {
					name = L['Sort Direction'],
					desc = L['Defines the sort order of the selected sort method.'],
					type = 'select',
					values = {
						['+'] = '+',
						['-'] = '-',
					},				
				},
				maxWraps = {
					name = L['Max Wraps'],
					desc = L['Limit the number of rows or columns.'],
					type = 'range',
					min = 0, max = 3, step = 1,
				},
			},
		},				
	},
}