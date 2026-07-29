local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local AB = E:GetModule('ActionBars')
local ACH = E.Libs.ACH

local THRESHOLD = { min = 0, softMax = 3600, max = 86400, step = 1 }
local MIN_DURATION = { min = 0, softMax = 60, max = 3600, step = 0.001, bigStep = 1 }

local function Group(order, db, label)
	local main = ACH:Group(label, nil, order, nil, function(info) return E.db.cooldown[db][info[#info]] end, function(info, value) E.db.cooldown[db][info[#info]] = value; E:CooldownSettings(db); end, function() return db == 'cdmanager' and not (E.private.skins.blizzard.enable and E.private.skins.blizzard.cooldownManager) end, function() return (db == 'cdmanager' and not E.Retail) end)
	E.Options.args.cooldown.args[db] = main

	local charges = db ~= 'actionbar' and db ~= 'bossbutton' and db ~= 'zonebutton'
	local lossOfControl = db ~= 'actionbar' and db ~= 'bossbutton'

	local mainArgs = main.args
	local targetAura = ACH:Group(L["Target Aura"], nil, 10, nil, function(info) return E.db.cooldown.targetaura[info[#info]] end, function(info, value) E.db.cooldown.targetaura[info[#info]] = value; E:CooldownSettings('targetaura'); end, nil, E.Retail or db ~= 'actionbar')
	targetAura.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.db.cooldown.targetaura[info[#info]] end, function(info, value) E.db.cooldown.targetaura[info[#info]] = value; AB:SetTargetAuraCooldowns(value) end)
	targetAura.args.text = ACH:Color(L["Text Color"], nil, 2, nil, nil, function(info) local t = E.db.cooldown.targetaura.colors[info[#info]] local d = P.cooldown.targetaura.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.cooldown.targetaura.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a; E:CooldownSettings('targetaura'); end)
	targetAura.args.threshold = ACH:Range(L["Threshold"], L["Abbreviation threshold (in seconds)."], 3, THRESHOLD, nil, function(info) return E.db.cooldown.targetaura[info[#info]] end, function(info, value) E.db.cooldown.targetaura[info[#info]] = value; E:CooldownSettings('targetaura'); end)
	targetAura.args.minDuration = ACH:Range(L["Minimum Duration"], L["Minimum countdown duration (in seconds)."], 4, MIN_DURATION, nil, function(info) return E.db.cooldown.targetaura[info[#info]] * 0.001 end, function(info, value) E.db.cooldown.targetaura[info[#info]] = value * 1000; E:CooldownSettings('targetaura'); end)
	targetAura.inline = true
	mainArgs.targetAuraGroup = targetAura

	local general = ACH:Group(L["General"], nil, 20)
	general.args.minDuration = ACH:Range(L["Minimum Duration"], L["Minimum countdown duration (in seconds)."], 1, MIN_DURATION, nil, function(info) return E.db.cooldown[db][info[#info]] * 0.001 end, function(info, value) E.db.cooldown[db][info[#info]] = value * 1000; E:CooldownSettings(db); end)
	general.args.threshold = ACH:Range(L["Threshold"], L["Abbreviation threshold (in seconds)."], 2, THRESHOLD)
	general.args.roundup = ACH:Toggle(L["Round Timers"], nil, 3)
	general.args.reverse = ACH:Toggle(L["Reverse"], L["Reverse the cooldown animation."], 4)
	general.args.hideNumbers = ACH:Toggle(L["Hide Text"], L["The cooldown timer text."], 5, nil, nil, nil, nil, nil, nil, db == 'auraindicator')
	general.args.chargeText = ACH:Toggle(L["Text: Charge"], L["The charge cooldown text."], 6, nil, nil, nil, nil, nil, nil, charges)
	general.args.locText = ACH:Toggle(L["Text: Loss of Control"], L["The loss of control cooldown text."], 7, nil, nil, nil, nil, nil, nil, lossOfControl)
	general.args.hideBling = ACH:Toggle(L["Hide Bling"], L["Completion flash when the cooldown finishes."], 8)
	general.args.altBling = ACH:Toggle(L["Alternative Bling"], nil, 9)
	-- general.args.rotation = ACH:Range(L["Rotation"], L["Rotates the entire cooldown clockwise."], 10, { min = 0, max = 360, step = 1 })
	general.inline = true
	mainArgs.generalGroup = general

	local _, textGroup, thresholdGroup = C:GetCooldownConfig(db, E.db.cooldown[db], P.cooldown[db], charges, lossOfControl)
	mainArgs.textGroup = textGroup
	mainArgs.thresholdGroup = thresholdGroup
end

E.Options.args.cooldown = ACH:Group(L["Cooldown & Duration"], nil, 2, 'tab', function(info) return E.db.cooldown[info[#info]] end, function(info, value) E.db.cooldown[info[#info]] = value; E:CooldownSettings('global'); end)
E.Options.args.cooldown.args.intro = ACH:Description(L["COOLDOWN_DESC"], 0)
E.Options.args.cooldown.args.enable = ACH:Toggle(L["Enable"], L["Display cooldown text on anything with the cooldown spiral."], 1, nil, nil, nil, nil, function(info, value) E.db.cooldown[info[#info]] = value; E:CooldownSettings('global'); E.ShowPopup = true end)

Group(10, 'global',			L["Global"])
Group(11, 'auras',			L["BUFFOPTIONS_LABEL"])
Group(12, 'actionbar',		L["ActionBars"])
Group(13, 'bags',			L["Bags"])
Group(14, 'nameplates',		L["Nameplates"])
Group(15, 'unitframe',		L["UnitFrames"])
Group(16, 'aurabars',		L["Aura Bars"])
Group(17, 'auraindicator',	L["Aura Indicator"])
Group(18, 'cdmanager',		L["Cooldown Manager"])
Group(19, 'totemtracker',	L["Totem Tracker"])
Group(20, 'bossbutton',		L["Boss Button"])
Group(21, 'zonebutton',		L["Zone Button"])
