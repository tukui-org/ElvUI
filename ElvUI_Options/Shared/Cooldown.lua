local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local ACH = E.Libs.ACH

local function Group(order, db, label)
	local main = ACH:Group(label, nil, order, nil, function(info) return E.db.cooldown[db][info[#info]] end, function(info, value) E.db.cooldown[db][info[#info]] = value; E:CooldownSettings(db); end, nil, function() return (db == 'auraindicator' and E.Retail) or (db == 'cdmanager' and not E.Retail) end)
	E.Options.args.cooldown.args[db] = main

	local mainArgs = main.args
	local colors = ACH:Group(L["Color"], nil, 10, nil, function(info) local t = E.db.cooldown[db].colors[info[#info]] local d = P.cooldown[db].colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a; end, function(info, r, g, b, a) local t = E.db.cooldown[db].colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a; E:CooldownSettings(db); end)
	colors.args.text = ACH:Color(L["Text Color"], nil, 1)
	colors.args.edge = ACH:Color(L["Edge Color"], nil, 2, true, nil, nil, nil, nil, db == 'aurabars')
	colors.args.swipe = ACH:Color(L["Swipe Color"], nil, 3, true, nil, nil, nil, nil, db == 'aurabars')
	colors.args.spacer1 = ACH:Spacer(4, 'full')
	colors.args.swipeCharge = ACH:Color(L["Swipe: Charge"], nil, 10, true, nil, nil, nil, nil, db ~= 'actionbar')
	colors.args.edgeCharge = ACH:Color(L["Edge: Charge"], nil, 11, true, nil, nil, nil, nil, db ~= 'actionbar')
	colors.args.edgeLOC = ACH:Color(L["Edge: Loss of Control"], nil, 12, true, nil, nil, nil, nil, db ~= 'actionbar')
	colors.args.swipeLOC = ACH:Color(L["Swipe: Loss of Control"], nil, 13, true, nil, nil, nil, nil, db ~= 'actionbar')
	colors.inline = true
	mainArgs.colorGroup = colors

	local general = ACH:Group(L["General"], nil, 20)
	general.args.hideNumbers = ACH:Toggle(L["Hide Text"], L["The cooldown timer text."], 1)
	general.args.hideBling = ACH:Toggle(L["Hide Bling"], L["Completion flash when the cooldown finishes."], 4)
	general.args.altBling = ACH:Toggle(L["Alternative Bling"], nil, 5)
	general.args.reverse = ACH:Toggle(L["Reverse"], L["Reverse the cooldown animation."], 6)
	general.args.spacer1 = ACH:Spacer(7, 'full')
	general.args.threshold = ACH:Range(L["Threshold"], L["Abbreviation threshold (in seconds)."], 10, { min = 0, softMax = 3600, max = 86400, step = 1 })
	general.args.minDuration = ACH:Range(L["Minimum Duration"], L["Minimum countdown duration (in milliseconds)."], 11, { min = 0, softMax = 5000, max = 60000, step = 1 })
	-- general.args.rotation = ACH:Range(L["Rotation"], L["Rotates the entire cooldown clockwise."], 12, { min = 0, max = 360, step = 1 })
	general.inline = true
	mainArgs.generalGroup = general

	local fonts = ACH:Group(L["Fonts"], nil, 30)
	fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
	fonts.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	fonts.inline = true
	mainArgs.fontGroup = fonts

	local position = ACH:Group(L["Text Position"], nil, 40)
	position.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPositions)
	position.args.offsetX = ACH:Range(L["X-Offset"], nil, 2, { min = -50, max = 50, step = 1 })
	position.args.offsetY = ACH:Range(L["Y-Offset"], nil, 3, { min = -50, max = 50, step = 1 })
	position.inline = true
	mainArgs.positionGroup = position
end

E.Options.args.cooldown = ACH:Group(L["Cooldown Text"], nil, 2, 'tab', function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; E:CooldownSettings('global'); end)
E.Options.args.cooldown.args.intro = ACH:Description(L["COOLDOWN_DESC"], 0)
E.Options.args.cooldown.args.enable = ACH:Toggle(L["Enable"], L["Display cooldown text on anything with the cooldown spiral."], 1, nil, nil, nil, nil, function(info, value) E.db.cooldown[info[#info]] = value; E:CooldownSettings('global'); E.ShowPopup = true end)

Group(10, 'global',		L["Global"])
Group(11, 'auras',		L["BUFFOPTIONS_LABEL"])
Group(12, 'actionbar',	L["ActionBars"])
Group(13, 'bags',		L["Bags"])
Group(14, 'nameplates',	L["Nameplates"])
Group(15, 'unitframe',	L["UnitFrames"])
Group(16, 'aurabars',	L["Aura Bars"])
Group(17, 'auraindicator', L["Aura Indicator"])
Group(18, 'cdmanager',	L["Cooldown Manager"])
Group(19, 'totemtracker', L["Totem Tracker"])
Group(20, 'bossbutton',	L["Boss Button"])
Group(21, 'zonebutton',	L["Zone Button"])
