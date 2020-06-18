local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local A = E:GetModule('Auras')
local ACH = E.Libs.ACH

local format = format
-- GLOBALS: ElvUIPlayerBuffs, ElvUIPlayerDebuffs

local function GetAuraOptions()
	local auraOptions = {
		size = {
			order = 1,
			type = 'range',
			name = L["Size"],
			desc = L["Set the size of the individual auras."],
			min = 16, max = 60, step = 2,
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
			order = 4,
			type = 'select',
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
			order = 5,
			type = 'range',
			name = L["Wrap After"],
			desc = L["Begin a new row or column after this many auras."],
			min = 1, max = 32, step = 1,
		},
		maxWraps = {
			order = 6,
			name = L["Max Wraps"],
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
	name = L["BUFFOPTIONS_LABEL"],
	childGroups = "tab",
	order = 2,
	get = function(info) return E.private.auras[info[#info]] end,
	set = function(info, value)
		E.private.auras[info[#info]] = value;
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	args = {
		intro = ACH:Description(L["AURAS_DESC"], 0),
		enable = {
			order = 1,
			type = 'toggle',
			name = L["Enable"],
		},
		disableBlizzard = {
			order = 2,
			type = 'toggle',
			name = L["Disabled Blizzard"],
		},
		buffsHeader = {
			order = 3,
			type = 'toggle',
			name = L["Buffs"],
		},
		debuffsHeader = {
			order = 4,
			type = 'toggle',
			name = L["Debuffs"],
		},
		general = {
			order = 5,
			type = 'group',
			name = L["General"],
			get = function(info) return E.db.auras[info[#info]] end,
			set = function(info, value) E.db.auras[info[#info]] = value; A:UpdateHeader(A.BuffFrame); A:UpdateHeader(A.DebuffFrame) end,
			args = {
				fadeThreshold = {
					order = 1,
					type = 'range',
					name = L["Fade Threshold"],
					desc = L["Threshold before the icon will fade out and back in. Set to -1 to disable."],
					min = -1, max = 30, step = 1,
				},
				font = {
					order = 2,
					type = "select", dialogControl = 'LSM30_Font',
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				showDuration = {
					order = 3,
					type = 'toggle',
					name = L["Duration Enable"],
				},
				fontOutline = {
					order = 4,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = C.Values.FontFlags,
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
				statusBar = {
					order = 9,
					type = 'group',
					name = L["Statusbar"],
					guiInline = true,
					args = {
						barShow = {
							order = 0,
							type = 'toggle',
							name = L["Enable"],
						},
						barNoDuration = {
							order = 0,
							type = 'toggle',
							name = L["No Duration"],
						},
						barTexture = {
							order = 3,
							type = "select", dialogControl = 'LSM30_Statusbar',
							name = L["Texture"],
							values = _G.AceGUIWidgetLSMlists.statusbar,
						},
						barColor = {
							type = 'color',
							order = 4,
							name = L.COLOR,
							hasAlpha = false,
							disabled = function() return not E.db.auras.barShow or (E.db.auras.barColorGradient or not E.db.auras.barShow) end,
							get = function(info)
								local t = E.db.auras.barColor
								local d = P.auras.barColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b)
								local t = E.db.auras.barColor
								t.r, t.g, t.b = r, g, b
							end,
						},
						barColorGradient = {
							order = 5,
							type = 'toggle',
							name = L["Color by Value"],
							disabled = function() return not E.db.auras.barShow end,
						},
						barWidth = {
							order = 6,
							type = 'range',
							name = L["Width"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.auras.barShow end,
						},
						barHeight = {
							order = 7,
							type = 'range',
							name = L["Height"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.auras.barShow end,
						},
						barSpacing = {
							order = 8,
							type = 'range',
							name = L["Spacing"],
							min = -10, max = 10, step = 1,
							disabled = function() return not E.db.auras.barShow end,
						},
						barPosition = {
							order = 9,
							type = 'select',
							name = L["Position"],
							disabled = function() return not E.db.auras.barShow end,
							values = {
								['TOP'] = L["Top"],
								['BOTTOM'] = L["Bottom"],
								['LEFT'] = L["Left"],
								['RIGHT'] = L["Right"],
							},
						},
					},
				},
				masque = {
					order = 20,
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
			get = function(info) return E.db.auras.buffs[info[#info]] end,
			set = function(info, value) E.db.auras.buffs[info[#info]] = value; A:UpdateHeader(A.BuffFrame) end,
			disabled = function() return not E.private.auras.buffsHeader end,
			args = GetAuraOptions(),
		},
		debuffs = {
			order = 20,
			type = 'group',
			name = L["Debuffs"],
			get = function(info) return E.db.auras.debuffs[info[#info]] end,
			set = function(info, value) E.db.auras.debuffs[info[#info]] = value; A:UpdateHeader(A.DebuffFrame) end,
			disabled = function() return not E.private.auras.debuffsHeader end,
			args = GetAuraOptions(),
		},
	},
}
