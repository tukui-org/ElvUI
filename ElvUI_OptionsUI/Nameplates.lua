local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(E.OptionsUI)
local NP = E:GetModule('NamePlates')
local ACD = E.Libs.AceConfigDialog
local ACH = E.Libs.ACH

local _G = _G
local max, strfind, wipe = max, strfind, wipe
local pairs, type, strsplit = pairs, type, strsplit
local next, tonumber, format = next, tonumber, format

local IsAddOnLoaded = IsAddOnLoaded
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local SetCVar = SetCVar


local function GetAddOnStatus(index, locale, name)
	local status = IsAddOnLoaded(name) and format('|cff33ff33%s|r', L["Enabled"]) or format('|cffff3333%s|r', L["Disabled"])
	return ACH:Description(format('%s: %s', locale, status), index, 'medium')
end

local carryFilterFrom, carryFilterTo

local ORDER = 100
local filters = {}

local function NamePlateMaxHeight(unit) local heightType = unit == 'PLAYER' and 'personalHeight' or strfind('FRIENDLY', unit) and 'friendlyHeight' or strfind('ENEMY', unit) and 'enemyHeight' return max(NP.db.plateSize[heightType] or 0, 20) end
local function NamePlateMaxWidth(unit) local widthType = unit == 'PLAYER' and 'personalWidth' or strfind('FRIENDLY', unit) and 'friendlyWidth' or strfind('ENEMY', unit) and 'enemyWidth' return max(NP.db.plateSize[widthType] or 0, 250) end

local function GetUnitSettings(unit, name)
	local copyValues = {}
	for x, y in pairs(NP.db.units) do
		if (type(y) == 'table' and x ~= unit) then
			copyValues[x] = L[x]
		end
	end

	local group = ACH:Group(name, nil, ORDER, 'tree', function(info) return E.db.nameplates.units[unit][info[#info]] end, function(info, value) E.db.nameplates.units[unit][info[#info]] = value NP:ConfigureAll() end, function() return not E.NamePlates.Initialized end)
	group.args.enable = ACH:Toggle(L["Enable"], nil, -10)
	group.args.showTestFrame = ACH:Execute(L["Show/Hide Test Frame"], nil, -9, function() if not _G.ElvNP_Test:IsEnabled() or _G.ElvNP_Test.frameType ~= unit then _G.ElvNP_Test:Enable() _G.ElvNP_Test.frameType = unit NP:NamePlateCallBack(_G.ElvNP_Test, 'NAME_PLATE_UNIT_ADDED') _G.ElvNP_Test:UpdateAllElements('ForceUpdate') else NP:DisablePlate(_G.ElvNP_Test) _G.ElvNP_Test:Disable() end end)
	group.args.defaultSettings = ACH:Execute(L["Default Settings"], L["Set Settings to Default"], -8, function() NP:ResetSettings(unit) NP:ConfigureAll() end)
	group.args.copySettings = ACH:Select(L["Copy settings from"], L["Copy settings from another unit."], -7, copyValues, nil, nil, function() return '' end, function(_, value) NP:CopySettings(value, unit) NP:ConfigureAll() end)

	group.args.general = ACH:Group(L["General"], nil, 1, nil, function(info) return E.db.nameplates.units[unit][info[#info]] end, function(info, value) E.db.nameplates.units[unit][info[#info]] = value NP:SetCVars() NP:ConfigureAll() end)
	group.args.general.args.visibilityShortcut = ACH:Execute(L["Visibility"], nil, 100, function() ACD:SelectGroup('ElvUI', 'nameplate', 'generalGroup', 'general', 'plateVisibility') end)
	group.args.general.args.nameOnly = ACH:Toggle(L["Name Only"], nil, 101)
	group.args.general.args.showTitle = ACH:Toggle(L["Show Title"], L["Title will only appear if Name Only is enabled or triggered in a Style Filter."], 102)
	group.args.general.args.smartAuraPosition = ACH:Select(L["Smart Aura Position"], L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."], 104, C.Values.SmartAuraPosition)

	group.args.healthGroup = ACH:Group(L["Health"], nil, 2, nil, function(info) return E.db.nameplates.units[unit].health[info[#info]] end, function(info, value) E.db.nameplates.units[unit].health[info[#info]] = value NP:ConfigureAll() end)
	group.args.healthGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, nil, function() return unit == 'PLAYER' end)
	group.args.healthGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 4, max = NamePlateMaxHeight(unit), step = 1 })
	group.args.healthGroup.args.width = ACH:Execute(L["Width"], nil, 4, function() ACD:SelectGroup('ElvUI', 'nameplate', 'generalGroup', 'general', 'clickableRange') end)
	group.args.healthGroup.args.healPrediction = ACH:Toggle(L["Heal Prediction"], nil, 5)

	group.args.healthGroup.args.textGroup = ACH:Group(L["Text"], nil, 200, nil, function(info) return E.db.nameplates.units[unit].health.text[info[#info]] end, function(info, value) E.db.nameplates.units[unit].health.text[info[#info]] = value NP:ConfigureAll() end)
	group.args.healthGroup.args.textGroup.inline = true
	group.args.healthGroup.args.textGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.healthGroup.args.textGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.healthGroup.args.textGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
	group.args.healthGroup.args.textGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.healthGroup.args.textGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.healthGroup.args.textGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.healthGroup.args.textGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.healthGroup.args.textGroup.args.fontGroup.inline = true
	group.args.healthGroup.args.textGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.healthGroup.args.textGroup.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.healthGroup.args.textGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.powerGroup = ACH:Group(L["Power"], nil, 3, nil, function(info) return E.db.nameplates.units[unit].power[info[#info]] end, function(info, value) E.db.nameplates.units[unit].power[info[#info]] = value NP:ConfigureAll() end)
	group.args.powerGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.powerGroup.args.hideWhenEmpty = ACH:Toggle(L["Hide When Empty"], nil, 2)
	group.args.powerGroup.args.width = ACH:Range(L["Width"], nil, 3, { min = 50, max = NamePlateMaxWidth(unit), step = 1 })
	group.args.powerGroup.args.height = ACH:Range(L["Height"], nil, 4, { min = 4, max = NamePlateMaxHeight(unit), step = 1 })
	group.args.powerGroup.args.displayAltPower = ACH:Toggle(L["Swap to Alt Power"], nil, 7)
	group.args.powerGroup.args.useAtlas = ACH:Toggle(L["Use Atlas Textures"], nil, 8)
	group.args.powerGroup.args.classColor = ACH:Toggle(L["Use Class Color"], nil, 9)

	group.args.powerGroup.args.textGroup = ACH:Group(L["Text"], nil, 200, nil, function(info) return E.db.nameplates.units[unit].power.text[info[#info]] end, function(info, value) E.db.nameplates.units[unit].power.text[info[#info]] = value NP:ConfigureAll() end)
	group.args.powerGroup.args.textGroup.inline = true
	group.args.powerGroup.args.textGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.powerGroup.args.textGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.powerGroup.args.textGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
	group.args.powerGroup.args.textGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.powerGroup.args.textGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.powerGroup.args.textGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.powerGroup.args.textGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.powerGroup.args.textGroup.args.fontGroup.inline = true
	group.args.powerGroup.args.textGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.powerGroup.args.textGroup.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.powerGroup.args.textGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.castGroup = ACH:Group(L["Cast Bar"], nil, 4, nil, function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end, function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value NP:ConfigureAll() end)
	group.args.castGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.castGroup.args.sourceInterrupt = ACH:Toggle(L["Display Interrupt Source"], L["Display the unit name who interrupted a spell on the castbar. You should increase the Time to Hold to show properly."], 2)
	group.args.castGroup.args.sourceInterruptClassColor = ACH:Group(L["Class Color Source"], nil, 3, nil, nil, nil, nil, function() return not E.db.nameplates.units[unit].castbar.sourceInterrupt end)
	-- order 4 is player Display Target
	group.args.castGroup.args.timeToHold = ACH:Range(L["Time To Hold"], L["How many seconds the castbar should stay visible after the cast failed or was interrupted."], 5, { min = 0, max = 5, step = .1 })
	group.args.castGroup.args.width = ACH:Range(L["Width"], nil, 6, { min = 50, max = NamePlateMaxWidth(unit), step = 1 })
	group.args.castGroup.args.height = ACH:Range(L["Height"], nil, 7, { min = 4, max = NamePlateMaxHeight(unit), step = 1 })
	group.args.castGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })

	group.args.castGroup.args.textGroup = ACH:Group(L["Text"], nil, 20, nil, function(info) return E.db.nameplates.units[unit].power.text[info[#info]] end, function(info, value) E.db.nameplates.units[unit].power.text[info[#info]] = value NP:ConfigureAll() end)
	group.args.castGroup.args.textGroup.inline = true
	group.args.castGroup.args.textGroup.args.hideSpellName = ACH:Toggle(L["Hide Spell Name"], nil, 1)
	group.args.castGroup.args.textGroup.args.hideTime = ACH:Toggle(L["Hide Time"], nil, 2)
	group.args.castGroup.args.textGroup.args.textPosition = ACH:Select(L["Position"], nil, 3, { ONBAR = L["Cast Bar"], ABOVE = L["Above"], BELOW = L["Below"] })
	group.args.castGroup.args.textGroup.args.castTimeFormat = ACH:Select(L["Cast Time Format"], nil, 4, { CURRENT = L["Current"], CURRENTMAX = L["Current / Max"], REMAINING = L["Remaining"], REMAININGMAX = L["Remaining / Max"] })
	group.args.castGroup.args.textGroup.args.channelTimeFormat = ACH:Select(L["Channel Time Format"], nil, 5, { CURRENT = L["Current"], CURRENTMAX = L["Current / Max"], REMAINING = L["Remaining"], REMAININGMAX = L["Remaining / Max"] })
	group.args.castGroup.args.textGroup.args.timeXOffset = ACH:Range(L["Time X-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.timeYOffset = ACH:Range(L["Time Y-Offset"], nil, 7, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.textXOffset = ACH:Range(L["Text X-Offset"], nil, 8, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.textGroup.args.textYOffset = ACH:Range(L["Text Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })

	group.args.castGroup.args.iconGroup = ACH:Group(L["Icon"], nil, 21)
	group.args.castGroup.args.iconGroup.inline = true
	group.args.castGroup.args.iconGroup.args.showIcon = ACH:Toggle(L["Show Icon"], nil, 1)
	group.args.castGroup.args.iconGroup.args.iconPosition = ACH:Select(L["Position"], nil, 3, { LEFT = L["Left"], RIGHT = L["Right"] })
	group.args.castGroup.args.iconGroup.args.iconSize = ACH:Range(L["Icon Size"], nil, 3, { min = 4, max = 40, step = 1 })
	group.args.castGroup.args.iconGroup.args.iconOffsetX = ACH:Range(L["X-Offset"], nil, 8, { min = -100, max = 100, step = 1 })
	group.args.castGroup.args.iconGroup.args.iconOffsetY = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })

	group.args.castGroup.args.fontGroup = ACH:Group('', nil, 30)
	group.args.castGroup.args.fontGroup.inline = true
	group.args.castGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.castGroup.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.castGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.buffsGroup = ACH:Group(L["Buffs"], nil, 5, nil, function(info) return E.db.nameplates.units[unit].buffs[info[#info]] end, function(info, value) E.db.nameplates.units[unit].buffs[info[#info]] = value NP:ConfigureAll() end)
	group.args.buffsGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.buffsGroup.args.stackAuras = ACH:Toggle(L["Stack Auras"], L["This will join auras together which are normally separated. Example: Bolstering and Force of Nature."], 2)
	group.args.buffsGroup.args.desaturate = ACH:Toggle(L["Desaturate Icon"], L["Set auras that are not from you to desaturad."], 3)
	group.args.buffsGroup.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 4)
	group.args.buffsGroup.args.size = ACH:Range(function() return E.db.nameplates.units[unit].buffs.keepSizeRatio and L["Size"] or L["Width"] end, nil, 5, { min = 6, max = 60, step = 1 })
	group.args.buffsGroup.args.height = ACH:Range(L["Height"], nil, 6, { min = 6, max = 60, step = 1 }, nil, nil, nil, nil, function() return E.db.nameplates.units[unit].buffs.keepSizeRatio end)
	group.args.buffsGroup.args.numAuras = ACH:Range(L["Per Row"], nil, 7, { min = 1, max = 20, step = 1 })
	group.args.buffsGroup.args.numRows = ACH:Range(L["Num Rows"], nil, 8, { min = 1, max = 5, step = 1 })
	group.args.buffsGroup.args.spacing = ACH:Range(L["Spacing"], nil, 9, { min = 0, max = 60, step = 1 })
	group.args.buffsGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 10, { min = -100, max = 100, step = 1 })
	group.args.buffsGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 11, { min = -100, max = 100, step = 1 })
	group.args.buffsGroup.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 12, C.Values.Anchors)
	group.args.buffsGroup.args.attachTo = ACH:Select(L["Attach To"], L["What to attach the anchor frame to."], 13, { FRAME = L["Frame"], DEBUFFS = L["Debuffs"], HEALTH = L["Health"], POWER = L["Power"] }, nil, nil, nil, nil, function() local position = E.db.nameplates.units[unit].smartAuraPosition return position == 'BUFFS_ON_DEBUFFS' or position == 'FLUID_BUFFS_ON_DEBUFFS' end)
	group.args.buffsGroup.args.growthX = ACH:Select(L["Growth X-Direction"], nil, 14, { LEFT = L["Left"], RIGHT = L["Right"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.units[unit].buffs.anchorPoint return point == 'LEFT' or point == 'RIGHT' end)
	group.args.buffsGroup.args.growthY = ACH:Select(L["Growth X-Direction"], nil, 15, { UP = L["Up"], DOWN = L["Down"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.units[unit].buffs.anchorPoint return point == 'TOP' or point == 'BOTTOM' end)

	group.args.buffsGroup.args.stacks = ACH:Group(L["Stack Counter"], nil, 20)
	group.args.buffsGroup.args.stacks.inline = true
	group.args.buffsGroup.args.stacks.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.buffsGroup.args.stacks.args.countFontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.buffsGroup.args.stacks.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	group.args.buffsGroup.args.stacks.args.countXOffset = ACH:Range(L["X-Offset"], nil, 10, { min = -100, max = 100, step = 1 })
	group.args.buffsGroup.args.stacks.args.countYOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })
	group.args.buffsGroup.args.stacks.args.countPosition = ACH:Select(L["Position"], nil, 3, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT' })

	group.args.buffsGroup.args.duration = ACH:Group(L["Duration"], nil, 25)
	group.args.buffsGroup.args.duration.inline = true
	group.args.buffsGroup.args.duration.args.cooldownShortcut = ACH:Execute(L["Cooldowns"], nil, 1, function() ACD:SelectGroup('ElvUI', 'cooldown', 'nameplates') end)
	group.args.buffsGroup.args.duration.args.durationPosition = ACH:Select(L["Position"], nil, 2, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT' })

	group.args.buffsGroup.args.filtersGroup = ACH:Group(L["FILTERS"], nil, 30)
	group.args.buffsGroup.args.filtersGroup.inline = true
	group.args.buffsGroup.args.filtersGroup.args.minDuration = ACH:Range(L["Minimum Duration"], L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	group.args.buffsGroup.args.filtersGroup.args.maxDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	group.args.buffsGroup.args.filtersGroup.args.jumpToFilter = ACH:Execute(L["Filters Page"], L["Shortcut to global filters."], 3, function() ACD:SelectGroup('ElvUI', 'filters') end)
	group.args.buffsGroup.args.filtersGroup.args.specialFilters = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 4, function() wipe(filters) local list = E.global.unitframe.specialFilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', value) NP:ConfigureAll() end)
	group.args.buffsGroup.args.filtersGroup.args.specialFilters.sortByValue = true
	group.args.buffsGroup.args.filtersGroup.args.filter = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 5, function() wipe(filters) local list = E.global.unitframe.aurafilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', value) NP:ConfigureAll() end)
	group.args.buffsGroup.args.filtersGroup.args.resetPriority = ACH:Execute(L["Reset Priority"], L["Reset filter priority to the default state."], 7, function() E.db.nameplates.units[unit].buffs.priority = P.nameplates.units[unit].buffs.priority NP:ConfigureAll() end)

	group.args.buffsGroup.args.filtersGroup.args.filterPriority = ACH:MultiSelect(L["Filter Priority"], nil, 8, function() local str = E.db.nameplates.units[unit].buffs.priority if str == '' then return {} end return {strsplit(',', str)} end, nil, nil, function(_, value) local str = E.db.nameplates.units[unit].buffs.priority if str == '' then return end local tbl = {strsplit(',', str)} return tbl[value] end, function() NP:ConfigureAll() end)
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.dragdrop = true
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.dragOnLeave = E.noop -- keep it her
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.dragOnEnter = function(info) carryFilterTo = info.obj.value end
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.dragOnMouseDown = function(info) carryFilterFrom, carryFilterTo = info.obj.value, nil end
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.dragOnMouseUp = function() C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', carryFilterTo, nil, carryFilterFrom) carryFilterFrom, carryFilterTo = nil, nil end
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.dragOnClick = function() C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', carryFilterFrom, true) end
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.stateSwitchGetText = C.StateSwitchGetText
	group.args.buffsGroup.args.filtersGroup.args.filterPriority.stateSwitchOnClick = function() C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', carryFilterFrom, nil, nil, true) end
	group.args.buffsGroup.args.filtersGroup.args.spacer3 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 9)

	group.args.debuffsGroup = ACH:Group(L["Debuffs"], nil, 5, nil, function(info) return E.db.nameplates.units[unit].debuffs[info[#info]] end, function(info, value) E.db.nameplates.units[unit].debuffs[info[#info]] = value NP:ConfigureAll() end)
	group.args.debuffsGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.debuffsGroup.args.stackAuras = ACH:Toggle(L["Stack Auras"], L["This will join auras together which are normally separated. Example: Bolstering and Force of Nature."], 2)
	group.args.debuffsGroup.args.desaturate = ACH:Toggle(L["Desaturate Icon"], L["Set auras that are not from you to desaturad."], 3)
	group.args.debuffsGroup.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 4)
	group.args.debuffsGroup.args.size = ACH:Range(function() return E.db.nameplates.units[unit].debuffs.keepSizeRatio and L["Size"] or L["Width"] end, nil, 5, { min = 6, max = 60, step = 1 })
	group.args.debuffsGroup.args.height = ACH:Range(L["Height"], nil, 6, { min = 6, max = 60, step = 1 }, nil, nil, nil, nil, function() return E.db.nameplates.units[unit].debuffs.keepSizeRatio end)
	group.args.debuffsGroup.args.numAuras = ACH:Range(L["Per Row"], nil, 7, { min = 1, max = 20, step = 1 })
	group.args.debuffsGroup.args.numRows = ACH:Range(L["Num Rows"], nil, 8, { min = 1, max = 5, step = 1 })
	group.args.debuffsGroup.args.spacing = ACH:Range(L["Spacing"], nil, 9, { min = 0, max = 60, step = 1 })
	group.args.debuffsGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 10, { min = -100, max = 100, step = 1 })
	group.args.debuffsGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 11, { min = -100, max = 100, step = 1 })
	group.args.debuffsGroup.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 12, C.Values.Anchors)
	group.args.debuffsGroup.args.attachTo = ACH:Select(L["Attach To"], L["What to attach the anchor frame to."], 13, { FRAME = L["Frame"], DEBUFFS = L["Debuffs"], HEALTH = L["Health"], POWER = L["Power"] }, nil, nil, nil, nil, function() local position = E.db.nameplates.units[unit].smartAuraPosition return position == 'BUFFS_ON_DEBUFFS' or position == 'FLUID_BUFFS_ON_DEBUFFS' end)
	group.args.debuffsGroup.args.growthX = ACH:Select(L["Growth X-Direction"], nil, 14, { LEFT = L["Left"], RIGHT = L["Right"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.units[unit].debuffs.anchorPoint return point == 'LEFT' or point == 'RIGHT' end)
	group.args.debuffsGroup.args.growthY = ACH:Select(L["Growth X-Direction"], nil, 15, { UP = L["Up"], DOWN = L["Down"] }, nil, nil, nil, nil, function() local point = E.db.nameplates.units[unit].debuffs.anchorPoint return point == 'TOP' or point == 'BOTTOM' end)

	group.args.debuffsGroup.args.stacks = ACH:Group(L["Stack Counter"], nil, 20)
	group.args.debuffsGroup.args.stacks.inline = true
	group.args.debuffsGroup.args.stacks.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.debuffsGroup.args.stacks.args.countFontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.debuffsGroup.args.stacks.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	group.args.debuffsGroup.args.stacks.args.countXOffset = ACH:Range(L["X-Offset"], nil, 10, { min = -100, max = 100, step = 1 })
	group.args.debuffsGroup.args.stacks.args.countYOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })
	group.args.debuffsGroup.args.stacks.args.countPosition = ACH:Select(L["Position"], nil, 3, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT' })

	group.args.debuffsGroup.args.duration = ACH:Group(L["Duration"], nil, 25)
	group.args.debuffsGroup.args.duration.inline = true
	group.args.debuffsGroup.args.duration.args.cooldownShortcut = ACH:Execute(L["Cooldowns"], nil, 1, function() ACD:SelectGroup('ElvUI', 'cooldown', 'nameplates') end)
	group.args.debuffsGroup.args.duration.args.durationPosition = ACH:Select(L["Position"], nil, 2, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT' })

	group.args.debuffsGroup.args.filtersGroup = ACH:Group(L["FILTERS"], nil, 30)
	group.args.debuffsGroup.args.filtersGroup.inline = true
	group.args.debuffsGroup.args.filtersGroup.args.minDuration = ACH:Range(L["Minimum Duration"], L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	group.args.debuffsGroup.args.filtersGroup.args.maxDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	group.args.debuffsGroup.args.filtersGroup.args.jumpToFilter = ACH:Execute(L["Filters Page"], L["Shortcut to global filters."], 3, function() ACD:SelectGroup('ElvUI', 'filters') end)
	group.args.debuffsGroup.args.filtersGroup.args.specialFilters = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 4, function() wipe(filters) local list = E.global.unitframe.specialFilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', value) NP:ConfigureAll() end)
	group.args.debuffsGroup.args.filtersGroup.args.specialFilters.sortByValue = true
	group.args.debuffsGroup.args.filtersGroup.args.filter = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 5, function() wipe(filters) local list = E.global.unitframe.aurafilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.nameplates.units, unit, 'buffs', value) NP:ConfigureAll() end)
	group.args.debuffsGroup.args.filtersGroup.args.resetPriority = ACH:Execute(L["Reset Priority"], L["Reset filter priority to the default state."], 7, function() E.db.nameplates.units[unit].debuffs.priority = P.nameplates.units[unit].debuffs.priority NP:ConfigureAll() end)

	group.args.debuffsGroup.args.filtersGroup.args.filterPriority = ACH:MultiSelect(L["Filter Priority"], nil, 8, function() local str = E.db.nameplates.units[unit].debuffs.priority if str == '' then return {} end return {strsplit(',', str)} end, nil, nil, function(_, value) local str = E.db.nameplates.units[unit].debuffs.priority if str == '' then return end local tbl = {strsplit(',', str)} return tbl[value] end, function() NP:ConfigureAll() end)
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.dragdrop = true
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.dragOnLeave = E.noop
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.dragOnEnter = function(info) carryFilterTo = info.obj.value end
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.dragOnMouseDown = function(info) carryFilterFrom, carryFilterTo = info.obj.value, nil end
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.dragOnMouseUp = function() C.SetFilterPriority(E.db.nameplates.units, unit, 'debuffs', carryFilterTo, nil, carryFilterFrom) carryFilterFrom, carryFilterTo = nil, nil end
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.dragOnClick = function() C.SetFilterPriority(E.db.nameplates.units, unit, 'debuffs', carryFilterFrom, true) end
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.stateSwitchGetText = C.StateSwitchGetText
	group.args.debuffsGroup.args.filtersGroup.args.filterPriority.stateSwitchOnClick = function() C.SetFilterPriority(E.db.nameplates.units, unit, 'debuffs', carryFilterFrom, nil, nil, true) end
	group.args.debuffsGroup.args.filtersGroup.args.spacer3 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 9)

	group.args.portraitGroup = ACH:Group(L["PvP Indicator"], L["Horde / Alliance / Honor Info"], 10, nil, function(info) return E.db.nameplates.units[unit].portrait[info[#info]] end, function(info, value) E.db.nameplates.units[unit].portrait[info[#info]] = value NP:ConfigureAll() end)
	group.args.portraitGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.portraitGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 12, max = 64, step = 1 })
	group.args.portraitGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 12, max = 64, step = 1 })
	group.args.portraitGroup.args.position = ACH:Select(L["Position"], nil, 4, { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
	group.args.portraitGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.portraitGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.levelGroup = ACH:Group(L["Level"], nil, 8, nil, function(info) return E.db.nameplates.units[unit].level[info[#info]] end, function(info, value) E.db.nameplates.units[unit].level[info[#info]] = value NP:ConfigureAll() end)
	group.args.levelGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.levelGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.levelGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
	group.args.levelGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.levelGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.levelGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.levelGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.levelGroup.args.fontGroup.inline = true
	group.args.levelGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.levelGroup.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.levelGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.nameGroup = ACH:Group(L["Name"], nil, 8, nil, function(info) return E.db.nameplates.units[unit].name[info[#info]] end, function(info, value) E.db.nameplates.units[unit].name[info[#info]] = value NP:ConfigureAll() end)
	group.args.nameGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.nameGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.nameGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
	group.args.nameGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.nameGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.nameGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.nameGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.nameGroup.args.fontGroup.inline = true
	group.args.nameGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.nameGroup.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.nameGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.titleGroup = ACH:Group(L["UNIT_NAME_PLAYER_TITLE"], nil, 8, nil, function(info) return E.db.nameplates.units[unit].title[info[#info]] end, function(info, value) E.db.nameplates.units[unit].title[info[#info]] = value NP:ConfigureAll() end)
	group.args.titleGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.titleGroup.args.format = ACH:Input(L["Text Format"], nil, 2, nil, 'full')
	group.args.titleGroup.args.position = ACH:Select(L["Position"], nil, 3, { CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT' })
	group.args.titleGroup.args.parent = ACH:Select(L["Parent"], nil, 4, { Nameplate = L["Nameplate"], Health = L["Health"] })
	group.args.titleGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.titleGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.titleGroup.args.fontGroup = ACH:Group('', nil, 7)
	group.args.titleGroup.args.fontGroup.inline = true
	group.args.titleGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	group.args.titleGroup.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
	group.args.titleGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)

	group.args.pvpindicator = ACH:Group(L["PvP Indicator"], L["Horde / Alliance / Honor Info"], 10, nil, function(info) return E.db.nameplates.units[unit].pvpindicator[info[#info]] end, function(info, value) E.db.nameplates.units[unit].pvpindicator[info[#info]] = value NP:ConfigureAll() end)
	group.args.pvpindicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.pvpindicator.args.showBadge = ACH:Toggle(L["Show Badge"], L["Show PvP Badge Indicator if available"], 2)
	group.args.pvpindicator.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
	group.args.pvpindicator.args.position = ACH:Select(L["Position"], nil, 4, { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
	group.args.pvpindicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.pvpindicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	group.args.raidTargetIndicator = ACH:Group(L["PvP Indicator"], L["Horde / Alliance / Honor Info"], 10, nil, function(info) return E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] end, function(info, value) E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] = value NP:ConfigureAll() end)
	group.args.raidTargetIndicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	group.args.raidTargetIndicator.args.showBadge = ACH:Toggle(L["Show Badge"], L["Show PvP Badge Indicator if available"], 2)
	group.args.raidTargetIndicator.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
	group.args.raidTargetIndicator.args.position = ACH:Select(L["Position"], nil, 4, { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
	group.args.raidTargetIndicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	group.args.raidTargetIndicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

	if unit == 'PLAYER' then
		group.args.classBarGroup = ACH:Group(L["Classbar"], nil, 13, nil, function(info) return E.db.nameplates.units[unit].classpower[info[#info]] end, function(info, value) E.db.nameplates.units[unit].classpower[info[#info]] = value NP:ConfigureAll() end)
		group.args.classBarGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.classBarGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = NamePlateMaxWidth(unit), step = 1 })
		group.args.classBarGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 4, max = NamePlateMaxHeight(unit), step = 1 })
		group.args.classBarGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
		group.args.classBarGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
		group.args.classBarGroup.args.sortDirection = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 7, { asc = L["Ascending"], desc = L["Descending"], NONE = L["NONE"] }, nil, nil, nil, nil, nil, function() return (E.myclass ~= 'DEATHKNIGHT') end)

		group.args.general.args.useStaticPosition = ACH:Toggle(L["Use Static Position"], L["When enabled the nameplate will stay visible in a locked position."], 105, nil, nil, nil, nil, nil, function() return not E.db.nameplates.units[unit].enable end)
	elseif unit == 'FRIENDLY_PLAYER' or unit == 'ENEMY_PLAYER' then
		group.args.general.args.markHealers = ACH:Toggle(L["Healer Icon"], L["Display a healer icon over known healers inside battlegrounds or arenas."], 105)
		group.args.general.args.markHealers = ACH:Toggle(L["Tank Icon"], L["Display a tank icon over known tanks inside battlegrounds or arenas."], 106)
	elseif unit == 'ENEMY_NPC' or unit == 'FRIENDLY_NPC' then
		group.args.eliteIcon = ACH:Group(L["Classbar"], nil, 13, nil, function(info) return E.db.nameplates.units[unit].eliteIcon[info[#info]] end, function(info, value) E.db.nameplates.units[unit].eliteIcon[info[#info]] = value NP:ConfigureAll() end)
		group.args.eliteIcon.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.eliteIcon.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
		group.args.eliteIcon.args.position = ACH:Select(L["Position"], nil, 4, { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
		group.args.eliteIcon.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
		group.args.eliteIcon.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

		group.args.questIcon = ACH:Group(L["Classbar"], nil, 13, nil, function(info) return E.db.nameplates.units[unit].questIcon[info[#info]] end, function(info, value) E.db.nameplates.units[unit].questIcon[info[#info]] = value NP:ConfigureAll() end)
		group.args.questIcon.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.questIcon.args.hideIcon = ACH:Toggle(L["Hide Icon"], nil, 2)
		group.args.questIcon.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
		group.args.questIcon.args.position = ACH:Select(L["Position"], nil, 4, { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
		group.args.questIcon.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
		group.args.questIcon.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })

		group.args.questIcon.args.fontGroup = ACH:Group('', nil, 7)
		group.args.questIcon.args.fontGroup.inline = true
		group.args.questIcon.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
		group.args.questIcon.args.fontGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, { min = 4, max = 60, step = 1 })
		group.args.questIcon.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
		group.args.questIcon.args.fontGroup.args.position = ACH:Select(L["Text Position"], nil, 4, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT' })
	end

	if unit == 'PLAYER' or unit == 'FRIENDLY_PLAYER' or unit == 'ENEMY_PLAYER' then
		group.args.healthGroup.args.useClassColor = ACH:Toggle(L["Use Class Color"], nil, 10)

		group.args.portraitGroup.args.classicon = ACH:Toggle(L["Class Icon"], nil, 2)

		group.args.pvpindicator = ACH:Group(L["PvP Classification Indicator"], L["Cart / Flag / Orb / Assassin Bounty"], 30, nil, function(info) return E.db.nameplates.units[unit].pvpclassificationindicator[info[#info]] end, function(info, value) E.db.nameplates.units[unit].pvpclassificationindicator[info[#info]] = value NP:ConfigureAll() end)
		group.args.pvpindicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.pvpindicator.args.size = ACH:Range(L["Size"], nil, 2, { min = 12, max = 64, step = 1 })
		group.args.pvpindicator.args.position = ACH:Select(L["Position"], nil, 3, { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
		group.args.pvpindicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
		group.args.pvpindicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	end

	ORDER = ORDER + 2
	return group
end

E.Options.args.nameplate = ACH:Group(L["NamePlates"], nil, 2, 'tab', function(info) return E.db.nameplates[info[#info]] end, function(info, value) E.db.nameplates[info[#info]] = value; NP:ConfigureAll() end)
E.Options.args.nameplate.args.intro = ACH:Description(L["NAMEPLATE_DESC"], 0)
E.Options.args.nameplate.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function(info) return E.private.nameplates[info[#info]] end, function(info, value) E.private.nameplates[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.nameplate.args.statusbar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 2)
E.Options.args.nameplate.args.resetFilters = ACH:Execute(L["Reset Aura Filters"], nil, 3, function() E:StaticPopup_Show('RESET_NP_AF') end)
E.Options.args.nameplate.args.resetcvars = ACH:Execute(L["Reset CVars"], L["Reset Nameplate CVars to the ElvUI recommended defaults."], 4, function() NP:CVarReset() end, nil, true)

E.Options.args.nameplate.args.generalGroup = ACH:Group(L["General"], nil, 5, nil, nil, function(info, value) E.db.nameplates[info[#info]] = value NP:SetCVars() NP:ConfigureAll() end, function() return not E.NamePlates.Initialized end)
E.Options.args.nameplate.args.generalGroup.args.motionType = ACH:Select(L["UNIT_NAMEPLATES_TYPES"], L["Set to either stack nameplates vertically or allow them to overlap."], 1, { STACKED = L["UNIT_NAMEPLATES_TYPE_2"], OVERLAP = L["UNIT_NAMEPLATES_TYPE_1"] })
E.Options.args.nameplate.args.generalGroup.args.showEnemyCombat = ACH:Select(L["Enemy Combat Toggle"], L["Control enemy nameplates toggling on or off when in combat."], 2, { DISABLED = L["DISABLE"], TOGGLE_ON = L["Toggle On While In Combat"], TOGGLE_OFF = L["Toggle Off While In Combat"] }, nil, nil, nil, function(info, value) E.db.nameplates[info[#info]] = value NP:PLAYER_REGEN_ENABLED() end)
E.Options.args.nameplate.args.generalGroup.args.showFriendlyCombat = ACH:Select(L["Friendly Combat Toggle"], L["Control friendly nameplates toggling on or off when in combat."], 3, { DISABLED = L["DISABLE"], TOGGLE_ON = L["Toggle On While In Combat"], TOGGLE_OFF = L["Toggle Off While In Combat"] }, nil, nil, nil, function(info, value) E.db.nameplates[info[#info]] = value NP:PLAYER_REGEN_ENABLED() end)

E.Options.args.nameplate.args.generalGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 4)
E.Options.args.nameplate.args.generalGroup.args.smoothbars.customWidth = 110

E.Options.args.nameplate.args.generalGroup.args.clampToScreen = ACH:Toggle(L["Clamp Nameplates"], L["Clamp nameplates to the top of the screen when outside of view."], 5)
E.Options.args.nameplate.args.generalGroup.args.clampToScreen.customWidth = 140

E.Options.args.nameplate.args.generalGroup.args.spacer1 = ACH:Spacer(6, 'full')
E.Options.args.nameplate.args.generalGroup.args.overlapV = {
					order = 10,
					type = 'range',
					name = L["Overlap Vertical"],
					desc = L["Percentage amount for vertical overlap of Nameplates."],
					min = 0,
					max = 3,
					step = 0.1,
					get = function() return tonumber(GetCVar('nameplateOverlapV')) end,
					set = function(_, value) SetCVar('nameplateOverlapV', value) end
				}
E.Options.args.nameplate.args.generalGroup.args.overlapH = {
					order = 11,
					type = 'range',
					name = L["Overlap Horizontal"],
					desc = L["Percentage amount for horizontal overlap of Nameplates."],
					min = 0,
					max = 3,
					step = 0.1,
					get = function() return tonumber(GetCVar('nameplateOverlapH')) end,
					set = function(_, value) SetCVar('nameplateOverlapH', value) end
				}
E.Options.args.nameplate.args.generalGroup.args.lowHealthThreshold = {
					order = 12,
					name = L["Low Health Threshold"],
					desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
					type = 'range',
					isPercent = true,
					min = 0,
					softMax = 0.5,
					max = 0.8,
					step = 0.01
				}
E.Options.args.nameplate.args.generalGroup.args.highlight = {
					order = 13,
					type = 'toggle',
					customWidth = 125,
					name = L["Hover Highlight"]
				}
E.Options.args.nameplate.args.generalGroup.args.fadeIn = {
					order = 14,
					type = 'toggle',
					customWidth = 125,
					name = L["Alpha Fading"]
				}
E.Options.args.nameplate.args.generalGroup.args.spacer2 = ACH:Spacer(15, 'full')
E.Options.args.nameplate.args.generalGroup.args.plateVisibility = {
					order = 50,
					type = 'group',
					name = L["Visibility"],
					args = {
						showAll = {
							order = 0,
							type = 'toggle',
							customWidth = 250,
							name = L["UNIT_NAMEPLATES_AUTOMODE"],
							desc = L["This option controls the Blizzard setting for whether or not the Nameplates should be shown."],
							get = function(info)
								return E.db.nameplates.visibility.showAll
							end,
							set = function(info, value)
								E.db.nameplates.visibility.showAll = value
								NP:SetCVars()
								NP:ConfigureAll()
							end
						},
						showAlways = {
							order = 1,
							type = 'toggle',
							name = L["Always Show Player"],
							disabled = function()
								return not E.db.nameplates.units.PLAYER.enable
							end,
							get = function(info)
								return E.db.nameplates.units.PLAYER.visibility.showAlways
							end,
							set = function(info, value)
								E.db.nameplates.units.PLAYER.visibility.showAlways = value
								NP:SetCVars()
								NP:ConfigureAll()
							end
						},
						cvars = {
							order = 2,
							type = 'multiselect',
							name = L["Blizzard CVars"],
							get = function(info, key)
								return GetCVarBool(key)
							end,
							set = function(_, key, value)
								if key == 'nameplateOtherAtBase' then
									SetCVar(key, value and '2' or '0')
								else
									SetCVar(key, value and '1' or '0')
								end
							end,
							values = {
								nameplateOtherAtBase = L["Nameplate At Base"],
								nameplateShowOnlyNames = 'Show Only Names',
							},
						},
						playerVisibility = {
							order = 5,
							type = 'group',
							inline = true,
							name = L["Player"],
							get = function(info)
								return E.db.nameplates.units.PLAYER.visibility[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.units.PLAYER.visibility[info[#info]] = value
								NP:SetCVars()
								NP:ConfigureAll()
							end,
							args = {
								showInCombat = {
									order = 2,
									type = 'toggle',
									name = L["Show In Combat"],
									disabled = function()
										return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways
									end
								},
								showWithTarget = {
									order = 2,
									type = 'toggle',
									name = L["Show With Target"],
									desc = L["When using Static Position, this option also requires the target to be attackable."],
									disabled = function()
										return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways
									end
								},
								spacer1 = ACH:Spacer(3, 'full'),
								hideDelay = {
									order = 4,
									type = 'range',
									name = L["Hide Delay"],
									min = 0,
									max = 20,
									step = 0.01,
									bigStep = 1,
									disabled = function()
										return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways
									end
								},
								alphaDelay = {
									order = 5,
									type = 'range',
									name = L["Delay Alpha"],
									min = 0,
									max = 1,
									step = 0.01,
									bigStep = 0.1,
									disabled = function()
										return not E.db.nameplates.units.PLAYER.enable or E.db.nameplates.units.PLAYER.visibility.showAlways
									end
								}
							}
						},
						enemyVisibility = {
							type = 'group',
							order = 10,
							inline = true,
							name = L["Enemy"],
							disabled = function()
								return not E.db.nameplates.visibility.showAll
							end,
							get = function(info)
								return E.db.nameplates.visibility.enemy[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.visibility.enemy[info[#info]] = value
								NP:SetCVars()
								NP:ConfigureAll()
							end,
							args = {
								guardians = {
									type = 'toggle',
									order = 1,
									name = L["Guardians"]
								},
								minions = {
									type = 'toggle',
									order = 2,
									name = L["Minions"]
								},
								minus = {
									type = 'toggle',
									order = 3,
									name = L["Minus"]
								},
								pets = {
									type = 'toggle',
									order = 4,
									name = L["Pets"]
								},
								totems = {
									type = 'toggle',
									order = 5,
									name = L["Totems"]
								}
							}
						},
						friendlyVisibility = {
							type = 'group',
							order = 15,
							inline = true,
							name = L["Friendly"],
							disabled = function()
								return not E.db.nameplates.visibility.showAll
							end,
							get = function(info)
								return E.db.nameplates.visibility.friendly[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.visibility.friendly[info[#info]] = value
								NP:SetCVars()
								NP:ConfigureAll()
							end,
							args = {
								guardians = {
									type = 'toggle',
									order = 1,
									name = L["Guardians"]
								},
								minions = {
									type = 'toggle',
									order = 2,
									name = L["Minions"]
								},
								npcs = {
									type = 'toggle',
									order = 3,
									name = L["NPC"]
								},
								pets = {
									type = 'toggle',
									order = 4,
									name = L["Pets"]
								},
								totems = {
									type = 'toggle',
									order = 5,
									name = L["Totems"]
								}
							}
						}
					}
				}

E.Options.args.nameplate.args.generalGroup.args.bossMods = {
					order = 55,
					type = 'group',
					name = L["Boss Mod Auras"],
					get = function(info)
						return E.db.nameplates.bossMods[info[#info]]
					end,
					set = function(info, value)
						E.db.nameplates.bossMods[info[#info]] = value
						NP:ConfigureAll()
					end,
					args = {
						supported = {
							order = -1,
							type = 'group',
							name = L["Supported"],
							inline = true,
							args = {
								dbm = GetAddOnStatus(1, 'Deadly Boss Mods', 'DBM-Core'),
								bw = GetAddOnStatus(2, 'BigWigs', 'BigWigs')
							},
						},
						enable = {
							order = 1,
							name = L["Enable"],
							type = 'toggle'
						},
						settings = {
							order = 2,
							type = 'group',
							name = '',
							inline = true,
							disabled = function()
								return not E.db.nameplates.bossMods.enable or not (IsAddOnLoaded('BigWigs') or IsAddOnLoaded('DBM-Core'))
							end,
							args = {
								keepSizeRatio = {
									type = 'toggle',
									order = 1,
									name = L["Keep Size Ratio"]
								},
								size = {
									order = 2,
									name = function() return E.db.nameplates.bossMods.keepSizeRatio and L["Icon Size"] or L["Icon Width"] end,
									type = 'range',
									min = 6, max = 60, step = 1
								},
								height = {
									order = 3,
									hidden = function() return E.db.nameplates.bossMods.keepSizeRatio end,
									name = L["Icon Height"],
									type = 'range',
									min = 6, max = 60, step = 1
								},
								spacing = {
									order = 5,
									name = L["Spacing"],
									type = 'range',
									min = 0,
									max = 60,
									step = 1
								},
								xOffset = {
									order = 6,
									name = L["X-Offset"],
									type = 'range',
									min = -100,
									max = 100,
									step = 1
								},
								yOffset = {
									order = 7,
									type = 'range',
									name = L["Y-Offset"],
									min = -100,
									max = 100,
									step = 1
								},
								anchorPoint = {
									type = 'select',
									order = 8,
									name = L["Anchor Point"],
									desc = L["What point to anchor to the frame you set to attach to."],
									values = C.Values.Anchors
								},
								growthX = {
									type = 'select',
									order = 10,
									name = L["Growth X-Direction"],
									disabled = function()
										local point = E.db.nameplates.bossMods.anchorPoint
										return point == 'LEFT' or point == 'RIGHT'
									end,
									values = {
										LEFT = L["Left"],
										RIGHT = L["Right"]
									}
								},
								growthY = {
									type = 'select',
									order = 11,
									disabled = function()
										local point = E.db.nameplates.bossMods.anchorPoint
										return point == 'TOP' or point == 'BOTTOM'
									end,
									name = L["Growth Y-Direction"],
									values = {
										UP = L["Up"],
										DOWN = L["Down"]
									}
								},
							},
						},
					}
				}

E.Options.args.nameplate.args.generalGroup.args.effectiveGroup = ACH:Group(L["Effective Updates"], nil, 60, nil, function(info) return E.global.nameplate[info[#info]] end, function(info, value) E.global.nameplate[info[#info]] = value; NP:ConfigureAll() end)
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.warning = ACH:Description(L["|cffFF0000Warning:|r This causes updates to happen at a fraction of a second."]..'\n'..L["Enabling this has the potential to make updates faster, though setting a speed value that is too high may cause it to actually run slower than the default scheme, which use Blizzard events only with no update loops provided."], 0, 'medium')
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.effectiveHealth = ACH:Toggle(L["Health"], nil, 1)
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.effectivePower = ACH:Toggle(L["Power"], nil, 2)
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.effectiveAura = ACH:Toggle(L["Aura"], nil, 3)
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.spacer1 = ACH:Spacer(4, 'full')
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.effectiveHealthSpeed = ACH:Range(L["Health Speed"], nil, 5, { min = .1, max = .5, step = .05 }, nil, nil, nil, function() return not E.global.nameplate.effectiveHealth end)
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.effectivePowerSpeed = ACH:Range(L["Power Speed"], nil, 6, { min = .1, max = .5, step = .05 }, nil, nil, nil, function() return not E.global.nameplate.effectivePower end)
E.Options.args.nameplate.args.generalGroup.args.effectiveGroup.args.effectiveAuraSpeed = ACH:Range(L["Aura Speed"], nil, 7, { min = .1, max = .5, step = .05 }, nil, nil, nil, function() return not E.global.nameplate.effectiveAura end)

E.Options.args.nameplate.args.generalGroup.args.clickThrough = ACH:Group(L["Click Through"], nil, 65, nil, function(info) return E.db.nameplates.clickThrough[info[#info]] end)
E.Options.args.nameplate.args.generalGroup.args.clickThrough.args.personal = ACH:Toggle(L["Personal"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.nameplates.clickThrough[info[#info]] = value NP:SetNamePlateSelfClickThrough() end)
E.Options.args.nameplate.args.generalGroup.args.clickThrough.args.friendly = ACH:Toggle(L["Friendly"], nil, 2, nil, nil, nil, nil, function(info, value) E.db.nameplates.clickThrough[info[#info]] = value NP:SetNamePlateFriendlyClickThrough() end)
E.Options.args.nameplate.args.generalGroup.args.clickThrough.args.enemy = ACH:Toggle(L["Enemy"], nil, 3, nil, nil, nil, nil, function(info, value) E.db.nameplates.clickThrough[info[#info]] = value NP:SetNamePlateEnemyClickThrough() end)

E.Options.args.nameplate.args.generalGroup.args.clickableRange = ACH:Group(L["Clickable Size"], nil, 70, nil, function(info) return E.db.nameplates.plateSize[info[#info]] end, function(info, value) E.db.nameplates.plateSize[info[#info]] = value NP:ConfigureAll() end)
E.Options.args.nameplate.args.generalGroup.args.clickableRange.args.personal = {
							order = 1,
							type = 'group',
							inline = true,
							name = L["Personal"],
							args = {
								personalWidth = {
									order = 1,
									type = 'range',
									name = L["Clickable Width / Width"],
									desc = L["Controls the width and how big of an area on the screen will accept clicks to target unit."],
									min = 50,
									max = 250,
									step = 1
								},
								personalHeight = {
									order = 2,
									type = 'range',
									name = L["Clickable Height"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 10,
									max = 75,
									step = 1
								}
							}
						}
E.Options.args.nameplate.args.generalGroup.args.clickableRange.args.friendly = {
							order = 2,
							type = 'group',
							inline = true,
							name = L["Friendly"],
							args = {
								friendlyWidth = {
									order = 1,
									type = 'range',
									name = L["Clickable Width / Width"],
									desc = L["Change the width and controls how big of an area on the screen will accept clicks to target unit."],
									min = 50,
									max = 250,
									step = 1
								},
								friendlyHeight = {
									order = 2,
									type = 'range',
									name = L["Clickable Height"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 10,
									max = 75,
									step = 1
								}
							}
						}
E.Options.args.nameplate.args.generalGroup.args.clickableRange.args.enemy = {
							order = 3,
							type = 'group',
							inline = true,
							name = L["Enemy"],
							args = {
								enemyWidth = {
									order = 1,
									type = 'range',
									name = L["Clickable Width / Width"],
									desc = L["Change the width and controls how big of an area on the screen will accept clicks to target unit."],
									min = 50,
									max = 250,
									step = 1
								},
								enemyHeight = {
									order = 2,
									type = 'range',
									name = L["Clickable Height"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 10,
									max = 75,
									step = 1
								}
							}
						}

E.Options.args.nameplate.args.generalGroup.args.cutaway = {
					order = 75,
					type = 'group',
					name = L["Cutaway Bars"],
					args = {
						health = {
							order = 1,
							type = 'group',
							inline = true,
							name = L["Health"],
							get = function(info)
								return E.db.nameplates.cutaway.health[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.cutaway.health[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								enabled = {
									type = 'toggle',
									order = 1,
									name = L["Enable"]
								},
								forceBlankTexture = {
									type = 'toggle',
									order = 2,
									name = L["Blank Texture"]
								},
								lengthBeforeFade = {
									type = 'range',
									order = 3,
									name = L["Fade Out Delay"],
									desc = L["How much time before the cutaway health starts to fade."],
									min = 0.1,
									max = 1,
									step = 0.1,
									disabled = function()
										return not E.db.nameplates.cutaway.health.enabled
									end
								},
								fadeOutTime = {
									type = 'range',
									order = 4,
									name = L["Fade Out"],
									desc = L["How long the cutaway health will take to fade out."],
									min = 0.1,
									max = 1,
									step = 0.1,
									disabled = function()
										return not E.db.nameplates.cutaway.health.enabled
									end
								}
							}
						},
						power = {
							order = 2,
							type = 'group',
							name = L["Power"],
							inline = true,
							get = function(info)
								return E.db.nameplates.cutaway.power[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.cutaway.power[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								enabled = {
									type = 'toggle',
									order = 1,
									name = L["Enable"]
								},
								forceBlankTexture = {
									type = 'toggle',
									order = 2,
									name = L["Blank Texture"]
								},
								lengthBeforeFade = {
									type = 'range',
									order = 3,
									name = L["Fade Out Delay"],
									desc = L["How much time before the cutaway power starts to fade."],
									min = 0.1,
									max = 1,
									step = 0.1,
									disabled = function()
										return not E.db.nameplates.cutaway.power.enabled
									end
								},
								fadeOutTime = {
									type = 'range',
									order = 4,
									name = L["Fade Out"],
									desc = L["How long the cutaway power will take to fade out."],
									min = 0.1,
									max = 1,
									step = 0.1,
									disabled = function()
										return not E.db.nameplates.cutaway.power.enabled
									end
								}
							}
						}
					}
				}

E.Options.args.nameplate.args.generalGroup.args.threatGroup = {
					order = 80,
					type = 'group',
					name = L["Threat"],
					get = function(info) return E.db.nameplates.threat[info[#info]] end,
					set = function(info, value) E.db.nameplates.threat[info[#info]] = value NP:ConfigureAll() end,
					args = {
						enable = {
							order = 0,
							type = 'toggle',
							name = L["Enable"]
						},
						useThreatColor = {
							order = 1,
							type = 'toggle',
							name = L["Use Threat Color"]
						},
						beingTankedByTank = {
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							order = 2,
							type = 'toggle',
							disabled = function()
								return not E.db.nameplates.threat.useThreatColor
							end
						},
						indicator = {
							name = L["Show Icon"],
							order = 3,
							type = 'toggle',
							disabled = function()
								return not E.db.nameplates.threat.enable
							end
						},
						goodScale = {
							name = L["Good Scale"],
							order = 4,
							type = 'range',
							isPercent = true,
							min = 0.5,
							max = 1.5,
							softMin = .75,
							softMax = 1.25,
							step = 0.01,
							disabled = function()
								return not E.db.nameplates.threat.enable
							end
						},
						badScale = {
							name = L["Bad Scale"],
							order = 6,
							type = 'range',
							isPercent = true,
							min = 0.5,
							max = 1.5,
							softMin = .75,
							softMax = 1.25,
							step = 0.01,
							disabled = function()
								return not E.db.nameplates.threat.enable
							end
						}
					}
				}

E.Options.args.nameplate.args.colorsGroup = ACH:Group(L["COLORS"], nil, 15, nil, nil, nil, function() return not E.NamePlates.Initialized end)
E.Options.args.nameplate.args.colorsGroup.args.general = {
					order = 1,
					type = 'group',
					name = L["General"],
					inline = true,
					get = function(info) return E.db.nameplates.colors[info[#info]] end,
					set = function(info, value) E.db.nameplates.colors[info[#info]] = value; NP:ConfigureAll() end,
					args = {
						glowColor = {
							name = L["Target Indicator Color"],
							type = 'color',
							order = 1,
							get = function(info)
								local t, d = E.db.nameplates.colors[info[#info]], P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							hasAlpha = true
						},
						auraByDispels = {
							order = 2,
							name = L["Borders By Dispel"],
							type = 'toggle',
						},
						auraByType = {
							order = 3,
							name = L["Borders By Type"],
							type = 'toggle',
						},
					}
				}

E.Options.args.nameplate.args.colorsGroup.args.threat = {
					order = 2,
					type = 'group',
					name = L["Threat"],
					inline = true,
					get = function(info)
						local t, d = E.db.nameplates.colors.threat[info[#info]], P.nameplates.colors.threat[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local t = E.db.nameplates.colors.threat[info[#info]]
						t.r, t.g, t.b, t.a = r, g, b, a
						NP:ConfigureAll()
					end,
					disabled = function() return not E.db.nameplates.threat.useThreatColor end,
					args = {
						goodColor = {
							type = 'color',
							order = 1,
							name = L["Good Color"],
						},
						goodTransition = {
							type = 'color',
							order = 2,
							name = L["Good Transition Color"],
						},
						badTransition = {
							name = L["Bad Transition Color"],
							order = 3,
							type = 'color',
						},
						badColor = {
							name = L["Bad Color"],
							order = 4,
							type = 'color',
						},
						offTankColor = {
							name = L["Off Tank"],
							order = 5,
							type = 'color',
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end
						},
						offTankColorGoodTransition = {
							name = L["Off Tank Good Transition"],
							order = 6,
							type = 'color',
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end
						},
						offTankColorBadTransition = {
							name = L["Off Tank Bad Transition"],
							order = 7,
							type = 'color',
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end
						}
					}
				}

E.Options.args.nameplate.args.colorsGroup.args.castGroup = {
					order = 3,
					type = 'group',
					name = L["Cast Bar"],
					inline = true,
					get = function(info)
						local t, d = E.db.nameplates.colors[info[#info]], P.nameplates.colors[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.colors[info[#info]]
						t.r, t.g, t.b = r, g, b
						NP:ConfigureAll()
					end,
					args = {
						castColor = {
							type = 'color',
							order = 1,
							name = L["Interruptible"],
						},
						castNoInterruptColor = {
							name = L["Non-Interruptible"],
							order = 2,
							type = 'color',
						},
						castInterruptedColor = {
							name = L["Interrupted"],
							order = 2,
							type = 'color',
						},
						castbarDesaturate = {
							type = 'toggle',
							name = L["Desaturated Icon"],
							desc = L["Show the castbar icon desaturated if a spell is not interruptible."],
							order = 3,
							get = function(info) return E.db.nameplates.colors[info[#info]] end,
							set = function(info, value) E.db.nameplates.colors[info[#info]] = value NP:ConfigureAll() end
						}
					}
				}

E.Options.args.nameplate.args.colorsGroup.args.selectionGroup = {
					order = 4,
					type = 'group',
					name = L["Selection"],
					inline = true,
					get = function(info)
						local n = tonumber(info[#info])
						local t, d = E.db.nameplates.colors.selection[n], P.nameplates.colors.selection[n]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.colors.selection[tonumber(info[#info])]
						t.r, t.g, t.b = r, g, b
						NP:ConfigureAll()
					end,
					args = {
						['0'] = {
							order = 0,
							name = L["Hostile"],
							type = 'color'
						},
						['1'] = {
							order = 1,
							name = L["Unfriendly"],
							type = 'color'
						},
						['2'] = {
							order = 2,
							name = L["Neutral"],
							type = 'color'
						},
						['3'] = {
							order = 3,
							name = L["Friendly"],
							type = 'color'
						},
						['5'] = {
							order = 5,
							name = L["Player"], -- Player Extended
							type = 'color'
						},
						['6'] = {
							order = 6,
							name = L["PARTY"],
							type = 'color'
						},
						['7'] = {
							order = 7,
							name = L["Party PVP"],
							type = 'color'
						},
						['8'] = {
							order = 8,
							name = L["Friend"],
							type = 'color'
						},
						['9'] = {
							order = 9,
							name = L["Dead"],
							type = 'color'
						},
						['13'] = {
							order = 13,
							name = L["Battleground Friendly"],
							type = 'color'
						}
					}
				}

E.Options.args.nameplate.args.colorsGroup.args.reactions = {
					order = 5,
					type = 'group',
					name = L["Reaction Colors"],
					inline = true,
					get = function(info) local t, d = E.db.nameplates.colors.reactions[info[#info]], P.nameplates.colors.reactions[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end,
					set = function(info, r, g, b) local t = E.db.nameplates.colors.reactions[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end,
					args = {
						bad = {
							name = L["Enemy"],
							order = 1,
							type = 'color',
						},
						neutral = {
							name = L["Neutral"],
							order = 2,
							type = 'color',
						},
						good = {
							name = L["Friendly"],
							order = 4,
							type = 'color',
						},
						tapped = {
							name = L["Tagged NPC"],
							order = 5,
							type = 'color',
							get = function(info) local t, d = E.db.nameplates.colors[info[#info]], P.nameplates.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end,
							set = function(info, r, g, b) local t = E.db.nameplates.colors[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end
						}
					}
				}

E.Options.args.nameplate.args.colorsGroup.args.healPrediction = ACH:Group(L["Heal Prediction"], nil, 6, nil, function(info) local t, d = E.db.nameplates.colors.healPrediction[info[#info]], P.nameplates.colors.healPrediction[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.healPrediction[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end)
E.Options.args.nameplate.args.colorsGroup.args.healPrediction.inline = true

E.Options.args.nameplate.args.colorsGroup.args.healPrediction.args.personal = ACH:Color(L["Personal"], nil, 1, true)
E.Options.args.nameplate.args.colorsGroup.args.healPrediction.args.others = ACH:Color(L["Others"], nil, 2, true)
E.Options.args.nameplate.args.colorsGroup.args.healPrediction.args.absorbs = ACH:Color(L["Absorbs"], nil, 3, true)
E.Options.args.nameplate.args.colorsGroup.args.healPrediction.args.healAbsorbs = ACH:Color(L["Heal Absorbs"], nil, 4, true)

E.Options.args.nameplate.args.colorsGroup.args.power = ACH:Group(L["Power Color"], nil, 7, nil, function(info) local t, d = E.db.nameplates.colors.power[info[#info]], P.nameplates.colors.power[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.power[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end)
E.Options.args.nameplate.args.colorsGroup.args.power.inline = true
E.Options.args.nameplate.args.colorsGroup.args.power.args.ENERGY = ACH:Color(L["ENERGY"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.FOCUS = ACH:Color(L["FOCUS"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.FURY = ACH:Color(L["FURY"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.INSANITY = ACH:Color(L["INSANITY"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.LUNAR_POWER = ACH:Color(L["LUNAR_POWER"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.MAELSTROM = ACH:Color(L["MAELSTROM"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.MANA = ACH:Color(L["MANA"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.PAIN = ACH:Color(L["PAIN"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.RAGE = ACH:Color(L["RAGE"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.RUNIC_POWER = ACH:Color(L["RUNIC_POWER"])
E.Options.args.nameplate.args.colorsGroup.args.power.args.ALT_POWER = ACH:Color(L["Swapped Alt Power"])

E.Options.args.nameplate.args.colorsGroup.args.classResources = ACH:Group(L["Class Resources"], nil, 8, nil, function(info) local t, d = E.db.nameplates.colors.classResources[info[#info]], P.nameplates.colors.classResources[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.nameplates.colors.classResources[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a NP:ConfigureAll() end)
E.Options.args.nameplate.args.colorsGroup.args.classResources.inline = true
E.Options.args.nameplate.args.colorsGroup.args.classResources.args.PALADIN = ACH:Color(L["HOLY_POWER"], nil, 1)
E.Options.args.nameplate.args.colorsGroup.args.classResources.args.MAGE = ACH:Color(L["POWER_TYPE_ARCANE_CHARGES"], nil, 2)
E.Options.args.nameplate.args.colorsGroup.args.classResources.args.WARLOCK = ACH:Color(L["SOUL_SHARDS"], nil, 3)
E.Options.args.nameplate.args.colorsGroup.args.classResources.args.DEATHKNIGHT = ACH:Color(L["RUNES"], nil, 4)
E.Options.args.nameplate.args.colorsGroup.args.classResources.args.COMBO_POINTS = ACH:Group(L["COMBO_POINTS"], nil, 10, nil, function(info) local t, d = E.db.nameplates.colors.classResources.comboPoints[tonumber(info[#info])], P.nameplates.colors.classResources.comboPoints[tonumber(info[#info])] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources.comboPoints[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)
E.Options.args.nameplate.args.colorsGroup.args.classResources.args.CHI_POWER = ACH:Group(L["CHI_POWER"], nil, 11, nil, function(info) local t, d = E.db.nameplates.colors.classResources.MONK[tonumber(info[#info])], P.nameplates.colors.classResources.MONK[tonumber(info[#info])] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources.MONK[tonumber(info[#info])] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)

E.Options.args.nameplate.args.colorsGroup.args.classResources.args.COMBO_POINTS.args.chargedComboPoint = ACH:Color(L["Charged Combo Point"], nil, 13, nil, nil, function(info) local t, d = E.db.nameplates.colors.classResources[info[#info]], P.nameplates.colors.classResources[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.nameplates.colors.classResources[info[#info]] t.r, t.g, t.b = r, g, b NP:ConfigureAll() end)

for i = 1, 6 do
	E.Options.args.nameplate.args.colorsGroup.args.classResources.args.CHI_POWER.args[''..i] = ACH:Color(L["CHI_POWER"]..' #'..i)
	E.Options.args.nameplate.args.colorsGroup.args.classResources.args.COMBO_POINTS.args[''..i] = ACH:Color(L["COMBO_POINTS"]..' #'..i)
end

E.Options.args.nameplate.args.playerGroup = GetUnitSettings('PLAYER', L["Player"])
E.Options.args.nameplate.args.friendlyPlayerGroup = GetUnitSettings('FRIENDLY_PLAYER', L["FRIENDLY_PLAYER"])
E.Options.args.nameplate.args.friendlyNPCGroup = GetUnitSettings('FRIENDLY_NPC', L["FRIENDLY_NPC"])
E.Options.args.nameplate.args.enemyPlayerGroup = GetUnitSettings('ENEMY_PLAYER', L["ENEMY_PLAYER"])
E.Options.args.nameplate.args.enemyNPCGroup = GetUnitSettings('ENEMY_NPC', L["ENEMY_NPC"])

E.Options.args.nameplate.args.targetGroup = {
			order = 101,
			type = 'group',
			name = L["TARGET"],
			get = function(info)
				return E.db.nameplates.units.TARGET[info[#info]]
			end,
			set = function(info, value)
				E.db.nameplates.units.TARGET[info[#info]] = value
				NP:SetCVars()
				NP:ConfigureAll()
			end,
			disabled = function()
				return not E.NamePlates.Initialized
			end,
			args = {
				nonTargetAlphaShortcut = {
					order = 1,
					type = 'execute',
					name = L["Non-Target Alpha"],
					func = function()
						ACD:SelectGroup('ElvUI', 'nameplate', 'filters', 'actions')
						selectedNameplateFilter = 'ElvUI_NonTarget'
						UpdateFilterGroup()
					end
				},
				targetScaleShortcut = {
					order = 2,
					type = 'execute',
					name = L["Scale"],
					func = function()
						ACD:SelectGroup('ElvUI', 'nameplate', 'filters', 'actions')
						selectedNameplateFilter = 'ElvUI_Target'
						UpdateFilterGroup()
					end
				},
				spacer1 = ACH:Spacer(3, 'full'),
				glowStyle = {
					order = 4,
					type = 'select',
					customWidth = 225,
					name = L["Target/Low Health Indicator"],
					values = {
						none = L["NONE"],
						style1 = L["Border Glow"],
						style2 = L["Background Glow"],
						style3 = L["Top Arrow"],
						style4 = L["Side Arrows"],
						style5 = L["Border Glow"] .. ' + ' .. L["Top Arrow"],
						style6 = L["Background Glow"] .. ' + ' .. L["Top Arrow"],
						style7 = L["Border Glow"] .. ' + ' .. L["Side Arrows"],
						style8 = L["Background Glow"] .. ' + ' .. L["Side Arrows"]
					}
				},
				arrowScale = {
					order = 5,
					type = 'range',
					name = L["Arrow Scale"],
					min = 0.2,
					max = 2,
					step = 0.01,
					isPercent = true
				},
				arrowSpacing = {
					order = 6,
					name = L["Arrow Spacing"],
					type = 'range',
					min = 0,
					max = 50,
					step = 1
				},
				arrows = {
					order = 30,
					name = L["Arrow Texture"],
					type = 'multiselect',
					customWidth = 80,
					get = function(_, key)
						return E.db.nameplates.units.TARGET.arrow == key
					end,
					set = function(_, key)
						E.db.nameplates.units.TARGET.arrow = key
						NP:SetCVars()
						NP:ConfigureAll()
					end,
				}
			}
		}

E.Options.args.nameplate.args.targetGroup.args.classBarGroup = ACH:Group(L["Classbar"], nil, 13, nil, function(info) return E.db.nameplates.units.TARGET.classpower[info[#info]] end, function(info, value) E.db.nameplates.units.TARGET.classpower[info[#info]] = value NP:ConfigureAll() end)
E.Options.args.nameplate.args.targetGroup.args.classBarGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
E.Options.args.nameplate.args.targetGroup.args.classBarGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = NamePlateMaxWidth('PLAYER'), step = 1 })
E.Options.args.nameplate.args.targetGroup.args.classBarGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 4, max = NamePlateMaxHeight('PLAYER'), step = 1 })
E.Options.args.nameplate.args.targetGroup.args.classBarGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
E.Options.args.nameplate.args.targetGroup.args.classBarGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
E.Options.args.nameplate.args.targetGroup.args.classBarGroup.args.sortDirection = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 7, { asc = L["Ascending"], desc = L["Descending"], NONE = L["NONE"] }, nil, nil, nil, nil, nil, function() return (E.myclass ~= 'DEATHKNIGHT') end)

do -- target arrow textures
	local arrows = {}
	E.Options.args.nameplate.args.targetGroup.args.arrows.values = arrows

	for key, arrow in pairs(E.Media.Arrows) do
		arrows[key] = E:TextureString(arrow, ':32:32')
	end
end
