local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local A = E:GetModule('Auras')
local ACH = E.Libs.ACH

local Auras = ACH:Group(L["BUFFOPTIONS_LABEL"], nil, 2, 'tab', function(info) return E.private.auras[info[#info]] end, function(info, value) E.private.auras[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.auras = Auras

Auras.args.intro = ACH:Description(L["AURAS_DESC"], 0)
Auras.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Auras.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 2, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'auras') end)
Auras.args.disableBlizzard = ACH:Toggle(L["Disabled Blizzard"], nil, 3)
Auras.args.buffsHeader = ACH:Toggle(L["Buffs"], nil, 4)
Auras.args.debuffsHeader = ACH:Toggle(L["Debuffs"], nil, 5)

Auras.args.masque = ACH:MultiSelect(L["Masque Support"], nil, 10, { buffs = L["Buffs"], debuffs = L["Debuffs"] }, nil, nil, function(_, key) return E.private.auras.masque[key] end, function(_, key, value) E.private.auras.masque[key] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.Masque or not E.private.auras.enable end)

local SharedOptions = {
	general = ACH:Group(L["General"], nil, 1, nil),

	size = ACH:Range(L["Size"], L["Set the size of the individual auras."], 2, { min = 16, max = 60, step = 2 }),
	growthDirection = ACH:Select(L["Growth Direction"], L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."], 4, C.Values.GrowthDirection),
	wrapAfter = ACH:Range(L["Wrap After"], L["Begin a new row or column after this many auras."], 5, { min = 1, max = 32, step = 1 }),
	maxWraps = ACH:Range(L["Max Wraps"], L["Limit the number of rows or columns."], 6, { min = 1, max = 32, step = 1 }),
	horizontalSpacing = ACH:Range(L["Horizontal Spacing"], nil, 7, { min = 0, max = 50, step = 1 }),
	verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 8, { min = 0, max = 50, step = 1 }),
	sortMethod = ACH:Select(L["Sort Method"], L["Defines how the group is sorted."], 9, { INDEX = L["Index"], TIME = L["Time"], NAME = L["Name"] }),
	sortDir = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 10, { ['+'] = L["Ascending"], ['-'] = L["Descending"] }),
	seperateOwn = ACH:Select(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], 11, { [-1] = L["Other's First"], [0] = L["No Sorting"], [1] = L["Your Auras First"] }),

	statusBar = ACH:Group(L["Statusbar"], nil, -3),
	timeGroup = ACH:Group(L['Time'], nil, -2),
	countGroup = ACH:Group(L['Count'], nil, -1),
}

SharedOptions.general.inline = true
SharedOptions.general.args.fadeThreshold = ACH:Range(L["Fade Threshold"], L["Threshold before the icon will fade out and back in. Set to -1 to disable."], 1, { min = -1, max = 30, step = 1 })
SharedOptions.general.args.showDuration = ACH:Toggle(L["Duration Enable"], nil, 3)

SharedOptions.timeGroup.inline = true
SharedOptions.timeGroup.args.timeFont = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.timeGroup.args.timeFontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
SharedOptions.timeGroup.args.timeFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
SharedOptions.timeGroup.args.timeXOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -60, max = 60, step = 1 })
SharedOptions.timeGroup.args.timeYOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -60, max = 60, step = 1 })

SharedOptions.countGroup.inline = true
SharedOptions.countGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.countGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
SharedOptions.countGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
SharedOptions.countGroup.args.countXOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -60, max = 60, step = 1 })
SharedOptions.countGroup.args.countYOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -60, max = 60, step = 1 })

SharedOptions.statusBar.inline = true
SharedOptions.statusBar.args.barShow = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
SharedOptions.statusBar.args.barNoDuration = ACH:Toggle(L["No Duration"], nil, 2)
SharedOptions.statusBar.args.barTexture = ACH:SharedMediaStatusbar(L["Texture"], nil, 3)
SharedOptions.statusBar.args.barColor = ACH:Color(L.COLOR, nil, 4, true)
SharedOptions.statusBar.args.barColorGradient = ACH:Toggle(L["Color by Value"], nil, 5)
SharedOptions.statusBar.args.barPosition = ACH:Select(L["Position"], nil, 6, { TOP = L["Top"], BOTTOM = L["Bottom"], LEFT = L["Left"], RIGHT = L["Right"] })
SharedOptions.statusBar.args.barSize = ACH:Range(L["Size"], nil, 7, { min = 1, max = 10, step = 1 })
SharedOptions.statusBar.args.barSpacing = ACH:Range(L["Spacing"], nil, 8, { min = -10, max = 10, step = 1 })

Auras.args.buffs = ACH:Group(L["Buffs"], nil, 2, nil, function(info) return E.db.auras.buffs[info[#info]] end, function(info, value) E.db.auras.buffs[info[#info]] = value; A:UpdateHeader(A.BuffFrame) end, function() return not E.private.auras.buffsHeader end)
Auras.args.buffs.args = CopyTable(SharedOptions)
Auras.args.buffs.args.general.get = function(info) return E.db.auras.buffs[info[#info]] end
Auras.args.buffs.args.general.set = function(info, value) E.db.auras.buffs[info[#info]] = value; A:UpdateHeader(A.BuffFrame) end
Auras.args.buffs.args.statusBar.disabled = function() return not E.db.auras.buffs.barShow end
Auras.args.buffs.args.statusBar.args.barColor.get = function() local t = E.db.auras.buffs.barColor local d = P.auras.buffs.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
Auras.args.buffs.args.statusBar.args.barColor.set = function(_, r, g, b) local t = E.db.auras.buffs.barColor t.r, t.g, t.b = r, g, b end
Auras.args.buffs.args.statusBar.args.barColor.disabled = function() return not E.db.auras.buffs.barShow or (E.db.auras.buffs.barColorGradient or not E.db.auras.buffs.barShow) end

Auras.args.debuffs = ACH:Group(L["Debuffs"], nil, 3, nil, function(info) return E.db.auras.debuffs[info[#info]] end, function(info, value) E.db.auras.debuffs[info[#info]] = value; A:UpdateHeader(A.DebuffFrame) end, function() return not E.private.auras.debuffsHeader end)
Auras.args.debuffs.args = CopyTable(SharedOptions)
Auras.args.debuffs.args.general.get = function(info) return E.db.auras.debuffs[info[#info]] end
Auras.args.debuffs.args.general.set = function(info, value) E.db.auras.debuffs[info[#info]] = value; A:UpdateHeader(A.DebuffFrame) end
Auras.args.debuffs.args.statusBar.disabled = function() return not E.db.auras.debuffs.barShow end
Auras.args.debuffs.args.statusBar.args.barColor.get = function() local t = E.db.auras.debuffs.barColor local d = P.auras.debuffs.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
Auras.args.debuffs.args.statusBar.args.barColor.set = function(_, r, g, b) local t = E.db.auras.debuffs.barColor t.r, t.g, t.b = r, g, b end
Auras.args.debuffs.args.statusBar.args.barColor.disabled = function() return not E.db.auras.debuffs.barShow or (E.db.auras.debuffs.barColorGradient or not E.db.auras.debuffs.barShow) end
