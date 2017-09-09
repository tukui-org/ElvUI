local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

local next = next
local ipairs = ipairs
local tremove = tremove
local tinsert = tinsert
local tsort = table.sort
local tonumber = tonumber
local tconcat = table.concat
local format = string.format
local GetSpellInfo = GetSpellInfo
local GetNumClasses = GetNumClasses
local GetClassInfo = GetClassInfo
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local pairs, type, strsplit, match, gsub = pairs, type, strsplit, string.match, string.gsub
local LEVEL, NONE, REPUTATION, COMBAT, FILTERS = LEVEL, NONE, REPUTATION, COMBAT, FILTERS
local FRIEND, ENEMY, CLASS, ROLE, TANK, HEALER, DAMAGER, COLOR = FRIEND, ENEMY, CLASS, ROLE, TANK, HEALER, DAMAGER, COLOR
local OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS = OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS
local FACTION_STANDING_LABEL1 = FACTION_STANDING_LABEL1
local FACTION_STANDING_LABEL2 = FACTION_STANDING_LABEL2
local FACTION_STANDING_LABEL3 = FACTION_STANDING_LABEL3
local FACTION_STANDING_LABEL4 = FACTION_STANDING_LABEL4
local FACTION_STANDING_LABEL5 = FACTION_STANDING_LABEL5
local FACTION_STANDING_LABEL6 = FACTION_STANDING_LABEL6
local FACTION_STANDING_LABEL7 = FACTION_STANDING_LABEL7
local FACTION_STANDING_LABEL8 = FACTION_STANDING_LABEL8
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: MAX_PLAYER_LEVEL, AceGUIWidgetLSMlists, CUSTOM_CLASS_COLORS

local selectedNameplateFilter

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
};

local carryFilterFrom, carryFilterTo
local function filterValue(value)
	return gsub(value,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function filterPriority(auraType, unit, value, remove, movehere, friendState)
	if not auraType or not value then return end
	local filter = E.db.nameplates.units[unit] and E.db.nameplates.units[unit][auraType] and E.db.nameplates.units[unit][auraType].filters and E.db.nameplates.units[unit][auraType].filters.priority
	if not filter then return end
	local found = filterMatch(filter, filterValue(value))
	if found and movehere then
		local tbl, sv, sm = {strsplit(",",filter)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm);tinsert(tbl, sv, movehere);
		E.db.nameplates.units[unit][auraType].filters.priority = tconcat(tbl,',')
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
				local tbl, sv, sm = {strsplit(",",filter)}
				for i in ipairs(tbl) do
					if tbl[i] == value then sv = i;break end
				end
				tinsert(tbl, sv, state);tremove(tbl, sv+1)
				E.db.nameplates.units[unit][auraType].filters.priority = tconcat(tbl,',')
			end
		end
	elseif found and remove then
		E.db.nameplates.units[unit][auraType].filters.priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.nameplates.units[unit][auraType].filters.priority = (filter == '' and value) or (filter..","..value)
	end
end

local specListOrder = 50 --start at 50
local classTable, classIndexTable, classOrder
local function UpdateClassSpec(classTag, coloredName, enabled)
	if not (classTable[classTag] and classTable[classTag].classID) then return end
	specListOrder = specListOrder+(enabled ~= false and 1 or -1)
	local classSpec = format("%s%s", classTag, "spec");
	if (not enabled) and E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] then
		E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] = nil
		return --stop when we remove one
	end
	if not E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] then
		E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] = {
			order = specListOrder,
			type = "group",
			name = classTable[classTag].name,
			guiInline = true,
			args = {},
		}
	end
	local coloredName = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classTag]
	coloredName = (coloredName and coloredName.colorStr) or "ff666666"
	for i=1, GetNumSpecializationsForClassID(classTable[classTag].classID) do
		local specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classTable[classTag].classID, i)
		local tagID = format("%s%s", classTag, specID)
		if not E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec].args[tagID] then
			E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec].args[tagID] = {
				order = i,
				name = format("|c%s%s|r", coloredName, name),
				type = 'toggle',
				get = function(info)
					local tagTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag]
					return tagTrigger and tagTrigger.specs and tagTrigger.specs[specID]
				end,
				set = function(info, value)
					--set this to nil if false to keep its population to only enabled ones
					local tagTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag]
					if not tagTrigger.specs then
						E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs = {}
					end
					E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs[specID] = value or nil
					if not next(E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs) then
						E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs = nil
					end
					NP:ConfigureAll()
				end
			}
		end
	end
end

local function UpdateClassSection()
	if E.global.nameplate.filters[selectedNameplateFilter] then
		if not classTable then
			local classDisplayName, classTag, classID;
			classTable, classIndexTable = {}, {}
			for i=1, GetNumClasses() do
				classDisplayName, classTag, classID = GetClassInfo(i)
				if not classTable[classTag] then
					classTable[classTag] = {}
				end
				classTable[classTag].name = classDisplayName
				classTable[classTag].classID = classID
			end
			for classTag, content in pairs(classTable) do
				tinsert(classIndexTable, classTag)
			end
			tsort(classIndexTable)
		end
		classOrder = 0
		local coloredName;
		for index, classTag in ipairs(classIndexTable) do
			classOrder = classOrder + 1
			coloredName = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classTag]
			coloredName = (coloredName and coloredName.colorStr) or "ff666666"
			local classTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class
			if classTrigger and classTrigger[classTag] and classTrigger[classTag].enabled then
				UpdateClassSpec(classTag) --populate enabled class spec boxes
			end
			E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classTag] = {
				order = classOrder,
				name = format("|c%s%s|r", coloredName, classTable[classTag].name),
				type = 'toggle',
				get = function(info)
					local tagTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag]
					return tagTrigger and tagTrigger.enabled
				end,
				set = function(info, value)
					local tagTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag]
					if not tagTrigger then
						E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag] = {}
					end
					--set this to nil if false to keep its population to only enabled ones
					if value then
						E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].enabled = value
					else
						E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag] = nil
					end
					UpdateClassSpec(classTag, value)
					NP:ConfigureAll()
				end
			}
		end
	end
end

local function UpdateStyleLists()
	if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.names.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {},
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.names) then
			for name, _ in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.names) do
				E.Options.args.nameplate.args.filters.args.triggers.args.names.args.names.args[name] = {
					name = name,
					type = "toggle",
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.names and E.global.nameplate.filters[selectedNameplateFilter].triggers.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.names[name] = value
						NP:ConfigureAll()
					end,
				}
			end
		end
	end
	if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers.casting and E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells then
		E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {},
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells) then
			local spell, spellName, notDisabled
			for name, _ in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells.args[name] = {
					name = spell,
					type = "toggle",
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells and E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[name] = value
						NP:ConfigureAll()
					end,
				}
			end
		end
	end
	if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {},
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) then
			local spell, spellName, notDisabled
			for name, _ in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names.args[name] = {
					textWidth = true,
					name = spell,
					type = "toggle",
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name] = value
						NP:ConfigureAll()
					end,
				}
			end
		end
	end
	if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {},
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) then
			local spell, spellName, notDisabled
			for name, _ in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names.args[name] = {
					textWidth = true,
					name = spell,
					type = "toggle",
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name] = value
						NP:ConfigureAll()
					end,
				}
			end
		end
	end
end

local function GetStyleFilterDefaultOptions(filter)
	if filter and G.nameplate.filters[filter] and P.nameplates.filters[filter] then
		E.db.nameplates.filters[filter] = E:CopyTable({}, P.nameplates.filters[filter]) --copy the profile options
		return E:CopyTable({}, G.nameplate.filters[filter]) --return the copy of the global options
	end

	local styleFilterProfileOptions = {
		["triggers"] = {
			["enable"] = true
		}
	}

	local styleFilterDefaultOptions = {
		["triggers"] = {
			["priority"] = 1,
			["isTarget"] = false,
			["notTarget"] = false,
			["questBoss"] = false,
			["level"] = false,
			["casting"] = {
				["interruptible"] = false,
				["spells"] = {},
			},
			["role"] = {
				["tank"] = false,
				["healer"] = false,
				["damager"] = false,
			},
			["class"] = {}, --this can stay empty we only will accept values that exist
			["curlevel"] = 0,
			["maxlevel"] = 0,
			["minlevel"] = 0,
			["healthThreshold"] = false,
			["underHealthThreshold"] = 0,
			["overHealthThreshold"] = 0,
			["names"] = {},
			["nameplateType"] = {
				["enable"] = false,
				["friendlyPlayer"] = false,
				["friendlyNPC"] = false,
				["healer"] = false,
				["enemyPlayer"] = false,
				["enemyNPC"] = false,
				["neutral"] = false
			},
			["reactionType"] = {
				["enabled"] = false,
				["reputation"] = false,
				["hated"] = false,
				["hostile"] = false,
				["unfriendly"] = false,
				["neutral"] = false,
				["friendly"] = false,
				["honored"] = false,
				["revered"] = false,
				["exalted"] = false
			},
			["buffs"] = {
				["mustHaveAll"] = false,
				["missing"] = false,
				["names"] = {},
				["minTimeLeft"] = 0,
				["maxTimeLeft"] = 0,
			},
			["debuffs"] = {
				["mustHaveAll"] = false,
				["missing"] = false,
				["names"] = {},
				["minTimeLeft"] = 0,
				["maxTimeLeft"] = 0,
			},
			["inCombat"] = false,
			["outOfCombat"] = false,
			["inCombatUnit"] = false,
			["outOfCombatUnit"] = false,
		},
		["actions"] = {
			["color"] = {
				["health"] = false,
				["border"] = false,
				["name"] = false,
				["healthColor"] = {r=1,g=1,b=1,a=1},
				["borderColor"] = {r=1,g=1,b=1,a=1},
				["nameColor"] = {r=1,g=1,b=1,a=1}
			},
			["texture"] = {
				["enable"] = false,
				["texture"] = "ElvUI Norm",
			},
			["hide"] = false,
			["usePortrait"] = false,
			["scale"] = 1.0,
		},
	}

	if not E.db.nameplates then E.db.nameplates = {} end
	if not E.db.nameplates.filters then E.db.nameplates.filters = {} end

	E.db.nameplates.filters[filter] = styleFilterProfileOptions

	return styleFilterDefaultOptions
end

local function UpdateFilterGroup()
	if not selectedNameplateFilter or not E.global.nameplate.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = nil
		E.Options.args.nameplate.args.filters.args.actions = nil
		E.Options.args.nameplate.args.filters.args.triggers = nil
	end
	if selectedNameplateFilter and E.global.nameplate.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = {
			order = 4,
			type = "header",
			name = selectedNameplateFilter,
		}
		E.Options.args.nameplate.args.filters.args.triggers = {
			type = "group",
			name = L["Triggers"],
			order = 5,
			args = {
				enable = {
					name = L["Enable"],
					order = 0,
					type = 'toggle',
					get = function(info)
						return (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					set = function(info, value)
						if not E.db.nameplates then E.db.nameplates = {} end
						if not E.db.nameplates.filters then E.db.nameplates.filters = {} end
						if not E.db.nameplates.filters[selectedNameplateFilter] then E.db.nameplates.filters[selectedNameplateFilter] = {} end
						if not E.db.nameplates.filters[selectedNameplateFilter].triggers then E.db.nameplates.filters[selectedNameplateFilter].triggers = {} end
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable = value
						UpdateStyleLists() --we need this to recolor the spellid based on wether or not the filter is disabled
						NP:ConfigureAll()
					end,
				},
				priority = {
					name = L["Filter Priority"],
					desc = L["Lower numbers mean a higher priority. Filters are processed in order from 1 to 100."],
					order = 1,
					type = "range",
					min = 1, max = 100, step = 1,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.priority or 1
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.priority = value
						NP:ConfigureAll()
					end,
				},
				resetFilter = {
					order = 2,
					name = L["Clear Filter"],
					desc = L["Return filter to its default state."],
					type = "execute",
					func = function()
						E.global.nameplate.filters[selectedNameplateFilter] = GetStyleFilterDefaultOptions(selectedNameplateFilter);
						UpdateStyleLists();
						NP:ConfigureAll()
					end,
				},
				spacer1 = {
					order = 3,
					type = 'description',
					name = '',
				},
				isTarget = {
					name = L["Is Targeted"],
					order = 4,
					type = 'toggle',
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.isTarget
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.isTarget = value
						NP:ConfigureAll()
					end,
				},
				notTarget = {
					name = L["Not Targeted"],
					order = 5,
					type = 'toggle',
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.notTarget
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.notTarget = value
						NP:ConfigureAll()
					end,
				},
				questBoss = {
					name = "Quest Boss",
					order = 6,
					type = 'toggle',
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.questBoss
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.questBoss = value
						NP:ConfigureAll()
					end,
				},
				names = {
					name = L["Name"],
					order = 7,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						addName = {
							order = 1,
							name = L["Add Name or NPC ID"],
							desc = L["Add a Name or NPC ID to the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.names[value] = true;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeName = {
							order = 2,
							name = L["Remove Name or NPC ID"],
							desc = L["Remove a Name or NPC ID from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.names[value] = nil;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						}
					},
				},
				casting = {
					order = 8,
					type = 'group',
					name = L["Casting"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						interruptible = {
							type = 'toggle',
							order = 1,
							name = L["Interruptible"],
							desc = L["If enabled then the filter will only activate if the unit is casting interruptible spells."],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.interruptible
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.interruptible = value
								NP:ConfigureAll()
							end,
						},
						spacer2 = {
							order = 2,
							type = 'description',
							name = '',
						},
						addSpell = {
							order = 3,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[value] = true;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeSpell = {
							order = 4,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[value] = nil;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						description = {
							order = 6,
							type = "descriptiption",
							name = L["If this list is empty, and if 'Interruptible' is checked, then the filter will activate on any type of cast that can be interrupted."],
						},
					}
				},
				combat = {
					order = 9,
					type = 'group',
					name = COMBAT,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						inCombat = {
							name = L["Player in Combat"],
							desc = L["If enabled then the filter will only activate when you are in combat."],
							order = 1,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.inCombat
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.inCombat = value
								NP:ConfigureAll()
							end,
						},
						outOfCombat = {
							name = L["Player Out of Combat"],
							desc = L["If enabled then the filter will only activate when you are out of combat."],
							order = 2,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.outOfCombat
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.outOfCombat = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = '',
						},
						inCombatUnit = {
							name = L["Unit in Combat"],
							desc = L["If enabled then the filter will only activate when the unit is in combat."],
							order = 4,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.inCombatUnit
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.inCombatUnit = value
								NP:ConfigureAll()
							end,
						},
						outOfCombatUnit = {
							name = L["Unit Out of Combat"],
							desc = L["If enabled then the filter will only activate when the unit is out of combat."],
							order = 5,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.outOfCombatUnit
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.outOfCombatUnit = value
								NP:ConfigureAll()
							end,
						}
					},
				},
				class = {
					order = 10,
					type = 'group',
					name = CLASS,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {}
				},
				role = {
					order = 11,
					type = 'group',
					name = ROLE,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						tank = {
							type = 'toggle',
							order = 1,
							name = TANK,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.role.tank
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.role.tank = value
								NP:ConfigureAll()
							end,
						},
						healer = {
							type = 'toggle',
							order = 1,
							name = HEALER,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.role.healer
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.role.healer = value
								NP:ConfigureAll()
							end,
						},
						damager = {
							type = 'toggle',
							order = 1,
							name = DAMAGER,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.role.damager
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.role.damager = value
								NP:ConfigureAll()
							end,
						},
					}
				},
				health = {
					order = 12,
					type = 'group',
					name = L["Health Threshold"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 2,
							type = 'description',
							name = " ",
						},
						underHealthThreshold = {
							order = 3,
							type = 'range',
							name = L["Under Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.underHealthThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.underHealthThreshold = value
								NP:ConfigureAll()
							end,
						},
						overHealthThreshold = {
							order = 4,
							type = 'range',
							name = L["Over Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.overHealthThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.overHealthThreshold = value
								NP:ConfigureAll()
							end,
						},
					},
				},
				levels = {
					order = 13,
					type = 'group',
					name = LEVEL,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.level
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.level = value
								NP:ConfigureAll()
							end,
						},
						matchLevel = {
							type = 'toggle',
							order = 2,
							name = L["Match Player Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches your own."],
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.level end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = L["LEVEL_BOSS"],
						},
						minLevel = {
							order = 4,
							type = 'range',
							name = L["Minimum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or higher than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel = value
								NP:ConfigureAll()
							end,
						},
						maxLevel = {
							order = 5,
							type = 'range',
							name = L["Maximum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel = value
								NP:ConfigureAll()
							end,
						},
						currentLevel = {
							name = L["Current Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches this value."],
							order = 6,
							type = "range",
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel or 0
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel = value
								NP:ConfigureAll()
							end,
						},
					},
				},
				buffs = {
					name = L["Buffs"],
					order = 14,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll = value
								NP:ConfigureAll()
							end,
						},
						missing = {
							order = 2,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.missing
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.missing = value
								NP:ConfigureAll()
							end,
						},
						minTimeLeft = {
							order = 3,
							type = 'range',
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a buff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.minTimeLeft
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.minTimeLeft = value
								NP:ConfigureAll()
							end,
						},
						maxTimeLeft = {
							order = 4,
							type = 'range',
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a buff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.maxTimeLeft
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.maxTimeLeft = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 5,
							type = 'description',
							name = " ",
						},
						addBuff = {
							order = 6,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[value] = true;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeBuff = {
							order = 7,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[value] = nil;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						}
					},
				},
				debuffs = {
					name = L["Debuffs"],
					order = 15,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll = value
								NP:ConfigureAll()
							end,
						},
						missing = {
							order = 2,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.missing
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.missing = value
								NP:ConfigureAll()
							end,
						},
						minTimeLeft = {
							order = 3,
							type = 'range',
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.minTimeLeft
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.minTimeLeft = value
								NP:ConfigureAll()
							end,
						},
						maxTimeLeft = {
							order = 4,
							type = 'range',
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.maxTimeLeft
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.maxTimeLeft = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 5,
							type = "description",
							name = " ",
						},
						addDebuff = {
							order = 6,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[value] = true;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeDebuff = {
							order = 7,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[value] = nil;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						}
					},
				},
				nameplateType = {
					name = L["Unit Type"],
					order = 16,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType and E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable = value
								NP:ConfigureAll()
							end,
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 1,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable end,
							args = {
								friendlyPlayer = {
									name = L["FRIENDLY_PLAYER"],
									order = 1,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer = value
										NP:ConfigureAll()
									end,
								},
								friendlyNPC = {
									name = L["FRIENDLY_NPC"],
									order = 2,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC = value
										NP:ConfigureAll()
									end,
								},
								healer = {
									name = L["HEALER"],
									order = 3,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.healer
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.healer = value
										NP:ConfigureAll()
									end,
								},
								enemyPlayer = {
									name = L["ENEMY_PLAYER"],
									order = 4,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer = value
										NP:ConfigureAll()
									end,
								},
								enemyNPC = {
									name = L["ENEMY_NPC"],
									order = 5,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC = value
										NP:ConfigureAll()
									end,
								},
								player = {
									name = L["PLAYER"],
									order = 6,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.player
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.player = value
										NP:ConfigureAll()
									end,
								},
							},
						},
					},
				},
				reactionType = {
					name = L["Reaction Type"],
					order = 17,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable = value
								NP:ConfigureAll()
							end,
						},
						reputation = {
							name = REPUTATION,
							desc = L["If this is enabled then the reaction check will use your reputation with the faction the unit belongs to."],
							order = 0,
							type = 'toggle',
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation = value
								NP:ConfigureAll()
							end,
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 1,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable end,
							args = {
								hated = {
									name = FACTION_STANDING_LABEL1,
									order = 1,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.hated
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.hated = value
										NP:ConfigureAll()
									end,
								},
								hostile = {
									name = FACTION_STANDING_LABEL2,
									order = 2,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.hostile
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.hostile = value
										NP:ConfigureAll()
									end,
								},
								unfriendly = {
									name = FACTION_STANDING_LABEL3,
									order = 3,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.unfriendly
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.unfriendly = value
										NP:ConfigureAll()
									end,
								},
								neutral = {
									name = FACTION_STANDING_LABEL4,
									order = 4,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.neutral
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.neutral = value
										NP:ConfigureAll()
									end,
								},
								friendly = {
									name = FACTION_STANDING_LABEL5,
									order = 5,
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.friendly
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.friendly = value
										NP:ConfigureAll()
									end,
								},
								honored = {
									name = FACTION_STANDING_LABEL6,
									order = 6,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.honored
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.honored = value
										NP:ConfigureAll()
									end,
								},
								revered = {
									name = FACTION_STANDING_LABEL7,
									order = 7,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.revered
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.revered = value
										NP:ConfigureAll()
									end,
								},
								exalted = {
									name = FACTION_STANDING_LABEL8,
									order = 8,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.exalted
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.exalted = value
										NP:ConfigureAll()
									end,
								},
							},
						},
					},
				},
			},
		}
		E.Options.args.nameplate.args.filters.args.actions = {
			type = "group",
			name = L["Actions"],
			order = 6,
			disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
			args = {
				hide = {
					order = 0,
					type = 'toggle',
					name = L["Hide Frame"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.hide = value
						NP:ConfigureAll()
					end,
				},
				scale = {
					order = 2,
					type = "range",
					name = L["Scale"],
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.scale or 1
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.scale = value
						NP:ConfigureAll()
					end,
					min=0.35, max = 1.5, step = 0.01,
				},
				usePortrait = {
					order = 0,
					type = 'toggle',
					name = L["Use Portrait"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.usePortrait
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.usePortrait = value
						NP:ConfigureAll()
					end,
				},
				color = {
					order = 4,
					type = "group",
					name = COLOR,
					guiInline = true,
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					args = {
						health = {
							name = L["Health"],
							order = 1,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.color.health
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.color.health = value
								NP:ConfigureAll()
							end,
						},
						healthColor = {
							name = L["Health Color"],
							type = 'color',
							order = 2,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.health end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.healthColor
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.healthColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " ",
						},
						border = {
							name = L["Border"],
							order = 4,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.color.border
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.color.border = value
								NP:ConfigureAll()
							end,
						},
						borderColor = {
							name = L["Border Color"],
							type = 'color',
							order = 5,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.border end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.borderColor
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.borderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
						spacer2 = {
							order = 6,
							type = "description",
							name = " ",
						},
						name = {
							name = L["Name"],
							order = 7,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.color.name
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.color.name = value
								NP:ConfigureAll()
							end,
						},
						nameColor = {
							name = L["Name Color"],
							type = 'color',
							order = 8,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.name end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.nameColor
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.nameColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
					},
				},
				texture = {
					order = 5,
					type = "group",
					name = L["Texture"],
					guiInline = true,
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							name = L["Enable"],
							order = 1,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.texture.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.texture.enable = value
								NP:ConfigureAll()
							end,
						},
						texture = {
							order = 2,
							type = "select",
							dialogControl = 'LSM30_Statusbar',
							name = L["Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.texture.enable end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.texture.texture
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.texture.texture = value
								NP:ConfigureAll()
							end,
						},
					},
				},
			},
		}

		UpdateClassSection()
		UpdateStyleLists()
	end
end

local ORDER = 100
local function GetUnitSettings(unit, name)
	local copyValues = {}
	for x, y in pairs(NP.db.units) do
		if(type(y) == "table" and x ~= unit) then
			copyValues[x] = L[x]
		end
	end
	local group = {
		type = "group",
		order = ORDER,
		name = name,
		childGroups = "tab",
		get = function(info) return E.db.nameplates.units[unit][ info[#info] ] end,
		set = function(info, value) E.db.nameplates.units[unit][ info[#info] ] = value; NP:ConfigureAll() end,
		disabled = function() return not E.NamePlates; end,
		args = {
			copySettings = {
				order = -10,
				name = L["Copy Settings From"],
				desc = L["Copy settings from another unit."],
				type = "select",
				values = copyValues,
				get = function() return '' end,
				set = function(info, value)
					NP:CopySettings(value, unit)
					NP:ConfigureAll()
				end,
			},
			defaultSettings = {
				order = -9,
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				type = "execute",
				func = function(info, value)
					NP:ResetSettings(unit)
					NP:ConfigureAll()
				end,
			},
			healthGroup = {
				order = 1,
				name = L["Health"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].healthbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].healthbar[ info[#info] ] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Health"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						disabled = function() return unit == "PLAYER" end,
						hidden = function() return unit == "PLAYER" end,
					},
					height = {
						order = 2,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					width = {
						order = 3,
						name = L["Width"],
						type = "range",
						min = 50, max = 200, step = 1,
					},
					textGroup = {
						order = 100,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].healthbar.text[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].healthbar.text[ info[#info] ] = value; NP:ConfigureAll() end,
						args = {
							enable = {
								order = 1,
								name = L["Enable"],
								type = "toggle",
							},
							format = {
								order = 2,
								name = L["Format"],
								type = "select",
								values = {
									['CURRENT'] = L["Current"],
									['CURRENT_MAX'] = L["Current / Max"],
									['CURRENT_PERCENT'] =  L["Current - Percent"],
									['CURRENT_MAX_PERCENT'] = L["Current - Max | Percent"],
									['PERCENT'] = L["Percent"],
									['DEFICIT'] = L["Deficit"],
								},
							},
						},
					},
				},
			},
			powerGroup = {
				order = 2,
				name = L["Power"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].powerbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].powerbar[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Power"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					hideWhenEmpty = {
						order = 2,
						name = L["Hide When Empty"],
						type = "toggle",
					},
					height = {
						order = 3,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					textGroup = {
						order = 100,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].powerbar.text[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].powerbar.text[ info[#info] ] = value; NP:ConfigureAll() end,
						args = {
							enable = {
								order = 1,
								name = L["Enable"],
								type = "toggle",
							},
							format = {
								order = 2,
								name = L["Format"],
								type = "select",
								values = {
									['CURRENT'] = L["Current"],
									['CURRENT_MAX'] = L["Current / Max"],
									['CURRENT_PERCENT'] =  L["Current - Percent"],
									['CURRENT_MAX_PERCENT'] = L["Current - Max | Percent"],
									['PERCENT'] = L["Percent"],
									['DEFICIT'] = L["Deficit"],
								},
							},
						},
					},
				},
			},
			castGroup = {
				order = 3,
				name = L["Cast Bar"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].castbar[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Cast Bar"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					hideSpellName = {
						order = 2,
						name = L["Hide Spell Name"],
						type = "toggle",
					},
					hideTime = {
						order = 3,
						name = L["Hide Time"],
						type = "toggle",
					},
					height = {
						order = 4,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					castTimeFormat = {
						order = 5,
						type = "select",
						name = L["Cast Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"],
						},
					},
					channelTimeFormat = {
						order = 6,
						type = "select",
						name = L["Channel Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"],
						},
					},
					timeToHold = {
						order = 7,
						type = "range",
						name = L["Time To Hold"],
						desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
						min = 0, max = 4, step = 0.1,
					},
				},
			},
			buffsGroup = {
				order = 4,
				name = L["Buffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].buffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].buffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Buffs"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					baseHeight = {
						order = 3,
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						type = "range",
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = FILTERS,
						order = 4,
						type = "group",
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							jumpToFilter = {
								order = 3,
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								type = "execute",
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " ",
							},
							specialFilters = {
								order = 5,
								type = "select",
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.unitframe['specialFilters']
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('buffs', unit, value)
									NP:ConfigureAll()
								end
							},
							filter = {
								order = 6,
								type = "select",
								name = L["Add Regular Filter"],
								desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
								values = function()
									local filters = {}
									local list = E.global.unitframe['aurafilters']
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('buffs', unit, value)
									NP:ConfigureAll()
								end
							},
							resetPriority = {
								order = 7,
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								type = "execute",
								func = function()
									E.db.nameplates.units[unit].buffs.filters.priority = P.nameplates.units[unit].buffs.filters.priority
									NP:ConfigureAll()
								end,
							},
							filterPriority = {
								order = 8,
								name = L["Filter Priority"],
								type = "multiselect",
								dragdrop = true,
								dragOnLeave = function() end, --keep this here
								dragOnEnter = function(info, value)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info, value)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info, value)
									filterPriority('buffs', unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info, value)
									filterPriority('buffs', unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = function(button, text, value)
									local friend, enemy = match(text, "^Friendly:([^,]*)"), match(text, "^Enemy:([^,]*)")
									return (friend and format("|cFF33FF33%s|r %s", FRIEND, friend)) or (enemy and format("|cFFFF3333%s|r %s", ENEMY, enemy))
								end,
								stateSwitchOnClick = function(info, value)
									filterPriority('buffs', unit, carryFilterFrom, nil, nil, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function(info, value)
									NP:ConfigureAll()
								end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."].."\n"..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."],
							},
						},
					},
				},
			},
			debuffsGroup = {
				order = 5,
				name = L["Debuffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Debuffs"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					baseHeight = {
						order = 3,
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						type = "range",
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = FILTERS,
						order = 4,
						type = "group",
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							jumpToFilter = {
								order = 3,
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								type = "execute",
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " ",
							},
							specialFilters = {
								order = 5,
								type = "select",
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.unitframe['specialFilters']
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('debuffs', unit, value)
									NP:ConfigureAll()
								end
							},
							filter = {
								order = 6,
								type = "select",
								name = L["Add Regular Filter"],
								desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
								values = function()
									local filters = {}
									local list = E.global.unitframe['aurafilters']
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority('debuffs', unit, value)
									NP:ConfigureAll()
								end
							},
							resetPriority = {
								order = 7,
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								type = "execute",
								func = function()
									E.db.nameplates.units[unit].debuffs.filters.priority = P.nameplates.units[unit].debuffs.filters.priority
									NP:ConfigureAll()
								end,
							},
							filterPriority = {
								order = 8,
								dragdrop = true,
								type = "multiselect",
								name = L["Filter Priority"],
								dragOnLeave = function() end, --keep this here
								dragOnEnter = function(info, value)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info, value)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info, value)
									filterPriority('debuffs', unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info, value)
									filterPriority('debuffs', unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = function(button, text, value)
									local friend, enemy = match(text, "^Friendly:([^,]*)"), match(text, "^Enemy:([^,]*)")
									return (friend and format("|cFF33FF33%s|r %s", FRIEND, friend)) or (enemy and format("|cFFFF3333%s|r %s", ENEMY, enemy))
								end,
								stateSwitchOnClick = function(info, value)
									filterPriority('debuffs', unit, carryFilterFrom, nil, nil, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function(info, value)
									NP:ConfigureAll()
								end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."].."\n"..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."],
							},
						},
					},
				},
			},
			portraitGroup = {
				order = 6,
				name = L["Portrait"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].portrait[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].portrait[ info[#info] ] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Portrait"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					width = {
						order = 2,
						name = L["Width"],
						type = "range",
						min = 5, max = 100, step = 1,
					},
					height = {
						order = 3,
						name = L["Height"],
						type = "range",
						min = 5, max = 100, step = 1,
					},
				},
			},
			levelGroup = {
				order = 7,
				name = LEVEL,
				type = "group",
				args = {
					header = {
						order = 0,
						type = "header",
						name = LEVEL,
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showLevel end,
						set = function(info, value) E.db.nameplates.units[unit].showLevel = value; NP:ConfigureAll() end,
					},
				},
			},
			nameGroup = {
				order = 8,
				name = L["Name"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].name[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].name[ info[#info] ] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Name"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showName end,
						set = function(info, value) E.db.nameplates.units[unit].showName = value; NP:ConfigureAll() end,
					},
				},
			},
		},
	}

	if unit == "PLAYER" then
		group.args.enable = {
			order = -15,
			name = L["Enable"],
			type = "toggle",
		}
		group.args.general = {
			order = 0,
			type = "group",
			name = L["General"],
			args = {
				useStaticPosition = {
					order = 1,
					type = "toggle",
					name = L["Use Static Position"],
					desc = L["When enabled the nameplate will stay visible in a locked position."],
					get = function(info) return E.db.nameplates.units[unit].useStaticPosition end,
					set = function(info, value) E.db.nameplates.units[unit].useStaticPosition = value; NP:ConfigureAll() end,
				},
				visibility = {
					order = 10,
					type = "group",
					guiInline = true,
					name = L["Visibility"],
					args = {
						showAlways = {
							order = 1,
							type = "toggle",
							name = L["Always Show"],
							get = function(info) return E.db.nameplates.units[unit].visibility.showAlways end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.showAlways = value; NP:ConfigureAll() end,
						},
						showInCombat = {
							order = 2,
							type = "toggle",
							name = L["Show In Combat"],
							get = function(info) return E.db.nameplates.units[unit].visibility.showInCombat end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.showInCombat = value; NP:ConfigureAll() end,
							disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
						},
						showWithTarget = {
							order = 2,
							type = "toggle",
							name = L["Show With Target"],
							get = function(info) return E.db.nameplates.units[unit].visibility.showWithTarget end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.showWithTarget = value; NP:ConfigureAll() end,
							disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
						},
						hideDelay = {
							order = 4,
							type = "range",
							name = L["Hide Delay"],
							min = 0, max = 20, step = 0.5,
							get = function(info) return E.db.nameplates.units[unit].visibility.hideDelay end,
							set = function(info, value) E.db.nameplates.units[unit].visibility.hideDelay = value; NP:ConfigureAll() end,
							disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
						},
					},
				},
			},
		}
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"],
		}
	elseif unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" then
		group.args.minions = {
			order = 0,
			name = L["Display Minions"],
			desc = unit == "FRIENDLY_PLAYER" and OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS or OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS,
			type = "toggle",
		}
		if unit == "ENEMY_PLAYER" then
			group.args.markHealers = {
				type = "toggle",
				order = 10,
				name = L["Healer Icon"],
				desc = L["Display a healer icon over known healers inside battlegrounds or arenas."],
				set = function(info, value) E.db.nameplates.units.ENEMY_PLAYER[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:ConfigureAll() end,
			}
		end
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"],
		}
	elseif unit == "ENEMY_NPC" then
		group.args.minors = {
			order = 0,
			name = L["Display Minor Units"],
			desc = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS,
			type = "toggle",
		}
		group.args.eliteIcon = {
			order = 10,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[ info[#info] ] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[ info[#info] ] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Elite Icon"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"],
					},
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
				},
				xOffset = {
					order = 4,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 5,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
			},
		}
		group.args.detection = {
			order = 11,
			name = L["Detection"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].detection[ info[#info] ] end,
			set = function(info, value) E.db.nameplates.units[unit].detection[ info[#info] ] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Suramar Detection"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
			},
		}
	elseif unit == "FRIENDLY_NPC" then
		group.args.eliteIcon = {
			order = 10,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[ info[#info] ] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[ info[#info] ] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Elite Icon"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"],
					},
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
				},
				xOffset = {
					order = 4,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 5,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
			},
		}
	elseif unit == "HEALER" then
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"],
		}
	end


	ORDER = ORDER + 100
	return group
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplates[ info[#info] ] end,
	set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:ConfigureAll() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[ info[#info] ] end,
			set = function(info, value) E.private.nameplates[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		intro = {
			order = 2,
			type = "description",
			name = L["NAMEPLATE_DESC"],
		},
		header = {
			order = 3,
			type = "header",
			name = L["Shortcuts"],
		},
		spacer1 = {
			order = 4,
			type = "description",
			name = " ",
		},
		generalShortcut = {
			order = 5,
			type = "execute",
			name = L["General"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "general") end,
			disabled = function() return not E.NamePlates; end,
		},
		fontsShortcut = {
			order = 6,
			type = "execute",
			name = L["Fonts"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "fontGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		classBarShortcut = {
			order = 7,
			type = "execute",
			name = L["Classbar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "classBarGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer2 = {
			order = 8,
			type = "description",
			name = " ",
		},
		threatShortcut = {
			order = 9,
			type = "execute",
			name = L["Threat"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "threatGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		castBarShortcut = {
			order = 10,
			type = "execute",
			name = L["Cast Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "castGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		reactionShortcut = {
			order = 11,
			type = "execute",
			name = L["Reaction Colors"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "reactions") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " ",
		},
		playerShortcut = {
			order = 13,
			type = "execute",
			name = L["Player Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "playerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		healerShortcut = {
			order = 14,
			type = "execute",
			name = L["Healer Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "healerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		friendlyPlayerShortcut = {
			order = 15,
			type = "execute",
			name = L["Friendly Player Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer4 = {
			order = 16,
			type = "description",
			name = " ",
		},
		enemyPlayerShortcut = {
			order = 17,
			type = "execute",
			name = L["Enemy Player Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		friendlyNPCShortcut = {
			order = 18,
			type = "execute",
			name = L["Friendly NPC Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		enemyNPCShortcut = {
			order = 19,
			type = "execute",
			name = L["Enemy NPC Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer5 = {
			order = 20,
			type = "description",
			name = " ",
		},
		filtersShortcut = {
			order = 21,
			type = "execute",
			name = L["Style Filter"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "filters") end,
			disabled = function() return not E.NamePlates; end,
		},
		generalGroup = {
			order = 22,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates; end,
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					args = {
						statusbar = {
							order = 0,
							type = "select",
							dialogControl = 'LSM30_Statusbar',
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
						},
						motionType = {
							type = "select",
							order = 1,
							name = UNIT_NAMEPLATES_TYPES,
							desc = L["Set to either stack nameplates vertically or allow them to overlap."],
							values = {
								['STACKED'] = UNIT_NAMEPLATES_TYPE_2,
								['OVERLAP'] = UNIT_NAMEPLATES_TYPE_1,
							},
						},
						displayStyle = {
							type = "select",
							order = 2,
							name = L["Display Style"],
							desc = L["Controls which nameplates will be displayed."],
							values = {
								["ALL"] = ALL,
								["BLIZZARD"] = L["Target, Quest, Combat"],
								["TARGET"] = L["Only Show Target"],
							},
						},
						showNPCTitles = {
							order = 3,
							type = "toggle",
							name = L["Show NPC Titles"],
							desc = L["Display NPC Titles whenever healthbars arent displayed and names are."]
						},
						clampToScreen = {
							order = 4,
							type = "toggle",
							name = L["Clamp Nameplates"],
							desc = L["Clamp nameplates to the top of the screen when outside of view."],
						},
						lowHealthThreshold = {
							order = 5,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, max = 1, step = 0.01,
						},
						showEnemyCombat = {
							order = 6,
							type = "select",
							name = L["Enemy Combat Toggle"],
							desc = L["Control enemy nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = DISABLE,
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[ info[#info] ] = value;
								NP:PLAYER_REGEN_ENABLED()
							end,
						},
						showFriendlyCombat = {
							order = 7,
							type = "select",
							name = L["Friendly Combat Toggle"],
							desc = L["Control friendly nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = DISABLE,
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:PLAYER_REGEN_ENABLED() end,
						},
						loadDistance = {
							order = 8,
							type = "range",
							name = L["Load Distance"],
							desc = L["Only load nameplates for units within this range."],
							min = 10, max = 100, step = 1,
						},
						clickableWidth = {
							order = 9,
							type = "range",
							name = L["Clickable Width"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 50, max = 200, step = 1,
							set = function(info, value) E.db.nameplates.clickableWidth = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						clickableHeight = {
							order = 10,
							type = "range",
							name = L["Clickable Height"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 10, max = 75, step = 1,
							set = function(info, value) E.db.nameplates.clickableHeight = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						resetFilters = {
							order = 11,
							name = "Reset Aura Filters",
							type = "execute",
							func = function(info, value)
								E:StaticPopup_Show("RESET_NP_AF") --reset nameplate aurafilters
							end,
						},
						targetedNamePlate = {
							order = 12,
							type = "group",
							guiInline = true,
							name = L["Targeted Nameplate"],
							get = function(info) return E.db.nameplates[ info[#info] ] end,
							set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:ConfigureAll() end,
							args = {
								useTargetScale = {
									order = 1,
									type = "toggle",
									name = L["Use Target Scale"],
									desc = L["Enable/Disable the scaling of targetted nameplates."],
								},
								targetScale = {
									order = 2,
									type = "range",
									isPercent = true,
									name = L["Target Scale"],
									desc = L["Scale of the nameplate that is targetted."],
									min = 0.3, max = 2, step = 0.01,
									disabled = function() return E.db.nameplates.useTargetScale ~= true end,
								},
								nonTargetTransparency = {
									order = 3,
									type = "range",
									isPercent = true,
									name = L["Non-Target Transparency"],
									desc = L["Set the transparency level of nameplates that are not the target nameplate."],
									min = 0, max = 1, step = 0.01,
								},
								spacer1 = {
									order = 4,
									type = 'description',
									name = ' ',
								},
								glowColor = {
									name = L["Target Indicator"].." "..COLOR,
									type = 'color',
									order = 5,
									hasAlpha = true,
									get = function(info)
										local t = E.db.nameplates.glowColor
										local d = P.nameplates.glowColor
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
									end,
									set = function(info, r, g, b, a)
										local t = E.db.nameplates.glowColor
										t.r, t.g, t.b, t.a = r, g, b, a
										NP:ConfigureAll()
									end,
								},
								targetGlow = {
									order = 6,
									type = "select",
									customWidth = 225,
									name = L["Target Indicator"],
									get = function(info) return E.db.nameplates.targetGlow end,
									set = function(info, value) E.db.nameplates.targetGlow = value; NP:ConfigureAll() end,
									values = {
										['none'] = NONE,
										['style1'] = L["Border Glow"],
										['style2'] = L["Background Glow"],
										['style3'] = L["Top Arrow"],
										['style4'] = L["Side Arrows"],
										['style5'] = L["Border Glow"].." + "..L["Top Arrow"],
										['style6'] = L["Background Glow"].." + "..L["Top Arrow"],
										['style7'] = L["Border Glow"].." + "..L["Side Arrows"],
										['style8'] = L["Background Glow"].." + "..L["Side Arrows"],
									},
								},
								alwaysShowTargetHealth = {
									order = 7,
									type = "toggle",
									name = L["Always Show Target Health"],
									customWidth = 200,
								},
							},
						},
						clickThrough = {
							order = 13,
							type = "group",
							guiInline = true,
							name = L["Click Through"],
							get = function(info) return E.db.nameplates.clickThrough[ info[#info] ] end,
							args = {
								personal = {
									order = 1,
									type = "toggle",
									name = L["Personal"],
									set = function(info, value) E.db.nameplates.clickThrough.personal = value; NP:SetNamePlateSelfClickThrough() end,
								},
								friendly = {
									order = 2,
									type = "toggle",
									name = L["Friendly"],
									set = function(info, value) E.db.nameplates.clickThrough.friendly = value; NP:SetNamePlateFriendlyClickThrough() end,
								},
								enemy = {
									order = 3,
									type = "toggle",
									name = L["Enemy"],
									set = function(info, value) E.db.nameplates.clickThrough.enemy = value; NP:SetNamePlateEnemyClickThrough() end,
								},
							},
						},
					},
				},
				fontGroup = {
					order = 100,
					type = 'group',
					name = L["Fonts"],
					args = {
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 4,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
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
					},
				},
				classBarGroup = {
					order = 125,
					type = "group",
					name = L["Classbar"],
					get = function(info) return E.db.nameplates.classbar[ info[#info] ] end,
					set = function(info, value) E.db.nameplates.classbar[ info[#info] ] = value; NP:ConfigureAll() end,
					args = {
						enable = {
							type = "toggle",
							order = 1,
							name = L["Enable"]
						},
						attachTo = {
							type = "select",
							order = 2,
							name = L["Attach To"],
							values = {
								PLAYER = L["Player Nameplate"],
								TARGET = L["Targeted Nameplate"],
							},
						},
						position = {
							type = "select",
							order = 3,
							name = L["Position"],
							values = {
								ABOVE = L["Above"],
								BELOW = L["Below"],
							},
						},
					},
				},
				threatGroup = {
					order = 150,
					type = "group",
					name = L["Threat"],
					get = function(info)
						local t = E.db.nameplates.threat[ info[#info] ]
						local d = P.nameplates.threat[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.threat[ info[#info] ]
						t.r, t.g, t.b = r, g, b
					end,
					args = {
						useThreatColor = {
							order = 1,
							type = "toggle",
							name = L["Use Threat Color"],
							get = function(info) return E.db.nameplates.threat.useThreatColor end,
							set = function(info, value) E.db.nameplates.threat.useThreatColor = value; end,
						},
						goodColor = {
							type = "color",
							order = 2,
							name = L["Good Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						badColor = {
							name = L["Bad Color"],
							order = 3,
							type = 'color',
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						goodTransition = {
							type = "color",
							order = 4,
							name = L["Good Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						badTransition = {
							name = L["Bad Transition Color"],
							order = 5,
							type = 'color',
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						beingTankedByTank = {
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							order = 6,
							type = "toggle",
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						beingTankedByTankColor = {
							name = L["Tanked Color"],
							order = 7,
							type = 'color',
							hasAlpha = false,
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end,
						},
						goodScale = {
							name = L["Good Scale"],
							order = 8,
							type = 'range',
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
						},
						badScale = {
							name = L["Bad Scale"],
							order = 9,
							type = 'range',
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
						},
					},
				},
				castGroup = {
					order = 175,
					type = "group",
					name = L["Cast Bar"],
					get = function(info)
						local t = E.db.nameplates[ info[#info] ]
						local d = P.nameplates[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:ForEachPlate("ConfigureElement_CastBar")
					end,
					args = {
						castColor = {
							type = "color",
							order = 1,
							name = L["Cast Color"],
							hasAlpha = false,
						},
						castNoInterruptColor = {
							name = L["Cast No Interrupt Color"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
					},
				},
				reactions = {
					order = 200,
					type = "group",
					name = L["Reaction Colors"],
					get = function(info)
						local t = E.db.nameplates.reactions[ info[#info] ]
						local d = P.nameplates.reactions[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.reactions[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:ForEachPlate("UpdateElement_HealthColor", true)
						NP:ForEachPlate("UpdateElement_Name", true)
					end,
					args = {
						--[[offline = {
							type = "color",
							order = 1,
							name = L["Offline"],
							hasAlpha = false,
						},]]
						bad = {
							name = L["Enemy"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
						neutral = {
							name = L["Neutral"],
							order = 3,
							type = 'color',
							hasAlpha = false,
						},
						good = {
							name = L["Friendly"],
							order = 4,
							type = 'color',
							hasAlpha = false,
						},
						tapped = {
							name = L["Tagged NPC"],
							order = 5,
							type = 'color',
							hasAlpha = false,
						},
					},
				},
			},
		},
		playerGroup = GetUnitSettings("PLAYER", L["Player Frame"]),
		healerGroup = GetUnitSettings("HEALER", L["Healer Frames"]),
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["Friendly Player Frames"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["Enemy Player Frames"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["Friendly NPC Frames"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["Enemy NPC Frames"]),
		filters = {
			type = "group",
			order = -99,
			name = L["Style Filter"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates; end,
			args = {
				addFilter = {
					order = 1,
					name = L["Add Nameplate Filter"],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if match(value, "^[%s%p]-$") then
							return
						end
						if E.global['nameplate']['filters'][value] then
							E:Print(L["Filter already exists!"])
							return
						end
						E.global.nameplate.filters[value] = GetStyleFilterDefaultOptions(value);
						UpdateFilterGroup();
						NP:ConfigureAll()
					end,
				},
				removeFilter = {
					order = 2,
					name = L["Remove Nameplate Filter"],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if match(value, "^[%s%p]-$") then
							return
						end
						if G.nameplate.filters[value] then
							E.db.nameplates.filters[value].triggers.enable = false;
							E:Print(L["You can't remove a default name from the filter, disabling the name."])
						else
							for profile in pairs(E.data.profiles) do
								if E.data.profiles[profile].nameplates and E.data.profiles[profile].nameplates.filters and E.data.profiles[profile].nameplates.filters[value] then
									E.data.profiles[profile].nameplates.filters[value] = nil;
								end
							end
							E.global.nameplate.filters[value] = nil;
							selectedNameplateFilter = nil;
						end
						UpdateFilterGroup();
						NP:ConfigureAll()
					end,
				},
				selectFilter = {
					name = L["Select Nameplate Filter"],
					type = 'select',
					order = 3,
					get = function(info) return selectedNameplateFilter end,
					set = function(info, value) selectedNameplateFilter = value; UpdateFilterGroup() end,
					values = function()
						local filters, priority, name, profile = {}
						local list = E.global.nameplate.filters
						local profile = E.db.nameplates.filters
						if not list then return end
						for filter, content in pairs(list) do
							priority = (content.triggers and content.triggers.priority) or "?"
							name = (content.triggers and profile[filter] and profile[filter].triggers and profile[filter].triggers.enable and filter) or (content.triggers and format("|cFF666666%s|r", filter)) or filter
							filters[filter] = format("|cFFffff00(%s)|r %s", priority, name)
						end
						return filters
					end,
				},
			},
		},
	},
}
