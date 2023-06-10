local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local A = E:GetModule('Auras')
local PA = E:GetModule('PrivateAuras')
local ACH = E.Libs.ACH

local CopyTable = CopyTable

local DebuffColors = E.Libs.Dispel:GetDebuffTypeColor()

local SharedOptions = {
	growthDirection = ACH:Select(L["Growth Direction"], L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."], 1, C.Values.GrowthDirection),
	sortMethod = ACH:Select(L["Sort Method"], L["Defines how the group is sorted."], 2, { INDEX = L["Index"], TIME = L["Time"], NAME = L["Name"] }),
	sortDir = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 3, { ['+'] = L["Ascending"], ['-'] = L["Descending"] }),
	seperateOwn = ACH:Select(L["Separate"], L["Indicate whether buffs you cast yourself should be separated before or after."], 4, { [-1] = L["Other's First"], [0] = L["No Sorting"], [1] = L["Your Auras First"] }),

	size = ACH:Range(L["Size"], L["Set the size of the individual auras."], 5, { min = 10, max = 60, step = 1 }),
	wrapAfter = ACH:Range(L["Wrap After"], L["Begin a new row or column after this many auras."], 6, { min = 1, max = 32, step = 1 }),
	maxWraps = ACH:Range(L["Max Wraps"], L["Limit the number of rows or columns."], 7, { min = 1, max = 32, step = 1 }),
	horizontalSpacing = ACH:Range(L["Horizontal Spacing"], nil, 8, { min = 0, max = 50, step = 1 }),
	verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 9, { min = 0, max = 50, step = 1 }),
	fadeThreshold = ACH:Range(L["Fade Threshold"], L["Threshold before the icon will fade out and back in. Set to -1 to disable."], 10, { min = -1, max = 30, step = 1 }),
	showDuration = ACH:Toggle(L["Duration Enable"], nil, 11),

	statusBar = ACH:Group(L["Statusbar"], nil, -3),
	timeGroup = ACH:Group(L["Time Text"], nil, -2),
	countGroup = ACH:Group(L["Count Text"], nil, -1),
}

SharedOptions.timeGroup.args.timeFont = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.timeGroup.args.timeFontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
SharedOptions.timeGroup.args.timeFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
SharedOptions.timeGroup.args.timeXOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -60, max = 60, step = 1 })
SharedOptions.timeGroup.args.timeYOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -60, max = 60, step = 1 })

SharedOptions.countGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
SharedOptions.countGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 2)
SharedOptions.countGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
SharedOptions.countGroup.args.countXOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -60, max = 60, step = 1 })
SharedOptions.countGroup.args.countYOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -60, max = 60, step = 1 })

do
	local notBarShow = function(info) local db = E.db.auras[info[#info-2]] if db then return not db.barShow end end
	SharedOptions.statusBar.args.barShow = ACH:Toggle(L["Enable"], nil, 1)
	SharedOptions.statusBar.args.barNoDuration = ACH:Toggle(L["No Duration"], nil, 2, nil, nil, nil, nil, nil, notBarShow)
	SharedOptions.statusBar.args.barTexture = ACH:SharedMediaStatusbar(L["Texture"], nil, 3, nil, nil, nil, notBarShow)
	SharedOptions.statusBar.args.barColor = ACH:Color(L.COLOR, nil, 4, true, nil, nil, nil, notBarShow)
	SharedOptions.statusBar.args.barColorGradient = ACH:Toggle(L["Color by Value"], nil, 5, nil, nil, nil, nil, nil, notBarShow)
	SharedOptions.statusBar.args.barPosition = ACH:Select(L["Position"], nil, 6, { TOP = L["Top"], BOTTOM = L["Bottom"], LEFT = L["Left"], RIGHT = L["Right"] }, nil, nil, nil, nil, notBarShow)
	SharedOptions.statusBar.args.barSize = ACH:Range(L["Size"], nil, 7, { min = 1, max = 10, step = 1 }, nil, nil, nil, notBarShow)
	SharedOptions.statusBar.args.barSpacing = ACH:Range(L["Spacing"], nil, 8, { min = -10, max = 10, step = 1 }, nil, nil, nil, notBarShow)
end

local Auras = ACH:Group(L["BUFFOPTIONS_LABEL"], nil, 2, 'tab', function(info) return E.private.auras[info[#info]] end, function(info, value) E.private.auras[info[#info]] = value; E.ShowPopup = true end)
E.Options.args.auras = Auras

Auras.args.intro = ACH:Description(L["AURAS_DESC"], 0)
Auras.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Auras.args.buffsHeader = ACH:Toggle(L["Buffs"], nil, 2, nil, nil, 80)
Auras.args.debuffsHeader = ACH:Toggle(L["Debuffs"], nil, 3, nil, nil, 80)
Auras.args.disableBlizzard = ACH:Toggle(L["Disabled Blizzard"], nil, 4, nil, nil, 140)
Auras.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 5, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'auras') end)

Auras.args.colorGroup = ACH:MultiSelect(L["Colors"], nil, 6, { colorEnchants = L["Color Enchants"], colorDebuffs = L["Color Debuffs"] }, nil, nil, function(_, key) return E.db.auras[key] end, function(_, key, value) E.db.auras[key] = value end)

do
	Auras.args.debuffColors = ACH:Group(E.NewSign..L["Debuff Colors"], nil, 7, nil, function(info) local t, d = E.db.general.debuffColors[info[#info]], P.general.debuffColors[info[#info]] return t.r, t.g, t.b, 1, d.r, d.g, d.b, 1 end, function(info, r, g, b) E:UpdateDispelColor(info[#info], r, g, b) end)
	Auras.args.debuffColors.args.spacer1 = ACH:Spacer(10, 'full')
	Auras.args.debuffColors.inline = true

	local order = { none = 0, Magic = 1, Curse = 2, Disease = 3, Poison = 4, EnemyNPC = 11, BadDispel = 12, Bleed = 13, Stealable = 14 }
	for key in next, DebuffColors do
		if key ~= '' then -- this is a reference to none
			Auras.args.debuffColors.args[key] = ACH:Color(key == 'none' and 'None' or key, nil, order[key] or -1, nil, 120)
		end
	end
end

Auras.args.buffs = ACH:Group(L["Buffs"], nil, 10, nil, function(info) return E.db.auras.buffs[info[#info]] end, function(info, value) E.db.auras.buffs[info[#info]] = value; A:UpdateHeader(A.BuffFrame) end, function() return not E.private.auras.buffsHeader end)
Auras.args.buffs.args = CopyTable(SharedOptions)
Auras.args.buffs.args.statusBar.args.barColor.get = function() local t = E.db.auras.buffs.barColor local d = P.auras.buffs.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
Auras.args.buffs.args.statusBar.args.barColor.set = function(_, r, g, b) local t = E.db.auras.buffs.barColor t.r, t.g, t.b = r, g, b end
Auras.args.buffs.args.statusBar.args.barColor.disabled = function() return not E.db.auras.buffs.barShow or (E.db.auras.buffs.barColorGradient or not E.db.auras.buffs.barShow) end

Auras.args.debuffs = ACH:Group(L["Debuffs"], nil, 11, nil, function(info) return E.db.auras.debuffs[info[#info]] end, function(info, value) E.db.auras.debuffs[info[#info]] = value; A:UpdateHeader(A.DebuffFrame) end, function() return not E.private.auras.debuffsHeader end)
Auras.args.debuffs.args = CopyTable(SharedOptions)
Auras.args.debuffs.args.statusBar.args.barColor.get = function() local t = E.db.auras.debuffs.barColor local d = P.auras.debuffs.barColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end
Auras.args.debuffs.args.statusBar.args.barColor.set = function(_, r, g, b) local t = E.db.auras.debuffs.barColor t.r, t.g, t.b = r, g, b end
Auras.args.debuffs.args.statusBar.args.barColor.disabled = function() return not E.db.auras.debuffs.barShow or (E.db.auras.debuffs.barColorGradient or not E.db.auras.debuffs.barShow) end

Auras.args.privateAuras = ACH:Group(E.NewSign..L["Private Auras"], nil, 12, nil, function(info) return E.db.general.privateAuras[info[#info]] end, function(info, value) E.db.general.privateAuras[info[#info]] = value; PA:PlayerPrivateAuras() end, nil, not E.Retail)
Auras.args.privateAuras.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Auras.args.privateAuras.args.countdownFrame = ACH:Toggle(L["Cooldown Spiral"], nil, 3)
Auras.args.privateAuras.args.countdownNumbers = ACH:Toggle(L["Cooldown Numbers"], nil, 4)

Auras.args.privateAuras.args.icon = ACH:Group(L["Icon"], nil, 10, nil, function(info) return E.db.general.privateAuras.icon[info[#info]] end, function(info, value) E.db.general.privateAuras.icon[info[#info]] = value; PA:PlayerPrivateAuras() end)
Auras.args.privateAuras.args.icon.args.point = ACH:Select(L["Point"], nil, 1, { TOP = L["Top"], BOTTOM = L["Bottom"], LEFT = L["Left"], RIGHT = L["Right"] })
Auras.args.privateAuras.args.icon.args.offset = ACH:Range(L["Offset"], nil, 2, { min = -4, max = 64, step = 1 })
Auras.args.privateAuras.args.icon.args.amount = ACH:Range(L["Amount"], nil, 3, { min = 1, max = 5, step = 1 })
Auras.args.privateAuras.args.icon.args.size = ACH:Range(L["Size"], nil, 4, { min = 6, max = 80, step = 1 })
Auras.args.privateAuras.args.icon.inline = true

Auras.args.privateAuras.args.duration = ACH:Group(L["Duration"], nil, 20, nil, function(info) return E.db.general.privateAuras.duration[info[#info]] end, function(info, value) E.db.general.privateAuras.duration[info[#info]] = value; PA:PlayerPrivateAuras() end)
Auras.args.privateAuras.args.duration.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Auras.args.privateAuras.args.duration.args.enable.customWidth = 100
Auras.args.privateAuras.args.duration.args.point = ACH:Select(L["Point"], nil, 5, { TOP = L["Top"], BOTTOM = L["Bottom"], LEFT = L["Left"], RIGHT = L["Right"] })
Auras.args.privateAuras.args.duration.args.offsetX = ACH:Range(L["X-Offset"], nil, 6, { min = -60, max = 60, step = 1 })
Auras.args.privateAuras.args.duration.args.offsetY = ACH:Range(L["Y-Offset"], nil, 7, { min = -60, max = 60, step = 1 })
Auras.args.privateAuras.args.duration.inline = true

Auras.args.masqueGroup = ACH:Group(L["Masque"], nil, 13, nil, nil, nil, function() return not E.Masque or not E.private.auras.enable end)
Auras.args.masqueGroup.args.masque = ACH:MultiSelect(L["Masque Support"], L["Allow Masque to handle the skinning of this element."], 10, { buffs = L["Buffs"], debuffs = L["Debuffs"] }, nil, nil, function(_, key) return E.private.auras.masque[key] end, function(_, key, value) E.private.auras.masque[key] = value; E.ShowPopup = true end)
