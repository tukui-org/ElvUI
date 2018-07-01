local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB

E.Options.args.cooldown = {
	type = 'group',
	name = L["Cooldowns"],
	childGroups = "tab",
	get = function(info) return E.db.cooldown[ info[#info] ] end,
	set = function(info, value) E.db.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('global'); end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L["COOLDOWN_DESC"],
		},
		enable = {
			type = "toggle",
			order = 2,
			name = L["Enable"],
			desc = L["Display cooldown text on anything with the cooldown spiral."]
		},
		main = {
			type = "group",
			order = 3,
			name = L["Cooldown Text"],
			get = function(info)
				local t = E.db.cooldown[ info[#info] ]
				local d = P.cooldown[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local t = E.db.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				E:UpdateCooldownSettings('global');
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Cooldown Text"],
				},
				threshold = {
					type = 'range',
					order = 3,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					get = function(info) return E.db.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('global'); end,
				},
				expiringColor = {
					type = 'color',
					order = 4,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
				},
				secondsColor = {
					type = 'color',
					order = 5,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
				},
				minutesColor = {
					type = 'color',
					order = 6,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
				},
				hoursColor = {
					type = 'color',
					order = 7,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
				},
				daysColor = {
					type = 'color',
					order = 8,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
				},
			},
		},
		auras = {
			type = "group",
			order = 4,
			name = BUFFOPTIONS_LABEL,
			get = function(info)
				local t = E.db.auras.cooldown[ info[#info] ]
				local d = P.auras.cooldown[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
			end,
			set = function(info, r, g, b)
				local t = E.db.auras.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b;
				E:UpdateCooldownSettings('auras');
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = BUFFOPTIONS_LABEL,
				},
				override = {
					type = "toggle",
					order = 2,
					name = L["Use Override"],
					desc = L["This will override the global cooldown settings."],
					get = function(info) return E.db.auras.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.auras.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('auras'); end,
				},
				reverse = {
					type = "toggle",
					order = 3,
					name = L["Reverse Toggle"],
					desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
					get = function(info) return E.db.auras.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.auras.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('auras'); end,
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = "",
				},
				threshold = {
					type = 'range',
					order = 5,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					disabled = function() return not E.db.auras.cooldown.override end,
					get = function(info) return E.db.auras.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.auras.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('auras'); end,
				},
				expiringColor = {
					type = 'color',
					order = 6,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
					disabled = function() return not E.db.auras.cooldown.override end,
				},
				secondsColor = {
					type = 'color',
					order = 7,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
					disabled = function() return not E.db.auras.cooldown.override end,
				},
				minutesColor = {
					type = 'color',
					order = 8,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
					disabled = function() return not E.db.auras.cooldown.override end,
				},
				hoursColor = {
					type = 'color',
					order = 9,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
					disabled = function() return not E.db.auras.cooldown.override end,
				},
				daysColor = {
					type = 'color',
					order = 10,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
					disabled = function() return not E.db.auras.cooldown.override end,
				},
			},
		},
		bags = {
			type = "group",
			order = 5,
			name = L["Bags"],
			get = function(info)
				local t = E.db.bags.cooldown[ info[#info] ]
				local d = P.bags.cooldown[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
			end,
			set = function(info, r, g, b)
				local t = E.db.bags.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b;
				E:UpdateCooldownSettings('bags');
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Bags"],
				},
				override = {
					type = "toggle",
					order = 2,
					name = L["Use Override"],
					desc = L["This will override the global cooldown settings."],
					get = function(info) return E.db.bags.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.bags.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('bags'); end,
				},
				reverse = {
					type = "toggle",
					order = 3,
					name = L["Reverse Toggle"],
					desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
					get = function(info) return E.db.bags.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.bags.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('bags'); end,
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = "",
				},
				threshold = {
					type = 'range',
					order = 5,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					disabled = function() return not E.db.bags.cooldown.override end,
					get = function(info) return E.db.bags.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.bags.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('bags'); end,
				},
				expiringColor = {
					type = 'color',
					order = 6,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
					disabled = function() return not E.db.bags.cooldown.override end,
				},
				secondsColor = {
					type = 'color',
					order = 7,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
					disabled = function() return not E.db.bags.cooldown.override end,
				},
				minutesColor = {
					type = 'color',
					order = 8,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
					disabled = function() return not E.db.bags.cooldown.override end,
				},
				hoursColor = {
					type = 'color',
					order = 9,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
					disabled = function() return not E.db.bags.cooldown.override end,
				},
				daysColor = {
					type = 'color',
					order = 10,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
					disabled = function() return not E.db.bags.cooldown.override end,
				},
			},
		},
		nameplates = {
			type = "group",
			order = 6,
			name = L["NamePlates"],
			get = function(info)
				local t = E.db.nameplates.cooldown[ info[#info] ]
				local d = P.nameplates.cooldown[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
			end,
			set = function(info, r, g, b)
				local t = E.db.nameplates.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b;
				E:UpdateCooldownSettings('nameplates');
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["NamePlates"],
				},
				override = {
					type = "toggle",
					order = 2,
					name = L["Use Override"],
					desc = L["This will override the global cooldown settings."],
					get = function(info) return E.db.nameplates.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.nameplates.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('nameplates'); end,
				},
				reverse = {
					type = "toggle",
					order = 3,
					name = L["Reverse Toggle"],
					desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
					get = function(info) return E.db.nameplates.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.nameplates.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('nameplates'); end,
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = "",
				},
				threshold = {
					type = 'range',
					order = 5,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					disabled = function() return not E.db.nameplates.cooldown.override end,
					get = function(info) return E.db.nameplates.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.nameplates.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('nameplates'); end,
				},
				expiringColor = {
					type = 'color',
					order = 6,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
					disabled = function() return not E.db.nameplates.cooldown.override end,
				},
				secondsColor = {
					type = 'color',
					order = 7,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
					disabled = function() return not E.db.nameplates.cooldown.override end,
				},
				minutesColor = {
					type = 'color',
					order = 8,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
					disabled = function() return not E.db.nameplates.cooldown.override end,
				},
				hoursColor = {
					type = 'color',
					order = 9,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
					disabled = function() return not E.db.nameplates.cooldown.override end,
				},
				daysColor = {
					type = 'color',
					order = 10,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
					disabled = function() return not E.db.nameplates.cooldown.override end,
				},
			},
		},
		unitframe = {
			type = "group",
			order = 7,
			name = L["UnitFrames"],
			get = function(info)
				local t = E.db.unitframe.cooldown[ info[#info] ]
				local d = P.unitframe.cooldown[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
			end,
			set = function(info, r, g, b)
				local t = E.db.unitframe.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b;
				E:UpdateCooldownSettings('unitframe');
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["UnitFrames"],
				},
				override = {
					type = "toggle",
					order = 2,
					name = L["Use Override"],
					desc = L["This will override the global cooldown settings."],
					get = function(info) return E.db.unitframe.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('unitframe'); end,
				},
				reverse = {
					type = "toggle",
					order = 3,
					name = L["Reverse Toggle"],
					desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
					get = function(info) return E.db.unitframe.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('unitframe'); end,
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = "",
				},
				threshold = {
					type = 'range',
					order = 5,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					disabled = function() return not E.db.unitframe.cooldown.override end,
					get = function(info) return E.db.unitframe.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.cooldown[ info[#info] ] = value; E:UpdateCooldownSettings('unitframe'); end,
				},
				expiringColor = {
					type = 'color',
					order = 6,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
					disabled = function() return not E.db.unitframe.cooldown.override end,
				},
				secondsColor = {
					type = 'color',
					order = 7,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
					disabled = function() return not E.db.unitframe.cooldown.override end,
				},
				minutesColor = {
					type = 'color',
					order = 8,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
					disabled = function() return not E.db.unitframe.cooldown.override end,
				},
				hoursColor = {
					type = 'color',
					order = 9,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
					disabled = function() return not E.db.unitframe.cooldown.override end,
				},
				daysColor = {
					type = 'color',
					order = 10,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
					disabled = function() return not E.db.unitframe.cooldown.override end,
				},
			},
		},
	},
}