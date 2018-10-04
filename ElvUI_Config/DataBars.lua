local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars')

E.Options.args.databars = {
	type = "group",
	name = L["DataBars"],
	childGroups = "tab",
	get = function(info) return E.db.databars[ info[#info] ] end,
	set = function(info, value) E.db.databars[ info[#info] ] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["Setup on-screen display of information bars."],
		},
		spacer = {
			order = 2,
			type = "description",
			name = "",
		},
		experience = {
			order = 5,
			get = function(info) return mod.db.experience[ info[#info] ] end,
			set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperienceDimensions() end,
			type = "group",
			name = XPBAR_LABEL,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:EnableDisable_ExperienceBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideAtMaxLevel = {
					order = 2,
					type = "toggle",
					name = L["Hide At Max Level"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
				},
				hideInVehicle = {
					order = 3,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
				},
				hideInCombat = {
					order = 4,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
				},
				reverseFill = {
					order = 5,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				orientation = {
					order = 6,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 7,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 8,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				font = {
					order = 9,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				textSize = {
					order = 10,
					name = FONT_SIZE,
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 11,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				textFormat = {
					order = 12,
					type = 'select',
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = NONE,
						PERCENT = L["Percent"],
						CUR = L["Current"],
						REM = L["Remaining"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
				},
			},
		},
		reputation = {
			order = 6,
			get = function(info) return mod.db.reputation[ info[#info] ] end,
			set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputationDimensions() end,
			type = "group",
			name = REPUTATION,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:EnableDisable_ReputationBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideInVehicle = {
					order = 2,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end,
				},
				hideInCombat = {
					order = 3,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end,
				},
				reverseFill = {
					order = 4,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				spacer = {
					order = 5,
					type = "description",
					name = " ",
				},
				orientation = {
					order = 6,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 7,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 8,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				font = {
					order = 9,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				textSize = {
					order = 10,
					name = FONT_SIZE,
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 11,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				textFormat = {
					order = 12,
					type = 'select',
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = NONE,
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end,
				},
			},
		},
		honor = {
			order = 7,
			get = function(info) return mod.db.honor[ info[#info] ] end,
			set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:UpdateHonorDimensions() end,
			type = "group",
			name = HONOR,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:EnableDisable_HonorBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideInVehicle = {
					order = 2,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:UpdateHonor() end,
				},
				hideInCombat = {
					order = 3,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:UpdateHonor() end,
				},
				hideOutsidePvP = {
					order = 4,
					type = "toggle",
					name = L["Hide Outside PvP"],
					set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:UpdateHonor() end,
				},
				hideBelowMaxLevel = {
					order = 5,
					type = "toggle",
					name = L["Hide Below Max Level"],
					set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:UpdateHonor() end,
				},
				reverseFill = {
					order = 6,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 8,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 9,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				font = {
					order = 10,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				textSize = {
					order = 11,
					name = FONT_SIZE,
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 12,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				textFormat = {
					order = 13,
					type = 'select',
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = NONE,
						PERCENT = L["Percent"],
						CUR = L["Current"],
						REM = L["Remaining"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.honor[ info[#info] ] = value; mod:UpdateHonor() end,
				},
			},
		},
		azerite = {
			order = 8,
			get = function(info) return mod.db.azerite[ info[#info] ] end,
			set = function(info, value) mod.db.azerite[ info[#info] ] = value; mod:UpdateAzeriteDimensions() end,
			type = "group",
			name = L["Azerite Bar"],
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.azerite[ info[#info] ] = value; mod:EnableDisable_AzeriteBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideInVehicle = {
					order = 3,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.azerite[ info[#info] ] = value; mod:UpdateAzerite() end,
				},
				hideInCombat = {
					order = 4,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.azerite[ info[#info] ] = value; mod:UpdateAzerite() end,
				},
				reverseFill = {
					order = 5,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				orientation = {
					order = 6,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 7,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 8,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				font = {
					order = 9,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				textSize = {
					order = 10,
					name = FONT_SIZE,
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 11,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				textFormat = {
					order = 12,
					type = 'select',
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = NONE,
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.azerite[ info[#info] ] = value; mod:UpdateAzerite() end,
				},
			},
		},
	},
}
