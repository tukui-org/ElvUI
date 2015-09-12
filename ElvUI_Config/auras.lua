local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB
local A = E:GetModule('Auras')

local auraOptions = {
	size = {
		type = 'range',
		name = L["Size"],
		desc = L["Set the size of the individual auras."],
		min = 16, max = 60, step = 2,
		order = 1,
	},
	growthDirection = {
		type = 'select',
		order = 2,
		name = L["Growth Direction"],
		desc = L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."],
		values = {
			DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
			DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
			UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
			UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
			RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
			RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
			LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
			LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
		},
	},
	wrapAfter = {
		type = 'range',
		order = 3,
		name = L["Wrap After"],
		desc = L["Begin a new row or column after this many auras."],
		min = 1, max = 32, step = 1,
	},
	maxWraps = {
		name = L["Max Wraps"],
		order = 4,
		desc = L["Limit the number of rows or columns."],
		type = 'range',
		min = 1, max = 32, step = 1,
	},
	horizontalSpacing = {
		order = 5,
		type = 'range',
		name = L["Horizontal Spacing"],
		min = 0, max = 50, step = 1,
	},
	verticalSpacing = {
		order = 6,
		type = 'range',
		name = L["Vertical Spacing"],
		min = 0, max = 50, step = 1,
	},
	sortMethod = {
		order = 7,
		name = L["Sort Method"],
		desc = L["Defines how the group is sorted."],
		type = 'select',
		values = {
			['INDEX'] = L["Index"],
			['TIME'] = L["Time"],
			['NAME'] = L["Name"],
		},
	},
	sortDir = {
		order = 8,
		name = L["Sort Direction"],
		desc = L["Defines the sort order of the selected sort method."],
		type = 'select',
		values = {
			['+'] = L["Ascending"],
			['-'] = L["Descending"],
		},
	},
	seperateOwn = {
		order = 9,
		name = L["Seperate"],
		desc = L["Indicate whether buffs you cast yourself should be separated before or after."],
		type = 'select',
		values = {
			[-1] = L["Other's First"],
			[0] = L["No Sorting"],
			[1] = L["Your Auras First"],
		},
	},
}

E.Options.args.auras = {
	type = 'group',
	name = BUFFOPTIONS_LABEL,
	childGroups = "select",
	get = function(info) return E.db.auras[ info[#info] ] end,
	set = function(info, value) E.db.auras[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerBuffs); A:UpdateHeader(ElvUIPlayerDebuffs) end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L["AURAS_DESC"],
		},
		enable = {
			order = 2,
			type = 'toggle',
			name = L["Enable"],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value)
				E.private.auras[ info[#info] ] = value;
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		disableBlizzard = {
			order = 3,
			type = 'toggle',
			name = L["Disabled Blizzard"],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value)
				E.private.auras[ info[#info] ] = value;
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		general = {
			order = 5,
			type = 'group',
			name = L["General"],
			args = {
				fadeThreshold = {
					type = 'range',
					name = L["Fade Threshold"],
					desc = L["Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable."],
					min = -1, max = 30, step = 1,
					order = 1,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 2,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 3,
					name = L["Font Size"],
					type = "range",
					min = 4, max = 22, step = 1,
				},
				fontOutline = {
					order = 4,
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
				timeXOffset = {
					order = 5,
					name = L["Time xOffset"],
					type = 'range',
					min = -60, max = 60, step = 1,
				},
				timeYOffset = {
					order = 6,
					name = L["Time yOffset"],
					type = 'range',
					min = -60, max = 60, step = 1,
				},
				countXOffset = {
					order = 7,
					name = L["Count xOffset"],
					type = 'range',
					min = -60, max = 60, step = 1,
				},
				countYOffset = {
					order = 8,
					name = L["Count yOffset"],
					type = 'range',
					min = -60, max = 60, step = 1,
				},
				masque = {
					order = 9,
					type = "group",
					guiInline = true,
					name = L["Masque Support"],
					get = function(info) return E.private.auras.masque[info[#info]] end,
					set = function(info, value) E.private.auras.masque[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return not E.private.auras.enable end,
					args = {
						buffs = {
							order = 1,
							type = "toggle",
							name = L["Buffs"],
							desc = L["Allow Masque to handle the skinning of this element."],
						},
						debuffs = {
							order = 1,
							type = "toggle",
							name = L["Debuffs"],
							desc = L["Allow Masque to handle the skinning of this element."],
						},
						consolidatedBuffs = {
							order = 1,
							type = "toggle",
							name = L["Consolidated Buffs"],
							desc = L["Allow Masque to handle the skinning of this element."],
						},
					},
				},
			},
		},
		consolidatedBuffs = {
			order = 9,
			type = 'group',
			name = L["Consolidated Buffs"],
			disabled = function() return (E.private.general.minimap.enable ~= true or E.private.auras.disableBlizzard ~= true) end,
			get = function(info) return E.db.auras.consolidatedBuffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.consolidatedBuffs[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
			args = {
				enable = {
					order = 1,
					type = 'toggle',
					name = L["Enable"],
					set = function(info, value)
						E.db.auras.consolidatedBuffs[ info[#info] ] = value
						E:GetModule('Minimap'):UpdateSettings()
						A:UpdateHeader(ElvUIPlayerBuffs)
					end,
					desc = L["Display the consolidated buffs bar."],
				},
				filter = {
					order = 2,
					name = L["Filter Consolidated"],
					desc = L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."],
					type = 'toggle',
				},
				durations = {
					order = 3,
					type = 'toggle',
					name = L["Remaining Time"]
				},
				reverseStyle = {
					order = 4,
					type = 'toggle',
					name = L["Reverse Style"],
					desc = L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."],
				},
				position = {
					order = 5,
					type = 'select',
					name = L["Position"],
					set = function(info, value) E.db.auras.consolidatedBuffs[ info[#info] ] = value; E:StaticPopup_Show('CONFIG_RL') end,
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
					}
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 6,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 7,
					name = L["Font Size"],
					type = "range",
					min = 4, max = 22, step = 1,
				},
				fontOutline = {
					order = 8,
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
		buffs = {
			order = 10,
			type = 'group',
			name = L["Buffs"],
			get = function(info) return E.db.auras.buffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.buffs[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerBuffs) end,
			args = auraOptions,
		},
		debuffs = {
			order = 20,
			type = 'group',
			name = L["Debuffs"],
			get = function(info) return E.db.auras.debuffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.debuffs[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerDebuffs) end,
			args = auraOptions,
		},
	},
}