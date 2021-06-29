local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames')
local ACD = E.Libs.AceConfigDialog
local ACH = E.Libs.ACH

local _G = _G
local format, gsub, ipairs, pairs, select, strmatch, strsplit = format, gsub, ipairs, pairs, select, strmatch, strsplit
local tconcat, tinsert, tremove, type, wipe, tonumber = table.concat, tinsert, tremove, type, wipe, tonumber
local GetScreenWidth = GetScreenWidth
local GetNumClasses = GetNumClasses
local GetClassInfo = GetClassInfo

-- GLOBALS: ElvUF_Parent, ElvUF_Player, ElvUF_Pet, ElvUF_PetTarget, ElvUF_Party, ElvUF_Raidpet
-- GLOBALS: ElvUF_Target, ElvUF_TargetTarget, ElvUF_TargetTargetTarget, ElvUF_Focus, ElvUF_FocusTarget

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
	NONE = L["NONE"],
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
	Health = L["Health"],
	Power = L["Power"],
	InfoPanel = L["Information Panel"],
	Frame = L["Frame"],
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
	DISABLED = L["DISABLE"],
	BUFFS_ON_DEBUFFS = L["Position Buffs on Debuffs"],
	DEBUFFS_ON_BUFFS = L["Position Debuffs on Buffs"],
	FLUID_BUFFS_ON_DEBUFFS = L["Fluid Position Buffs on Debuffs"],
	FLUID_DEBUFFS_ON_BUFFS = L["Fluid Position Debuffs on Buffs"],
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

local CUSTOMTEXT_CONFIGS = {}
local carryFilterFrom, carryFilterTo
local function filterMatch(s,v)
	local m1, m2, m3, m4 = '^'..v..'$', '^'..v..',', ','..v..'$', ','..v..','
	return (strmatch(s, m1) and m1) or (strmatch(s, m2) and m2) or (strmatch(s, m3) and m3) or (strmatch(s, m4) and v..',')
end

local function filterPriority(auraType, groupName, value, remove, movehere, friendState)
	if not auraType or not value then return end
	local filter = E.db.unitframe.units[groupName] and E.db.unitframe.units[groupName][auraType] and E.db.unitframe.units[groupName][auraType].priority
	if not filter then return end
	local found = filterMatch(filter, E:EscapeString(value))
	if found and movehere then
		local tbl, sv, sm = {strsplit(',',filter)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm);tinsert(tbl, sv, movehere);
		E.db.unitframe.units[groupName][auraType].priority = tconcat(tbl,',')
	elseif found and friendState then
		local realValue = strmatch(value, '^Friendly:([^,]*)') or strmatch(value, '^Enemy:([^,]*)') or value
		local friend = filterMatch(filter, E:EscapeString('Friendly:'..realValue))
		local enemy = filterMatch(filter, E:EscapeString('Enemy:'..realValue))
		local default = filterMatch(filter, E:EscapeString(realValue))

		local state =
			(friend and (not enemy) and format('%s%s','Enemy:',realValue))					--[x] friend [ ] enemy: > enemy
		or	((not enemy and not friend) and format('%s%s','Friendly:',realValue))			--[ ] friend [ ] enemy: > friendly
		or	(enemy and (not friend) and default and format('%s%s','Friendly:',realValue))	--[ ] friend [x] enemy: (default exists) > friendly
		or	(enemy and (not friend) and strmatch(value, '^Enemy:') and realValue)			--[ ] friend [x] enemy: (no default) > realvalue
		or	(friend and enemy and realValue)												--[x] friend [x] enemy: > default

		if state then
			local stateFound = filterMatch(filter, E:EscapeString(state))
			if not stateFound then
				local tbl, sv = {strsplit(',',filter)}
				for i in ipairs(tbl) do
					if tbl[i] == value then sv = i;break end
				end
				tinsert(tbl, sv, state);tremove(tbl, sv+1)
				E.db.unitframe.units[groupName][auraType].priority = tconcat(tbl,',')
			end
		end
	elseif found and remove then
		E.db.unitframe.units[groupName][auraType].priority = gsub(filter, found, '')
	elseif not found and not remove then
		E.db.unitframe.units[groupName][auraType].priority = (filter == '' and value) or (filter..','..value)
	end
end

-----------------------------------------------------------------------
-- OPTIONS TABLES
-----------------------------------------------------------------------
local function GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, subGroup)
	local config = ACH:Group(L["Strata and Level"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].strataAndLevel[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].strataAndLevel[info[#info]] = value; updateFunc(UF, groupName, numUnits) end)
	config.args.useCustomStrata = ACH:Toggle(L["Use Custom Strata"], nil, 1)
	config.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 2, C.Values.Strata)
	config.args.spacer = ACH:Spacer(3)
	config.args.useCustomLevel = ACH:Toggle(L["Use Custom Level"], nil, 4)
	config.args.frameLevel = ACH:Range(L["Frame Level"], nil, 5, { min = 2, max = 128, step = 1 })

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].strataAndLevel[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].strataAndLevel[info[#info]] = value; updateFunc(UF, groupName, numUnits) end
	end

	return config
end

local function GetOptionsTable_AuraBars(updateFunc, groupName)
	local config = {
		type = 'group',
		name = L["Aura Bars"],
		get = function(info) return E.db.unitframe.units[groupName].aurabar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].aurabar[info[#info]] = value; updateFunc(UF, groupName) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
			},
			configureButton1 = {
				order = 2,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup('ElvUI', 'unitframe', 'generalOptionsGroup', 'allColorsGroup', 'auraBars') end,
			},
			configureButton2 = {
				order = 3,
				name = L["Coloring (Specific)"],
				desc = L["This opens the AuraBar Colors filter. These settings affect specific spells."],
				type = 'execute',
				func = function() E:SetToFilterConfig('AuraBar Colors') end,
			},
			anchorPoint = {
				type = 'select',
				order = 4,
				name = L["Anchor Point"],
				desc = L["What point to anchor to the frame you set to attach to."],
				values = {
					ABOVE = L["Above"],
					BELOW = L["Below"],
				},
			},
			attachTo = {
				type = 'select',
				order = 5,
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = {
					FRAME = L["Frame"],
					DEBUFFS = L["Debuffs"],
					BUFFS = L["Buffs"],
					DETACHED = L["Detach From Frame"],
				},
			},
			height = {
				type = 'range',
				order = 6,
				name = L["Height"],
				min = 5, max = 40, step = 1,
			},
			detachedWidth = {
				type = 'range',
				order = 7,
				name = L["Detached Width"],
				hidden = function() return E.db.unitframe.units[groupName].aurabar.attachTo ~= 'DETACHED' end,
				min = 50, max = 500, step = 1,
			},
			maxBars = {
				type = 'range',
				order = 8,
				name = L["Max Bars"],
				min = 1, max = 40, step = 1,
			},
			sortMethod = {
				order = 9,
				name = L["Sort By"],
				desc = L["Method to sort by."],
				type = 'select',
				values = {
					TIME_REMAINING = L["Time Remaining"],
					DURATION = L["Duration"],
					NAME = L["NAME"],
					INDEX = L["Index"],
					PLAYER = L["PLAYER"],
				},
			},
			sortDirection = {
				order = 10,
				name = L["Sort Direction"],
				desc = L["Ascending or Descending order."],
				type = 'select',
				values = {
					ASCENDING = L["Ascending"],
					DESCENDING = L["Descending"],
				},
			},
			clickThrough = {
				order = 11,
				name = L["Click Through"],
				desc = L["Ignore mouse events."],
				type = 'toggle',
			},
			friendlyAuraType = {
				type = 'select',
				order = 16,
				name = L["Friendly Aura Type"],
				desc = L["Set the type of auras to show when a unit is friendly."],
				values = {
					HARMFUL = L["Debuffs"],
					HELPFUL = L["Buffs"],
				},
			},
			enemyAuraType = {
				type = 'select',
				order = 17,
				name = L["Enemy Aura Type"],
				desc = L["Set the type of auras to show when a unit is a foe."],
				values = {
					HARMFUL = L["Debuffs"],
					HELPFUL = L["Buffs"],
				},
			},
			yOffset = {
				order = 19,
				type = 'range',
				name = L["Y-Offset"],
				min = 0, max = 100, step = 1,
				hidden = function() return E.db.unitframe.units[groupName].aurabar.attachTo == 'DETACHED' end,
			},
			spacing = {
				order = 20,
				type = 'range',
				name = L["Spacing"],
				min = 0, softMax = 20, step = 1,
			},
			filters = {
				name = L["FILTERS"],
				inline = true,
				type = 'group',
				order = 500,
				args = {
					minDuration = {
						order = 1,
						type = 'range',
						name = L["Minimum Duration"],
						desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
						min = 0, max = 10800, step = 1,
					},
					maxDuration = {
						order = 2,
						type = 'range',
						name = L["Maximum Duration"],
						desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
						min = 0, max = 10800, step = 1,
					},
					jumpToFilter = {
						order = 3,
						name = L["Filters Page"],
						desc = L["Shortcut to 'Filters' section of the config."],
						type = 'execute',
						func = function() ACD:SelectGroup('ElvUI', 'filters') end,
					},
					specialPriority = {
						order = 4,
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
					},
					priority = {
						order = 5,
						name = L["Add Regular Filter"],
						desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."],
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
					},
					resetPriority = {
						order = 6,
						name = L["Reset Priority"],
						desc = L["Reset filter priority to the default state."],
						type = 'execute',
						func = function()
							E.db.unitframe.units[groupName].aurabar.priority = P.unitframe.units[groupName].aurabar.priority
							updateFunc(UF, groupName)
						end,
					},
					filterPriority = {
						order = 7,
						dragdrop = true,
						type = 'multiselect',
						name = L["Filter Priority"],
						dragOnLeave = E.noop, --keep this here
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
						stateSwitchGetText = C.StateSwitchGetText,
						stateSwitchOnClick = function(info)
							filterPriority('aurabar', groupName, carryFilterFrom, nil, nil, true)
						end,
						values = function()
							local str = E.db.unitframe.units[groupName].aurabar.priority
							if str == '' then return nil end
							return {strsplit(',',str)}
						end,
						get = function(info, value)
							local str = E.db.unitframe.units[groupName].aurabar.priority
							if str == '' then return nil end
							local tbl = {strsplit(',',str)}
							return tbl[value]
						end,
						set = function(info)
							E.db.unitframe.units[groupName].aurabar[info[#info]] = nil -- this was being set when drag and drop was first added, setting it to nil to clear tester profiles of this variable
							updateFunc(UF, groupName)
						end
					},
					spacer1 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."]..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 8, 'medium'),
				},
			},
		},
	}

	if groupName == 'target' then
		config.args.attachTo.values.PLAYER_AURABARS = L["Player Frame Aura Bars"]
	end

	return config
end

local function GetOptionsTable_Auras(auraType, updateFunc, groupName, numUnits)
	local config = ACH:Group(auraType == 'buffs' and L["Buffs"] or L["Debuffs"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value; updateFunc(UF, groupName, numUnits) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.perrow = ACH:Range(L["Per Row"], nil, 3, { min = 1, max = 20, step = 1 })
	config.args.numrows = ACH:Range(L["Num Rows"], nil, 4, { min = 1, max = 10, step = 1 })
	config.args.sizeOverride = ACH:Range(L["Size Override"], L["If not set to 0 then override the size of the aura icon to this."], 5, { min = 0, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -80, max = 80, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -80, max = 80, step = 1 })
	config.args.spacing = ACH:Range(L["Spacing"], nil, 8, { min = -1, max = 20, step = 1 })
	config.args.attachTo = ACH:Select(L["Attach To"], L["What to attach the anchor frame to."], 9, { FRAME = L["Frame"], DEBUFFS = L["Debuffs"], HEALTH = L["Health"], POWER = L["Power"] }, nil, nil, nil, nil, nil, function() local smartAuraPosition = E.db.unitframe.units[groupName].smartAuraPosition return (smartAuraPosition and (smartAuraPosition == 'BUFFS_ON_DEBUFFS' or smartAuraPosition == 'FLUID_BUFFS_ON_DEBUFFS')) end)
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 10, positionValues)
	config.args.clickThrough = ACH:Toggle(L["Click Through"], L["Ignore mouse events."], 11)
	config.args.sortMethod = ACH:Select( L["Sort By"], L["Method to sort by."], 12, { TIME_REMAINING = L["Time Remaining"], DURATION = L["Duration"], NAME = L["NAME"], INDEX = L["Index"], PLAYER = L["PLAYER"] })
	config.args.sortDirection = ACH:Select(L["Sort Direction"], L["Ascending or Descending order."], 13, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })

	config.args.stacks = ACH:Group(L["Stack Counter"], nil, 14, nil, function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value; updateFunc(UF, groupName, numUnits) end)
	config.args.stacks.inline = true
	config.args.stacks.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 1)
	config.args.stacks.args.countFontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
	config.args.stacks.args.countFontOutline = ACH:FontFlags(L["Font Outline"], L["Set the font outline."], 3)

	config.args.duration = ACH:Group(L["Duration"], nil, 15, nil, function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end, function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value; updateFunc(UF, groupName, numUnits) end)
	config.args.duration.inline = true
	config.args.duration.args.cooldownShortcut = ACH:Execute(L["Cooldowns"], nil, 1, function() ACD:SelectGroup('ElvUI', 'cooldown', 'unitframe') end)
	config.args.duration.args.durationPosition = ACH:Select(L["Position"], nil, 2, { TOP = 'TOP', LEFT = 'LEFT', BOTTOM = 'BOTTOM', CENTER = 'CENTER', TOPLEFT = 'TOPLEFT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT' })

	config.args.filters = {
		name = L["FILTERS"],
		inline = true,
		type = 'group',
		order = 500,
		args = {
			minDuration = {
				order = 1,
				type = 'range',
				name = L["Minimum Duration"],
				desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
				min = 0, max = 10800, step = 1,
			},
			maxDuration = {
				order = 2,
				type = 'range',
				name = L["Maximum Duration"],
				desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
				min = 0, max = 10800, step = 1,
			},
			jumpToFilter = {
				order = 3,
				name = L["Filters Page"],
				desc = L["Shortcut to 'Filters' section of the config."],
				type = 'execute',
				func = function() ACD:SelectGroup('ElvUI', 'filters') end,
			},
			specialPriority = {
				order = 4,
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
			},
			priority = {
				order = 5,
				name = L["Add Regular Filter"],
				desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."],
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
			},
			resetPriority = {
				order = 6,
				name = L["Reset Priority"],
				desc = L["Reset filter priority to the default state."],
				type = 'execute',
				func = function()
					E.db.unitframe.units[groupName][auraType].priority = P.unitframe.units[groupName][auraType].priority
					updateFunc(UF, groupName, numUnits)
				end,
			},
			filterPriority = {
				order = 7,
				dragdrop = true,
				type = 'multiselect',
				name = L["Filter Priority"],
				dragOnLeave = E.noop, --keep this here
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
				stateSwitchGetText = C.StateSwitchGetText,
				stateSwitchOnClick = function(info)
					filterPriority(auraType, groupName, carryFilterFrom, nil, nil, true)
				end,
				values = function()
					local str = E.db.unitframe.units[groupName][auraType].priority
					if str == '' then return nil end
					return {strsplit(',',str)}
				end,
				get = function(info, value)
					local str = E.db.unitframe.units[groupName][auraType].priority
					if str == '' then return nil end
					local tbl = {strsplit(',',str)}
					return tbl[value]
				end,
				set = function(info)
					E.db.unitframe.units[groupName][auraType][info[#info]] = nil -- this was being set when drag and drop was first added, setting it to nil to clear tester profiles of this variable
					updateFunc(UF, groupName, numUnits)
				end
			},
			spacer1 = ACH:Description(L["Use drag and drop to rearrange filter priority or right click to remove a filter."]..'\n'..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."], 8, 'medium'),
		},
	}

	if auraType == 'debuffs' then
		config.args.attachTo.values = { FRAME = L["Frame"], BUFFS = L["Buffs"], HEALTH = L["Health"], POWER = L["Power"] }
		config.args.attachTo.disabled = function()
			local smartAuraPosition = E.db.unitframe.units[groupName].smartAuraPosition
			return (smartAuraPosition and (smartAuraPosition == 'DEBUFFS_ON_BUFFS' or smartAuraPosition == 'FLUID_DEBUFFS_ON_BUFFS'))
		end
		config.args.desaturate = ACH:Toggle(L["Desaturate Icon"], nil, 2)
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
	local config = {
		type = 'group',
		name = L["Aura Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].buffIndicator[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].buffIndicator[info[#info]] = value; updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = 'toggle',
				name = L["Enable"],
			},
			size = {
				order = 3,
				type = 'range',
				name = L["Size"],
				min = 6, max = 48, step = 1,
			},
			countFontSize = {
				order = 2,
				name = L["FONT_SIZE"],
				type = 'range',
				min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
			},
			profileSpecific = {
				type = 'toggle',
				name = L["Profile Specific"],
				desc = L["Use the profile specific filter Aura Indicator (Profile) instead of the global filter Aura Indicator."],
				order = 4,
			},
			configureButton = {
				order = 6,
				type = 'execute',
				name = L["Configure Auras"],
				func = function()
					if groupName == 'pet' then
						E:SetToFilterConfig('Aura Indicator (Pet)')
					elseif E.db.unitframe.units[groupName].buffIndicator.profileSpecific then
						E:SetToFilterConfig('Aura Indicator (Profile)')
					else
						E:SetToFilterConfig('Aura Indicator (Class)')
					end
				end,
			}
		},
	}

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].buffIndicator[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].buffIndicator[info[#info]] = value; updateFunc(UF, groupName, numGroup) end
	else
		config.args.applyToAll = {
			name = ' ',
			inline = true,
			type = 'group',
			order = 50,
			get = function(info)
				return BuffIndicator_ApplyToAll(info, nil, E.db.unitframe.units[groupName].buffIndicator.profileSpecific, groupName == 'pet')
			end,
			set = function(info, value)
				BuffIndicator_ApplyToAll(info, value, E.db.unitframe.units[groupName].buffIndicator.profileSpecific, groupName == 'pet')
				updateFunc(UF, groupName, numGroup)
			end,
			args = {
				header = ACH:Description(L["|cffFF0000Warning:|r Changing options in this section will apply to all Aura Indicator auras. To change only one Aura, please click \"Configure Auras\" and change that specific Auras settings. If \"Profile Specific\" is selected it will apply to that filter set."], 1),
				style = {
					name = L["Style"],
					order = 2,
					type = 'select',
					values = {
						timerOnly = L["Timer Only"],
						coloredIcon = L["Colored Icon"],
						texturedIcon = L["Textured Icon"],
					},
				},
				textThreshold = {
					name = L["Text Threshold"],
					desc = L["At what point should the text be displayed. Set to -1 to disable."],
					type = 'range',
					order = 4,
					min = -1, max = 60, step = 1,
				},
				displayText = {
					name = L["Display Text"],
					type = 'toggle',
					order = 5,
				},
			}
		}
	end

	return config
end

local function GetOptionsTable_Castbar(hasTicks, updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		name = L["Castbar"],
		get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 0,
				type = 'toggle',
				name = L["Enable"],
			},
			reverse = {
				order = 1,
				type = 'toggle',
				name = L["Reverse"],
			},
			width = {
				order = 3,
				name = L["Width"],
				type = 'range',
				softMax = 600,
				min = 50, max = GetScreenWidth(), step = 1,
			},
			height = {
				order = 4,
				name = L["Height"],
				type = 'range',
				min = 5, max = 85, step = 1,
			},
			matchsize = {
				order = 5,
				type = 'execute',
				name = L["Match Frame Width"],
				func = function() E.db.unitframe.units[groupName].castbar.width = E.db.unitframe.units[groupName].width; updateFunc(UF, groupName, numUnits) end,
			},
			forceshow = {
				order = 6,
				name = L["SHOW"]..' / '..L["HIDE"],
				func = function()
					local frameName = gsub('ElvUF_'..E:StringTitle(groupName), 't(arget)', 'T%1')
					if groupName == 'party' then
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
				order = 7,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup('ElvUI', 'unitframe', 'generalOptionsGroup', 'allColorsGroup', 'castBars') end,
			},
			spark = {
				order = 8,
				type = 'toggle',
				name = L["Spark"],
				desc = L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."],
			},
			latency = {
				order = 10,
				name = L["Latency"],
				type = 'toggle',
				hidden = function() return groupName ~= 'player' end,
			},
			format = {
				order = 11,
				type = 'select',
				name = L["Format"],
				desc = L["Cast Time Format"],
				values = {
					CURRENTMAX = L["Current / Max"],
					CURRENT = L["Current"],
					REMAINING = L["Remaining"],
					REMAININGMAX = L["Remaining / Max"],
				},
			},
			timeToHold = {
				order = 12,
				name = L["Time To Hold"],
				desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
				type = 'range',
				min = 0, max = 10, step = .1,
			},
			overlayOnFrame = {
				order = 3,
				type = 'select',
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = {
					Health = L["Health"],
					Power = L["Power"],
					InfoPanel = L["Information Panel"],
					None = L["NONE"],
				},
			},
			textGroup = {
				order = 16,
				type = 'group',
				name = L["Text"],
				inline = true,
				get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
				args = {
					hidetext = {
						order = 1,
						type = 'toggle',
						name = L["Hide Text"],
						desc = L["Hide Castbar text. Useful if your power height is very low or if you use power offset."],
					},
					textColor = {
						order = 2,
						type = 'color',
						name = L["COLOR"],
						hasAlpha = true,
						get = function(info)
							local c = E.db.unitframe.units[groupName].castbar.textColor
							local d = P.unitframe.units[groupName].castbar.textColor
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							local c = E.db.unitframe.units[groupName].castbar.textColor
							c.r, c.g, c.b, c.a = r, g, b, a
							updateFunc(UF, groupName, numUnits)
						end,
					},
					textSettings = {
						order = 2,
						type = 'group',
						name = L["Text Options"],
						inline = true,
						get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
						set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
						args = {
							enable = {
								order = 1,
								type = 'toggle',
								name = L["Custom Font"],
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
							},
							font = {
								order = 2,
								type = 'select',
								dialogControl = 'LSM30_Font',
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end
							},
							fontSize = {
								order = 3,
								type = 'range',
								name = L["Font Size"],
								min = 6, max = 64, step = 1,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end
							},
							fontStyle = {
								order = 4,
								type = 'select',
								name = L["Font Outline"],
								values = C.Values.FontFlags,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end
							},
							xOffsetText = {
								order = 4,
								type = 'range',
								name = L["X-Offset"],
								min = -500, max = 500, step = 1,
							},
							yOffsetText = {
								order = 5,
								type = 'range',
								name = L["Y-Offset"],
								min = -500, max = 500, step = 1,
							},
						},
					},
					timeSettings = {
						order = 3,
						type = 'group',
						name = L["Time Options"],
						inline = true,
						get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
						set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
						args = {
							enable = {
								order = 1,
								type = 'toggle',
								name = L["Custom Font"],
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
							},
							font = {
								order = 2,
								type = 'select',
								dialogControl = 'LSM30_Font',
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end
							},
							fontSize = {
								order = 3,
								type = 'range',
								name = L["Font Size"],
								min = 6, max = 64, step = 1,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end
							},
							fontStyle = {
								order = 4,
								type = 'select',
								name = L["Font Outline"],
								values = C.Values.FontFlags,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end
							},
							xOffsetTime = {
								order = 4,
								type = 'range',
								name = L["X-Offset"],
								min = -500, max = 500, step = 1,
							},
							yOffsetTime = {
								order = 5,
								type = 'range',
								name = L["Y-Offset"],
								min = -500, max = 500, step = 1,
							},
						},
					},
				},
			},
			iconSettings = {
				order = 17,
				type = 'group',
				name = L["Icon"],
				inline = true,
				get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
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
						type = 'toggle',
					},
					iconSize = {
						order = 3,
						name = L["Icon Size"],
						desc = L["This dictates the size of the icon when it is not attached to the castbar."],
						type = 'range',
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
						min = 8, max = 150, step = 1,
					},
					iconAttachedTo = {
						order = 4,
						type = 'select',
						name = L["Attach To"],
						desc = L["The object you want to attach to."],
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
						values = {
							Frame = L["Frame"],
							Castbar = L["Castbar"],
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
						type = 'range',
						name = L["X-Offset"],
						min = -500, max = 500, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
					},
					iconYOffset = {
						order = 6,
						type = 'range',
						name = L["Y-Offset"],
						min = -500, max = 500, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached end,
					},
				},
			},
			strataAndLevel = GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, 'castbar'),
			customColor = {
				order = 21,
				type = 'group',
				name = L["Custom Color"],
				inline = true,
				get = function(info)
					if info.type == 'color' then
						local c = E.db.unitframe.units[groupName].castbar.customColor[info[#info]]
						local d = P.unitframe.units[groupName].castbar.customColor[info[#info]]
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, 1.0
					else
						return E.db.unitframe.units[groupName].castbar.customColor[info[#info]]
					end
				end,
				set = function(info, ...)
					if info.type == 'color' then
						local r, g, b, a = ...
						local c = E.db.unitframe.units[groupName].castbar.customColor[info[#info]]
						c.r, c.g, c.b, c.a = r, g, b, a
					else
						local value = ...
						E.db.unitframe.units[groupName].castbar.customColor[info[#info]] = value
					end

					updateFunc(UF, groupName, numUnits)
				end,
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
					},
					transparent = {
						order = 2,
						type = 'toggle',
						name = L["Transparent"],
						desc = L["Make textures transparent."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end,
					},
					invertColors = {
						order = 3,
						type = 'toggle',
						name = L["Invert Colors"],
						desc = L["Invert foreground and background colors."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable or not E.db.unitframe.units[groupName].castbar.customColor.transparent end,
					},
					spacer1 = ACH:Spacer(4, 'full'),
					useClassColor = {
						order = 5,
						type = 'toggle',
						name = L["Class Color"],
						desc = L["Color castbar by the class of the unit's class."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end,
					},
					useReactionColor = {
						order = 5,
						type = 'toggle',
						name = L["Reaction Color"],
						desc = L["Color castbar by the reaction of the unit to the player."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable or (groupName == 'player' or groupName == 'pet') end,
					},
					useCustomBackdrop = {
						order = 6,
						type = 'toggle',
						name = L["Custom Backdrop"],
						desc = L["Use the custom backdrop color instead of a multiple of the main color."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end,
					},
					spacer2 = ACH:Spacer(7, 'full'),
					colorBackdrop = {
						order = 8,
						type = 'color',
						name = L["Custom Backdrop"],
						desc = L["Use the custom backdrop color instead of a multiple of the main color."],
						disabled = function()
							return not E.db.unitframe.units[groupName].castbar.customColor.enable or not E.db.unitframe.units[groupName].castbar.customColor.useCustomBackdrop
						end,
						hasAlpha = true,
					},
					color = {
						order = 9,
						name = L["Interruptible"],
						type = 'color',
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end,
					},
					colorNoInterrupt = {
						order = 10,
						name = L["Non-Interruptible"],
						type = 'color',
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end,
					},
					spacer3 = ACH:Spacer(11, 'full'),
					colorInterrupted = {
						name = L["Interrupted"],
						order = 12,
						type = 'color',
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end,
					},
				},
			},
		},
	}

	if groupName == 'player' then
		config.args.displayTarget = {
			order = 13,
			type = 'toggle',
			name = L["Display Target"],
			desc = L["Display the target of current cast."],
		}
	end

	if groupName == 'party' then
		config.args.positionsGroup = {
			order = 19,
			type = 'group',
			name = L["Position"],
			get = function(info) return E.db.unitframe.units[groupName].castbar.positionsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units[groupName].castbar.positionsGroup[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
			inline = true,
			args = {
				anchorPoint = {
					type = 'select',
					order = 4,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = positionValues,
				},
				xOffset = {
					order = 5,
					type = 'range',
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
			}
		}
	end

	if hasTicks then
		config.args.ticks = {
			order = 20,
			type = 'group',
			inline = true,
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
					type = 'color',
					name = L["COLOR"],
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
					type = 'range',
					name = L["Width"],
					min = 1, max = 20, step = 1,
				},
			},
		}
	end

	return config
end

local function GetOptionsTable_Cutaway(updateFunc, groupName, numGroup)
	local config = {
		type = 'group',
		childGroups = 'tab',
		name = L["Cutaway Bars"],
		args = {
			health = {
				order = 1,
				type = 'group',
				inline = true,
				name = L["Health"],
				get = function(info) return E.db.unitframe.units[groupName].cutaway.health[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].cutaway.health[info[#info]] = value; updateFunc(UF, groupName, numGroup) end,
				args = {
					enabled = {
						type = 'toggle',
						order = 1,
						name = L["Enable"]
					},
					lengthBeforeFade = {
						type = 'range',
						order = 2,
						name = L["Fade Out Delay"],
						desc = L["How much time before the cutaway health starts to fade."],
						min = 0.1,
						max = 1,
						step = 0.1,
						disabled = function()
							return not E.db.unitframe.units[groupName].cutaway.health.enabled
						end
					},
					fadeOutTime = {
						type = 'range',
						order = 3,
						name = L["Fade Out"],
						desc = L["How long the cutaway health will take to fade out."],
						min = 0.1,
						max = 1,
						step = 0.1,
						disabled = function()
							return not E.db.unitframe.units[groupName].cutaway.health.enabled
						end
					}
				}
			}
		}
	}
	if E.db.unitframe.units[groupName].cutaway.power then
		config.args.power = {
			order = 2,
			type = 'group',
			name = L["Power"],
			inline = true,
			get = function(info) return E.db.unitframe.units[groupName].cutaway.power[info[#info]] end,
			set = function(info, value) E.db.unitframe.units[groupName].cutaway.power[info[#info]] = value; updateFunc(UF, groupName, numGroup) end,
			args = {
				enabled = {
					type = 'toggle',
					order = 1,
					name = L["Enable"]
				},
				lengthBeforeFade = {
					type = 'range',
					order = 2,
					name = L["Fade Out Delay"],
					desc = L["How much time before the cutaway power starts to fade."],
					min = 0.1,
					max = 1,
					step = 0.1,
					disabled = function()
						return not E.db.unitframe.units[groupName].cutaway.power.enabled
					end
				},
				fadeOutTime = {
					type = 'range',
					order = 3,
					name = L["Fade Out"],
					desc = L["How long the cutaway power will take to fade out."],
					min = 0.1,
					max = 1,
					step = 0.1,
					disabled = function()
						return not E.db.unitframe.units[groupName].cutaway.power.enabled
					end
				}
			}
		}
	end

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
		for i = 1, UF[unit]:GetNumChildren() do
			local child = select(i, UF[unit]:GetChildren())

			for x = 1, child:GetNumChildren() do
				local subchild = select(x, child:GetChildren())
				UF:Configure_CustomTexts(subchild)
				subchild:UpdateTags()
			end
		end
	elseif unit == 'boss' or unit == 'arena' then
		for i = 1, 5 do
			UF:Configure_CustomTexts(UF[unit..i])
			UF[unit..i]:UpdateTags()
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

	E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName] = {
		order = -1,
		type = 'group',
		name = objectName,
		get = function(info) return E.db.unitframe.units[unit].customTexts[objectName][info[#info]] end,
		set = function(info, value)
			E.db.unitframe.units[unit].customTexts[objectName][info[#info]] = value
			UpdateCustomTextGroup(unit)
		end,
		args = {
			delete = {
				type = 'execute',
				order = 2,
				name = L["DELETE"],
				func = function()
					E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName] = nil
					E.db.unitframe.units[unit].customTexts[objectName] = nil

					UpdateCustomTextGroup(unit)
				end,
			},
			enable = {
				order = 3,
				type = 'toggle',
				name = L["Enable"],
			},
			font = {
				type = 'select', dialogControl = 'LSM30_Font',
				order = 4,
				name = L["Font"],
				values = _G.AceGUIWidgetLSMlists.font,
			},
			size = {
				order = 5,
				name = L["FONT_SIZE"],
				type = 'range',
				min = 6, max = 64, step = 1,
			},
			fontOutline = {
				order = 6,
				name = L["Font Outline"],
				desc = L["Set the font outline."],
				type = 'select',
				values = C.Values.FontFlags,
			},
			justifyH = {
				order = 7,
				type = 'select',
				name = L["JustifyH"],
				desc = L["Sets the font instance's horizontal text alignment style."],
				values = {
					CENTER = L["Center"],
					LEFT = L["Left"],
					RIGHT = L["Right"],
				},
			},
			xOffset = {
				order = 8,
				type = 'range',
				name = L["X-Offset"],
				min = -400, max = 400, step = 1,
			},
			yOffset = {
				order = 9,
				type = 'range',
				name = L["Y-Offset"],
				min = -400, max = 400, step = 1,
			},
			attachTextTo = {
				type = 'select',
				order = 10,
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
				type = 'input',
				width = 'full',
			},
		},
	}

	if unit == 'player' and UF.player.AdditionalPower then
		E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].args.attachTextTo.values.AdditionalPower = L["Additional Power"]
	end

	tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName]) --Register this custom text config to be hidden on profile change
end

local function GetOptionsTable_CustomText(updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		childGroups = 'tab',
		name = L["Custom Texts"],
		args = {
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
						E.db.unitframe.units[groupName].customTexts = {}
					end

					local frameName = 'ElvUF_'..E:StringTitle(groupName)
					if E.db.unitframe.units[groupName].customTexts[textName] or (_G[frameName] and _G[frameName].customTexts and _G[frameName].customTexts[textName] or _G[frameName..'Group1UnitButton1'] and _G[frameName..'Group1UnitButton1'].customTexts and _G[frameName..'Group1UnitButton1'][textName]) then
						E:Print(L["The name you have selected is already in use by another element."])
						return
					end

					E.db.unitframe.units[groupName].customTexts[textName] = {
						text_format = strmatch(textName, '^%[') and textName or '',
						size = E.db.unitframe.fontSize,
						font = E.db.unitframe.font,
						xOffset = 0,
						yOffset = 0,
						justifyH = 'CENTER',
						fontOutline = E.db.unitframe.fontOutline,
						attachTextTo = 'Health'
					}

					CreateCustomTextGroup(groupName, textName)
					updateFunc(UF, groupName, numUnits)

					E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'unitframe', individual[groupName] and 'individualUnits' or 'groupUnits', groupName, 'customText', textName)
				end,
			},
		},
	}

	return config
end

local function GetOptionsTable_Fader(updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		name = L["Fader"],
		get = function(info) return E.db.unitframe.units[groupName].fader[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].fader[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			range = {
				type = 'toggle',
				order = 3,
				name = L["Range"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end,
				hidden = function() return groupName == 'player' end,
			},
			hover = {
				type = 'toggle',
				order = 4,
				name = L["Hover"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			combat = {
				type = 'toggle',
				order = 5,
				name = L["Combat"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			unittarget = {
				type = 'toggle',
				order = 6,
				name = L["Unit Target"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
				hidden = function() return groupName == 'player' end,
			},
			playertarget = {
				type = 'toggle',
				order = 7,
				name = (groupName == 'player' and L["Target"]) or L["Player Target"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			focus = {
				type = 'toggle',
				order = 8,
				name = L["Focus"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			health = {
				type = 'toggle',
				order = 9,
				name = L["Health"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			power = {
				type = 'toggle',
				order = 10,
				name = L["Power"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			vehicle = {
				type = 'toggle',
				order = 11,
				name = L["Vehicle"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			casting = {
				type = 'toggle',
				order = 12,
				name = L["Casting"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			spacer = ACH:Spacer(13, 'full'),
			delay = {
				order = 14,
				name = L["Fade Out Delay"],
				type = 'range',
				min = 0, max = 3, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
			},
			smooth = {
				order = 15,
				name = L["Smooth"],
				type = 'range',
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end,
			},
			minAlpha = {
				order = 16,
				name = L["Min Alpha"],
				type = 'range',
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end,
			},
			maxAlpha = {
				order = 17,
				name = L["Max Alpha"],
				type = 'range',
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end,
			},
		},
	}

	return config
end

local function GetOptionsTable_Health(isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		name = L["Health"],
		get = function(info) return E.db.unitframe.units[groupName].health[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].health[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			reverseFill = {
				type = 'toggle',
				order = 1,
				name = L["Reverse Fill"],
			},
			attachTextTo = {
				type = 'select',
				order = 3,
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
			},
			colorOverride = {
				order = 4,
				name = L["Class Color Override"],
				desc = L["Override the default class color setting."],
				type = 'select',
				values = colorOverrideValues,
				get = function(info) return E.db.unitframe.units[groupName][info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName][info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
			},
			configureButton = {
				order = 5,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup('ElvUI', 'unitframe', 'generalOptionsGroup', 'allColorsGroup', 'healthGroup') end,
			},
			textGroup = {
				type = 'group',
				name = L["Text Options"],
				inline = true,
				args = {
					position = {
						type = 'select',
						order = 1,
						name = L["Position"],
						values = positionValues,
					},
					xOffset = {
						order = 2,
						type = 'range',
						name = L["X-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1,
					},
					yOffset = {
						order = 3,
						type = 'range',
						name = L["Y-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1,
					},
					text_format = {
						order = 4,
						name = L["Text Format"],
						desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
						type = 'input',
						width = 'full',
					},
				},
			},
		},
	}

	if isGroupFrame then
		config.args.orientation = {
			type = 'select',
			order = 9,
			name = L["Statusbar Fill Orientation"],
			desc = L["Direction the health bar moves when gaining/losing health."],
			values = {
				HORIZONTAL = L["Horizontal"],
				VERTICAL = L["Vertical"],
			},
		}
	end

	if groupName == 'pet' or groupName == 'raidpet' then
		config.args.colorPetByUnitClass = {
			type = 'toggle',
			order = 2,
			name = L["Color by Unit Class"],
		}
	end

	return config
end

local function GetOptionsTable_HealPrediction(updateFunc, groupName, numGroup, subGroup)
	local config = {
		type = 'group',
		name = L["Heal Prediction"],
		desc = L["Show an incoming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
		get = function(info) return E.db.unitframe.units[groupName].healPrediction[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].healPrediction[info[#info]] = value; updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 1,
				type = 'toggle',
				name = L["Enable"],
			},
			height = {
				type = 'range',
				order = 2,
				name = L["Height"],
				min = -1, max = 500, step = 1,
			},
			colorsButton = {
				order = 3,
				type = 'execute',
				name = L["COLORS"],
				func = function() ACD:SelectGroup('ElvUI', 'unitframe', 'generalOptionsGroup', 'allColorsGroup', 'healPrediction') end,
				disabled = function() return not E.UnitFrames.Initialized end,
			},
			anchorPoint = {
				order = 5,
				type = 'select',
				name = L["Anchor Point"],
				values = {
					TOP = 'TOP',
					BOTTOM = 'BOTTOM',
					CENTER = 'CENTER'
				}
			},
			absorbStyle = {
				order = 6,
				type = 'select',
				name = L["Absorb Style"],
				values = {
					NONE = L["NONE"],
					NORMAL = L["Normal"],
					REVERSED = L["Reversed"],
					WRAPPED = L["Wrapped"],
					OVERFLOW = L["Overflow"]
				},
			},
			overflowButton = {
				order = 7,
				type = 'execute',
				name = L["Max Overflow"],
				func = function() ACD:SelectGroup('ElvUI', 'unitframe', 'generalOptionsGroup', 'allColorsGroup', 'healPrediction') end,
				disabled = function() return not E.UnitFrames.Initialized end,
			},
			warning = ACH:Description(function()
				if E.db.unitframe.colors.healPrediction.maxOverflow == 0 then
					local text = L["Max Overflow is set to zero. Absorb Overflows will be hidden when using Overflow style.\nIf used together Max Overflow at zero and Overflow mode will act like Normal mode without the ending sliver of overflow."]
					return text .. (E.db.unitframe.units[groupName].healPrediction.absorbStyle == 'OVERFLOW' and ' |cffFF9933You are using Overflow with Max Overflow at zero.|r ' or '')
				end
			end, 50, 'medium', nil, nil, nil, nil, 'full'),
		},
	}

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].healPrediction[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].healPrediction[info[#info]] = value; updateFunc(UF, groupName, numGroup) end
	end

	return config
end

local function GetOptionsTable_InformationPanel(updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		name = L["Information Panel"],
		get = function(info) return E.db.unitframe.units[groupName].infoPanel[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].infoPanel[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
			},
			transparent = {
				type = 'toggle',
				order = 3,
				name = L["Transparent"],
			},
			height = {
				type = 'range',
				order = 4,
				name = L["Height"],
				min = 2, max = 30, step = 1,
			},
		}
	}

	return config
end

local function GetOptionsTable_Name(updateFunc, groupName, numUnits, subGroup)
	local config = {
		type = 'group',
		name = L["Name"],
		get = function(info) return E.db.unitframe.units[groupName].name[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].name[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			position = {
				type = 'select',
				order = 2,
				name = L["Position"],
				values = positionValues,
			},
			xOffset = {
				order = 3,
				type = 'range',
				name = L["X-Offset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 4,
				type = 'range',
				name = L["Y-Offset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1,
			},
			attachTextTo = {
				type = 'select',
				order = 5,
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
				type = 'input',
				width = 'full',
			},
		},
	}


	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].name[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].name[info[#info]] = value; updateFunc(UF, groupName, numUnits) end
	end

	return config
end

local function GetOptionsTable_PhaseIndicator(updateFunc, groupName, numGroup)
	local config = {
		type = 'group',
		name = L["Phase Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].phaseIndicator[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].phaseIndicator[info[#info]] = value; updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = 'toggle',
				name = L["Enable"],
			},
			scale = {
				order = 3,
				type = 'range',
				name = L["Scale"],
				isPercent = true,
				min = 0.5, max = 1.5, step = 0.01,
			},
			anchorPoint = {
				order = 5,
				type = 'select',
				name = L["Anchor Point"],
				values = positionValues,
			},
			xOffset = {
				order = 6,
				type = 'range',
				name = L["X-Offset"],
				min = -100, max = 100, step = 1,
			},
			yOffset = {
				order = 7,
				type = 'range',
				name = L["Y-Offset"],
				min = -100, max = 100, step = 1,
			},
		},
	}

	return config
end

local function GetOptionsTable_Portrait(updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		name = L["Portrait"],
		get = function(info) return E.db.unitframe.units[groupName].portrait[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].portrait[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			warning = ACH:Description(function() return (E.db.unitframe.units[groupName].orientation == 'MIDDLE' and L["Overlay mode is forced when the Frame Orientation is set to Middle."]) or '' end, 1, 'medium', nil, nil, nil, nil, 'full'),
			enable = {
				type = 'toggle',
				order = 2,
				name = L["Enable"],
				desc = L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."],
				confirmText = L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."],
				confirm = true
			},
			paused = {
				order = 3,
				type = 'toggle',
				name = L["Pause"],
				disabled = function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end,
			},
			overlay = {
				order = 4,
				type = 'toggle',
				name = L["Overlay"],
				desc = L["The Portrait will overlay the Healthbar. This will be automatically happen if the Frame Orientation is set to Middle."],
				get = function(info) return (E.db.unitframe.units[groupName].orientation == 'MIDDLE') or E.db.unitframe.units[groupName].portrait[info[#info]] end,
				disabled = function() return E.db.unitframe.units[groupName].orientation == 'MIDDLE' end
			},
			fullOverlay = {
				order = 5,
				type = 'toggle',
				name = L["Full Overlay"],
				desc = L["This option allows the overlay to span the whole health, including the background."],
				disabled = function() return not (E.db.unitframe.units[groupName].orientation == 'MIDDLE' or E.db.unitframe.units[groupName].portrait.overlay) end,
			},
			style = {
				order = 6,
				type = 'select',
				name = L["Style"],
				desc = L["Select the display method of the portrait."],
				values = {
					['2D'] = L["2D"],
					['3D'] = L["3D"],
					['Class'] = L["Class"],
				},
			},
			width = {
				order = 7,
				type = 'range',
				name = L["Width"],
				min = 15, max = 150, step = 1,
				disabled = function() return (E.db.unitframe.units[groupName].orientation == 'MIDDLE' or E.db.unitframe.units[groupName].portrait.overlay) end,
			},
			overlayAlpha = {
				order = 8,
				type = 'range',
				name = L["Overlay Alpha"],
				desc = L["Set the alpha level of portrait when frame is overlayed."],
				min = 0.01, max = 1, step = 0.01,
				disabled = function() return not (E.db.unitframe.units[groupName].orientation == 'MIDDLE' or E.db.unitframe.units[groupName].portrait.overlay) end,
			},
			rotation = {
				order = 9,
				type = 'range',
				name = L["Model Rotation"],
				min = 0, max = 360, step = 1,
				disabled = function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end,
			},
			desaturation = {
				order = 10,
				type = 'range',
				name = L["Desaturate"],
				min = 0, max = 1, step = 0.01,
				disabled = function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end,
			},
			camDistanceScale = {
				order = 11,
				type = 'range',
				name = L["Camera Distance Scale"],
				desc = L["How far away the portrait is from the camera."],
				min = 0.01, max = 4, step = 0.01,
				disabled = function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end,
			},
			xOffset = {
				order = 12,
				type = 'range',
				name = L["X-Offset"],
				desc = L["Position the Model horizontally."],
				min = -1, max = 1, step = 0.01,
				disabled = function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end,
			},
			yOffset = {
				order = 13,
				type = 'range',
				name = L["Y-Offset"],
				desc = L["Position the Model vertically."],
				min = -1, max = 1, step = 0.01,
				disabled = function() return E.db.unitframe.units[groupName].portrait.style ~= '3D' end,
			},
		},
	}

	return config
end

local function GetOptionsTable_Power(hasDetatchOption, updateFunc, groupName, numUnits, hasStrataLevel)
	local config = {
		type = 'group',
		name = L["Power"],
		get = function(info) return E.db.unitframe.units[groupName].power[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].power[info[#info]] = value; updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
			},
			attachTextTo = {
				type = 'select',
				order = 2,
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
			},
			width = {
				type = 'select',
				order = 3,
				name = L["Style"],
				values = {
					fill = L["Filled"],
					spaced = L["Spaced"],
					inset = L["Inset"],
					offset = L["Offset"],
				},
				set = function(info, value)
					E.db.unitframe.units[groupName].power[info[#info]] = value

					local frameName = gsub('ElvUF_'..E:StringTitle(groupName), 't(arget)', 'T%1')
					if numUnits then
						for i=1, numUnits do
							local frame = _G[frameName..i]
							if frame and frame.Power then
								local min, max = frame.Power:GetMinMaxValues()
								frame.Power:SetMinMaxValues(min, max+500)
								frame.Power:SetValue(1)
								frame.Power:SetValue(0)
							end
						end
					else
						local frame = _G[frameName]
						if frame then
							if frame.Power then
								local min, max = frame.Power:GetMinMaxValues()
								frame.Power:SetMinMaxValues(min, max+500)
								frame.Power:SetValue(1)
								frame.Power:SetValue(0)
							else
								for i=1, frame:GetNumChildren() do
									local child = select(i, frame:GetChildren())
									if child and child.Power then
										local min, max = child.Power:GetMinMaxValues()
										child.Power:SetMinMaxValues(min, max+500)
										child.Power:SetValue(1)
										child.Power:SetValue(0)
									end
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
				min = 2, max = 50, step = 1,
				hidden = function() return E.db.unitframe.units[groupName].power.width == 'offset' end,
			},
			powerPrediction = {
				type = 'toggle',
				order = 5,
				name = L["Power Prediction"],
			},
			offset = {
				type = 'range',
				name = L["Offset"],
				desc = L["Offset of the powerbar to the healthbar, set to 0 to disable."],
				order = 6,
				min = 0, max = 20, step = 1,
				hidden = function() return E.db.unitframe.units[groupName].power.width ~= 'offset' end,
			},
			reverseFill = {
				type = 'toggle',
				order = 7,
				name = L["Reverse Fill"],
			},
			configureButton = {
				order = 10,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = 'execute',
				func = function() ACD:SelectGroup('ElvUI', 'unitframe', 'generalOptionsGroup', 'allColorsGroup', 'powerGroup') end,
			},
			textGroup = {
				type = 'group',
				name = L["Text Options"],
				inline = true,
				args = {
					position = {
						type = 'select',
						order = 1,
						name = L["Position"],
						values = positionValues,
					},
					xOffset = {
						order = 2,
						type = 'range',
						name = L["X-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1,
					},
					yOffset = {
						order = 3,
						type = 'range',
						name = L["Y-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1,
					},
					text_format = {
						order = 4,
						name = L["Text Format"],
						desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
						type = 'input',
						width = 'full',
					},
				},
			},
		},
	}

	if hasDetatchOption then
		config.args.detachFromFrame = {
			type = 'toggle',
			order = 90,
			name = L["Detach From Frame"],
		}
		config.args.autoHide = {
			order = 91,
			type = 'toggle',
			name = L["Auto-Hide"],
			hidden = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
		}
		config.args.detachedWidth = {
			type = 'range',
			order = 92,
			name = L["Detached Width"],
			hidden = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
			min = 15, max = 1000, step = 1,
		}
		config.args.parent = {
			type = 'select',
			order = 93,
			name = L["Parent"],
			desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
			hidden = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
			values = {
				FRAME = 'FRAME',
				UIPARENT = 'UIPARENT',
			},
		}
	end

	if hasStrataLevel then
		config.args.strataAndLevel = GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, 'power')
	end

	if groupName == 'party' or groupName == 'raid' or groupName == 'raid40' then
		config.args.displayAltPower = {
			type = 'toggle',
			order = 9,
			name = L["Swap to Alt Power"],
		}
	end

	return config
end

local function GetOptionsTable_PVPClassificationIndicator(updateFunc, groupName, numGroup)
	local config = {
		name = L["PvP Classification Indicator"],
		desc = L["Cart / Flag / Orb / Assassin Bounty"],
		type = 'group',
		get = function(info)
			return E.db.unitframe.units[groupName].pvpclassificationindicator[info[#info]]
		end,
		set = function(info, value)
			E.db.unitframe.units[groupName].pvpclassificationindicator[info[#info]] = value
			updateFunc(UF, groupName, numGroup)
		end,
		args = {
			enable = {
				order = 1,
				name = L["Enable"],
				type = 'toggle'
			},
			size = {
				order = 2,
				name = L["Size"],
				type = 'range',
				min = 5,
				max = 100,
				step = 1
			},
			position = {
				order = 3,
				type = 'select',
				name = L["Icon Position"],
				values = {
					CENTER = 'CENTER',
					TOPLEFT = 'TOPLEFT',
					BOTTOMLEFT = 'BOTTOMLEFT',
					TOPRIGHT = 'TOPRIGHT',
					BOTTOMRIGHT = 'BOTTOMRIGHT'
				}
			},
			xOffset = {
				order = 4,
				name = L["X-Offset"],
				type = 'range',
				min = -100,
				max = 100,
				step = 1
			},
			yOffset = {
				order = 5,
				name = L["Y-Offset"],
				type = 'range',
				min = -100,
				max = 100,
				step = 1
			}
		}
	}

	return config
end

local function GetOptionsTable_PVPIcon(updateFunc, groupName, numGroup)
	local config = {
		type = 'group',
		name = L["PvP & Prestige Icon"],
		get = function(info) return E.db.unitframe.units[groupName].pvpIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].pvpIcon[info[#info]] = value; updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = 'toggle',
				name = L["Enable"],
			},
			scale = {
				order = 3,
				type = 'range',
				name = L["Scale"],
				isPercent = true,
				min = 0.1, max = 2, step = 0.01,
			},
			anchorPoint = {
				order = 5,
				type = 'select',
				name = L["Anchor Point"],
				values = positionValues,
			},
			xOffset = {
				order = 6,
				type = 'range',
				name = L["X-Offset"],
				min = -100, max = 100, step = 1,
			},
			yOffset = {
				order = 7,
				type = 'range',
				name = L["Y-Offset"],
				min = -100, max = 100, step = 1,
			},
		},
	}

	return config
end

local function GetOptionsTable_RaidDebuff(updateFunc, groupName)
	local config = {
		type = 'group',
		name = L["RaidDebuff Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].rdebuffs[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].rdebuffs[info[#info]] = value; updateFunc(UF, groupName) end,
		args = {
			enable = {
				order = 2,
				type = 'toggle',
				name = L["Enable"],
			},
			showDispellableDebuff = {
				order = 3,
				type = 'toggle',
				name = L["Show Dispellable Debuffs"],
			},
			onlyMatchSpellID = {
				order = 4,
				type = 'toggle',
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
				type = 'select', dialogControl = 'LSM30_Font',
				name = L["Font"],
				values = _G.AceGUIWidgetLSMlists.font,
			},
			fontSize = {
				order = 6,
				type = 'range',
				name = L["FONT_SIZE"],
				min = 6, max = 64, step = 1,
			},
			fontOutline = {
				order = 7,
				type = 'select',
				name = L["Font Outline"],
				values = C.Values.FontFlags,
			},
			xOffset = {
				order = 8,
				type = 'range',
				name = L["X-Offset"],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 9,
				type = 'range',
				name = L["Y-Offset"],
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
				type = 'group',
				inline = true,
				name = L["Duration Text"],
				get = function(info) return E.db.unitframe.units[groupName].rdebuffs.duration[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].rdebuffs.duration[info[#info]] = value; updateFunc(UF, groupName) end,
				args = {
					position = {
						order = 1,
						type = 'select',
						name = L["Position"],
						values = positionValues,
					},
					xOffset = {
						order = 2,
						type = 'range',
						name = L["X-Offset"],
						min = -10, max = 10, step = 1,
					},
					yOffset = {
						order = 3,
						type = 'range',
						name = L["Y-Offset"],
						min = -10, max = 10, step = 1,
					},
					color = {
						order = 4,
						type = 'color',
						name = L["COLOR"],
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
				type = 'group',
				inline = true,
				name = L["Stack Counter"],
				get = function(info) return E.db.unitframe.units[groupName].rdebuffs.stack[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].rdebuffs.stack[info[#info]] = value; updateFunc(UF, groupName) end,
				args = {
					position = {
						order = 1,
						type = 'select',
						name = L["Position"],
						values = positionValues,
					},
					xOffset = {
						order = 2,
						type = 'range',
						name = L["X-Offset"],
						min = -10, max = 10, step = 1,
					},
					yOffset = {
						order = 3,
						type = 'range',
						name = L["Y-Offset"],
						min = -10, max = 10, step = 1,
					},
					color = {
						order = 4,
						type = 'color',
						name = L["COLOR"],
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

local function GetOptionsTable_RaidIcon(updateFunc, groupName, numUnits, subGroup)
	local config = ACH:Group(L["Target Marker Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].raidicon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].raidicon[info[#info]] = value; updateFunc(UF, groupName, numUnits) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.unitframe.units[groupName][subGroup].raidicon[info[#info]] end
		config.set = function(info, value) E.db.unitframe.units[groupName][subGroup].raidicon[info[#info]] = value; updateFunc(UF, groupName, numUnits) end
	end

	return config
end

local function GetOptionsTable_RoleIcons(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Role Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].roleIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].roleIcon[info[#info]] = value; updateFunc(UF, groupName, numGroup) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.options = ACH:MultiSelect(' ', nil, 1, { tank = L["Show For Tanks"], healer = L["Show For Healers"], damager = L["Show For DPS"], combatHide = L["Hide In Combat"] }, nil, nil, function(_, key) return E.db.unitframe.units[groupName].roleIcon[key] end, function(_, key, value) E.db.unitframe.units[groupName].roleIcon[key] = value; updateFunc(UF, groupName, numGroup) end)
	config.args.position = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.attachTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_RaidRoleIcons(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Leader Indicator"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].raidRoleIcons[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].raidRoleIcons[info[#info]] = value; updateFunc(UF, groupName, numGroup) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.position = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ReadyCheckIcon(updateFunc, groupName)
	local config = ACH:Group(L["Ready Check Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].readycheckIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].readycheckIcon[info[#info]] = value; updateFunc(UF, groupName) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ResurrectIcon(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Resurrect Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].resurrectIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].resurrectIcon[info[#info]] = value; updateFunc(UF, groupName, numUnits) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_SummonIcon(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Summon Icon"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].summonIcon[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].summonIcon[info[#info]] = value; updateFunc(UF, groupName, numUnits) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.attachTo = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.attachToObject = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ClassBar(updateFunc, groupName, numUnits)
	local config = ACH:Group(L["Classbar"], nil, nil, nil, function(info) return E.db.unitframe.units[groupName].classbar[info[#info]] end, function(info, value) E.db.unitframe.units[groupName].classbar[info[#info]] = value; updateFunc(UF, groupName, numUnits) end)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.height = {
				type = 'range',
				order = 3,
				name = L["Height"],
				min = 2, max = 30, step = 1,
			}
	config.args.fill = {
				type = 'select',
				order = 4,
				name = L["Fill"],
				values = {
					fill = L["Filled"],
					spaced = L["Spaced"],
				},
			}

	if groupName == 'party' or groupName == 'raid' or groupName == 'raid40' then
		config.args.altPowerColor = {
			get = function(info)
				local t = E.db.unitframe.units[groupName].classbar[info[#info]]
				local d = P.unitframe.units[groupName].classbar[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local t = E.db.unitframe.units[groupName].classbar[info[#info]]
				t.r, t.g, t.b = r, g, b
				UF:Update_AllFrames()
			end,
			order = 5,
			name = L["COLOR"],
			type = 'color',
		}
		config.args.altPowerTextFormat = {
			order = 6,
			name = L["Text Format"],
			desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
			type = 'input',
			width = 'full',
		}
	elseif groupName == 'player' then
		config.args.height.max = (E.db.unitframe.units[groupName].classbar.detachFromFrame and 300 or 30)
		config.args.autoHide = {
			order = 5,
			type = 'toggle',
			name = L["Auto-Hide"],
		}
		config.args.spacer = ACH:Spacer(10)
		config.args.detachGroup = {
			order = 20,
			type = 'group',
			name = L["Detach From Frame"],
			get = function(info) return E.db.unitframe.units.player.classbar[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.classbar[info[#info]] = value; UF:CreateAndUpdateUF('player') end,
			hidden = groupName ~= 'player',
			inline = true,
			args = {
				detachFromFrame = {
					type = 'toggle',
					order = 1,
					name = L["Enable"],
					width = 'full',
					set = function(info, value)
						E.Options.args.unitframe.args.individualUnits.args.player.args.classbar.args.height.max = (value and 300) or 30
						E.db.unitframe.units.player.classbar[info[#info]] = value
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
						HORIZONTAL = L["Horizontal"],
						VERTICAL = L["Vertical"],
					},
				},
				verticalOrientation = {
					order = 4,
					type = 'toggle',
					name = L["Vertical Fill Direction"],
					disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
				},
				spacing = {
					order = 5,
					type = 'range',
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
						FRAME = 'FRAME',
						UIPARENT = 'UIPARENT',
					},
				},
				strataAndLevel = GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits, 'classbar'),
			},
		}
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
		config.args.hideonnpc = ACH:Toggle(L["Text Toggle On NPC"], L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."], 5, nil, nil, nil, function() return E.db.unitframe.units[groupName].power.hideonnpc end, function(_, value) E.db.unitframe.units[groupName].power.hideonnpc = value; updateFunc(UF, groupName, numUnits) end)
	end

	if groupName ~= 'party' and groupName ~= 'raid' and groupName ~= 'raid40' and groupName ~= 'raidpet' and groupName ~= 'assist' and groupName ~= 'tank' then
		config.args.smartAuraPosition = ACH:Select(L["Smart Aura Position"], L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."], 6, smartAuraPositionValues)
	end

	if groupName ~= 'arena' then
		config.args.threatStyle = ACH:Select(L["Threat Display Mode"], nil, 7, threatValues)
	end

	config.args.positionsGroup = ACH:Group(L["Size and Positions"], nil, 100, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value; updateFunc(UF, groupName, numUnits) end)
	config.args.positionsGroup.inline = true
	config.args.positionsGroup.args.width = ACH:Range(L["Width"], nil, 1, { min = 50, max = 1000, step = 1 })
	config.args.positionsGroup.args.height = ACH:Range(L["Height"], nil, 2, { min = 5, max = 500, step = 1 })

	if groupName == 'party' or groupName == 'raid' or groupName == 'raid40' or groupName == 'raidpet' then
		config.args.positionsGroup.args.growthDirection = ACH:Select(L["Growth Direction"], L["Growth direction from the first unitframe."], 4, growthDirectionValues)
		config.args.positionsGroup.args.numGroups = ACH:Range(L["Number of Groups"], nil, 7, { min = 1, max = 8, step = 1 }, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) if UF[groupName].isForced then UF:HeaderConfig(UF[groupName]) UF:HeaderConfig(UF[groupName], true) end end)
		config.args.positionsGroup.args.groupsPerRowCol = ACH:Range(L["Groups Per Row/Column"], nil, 8, { min = 1, max = 8, step = 1 }, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) if UF[groupName].isForced then UF:HeaderConfig(UF[groupName]) UF:HeaderConfig(UF[groupName], true) end end)
		config.args.positionsGroup.args.horizontalSpacing = ACH:Range(L["Horizontal Spacing"], nil, 9, { min = -1, max = 50, step = 1 })
		config.args.positionsGroup.args.verticalSpacing = ACH:Range(L["Vertical Spacing"], nil, 10, { min = -1, max = 50, step = 1 })
		config.args.positionsGroup.args.groupSpacing = ACH:Range(L["Group Spacing"], L["Additional spacing between each individual group."], 11, { min = 0, max = 50, step = 1 })

		config.args.visibilityGroup = ACH:Group(L["Visibility"], nil, 200, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end)
		config.args.visibilityGroup.inline = true
		config.args.visibilityGroup.args.showPlayer = ACH:Toggle(L["Display Player"], L["When true, the header includes the player when not in a raid."], 0)
		config.args.visibilityGroup.args.defaults = ACH:Execute(L["Restore Defaults"], nil, 1, function() E.db.unitframe.units[groupName].visibility = P.unitframe.units[groupName].visibility updateFunc(UF, groupName, numUnits) end, nil, true)
		config.args.visibilityGroup.args.visibility = ACH:Input(L["Visibility"], L["VISIBILITY_DESC"], 2, nil, 'full')

		config.args.sortingGroup = ACH:Group(L["Grouping & Sorting"], nil, 300, nil, nil, function(info, value) E.db.unitframe.units[groupName][info[#info]] = value; updateFunc(UF, groupName, numUnits) end)
		config.args.sortingGroup.inline = true
		config.args.sortingGroup.args.raidWideSorting = ACH:Toggle(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], 1)
		config.args.sortingGroup.args.invertGroupingOrder = ACH:Toggle(L["Invert Grouping Order"], L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."], 2, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].raidWideSorting end)
		config.args.sortingGroup.args.startFromCenter = ACH:Toggle(L["Start Near Center"], L["The initial group will start near the center and grow out."], 3, nil, nil, nil, nil, nil, nil, function() return not E.db.unitframe.units[groupName].raidWideSorting end)
		config.args.sortingGroup.args.groupBy = ACH:Select(L["Group By"], L["Set the order that the group will sort."], 4, { CLASS = L["CLASS"], ROLE = L["Role"], NAME = L["NAME"], GROUP = L["GROUP"], INDEX = L["Index"] })
		config.args.sortingGroup.args.sortDir = ACH:Select(L["Sort Direction"], nil, 5, { ASC = L["Ascending"], DESC = L["Descending"] })
		config.args.sortingGroup.args.sortMethod = ACH:Select(L["Sort Method"], nil, 6, { NAME = L["NAME"], INDEX = L["Index"] }, nil, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].groupBy == 'INDEX' or E.db.unitframe.units[groupName].groupBy == 'NAME' end)

		config.args.sortingGroup.args.roleSetup = ACH:Group(L["Role Order"], nil, 7, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].groupBy ~= 'ROLE' end)
		config.args.sortingGroup.args.roleSetup.inline = true
		config.args.sortingGroup.args.roleSetup.args.ROLE1 = ACH:Select(' ', nil, 1, { TANK = L["Tank"] , HEALER = L["Healer"], DAMAGER = L["DPS"] })
		config.args.sortingGroup.args.roleSetup.args.ROLE2 = ACH:Select(' ', nil, 2, { TANK = L["Tank"] , HEALER = L["Healer"], DAMAGER = L["DPS"] })
		config.args.sortingGroup.args.roleSetup.args.ROLE3 = ACH:Select(' ', nil, 3, { TANK = L["Tank"] , HEALER = L["Healer"], DAMAGER = L["DPS"] })

		config.args.sortingGroup.args.classSetup = ACH:Group(L["Class Order"], nil, 7, nil, nil, nil, nil, function() return E.db.unitframe.units[groupName].groupBy ~= 'CLASS' end)
		config.args.sortingGroup.args.classSetup.inline = true

		local classTable = {}
		for i = 1, GetNumClasses() do
			local classDisplayName, classTag = GetClassInfo(i)
			classTable[classTag] = classDisplayName
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

	if groupName == 'raid' or groupName == 'raid40' or groupName == 'raidpet' then
		config.args.positionsGroup.args.numGroups.disabled = function() return E.db.unitframe.smartRaidFilter end
		config.args.visibilityGroup.args.visibility.disabled = function() return E.db.unitframe.smartRaidFilter end
	end

	if (groupName == 'target' or groupName == 'boss' or groupName == 'tank' or groupName == 'arena' or groupName == 'assist') and not E:IsAddOnEnabled('Clique') then
		config.args.middleClickFocus = ACH:Toggle(L["Middle Click - Set Focus"], L["Middle clicking the unit frame will cause your focus to match the unit."], 16)
	end

	return config
end

local function GetOptionsTable_CombatIconGroup(updateFunc, groupName, numUnits)
	local config = {
		type = 'group',
		name = L["Combat Icon"],
		get = function(info) return E.db.unitframe.units[groupName].CombatIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].CombatIcon[info[#info]] = value updateFunc(UF, groupName, numUnits) UF:TestingDisplay_CombatIndicator(UF[groupName]) end,
		args = {
			enable = ACH:Toggle(L["Enable"], nil, 0),
			defaultColor = {
				order = 3,
				type = 'toggle',
				name = L["Default Color"],
			},
			color = {
				order = 4,
				type = 'color',
				name = L["COLOR"],
				hasAlpha = true,
				disabled = function() return E.db.unitframe.units[groupName].CombatIcon.defaultColor end,
				get = function() local c = E.db.unitframe.units[groupName].CombatIcon.color local d = P.unitframe.units[groupName].CombatIcon.color return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end,
				set = function(_, r, g, b, a) local c = E.db.unitframe.units[groupName].CombatIcon.color c.r, c.g, c.b, c.a = r, g, b, a updateFunc(UF, groupName, numUnits) UF:TestingDisplay_CombatIndicator(UF[groupName]) end,
			},
			size = {
				order = 5,
				type = 'range',
				name = L["Size"],
				min = 10, max = 60, step = 1,
			},
			xOffset = {
				order = 6,
				type = 'range',
				name = L["X-Offset"],
				min = -100, max = 100, step = 1,
			},
			yOffset = {
				order = 7,
				type = 'range',
				name = L["Y-Offset"],
				min = -100, max = 100, step = 1,
			},
			anchorPoint = {
				order = 9,
				type = 'select',
				name = L["Anchor Point"],
				values = positionValues,
			},
			texture = {
				order = 10,
				type = 'select',
				sortByValue = true,
				name = L["Texture"],
				values = {
					CUSTOM = L["CUSTOM"],
					DEFAULT = L["DEFAULT"],
					COMBAT = E:TextureString(E.Media.Textures.Combat, ':14'),
					PLATINUM = [[|TInterface\Challenges\ChallengeMode_Medal_Platinum:14|t]],
					ATTACK = [[|TInterface\CURSOR\Attack:14|t]],
					ALERT = [[|TInterface\DialogFrame\UI-Dialog-Icon-AlertNew:14|t]],
					ALERT2 = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14|t]],
					ARTHAS =[[|TInterface\LFGFRAME\UI-LFR-PORTRAIT:14|t]],
					SKULL = [[|TInterface\LootFrame\LootPanel-Icon:14|t]],
				},
			},
			customTexture = {
				type = 'input',
				order = 11,
				customWidth = 250,
				name = L["Custom Texture"],
				disabled = function()
					return E.db.unitframe.units[groupName].CombatIcon.texture ~= 'CUSTOM'
				end,
				set = function(_, value)
					E.db.unitframe.units[groupName].CombatIcon.customTexture = (value and (not value:match('^%s-$')) and value) or nil
					updateFunc(UF, groupName, numUnits)
					UF:TestingDisplay_CombatIndicator(UF[groupName])
				end
			},
		},
	}

	return config
end

local filterList = {}
local function modifierList()
	wipe(filterList)

	filterList.NONE = L["NONE"]
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

E.Options.args.unitframe = {
	type = 'group',
	name = L["UnitFrames"],
	childGroups = 'tab',
	order = 2,
	get = function(info) return E.db.unitframe[info[#info]] end,
	set = function(info, value) E.db.unitframe[info[#info]] = value end,
	args = {
		intro = ACH:Description(L["UNITFRAME_DESC"], 0),
		enable = {
			order = 1,
			type = 'toggle',
			name = L["Enable"],
			get = function(info) return E.private.unitframe.enable end,
			set = function(info, value) E.private.unitframe.enable = value; E:StaticPopup_Show('PRIVATE_RL') end
		},
		generalOptionsGroup = {
			order = 3,
			type = 'group',
			childGroups = 'tab',
			name = L["General"],
			args = {
				generalGroup = {
					order = 2,
					type = 'group',
					name = L["General"],
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						resetFilters = {
							order = 1,
							name = L["Reset Aura Filters"],
							type = 'execute',
							func = function(info)
								E:StaticPopup_Show('RESET_UF_AF') --reset unitframe aurafilters
							end,
						},
						borderOptions = {
							order = 2,
							name = L["Border Options"],
							type = 'execute',
							func = function() ACD:SelectGroup('ElvUI', 'general', 'media') end,
						},
						spacer1 = ACH:Spacer(6, 'full'),
						smartRaidFilter = {
							order = 7,
							name = L["Smart Raid Filter"],
							desc = L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."],
							type = 'toggle',
							set = function(info, value) E.db.unitframe[info[#info]] = value; UF:UpdateAllHeaders(value) end
						},
						targetOnMouseDown = {
							order = 8,
							name = L["Target On Mouse-Down"],
							desc = L["Target units on mouse down rather than mouse up. |n|n|cffFF0000Warning: If you are using the addon Clique you may have to adjust your Clique settings when changing this."],
							type = 'toggle',
						},
						targetSound = {
							order = 9,
							type = 'toggle',
							name = L["Targeting Sound"],
							desc = L["Enable a sound if you select a unit."],
						},
						effectiveGroup = {
							order = 50,
							type = 'group',
							inline = true,
							name = L["Effective Updates"],
							args = {
								warning = ACH:Description(L["|cffFF0000Warning:|r This causes updates to happen at a fraction of a second."]..'\n'..L["Enabling this has the potential to make updates faster, though setting a speed value that is too high may cause it to actually run slower than the default scheme, which use Blizzard events only with no update loops provided."], 0, 'medium'),
								effectiveHealth = {
									order = 1,
									type = 'toggle',
									name = L["Health"],
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value; UF:Update_AllFrames() end
								},
								effectivePower = {
									order = 2,
									type = 'toggle',
									name = L["Power"],
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value; UF:Update_AllFrames() end
								},
								effectiveAura = {
									order = 3,
									type = 'toggle',
									name = L["Aura"],
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value; UF:Update_AllFrames() end
								},
								spacer1 = ACH:Spacer(4, 'full'),
								effectiveHealthSpeed = {
									order = 5,
									name = L["Health Speed"],
									type = 'range',
									min = .1, max = .5, step = .05,
									disabled = function() return not E.global.unitframe.effectiveHealth end,
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value; UF:Update_AllFrames() end
								},
								effectivePowerSpeed = {
									order = 6,
									name = L["Power Speed"],
									type = 'range',
									min = .1, max = .5, step = .05,
									disabled = function() return not E.global.unitframe.effectivePower end,
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value; UF:Update_AllFrames() end
								},
								effectiveAuraSpeed = {
									order = 7,
									name = L["Aura Speed"],
									type = 'range',
									min = .1, max = .5, step = .05,
									disabled = function() return not E.global.unitframe.effectiveAura end,
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value; UF:Update_AllFrames() end
								},
							},
						},
						modifiers = {
							type = 'group',
							name = L["Filter Modifiers"],
							order = 60,
							inline = true,
							get = function(info) return E.db.unitframe.modifiers[info[#info]] end,
							set = function(info, value) E.db.unitframe.modifiers[info[#info]] = value end,
							args = {
								SHIFT = {
									order = 1,
									type = 'select',
									name = L["SHIFT"],
									values = modifierList,
								},
								ALT = {
									order = 2,
									type = 'select',
									name = L["ALT"],
									values = modifierList,
								},
								CTRL = {
									order = 3,
									type = 'select',
									name = L["CTRL"],
									values = modifierList,
								},
							},
						},
						barGroup = {
							order = 70,
							type = 'group',
							inline = true,
							name = L["Bars"],
							args = {
								smoothbars = {
									type = 'toggle',
									order = 2,
									name = L["Smooth Bars"],
									desc = L["Bars will transition smoothly."],
									set = function(info, value)
										E.db.unitframe[info[#info]] = value
										UF:Update_AllFrames()
									end,
								},
								statusbar = {
									type = 'select', dialogControl = 'LSM30_Statusbar',
									order = 3,
									name = L["StatusBar Texture"],
									desc = L["Main statusbar texture."],
									values = _G.AceGUIWidgetLSMlists.statusbar,
									set = function(info, value)
										E.db.unitframe[info[#info]] = value
										UF:Update_StatusBars()
									end,
								},
							},
						},
						fontGroup = {
							order = 80,
							type = 'group',
							inline = true,
							name = L["Fonts"],
							args = {
								font = {
									type = 'select', dialogControl = 'LSM30_Font',
									order = 4,
									name = L["Default Font"],
									desc = L["The font that the unitframes will use."],
									values = _G.AceGUIWidgetLSMlists.font,
									set = function(info, value) E.db.unitframe[info[#info]] = value; UF:Update_FontStrings() end,
								},
								fontSize = {
									order = 5,
									name = L["FONT_SIZE"],
									desc = L["Set the font size for unitframes."],
									type = 'range',
									min = 6, max = 64, step = 1,
									set = function(info, value) E.db.unitframe[info[#info]] = value; UF:Update_FontStrings() end,
								},
								fontOutline = {
									order = 6,
									name = L["Font Outline"],
									desc = L["Set the font outline."],
									type = 'select',
									values = C.Values.FontFlags,
									set = function(info, value) E.db.unitframe[info[#info]] = value; UF:Update_FontStrings() end,
								},
							},
						},
					},
				},
				frameGlowGroup = {
					order = 3,
					type = 'group',
					childGroups = 'tree',
					name = L["Frame Glow"],
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						mainGlow = {
							order = 1,
							type = 'group',
							inline = true,
							name = L["Mouseover Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.mainGlow[info[#info]]
								if type(t) == 'boolean' then return t end
								local d = P.unitframe.colors.frameGlow.mainGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.mainGlow[info[#info]]
								if type(t) == 'boolean' then
									E.db.unitframe.colors.frameGlow.mainGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.mainGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = 'toggle',
									name = L["Enable"],
									disabled = false,
								},
								spacer = ACH:Spacer(2),
								class = {
									order = 3,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 4,
									name = L["COLOR"],
									type = 'color',
									hasAlpha = true,
								},
							}
						},
						targetGlow = {
							order = 3,
							type = 'group',
							inline = true,
							name = L["Targeted Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.targetGlow[info[#info]]
								if type(t) == 'boolean' then return t end
								local d = P.unitframe.colors.frameGlow.targetGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.targetGlow[info[#info]]
								if type(t) == 'boolean' then
									E.db.unitframe.colors.frameGlow.targetGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.targetGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = 'toggle',
									name = L["Enable"],
									disabled = false,
								},
								spacer = ACH:Spacer(2),
								class = {
									order = 3,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 4,
									name = L["COLOR"],
									type = 'color',
									hasAlpha = true,
								},
							}
						},
						focusGlow = {
							order = 4,
							type = 'group',
							inline = true,
							name = L["Focused Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.focusGlow[info[#info]]
								if type(t) == 'boolean' then return t end
								local d = P.unitframe.colors.frameGlow.focusGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.focusGlow[info[#info]]
								if type(t) == 'boolean' then
									E.db.unitframe.colors.frameGlow.focusGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.focusGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = 'toggle',
									name = L["Enable"],
									disabled = false,
								},
								spacer = ACH:Spacer(2),
								class = {
									order = 3,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 4,
									name = L["COLOR"],
									type = 'color',
									hasAlpha = true,
								},
							}
						},
						mouseoverGlow = {
							order = 5,
							type = 'group',
							inline = true,
							name = L["Mouseover Highlight"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
								if type(t) == 'boolean' then return t end
								local d = P.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
								if type(t) == 'boolean' then
									E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
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
									type = 'select',
									dialogControl = 'LSM30_Statusbar',
									order = 2,
									name = L["Texture"],
									values = _G.AceGUIWidgetLSMlists.statusbar,
									get = function(info)
										return E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
									end,
									set = function(info, value)
										E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] = value
										UF:FrameGlow_UpdateFrames()
									end,
								},
								spacer = ACH:Spacer(3),
								class = {
									order = 4,
									type = 'toggle',
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."],
								},
								color = {
									order = 5,
									name = L["COLOR"],
									type = 'color',
									hasAlpha = true,
								},
							}
						},
					}
				},
				allColorsGroup = {
					order = 4,
					type = 'group',
					name = L["COLORS"],
					get = function(info) return E.db.unitframe.colors[info[#info]] end,
					set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						healthGroup = {
							order = 2,
							type = 'group',
							name = L["HEALTH"],
							get = function(info)
								local t = E.db.unitframe.colors[info[#info]]
								local d = P.unitframe.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors[info[#info]]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								colorhealthbyvalue = {
									order = 1,
									type = 'toggle',
									name = L["Health By Value"],
									desc = L["Color health by amount remaining."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								healthselection = {
									order = 2,
									type = 'toggle',
									name = L["Selection Health"],
									desc = L["Color health by color selection."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								healthclass = {
									order = 3,
									type = 'toggle',
									name = L["Class Health"],
									desc = L["Color health by classcolor or reaction."],
									disabled = function() return E.db.unitframe.colors.healthselection end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								forcehealthreaction = {
									order = 4,
									type = 'toggle',
									name = L["Force Reaction Color"],
									desc = L["Forces reaction color instead of class color on units controlled by players."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
									disabled = function() return E.db.unitframe.colors.healthselection or not E.db.unitframe.colors.healthclass end,
								},
								transparentHealth = {
									order = 6,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								useDeadBackdrop = {
									order = 7,
									type = 'toggle',
									name = L["Use Dead Backdrop"],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								classbackdrop = {
									order = 8,
									type = 'toggle',
									name = L["Class Backdrop"],
									desc = L["Color the health backdrop by class or reaction."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
									disabled = function() return E.db.unitframe.colors.customhealthbackdrop end
								},
								customhealthbackdrop = {
									order = 9,
									type = 'toggle',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								healthMultiplier = {
									order = 10,
									name = L["Health Backdrop Multiplier"],
									type = 'range',
									min = 0, softMax = 0.75, max = 1, step = .01,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
									disabled = function() return E.db.unitframe.colors.customhealthbackdrop end
								},
								health_backdrop = {
									order = 20,
									type = 'color',
									name = L["Health Backdrop"],
									disabled = function() return not E.db.unitframe.colors.customhealthbackdrop end
								},
								tapped = {
									order = 21,
									type = 'color',
									name = L["Tapped"],
								},
								health = {
									order = 22,
									type = 'color',
									name = L["Health"],
								},
								disconnected = {
									order = 23,
									type = 'color',
									name = L["Disconnected"],
								},
								health_backdrop_dead = {
									order = 24,
									type = 'color',
									name = L["Custom Dead Backdrop"],
									desc = L["Use this backdrop color for units that are dead or ghosts."],
									customWidth = 250,
								},
							},
						},
						powerGroup = {
							order = 3,
							type = 'group',
							name = L["Powers"],
							get = function(info)
								local t = E.db.unitframe.colors.power[info[#info]]
								local d = P.unitframe.colors.power[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.power[info[#info]]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								transparentPower = {
									order = 1,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								invertPower = {
									order = 2,
									type = 'toggle',
									name = L["Invert Colors"],
									desc = L["Invert foreground and background colors."],
									disabled = function() return not E.db.unitframe.colors.transparentPower end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								powerselection = {
									order = 3,
									type = 'toggle',
									name = L["Selection Power"],
									desc = L["Color power by color selection."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								powerclass = {
									order = 4,
									type = 'toggle',
									name = L["Class Power"],
									desc = L["Color power by classcolor or reaction."],
									disabled = function() return E.db.unitframe.colors.powerselection end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								spacer2 = ACH:Spacer(5, 'full'),
								custompowerbackdrop = {
									order = 6,
									type = 'toggle',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								power_backdrop = {
									order = 7,
									type = 'color',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									disabled = function() return not E.db.unitframe.colors.custompowerbackdrop end,
									get = function(info)
										local t = E.db.unitframe.colors[info[#info]]
										local d = P.unitframe.colors[info[#info]]
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors[info[#info]]
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,
								},
								spacer3 = ACH:Spacer(8, 'full'),
								MANA = {
									order = 20,
									name = L["MANA"],
									type = 'color',
								},
								RAGE = {
									order = 21,
									name = L["RAGE"],
									type = 'color',
								},
								FOCUS = {
									order = 22,
									name = L["FOCUS"],
									type = 'color',
								},
								ENERGY = {
									order = 23,
									name = L["ENERGY"],
									type = 'color',
								},
								RUNIC_POWER = {
									order = 24,
									name = L["RUNIC_POWER"],
									type = 'color',
								},
								PAIN = {
									order = 25,
									name = L["PAIN"],
									type = 'color',
								},
								FURY = {
									order = 26,
									name = L["FURY"],
									type = 'color',
								},
								LUNAR_POWER = {
									order = 27,
									name = L["LUNAR_POWER"],
									type = 'color'
								},
								INSANITY = {
									order = 28,
									name = L["INSANITY"],
									type = 'color'
								},
								MAELSTROM = {
									order = 29,
									name = L["MAELSTROM"],
									type = 'color'
								},
								ALT_POWER = {
									order = 30,
									name = L["Swapped Alt Power"],
									type = 'color'
								},
							},
						},
						castBars = {
							order = 4,
							type = 'group',
							name = L["Castbar"],
							get = function(info)
								local t = E.db.unitframe.colors[info[#info]]
								local d = P.unitframe.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								transparentCastbar = {
									order = 1,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								invertCastbar = {
									order = 2,
									type = 'toggle',
									name = L["Invert Colors"],
									desc = L["Invert foreground and background colors."],
									disabled = function() return not E.db.unitframe.colors.transparentCastbar end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								castClassColor = {
									order = 3,
									type = 'toggle',
									name = L["Class Castbars"],
									desc = L["Color castbars by the class of player units."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								castReactionColor = {
									order = 4,
									type = 'toggle',
									name = L["Reaction Castbars"],
									desc = L["Color castbars by the reaction type of non-player units."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								spacer1 = ACH:Spacer(5, 'full'),
								customcastbarbackdrop = {
									order = 6,
									type = 'toggle',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								castbar_backdrop = {
									order = 7,
									type = 'color',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									disabled = function() return not E.db.unitframe.colors.customcastbarbackdrop end,
									hasAlpha = true,
								},
								spacer2 = ACH:Spacer(8, 'full'),
								castColor = {
									order = 9,
									name = L["Interruptible"],
									type = 'color',
								},
								castNoInterrupt = {
									order = 10,
									name = L["Non-Interruptible"],
									type = 'color',
								},
								castInterruptedColor = {
									name = L["Interrupted"],
									order = 11,
									type = 'color',
								},
							},
						},
						auras = {
							order = 5,
							type = 'group',
							name = L["Auras"],
							args = {
								auraByType = {
									order = 3,
									name = L["By Type"],
									type = 'toggle',
								},
							},
						},
						auraBars = {
							order = 5,
							type = 'group',
							name = L["Aura Bars"],
							args = {
								transparentAurabars = {
									order = 1,
									type = 'toggle',
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								invertAurabars = {
									order = 2,
									type = 'toggle',
									name = L["Invert Colors"],
									desc = L["Invert foreground and background colors."],
									disabled = function() return not E.db.unitframe.colors.transparentAurabars end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								auraBarByType = {
									order = 3,
									name = L["By Type"],
									desc = L["Color aurabar debuffs by type."],
									type = 'toggle',
								},
								auraBarTurtle = {
									order = 4,
									name = L["Color Turtle Buffs"],
									desc = L["Color all buffs that reduce the unit's incoming damage."],
									type = 'toggle',
								},
								spacer1 = ACH:Spacer(5, 'full'),
								customaurabarbackdrop = {
									order = 6,
									type = 'toggle',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
								},
								aurabar_backdrop = {
									order = 7,
									type = 'color',
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									disabled = function() return not E.db.unitframe.colors.customaurabarbackdrop end,
									get = function(info)
										local t = E.db.unitframe.colors[info[#info]]
										local d = P.unitframe.colors[info[#info]]
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors[info[#info]]
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,
								},
								spacer2 = ACH:Spacer(8, 'full'),
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
											local classColor = E:ClassColor(E.myclass, true)
											r, g, b = classColor.r, classColor.g, classColor.b
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
									order = 15,
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
						reactionGroup = {
							order = 6,
							type = 'group',
							name = L["Reactions"],
							get = function(info)
								local t = E.db.unitframe.colors.reaction[info[#info]]
								local d = P.unitframe.colors.reaction[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.reaction[info[#info]]
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
						selectionGroup = {
							order = 7,
							type = 'group',
							name = L["Selection"],
							get = function(info)
								local n = tonumber(info[#info])
								local t = E.db.unitframe.colors.selection[n]
								local d = P.unitframe.colors.selection[n]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local n = tonumber(info[#info])
								local t = E.db.unitframe.colors.selection[n]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								['0'] = {
									order = 0,
									name = L["Hostile"],
									type = 'color',
								},
								['1'] = {
									order = 1,
									name = L["Unfriendly"],
									type = 'color',
								},
								['2'] = {
									order = 2,
									name = L["Neutral"],
									type = 'color',
								},
								['3'] = {
									order = 3,
									name = L["Friendly"],
									type = 'color',
								},
								['5'] = {
									order = 5,
									name = L["Player"], -- Player Extended
									type = 'color',
								},
								['6'] = {
									order = 6,
									name = L["PARTY"],
									type = 'color',
								},
								['7'] = {
									order = 7,
									name = L["Party PVP"],
									type = 'color',
								},
								['8'] = {
									order = 8,
									name = L["Friend"],
									type = 'color',
								},
								['9'] = {
									order = 9,
									name = L["Dead"],
									type = 'color',
								},
								['13'] = {
									order = 13,
									name = L["Battleground Friendly"],
									type = 'color',
								},
							},
						},
						healPrediction = {
							order = 9,
							name = L["Heal Prediction"],
							type = 'group',
							get = function(info)
								local t = E.db.unitframe.colors.healPrediction[info[#info]]
								local d = P.unitframe.colors.healPrediction[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.healPrediction[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								maxOverflow = {
									order = 1,
									type = 'range',
									name = L["Max Overflow"],
									desc = L["Max amount of overflow allowed to extend past the end of the health bar."],
									isPercent = true,
									min = 0, max = 1, step = 0.01,
									get = function(info) return E.db.unitframe.colors.healPrediction.maxOverflow end,
									set = function(info, value) E.db.unitframe.colors.healPrediction.maxOverflow = value; UF:Update_AllFrames() end,
								},
								spacer1 = ACH:Spacer(2, 'full'),
								personal = {
									order = 3,
									name = L["Personal"],
									type = 'color',
									hasAlpha = true,
								},
								others = {
									order = 4,
									name = L["Others"],
									type = 'color',
									hasAlpha = true,
								},
								absorbs = {
									order = 5,
									name = L["Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								healAbsorbs = {
									order = 6,
									name = L["Heal Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								overabsorbs = {
									order = 7,
									name = L["Over Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
								overhealabsorbs = {
									order = 8,
									name = L["Over Heal Absorbs"],
									type = 'color',
									hasAlpha = true,
								},
							},
						},
						powerPrediction = {
							order = 10,
							name = L["Power Prediction"],
							type = 'group',
							get = function(info)
								local t = E.db.unitframe.colors.powerPrediction[info[#info]]
								local d = P.unitframe.colors.powerPrediction[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.powerPrediction[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								enable = {
									order = 15,
									type = 'toggle',
									customWidth = 250,
									name = L["Custom Power Prediction Color"],
									get = function(info) return E.db.unitframe.colors.powerPrediction[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors.powerPrediction[info[#info]] = value; UF:Update_AllFrames() end,
								},
								spacer2 = ACH:Spacer(16),
								color = {
									order = 17,
									name = L["Power Prediction Color"],
									type = 'color',
									hasAlpha = true,
								},
								additional = {
									order = 18,
									name = L["Additional Power Prediction Color"],
									type = 'color',
									hasAlpha = true,
								},
							},
						},
						debuffHighlight = {
							order = 11,
							name = L["Debuff Highlighting"],
							type = 'group',
							get = function(info)
								local t = E.db.unitframe.colors.debuffHighlight[info[#info]]
								local d = P.unitframe.colors.debuffHighlight[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.debuffHighlight[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								debuffHighlighting = {
									order = 1,
									name = L["Highlight Color Style"],
									desc = L["Color the unit healthbar if there is a debuff that can be dispelled by you."], -- NEEDS UPDATED
									type = 'select',
									get = function(info) return E.db.unitframe[info[#info]] end,
									set = function(info, value) E.db.unitframe[info[#info]] = value end,
									values = {
										NONE = NONE,
										GLOW = L["Glow"],
										FILL = L["Fill"]
									},
								},
								blendMode = {
									order = 2,
									name = L["Blend Mode"],
									type = 'select',
									values = blendModeValues,
									get = function(info) return E.db.unitframe.colors.debuffHighlight[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors.debuffHighlight[info[#info]] = value; UF:Update_AllFrames() end
								},
								spacer1 = ACH:Spacer(3, 'full'),
								Magic = {
									order = 4,
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG7"],--Magic Effect
									type = 'color',
									hasAlpha = true,
								},
								Curse = {
									order = 5,
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG8"],--Curse Effect
									type = 'color',
									hasAlpha = true,
								},
								Disease = {
									order = 6,
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG10"],--Disease Effect
									type = 'color',
									hasAlpha = true,
								},
								Poison = {
									order = 7,
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG9"],--Poison Effect
									type = 'color',
									hasAlpha = true,
								},
							},
						},
					},
				},
				disabledBlizzardFrames = {
					order = 5,
					type = 'group',
					name = L["Disabled Blizzard Frames"],
					get = function(info) return E.private.unitframe.disabledBlizzardFrames[info[#info]] end,
					set = function(info, value) E.private.unitframe.disabledBlizzardFrames[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end,
					args = {
						individual = {
							order = 1,
							type = 'group',
							name = L["Individual Units"],
							inline = true,
							args = {
								player = {
									order = 1,
									type = 'toggle',
									name = L["Player"],
									desc = L["Disables the player and pet unitframes."],
								},
								target = {
									order = 2,
									type = 'toggle',
									name = L["TARGET"],
									desc = L["Disables the target and target of target unitframes."],
								},
								focus = {
									order = 3,
									type = 'toggle',
									name = L["Focus"],
									desc = L["Disables the focus and target of focus unitframes."],
								},
							},
						},
						group = {
							order = 2,
							type = 'group',
							name = L["Group Units"],
							inline = true,
							args = {
								party = {
									order = 6,
									type = 'toggle',
									name = L["PARTY"],
								},
								raid = {
									order = 7,
									type = 'toggle',
									name = L["Raid"],
								},
								boss = {
									order = 8,
									type = 'toggle',
									name = L["Boss"],
								},
								arena = {
									order = 9,
									type = 'toggle',
									name = L["Arena"],
								},
							},
						},
					},
				},
				raidDebuffIndicator = {
					order = 6,
					type = 'group',
					name = L["RaidDebuff Indicator"],
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						instanceFilter = {
							order = 2,
							type = 'select',
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
							type = 'select',
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
		individualUnits = {
			order = 4,
			type = 'group',
			childGroups = 'tab',
			name = L["Individual Units"],
			args = {},
		},
		groupUnits = {
			order = 5,
			type = 'group',
			childGroups = 'tab',
			name = L["Group Units"],
			args = {},
		}
	},
}

--Player
E.Options.args.unitframe.args.individualUnits.args.player = {
	name = L["Player"],
	type = 'group',
	order = 3,
	get = function(info) return E.db.unitframe.units.player[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.player[info[#info]] = value; UF:CreateAndUpdateUF('player') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
			set = function(info, value)
				E.db.unitframe.units.player[info[#info]] = value
				UF:CreateAndUpdateUF('player')
			end,
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.player.forceShowAuras then
					UF.player.forceShowAuras = nil
				else
					UF.player.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('player')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Player"], nil, {unit='player', mover='Player Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'player'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'player'),
		RestIcon = {
			type = 'group',
			name = L["Rest Icon"],
			get = function(info) return E.db.unitframe.units.player.RestIcon[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.RestIcon[info[#info]] = value; UF:CreateAndUpdateUF('player'); UF:TestingDisplay_RestingIndicator(ElvUF_Player) end,
			args = {
				enable = {
					order = 2,
					type = 'toggle',
					name = L["Enable"],
				},
				defaultColor = {
					order = 3,
					type = 'toggle',
					name = L["Default Color"],
				},
				color = {
					order = 4,
					type = 'color',
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
						UF:CreateAndUpdateUF('player')
						UF:TestingDisplay_RestingIndicator(UF.player)
					end,
				},
				size = {
					order = 5,
					type = 'range',
					name = L["Size"],
					min = 10, max = 60, step = 1,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
				anchorPoint = {
					order = 9,
					type = 'select',
					name = L["Anchor Point"],
					values = positionValues,
				},
				texture = {
					order = 10,
					type = 'select',
					sortByValue = true,
					name = L["Texture"],
					values = {
						CUSTOM = L["CUSTOM"],
						DEFAULT = L["DEFAULT"]
					},
				},
				customTexture = {
					type = 'input',
					order = 11,
					customWidth = 250,
					name = L["Custom Texture"],
					disabled = function()
						return E.db.unitframe.units.player.RestIcon.texture ~= 'CUSTOM'
					end,
					set = function(_, value)
						E.db.unitframe.units.player.RestIcon.customTexture = (value and (not value:match('^%s-$')) and value) or nil
						UF:CreateAndUpdateUF('player')
						UF:TestingDisplay_RestingIndicator(UF.player)
					end
				},
			},
		},
		PartyIndicator = {
			type = 'group',
			name = L["Party Indicator"],
			get = function(info) return E.db.unitframe.units.player.partyIndicator[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.partyIndicator[info[#info]] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					order = 2,
					type = 'toggle',
					name = L["Enable"],
				},
				scale = {
					order = 3,
					type = 'range',
					name = L["Scale"],
					isPercent = true,
					min = 0.5, max = 1.5, step = 0.01,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
				},
				anchorPoint = {
					order = 9,
					type = 'select',
					name = L["Anchor Point"],
					values = positionValues,
				},
			},
		},
		pvpText = {
			type = 'group',
			name = L["PvP Text"],
			get = function(info) return E.db.unitframe.units.player.pvp[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.pvp[info[#info]] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L["Position"],
					values = positionValues,
				},
				text_format = {
					order = 100,
					name = L["Text Format"],
					desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
					type = 'input',
					width = 'full',
				},
			},
		},
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'player'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'player'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'player'),
		castbar = GetOptionsTable_Castbar(true, UF.CreateAndUpdateUF, 'player'),
		CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, 'player'),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateUF, 'player'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'player'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'player'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'player'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'player'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'player'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'player'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'player'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'player'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'player'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'player', nil, true),
		pvpIcon = GetOptionsTable_PVPIcon(UF.CreateAndUpdateUF, 'player'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'player'),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateUF, 'player'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateUF, 'player'),
	},
}

do -- resting icons
	local resting = E.Options.args.unitframe.args.individualUnits.args.player.args.RestIcon.args.texture.values
	for key, icon in pairs(E.Media.RestIcons) do
		resting[key] = E:TextureString(icon, ':14:14')
	end
end

--Target
E.Options.args.unitframe.args.individualUnits.args.target = {
	name = L["TARGET"],
	type = 'group',
	order = 4,
	get = function(info) return E.db.unitframe.units.target[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.target[info[#info]] = value; UF:CreateAndUpdateUF('target') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.target.forceShowAuras then
					UF.target.forceShowAuras = nil
				else
					UF.target.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('target')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Target Frame"], nil, {unit='target', mover='Target Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'target'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'target'),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'target'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'target'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'target'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'target'),
		CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, 'target'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'target'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'target'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'target'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'target'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'target'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'target'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'target'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'target'),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateUF, 'target'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'target'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'target', nil, true),
		pvpIcon = GetOptionsTable_PVPIcon(UF.CreateAndUpdateUF, 'target'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'target'),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateUF, 'target'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateUF, 'target'),
	},
}

--TargetTarget
E.Options.args.unitframe.args.individualUnits.args.targettarget = {
	name = L["TargetTarget"],
	type = 'group',
	order = 5,
	get = function(info) return E.db.unitframe.units.targettarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.targettarget[info[#info]] = value; UF:CreateAndUpdateUF('targettarget') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.targettarget.forceShowAuras then
					UF.targettarget.forceShowAuras = nil
				else
					UF.targettarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('targettarget')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["TargetTarget Frame"], nil, {unit='targettarget', mover='TargetTarget Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'targettarget'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'targettarget'),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'targettarget'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'targettarget'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettarget'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'targettarget'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'targettarget'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'targettarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'targettarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'targettarget'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'targettarget'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettarget'),
	},
}

--TargetTargetTarget
E.Options.args.unitframe.args.individualUnits.args.targettargettarget = {
	name = L["TargetTargetTarget"],
	type = 'group',
	order = 6,
	get = function(info) return E.db.unitframe.units.targettargettarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.targettargettarget[info[#info]] = value; UF:CreateAndUpdateUF('targettargettarget') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.targettargettarget.forceShowAuras then
					UF.targettargettarget.forceShowAuras = nil
				else
					UF.targettargettarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('targettargettarget')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["TargetTargetTarget Frame"], nil, {unit='targettargettarget', mover='TargetTargetTarget Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'targettargettarget'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'targettargettarget'),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'targettargettarget'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'targettargettarget'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettargettarget'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'targettargettarget'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'targettargettarget'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'targettargettarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettargettarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'targettargettarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettargettarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'targettargettarget'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'targettargettarget'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettargettarget'),
	},
}

--Focus
E.Options.args.unitframe.args.individualUnits.args.focus = {
	name = L["Focus"],
	type = 'group',
	order = 7,
	get = function(info) return E.db.unitframe.units.focus[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.focus[info[#info]] = value; UF:CreateAndUpdateUF('focus') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.focus.forceShowAuras then
					UF.focus.forceShowAuras = nil
				else
					UF.focus.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('focus')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Focus Frame"], nil, {unit='focus', mover='Focus Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'focus'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'focus'),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'focus'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'focus'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUF, 'focus'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'focus'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'focus'),
		CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, 'focus'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focus'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'focus'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'focus'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'focus'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'focus'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focus'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'focus'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focus'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'focus'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'focus'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focus'),
	},
}

--Focus Target
E.Options.args.unitframe.args.individualUnits.args.focustarget = {
	name = L["FocusTarget"],
	type = 'group',
	order = 8,
	get = function(info) return E.db.unitframe.units.focustarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.focustarget[info[#info]] = value; UF:CreateAndUpdateUF('focustarget') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.focustarget.forceShowAuras then
					UF.focustarget.forceShowAuras = nil
				else
					UF.focustarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('focustarget')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["FocusTarget Frame"], nil, {unit='focustarget', mover='FocusTarget Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'focustarget'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'focustarget'),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'focustarget'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focustarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focustarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'focustarget'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'focustarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focustarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'focustarget'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'focustarget'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'focustarget'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'focustarget'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focustarget'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'focustarget'),
	},
}

--Pet
E.Options.args.unitframe.args.individualUnits.args.pet = {
	name = L["PET"],
	type = 'group',
	order = 9,
	get = function(info) return E.db.unitframe.units.pet[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.pet[info[#info]] = value; UF:CreateAndUpdateUF('pet') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.pet.forceShowAuras then
					UF.pet.forceShowAuras = nil
				else
					UF.pet.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('pet')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Pet Frame"], nil, {unit='pet', mover='Pet Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'pet'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'pet'),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'pet'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUF, 'pet'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, 'pet'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pet'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pet'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'pet'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'pet'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pet'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'pet'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'pet'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'pet'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'pet'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'pet'),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, 'pet'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'pet'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'pet'),
	},
}

--Pet Target
E.Options.args.unitframe.args.individualUnits.args.pettarget = {
	name = L["PetTarget"],
	type = 'group',
	order = 10,
	get = function(info) return E.db.unitframe.units.pettarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.pettarget[info[#info]] = value; UF:CreateAndUpdateUF('pettarget') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		showAuras = {
			order = 2,
			type = 'execute',
			name = L["Show Auras"],
			func = function()
				if UF.pettarget.forceShowAuras then
					UF.pettarget.forceShowAuras = nil
				else
					UF.pettarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF('pettarget')
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["PetTarget Frame"], nil, {unit='pettarget', mover='PetTarget Frame'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, 'pettarget'); E:RefreshGUI() end,
			confirm = true,
		},
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, 'pettarget'),
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, 'pettarget'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUF, 'pettarget'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pettarget'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, 'pettarget'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUF, 'pettarget'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, 'pettarget'),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pettarget'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, 'pettarget'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pettarget'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'pettarget'),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, 'pettarget'),
	},
}

--Boss Frames
E.Options.args.unitframe.args.groupUnits.args.boss = {
	name = L["Boss"],
	type = 'group',
	order = 1000,
	get = function(info) return E.db.unitframe.units.boss[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.boss[info[#info]] = value; UF:CreateAndUpdateUFGroup('boss', _G.MAX_BOSS_FRAMES) end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		displayFrames = {
			type = 'execute',
			order = 2,
			name = L["Display Frames"],
			desc = L["Force the frames to show, they will act as if they are the player frame."],
			func = function() UF:ToggleForceShowGroupFrames('boss', _G.MAX_BOSS_FRAMES) end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Boss Frames"], nil, {unit='boss', mover='Boss Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				arena = L["Arena"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'boss'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUFGroup, 'boss', _G.MAX_BOSS_FRAMES),
	},
}

--Arena Frames
E.Options.args.unitframe.args.groupUnits.args.arena = {
	name = L["Arena"],
	type = 'group',
	order = 1000,
	get = function(info) return E.db.unitframe.units.arena[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.arena[info[#info]] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		displayFrames = {
			type = 'execute',
			order = 2,
			name = L["Display Frames"],
			desc = L["Force the frames to show, they will act as if they are the player frame."],
			func = function() UF:ToggleForceShowGroupFrames('arena', 5) end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Arena Frames"], nil, {unit='arena', mover='Arena Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				boss = L["Boss"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'arena'); E:RefreshGUI() end,
			confirm = true,
		},
		pvpTrinket = {
			order = 4001,
			type = 'group',
			name = L["PVP Trinket"],
			get = function(info) return E.db.unitframe.units.arena.pvpTrinket[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.arena.pvpTrinket[info[#info]] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
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
						LEFT = L["Left"],
						RIGHT = L["Right"],
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
					name = L["X-Offset"],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["Y-Offset"],
					min = -60, max = 60, step = 1,
				},
			},
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUFGroup, 'arena', 5),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUFGroup, 'arena', 5),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'arena', 5),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, 'arena', 5),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'arena', 5),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'arena', 5),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUFGroup, 'arena', 5),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateUFGroup, 'arena', 5),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateUFGroup, 'arena', 5),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUFGroup, 'arena', 5),
		pvpclassificationindicator = GetOptionsTable_PVPClassificationIndicator(UF.CreateAndUpdateUFGroup, 'arena', 5),
	},
}

--Party Frames
E.Options.args.unitframe.args.groupUnits.args.party = {
	name = L["PARTY"],
	type = 'group',
	order = 9,
	get = function(info) return E.db.unitframe.units.party[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.party[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('party') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		configureToggle = {
			order = 2,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Party, ElvUF_Party.forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Party Frames"], nil, {unit='party', mover='Party Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				raid = L["Raid Frames"],
				raid40 = L["Raid40 Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'party'); E:RefreshGUI() end,
			confirm = true,
		},
		petsGroup = {
			type = 'group',
			name = L["Party Pets"],
			get = function(info) return E.db.unitframe.units.party.petsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.party.petsGroup[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				enable = {
					type = 'toggle',
					name = L["Enable"],
					order = 0,
				},
				colorPetByUnitClass = {
					type = 'toggle',
					name = L["Color by Unit Class"],
					order = 1,
				},
				width = {
					order = 2,
					name = L["Width"],
					type = 'range',
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 3,
					name = L["Height"],
					type = 'range',
					min = 5, max = 500, step = 1,
				},
				anchorPoint = {
					type = 'select',
					order = 4,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 5,
					type = 'range',
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 6,
					type = 'range',
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				threatStyle = ACH:Select(L["Threat Display Mode"], nil, 10, threatValues),
				name = {
					order = 20,
					type = 'group',
					inline = true,
					get = function(info) return E.db.unitframe.units.party.petsGroup.name[info[#info]] end,
					set = function(info, value) E.db.unitframe.units.party.petsGroup.name[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('party') end,
					name = L["Name"],
					args = {
						position = {
							type = 'select',
							order = 1,
							name = L["Position"],
							values = positionValues,
						},
						xOffset = {
							order = 2,
							type = 'range',
							name = L["X-Offset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1,
						},
						yOffset = {
							order = 3,
							type = 'range',
							name = L["Y-Offset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1,
						},
						text_format = {
							order = 100,
							name = L["Text Format"],
							desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
							type = 'input',
							width = 'full',
						},
					},
				},
				buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'petsGroup'),
				healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'petsGroup'),
			},
		},
		targetsGroup = {
			type = 'group',
			name = L["Party Targets"],
			get = function(info) return E.db.unitframe.units.party.targetsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.party.targetsGroup[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
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
					min = 5, max = 500, step = 1,
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
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				threatStyle = ACH:Select(L["Threat Display Mode"], nil, 10, threatValues),
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'targetsGroup'),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'party', nil, 'targetsGroup'),
			},
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'party'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'party'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'party'),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateHeaderGroup, 'party', 5),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, 'party'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'party'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'party'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'party'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'party'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'party'),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'party'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'party'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party'),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, 'party'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'party'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'party'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, 'party'),
		roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, 'party'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'party'),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
		summonIcon = GetOptionsTable_SummonIcon(UF.CreateAndUpdateHeaderGroup, 'party'),
	},
}
E.Options.args.unitframe.args.groupUnits.args.party.args.classbar.name = L["Alternative Power"]
E.Options.args.unitframe.args.groupUnits.args.party.args.targetsGroup.args.name.inline = true
E.Options.args.unitframe.args.groupUnits.args.party.args.targetsGroup.args.raidicon.inline = true

--Raid Frames
E.Options.args.unitframe.args.groupUnits.args.raid = {
	name = L["Raid"],
	type = 'group',
	order = 10,
	get = function(info) return E.db.unitframe.units.raid[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.raid[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('raid') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		header = ACH:Description(L["|cffFF0000Warning:|r Enable and Number of Groups are managed by Smart Raid Filter. Disable Smart Raid Filter in (UnitFrames - General) to change these settings."], 0, 'large', nil, nil, nil, nil, nil, function() return not E.db.unitframe.smartRaidFilter end),
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
			disabled = function() return E.db.unitframe.smartRaidFilter end,
		},
		configureToggle = {
			order = 2,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(_G.ElvUF_Raid, _G.ElvUF_Raid.forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Raid Frames"], nil, {unit = 'raid', mover='Raid Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				party = L["Party Frames"],
				raid40 = L["Raid40 Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'raid'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'raid'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'raid'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'raid'),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, 'raid'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raid'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'raid'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'raid'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'raid'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raid'),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raid'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'raid'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raid'),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, 'raid'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raid'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'raid'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, 'raid'),
		roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, 'raid'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raid'),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
		summonIcon = GetOptionsTable_SummonIcon(UF.CreateAndUpdateHeaderGroup, 'raid'),
	},
}
E.Options.args.unitframe.args.groupUnits.args.raid.args.classbar.name = L["Alternative Power"]

--Raid-40 Frames
E.Options.args.unitframe.args.groupUnits.args.raid40 = {
	name = L["Raid-40"],
	type = 'group',
	order = 11,
	get = function(info) return E.db.unitframe.units.raid40[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.raid40[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('raid40') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		header = ACH:Description(L["|cffFF0000Warning:|r Enable and Number of Groups are managed by Smart Raid Filter. Disable Smart Raid Filter in (UnitFrames - General) to change these settings."], 0, 'large', nil, nil, nil, nil, nil, function() return not E.db.unitframe.smartRaidFilter end),
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
			disabled = function() return E.db.unitframe.smartRaidFilter end,
		},
		configureToggle = {
			order = 2,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(_G.ElvUF_Raid40, _G.ElvUF_Raid40.forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Raid-40 Frames"], nil, {unit='raid40', mover='Raid Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				party = L["Party Frames"],
				raid = L["Raid Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'raid40'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'raid40'),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'raid40'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raid40'),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, 'raid40'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
		summonIcon = GetOptionsTable_SummonIcon(UF.CreateAndUpdateHeaderGroup, 'raid40'),
	},
}
E.Options.args.unitframe.args.groupUnits.args.raid40.args.classbar.name = L["Alternative Power"]

--Raid Pet Frames
E.Options.args.unitframe.args.groupUnits.args.raidpet = {
	order = 12,
	type = 'group',
	name = L["Raid Pet"],
	get = function(info) return E.db.unitframe.units.raidpet[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.raidpet[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('raidpet') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		header = ACH:Description(L["|cffFF0000Warning:|r Enable and Number of Groups are managed by Smart Raid Filter. Disable Smart Raid Filter in (UnitFrames - General) to change these settings."], 0, 'large', nil, nil, nil, nil, nil, function() return not E.db.unitframe.smartRaidFilter end),
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
			disabled = function() return E.db.unitframe.smartRaidFilter end,
		},
		configureToggle = {
			order = 2,
			type = 'execute',
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Raidpet, ElvUF_Raidpet.forceShow ~= true or nil)
			end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Raid Pet Frames"], nil, {unit='raidpet', mover='Raid Pet Frames'}) end,
		},
		copyFrom = {
			type = 'select',
			order = 4,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				party = L["Party Frames"],
				raid = L["Raid Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'raidpet'); E:RefreshGUI() end,
			confirm = true,
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'raidpet'),
	},
}

--Tank Frames
E.Options.args.unitframe.args.groupUnits.args.tank = {
	name = L["TANK"],
	type = 'group',
	order = 13,
	get = function(info) return E.db.unitframe.units.tank[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.tank[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('tank') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Tank Frames"], nil, {unit='tank'}) end,
		},
		targetsGroup = {
			order = 700,
			type = 'group',
			name = L["Tank Target"],
			get = function(info) return E.db.unitframe.units.tank.targetsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.tank.targetsGroup[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('tank') end,
			args = {
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
					min = 5, max = 500, step = 1,
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
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				threatStyle = ACH:Select(L["Threat Display Mode"], nil, 10, threatValues),
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'tank', nil, 'targetsGroup'),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'tank', nil, 'targetsGroup'),
			},
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'tank'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'tank'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'tank'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'tank'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'tank'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'tank'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'tank'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'tank'),
	},
}
E.Options.args.unitframe.args.groupUnits.args.tank.args.name.args.attachTextTo.values = { Health = L["Health"], Frame = L["Frame"] }
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.name.args.attachTextTo.values = { Health = L["Health"], Frame = L["Frame"] }
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.name.get = function(info) return E.db.unitframe.units.tank.targetsGroup.name[info[#info]] end
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.name.set = function(info, value) E.db.unitframe.units.tank.targetsGroup.name[info[#info]] = value; UF.CreateAndUpdateHeaderGroup(UF, 'tank') end
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.name.inline = true
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.raidicon.inline = true

--Assist Frames
E.Options.args.unitframe.args.groupUnits.args.assist = {
	name = L["Assist"],
	type = 'group',
	order = 14,
	get = function(info) return E.db.unitframe.units.assist[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.assist[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('assist') end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L["Enable"],
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show('RESET_UF_UNIT', L["Assist Frames"], nil, {unit='assist'}) end,
		},
		targetsGroup = {
			order = 701,
			type = 'group',
			name = L["Assist Target"],
			get = function(info) return E.db.unitframe.units.assist.targetsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.assist.targetsGroup[info[#info]] = value; UF:CreateAndUpdateHeaderGroup('assist') end,
			args = {
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
					min = 5, max = 500, step = 1,
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
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'assist', nil, 'targetsGroup'),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'assist', nil, 'targetsGroup'),
			},
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, 'assist'),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, 'assist'),
		buffs = GetOptionsTable_Auras('buffs', UF.CreateAndUpdateHeaderGroup, 'assist'),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, 'assist'),
		debuffs = GetOptionsTable_Auras('debuffs', UF.CreateAndUpdateHeaderGroup, 'assist'),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, 'assist'),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'assist'),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, 'assist'),
	},
}
E.Options.args.unitframe.args.groupUnits.args.assist.args.name.args.attachTextTo.values = { Health = L["Health"], Frame = L["Frame"] }
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.name.args.attachTextTo.values = { Health = L["Health"], Frame = L["Frame"] }
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.name.get = function(info) return E.db.unitframe.units.assist.targetsGroup.name[info[#info]] end
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.name.set = function(info, value) E.db.unitframe.units.assist.targetsGroup.name[info[#info]] = value; UF.CreateAndUpdateHeaderGroup(UF, 'assist') end
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.name.inline = true
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.raidicon.inline = true

--MORE COLORING STUFF YAY
E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup = {
	order = -10,
	type = 'group',
	name = L["Class Resources"],
	get = function(info)
		local t = E.db.unitframe.colors.classResources[info[#info]]
		local d = P.unitframe.colors.classResources[info[#info]]
		return t.r, t.g, t.b, t.a, d.r, d.g, d.b
	end,
	set = function(info, r, g, b)
		local t = E.db.unitframe.colors.classResources[info[#info]]
		t.r, t.g, t.b = r, g, b
		UF:Update_AllFrames()
	end,
	args = {
		--[=[transparentClasspower = {
			order = 1,
			type = 'toggle',
			name = L["Transparent"],
			desc = L["Make textures transparent."],
			get = function(info) return E.db.unitframe.colors[info[#info]] end,
			set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
		},
		invertClasspower = {
			order = 2,
			type = 'toggle',
			name = L["Invert Colors"],
			desc = L["Invert foreground and background colors."],
			disabled = function() return not E.db.unitframe.colors.transparentClasspower end,
			get = function(info) return E.db.unitframe.colors[info[#info]] end,
			set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
		},
		spacer1 = {
			order = 3,
			type = 'description',
			name = ' ',
			width = 'full'
		},]=]
		customclasspowerbackdrop = {
			order = 4,
			type = 'toggle',
			name = L["Use Custom Backdrop"],
			desc = L["Use the custom backdrop color instead of a multiple of the main color."],
			get = function(info) return E.db.unitframe.colors[info[#info]] end,
			set = function(info, value) E.db.unitframe.colors[info[#info]] = value; UF:Update_AllFrames() end,
		},
		classpower_backdrop = {
			order = 5,
			type = 'color',
			name = L["Custom Backdrop"],
			disabled = function() return not E.db.unitframe.colors.customclasspowerbackdrop end,
			get = function(info)
				local t = E.db.unitframe.colors[info[#info]]
				local d = P.unitframe.colors[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local t = E.db.unitframe.colors[info[#info]]
				t.r, t.g, t.b = r, g, b
				UF:Update_AllFrames()
			end,
		},
		spacer2 = ACH:Spacer(6, 'full'),
	}
}


for i in pairs(P.unitframe.colors.classResources.comboPoints) do
	E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args['combo'..i] = {
		order = 10 + i,
		type = 'color',
		name = L["Combo Point"]..' #'..i,
		get = function()
			local t = E.db.unitframe.colors.classResources.comboPoints[i]
			local d = P.unitframe.colors.classResources.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(_, r, g, b)
			local t = E.db.unitframe.colors.classResources.comboPoints[i]
			t.r, t.g, t.b = r, g, b
			UF:Update_AllFrames()
		end,
	}
end

E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args.chargedComboPoint = {
	order = 17,
	type = 'color',
	name = L["Charged Combo Point"],
	get = function()
		local t = E.db.unitframe.colors.classResources.chargedComboPoint
		local d = P.unitframe.colors.classResources.chargedComboPoint
		return t.r, t.g, t.b, t.a, d.r, d.g, d.b
	end,
	set = function(_, r, g, b)
		local t = E.db.unitframe.colors.classResources.chargedComboPoint
		t.r, t.g, t.b = r, g, b
		UF:Update_AllFrames()
	end,
}

if P.unitframe.colors.classResources[E.myclass] then
	E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args.spacer5 = ACH:Spacer(20, 'full')

	local ORDER = 30
	if E.myclass == 'PALADIN' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = L["HOLY_POWER"],
			order = ORDER,
		}
	elseif E.myclass == 'MAGE' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = L["POWER_TYPE_ARCANE_CHARGES"],
			order = ORDER,
		}
	elseif E.myclass == 'MONK' then
		for i = 1, 6 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = L["CHI_POWER"]..' #'..i,
				order = ORDER+i,
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
			name = L["SOUL_SHARDS"],
			order = ORDER,
		}
	elseif E.myclass == 'DEATHKNIGHT' then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = L["RUNES"],
			order = ORDER,
		}
	end
end

if E.myclass == 'DEATHKNIGHT' then
	E.Options.args.unitframe.args.individualUnits.args.player.args.classbar.args.sortDirection = {
		name = L["Sort Direction"],
		desc = L["Defines the sort order of the selected sort method."],
		type = 'select',
		order = 7,
		values = {
			asc = L["Ascending"],
			desc = L["Descending"],
			NONE = L["NONE"],
		},
		get = function(info) return E.db.unitframe.units.player.classbar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units.player.classbar[info[#info]] = value; UF:CreateAndUpdateUF('player') end,
	}
end

--Custom Texts
function E:RefreshCustomTextsConfigs()
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

E:RefreshCustomTextsConfigs()
