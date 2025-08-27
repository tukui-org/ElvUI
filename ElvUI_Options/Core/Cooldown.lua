local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local AB = E:GetModule('ActionBars')
local ACH = E.Libs.ACH

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local function profile(db)
	return (db == 'global' and E.db.cooldown) or E.db[db].cooldown
end

local function private(db)
	return (db == 'global' and P.cooldown) or P[db].cooldown
end

local function Group(order, db, label)
	local main = ACH:Group(label, nil, order, nil, function(info) local t = (profile(db))[info[#info]] local d = (private(db))[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b; end, function(info, r, g, b) local t = (profile(db))[info[#info]] t.r, t.g, t.b = r, g, b; E:UpdateCooldownSettings(db); end, function() return db == 'cdmanager' and not (E.private.skins.blizzard.enable and E.private.skins.blizzard.cooldownManager) end, function() return (db == 'WeakAuras' and not IsAddOnLoaded(db)) or (db == 'cdmanager' and not E.Retail) end)
	E.Options.args.cooldown.args[db] = main

	local mainArgs = main.args
	mainArgs.showModRate = ACH:Toggle(L["Display Modified Rate"], nil, 1, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)
	mainArgs.reverse = ACH:Toggle(L["Reverse Toggle"], L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."], 5, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)
	mainArgs.hideBlizzard = ACH:Toggle(L["Force Hide Blizzard Text"], L["This option will force hide Blizzard's cooldown text if it is enabled at [Interface > ActionBars > Show Numbers on Cooldown]."], 6, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)

	local seconds = ACH:Group(L["Text Threshold"], nil, 20, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, function() return not (profile(db)).checkSeconds end)
	seconds.inline = true
	seconds.args.checkSeconds = ACH:Toggle(L["Enable"], L["This will override the global cooldown settings."], 1, nil, nil, nil, nil, nil, false)
	seconds.args.mmssThreshold = ACH:Range(L["MM:SS Threshold"], L["Threshold (in seconds) before text is shown in the MM:SS format. Set to -1 to never change to this format."], 2, { min = -1, max = 10800, step = 1 })
	seconds.args.hhmmThreshold = ACH:Range(L["HH:MM Threshold"], L["Threshold (in minutes) before text is shown in the HH:MM format. Set to -1 to never change to this format."], 3, { min = -1, max = 1440, step = 1 })
	mainArgs.secondsGroup = seconds

	local fonts = ACH:Group(L["Fonts"], nil, 30, nil, function(info) return (profile(db)).fonts[info[#info]] end, function(info, value) (profile(db)).fonts[info[#info]] = value; E:UpdateCooldownSettings(db); end, function() return not (profile(db)).fonts.enable end)
	fonts.inline = true
	fonts.args.enable = ACH:Toggle(L["Enable"], L["This will override the global cooldown settings."], 1, nil, nil, nil, nil, nil, false)
	fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 3, { min = 10, max = 50, step = 1 })
	fonts.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 4)
	mainArgs.fontGroup = fonts

	local colors = ACH:Group(L["Color Override"], nil, 40, nil, nil, nil, function() return not (profile(db)).override end)
	colors.inline = true
	colors.args.override = ACH:Toggle(L["Enable"], L["This will override the global cooldown settings."], 1, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, false)
	colors.args.threshold = ACH:Range(L["Low Threshold"], L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"], 2, { min = -1, max = 20, step = 1 }, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)
	mainArgs.colorGroup = colors

	local tColors = ACH:Group(L["Threshold Colors"], nil, 3)
	tColors.args.modRateColor = ACH:Color(L["Modified Rate"], L["Color when the text is using a modified timer rate."], 2, nil, nil, nil, nil, nil, not E.Retail)
	tColors.args.expiringColor = ACH:Color(L["Expiring"], L["Color when the text is about to expire."], 3)
	tColors.args.secondsColor = ACH:Color(L["Seconds"], L["Color when the text is in the seconds format."], 4)
	tColors.args.minutesColor = ACH:Color(L["Minutes"], L["Color when the text is in the minutes format."], 5)
	tColors.args.hoursColor = ACH:Color(L["Hours"], L["Color when the text is in the hours format."], 6)
	tColors.args.daysColor = ACH:Color(L["Days"], L["Color when the text is in the days format."], 7)
	tColors.args.mmssColor = ACH:Color(L["MM:SS"], nil, 8)
	tColors.args.hhmmColor = ACH:Color(L["HH:MM"], nil, 9)
	mainArgs.colorGroup.args.timeColors = tColors

	local iColors = ACH:Group(L["Time Indicator Colors"], nil, 4, nil, nil, nil, function() return not (profile(db)).useIndicatorColor end)
	iColors.args.useIndicatorColor = ACH:Toggle(L["Use Indicator Color"], nil, 0, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end, false)
	iColors.args.expireIndicator = ACH:Color(L["Expiring"], L["Color when the text is about to expire."], 3)
	iColors.args.secondsIndicator = ACH:Color(L["Seconds"], L["Color when the text is in the seconds format."], 4)
	iColors.args.minutesIndicator = ACH:Color(L["Minutes"], L["Color when the text is in the minutes format."], 5)
	iColors.args.hoursIndicator = ACH:Color(L["Hours"], L["Color when the text is in the hours format."], 6)
	iColors.args.daysIndicator = ACH:Color(L["Days"], L["Color when the text is in the days format."], 7)
	iColors.args.hhmmColorIndicator = ACH:Color(L["MM:SS"], nil, 8)
	iColors.args.mmssColorIndicator = ACH:Color(L["HH:MM"], nil, 9)
	mainArgs.colorGroup.args.indicatorColors = iColors

	if db == 'global' then
		mainArgs.reverse = nil
		mainArgs.colorGroup.args.override = nil
		mainArgs.colorGroup.disabled = nil
		mainArgs.colorGroup.name = L["Colors"]
		mainArgs.roundTime = ACH:Toggle(L["Round Timers"], nil, 2, nil, nil, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:UpdateCooldownSettings(db); end)
	elseif db == 'auras' then
		mainArgs.reverse = nil
		mainArgs.hideBlizzard = nil
		mainArgs.showModRate = nil
		mainArgs.fontGroup = nil
	elseif db == 'actionbar' then
		local auraGroup = ACH:Group(L["Target Aura"], nil, 10)
		auraGroup.args.targetAura = ACH:Toggle(L["Enable"], L["Display Target's Aura Duration, when there is no CD displaying."], 1, nil, nil, nil, function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; E:UpdateCooldownSettings(db); end)
		auraGroup.args.targetAuraDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 2, { min = 0, max = 10800, step = 1 }, nil, function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; if AB.Initialized then AB:SetTargetAuraDuration(value) end end)

		auraGroup.args.spacer = ACH:Spacer(5)
		auraGroup.args.targetAuraColor = ACH:Color(L["Target Aura"], L["Color of the Targets Aura time."], 6, nil, 125)
		auraGroup.args.expiringAuraColor = ACH:Color(L["Target Aura Expiring"], L["Color of the Targets Aura time when expiring."], 7, nil, 175)
		auraGroup.args.targetAuraIndicator = ACH:Color(L["Indicator"], L["Color of the Targets Aura time."], 10, nil, 125, nil, nil, false)
		auraGroup.args.expiringAuraIndicator = ACH:Color(L["Indicator Expiring"], L["Color of the Targets Aura time when expiring."], 11, nil, 175, nil, nil, false)
		auraGroup.inline = true

		mainArgs.auraGroup = auraGroup
	end
end

E.Options.args.cooldown = ACH:Group(L["Cooldown Text"], nil, 2, 'tab', function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; E:UpdateCooldownSettings('global'); end)
E.Options.args.cooldown.args.intro = ACH:Description(L["COOLDOWN_DESC"], 0)
E.Options.args.cooldown.args.enable = ACH:Toggle(L["Enable"], L["Display cooldown text on anything with the cooldown spiral."], 1)

Group( 5, 'global',		L["Global"])
Group( 6, 'auras',		L["BUFFOPTIONS_LABEL"])
Group( 7, 'actionbar',	L["ActionBars"])
Group( 8, 'bags',		L["Bags"])
Group( 9, 'nameplates',	L["Nameplates"])
Group(10, 'unitframe',	L["UnitFrames"])
Group(11, 'cdmanager',	L["Cooldown Manager"])

if E.OtherAddons.WeakAuras then
	Group(20, 'WeakAuras',	L["WeakAuras"])
end
