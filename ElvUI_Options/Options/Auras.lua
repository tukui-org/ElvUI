local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local A = E:GetModule('Auras')
local ACH = E.Libs.ACH

local CopyTable = CopyTable

local SharedOptions = {
	growthDirection = ACH:Select(L["Growth Direction"], L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."], 1, C.Values.GrowthDirection),
	sortMethod = ACH:Select(L["Sort Method"], L["Defines how the group is sorted."], 2, { INDEX = L["Index"], TIME = L["Time"], NAME = L["Name"] }),
	sortDir = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 3, { ['+'] = L["Ascending"], ['-'] = L["Descending"] }),
	seperateOwn = ACH:Select(L["Separate"], L["Indicate whether buffs you cast yourself should be separated before or after."], 4, { [-1] = L["Other's First"], [0] = L["No Sorting"], [1] = L["Your Auras First"] }),

	size = ACH:Range(L["Size"], L["Set the size of the individual auras."], 5, { min = 16, max = 60, step = 2 }),
	wrapAfter = ACH:Range(L["Wrap After"], L["Begin a new row or column after this many auras."], 6, { min = 1, max = 32, step = 1 }),
	maxWraps = ACH:Range(L["Max Wraps"], L["Limit the number of rows or columns."], 7, { min = 1, max = 32, step = 1 }),
	horizontalSpacing = ACH:Range(L["Horizontal Spacing"], nil, 8, { min = 0, max = 50, step = 1 }),
	verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 9, { min = 0, max = 50, step = 1 }),
	fadeThreshold = ACH:Range(L["Fade Threshold"], L["Threshold before the icon will fade out and back in. Set to -1 to disable."], 10, { min = -1, max = 30, step = 1 }),
	showDuration = ACH:Toggle(L["Duration Enable"], nil, 11),

	statusBar = ACH:Group(L["Statusbar"], nil, -3),
	timeGroup = ACH:Group(L["Time"], nil, -2),
	countGroup = ACH:Group(L["Count"], nil, -1),
}

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

local Auras = ACH:Group(L["BUFFOPTIONS_LABEL"], nil, 2, 'tab', function(info) return E.private.auras[info[#info]] end, function(info, value) E.private.auras[info[#info]] = value; E.ShowPopup = true end)
E.Options.args.auras = Auras

Auras.args.intro = ACH:Description(L["AURAS_DESC"], 0)
Auras.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Auras.args.buffsHeader = ACH:Toggle(L["Buffs"], nil, 2, nil, nil, 80)
Auras.args.debuffsHeader = ACH:Toggle(L["Debuffs"], nil, 3, nil, nil, 80)
Auras.args.disableBlizzard = ACH:Toggle(L["Disabled Blizzard"], nil, 4, nil, nil, 140)
Auras.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 5, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'auras') end)

Auras.args.colorGroup = ACH:MultiSelect(L["Colors"], nil, 6, { colorEnchants = L["Color Enchants"], colorDebuffs = L["Color Debuffs"] }, nil, nil, function(_, key) return E.db.auras[key] end, function(_, key, value) E.db.auras[key] = value end)

Auras.args.buffs = ACH:Group(L["Buffs"], nil, 10, nil, function(info) return E.db.auras.buffs[info[#info]] end, function(info, value) E.db.auras.buffs[info[#info]] = value; A:UpdateHeader(A.BuffFrame) end, function() return not E.private.auras.buffsHeader end)
Auras.args.buffs.args = CopyTable(SharedOptions)
Auras.args.buffs.args.statusBar.disabled = function() return not E.db.auras.buffs.barShow end
Auras.args.buffs.args.statusBar.args.barColor.get = function() local t = E.db.auras.buffs.barColor local d = P.auras.buffs.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
Auras.args.buffs.args.statusBar.args.barColor.set = function(_, r, g, b) local t = E.db.auras.buffs.barColor t.r, t.g, t.b = r, g, b end
Auras.args.buffs.args.statusBar.args.barColor.disabled = function() return not E.db.auras.buffs.barShow or (E.db.auras.buffs.barColorGradient or not E.db.auras.buffs.barShow) end

Auras.args.debuffs = ACH:Group(L["Debuffs"], nil, 11, nil, function(info) return E.db.auras.debuffs[info[#info]] end, function(info, value) E.db.auras.debuffs[info[#info]] = value; A:UpdateHeader(A.DebuffFrame) end, function() return not E.private.auras.debuffsHeader end)
Auras.args.debuffs.args = CopyTable(SharedOptions)
Auras.args.debuffs.args.statusBar.disabled = function() return not E.db.auras.debuffs.barShow end
Auras.args.debuffs.args.statusBar.args.barColor.get = function() local t = E.db.auras.debuffs.barColor local d = P.auras.debuffs.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
Auras.args.debuffs.args.statusBar.args.barColor.set = function(_, r, g, b) local t = E.db.auras.debuffs.barColor t.r, t.g, t.b = r, g, b end
Auras.args.debuffs.args.statusBar.args.barColor.disabled = function() return not E.db.auras.debuffs.barShow or (E.db.auras.debuffs.barColorGradient or not E.db.auras.debuffs.barShow) end

Auras.args.masqueGroup = ACH:Group(L["Masque"], nil, 12, nil, nil, nil, function() return not E.Masque or not E.private.auras.enable end)
Auras.args.masqueGroup.args.masque = ACH:MultiSelect(L["Masque Support"], L["Allow Masque to handle the skinning of this element."], 10, { buffs = L["Buffs"], debuffs = L["Debuffs"] }, nil, nil, function(_, key) return E.private.auras.masque[key] end, function(_, key, value) E.private.auras.masque[key] = value; E.ShowPopup = true end)
