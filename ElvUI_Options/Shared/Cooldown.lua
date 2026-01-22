local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local ACH = E.Libs.ACH

local function profile(db)
	return (db == 'global' and E.db.cooldown) or E.db[db].cooldown
end

local function private(db)
	return (db == 'global' and P.cooldown) or P[db].cooldown
end

local function Group(order, db, label)
	local main = ACH:Group(label, nil, order, nil, function(info) local t = (profile(db))[info[#info]] local d = (private(db))[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b; end, function(info, r, g, b) local t = (profile(db))[info[#info]] t.r, t.g, t.b = r, g, b; E:CooldownSettings(db); end, function() return db == 'cdmanager' and not (E.private.skins.blizzard.enable and E.private.skins.blizzard.cooldownManager) end, function() return (db == 'cdmanager' and not E.Retail) end)
	E.Options.args.cooldown.args[db] = main

	local mainArgs = main.args

	local colors = ACH:Group(L["Color"], nil, 10)
	colors.args.color = ACH:Color(L["Color"], nil, 2)
	colors.inline = true

	mainArgs.colorGroup = colors

	local fonts = ACH:Group(L["Fonts"], nil, 11, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:CooldownSettings(db); end)
	fonts.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	fonts.args.fontSize = ACH:Range(L["Font Size"], nil, 3, { min = 10, max = 50, step = 1 })
	fonts.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 4)
	fonts.inline = true

	mainArgs.fontGroup = fonts

	local position = ACH:Group(L["Text Position"], nil, 12, nil, function(info) return (profile(db))[info[#info]] end, function(info, value) (profile(db))[info[#info]] = value; E:CooldownSettings(db); end)
	position.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPositions)
	position.args.offsetX = ACH:Range(L["X-Offset"], nil, 2, { min = -50, max = 50, step = 1 })
	position.args.offsetY = ACH:Range(L["Y-Offset"], nil, 3, { min = -50, max = 50, step = 1 })
	position.inline = true

	mainArgs.positionGroup = position
end

E.Options.args.cooldown = ACH:Group(L["Cooldown Text"], nil, 2, 'tab', function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; E:CooldownSettings('global'); end)
E.Options.args.cooldown.args.intro = ACH:Description(L["COOLDOWN_DESC"], 0)
E.Options.args.cooldown.args.enable = ACH:Toggle(L["Enable"], L["Display cooldown text on anything with the cooldown spiral."], 1, nil, nil, nil, nil, function(info, value) E.db.cooldown[info[#info]] = value; E:CooldownSettings('global'); E.ShowPopup = true end)

Group( 5, 'global',		L["Global"])
Group( 6, 'auras',		L["BUFFOPTIONS_LABEL"])
Group( 7, 'actionbar',	L["ActionBars"])
Group( 8, 'bags',		L["Bags"])
Group( 9, 'nameplates',	L["Nameplates"])
Group(10, 'unitframe',	L["UnitFrames"])
Group(11, 'aurabars',	L["Aura Bars"])
Group(12, 'cdmanager',	L["Cooldown Manager"])
