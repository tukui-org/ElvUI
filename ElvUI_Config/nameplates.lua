local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
local GetTalentInfo = GetTalentInfo
local GetPvpTalentInfo = GetPvpTalentInfo
local GetDifficultyInfo = GetDifficultyInfo
local pairs, type, strsplit, match, gsub = pairs, type, strsplit, string.match, string.gsub
local DUNGEON_DIFFICULTY, RAID_INFO_WORLD_BOSS = DUNGEON_DIFFICULTY, RAID_INFO_WORLD_BOSS
local PLAYER_DIFFICULTY1, ITEM_QUALITY3_DESC, SPEED, DISABLE = PLAYER_DIFFICULTY1, ITEM_QUALITY3_DESC, SPEED, DISABLE
local LEVEL, NONE, REPUTATION, COMBAT, FILTERS, TALENT, ELITE = LEVEL, NONE, REPUTATION, COMBAT, FILTERS, TALENT, ELITE
local ARENA, RAID, DUNGEONS, BATTLEFIELDS, SCENARIOS = ARENA, RAID, DUNGEONS, BATTLEFIELDS, SCENARIOS
local BLOCK, FRIEND, ENEMY, CLASS, ROLE, TANK, HEALER, DAMAGER, COLOR = BLOCK, FRIEND, ENEMY, CLASS, ROLE, TANK, HEALER, DAMAGER, COLOR
local OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS = OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS
local FACTION_STANDING_LABEL1 = FACTION_STANDING_LABEL1
local FACTION_STANDING_LABEL2 = FACTION_STANDING_LABEL2
local FACTION_STANDING_LABEL3 = FACTION_STANDING_LABEL3
local FACTION_STANDING_LABEL4 = FACTION_STANDING_LABEL4
local FACTION_STANDING_LABEL5 = FACTION_STANDING_LABEL5
local FACTION_STANDING_LABEL6 = FACTION_STANDING_LABEL6
local FACTION_STANDING_LABEL7 = FACTION_STANDING_LABEL7
local FACTION_STANDING_LABEL8 = FACTION_STANDING_LABEL8
local GARRISON_CURRENT_LEVEL = GARRISON_CURRENT_LEVEL --"Tier %d";
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: MAX_PLAYER_LEVEL, AceGUIWidgetLSMlists, CUSTOM_CLASS_COLORS

local selectedNameplateFilter

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
				local tbl, sv = {strsplit(",",filter)}
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

local specListOrder = 50 -- start at 50
local classTable, classIndexTable, classOrder
local function UpdateClassSpec(classTag, enabled)
	if not (classTable[classTag] and classTable[classTag].classID) then return end
	local classSpec = format("%s%s", classTag, "spec");
	if (enabled == false) then
		if E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] then
			E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] = nil
			specListOrder = specListOrder-1
		end
		return -- stop when we remove one OR when we pass disable with clear filter
	end
	if not E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] then
		specListOrder = specListOrder+1
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
		local specID, name = GetSpecializationInfoForClassID(classTable[classTag].classID, i)
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
			for classTag in pairs(classTable) do
				tinsert(classIndexTable, classTag)
			end
			tsort(classIndexTable)
		end
		classOrder = 0
		local coloredName;
		for _, classTag in ipairs(classIndexTable) do
			classOrder = classOrder + 1
			coloredName = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classTag]
			coloredName = (coloredName and coloredName.colorStr) or "ff666666"
			local classTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class
			if classTrigger then
				if classTrigger[classTag] and classTrigger[classTag].enabled then
					UpdateClassSpec(classTag) --populate enabled class spec boxes
				else
					UpdateClassSpec(classTag, false)
				end
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

local formatStr = [[|T%s:12:12:0:0:64:64:4:60:4:60|t %s]]
local function GetTalentString(tier, column)
	local _, name, texture = GetTalentInfo(tier, column, 1);
	return formatStr:format(texture, name);
end

local function GetPvpTalentString(tier, column)
	local _, name, texture = GetPvpTalentInfo(tier, column, 1);
	return formatStr:format(texture, name);
end

local function GenerateValues(tier, isPvP)
	local values = {};

	for i = 1, 3 do
		values[i] = isPvP and GetPvpTalentString(tier, i) or GetTalentString(tier, i);
	end

	return values;
end

local function UpdateTalentSection()
	if E.global.nameplate.filters[selectedNameplateFilter] then
		local maxTiers = (E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == "normal" and 7) or 6;
		E.Options.args.nameplate.args.filters.args.triggers.args.talent.args = {
			enabled = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
				get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled end,
				set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled = value; UpdateTalentSection(); NP:ConfigureAll() end
			},
			type = {
				type = 'toggle',
				order = 2,
				name = L["Is PvP Talents"],
				disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled end,
				get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == "pvp" end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type = value and "pvp" or "normal";
					UpdateTalentSection();
					NP:ConfigureAll();
				end
			},
			requireAll = {
				type = 'toggle',
				order = 3,
				name = L["Require All"],
				disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled end,
				get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.requireAll end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.requireAll = value;
					UpdateTalentSection();
					NP:ConfigureAll();
				end
			},
		}

		if not E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers then
			E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers = {
				type = 'group',
				order = 4,
				name = L["Tiers"],
				guiInline = true,
				disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled end,
				args = {}
			}
		end

		local order = 1;
		for i = 1, maxTiers do
			E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers.args["tier"..i.."enabled"] = {
				type = 'toggle',
				order = order,
				name = format(GARRISON_CURRENT_LEVEL, i),
				get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i..'enabled'] end,
				set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i..'enabled'] = value; UpdateTalentSection(); NP:ConfigureAll() end
			}
			order = order + 1;
			if (E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i..'enabled']) then
				E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers.args["tier"..i] = {
					type = 'group',
					order = order,
					guiInline = true,
					name = L['Tier '..i],
					args = {
						missing = {
							type = 'toggle',
							order = 2,
							name = L["Missing"],
							desc = L["Match this trigger if the talent is not selected"],
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i].missing end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i].missing = value; UpdateTalentSection(); NP:ConfigureAll() end,
						},
						column = {
							type = 'select',
							order = 1,
							name = TALENT,
							style = 'dropdown',
							desc = L["Talent to match"],
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i].column end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i].column = value; NP:ConfigureAll() end,
							values = function() return GenerateValues(i, E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == "pvp") end,
						},
					}
				}
				order = order + 1;
			end
			E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers.args["spacer"..i] = {
				order = order,
				type = 'description',
				name = '',
			}
			order = order + 1
		end
	end
end

local function UpdateInstanceDifficulty()
	if (E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party) then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.dungeonDifficulty = {
			type = 'group',
			name = DUNGEON_DIFFICULTY,
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			guiInline = true,
			order = 10,
			get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[info[#info]] end,
			set = function(info, value)
				E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[info[#info]] = value;
				UpdateInstanceDifficulty();
				NP:ConfigureAll();
			end,
			args = {
				normal = {
					type = 'toggle',
					name = GetDifficultyInfo(1),
					order = 1,
				},
				heroic = {
					type = 'toggle',
					name = GetDifficultyInfo(2),
					order = 2,
				},
				mythic = {
					type = 'toggle',
					name = GetDifficultyInfo(23),
					order = 3,
				},
				["mythic+"] = {
					type = 'toggle',
					name = GetDifficultyInfo(8),
					order = 4,
				},
				["timewalking"] = {
					type = 'toggle',
					name = GetDifficultyInfo(24),
					order = 5,
				},
			};
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.dungeonDifficulty = nil;
	end

	if (E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid) then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.raidDifficulty = {
			type = 'group',
			name = L["Raid Difficulty"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			guiInline = true,
			order = 11,
			get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[info[#info]] end,
			set = function(info, value)
				E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[info[#info]] = value;
				UpdateInstanceDifficulty();
				NP:ConfigureAll();
			end,
			args = {
				lfr = {
					type = 'toggle',
					name = GetDifficultyInfo(17),
					order = 1,
				},
				normal = {
					type = 'toggle',
					name = GetDifficultyInfo(14),
					order = 2,
				},
				heroic = {
					type = 'toggle',
					name = GetDifficultyInfo(15),
					order = 3,
				},
				mythic = {
					type = 'toggle',
					name = GetDifficultyInfo(16),
					order = 4,
				},
				timewalking = {
					type = 'toggle',
					name = GetDifficultyInfo(24),
					order = 5,
				},
				legacy10normal = {
					type = 'toggle',
					name = GetDifficultyInfo(3),
					order = 6,
				},
				legacy25normal = {
					type = 'toggle',
					name = GetDifficultyInfo(4),
					order = 7,
				},
				legacy10heroic = {
					type = 'toggle',
					name = GetDifficultyInfo(5),
					order = 8,
				},
				legacy25heroic = {
					type = 'toggle',
					name = GetDifficultyInfo(6),
					order = 9,
				}
			};
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.raidDifficulty = nil;
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
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.names) do
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
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells) do
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

	if E.global.nameplate.filters[selectedNameplateFilter] and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {},
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names) do
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
				E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names.args[name] = {
					name = spell,
					type = "select",
					values = {
						["DISABLED"] = DISABLE,
						["ONCD"] = L["On Cooldown"],
						["OFFCD"] = L["Off Cooldown"],
					},
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[name] = value
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
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) do
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
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) do
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
						local filter = {};
						if G.nameplate.filters[selectedNameplateFilter] then
							filter = E:CopyTable(filter, G.nameplate.filters[selectedNameplateFilter]);
						end
						NP:StyleFilterInitializeFilter(filter);
						E.global.nameplate.filters[selectedNameplateFilter] = filter;
						UpdateStyleLists()
						UpdateClassSection()
						UpdateTalentSection()
						UpdateInstanceDifficulty()
						NP:ConfigureAll()
					end,
				},
				spacer1 = {
					order = 3,
					type = 'description',
					name = '',
				},
				names = {
					name = L["Name"],
					order = 6,
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
				targeting = {
					name = L["Targeting"],
					order = 7,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						isTarget = {
							name = L["Is Targeted"],
							desc = L["If enabled then the filter will only activate when you are targeting the unit."],
							order = 1,
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
							desc = L["If enabled then the filter will only activate when you are not targeting the unit."],
							order = 2,
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
						spacer2 = {
							order = 3,
							type = 'description',
							name = '',
						},
						targetMe = {
							name = L["Is Targeting Player"],
							desc = L["If enabled then the filter will only activate when the unit is targeting you."],
							order = 4,
							type = 'toggle',
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.targetMe
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.targetMe = value
								NP:ConfigureAll()
							end,
						},
						notTargetMe = {
							name = L["Is Not Targeting Player"],
							desc = L["If enabled then the filter will only activate when the unit is not targeting you."],
							order = 5,
							type = 'toggle',
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.notTargetMe
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.notTargetMe = value
								NP:ConfigureAll()
							end,
						},
					}
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
						notInterruptible = {
							type = 'toggle',
							order = 2,
							name = L["Non-Interruptable"],
							desc = L["If enabled then the filter will only activate if the unit is casting not interruptible spells."],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.notInterruptible
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.notInterruptible = value
								NP:ConfigureAll()
							end,
						},
						spacer2 = {
							order = 3,
							type = 'description',
							name = '',
						},
						addSpell = {
							order = 4,
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
							order = 5,
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
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						inCombat = {
							name = L["Player in Combat"],
							desc = L["If enabled then the filter will only activate when you are in combat."],
							order = 1,
							type = 'toggle',
						},
						outOfCombat = {
							name = L["Player Out of Combat"],
							desc = L["If enabled then the filter will only activate when you are out of combat."],
							order = 2,
							type = 'toggle',
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
						},
						outOfCombatUnit = {
							name = L["Unit Out of Combat"],
							desc = L["If enabled then the filter will only activate when the unit is out of combat."],
							order = 5,
							type = 'toggle',
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
				talent = {
					order = 11,
					type = 'group',
					name = TALENT,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {}
				},
				role = {
					order = 12,
					type = 'group',
					name = ROLE,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.role[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.role[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						tank = {
							type = 'toggle',
							order = 1,
							name = TANK,
						},
						healer = {
							type = 'toggle',
							order = 2,
							name = HEALER,
						},
						damager = {
							type = 'toggle',
							order = 3,
							name = DAMAGER,
						},
					}
				},
				classification = {
					order = 13,
					type = 'group',
					name = L["Classification"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.classification[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.classification[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						worldboss = {
							type = 'toggle',
							order = 1,
							name = RAID_INFO_WORLD_BOSS,
						},
						rareelite = {
							type = 'toggle',
							order = 2,
							name = L["Rare Elite"],
						},
						normal = {
							type = 'toggle',
							order = 3,
							name = PLAYER_DIFFICULTY1,
						},
						rare = {
							type = 'toggle',
							order = 4,
							name = ITEM_QUALITY3_DESC,
						},
						trivial = {
							type = 'toggle',
							order = 5,
							name = L["Trivial"],
						},
						elite = {
							type = 'toggle',
							order = 6,
							name = ELITE,
						},
						minus = {
							type = 'toggle',
							order = 7,
							name = L["Minus"],
						},
						questBoss = {
							name = L["Quest Boss"],
							order = 8,
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
					}
				},
				health = {
					order = 14,
					type = 'group',
					name = L["Health Threshold"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						healthThreshold = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
						},
						healthUsePlayer = {
							type = 'toggle',
							order = 2,
							name = L["Player Health"],
							desc = L["Enabling this will check your health amount."],
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold end,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = " ",
						},
						underHealthThreshold = {
							order = 4,
							type = 'range',
							name = L["Under Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.underHealthThreshold or 0 end,
						},
						overHealthThreshold = {
							order = 5,
							type = 'range',
							name = L["Over Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.overHealthThreshold or 0 end,
						},
					},
				},
				power = {
					order = 15,
					type = 'group',
					name = L["Power Threshold"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						powerThreshold = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
						},
						powerUsePlayer = {
							type = 'toggle',
							order = 2,
							name = L["Player Power"],
							desc = L["Enabling this will check your power amount."],
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.powerThreshold end,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = " ",
						},
						underPowerThreshold = {
							order = 4,
							type = 'range',
							name = L["Under Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.powerThreshold end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.underPowerThreshold or 0 end,
						},
						overPowerThreshold = {
							order = 5,
							type = 'range',
							name = L["Over Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.powerThreshold end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.overPowerThreshold or 0 end,
						},
					},
				},
				levels = {
					order = 16,
					type = 'group',
					name = LEVEL,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						level = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
						},
						mylevel = {
							type = 'toggle',
							order = 2,
							name = L["Match Player Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches your own."],
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].triggers.level end,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = L["LEVEL_BOSS"],
						},
						minlevel = {
							order = 4,
							type = 'range',
							name = L["Minimum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or higher than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel or 0 end,
						},
						maxlevel = {
							order = 5,
							type = 'range',
							name = L["Maximum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel or 0 end,
						},
						curlevel = {
							name = L["Current Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches this value."],
							order = 6,
							type = "range",
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel or 0 end,
						},
					},
				},
				cooldowns = {
					name = L["Cooldowns"],
					order = 17,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all cooldowns to activate the filter. Otherwise it will only require any one of the cooldowns to activate it."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll = value
								NP:ConfigureAll()
							end,
						},
						spacer1 = {
							order = 5,
							type = 'description',
							name = " ",
						},
						addCooldown = {
							order = 6,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = "ONCD";
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeCooldown = {
							order = 7,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = nil;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						}
					},
				},
				buffs = {
					name = L["Buffs"],
					order = 18,
					type = "group",
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = "toggle",
						},
						missing = {
							order = 2,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = "toggle",
						},
						minTimeLeft = {
							order = 3,
							type = 'range',
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a buff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
						},
						maxTimeLeft = {
							order = 4,
							type = 'range',
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a buff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
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
					order = 19,
					type = "group",
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = "toggle",
						},
						missing = {
							order = 2,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
						},
						minTimeLeft = {
							order = 3,
							type = 'range',
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
						},
						maxTimeLeft = {
							order = 4,
							type = 'range',
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
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
					order = 20,
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
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType[info[#info]] end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType[info[#info]] = value; NP:ConfigureAll() end,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable end,
							args = {
								friendlyPlayer = {
									name = L["FRIENDLY_PLAYER"],
									order = 1,
									type = 'toggle',
								},
								friendlyNPC = {
									name = L["FRIENDLY_NPC"],
									order = 2,
									type = 'toggle',
								},
								healer = {
									name = L["HEALER"],
									order = 3,
									type = 'toggle',
								},
								enemyPlayer = {
									name = L["ENEMY_PLAYER"],
									order = 4,
									type = 'toggle',
								},
								enemyNPC = {
									name = L["ENEMY_NPC"],
									order = 5,
									type = 'toggle',
								},
								player = {
									name = L["PLAYER"],
									order = 6,
									type = 'toggle',
								},
							},
						},
					},
				},
				reactionType = {
					name = L["Reaction Type"],
					order = 21,
					type = "group",
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
						},
						reputation = {
							name = REPUTATION,
							desc = L["If this is enabled then the reaction check will use your reputation with the faction the unit belongs to."],
							order = 0,
							type = 'toggle',
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable end,
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
								},
								hostile = {
									name = FACTION_STANDING_LABEL2,
									order = 2,
									type = 'toggle',
								},
								unfriendly = {
									name = FACTION_STANDING_LABEL3,
									order = 3,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								neutral = {
									name = FACTION_STANDING_LABEL4,
									order = 4,
									type = 'toggle',
								},
								friendly = {
									name = FACTION_STANDING_LABEL5,
									order = 5,
									type = 'toggle',
								},
								honored = {
									name = FACTION_STANDING_LABEL6,
									order = 6,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								revered = {
									name = FACTION_STANDING_LABEL7,
									order = 7,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								exalted = {
									name = FACTION_STANDING_LABEL8,
									order = 8,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
							},
						},
					},
				},
				instanceType = {
					order = 22,
					type = 'group',
					name = L["Instance Type"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						none = {
							type = 'toggle',
							order = 1,
							name = NONE,
						},
						scenario = {
							type = 'toggle',
							order = 2,
							name = SCENARIOS,
						},
						party = {
							type = 'toggle',
							order = 3,
							name = DUNGEONS,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party = value
								UpdateInstanceDifficulty();
								NP:ConfigureAll()
							end,
						},
						raid = {
							type = 'toggle',
							order = 5,
							name = RAID,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid = value
								UpdateInstanceDifficulty();
								NP:ConfigureAll()
							end,
						},
						arena = {
							type = 'toggle',
							order = 7,
							name = ARENA,
						},
						pvp = {
							type = 'toggle',
							order = 8,
							name = BATTLEFIELDS,
						},
					}
				},
			},
		}
		E.Options.args.nameplate.args.filters.args.actions = {
			type = "group",
			name = L["Actions"],
			order = 6,
			get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].actions[info[#info]] end,
			set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].actions[info[#info]] = value; NP:ConfigureAll() end,
			disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
			args = {
				hide = {
					order = 1,
					type = 'toggle',
					name = L["Hide Frame"],
				},
				usePortrait = {
					order = 2,
					type = 'toggle',
					name = L["Use Portrait"],
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
				},
				nameOnly = {
					name = L["Name Only"],
					order = 3,
					type = 'toggle',
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = " ",
				},
				scale = {
					order = 5,
					type = "range",
					name = L["Scale"],
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].actions.scale or 1 end,
					min=0.35, max = 1.5, step = 0.01,
				},
				alpha = {
					order = 6,
					type = "range",
					name = L["Alpha"],
					desc = L["Change the alpha level of the frame."],
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].actions.alpha or -1 end,
					min=-1, max = 100, step = 1,
				},
				frameLevel = {
					name = L["Frame Level"],
					desc = L["NAMEPLATE_FRAMELEVEL_DESC"],
					order = 7,
					type = "range",
					min = 0, max = 10, step = 1,
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].actions.frameLevel or 0 end,
				},
				color = {
					order = 10,
					type = "group",
					name = COLOR,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].actions.color[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].actions.color[info[#info]] = value; NP:ConfigureAll() end,
					guiInline = true,
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					args = {
						health = {
							name = L["Health"],
							order = 1,
							type = 'toggle',
						},
						healthColor = {
							name = L["Health Color"],
							type = 'color',
							order = 2,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.health end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.healthColor
								return t.r, t.g, t.b, t.a, 136/255, 255/255, 102/255, 1
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
						power = {
							name = L["Power"],
							order = 4,
							type = 'toggle',
						},
						powerColor = {
							name = L["Power Color"],
							type = 'color',
							order = 5,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.power end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.powerColor
								return t.r, t.g, t.b, t.a, 102/255, 136/255, 255/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.powerColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
						spacer2 = {
							order = 6,
							type = "description",
							name = " ",
						},
						border = {
							name = L["Border"],
							order = 7,
							type = 'toggle',
						},
						borderColor = {
							name = L["Border Color"],
							type = 'color',
							order = 8,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.border end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.borderColor
								return t.r, t.g, t.b, t.a, 0, 0, 0, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.borderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
						spacer3 = {
							order = 9,
							type = "description",
							name = " ",
						},
						name = {
							name = L["Name"],
							order = 10,
							type = 'toggle',
						},
						nameColor = {
							name = L["Name Color"],
							type = 'color',
							order = 11,
							hasAlpha = true,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.name end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.nameColor
								return t.r, t.g, t.b, t.a, 200/255, 200/255, 200/255, 1
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
					order = 20,
					type = "group",
					name = L["Texture"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].actions.texture[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].actions.texture[info[#info]] = value; NP:ConfigureAll() end,
					guiInline = true,
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							name = L["Enable"],
							order = 1,
							type = 'toggle',
						},
						texture = {
							order = 2,
							type = "select",
							dialogControl = 'LSM30_Statusbar',
							name = L["Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not E.global.nameplate.filters[selectedNameplateFilter].actions.texture.enable end,
						},
					},
				},
				flashing = {
					order = 30,
					type = "group",
					name = L["Flash"],
					guiInline = true,
					disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							name = L["Enable"],
							order = 1,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.flash.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.flash.enable = value
								NP:ConfigureAll()
							end,
						},
						speed = {
							order = 2,
							type = "range",
							name = SPEED,
							disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.flash.speed or 4
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.flash.speed = value
								NP:ConfigureAll()
							end,
							min=1, max = 10, step = 1,
						},
						color = {
							name = COLOR,
							type = 'color',
							order = 3,
							hasAlpha = true,
							disabled = function() return E.global.nameplate.filters[selectedNameplateFilter].actions.hide end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.flash.color
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.flash.color
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
						},
					},
				},
			},
		}

		specListOrder = 50 -- reset this to 50
		UpdateClassSection()
		UpdateTalentSection()
		UpdateInstanceDifficulty()
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
				func = function(info)
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
					sourceInterrupt = {
						order = 4,
						type = 'toggle',
						name = L["Display Interrupt Source"],
						desc = L["Display the unit name who interrupted a spell on the castbar. You should increase the 'Time to Hold' to show properly."],
					},
					sourceInterruptClassColor = {
						order = 4,
						type = 'toggle',
						name = L["Show Interrupt Source in Class Color"],
						disabled = function() return not E.db.nameplates.units[unit].castbar.sourceInterrupt end,
					},
					-- order 5 is player Display Target
					height = {
						order = 6,
						name = L["Height"],
						type = "range",
						min = 4, max = 20, step = 1,
					},
					castTimeFormat = {
						order = 7,
						type = "select",
						name = L["Cast Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"],
						},
					},
					channelTimeFormat = {
						order = 8,
						type = "select",
						name = L["Channel Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"],
						},
					},
					timeToHold = {
						order = 9,
						type = "range",
						name = L["Time To Hold"],
						desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
						min = 0, max = 4, step = 0.1,
					},
					iconPosition = {
						order = 10,
						type = "select",
						name = L["Icon Position"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"],
						},
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
					widthOverride = {
						order = 4,
						name = L["Icon Width Override"],
						desc = L["If not set to 0 then set the width of the Aura Icon to this"],
						type = "range",
						min = 0, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = FILTERS,
						order = 5,
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
								sortByValue = true,
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
									local list = E.global.unitframe.aurafilters
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
								dragOnEnter = function(info)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info)
									filterPriority('buffs', unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info)
									filterPriority('buffs', unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = function(_, TEXT)
									local friend, enemy = match(TEXT, "^Friendly:([^,]*)"), match(TEXT, "^Enemy:([^,]*)")
									local text = friend or enemy or TEXT
									local SF, localized = E.global.unitframe.specialFilters[text], L[text]
									local blockText = SF and localized and text:match("^block") and localized:gsub("^%[.-]%s?", "")
									local filterText = (blockText and format("|cFF999999%s|r %s", BLOCK, blockText)) or localized or text
									return (friend and format("|cFF33FF33%s|r %s", FRIEND, filterText)) or (enemy and format("|cFFFF3333%s|r %s", ENEMY, filterText)) or filterText
								end,
								stateSwitchOnClick = function()
									filterPriority('buffs', unit, carryFilterFrom, nil, nil, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(_, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function()
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
					widthOverride = {
						order = 4,
						name = L["Icon Width Override"],
						desc = L["If not set to 0 then set the width of the Aura Icon to this"],
						type = "range",
						min = 0, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = FILTERS,
						order = 5,
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
								sortByValue = true,
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
									local list = E.global.unitframe.aurafilters
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
								dragOnEnter = function(info)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info)
									filterPriority('debuffs', unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info)
									filterPriority('debuffs', unit, carryFilterFrom, true)
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
								set = function(info)
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
							desc = L["When using Static Position, this option also requires the target to be attackable."],
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
		group.args.castGroup.args.displayTarget = {
			order = 5,
			type = 'toggle',
			name = L["Display Target"],
			desc = L["Display the target of your current cast. Useful for mouseover casts."],
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
		cooldownShortcut = {
			order = 7,
			type = "execute",
			name = L["Cooldowns"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "cooldown", "nameplates") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer2 = {
			order = 8,
			type = "description",
			name = " ",
		},
		classBarShortcut = {
			order = 9,
			type = "execute",
			name = L["Classbar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "classBarGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		threatShortcut = {
			order = 10,
			type = "execute",
			name = L["Threat"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "threatGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		castBarShortcut = {
			order = 11,
			type = "execute",
			name = L["Cast Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "castGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " ",
		},
		reactionShortcut = {
			order = 13,
			type = "execute",
			name = L["Reaction Colors"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "reactions") end,
			disabled = function() return not E.NamePlates; end,
		},
		healPredictionShortcut = {
			order = 14,
			type = "execute",
			name = L["Heal Prediction"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "healPrediction") end,
			disabled = function() return not E.NamePlates; end,
		},
		cutawayHealthShortcut = {
			order = 15,
			type = "execute",
			name = L["Cutaway Health"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "cutawayHealth") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer4 = {
			order = 16,
			type = "description",
			name = " ",
		},
		questIcon = {
			order = 17,
			type = "execute",
			name = L["Quest Icon"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "questIcon") end,
			disabled = function() return not E.NamePlates; end,
		},
		playerShortcut = {
			order = 17,
			type = "execute",
			name = L["Player Frame"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "playerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		healerShortcut = {
			order = 18,
			type = "execute",
			name = L["Healer Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "healerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer5 = {
			order = 19,
			type = "description",
			name = " ",
		},
		friendlyPlayerShortcut = {
			order = 20,
			type = "execute",
			name = L["Friendly Player Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		enemyPlayerShortcut = {
			order = 21,
			type = "execute",
			name = L["Enemy Player Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		friendlyNPCShortcut = {
			order = 22,
			type = "execute",
			name = L["Friendly NPC Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		spacer6 = {
			order = 23,
			type = "description",
			name = " ",
		},
		enemyNPCShortcut = {
			order = 24,
			type = "execute",
			name = L["Enemy NPC Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
			disabled = function() return not E.NamePlates; end,
		},
		filtersShortcut = {
			order = 25,
			type = "execute",
			name = L["Style Filter"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "filters") end,
			disabled = function() return not E.NamePlates; end,
		},
		generalGroup = {
			order = 26,
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
						hideBlizzardPlates = {
							order = 3,
							type = "toggle",
							name = L["Hide Blizzard Plates"],
							desc = L["If enabled then you will no longer see nameplates that use the default Blizzard appearance."],
							set = function(info, value)
								E.db.nameplates.hideBlizzardPlates = value;
								E:StaticPopup_Show("CONFIG_RL")
							end,
						},
						showNPCTitles = {
							order = 4,
							type = "toggle",
							name = L["Show NPC Titles"],
							desc = L["Display NPC Titles whenever healthbars arent displayed and names are."]
						},
						clampToScreen = {
							order = 5,
							type = "toggle",
							name = L["Clamp Nameplates"],
							desc = L["Clamp nameplates to the top of the screen when outside of view."],
						},
						lowHealthThreshold = {
							order = 6,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, max = 1, step = 0.01,
						},
						showEnemyCombat = {
							order = 7,
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
							order = 8,
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
							order = 9,
							type = "range",
							name = L["Load Distance"],
							desc = L["Only load nameplates for units within this range."],
							min = 10, max = 100, step = 1,
						},
						clickableWidth = {
							order = 10,
							type = "range",
							name = L["Clickable Width"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 50, max = 200, step = 1,
							set = function(info, value) E.db.nameplates.clickableWidth = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						clickableHeight = {
							order = 11,
							type = "range",
							name = L["Clickable Height"],
							desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
							min = 10, max = 75, step = 1,
							set = function(info, value) E.db.nameplates.clickableHeight = value; E:StaticPopup_Show("CONFIG_RL") end,
						},
						resetFilters = {
							order = 12,
							name = L["Reset Aura Filters"],
							type = "execute",
							func = function(info)
								E:StaticPopup_Show("RESET_NP_AF") --reset nameplate aurafilters
							end,
						},
						nameColoredGlow = {
							order = 13,
							type = "toggle",
							name = L["Name Colored Glow"],
							desc = L["Use the Name Color of the unit for the Name Glow."],
						},
						targetedNamePlate = {
							order = 14,
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
									name = L["Target Indicator Color"],
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
									name = L["Target/Low Health Indicator"],
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
							order = 15,
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
						name = {
							type = "group",
							order = 3,
							name = L["Default Font"],
							guiInline = true,
							args = {
								font = {
									type = "select", dialogControl = 'LSM30_Font',
									order = 1,
									name = L["Font"],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
								fontSize = {
									order = 2,
									name = FONT_SIZE,
									type = "range",
									min = 4, max = 60, step = 1,
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
								fontOutline = {
									order = 3,
									name = L["Font Outline"],
									desc = L["Set the font outline."],
									type = "select",
									values = {
										['NONE'] = NONE,
										['OUTLINE'] = 'OUTLINE',
										['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
										['THICKOUTLINE'] = 'THICKOUTLINE',
									},
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
							},
						},
						health = {
							type = "group",
							order = 4,
							name = L["Health"],
							guiInline = true,
							args = {
								healthFont = {
									type = "select", dialogControl = 'LSM30_Font',
									order = 1,
									name = L["Font"],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
								healthFontSize = {
									order = 2,
									name = FONT_SIZE,
									type = "range",
									min = 4, max = 36, step = 1, -- max 20 cause otherwise it looks weird
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
								healthFontOutline = {
									order = 3,
									name = L["Font Outline"],
									desc = L["Set the font outline."],
									type = "select",
									values = {
										['NONE'] = NONE,
										['OUTLINE'] = 'OUTLINE',
										['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
										['THICKOUTLINE'] = 'THICKOUTLINE',
									},
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
							}
						},
						stacks = {
							type = "group",
							order = 5,
							name = L["Stack Counter"],
							guiInline = true,
							args = {
								stackFont = {
									type = "select", dialogControl = 'LSM30_Font',
									order = 12,
									name = L["Font"],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
								stackFontSize = {
									order = 13,
									name = FONT_SIZE,
									type = "range",
									min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
								stackFontOutline = {
									order = 14,
									name = L["Font Outline"],
									desc = L["Set the font outline."],
									type = "select",
									values = {
										['NONE'] = NONE,
										['OUTLINE'] = 'OUTLINE',
										['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
										['THICKOUTLINE'] = 'THICKOUTLINE',
									},
									set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:UpdatePlateFonts() end,
								},
							}
						},
						duration = {
							type = "group",
							order = 6,
							name = L["Duration"],
							guiInline = true,
							args = {
								cooldownShortcut = {
									order = 1,
									type = "execute",
									name = L["Cooldowns"],
									buttonElvUI = true,
									func = function() ACD:SelectGroup("ElvUI", "cooldown", "nameplates") end,
								},
								durationPosition = {
									order = 2,
									name = L["Position"],
									type = "select",
									values = {
										["CENTER"] = L["Center"],
										["TOPLEFT"] = "TOPLEFT",
										["BOTTOMLEFT"] = "BOTTOMLEFT",
										["TOPRIGHT"] = "TOPRIGHT",
									},
								},
							}
						},
					},
				},
				classBarGroup = {
					order = 130,
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
						goodScale = {
							name = L["Good Scale"],
							order = 2,
							type = 'range',
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
						},
						badScale = {
							name = L["Bad Scale"],
							order = 3,
							type = 'range',
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
						},
						beingTankedByTank = {
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							order = 4,
							type = "toggle",
							get = function(info) return E.db.nameplates.threat[ info[#info] ] end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						beingTankedByTankColor = {
							name = L["Tanked Color"],
							order = 5,
							type = 'color',
							hasAlpha = false,
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end,
						},
						spacer1 = {
							order = 6,
							type = 'description',
							name = '',
						},
						goodColor = {
							type = "color",
							order = 7,
							name = L["Good Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						badColor = {
							name = L["Bad Color"],
							order = 8,
							type = 'color',
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						spacer2 = {
							order = 9,
							type = 'description',
							name = '',
						},
						goodTransition = {
							type = "color",
							order = 10,
							name = L["Good Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						badTransition = {
							name = L["Bad Transition Color"],
							order = 11,
							type = 'color',
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
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
							order = 0,
							name = L["Offline"],
							hasAlpha = false,
						},]]
						bad = {
							name = L["Enemy"],
							order = 1,
							type = 'color',
							hasAlpha = false,
						},
						neutral = {
							name = L["Neutral"],
							order = 2,
							type = 'color',
							hasAlpha = false,
						},
						spacer1 = {
							order = 3,
							type = 'description',
							name = '',
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
				healPrediction = {
					order = 225,
					name = L["Heal Prediction"],
					type = 'group',
					get = function(info)
						local t = E.db.nameplates.healPrediction[ info[#info] ]
						local d = P.nameplates.healPrediction[ info[#info] ]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local t = E.db.nameplates.healPrediction[ info[#info] ]
						t.r, t.g, t.b, t.a = r, g, b, a
						NP:ForEachPlate("ConfigureElement_HealthBar", true)
						if NP.PlayerFrame__ and NP.PlayerFrame__.unitFrame and NP.PlayerFrame__.unitFrame.UnitType then
							NP:ConfigureElement_HealthBar(NP.PlayerFrame__.unitFrame, true)
						end
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
						spacer1 = {
							order = 3,
							type = 'description',
							name = '',
						},
						absorbs = {
							order = 4,
							name = L["Absorbs"],
							type = 'color',
							hasAlpha = true,
						},
						healAbsorbs = {
							order = 5,
							name = L["Heal Absorbs"],
							type = 'color',
							hasAlpha = true,
						},
					},
				},
				cutawayHealth = {
					order = 226,
					name = L["Cutaway Health"],
					type = 'group',
					args = {
						enabled = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							get = function(info) return E.db.nameplates.cutawayHealth end,
							set = function(info, value) E.db.nameplates.cutawayHealth = value; end,
						},
						healthLength = {
							type = 'range',
							order = 2,
							name = L["Health Length"],
							desc = L["How much time before the CutawayHealth starts to fade."],
							min = 0.1, max = 1, step = 0.1,
							get = function(info) return E.db.nameplates.cutawayHealthLength end,
							set = function(info, value) E.db.nameplates.cutawayHealthLength = value; end,
						},
						healthFadeOutTime = {
							type = 'range',
							order = 3,
							name = L["Fade Out"],
							desc = L["How long the CutawayHealth will take to fade out."],
							min = 0.1, max = 1, step = 0.1,
							get = function(info) return E.db.nameplates.cutawayHealthFadeOutTime end,
							set = function(info, value) E.db.nameplates.cutawayHealthFadeOutTime = value; end,
						},
					},
				},
				questIcon = {
					order = 226,
					name = L["Quest Icon"],
					type = 'group',
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							get = function(info) return E.db.nameplates.questIcon end,
							set = function(info, value) E.db.nameplates.questIcon = value; NP:ConfigureAll() end,
						},
						questIconSize = {
							type = 'range',
							order = 2,
							name = L["Size"],
							min = 10, max = 50, step = 1,
							get = function(info) return E.db.nameplates.questIconSize end,
							set = function(info, value) E.db.nameplates.questIconSize = value; NP:ConfigureAll() end,
						},
						questIconPosition = {
							type = 'select',
							order = 3,
							name = L["Position"],
							values = {
								["LEFT"] = L["Left"],
								["RIGHT"] = L["Right"],
							},
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
					name = L["Create Filter"],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if match(value, "^[%s%p]-$") then
							return
						end
						if E.global.nameplate.filters[value] then
							E:Print(L["Filter already exists!"])
							return
						end
						local filter = {};
						NP:StyleFilterInitializeFilter(filter);
						E.global.nameplate.filters[value] = filter;
						UpdateFilterGroup();
						NP:ConfigureAll()
					end,
				},
				selectFilter = {
					name = L["Select Filter"],
					type = 'select',
					order = 2,
					sortByValue = true,
					get = function(info) return selectedNameplateFilter end,
					set = function(info, value) selectedNameplateFilter = value; UpdateFilterGroup() end,
					values = function()
						local filters, priority, name = {}
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
				removeFilter = {
					order = 3,
					name = L["Delete Filter"],
					desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
					type = 'execute',
					buttonElvUI = true,
					func = function()
						for profile in pairs(E.data.profiles) do
							if E.data.profiles[profile].nameplates and E.data.profiles[profile].nameplates.filters and E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] then
								E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] = nil;
							end
						end
						E.global.nameplate.filters[selectedNameplateFilter] = nil;
						selectedNameplateFilter = nil;
						UpdateFilterGroup();
						NP:ConfigureAll()
					end,
					disabled = function() return G.nameplate.filters[selectedNameplateFilter] end,
					hidden = function() return selectedNameplateFilter == nil end,
				},
			},
		},
	},
}
