local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB
local A = E:GetModule('Auras')

local format = string.format

-- GLOBALS: ElvUIPlayerBuffs, ElvUIPlayerDebuffs

local function GetAuraOptions(headerName)
	local auraOptions = {
		header = {
			order = 0,
			type = "header",
			name = headerName,
		},
		size = {
			type = 'range',
			name = L["Size"],
			desc = L["Set the size of the individual auras."],
			min = 16, max = 60, step = 2,
			order = 1,
		},
		durationFontSize = {
			order = 2,
			type = "range",
			name = L["Duration Font Size"],
			min = 4, max = 212, step = 1,
		},
		countFontSize = {
			order = 3,
			type = "range",
			name = L["Count Font Size"],
			min = 4, max = 212, step = 1,
		},
		growthDirection = {
			type = 'select',
			order = 4,
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
			order = 5,
			name = L["Wrap After"],
			desc = L["Begin a new row or column after this many auras."],
			min = 1, max = 32, step = 1,
		},
		maxWraps = {
			name = L["Max Wraps"],
			order = 6,
			desc = L["Limit the number of rows or columns."],
			type = 'range',
			min = 1, max = 32, step = 1,
		},
		horizontalSpacing = {
			order = 7,
			type = 'range',
			name = L["Horizontal Spacing"],
			min = 0, max = 50, step = 1,
		},
		verticalSpacing = {
			order = 8,
			type = 'range',
			name = L["Vertical Spacing"],
			min = 0, max = 50, step = 1,
		},
		sortMethod = {
			order = 9,
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
			order = 10,
			name = L["Sort Direction"],
			desc = L["Defines the sort order of the selected sort method."],
			type = 'select',
			values = {
				['+'] = L["Ascending"],
				['-'] = L["Descending"],
			},
		},
		seperateOwn = {
			order = 11,
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

	return auraOptions
end

E.Options.args.auras = {
	type = 'group',
	name = BUFFOPTIONS_LABEL,
	childGroups = "tab",
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
				header = {
					order = 0,
					type = "header",
					name = L["General"],
				},
				fadeThreshold = {
					type = 'range',
					name = L["Fade Threshold"],
					desc = L["Threshold before the icon will fade out and back in. Set to -1 to disable."],
					min = -1, max = 30, step = 1,
					order = 1,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 2,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontOutline = {
					order = 4,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = NONE,
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
					},
				},
			},
		},
		buffs = {
			order = 15,
			type = 'group',
			name = L["Buffs"],
			get = function(info) return E.db.auras.buffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.buffs[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerBuffs) end,
			args = GetAuraOptions(L["Buffs"]),
		},
		debuffs = {
			order = 20,
			type = 'group',
			name = L["Debuffs"],
			get = function(info) return E.db.auras.debuffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.debuffs[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerDebuffs) end,
			args = GetAuraOptions(L["Debuffs"]),
		},
	},
}
