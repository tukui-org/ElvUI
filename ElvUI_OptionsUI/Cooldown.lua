local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local ACH = E.Libs.ACH

-- GLOBALS: AceGUIWidgetLSMlists

local function profile(db)
	return (db == 'global' and E.db.cooldown) or E.db[db].cooldown
end

local function private(db)
	return (db == 'global' and P.cooldown) or P[db].cooldown
end

local function group(order, db, label)
	local main = ACH:Group(label, nil, order, nil, function(info) local t = (profile(db))[info[#info]] local d = (private(db))[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b; end, function(info, r, g, b) local t = (profile(db))[info[#info]] t.r, t.g, t.b = r, g, b; E:UpdateCooldownSettings(db); end)
	E.Options.args.cooldown.args[db] = main

	local mainArgs = main.args
	mainArgs.reverse = ACH:Toggle(L["Reverse Toggle"], L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."], 1, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)
	mainArgs.hideBlizzard = ACH:Toggle(L["Force Hide Blizzard Text"], L["This option will force hide Blizzard's cooldown text if it is enabled at [Interface > ActionBars > Show Numbers on Cooldown]."], 2, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, nil, function() if db == 'global' then return E.db.cooldown.enable else return (E.db.cooldown.enable and not profile(db).reverse) or (not E.db.cooldown.enable and profile(db).reverse) end end)

	local seconds = ACH:Group(L["Text Threshold"], nil, 3, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, function() return not (profile(db)).checkSeconds end)
	seconds.inline = true
	seconds.args.checkSeconds = ACH:Toggle(L["Enable"], L["This will override the global cooldown settings."], 1, nil, nil, nil, nil, nil, false)
	seconds.args.mmssThreshold = ACH:Range(L["MM:SS Threshold"], L["Threshold (in seconds) before text is shown in the MM:SS format. Set to -1 to never change to this format."], 2, { min = -1, max = 10800, step = 1 })
	seconds.args.hhmmThreshold = ACH:Range(L["HH:MM Threshold"], L["Threshold (in minutes) before text is shown in the HH:MM format. Set to -1 to never change to this format."], 3, { min = -1, max = 1440, step = 1 })
	mainArgs.secondsGroup = seconds

	local fonts = ACH:Group(L["Fonts"], nil, 4, nil, function(info) return (profile(db)).fonts[info[#info]] end, function(info, value) (profile(db)).fonts[info[#info]] = value; E:UpdateCooldownSettings(db); end, function() return not (profile(db)).fonts.enable end)
	fonts.inline = true
	fonts.args.enable = ACH:Toggle(L["Enable"], L["This will override the global cooldown settings."], 1, nil, nil, nil, nil, nil, false)
	fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 3, { min = 10, max = 50, step = 1 })
	fonts.args.fontOutline = ACH:Select(L["Font Outline"], nil, 4, C.Values.FontFlags)
	mainArgs.fontGroup = fonts

	local colors = ACH:Group(L["Color Override"], nil, 5, nil, nil, nil, function() return not (profile(db)).override end)
	colors.inline = true
	colors.args.override = ACH:Toggle(L["Enable"], L["This will override the global cooldown settings."], 1, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, false)
	colors.args.threshold = ACH:Range(L["Low Threshold"], L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"], 2, { min = -1, max = 20, step = 1 }, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)
	mainArgs.colorGroup = colors

	local tColors = ACH:Group(L["Threshold Colors"], nil, 3)
	tColors.args.expiringColor = ACH:Color(L["Expiring"], L["Color when the text is about to expire"], 1)
	tColors.args.secondsColor = ACH:Color(L["Seconds"], L["Color when the text is in the seconds format."], 2)
	tColors.args.minutesColor = ACH:Color(L["Minutes"], L["Color when the text is in the minutes format."], 3)
	tColors.args.hoursColor = ACH:Color(L["Hours"], L["Color when the text is in the hours format."], 4)
	tColors.args.daysColor = ACH:Color(L["Days"], L["Color when the text is in the days format."], 5)
	tColors.args.mmssColor = ACH:Color(L["MM:SS"], nil, 6)
	tColors.args.hhmmColor = ACH:Color(L["HH:MM"], nil, 7)
	mainArgs.colorGroup.args.timeColors = tColors

	local iColors = ACH:Group(L["Time Indicator Colors"], nil, 4, nil, nil, nil, function() return not (profile(db)).useIndicatorColor end)
	iColors.args.useIndicatorColor = ACH:Toggle(L["Use Indicator Color"], nil, 0, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, false)
	iColors.args.expireIndicator = ACH:Color(L["Expiring"], L["Color when the text is about to expire"], 1)
	iColors.args.secondsIndicator = ACH:Color(L["Seconds"], L["Color when the text is in the seconds format."], 2)
	iColors.args.minutesIndicator = ACH:Color(L["Minutes"], L["Color when the text is in the minutes format."], 3)
	iColors.args.hoursIndicator = ACH:Color(L["Hours"], L["Color when the text is in the hours format."], 4)
	iColors.args.daysIndicator = ACH:Color(L["Days"], L["Color when the text is in the days format."], 5)
	iColors.args.hhmmColorIndicator = ACH:Color(L["MM:SS"], nil, 6)
	iColors.args.mmssColorIndicator = ACH:Color(L["HH:MM"], nil, 7)
	mainArgs.colorGroup.args.indicatorColors = iColors

	if db == 'global' then
		mainArgs.reverse = nil
		mainArgs.colorGroup.args.override = nil
		mainArgs.colorGroup.disabled = nil
		mainArgs.colorGroup.name = L["COLORS"]

		-- keep these two in this order
		E.Options.args.cooldown.args.hideBlizzard = mainArgs.hideBlizzard
		mainArgs.hideBlizzard = nil
	elseif db == 'auras' then
		mainArgs.reverse = nil
		mainArgs.hideBlizzard = nil
		mainArgs.fontGroup = nil
	end
end

E.Options.args.cooldown = ACH:Group(L["Cooldown Text"], nil, 2, 'tab', function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; E:UpdateCooldownSettings('global'); end)
E.Options.args.cooldown.args.intro = ACH:Description(L["COOLDOWN_DESC"], 0)
E.Options.args.cooldown.args.enable = ACH:Toggle(L["Enable"], L["Display cooldown text on anything with the cooldown spiral."], 1)

group(5,  'global',     L["Global"])
group(6,  'auras',      L["BUFFOPTIONS_LABEL"])
group(7,  'actionbar',  L["ActionBars"])
group(8,  'bags',       L["Bags"])
group(9,  'nameplates', L["NamePlates"])
group(10, 'unitframe',  L["UnitFrames"])
