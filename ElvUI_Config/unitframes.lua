local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')
local NP = E:GetModule("NamePlates")

local _G = _G
local type = type
local select = select
local pairs = pairs
local ipairs = ipairs
local format = string.format
local tremove = table.remove
local tconcat = table.concat
local tinsert = table.insert
local twipe = table.wipe
local strsplit = strsplit
local match = string.match
local gsub = string.gsub
local IsAddOnLoaded = IsAddOnLoaded
local GetScreenWidth = GetScreenWidth
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local BLOCK, FRIEND, ENEMY, SHOW, HIDE, DELETE, NONE, FILTERS, FONT_SIZE, COLOR = BLOCK, FRIEND, ENEMY, SHOW, HIDE, DELETE, NONE, FILTERS, FONT_SIZE, COLOR

-- GLOBALS: MAX_BOSS_FRAMES
-- GLOBALS: CUSTOM_CLASS_COLORS, AceGUIWidgetLSMlists
-- GLOBALS: ElvUF_Parent, ElvUF_Player, ElvUF_Pet, ElvUF_PetTarget, ElvUF_Party, ElvUF_Raidpet
-- GLOBALS: ElvUF_Target, ElvUF_TargetTarget, ElvUF_TargetTargetTarget, ElvUF_Focus, ElvUF_FocusTarget

-- The variables below aren't caught by mikk's Find Globals script
local CUSTOM, DISABLE, DEFAULT, COLORS = CUSTOM, DISABLE, DEFAULT, COLORS
local SHIFT_KEY, ALT_KEY, CTRL_KEY = SHIFT_KEY, ALT_KEY, CTRL_KEY
local HEALTH, MANA, NAME, PLAYER, CLASS, ROLE, GROUP = HEALTH, MANA, NAME, PLAYER, CLASS, ROLE, GROUP
local CHI_POWER, RAGE, FOCUS, ENERGY, PAIN, FURY, INSANITY, MAELSTROM, RUNIC_POWER, HOLY_POWER, LUNAR_POWER = CHI_POWER, RAGE, FOCUS, ENERGY, PAIN, FURY, INSANITY, MAELSTROM, RUNIC_POWER, HOLY_POWER, LUNAR_POWER
local POWER_TYPE_ARCANE_CHARGES, SOUL_SHARDS, RUNES = POWER_TYPE_ARCANE_CHARGES, SOUL_SHARDS, RUNES
------------------------------

local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

local positionValues = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
	CENTER = 'CENTER',
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
}

local orientationValues = {
	--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
	["LEFT"] = L["Left"],
	["MIDDLE"] = L["Middle"],
	["RIGHT"] = L["Right"],
}

local threatValues = {
	['GLOW'] = L["Glow"],
	['BORDERS'] = L["Borders"],
	['HEALTHBORDER'] = L["Health Border"],
	["INFOPANELBORDER"] = L["InfoPanel Border"],
	['ICONTOPLEFT'] = L["Icon: TOPLEFT"],
	['ICONTOPRIGHT'] = L["Icon: TOPRIGHT"],
	['ICONBOTTOMLEFT'] = L["Icon: BOTTOMLEFT"],
	['ICONBOTTOMRIGHT'] = L["Icon: BOTTOMRIGHT"],
	['ICONLEFT'] = L["Icon: LEFT"],
	['ICONRIGHT'] = L["Icon: RIGHT"],
	['ICONTOP'] = L["Icon: TOP"],
	['ICONBOTTOM'] = L["Icon: BOTTOM"],
	['NONE'] = NONE,
}

local petAnchors = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
}

local attachToValues = {
	["Health"] = L["Health"],
	["Power"] = L["Power"],
	["InfoPanel"] = L["Information Panel"],
	["Frame"] = L["Frame"],
}

local growthDirectionValues = {
	DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
	DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
	UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
	UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
	RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
	RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
	LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
	LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
}

local smartAuraPositionValues = {
	["DISABLED"] = DISABLE,
	["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
	["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"],
	["FLUID_BUFFS_ON_DEBUFFS"] = L["Fluid Position Buffs on Debuffs"],
	["FLUID_DEBUFFS_ON_BUFFS"] = L["Fluid Position Debuffs on Buffs"],
}

local colorOverrideValues = {
	['USE_DEFAULT'] = L["Use Default"],
	['FORCE_ON'] = L["Force On"],
	['FORCE_OFF'] = L["Force Off"],
}

local CUSTOMTEXT_CONFIGS = {}

local carryFilterFrom, carryFilterTo
local function filterValue(value)
	return gsub(value,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function filterPriority(auraType, groupName, value, remove, movehere, friendState)
	if not auraType or not value then return end
	local filter = E.db.unitframe.units[groupName] and E.db.unitframe.units[groupName][auraType] and E.db.unitframe.units[groupName][auraType].priority
	if not filter then return end
	local found = filterMatch(filter, filterValue(value))
	if found and movehere then
		local tbl, sv, sm = {strsplit(",",filter)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm);tinsert(tbl, sv, movehere);
		E.db.unitframe.units[groupName][auraType].priority = tconcat(tbl,',')
	elseif found and friendState then
		local realValue = match(value, "^Friendly:([^,]*)") or match(value, "^Enemy:([^,]*)") or value
		local friend = filterMatch(filter, filterValue("Friendly:"..realValue))
		local enemy = filterMatch(filter, filterValue("Enemy:"..realValue))
		local default = filterMatch(filter, filterValue(realValue))

		local state =
			(friend and (not enemy) and format("%s%s","Enemy:",realValue))					--[x] friend [ ] enemy: > enemy
		or	((not enemy and not friend) and format("%s%s","Friendly:",realValue))			--[ ] friend [ ] enemy: > friendly
		or	(enemy and (not friend) and default and format("%s%s","Friendly:",realValue))	--[ ] friend [x] enemy: (default exists) > friendly
		or	(enemy and (not friend) and match(value, "^Enemy:") and realValue)				--[ ] friend [x] enemy: (no default) > realvalue
		or	(friend and enemy and realValue)												--[x] friend [x] enemy: > default

		if state then
			local stateFound = filterMatch(filter, filterValue(state))
			if not stateFound then
				local tbl, sv = {strsplit(",",filter)}
				for i in ipairs(tbl) do
					if tbl[i] == value then sv = i;break end
				end
				tinsert(tbl, sv, state);tremove(tbl, sv+1)
				E.db.unitframe.units[groupName][auraType].priority = tconcat(tbl,',')
			end
		end
	elseif found and remove then
		E.db.unitframe.units[groupName][auraType].priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.unitframe.units[groupName][auraType].priority = (filter == '' and value) or (filter..","..value)
	end
end

-----------------------------------------------------------------------
-- OPTIONS TABLES
-----------------------------------------------------------------------
local function GetOptionsTable_AuraBars(updateFunc, groupName)
	local config = {
		order = 1100,
		type = 'group',
		name = L["Aura Bars"],
		get = function(info) return E.db.unitframe.units[groupName].aurabar[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].aurabar[ info[#info] ] = value; updateFunc(UF, groupName) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Aura Bars"],
			},
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			configureButton1 = {
				order = 3,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "auraBars") end,
			},
			configureButton2 = {
				order = 4,
				name = L["Coloring (Specific)"],
				type = 'execute',
				func = function() E:SetToFilterConfig('AuraBar Colors') end,
			},
			anchorPoint = {
				type = 'select',
				order = 5,
				name = L["Anchor Point"],
				desc = L["What point to anchor to the frame you set to attach to."],
				values = {
					['ABOVE'] = L["Above"],
					['BELOW'] = L["Below"],
				},
			},
			attachTo = {
				type = 'select',
				order = 6,
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = {
					['FRAME'] = L["Frame"],
					['DEBUFFS'] = L["Debuffs"],
					['BUFFS'] = L["Buffs"],
				},
			},
			height = {
				type = 'range',
				order = 7,
				name = L["Height"],
				min = 6, max = 40, step = 1,
			},
			maxBars = {
				type = 'range',
				order = 8,
				name = L["Max Bars"],
				min = 1, max = 40, step = 1,
			},
			sort = {
				type = 'select',
				order = 9,
				name = L["Sort Method"],
				values = {
					['TIME_REMAINING'] = L["Time Remaining"],
					['TIME_REMAINING_REVERSE'] = L["Time Remaining Reverse"],
					['TIME_DURATION'] = L["Duration"],
					['TIME_DURATION_REVERSE'] = L["Duration Reverse"],
					['NAME'] = NAME,
					['NONE'] = NONE,
				},
			},
			friendlyAuraType = {
				type = 'select',
				order = 16,
				name = L["Friendly Aura Type"],
				desc = L["Set the type of auras to show when a unit is friendly."],
				values = {
					['HARMFUL'] = L["Debuffs"],
					['HELPFUL'] = L["Buffs"],
				},
			},
			enemyAuraType = {
				type = 'select',
				order = 17,
				name = L["Enemy Aura Type"],
				desc = L["Set the type of auras to show when a unit is a foe."],
				values = {
					['HARMFUL'] = L["Debuffs"],
					['HELPFUL'] = L["Buffs"],
				},
			},
			uniformThreshold = {
				order = 18,
				type = "range",
				name = L["Uniform Threshold"],
				desc = L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."],
				min = 0, max = 3600, step = 1,
			},
			yOffset = {
				order = 19,
				type = 'range',
				name = L["yOffset"],
				min = -1000, max = 1000, step = 1,
			},
			spacing = {
				order = 20,
				type = "range",
				name = L["Spacing"],
				min = 0, softMax = 20, step = 1,
			},
			filters = {
				name = FILTERS,
				guiInline = true,
				type = 'group',
				order = 500,
				args = {},
			},
		},
	}

	if groupName == "target" then
		config.args.attachTo.values['PLAYER_AURABARS'] = L["Player Frame Aura Bars"]
	end

	config.args.filters.args.minDuration = {
		order = 16,
		type = 'range',
		name = L["Minimum Duration"],
		desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
		min = 0, max = 10800, step = 1,
	}
	config.args.filters.args.maxDuration = {
		order = 17,
		type = 'range',
		name = L["Maximum Duration"],
		desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
		min = 0, max = 10800, step = 1,
	}
	config.args.filters.args.jumpToFilter = {
		order = 18,
		name = L["Filters Page"],
		desc = L["Shortcut to 'Filters' section of the config."],
		type = "execute",
		func = function() ACD:SelectGroup("ElvUI", "filters") end,
	}
	config.args.filters.args.specialPriority = {
		order = 19,
		sortByValue = true,
		type = 'select',
		name = L["Add Special Filter"],
		desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
		values = function()
			local filters = {}
			local list = E.global.unitframe.specialFilters
			if not list then return end
			for filter in pairs(list) do
				filters[filter] = L[filter]
			end
			return filters
		end,
		set = function(info, value)
			filterPriority('aurabar', groupName, value)
			updateFunc(UF, groupName)
		end
	}
	config.args.filters.args.priority = {
		order = 20,
		name = L["Add Regular Filter"],
		desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
		type = 'select',
		values = function()
			local filters = {}
			local list = E.global.unitframe.aurafilters
			if not list then return end
			for filter in pairs(list) do
				filters[filter] = filter
			end
			return filters
		end,
		set = function(info, value)
			filterPriority('aurabar', groupName, value)
			updateFunc(UF, groupName)
		end
	}
	config.args.filters.args.resetPriority = {
		order = 21,
		name = L["Reset Priority"],
		desc = L["Reset filter priority to the default state."],
		type = "execute",
		func = function()
			E.db.unitframe.units[groupName].aurabar.priority = P.unitframe.units[groupName].aurabar.priority
			updateFunc(UF, groupName)
		end,
	}
	config.args.filters.args.filterPriority = {
		order = 22,
		dragdrop = true,
		type = "multiselect",
		name = L["Filter Priority"],
		dragOnLeave = function() end, --keep this here
		dragOnEnter = function(info)
			carryFilterTo = info.obj.value
		end,
		dragOnMouseDown = function(info)
			carryFilterFrom, carryFilterTo = info.obj.value, nil
		end,
		dragOnMouseUp = function(info)
			filterPriority('aurabar', groupName, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
			carryFilterFrom, carryFilterTo = nil, nil
		end,
		dragOnClick = function(info)
			filterPriority('aurabar', groupName, carryFilterFrom, true)
		end,
		stateSwitchGetText = function(_, TEXT)
			local friend, enemy = match(TEXT, "^Friendly:([^,]*)"), match(TEXT, "^Enemy:([^,]*)")
			local text = friend or enemy or TEXT
			local SF, localized = E.global.unitframe.specialFilters[text], L[text]
			local blockText = SF and localized and text:match("^block") and localized:gsub("^%[.-]%s?", "")
			local filterText = (blockText and format("|cFF999999%s|r %s", BLOCK, blockText)) or localized or text
			return (friend and format("|cFF33FF33%s|r %s", FRIEND, filterText)) or (enemy and format("|cFFFF3333%s|r %s", ENEMY, filterText)) or filterText
		end,
		stateSwitchOnClick = function(info)
			filterPriority('aurabar', groupName, carryFilterFrom, nil, nil, true)
		end,
		values = function()
			local str = E.db.unitframe.units[groupName].aurabar.priority
			if str == "" then return nil end
			return {strsplit(",",str)}
		end,
		get = function(info, value)
			local str = E.db.unitframe.units[groupName].aurabar.priority
			if str == "" then return nil end
			local tbl = {strsplit(",",str)}
			return tbl[value]
		end,
		set = function(info)
			E.db.unitframe.units[groupName].aurabar[ info[#info] ] = nil -- this was being set when drag and drop was first added, setting it to nil to clear tester profiles of this variable
			updateFunc(UF, groupName)
		end
	}
	config.args.filters.args.spacer1 = {
		order = 23,
		type = "description",
		name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."].."\n"..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."],
	}

	return config
end

local function GetOptionsTable_Auras(auraType, isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		order = auraType == 'buffs' and 600 or 700,
		type = 'group',
		name = auraType == 'buffs' and L["Buffs"] or L["Debuffs"],
		get = function(info) return E.db.unitframe.units[groupName][auraType][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName][auraType][ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				type = "header",
				order = 1,
				name = auraType == 'buffs' and L["Buffs"] or L["Debuffs"],
			},
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			perrow = {
				type = 'range',
				order = 3,
				name = L["Per Row"],
				min = 1, max = 20, step = 1,
			},
			numrows = {
				type = 'range',
				order = 4,
				name = L["Num Rows"],
				min = 1, max = 10, step = 1,
			},
			sizeOverride = {
				type = 'range',
				order = 5,
				name = L["Size Override"],
				desc = L["If not set to 0 then override the size of the aura icon to this."],
				min = 0, max = 60, step = 1,
			},
			xOffset = {
				order = 6,
				type = 'range',
				name = L["xOffset"],
				min = -1000, max = 1000, step = 1,
			},
			yOffset = {
				order = 7,
				type = 'range',
				name = L["yOffset"],
				min = -1000, max = 1000, step = 1,
			},
			anchorPoint = {
				type = 'select',
				order = 8,
				name = L["Anchor Point"],
				desc = L["What point to anchor to the frame you set to attach to."],
				values = positionValues,
			},
			fontSize = {
				order = 9,
				name = FONT_SIZE,
				type = "range",
				min = 6, max = 212, step = 1,
			},
			clickThrough = {
				order = 15,
				name = L["Click Through"],
				desc = L["Ignore mouse events."],
				type = 'toggle',
			},
			sortMethod = {
				order = 16,
				name = L["Sort By"],
				desc = L["Method to sort by."],
				type = 'select',
				values = {
					['TIME_REMAINING'] = L["Time Remaining"],
					['DURATION'] = L["Duration"],
					['NAME'] = NAME,
					['INDEX'] = L["Index"],
					["PLAYER"] = PLAYER,
				},
			},
			sortDirection = {
				order = 16,
				name = L["Sort Direction"],
				desc = L["Ascending or Descending order."],
				type = 'select',
				values = {
					['ASCENDING'] = L["Ascending"],
					['DESCENDING'] = L["Descending"],
				},
			},
			filters = {
				name = FILTERS,
				guiInline = true,
				type = 'group',
				order = 500,
				args = {},
			},
		},
	}

	if auraType == "buffs" then
		config.args.attachTo = {
			type = 'select',
			order = 7,
			name = L["Attach To"],
			desc = L["What to attach the buff anchor frame to."],
			values = {
				['FRAME'] = L["Frame"],
				['DEBUFFS'] = L["Debuffs"],
				["HEALTH"] = L["Health"],
				["POWER"] = L["Power"],
			},
			disabled = function()
				local smartAuraPosition = E.db.unitframe.units[groupName].smartAuraPosition
				return (smartAuraPosition and (smartAuraPosition == "BUFFS_ON_DEBUFFS" or smartAuraPosition == "FLUID_BUFFS_ON_DEBUFFS"))
			end,
		}
	else
		config.args.attachTo = {
			type = 'select',
			order = 7,
			name = L["Attach To"],
			desc = L["What to attach the debuff anchor frame to."],
			values = {
				['FRAME'] = L["Frame"],
				['BUFFS'] = L["Buffs"],
				["HEALTH"] = L["Health"],
				["POWER"] = L["Power"],
			},
			disabled = function()
				local smartAuraPosition = E.db.unitframe.units[groupName].smartAuraPosition
				return (smartAuraPosition and (smartAuraPosition == "DEBUFFS_ON_BUFFS" or smartAuraPosition == "FLUID_DEBUFFS_ON_BUFFS"))
			end,
		}
	end

	if isGroupFrame then
		config.args.countFontSize = {
			order = 10,
			name = L["Count Font Size"],
			type = "range",
			min = 6, max = 212, step = 1,
		}
	end

	config.args.filters.args.minDuration = {
		order = 16,
		type = 'range',
		name = L["Minimum Duration"],
		desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
		min = 0, max = 10800, step = 1,
	}
	config.args.filters.args.maxDuration = {
		order = 17,
		type = 'range',
		name = L["Maximum Duration"],
		desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
		min = 0, max = 10800, step = 1,
	}
	config.args.filters.args.jumpToFilter = {
		order = 18,
		name = L["Filters Page"],
		desc = L["Shortcut to 'Filters' section of the config."],
		type = "execute",
		func = function() ACD:SelectGroup("ElvUI", "filters") end,
	}
	config.args.filters.args.specialPriority = {
		order = 19,
		sortByValue = true,
		type = 'select',
		name = L["Add Special Filter"],
		desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
		values = function()
			local filters = {}
			local list = E.global.unitframe.specialFilters
			if not list then return end
			for filter in pairs(list) do
				filters[filter] = L[filter]
			end
			return filters
		end,
		set = function(info, value)
			filterPriority(auraType, groupName, value)
			updateFunc(UF, groupName, numUnits)
		end
	}
	config.args.filters.args.priority = {
		order = 20,
		name = L["Add Regular Filter"],
		desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
		type = 'select',
		values = function()
			local filters = {}
			local list = E.global.unitframe.aurafilters
			if not list then return end
			for filter in pairs(list) do
				filters[filter] = filter
			end
			return filters
		end,
		set = function(info, value)
			filterPriority(auraType, groupName, value)
			updateFunc(UF, groupName, numUnits)
		end
	}
	config.args.filters.args.resetPriority = {
		order = 21,
		name = L["Reset Priority"],
		desc = L["Reset filter priority to the default state."],
		type = "execute",
		func = function()
			E.db.unitframe.units[groupName][auraType].priority = P.unitframe.units[groupName][auraType].priority
			updateFunc(UF, groupName, numUnits)
		end,
	}
	config.args.filters.args.filterPriority = {
		order = 22,
		dragdrop = true,
		type = "multiselect",
		name = L["Filter Priority"],
		dragOnLeave = function() end, --keep this here
		dragOnEnter = function(info)
			carryFilterTo = info.obj.value
		end,
		dragOnMouseDown = function(info)
			carryFilterFrom, carryFilterTo = info.obj.value, nil
		end,
		dragOnMouseUp = function(info)
			filterPriority(auraType, groupName, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
			carryFilterFrom, carryFilterTo = nil, nil
		end,
		dragOnClick = function(info)
			filterPriority(auraType, groupName, carryFilterFrom, true)
		end,
		stateSwitchGetText = function(_, TEXT)
			local friend, enemy = match(TEXT, "^Friendly:([^,]*)"), match(TEXT, "^Enemy:([^,]*)")
			local text = friend or enemy or TEXT
			local SF, localized = E.global.unitframe.specialFilters[text], L[text]
			local blockText = SF and localized and text:match("^block") and localized:gsub("^%[.-]%s?", "")
			local filterText = (blockText and format("|cFF999999%s|r %s", BLOCK, blockText)) or localized or text
			return (friend and format("|cFF33FF33%s|r %s", FRIEND, filterText)) or (enemy and format("|cFFFF3333%s|r %s", ENEMY, filterText)) or filterText
		end,
		stateSwitchOnClick = function(info)
			filterPriority(auraType, groupName, carryFilterFrom, nil, nil, true)
		end,
		values = function()
			local str = E.db.unitframe.units[groupName][auraType].priority
			if str == "" then return nil end
			return {strsplit(",",str)}
		end,
		get = function(info, value)
			local str = E.db.unitframe.units[groupName][auraType].priority
			if str == "" then return nil end
			local tbl = {strsplit(",",str)}
			return tbl[value]
		end,
		set = function(info)
			E.db.unitframe.units[groupName][auraType][ info[#info] ] = nil -- this was being set when drag and drop was first added, setting it to nil to clear tester profiles of this variable
			updateFunc(UF, groupName, numUnits)
		end
	}
	config.args.filters.args.spacer1 = {
		order = 23,
		type = "description",
		name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."].."\n"..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."],
	}

	return config
end

local function GetOptionsTable_Castbar(hasTicks, updateFunc, groupName, numUnits)
	local config = {
		order = 800,
		type = 'group',
		name = L["Castbar"],
		get = function(info) return E.db.unitframe.units[groupName].castbar[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].castbar[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Castbar"],
			},
			matchsize = {
				order = 2,
				type = 'execute',
				name = L["Match Frame Width"],
				func = function() E.db.unitframe.units[groupName].castbar.width = E.db.unitframe.units[groupName].width; updateFunc(UF, groupName, numUnits) end,
			},
			forceshow = {
				order = 3,
				name = SHOW..' / '..HIDE,
				func = function()
					local frameName = E:StringTitle(groupName)
					frameName = "ElvUF_"..frameName
					frameName = frameName:gsub('t(arget)', 'T%1')

					if groupName == "party" then
						local header = UF.headers[groupName]
						for i = 1, header:GetNumChildren() do
							local group = select(i, header:GetChildren())
							for j = 1, group:GetNumChildren() do
								--Party unitbutton
								local unitbutton = select(j, group:GetChildren())
								local castbar = unitbutton.Castbar
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
				end,
				type = 'execute',
			},
			configureButton = {
				order = 4,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "castBars") end,
			},
			enable = {
				type = 'toggle',
				order = 5,
				name = L["Enable"],
			},
			width = {
				order = 6,
				name = L["Width"],
				type = 'range',
				softMax = 600,
				min = 50, max = GetScreenWidth(), step = 1,
			},
			height = {
				order = 7,
				name = L["Height"],
				type = 'range',
				min = 10, max = 85, step = 1,
			},
			latency = {
				order = 8,
				name = L["Latency"],
				type = 'toggle',
			},
			format = {
				order = 9,
				type = 'select',
				name = L["Format"],
				values = {
					['CURRENTMAX'] = L["Current / Max"],
					['CURRENT'] = L["Current"],
					['REMAINING'] = L["Remaining"],
					['REMAININGMAX'] = L["Remaining / Max"],
				},
			},
			spark = {
				order = 10,
				type = 'toggle',
				name = L["Spark"],
				desc = L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."],
			},
			insideInfoPanel = {
				order = 11,
				name = L["Inside Information Panel"],
				desc = L["Display the castbar inside the information panel, the icon will be displayed outside the main unitframe."],
				type = "toggle",
				disabled = function() return not E.db.unitframe.units[groupName].infoPanel or not E.db.unitframe.units[groupName].infoPanel.enable end,
			},
			iconSettings = {
				order = 13,
				type = "group",
				name = L["Icon"],
				guiInline = true,
				get = function(info) return E.db.unitframe.units[groupName].castbar[ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
				args = {
					icon = {
						order = 1,
						name = L["Enable"],
						type = 'toggle',
					},
					iconAttached = {
						order = 2,
						name = L["Icon Inside Castbar"],
						desc = L["Display the castbar icon inside the castbar."],
						type = "toggle",
					},
					iconSize = {
						order = 3,
						name = L["Icon Size"],
						desc = L["This dictates the size of the icon when it is not attached to the castbar."],
						type = "range",
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
						min = 8, max = 150, step = 1,
					},
					iconAttachedTo = {
						order = 4,
						type = "select",
						name = L["Attach To"],
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
						values = {
							["Frame"] = L["Frame"],
							["Castbar"] = L["Castbar"],
						},
					},
					iconPosition = {
						type = 'select',
						order = 5,
						name = L["Position"],
						values = positionValues,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
					},
					iconXOffset = {
						order = 5,
						type = "range",
						name = L["xOffset"],
						min = -300, max = 300, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
					},
					iconYOffset = {
						order = 6,
						type = "range",
						name = L["yOffset"],
						min = -300, max = 300, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
					},
				},
			},
			timeToHold = {
				order = 8,
				name = L["Time To Hold"],
				desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
				type = "range",
				min = 0, max = 10, step = .1,
			},
			strataAndLevel = {
				order = 9,
				type = "group",
				name = L["Strata and Level"],
				get = function(info) return E.db.unitframe.units[groupName].castbar.strataAndLevel[ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar.strataAndLevel[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
				guiInline = true,
				args = {
					useCustomStrata = {
						order = 1,
						type = "toggle",
						name = L["Use Custom Strata"],
					},
					frameStrata = {
						order = 2,
						type = "select",
						name = L["Frame Strata"],
						values = {
							["BACKGROUND"] = "BACKGROUND",
							["LOW"] = "LOW",
							["MEDIUM"] = "MEDIUM",
							["HIGH"] = "HIGH",
							["DIALOG"] = "DIALOG",
							["TOOLTIP"] = "TOOLTIP",
						},
					},
					spacer = {
						order = 3,
						type = "description",
						name = "",
					},
					useCustomLevel = {
						order = 4,
						type = "toggle",
						name = L["Use Custom Level"],
					},
					frameLevel = {
						order = 5,
						type = "range",
						name = L["Frame Level"],
						min = 2, max = 128, step = 1,
					},
				},
			}
		},
	}


	if hasTicks then
		config.args.displayTarget = {
			order = 11,
			type = 'toggle',
			name = L["Display Target"],
			desc = L["Display the target of your current cast. Useful for mouseover casts."],
		}
		config.args.ticks = {
			order = 12,
			type = "group",
			guiInline = true,
			name = L["Ticks"],
			args = {
				ticks = {
					order = 1,
					type = 'toggle',
					name = L["Ticks"],
					desc = L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."],
				},
				tickColor = {
					order = 2,
					type = "color",
					name = COLOR,
					hasAlpha = true,
					get = function(info)
						local c = E.db.unitframe.units[groupName].castbar.tickColor
						local d = P.unitframe.units[groupName].castbar.tickColor
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local c = E.db.unitframe.units[groupName].castbar.tickColor
						c.r, c.g, c.b, c.a = r, g, b, a
						updateFunc(UF, groupName, numUnits)
					end,
				},
				tickWidth = {
					order = 3,
					type = "range",
					name = L["Width"],
					min = 1, max = 20, step = 1,
				},
			},
		}
	end

	return config
end


local function GetOptionsTable_InformationPanel(updateFunc, groupName, numUnits)

	local config = {
		order = 4000,
		type = 'group',
		name = L["Information Panel"],
		get = function(info) return E.db.unitframe.units[groupName].infoPanel[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].infoPanel[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Information Panel"],
			},
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			transparent = {
				type = "toggle",
				order = 3,
				name = L["Transparent"],
			},
			height = {
				type = 'range',
				order = 4,
				name = L["Height"],
				min = 4, max = 30, step = 1,
			},
		}
	}

	return config
end

local function GetOptionsTable_Health(isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		order = 100,
		type = 'group',
		name = L["Health"],
		get = function(info) return E.db.unitframe.units[groupName].health[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].health[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 0,
				type = "header",
				name = L["Health"],
			},
			position = {
				type = 'select',
				order = 1,
				name = L["Text Position"],
				values = positionValues,
			},
			xOffset = {
				order = 2,
				type = 'range',
				name = L["Text xOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 3,
				type = 'range',
				name = L["Text yOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			reverseFill = {
				type = "toggle",
				order = 4,
				name = L["Reverse Fill"],
			},
			attachTextTo = {
				type = 'select',
				order = 5,
				name = L["Attach Text To"],
				values = attachToValues,
			},
			bgUseBarTexture = {
				type = "toggle",
				order = 6,
				name = L["Use Health Texture on Background"],
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = 'input',
				width = 'full',
				desc = L["TEXT_FORMAT_DESC"],
			},
			configureButton = {
				order = 6,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "healthGroup") end,
			},
		},
	}

	if isGroupFrame then
		config.args.frequentUpdates = {
			type = 'toggle',
			order = 2,
			name = L["Frequent Updates"],
			desc = L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."],
		}

		config.args.orientation = {
			type = 'select',
			order = 3,
			name = L["Statusbar Fill Orientation"],
			desc = L["Direction the health bar moves when gaining/losing health."],
			values = {
				['HORIZONTAL'] = L["Horizontal"],
				['VERTICAL'] = L["Vertical"],
			},
		}
	end

	return config
end

local function CreateCustomTextGroup(unit, objectName)
	if not E.Options.args.unitframe.args[unit] then
		return
	elseif E.Options.args.unitframe.args[unit].args.customText.args[objectName] then
		E.Options.args.unitframe.args[unit].args.customText.args[objectName].hidden = false -- Re-show existing custom texts which belong to current profile and were previously hidden
		tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[unit].args.customText.args[objectName]) --Register this custom text config to be hidden again on profile change
		return
	end

	E.Options.args.unitframe.args[unit].args.customText.args[objectName] = {
		order = -1,
		type = 'group',
		name = objectName,
		get = function(info) return E.db.unitframe.units[unit].customTexts[objectName][ info[#info] ] end,
		set = function(info, value)
			E.db.unitframe.units[unit].customTexts[objectName][ info[#info] ] = value;

			if unit == 'party' or unit:find('raid') then
				UF:CreateAndUpdateHeaderGroup(unit)
			elseif unit == 'boss' then
				UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES)
			elseif unit == 'arena' then
				UF:CreateAndUpdateUFGroup('arena', 5)
			else
				UF:CreateAndUpdateUF(unit)
			end
		end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = objectName,
			},
			delete = {
				type = 'execute',
				order = 2,
				name = DELETE,
				func = function()
					E.Options.args.unitframe.args[unit].args.customText.args[objectName] = nil;
					E.db.unitframe.units[unit].customTexts[objectName] = nil;

					if unit == 'boss' or unit == 'arena' then
						for i=1, 5 do
							if UF[unit..i] then
								UF[unit..i]:Untag(UF[unit..i].customTexts[objectName]);
								UF[unit..i].customTexts[objectName]:Hide();
								UF[unit..i].customTexts[objectName] = nil
							end
						end
					elseif unit == 'party' or unit:find('raid') then
						for i=1, UF[unit]:GetNumChildren() do
							local child = select(i, UF[unit]:GetChildren())
							if child.Untag then
								child:Untag(child.customTexts[objectName]);
								child.customTexts[objectName]:Hide();
								child.customTexts[objectName] = nil
							else
								for x=1, child:GetNumChildren() do
									local c2 = select(x, child:GetChildren())
									if(c2.Untag) then
										c2:Untag(c2.customTexts[objectName]);
										c2.customTexts[objectName]:Hide();
										c2.customTexts[objectName] = nil
									end
								end
							end
						end
					elseif UF[unit] then
						UF[unit]:Untag(UF[unit].customTexts[objectName]);
						UF[unit].customTexts[objectName]:Hide();
						UF[unit].customTexts[objectName] = nil
					end
				end,
			},
			enable = {
				order = 3,
				type = "toggle",
				name = L["Enable"],
			},
			font = {
				type = "select", dialogControl = 'LSM30_Font',
				order = 4,
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font,
			},
			size = {
				order = 5,
				name = FONT_SIZE,
				type = "range",
				min = 4, max = 212, step = 1,
			},
			fontOutline = {
				order = 6,
				name = L["Font Outline"],
				desc = L["Set the font outline."],
				type = "select",
				values = {
					['NONE'] = NONE,
					['OUTLINE'] = 'OUTLINE',
					['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
					['THICKOUTLINE'] = 'THICKOUTLINE',
				},
			},
			justifyH = {
				order = 7,
				type = 'select',
				name = L["JustifyH"],
				desc = L["Sets the font instance's horizontal text alignment style."],
				values = {
					['CENTER'] = L["Center"],
					['LEFT'] = L["Left"],
					['RIGHT'] = L["Right"],
				},
			},
			xOffset = {
				order = 8,
				type = 'range',
				name = L["xOffset"],
				min = -400, max = 400, step = 1,
			},
			yOffset = {
				order = 9,
				type = 'range',
				name = L["yOffset"],
				min = -400, max = 400, step = 1,
			},
			attachTextTo = {
				type = 'select',
				order = 10,
				name = L["Attach Text To"],
				values = attachToValues,
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = 'input',
				width = 'full',
				desc = L["TEXT_FORMAT_DESC"],
			},
		},
	}

	tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[unit].args.customText.args[objectName]) --Register this custom text config to be hidden on profile change
end

local function GetOptionsTable_CustomText(updateFunc, groupName, numUnits)
	local config = {
		order = 5100,
		type = "group",
		name = L["Custom Texts"],
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Custom Texts"],
			},
			createCustomText = {
				order = 2,
				type = 'input',
				name = L["Create Custom Text"],
				width = 'full',
				get = function() return '' end,
				set = function(info, textName)
					for object in pairs(E.db.unitframe.units[groupName]) do
						if object:lower() == textName:lower() then
							E:Print(L["The name you have selected is already in use by another element."])
							return
						end
					end

					if not E.db.unitframe.units[groupName].customTexts then
						E.db.unitframe.units[groupName].customTexts = {};
					end

					local frameName = "ElvUF_"..E:StringTitle(groupName)
					if E.db.unitframe.units[groupName].customTexts[textName] or (_G[frameName] and _G[frameName].customTexts and _G[frameName].customTexts[textName] or _G[frameName.."Group1UnitButton1"] and _G[frameName.."Group1UnitButton1"].customTexts and _G[frameName.."Group1UnitButton1"][textName]) then
						E:Print(L["The name you have selected is already in use by another element."])
						return;
					end

					E.db.unitframe.units[groupName].customTexts[textName] = {
						['text_format'] = '',
						['size'] = E.db.unitframe.fontSize,
						['font'] = E.db.unitframe.font,
						['xOffset'] = 0,
						['yOffset'] = 0,
						['justifyH'] = 'CENTER',
						['fontOutline'] = E.db.unitframe.fontOutline,
						['attachTextTo'] = 'Health'
					};

					CreateCustomTextGroup(groupName, textName)
					updateFunc(UF, groupName, numUnits)
				end,
			},
		},
	}

	return config
end

local function GetOptionsTable_Name(updateFunc, groupName, numUnits)
	local config = {
		order = 400,
		type = 'group',
		name = L["Name"],
		get = function(info) return E.db.unitframe.units[groupName].name[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].name[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Name"],
			},
			position = {
				type = 'select',
				order = 2,
				name = L["Text Position"],
				values = positionValues,
			},
			xOffset = {
				order = 3,
				type = 'range',
				name = L["Text xOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 4,
				type = 'range',
				name = L["Text yOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			attachTextTo = {
				type = 'select',
				order = 5,
				name = L["Attach Text To"],
				values = attachToValues,
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = 'input',
				width = 'full',
				desc = L["TEXT_FORMAT_DESC"],
			},
		},
	}

	return config
end

local function GetOptionsTable_Portrait(updateFunc, groupName, numUnits)
	local config = {
		order = 400,
		type = 'group',
		name = L["Portrait"],
		get = function(info) return E.db.unitframe.units[groupName].portrait[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].portrait[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Portrait"],
			},
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
				desc = L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."],
			},
			width = {
				type = 'range',
				order = 3,
				name = L["Width"],
				min = 15, max = 150, step = 1,
			},
			overlay = {
				type = 'toggle',
				name = L["Overlay"],
				desc = L["The Portrait will overlay the Healthbar. This will be automatically happen if the Frame Orientation is set to Middle."],
				order = 4,
			},
			rotation = {
				type = 'range',
				name = L["Model Rotation"],
				order = 4,
				min = 0, max = 360, step = 1,
			},
			camDistanceScale = {
				type = 'range',
				name = L["Camera Distance Scale"],
				desc = L["How far away the portrait is from the camera."],
				order = 5,
				min = 0.01, max = 4, step = 0.01,
			},
			style = {
				type = 'select',
				name = L["Style"],
				desc = L["Select the display method of the portrait."],
				order = 6,
				values = {
					['2D'] = L["2D"],
					['3D'] = L["3D"],
				},
			},
			xOffset = {
				order = 7,
				type = "range",
				name = L["xOffset"],
				desc = L["Position the Model horizontally."],
				min = -1, max = 1, step = 0.01,
			},
			yOffset = {
				order = 8,
				type = "range",
				name = L["yOffset"],
				desc = L["Position the Model vertically."],
				min = -1, max = 1, step = 0.01,
			},
		},
	}

	return config
end

local function GetOptionsTable_Power(hasDetatchOption, updateFunc, groupName, numUnits, hasStrataLevel)
	local config = {
		order = 200,
		type = 'group',
		name = L["Power"],
		get = function(info) return E.db.unitframe.units[groupName].power[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].power[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 0,
				type = "header",
				name = L["Power"],
			},
			enable = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
			},
			powerPrediction = {
				type = 'toggle',
				order = 2,
				name = L["Power Prediction"],
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = 'input',
				width = 'full',
				desc = L["TEXT_FORMAT_DESC"],
			},
			width = {
				type = 'select',
				order = 3,
				name = L["Style"],
				values = {
					['fill'] = L["Filled"],
					['spaced'] = L["Spaced"],
					['inset'] = L["Inset"]
				},
				set = function(info, value)
					E.db.unitframe.units[groupName].power[ info[#info] ] = value;

					local frameName = E:StringTitle(groupName)
					frameName = "ElvUF_"..frameName
					frameName = frameName:gsub('t(arget)', 'T%1')

					if numUnits then
						for i=1, numUnits do
							if _G[frameName..i] then
								local min, max = _G[frameName..i].Power:GetMinMaxValues()
								_G[frameName..i].Power:SetMinMaxValues(min, max + 500)
								_G[frameName..i].Power:SetValue(1)
								_G[frameName..i].Power:SetValue(0)
							end
						end
					else
						if _G[frameName] and _G[frameName].Power then
							local min, max = _G[frameName].Power:GetMinMaxValues()
							_G[frameName].Power:SetMinMaxValues(min, max + 500)
							_G[frameName].Power:SetValue(1)
							_G[frameName].Power:SetValue(0)
						else
							for i=1, _G[frameName]:GetNumChildren() do
								local child = select(i, _G[frameName]:GetChildren())
								if child and child.Power then
									local min, max = child.Power:GetMinMaxValues()
									child.Power:SetMinMaxValues(min, max + 500)
									child.Power:SetValue(1)
									child.Power:SetValue(0)
								end
							end
						end
					end

					updateFunc(UF, groupName, numUnits)
				end,
			},
			height = {
				type = 'range',
				name = L["Height"],
				order = 4,
				min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 50, step = 1,
			},
			offset = {
				type = 'range',
				name = L["Offset"],
				desc = L["Offset of the powerbar to the healthbar, set to 0 to disable."],
				order = 5,
				min = 0, max = 20, step = 1,
			},
			configureButton = {
				order = 6,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "powerGroup") end,
			},
			reverseFill = {
				type = "toggle",
				order = 7,
				name = L["Reverse Fill"],
			},
			position = {
				type = 'select',
				order = 8,
				name = L["Text Position"],
				values = positionValues,
			},
			xOffset = {
				order = 9,
				type = 'range',
				name = L["Text xOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 10,
				type = 'range',
				name = L["Text yOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			attachTextTo = {
				type = 'select',
				order = 11,
				name = L["Attach Text To"],
				values = attachToValues,
			},
		},
	}

	if hasDetatchOption then
			config.args.detachFromFrame = {
				type = 'toggle',
				order = 11,
				name = L["Detach From Frame"],
			}
			config.args.detachedWidth = {
				type = 'range',
				order = 12,
				name = L["Detached Width"],
				disabled = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
				min = 15, max = 1000, step = 1,
			}
			config.args.parent = {
				type = 'select',
				order = 13,
				name = L["Parent"],
				desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
				disabled = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
				values = {
					["FRAME"] = "FRAME",
					["UIPARENT"] = "UIPARENT",
				},
			}
	end

	if hasStrataLevel then
		config.args.strataAndLevel = {
			order = 101,
			type = "group",
			name = L["Strata and Level"],
			get = function(info) return E.db.unitframe.units[groupName].power.strataAndLevel[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units[groupName].power.strataAndLevel[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
			guiInline = true,
			args = {
				useCustomStrata = {
					order = 1,
					type = "toggle",
					name = L["Use Custom Strata"],
				},
				frameStrata = {
					order = 2,
					type = "select",
					name = L["Frame Strata"],
					values = {
						["BACKGROUND"] = "BACKGROUND",
						["LOW"] = "LOW",
						["MEDIUM"] = "MEDIUM",
						["HIGH"] = "HIGH",
						["DIALOG"] = "DIALOG",
						["TOOLTIP"] = "TOOLTIP",
					},
				},
				spacer = {
					order = 3,
					type = "description",
					name = "",
				},
				useCustomLevel = {
					order = 4,
					type = "toggle",
					name = L["Use Custom Level"],
				},
				frameLevel = {
					order = 5,
					type = "range",
					name = L["Frame Level"],
					min = 2, max = 128, step = 1,
				},
			},
		}
	end

	return config
end

local function GetOptionsTable_RaidIcon(updateFunc, groupName, numUnits)
	local config = {
		order = 5000,
		type = 'group',
		name = L["Raid Icon"],
		get = function(info) return E.db.unitframe.units[groupName].raidicon[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].raidicon[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Raid Icon"],
			},
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			attachTo = {
				type = 'select',
				order = 3,
				name = L["Position"],
				values = positionValues,
			},
			attachToObject = {
				type = 'select',
				order = 4,
				name = L["Attach To"],
				values = attachToValues,
			},
			size = {
				type = 'range',
				name = L["Size"],
				order = 4,
				min = 8, max = 60, step = 1,
			},
			xOffset = {
				order = 5,
				type = 'range',
				name = L["xOffset"],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 6,
				type = 'range',
				name = L["yOffset"],
				min = -300, max = 300, step = 1,
			},
		},
	}

	return config
end

local function GetOptionsTable_ResurrectIcon(updateFunc, groupName, numUnits)
	local config = {
		order = 5001,
		type = 'group',
		name = L["Resurrect Icon"],
		get = function(info) return E.db.unitframe.units[groupName].resurrectIcon[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].resurrectIcon[ info[#info] ] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Resurrect Icon"],
			},
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			attachTo = {
				type = 'select',
				order = 3,
				name = L["Position"],
				values = positionValues,
			},
			attachToObject = {
				type = 'select',
				order = 4,
				name = L["Attach To"],
				values = attachToValues,
			},
			size = {
				order = 5,
				type = 'range',
				name = L["Size"],
				min = 8, max = 60, step = 1,
			},
			xOffset = {
				order = 6,
				type = 'range',
				name = L["xOffset"],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 7,
				type = 'range',
				name = L["yOffset"],
				min = -300, max = 300, step = 1,
			},
		},
	}

	return config
end

local function GetOptionsTable_RaidDebuff(updateFunc, groupName)
	local config = {
		order = 800,
		type = 'group',
		name = L["RaidDebuff Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].rdebuffs[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].rdebuffs[ info[#info] ] = value; updateFunc(UF, groupName) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["RaidDebuff Indicator"],
			},
			enable = {
				order = 2,
				type = 'toggle',
				name = L["Enable"],
			},
			showDispellableDebuff = {
				order = 3,
				type = "toggle",
				name = L["Show Dispellable Debuffs"],
			},
			onlyMatchSpellID = {
				order = 4,
				type = "toggle",
				name = L["Only Match SpellID"],
				desc = L["When enabled it will only show spells that were added to the filter using a spell ID and not a name."],
			},
			size = {
				order = 4,
				type = 'range',
				name = L["Size"],
				min = 8, max = 100, step = 1,
			},
			font = {
				order = 5,
				type = "select", dialogControl = "LSM30_Font",
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font,
			},
			fontSize = {
				order = 6,
				type = 'range',
				name = FONT_SIZE,
				min = 7, max = 212, step = 1,
			},
			fontOutline = {
				order = 7,
				type = "select",
				name = L["Font Outline"],
				values = {
					["NONE"] = NONE,
					["OUTLINE"] = "OUTLINE",
					["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
					["THICKOUTLINE"] = "THICKOUTLINE",
				},
			},
			xOffset = {
				order = 8,
				type = 'range',
				name = L["xOffset"],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 9,
				type = 'range',
				name = L["yOffset"],
				min = -300, max = 300, step = 1,
			},
			configureButton = {
				order = 10,
				type = 'execute',
				name = L["Configure Auras"],
				func = function() E:SetToFilterConfig('RaidDebuffs') end,
			},
			duration = {
				order = 11,
				type = "group",
				guiInline = true,
				name = L["Duration Text"],
				get = function(info) return E.db.unitframe.units[groupName].rdebuffs.duration[ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units[groupName].rdebuffs.duration[ info[#info] ] = value; updateFunc(UF, groupName) end,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = positionValues,
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["xOffset"],
						min = -10, max = 10, step = 1,
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["yOffset"],
						min = -10, max = 10, step = 1,
					},
					color = {
						order = 4,
						type = "color",
						name = COLOR,
						hasAlpha = true,
						get = function(info)
							local c = E.db.unitframe.units.raid.rdebuffs.duration.color
							local d = P.unitframe.units.raid.rdebuffs.duration.color
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							local c = E.db.unitframe.units.raid.rdebuffs.duration.color
							c.r, c.g, c.b, c.a = r, g, b, a
							UF:CreateAndUpdateHeaderGroup('raid')
						end,
					},
				},
			},
			stack = {
				order = 12,
				type = "group",
				guiInline = true,
				name = L["Stack Counter"],
				get = function(info) return E.db.unitframe.units[groupName].rdebuffs.stack[ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units[groupName].rdebuffs.stack[ info[#info] ] = value; updateFunc(UF, groupName) end,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = positionValues,
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["xOffset"],
						min = -10, max = 10, step = 1,
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["yOffset"],
						min = -10, max = 10, step = 1,
					},
					color = {
						order = 4,
						type = "color",
						name = COLOR,
						hasAlpha = true,
						get = function(info)
							local c = E.db.unitframe.units[groupName].rdebuffs.stack.color
							local d = P.unitframe.units[groupName].rdebuffs.stack.color
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							local c = E.db.unitframe.units[groupName].rdebuffs.stack.color
							c.r, c.g, c.b, c.a = r, g, b, a
							updateFunc(UF, groupName)
						end,
					},
				},
			},
		},
	}

	return config
end

local function GetOptionsTable_ReadyCheckIcon(updateFunc, groupName)
	local config = {
		order = 900,
		type = "group",
		name = L["Ready Check Icon"],
		get = function(info) return E.db.unitframe.units[groupName].readycheckIcon[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].readycheckIcon[ info[#info] ] = value; updateFunc(UF, groupName) end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Ready Check Icon"],
			},
			enable = {
				order = 2,
				type = "toggle",
				name = L["Enable"],
			},
			size = {
				order = 3,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1,
			},
			attachTo = {
				order = 4,
				type = "select",
				name = L["Attach To"],
				values = attachToValues,
			},
			position = {
				order = 5,
				type = "select",
				name = L["Position"],
				values = positionValues,
			},
			xOffset = {
				order = 6,
				type = "range",
				name = L["xOffset"],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 7,
				type = "range",
				name = L["yOffset"],
				min = -300, max = 300, step = 1,
			},
		},
	}

	return config
end

local function GetOptionsTable_HealPrediction(updateFunc, groupName)
	local config = {
		order = 101,
		type = "group",
		name = L["Heal Prediction"],
		desc = L["Show an incoming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
		get = function(info) return E.db.unitframe.units[groupName].healPrediction[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName].healPrediction[ info[#info] ] = value; updateFunc(UF, groupName) end,
		args = {
			header = {
				order = 0,
				type = "header",
				name = L["Heal Prediction"],
			},
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			showOverAbsorbs = {
				order = 2,
				type = "toggle",
				name = L["Show Over Absorbs"],
			},
			showAbsorbAmount = {
				order = 3,
				type = "toggle",
				name = L["Show Absorb Amount"],
				disabled = function() return not E.db.unitframe.units[groupName].healPrediction.showOverAbsorbs end,
			},
			colors = {
				order = 4,
				type = "execute",
				name = COLORS,
				buttonElvUI = true,
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup") end,
				disabled = function() return not E.UnitFrames; end,
			},
		},
	}

	return config
end

E.Options.args.unitframe = {
	type = "group",
	name = L["UnitFrames"],
	childGroups = "tree",
	get = function(info) return E.db.unitframe[ info[#info] ] end,
	set = function(info, value) E.db.unitframe[ info[#info] ] = value end,
	args = {
		enable = {
			order = 0,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.unitframe.enable end,
			set = function(info, value) E.private.unitframe.enable = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		intro = {
			order = 1,
			type = "description",
			name = L["UNITFRAME_DESC"],
		},
		header = {
			order = 2,
			type = "header",
			name = L["Shortcuts"],
		},
		spacer1 = {
			order = 3,
			type = "description",
			name = " ",
		},
		generalShortcut = {
			order = 4,
			type = "execute",
			name = L["General"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "generalGroup") end,
			disabled = function() return not E.UnitFrames; end,
		},
		frameGlowShortcut = {
			order = 5,
			type = "execute",
			name = L["Frame Glow"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "frameGlowGroup") end,
			disabled = function() return not E.UnitFrames; end,
		},
		cooldownShortcut = {
			order = 6,
			type = "execute",
			name = L["Cooldowns"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "cooldown", "unitframe") end,
			disabled = function() return not E.UnitFrames; end,
		},
		spacer2 = {
			order = 7,
			type = "description",
			name = " ",
		},
		colorsShortcut = {
			order = 8,
			type = "execute",
			name = COLORS,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup") end,
			disabled = function() return not E.UnitFrames; end,
		},
		blizzardShortcut = {
			order = 9,
			type = "execute",
			name = L["Disabled Blizzard Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "disabledBlizzardFrames") end,
			disabled = function() return not E.UnitFrames; end,
		},
		playerShortcut = {
			order = 10,
			type = "execute",
			name = L["Player Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "player") end,
			disabled = function() return not E.UnitFrames; end,
		},
		spacer3 = {
			order = 11,
			type = "description",
			name = " ",
		},
		targetShortcut = {
			order = 12,
			type = "execute",
			name = L["Target Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "target") end,
			disabled = function() return not E.UnitFrames; end,
		},
		targettargetShortcut = {
			order = 13,
			type = "execute",
			name = L["TargetTarget Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "targettarget") end,
			disabled = function() return not E.UnitFrames; end,
		},
		targettargettargetShortcut = {
			order = 14,
			type = "execute",
			name = L["TargetTargetTarget Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "targettargettarget") end,
			disabled = function() return not E.UnitFrames; end,
		},
		spacer4 = {
			order = 15,
			type = "description",
			name = " ",
		},
		focusShortcut = {
			order = 16,
			type = "execute",
			name = L["Focus Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "focus") end,
			disabled = function() return not E.UnitFrames; end,
		},
		focustargetShortcut = {
			order = 17,
			type = "execute",
			name = L["FocusTarget Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "focustarget") end,
			disabled = function() return not E.UnitFrames; end,
		},
		petShortcut = {
			order = 18,
			type = "execute",
			name = L["Pet Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "pet") end,
			disabled = function() return not E.UnitFrames; end,
		},
		spacer5 = {
			order = 19,
			type = "description",
			name = " ",
		},
		pettargetShortcut = {
			order = 20,
			type = "execute",
			name = L["PetTarget Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "pettarget") end,
			disabled = function() return not E.UnitFrames; end,
		},
		arenaShortcut = {
			order = 21,
			type = "execute",
			name = L["Arena Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "arena") end,
			disabled = function() return not E.UnitFrames; end,
		},
		bossShortcut = {
			order = 22,
			type = "execute",
			name = L["Boss Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "boss") end,
			disabled = function() return not E.UnitFrames; end,
		},
		spacer6 = {
			order = 23,
			type = "description",
			name = " ",
		},
		partyShortcut = {
			order = 24,
			type = "execute",
			name = L["Party Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "party") end,
			disabled = function() return not E.UnitFrames; end,
		},
		raidShortcut = {
			order = 25,
			type = "execute",
			name = L["Raid Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "raid") end,
			disabled = function() return not E.UnitFrames; end,
		},
		raid40Shortcut = {
			order = 26,
			type = "execute",
			name = L["Raid-40 Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "raid40") end,
			disabled = function() return not E.UnitFrames; end,
		},
		spacer7 = {
			order = 27,
			type = "description",
			name = " ",
		},
		raidpetShortcut = {
			order = 28,
			type = "execute",
			name = L["Raid Pet Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "raidpet") end,
			disabled = function() return not E.UnitFrames; end,
		},
		assistShortcut = {
			order = 29,
			type = "execute",
			name = L["Assist Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "assist") end,
			disabled = function() return not E.UnitFrames; end,
		},
		tankShortcut = {
			order = 30,
			type = "execute",
			name = L["Tank Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "unitframe", "tank") end,
			disabled = function() return not E.UnitFrames; end,
		},
		generalOptionsGroup = {
			order = 31,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.UnitFrames; end,
			args = {
				generalGroup = {
					order = 1,
					type = 'group',
					name = L["General"],
					args = {
						header = {
							order = 0,
							type = "header",
							name = L["General"],
						},
						thinBorders = {
							order = 1,
							name = L["Thin Borders"],
							desc = L["Use thin borders on certain unitframe elements."],
							type = 'toggle',
							disabled = function() return E.private.general.pixelPerfect end,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						OORAlpha = {
							order = 2,
							name = L["OOR Alpha"],
							desc = L["The alpha to set units that are out of range to."],
							type = 'range',
							softMin = .1, min = 0, max = 1, step = 0.01,
						},
						debuffHighlighting = {
							order = 3,
							name = L["Debuff Highlighting"],
							desc = L["Color the unit healthbar if there is a debuff that can be dispelled by you."],
							type = 'select',
							values = {
								['NONE'] = NONE,
								['GLOW'] = L["Glow"],
								['FILL'] = L["Fill"]
							},
						},
						smartRaidFilter = {
							order = 4,
							name = L["Smart Raid Filter"],
							desc = L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."],
							type = 'toggle',
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:UpdateAllHeaders() end
						},
						targetOnMouseDown = {
							order = 5,
							name = L["Target On Mouse-Down"],
							desc = L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."],
							type = "toggle",
						},
						auraBlacklistModifier = {
							order = 6,
							type = "select",
							name = L["Blacklist Modifier"],
							desc = L["You need to hold this modifier down in order to blacklist an aura by right-clicking the icon. Set to None to disable the blacklist functionality."],
							values = {
								['NONE'] = NONE,
								['SHIFT'] = SHIFT_KEY,
								['ALT'] = ALT_KEY,
								['CTRL'] = CTRL_KEY,
							},
						},
						resetFilters = {
							order = 7,
							name = L["Reset Aura Filters"],
							type = "execute",
							func = function(info)
								E:StaticPopup_Show("RESET_UF_AF") --reset unitframe aurafilters
							end,
						},
						barGroup = {
							order = 20,
							type = 'group',
							guiInline = true,
							name = L["Bars"],
							args = {
								smoothbars = {
									type = 'toggle',
									order = 2,
									name = L["Smooth Bars"],
									desc = L["Bars will transition smoothly."],
									set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_AllFrames(); end,
								},
								statusbar = {
									type = "select", dialogControl = 'LSM30_Statusbar',
									order = 3,
									name = L["StatusBar Texture"],
									desc = L["Main statusbar texture."],
									values = AceGUIWidgetLSMlists.statusbar,
									set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_StatusBars() end,
								},
							},
						},
						fontGroup = {
							order = 30,
							type = 'group',
							guiInline = true,
							name = L["Fonts"],
							args = {
								font = {
									type = "select", dialogControl = 'LSM30_Font',
									order = 4,
									name = L["Default Font"],
									desc = L["The font that the unitframes will use."],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings() end,
								},
								fontSize = {
									order = 5,
									name = FONT_SIZE,
									desc = L["Set the font size for unitframes."],
									type = "range",
									min = 4, max = 212, step = 1,
									set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings() end,
								},
								fontOutline = {
									order = 6,
									name = L["Font Outline"],
									desc = L["Set the font outline."],
									type = "select",
									values = {
										['NONE'] = NONE,
										['OUTLINE'] = 'OUTLINE',
										['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
										['THICKOUTLINE'] = 'THICKOUTLINE',
									},
									set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings() end,
								},
							},
						},
					},
				},
				frameGlowGroup = {
					order = 2,
					type = 'group',
					childGroups = "tree",
					name = L["Frame Glow"],
					args = {
						mainGlow = {
							order = 1,
							type = 'group',
							guiInline = true,
							name = L["Mouseover Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.mainGlow[ info[#info] ]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.mainGlow[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.mainGlow[ info[#info] ]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.mainGlow[ info[#info] ] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames();
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.mainGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = 'toggle',
									name = L["Enable"],
									disabled = false,
								},
								spacer = {
									order = 2,
									type = "description",
									name = "",
								},
								class = {
									order = 3,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 4,
									name = COLOR,
									type = 'color',
									hasAlpha = true,
								},
							}
						},
						targetGlow = {
							order = 3,
							type = 'group',
							guiInline = true,
							name = L["Targeted Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.targetGlow[ info[#info] ]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.targetGlow[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.targetGlow[ info[#info] ]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.targetGlow[ info[#info] ] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames();
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.targetGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = 'toggle',
									name = L["Enable"],
									disabled = false,
								},
								spacer = {
									order = 2,
									type = "description",
									name = "",
								},
								class = {
									order = 3,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 4,
									name = COLOR,
									type = 'color',
									hasAlpha = true,
								},
							}
						},
						mouseoverGlow = {
							order = 5,
							type = 'group',
							guiInline = true,
							name = L["Mouseover Highlight"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[ info[#info] ]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.mouseoverGlow[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[ info[#info] ]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.mouseoverGlow[ info[#info] ] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames();
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.mouseoverGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = 'toggle',
									name = L["Enable"],
									disabled = false,
								},
								texture = {
									type = "select",
									dialogControl = 'LSM30_Statusbar',
									order = 2,
									name = L["Texture"],
									values = AceGUIWidgetLSMlists.statusbar,
									get = function(info)
										return E.db.unitframe.colors.frameGlow.mouseoverGlow[ info[#info] ]
									end,
									set = function(info, value)
										E.db.unitframe.colors.frameGlow.mouseoverGlow[ info[#info] ] = value;
										UF:FrameGlow_UpdateFrames();
									end,
								},
								spacer = {
									order = 3,
									type = "description",
									name = "",
								},
								class = {
									order = 4,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 5,
									name = COLOR,
									type = 'color',
									hasAlpha = true,
								},
							}
						},
					}
				},
				allColorsGroup = {
					order = 3,
					type = 'group',
					childGroups = "tree",
					name = COLORS,
					get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
					args = {
						header = {
							order = 0,
							type = "header",
							name = COLORS,
						},
						borderColor = {
							order = 1,
							type = "color",
							name = L["Border Color"],
							get = function(info)
								local t = E.db.unitframe.colors.borderColor
								local d = P.unitframe.colors.borderColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.borderColor
								t.r, t.g, t.b = r, g, b
								E:UpdateMedia()
								E:UpdateBorderColors()
							end,
						},
						healthGroup = {
							order = 2,
							type = 'group',
							name = HEALTH,
							get = function(info)
								local t = E.db.unitframe.colors[ info[#info] ]
								local d = P.unitframe.colors[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								healthclass = {
									order = 0,
									type = 'toggle',
									name = L["Class Health"],
									desc = L["Color health by classcolor or reaction."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								forcehealthreaction = {
									order = 1,
									type = 'toggle',
									name = L["Force Reaction Color"],
									desc = L["Forces reaction color instead of class color on units controlled by players."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
									disabled = function() return not E.db.unitframe.colors.healthclass end,
								},
								colorhealthbyvalue = {
									order = 2,
									type = 'toggle',
									name = L["Health By Value"],
									desc = L["Color health by amount remaining."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								customhealthbackdrop = {
									order = 3,
									type = 'toggle',
									name = L["Custom Health Backdrop"],
									desc = L["Use the custom health backdrop color instead of a multiple of the main health color."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								classbackdrop = {
									order = 4,
									type = 'toggle',
									name = L["Class Backdrop"],
									desc = L["Color the health backdrop by class or reaction."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								transparentHealth = {
									order = 5,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								useDeadBackdrop = {
									order = 6,
									type = "toggle",
									name = L["Use Dead Backdrop"],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								health = {
									order = 10,
									type = 'color',
									name = L["Health"],
								},
								health_backdrop = {
									order = 11,
									type = 'color',
									name = L["Health Backdrop"],
								},
								healthmultiplier = {
									order = 12,
									name = L["Health Backdrop Multiplier"],
									type = 'range',
									min = 0, max = 1, step = .01,
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								tapped = {
									order = 13,
									type = 'color',
									name = L["Tapped"],
								},
								disconnected = {
									order = 14,
									type = 'color',
									name = L["Disconnected"],
								},
								health_backdrop_dead = {
									order = 15,
									type = "color",
									name = L["Custom Dead Backdrop"],
									desc = L["Use this backdrop color for units that are dead or ghosts."],
								},
							},
						},
						powerGroup = {
							order = 3,
							type = 'group',
							name = L["Powers"],
							get = function(info)
								local t = E.db.unitframe.colors.power[ info[#info] ]
								local d = P.unitframe.colors.power[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.power[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
								NP:ConfigureAll()
							end,
							args = {
								powerclass = {
									order = 0,
									type = 'toggle',
									name = L["Class Power"],
									desc = L["Color power by classcolor or reaction."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								transparentPower = {
									order = 1,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								MANA = {
									order = 3,
									name = MANA,
									type = 'color',
								},
								RAGE = {
									order = 4,
									name = RAGE,
									type = 'color',
								},
								FOCUS = {
									order = 5,
									name = FOCUS,
									type = 'color',
								},
								ENERGY = {
									order = 6,
									name = ENERGY,
									type = 'color',
								},
								RUNIC_POWER = {
									order = 7,
									name = RUNIC_POWER,
									type = 'color',
								},
								PAIN = {
									order = 8,
									name = PAIN,
									type = 'color',
								},
								FURY = {
									order = 9,
									name = FURY,
									type = 'color',
								},
								LUNAR_POWER = {
									order = 10,
									name = LUNAR_POWER,
									type = 'color'
								},
								INSANITY = {
									order = 11,
									name = INSANITY,
									type = 'color'
								},
								MAELSTROM = {
									order = 12,
									name = MAELSTROM,
									type = 'color'
								},
							},
						},
						reactionGroup = {
							order = 4,
							type = 'group',
							name = L["Reactions"],
							get = function(info)
								local t = E.db.unitframe.colors.reaction[ info[#info] ]
								local d = P.unitframe.colors.reaction[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.reaction[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								BAD = {
									order = 1,
									name = L["Bad"],
									type = 'color',
								},
								NEUTRAL = {
									order = 2,
									name = L["Neutral"],
									type = 'color',
								},
								GOOD = {
									order = 3,
									name = L["Good"],
									type = 'color',
								},
							},
						},
						castBars = {
							order = 6,
							type = 'group',
							name = L["Castbar"],
							get = function(info)
								local t = E.db.unitframe.colors[ info[#info] ]
								local d = P.unitframe.colors[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								castClassColor = {
									order = 0,
									type = 'toggle',
									name = L["Class Castbars"],
									desc = L["Color castbars by the class of player units."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								castReactionColor = {
									order = 0,
									type = 'toggle',
									name = L["Reaction Castbars"],
									desc = L["Color castbars by the reaction type of non-player units."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								transparentCastbar = {
									order = 2,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								castColor = {
									order = 3,
									name = L["Interruptable"],
									type = 'color',
								},
								castNoInterrupt = {
									order = 4,
									name = L["Non-Interruptable"],
									type = 'color',
								},
							},
						},
						auraBars = {
							order = 7,
							type = 'group',
							name = L["Aura Bars"],
							args = {
								transparentAurabars = {
									order = 0,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								},
								auraBarByType = {
									order = 1,
									name = L["By Type"],
									desc = L["Color aurabar debuffs by type."],
									type = 'toggle',
								},
								auraBarTurtle = {
									order = 2,
									name = L["Color Turtle Buffs"],
									desc = L["Color all buffs that reduce the unit's incoming damage."],
									type = 'toggle',
								},
								BUFFS = {
									order = 10,
									name = L["Buffs"],
									type = 'color',
									get = function(info)
										local t = E.db.unitframe.colors.auraBarBuff
										local d = P.unitframe.colors.auraBarBuff
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										if E:CheckClassColor(r, g, b) then
											local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
											r = classColor.r
											g = classColor.g
											b = classColor.b
										end

										local t = E.db.unitframe.colors.auraBarBuff
										t.r, t.g, t.b = r, g, b

										UF:Update_AllFrames()
									end,
								},
								DEBUFFS = {
									order = 11,
									name = L["Debuffs"],
									type = 'color',
									get = function(info)
										local t = E.db.unitframe.colors.auraBarDebuff
										local d = P.unitframe.colors.auraBarDebuff
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors.auraBarDebuff
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,
								},
								auraBarTurtleColor = {
									order = 12,
									name = L["Turtle Color"],
									type = 'color',
									get = function(info)
										local t = E.db.unitframe.colors.auraBarTurtleColor
										local d = P.unitframe.colors.auraBarTurtleColor
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors.auraBarTurtleColor
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,
								},
							},
						},
						healPrediction = {
							order = 8,
							name = L["Heal Prediction"],
							type = 'group',
							get = function(info)
								local t = E.db.unitframe.colors.healPrediction[ info[#info] ]
								local d = P.unitframe.colors.healPrediction[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.healPrediction[ info[#info] ]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								personal = {
									order = 1,
									name = L["Personal"],
									type = 'color',
									hasAlpha = true,
								},
								others = {
									order = 2,
									name = L["Others"],
									type = 'color',
									hasAlpha = true,
								},
								absorbs = {
									order = 2,
									name = L["Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								healAbsorbs = {
									order = 3,
									name = L["Heal Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								overabsorbs = {
									order = 4,
									name = L["Over Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								overhealabsorbs = {
									order = 4,
									name = L["Over Heal Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								maxOverflow = {
									order = 6,
									type = "range",
									name = L["Max Overflow"],
									desc = L["Max amount of overflow allowed to extend past the end of the health bar."],
									isPercent = true,
									min = 0, max = 1, step = 0.01,
									get = function(info) return E.db.unitframe.colors.healPrediction.maxOverflow end,
									set = function(info, value) E.db.unitframe.colors.healPrediction.maxOverflow = value; UF:Update_AllFrames() end,
								},
							},
						},
						debuffHighlight = {
							order = 9,
							name = L["Debuff Highlighting"],
							type = 'group',
							get = function(info)
								local t = E.db.unitframe.colors.debuffHighlight[ info[#info] ]
								local d = P.unitframe.colors.debuffHighlight[ info[#info] ]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.debuffHighlight[ info[#info] ]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								Magic = {
									order = 1,
									name = ENCOUNTER_JOURNAL_SECTION_FLAG7,--Magic Effect
									type = 'color',
									hasAlpha = true,
								},
								Curse = {
									order = 2,
									name = ENCOUNTER_JOURNAL_SECTION_FLAG8,--Curse Effect
									type = 'color',
									hasAlpha = true,
								},
								Disease = {
									order = 3,
									name = ENCOUNTER_JOURNAL_SECTION_FLAG10,--Disease Effect
									type = 'color',
									hasAlpha = true,
								},
								Poison = {
									order = 4,
									name = ENCOUNTER_JOURNAL_SECTION_FLAG9,--Poison Effect
									type = 'color',
									hasAlpha = true,
								},
							},
						},
					},
				},
				disabledBlizzardFrames = {
					order = 4,
					type = "group",
					name = L["Disabled Blizzard Frames"],
					get = function(info) return E.private.unitframe.disabledBlizzardFrames[ info[#info] ] end,
					set = function(info, value) E.private.unitframe.disabledBlizzardFrames[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
					args = {
						header = {
							order = 0,
							type = "header",
							name = L["Disabled Blizzard Frames"],
						},
						player = {
							order = 1,
							type = 'toggle',
							name = L["Player Frame"],
							desc = L["Disables the player and pet unitframes."],
						},
						target = {
							order = 2,
							type = 'toggle',
							name = L["Target Frame"],
							desc = L["Disables the target and target of target unitframes."],
						},
						focus = {
							order = 3,
							type = 'toggle',
							name = L["Focus Frame"],
							desc = L["Disables the focus and target of focus unitframes."],
						},
						boss = {
							order = 4,
							type = 'toggle',
							name = L["Boss Frames"],
						},
						arena = {
							order = 5,
							type = 'toggle',
							name = L["Arena Frames"],
						},
						party = {
							order = 6,
							type = 'toggle',
							name = L["Party Frames"],
						},
						raid = {
							order = 7,
							type = 'toggle',
							name = L["Raid Frames"],
						},
					},
				},
				raidDebuffIndicator = {
					order = 5,
					type = "group",
					name = L["RaidDebuff Indicator"],
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["RaidDebuff Indicator"],
						},
						instanceFilter = {
							order = 2,
							type = "select",
							name = L["Dungeon & Raid Filter"],
							values = function()
								local filters = {}
								local list = E.global.unitframe.aurafilters
								if not list then return end
								for filter in pairs(list) do
									filters[filter] = filter
								end

								return filters
							end,
							get = function(info) return E.global.unitframe.raidDebuffIndicator.instanceFilter end,
							set = function(info, value) E.global.unitframe.raidDebuffIndicator.instanceFilter = value; UF:UpdateAllHeaders() end,
						},
						otherFilter = {
							order = 3,
							type = "select",
							name = L["Other Filter"],
							values = function()
								local filters = {}
								local list = E.global.unitframe.aurafilters
								if not list then return end
								for filter in pairs(list) do
									filters[filter] = filter
								end

								return filters
							end,
							get = function(info) return E.global.unitframe.raidDebuffIndicator.otherFilter end,
							set = function(info, value) E.global.unitframe.raidDebuffIndicator.otherFilter = value; UF:UpdateAllHeaders() end,
						},
					},
				},
			},
		},
	},
}

--Player
E.Options.args.unitframe.args.player = {
	name = L["Player Frame"],
	type = 'group',
	order = 300,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.player[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.player[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
					set = function(info, value)
						E.db.unitframe.units.player[ info[#info] ] = value;
						UF:CreateAndUpdateUF('player');
						if value == true and E.db.unitframe.units.player.combatfade then
							ElvUF_Pet:SetParent(ElvUF_Player)
						else
							ElvUF_Pet:SetParent(ElvUF_Parent)
						end
					end,
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'player'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Player Frame"], nil, {unit='player', mover='Player Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_Player
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('player')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
					set = function(info, value)
						if E.db.unitframe.units.player.castbar.width == E.db.unitframe.units.player[ info[#info] ] then
							E.db.unitframe.units.player.castbar.width = value;
						end

						E.db.unitframe.units.player[ info[#info] ] = value;
						UF:CreateAndUpdateUF('player');
					end,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				combatfade = {
					order = 8,
					name = L["Combat Fade"],
					desc = L["Fade the unitframe when out of combat, not casting, no target exists."],
					type = 'toggle',
					set = function(info, value)
						E.db.unitframe.units.player[ info[#info] ] = value;
						UF:CreateAndUpdateUF('player');
						if value == true and E.db.unitframe.units.player.enable then
							ElvUF_Pet:SetParent(ElvUF_Player)
						else
							ElvUF_Pet:SetParent(ElvUF_Parent)
						end
					end,
				},
				hideonnpc = {
					type = 'toggle',
					order = 10,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.player.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.player.power.hideonnpc = value; UF:CreateAndUpdateUF('player') end,
				},
				threatStyle = {
					type = 'select',
					order = 11,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 12,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 13,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 14,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				spacer = {
					order = 15,
					type = "description",
					name = "",
				},
				disableMouseoverGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 17,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'player'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'player'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'player'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'player'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'player', nil, true),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'player'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'player'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'player'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'player'),
		castbar = GetOptionsTable_Castbar(true, UF.CreateAndUpdateUF, 'player'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'player'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'player'),
		classbar = {
			order = 1000,
			type = 'group',
			name = L["Classbar"],
			get = function(info) return E.db.unitframe.units.player.classbar[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.player.classbar[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Classbar"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				height = {
					type = 'range',
					order = 3,
					name = L["Height"],
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7),
					max = (E.db.unitframe.units.player.classbar.detachFromFrame and 300 or 30),
					step = 1,
				},
				fill = {
					type = 'select',
					order = 4,
					name = L["Fill"],
					values = {
						['fill'] = L["Filled"],
						['spaced'] = L["Spaced"],
					},
				},
				autoHide = {
					order = 5,
					type = 'toggle',
					name = L["Auto-Hide"],
				},
				additionalPowerText = {
					order = 6,
					type = "toggle",
					name = L["Additional Power Text"],
				},
				spacer = {
					order = 10,
					type = "description",
					name = "",
				},
				detachGroup = {
					order = 20,
					type = "group",
					name = L["Detach From Frame"],
					get = function(info) return E.db.unitframe.units.player.classbar[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.units.player.classbar[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
					guiInline = true,
					args = {
						detachFromFrame = {
							type = 'toggle',
							order = 1,
							name = ENABLE,
							width = 'full',
							set = function(info, value)
								if value == true then
									E.Options.args.unitframe.args.player.args.classbar.args.height.max = 300
								else
									E.Options.args.unitframe.args.player.args.classbar.args.height.max = 30
								end
								E.db.unitframe.units.player.classbar[ info[#info] ] = value;
								UF:CreateAndUpdateUF('player')
							end,
						},
						detachedWidth = {
							type = 'range',
							order = 2,
							name = L["Detached Width"],
							disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
							min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 800, step = 1,
						},
						orientation = {
							type = 'select',
							order = 3,
							name = L["Frame Orientation"],
							disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
							values = {
								['HORIZONTAL'] = L["Horizontal"],
								['VERTICAL'] = L["Vertical"],
							},
						},
						verticalOrientation = {
							order = 4,
							type = "toggle",
							name = L["Vertical Fill Direction"],
							disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
						},
						spacing = {
							order = 5,
							type = "range",
							name = L["Spacing"],
							min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 20, step = 1,
							disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
						},
						parent = {
							type = 'select',
							order = 6,
							name = L["Parent"],
							desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
							disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
							values = {
								["FRAME"] = "FRAME",
								["UIPARENT"] = "UIPARENT",
							},
						},
						strataAndLevel = {
							order = 10,
							type = "group",
							name = L["Strata and Level"],
							get = function(info) return E.db.unitframe.units.player.classbar.strataAndLevel[ info[#info] ] end,
							set = function(info, value) E.db.unitframe.units.player.classbar.strataAndLevel[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
							guiInline = true,
							disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
							hidden = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
							args = {
								useCustomStrata = {
									order = 1,
									type = "toggle",
									name = L["Use Custom Strata"],
								},
								frameStrata = {
									order = 2,
									type = "select",
									name = L["Frame Strata"],
									values = {
										["BACKGROUND"] = "BACKGROUND",
										["LOW"] = "LOW",
										["MEDIUM"] = "MEDIUM",
										["HIGH"] = "HIGH",
										["DIALOG"] = "DIALOG",
										["TOOLTIP"] = "TOOLTIP",
									},
								},
								spacer = {
									order = 3,
									type = "description",
									name = "",
								},
								useCustomLevel = {
									order = 4,
									type = "toggle",
									name = L["Use Custom Level"],
								},
								frameLevel = {
									order = 5,
									type = "range",
									name = L["Frame Level"],
									min = 2, max = 128, step = 1,
								},
							},
						},
					},
				},
			},
		},
		RestIcon = {
			order = 430,
			type = 'group',
			name = L["Rest Icon"],
			get = function(info) return E.db.unitframe.units.player.RestIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.player.RestIcon[ info[#info] ] = value; UF:CreateAndUpdateUF('player'); UF:TestingDisplay_RestingIndicator(ElvUF_Player); end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Rest Icon"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				defaultColor = {
					order = 3,
					type = "toggle",
					name = L["Default Color"],
				},
				color = {
					order = 4,
					type = "color",
					name = COLOR,
					hasAlpha = true,
					disabled = function()
						return E.db.unitframe.units.player.RestIcon.defaultColor
					end,
					get = function()
						local c = E.db.unitframe.units.player.RestIcon.color
						local d = P.unitframe.units.player.RestIcon.color
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
					end,
					set = function(_, r, g, b, a)
						local c = E.db.unitframe.units.player.RestIcon.color
						c.r, c.g, c.b, c.a = r, g, b, a
						UF:CreateAndUpdateUF('player');
						UF:TestingDisplay_RestingIndicator(ElvUF_Player);
					end,
				},
				size = {
					order = 5,
					type = "range",
					name = L["Size"],
					min = 10, max = 60, step = 1,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
				spacer2 = {
					order = 8,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 9,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				texture = {
					order = 10,
					type = "select",
					sortByValue = true,
					name = L["Texture"],
					values = {
						["CUSTOM"] = CUSTOM,
						["DEFAULT"] = DEFAULT,
						["RESTING"] = [[|TInterface\AddOns\ElvUI\media\textures\resting:14|t]],
						["RESTING1"] = [[|TInterface\AddOns\ElvUI\media\textures\resting1:14|t]],
					},
				},
				customTexture = {
					type = 'input',
					order = 11,
					customWidth = 250,
					name = L["Custom Texture"],
					disabled = function()
						return E.db.unitframe.units.player.RestIcon.texture ~= "CUSTOM"
					end,
					set = function(_, value)
						E.db.unitframe.units.player.RestIcon.customTexture = (value and (not value:match("^%s-$")) and value) or nil
						UF:CreateAndUpdateUF('player');
						UF:TestingDisplay_RestingIndicator(ElvUF_Player);
					end
				},
			},
		},
		CombatIcon = {
			order = 440,
			type = 'group',
			name = L["Combat Icon"],
			get = function(info) return E.db.unitframe.units.player.CombatIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.player.CombatIcon[ info[#info] ] = value; UF:CreateAndUpdateUF('player'); UF:TestingDisplay_CombatIndicator(ElvUF_Player); end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Combat Icon"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				defaultColor = {
					order = 3,
					type = "toggle",
					name = L["Default Color"],
				},
				color = {
					order = 4,
					type = "color",
					name = COLOR,
					hasAlpha = true,
					disabled = function()
						return E.db.unitframe.units.player.CombatIcon.defaultColor
					end,
					get = function()
						local c = E.db.unitframe.units.player.CombatIcon.color
						local d = P.unitframe.units.player.CombatIcon.color
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
					end,
					set = function(_, r, g, b, a)
						local c = E.db.unitframe.units.player.CombatIcon.color
						c.r, c.g, c.b, c.a = r, g, b, a
						UF:CreateAndUpdateUF('player');
						UF:TestingDisplay_CombatIndicator(ElvUF_Player);
					end,
				},
				size = {
					order = 5,
					type = "range",
					name = L["Size"],
					min = 10, max = 60, step = 1,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
				spacer2 = {
					order = 8,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 9,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				texture = {
					order = 10,
					type = "select",
					sortByValue = true,
					name = L["Texture"],
					values = {
						["CUSTOM"] = CUSTOM,
						["DEFAULT"] = DEFAULT,
						["COMBAT"] = [[|TInterface\AddOns\ElvUI\media\textures\combat:14|t]],
						["PLATINUM"] = [[|TInterface\Challenges\ChallengeMode_Medal_Platinum:14|t]],
						["ATTACK"] = [[|TInterface\CURSOR\Attack:14|t]],
						["ALERT"] = [[|TInterface\DialogFrame\UI-Dialog-Icon-AlertNew:14|t]],
						["ALERT2"] = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14|t]],
						["ARTHAS"] =[[|TInterface\LFGFRAME\UI-LFR-PORTRAIT:14|t]],
						["SKULL"] = [[|TInterface\LootFrame\LootPanel-Icon:14|t]],
					},
				},
				customTexture = {
					type = 'input',
					order = 11,
					customWidth = 250,
					name = L["Custom Texture"],
					disabled = function()
						return E.db.unitframe.units.player.CombatIcon.texture ~= "CUSTOM"
					end,
					set = function(_, value)
						E.db.unitframe.units.player.CombatIcon.customTexture = (value and (not value:match("^%s-$")) and value) or nil
						UF:CreateAndUpdateUF('player');
						UF:TestingDisplay_CombatIndicator(ElvUF_Player);
					end
				},
			},
		},
		pvpIcon = {
			order = 450,
			type = 'group',
			name = L["PvP & Prestige Icon"],
			get = function(info) return E.db.unitframe.units.player.pvpIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.player.pvpIcon[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["PvP & Prestige Icon"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.1, max = 2, step = 0.01,
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
			},
		},
		pvpText = {
			order = 460,
			type = 'group',
			name = L["PvP Text"],
			get = function(info) return E.db.unitframe.units.player.pvp[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.player.pvp[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name =L["PvP Text"],
				},
				position = {
					type = 'select',
					order = 2,
					name = L["Position"],
					values = positionValues,
				},
				text_format = {
					order = 100,
					name = L["Text Format"],
					type = 'input',
					width = 'full',
					desc = L["TEXT_FORMAT_DESC"],
				},
			},
		},
		raidRoleIcons = {
			order = 703,
			type = 'group',
			name = L["RL Icon"],
			get = function(info) return E.db.unitframe.units.player.raidRoleIcons[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.player.raidRoleIcons[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["RL Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = {
						['TOPLEFT'] = 'TOPLEFT',
						['TOPRIGHT'] = 'TOPRIGHT',
					},
				},
			},
		},
	},
}

--Target
E.Options.args.unitframe.args.target = {
	name = L["Target Frame"],
	type = 'group',
	order = 400,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.target[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.target[ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'target'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Target Frame"], nil, {unit='target', mover='Target Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_Target
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('target')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
					set = function(info, value)
						if E.db.unitframe.units.target.castbar.width == E.db.unitframe.units.target[ info[#info] ] then
							E.db.unitframe.units.target.castbar.width = value;
						end

						E.db.unitframe.units.target[ info[#info] ] = value;
						UF:CreateAndUpdateUF('target');
					end,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 10,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.target.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.target.power.hideonnpc = value; UF:CreateAndUpdateUF('target') end,
				},
				middleClickFocus = {
					order = 11,
					name = L["Middle Click - Set Focus"],
					desc = L["Middle clicking the unit frame will cause your focus to match the unit."],
					type = 'toggle',
					disabled = function() return IsAddOnLoaded("Clique") end,
				},
				threatStyle = {
					type = 'select',
					order = 12,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 13,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 14,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 15,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				disableMouseoverGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 17,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'target'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'target'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'target'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'target'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'target', nil, true),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'target'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'target'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'target'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'target'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'target'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'target'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'target'),
		pvpIcon = {
			order = 449,
			type = 'group',
			name = L["PvP & Prestige Icon"],
			get = function(info) return E.db.unitframe.units.target.pvpIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.target.pvpIcon[ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["PvP & Prestige Icon"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.1, max = 2, step = 0.01,
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
			},
		},
		phaseIndicator = {
			order = 450,
			type = 'group',
			name = L["Phase Indicator"],
			get = function(info) return E.db.unitframe.units.target.phaseIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.target.phaseIndicator[ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Phase Indicator"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.5, max = 1.5, step = 0.01,
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
			},
		},
	},
}

--TargetTarget
E.Options.args.unitframe.args.targettarget = {
	name = L["TargetTarget Frame"],
	type = 'group',
	order = 500,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.targettarget[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.targettarget[ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'targettarget'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["TargetTarget Frame"], nil, {unit='targettarget', mover='TargetTarget Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_TargetTarget
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('targettarget')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 9,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.targettarget.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.targettarget.power.hideonnpc = value; UF:CreateAndUpdateUF('targettarget') end,
				},
				threatStyle = {
					type = 'select',
					order = 10,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 11,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = {
						["DISABLED"] = DISABLE,
						["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
						["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"],
					},
				},
				orientation = {
					order = 12,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 13,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				spacer = {
					order = 14,
					type = "description",
					name = "",
				},
				disableMouseoverGlow = {
					order = 15,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'targettarget'),
		power = GetOptionsTable_Power(nil, UF.CreateAndUpdateUF, 'targettarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'targettarget'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'targettarget'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'targettarget'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettarget'),
	},
}

--TargetTargetTarget
E.Options.args.unitframe.args.targettargettarget = {
	name = L["TargetTargetTarget Frame"],
	type = 'group',
	order = 500,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.targettargettarget[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.targettargettarget[ info[#info] ] = value; UF:CreateAndUpdateUF('targettargettarget') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'targettargettarget'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["TargetTargetTarget Frame"], nil, {unit='targettargettarget', mover='TargetTargetTarget Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_TargetTargetTarget
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('targettargettarget')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 9,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.targettargettarget.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.targettargettarget.power.hideonnpc = value; UF:CreateAndUpdateUF('targettargettarget') end,
				},
				threatStyle = {
					type = 'select',
					order = 10,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 11,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 12,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 13,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				spacer = {
					order = 14,
					type = "description",
					name = "",
				},
				disableMouseoverGlow = {
					order = 15,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettargettarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettargettarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'targettargettarget'),
		power = GetOptionsTable_Power(nil, UF.CreateAndUpdateUF, 'targettargettarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettargettarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'targettargettarget'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'targettargettarget'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'targettargettarget'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettargettarget'),
	},
}

--Focus
E.Options.args.unitframe.args.focus = {
	name = L["Focus Frame"],
	type = 'group',
	order = 600,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.focus[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.focus[ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'focus'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Focus Frame"], nil, {unit='focus', mover='Focus Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_Focus
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('focus')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 10,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.focus.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.focus.power.hideonnpc = value; UF:CreateAndUpdateUF('focus') end,
				},
				threatStyle = {
					type = 'select',
					order = 11,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 12,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 13,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 14,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				disableMouseoverGlow = {
					order = 15,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'focus'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focus'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focus'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'focus'),
		power = GetOptionsTable_Power(nil, UF.CreateAndUpdateUF, 'focus'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focus'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'focus'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'focus'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'focus'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'focus'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'focus'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focus'),
	},
}

--Focus Target
E.Options.args.unitframe.args.focustarget = {
	name = L["FocusTarget Frame"],
	type = 'group',
	order = 700,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.focustarget[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.focustarget[ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'focustarget'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["FocusTarget Frame"], nil, {unit='focustarget', mover='FocusTarget Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_FocusTarget
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('focustarget')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 9,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.focustarget.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.focustarget.power.hideonnpc = value; UF:CreateAndUpdateUF('focustarget') end,
				},
				threatStyle = {
					type = 'select',
					order = 10,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 11,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 12,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 13,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				spacer = {
					order = 14,
					type = "description",
					name = "",
				},
				disableMouseoverGlow = {
					order = 15,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focustarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focustarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'focustarget'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUF, 'focustarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focustarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'focustarget'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'focustarget'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'focustarget'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focustarget'),
	},
}

--Pet
E.Options.args.unitframe.args.pet = {
	name = L["Pet Frame"],
	type = 'group',
	order = 800,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.pet[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.pet[ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'pet'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Pet Frame"], nil, {unit='pet', mover='Pet Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_Pet
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('pet')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 10,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.pet.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.pet.power.hideonnpc = value; UF:CreateAndUpdateUF('pet') end,
				},
				threatStyle = {
					type = 'select',
					order = 11,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 12,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 13,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 14,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				disableMouseoverGlow = {
					order = 15,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		buffIndicator = {
			order = 600,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.pet.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.pet.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Buff Indicator"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
			},
		},
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'pet'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pet'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pet'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'pet'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUF, 'pet'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pet'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'pet'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'pet'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'pet'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'pet'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'pet'),
	},
}

--Pet Target
E.Options.args.unitframe.args.pettarget = {
	name = L["PetTarget Frame"],
	type = 'group',
	order = 900,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.pettarget[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.pettarget[ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = UF.units,
					set = function(info, value) UF:MergeUnitSettings(value, 'pettarget'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["PetTarget Frame"], nil, {unit='pettarget', mover='PetTarget Frame'}) end,
				},
				showAuras = {
					order = 5,
					type = 'execute',
					name = L["Show Auras"],
					func = function()
						local frame = ElvUF_PetTarget
						if frame.forceShowAuras then
							frame.forceShowAuras = nil;
						else
							frame.forceShowAuras = true;
						end

						UF:CreateAndUpdateUF('pettarget')
					end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 9,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.pettarget.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.pettarget.power.hideonnpc = value; UF:CreateAndUpdateUF('pettarget') end,
				},
				threatStyle = {
					type = 'select',
					order = 10,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 11,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 12,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 13,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				spacer = {
					order = 14,
					type = "description",
					name = "",
				},
				disableMouseoverGlow = {
					order = 15,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pettarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pettarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'pettarget'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUF, 'pettarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pettarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'pettarget'),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUF, 'pettarget'),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUF, 'pettarget'),
	},
}

--Boss Frames
E.Options.args.unitframe.args.boss = {
	name = L["Boss Frames"],
	type = 'group',
	order = 1000,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.boss[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.boss[ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = {
						['boss'] = 'boss',
						['arena'] = 'arena',
					},
					set = function(info, value) UF:MergeUnitSettings(value, 'boss'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Boss Frames"], nil, {unit='boss', mover='Boss Frames'}) end,
				},
				displayFrames = {
					type = 'execute',
					order = 5,
					name = L["Display Frames"],
					desc = L["Force the frames to show, they will act as if they are the player frame."],
					func = function() UF:ToggleForceShowGroupFrames('boss', MAX_BOSS_FRAMES) end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
					set = function(info, value)
						if E.db.unitframe.units.boss.castbar.width == E.db.unitframe.units.boss[ info[#info] ] then
							E.db.unitframe.units.boss.castbar.width = value;
						end

						E.db.unitframe.units.boss[ info[#info] ] = value;
						UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES);
					end,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 9,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.boss.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.boss.power.hideonnpc = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
				},
				growthDirection = {
					order = 10,
					type = "select",
					name = L["Growth Direction"],
					values = {
						["UP"] = L["Bottom to Top"],
						["DOWN"] = L["Top to Bottom"],
						["LEFT"] = L["Right to Left"],
						["RIGHT"] = L["Left to Right"],
					},
				},
				spacing = {
					order = 11,
					type = "range",
					name = L["Spacing"],
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 400, step = 1,
				},
				threatStyle = {
					type = 'select',
					order = 12,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				smartAuraPosition = {
					order = 13,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 14,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 15,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				disableMouseoverGlow = {
					order = 16,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 17,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
	},
}

--Arena Frames
E.Options.args.unitframe.args.arena = {
	name = L["Arena Frames"],
	type = 'group',
	order = 1000,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.arena[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.arena[ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		generalGroup = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					width = "full",
				},
				copyFrom = {
					type = 'select',
					order = 3,
					name = L["Copy From"],
					desc = L["Select a unit to copy settings from."],
					values = {
						['boss'] = 'boss',
						['arena'] = 'arena',
					},
					set = function(info, value) UF:MergeUnitSettings(value, 'arena'); end,
				},
				resetSettings = {
					type = 'execute',
					order = 4,
					name = L["Restore Defaults"],
					func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Arena Frames"], nil, {unit='arena', mover='Arena Frames'}) end,
				},
				displayFrames = {
					type = 'execute',
					order = 5,
					name = L["Display Frames"],
					desc = L["Force the frames to show, they will act as if they are the player frame."],
					func = function() UF:ToggleForceShowGroupFrames('arena', 5) end,
				},
				width = {
					order = 6,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
					set = function(info, value)
						if E.db.unitframe.units.arena.castbar.width == E.db.unitframe.units.arena[ info[#info] ] then
							E.db.unitframe.units.arena.castbar.width = value;
						end

						E.db.unitframe.units.arena[ info[#info] ] = value;
						UF:CreateAndUpdateUFGroup('arena', 5);
					end,
				},
				height = {
					order = 7,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				rangeCheck = {
					order = 8,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				hideonnpc = {
					type = 'toggle',
					order = 10,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.arena.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.arena.power.hideonnpc = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
				},
				pvpSpecIcon = {
					order = 11,
					name = L["Spec Icon"],
					desc = L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."],
					type = 'toggle',
				},
				growthDirection = {
					order = 12,
					type = "select",
					name = L["Growth Direction"],
					values = {
						["UP"] = L["Bottom to Top"],
						["DOWN"] = L["Top to Bottom"],
						["LEFT"] = L["Right to Left"],
						["RIGHT"] = L["Left to Right"],
					},
				},
				spacing = {
					order = 13,
					type = "range",
					name = L["Spacing"],
					min = 0, max = 400, step = 1,
				},
				colorOverride = {
					order = 14,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				smartAuraPosition = {
					order = 15,
					type = "select",
					name = L["Smart Aura Position"],
					desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
					values = smartAuraPositionValues,
				},
				orientation = {
					order = 16,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						--["MIDDLE"] = L["Middle"], --no way to handle this with trinket
						["RIGHT"] = L["Right"],
					},
				},
				spacer = {
					order = 17,
					type = "description",
					name = "",
				},
				disableMouseoverGlow = {
					order = 18,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 19,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		pvpTrinket = {
			order = 4001,
			type = 'group',
			name = L["PVP Trinket"],
			get = function(info) return E.db.unitframe.units.arena.pvpTrinket[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.arena.pvpTrinket[ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["PVP Trinket"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = {
						['LEFT'] = L["Left"],
						['RIGHT'] = L["Right"],
					},
				},
				size = {
					order = 4,
					type = 'range',
					name = L["Size"],
					min = 10, max = 60, step = 1,
				},
				xOffset = {
					order = 5,
					type = 'range',
					name = L["xOffset"],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["yOffset"],
					min = -60, max = 60, step = 1,
				},
			},
		},
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUFGroup, 'arena', 5),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'arena', 5),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, 'arena', 5),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'arena', 5),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'arena', 5),
		buffs = GetOptionsTable_Auras('buffs', false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		debuffs = GetOptionsTable_Auras('debuffs', false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
	},
}

--Party Frames
E.Options.args.unitframe.args.party = {
	name = L["Party Frames"],
	type = 'group',
	order = 1100,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.party[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.party[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		configureToggle = {
			order = 1,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Party, ElvUF_Party.forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Party Frames"], nil, {unit='party', mover='Party Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 3,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				['raid'] = L["Raid Frames"],
				['raid40'] = L["Raid40 Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'party', true); end,
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'party'),
		generalGroup = {
			order = 5,
			type = 'group',
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				hideonnpc = {
					type = 'toggle',
					order = 3,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.party.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.party.power.hideonnpc = value; UF:CreateAndUpdateHeaderGroup('party'); end,
				},
				rangeCheck = {
					order = 4,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				threatStyle = {
					type = 'select',
					order = 6,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				colorOverride = {
					order = 7,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				orientation = {
					order = 8,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				disableMouseoverGlow = {
					order = 9,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 10,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.party[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party', nil, nil, true) end,
					args = {
						width = {
							order = 1,
							name = L["Width"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.party[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
						},
						height = {
							order = 2,
							name = L["Height"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.party[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
						},
						spacer = {
							order = 3,
							name = '',
							type = 'description',
							width = 'full',
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = 'select',
							values = growthDirectionValues,
						},
						numGroups = {
							order = 7,
							type = 'range',
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
								set = function(info, value)
									E.db.unitframe.units.party[ info[#info] ] = value;
									UF:CreateAndUpdateHeaderGroup('party')
									if ElvUF_Party.isForced then
										UF:HeaderConfig(ElvUF_Party)
										UF:HeaderConfig(ElvUF_Party, true)
									end
								end,
						},
						groupsPerRowCol = {
							order = 8,
							type = 'range',
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units.party[ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup('party')
								if ElvUF_Party.isForced then
									UF:HeaderConfig(ElvUF_Party)
									UF:HeaderConfig(ElvUF_Party, true)
								end
							end,
						},
						horizontalSpacing = {
							order = 9,
							type = 'range',
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1,
						},
						verticalSpacing = {
							order = 10,
							type = 'range',
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1,
						},
						groupSpacing = {
							order = 11,
							type = "range",
							name = L["Group Spacing"],
							desc = L["Additional spacing between each individual group."],
							min = 0, softMax = 50, step = 1,
						},
					},
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.party[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party', nil, nil, true) end,
					args = {
						showPlayer = {
							order = 1,
							type = 'toggle',
							name = L["Display Player"],
							desc = L["When true, the header includes the player when not in a raid."],
						},
						visibility = {
							order = 2,
							type = 'input',
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = 'full',
						},
					},
				},
				sortingGroup = {
					order = 300,
					type = 'group',
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units.party[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party', nil, nil, true) end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = 'select',
							values = {
								['CLASS'] = CLASS,
								['CLASSROLE'] = CLASS..' & '..ROLE,
								['ROLE'] = ROLE,
								['NAME'] = NAME,
								['MTMA'] = L["Main Tanks / Main Assist"],
								['GROUP'] = GROUP,
							},
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = 'select',
							values = {
								['ASC'] = L["Ascending"],
								['DESC'] = L["Descending"]
							},
						},
						spacer = {
							order = 3,
							type = 'description',
							width = 'full',
							name = ' '
						},
						raidWideSorting = {
							order = 4,
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
							type = 'toggle',
						},
						invertGroupingOrder = {
							order = 5,
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units.party.raidWideSorting end,
							type = 'toggle',
						},
						startFromCenter = {
							order = 6,
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units.party.raidWideSorting end,
							type = 'toggle',
						},
					},
				},
			},
		},
		buffIndicator = {
			order = 701,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.party.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.party.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Buff Indicator"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
				profileSpecific = {
					type = 'toggle',
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = 'execute',
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units.party.buffIndicator.profileSpecific then
							E:SetToFilterConfig('Buff Indicator (Profile)')
						else
							E:SetToFilterConfig('Buff Indicator')
						end
					end,
					order = 6
				},
			},
		},
		roleIcon = {
			order = 702,
			type = 'group',
			name = L["Role Icon"],
			get = function(info) return E.db.unitframe.units.party.roleIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.party.roleIcon[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Role Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = positionValues,
				},
				attachTo = {
					type = 'select',
					order = 4,
					name = L["Attach To"],
					values = attachToValues,
				},
				xOffset = {
					order = 5,
					type = 'range',
					name = L["xOffset"],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["yOffset"],
					min = -300, max = 300, step = 1,
				},
				size = {
					type = 'range',
					order = 7,
					name = L["Size"],
					min = 4, max = 100, step = 1,
				},
				tank = {
					order = 8,
					type = "toggle",
					name = L["Show For Tanks"],
				},
				healer = {
					order = 9,
					type = "toggle",
					name = L["Show For Healers"],
				},
				damager = {
					order = 10,
					type = "toggle",
					name = L["Show For DPS"],
				},
				combatHide = {
					order = 11,
					type = "toggle",
					name = L["Hide In Combat"],
				},
			},
		},
		raidRoleIcons = {
			order = 703,
			type = 'group',
			name = L["RL Icon"],
			get = function(info) return E.db.unitframe.units.party.raidRoleIcons[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.party.raidRoleIcons[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["RL Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = {
						['TOPLEFT'] = 'TOPLEFT',
						['TOPRIGHT'] = 'TOPRIGHT',
					},
				},
			},
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'party'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'party'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'party'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'party'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'party'),
		buffs = GetOptionsTable_Auras('buffs', true, UF.CreateAndUpdateHeaderGroup, 'party'),
		debuffs = GetOptionsTable_Auras('debuffs', true, UF.CreateAndUpdateHeaderGroup, 'party'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'party'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateHeaderGroup, 'party', 5),
		petsGroup = {
			order = 850,
			type = 'group',
			name = L["Party Pets"],
			get = function(info) return E.db.unitframe.units.party.petsGroup[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.party.petsGroup[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Party Pets"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				width = {
					order = 3,
					name = L["Width"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 4,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				name = {
					order = 8,
					type = 'group',
					guiInline = true,
					get = function(info) return E.db.unitframe.units.party.petsGroup.name[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.units.party.petsGroup.name[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
					name = L["Name"],
					args = {
						position = {
							type = 'select',
							order = 1,
							name = L["Text Position"],
							values = positionValues,
						},
						xOffset = {
							order = 2,
							type = 'range',
							name = L["Text xOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1,
						},
						yOffset = {
							order = 3,
							type = 'range',
							name = L["Text yOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1,
						},
						text_format = {
							order = 100,
							name = L["Text Format"],
							type = 'input',
							width = 'full',
							desc = L["TEXT_FORMAT_DESC"],
						},
					},
				},
			},
		},
		targetsGroup = {
			order = 900,
			type = 'group',
			name = L["Party Targets"],
			get = function(info) return E.db.unitframe.units.party.targetsGroup[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.party.targetsGroup[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Party Targets"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				width = {
					order = 3,
					name = L["Width"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 4,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				name = {
					order = 8,
					type = 'group',
					guiInline = true,
					get = function(info) return E.db.unitframe.units.party.targetsGroup.name[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.units.party.targetsGroup.name[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
					name = L["Name"],
					args = {
						position = {
							type = 'select',
							order = 1,
							name = L["Text Position"],
							values = positionValues,
						},
						xOffset = {
							order = 2,
							type = 'range',
							name = L["Text xOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1,
						},
						yOffset = {
							order = 3,
							type = 'range',
							name = L["Text yOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1,
						},
						text_format = {
							order = 100,
							name = L["Text Format"],
							type = 'input',
							width = 'full',
							desc = L["TEXT_FORMAT_DESC"],
						},
					},
				},
			},
		},
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
		phaseIndicator = {
			order = 5005,
			type = 'group',
			name = L["Phase Indicator"],
			get = function(info) return E.db.unitframe.units.party.phaseIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.party.phaseIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Phase Indicator"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.5, max = 1.5, step = 0.01,
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
			},
		},
	},
}

--Raid Frames
E.Options.args.unitframe.args.raid = {
	name = L["Raid Frames"],
	type = 'group',
	order = 1100,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.raid[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.raid[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		configureToggle = {
			order = 1,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(_G['ElvUF_Raid'], _G['ElvUF_Raid'].forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Raid Frames"], nil, {unit='raid', mover='Raid Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 3,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				['party'] = L["Party Frames"],
				['raid40'] = L["Raid40 Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'raid', true); end,
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raid'),
		generalGroup = {
			order = 5,
			type = 'group',
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				hideonnpc = {
					type = 'toggle',
					order = 3,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.raid.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.raid.power.hideonnpc = value; UF:CreateAndUpdateHeaderGroup('raid'); end,
				},
				rangeCheck = {
					order = 4,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				threatStyle = {
					type = 'select',
					order = 6,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				colorOverride = {
					order = 7,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				orientation = {
					order = 8,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				disableMouseoverGlow = {
					order = 9,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 10,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.raid[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid', nil, nil, true) end,
					args = {
						width = {
							order = 1,
							name = L["Width"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.raid[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
						},
						height = {
							order = 2,
							name = L["Height"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.raid[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
						},
						spacer = {
							order = 3,
							name = '',
							type = 'description',
							width = 'full',
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = 'select',
							values = growthDirectionValues,
						},
						numGroups = {
							order = 7,
							type = 'range',
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units.raid[ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup('raid')
								if _G['ElvUF_Raid'].isForced then
									UF:HeaderConfig(_G['ElvUF_Raid'])
									UF:HeaderConfig(_G['ElvUF_Raid'], true)
								end
							end,
						},
						groupsPerRowCol = {
							order = 8,
							type = 'range',
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units.raid[ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup('raid')
								if _G['ElvUF_Raid'].isForced then
									UF:HeaderConfig(_G['ElvUF_Raid'])
									UF:HeaderConfig(_G['ElvUF_Raid'], true)
								end
							end,
						},
						horizontalSpacing = {
							order = 9,
							type = 'range',
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1,
						},
						verticalSpacing = {
							order = 10,
							type = 'range',
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1,
						},
						groupSpacing = {
							order = 11,
							type = "range",
							name = L["Group Spacing"],
							desc = L["Additional spacing between each individual group."],
							min = 0, softMax = 50, step = 1,
						},
					},
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.raid[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid', nil, nil, true) end,
					args = {
						showPlayer = {
							order = 1,
							type = 'toggle',
							name = L["Display Player"],
							desc = L["When true, the header includes the player when not in a raid."],
						},
						visibility = {
							order = 2,
							type = 'input',
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = 'full',
						},
					},
				},
				sortingGroup = {
					order = 300,
					type = 'group',
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units.raid[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid', nil, nil, true) end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = 'select',
							values = {
								['CLASS'] = CLASS,
								['CLASSROLE'] = CLASS..' & '..ROLE,
								['ROLE'] = ROLE,
								['NAME'] = NAME,
								['MTMA'] = L["Main Tanks / Main Assist"],
								['GROUP'] = GROUP,
							},
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = 'select',
							values = {
								['ASC'] = L["Ascending"],
								['DESC'] = L["Descending"]
							},
						},
						spacer = {
							order = 3,
							type = 'description',
							width = 'full',
							name = ' '
						},
						raidWideSorting = {
							order = 4,
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
							type = 'toggle',
						},
						invertGroupingOrder = {
							order = 5,
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units.raid.raidWideSorting end,
							type = 'toggle',
						},
						startFromCenter = {
							order = 6,
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units.raid.raidWideSorting end,
							type = 'toggle',
						},
					},
				},
			},
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raid'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raid'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'raid'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'raid'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raid'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raid'),
		buffs = GetOptionsTable_Auras('buffs', true, UF.CreateAndUpdateHeaderGroup, 'raid'),
		debuffs = GetOptionsTable_Auras('debuffs', true, UF.CreateAndUpdateHeaderGroup, 'raid'),
		buffIndicator = {
			order = 701,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.raid.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Buff Indicator"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
				profileSpecific = {
					type = 'toggle',
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = 'execute',
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units.raid.buffIndicator.profileSpecific then
							E:SetToFilterConfig('Buff Indicator (Profile)')
						else
							E:SetToFilterConfig('Buff Indicator')
						end
					end,
					order = 6
				},
			},
		},
		roleIcon = {
			order = 702,
			type = 'group',
			name = L["Role Icon"],
			get = function(info) return E.db.unitframe.units.raid.roleIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid.roleIcon[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Role Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = positionValues,
				},
				attachTo = {
					type = 'select',
					order = 4,
					name = L["Attach To"],
					values = attachToValues,
				},
				xOffset = {
					order = 5,
					type = 'range',
					name = L["xOffset"],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["yOffset"],
					min = -300, max = 300, step = 1,
				},
				size = {
					type = 'range',
					order = 7,
					name = L["Size"],
					min = 4, max = 100, step = 1,
				},
				tank = {
					order = 8,
					type = "toggle",
					name = L["Show For Tanks"],
				},
				healer = {
					order = 9,
					type = "toggle",
					name = L["Show For Healers"],
				},
				damager = {
					order = 10,
					type = "toggle",
					name = L["Show For DPS"],
				},
				combatHide = {
					order = 11,
					type = "toggle",
					name = L["Hide In Combat"],
				},
			},
		},
		raidRoleIcons = {
			order = 703,
			type = 'group',
			name = L["RL Icon"],
			get = function(info) return E.db.unitframe.units.raid.raidRoleIcons[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid.raidRoleIcons[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["RL Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = {
						['TOPLEFT'] = 'TOPLEFT',
						['TOPRIGHT'] = 'TOPRIGHT',
					},
				},
			},
		},
		phaseIndicator = {
			order = 5006,
			type = 'group',
			name = L["Phase Indicator"],
			get = function(info) return E.db.unitframe.units.raid.phaseIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid.phaseIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Phase Indicator"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.5, max = 1.5, step = 0.01,
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
			},
		},
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raid'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
	},
}

--Raid-40 Frames
E.Options.args.unitframe.args.raid40 = {
	name = L["Raid-40 Frames"],
	type = 'group',
	order = 1100,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.raid40[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.raid40[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		configureToggle = {
			order = 1,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(_G['ElvUF_Raid40'], _G['ElvUF_Raid40'].forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Raid-40 Frames"], nil, {unit='raid40', mover='Raid Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 3,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				['party'] = L["Party Frames"],
				['raid'] = L["Raid Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'raid40', true); end,
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		generalGroup = {
			order = 5,
			type = 'group',
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				hideonnpc = {
					type = 'toggle',
					order = 3,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units.raid40.power.hideonnpc end,
					set = function(info, value) E.db.unitframe.units.raid40.power.hideonnpc = value; UF:CreateAndUpdateHeaderGroup('raid40'); end,
				},
				rangeCheck = {
					order = 4,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				threatStyle = {
					type = 'select',
					order = 6,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				colorOverride = {
					order = 7,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				orientation = {
					order = 8,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				disableMouseoverGlow = {
					order = 9,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 10,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.raid40[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40', nil, nil, true) end,
					args = {
						width = {
							order = 1,
							name = L["Width"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.raid40[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
						},
						height = {
							order = 2,
							name = L["Height"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.raid40[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
						},
						spacer = {
							order = 3,
							name = '',
							type = 'description',
							width = 'full',
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = 'select',
							values = growthDirectionValues,
						},
						numGroups = {
							order = 7,
							type = 'range',
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units.raid40[ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup('raid40')
								if _G['ElvUF_Raid'].isForced then
									UF:HeaderConfig(_G['ElvUF_Raid40'])
									UF:HeaderConfig(_G['ElvUF_Raid40'], true)
								end
							end,
						},
						groupsPerRowCol = {
							order = 8,
							type = 'range',
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units.raid40[ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup('raid40')
								if _G['ElvUF_Raid'].isForced then
									UF:HeaderConfig(_G['ElvUF_Raid40'])
									UF:HeaderConfig(_G['ElvUF_Raid40'], true)
								end
							end,
						},
						horizontalSpacing = {
							order = 9,
							type = 'range',
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1,
						},
						verticalSpacing = {
							order = 10,
							type = 'range',
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1,
						},
						groupSpacing = {
							order = 11,
							type = "range",
							name = L["Group Spacing"],
							desc = L["Additional spacing between each individual group."],
							min = 0, softMax = 50, step = 1,
						},
					},
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.raid40[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40', nil, nil, true) end,
					args = {
						showPlayer = {
							order = 1,
							type = 'toggle',
							name = L["Display Player"],
							desc = L["When true, the header includes the player when not in a raid."],
						},
						visibility = {
							order = 2,
							type = 'input',
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = 'full',
						},
					},
				},
				sortingGroup = {
					order = 300,
					type = 'group',
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units.raid40[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40', nil, nil, true) end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = 'select',
							values = {
								['CLASS'] = CLASS,
								['CLASSROLE'] = CLASS..' & '..ROLE,
								['ROLE'] = ROLE,
								['NAME'] = NAME,
								['MTMA'] = L["Main Tanks / Main Assist"],
								['GROUP'] = GROUP,
							},
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = 'select',
							values = {
								['ASC'] = L["Ascending"],
								['DESC'] = L["Descending"]
							},
						},
						spacer = {
							order = 3,
							type = 'description',
							width = 'full',
							name = ' '
						},
						raidWideSorting = {
							order = 4,
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
							type = 'toggle',
						},
						invertGroupingOrder = {
							order = 5,
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units.raid40.raidWideSorting end,
							type = 'toggle',
						},
						startFromCenter = {
							order = 6,
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units.raid40.raidWideSorting end,
							type = 'toggle',
						},
					},
				},
			},
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raid40'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'raid40'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		buffs = GetOptionsTable_Auras('buffs', true, UF.CreateAndUpdateHeaderGroup, 'raid40'),
		debuffs = GetOptionsTable_Auras('debuffs', true, UF.CreateAndUpdateHeaderGroup, 'raid40'),
		buffIndicator = {
			order = 701,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.raid40.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid40.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Buff Indicator"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
				profileSpecific = {
					type = 'toggle',
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = 'execute',
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units.raid40.buffIndicator.profileSpecific then
							E:SetToFilterConfig('Buff Indicator (Profile)')
						else
							E:SetToFilterConfig('Buff Indicator')
						end
					end,
					order = 6
				},
			},
		},
		roleIcon = {
			order = 702,
			type = 'group',
			name = L["Role Icon"],
			get = function(info) return E.db.unitframe.units.raid40.roleIcon[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid40.roleIcon[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Role Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = positionValues,
				},
				attachTo = {
					type = 'select',
					order = 4,
					name = L["Attach To"],
					values = attachToValues,
				},
				xOffset = {
					order = 5,
					type = 'range',
					name = L["xOffset"],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["yOffset"],
					min = -300, max = 300, step = 1,
				},
				size = {
					type = 'range',
					order = 7,
					name = L["Size"],
					min = 4, max = 100, step = 1,
				},
				tank = {
					order = 8,
					type = "toggle",
					name = L["Show For Tanks"],
				},
				healer = {
					order = 9,
					type = "toggle",
					name = L["Show For Healers"],
				},
				damager = {
					order = 10,
					type = "toggle",
					name = L["Show For DPS"],
				},
				combatHide = {
					order = 11,
					type = "toggle",
					name = L["Hide In Combat"],
				},
			},
		},
		raidRoleIcons = {
			order = 703,
			type = 'group',
			name = L["RL Icon"],
			get = function(info) return E.db.unitframe.units.raid40.raidRoleIcons[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid40.raidRoleIcons[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["RL Icon"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				position = {
					type = 'select',
					order = 3,
					name = L["Position"],
					values = {
						['TOPLEFT'] = 'TOPLEFT',
						['TOPRIGHT'] = 'TOPRIGHT',
					},
				},
			},
		},
		phaseIndicator = {
			order = 5007,
			type = 'group',
			name = L["Phase Indicator"],
			get = function(info) return E.db.unitframe.units.raid40.phaseIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raid40.phaseIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Phase Indicator"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.5, max = 1.5, step = 0.01,
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
			},
		},
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
	},
}

--Raid Pet Frames
E.Options.args.unitframe.args.raidpet = {
	order = 1200,
	type = 'group',
	name = L["Raid Pet Frames"],
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.raidpet[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.raidpet[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		configureToggle = {
			order = 1,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Raidpet, ElvUF_Raidpet.forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Raid Pet Frames"], nil, {unit='raidpet', mover='Raid Pet Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 3,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				['party'] = L["Party Frames"],
				['raid'] = L["Raid Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'raidpet', true); end,
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		generalGroup = {
			order = 5,
			type = 'group',
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				rangeCheck = {
					order = 3,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				threatStyle = {
					type = 'select',
					order = 5,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				colorOverride = {
					order = 6,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				disableMouseoverGlow = {
					order = 8,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 9,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.raidpet[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet', nil, nil, true) end,
					args = {
						width = {
							order = 1,
							name = L["Width"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.raidpet[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet') end,
						},
						height = {
							order = 2,
							name = L["Height"],
							type = 'range',
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units.raidpet[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet') end,
						},
						spacer = {
							order = 3,
							name = '',
							type = 'description',
							width = 'full',
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = 'select',
							values = growthDirectionValues,
						},
						numGroups = {
							order = 7,
							type = 'range',
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
								set = function(info, value)
									E.db.unitframe.units.raidpet[ info[#info] ] = value;
									UF:CreateAndUpdateHeaderGroup('raidpet')
									if ElvUF_Raidpet.isForced then
										UF:HeaderConfig(ElvUF_Raidpet)
										UF:HeaderConfig(ElvUF_Raidpet, true)
									end
								end,
						},
						groupsPerRowCol = {
							order = 8,
							type = 'range',
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units.raidpet[ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup('raidpet')
								if ElvUF_Raidpet.isForced then
									UF:HeaderConfig(ElvUF_Raidpet)
									UF:HeaderConfig(ElvUF_Raidpet, true)
								end
							end,
						},
						horizontalSpacing = {
							order = 9,
							type = 'range',
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1,
						},
						verticalSpacing = {
							order = 10,
							type = 'range',
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1,
						},
						groupSpacing = {
							order = 11,
							type = "range",
							name = L["Group Spacing"],
							desc = L["Additional spacing between each individual group."],
							min = 0, softMax = 50, step = 1,
						},
					},
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = 'group',
					guiInline = true,
					set = function(info, value) E.db.unitframe.units.raidpet[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet', nil, nil, true) end,
					args = {
						visibility = {
							order = 2,
							type = 'input',
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = 'full',
						},
					},
				},
				sortingGroup = {
					order = 300,
					type = 'group',
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units.raidpet[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet', nil, nil, true) end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = 'select',
							values = {
								['NAME'] = L["Owners Name"],
								['PETNAME'] = L["Pet Name"],
								['GROUP'] = GROUP,
							},
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = 'select',
							values = {
								['ASC'] = L["Ascending"],
								['DESC'] = L["Descending"]
							},
						},
						spacer = {
							order = 3,
							type = 'description',
							width = 'full',
							name = ' '
						},
						raidWideSorting = {
							order = 4,
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
							type = 'toggle',
						},
						invertGroupingOrder = {
							order = 5,
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units.raidpet.raidWideSorting end,
							type = 'toggle',
						},
						startFromCenter = {
							order = 6,
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units.raidpet.raidWideSorting end,
							type = 'toggle',
						},
					},
				},
			},
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		buffs = GetOptionsTable_Auras('buffs', true, UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		debuffs = GetOptionsTable_Auras('debuffs', true, UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		buffIndicator = {
			order = 701,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.raidpet.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.raidpet.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raidpet') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Buff Indicator"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
				configureButton = {
					type = 'execute',
					name = L["Configure Auras"],
					func = function() E:SetToFilterConfig('Buff Indicator') end,
					order = 5
				},
			},
		},
	},
}

--Tank Frames
E.Options.args.unitframe.args.tank = {
	name = L["Tank Frames"],
	type = 'group',
	order = 1300,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.tank[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.tank[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('tank') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		resetSettings = {
			type = 'execute',
			order = 1,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Tank Frames"], nil, {unit='tank'}) end,
		},
		generalGroup = {
			order = 2,
			type = 'group',
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				width = {
					order = 3,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 4,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				verticalSpacing = {
					order = 5,
					type = "range",
					name = L["Vertical Spacing"],
					min = 0, max = 100, step = 1,
				},
				disableDebuffHighlight = {
					order = 6,
					type = "toggle",
					name = L["Disable Debuff Highlight"],
					desc = L["Forces Debuff Highlight to be disabled for these frames"],
					disabled = function() return E.db.unitframe.debuffHighlighting == "NONE" end,
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 8,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				disableMouseoverGlow = {
					order = 9,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 10,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		targetsGroup = {
			order = 700,
			type = 'group',
			name = L["Tank Target"],
			get = function(info) return E.db.unitframe.units.tank.targetsGroup[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.tank.targetsGroup[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('tank') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Tank Target"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				width = {
					order = 3,
					name = L["Width"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 4,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				colorOverride = {
					order = 8,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'tank'),
			},
		},
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'tank'),
		buffs = GetOptionsTable_Auras('buffs', true, UF.CreateAndUpdateHeaderGroup, 'tank'),
		debuffs = GetOptionsTable_Auras('debuffs', true, UF.CreateAndUpdateHeaderGroup, 'tank'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'tank'),
		buffIndicator = {
			order = 701,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.tank.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.tank.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('tank') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Buff Indicator"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
				profileSpecific = {
					type = 'toggle',
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = 'execute',
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units.tank.buffIndicator.profileSpecific then
							E:SetToFilterConfig('Buff Indicator (Profile)')
						else
							E:SetToFilterConfig('Buff Indicator')
						end
					end,
					order = 6
				},
			},
		},
	},
}
E.Options.args.unitframe.args.tank.args.name.args.attachTextTo.values = { ["Health"] = L["Health"], ["Frame"] = L["Frame"] }
E.Options.args.unitframe.args.tank.args.targetsGroup.args.name.args.attachTextTo.values = { ["Health"] = L["Health"], ["Frame"] = L["Frame"] }
E.Options.args.unitframe.args.tank.args.targetsGroup.args.name.get = function(info) return E.db.unitframe.units['tank'].targetsGroup.name[ info[#info] ] end
E.Options.args.unitframe.args.tank.args.targetsGroup.args.name.set = function(info, value) E.db.unitframe.units['tank'].targetsGroup.name[ info[#info] ] = value; UF.CreateAndUpdateHeaderGroup(UF, 'tank') end

--Assist Frames
E.Options.args.unitframe.args.assist = {
	name = L["Assist Frames"],
	type = 'group',
	order = 1300,
	childGroups = "tab",
	get = function(info) return E.db.unitframe.units.assist[ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units.assist[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('assist') end,
	disabled = function() return not E.UnitFrames; end,
	args = {
		resetSettings = {
			type = 'execute',
			order = 1,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Assist Frames"], nil, {unit='assist'}) end,
		},
		generalGroup = {
			order = 2,
			type = 'group',
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
				},
				width = {
					order = 3,
					name = L["Width"],
					type = 'range',
					min = 50, max = 1000, step = 1,
				},
				height = {
					order = 4,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				verticalSpacing = {
					order = 5,
					type = "range",
					name = L["Vertical Spacing"],
					min = 0, max = 100, step = 1,
				},
				disableDebuffHighlight = {
					order = 6,
					type = "toggle",
					name = L["Disable Debuff Highlight"],
					desc = L["Forces Debuff Highlight to be disabled for these frames"],
					disabled = function() return E.db.unitframe.debuffHighlighting == "NONE" end,
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame."],
					values = orientationValues,
				},
				colorOverride = {
					order = 8,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				disableMouseoverGlow = {
					order = 9,
					type = "toggle",
					name = L["Block Mouseover Glow"],
					desc = L["Forces Mouseover Glow to be disabled for these frames"],
				},
				disableTargetGlow = {
					order = 10,
					type = "toggle",
					name = L["Block Target Glow"],
					desc = L["Forces Target Glow to be disabled for these frames"],
				},
			},
		},
		targetsGroup = {
			order = 701,
			type = 'group',
			name = L["Assist Target"],
			get = function(info) return E.db.unitframe.units.assist.targetsGroup[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.assist.targetsGroup[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('assist') end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Assist Target"],
				},
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 2,
				},
				width = {
					order = 3,
					name = L["Width"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 4,
					name = L["Height"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				colorOverride = {
					order = 8,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = 'select',
					values = colorOverrideValues,
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'assist'),
			},
		},
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'assist'),
		buffs = GetOptionsTable_Auras('buffs', true, UF.CreateAndUpdateHeaderGroup, 'assist'),
		debuffs = GetOptionsTable_Auras('debuffs', true, UF.CreateAndUpdateHeaderGroup, 'assist'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'assist'),
		buffIndicator = {
			order = 702,
			type = 'group',
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units.assist.buffIndicator[ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units.assist.buffIndicator[ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('assist') end,
			args = {
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 1,
				},
				size = {
					type = 'range',
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = 'range',
					name = FONT_SIZE,
					order = 4,
					min = 7, max = 212, step = 1,
				},
				profileSpecific = {
					type = 'toggle',
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = 'execute',
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units.assist.buffIndicator.profileSpecific then
							E:SetToFilterConfig('Buff Indicator (Profile)')
						else
							E:SetToFilterConfig('Buff Indicator')
						end
					end,
					order = 6
				},
			},
		},
	},
}
E.Options.args.unitframe.args.assist.args.name.args.attachTextTo.values = { ["Health"] = L["Health"], ["Frame"] = L["Frame"] }
E.Options.args.unitframe.args.assist.args.targetsGroup.args.name.args.attachTextTo.values = { ["Health"] = L["Health"], ["Frame"] = L["Frame"] }
E.Options.args.unitframe.args.assist.args.targetsGroup.args.name.get = function(info) return E.db.unitframe.units['assist'].targetsGroup.name[ info[#info] ] end
E.Options.args.unitframe.args.assist.args.targetsGroup.args.name.set = function(info, value) E.db.unitframe.units['assist'].targetsGroup.name[ info[#info] ] = value; UF.CreateAndUpdateHeaderGroup(UF, 'assist') end

--MORE COLORING STUFF YAY
E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup = {
	order = -10,
	type = 'group',
	name = L["Class Resources"],
	get = function(info)
		local t = E.db.unitframe.colors.classResources[ info[#info] ]
		local d = P.unitframe.colors.classResources[ info[#info] ]
		return t.r, t.g, t.b, t.a, d.r, d.g, d.b
	end,
	set = function(info, r, g, b)
		local t = E.db.unitframe.colors.classResources[ info[#info] ]
		t.r, t.g, t.b = r, g, b
		UF:Update_AllFrames()
	end,
	args = {}
}

E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args.bgColor = {
	order = 1,
	type = 'color',
	name = L["Backdrop Color"],
	hasAlpha = false,
}

for i = 1, 3 do
	E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args['combo'..i] = {
		order = i + 2,
		type = 'color',
		name = L["Combo Point"]..' #'..i,
		get = function(info)
			local t = E.db.unitframe.colors.classResources.comboPoints[i]
			local d = P.unitframe.colors.classResources.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = E.db.unitframe.colors.classResources.comboPoints[i]
			t.r, t.g, t.b = r, g, b
			UF:Update_AllFrames()
		end,
	}
end


if P.unitframe.colors.classResources[E.myclass] then
	E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args.spacer2 = {
		order = 10,
		name = ' ',
		type = 'description',
		width = 'full',
	}

	local ORDER = 20
	if E.myclass == 'PALADIN' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = HOLY_POWER,
			order = ORDER,
		}
	elseif E.myclass == 'MAGE' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = POWER_TYPE_ARCANE_CHARGES,
			order = ORDER,
		}
	elseif E.myclass == 'ROGUE' then
		for i = 1, 5 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = L["Anticipation"]..' #'..i,
				order = ORDER + i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.ROGUE[i]
					local d = P.unitframe.colors.classResources.ROGUE[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.ROGUE[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end,
			}
		end
	elseif E.myclass == 'MONK' then
		for i = 1, 6 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = CHI_POWER..' #'..i,
				order = ORDER + i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.MONK[i]
					local d = P.unitframe.colors.classResources.MONK[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.MONK[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end,
			}
		end
	elseif E.myclass == 'WARLOCK' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = SOUL_SHARDS,
			order = ORDER,
		}
	elseif E.myclass == 'DEATHKNIGHT' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = RUNES,
			order = ORDER,
		}
	end
end

if E.myclass == 'DEATHKNIGHT' then
	E.Options.args.unitframe.args.player.args.classbar.args.sortDirection = {
		name = L["Sort Direction"],
		desc = L["Defines the sort order of the selected sort method."],
		type = 'select',
		order = 7,
		values = {
			['asc'] = L["Ascending"],
			['desc'] = L["Descending"],
			['NONE'] = NONE,
		},
		get = function(info) return E.db.unitframe.units.player.classbar[ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units.player.classbar[ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
	}
end

--Custom Texts
function E:RefreshCustomTextsConfigs()
	--Hide any custom texts that don't belong to current profile
	for _, customText in pairs(CUSTOMTEXT_CONFIGS) do
		customText.hidden = true
	end
	twipe(CUSTOMTEXT_CONFIGS)

	for unit in pairs(E.db.unitframe.units) do
		if E.db.unitframe.units[unit].customTexts then
			for objectName in pairs(E.db.unitframe.units[unit].customTexts) do
				CreateCustomTextGroup(unit, objectName)
			end
		end
	end
end
E:RefreshCustomTextsConfigs()
