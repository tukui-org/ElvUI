local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local ACH = E.Libs.ACH

local pairs = pairs

-- GLOBALS: AceGUIWidgetLSMlists

local function profile(db)
	return (db == 'global' and E.db.cooldown) or E.db[db].cooldown
end

local function private(db)
	return (db == 'global' and P.cooldown) or P[db].cooldown
end

local function group(order, db, label)
	E.Options.args.cooldown.args[db] = {
		type = "group",
		order = order,
		name = label,
		get = function(info)
			local t = (profile(db))[info[#info]]
			local d = (private(db))[info[#info]]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
		end,
		set = function(info, r, g, b)
			local t = (profile(db))[info[#info]]
			t.r, t.g, t.b = r, g, b;
			E:UpdateCooldownSettings(db);
		end,
		args = {
			reverse = {
				type = "toggle",
				order = 2,
				name = L["Reverse Toggle"],
				desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
				get = function(info) return (profile(db))[info[#info]] end,
				set = function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end,
			},
			hideBlizzard = {
				type = "toggle",
				order = 3,
				name = L["Force Hide Blizzard Text"],
				desc = L["This option will force hide Blizzard's cooldown text if it is enabled at [Interface > ActionBars > Show Numbers on Cooldown]."],
				get = function(info) return (profile(db))[info[#info]] end,
				set = function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end,
				disabled = function()
					if db == "global" then
						return E.db.cooldown.enable
					else
						return (E.db.cooldown.enable and not profile(db).reverse) or (not E.db.cooldown.enable and profile(db).reverse)
					end
				end,
			},
			secondsGroup = {
				order = 5,
				type = "group",
				name = L["Text Threshold"],
				guiInline = true,
				get = function(info) return (profile(db))[info[#info]] end,
				set = function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end,
				disabled = function() return not (profile(db)).checkSeconds end,
				args = {
					checkSeconds = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L["This will override the global cooldown settings."],
						disabled = E.noop,
					},
					mmssThreshold = {
						order = 2,
						type = 'range',
						name = L["MM:SS Threshold"],
						desc = L["Threshold (in seconds) before text is shown in the MM:SS format. Set to -1 to never change to this format."],
						min = -1, max = 10800, step = 1,
					},
					hhmmThreshold = {
						order = 3,
						type = 'range',
						name = L["HH:MM Threshold"],
						desc = L["Threshold (in minutes) before text is shown in the HH:MM format. Set to -1 to never change to this format."],
						min = -1, max = 1440, step = 1,
					},
				}
			},
			colorGroup = {
				order = 10,
				type = "group",
				name = L["Color Override"],
				guiInline = true,
				args = {
					override = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L["This will override the global cooldown settings."],
						get = function(info) return (profile(db))[info[#info]] end,
						set = function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end,
					},
					threshold = {
						type = 'range',
						order = 2,
						name = L["Low Threshold"],
						desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
						min = -1, max = 20, step = 1,
						disabled = function() return not (profile(db)).override end,
						get = function(info) return (profile(db))[info[#info]] end,
						set = function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end,
					},
					spacer1 = ACH:Header(L["Threshold Colors"], 3),
					expiringColor = {
						type = 'color',
						order = 5,
						name = L["Expiring"],
						desc = L["Color when the text is about to expire"],
						disabled = function() return not (profile(db)).override end,
					},
					secondsColor = {
						type = 'color',
						order = 6,
						name = L["Seconds"],
						desc = L["Color when the text is in the seconds format."],
						disabled = function() return not (profile(db)).override end,
					},
					minutesColor = {
						type = 'color',
						order = 7,
						name = L["Minutes"],
						desc = L["Color when the text is in the minutes format."],
						disabled = function() return not (profile(db)).override end,
					},
					hoursColor = {
						type = 'color',
						order = 8,
						name = L["Hours"],
						desc = L["Color when the text is in the hours format."],
						disabled = function() return not (profile(db)).override end,
					},
					daysColor = {
						type = 'color',
						order = 9,
						name = L["Days"],
						desc = L["Color when the text is in the days format."],
						disabled = function() return not (profile(db)).override end,
					},
					mmssColor = {
						type = 'color',
						order = 10,
						name = L["MM:SS"],
						disabled = function() return not (profile(db)).override end,
					},
					hhmmColor = {
						type = 'color',
						order = 11,
						name = L["HH:MM"],
						disabled = function() return not (profile(db)).override end,
					},
					spacer3 = ACH:Header(L["Time Indicator Colors"], 12),
					useIndicatorColor = {
						type = "toggle",
						order = 13,
						name = L["Use Indicator Color"],
						get = function(info) return (profile(db))[info[#info]] end,
						set = function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end,
						disabled = function() return not (profile(db)).override end,
					},
					spacer4 = ACH:Spacer(14),
					expireIndicator = {
						type = 'color',
						order = 15,
						name = L["Expiring"],
						desc = L["Color when the text is about to expire"],
						disabled = function() return not (profile(db)).override end,
					},
					secondsIndicator = {
						type = 'color',
						order = 16,
						name = L["Seconds"],
						desc = L["Color when the text is in the seconds format."],
						disabled = function() return not (profile(db)).override end,
					},
					minutesIndicator = {
						type = 'color',
						order = 17,
						name = L["Minutes"],
						desc = L["Color when the text is in the minutes format."],
						disabled = function() return not (profile(db)).override end,
					},
					hoursIndicator = {
						type = 'color',
						order = 18,
						name = L["Hours"],
						desc = L["Color when the text is in the hours format."],
						disabled = function() return not (profile(db)).override end,
					},
					daysIndicator = {
						type = 'color',
						order = 19,
						name = L["Days"],
						desc = L["Color when the text is in the days format."],
						disabled = function() return not (profile(db)).override end,
					},
					hhmmColorIndicator = {
						type = 'color',
						order = 20,
						name = L["MM:SS"],
						disabled = function() return not (profile(db)).override end,
					},
					mmssColorIndicator = {
						type = 'color',
						order = 21,
						name = L["HH:MM"],
						disabled = function() return not (profile(db)).override end,
					},
				}
			},
			fontGroup = {
				order = 20, -- keep this at the bottom
				type = "group",
				name = L["Fonts"],
				guiInline = true,
				get = function(info) return (profile(db)).fonts[info[#info]] end,
				set = function(info, value) (profile(db)).fonts[info[#info]] = value; E:UpdateCooldownSettings(db); end,
				disabled = function() return not (profile(db)).fonts.enable end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L["This will override the global cooldown settings."],
						disabled = E.noop,
					},
					fontSize = {
						order = 3,
						type = 'range',
						name = L["Text Font Size"],
						min = 10, max = 50, step = 1,
					},
					font = {
						order = 4,
						type = 'select',
						name = L["Font"],
						dialogControl = 'LSM30_Font',
						values = AceGUIWidgetLSMlists.font,
					},
					fontOutline = {
						order = 5,
						type = "select",
						name = L["Font Outline"],
						values = C.Values.FontFlags,
					},
				}
			}
		},
	}

	if db == 'global' then
		-- clean up the main one
		E.Options.args.cooldown.args[db].args.reverse = nil
		E.Options.args.cooldown.args[db].args.colorGroup.args.override = nil

		-- remove disables
		for _, x in pairs(E.Options.args.cooldown.args[db].args.colorGroup.args) do
			if x.disabled then x.disabled = nil end
		end

		-- rename the tab
		E.Options.args.cooldown.args[db].args.colorGroup.name = L["COLORS"]

		-- move hide blizzard option into the top toggles, keeping order 3 is fine and correct.
		E.Options.args.cooldown.args.hideBlizzard = E.Options.args.cooldown.args[db].args.hideBlizzard
		E.Options.args.cooldown.args[db].args.hideBlizzard = nil
	else
		E.Options.args.cooldown.args[db].args.colorGroup.args.spacer2 = nil
	end

	if db == 'auras' then
		-- even though the top auras can support hiding the text, don't allow this to be a setting to prevent confusion
		E.Options.args.cooldown.args[db].args.reverse = nil

		-- this text is different so just hide this option for top auras
		E.Options.args.cooldown.args[db].args.hideBlizzard = nil

		-- this is basically creates a second way to change font, we only really need one
		E.Options.args.cooldown.args[db].args.fontGroup = nil
	end
end

E.Options.args.cooldown = {
	type = 'group',
	name = L["Cooldown Text"],
	childGroups = "tab",
	order = 2,
	get = function(info) return E.db.cooldown[info[#info]] end,
	set = function(info, value) E.db.cooldown[info[#info]] = value; E:UpdateCooldownSettings('global'); end,
	args = {
		intro = ACH:Description(L["COOLDOWN_DESC"], 1),
		enable = {
			type = "toggle",
			order = 2,
			name = L["Enable"],
			desc = L["Display cooldown text on anything with the cooldown spiral."]
		},
	},
}

group(5,  'global',     L["Global"])
group(6,  'auras',      L["BUFFOPTIONS_LABEL"])
group(7,  'actionbar',  L["ActionBars"])
group(8,  'bags',       L["Bags"])
group(9,  'nameplates', L["NamePlates"])
group(10, 'unitframe',  L["UnitFrames"])
