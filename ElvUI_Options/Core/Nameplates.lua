local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local NP = E:GetModule('NamePlates')
local ACD = E.Libs.AceConfigDialog
local ACH = E.Libs.ACH

local max, wipe, strfind = max, wipe, strfind
local pairs, type, strsplit = pairs, type, strsplit
local next, tonumber, format = next, tonumber, format

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetCVarBool = C_CVar.GetCVarBool

local function GetAddOnStatus(index, locale, name)
	local status = IsAddOnLoaded(name) and format('|cff33ff33%s|r', L["Enabled"]) or format('|cffff3333%s|r', L["Disabled"])
	return ACH:Description(format('%s: %s', locale, status), index, 'medium')
end

local carryFilterFrom, carryFilterTo

local ORDER = 100
local filters = {}

local minHeight, minWidth = 2, 40
local function MaxHeight(unit) local heightType = unit == 'PLAYER' and 'personalHeight' or strfind(unit, 'FRIENDLY') and 'friendlyHeight' or strfind(unit, 'ENEMY') and 'enemyHeight' return max(NP.db.plateSize[heightType] or 0, 20) end
local function MaxWidth(unit) local widthType = unit == 'PLAYER' and 'personalWidth' or strfind(unit, 'FRIENDLY') and 'friendlyWidth' or strfind(unit, 'ENEMY') and 'enemyWidth' return max(NP.db.plateSize[widthType] or 0, 250) end

local auraKeys = {
	buffs = { name = L["Buffs"], order = 1 },
	debuffs = { name = L["Debuffs"], order = 2 },
	auras = { name = L["Custom"], order = -1 },
}

local function GetUnitAuras(unit, auraType)
	local key = auraKeys[auraType]
	local group = ACH:Group(key.name, nil, key.order, nil, function(info) return E.db.nameplates.units[unit][auraType][info[#info]] end, function(info, value) E.db.nameplates.units[unit][auraType][info[#info]] = value NP:ConfigureAll() end)
	group.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.stackAuras = ACH:Toggle(L["Stack Auras"], L["This will join auras together which are normally separated. Example: Bolstering and Force of Nature."], 2)
	group.args.desaturate = ACH:Toggle(L["Desaturate Icon"], L["Set auras that are not from you to desaturated."], 3)
	group.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 4)

	group.args.generalGroup = ACH:Group(L["General"], nil, 10)
	group.args.generalGroup.args.size = ACH:Range(function() return E.db.nameplates.units[unit][auraType].keepSizeRatio and L["Size"] or L["Width"] end, nil, 5, { min = 6, max = 60, step = 1 })
	group.args.generalGroup.args.height = ACH:Range(L["Height"], nil, 6, { min = 6, max = 60, step = 1 }, nil, nil, nil, nil, function() return E.db.nameplates.units[unit][auraType].keepSizeRatio end)
	group.args.generalGroup.args.numAuras = ACH:Range(L["Per Row"], nil, 7, { min = 1, max = 20, step = 1 })
	group.args.generalGroup.args.numRows = ACH:Range(L["Num Rows"], nil, 8, { min = 1, max = 5, step = 1 })
	group.args.generalGroup.args.spacing = ACH:Range(L["Spacing"], nil, 9, { min = 0, max = 60, step = 1 })
	group.args.generalGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 10, { min = -100, max = 100, step = 1 })
	group.args.generalGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 11, { min = -100, max = 100, step = 1 })
	group.args.generalGroup.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 12, C.Values.Anchors)
	group.args.generalGroup.args.attachTo = ACH:Select(L["Attach To"], L["What to attach the anchor frame to."], 13, { FRAME = L["Frame"], DEBUFFS = L["Debuffs"], HEALTH = L["Health"], POWER = L["Power"] }, nil, nil, nil, nil, function() local position = E.db.nameplates.units[unit].smartAuraPosition return position == 'BUFFS_ON_DEBUFFS' or position == 'FLUID_BUFFS_ON_DEBUFFS' end)
	group.args.generalGroup.args.growthX = ACH:Select(L["Growth X-Direction"], nil, 14, { LEFT = L["Left"], RIGHT = L["Right"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.units[unit][auraType].anchorPoint return point == 'LEFT' or point == 'RIGHT' end)
	group.args.generalGroup.args.growthY = ACH:Select(L["Growth Y-Direction"], nil, 15, { UP = L["Up"], DOWN = L["Down"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.units[unit][auraType].anchorPoint return point == 'TOP' or point == 'BOTTOM' end)
	group.args.generalGroup.args.sortMethod = ACH:Select(L["Sort By"], L["Method to sort by."], 16, { TIME_REMAINING = L["Time Remaining"], DURATION = L["Duration"], NAME = L["Name"], INDEX = L["Index"], PLAYER = L["Player"] })
	group.args.generalGroup.args.sortDirection = ACH:Select(L["Sort Direction"], L["Ascending or Descending order."], 17, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
	group.args.generalGroup.args.filter = ACH:Select(L["Aura Filter"], nil, 18, { RAID = L["Raid"], HELPFUL = L["Buffs"], HARMFUL = L["Debuffs"], ["HELPFUL|HARMFUL"] = L["Buffs and Debuffs"] }, nil, nil, nil, nil, nil, auraType ~= 'auras')

	group.args.textGroup = ACH:Group(L["Text"], nil, 15)
	group.args.textGroup.args.stacks = ACH:Group(L["Stack Counter"], nil, 20)
	group.args.textGroup.args.stacks.inline = true
	group.args.textGroup.args.stacks.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.textGroup.args.stacks.args.countFontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.textGroup.args.stacks.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	group.args.textGroup.args.stacks.args.countXOffset = ACH:Range(L["X-Offset"], nil, 10, { min = -100, max = 100, step = 1 })
	group.args.textGroup.args.stacks.args.countYOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })
	group.args.textGroup.args.stacks.args.countPosition = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)

	group.args.textGroup.args.duration = ACH:Group(L["Duration"], nil, 25)
	group.args.textGroup.args.duration.inline = true
	group.args.textGroup.args.duration.args.cooldownShortcut = ACH:Execute(L["Cooldowns"], nil, 1, function() ACD:SelectGroup('ElvUI', 'cooldown', 'nameplates') end)
	group.args.textGroup.args.duration.args.durationPosition = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)

	group.args.filtersGroup = ACH:Group(L["Filters"], nil, 30)
	group.args.filtersGroup.args.minDuration = ACH:Range(L["Minimum Duration"], L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	group.args.filtersGroup.args.maxDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	group.args.filtersGroup.args.jumpToFilter = ACH:Execute(L["Filters Page"], L["Shortcut to global filters."], 3, function() ACD:SelectGroup('ElvUI', 'filters') end)
	group.args.filtersGroup.args.specialFilters = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 4, function() wipe(filters) local list = E.global.unitframe.specialFilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.nameplates.units, unit, auraType, value) NP:ConfigureAll() end, nil, nil, true)
	group.args.filtersGroup.args.filter = ACH:Select(L["Add Regular Filter"], L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."], 5, function() wipe(filters) local list = E.global.unitframe.aurafilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.nameplates.units, unit, auraType, value) NP:ConfigureAll() end)
	group.args.filtersGroup.args.resetPriority = ACH:Execute(L["Reset Priority"], L["Reset filter priority to the default state."], 7, function() E.db.nameplates.units[unit][auraType].priority = P.nameplates.units[unit][auraType].priority NP:ConfigureAll() end)

	group.args.filtersGroup.args.filterPriority = ACH:MultiSelect(L["Filter Priority"], nil, 8, function() local str = E.db.nameplates.units[unit][auraType].priority if str == '' then return {} end return {strsplit(',', str)} end, nil, nil, function(_, value) local str = E.db.nameplates.units[unit][auraType].priority if str == '' then return end local tbl = {strsplit(',', str)} return tbl[value] end, function() NP:ConfigureAll() end)
	group.args.filtersGroup.args.filterPriority.dragdrop = true
	group.args.filtersGroup.args.filterPriority.dragOnLeave = E.noop -- keep it her
	group.args.filtersGroup.args.filterPriority.dragOnEnter = function(info) carryFilterTo = info.obj.value end
	group.args.filtersGroup.args.filterPriority.dragOnMouseDown = function(info) carryFilterFrom, carryFilterTo = info.obj.value, nil end
	group.args.filtersGroup.args.filterPriority.dragOnMouseUp = function() C.SetFilterPriority(E.db.nameplates.units, unit, auraType, carryFilterTo, nil, carryFilterFrom) carryFilterFrom, carryFilterTo = nil, nil end
	group.args.filtersGroup.args.filterPriority.dragOnClick = function() C.SetFilterPriority(E.db.nameplates.units, unit, auraType, carryFilterFrom, true) end
	group.args.filtersGroup.args.filterPriority.stateSwitchGetText = C.StateSwitchGetText
	group.args.filtersGroup.args.filterPriority.stateSwitchOnClick = function() C.SetFilterPriority(E.db.nameplates.units, unit, auraType, carryFilterFrom, nil, nil, true) end
	group.args.filtersGroup.args.spacer1 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 9)

	return group
end

local function GetUnitSettings(unit, name)
	local copyValues = {}

	for x, y in pairs(NP.db.units) do
		if (type(y) == 'table' and x ~= unit) then
			copyValues[x] = L[x]
		end
	end

	local group = ACH:Group(name, nil, ORDER, 'tree', function(info) return E.db.nameplates.units[unit][info[#info]] end, function(info, value) E.db.nameplates.units[unit][info[#info]] = value NP:ConfigureAll() end, function() return not E.NamePlates.Initialized end, unit == 'PLAYER' and not E.Retail)
	group.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.showTestFrame = ACH:Execute(L["Show/Hide Test Frame"], nil, 2, function() if not NP.TestFrame:IsEnabled() or NP.TestFrame.frameType ~= unit then NP.TestFrame:Enable() NP.TestFrame.frameType = unit NP:NamePlateCallBack(NP.TestFrame, 'NAME_PLATE_UNIT_ADDED') NP.TestFrame:UpdateAllElements('ForceUpdate') else NP:DisablePlate(NP.TestFrame) NP.TestFrame:Disable() end end)
	group.args.defaultSettings = ACH:Execute(L["Default Settings"], L["Set Settings to Default"], 3, function() NP:ResetSettings(unit) NP:ConfigureAll() end)
	group.args.copySettings = ACH:Select(L["Copy settings from"], L["Copy settings from another unit."], 4, copyValues, nil, nil, C.Blank, function(_, value) NP:CopySettings(value, unit) NP:ConfigureAll() end)

	group.args.general = ACH:Group(L["General"], nil, 5, nil, function(info) return E.db.nameplates.units[unit][info[#info]] end, function(info, value) E.db.nameplates.units[unit][info[#info]] = value NP:SetCVars() NP:ConfigureAll() end)
	group.args.general.args.visibilityShortcut = ACH:Execute(L["Visibility"], nil, 100, function() ACD:SelectGroup('ElvUI', 'nameplates', 'generalGroup', 'general', 'plateVisibility') end)
	group.args.general.args.nameOnly = ACH:Toggle(L["Name Only"], nil, 101)
	group.args.general.args.showTitle = ACH:Toggle(L["Show Title"], L["Title will only appear if Name Only is enabled or triggered in a Style Filter."], 102)
	group.args.general.inline = true

	group.args.aurasGroup = ACH:Group(L["Auras"], nil, 5, 'tab')
	group.args.aurasGroup.args.smartAuraPosition = ACH:Select(L["Smart Aura Position"], L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."], 1, C.Values.SmartAuraPositions)
	group.args.aurasGroup.args.auras = GetUnitAuras(unit, 'auras')
	group.args.aurasGroup.args.buffs = GetUnitAuras(unit, 'buffs')
	group.args.aurasGroup.args.debuffs = GetUnitAuras(unit, 'debuffs')

	group.args.healthGroup = ACH:Group(L["Health"], nil, 10, nil, function(info) return E.db.nameplates.units[unit].health[info[#info]] end, function(info, value) E.db.nameplates.units[unit].health[info[#info]] = value NP:ConfigureAll() end)
	group.args.healthGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, nil, function() return unit == 'PLAYER' end)
	group.args.healthGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = minHeight, max = MaxHeight(unit), step = 1 })
	group.args.healthGroup.args.width = ACH:Execute(L["Width"], nil, 4, function() ACD:SelectGroup('ElvUI', 'nameplates', 'generalGroup', 'clickableRange') end)
	group.args.healthGroup.args.healPrediction = ACH:Toggle(L["Heal Prediction"], nil, 5)
	group.args.healthGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 6)

	group.args.healthGroup.args.textGroup = ACH:Group(L["Text"], nil, 200, nil, function(info) return E.db.nameplates.units[unit].health.text[info[#info]] end, function(info, value) E.db.nameplates.units[unit].health.text[info[#info]] = value NP:ConfigureAll() end)
	group.args.healthGroup.args.textGroup.inline = true
	group.args.healthGroup.args.textGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.healthGroup.args.textGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.healthGroup.args.textGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = L["CENTER"], TOPLEFT = L["TOPLEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] })
	group.args.healthGroup.args.textGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.healthGroup.args.textGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.healthGroup.args.textGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.healthGroup.args.textGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.healthGroup.args.textGroup.args.fontGroup.inline = true
	group.args.healthGroup.args.textGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.healthGroup.args.textGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.healthGroup.args.textGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.powerGroup = ACH:Group(L["Power"], nil, 15, nil, function(info) return E.db.nameplates.units[unit].power[info[#info]] end, function(info, value) E.db.nameplates.units[unit].power[info[#info]] = value NP:ConfigureAll() end)
	group.args.powerGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.powerGroup.args.hideWhenEmpty = ACH:Toggle(L["Hide When Empty"], nil, 2)
	group.args.powerGroup.args.width = ACH:Range(L["Width"], nil, 3, { min = minWidth, max = MaxWidth(unit), step = 1 })
	group.args.powerGroup.args.height = ACH:Range(L["Height"], nil, 4, { min = minHeight, max = MaxHeight(unit), step = 1 })
	group.args.powerGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.powerGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
	group.args.powerGroup.args.displayAltPower = ACH:Toggle(L["Swap to Alt Power"], nil, 7)
	group.args.powerGroup.args.useAtlas = ACH:Toggle(L["Use Atlas Textures"], nil, 8)
	group.args.powerGroup.args.useClassColor = ACH:Toggle(L["Use Class Color"], nil, 9)
	group.args.powerGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 10)

	group.args.powerGroup.args.textGroup = ACH:Group(L["Text"], nil, 200, nil, function(info) return E.db.nameplates.units[unit].power.text[info[#info]] end, function(info, value) E.db.nameplates.units[unit].power.text[info[#info]] = value NP:ConfigureAll() end)
	group.args.powerGroup.args.textGroup.inline = true
	group.args.powerGroup.args.textGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.powerGroup.args.textGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.powerGroup.args.textGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = L["CENTER"], TOPLEFT = L["TOPLEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] })
	group.args.powerGroup.args.textGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.powerGroup.args.textGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.powerGroup.args.textGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.powerGroup.args.textGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.powerGroup.args.textGroup.args.fontGroup.inline = true
	group.args.powerGroup.args.textGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.powerGroup.args.textGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.powerGroup.args.textGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.castGroup = ACH:Group(L["Cast Bar"], nil, 20, 'tab', function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end, function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value NP:ConfigureAll() end)
	group.args.castGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.castGroup.args.sourceInterrupt = ACH:Toggle(L["Display Interrupt Source"], L["Display the unit name who interrupted a spell on the castbar. You should increase the Time to Hold to show properly."], 2)
	group.args.castGroup.args.sourceInterruptClassColor = ACH:Toggle(L["Class Color Source"], nil, 3, nil, nil, nil, nil, nil, function() return not E.db.nameplates.units[unit].castbar.sourceInterrupt end)
	group.args.castGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 5)

	-- order 4 is player Display Target
	group.args.castGroup.args.generalGroup = ACH:Group(L["General"], nil, 10)
	group.args.castGroup.args.generalGroup.args.timeToHold = ACH:Range(L["Time To Hold"], L["How many seconds the castbar should stay visible after the cast failed or was interrupted."], 5, { min = 0, max = 5, step = .1 })
	group.args.castGroup.args.generalGroup.args.width = ACH:Range(L["Width"], nil, 6, { min = minWidth, max = MaxWidth(unit), step = 1 })
	group.args.castGroup.args.generalGroup.args.height = ACH:Range(L["Height"], nil, 7, { min = minHeight, max = MaxHeight(unit), step = 1 })
	group.args.castGroup.args.generalGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -300, softMin = -100, softMax = 100, max = 300, step = 1 })
	group.args.castGroup.args.generalGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -300, softMin = -100, softMax = 100, max = 300, step = 1 })

	group.args.castGroup.args.generalGroup.args.iconGroup = ACH:Group(L["Icon"], nil, 21)
	group.args.castGroup.args.generalGroup.args.iconGroup.args.showIcon = ACH:Toggle(L["Show Icon"], nil, 1)
	group.args.castGroup.args.generalGroup.args.iconGroup.args.iconPosition = ACH:Select(L["Position"], nil, 3, { LEFT = L["Left"], RIGHT = L["Right"] })
	group.args.castGroup.args.generalGroup.args.iconGroup.args.iconSize = ACH:Range(L["Icon Size"], nil, 3, { min = 4, max = 40, step = 1 })
	group.args.castGroup.args.generalGroup.args.iconGroup.args.iconOffsetX = ACH:Range(L["X-Offset"], nil, 8, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.generalGroup.args.iconGroup.args.iconOffsetY = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.generalGroup.args.iconGroup.inline = true

	group.args.castGroup.args.textGroup = ACH:Group(L["Text"], nil, 20)
	group.args.castGroup.args.textGroup.args.hideSpellName = ACH:Toggle(L["Hide Spell Name"], nil, 1)
	group.args.castGroup.args.textGroup.args.hideTime = ACH:Toggle(L["Hide Time"], nil, 2)
	group.args.castGroup.args.textGroup.args.spellRename = ACH:Toggle(L["BigWigs Spell Rename"], L["Allows BigWigs to rename specific encounter spells on your castbar to something better to understand.\nExample: 'Impaling Eruption' becomes 'Frontal' and 'Twilight Massacre' becomes 'Dash'."], 3)
	group.args.castGroup.args.textGroup.args.textPosition = ACH:Select(L["Position"], nil, 5, { ONBAR = L["Cast Bar"], ABOVE = L["Above"], BELOW = L["Below"] })
	group.args.castGroup.args.textGroup.args.castTimeFormat = ACH:Select(L["Cast Time Format"], nil, 6, { CURRENT = L["Current"], CURRENTMAX = L["Current / Max"], REMAINING = L["Remaining"], REMAININGMAX = L["Remaining / Max"] })
	group.args.castGroup.args.textGroup.args.channelTimeFormat = ACH:Select(L["Channel Time Format"], nil, 7, { CURRENT = L["Current"], CURRENTMAX = L["Current / Max"], REMAINING = L["Remaining"], REMAININGMAX = L["Remaining / Max"] })

	group.args.castGroup.args.textGroup.args.time = ACH:Group(L["Time Options"], nil, 10)
	group.args.castGroup.args.textGroup.args.time.args.timeXOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.time.args.timeYOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.time.inline = true

	group.args.castGroup.args.textGroup.args.text = ACH:Group(L["Text Options"], nil, 11)
	group.args.castGroup.args.textGroup.args.text.args.textXOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.text.args.textYOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.text.inline = true

	group.args.castGroup.args.textGroup.args.fontGroup = ACH:Group(L["Font"], nil, 30)
	group.args.castGroup.args.textGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.castGroup.args.textGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.castGroup.args.textGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	group.args.castGroup.args.textGroup.args.fontGroup.inline = true

	group.args.privateAuras = ACH:Group(L["Private Auras"], nil, 35, nil, function(info) return E.db.nameplates.units[unit].privateAuras[info[#info]] end, function(info, value) E.db.nameplates.units[unit].privateAuras[info[#info]] = value NP:ConfigureAll() end, nil, not E.Retail)
	group.args.privateAuras.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.privateAuras.args.countdownFrame = ACH:Toggle(L["Cooldown Spiral"], nil, 3)
	group.args.privateAuras.args.countdownNumbers = ACH:Toggle(L["Cooldown Numbers"], nil, 4)

	group.args.privateAuras.args.icon = ACH:Group(L["Icon"], nil, 10, nil, function(info) return E.db.nameplates.units[unit].privateAuras.icon[info[#info]] end, function(info, value) E.db.nameplates.units[unit].privateAuras.icon[info[#info]] = value NP:ConfigureAll() end)
	group.args.privateAuras.args.icon.args.point = ACH:Select(L["Direction"], nil, 1, C.Values.EdgePositions)
	group.args.privateAuras.args.icon.args.offset = ACH:Range(L["Offset"], nil, 2, { min = -4, max = 64, step = 1 })
	group.args.privateAuras.args.icon.args.amount = ACH:Range(L["Amount"], nil, 3, { min = 1, max = 5, step = 1 })
	group.args.privateAuras.args.icon.args.size = ACH:Range(L["Size"], nil, 4, { min = 6, max = 80, step = 1 })
	group.args.privateAuras.args.icon.inline = true

	group.args.privateAuras.args.duration = ACH:Group(L["Duration"], nil, 20, nil, function(info) return E.db.nameplates.units[unit].privateAuras.duration[info[#info]] end, function(info, value) E.db.nameplates.units[unit].privateAuras.duration[info[#info]] = value NP:ConfigureAll() end)
	group.args.privateAuras.args.duration.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, 100)
	group.args.privateAuras.args.duration.args.point = ACH:Select(L["Point"], nil, 5, C.Values.AllPoints)
	group.args.privateAuras.args.duration.args.offsetX = ACH:Range(L["X-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
	group.args.privateAuras.args.duration.args.offsetY = ACH:Range(L["Y-Offset"], nil, 7, { min = -100, max = 100, step = 1 })
	group.args.privateAuras.args.duration.inline = true

	group.args.privateAuras.args.parent = ACH:Group(L["Holder"], nil, 20, nil, function(info) return E.db.nameplates.units[unit].privateAuras.parent[info[#info]] end, function(info, value) E.db.nameplates.units[unit].privateAuras.parent[info[#info]] = value NP:ConfigureAll() end)
	group.args.privateAuras.args.parent.args.point = ACH:Select(L["Point"], nil, 5, C.Values.AllPoints)
	group.args.privateAuras.args.parent.args.offsetX = ACH:Range(L["X-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
	group.args.privateAuras.args.parent.args.offsetY = ACH:Range(L["Y-Offset"], nil, 7, { min = -100, max = 100, step = 1 })
	group.args.privateAuras.args.parent.inline = true

	group.args.portraitGroup = ACH:Group(L["Portrait"], nil, 40, nil, function(info) return E.db.nameplates.units[unit].portrait[info[#info]] end, function(info, value) E.db.nameplates.units[unit].portrait[info[#info]] = value NP:ConfigureAll() end)
	group.args.portraitGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.portraitGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 12, max = 64, step = 1 })
	group.args.portraitGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 12, max = 64, step = 1 })
	group.args.portraitGroup.args.position = ACH:Select(L["Position"], nil, 4, C.Values.AllPositions)
	group.args.portraitGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.portraitGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.levelGroup = ACH:Group(L["Level"], nil, 45, nil, function(info) return E.db.nameplates.units[unit].level[info[#info]] end, function(info, value) E.db.nameplates.units[unit].level[info[#info]] = value NP:ConfigureAll() end)
	group.args.levelGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.levelGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.levelGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = L["CENTER"], TOPLEFT = L["TOPLEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] })
	group.args.levelGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.levelGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.levelGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.levelGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.levelGroup.args.fontGroup.inline = true
	group.args.levelGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.levelGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.levelGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.nameGroup = ACH:Group(L["Name"], nil, 50, nil, function(info) return E.db.nameplates.units[unit].name[info[#info]] end, function(info, value) E.db.nameplates.units[unit].name[info[#info]] = value NP:ConfigureAll() end)
	group.args.nameGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.nameGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.nameGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = L["CENTER"], TOPLEFT = L["TOPLEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] })
	group.args.nameGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.nameGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.nameGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.nameGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.nameGroup.args.fontGroup.inline = true
	group.args.nameGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.nameGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.nameGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.titleGroup = ACH:Group(L["UNIT_NAME_PLAYER_TITLE"], nil, 55, nil, function(info) return E.db.nameplates.units[unit].title[info[#info]] end, function(info, value) E.db.nameplates.units[unit].title[info[#info]] = value NP:ConfigureAll() end)
	group.args.titleGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.titleGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.titleGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = L["CENTER"], TOPLEFT = L["TOPLEFT"], BOTTOMLEFT = L["BOTTOMLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] })
	group.args.titleGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.titleGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.titleGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.titleGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.titleGroup.args.fontGroup.inline = true
	group.args.titleGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.titleGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.titleGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.pvpindicator = ACH:Group(L["PvP Indicator"], L["Horde / Alliance / Honor Info"], 60, nil, function(info) return E.db.nameplates.units[unit].pvpindicator[info[#info]] end, function(info, value) E.db.nameplates.units[unit].pvpindicator[info[#info]] = value NP:ConfigureAll() end)
	group.args.pvpindicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.pvpindicator.args.showBadge = ACH:Toggle(L["Show Badge"], L["Show PvP Badge Indicator if available"], 2)
	group.args.pvpindicator.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
	group.args.pvpindicator.args.position = ACH:Select(L["Position"], nil, 4, C.Values.AllPositions)
	group.args.pvpindicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.pvpindicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.raidTargetIndicator = ACH:Group(L["Target Marker Icon"], nil, 65, nil, function(info) return E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] end, function(info, value) E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] = value NP:ConfigureAll() end)
	group.args.raidTargetIndicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.raidTargetIndicator.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
	group.args.raidTargetIndicator.args.position = ACH:Select(L["Position"], nil, 4, C.Values.AllPositions)
	group.args.raidTargetIndicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.raidTargetIndicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	if unit == 'PLAYER' then
		group.args.classBarGroup = ACH:Group(L["Class Bar"], nil, 80, nil, function(info) return E.db.nameplates.units[unit].classpower[info[#info]] end, function(info, value) E.db.nameplates.units[unit].classpower[info[#info]] = value NP:ConfigureAll() end)
		group.args.classBarGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.classBarGroup.args.classColor = ACH:Toggle(L["Use Class Color"], nil, 2, nil, nil, nil, nil, nil, nil, not E.Retail and E.myclass == 'DEATHKNIGHT')
		group.args.classBarGroup.args.width = ACH:Range(L["Width"], nil, 3, { min = minWidth, max = MaxWidth(unit), step = 1 })
		group.args.classBarGroup.args.height = ACH:Range(L["Height"], nil, 4, { min = minHeight, max = MaxHeight(unit), step = 1 })
		group.args.classBarGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
		group.args.classBarGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
		group.args.classBarGroup.args.sortDirection = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 7, { asc = L["Ascending"], desc = L["Descending"], NONE = L["None"] }, nil, nil, nil, nil, nil, function() return (E.myclass ~= 'DEATHKNIGHT') end)

		group.args.castGroup.args.displayTarget = ACH:Toggle(L["Display Target"], L["Display the target of current cast."], 4)

		group.args.general.args.useStaticPosition = ACH:Toggle(L["Use Static Position"], L["When enabled the nameplate will stay visible in a locked position."], 105, nil, nil, nil, nil, nil, function() return not E.db.nameplates.units[unit].enable end)
	elseif unit == 'FRIENDLY_PLAYER' or unit == 'ENEMY_PLAYER' then
		group.args.general.args.markHealers = ACH:Toggle(L["Healer Icon"], L["Display a healer icon over known healers inside battlegrounds or arenas."], 105)
		group.args.general.args.markTanks = ACH:Toggle(L["Tank Icon"], L["Display a tank icon over known tanks inside battlegrounds or arenas."], 106)
	elseif unit == 'ENEMY_NPC' or unit == 'FRIENDLY_NPC' then
		group.args.eliteIcon = ACH:Group(L["Elite Icon"], nil, 75, nil, function(info) return E.db.nameplates.units[unit].eliteIcon[info[#info]] end, function(info, value) E.db.nameplates.units[unit].eliteIcon[info[#info]] = value NP:ConfigureAll() end)
		group.args.eliteIcon.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.eliteIcon.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
		group.args.eliteIcon.args.position = ACH:Select(L["Position"], nil, 4, C.Values.AllPositions)
		group.args.eliteIcon.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
		group.args.eliteIcon.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

		group.args.castGroup.args.displayTarget = ACH:Toggle(L["Display Target"], L["Display the target of current cast."], 4)

		group.args.questIcon = ACH:Group(L["Quest Icon"], nil, 70, nil, function(info) return E.db.nameplates.units[unit].questIcon[info[#info]] end, function(info, value) E.db.nameplates.units[unit].questIcon[info[#info]] = value NP:ConfigureAll() end, nil, E.Classic)
		group.args.questIcon.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.questIcon.args.hideIcon = ACH:Toggle(L["Hide Icon"], nil, 2)
		group.args.questIcon.args.position = ACH:Select(L["Position"], nil, 3, C.Values.AllPositions)
		group.args.questIcon.args.spacer1 = ACH:Spacer(5, 'full')
		group.args.questIcon.args.size = ACH:Range(L["Size"], nil, 6, { min = 12, max = 64, step = 1 })
		group.args.questIcon.args.spacing = ACH:Range(L["Spacing"], nil, 7, { min = -20, max = 20, step = 1 })
		group.args.questIcon.args.xOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -80, max = 80, step = 1 })
		group.args.questIcon.args.yOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -80, max = 80, step = 1 })

		group.args.questIcon.args.fontGroup = ACH:Group('', nil, 20)
		group.args.questIcon.args.fontGroup.inline = true
		group.args.questIcon.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
		group.args.questIcon.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, { min = 4, max = 60, step = 1 })
		group.args.questIcon.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
		group.args.questIcon.args.fontGroup.args.spacer1 = ACH:Spacer(5, 'full')
		group.args.questIcon.args.fontGroup.args.textPosition = ACH:Select(L["Text Position"], nil, 6, C.Values.AllPoints)
		group.args.questIcon.args.fontGroup.args.textXOffset = ACH:Range(L["X-Offset"], nil, 7, { min = -20, max = 20, step = 1 })
		group.args.questIcon.args.fontGroup.args.textYOffset = ACH:Range(L["Y-Offset"], nil, 8, { min = -20, max = 20, step = 1 })
	end

	if unit == 'PLAYER' or unit == 'FRIENDLY_PLAYER' or unit == 'ENEMY_PLAYER' then
		group.args.healthGroup.args.useClassColor = ACH:Toggle(L["Use Class Color"], nil, 10)

		group.args.portraitGroup.args.specicon = ACH:Toggle(L["Spec Icon"], nil, 21, nil, nil, nil, nil, nil, nil, not E.Retail)
		group.args.portraitGroup.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 22, nil, nil, nil, nil, nil, nil, not E.Retail)

		group.args.pvpclassificationindicator = ACH:Group(L["PvP Classification Indicator"], L["Cart / Flag / Orb / Assassin Bounty"], 70, nil, function(info) return E.db.nameplates.units[unit].pvpclassificationindicator[info[#info]] end, function(info, value) E.db.nameplates.units[unit].pvpclassificationindicator[info[#info]] = value NP:ConfigureAll() end)
		group.args.pvpclassificationindicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.pvpclassificationindicator.args.size = ACH:Range(L["Size"], nil, 2, { min = 12, max = 64, step = 1 })
		group.args.pvpclassificationindicator.args.position = ACH:Select(L["Position"], nil, 3, C.Values.AllPositions)
		group.args.pvpclassificationindicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
		group.args.pvpclassificationindicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	end

	ORDER = ORDER + 2
	return group
end

E.Options.args.nameplates = ACH:Group(L["Nameplates"], nil, 2, 'tab', function(info) return E.db.nameplates[info[#info]] end, function(info, value) E.db.nameplates[info[#info]] = value; NP:ConfigureAll() end)
local NamePlates = E.Options.args.nameplates.args

NamePlates.intro = ACH:Description(L["NAMEPLATE_DESC"], 0)
NamePlates.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.private.nameplates[info[#info]] end, function(info, value) E.private.nameplates[info[#info]] = value E.ShowPopup = true end)
NamePlates.statusbar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 2)
NamePlates.resetFilters = ACH:Execute(L["Reset Aura Filters"], nil, 3, function() E:StaticPopup_Show('RESET_NP_AF') end)
NamePlates.resetcvars = ACH:Execute(L["Reset CVars"], L["Reset Nameplate CVars to the ElvUI recommended defaults."], 4, function() NP:CVarReset() end, nil, true)

NamePlates.generalGroup = ACH:Group(L["General"], nil, 5, nil, nil, function(info, value) E.db.nameplates[info[#info]] = value NP:SetCVars() NP:ConfigureAll() end, function() return not E.NamePlates.Initialized end)
NamePlates.generalGroup.args.motionType = ACH:Select(L["UNIT_NAMEPLATES_TYPES"], L["Set to either stack nameplates vertically or allow them to overlap."], 1, { STACKED = L["UNIT_NAMEPLATES_TYPE_2"], OVERLAP = L["UNIT_NAMEPLATES_TYPE_1"] })
NamePlates.generalGroup.args.showEnemyCombat = ACH:Select(L["Enemy Combat Toggle"], L["Control enemy nameplates toggling on or off when in combat."], 2, { DISABLED = L["Disable"], TOGGLE_ON = L["Toggle On While In Combat"], TOGGLE_OFF = L["Toggle Off While In Combat"] }, nil, nil, nil, function(info, value) E.db.nameplates[info[#info]] = value NP:PLAYER_REGEN_ENABLED() end)
NamePlates.generalGroup.args.showFriendlyCombat = ACH:Select(L["Friendly Combat Toggle"], L["Control friendly nameplates toggling on or off when in combat."], 3, { DISABLED = L["Disable"], TOGGLE_ON = L["Toggle On While In Combat"], TOGGLE_OFF = L["Toggle Off While In Combat"] }, nil, nil, nil, function(info, value) E.db.nameplates[info[#info]] = value NP:PLAYER_REGEN_ENABLED() end)
NamePlates.generalGroup.args.clampToScreen = ACH:Toggle(L["Clamp Nameplates"], L["Clamp nameplates to the top of the screen when outside of view."], 5, nil, nil, 140)
NamePlates.generalGroup.args.spacer1 = ACH:Spacer(6, 'full')
NamePlates.generalGroup.args.overlapV = ACH:Range(L["Overlap Vertical"], L["Percentage amount for vertical overlap of Nameplates."], 10, { min = 0, max = 3, step = .1 })
NamePlates.generalGroup.args.overlapH = ACH:Range(L["Overlap Horizontal"], L["Percentage amount for horizontal overlap of Nameplates."], 10, { min = 0, max = 3, step = .1 })
NamePlates.generalGroup.args.lowHealthThreshold = ACH:Range(L["Low Health Threshold"], L["Make the unitframe glow when it is below this percent of health."], 11, { min = 0, softMax = .5, max = .8, step = .01, isPercent = true })
NamePlates.generalGroup.args.loadDistance = ACH:Range(L["Load Distance"], L["Only load nameplates for units within this range."], 12, { min = 0, max = 41, step = 1 }, nil, nil, nil, nil, E.Classic or E.Retail)
NamePlates.generalGroup.args.highlight = ACH:Toggle(L["Hover Highlight"], nil, 13, nil, nil, 125)
NamePlates.generalGroup.args.fadeIn = ACH:Toggle(L["Alpha Fading"], nil, 14, nil, nil, 125)

NamePlates.generalGroup.args.spacer2 = ACH:Spacer(15, 'full')
NamePlates.generalGroup.args.plateVisibility = ACH:Group(L["Visibility"], nil, 50)
NamePlates.generalGroup.args.plateVisibility.args.showAll = ACH:Toggle(L["UNIT_NAMEPLATES_AUTOMODE"], L["This option controls the Blizzard setting for whether or not the Nameplates should be shown."], 0, nil, nil, 250, function(info) return E.db.nameplates.visibility[info[#info]] end, function(info, value) E.db.nameplates.visibility[info[#info]] = value NP:SetCVars() NP:ConfigureAll() end)
NamePlates.generalGroup.args.plateVisibility.args.showAlways = ACH:Toggle(L["Always Show Player"], nil, 1, nil, nil, nil, function(info) return E.db.nameplates.units.PLAYER.visibility[info[#info]] end, function(info, value) E.db.nameplates.units.PLAYER.visibility[info[#info]] = value NP:SetCVars() NP:ConfigureAll() end, nil, not E.Retail)
NamePlates.generalGroup.args.plateVisibility.args.cvars = ACH:MultiSelect(L["Blizzard CVars"], nil, 3, { nameplateOtherAtBase = L["Nameplate At Base"], nameplateShowOnlyNames = L["Show Only Names"] }, nil, nil, function(_, key) return E.db.nameplates.visibility[key] or GetCVarBool(key) end, function(_, key, value) E:SetCVar(key, value and (key == 'nameplateOtherAtBase' and 2 or 1) or 0) if key == 'nameplateShowOnlyNames' then E.db.nameplates.visibility[key] = value end end)
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility = ACH:Group(L["Player"], nil, 5, nil, function(info) return E.db.nameplates.units.PLAYER.visibility[info[#info]] end, function(info, value) E.db.nameplates.units.PLAYER.visibility[info[#info]] = value NP:SetCVars() NP:ConfigureAll() end, nil, not E.Retail)
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility.inline = true
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility.args.showInCombat = ACH:Toggle(L["Show In Combat"], nil, 1, nil, nil, nil, nil, nil, function() return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways end)
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility.args.showWithTarget = ACH:Toggle(L["Show With Target"], L["When using Static Position, this option also requires the target to be attackable."], 2, nil, nil, nil, nil, nil, function() return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways end)
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility.args.spacer1 = ACH:Spacer(3, 'full')
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility.args.hideDelay = ACH:Range(L["Hide Delay"], nil, 4, { min = 0, max = 20, step = .01, bigStep = 1 }, nil, nil, nil, function() return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways end)
NamePlates.generalGroup.args.plateVisibility.args.playerVisibility.args.alphaDelay = ACH:Range(L["Delay Alpha"], nil, 5, { min = 0, max = 1, step = .01, bigStep = .1 }, nil, nil, nil, function() return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways end)

NamePlates.generalGroup.args.plateVisibility.args.enemyVisibility = ACH:MultiSelect(L["Enemy"], nil, 10, { guardians = L["Guardians"], minions = L["Minions"], minus = L["Minus"], pets = L["Pets"], totems = L["Totems"] }, nil, nil, function(_, key) return E.db.nameplates.visibility.enemy[key] end, function(_, key, value) E.db.nameplates.visibility.enemy[key] = value NP:SetCVars() NP:ConfigureAll() end, function() return not E.db.nameplates.visibility.showAll end)
NamePlates.generalGroup.args.plateVisibility.args.friendlyVisibility = ACH:MultiSelect(L["Friendly"], nil, 15, { guardians = L["Guardians"], minions = L["Minions"], npcs = L["NPC"], pets = L["Pets"], totems = L["Totems"] }, nil, nil, function(_, key) return E.db.nameplates.visibility.friendly[key] end, function(_, key, value) E.db.nameplates.visibility.friendly[key] = value NP:SetCVars() NP:ConfigureAll() end, function() return not E.db.nameplates.visibility.showAll end)

local envConditions = { party = L["Dungeons"], raid = L["Raids"], scenario = L["Scenario"], arena = L["Arena"], pvp = L["Battleground"], resting = L["Resting"], world = L["World"] }
NamePlates.generalGroup.args.enviromentConditions = ACH:Group(L["Enviroment Conditions"], nil, 60, nil, function(info) return E.db.nameplates.enviromentConditions[info[#info]] end, function(info, value) E.db.nameplates.enviromentConditions[info[#info]] = value NP:EnviromentConditionals() end)
NamePlates.generalGroup.args.enviromentConditions.args.enemyEnabled = ACH:Toggle(L["Enemy Enabled"], L["This option controls whether nameplates will follow the visibility settings below.\n|cffFF3333Warning:|r This will be overridden by the Enemy Combat Toggle."], 10, nil, nil, 250)
NamePlates.generalGroup.args.enviromentConditions.args.enemy = ACH:MultiSelect(L["Enemy"], nil, 11, envConditions, nil, nil, function(_, key) return E.db.nameplates.enviromentConditions.enemy[key] end, function(_, key, value) E.db.nameplates.enviromentConditions.enemy[key] = value NP:EnviromentConditionals() end, nil, function() return not E.db.nameplates.enviromentConditions.enemyEnabled end)
NamePlates.generalGroup.args.enviromentConditions.args.friendlyEnabled = ACH:Toggle(L["Friendly Enabled"], L["This option controls whether nameplates will follow the visibility settings below.\n|cffFF3333Warning:|r This will be overridden by the Friendly Combat Toggle."], 20, nil, nil, 250)
NamePlates.generalGroup.args.enviromentConditions.args.friendly = ACH:MultiSelect(L["Friendly"], nil, 21, envConditions, nil, nil, function(_, key) return E.db.nameplates.enviromentConditions.friendly[key] end, function(_, key, value) E.db.nameplates.enviromentConditions.friendly[key] = value NP:EnviromentConditionals() end, nil, function() return not E.db.nameplates.enviromentConditions.friendlyEnabled end)
NamePlates.generalGroup.args.enviromentConditions.args.stackingEnabled = ACH:Toggle(L["Stacking Enabled"], L["This option controls whether nameplates will follow the settings below.\n|cffFF3333Warning:|r This is an override to the Motion Type setting."], 30, nil, nil, 250)
NamePlates.generalGroup.args.enviromentConditions.args.stacking = ACH:MultiSelect(L["Stacking Plates"], nil, 31, envConditions, nil, nil, function(_, key) return E.db.nameplates.enviromentConditions.stackingNameplates[key] end, function(_, key, value) E.db.nameplates.enviromentConditions.stackingNameplates[key] = value NP:EnviromentConditionals() end, nil, function() return not E.db.nameplates.enviromentConditions.stackingEnabled end)

NamePlates.generalGroup.args.bossMods = ACH:Group(L["Boss Mod Auras"], nil, 55, nil, function(info) return E.db.nameplates.bossMods[info[#info]] end, function(info, value) E.db.nameplates.bossMods[info[#info]] = value NP:ConfigureAll() end)
NamePlates.generalGroup.args.bossMods.args.enable = ACH:Toggle(L["Enable"], nil, 0)
NamePlates.generalGroup.args.bossMods.args.supported = ACH:Group(L["Supported"], nil, 1)
NamePlates.generalGroup.args.bossMods.args.supported.inline = true
NamePlates.generalGroup.args.bossMods.args.supported.args.dbm = GetAddOnStatus(1, 'Deadly Boss Mods', 'DBM-Core')
NamePlates.generalGroup.args.bossMods.args.supported.args.bw = GetAddOnStatus(2, 'BigWigs', 'BigWigs')
NamePlates.generalGroup.args.bossMods.args.settings = ACH:Group(' ', nil, 2, nil, nil, nil, function() return not E.db.nameplates.bossMods.enable or not (IsAddOnLoaded('BigWigs') or IsAddOnLoaded('DBM-Core')) end)
NamePlates.generalGroup.args.bossMods.args.settings.inline = true
NamePlates.generalGroup.args.bossMods.args.settings.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 1)
NamePlates.generalGroup.args.bossMods.args.settings.args.size = ACH:Range(function() return E.db.nameplates.bossMods.keepSizeRatio and L["Icon Size"] or L["Icon Width"] end, nil, 2, { min = 6, max = 64, step = 1 })
NamePlates.generalGroup.args.bossMods.args.settings.args.height = ACH:Range(L["Icon Height"], nil, 3, { min = 6, max = 64, step = 1 }, nil, nil, nil, nil, function() return E.db.nameplates.bossMods.keepSizeRatio end)
NamePlates.generalGroup.args.bossMods.args.settings.args.spacing = ACH:Range(L["Spacing"], nil, 4, { min = 6, max = 64, step = 1 }, nil, nil, nil, nil, function() return E.db.nameplates.bossMods.keepSizeRatio end)
NamePlates.generalGroup.args.bossMods.args.settings.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
NamePlates.generalGroup.args.bossMods.args.settings.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
NamePlates.generalGroup.args.bossMods.args.settings.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 7, C.Values.Anchors)
NamePlates.generalGroup.args.bossMods.args.settings.args.growthX = ACH:Select(L["Growth X-Direction"], nil, 8, { LEFT = L["Left"], RIGHT = L["Right"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.bossMods.anchorPoint return point == 'LEFT' or point == 'RIGHT' or not (IsAddOnLoaded('BigWigs') or IsAddOnLoaded('DBM-Core')) end)
NamePlates.generalGroup.args.bossMods.args.settings.args.growthY = ACH:Select(L["Growth Y-Direction"], nil, 9, { UP = L["Up"], DOWN = L["Down"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.bossMods.anchorPoint return point == 'TOP' or point == 'BOTTOM' or not (IsAddOnLoaded('BigWigs') or IsAddOnLoaded('DBM-Core')) end)

NamePlates.generalGroup.args.clickThrough = ACH:Group(L["Click Through"], nil, 65, nil, function(info) return E.db.nameplates.clickThrough[info[#info]] end)
NamePlates.generalGroup.args.clickThrough.args.personal = ACH:Toggle(L["Personal"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.nameplates.clickThrough[info[#info]] = value NP:SetNamePlateSelfClickThrough() end)
NamePlates.generalGroup.args.clickThrough.args.friendly = ACH:Toggle(L["Friendly"], nil, 2, nil, nil, nil, nil, function(info, value) E.db.nameplates.clickThrough[info[#info]] = value NP:SetNamePlateFriendlyClickThrough() end)
NamePlates.generalGroup.args.clickThrough.args.enemy = ACH:Toggle(L["Enemy"], nil, 3, nil, nil, nil, nil, function(info, value) E.db.nameplates.clickThrough[info[#info]] = value NP:SetNamePlateEnemyClickThrough() end)

NamePlates.generalGroup.args.clickableRange = ACH:Group(L["Clickable Size"], nil, 70, nil, function(info) return E.db.nameplates.plateSize[info[#info]] end, function(info, value) E.db.nameplates.plateSize[info[#info]] = value NP:ConfigureAll() end)
NamePlates.generalGroup.args.clickableRange.args.personal = ACH:Group(L["Personal"], nil, 1)
NamePlates.generalGroup.args.clickableRange.args.personal.inline = true
NamePlates.generalGroup.args.clickableRange.args.personal.args.personalWidth = ACH:Range(L["Clickable Width / Width"], L["Change the width and controls how big of an area on the screen will accept clicks to target unit."], 1, { min = 1, max = 250, step = 1 })
NamePlates.generalGroup.args.clickableRange.args.personal.args.personalHeight = ACH:Range(L["Clickable Height"], L["Controls how big of an area on the screen will accept clicks to target unit."], 2, { min = 1, max = 75, step = 1 })

NamePlates.generalGroup.args.clickableRange.args.friendly = ACH:Group(L["Friendly"], nil, 2)
NamePlates.generalGroup.args.clickableRange.args.friendly.inline = true
NamePlates.generalGroup.args.clickableRange.args.friendly.args.friendlyWidth = ACH:Range(L["Clickable Width / Width"], L["Change the width and controls how big of an area on the screen will accept clicks to target unit."], 1, { min = 1, max = 250, step = 1 })
NamePlates.generalGroup.args.clickableRange.args.friendly.args.friendlyHeight = ACH:Range(L["Clickable Height"], L["Controls how big of an area on the screen will accept clicks to target unit."], 2, { min = 1, max = 75, step = 1 })

NamePlates.generalGroup.args.clickableRange.args.enemy = ACH:Group(L["Enemy"], nil, 3)
NamePlates.generalGroup.args.clickableRange.args.enemy.inline = true
NamePlates.generalGroup.args.clickableRange.args.enemy.args.enemyWidth = ACH:Range(L["Clickable Width / Width"], L["Change the width and controls how big of an area on the screen will accept clicks to target unit."], 1, { min = 1, max = 250, step = 1 })
NamePlates.generalGroup.args.clickableRange.args.enemy.args.enemyHeight = ACH:Range(L["Clickable Height"], L["Controls how big of an area on the screen will accept clicks to target unit."], 2, { min = 1, max = 75, step = 1 })

NamePlates.generalGroup.args.cutaway = ACH:Group(L["Cutaway Bars"], nil, 75)
NamePlates.generalGroup.args.cutaway.args.health = ACH:Group(L["Health"], nil, 1, nil, function(info) return E.db.nameplates.cutaway.health[info[#info]] end, function(info, value) E.db.nameplates.cutaway.health[info[#info]] = value NP:ConfigureAll() end)
NamePlates.generalGroup.args.cutaway.args.health.inline = true
NamePlates.generalGroup.args.cutaway.args.health.args.enabled = ACH:Toggle(L["Enable"], nil, 1)
NamePlates.generalGroup.args.cutaway.args.health.args.forceBlankTexture = ACH:Toggle(L["Blank Texture"], nil, 2)
NamePlates.generalGroup.args.cutaway.args.health.args.lengthBeforeFade = ACH:Range(L["Fade Out Delay"], L["How much time before the cutaway health starts to fade."], 3, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.nameplates.cutaway.health.enabled end)
NamePlates.generalGroup.args.cutaway.args.health.args.fadeOutTime = ACH:Range(L["Fade Out"], L["How long the cutaway health will take to fade out."], 4, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.nameplates.cutaway.health.enabled end)

NamePlates.generalGroup.args.cutaway.args.power = ACH:Group(L["Power"], nil, 2, nil, function(info) return E.db.nameplates.cutaway.power[info[#info]] end, function(info, value) E.db.nameplates.cutaway.power[info[#info]] = value NP:ConfigureAll() end)
NamePlates.generalGroup.args.cutaway.args.power.inline = true
NamePlates.generalGroup.args.cutaway.args.power.args.enabled = ACH:Toggle(L["Enable"], nil, 1)
NamePlates.generalGroup.args.cutaway.args.power.args.forceBlankTexture = ACH:Toggle(L["Blank Texture"], nil, 2)
NamePlates.generalGroup.args.cutaway.args.power.args.lengthBeforeFade = ACH:Range(L["Fade Out Delay"], L["How much time before the cutaway power starts to fade."], 3, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.nameplates.cutaway.power.enabled end)
NamePlates.generalGroup.args.cutaway.args.power.args.fadeOutTime = ACH:Range(L["Fade Out"], L["How long the cutaway power will take to fade out."], 4, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.nameplates.cutaway.power.enabled end)

NamePlates.generalGroup.args.threatGroup = ACH:Group(L["Threat"], nil, 80, nil, function(info) return E.db.nameplates.threat[info[#info]] end, function(info, value) E.db.nameplates.threat[info[#info]] = value NP:ConfigureAll() end)
NamePlates.generalGroup.args.threatGroup.args.enable = ACH:Toggle(L["Enable"], nil, 0)
NamePlates.generalGroup.args.threatGroup.args.goodScale = ACH:Range(L["Good Scale"], nil, 1, { min = .5, max = 1.5, step = .01, isPercent = true }, nil, nil, nil, function() return not E.db.nameplates.threat.enable end)
NamePlates.generalGroup.args.threatGroup.args.badScale = ACH:Range(L["Bad Scale"], nil, 2, { min = .5, max = 1.5, step = .01, isPercent = true }, nil, nil, nil, function() return not E.db.nameplates.threat.enable end)
NamePlates.generalGroup.args.threatGroup.args.useThreatColor = ACH:Toggle(L["Use Threat Color"], nil, 3)
NamePlates.generalGroup.args.threatGroup.args.beingTankedByTank = ACH:Toggle(L["Off Tank"], L["Use Off Tank Color when another Tank has threat."], 4, nil, nil, nil, nil, nil, function() return not E.db.nameplates.threat.useThreatColor end)
NamePlates.generalGroup.args.threatGroup.args.beingTankedByPet = ACH:Toggle(L["Off Tank (Pets)"], nil, 5, nil, nil, nil, nil, nil, function() return not E.db.nameplates.threat.useThreatColor end)
NamePlates.generalGroup.args.threatGroup.args.indicator = ACH:Toggle(L["Show Icon"], nil, 6, nil, nil, nil, nil, nil, function() return not E.db.nameplates.threat.enable end)

NamePlates.generalGroup.args.widgetGroup = ACH:Group(L["Widget"], nil, 90, nil, function(info) return E.db.nameplates.widgets[info[#info]] end, function(info, value) E.db.nameplates.widgets[info[#info]] = value NP:ConfigureAll() end)
NamePlates.generalGroup.args.widgetGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 1, { min = -100, max = 100, step = 1 })
NamePlates.generalGroup.args.widgetGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 2, { min = -100, max = 100, step = 1 })
NamePlates.generalGroup.args.widgetGroup.args.below = ACH:Toggle(L["Below"], nil, 3)

NamePlates.colorsGroup = ACH:Group(L["Colors"], nil, 15, nil, nil, nil, function() return not E.NamePlates.Initialized end)
NamePlates.colorsGroup.args.general = ACH:Group(L["General"], nil, 1, nil, function(info) local t, d = E.db.nameplates.colors[info[#info]], P.nameplates.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end)
NamePlates.colorsGroup.args.general.inline = true

do
	local function GetToggle(info) return E.db.nameplates.colors[info[#info]] end
	local function SetToggle(info, value) E.db.nameplates.colors[info[#info]] = value NP:ConfigureAll() end
	NamePlates.colorsGroup.args.general.args.preferGlowColor = ACH:Toggle(L["Prefer Target Color"], L["When this is enabled, Low Health Threshold colors will not be displayed while targeted."], 1, nil, nil, nil, GetToggle, SetToggle)
	NamePlates.colorsGroup.args.general.args.auraByDispels = ACH:Toggle(L["Borders By Dispel"], nil, 2, nil, nil, nil, GetToggle, SetToggle)
	NamePlates.colorsGroup.args.general.args.auraByType = ACH:Toggle(L["Borders By Type"], nil, 3, nil, nil, nil, GetToggle, SetToggle)
end

NamePlates.colorsGroup.args.general.args.spacer1 = ACH:Spacer(5, 'full')
NamePlates.colorsGroup.args.general.args.glowColor = ACH:Color(L["Target Indicator Color"], nil, 6, true)
NamePlates.colorsGroup.args.general.args.lowHealthColor = ACH:Color(L["Low Health Color"], L["Color when at Low Health Threshold"], 7, true)
NamePlates.colorsGroup.args.general.args.lowHealthHalf = ACH:Color(L["Low Health Half"], L["Color when at half of the Low Health Threshold"], 8, true)

NamePlates.colorsGroup.args.threat = ACH:Group(L["Threat"], nil, 2, nil, function(info) local t, d = E.db.nameplates.colors.threat[info[#info]], P.nameplates.colors.threat[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.threat[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end, function() return not E.db.nameplates.threat.useThreatColor end)
NamePlates.colorsGroup.args.threat.inline = true
NamePlates.colorsGroup.args.threat.args.goodColor = ACH:Color(L["Good Color"], nil, 1)
NamePlates.colorsGroup.args.threat.args.goodTransition = ACH:Color(L["Good Transition Color"], nil, 2)
NamePlates.colorsGroup.args.threat.args.badTransition = ACH:Color(L["Bad Transition Color"], nil, 3)
NamePlates.colorsGroup.args.threat.args.badColor = ACH:Color(L["Bad Color"], nil, 4)
NamePlates.colorsGroup.args.threat.args.offTankColor = ACH:Color(L["Off Tank"], nil, 5, nil, nil, nil, nil, nil, function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end)
NamePlates.colorsGroup.args.threat.args.offTankColorGoodTransition = ACH:Color(L["Off Tank Good Transition"], nil, 6, nil, nil, nil, nil, function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end)
NamePlates.colorsGroup.args.threat.args.offTankColorBadTransition = ACH:Color(L["Off Tank Bad Transition"], nil, 7, nil, nil, nil, nil, function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end)

NamePlates.colorsGroup.args.castGroup = ACH:Group(L["Cast Bar"], nil, 3, nil, function(info) local t, d = E.db.nameplates.colors[info[#info]], P.nameplates.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)
NamePlates.colorsGroup.args.castGroup.inline = true
NamePlates.colorsGroup.args.castGroup.args.castColor = ACH:Color(L["Interruptible"], nil, 1)
NamePlates.colorsGroup.args.castGroup.args.castNoInterruptColor = ACH:Color(L["Non-Interruptible"], nil, 2)
NamePlates.colorsGroup.args.castGroup.args.castInterruptedColor = ACH:Color(L["Interrupted"], nil, 3)
NamePlates.colorsGroup.args.castGroup.args.castbarDesaturate = ACH:Toggle(L["Desaturated Icon"], L["Show the castbar icon desaturated if a spell is not interruptible."], 4, nil, nil, nil, function(info) return E.db.nameplates.colors[info[#info]] end, function(info, value) E.db.nameplates.colors[info[#info]] = value NP:ConfigureAll() end)

NamePlates.colorsGroup.args.castGroup.args.empowerStage = ACH:Group(L["Empower Stages"], nil, 20, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.nameplates.colors.empoweredCast[i], P.nameplates.colors.empoweredCast[i] return t.r, t.g, t.b, 1, d.r, d.g, d.b, 1 end, function(info, r, g, b) local t = E.db.nameplates.colors.empoweredCast[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end, nil, not E.Retail)
NamePlates.colorsGroup.args.castGroup.args.empowerStage.inline = true

for i in next, P.nameplates.colors.empoweredCast do
	NamePlates.colorsGroup.args.castGroup.args.empowerStage.args[''..i] = ACH:Color(C.Values.Roman[i])
end

NamePlates.colorsGroup.args.selectionGroup = ACH:Group(L["Selection"], nil, 4, nil, function(info) local n = tonumber(info[#info]) local t, d = E.db.nameplates.colors.selection[n], P.nameplates.colors.selection[n] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.selection[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)
NamePlates.colorsGroup.args.selectionGroup.inline = true
NamePlates.colorsGroup.args.selectionGroup.args['0'] = ACH:Color(L["Hostile"], nil, 0)
NamePlates.colorsGroup.args.selectionGroup.args['1'] = ACH:Color(L["Unfriendly"], nil, 1)
NamePlates.colorsGroup.args.selectionGroup.args['2'] = ACH:Color(L["Neutral"], nil, 2)
NamePlates.colorsGroup.args.selectionGroup.args['3'] = ACH:Color(L["Friendly"], nil, 3)
NamePlates.colorsGroup.args.selectionGroup.args['5'] = ACH:Color(L["Player"], nil, 5)
NamePlates.colorsGroup.args.selectionGroup.args['6'] = ACH:Color(L["Party"], nil, 6)
NamePlates.colorsGroup.args.selectionGroup.args['7'] = ACH:Color(L["Party PVP"], nil, 7)
NamePlates.colorsGroup.args.selectionGroup.args['8'] = ACH:Color(L["Friend"], nil, 8)
NamePlates.colorsGroup.args.selectionGroup.args['9'] = ACH:Color(L["Dead"], nil, 9)
NamePlates.colorsGroup.args.selectionGroup.args['13'] = ACH:Color(L["Battleground Friendly"], nil, 13)

NamePlates.colorsGroup.args.reactions = ACH:Group(L["Reaction Colors"], nil, 5, nil, function(info) local t, d = E.db.nameplates.colors.reactions[info[#info]], P.nameplates.colors.reactions[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.reactions[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)
NamePlates.colorsGroup.args.reactions.inline = true
NamePlates.colorsGroup.args.reactions.args.bad = ACH:Color(L["Enemy"], nil, 1)
NamePlates.colorsGroup.args.reactions.args.neutral = ACH:Color(L["Neutral"], nil, 2)
NamePlates.colorsGroup.args.reactions.args.good = ACH:Color(L["Friendly"], nil, 3)
NamePlates.colorsGroup.args.reactions.args.tapped = ACH:Color(L["Tagged NPC"], nil, 4, nil, nil, function(info) local t, d = E.db.nameplates.colors[info[#info]], P.nameplates.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)

NamePlates.colorsGroup.args.healPrediction = ACH:Group(L["Heal Prediction"], nil, 6, nil, function(info) local t, d = E.db.nameplates.colors.healPrediction[info[#info]], P.nameplates.colors.healPrediction[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.healPrediction[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end)
NamePlates.colorsGroup.args.healPrediction.inline = true

NamePlates.colorsGroup.args.healPrediction.args.personal = ACH:Color(L["Personal"], nil, 1, true)
NamePlates.colorsGroup.args.healPrediction.args.others = ACH:Color(L["Others"], nil, 2, true)
NamePlates.colorsGroup.args.healPrediction.args.absorbs = ACH:Color(L["Absorbs"], nil, 3, true, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.healPrediction.args.healAbsorbs = ACH:Color(L["Heal Absorbs"], nil, 4, true, nil, nil, nil, nil, E.Classic)

NamePlates.colorsGroup.args.power = ACH:Group(L["Power Color"], nil, 7, nil, function(info) local t, d = E.db.nameplates.colors.power[info[#info]], P.nameplates.colors.power[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.power[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end)
NamePlates.colorsGroup.args.power.inline = true
NamePlates.colorsGroup.args.power.args.MANA = ACH:Color(L["MANA"], nil, 1)
NamePlates.colorsGroup.args.power.args.RAGE = ACH:Color(L["RAGE"], nil, 2)
NamePlates.colorsGroup.args.power.args.FOCUS = ACH:Color(L["FOCUS"], nil, 3)
NamePlates.colorsGroup.args.power.args.ENERGY = ACH:Color(L["ENERGY"], nil, 4)
NamePlates.colorsGroup.args.power.args.RUNIC_POWER = ACH:Color(L["RUNIC_POWER"], nil, 5)
NamePlates.colorsGroup.args.power.args.PAIN = ACH:Color(L["PAIN"], nil, 6, nil, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.power.args.FURY = ACH:Color(L["FURY"], nil, 7, nil, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.power.args.LUNAR_POWER = ACH:Color(L["LUNAR_POWER"], nil, 8, nil, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.power.args.INSANITY = ACH:Color(L["INSANITY"], nil, 9, nil, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.power.args.MAELSTROM = ACH:Color(L["MAELSTROM"], nil, 10, nil, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.power.args.ALT_POWER = ACH:Color(L["Swapped Alt Power"], nil, 11)

do
	local classPowers = { PALADIN = true, WARLOCK = true, MAGE = true }
	NamePlates.colorsGroup.args.classResources = ACH:Group(L["Class Resources"], nil, 8, nil, function(info) local t, d = E.db.nameplates.colors.classResources[info[#info]], P.nameplates.colors.classResources[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.classResources[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end, nil, not E.Retail or not classPowers[E.myclass])
end

NamePlates.colorsGroup.args.classResources.inline = true
NamePlates.colorsGroup.args.classResources.args.PALADIN = ACH:Color(L["HOLY_POWER"], nil, 1, nil, nil, nil, nil, nil, E.Classic)
NamePlates.colorsGroup.args.classResources.args.MAGE = ACH:Color(L["POWER_TYPE_ARCANE_CHARGES"], nil, 2, nil, nil, nil, nil, nil, not E.Retail)
NamePlates.colorsGroup.args.classResources.args.WARLOCK = ACH:Color(L["SOUL_SHARDS"], nil, 3, nil, nil, nil, nil, nil, E.Classic)

NamePlates.colorsGroup.args.COMBO_POINTS = ACH:Group(L["COMBO_POINTS"], nil, 10, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.nameplates.colors.classResources.comboPoints[i], P.nameplates.colors.classResources.comboPoints[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources.comboPoints[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)
NamePlates.colorsGroup.args.COMBO_POINTS.args.chargedComboPoint = ACH:Color(L["Charged Combo Point"], nil, 13, nil, nil, function(info) local t, d = E.db.nameplates.colors.classResources[info[#info]], P.nameplates.colors.classResources[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end, nil, not E.Retail)
NamePlates.colorsGroup.args.COMBO_POINTS.inline = true

NamePlates.colorsGroup.args.CHI_POWER = ACH:Group(L["CHI_POWER"], nil, 11, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.nameplates.colors.classResources.MONK[i], P.nameplates.colors.classResources.MONK[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources.MONK[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end, nil, E.Classic)
NamePlates.colorsGroup.args.CHI_POWER.inline = true

NamePlates.colorsGroup.args.EVOKER = ACH:Group(L["POWER_TYPE_ESSENCE"], nil, 12, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.nameplates.colors.classResources.EVOKER[i], P.nameplates.colors.classResources.EVOKER[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources.EVOKER[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end, nil, not E.Retail)
NamePlates.colorsGroup.args.EVOKER.inline = true

for i = 1, 7 do
	if i ~= 7 then
		NamePlates.colorsGroup.args.CHI_POWER.args[''..i] = ACH:Color(C.Values.Roman[i])
		NamePlates.colorsGroup.args.EVOKER.args[''..i] = ACH:Color(C.Values.Roman[i])
	end

	NamePlates.colorsGroup.args.COMBO_POINTS.args[''..i] = ACH:Color(C.Values.Roman[i])
end

NamePlates.colorsGroup.args.RUNES = ACH:Group(L["RUNES"], nil, 4, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.nameplates.colors.classResources.DEATHKNIGHT[i], P.nameplates.colors.classResources.DEATHKNIGHT[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources.DEATHKNIGHT[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end, nil, E.Classic)
NamePlates.colorsGroup.args.RUNES.inline = true

do
	local runeText = { [-1] = L["RUNE_CHARGE"], [0] = L["RUNES"], L["RUNE_BLOOD"], L["RUNE_FROST"], L["RUNE_UNHOLY"], L["RUNE_DEATH"] }
	for i = -1, 4 do
		NamePlates.colorsGroup.args.RUNES.args[''..i] = ACH:Color(runeText[i], nil, i == -1 and 10 or i, nil, nil, nil, nil, function() return i == -1 and not E.db.nameplates.colors.chargingRunes end, function() return (E.Mists and i < 1) or (not E.Mists and i == 4) or (E.Retail and E.db.unitframe.colors.runeBySpec and i == 0) or (E.Retail and not E.db.unitframe.colors.runeBySpec and i > 0) end)
	end
end

NamePlates.colorsGroup.args.RUNES.args.runeBySpec = ACH:Toggle(L["Color By Spec"], nil, 11, nil, nil, nil, function(info) return E.db.nameplates.colors[info[#info]] end, function(info, value) E.db.nameplates.colors[info[#info]] = value NP:ConfigureAll() end, nil, not E.Retail)
NamePlates.colorsGroup.args.RUNES.args.chargingRunes = ACH:Toggle(E.Retail and L["Charging Rune Color"] or L["Faded Charging Rune"], nil, 11, nil, nil, nil, function(info) return E.db.nameplates.colors[info[#info]] end, function(info, value) E.db.nameplates.colors[info[#info]] = value NP:ConfigureAll() end)

NamePlates.playerGroup = GetUnitSettings('PLAYER', L["Player"])
NamePlates.friendlyPlayerGroup = GetUnitSettings('FRIENDLY_PLAYER', L["FRIENDLY_PLAYER"])
NamePlates.enemyPlayerGroup = GetUnitSettings('ENEMY_PLAYER', L["ENEMY_PLAYER"])
NamePlates.friendlyNPCGroup = GetUnitSettings('FRIENDLY_NPC', L["FRIENDLY_NPC"])
NamePlates.enemyNPCGroup = GetUnitSettings('ENEMY_NPC', L["ENEMY_NPC"])

NamePlates.targetGroup = ACH:Group(L["Target"], nil, 90, nil, function(info) return E.db.nameplates.units.TARGET[info[#info]] end, function(info, value) E.db.nameplates.units.TARGET[info[#info]] = value NP:SetCVars() NP:ConfigureAll() end, function() return not E.NamePlates.Initialized end)
NamePlates.targetGroup.args.nonTargetAlphaShortcut = ACH:Execute(L["Non-Target Alpha"], nil, 1, function() C:StyleFilterSetConfig('ElvUI_NonTarget'); ACD:SelectGroup('ElvUI', 'nameplates', 'stylefilters', 'actions') end)
NamePlates.targetGroup.args.targetScaleShortcut = ACH:Execute(L["Scale"], nil, 2, function() C:StyleFilterSetConfig('ElvUI_Target'); ACD:SelectGroup('ElvUI', 'nameplates', 'stylefilters', 'actions') end)
NamePlates.targetGroup.args.spacer1 = ACH:Spacer(3, 'full')
NamePlates.targetGroup.args.glowStyle = ACH:Select(L["Target/Low Health Indicator"], nil, 4, { none = L["None"], style1 = L["Border Glow"], style2 = L["Background Glow"], style3 = L["Top Arrow"], style4 = L["Side Arrows"], style5 = L["Border Glow"]..' + '..L["Top Arrow"], style6 = L["Background Glow"]..' + '..L["Top Arrow"], style7 = L["Border Glow"]..' + '..L["Side Arrows"], style8 = L["Background Glow"]..' + '..L["Side Arrows"] }, nil, 225)
NamePlates.targetGroup.args.arrowScale = ACH:Range(L["Arrow Scale"], nil, 5, { min = .2, max = 2, step = .01, isPercent = true })
NamePlates.targetGroup.args.arrowSpacing = ACH:Range(L["Arrow Spacing"], nil, 6, { min = -30, softMin = 0, max = 60, step = 1 })
NamePlates.targetGroup.args.arrows = ACH:MultiSelect(L["Arrow Texture"], nil, 30, nil, nil, 80, function(_, key) return E.db.nameplates.units.TARGET.arrow == key end, function(_, key) E.db.nameplates.units.TARGET.arrow = key NP:SetCVars() NP:ConfigureAll() end)

for key, arrow in pairs(E.Media.Arrows) do
	NamePlates.targetGroup.args.arrows.values[key] = E:TextureString(arrow, ':32:32')
end

NamePlates.targetGroup.args.classBarGroup = ACH:Group(L["Class Bar"], nil, 13, nil, function(info) return E.db.nameplates.units.TARGET.classpower[info[#info]] end, function(info, value) E.db.nameplates.units.TARGET.classpower[info[#info]] = value NP:ConfigureAll() end)
NamePlates.targetGroup.args.classBarGroup.inline = true
NamePlates.targetGroup.args.classBarGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
NamePlates.targetGroup.args.classBarGroup.args.classColor = ACH:Toggle(L["Use Class Color"], nil, 2, nil, nil, nil, nil, nil, nil, not E.Retail and E.myclass == 'DEATHKNIGHT')
NamePlates.targetGroup.args.classBarGroup.args.width = ACH:Range(L["Width"], nil, 3, { min = minWidth, max = MaxWidth('PLAYER'), step = 1 })
NamePlates.targetGroup.args.classBarGroup.args.height = ACH:Range(L["Height"], nil, 4, { min = minHeight, max = MaxHeight('PLAYER'), step = 1 })
NamePlates.targetGroup.args.classBarGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
NamePlates.targetGroup.args.classBarGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
NamePlates.targetGroup.args.classBarGroup.args.sortDirection = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 7, { asc = L["Ascending"], desc = L["Descending"], NONE = L["None"] }, nil, nil, nil, nil, nil, function() return (E.myclass ~= 'DEATHKNIGHT') end)
