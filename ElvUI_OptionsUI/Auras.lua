local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local A = E:GetModule('Auras')
local ACH = E.Libs.ACH

local function GetAuraOptions()
	local auraOptions = {}

	auraOptions.size = ACH:Range(L["Size"], L["Set the size of the individual auras."], 1, { min = 16, max = 60, step = 2 })
	auraOptions.durationFontSize = ACH:Range(L["Duration Font Size"], nil, 2, C.Values.FontSize)
	auraOptions.countFontSize = ACH:Range(L["Count Font Size"], nil, 3, C.Values.FontSize)
	auraOptions.growthDirection = ACH:Select(L["Growth Direction"], L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."], 4, C.Values.GrowthDirection)
	auraOptions.wrapAfter = ACH:Range(L["Wrap After"], L["Begin a new row or column after this many auras."], 5, { min = 1, max = 32, step = 1 })
	auraOptions.maxWraps = ACH:Range(L["Max Wraps"], L["Limit the number of rows or columns."], 6, { min = 1, max = 32, step = 1 })
	auraOptions.horizontalSpacing = ACH:Range(L["Horizontal Spacing"], nil, 7, { min = 0, max = 50, step = 1 })
	auraOptions.verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 8, { min = 0, max = 50, step = 1 })
	auraOptions.sortMethod = ACH:Select(L["Sort Method"], L["Defines how the group is sorted."], 9, { INDEX = L["Index"], TIME = L["Time"], NAME = L["Name"] })
	auraOptions.sortDir = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 10, { ['+'] = L["Ascending"], ['-'] = L["Descending"] })
	auraOptions.seperateOwn = ACH:Select(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], 11, { [-1] = L["Other's First"], [0] = L["No Sorting"], [1] = L["Your Auras First"] })

	return auraOptions
end

E.Options.args.auras = ACH:Group(L["BUFFOPTIONS_LABEL"], nil, 2, 'tab', function(info) return E.private.auras[info[#info]] end, function(info, value) E.private.auras[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.auras.args.intro = ACH:Description(L["AURAS_DESC"], 0)
E.Options.args.auras.args.enable = ACH:Toggle(L["Enable"], nil, 1)
E.Options.args.auras.args.disableBlizzard = ACH:Toggle(L["Disabled Blizzard"], nil, 2)
E.Options.args.auras.args.buffsHeader = ACH:Toggle(L["Buffs"], nil, 3)
E.Options.args.auras.args.debuffsHeader = ACH:Toggle(L["Debuffs"], nil, 4)

E.Options.args.auras.args.general = ACH:Group(L["General"], nil, 1, nil, function(info) return E.db.auras[info[#info]] end, function(info, value) E.db.auras[info[#info]] = value; A:UpdateHeader(A.BuffFrame); A:UpdateHeader(A.DebuffFrame) end)
E.Options.args.auras.args.general.args.fadeThreshold = ACH:Range(L["Fade Threshold"], L["Threshold before the icon will fade out and back in. Set to -1 to disable."], 1, { min = -1, max = 30, step = 1 })
E.Options.args.auras.args.general.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
E.Options.args.auras.args.general.args.showDuration = ACH:Toggle(L["Duration Enable"], nil, 3)
E.Options.args.auras.args.general.args.fontOutline = ACH:Select(L["Font Outline"], L["Set the font outline."], 4, C.Values.FontFlags)
E.Options.args.auras.args.general.args.timeXOffset = ACH:Range(L["Time xOffset"], nil, 5, { min = -60, max = 60, step = 1 })
E.Options.args.auras.args.general.args.timeYOffset = ACH:Range(L["Time yOffset"], nil, 6, { min = -60, max = 60, step = 1 })
E.Options.args.auras.args.general.args.countXOffset = ACH:Range(L["Count xOffset"], nil, 7, { min = -60, max = 60, step = 1 })
E.Options.args.auras.args.general.args.countYOffset = ACH:Range(L["Count yOffset"], nil, 8, { min = -60, max = 60, step = 1 })

E.Options.args.auras.args.general.args.statusBar = ACH:Group(L["Statusbar"], nil, 9, nil, nil, nil, function() return not E.db.auras.barShow end)
E.Options.args.auras.args.general.args.statusBar.guiInline = true
E.Options.args.auras.args.general.args.statusBar.args.barShow = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
E.Options.args.auras.args.general.args.statusBar.args.barNoDuration = ACH:Toggle(L["No Duration"], nil, 2)
E.Options.args.auras.args.general.args.statusBar.args.barTexture = ACH:SharedMediaStatusbar(L["Texture"], nil, 3)
E.Options.args.auras.args.general.args.statusBar.args.barColor = ACH:Color(L.COLOR, nil, 4, true, nil, function() local t = E.db.auras.barColor local d = P.auras.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(_, r, g, b) local t = E.db.auras.barColor t.r, t.g, t.b = r, g, b end, function() return not E.db.auras.barShow or (E.db.auras.barColorGradient or not E.db.auras.barShow) end)
E.Options.args.auras.args.general.args.statusBar.args.barColorGradient = ACH:Toggle(L["Color by Value"], nil, 5)
E.Options.args.auras.args.general.args.statusBar.args.barPosition = ACH:Select(L["Position"], nil, 6, { TOP = L["Top"], BOTTOM = L["Bottom"], LEFT = L["Left"], RIGHT = L["Right"] })
E.Options.args.auras.args.general.args.statusBar.args.barWidth = ACH:Range(L["Width"], nil, 7, { min = 1, max = 10, step = 1 }, nil, nil, nil, nil, function() return E.db.auras.barPosition == 'TOP' or E.db.auras.barPosition == 'BOTTOM' end)
E.Options.args.auras.args.general.args.statusBar.args.barHeight = ACH:Range(L["Height"], nil, 7, { min = 1, max = 10, step = 1 }, nil, nil, nil, nil, function() return E.db.auras.barPosition == 'LEFT' or E.db.auras.barPosition == 'RIGHT' end)
E.Options.args.auras.args.general.args.statusBar.args.barSpacing = ACH:Range(L["Spacing"], nil, 8, { min = -10, max = 10, step = 1 })

E.Options.args.auras.args.general.args.masque = ACH:MultiSelect(L["Masque Support"], nil, 10, { buffs = L["Buffs"], debuffs = L["Debuffs"] }, nil, nil, function(_, key) return E.private.auras.masque[key] end, function(_, key, value) E.private.auras.masque[key] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.Masque or not E.private.auras.enable end)

E.Options.args.auras.args.buffs = ACH:Group(L["Buffs"], nil, 2, nil, function(info) return E.db.auras.buffs[info[#info]] end, function(info, value) E.db.auras.buffs[info[#info]] = value; A:UpdateHeader(A.BuffFrame) end, function() return not E.private.auras.buffsHeader end)
E.Options.args.auras.args.buffs.args = GetAuraOptions()

E.Options.args.auras.args.debuffs = ACH:Group(L["Debuffs"], nil, 3, nil, function(info) return E.db.auras.debuffs[info[#info]] end, function(info, value) E.db.auras.debuffs[info[#info]] = value; A:UpdateHeader(A.DebuffFrame) end, function() return not E.private.auras.debuffsHeader end)
E.Options.args.auras.args.debuffs.args = GetAuraOptions()
