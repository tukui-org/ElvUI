local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB

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
			local t = (profile(db))[ info[#info] ]
			local d = (private(db))[ info[#info] ]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
		end,
		set = function(info, r, g, b)
			local t = (profile(db))[ info[#info] ]
			t.r, t.g, t.b = r, g, b;
			E:UpdateCooldownSettings(db);
		end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = label,
			},
			override = {
				type = "toggle",
				order = 2,
				name = L["Use Override"],
				desc = L["This will override the global cooldown settings."],
				get = function(info) return (profile(db))[ info[#info] ] end,
				set = function(info, value) (profile(db))[ info[#info] ] = value; E:UpdateCooldownSettings(db); end,
			},
			reverse = {
				type = "toggle",
				order = 3,
				name = L["Reverse Toggle"],
				desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
				get = function(info) return (profile(db))[ info[#info] ] end,
				set = function(info, value) (profile(db))[ info[#info] ] = value; E:UpdateCooldownSettings(db); end,
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
				disabled = function() return not (profile(db)).override end,
				get = function(info) return (profile(db))[ info[#info] ] end,
				set = function(info, value) (profile(db))[ info[#info] ] = value; E:UpdateCooldownSettings(db); end,
			},
			expiringColor = {
				type = 'color',
				order = 6,
				name = L["Expiring"],
				desc = L["Color when the text is about to expire"],
				disabled = function() return not (profile(db)).override end,
			},
			secondsColor = {
				type = 'color',
				order = 7,
				name = L["Seconds"],
				desc = L["Color when the text is in the seconds format."],
				disabled = function() return not (profile(db)).override end,
			},
			minutesColor = {
				type = 'color',
				order = 8,
				name = L["Minutes"],
				desc = L["Color when the text is in the minutes format."],
				disabled = function() return not (profile(db)).override end,
			},
			hoursColor = {
				type = 'color',
				order = 9,
				name = L["Hours"],
				desc = L["Color when the text is in the hours format."],
				disabled = function() return not (profile(db)).override end,
			},
			daysColor = {
				type = 'color',
				order = 10,
				name = L["Days"],
				desc = L["Color when the text is in the days format."],
				disabled = function() return not (profile(db)).override end,
			},
		},
	}

	if db == 'global' then
		E.Options.args.cooldown.args[db].args.override = nil
		E.Options.args.cooldown.args[db].args.reverse = nil
		E.Options.args.cooldown.args[db].args.spacer1 = nil
		E.Options.args.cooldown.args[db].args.threshold.disabled = nil
		E.Options.args.cooldown.args[db].args.expiringColor.disabled = nil
		E.Options.args.cooldown.args[db].args.secondsColor.disabled = nil
		E.Options.args.cooldown.args[db].args.minutesColor.disabled = nil
		E.Options.args.cooldown.args[db].args.hoursColor.disabled = nil
		E.Options.args.cooldown.args[db].args.daysColor.disabled = nil
	end
end

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
	},
}

group(3, 'global', L["Cooldown Text"])
group(4, 'auras', BUFFOPTIONS_LABEL)
group(5, 'bags', L["Bags"])
group(6, 'nameplates', L["NamePlates"])
group(7, 'unitframe', L["UnitFrames"])
