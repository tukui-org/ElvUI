local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local ACD = E.Libs.AceConfigDialog

local _G = _G
local tconcat = table.concat
local pairs, type, strsplit, match, gsub = pairs, type, strsplit, string.match, string.gsub
local next, ipairs, tremove, tinsert, sort, tonumber, format = next, ipairs, tremove, tinsert, sort, tonumber, format

local GetClassInfo = GetClassInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetNumClasses = GetNumClasses
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local C_SpecializationInfo_GetPvpTalentSlotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo

local raidTargetIcon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t %s"
local selectedNameplateFilter

local positionValues = {
	TOPLEFT = 'TOPLEFT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
}

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
	local coloredName = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[classTag]) or _G.RAID_CLASS_COLORS[classTag]
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
			sort(classIndexTable)
		end
		classOrder = 0
		local coloredName;
		for _, classTag in ipairs(classIndexTable) do
			classOrder = classOrder+1
			coloredName = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[classTag]) or _G.RAID_CLASS_COLORS[classTag]
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

local function GetPvpTalentString(talentID)
	local _, name, texture = GetPvpTalentInfoByID(talentID);
	return formatStr:format(texture, name);
end

local function GenerateValues(tier, isPvP)
	local values = {};

	if isPvP then
		local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(tier)
		if slotInfo.availableTalentIDs then
			for i = 1, #slotInfo.availableTalentIDs do
				local talentID = slotInfo.availableTalentIDs[i]
				values[talentID] = GetPvpTalentString(talentID)
			end
		end
	else
		for i = 1, 3 do
			values[i] = GetTalentString(tier, i);
		end
	end

	return values;
end

local function UpdateTalentSection()
	if E.global.nameplate.filters[selectedNameplateFilter] then
		local maxTiers = (E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == "normal" and 7) or 4;
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
				name = format(L.GARRISON_CURRENT_LEVEL, i),
				get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i..'enabled'] end,
				set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i..'enabled'] = value; UpdateTalentSection(); NP:ConfigureAll() end
			}
			order = order+1;
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
							name = L.TALENT,
							style = 'dropdown',
							desc = L["Talent to match"],
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i].column end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier'..i].column = value; NP:ConfigureAll() end,
							values = function() return GenerateValues(i, E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == "pvp") end,
						},
					}
				}
				order = order+1;
			end
			E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers.args["spacer"..i] = {
				order = order,
				type = 'description',
				name = '',
			}
			order = order+1
		end
	end
end

local function UpdateInstanceDifficulty()
	if (E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party) then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.dungeonDifficulty = {
			type = 'group',
			name = L.DUNGEON_DIFFICULTY,
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
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.dungeonDifficulty = nil;
	end

	if (E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid) then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.raidDifficulty = {
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
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.raidDifficulty = nil;
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
						["DISABLED"] = _G.DISABLE,
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
						NP:StyleFilterCopyDefaults(filter);
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
						},
						negativeMatch = {
							order = 3,
							name = L["Negative Match"],
							desc = L["Match if Name or NPC ID is NOT in the list."],
							type = 'toggle',
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
						},
					},
				},
				targeting = {
					name = L["Targeting"],
					order = 7,
					type = "group",
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								isTarget = {
									name = L["Is Targeted"],
									desc = L["If enabled then the filter will only activate when you are targeting the unit."],
									order = 1,
									type = 'toggle',
								},
								notTarget = {
									name = L["Not Targeted"],
									desc = L["If enabled then the filter will only activate when you are not targeting the unit."],
									order = 2,
									type = 'toggle',
								},
								requireTarget = {
									name = L["Require Target"],
									desc = L["If enabled then the filter will only activate when you have a target."],
									order = 2,
									type = 'toggle',
								},
								targetMe = {
									name = L["Is Targeting Player"],
									desc = L["If enabled then the filter will only activate when the unit is targeting you."],
									order = 4,
									type = 'toggle',
								},
								notTargetMe = {
									name = L["Not Targeting Player"],
									desc = L["If enabled then the filter will only activate when the unit is not targeting you."],
									order = 5,
									type = 'toggle',
								},
								isFocus = {
									name = L["Is Focused"],
									desc = L["If enabled then the filter will only activate when you are focusing the unit."],
									order = 7,
									type = 'toggle',
								},
								notFocus = {
									name = L["Not Focused"],
									desc = L["If enabled then the filter will only activate when you are not focusing the unit."],
									order = 8,
									type = 'toggle',
								},
							}
						}
					}
				},
				casting = {
					order = 8,
					type = 'group',
					name = L["Casting"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.casting[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.casting[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								isCasting = {
									type = 'toggle',
									order = 1,
									name = L["Is Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is casting anything."]
								},
								notCasting = {
									type = 'toggle',
									order = 2,
									name = L["Not Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is not casting anything."]
								},
								isChanneling = {
									type = 'toggle',
									order = 3,
									customWidth = 200,
									name = L["Is Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is channeling anything."]
								},
								notChanneling = {
									type = 'toggle',
									order = 4,
									customWidth = 200,
									name = L["Not Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is not channeling anything."]
								},
								spacer1 = {
									order = 5,
									type = 'description',
									name = '',
									width = 'full'
								},
								interruptible = {
									type = 'toggle',
									order = 6,
									name = L["Interruptible"],
									desc = L["If enabled then the filter will only activate if the unit is casting interruptible spells."],
								},
								notInterruptible = {
									type = 'toggle',
									order = 7,
									name = L["Non-Interruptable"],
									desc = L["If enabled then the filter will only activate if the unit is casting not interruptible spells."],
								},
							}
						},
						addSpell = {
							order = 9,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[value] = true;
								UpdateFilterGroup();
								NP:ConfigureAll()
							end,
						},
						removeSpell = {
							order = 10,
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
						description1 = {
							order = 12,
							type = "description",
							name = L["You do not need to use 'Is Casting Anything' or 'Is Channeling Anything' for these spells to trigger."],
						},
						description2 = {
							order = 13,
							type = "description",
							name = L["If this list is empty, and if 'Interruptible' is checked, then the filter will activate on any type of cast that can be interrupted."],
						},
						notSpell = {
							type = 'toggle',
							order = -2,
							name = L["Not Spell"],
							desc = L["If enabled then the filter will only activate if the unit is not casting or channeling one of the selected spells."]
						},
					}
				},
				combat = {
					order = 9,
					type = 'group',
					name = L["Unit Conditions"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								inCombat = {
									name = L["Player in Combat"],
									desc = L["If enabled then the filter will only activate when you are in combat."],
									type = 'toggle',
									order = 1,
								},
								outOfCombat = {
									name = L["Player Out of Combat"],
									desc = L["If enabled then the filter will only activate when you are out of combat."],
									type = 'toggle',
									order = 2,
								},
								inCombatUnit = {
									name = L["Unit in Combat"],
									desc = L["If enabled then the filter will only activate when the unit is in combat."],
									type = 'toggle',
									order = 3,
								},
								outOfCombatUnit = {
									name = L["Unit Out of Combat"],
									desc = L["If enabled then the filter will only activate when the unit is out of combat."],
									type = 'toggle',
									order = 4,
								},
								spacer1 = {
									type = 'description',
									name = " ",
									width = 'full',
									order = 5,
								},
								inVehicle = {
									name = L["Player in Vehicle"],
									desc = L["If enabled then the filter will only activate when you are in a Vehicle."],
									order = 6,
									type = 'toggle',
								},
								outOfVehicle = {
									name = L["Player Out of Vehicle"],
									desc = L["If enabled then the filter will only activate when you are not in a Vehicle."],
									order = 7,
									type = 'toggle',
								},
								inVehicleUnit = {
									name = L["Unit in Vehicle"],
									desc = L["If enabled then the filter will only activate when the unit is in a Vehicle."],
									order = 8,
									type = 'toggle',
								},
								outOfVehicleUnit = {
									name = L["Unit Out of Vehicle"],
									desc = L["If enabled then the filter will only activate when the unit is not in a Vehicle."],
									order = 9,
									type = 'toggle',
								},
								spacer2 = {
									type = 'description',
									name = " ",
									width = 'full',
									order = 10,
								},
								isResting = {
									type = 'toggle',
									name = L["Player is Resting"],
									desc = L["If enabled then the filter will only activate when you are resting at an Inn."],
									order = 11,
								},
								isPet = {
									type = 'toggle',
									name = L["Unit is Pet"],
									desc = L["If enabled then the filter will only activate when the unit is a player's pet"],
									order = 12,
								},
							}
						}
					},
				},
				class = {
					order = 10,
					type = 'group',
					name = L.CLASS,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {}
				},
				talent = {
					order = 11,
					type = 'group',
					name = L.TALENT,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {}
				},
				role = {
					order = 12,
					type = 'group',
					name = L.ROLE,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.role[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.role[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								tank = {
									type = 'toggle',
									order = 1,
									name = L.TANK,
								},
								healer = {
									type = 'toggle',
									order = 2,
									name = L.HEALER,
								},
								damager = {
									type = 'toggle',
									order = 3,
									name = L.DAMAGER,
								},
							}
						}
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
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								worldboss = {
									type = 'toggle',
									order = 1,
									name = L.RAID_INFO_WORLD_BOSS,
								},
								rareelite = {
									type = 'toggle',
									order = 2,
									name = L["Rare Elite"],
								},
								normal = {
									type = 'toggle',
									order = 3,
									name = L.PLAYER_DIFFICULTY1,
								},
								rare = {
									type = 'toggle',
									order = 4,
									name = L.ITEM_QUALITY3_DESC,
								},
								trivial = {
									type = 'toggle',
									order = 5,
									name = L["Trivial"],
								},
								elite = {
									type = 'toggle',
									order = 6,
									name = L.ELITE,
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
						}
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
				keyMod = {
					name = L["Key Modifiers"],
					order = 16,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod and E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod.enable = value
								NP:ConfigureAll()
							end,
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 1,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod[info[#info]] end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod[info[#info]] = value; NP:ConfigureAll() end,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod.enable end,
							args = {
								Shift = {
									name = L["SHIFT_KEY_TEXT"],
									order = 1,
									type = 'toggle',
								},
								Alt = {
									name = L["ALT_KEY_TEXT"],
									order = 2,
									type = 'toggle',
								},
								Control = {
									name = L["CTRL_KEY_TEXT"],
									order = 3,
									type = 'toggle',
								},
								Modifier = {
									name = L["Any"],
									order = 4,
									type = 'toggle',
								},
								spacer1 = {
									order = 5,
									type = 'description',
									name = " ",
								},
								LeftShift = {
									name = L["Left Shift"],
									order = 6,
									type = 'toggle',
								},
								LeftAlt = {
									name = L["Left Alt"],
									order = 7,
									type = 'toggle',
								},
								LeftControl = {
									name = L["Left Control"],
									order = 8,
									type = 'toggle',
								},
								spacer2 = {
									order = 9,
									type = 'description',
									name = " ",
								},
								RightShift = {
									name = L["Right Shift"],
									order = 10,
									type = 'toggle',
								},
								RightAlt = {
									name = L["Right Alt"],
									order = 11,
									type = 'toggle',
								},
								RightControl = {
									name = L["Right Control"],
									order = 12,
									type = 'toggle',
								},
							},
						},
					},
				},
				levels = {
					order = 17,
					type = 'group',
					name = L.LEVEL,
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
							min = -1, max = _G.MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel or 0 end,
						},
						maxlevel = {
							order = 5,
							type = 'range',
							name = L["Maximum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."],
							min = -1, max = _G.MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel or 0 end,
						},
						curlevel = {
							name = L["Current Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches this value."],
							order = 6,
							type = "range",
							min = -1, max = _G.MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel or 0 end,
						},
					},
				},
				cooldowns = {
					name = L["Cooldowns"],
					order = 18,
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
								if match(value, "^[%s%p]-$") then return end

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
					order = 19,
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
								if match(value, "^[%s%p]-$") then return end

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
					order = 20,
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
								if match(value, "^[%s%p]-$") then return end

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
				threat = {
					name = L["Threat"],
					order = 21,
					type = "group",
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.threat and E.global.nameplate.filters[selectedNameplateFilter].triggers.threat.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.threat.enable = value
								NP:ConfigureAll()
							end,
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 1,
							get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.threat[info[#info]] end,
							set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.threat[info[#info]] = value; NP:ConfigureAll() end,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.threat.enable end,
							args = {
								good = {
									name = L["Good"],
									order = 1,
									type = 'toggle',
								},
								goodTransition = {
									name = L["Good Transition"],
									order = 2,
									type = 'toggle',
								},
								badTransition = {
									name = L["Bad Transition"],
									order = 3,
									type = 'toggle',
								},
								bad = {
									name = L["Bad"],
									order = 4,
									type = 'toggle',
								},
								spacer1 = {
									order = 5,
									type = "description",
									name = " ",
									width = 'full'
								},
								offTank = {
									name = L["Off Tank"],
									order = 6,
									type = 'toggle',
								},
								offTankGoodTransition = {
									name = L["Off Tank Good Transtion"],
									customWidth = 200,
									order = 7,
									type = 'toggle',
								},
								offTankBadTransition = {
									name = L["Off Tank Bad Transtion"],
									customWidth = 200,
									order = 8,
									type = 'toggle',
								},
							},
						},
					},
				},
				nameplateType = {
					name = L["Unit Type"],
					order = 22,
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
								enemyPlayer = {
									name = L["ENEMY_PLAYER"],
									order = 3,
									type = 'toggle',
								},
								enemyNPC = {
									name = L["ENEMY_NPC"],
									order = 4,
									type = 'toggle',
								},
								player = {
									name = L["Player"],
									order = 5,
									type = 'toggle',
								},
							},
						},
					},
				},
				reactionType = {
					name = L["Reaction Type"],
					order = 23,
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
							name = L.REPUTATION,
							desc = L["If this is enabled then the reaction check will use your reputation with the faction the unit belongs to."],
							order = 1,
							type = 'toggle',
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable end,
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable end,
							args = {
								hated = {
									name = L.FACTION_STANDING_LABEL1,
									order = 1,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								hostile = {
									name = L.FACTION_STANDING_LABEL2,
									order = 2,
									type = 'toggle',
								},
								unfriendly = {
									name = L.FACTION_STANDING_LABEL3,
									order = 3,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								neutral = {
									name = L.FACTION_STANDING_LABEL4,
									order = 4,
									type = 'toggle',
								},
								friendly = {
									name = L.FACTION_STANDING_LABEL5,
									order = 5,
									type = 'toggle',
								},
								honored = {
									name = L.FACTION_STANDING_LABEL6,
									order = 6,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								revered = {
									name = L.FACTION_STANDING_LABEL7,
									order = 7,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
								exalted = {
									name = L.FACTION_STANDING_LABEL8,
									order = 8,
									type = 'toggle',
									disabled = function() return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation) end,
								},
							},
						},
					},
				},
				creatureType = {
					name = L["Creature Type"],
					order = 24,
					type = 'group',
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							width = 'full'
						},
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType.enable end,
							args = {}
						}
					}
				},
				instanceType = {
					order = 25,
					type = 'group',
					name = L["Instance Type"],
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								none = {
									type = 'toggle',
									order = 1,
									name = L.NONE,
								},
								scenario = {
									type = 'toggle',
									order = 2,
									name = L.SCENARIOS,
								},
								party = {
									type = 'toggle',
									order = 3,
									name = L.DUNGEONS,
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
									name = L.RAID,
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
									name = L.ARENA,
								},
								pvp = {
									type = 'toggle',
									order = 8,
									name = L.BATTLEFIELDS,
								},
							}
						}
					}
				},
				raidTarget = {
					order = 26,
					type = 'group',
					name = L.BINDING_HEADER_RAID_TARGET,
					get = function(info) return E.global.nameplate.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]] end,
					set = function(info, value) E.global.nameplate.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]] = value; NP:ConfigureAll() end,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								star = {
									type = 'toggle',
									order = 1,
									name = format(raidTargetIcon, 1, L.RAID_TARGET_1),
								},
								circle = {
									type = 'toggle',
									order = 2,
									name = format(raidTargetIcon, 2, L.RAID_TARGET_2),
								},
								diamond = {
									type = 'toggle',
									order = 3,
									name = format(raidTargetIcon, 3, L.RAID_TARGET_3),
								},
								triangle = {
									type = 'toggle',
									order = 4,
									name = format(raidTargetIcon, 4, L.RAID_TARGET_4),
								},
								moon = {
									type = 'toggle',
									order = 5,
									name = format(raidTargetIcon, 5, L.RAID_TARGET_5),
								},
								square = {
									type = 'toggle',
									order = 6,
									name = format(raidTargetIcon, 6, L.RAID_TARGET_6),
								},
								cross = {
									type = 'toggle',
									order = 7,
									name = format(raidTargetIcon, 7, L.RAID_TARGET_7),
								},
								skull = {
									type = 'toggle',
									order = 8,
									name = format(raidTargetIcon, 8, L.RAID_TARGET_8),
								},
							}
						}
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
					min = 0.5, max = 1.5, softMin = .75, softMax = 1.25, step = 0.01,
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
				color = {
					order = 10,
					type = "group",
					name = L.COLOR,
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
							values = _G.AceGUIWidgetLSMlists.statusbar,
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
							name = L.SPEED,
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
							name = L.COLOR,
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

		do -- build creatureType options
			local creatureTypeOrder = {
				Aberration = 2,
				Beast = 3,
				Critter = 4,
				Demon = 5,
				Dragonkin = 6,
				Elemental = 7,
				['Gas Cloud'] = 8,
				Giant = 9,
				Humanoid = 10,
				Mechanical = 11,
				['Not specified'] = 12,
				Totem = 13,
				Undead = 14,
				['Wild Pet'] = 15,
				['Non-combat Pet'] = 16
			}

			for k, v in pairs(E.CreatureTypes) do
				E.Options.args.nameplate.args.filters.args.triggers.args.creatureType.args.types.args[v] = {
					type = 'toggle',
					order = creatureTypeOrder[v],
					name = k,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType.enable end,
				}
			end
		end

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
		get = function(info) return E.db.nameplates.units[unit][info[#info]] end,
		set = function(info, value) E.db.nameplates.units[unit][info[#info]] = value; NP:ConfigureAll() end,
		disabled = function() return not E.NamePlates.Initialized end,
		args = {
			enable = {
				order = -10,
				name = L["Enable"],
				type = "toggle",
			},
			showTestFrame = {
				order = -9,
				name = L["Show/Hide Test Frame"],
				type = "execute",
				func = function(info)
					if not _G.ElvNP_Test:IsEnabled() or _G.ElvNP_Test.frameType ~= unit then
						_G.ElvNP_Test:Enable()
						_G.ElvNP_Test.frameType = unit
						NP:UpdatePlate(_G.ElvNP_Test)
						NP:ConfigureAll()
					else
						NP:DisablePlate(_G.ElvNP_Test)
						_G.ElvNP_Test:Disable()
					end
				end,
			},
			defaultSettings = {
				order = -8,
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				type = "execute",
				func = function(info)
					NP:ResetSettings(unit)
					NP:ConfigureAll()
				end,
			},
			copySettings = {
				order = -7,
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
			general = {
				order = 1,
				type = "group",
				name = L["General"],
				get = function(info) return E.db.nameplates.units[unit][info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit][info[#info]] = value; NP:SetCVars() NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["General"],
					},
				},
			},
			healthGroup = {
				order = 2,
				name = L["Health"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].health[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].health[info[#info]] = value; NP:ConfigureAll() end,
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
						order = 3,
						name = L["Height"],
						type = "range",
						sliderElvUI = true,
						min = 4,
						max = function() return (E.db.nameplates.clickableHeight or 20) end,
						step = 1,
					},
					healPrediction = {
						order = 5,
						name = L["Heal Prediction"],
						type = "toggle",
					},
					textGroup = {
						order = 200,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].health.text[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].health.text[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							enable = {
								order = 1,
								name = L["Enable"],
								type = "toggle",
							},
							format = {
								order = 2,
								name = L["Text Format"],
								desc = L["TEXT_FORMAT_DESC"],
								type = "input",
							},
							position = {
								order = 3,
								type = "select",
								name = L["Position"],
								values = {
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["TOPRIGHT"] = "TOPRIGHT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",

								},
							},
							parent = {
								order = 4,
								type = "select",
								name = L["Parent"],
								values = {
									["Nameplate"] = L["Nameplate"],
									["Health"] = L["Health"],
								},
							},
							xOffset = {
								order = 5,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1,
							},
							yOffset = {
								order = 6,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1,
							},
							fontGroup = {
								type = "group",
								order = 7,
								name = "",
								guiInline = true,
								get = function(info) return E.db.nameplates.units[unit].health.text[info[#info]] end,
								set = function(info, value) E.db.nameplates.units[unit].health.text[info[#info]] = value; NP:ConfigureAll() end,
								args = {
									font = {
										type = "select", dialogControl = 'LSM30_Font',
										order = 1,
										name = L["Font"],
										values = _G.AceGUIWidgetLSMlists.font,
									},
									fontSize = {
										order = 2,
										name = L.FONT_SIZE,
										type = "range",
										min = 4, max = 60, step = 1,
									},
									fontOutline = {
										order = 3,
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										type = "select",
										values = C.Values.FontFlags,
									},
								},
							},
						},
					},
				},
			},
			powerGroup = {
				order = 3,
				name = L["Power"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].power[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].power[info[#info]] = value; NP:ConfigureAll() end,
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
					width = {
						order = 3,
						name = L["Width"],
						type = "range",
						sliderElvUI = true,
						min = 50,
						max = function() return (E.db.nameplates.clickableWidth or 250) end,
						step = 1,
					},
					height = {
						order = 4,
						name = L["Height"],
						type = "range",
						sliderElvUI = true,
						min = 4,
						max = function() return (E.db.nameplates.clickableHeight or 20) end,
						step = 1,
					},
					xOffset = {
						order = 5,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 6,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					displayAltPower = {
						order = 7,
						name = L["Swap to Alt Power"],
						type = "toggle",
					},
					useAtlas = {
						order = 8,
						name = L["Use Atlas Textures"],
						desc = L["Use Atlas Textures if there is one available."],
						type = "toggle",
					},
					classColor = {
						type = 'toggle',
						order = 9,
						name = L["Use Class Color"],
					},
					textGroup = {
						order = 200,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].power.text[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].power.text[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							enable = {
								order = 1,
								name = L["Enable"],
								type = "toggle",
							},
							format = {
								order = 2,
								name = L["Text Format"],
								desc = L["TEXT_FORMAT_DESC"],
								type = "input",
							},
							position = {
								order = 3,
								type = "select",
								name = L["Position"],
								values = {
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["TOPRIGHT"] = "TOPRIGHT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
								},
							},
							parent = {
								order = 4,
								type = "select",
								name = L["Parent"],
								values = {
									["Nameplate"] = L["Nameplate"],
									["Power"] = L["Power"],
								},
							},
							xOffset = {
								order = 5,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1,
							},
							yOffset = {
								order = 6,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1,
							},
							fontGroup = {
								type = "group",
								order = 7,
								name = "",
								guiInline = true,
								get = function(info) return E.db.nameplates.units[unit].power.text[info[#info]] end,
								set = function(info, value) E.db.nameplates.units[unit].power.text[info[#info]] = value; NP:ConfigureAll() end,
								args = {
									font = {
										type = "select", dialogControl = 'LSM30_Font',
										order = 1,
										name = L["Font"],
										values = _G.AceGUIWidgetLSMlists.font,
									},
									fontSize = {
										order = 2,
										name = L.FONT_SIZE,
										type = "range",
										min = 4, max = 60, step = 1,
									},
									fontOutline = {
										order = 3,
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										type = "select",
										values = C.Values.FontFlags,
									},
								},
							},
						},
					},
				},
			},
			castGroup = {
				order = 4,
				name = L["Cast Bar"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value; NP:ConfigureAll() end,
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
					sourceInterrupt = {
						order = 2,
						type = 'toggle',
						name = L["Display Interrupt Source"],
						desc = L["Display the unit name who interrupted a spell on the castbar. You should increase the 'Time to Hold' to show properly."],
					},
					sourceInterruptClassColor = {
						order = 3,
						type = 'toggle',
						name = L["Show Interrupt Source in Class Color"],
						disabled = function() return not E.db.nameplates.units[unit].castbar.sourceInterrupt end,
					},
					-- order 4 is player Display Target
					timeToHold = {
						order = 5,
						type = "range",
						name = L["Time To Hold"],
						desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
						min = 0, max = 4, step = 0.1,
					},
					width = {
						order = 7,
						name = L["Width"],
						type = "range",
						sliderElvUI = true,
						min = 50,
						max = function() return (E.db.nameplates.clickableWidth or 250) end,
						step = 1,
					},
					height = {
						order = 8,
						name = L["Height"],
						type = "range",
						sliderElvUI = true,
						min = 4,
						max = function() return (E.db.nameplates.clickableHeight or 20) end,
						step = 1,
					},
					xOffset = {
						order = 9,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 10,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					textGroup = {
						order = 20,
						name = L["Text"],
						type = "group",
						get = function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value; NP:ConfigureAll() end,
						guiInline = true,
						args = {
							hideSpellName = {
								order = 1,
								name = L["Hide Spell Name"],
								type = "toggle",
							},
							hideTime = {
								order = 2,
								name = L["Hide Time"],
								type = "toggle",
							},
							textPosition = {
								order = 3,
								name = L["Text Position"],
								type = "select",
								values = {
									["ONBAR"] = L["Cast Bar"],
									["ABOVE"] = L["Above"],
									["BELOW"] = L["Below"]
								},
							},
							castTimeFormat = {
								order = 4,
								type = "select",
								name = L["Cast Time Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENTMAX"] = L["Current / Max"],
									["REMAINING"] = L["Remaining"],
									['REMAININGMAX'] = L["Remaining / Max"],
								},
							},
							channelTimeFormat = {
								order = 5,
								type = "select",
								name = L["Channel Time Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENT_MAX"] = L["Current / Max"],
									["REMAINING"] = L["Remaining"],
									['REMAININGMAX'] = L["Remaining / Max"],
								},
							},
						},
					},
					iconGroup = {
						order = 25,
						name = L["Icon"],
						type = "group",
						get = function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value; NP:ConfigureAll() end,
						guiInline = true,
						args = {
							showIcon = {
								order = 11,
								type = "toggle",
								name = L["Show Icon"],
							},
							iconPosition = {
								order = 12,
								type = "select",
								name = L["Icon Position"],
								values = {
									["LEFT"] = L["Left"],
									["RIGHT"] = L["Right"],
								},
							},
							iconSize = {
								order = 13,
								name = L["Icon Size"],
								type = "range",
								min = 4, max = 40, step = 1,
							},
							iconOffsetX = {
								order = 14,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1,
							},
							iconOffsetY = {
								order = 15,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1,
							},
						},
					},
					fontGroup = {
						type = "group",
						order = 30,
						name = L["Font"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							font = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 1,
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
							},
							fontSize = {
								order = 2,
								name = L.FONT_SIZE,
								type = "range",
								min = 4, max = 60, step = 1,
							},
							fontOutline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = C.Values.FontFlags,
							},
						},
					},
				},
			},
			buffsGroup = {
				order = 5,
				name = L["Buffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].buffs[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].buffs[info[#info]] = value; NP:ConfigureAll() end,
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
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						--desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
					},
					size = {
						order = 3,
						name = L["Icon Size"],
						type = "range",
						min = 6, max = 60, step = 1,
					},
					--width = {
					--	order = 3,
					--	name = L["Icon Width"],
					--	type = "range",
					--	min = 6, max = 60, step = 1,
					--	get = function(info) return E.db.nameplates.units[unit].buffs[info[#info]] end,
					--	set = function(info, value) E.db.nameplates.units[unit].buffs[info[#info]] = value; NP:ConfigureAll() end,
					--},
					--height = {
					--	order = 4,
					--	name = L["Icon Height"],
					--	type = "range",
					--	min = 6, max = 60, step = 1,
					--	get = function(info) return E.db.nameplates.units[unit].buffs[info[#info]] end,
					--	set = function(info, value) E.db.nameplates.units[unit].buffs[info[#info]] = value; NP:ConfigureAll() end,
					--},
					spacing = {
						order = 5,
						name = L["Spacing"],
						type = "range",
						min = 0, max = 60, step = 1,
					},
					xOffset = {
						order = 6,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 7,
						type = 'range',
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1,
					},
					anchorPoint = {
						type = 'select',
						order = 8,
						name = L["Anchor Point"],
						desc = L["What point to anchor to the frame you set to attach to."],
						values = positionValues,
					},
					growthX = {
						type = 'select',
						order = 9,
						name = L["Growth X-Direction"],
						values = {
							['LEFT'] = L["Left"],
							['RIGHT'] = L["Right"],
						},
					},
					growthY = {
						type = 'select',
						order = 10,
						name = L["Growth Y-Direction"],
						values = {
							['UP'] = L["Up"],
							['DOWN'] = L["Down"],
						},
					},
					stacks = {
						type = "group",
						order = 11,
						name = L["Stack Counter"],
						guiInline = true,
						get = function(info, value) return E.db.nameplates.units[unit].buffs[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							countFont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 12,
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
							},
							countFontSize = {
								order = 13,
								name = L.FONT_SIZE,
								type = "range",
								min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
							},
							countFontOutline = {
								order = 14,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = C.Values.FontFlags,
							},
							countPosition = {
								order = 2,
								name = L["Position"],
								type = "select",
								values = {
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT",								},
							},
						}
					},
					duration = {
						type = "group",
						order = 12,
						name = L["Duration"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].buffs[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[info[#info]] = value; NP:ConfigureAll() end,
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
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT",
								},
							},
						}
					},
					filtersGroup = {
						name = L.FILTERS,
						order = 13,
						type = "group",
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].buffs.filters[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs.filters[info[#info]] = value; NP:ConfigureAll() end,
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
								dragOnLeave = E.noop, --keep this here
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
									local filterText = (blockText and format("|cFF999999%s|r %s", _G.BLOCK, blockText)) or localized or text
									return (friend and format("|cFF33FF33%s|r %s", _G.FRIEND, filterText)) or (enemy and format("|cFFFF3333%s|r %s", _G.ENEMY, filterText)) or filterText
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
				order = 6,
				name = L["Debuffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].debuffs[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].debuffs[info[#info]] = value; NP:ConfigureAll() end,
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
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
					},
					size = {
						order = 3,
						name = L["Icon Size"],
						type = "range",
						min = 6, max = 60, step = 1,
					},
					--width = {
					--	order = 3,
					--	name = L["Icon Width"],
					--	type = "range",
					--	min = 6, max = 60, step = 1,
					--	get = function(info) return E.db.nameplates.units[unit].debuffs[info[#info]] end,
					--	set = function(info, value) E.db.nameplates.units[unit].debuffs[info[#info]] = value; NP:ConfigureAll() end,
					--},
					--height = {
					--	order = 4,
					--	name = L["Icon Height"],
					--	type = "range",
					--	min = 6, max = 60, step = 1,
					--	get = function(info) return E.db.nameplates.units[unit].debuffs[info[#info]] end,
					--	set = function(info, value) E.db.nameplates.units[unit].debuffs[info[#info]] = value; NP:ConfigureAll() end,
					--},
					spacing = {
						order = 5,
						name = L["Spacing"],
						type = "range",
						min = 0, max = 60, step = 1,
					},
					xOffset = {
						order = 6,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 7,
						type = 'range',
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1,
					},
					anchorPoint = {
						type = 'select',
						order = 8,
						name = L["Anchor Point"],
						desc = L["What point to anchor to the frame you set to attach to."],
						values = positionValues,
					},
					growthX = {
						type = 'select',
						order = 9,
						name = L["Growth X-Direction"],
						values = {
							['LEFT'] = L["Left"],
							['RIGHT'] = L["Right"],
						},
					},
					growthY = {
						type = 'select',
						order = 10,
						name = L["Growth Y-Direction"],
						values = {
							['UP'] = L["Up"],
							['DOWN'] = L["Down"],
						},
					},
					stacks = {
						type = "group",
						order = 11,
						name = L["Stack Counter"],
						guiInline = true,
						get = function(info, value) return E.db.nameplates.units[unit].debuffs[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							countFont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 12,
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
							},
							countFontSize = {
								order = 13,
								name = L.FONT_SIZE,
								type = "range",
								min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
							},
							countFontOutline = {
								order = 14,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = C.Values.FontFlags,
							},
							countPosition = {
								order = 2,
								name = L["Position"],
								type = "select",
								values = {
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT",
								},
							},
						}
					},
					duration = {
						type = "group",
						order = 12,
						name = L["Duration"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].debuffs[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[info[#info]] = value; NP:ConfigureAll() end,
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
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT",
								},
							},
						}
					},
					filtersGroup = {
						name = L.FILTERS,
						order = 13,
						type = "group",
						get = function(info) return E.db.nameplates.units[unit].debuffs.filters[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs.filters[info[#info]] = value; NP:ConfigureAll() end,
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
								dragOnLeave = E.noop, --keep this here
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
									local filterText = (blockText and format("|cFF999999%s|r %s", _G.BLOCK, blockText)) or localized or text
									return (friend and format("|cFF33FF33%s|r %s", _G.FRIEND, filterText)) or (enemy and format("|cFFFF3333%s|r %s", _G.ENEMY, filterText)) or filterText
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
				order = 7,
				name = L["Portrait"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].portrait[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].portrait[info[#info]] = value; NP:ConfigureAll() end,
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
						min = 12, max = 64, step = 1,
					},
					height = {
						order = 3,
						name = L["Height"],
						type = "range",
						min = 12, max = 64, step = 1,
					},
					position = {
						order = 4,
						type = "select",
						name = L["Icon Position"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"],
							["TOP"] = L["Top"],
							["BOTTOM"] = L["Bottom"],
							["CENTER"] = L["Center"],
						},
					},
					xOffset = {
						order = 5,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 6,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
				},
			},
			levelGroup = {
				order = 8,
				name = L.LEVEL,
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].level[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].level[info[#info]] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L.LEVEL,
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					format = {
						order = 2,
						name = L["Format"],
						type = "input",
					},
					position = {
						order = 3,
						type = "select",
						name = L["Position"],
						values = {
							["CENTER"] = "CENTER",
							["TOPLEFT"] = "TOPLEFT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["TOPRIGHT"] = "TOPRIGHT",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					},
					parent = {
						order = 4,
						type = "select",
						name = L["Parent"],
						values = {
							["Nameplate"] = L["Nameplate"],
							["Health"] = L["Health"],
						},
					},
					xOffset = {
						order = 5,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 6,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					fontGroup = {
						type = "group",
						order = 7,
						name = "",
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].level[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].level[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							font = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 1,
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
							},
							fontSize = {
								order = 2,
								name = L.FONT_SIZE,
								type = "range",
								min = 4, max = 60, step = 1,
							},
							fontOutline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = C.Values.FontFlags,
							},
						},
					},
				},
			},
			nameGroup = {
				order = 9,
				name = L["Name"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].name[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].name[info[#info]] = value; NP:ConfigureAll() end,
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
					},
					format = {
						order = 2,
						name = L["Text Format"],
						desc = L["TEXT_FORMAT_DESC"],
						type = "input",
					},
					position = {
						order = 3,
						type = "select",
						name = L["Position"],
						values = {
							["CENTER"] = "CENTER",
							["TOPLEFT"] = "TOPLEFT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["TOPRIGHT"] = "TOPRIGHT",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					},
					parent = {
						order = 4,
						type = "select",
						name = L["Parent"],
						values = {
							["Nameplate"] = L["Nameplate"],
							["Health"] = L["Health"],
						},
					},
					xOffset = {
						order = 5,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 6,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					fontGroup = {
						type = "group",
						order = 7,
						name = L["Font"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].name[info[#info]] end,
						set = function(info, value) E.db.nameplates.units[unit].name[info[#info]] = value; NP:ConfigureAll() end,
						args = {
							font = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 1,
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
							},
							fontSize = {
								order = 2,
								name = L.FONT_SIZE,
								type = "range",
								min = 4, max = 60, step = 1,
							},
							fontOutline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = C.Values.FontFlags,
							},
						},
					},
				},
			},
			pvpindicator = {
				order = 10,
				name = L["PvP Indicator"],
				desc = L["Horde / Alliance / Honor Info"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].pvpindicator[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].pvpindicator[info[#info]] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["PvP Indicator"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					showBadge = {
						order = 2,
						name = L["Show Badge"],
						desc = L["Show PvP Badge Indicator if available"],
						type = "toggle",
					},
					size = {
						order = 3,
						name = L["Size"],
						type = "range",
						min = 12, max = 64, step = 1,
					},
					position = {
						order = 4,
						type = "select",
						name = L["Icon Position"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"],
							["TOP"] = L["Top"],
							["BOTTOM"] = L["Bottom"],
							["CENTER"] = L["Center"],
						},
					},
					xOffset = {
						order = 5,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 6,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
				},
			},
			raidTargetIndicator = {
				order = 11,
				name = L["Raid Icon"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Raid Icon"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
					},
					size = {
						order = 3,
						name = L["Size"],
						type = "range",
						min = 12, max = 64, step = 1,
					},
					position = {
						order = 4,
						type = "select",
						name = L["Icon Position"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"],
							["TOP"] = L["Top"],
							["BOTTOM"] = L["Bottom"],
							["CENTER"] = L["Center"],
						},
					},
					xOffset = {
						order = 5,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
					yOffset = {
						order = 6,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1,
					},
				},
			}
		},
	}

	-- start groups at 12, options at 100
	if unit == "PLAYER" then
		group.args.general.args.visibility = {
			order = 12,
			type = "group",
			guiInline = true,
			name = L["Visibility"],
			get = function(info) return E.db.nameplates.units[unit].visibility[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].visibility[info[#info]] = value; NP:SetCVars(); NP:ConfigureAll() end,
			args = {
				showAlways = {
					order = 1,
					type = "toggle",
					name = L["Always Show"],
				},
				showInCombat = {
					order = 2,
					type = "toggle",
					name = L["Show In Combat"],
					disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
				},
				showWithTarget = {
					order = 2,
					type = "toggle",
					name = L["Show With Target"],
					desc = L["When using Static Position, this option also requires the target to be attackable."],
					disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
				},
				hideDelay = {
					order = 4,
					type = "range",
					name = L["Hide Delay"],
					min = 0, max = 20, step = 1,
					disabled = function() return E.db.nameplates.units[unit].visibility.showAlways end,
				},
			},
		}
		group.args.classBarGroup = {
			order = 13,
			type = "group",
			name = L["Classbar"],
			get = function(info) return E.db.nameplates.units[unit].classpower[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].classpower[info[#info]] = value; NP:ConfigureAll() end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"]
				},
				width = {
					order = 2,
					name = L["Width"],
					type = "range",
					sliderElvUI = true,
					min = 50,
					max = function() return (E.db.nameplates.clickableWidth or 250) end,
					set = function(info, value) E.db.nameplates.units[unit].classpower[info[#info]] = value; NP:ConfigureAll() end,
					step = 1,
				},
				height = {
					order = 3,
					name = L["Height"],
					type = "range",
					sliderElvUI = true,
					min = 4,
					max = function() return (E.db.nameplates.clickableHeight or 20) end,
					step = 1,
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
				classColor = {
					type = "toggle",
					order = 6,
					name = L["Use Class Color"]
				},
				sortDirection = {
					name = L["Sort Direction"],
					desc = L["Defines the sort order of the selected sort method."],
					type = 'select',
					order = 7,
					values = {
						['asc'] = L["Ascending"],
						['desc'] = L["Descending"],
						['NONE'] = _G.NONE,
					},
					hidden = function() return (E.myclass ~= 'DEATHKNIGHT') end,
				},
			},
		}
		group.args.general.args.useStaticPosition = {
			order = 100,
			type = "toggle",
			name = L["Use Static Position"],
			desc = L["When enabled the nameplate will stay visible in a locked position."],
			disabled = function() return not E.db.nameplates.units[unit].enable end,
		}
		group.args.healthGroup.args.useClassColor = {
			order = 101,
			type = "toggle",
			name = L["Use Class Color"],
		}
		group.args.castGroup.args.displayTarget = {
			order = 4, -- stays at 4
			type = 'toggle',
			name = L["Display Target"],
			desc = L["Display the target of your current cast. Useful for mouseover casts."],
		}
	elseif unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" then
		group.args.general.args.nameOnly = {
			type = 'toggle',
			order = 100,
			name = L["Name Only"],
		}
		group.args.general.args.showTitle = {
			type = 'toggle',
			order = 101,
			name = L["Show Title"],
			desc = L["Title will only appear if Name Only is enabled or triggered in a Style Filter."],
		}
		group.args.general.args.markHealers = {
			type = "toggle",
			order = 102,
			name = L["Healer Icon"],
			desc = L["Display a healer icon over known healers inside battlegrounds or arenas."],
		}
		group.args.general.args.minions = {
			type = "toggle",
			order = 103,
			name = L.UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS,
		}
		group.args.healthGroup.args.useClassColor = {
			order = 104,
			type = "toggle",
			name = L["Use Class Color"],
		}
	elseif unit == "ENEMY_NPC" or unit == "FRIENDLY_NPC" then
		group.args.eliteIcon = {
			order = 12,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[info[#info]] = value; NP:ConfigureAll() end,
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
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
				},
				position = {
					order = 3,
					type = "select",
					name = L["Icon Position"],
					values = {
						["CENTER"] = "CENTER",
						["TOPLEFT"] = "TOPLEFT",
						["BOTTOMLEFT"] = "BOTTOMLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
						["BOTTOMRIGHT"] = "BOTTOMRIGHT",
					},
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
		group.args.questIcon = {
			order = 13,
			name = L["Quest Icon"],
			type = 'group',
			get = function(info) return E.db.nameplates.units[unit].questIcon[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].questIcon[info[#info]] = value; NP:SetCVars() NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Quest Icon"],
				},
				enable = {
					type = 'toggle',
					order = 1,
					name = L["Enable"],
				},
				size = {
					type = 'range',
					order = 2,
					name = L["Size"],
					min = 10, max = 50, step = 1,
				},
				position = {
					order = 3,
					type = "select",
					name = L["Icon Position"],
					values = {
						["CENTER"] = "CENTER",
						["TOPLEFT"] = "TOPLEFT",
						["BOTTOMLEFT"] = "BOTTOMLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
						["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						["LEFT"] = "LEFT",
						["RIGHT"] = "RIGHT",
					},
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
		group.args.general.args.nameOnly = {
			type = 'toggle',
			order = 100,
			name = L["Name Only"],
		}
		group.args.general.args.showTitle = {
			type = 'toggle',
			order = 101,
			name = L["Show Title"],
			desc = L["Title will only appear if Name Only is enabled or triggered in a Style Filter."]
		}
		if unit == "ENEMY_NPC" then
			group.args.general.args.minor = {
				type = 'toggle',
				order = 102,
				name = L.UNIT_NAMEPLATES_SHOW_ENEMY_MINUS,
			}
			group.args.general.args.minions = {
				type = "toggle",
				order = 103,
				name = L.UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS,
			}
		end
	end

	-- start groups at 30
	if unit == "PLAYER" or unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" then
		group.args.pvpclassificationindicator = {
			order = 30,
			name = L["PvP Classification Indicator"],
			desc = L["Cart / Flag / Orb / Assassin Bounty"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].pvpclassificationindicator[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].pvpclassificationindicator[info[#info]] = value; NP:ConfigureAll() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["PvP Classification Indicator"],
				},
				enable = {
					order = 1,
					name = L["Enable"],
					type = "toggle",
				},
				size = {
					order = 2,
					name = L["Size"],
					type = "range",
					min = 5, max = 100, step = 1,
				},
				position = {
					order = 3,
					type = "select",
					name = L["Icon Position"],
					values = {
						["CENTER"] = "CENTER",
						["TOPLEFT"] = "TOPLEFT",
						["BOTTOMLEFT"] = "BOTTOMLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
						["BOTTOMRIGHT"] = "BOTTOMRIGHT",
					},
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
	end

	-- start groups at 50
	if unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" or unit == "FRIENDLY_NPC" or unit == "ENEMY_NPC" then
		group.args.titleGroup = {
			order = 50,
			name = L.UNIT_NAME_PLAYER_TITLE,
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].title[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].title[info[#info]] = value; NP:ConfigureAll() end,
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
				},
				format = {
					order = 2,
					name = L["Text Format"],
					desc = L["TEXT_FORMAT_DESC"],
					type = "input",
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					values = {
						["CENTER"] = "CENTER",
						["TOPLEFT"] = "TOPLEFT",
						["BOTTOMLEFT"] = "BOTTOMLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
						["BOTTOMRIGHT"] = "BOTTOMRIGHT",
					},
				},
				parent = {
					order = 4,
					type = "select",
					name = L["Parent"],
					values = {
						["Nameplate"] = L["Nameplate"],
						["Health"] = L["Health"],
					},
				},
				xOffset = {
					order = 5,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
				yOffset = {
					order = 6,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
				},
				fontGroup = {
					type = "group",
					order = 7,
					name = L["Font"],
					guiInline = true,
					get = function(info) return E.db.nameplates.units[unit].title[info[#info]] end,
					set = function(info, value) E.db.nameplates.units[unit].title[info[#info]] = value; NP:ConfigureAll() end,
					args = {
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 1,
							name = L["Font"],
							values = _G.AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 2,
							name = L.FONT_SIZE,
							type = "range",
							min = 4, max = 60, step = 1,
						},
						fontOutline = {
							order = 3,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = C.Values.FontFlags,
						},
					},
				},
			},
		}
	end

	ORDER = ORDER+2
	return group
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplates[info[#info]] end,
	set = function(info, value) E.db.nameplates[info[#info]] = value; NP:ConfigureAll() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[info[#info]] end,
			set = function(info, value) E.private.nameplates[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end
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
			disabled = function() return not E.NamePlates.Initialized end,
		},
		cooldownShortcut = {
			order = 6,
			type = "execute",
			name = L["Cooldowns"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "cooldown", "nameplates") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		colorsShortcut = {
			order = 7,
			type = "execute",
			name = L.COLORS,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "colorsGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
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
			disabled = function() return not E.NamePlates.Initialized end,
		},
		cutawayHealthShortcut = {
			order = 10,
			type = "execute",
			name = L["Cutaway Health"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "cutawayHealth") end,
			disabled = function() return true end, -- not E.NamePlates;
		},
		filtersShortcut = {
			order = 11,
			type = "execute",
			name = L["Style Filter"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "filters") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " ",
		},
		playerShortcut = {
			order = 13,
			type = "execute",
			name = L["Player"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "playerGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		friendlyPlayerShortcut = {
			order = 14,
			type = "execute",
			name = L["FRIENDLY_PLAYER"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		friendlyNPCShortcut = {
			order = 15,
			type = "execute",
			name = L["FRIENDLY_NPC"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		spacer4 = {
			order = 16,
			type = "description",
			name = " ",
		},
		enemyPlayerShortcut = {
			order = 17,
			type = "execute",
			name = L["ENEMY_PLAYER"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		enemyNPCShortcut = {
			order = 18,
			type = "execute",
			name = L["ENEMY_NPC"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		targetShortcut = {
			order = 19,
			type = "execute",
			name = L.TARGET,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "targetGroup") end,
			disabled = function() return not E.NamePlates.Initialized end,
		},
		generalGroup = {
			order = 25,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates.Initialized end,
			args = {
				resetcvars = {
					order = 1,
					type = "execute",
					name = L["Reset CVars"],
					desc = L["Reset Nameplate CVars to the ElvUI recommended defaults."],
					func = function()
						NP:CVarReset()
					end,
					confirm = true,
				},
				resetFilters = {
					order = 2,
					name = L["Reset Aura Filters"],
					type = "execute",
					func = function()
						E:StaticPopup_Show("RESET_NP_AF") --reset nameplate aurafilters
					end,
				},
				general = {
					order = 10,
					type = "group",
					name = L["General"],
					get = function(info) return E.db.nameplates[info[#info]] end,
					set = function(info, value) E.db.nameplates[info[#info]] = value; NP:SetCVars(); NP:ConfigureAll(); end,
					args = {
						motionType = {
							type = "select",
							order = 1,
							name = L.UNIT_NAMEPLATES_TYPES,
							desc = L["Set to either stack nameplates vertically or allow them to overlap."],
							values = {
								['STACKED'] = L.UNIT_NAMEPLATES_TYPE_2,
								['OVERLAP'] = L.UNIT_NAMEPLATES_TYPE_1,
							},
						},
						showEnemyCombat = {
							order = 3,
							type = "select",
							name = L["Enemy Combat Toggle"],
							desc = L["Control enemy nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L.DISABLE,
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[info[#info]] = value;
								NP:PLAYER_REGEN_ENABLED()
							end,
						},
						showFriendlyCombat = {
							order = 4,
							type = "select",
							name = L["Friendly Combat Toggle"],
							desc = L["Control friendly nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L.DISABLE,
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value) E.db.nameplates[info[#info]] = value; NP:PLAYER_REGEN_ENABLED() end,
						},
						loadDistance = {
							order = 5,
							type = "range",
							name = L["Load Distance"],
							desc = L["Only load nameplates for units within this range."],
							min = 10, max = 100, step = 1,
						},
						statusbar = {
							order = 8,
							type = "select",
							dialogControl = 'LSM30_Statusbar',
							name = L["StatusBar Texture"],
							values = _G.AceGUIWidgetLSMlists.statusbar,
						},
						highlight = {
							order = 9,
							type = "toggle",
							name = L["Highlight on NamePlate"],
						},
						fadeIn = {
							order = 10,
							type = "toggle",
							name = L["Fade-in on Shown"],
						},
						clampToScreen = {
							order = 11,
							type = "toggle",
							name = L["Clamp Nameplates"],
							desc = L["Clamp nameplates to the top of the screen when outside of view."],
						},
						lowHealthThreshold = {
							order = 12,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, softMax = 0.5, max = 0.8, step = 0.01,
						},
						smoothbars = {
							type = 'toggle',
							order = 13,
							name = L["Smooth Bars"],
							desc = L["Bars will transition smoothly."],
							set = function(info, value) E.db.nameplates[info[#info]] = value; NP:ConfigureAll(); end,
						},
						nameplateShowAll = {
							order = 14,
							type = "toggle",
							name = L.UNIT_NAMEPLATES_AUTOMODE,
							get = function(info) return E.db.nameplates.visibility.nameplateShowAll end,
							set = function(info, value) E.db.nameplates.visibility.nameplateShowAll = value; NP:SetCVars() NP:ConfigureAll() end,
						},
						visibility = {
							order = 14,
							type = "group",
							guiInline = true,
							name = L["Name Visibility"],
							get = function(info) return E.db.nameplates.visibility[info[#info]] end,
							set = function(info, value) E.db.nameplates.visibility[info[#info]] = value; NP:SetCVars() NP:ConfigureAll() end,
							args = {
								UnitNameNPC = {
									order = 2,
									type = "toggle",
									name = L.NPC_NAMES_DROPDOWN_ALL,
									set = function(info, value) E.db.nameplates.visibility[info[#info]] = value; E.db.nameplates.visibility.UnitNameHostleNPC = false; NP:SetCVars() NP:ConfigureAll() end,
								},
								UnitNameFriendlySpecialNPCName ={
									order = 3,
									type = "toggle",
									name = L.NPC_NAMES_DROPDOWN_TRACKED,
								},
								UnitNameHostleNPC = {
									order = 4,
									type = "toggle",
									name = L["Hostile NPCs"],
									disabled = function() return E.db.nameplates.visibility.UnitNameNPC end,
								},
								UnitNameInteractiveNPC = {
									order = 5,
									type = "toggle",
									name = L["Interactive NPCs"],
								},
							},
						},
						clickThrough = {
							order = 15,
							type = "group",
							guiInline = true,
							name = L["Click Through"],
							get = function(info) return E.db.nameplates.clickThrough[info[#info]] end,
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
						plateSize = {
							order = 16,
							type = "group",
							guiInline = true,
							name = L["NamePlate Size"],
							args = {
								personal = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Personal"],
									get = function(info) return E.db.nameplates.plateSize[info[#info]] end,
									set = function(info, value) E.db.nameplates.plateSize[info[#info]] = value; NP:ConfigureAll() end,
									args = {
										personalWidth = {
											order = 1,
											type = "range",
											name = L["Clickable Width"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 50, max = 250, step = 1,
										},
										personalHeight = {
											order = 2,
											type = "range",
											name = L["Clickable Height"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 10, max = 75, step = 1,
										},
									},
								},
								friendly = {
									order = 2,
									type = "group",
									guiInline = true,
									name = L["Friendly"],
									get = function(info) return E.db.nameplates.plateSize[info[#info]] end,
									set = function(info, value) E.db.nameplates.plateSize[info[#info]] = value; NP:ConfigureAll() end,
									args = {
										friendlyWidth = {
											order = 1,
											type = "range",
											name = L["Clickable Width"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 50, max = 250, step = 1,
										},
										friendlyHeight = {
											order = 2,
											type = "range",
											name = L["Clickable Height"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 10, max = 75, step = 1,
										},
									},
								},
								enemy = {
									order = 3,
									type = "group",
									guiInline = true,
									name = L["Enemy"],
									get = function(info) return E.db.nameplates.plateSize[info[#info]] end,
									set = function(info, value) E.db.nameplates.plateSize[info[#info]] = value; NP:ConfigureAll() end,
									args = {
										enemyWidth = {
											order = 1,
											type = "range",
											name = L["Clickable Width"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 50, max = 250, step = 1,
										},
										enemyHeight = {
											order = 2,
											type = "range",
											name = L["Clickable Height"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 10, max = 75, step = 1,
										},
									},
								},
							},
						},
					},
				},
				colorsGroup ={
					type = 'group',
					name = L.COLORS,
					args = {
						general = {
							order = 1,
							type = "group",
							name = L["General"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors[info[#info]]
								local d = P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								glowColor = {
									name = L["Target Indicator Color"],
									type = 'color',
									order = 5,
									hasAlpha = true,
								},
							},
						},
						threat = {
							order = 2,
							type = "group",
							name = L["Threat"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.threat[info[#info]]
								local d = P.nameplates.colors.threat[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors.threat[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								goodColor = {
									type = "color",
									order = 1,
									name = L["Good Color"],
									hasAlpha = false,
									disabled = function() return not E.db.nameplates.threat.useThreatColor end,
								},
								goodTransition = {
									type = "color",
									order = 2,
									name = L["Good Transition Color"],
									hasAlpha = false,
									disabled = function() return not E.db.nameplates.threat.useThreatColor end,
								},
								badTransition = {
									name = L["Bad Transition Color"],
									order = 3,
									type = 'color',
									hasAlpha = false,
									disabled = function() return not E.db.nameplates.threat.useThreatColor end,
								},
								badColor = {
									name = L["Bad Color"],
									order = 4,
									type = 'color',
									hasAlpha = false,
									disabled = function() return not E.db.nameplates.threat.useThreatColor end,
								},
								offTankColor = {
									name = L["Off Tank"],
									order = 5,
									type = 'color',
									hasAlpha = false,
									disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end,
								},
								offTankColorGoodTransition = {
									name = L["Off Tank Good Transtion"],
									order = 6,
									type = 'color',
									hasAlpha = false,
									disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end,
								},
								offTankColorBadTransition = {
									name = L["Off Tank Bad Transtion"],
									order = 7,
									type = 'color',
									hasAlpha = false,
									disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor) end,
								},
							},
						},
						castGroup = {
							order = 3,
							type = "group",
							name = L["Cast Bar"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors[info[#info]]
								local d = P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
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
								castbarDesaturate = {
									type = 'toggle',
									name = L["Desaturated Icon"],
									desc = L["Show the castbar icon desaturated if a spell is not interruptible."],
									order = 3,
									get = function(info) return E.db.nameplates.colors[info[#info]] end,
									set = function(info, value) E.db.nameplates.colors[info[#info]] = value; NP:ConfigureAll() end,
								},
							},
						},
						selectionGroup = {
							order = 4,
							type = 'group',
							name = L["Selection"],
							guiInline = true,
							get = function(info)
								local n = tonumber(info[#info])
								local t = E.db.nameplates.colors.selection[n]
								local d = P.nameplates.colors.selection[n]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local n = tonumber(info[#info])
								local t = E.db.nameplates.colors.selection[n]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
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
						--[[ LS- said to just use "Player Extended" as "Player" and don't use "Player Simple" at all
								['4'] = {
									order = 4,
									name = L["Player Simple"],
									type = 'color',
								},
							]]
								['5'] = {
									order = 5,
									name = L["Player"], -- Player Extended
									type = 'color',
								},
								['6'] = {
									order = 6,
									name = L.PARTY,
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
						--[[ disabled in oUF for now by LS-
								['12'] = {
									order = 12,
									name = L["Self"],
									type = 'color',
								},
							]]
								['13'] = {
									order = 13,
									name = L["Battleground Friendly"],
									type = 'color',
								},
							},
						},
						reactions = {
							order = 5,
							type = "group",
							name = L["Reaction Colors"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.reactions[info[#info]]
								local d = P.nameplates.colors.reactions[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.nameplates.colors.reactions[info[#info]]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
							end,
							args = {
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
									get = function(info)
										local t = E.db.nameplates.colors[info[#info]]
										local d = P.nameplates.colors[info[#info]]
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.nameplates.colors[info[#info]]
										t.r, t.g, t.b = r, g, b
										NP:ConfigureAll()
									end,
								},
							},
						},
						healPrediction = {
							order = 6,
							name = L["Heal Prediction"],
							type = 'group',
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.healPrediction[info[#info]]
								local d = P.nameplates.colors.healPrediction[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors.healPrediction[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
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
						power = {
							order = 7,
							name = L["Power Color"],
							type = 'group',
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.power[info[#info]]
								local d = P.nameplates.colors.power[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors.power[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								ENERGY = {
									order = 1,
									name = L.ENERGY,
									type = 'color',
								},
								FOCUS = {
									order = 2,
									name = L.FOCUS,
									type = 'color',
								},
								FURY = {
									order = 3,
									name = L.FURY,
									type = 'color',
								},
								INSANITY = {
									order = 4,
									name = L.INSANITY,
									type = 'color',
								},
								LUNAR_POWER = {
									order = 5,
									name = L.LUNAR_POWER,
									type = 'color',
								},
								MAELSTROM = {
									order = 6,
									name = L.MAELSTROM,
									type = 'color',
								},
								MANA = {
									order = 7,
									name = L.MANA,
									type = 'color',
								},
								PAIN = {
									order = 8,
									name = L.PAIN,
									type = 'color',
								},
								RAGE = {
									order = 9,
									name = L.RAGE,
									type = 'color',
								},
								RUNIC_POWER = {
									order = 10,
									name = L.RUNIC_POWER,
									type = 'color',
								},
							},
						},
						classResources = {
							order = 8,
							name = L["Class Resources"],
							type = 'group',
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.classResources[info[#info]]
								local d = P.nameplates.colors.classResources[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors.classResources[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								['PALADIN'] = {
									type = 'color',
									order = 1,
									name = L.HOLY_POWER,
								},
								['MAGE'] = {
									type = 'color',
									order = 2,
									name = L.POWER_TYPE_ARCANE_CHARGES,
								},
								['WARLOCK'] = {
									type = 'color',
									order = 3,
									name = L.SOUL_SHARDS,
								},
								['DEATHKNIGHT'] = {
									type = 'color',
									order = 4,
									name = L.RUNES,
								},
								spacer1 = {
									order = 5,
									type = 'description',
									name = ' ',
								},
								spacer2 = {
									order = 20,
									type = 'description',
									name = ' ',
								},
							},
						},
					},
				},
				threatGroup = {
					order = 150,
					type = "group",
					name = L["Threat"],
					get = function(info) return E.db.nameplates.threat[info[#info]] end,
					set = function(info, value) E.db.nameplates.threat[info[#info]] = value; NP:ConfigureAll() end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
						},
						useThreatColor = {
							order = 1,
							type = "toggle",
							name = L["Use Threat Color"],
						},
						beingTankedByTank = {
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							order = 2,
							type = "toggle",
							disabled = function() return not E.db.nameplates.threat.useThreatColor end,
						},
						indicator = {
							name = L["Show Icon"],
							order = 3,
							type = 'toggle',
							disabled = function() return not E.db.nameplates.threat.enable end,
						},
						goodScale = {
							name = L["Good Scale"],
							order = 4,
							type = 'range',
							isPercent = true,
							min = 0.5, max = 1.5, softMin = .75, softMax = 1.25, step = 0.01,
							disabled = function() return not E.db.nameplates.threat.enable end,
						},
						badScale = {
							name = L["Bad Scale"],
							order = 6,
							type = 'range',
							isPercent = true,
							min = 0.5, max = 1.5, softMin = .75, softMax = 1.25, step = 0.01,
							disabled = function() return not E.db.nameplates.threat.enable end,
						},
					},
				},
				cutawayHealth = {
					order = 226,
					name = L["Cutaway Health"],
					type = 'group',
					disabled = function() return true end,
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
			},
		},
		filters = {
			type = "group",
			order = 30,
			name = L["Style Filter"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates.Initialized end,
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
						NP:StyleFilterCopyDefaults(filter);
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
		playerGroup = GetUnitSettings("PLAYER", L["Player"]),
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["FRIENDLY_PLAYER"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["FRIENDLY_NPC"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["ENEMY_PLAYER"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["ENEMY_NPC"]),
		targetGroup = {
			order = 101,
			type = "group",
			name = L.TARGET,
			get = function(info) return E.db.nameplates.units.TARGET[info[#info]] end,
			set = function(info, value) E.db.nameplates.units.TARGET[info[#info]] = value; NP:SetCVars() NP:ConfigureAll() end,
			disabled = function() return not E.NamePlates.Initialized end,
			args = {
				classBarGroup = {
					order = 1,
					type = "group",
					name = L["Classbar"],
					guiInline = true,
					get = function(info) return E.db.nameplates.units.TARGET.classpower[info[#info]] end,
					set = function(info, value) E.db.nameplates.units.TARGET.classpower[info[#info]] = value; NP:ConfigureAll() end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"]
						},
						width = {
							order = 2,
							name = L["Width"],
							type = "range",
							min = 50, max = 200, step = 1,
						},
						height = {
							order = 3,
							name = L["Height"],
							type = "range",
							min = 4, max = 20, step = 1,
						},
						xOffset = {
							order = 4,
							name = L["X-Offset"],
							type = "range",
							min = -100, max = 100, step = 1,
						},
						yOffset = {
							order = 4,
							name = L["Y-Offset"],
							type = "range",
							min = -100, max = 100, step = 1,
						},
						classColor = {
							type = "toggle",
							order = 5,
							name = L["Use Class Color"]
						},
						sortDirection = {
							order = 6,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = 'select',
							values = {
								['asc'] = L["Ascending"],
								['desc'] = L["Descending"],
								['NONE'] = L.NONE,
							},
							hidden = function() return (E.myclass ~= 'DEATHKNIGHT') end,
						},
					},
				},
				glowStyle = {
					order = 2,
					type = "select",
					customWidth = 225,
					name = L["Target/Low Health Indicator"],
					values = {
						['none'] = L.NONE,
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
				nonTargetAlphaShortcut = {
					order = 3,
					type = "execute",
					name = L["Non-Target Alpha"],
					buttonElvUI = true,
					func = function() ACD:SelectGroup("ElvUI", "nameplate", "filters", "actions"); selectedNameplateFilter = 'ElvUI_NonTarget'; UpdateFilterGroup() end,
				},
				targetScaleShortcut = {
					order = 4,
					type = "execute",
					name = L["Scale"],
					buttonElvUI = true,
					func = function() ACD:SelectGroup("ElvUI", "nameplate", "filters", "actions"); selectedNameplateFilter = 'ElvUI_Target'; UpdateFilterGroup() end,
				},
			},
		},
	},
}

ORDER = 10
for i = 1, 6 do
	E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.classResources.args['CHI_POWER'..i] = {
		type = 'color',
		order = i+ORDER,
		name = L.CHI_POWER..' #'..i,
		get = function(info)
			local t = E.db.nameplates.colors.classResources.MONK[i]
			local d = P.nameplates.colors.classResources.MONK[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = E.db.nameplates.colors.classResources.MONK[i]
			t.r, t.g, t.b = r, g, b
			NP:ConfigureAll()
		end,
	}
	E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.classResources.args['COMBO_POINTS'..i] = {
		type = 'color',
		order = i + (ORDER * 2),
		name = L.COMBO_POINTS..' #'..i,
		get = function(info)
			local t = E.db.nameplates.colors.classResources.comboPoints[i]
			local d = P.nameplates.colors.classResources.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = E.db.nameplates.colors.classResources.comboPoints[i]
			t.r, t.g, t.b = r, g, b
			NP:ConfigureAll()
		end,
	}
end

-- E.Options.args.tagGroup = {
-- 	order = 925,
-- 	type = "group",
-- 	name = L["Available Tags"],
-- 	args = {}
-- }

-- for Tag in next, E.oUF.Tags.Methods do
-- 	E.Options.args.tagGroup.args[Tag] = {
-- 		type = 'description',
-- 		fontSize = 'medium',
-- 		name = Tag,
-- 	}
-- end

-- E.Options.args.EventTrace = {
-- 	order = -50,
-- 	type = "group",
-- 	name = L["Event Trace"],
-- 	args = {}
-- }

-- local Frame = CreateFrame('Frame')
-- Frame:RegisterAllEvents()
-- Frame:SetScript('OnEvent', function(self, event, ...)
-- 	E.Options.args.EventTrace.args[event] = {
-- 		type = 'description',
-- 		fontSize = 'medium',
-- 		name = event,
-- 	}
-- end)
