local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local UF = E:GetModule('UnitFrames')
local ACD = E.Libs.AceConfigDialog
local ACH = E.Libs.ACH

local _G = _G
local next, format, strmatch, strsplit = next, format, strmatch, strsplit
local tinsert, tonumber, gsub, pairs, wipe, ceil = tinsert, tonumber, gsub, pairs, wipe, ceil

local GetNumClasses = GetNumClasses
local GetClassInfo = GetClassInfo
local CopyTable = CopyTable

local NUM_CLASSES = #CLASS_SORT_ORDER
local MAX_BOSS_FRAMES = 8

local orientationValues = {
	LEFT = L["Left"],
	MIDDLE = L["Middle"],
	RIGHT = L["Right"],
}

local threatValues = {
	GLOW = L["Glow"],
	BORDERS = L["Borders"],
	HEALTHBORDER = L["Health Border"],
	INFOPANELBORDER = L["InfoPanel Border"],
	ICONTOPLEFT = L["Icon: TOPLEFT"],
	ICONTOPRIGHT = L["Icon: TOPRIGHT"],
	ICONBOTTOMLEFT = L["Icon: BOTTOMLEFT"],
	ICONBOTTOMRIGHT = L["Icon: BOTTOMRIGHT"],
	ICONLEFT = L["Icon: LEFT"],
	ICONRIGHT = L["Icon: RIGHT"],
	ICONTOP = L["Icon: TOP"],
	ICONBOTTOM = L["Icon: BOTTOM"],
	NONE = L["None"],
}

local attachToValues = {
	Health = L["Health"],
	Power = L["Power"],
	ClassPower = L["Class Power"],
	InfoPanel = L["Information Panel"],
	Frame = L["Frame"],
}

local colorOverrideValues = {
	USE_DEFAULT = L["Use Default"],
	FORCE_ON = L["Force On"],
	FORCE_OFF = L["Force Off"],
}

local blendModeValues = {
	DISABLE = L["Disable"],
	BLEND = L["Blend"],
	ADD = L["Additive Blend"],
	ALPHAKEY = L["Alpha Key"],
}

local CUSTOMTEXT_CONFIGS, filters = {}, {}
local carryFilterFrom, carryFilterTo

local classTable = {}
for i = 1, GetNumClasses() do
	local classDisplayName, classTag = GetClassInfo(i)
	if classTag then
		classTable[classTag] = classDisplayName
	end
end

local roles = { TANK = L["Tank"] , HEALER = L["Healer"], DAMAGER = L["DPS"] }

-----------------------------------------------------------------------
-- OPTIONS TABLES
-----------------------------------------------------------------------
local function GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, subGroup)
	local config = ACH:Group(L["Strata and Level"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].strataAndLevel[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].strataAndLevel[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.useCustomStrata = ACH:Toggle(L["Use Custom Strata"], nil, 1)
	config.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 2, C.Values.Strata)
	config.args.spacer = ACH:Spacer(3)
	config.args.useCustomLevel = ACH:Toggle(L["Use Custom Level"], nil, 4)
	config.args.frameLevel = ACH:Range(L["Frame Level"], nil, 5, { min = 2, max = 128, step = 1 })

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].strataAndLevel[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].strataAndLevel[info[#info]] = value updateFunc(UF, groupName, numUnits) end
	end

	return config
end

local function GetOptionsTable_AuraBars(updateFunc, groupName)
	local config = ACH:Group(L["Aura Bars"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].aurabar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].aurabar[info[#info]] = value updateFunc(UF, groupName) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.reverseFill = ACH:Toggle(L["Reverse Fill"], nil, 1)
	config.args.abbrevName = ACH:Toggle(E.NewSign..L["Abbreviate Name"], nil, 2)
	config.args.clickThrough = ACH:Toggle(L["Click Through"], L["Ignore mouse events."], 3)
	config.args.configureButton1 = ACH:Execute(L["Coloring"], L["This opens the UnitFrames Color settings. These settings affect all unitframes."], 4, function() ACD:SelectGroup('ElvUI', 'unitframe', 'allColorsGroup') end)
	config.args.configureButton2 = ACH:Execute(L["Coloring (Specific)"], L["This opens the AuraBar Colors filter. These settings affect specific spells."], 5, function() C:SetToFilterConfig('AuraBar Colors') end)
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 6, { ABOVE = L["Above"], BELOW = L["Below"] })
	config.args.attachTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 7, { FRAME = L["Frame"], DEBUFFS = L["Debuffs"], BUFFS = L["Buffs"], DETACHED = L["Detach From Frame"] })
	config.args.height = ACH:Range(L["Height"], nil, 8, { min = 5, max = 40, step = 1 })
	config.args.detachedWidth = ACH:Range(L["Detached Width"], nil, 9, { min = 30, max = 1000, step = 1 }, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].aurabar.attachTo ~= 'DETACHED' end)
	config.args.maxBars = ACH:Range(L["Max Bars"], nil, 10, { min = 1, max = 40, step = 1 })
	config.args.sortMethod = ACH:Select(L["Sort By"], L["Method to sort by."], 11, { TIME_REMAINING = L["Time Remaining"], DURATION = L["Duration"], NAME = L["Name"], INDEX = L["Index"], PLAYER = L["Player"] })
	config.args.sortDirection = ACH:Select(L["Sort Direction"], L["Ascending or Descending order."], 12, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
	config.args.friendlyAuraType = ACH:Select(L["Friendly Aura Type"], L["Set the type of auras to show when a unit is friendly."], 13, { HARMFUL = L["Debuffs"], HELPFUL = L["Buffs"] })
	config.args.enemyAuraType = ACH:Select(L["Enemy Aura Type"], L["Set the type of auras to show when a unit is a foe."], 14, { HARMFUL = L["Debuffs"], HELPFUL = L["Buffs"] }, nil, nil, nil, nil, nil, groupName == 'player')
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 15, { min = 0, max = 100, step = 1 }, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].aurabar.attachTo == 'DETACHED' end)
	config.args.spacing = ACH:Range(L["Spacing"], nil, 16, { min = 0, softMax = 20, step = 1 })

	config.args.filtersGroup = ACH:Group(L["FILTERS"], nil, 30)
	config.args.filtersGroup.inline = true
	config.args.filtersGroup.args.minDuration = ACH:Range(L["Minimum Duration"], L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	config.args.filtersGroup.args.maxDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	config.args.filtersGroup.args.jumpToFilter = ACH:Execute(L["Filters Page"], L["Shortcut to global filters."], 3, function() ACD:SelectGroup('ElvUI', 'filters') end)
	config.args.filtersGroup.args.specialFilters = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 4, function() wipe(filters) local list = E.global.unitframe.specialFilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.unitframe.units, groupName, 'aurabar', value) updateFunc(UF, groupName) end)
	config.args.filtersGroup.args.specialFilters.sortByValue = true
	config.args.filtersGroup.args.filter = ACH:Select(L["Add Regular Filter"], L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."], 5, function() wipe(filters) local list = E.global.unitframe.aurafilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.unitframe.units, groupName, 'aurabar', value) updateFunc(UF, groupName) end)
	config.args.filtersGroup.args.resetPriority = ACH:Execute(L["Reset Priority"], L["Reset filter priority to the default state."], 7, function() E.db.unitframe.units[groupName].aurabar.priority = P.unitframe.units[groupName].aurabar.priority updateFunc(UF, groupName) end)

	config.args.filtersGroup.args.filterPriority = ACH:MultiSelect(L["Filter Priority"], nil, 8, function() local str = E.db.unitframe.units[groupName].aurabar.priority if str == '' then return {} end return {strsplit(',', str)} end, nil, nil, function(_, value) local str = E.db.unitframe.units[groupName].aurabar.priority if str == '' then return end local tbl = {strsplit(',', str)} return tbl[value] end, function() updateFunc(UF, groupName) end)
	config.args.filtersGroup.args.filterPriority.dragdrop = true
	config.args.filtersGroup.args.filterPriority.dragOnLeave = E.noop -- keep it here
	config.args.filtersGroup.args.filterPriority.dragOnEnter = function(info) carryFilterTo = info.obj.value end
	config.args.filtersGroup.args.filterPriority.dragOnMouseDown = function(info) carryFilterFrom, carryFilterTo = info.obj.value, nil end
	config.args.filtersGroup.args.filterPriority.dragOnMouseUp = function() C.SetFilterPriority(E.db.unitframe.units, groupName, 'aurabar', carryFilterTo, nil, carryFilterFrom) carryFilterFrom, carryFilterTo = nil, nil end
	config.args.filtersGroup.args.filterPriority.dragOnClick = function() C.SetFilterPriority(E.db.unitframe.units, groupName, 'aurabar', carryFilterFrom, true) end
	config.args.filtersGroup.args.filterPriority.stateSwitchGetText = C.StateSwitchGetText
	config.args.filtersGroup.args.filterPriority.stateSwitchOnClick = function() C.SetFilterPriority(E.db.unitframe.units, groupName, 'aurabar', carryFilterFrom, nil, nil, true) end
	config.args.filtersGroup.args.spacer1 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 9)

	if groupName == 'target' then
		config.args.attachTo.values.PLAYER_AURABARS = L["Player Frame Aura Bars"]
	end

	return config
end

local function GetOptionsTable_Auras(auraType, updateFunc, groupName, numUnits)
	local config = ACH:Group(auraType == 'buffs' and L["Buffs"] or L["Debuffs"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value updateFunc(UF, groupName, numUnits) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.stackAuras = ACH:Toggle(L["Stack Auras"], L["This will join auras together which are normally separated. Example: Bolstering and Force of Nature."], 2)
	config.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 3)
	config.args.sizeOverride = ACH:Range(function() return E.db.unitframe.units[groupName][auraType].keepSizeRatio and L["Size Override"] or L["Icon Width"] end, L["If not set to 0 then override the size of the aura icon to this."], 4, { min = 0, max = 80, step = 1 })
	config.args.height = ACH:Range(L["Icon Height"], nil, 5, { min = 6, max = 80, step = 1 }, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName][auraType].keepSizeRatio end)
	config.args.perrow = ACH:Range(L["Per Row"], nil, 6, { min = 1, max = 40, step = 1 })
	config.args.numrows = ACH:Range(L["Num Rows"], nil, 7, { min = 1, max = 10, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -100, max = 100, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -100, max = 100, step = 1 })
	config.args.spacing = ACH:Range(L["Spacing"], nil, 10, { min = -1, max = 20, step = 1 })
	config.args.attachTo = ACH:Select(L["Attach To"], L["What to attach the anchor frame to."], 11, { FRAME = L["Frame"], DEBUFFS = L["Debuffs"], HEALTH = L["Health"], POWER = L["Power"] }, nil, nil, nil, nil, function() local position = E.db.unitframe.units[groupName].smartAuraPosition return position == 'BUFFS_ON_DEBUFFS' or position == 'FLUID_BUFFS_ON_DEBUFFS' end)

	config.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 12, C.Values.Anchors)
	config.args.growthX = ACH:Select(L["Growth X-Direction"], nil, 13, { LEFT = L["Left"], RIGHT = L["Right"] }, nil, nil, nil, nil, function() local point = E.db.unitframe.units[groupName][auraType].anchorPoint return point == 'LEFT' or point == 'RIGHT' end)
	config.args.growthY = ACH:Select(L["Growth Y-Direction"], nil, 14, { UP = L["Up"], DOWN = L["Down"] }, nil, nil, nil, nil, function() local point = E.db.unitframe.units[groupName][auraType].anchorPoint return point == 'TOP' or point == 'BOTTOM' end)
	config.args.clickThrough = ACH:Toggle(L["Click Through"], L["Ignore mouse events."], 15)
	config.args.sortDirection = ACH:Select(L["Sort Direction"], L["Ascending or Descending order."], 17, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
	config.args.sortMethod = ACH:Select(L["Sort By"], L["Method to sort by."], 16, { TIME_REMAINING = L["Time Remaining"], DURATION = L["Duration"], NAME = L["Name"], INDEX = L["Index"], PLAYER = L["Player"] })

	config.args.stacks = ACH:Group(L["Stack Counter"], nil, 20, nil, function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.stacks.inline = true
	config.args.stacks.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
	config.args.stacks.args.countFontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
	config.args.stacks.args.countFontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 3)
	config.args.stacks.args.countXOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -60, max = 60, step = 1 })
	config.args.stacks.args.countYOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -60, max = 60, step = 1 })
	config.args.stacks.args.countPosition = ACH:Select(L["Position"], nil, 6, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', BOTTOMRIGHT = 'BOTTOMRIGHT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT' })

	config.args.duration = ACH:Group(L["Duration"], nil, 25, nil, function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.duration.inline = true
	config.args.duration.args.cooldownShortcut = ACH:Execute(L["Cooldowns"], nil, 1, function() ACD:SelectGroup('ElvUI', 'cooldown', 'unitframe') end)
	config.args.duration.args.durationPosition = ACH:Select(L["Position"], nil, 2, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT' })

	config.args.filtersGroup = ACH:Group(L["FILTERS"], nil, 30)
	config.args.filtersGroup.inline = true
	config.args.filtersGroup.args.minDuration = ACH:Range(L["Minimum Duration"], L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	config.args.filtersGroup.args.maxDuration = ACH:Range(L["Maximum Duration"], L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."], 1, { min = 0, max = 10800, step = 1 })
	config.args.filtersGroup.args.jumpToFilter = ACH:Execute(L["Filters Page"], L["Shortcut to global filters."], 3, function() ACD:SelectGroup('ElvUI', 'filters') end)
	config.args.filtersGroup.args.specialFilters = ACH:Select(L["Add Special Filter"], L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."], 4, function() wipe(filters) local list = E.global.unitframe.specialFilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.unitframe.units, groupName, auraType, value) updateFunc(UF, groupName, numUnits) end)
	config.args.filtersGroup.args.specialFilters.sortByValue = true
	config.args.filtersGroup.args.filter = ACH:Select(L["Add Regular Filter"], L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."], 5, function() wipe(filters) local list = E.global.unitframe.aurafilters if not (list and next(list)) then return filters end for filter in pairs(list) do filters[filter] = L[filter] end return filters end, nil, nil, nil, function(_, value) C.SetFilterPriority(E.db.unitframe.units, groupName, auraType, value) updateFunc(UF, groupName, numUnits) end)
	config.args.filtersGroup.args.resetPriority = ACH:Execute(L["Reset Priority"], L["Reset filter priority to the default state."], 7, function() E.db.unitframe.units[groupName][auraType].priority = P.unitframe.units[groupName][auraType].priority updateFunc(UF, groupName, numUnits) end)

	config.args.filtersGroup.args.filterPriority = ACH:MultiSelect(L["Filter Priority"], nil, 8, function() local str = E.db.unitframe.units[groupName][auraType].priority if str == '' then return {} end return {strsplit(',', str)} end, nil, nil, function(_, value) local str = E.db.unitframe.units[groupName][auraType].priority if str == '' then return end local tbl = {strsplit(',', str)} return tbl[value] end, function() updateFunc(UF, groupName, numUnits) end)
	config.args.filtersGroup.args.filterPriority.dragdrop = true
	config.args.filtersGroup.args.filterPriority.dragOnLeave = E.noop -- keep it here
	config.args.filtersGroup.args.filterPriority.dragOnEnter = function(info) carryFilterTo = info.obj.value end
	config.args.filtersGroup.args.filterPriority.dragOnMouseDown = function(info) carryFilterFrom, carryFilterTo = info.obj.value, nil end
	config.args.filtersGroup.args.filterPriority.dragOnMouseUp = function() C.SetFilterPriority(E.db.unitframe.units, groupName, auraType, carryFilterTo, nil, carryFilterFrom) carryFilterFrom, carryFilterTo = nil, nil end
	config.args.filtersGroup.args.filterPriority.dragOnClick = function() C.SetFilterPriority(E.db.unitframe.units, groupName, auraType, carryFilterFrom, true) end
	config.args.filtersGroup.args.filterPriority.stateSwitchGetText = C.StateSwitchGetText
	config.args.filtersGroup.args.filterPriority.stateSwitchOnClick = function() C.SetFilterPriority(E.db.unitframe.units, groupName, auraType, carryFilterFrom, nil, nil, true) end
	config.args.filtersGroup.args.spacer1 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 9)

	if auraType == 'debuffs' then
		config.args.desaturate = ACH:Toggle(L["Desaturate Icon"], L["Set auras that are not from you to desaturated."], 3)
		config.args.attachTo.values = { FRAME = L["Frame"], BUFFS = L["Buffs"], HEALTH = L["Health"], POWER = L["Power"] }
		config.args.attachTo.disabled = function() local position = E.db.unitframe.units[groupName].smartAuraPosition return position == 'DEBUFFS_ON_BUFFS' or position == 'FLUID_DEBUFFS_ON_BUFFS' end
	end

	return config
end

local function doApplyToAll(db, info, value)
	if not db then return end
	for _, spell in pairs(db) do
		if value ~= nil then
			spell[info[#info]] = value
		else
			return spell[info[#info]]
		end
	end
end

local function BuffIndicator_ApplyToAll(info, value, profile, pet)
	if profile then
		return doApplyToAll(E.db.unitframe.filters.aurawatch, info, value)
	elseif pet then
		return doApplyToAll(E.global.unitframe.aurawatch.PET, info, value)
	else
		return doApplyToAll(E.global.unitframe.aurawatch[E.myclass], info, value)
	end
end

local function GetOptionsTable_AuraWatch(updateFunc, groupName, numGroup, subGroup)
	local config = ACH:Group(L["Aura Indicator"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].buffIndicator[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].buffIndicator[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.size = ACH:Range(L["Size"], nil, 2, { min = 6, max = 48, step = 1 })
	config.args.countFontSize = ACH:Range(L["Font Size"], nil, 3, { min = 4, max = 20, step = 1 })
	config.args.profileSpecific = ACH:Toggle(L["Profile Specific"], L["Use the profile specific filter Aura Indicator (Profile) instead of the global filter Aura Indicator."], 4)
	config.args.configureButton = ACH:Execute(L["Configure Auras"], nil, 5, function() local configString = format('Aura Indicator (%s)', groupName == 'pet' and 'Pet' or E.db.unitframe.units[groupName].buffIndicator.profileSpecific and 'Profile' or 'Class') C:SetToFilterConfig(configString) end)

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].buffIndicator[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].buffIndicator[info[#info]] = value updateFunc(UF, groupName, numGroup) end
	else
		config.args.applyToAll = ACH:Group(' ', nil, 50, nil, function(info) return BuffIndicator_ApplyToAll(info, nil, E.db.unitframe.units[groupName].buffIndicator.profileSpecific, groupName == 'pet') end, function(info, value) BuffIndicator_ApplyToAll(info, value, E.db.unitframe.units[groupName].buffIndicator.profileSpecific, groupName == 'pet') updateFunc(UF, groupName, numGroup) end)
		config.args.applyToAll.inline = true
		config.args.applyToAll.args.header = ACH:Description(L["|cffFF3333Warning:|r Changing options in this section will apply to all Aura Indicator auras. To change only one Aura, please click \"Configure Auras\" and change that specific Auras settings. If \"Profile Specific\" is selected it will apply to that filter set."], 1)
		config.args.applyToAll.args.style = ACH:Select(L["Style"], nil, 2, { timerOnly = L["Timer Only"], coloredIcon = L["Colored Icon"], texturedIcon = L["Textured Icon"] })
		config.args.applyToAll.args.textThreshold = ACH:Range(L["Text Threshold"], L["At what point should the text be displayed. Set to -1 to disable."], 3, { min = -1, max = 60, step = 1 })
		config.args.applyToAll.args.displayText = ACH:Toggle(L["Display Text"], nil, 4)
	end

	return config
end

local function GetOptionsTable_Castbar(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Cast Bar"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.reverse = ACH:Toggle(L["Reverse"], nil, 2)
	config.args.width = ACH:Range(L["Width"], nil, 3, { min = 50, max = ceil(E.screenWidth), step = 1 })
	config.args.height = ACH:Range(L["Height"], nil, 4, { min = 5, max = 85, step = 1 })

	-- Need a better way for Test Frames
	config.args.forceshow = ACH:Execute(L["Show"]..' / '..L["Hide"], nil, 6)
	config.args.forceshow.func = function()
		local frameName = gsub('ElvUF_'..E:StringTitle(groupName), 't(arget)', 'T%1')
		if groupName == 'party' then
			local header = UF.headers[groupName]
			for _, group in next, { header:GetChildren() } do
				for _, unitbutton in next { group:GetChildren() } do
					local castbar = unitbutton.Castbar
					if castbar.oldHide then
						castbar.Hide = castbar.oldHide
						castbar.oldHide = nil
						castbar:Hide()
					else
						castbar.oldHide = castbar.Hide
						castbar.Hide = castbar.Show
						castbar:Show()
					end
				end
			end
		elseif numUnits then
			for i = 1, numUnits do
				local castbar = _G[frameName..i].Castbar
				if not castbar.oldHide then
					castbar.oldHide = castbar.Hide
					castbar.Hide = castbar.Show
					castbar:Show()
				else
					castbar.Hide = castbar.oldHide
					castbar.oldHide = nil
					castbar:Hide()
				end
			end
		else
			local castbar = _G[frameName].Castbar
			if not castbar.oldHide then
				castbar.oldHide = castbar.Hide
				castbar.Hide = castbar.Show
				castbar:Show()
			else
				castbar.Hide = castbar.oldHide
				castbar.oldHide = nil
				castbar:Hide()
			end
		end
	end

	config.args.configureButton = ACH:Execute(L["Coloring"], L["This opens the UnitFrames Color settings. These settings affect all unitframes."], 7, function() ACD:SelectGroup('ElvUI', 'unitframe', 'allColorsGroup') end)
	config.args.spark = ACH:Toggle(L["Spark"], L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."], 8)
	config.args.latency = ACH:Toggle(L["Latency"], nil, 10, nil, nil, nil, nil, nil, nil, function() return groupName ~= 'player' end)
	config.args.format = ACH:Select(L["Format"], L["Cast Time Format"], 11, { CURRENTMAX = L["Current / Max"], CURRENT = L["Current"], REMAINING = L["Remaining"], REMAININGMAX = L["Remaining / Max"] })
	config.args.timeToHold = ACH:Range(L["Time To Hold"], L["How many seconds the castbar should stay visible after the cast failed or was interrupted."], 12, { min = 0, max = 10, step = .1 })
	config.args.overlayOnFrame = ACH:Select(L["Attach To"], L["The object you want to attach to."], 3, { Health = L["Health"], Power = L["Power"], InfoPanel = L["Information Panel"], None = L["None"] })

	config.args.textGroup = ACH:Group(L["Text"], nil, 16, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.textGroup.inline = true
	config.args.textGroup.args.hidetext = ACH:Toggle(L["Hide Text"], L["Hide Castbar text. Useful if your power height is very low or if you use power offset."], 1)
	config.args.textGroup.args.textColor = ACH:Color(L["COLOR"], nil, 2, true, nil, function() local c, d = E.db.unitframe.units[groupName].castbar.textColor, P.unitframe.units[groupName].castbar.textColor return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local c = E.db.unitframe.units[groupName].castbar.textColor c.r, c.g, c.b, c.a = r, g, b, a updateFunc(UF, groupName, numUnits) end)

	config.args.textGroup.args.textSettings = ACH:Group(L["Text Options"], nil, 3, nil, function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end, function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end)
	config.args.textGroup.args.textSettings.inline = true
	config.args.textGroup.args.textSettings.args.enable = ACH:Toggle(L["Custom Font"], nil, 1, nil, nil, nil, nil, nil, false)
	config.args.textGroup.args.textSettings.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
	config.args.textGroup.args.textSettings.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
	config.args.textGroup.args.textSettings.args.fontStyle = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 3)
	config.args.textGroup.args.textSettings.args.xOffsetText = ACH:Range(L["X-Offset"], nil, 4, { min = -500, max = 500, step = 1 }, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end, false)
	config.args.textGroup.args.textSettings.args.yOffsetText = ACH:Range(L["Y-Offset"], nil, 5, { min = -500, max = 500, step = 1 }, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end, false)

	config.args.textGroup.args.timeSettings = ACH:Group(L["Time Options"], nil, 4, nil, function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end, function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end)
	config.args.textGroup.args.timeSettings.inline = true
	config.args.textGroup.args.timeSettings.args.enable = ACH:Toggle(L["Custom Font"], nil, 1, nil, nil, nil, nil, nil, false)
	config.args.textGroup.args.timeSettings.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.textGroup.args.timeSettings.args.fontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
	config.args.textGroup.args.timeSettings.args.fontStyle = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 4)
	config.args.textGroup.args.timeSettings.args.xOffsetTime = ACH:Range(L["X-Offset"], nil, 5, { min = -500, max = 500, step = 1 }, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end, false)
	config.args.textGroup.args.timeSettings.args.yOffsetTime = ACH:Range(L["Y-Offset"], nil, 6, { min = -500, max = 500, step = 1 }, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end, false)

	config.args.iconSettings = ACH:Group(L["Icon"], nil, 17, nil, function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end, function() return not E.db.unitframe.units[groupName].castbar.icon or E.db.unitframe.units[groupName].castbar.iconAttached end)
	config.args.iconSettings.inline = true
	config.args.iconSettings.args.icon = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
	config.args.iconSettings.args.iconAttached = ACH:Toggle(L["Icon Inside Castbar"], L["Display the castbar icon inside the castbar."], 2, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.icon end)
	config.args.iconSettings.args.iconSize = ACH:Range(L["Icon Size"], L["This dictates the size of the icon when it is not attached to the castbar."], 3, { min = 8, max = 150, step = 1 })
	config.args.iconSettings.args.iconAttachedTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, { Frame = L["Frame"], Castbar = L["Cast Bar"] })
	config.args.iconSettings.args.iconPosition = ACH:Select(L["Position"], nil, 5, C.Values.AllPoints)
	config.args.iconSettings.args.iconXOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -500, max = 500, step = 1 })
	config.args.iconSettings.args.iconYOffset = ACH:Range(L["Y-Offset"], nil, 4, { min = -500, max = 500, step = 1 })

	config.args.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, 'castbar')

	config.args.customColor = ACH:Group(L["Custom Color"], nil, 21, nil, function(info) if info.type == 'color' then local c, d = E.db.unitframe.units[groupName].castbar.customColor[info[#info]], P.unitframe.units[groupName].castbar.customColor[info[#info]] return c.r, c.g, c.b, c.a, d.r, d.g, d.b, 1 else return E.db.unitframe.units[groupName].castbar.customColor[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local c = E.db.unitframe.units[groupName].castbar.customColor[info[#info]] c.r, c.g, c.b, c.a = r, g, b, a else local value = ... E.db.unitframe.units[groupName].castbar.customColor[info[#info]] = value end updateFunc(UF, groupName, numUnits) end)
	config.args.customColor.inline = true
	config.args.customColor.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.customColor.args.transparent = ACH:Toggle(L["Transparent"], L["Make textures transparent."], 2, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.invertColors = ACH:Toggle(L["Invert Colors"], L["Invert foreground and background colors."], 3, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.transparent end, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.spacer1 = ACH:Spacer(4, 'full')
	config.args.customColor.args.useClassColor = ACH:Toggle(L["Class Color"], L["Color castbar by the class of the unit's class."], 5, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.useReactionColor = ACH:Toggle(L["Reaction Color"], L["Color castbar by the reaction of the unit to the player."], 6, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable or (groupName == 'player' or groupName == 'pet') end)
	config.args.customColor.args.useCustomBackdrop = ACH:Toggle(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 7, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.spacer2 = ACH:Spacer(8, 'full', function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.colorBackdrop = ACH:Color(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 9, true, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable or not E.db.unitframe.units[groupName].castbar.customColor.useCustomBackdrop end)
	config.args.customColor.args.color = ACH:Color(function() return (E.Retail or E.Wrath) and L["Interruptible"] or L["COLOR"] end, nil, 10, true, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.colorNoInterrupt = ACH:Color(L["Non-Interruptible"], nil, 11, true, nil, nil, nil, nil, function() return not (E.Retail or E.Wrath) or not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.spacer3 = ACH:Spacer(11, 'full', function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end)
	config.args.customColor.args.colorInterrupted = ACH:Color(L["Interrupted"], nil, 12, true, nil, nil, nil, nil, function() return not (E.Retail or E.Wrath) or not E.db.unitframe.units[groupName].castbar.customColor.enable end)

	if groupName == 'player' then
		config.args.displayTarget = ACH:Toggle(L["Display Target"], L["Display the target of current cast."], 13)

		config.args.ticks = ACH:Group(L["Ticks"], nil, 20)
		config.args.ticks.inline = true
		config.args.ticks.args.ticks = ACH:Toggle(L["Ticks"], L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."], 1)
		config.args.ticks.args.tickColor = ACH:Color(L["COLOR"], nil, 2, true, nil, function() local c, d = E.db.unitframe.units[groupName].castbar.tickColor, P.unitframe.units[groupName].castbar.tickColor return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local c = E.db.unitframe.units[groupName].castbar.tickColor c.r, c.g, c.b, c.a = r, g, b, a updateFunc(UF, groupName, numUnits) end)
		config.args.ticks.args.tickWidth = ACH:Range(L["Width"], nil, 3, { min = 1, max = 20, step = 1 })
	elseif groupName == 'pet' or groupName == 'boss' then
		config.args.displayTarget = ACH:Toggle(L["Display Target"], L["Display the target of current cast."], 13)
	end

	if groupName == 'party' or groupName == 'arena' then
		config.args.positionsGroup = ACH:Group(L["Position"], nil, 19, nil, function(info) return E.db.unitframe.units[groupName].castbar.positionsGroup[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].castbar.positionsGroup[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
		config.args.positionsGroup.inline = true
		config.args.positionsGroup.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
		config.args.positionsGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -500, max = 500, step = 1 })
		config.args.positionsGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -500, max = 500, step = 1 })
	end

	return config
end

local function GetOptionsTable_Cutaway(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Cutaway Bars"])
	config.args.health = ACH:Group(L["Health"], nil, 1, nil, function(info) return E.db.unitframe.units[groupName].cutaway.health[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].cutaway.health[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.health.inline = true
	config.args.health.args.enabled = ACH:Toggle(L["Enable"], nil, 1)
	config.args.health.args.forceBlankTexture = ACH:Toggle(L["Blank Texture"], nil, 2)
	config.args.health.args.lengthBeforeFade = ACH:Range(L["Fade Out Delay"], L["How much time before the cutaway health starts to fade."], 3, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].cutaway.health.enabled end)
	config.args.health.args.fadeOutTime = ACH:Range(L["Fade Out"], L["How long the cutaway health will take to fade out."], 4, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].cutaway.health.enabled end)

	config.args.power = ACH:Group(L["Power"], nil, 2, nil, function(info) return E.db.unitframe.units[groupName].cutaway.power[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].cutaway.power[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.power.inline = true
	config.args.power.args.enabled = ACH:Toggle(L["Enable"], nil, 1)
	config.args.power.args.forceBlankTexture = ACH:Toggle(L["Blank Texture"], nil, 2)
	config.args.power.args.lengthBeforeFade = ACH:Range(L["Fade Out Delay"], L["How much time before the cutaway power starts to fade."], 3, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].cutaway.power.enabled end)
	config.args.power.args.fadeOutTime = ACH:Range(L["Fade Out"], L["How long the cutaway power will take to fade out."], 4, { min = .1, max = 1, step = .1 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].cutaway.power.enabled end)

	return config
end

local individual = {
	player = true,
	target = true,
	targettarget = true,
	targettargettarget = true,
	focus = true,
	focustarget = true,
	pet = true,
	pettarget = true
}

local function UpdateCustomTextGroup(unit)
	if unit == 'party' or unit:find('raid') then
		for _, child in next, { UF[unit]:GetChildren() } do

			for _, subchild in next, { child:GetChildren() } do
				UF:Configure_CustomTexts(subchild)
				subchild:UpdateTags()
			end
		end
	elseif unit == 'boss' or unit == 'arena' then
		for i = 1, 10 do
			local unitframe = UF[unit..i]
			if unitframe then
				UF:Configure_CustomTexts(unitframe)
				unitframe:UpdateTags()
			end
		end
	else
		UF:Configure_CustomTexts(UF[unit])
		UF[unit]:UpdateTags()
	end
end

local function CreateCustomTextGroup(unit, objectName)
	if not E.private.unitframe.enable then return end
	local group = individual[unit] and 'individualUnits' or 'groupUnits'
	if not E.Options.args.unitframe.args[group].args[unit] then
		return
	elseif E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName] then
		E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].hidden = false -- Re-show existing custom texts which belong to current profile and were previously hidden
		tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName]) --Register this custom text config to be hidden again on profile change
		return
	end

	local config = ACH:Group(objectName, nil, nil, nil, function(info) return E.db.unitframe.units[unit].customTexts[objectName][info[#info]] end, function(info, value) E.db.unitframe.units[unit].customTexts[objectName][info[#info]] = value UpdateCustomTextGroup(unit) end)
	config.args.delete = ACH:Execute(L["Delete"], nil, 1, function() E.Options.args.unitframe.args[group].args[unit].args.customText.args.tags.args[objectName] = nil E.db.unitframe.units[unit].customTexts[objectName] = nil UpdateCustomTextGroup(unit) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 2)
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 3)
	config.args.size = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 5)
	config.args.justifyH = ACH:Select(L["JustifyH"], L["Sets the font instance's horizontal text alignment style."], 6, { CENTER = L["Center"], LEFT = L["Left"], RIGHT = L["Right"] })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 7, { min = -400, max = 400, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 8, { min = -400, max = 400, step = 1 })
	config.args.attachTextTo = ACH:Select(L["Attach Text To"], L["The object you want to attach to."], 9, attachToValues)
	config.args.text_format = ACH:Input(L["Text Format"], L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 100, nil, 'full')

	if unit == 'player' and UF.player.AdditionalPower then
		config.args.attachTextTo.values.AdditionalPower = L["Additional Power"]
	end

	E.Options.args.unitframe.args[group].args[unit].args.customText.args.tags.args[objectName] = config

	tinsert(CUSTOMTEXT_CONFIGS, config) --Register this custom text config to be hidden on profile change
end

--Custom Texts
function C:RefreshCustomTexts()
	--Hide any custom texts that don't belong to current profile
	for _, customText in pairs(CUSTOMTEXT_CONFIGS) do
		customText.hidden = true
	end
	wipe(CUSTOMTEXT_CONFIGS)

	for unit in pairs(E.db.unitframe.units) do
		if E.db.unitframe.units[unit].customTexts then
			for objectName in pairs(E.db.unitframe.units[unit].customTexts) do
				CreateCustomTextGroup(unit, objectName)
			end
		end
	end
end

local function GetOptionsTable_CustomText(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Custom Texts"], nil, nil, 'tab')
	config.args.tags = ACH:Group(L["Texts"])
	config.args.createCustomText = ACH:Input(L["Create Custom Text"], nil, 1, nil, 'full', C.Blank)
	config.args.createCustomText.set = function(_, textName) -- Needs split into a validate
		for object in pairs(E.db.unitframe.units[groupName]) do
			if object:lower() == textName:lower() then
				E:Print(L["The name you have selected is already in use by another element."])
				return
			end
		end

		if not E.db.unitframe.units[groupName].customTexts then
			E.db.unitframe.units[groupName].customTexts = {}
		end

		local frameName = 'ElvUF_'..E:StringTitle(groupName)
		if E.db.unitframe.units[groupName].customTexts[textName] or (_G[frameName] and _G[frameName].customTexts and _G[frameName].customTexts[textName] or _G[frameName..'Group1UnitButton1'] and _G[frameName..'Group1UnitButton1'].customTexts and _G[frameName..'Group1UnitButton1'][textName]) then
			E:Print(L["The name you have selected is already in use by another element."])
			return
		end

		E.db.unitframe.units[groupName].customTexts[textName] = CopyTable(G.unitframe.newCustomText)
		E.db.unitframe.units[groupName].customTexts[textName].text_format = strmatch(textName, '^%[') and textName or ''
		E.db.unitframe.units[groupName].customTexts[textName].size = E.db.unitframe.fontSize
		E.db.unitframe.units[groupName].customTexts[textName].font = E.db.unitframe.font
		E.db.unitframe.units[groupName].customTexts[textName].fontOutline = E.db.unitframe.fontOutline

		CreateCustomTextGroup(groupName, textName)
		updateFunc(UF, groupName, numUnits)

		E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'unitframe', individual[groupName] and 'individualUnits' or 'groupUnits', groupName, 'customText', textName)
	end

	return config
end

local function GetOptionsTable_Fader(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Fader"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].fader[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].fader[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.range = ACH:Toggle(L["Range"], nil, 2, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable end, groupName == 'player')
	config.args.hover = ACH:Toggle(L["Hover"], nil, 3, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.combat = ACH:Toggle(L["Combat"], nil, 4, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.unittarget = ACH:Toggle(L["Unit Target"], nil, 5, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end, groupName == 'player')
	config.args.playertarget = ACH:Toggle(groupName == 'player' and L["Target"] or L["Player Target"], nil, 6, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.focus = ACH:Toggle(L["Focus"], nil, 7, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.health = ACH:Toggle(L["Health"], nil, 8, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.power = ACH:Toggle(L["Power"], nil, 9, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.vehicle = ACH:Toggle(L["Vehicle"], nil, 10, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.casting = ACH:Toggle(L["Casting"], nil, 11, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.spacer = ACH:Spacer(12, 'full')
	config.args.delay = ACH:Range(L["Fade Out Delay"], nil, 13, { min = 0, max = 3, step = .01 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end)
	config.args.smooth = ACH:Range(L["Smooth"], nil, 14, { min = 0, max = 1, step = .01 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable end)
	config.args.minAlpha = ACH:Range(L["Min Alpha"], nil, 15, { min = 0, max = 1, step = .01 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable end)
	config.args.maxAlpha = ACH:Range(L["Max Alpha"], nil, 16, { min = 0, max = 1, step = .01 }, nil, nil, nil, function() return not E.db.unitframe.units[groupName].fader.enable end)

	return config
end

local function GetOptionsTable_HealPrediction(updateFunc, groupName, numGroup, subGroup)
	local config = ACH:Group(L["Heal Prediction"], L["Show an incoming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."], nil, nil, function(info) return E.db.unitframe.units[groupName].healPrediction[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].healPrediction[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.height = ACH:Range(L["Height"], nil, 2, { min = -1, max = 500, step = 1 })
	config.args.colorsButton = ACH:Execute(L["Colors"], nil, 3, function() ACD:SelectGroup('ElvUI', 'unitframe', 'allColorsGroup', 'healPrediction') end)
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], nil, 4, { TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' })
	config.args.absorbStyle = ACH:Select(L["Absorb Style"], nil, 5, { NONE = L["None"], NORMAL = L["Normal"], REVERSED = L["Reversed"], WRAPPED = L["Wrapped"], OVERFLOW = L["Overflow"] }, nil, nil, nil, nil, nil, not E.Retail)
	config.args.overflowButton = ACH:Execute(L["Max Overflow"], nil, 7, function() ACD:SelectGroup('ElvUI', 'unitframe', 'allColorsGroup', 'healPrediction') end)
	config.args.warning = ACH:Description(function()
		if E.db.unitframe.colors.healPrediction.maxOverflow == 0 then
			local text = L["Max Overflow is set to zero. Absorb Overflows will be hidden when using Overflow style.\nIf used together Max Overflow at zero and Overflow mode will act like Normal mode without the ending sliver of overflow."]
			return text .. (E.db.unitframe.units[groupName].healPrediction.absorbStyle == 'OVERFLOW' and ' |cffFF9933You are using Overflow with Max Overflow at zero.|r ' or '')
		end
	end, 50, 'medium', nil, nil, nil, nil, 'full')

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].healPrediction[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].healPrediction[info[#info]] = value updateFunc(UF, groupName, numGroup) end
	end

	return config
end

local function GetOptionsTable_Health(isGroupFrame, updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Health"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].health[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].health[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.reverseFill = ACH:Toggle(L["Reverse Fill"], nil, 1)
	config.args.attachTextTo = ACH:Select(L["Attach Text To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.colorOverride = ACH:Select(L["Class Color Override"], L["Override the default class color setting."], 5, colorOverrideValues, nil, nil, function(info) return E.db.unitframe.units[groupName][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.configureButton = ACH:Execute(L["Coloring"], L["This opens the UnitFrames Color settings. These settings affect all unitframes."], 6, function() ACD:SelectGroup('ElvUI', 'unitframe', 'allColorsGroup') end)

	config.args.textGroup = ACH:Group(L["Text Options"], nil, 10)
	config.args.textGroup.inline = true
	config.args.textGroup.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPoints)
	config.args.textGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -400, max = 400, step = 1 })
	config.args.textGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -400, max = 400, step = 1 })
	config.args.textGroup.args.text_format = ACH:Input(L["Text Format"], L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 4, nil, 'full')

	if isGroupFrame then
		config.args.orientation = ACH:Select(L["Statusbar Fill Orientation"], L["Direction the health bar moves when gaining/losing health."], 9, { HORIZONTAL = L["Horizontal"], VERTICAL = L["Vertical"] })
	end

	if groupName == 'pet' or groupName == 'raidpet' then
		config.args.colorPetByUnitClass = ACH:Toggle(L["Color by Unit Class"], nil, 2)

		if groupName == 'pet' and E.myclass == 'HUNTER' then
			config.args.colorHappiness = ACH:Toggle(L["Color by Happiness"], nil, 3)
		end
	end

	return config
end

local function GetOptionsTable_InformationPanel(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Information Panel"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].infoPanel[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].infoPanel[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.transparent = ACH:Toggle(L["Transparent"], nil, 2)
	config.args.height = ACH:Range(L["Height"], nil, 3, { min = 2, max = 30, step = 1 })

	return config
end

local function GetOptionsTable_Name(updateFunc, groupName, numUnits, subGroup)
	local config = ACH:Group(L["Name"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].name[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].name[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPoints)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -100, max = 100, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -100, max = 100, step = 1 })
	config.args.attachTextTo = ACH:Select(L["Attach Text To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.text_format = ACH:Input(L["Text Format"], L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 5, nil, 'full')

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].name[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].name[info[#info]] = value updateFunc(UF, groupName, numUnits) end
	end

	return config
end

local function GetOptionsTable_PhaseIndicator(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Phase Indicator"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].phaseIndicator[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].phaseIndicator[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.scale = ACH:Range(L["Scale"], nil, 2, { min = .5, max = 2, step = .01, isPercent = true })
	config.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })

	return config
end

local function GetOptionsTable_Portrait(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Portrait"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].portrait[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].portrait[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.warning = ACH:Description(function() return (E.db.unitframe.units[groupName].orientation == 'MIDDLE' and L["Overlay mode is forced when the Frame Orientation is set to Middle."]) or '' end, 1, 'medium', nil, nil, nil, nil, 'full')
	config.args.enable = ACH:Toggle(L["Enable"], nil, 2, nil, L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."])
	config.args.style = ACH:Select(L["Style"], L["Select the display method of the portrait."], 3, { ['2D'] = L["2D"], ['3D'] = L["3D"], Class = L["CLASS"] })
	config.args.paused = ACH:Toggle(L["Pause"], nil, 4, nil, nil, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end)
	config.args.overlay = ACH:Toggle(L["Overlay"], L["The Portrait will overlay the Healthbar. This will be automatically happen if the Frame Orientation is set to Middle."], 5, nil, nil, nil, function(info) return (E.db.unitframe.units[groupName].orientation == 'MIDDLE') or E.db.unitframe.units[groupName].portrait[info[#info]] end, nil, function() return E.db.unitframe.units[groupName].orientation == 'MIDDLE' end)
	config.args.fullOverlay = ACH:Toggle(L["Full Overlay"], L["This option allows the overlay to span the whole health, including the background."], 6, nil, nil, nil, nil, nil, function() return not (E.db.unitframe.units[groupName].orientation == 'MIDDLE' or E.db.unitframe.units[groupName].portrait.overlay) end)
	config.args.width = ACH:Range(L["Width"], nil, 7, { min = 15, max = 150, step = 1 }, nil, nil, nil, function() return (E.db.unitframe.units[groupName].orientation == 'MIDDLE' or E.db.unitframe.units[groupName].portrait.overlay) end)
	config.args.overlayAlpha = ACH:Range(L["Overlay Alpha"], L["Set the alpha level of portrait when frame is overlayed."], 8, { min = .01, max = 1, step = .01 }, nil, nil, nil, function() return not (E.db.unitframe.units[groupName].orientation == 'MIDDLE' or E.db.unitframe.units[groupName].portrait.overlay) end)
	config.args.rotation = ACH:Range(L["Model Rotation"], nil, 9, { min = 0, max = 360, step = 1 }, nil, nil, nil, function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end)
	config.args.desaturation = ACH:Range(L["Desaturate"], nil, 10, { min = 0, max = 1, step = .01 }, nil, nil, nil, function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end)
	config.args.camDistanceScale = ACH:Range(L["Camera Distance Scale"], L["How far away the portrait is from the camera."], 11, { min = .01, max = 4, step = .01 }, nil, nil, nil, function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end)
	config.args.xOffset = ACH:Range(L["X-Offset"], L["Position the Model horizontally."], 12, { min = -1, max = 1, step = .01 }, nil, nil, nil, function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end)
	config.args.yOffset = ACH:Range(L["Y-Offset"], L["Position the Model vertically."], 13, { min = -1, max = 1, step = .01 }, nil, nil, nil, function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end)

	return config
end

local function GetOptionsTable_Power(hasDetatchOption, updateFunc, groupName, numUnits, hasStrataLevel)
	local config = ACH:Group(L["Power"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].power[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].power[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.attachTextTo = ACH:Select(L["Attach Text To"], L["The object you want to attach to."], 2, attachToValues)
	config.args.width = ACH:Select(L["Style"], nil, 3, { fill = L["Filled"], spaced = L["Spaced"], inset = L["Inset"], offset = L["Offset"] })
	config.args.height = ACH:Range(L["Height"], nil, 4, { min = UF.thinBorders and 3 or 7, max = 50, step = 1 }, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].power.width == 'offset' end)
	config.args.offset = ACH:Range(L["Offset"], L["Offset of the powerbar to the healthbar, set to 0 to disable."], 5, { min = 0, max = 20, step = 1 }, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].power.width ~= 'offset' end)
	config.args.powerPrediction = ACH:Toggle(L["Power Prediction"], nil, 6)
	config.args.reverseFill = ACH:Toggle(L["Reverse Fill"], nil, 8)

	config.args.configureButton = ACH:Execute(L["Coloring"], L["This opens the UnitFrames Color settings. These settings affect all unitframes."], 10, function() ACD:SelectGroup('ElvUI', 'unitframe', 'allColorsGroup') end)

	config.args.textGroup = ACH:Group(L["Text Options"], nil, 20)
	config.args.textGroup.inline = true
	config.args.textGroup.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPoints)
	config.args.textGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -400, max = 400, step = 1 })
	config.args.textGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -400, max = 400, step = 1 })
	config.args.textGroup.args.text_format = ACH:Input(L["Text Format"], L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 4, nil, 'full')

	if hasDetatchOption then
		config.args.detachGroup = ACH:Group(L["Detach From Frame"], nil, 20)
		config.args.detachGroup.inline = true
		config.args.detachGroup.args.detachFromFrame = ACH:Toggle(L["Detach From Frame"], nil, 10)
		config.args.detachGroup.args.autoHide = ACH:Toggle(L["Auto-Hide"], nil, 11, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].power.detachFromFrame end)
		config.args.detachGroup.args.notInCombat = ACH:Toggle(L["Hide Out of Combat"], nil, 12, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].power.autoHide end)
		config.args.detachGroup.args.detachedWidth = ACH:Range(L["Detached Width"], nil, 13, { min = 30, max = 1000, step = 1 }, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].power.detachFromFrame end)
		config.args.detachGroup.args.parent = ACH:Select(L["Parent"], L["Choose UIPARENT to prevent it from hiding with the unitframe."], 14, { FRAME = 'FRAME', UIPARENT = 'UIPARENT' }, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].power.detachFromFrame end)
	end

	if hasStrataLevel then
		config.args.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, 'power')
	end

	if groupName == 'party' or strmatch(groupName, '^raid(%d)') then
		config.args.displayAltPower = ACH:Toggle(L["Swap to Alt Power"], nil, 9)
	end

	if groupName == 'player' then
		config.args.EnergyManaRegen = ACH:Toggle(L["Energy/Mana Regen Tick"], L["Enables the five-second-rule ticks for Mana classes and Energy ticks for Rogues and Druids."], 7, nil, nil, nil, nil, nil, nil, E.Retail)
	end

	return config
end

local function GetOptionsTable_PVPClassificationIndicator(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["PvP Classification Indicator"], L["Cart / Flag / Orb / Assassin Bounty"], nil, nil, function(info) return E.db.unitframe.units[groupName].pvpclassificationindicator[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].pvpclassificationindicator[info[#info]] = value updateFunc(UF, groupName, numGroup) end, nil, not E.Retail)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.size = ACH:Range(L["Size"], nil, 2, { min = 12, max = 64, step = 1 })
	config.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })

	return config
end

local function GetOptionsTable_PVPIcon(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["PvP & Prestige Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].pvpIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].pvpIcon[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.scale = ACH:Range(L["Scale"], nil, 2, { min = .5, max = 2, step = .01, isPercent = true })
	config.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })

	return config
end

local function GetOptionsTable_RaidDebuff(updateFunc, groupName)
	local config = ACH:Group(L["Raid Debuff Indicator"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].rdebuffs[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].rdebuffs[info[#info]] = value updateFunc(UF, groupName) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.showDispellableDebuff = ACH:Toggle(L["Show Dispellable Debuffs"], nil, 2)
	config.args.onlyMatchSpellID = ACH:Toggle(L["Only Match SpellID"], L["When enabled it will only show spells that were added to the filter using a spell ID and not a name."], 3)
	config.args.size = ACH:Range(L["Size"], nil, 4, { min = 8, max = 100, step = 1 })
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 5)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 6, C.Values.FontSize)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 7)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -300, max = 300, step = 1 })

	config.args.configureButton = ACH:Execute(L["Configure Auras"], nil, 10, function() C:SetToFilterConfig('RaidDebuffs') end)

	config.args.duration = ACH:Group(L["Duration Text"], nil, 12, nil, function(info) return E.db.unitframe.units[groupName].rdebuffs.duration[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].rdebuffs.duration[info[#info]] = value updateFunc(UF, groupName) end)
	config.args.duration.inline = true
	config.args.duration.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPoints)
	config.args.duration.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -100, max = 100, step = 1 })
	config.args.duration.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -100, max = 100, step = 1 })
	config.args.duration.args.color = ACH:Color(L["COLOR"], nil, 4, true, nil, function() local c, d = E.db.unitframe.units[groupName].rdebuffs.duration.color, P.unitframe.units[groupName].rdebuffs.duration.color return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local c = E.db.unitframe.units[groupName].rdebuffs.duration.color c.r, c.g, c.b, c.a = r, g, b, a updateFunc(UF, groupName) end)

	config.args.stack = ACH:Group(L["Stack Counter"], nil, 13, nil, function(info) return E.db.unitframe.units[groupName].rdebuffs.stack[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].rdebuffs.stack[info[#info]] = value updateFunc(UF, groupName) end)
	config.args.stack.inline = true
	config.args.stack.args.color = ACH:Color(L["COLOR"], nil, 4, true, nil, function() local c, d = E.db.unitframe.units[groupName].rdebuffs.stack.color, P.unitframe.units[groupName].rdebuffs.stack.color return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local c = E.db.unitframe.units[groupName].rdebuffs.stack.color c.r, c.g, c.b, c.a = r, g, b, a updateFunc(UF, groupName) end)
	config.args.stack.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPoints)
	config.args.stack.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -100, max = 100, step = 1 })
	config.args.stack.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -100, max = 100, step = 1 })

	return config
end

local function GetOptionsTable_RaidIcon(updateFunc, groupName, numUnits, subGroup)
	local config = ACH:Group(L["Target Marker Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].raidicon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].raidicon[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].raidicon[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].raidicon[info[#info]] = value updateFunc(UF, groupName, numUnits) end
	end

	return config
end

local function GetOptionsTable_RoleIcons(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Role Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].roleIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].roleIcon[info[#info]] = value updateFunc(UF, groupName, numGroup) end, nil, E.Classic)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.options = ACH:MultiSelect(' ', nil, 1, { tank = L["Show For Tanks"], healer = L["Show For Healers"], damager = L["Show For DPS"], combatHide = L["Hide In Combat"] }, nil, nil, function(_, key) return E.db.unitframe.units[groupName].roleIcon[key] end, function(_, key, value) E.db.unitframe.units[groupName].roleIcon[key] = value updateFunc(UF, groupName, numGroup) end)
	config.args.position = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)
	config.args.attachTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_RaidRoleIcons(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Raid Role Indicator"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].raidRoleIcons[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].raidRoleIcons[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.scale = ACH:Range(L["Scale"], nil, 1, { min = .5, max = 2, step = .01, isPercent = true })
	config.args.position = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ReadyCheckIcon(updateFunc, groupName)
	local config = ACH:Group(L["Ready Check Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].readycheckIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].readycheckIcon[info[#info]] = value updateFunc(UF, groupName) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.position = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ResurrectIcon(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Resurrect Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].resurrectIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].resurrectIcon[info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_SummonIcon(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Summon Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].summonIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].summonIcon[info[#info]] = value updateFunc(UF, groupName, numUnits) end, nil, not E.Retail)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, C.Values.AllPoints)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ClassBar(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Class Bar"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].classbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].classbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end, nil, function() return groupName ~= 'player' and not E.Retail end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.height = ACH:Range(L["Height"], nil, 1, { min = 2, max = 30, step = 1 })
	config.args.fill = ACH:Select(L["Style"], nil, 3, { fill = L["Filled"], spaced = L["Spaced"] })

	if groupName == 'party' or strmatch(groupName, '^raid(%d)') then
		config.args.altPowerColor = ACH:Color(L["COLOR"], nil, 3, nil, nil, function(info) local t, d = E.db.unitframe.units[groupName].classbar[info[#info]], P.unitframe.units[groupName].classbar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.units[groupName].classbar[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end)
		config.args.altPowerTextFormat = ACH:Input(L["Text Format"], L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 6, nil, 'full')
	elseif groupName == 'player' then
		config.args.height.max = function() return E.db.unitframe.units.player.classbar.detachFromFrame and 300 or 30 end
		config.args.autoHide = ACH:Toggle(L["Auto-Hide"], nil, 5)
		config.args.sortDirection = ACH:Select(L["Sort Direction"], L["Defines the sort order of the selected sort method."], 7, { asc = L["Ascending"], desc = L["Descending"], NONE = L["None"] }, nil, nil, nil, nil, nil, function() return (E.myclass ~= 'DEATHKNIGHT') end)

		config.args.altManaGroup = ACH:Group(L["Display Mana"], nil, 20, nil, function(info) return E.db.unitframe.altManaPowers[E.myclass][info[#info]] end, function(info, value) E.db.unitframe.altManaPowers[E.myclass][info[#info]] = value updateFunc(UF, groupName, numUnits) end, nil, function() if E.Retail then return not E.db.unitframe.altManaPowers[E.myclass] else return E.myclass ~= 'DRUID' end end)
		config.args.altManaGroup.args.info = ACH:Description(L["Will display mana when main power is:"], 0)
		config.args.altManaGroup.inline = true
		if E.myclass == 'DRUID' then
			config.args.altManaGroup.args.Rage = ACH:Toggle(L["RAGE"], nil, 1)
			config.args.altManaGroup.args.LunarPower = ACH:Toggle(L["LUNAR_POWER"], nil, 2, nil, nil, nil, nil, nil, nil, not E.Retail)
		elseif E.myclass == 'SHAMAN' then
			config.args.altManaGroup.args.Maelstrom = ACH:Toggle(L["MAELSTROM"], nil, 1, nil, nil, nil, nil, nil, nil, not E.Retail)
		elseif E.myclass == 'PRIEST' then
			config.args.altManaGroup.args.Insanity = ACH:Toggle(L["INSANITY"], nil, 1, nil, nil, nil, nil, nil, nil, not E.Retail)
		end

		config.args.detachGroup = ACH:Group(L["Detach From Frame"], nil, 30, nil, function(info) return E.db.unitframe.units.player.classbar[info[#info]] end, function(info, value) E.db.unitframe.units.player.classbar[info[#info]] = value UF:CreateAndUpdateUF('player') end, nil, groupName ~= 'player')
		config.args.detachGroup.inline = true
		config.args.detachGroup.args.detachFromFrame = ACH:Toggle(L["Enable"], nil, 1)
		config.args.detachGroup.args.detachedWidth = ACH:Range(L["Detached Width"], nil, 2, { min = 3, max = 1000, step = 1 }, nil, nil, nil, nil, function() return not E.db.unitframe.units.player.classbar.detachFromFrame end)
		config.args.detachGroup.args.orientation = ACH:Select(L["Frame Orientation"], nil, 3, { HORIZONTAL = L["Horizontal"], VERTICAL = L["Vertical"] }, nil, nil, nil, nil, function() return not E.db.unitframe.units.player.classbar.detachFromFrame end)
		config.args.detachGroup.args.verticalOrientation = ACH:Toggle(L["Vertical Fill Direction"], nil, 4, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units.player.classbar.detachFromFrame end)
		config.args.detachGroup.args.spacing = ACH:Range(L["Spacing"], nil, 5, { min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 20, step = 1 }, nil, nil, nil, nil, function() return not E.db.unitframe.units.player.classbar.detachFromFrame end)
		config.args.detachGroup.args.parent = ACH:Select(L["Parent"], L["Choose UIPARENT to prevent it from hiding with the unitframe."], 6, { FRAME = 'FRAME', UIPARENT = 'UIPARENT' }, nil, nil, nil, nil, function() return not E.db.unitframe.units.player.classbar.detachFromFrame end)
		config.args.detachGroup.args.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, 'classbar')
	end

	if groupName ~= 'player' then
		config.name = L["Alternative Power"]
	end

	return config
end

local function GetOptionsTable_GeneralGroup(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["General"], nil, 1)
	config.args.orientation = ACH:Select(L["Frame Orientation"], L["Set the orientation of the UnitFrame."], 1, orientationValues)
	config.args.disableMouseoverGlow = ACH:Toggle(L["Block Mouseover Glow"], L["Forces Mouseover Glow to be disabled for these frames"], 2)
	config.args.disableTargetGlow = ACH:Toggle(L["Block Target Glow"], L["Forces Target Glow to be disabled for these frames"], 3)
	config.args.disableFocusGlow = ACH:Toggle(L["Block Focus Glow"], L["Forces Focus Glow to be disabled for these frames"], 4)

	if groupName ~= 'tank' and groupName ~= 'assist' then
		config.args.hideonnpc = ACH:Toggle(L["Text Toggle On NPC"], L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."], 5, nil, nil, nil, function() return E.db.unitframe.units[groupName].power.hideonnpc end, function(_, value) E.db.unitframe.units[groupName].power.hideonnpc = value updateFunc(UF, groupName, numUnits) end)
	end

	if groupName ~= 'party' and groupName ~= 'assist' and groupName ~= 'tank' and not strmatch(groupName, '^raid') then
		config.args.smartAuraPosition = ACH:Select(L["Smart Aura Position"], L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."], 6, C.Values.SmartAuraPositions)
	end

	if groupName == 'arena' then
		config.args.pvpSpecIcon = ACH:Toggle(L["Spec Icon"], L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."], 5)
	else
		config.args.threatStyle = ACH:Select(L["Threat Display Mode"], nil, 7, threatValues)
	end

	config.args.positionsGroup = ACH:Group(L["Size and Positions"], nil, 100, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
	config.args.positionsGroup.inline = true
	config.args.positionsGroup.args.width = ACH:Range(L["Width"], nil, 1, { min = 40, max = 1000, step = 1 })
	config.args.positionsGroup.args.height = ACH:Range(L["Height"], nil, 2, { min = 5, max = 500, step = 1 })

	if groupName == 'party' or strmatch(groupName, '^raid') then
		config.args.positionsGroup.args.growthDirection = ACH:Select(L["Growth Direction"], L["Growth direction from the first unitframe."], 4, C.Values.GrowthDirection)
		config.args.positionsGroup.args.numGroups = ACH:Range(L["Number of Groups"], nil, 7, { min = 1, max = 8, step = 1 }, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) if UF[groupName].isForced then UF:HeaderConfig(UF[groupName]) UF:HeaderConfig(UF[groupName], true) end end, nil, groupName == 'party')
		config.args.positionsGroup.args.groupsPerRowCol = ACH:Range(L["Groups Per Row/Column"], nil, 8, { min = 1, max = 8, step = 1 }, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) if UF[groupName].isForced then UF:HeaderConfig(UF[groupName]) UF:HeaderConfig(UF[groupName], true) end end, nil, groupName == 'party')
		config.args.positionsGroup.args.horizontalSpacing = ACH:Range(L["Horizontal Spacing"], nil, 9, { min = -1, max = 50, step = 1 })
		config.args.positionsGroup.args.verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 10, { min = -1, max = 50, step = 1 })
		config.args.positionsGroup.args.groupSpacing = ACH:Range(L["Group Spacing"], L["Additional spacing between each individual group."], 11, { min = 0, max = 50, step = 1 }, nil, nil, nil, nil, groupName == 'party')

		config.args.visibilityGroup = ACH:Group(L["Visibility"], nil, 200, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
		config.args.visibilityGroup.inline = true
		config.args.visibilityGroup.args.showPlayer = ACH:Toggle(L["Display Player"], L["When true, the header includes the player when not in a raid."], 0)
		config.args.visibilityGroup.args.defaults = ACH:Execute(L["Restore Defaults"], function() return P.unitframe.units[groupName].visibility end, 1, function() E.db.unitframe.units[groupName].visibility = P.unitframe.units[groupName].visibility updateFunc(UF, groupName, numUnits) end, nil, true)
		config.args.visibilityGroup.args.visibility = ACH:Input(L["Visibility"], L["VISIBILITY_DESC"], 2, nil, 'full')

		config.args.sortingGroup = ACH:Group(L["Grouping & Sorting"], nil, 300, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
		config.args.sortingGroup.inline = true
		config.args.sortingGroup.args.raidWideSorting = ACH:Toggle(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], 1, nil, nil, nil, nil, nil, nil, groupName == 'party')
		config.args.sortingGroup.args.invertGroupingOrder = ACH:Toggle(L["Invert Grouping Order"], L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."], 2, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].raidWideSorting end)
		config.args.sortingGroup.args.startFromCenter = ACH:Toggle(L["Start Near Center"], L["The initial group will start near the center and grow out."], 3, nil, nil, nil, nil, nil, nil, function() return groupName ~= 'party' and not E.db.unitframe.units[groupName].raidWideSorting end)
		config.args.sortingGroup.args.groupBy = ACH:Select(L["Group By"], L["Set the order that the group will sort."], 4, { CLASS = L["CLASS"], ROLE = L["ROLE"], NAME = L["Name"], GROUP = L["GROUP"], INDEX = L["Index"] })
		config.args.sortingGroup.args.sortDir = ACH:Select(L["Sort Direction"], nil, 5, { ASC = L["Ascending"], DESC = L["Descending"] })
		config.args.sortingGroup.args.sortMethod = ACH:Select(L["Sort Method"], nil, 6, { NAME = L["Name"], INDEX = L["Index"] }, nil, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].groupBy == 'INDEX' or E.db.unitframe.units[groupName].groupBy == 'NAME' end)

		config.args.sortingGroup.args.roleSetup = ACH:Group(L["Role Order"], nil, 7, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].groupBy ~= 'ROLE' end)
		config.args.sortingGroup.args.roleSetup.inline = true
		config.args.sortingGroup.args.roleSetup.args.ROLE1 = ACH:Select(' ', nil, 1, roles)
		config.args.sortingGroup.args.roleSetup.args.ROLE2 = ACH:Select(' ', nil, 2, roles)
		config.args.sortingGroup.args.roleSetup.args.ROLE3 = ACH:Select(' ', nil, 3, roles)

		config.args.sortingGroup.args.classSetup = ACH:Group(L["Class Order"], nil, 7, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].groupBy ~= 'CLASS' end)
		config.args.sortingGroup.args.classSetup.inline = true

		for i = 1, NUM_CLASSES do
			config.args.sortingGroup.args.classSetup.args['CLASS'..i] = ACH:Select(' ', nil, i, classTable)
		end
	else
		config.args.positionsGroup.args.width.set = function(info, value) if E.db.unitframe.units[groupName].castbar and E.db.unitframe.units[groupName].castbar.width == E.db.unitframe.units[groupName][info[#info]] then E.db.unitframe.units[groupName].castbar.width = value end E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end

		if groupName == 'boss' or groupName == 'arena' then
			config.args.positionsGroup.args.spacing = ACH:Range(L["Spacing"], nil, 3, { min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 400, step = 1 })
			config.args.positionsGroup.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 4, { UP = L["Bottom to Top"], DOWN = L["Top to Bottom"], LEFT = L["Right to Left"], RIGHT = L["Left to Right"] })
		end

		if groupName == 'tank' or groupName == 'assist' then
			config.args.positionsGroup.args.verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 3, { min = 0, max = 100, step = 1 })
		end
	end

	if groupName == 'target' or groupName == 'boss' or groupName == 'tank' or groupName == 'arena' or groupName == 'assist' then
		config.args.middleClickFocus = ACH:Toggle(L["Middle Click - Set Focus"], L["Middle clicking the unit frame will cause your focus to match the unit.\n|cffff3333Note:|r If Clique is enabled, this option only effects ElvUI frames if they are not blacklisted in Clique."], 16)
	end

	return config
end

local function GetOptionsTable_CombatIconGroup(updateFunc, groupName, numUnits)
	local config = ACH:Group((groupName == 'party' and E.NewSign or '')..L["Combat Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].CombatIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].CombatIcon[info[#info]] = value updateFunc(UF, groupName, numUnits) UF:TestingDisplay_CombatIndicator(UF[groupName]) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.size = ACH:Range(L["Size"], nil, 2, { min = 12, max = 64, step = 1 })
	config.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
	config.args.defaultColor = ACH:Toggle(L["Default Color"], nil, 6)
	config.args.color = ACH:Color(L["COLOR"], nil, 7, true, nil, function() local c, d = E.db.unitframe.units[groupName].CombatIcon.color, P.unitframe.units[groupName].CombatIcon.color return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local c = E.db.unitframe.units[groupName].CombatIcon.color c.r, c.g, c.b, c.a = r, g, b, a updateFunc(UF, groupName, numUnits) UF:TestingDisplay_CombatIndicator(UF[groupName]) end, nil, function() return E.db.unitframe.units[groupName].CombatIcon.defaultColor end)
	config.args.texture = ACH:Select(L["Texture"], nil, 8, function() local table = { CUSTOM = L["CUSTOM"], DEFAULT = L["DEFAULT"] } for key, path in next, E.Media.CombatIcons do if key ~= 'DEFAULT' then table[key] = E:TextureString(path, ':14') end end return table end)
	config.args.texture.sortByValue = true
	config.args.customTexture = ACH:Input(L["Custom Texture"], nil, 9, nil, 250, nil, function(_, value) E.db.unitframe.units[groupName].CombatIcon.customTexture = (value and (not value:match('^%s-$')) and value) or nil updateFunc(UF, groupName, numUnits) UF:TestingDisplay_CombatIndicator(UF[groupName]) end)

	return config
end

local filterList = {}
local function modifierList()
	wipe(filterList)

	filterList.NONE = L["None"]
	filterList.Blacklist = L["Blacklist"]
	filterList.Whitelist = L["Whitelist"]

	local list = E.global.unitframe.aurafilters
	if list then
		for filter in pairs(list) do
			if not G.unitframe.aurafilters[filter] then
				filterList[filter] = filter
			end
		end
	end

	return filterList
end

E.Options.args.unitframe = ACH:Group(L["UnitFrames"], nil, 2, 'tab', function(info) return E.db.unitframe[info[#info]] end, function(info, value) E.db.unitframe[info[#info]] = value end)
local UnitFrame = E.Options.args.unitframe.args

UnitFrame.intro = ACH:Description(L["UNITFRAME_DESC"], 0)
UnitFrame.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.unitframe.enable end, function(_, value) E.private.unitframe.enable = value E.ShowPopup = true end)
UnitFrame.statusbar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], L["Main statusbar texture."], 2, nil, nil, function(info, value) E.db.unitframe[info[#info]] = value UF:Update_StatusBars() end)
UnitFrame.resetFilters = ACH:Execute(L["Reset Aura Filters"], nil, 3, function() E:StaticPopup_Show('RESET_UF_AF') end)
UnitFrame.borderOptions = ACH:Execute(L["Border Options"], nil, 4, function() ACD:SelectGroup('ElvUI', 'general', 'media') end)

UnitFrame.generalOptionsGroup = ACH:Group(L["General"], nil, 5, 'tree')
UnitFrame.generalOptionsGroup.args.targetOnMouseDown = ACH:Toggle(L["Target On Mouse-Down"], L["Target units on mouse down rather than mouse up.\n|cffff3333Note:|r If Clique is enabled, this option only effects ElvUI frames if they are not blacklisted in Clique."], 2)
UnitFrame.generalOptionsGroup.args.targetSound = ACH:Toggle(L["Targeting Sound"], L["Enable a sound if you select a unit."], 3)
UnitFrame.generalOptionsGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 4, nil, nil, nil, nil, function(info, value) E.db.unitframe[info[#info]] = value UF:Update_AllFrames() end)
UnitFrame.generalOptionsGroup.args.maxAllowedGroups = ACH:Toggle(E.NewSign..L["Max Allowed Groups"], L["Groups will be maxed as Mythic to 4, Other Raids to 6, and PVP / World to 8."], 5, nil, nil, nil, nil, function(info, value) E.db.unitframe[info[#info]] = value UF:ZONE_CHANGED_NEW_AREA() end)

UnitFrame.generalOptionsGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 10, nil, nil, function(info, value) E.db.unitframe[info[#info]] = value UF:Update_FontStrings() end)
UnitFrame.generalOptionsGroup.args.fontGroup.inline = true
UnitFrame.generalOptionsGroup.args.fontGroup.args.font = ACH:SharedMediaFont(L["Default Font"], L["The font that the unitframes will use."], 1)
UnitFrame.generalOptionsGroup.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
UnitFrame.generalOptionsGroup.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 5)

UnitFrame.generalOptionsGroup.args.modifiers = ACH:Group(L["Filter Modifiers"], nil, 20, nil, function(info) return E.db.unitframe.modifiers[info[#info]] end, function(info, value) E.db.unitframe.modifiers[info[#info]] = value end)
UnitFrame.generalOptionsGroup.args.modifiers.inline = true
UnitFrame.generalOptionsGroup.args.modifiers.args.SHIFT = ACH:Select(L["SHIFT"], nil, 1, modifierList)
UnitFrame.generalOptionsGroup.args.modifiers.args.ALT = ACH:Select(L["ALT"], nil, 2, modifierList)
UnitFrame.generalOptionsGroup.args.modifiers.args.CTRL = ACH:Select(L["CTRL"], nil, 3, modifierList)

UnitFrame.generalOptionsGroup.args.raidDebuffIndicator = ACH:Group(L["Raid Debuff Indicator"], nil, 30, nil, function(info) return E.global.unitframe.raidDebuffIndicator[info[#info]] end, function(info, value) E.global.unitframe.raidDebuffIndicator[info[#info]] = value UF:UpdateAllHeaders() end)
UnitFrame.generalOptionsGroup.args.raidDebuffIndicator.inline = true
UnitFrame.generalOptionsGroup.args.raidDebuffIndicator.args.instanceFilter = ACH:Select(L["Dungeon & Raid Filter"], nil, 1, function() wipe(filters) local list = E.global.unitframe.aurafilters if not list then return end for filter in pairs(list) do filters[filter] = filter end return filters end)
UnitFrame.generalOptionsGroup.args.raidDebuffIndicator.args.otherFilter = ACH:Select(L["Other Filter"], nil, 2, function() wipe(filters) local list = E.global.unitframe.aurafilters if not list then return end for filter in pairs(list) do filters[filter] = filter end return filters end)

UnitFrame.generalOptionsGroup.args.disabledBlizzardFrames = ACH:Group(L["Disabled Blizzard Frames"], nil, 40, nil, function(_, key) return E.private.unitframe.disabledBlizzardFrames[key] end, function(_, key, value) E.private.unitframe.disabledBlizzardFrames[key] = value E.ShowPopup = true end)
UnitFrame.generalOptionsGroup.args.disabledBlizzardFrames.inline = true

UnitFrame.generalOptionsGroup.args.disabledBlizzardFrames.args.individual = ACH:MultiSelect(L["Individual Units"], nil, 1, { castbar = L["Cast Bar"], player = L["Player"], target = L["Target"], focus = not E.Classic and L["Focus"] or nil })
UnitFrame.generalOptionsGroup.args.disabledBlizzardFrames.args.group = ACH:MultiSelect(L["Group Units"], nil, 2, { party = L["Party"], raid = L["Raid"], boss = (E.Retail or E.Wrath) and L["Boss"] or nil, arena = not E.Classic and L["Arena"] or nil })

UnitFrame.allColorsGroup = ACH:Group(L["Colors"], nil, 10, 'tree', function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end, function() return not E.UnitFrames.Initialized end)
local Colors = UnitFrame.allColorsGroup.args

Colors.healthGroup = ACH:Group(L["Health"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.unitframe.colors[info[#info]], P.unitframe.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b else return E.db.unitframe.colors[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.unitframe.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a or 1 else local value = ... E.db.unitframe.colors[info[#info]] = value end UF:Update_AllFrames() end)
Colors.healthGroup.args.colorhealthbyvalue = ACH:Toggle(L["Health By Value"], L["Color health by amount remaining."], 1)
Colors.healthGroup.args.healthselection = ACH:Toggle(L["Selection Health"], L["Color health by color selection."], 2, nil, nil, nil, nil, nil, nil, not E.Retail)
Colors.healthGroup.args.healthclass = ACH:Toggle(L["Class Health"], L["Color health by classcolor or reaction."], 3, nil, nil, nil, nil, nil, function() return E.Retail and E.db.unitframe.colors.healthselection end)
Colors.healthGroup.args.forcehealthreaction = ACH:Toggle(L["Force Reaction Color"], L["Forces reaction color instead of class color on units controlled by players."], 4, nil, nil, nil, nil, nil, function() return E.db.unitframe.colors.healthselection or not E.db.unitframe.colors.healthclass end)
Colors.healthGroup.args.transparentHealth = ACH:Toggle(L["Transparent"], L["Make textures transparent."], 6)
Colors.healthGroup.args.useDeadBackdrop = ACH:Toggle(L["Use Dead Backdrop"], nil, 7)
Colors.healthGroup.args.classbackdrop = ACH:Toggle(L["Class Backdrop"], L["Color the health backdrop by class or reaction."], 8, nil, nil, nil, nil, nil, function() return E.db.unitframe.colors.customhealthbackdrop end)
Colors.healthGroup.args.customhealthbackdrop = ACH:Toggle(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 9)
Colors.healthGroup.args.healthMultiplier = ACH:Range(L["Health Backdrop Multiplier"], nil, 10, { min = 0, softMax = 0.75, max = 1, step = .01 }, nil, nil, nil, function() return E.db.unitframe.colors.customhealthbackdrop end)
Colors.healthGroup.args.health_backdrop = ACH:Color(L["Health Backdrop"], nil, 20, nil, nil, nil, nil, function() return not E.db.unitframe.colors.customhealthbackdrop end)
Colors.healthGroup.args.tapped = ACH:Color(L["Tapped"], nil, 21)
Colors.healthGroup.args.health = ACH:Color(L["Health"], nil, 22)
Colors.healthGroup.args.disconnected = ACH:Color(L["Disconnected"], nil, 23)
Colors.healthGroup.args.health_backdrop_dead = ACH:Color(L["Custom Dead Backdrop"], L["Use this backdrop color for units that are dead or ghosts."], 24, nil, 250)

Colors.powerGroup = ACH:Group(L["Power"], nil, nil, nil, function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end)
Colors.powerGroup.args.transparentPower = ACH:Toggle(L["Transparent"], L["Make textures transparent."], 1)
Colors.powerGroup.args.invertPower = ACH:Toggle(L["Invert Colors"], L["Invert foreground and background colors."], 2, nil, nil, nil, nil, nil, function() return not E.db.unitframe.colors.transparentPower end)
Colors.powerGroup.args.powerselection = ACH:Toggle(L["Selection Power"], L["Color power by color selection."], 3, nil, nil, nil, nil, nil, not E.Retail)
Colors.powerGroup.args.powerclass = ACH:Toggle(L["Class Power"], L["Color power by classcolor or reaction."], 4, nil, nil, nil, nil, nil, function() return E.db.unitframe.colors.powerselection end)
Colors.powerGroup.args.spacer2 = ACH:Spacer(5, 'full')
Colors.powerGroup.args.custompowerbackdrop = ACH:Toggle(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 6)
Colors.powerGroup.args.power_backdrop = ACH:Color(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 7, nil, nil, function(info) local t, d = E.db.unitframe.colors[info[#info]], P.unitframe.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, function() return not E.db.unitframe.colors.custompowerbackdrop end)

Colors.castBars = ACH:Group(L["Cast Bar"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.unitframe.colors[info[#info]], P.unitframe.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b else return E.db.unitframe.colors[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.unitframe.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a or 1 else local value = ... E.db.unitframe.colors[info[#info]] = value end UF:Update_AllFrames() end)
Colors.castBars.args.transparentCastbar = ACH:Toggle(L["Transparent"], L["Make textures transparent."], 1)
Colors.castBars.args.invertCastbar = ACH:Toggle(L["Invert Colors"], L["Invert foreground and background colors."], 2, nil, nil, nil, nil, nil, function() return E.db.unitframe.colors.transparentCastbar end)
Colors.castBars.args.castClassColor = ACH:Toggle(L["Class Castbars"], L["Color castbars by the class of player units."], 3)
Colors.castBars.args.castReactionColor = ACH:Toggle(L["Reaction Castbars"], L["Color castbars by the reaction type of non-player units."], 4)
Colors.castBars.args.spacer1 = ACH:Spacer(5, 'full')
Colors.castBars.args.customcastbarbackdrop = ACH:Toggle(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 6)
Colors.castBars.args.castbar_backdrop = ACH:Color(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 7, true, nil, nil, nil, function() return not E.db.unitframe.colors.customcastbarbackdrop end)
Colors.castBars.args.spacer2 = ACH:Spacer(8, 'full')
Colors.castBars.args.castColor = ACH:Color(function() return (E.Retail or E.Wrath) and L["Interruptible"] or L["COLOR"] end, nil, 9)
Colors.castBars.args.castNoInterrupt = ACH:Color(L["Non-Interruptible"], nil, 10, nil, nil, nil, nil, nil, not (E.Retail or E.Wrath))
Colors.castBars.args.castInterruptedColor = ACH:Color(L["Interrupted"], nil, 11, nil, nil, nil, nil, nil, not (E.Retail or E.Wrath))

Colors.auras = ACH:Group(L["Auras"], nil, nil)
Colors.auras.args.auraByDispels = ACH:Toggle(L["Borders By Dispel"], nil, 1)
Colors.auras.args.auraByType = ACH:Toggle(L["Borders By Type"], nil, 2)

Colors.auraBars = ACH:Group(L["Aura Bars"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.unitframe.colors[info[#info]], P.unitframe.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return E.db.unitframe.colors[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... if E:CheckClassColor(r, g, b) then local classColor = E:ClassColor(E.myclass, true) r, g, b = classColor.r, classColor.g, classColor.b end local t = E.db.unitframe.colors[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a else local value = ... E.db.unitframe.colors[info[#info]] = value end UF:Update_AllFrames() end)
Colors.auraBars.args.transparentAurabars = ACH:Toggle(L["Transparent"], L["Make textures transparent."], 1)
Colors.auraBars.args.invertAurabars = ACH:Toggle(L["Invert Colors"], L["Invert foreground and background colors."], 2, nil, nil, nil, nil, nil, function() return not E.db.unitframe.colors.transparentAurabars end)
Colors.auraBars.args.auraBarByType = ACH:Toggle(L["By Type"], L["Color aurabar debuffs by type."], 3)
Colors.auraBars.args.auraBarTurtle = ACH:Toggle(L["Color Turtle Buffs"], L["Color all buffs that reduce the unit's incoming damage."], 4)
Colors.auraBars.args.spacer1 = ACH:Spacer(5, 'full')
Colors.auraBars.args.customaurabarbackdrop = ACH:Toggle(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 6)
Colors.auraBars.args.aurabar_backdrop = ACH:Color(L["Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 7, nil, nil, nil, nil, nil, function() return not E.db.unitframe.colors.customaurabarbackdrop end)
Colors.auraBars.args.spacer2 = ACH:Spacer(8, 'full')
Colors.auraBars.args.auraBarBuff = ACH:Color(L["Buffs"], nil, 10)
Colors.auraBars.args.auraBarDebuff = ACH:Color(L["Debuffs"], nil, 11)
Colors.auraBars.args.auraBarTurtleColor = ACH:Color(L["Turtle Color"], nil, 12)

Colors.reactionGroup = ACH:Group(L["Reactions"], nil, nil, nil, function(info) local t, d = E.db.unitframe.colors.reaction[info[#info]], P.unitframe.colors.reaction[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.reaction[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end)
Colors.reactionGroup.args.BAD = ACH:Color(L["Bad"], nil, 1)
Colors.reactionGroup.args.NEUTRAL = ACH:Color(L["Neutral"], nil, 2)
Colors.reactionGroup.args.GOOD = ACH:Color(L["Good"], nil, 3)

Colors.happiness = ACH:Group(L["Pet Happiness"], nil, nil, nil, function(info) local n = tonumber(info[#info]) local t, d = E.db.unitframe.colors.happiness[n], P.unitframe.colors.happiness[n] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local n = tonumber(info[#info]) local t = E.db.unitframe.colors.happiness[n] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, nil, E.Retail)
Colors.happiness.args['1'] = ACH:Color(L["Unhappy"], nil, 1)
Colors.happiness.args['2'] = ACH:Color(L["Content"], nil, 2)
Colors.happiness.args['3'] = ACH:Color(L["Happy"], nil, 3)

Colors.selectionGroup = ACH:Group(L["Selection"], nil, nil, nil, function(info) local n = tonumber(info[#info]) local t, d = E.db.unitframe.colors.selection[n], P.unitframe.colors.selection[n] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local n = tonumber(info[#info]) local t = E.db.unitframe.colors.selection[n] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, nil, not E.Retail)
Colors.selectionGroup.args['0'] = ACH:Color(L["Hostile"], nil, 1)
Colors.selectionGroup.args['1'] = ACH:Color(L["Unfriendly"], nil, 2)
Colors.selectionGroup.args['2'] = ACH:Color(L["Neutral"], nil, 3)
Colors.selectionGroup.args['3'] = ACH:Color(L["Friendly"], nil, 4)
Colors.selectionGroup.args['5'] = ACH:Color(L["Player"], nil, 5) -- Player Extended
Colors.selectionGroup.args['6'] = ACH:Color(L["Party"], nil, 6)
Colors.selectionGroup.args['7'] = ACH:Color(L["Party PVP"], nil, 7)
Colors.selectionGroup.args['8'] = ACH:Color(L["Friend"], nil, 8)
Colors.selectionGroup.args['9'] = ACH:Color(L["Dead"], nil, 9)
Colors.selectionGroup.args['13'] = ACH:Color(L["Battleground Friendly"], nil, 13)

Colors.healPrediction = ACH:Group(L["Heal Prediction"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.unitframe.colors.healPrediction[info[#info]], P.unitframe.colors.healPrediction[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return E.db.unitframe.colors.healPrediction[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.unitframe.colors.healPrediction[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a else local value = ... E.db.unitframe.colors.healPrediction[info[#info]] = value end UF:Update_AllFrames() end)
Colors.healPrediction.args.maxOverflow = ACH:Range(L["Max Overflow"], L["Max amount of overflow allowed to extend past the end of the health bar."], 1, { min = 0, max = 1, step = 0.01, isPercent = true })
Colors.healPrediction.args.spacer1 = ACH:Spacer(2, 'full')
Colors.healPrediction.args.personal = ACH:Color(L["Personal"], nil, 3, true)
Colors.healPrediction.args.others = ACH:Color(L["Others"], nil, 4, true)
Colors.healPrediction.args.absorbs = ACH:Color(L["Absorbs"], nil, 5, true, nil, nil, nil, nil, not E.Retail)
Colors.healPrediction.args.healAbsorbs = ACH:Color(L["Heal Absorbs"], nil, 6, true, nil, nil, nil, nil, not E.Retail)
Colors.healPrediction.args.overabsorbs = ACH:Color(L["Over Absorbs"], nil, 7, true, nil, nil, nil, nil, not E.Retail)
Colors.healPrediction.args.overhealabsorbs = ACH:Color(L["Over Heal Absorbs"], nil, 8, true, nil, nil, nil, nil, not E.Retail)

Colors.powerPrediction = ACH:Group(L["Power Prediction"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.unitframe.colors.powerPrediction[info[#info]], P.unitframe.colors.powerPrediction[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return E.db.unitframe.colors.powerPrediction[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.unitframe.colors.powerPrediction[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a else local value = ... E.db.unitframe.colors.powerPrediction[info[#info]] = value end UF:Update_AllFrames() end)
Colors.powerPrediction.args.enable = ACH:Toggle(L["Custom Power Prediction Color"], nil, 1, nil, nil, 250)
Colors.powerPrediction.args.spacer2 = ACH:Spacer(2)
Colors.powerPrediction.args.color = ACH:Color(L["Power Prediction Color"], nil, 3, true)
Colors.powerPrediction.args.additional = ACH:Color(L["Additional Power Prediction Color"], nil, 4, true)

Colors.debuffHighlight = ACH:Group(L["Aura Highlight"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.unitframe.colors.debuffHighlight[info[#info]], P.unitframe.colors.debuffHighlight[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return E.db.unitframe.colors.debuffHighlight[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.unitframe.colors.debuffHighlight[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a else local value = ... E.db.unitframe.colors.debuffHighlight[info[#info]] = value end UF:Update_AllFrames() end)
Colors.debuffHighlight.args.debuffHighlighting = ACH:Select(L["Highlight Color Style"], L["Color the unit healthbar if there is a debuff that can be dispelled by you."], 1, { NONE = L["None"], GLOW = L["Glow"], FILL = L["Fill"] }, nil, nil, function(info) return E.db.unitframe[info[#info]] end, function(info, value) E.db.unitframe[info[#info]] = value end)
Colors.debuffHighlight.args.blendMode = ACH:Select(L["Blend Mode"], nil, 2, blendModeValues)
Colors.debuffHighlight.args.spacer1 = ACH:Spacer(3, 'full')
Colors.debuffHighlight.args.Magic = ACH:Color(L["ENCOUNTER_JOURNAL_SECTION_FLAG7"], nil, 4, true)
Colors.debuffHighlight.args.Curse = ACH:Color(L["ENCOUNTER_JOURNAL_SECTION_FLAG8"], nil, 5, true)
Colors.debuffHighlight.args.Disease = ACH:Color(L["ENCOUNTER_JOURNAL_SECTION_FLAG10"], nil, 6, true)
Colors.debuffHighlight.args.Poison = ACH:Color(L["ENCOUNTER_JOURNAL_SECTION_FLAG9"], nil, 7, true)

Colors.threatGroup = ACH:Group(L["Threat"], nil, nil, nil, function(info) local n = tonumber(info[#info]) local t, d = E.db.unitframe.colors.threat[n], P.unitframe.colors.threat[n] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b) local n = tonumber(info[#info]) local t = E.db.unitframe.colors.threat[n] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end)
Colors.threatGroup.args['0'] = ACH:Color(L["Low Threat"], nil, 1)
Colors.threatGroup.args['1'] = ACH:Color(L["Gaining Threat"], nil, 2)
Colors.threatGroup.args['2'] = ACH:Color(L["Losing Threat"], nil, 3)
Colors.threatGroup.args['3'] = ACH:Color(L["Securely Tanking"], nil, 4)

Colors.classResourceGroup = ACH:Group(L["Class Resources"], nil, nil, nil, function(info) local t, d = E.db.unitframe.colors.classResources[info[#info]], P.unitframe.colors.classResources[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.classResources[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end)
-- Colors.classResourceGroup.args.transparentClasspower = ACH:Toggle(L["Transparent"], L["Make textures transparent."], 1, nil, nil, nil, function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end)
-- Colors.classResourceGroup.args.invertClasspower = ACH:Toggle(L["Invert Colors"], L["Invert foreground and background colors."], 2, nil, nil, nil, function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end, function() return not E.db.unitframe.colors.transparentClasspower end)

Colors.classResourceGroup.args.powerGroup = ACH:Group(L["Power"], nil, 0, nil, function(info) local t, d = E.db.unitframe.colors.power[info[#info]], P.unitframe.colors.power[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.power[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end)
Colors.classResourceGroup.args.powerGroup.inline = true
Colors.classResourceGroup.args.powerGroup.args.MANA = ACH:Color(L["MANA"], nil, 1)
Colors.classResourceGroup.args.powerGroup.args.RAGE = ACH:Color(L["RAGE"], nil, 2)
Colors.classResourceGroup.args.powerGroup.args.FOCUS = ACH:Color(L["FOCUS"], nil, 3)
Colors.classResourceGroup.args.powerGroup.args.ENERGY = ACH:Color(L["ENERGY"], nil, 4)
Colors.classResourceGroup.args.powerGroup.args.RUNIC_POWER = ACH:Color(L["RUNIC_POWER"], nil, 5)
Colors.classResourceGroup.args.powerGroup.args.PAIN = ACH:Color(L["PAIN"], nil, 6, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.powerGroup.args.FURY = ACH:Color(L["FURY"], nil, 7, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.powerGroup.args.LUNAR_POWER = ACH:Color(L["LUNAR_POWER"], nil, 8, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.powerGroup.args.INSANITY = ACH:Color(L["INSANITY"], nil, 9, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.powerGroup.args.MAELSTROM = ACH:Color(L["MAELSTROM"], nil, 10, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.powerGroup.args.ALT_POWER = ACH:Color(L["Swapped Alt Power"], nil, 11)

do
	local classPowers = { PALADIN = true, WARLOCK = true, MAGE = true }
	Colors.classResourceGroup.args.class = ACH:Group(L["Class Resources"], nil, 1, nil, nil, nil, nil, not E.Retail or not classPowers[E.myclass])
end

Colors.classResourceGroup.args.class.inline = true
Colors.classResourceGroup.args.class.args.PALADIN = ACH:Color(L["HOLY_POWER"], nil, 1, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.class.args.MAGE = ACH:Color(L["POWER_TYPE_ARCANE_CHARGES"], nil, 2, nil, nil, nil, nil, nil, not E.Retail)
Colors.classResourceGroup.args.class.args.WARLOCK = ACH:Color(L["SOUL_SHARDS"], nil, 3, nil, nil, nil, nil, nil, not E.Retail)

Colors.classResourceGroup.args.COMBO_POINTS = ACH:Group(L["COMBO_POINTS"], nil, 2, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.unitframe.colors.classResources.comboPoints[i], P.unitframe.colors.classResources.comboPoints[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.classResources.comboPoints[tonumber(info[#info])] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end)
Colors.classResourceGroup.args.COMBO_POINTS.args.chargedComboPoint = ACH:Color(L["Charged Combo Point"], nil, 20, nil, nil, function(info) local t, d = E.db.unitframe.colors.classResources[info[#info]], P.unitframe.colors.classResources[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.classResources[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, nil, not E.Retail)
Colors.classResourceGroup.args.COMBO_POINTS.inline = true

Colors.classResourceGroup.args.CHI_POWER = ACH:Group(L["CHI_POWER"], nil, 3, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.unitframe.colors.classResources.MONK[i], P.unitframe.colors.classResources.MONK[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.classResources.MONK[tonumber(info[#info])] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, nil, not E.Retail)
Colors.classResourceGroup.args.CHI_POWER.inline = true

for i = 1, 7 do
	if i ~= 7 then
		Colors.classResourceGroup.args.CHI_POWER.args[''..i] = ACH:Color(L["CHI_POWER"]..' #'..i)
	end

	Colors.classResourceGroup.args.COMBO_POINTS.args[''..i] = ACH:Color(L["COMBO_POINTS"]..' #'..i)
end

Colors.classResourceGroup.args.RUNES = ACH:Group(L["RUNES"], nil, 4, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.unitframe.colors.classResources.DEATHKNIGHT[i], P.unitframe.colors.classResources.DEATHKNIGHT[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[tonumber(info[#info])] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, nil, not (E.Retail or E.Wrath))
Colors.classResourceGroup.args.RUNES.inline = true

do
	local runeText = { [-1] = L["RUNE_CHARGE"], [0] = L["RUNES"], L["RUNE_BLOOD"], L["RUNE_FROST"], L["RUNE_UNHOLY"], L["RUNE_DEATH"] }
	for i = -1, 4 do
		Colors.classResourceGroup.args.RUNES.args[''..i] = ACH:Color(runeText[i], nil, i == -1 and 10 or i, nil, nil, nil, nil, function() return i == -1 and not E.db.unitframe.colors.chargingRunes end, function() return (E.Wrath and i < 1) or (not E.Wrath and i == 4) or (E.Retail and E.db.unitframe.colors.runeBySpec and i == 0) or (E.Retail and not E.db.unitframe.colors.runeBySpec and i > 0) end)
	end
end

Colors.classResourceGroup.args.RUNES.args.runeBySpec = ACH:Toggle(L["Color By Spec"], nil, 11, nil, nil, nil, function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end, nil, not E.Retail)
Colors.classResourceGroup.args.RUNES.args.chargingRunes = ACH:Toggle(E.Retail and L["Charging Rune Color"] or L["Faded Charging Rune"], nil, 11, nil, nil, nil, function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end)

Colors.classResourceGroup.args.TOTEMS = ACH:Group(L["Totems"], nil, 4, nil, function(info) local i = tonumber(info[#info]); local t, d = E.db.unitframe.colors.classResources.SHAMAN[i], P.unitframe.colors.classResources.SHAMAN[i] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors.classResources.SHAMAN[tonumber(info[#info])] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, nil, E.Retail)
Colors.classResourceGroup.args.TOTEMS.inline = true

do
	local totemText = { L["TOTEM_EARTH"], L["TOTEM_FIRE"], L["TOTEM_WATER"], L["TOTEM_AIR"] }
	for i = 1, 4 do
		Colors.classResourceGroup.args.TOTEMS.args[''..i] = ACH:Color(totemText[i], nil, i)
	end
end

Colors.classResourceGroup.args.classpower_backdrop = ACH:Color(L["Custom Backdrop"], nil, 30, nil, nil, function(info) local t, d = E.db.unitframe.colors[info[#info]], P.unitframe.colors[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.unitframe.colors[info[#info]] t.r, t.g, t.b = r, g, b UF:Update_AllFrames() end, function() return not E.db.unitframe.colors.customclasspowerbackdrop end)
Colors.classResourceGroup.args.customclasspowerbackdrop = ACH:Toggle(L["Use Custom Backdrop"], L["Use the custom backdrop color instead of a multiple of the main color."], 31, nil, nil, nil, function(info) return E.db.unitframe.colors[info[#info]] end, function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end)

UnitFrame.frameGlowGroup = ACH:Group(L["Frame Glow"], nil, 25, 'tree', nil, nil, function() return not E.UnitFrames.Initialized end)
UnitFrame.frameGlowGroup.args.mainGlow = ACH:Group(L["Mouseover Glow"], nil, 1, nil, function(info) local t = E.db.unitframe.colors.frameGlow.mainGlow[info[#info]] if info.type == 'color' then local d = P.unitframe.colors.frameGlow.mainGlow[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return t end end, function(info, ...) if info.type == 'color' then local t = E.db.unitframe.colors.frameGlow.mainGlow[info[#info]] t.r, t.g, t.b, t.a = ... else E.db.unitframe.colors.frameGlow.mainGlow[info[#info]] = ... end UF:FrameGlow_UpdateFrames() end, function() return not E.db.unitframe.colors.frameGlow.mainGlow.enable end)
UnitFrame.frameGlowGroup.args.mainGlow.inline = true
UnitFrame.frameGlowGroup.args.mainGlow.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
UnitFrame.frameGlowGroup.args.mainGlow.args.spacer = ACH:Spacer(2)
UnitFrame.frameGlowGroup.args.mainGlow.args.class = ACH:Toggle(L["Use Class Color"], L["Alpha channel is taken from the color option."], 3)
UnitFrame.frameGlowGroup.args.mainGlow.args.color = ACH:Color(L["COLOR"], nil, 4, true)

UnitFrame.frameGlowGroup.args.targetGlow = ACH:Group(L["Targeted Glow"], nil, 2, nil, function(info) local t = E.db.unitframe.colors.frameGlow.targetGlow[info[#info]] if info.type == 'color' then local d = P.unitframe.colors.frameGlow.targetGlow[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return t end end, function(info, ...) if info.type == 'color' then local t = E.db.unitframe.colors.frameGlow.targetGlow[info[#info]] t.r, t.g, t.b, t.a = ... else E.db.unitframe.colors.frameGlow.targetGlow[info[#info]] = ... end UF:FrameGlow_UpdateFrames() end, function() return not E.db.unitframe.colors.frameGlow.targetGlow.enable end)
UnitFrame.frameGlowGroup.args.targetGlow.inline = true
UnitFrame.frameGlowGroup.args.targetGlow.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
UnitFrame.frameGlowGroup.args.targetGlow.args.spacer = ACH:Spacer(2)
UnitFrame.frameGlowGroup.args.targetGlow.args.class = ACH:Toggle(L["Use Class Color"], L["Alpha channel is taken from the color option."], 3)
UnitFrame.frameGlowGroup.args.targetGlow.args.color = ACH:Color(L["COLOR"], nil, 4, true)

UnitFrame.frameGlowGroup.args.focusGlow = ACH:Group(L["Focused Glow"], nil, 2, nil, function(info) local t = E.db.unitframe.colors.frameGlow.focusGlow[info[#info]] if info.type == 'color' then local d = P.unitframe.colors.frameGlow.focusGlow[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return t end end, function(info, ...) if info.type == 'color' then local t = E.db.unitframe.colors.frameGlow.focusGlow[info[#info]] t.r, t.g, t.b, t.a = ... else E.db.unitframe.colors.frameGlow.focusGlow[info[#info]] = ... end UF:FrameGlow_UpdateFrames() end, function() return not E.db.unitframe.colors.frameGlow.focusGlow.enable end, E.Classic)
UnitFrame.frameGlowGroup.args.focusGlow.inline = true
UnitFrame.frameGlowGroup.args.focusGlow.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
UnitFrame.frameGlowGroup.args.focusGlow.args.spacer = ACH:Spacer(2)
UnitFrame.frameGlowGroup.args.focusGlow.args.class = ACH:Toggle(L["Use Class Color"], L["Alpha channel is taken from the color option."], 3)
UnitFrame.frameGlowGroup.args.focusGlow.args.color = ACH:Color(L["COLOR"], nil, 4, true)

UnitFrame.frameGlowGroup.args.mouseoverGlow = ACH:Group(L["Mouseover Highlight"], nil, 2, nil, function(info) local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] if info.type == 'color' then local d = P.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a else return t end end, function(info, ...) if info.type == 'color' then local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] t.r, t.g, t.b, t.a = ... else E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] = ... end UF:FrameGlow_UpdateFrames() end, function() return not E.db.unitframe.colors.frameGlow.mouseoverGlow.enable end)
UnitFrame.frameGlowGroup.args.mouseoverGlow.inline = true
UnitFrame.frameGlowGroup.args.mouseoverGlow.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, nil, false)
UnitFrame.frameGlowGroup.args.mouseoverGlow.args.texture = ACH:SharedMediaStatusbar(L["Texture"], nil, 2)
UnitFrame.frameGlowGroup.args.mouseoverGlow.args.spacer = ACH:Spacer(3)
UnitFrame.frameGlowGroup.args.mouseoverGlow.args.class = ACH:Toggle(L["Use Class Color"], L["Alpha channel is taken from the color option."], 4)
UnitFrame.frameGlowGroup.args.mouseoverGlow.args.color = ACH:Color(L["COLOR"], nil, 5, true)

UnitFrame.individualUnits = ACH:Group(L["Individual Units"], nil, 15, 'tab', nil, nil, function() return not E.UnitFrames.Initialized end)
local IndividualUnits = UnitFrame.individualUnits.args

local SingleCopyFrom = {}
for unit in pairs(UF.units) do
	SingleCopyFrom[unit] = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
end

local function CopyFromSingle(info)
	local tbl = {}

	for name, locale in pairs(SingleCopyFrom) do
		if name ~= info[#info - 1] then
			tbl[name] = locale
		end
	end

	return tbl
end

IndividualUnits.player = ACH:Group(L["Player"], nil, 1, nil, function(info) return E.db.unitframe.units.player[info[#info]] end, function(info, value) E.db.unitframe.units.player[info[#info]] = value UF:CreateAndUpdateUF('player') end)
local Player = IndividualUnits.player.args

Player.enable = ACH:Toggle(L["Enable"], nil, 1)
Player.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.player.forceShowAuras = not UF.player.forceShowAuras UF:CreateAndUpdateUF('player') end)
Player.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Player"], nil, { unit = 'player', mover = 'Player Frame' }) end)
Player.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'player') E:RefreshGUI() end)

Player.aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'player')
Player.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'player')
Player.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateUF, 'player')
Player.classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateUF, 'player')
Player.CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, 'player')
Player.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'player')
Player.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'player')
Player.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'player')
Player.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'player')
Player.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'player')
Player.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'player')
Player.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'player')
Player.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'player')
Player.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'player')
Player.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'player')
Player.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'player', nil, true)
Player.pvpIcon = GetOptionsTable_PVPIcon(UF.CreateAndUpdateUF, 'player')
Player.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'player')
Player.raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateUF, 'player')
Player.resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateUF, 'player')
Player.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'player')

Player.RestIcon = ACH:Group(L["Rest Icon"], nil, nil, nil, function(info) return E.db.unitframe.units.player.RestIcon[info[#info]] end, function(info, value) E.db.unitframe.units.player.RestIcon[info[#info]] = value UF:CreateAndUpdateUF('player') UF:TestingDisplay_RestingIndicator(UF.player) end)
Player.RestIcon.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Player.RestIcon.args.hideAtMaxLevel = ACH:Toggle(L["Hide At Max Level"], nil, 2)
Player.RestIcon.args.size = ACH:Range(L["Size"], nil, 3, { min = 12, max = 64, step = 1 })
Player.RestIcon.args.anchorPoint = ACH:Select(L["Position"], nil, 4, C.Values.AllPoints)
Player.RestIcon.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -100, max = 100, step = 1 })
Player.RestIcon.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -100, max = 100, step = 1 })
Player.RestIcon.args.defaultColor = ACH:Toggle(L["Default Color"], nil, 7)
Player.RestIcon.args.color = ACH:Color(L["COLOR"], nil, 8, true, nil, function() local c, d = E.db.unitframe.units.player.RestIcon.color, P.unitframe.units.player.RestIcon.color return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local c = E.db.unitframe.units.player.RestIcon.color c.r, c.g, c.b, c.a = r, g, b, a UF:CreateAndUpdateUF('player') UF:TestingDisplay_RestingIndicator(UF.player) end, nil, function() return E.db.unitframe.units.player.RestIcon.defaultColor end)
Player.RestIcon.args.texture = ACH:Select(L["Texture"], nil, 9, { CUSTOM = L["CUSTOM"], DEFAULT = L["DEFAULT"] })
Player.RestIcon.args.texture.sortByValue = true
Player.RestIcon.args.customTexture = ACH:Input(L["Custom Texture"], nil, 10, nil, 250, nil, function(_, value) E.db.unitframe.units.player.RestIcon.customTexture = (value and (not value:match('^%s-$')) and value) or nil UF:CreateAndUpdateUF('player') UF:TestingDisplay_RestingIndicator(UF.player) end)

for key, icon in pairs(E.Media.RestIcons) do
	Player.RestIcon.args.texture.values[key] = E:TextureString(icon, ':14:14')
end

Player.PartyIndicator = ACH:Group(L["Party Indicator"], nil, nil, nil, function(info) return E.db.unitframe.units.player.partyIndicator[info[#info]] end, function(info, value) E.db.unitframe.units.player.partyIndicator[info[#info]] = value UF:CreateAndUpdateUF('player') end)
Player.PartyIndicator.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Player.PartyIndicator.args.scale = ACH:Range(L["Scale"], nil, 2, { min = .5, max = 2, step = .01, isPercent = true })
Player.PartyIndicator.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
Player.PartyIndicator.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
Player.PartyIndicator.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })

Player.pvpText = ACH:Group(L["PvP Text"], nil, nil, nil, function(info) return E.db.unitframe.units.player.pvp[info[#info]] end, function(info, value) E.db.unitframe.units.player.pvp[info[#info]] = value UF:CreateAndUpdateUF('player') end)
Player.pvpText.args.position = ACH:Select(L["Position"], nil, 1, C.Values.AllPoints)
Player.pvpText.args.text_format = ACH:Input(L["Text Format"], L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 100, nil, 'full')

IndividualUnits.pet = ACH:Group(L["Pet"], nil, 2, nil, function(info) return E.db.unitframe.units.pet[info[#info]] end, function(info, value) E.db.unitframe.units.pet[info[#info]] = value UF:CreateAndUpdateUF('pet') end)
local Pet = IndividualUnits.pet.args

Pet.enable = ACH:Toggle(L["Enable"], nil, 1)
Pet.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.pet.forceShowAuras = not UF.pet.forceShowAuras UF:CreateAndUpdateUF('pet') end)
Pet.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Pet Frame"], nil, { unit = 'pet', mover = 'Pet Frame' }) end)
Pet.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'pet') E:RefreshGUI() end)

Pet.aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'pet')
Pet.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUF, 'pet')
Pet.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'pet')
Pet.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateUF, 'pet')
Pet.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pet')
Pet.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'pet')
Pet.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'pet')
Pet.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'pet')
Pet.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'pet')
Pet.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'pet')
Pet.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pet')
Pet.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'pet')
Pet.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pet')
Pet.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'pet')
Pet.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'pet')
Pet.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'pet')
Pet.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'pet')

IndividualUnits.target = ACH:Group(L["Target"], nil, 3, nil, function(info) return E.db.unitframe.units.target[info[#info]] end, function(info, value) E.db.unitframe.units.target[info[#info]] = value UF:CreateAndUpdateUF('target') end)
local Target = IndividualUnits.target.args

Target.enable = ACH:Toggle(L["Enable"], nil, 1)
Target.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.target.forceShowAuras = not UF.target.forceShowAuras UF:CreateAndUpdateUF('target') end)
Target.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Target Frame"], nil, { unit = 'target', mover = 'Target Frame' }) end)
Target.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'target') E:RefreshGUI() end)

Target.aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'target')
Target.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'target')
Target.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateUF, 'target')
Target.CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, 'target')
Target.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'target')
Target.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'target')
Target.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'target')
Target.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'target')
Target.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'target')
Target.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'target')
Target.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'target')
Target.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'target')
Target.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'target')
Target.phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateUF, 'target')
Target.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'target')
Target.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'target', nil, true)
Target.pvpIcon = GetOptionsTable_PVPIcon(UF.CreateAndUpdateUF, 'target')
Target.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'target')
Target.raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateUF, 'target')
Target.resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateUF, 'target')
Target.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'target')

IndividualUnits.targettarget = ACH:Group(L["TargetTarget"], nil, 4, nil, function(info) return E.db.unitframe.units.targettarget[info[#info]] end, function(info, value) E.db.unitframe.units.targettarget[info[#info]] = value UF:CreateAndUpdateUF('targettarget') end)
local TargetTarget = IndividualUnits.targettarget.args

TargetTarget.enable = ACH:Toggle(L["Enable"], nil, 1)
TargetTarget.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.targettarget.forceShowAuras = not UF.targettarget.forceShowAuras UF:CreateAndUpdateUF('targettarget') end)
TargetTarget.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["TargetTarget Frame"], nil, { unit = 'targettarget', mover = 'TargetTarget Frame' }) end)
TargetTarget.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'targettarget') E:RefreshGUI() end)

TargetTarget.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettarget')
TargetTarget.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'targettarget')

IndividualUnits.targettargettarget = ACH:Group(L["TargetTargetTarget"], nil, 5, nil, function(info) return E.db.unitframe.units.targettargettarget[info[#info]] end, function(info, value) E.db.unitframe.units.targettargettarget[info[#info]] = value UF:CreateAndUpdateUF('targettargettarget') end)
local TargetTargetTarget = IndividualUnits.targettargettarget.args

TargetTargetTarget.enable = ACH:Toggle(L["Enable"], nil, 1)
TargetTargetTarget.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.targettargettarget.forceShowAuras = not UF.targettargettarget.forceShowAuras UF:CreateAndUpdateUF('targettargettarget') end)
TargetTargetTarget.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["TargetTargetTarget Frame"], nil, { unit = 'targettargettarget', mover = 'TargetTargetTarget Frame' }) end)
TargetTargetTarget.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'targettargettarget') E:RefreshGUI() end)

TargetTargetTarget.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettargettarget')
TargetTargetTarget.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'targettargettarget')

IndividualUnits.focus = ACH:Group(L["Focus"], nil, 6, nil, function(info) return E.db.unitframe.units.focus[info[#info]] end, function(info, value) E.db.unitframe.units.focus[info[#info]] = value UF:CreateAndUpdateUF('focus') end, nil, function() return E.Classic end)
local Focus = IndividualUnits.focus.args

Focus.enable = ACH:Toggle(L["Enable"], nil, 1)
Focus.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.focus.forceShowAuras = not UF.focus.forceShowAuras UF:CreateAndUpdateUF('focus') end)
Focus.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Focus Frame"], nil, { unit = 'focus', mover = 'Focus Frame' }) end)
Focus.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'focus') E:RefreshGUI() end)
Focus.aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'focus')
Focus.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUF, 'focus')
Focus.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'focus')
Focus.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateUF, 'focus')
Focus.CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, 'focus')
Focus.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focus')
Focus.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'focus')
Focus.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'focus')
Focus.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'focus')
Focus.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'focus')
Focus.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'focus')
Focus.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focus')
Focus.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'focus')
Focus.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focus')
Focus.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'focus')
Focus.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'focus')
Focus.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focus')
Focus.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'focus')

IndividualUnits.focustarget = ACH:Group(L["FocusTarget"], nil, 8, nil, function(info) return E.db.unitframe.units.focustarget[info[#info]] end, function(info, value) E.db.unitframe.units.focustarget[info[#info]] = value UF:CreateAndUpdateUF('focustarget') end, nil, E.Classic)
local FocusTarget = IndividualUnits.focustarget.args

FocusTarget.enable = ACH:Toggle(L["Enable"], nil, 1)
FocusTarget.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.focustarget.forceShowAuras = not UF.focustarget.forceShowAuras UF:CreateAndUpdateUF('focustarget') end)
FocusTarget.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["FocusTarget Frame"], nil, { unit = 'focustarget', mover = 'FocusTarget Frame' }) end)
FocusTarget.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'focustarget') E:RefreshGUI() end)
FocusTarget.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focustarget')
FocusTarget.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'focustarget')

IndividualUnits.pettarget = ACH:Group(L["PetTarget"], nil, 10, nil, function(info) return E.db.unitframe.units.pettarget[info[#info]] end, function(info, value) E.db.unitframe.units.pettarget[info[#info]] = value UF:CreateAndUpdateUF('pettarget') end)
local PetTarget = IndividualUnits.pettarget.args

PetTarget.enable = ACH:Toggle(L["Enable"], nil, 1)
PetTarget.showAuras = ACH:Execute(L["Show Auras"], nil, 2, function() UF.pettarget.forceShowAuras = not UF.pettarget.forceShowAuras UF:CreateAndUpdateUF('pettarget') end)
PetTarget.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["PetTarget Frame"], nil, { unit = 'pettarget', mover = 'PetTarget Frame' }) end)
PetTarget.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromSingle, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'pettarget') E:RefreshGUI() end)

PetTarget.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'pettarget')
PetTarget.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'pettarget')
PetTarget.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pettarget')
PetTarget.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'pettarget')
PetTarget.power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'pettarget')
PetTarget.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'pettarget')

UnitFrame.groupUnits = ACH:Group(L["Group Units"], nil, 16, 'tab', nil, nil, function() return not E.UnitFrames.Initialized end)
local GroupUnits = UnitFrame.groupUnits.args

GroupUnits.boss = ACH:Group(L["Boss"], nil, nil, nil, function(info) return E.db.unitframe.units.boss[info[#info]] end, function(info, value) E.db.unitframe.units.boss[info[#info]] = value UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end, nil, not (E.Retail or E.Wrath))
local Boss = GroupUnits.boss.args

Boss.enable = ACH:Toggle(L["Enable"], nil, 1)
Boss.displayFrames = ACH:Execute(L["Display Frames"], L["Force the frames to show, they will act as if they are the player frame."], 2, function() UF:ToggleForceShowGroupFrames('boss', MAX_BOSS_FRAMES) end)
Boss.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Boss Frames"], nil, {unit='boss', mover='Boss Frames'}) end)
Boss.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, { arena = L["Arena"] }, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'boss') E:RefreshGUI() end)

Boss.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)
Boss.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES)

GroupUnits.arena = ACH:Group(L["Arena"], nil, nil, nil, function(info) return E.db.unitframe.units.arena[info[#info]] end, function(info, value) E.db.unitframe.units.arena[info[#info]] = value UF:CreateAndUpdateUFGroup('arena', 5) end, nil, E.Classic)
local Arena = GroupUnits.arena.args

Arena.enable = ACH:Toggle(L["Enable"], nil, 1)
Arena.displayFrames = ACH:Execute(L["Display Frames"], L["Force the frames to show, they will act as if they are the player frame."], 2, function() UF:ToggleForceShowGroupFrames('arena', 5) end)
Arena.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Arena Frames"], nil, { unit = 'arena', mover = 'Arena Frames' }) end)
Arena.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, { boss = L["Boss"] }, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'arena') E:RefreshGUI() end, nil, not E.Retail)

Arena.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.fader = GetOptionsTable_Fader(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, 'arena', 5)
Arena.pvpclassificationindicator = GetOptionsTable_PVPClassificationIndicator(UF.CreateAndUpdateUFGroup, 'arena', 5)

Arena.pvpTrinket = ACH:Group(L["PVP Trinket"], nil, nil, nil, function(info) return E.db.unitframe.units.arena.pvpTrinket[info[#info]] end, function(info, value) E.db.unitframe.units.arena.pvpTrinket[info[#info]] = value UF:CreateAndUpdateUFGroup('arena', 5) end)
Arena.pvpTrinket.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Arena.pvpTrinket.args.size = ACH:Range(L["Size"], nil, 2, { min = 12, max = 64, step = 1 })
Arena.pvpTrinket.args.anchorPoint = ACH:Select(L["Position"], nil, 3, C.Values.AllPoints)
Arena.pvpTrinket.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -100, max = 100, step = 1 })
Arena.pvpTrinket.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -100, max = 100, step = 1 })

--Party Frames
GroupUnits.party = ACH:Group(L["Party"], nil, nil, nil, function(info) return E.db.unitframe.units.party[info[#info]] end, function(info, value) E.db.unitframe.units.party[info[#info]] = value UF:CreateAndUpdateHeaderGroup('party') end)
local Party = GroupUnits.party.args

local HeaderCopyFrom = { party = L["Party Frames"], raidpet = L["Raid Pet"] }
for i = 1, 3 do
	HeaderCopyFrom['raid'..i] = L[format("Raid %s Frames", i)]
end

local function CopyFromHeader(info)
	local tbl = {}

	for name, locale in pairs(HeaderCopyFrom) do
		if name ~= info[#info - 1] then
			tbl[name] = locale
		end
	end

	return tbl
end

Party.enable = ACH:Toggle(L["Enable"], nil, 1)
Party.configureToggle = ACH:Execute(L["Display Frames"], nil, 2, function() UF:HeaderConfig(UF.party, UF.party.forceShow ~= true or nil) end)
Party.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Party Frames"], nil, { unit = 'party', mover = 'Party Frames' }) end)
Party.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromHeader, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'party') E:RefreshGUI() end)

Party.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'party')
Party.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'party')
Party.castbar = GetOptionsTable_Castbar(UF.CreateAndUpdateHeaderGroup, 'party')
Party.classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, 'party')
Party.CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateHeaderGroup, 'party')
Party.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'party')
Party.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'party')
Party.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'party')
Party.fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'party')
Party.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'party')
Party.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'party')
Party.health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'party')
Party.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'party')
Party.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party')
Party.phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, 'party')
Party.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'party')
Party.power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'party')
Party.pvpclassificationindicator = GetOptionsTable_PVPClassificationIndicator(UF.CreateAndUpdateHeaderGroup, 'party')
Party.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'party')
Party.raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, 'party')
Party.rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'party')
Party.readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'party')
Party.resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'party')
Party.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, 'party')
Party.summonIcon = GetOptionsTable_SummonIcon(UF.CreateAndUpdateHeaderGroup, 'party')

Party.petsGroup = ACH:Group(L["Pet Group"], nil, -2, nil, function(info) return E.db.unitframe.units.party.petsGroup[info[#info]] end, function(info, value) E.db.unitframe.units.party.petsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup('party') end)
Party.petsGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Party.petsGroup.args.colorPetByUnitClass = ACH:Toggle(L["Color by Unit Class"], nil, 2)
Party.petsGroup.args.width = ACH:Range(L["Width"], nil, 3, { min = 50, max = 1000, step = 1 })
Party.petsGroup.args.height = ACH:Range(L["Height"], nil, 4, { min = 5, max = 500, step = 1 })
Party.petsGroup.args.anchorPoint = ACH:Select(L["Position"], nil, 5, C.Values.AllPoints)
Party.petsGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -500, max = 500, step = 1 })
Party.petsGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -500, max = 500, step = 1 })
Party.petsGroup.args.threatStyle = ACH:Select(L["Threat Display Mode"], nil, 8, threatValues)
Party.petsGroup.args.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'petsGroup')
Party.petsGroup.args.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'petsGroup')
Party.petsGroup.args.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'petsGroup')

Party.targetsGroup = ACH:Group(L["Target Group"], nil, -1, nil, function(info) return E.db.unitframe.units.party.targetsGroup[info[#info]] end, function(info, value) E.db.unitframe.units.party.targetsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup('party') end)
Party.targetsGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
Party.targetsGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = 1000, step = 1 })
Party.targetsGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 5, max = 500, step = 1 })
Party.targetsGroup.args.anchorPoint = ACH:Select(L["Position"], nil, 4, C.Values.AllPoints)
Party.targetsGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -500, max = 500, step = 1 })
Party.targetsGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -500, max = 500, step = 1 })
Party.targetsGroup.args.threatStyle = ACH:Select(L["Threat Display Mode"], nil, 7, threatValues)
Party.targetsGroup.args.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'targetsGroup')
Party.targetsGroup.args.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'targetsGroup')

for i = 1, 3 do
	GroupUnits['raid'..i] = ACH:Group(function() local raid, name = L[format('Raid %s', i)], E.db.unitframe.units['raid'..i].customName return name and name ~= '' and format('%s%s - %s', E.NewSign, raid, name) or format('%s%s', E.NewSign, raid) end, nil, nil, nil, function(info) return E.db.unitframe.units['raid'..i][info[#info]] end, function(info, value) E.db.unitframe.units['raid'..i][info[#info]] = value UF:CreateAndUpdateHeaderGroup('raid'..i) end)

	local Raid = GroupUnits['raid'..i].args
	Raid.enable = ACH:Toggle(L["Enable"], nil, 1)
	Raid.configureToggle = ACH:Execute(L["Display Frames"], nil, 2, function() UF:HeaderConfig(UF['raid'..i], UF['raid'..i].forceShow ~= true or nil) end)
	Raid.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L[format("Raid %s Frames", i)], nil, {unit = format('raid%s', i), mover=format('Raid %s Frames', i)}) end)
	Raid.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromHeader, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'raid'..i) E:RefreshGUI() end)

	Raid.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.generalGroup.args.customName = ACH:Input(L["Custom Name"], nil, 0, nil, 'full')
	Raid.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.pvpclassificationindicator = GetOptionsTable_PVPClassificationIndicator(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
	Raid.summonIcon = GetOptionsTable_SummonIcon(UF.CreateAndUpdateHeaderGroup, 'raid'..i)
end

GroupUnits.raidpet = ACH:Group(L["Raid Pet"], nil, nil, nil, function(info) return E.db.unitframe.units.raidpet[info[#info]] end, function(info, value) E.db.unitframe.units.raidpet[info[#info]] = value UF:CreateAndUpdateHeaderGroup('raidpet') end)
local RaidPet = GroupUnits.raidpet.args

RaidPet.enable = ACH:Toggle(L["Enable"], nil, 1)
RaidPet.configureToggle = ACH:Execute(L["Display Frames"], nil, 2, function() UF:HeaderConfig(UF.raidpet, UF.raidpet.forceShow ~= true or nil) end)
RaidPet.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Raid Pet Frames"], nil, {unit = 'raidpet', mover='Raid Pet Frames'}) end)
RaidPet.copyFrom = ACH:Select(L["Copy From"], L["Select a unit to copy settings from."], 4, CopyFromHeader, true, nil, nil, function(_, value) UF:MergeUnitSettings(value, 'raidpet') E:RefreshGUI() end)

RaidPet.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raidpet')
RaidPet.rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raidpet')

for unit, locale in pairs({ tank = 'Tank', assist = 'Assist' }) do
	GroupUnits[unit] = ACH:Group(L[locale], nil, nil, nil, function(info) return E.db.unitframe.units[unit][info[#info]] end, function(info, value) E.db.unitframe.units[unit][info[#info]] = value UF:CreateAndUpdateHeaderGroup(unit) end)
	GroupUnits[unit].args.enable = ACH:Toggle(L["Enable"], nil, 1)

	GroupUnits[unit].args.buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.healPrediction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, unit)
	GroupUnits[unit].args.rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, unit)

	GroupUnits[unit].args.targetsGroup = ACH:Group(L["Target Group"], nil, -1, nil, function(info) return E.db.unitframe.units[unit].targetsGroup[info[#info]] end, function(info, value) E.db.unitframe.units[unit].targetsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup(unit) end)
	GroupUnits[unit].args.targetsGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	GroupUnits[unit].args.targetsGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = 1000, step = 1 })
	GroupUnits[unit].args.targetsGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 5, max = 500, step = 1 })
	GroupUnits[unit].args.targetsGroup.args.anchorPoint = ACH:Select(L["Position"], nil, 4, C.Values.AllPoints)
	GroupUnits[unit].args.targetsGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, { min = -500, max = 500, step = 1 })
	GroupUnits[unit].args.targetsGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, { min = -500, max = 500, step = 1 })
	GroupUnits[unit].args.targetsGroup.args.threatStyle = ACH:Select(L["Threat Display Mode"], nil, 7, threatValues)
	GroupUnits[unit].args.targetsGroup.args.name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, unit, nil, 'targetsGroup')
	GroupUnits[unit].args.targetsGroup.args.raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, unit, nil, 'targetsGroup')

	GroupUnits[unit].args.name.args.attachTextTo.values = { Health = L["Health"], Frame = L["Frame"] }
	GroupUnits[unit].args.targetsGroup.args.name.args.attachTextTo.values = { Health = L["Health"], Frame = L["Frame"] }
end

GroupUnits.tank.args.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Tank Frames"], nil, { unit = 'tank' }) end)
GroupUnits.assist.args.resetSettings = ACH:Execute(L["Restore Defaults"], nil, 3, function() E:StaticPopup_Show('RESET_UF_UNIT', L["Assist Frames"], nil, { unit = 'assist' }) end)

C:RefreshCustomTexts() -- Fire the current profile for custom texts
