local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(E.OptionsUI)
local NP = E:GetModule('NamePlates')
local ACH = E.Libs.ACH

local _G = _G
local wipe, pairs, strmatch, tostring = wipe, pairs, strmatch, tostring
local next, ipairs, tinsert, sort, tonumber, format = next, ipairs, tinsert, sort, tonumber, format

local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_SpecializationInfo_GetPvpTalentSlotInfo = E.Retail and C_SpecializationInfo.GetPvpTalentSlotInfo
local GetClassInfo = GetClassInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetInstanceInfo = GetInstanceInfo
local GetNumClasses = GetNumClasses
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetRealZoneText = GetRealZoneText
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetTalentInfo = GetTalentInfo

local filters = {}
local raidTargetIcon = [[|TInterface\TargetingFrame\UI-RaidTargetingIcon_%s:0|t %s]]

C.SelectedNameplateStyleFilter = nil

local function GetFilter(collect, profile)
	local setting = (profile and E.db.nameplates.filters[C.SelectedNameplateStyleFilter]) or E.global.nameplate.filters[C.SelectedNameplateStyleFilter]

	if collect and setting then
		return setting.triggers, setting.actions
	else
		return setting
	end
end

local function DisabledFilter()
	local profileTriggers = GetFilter(true, true)
	return not (profileTriggers and profileTriggers.enable)
end

local specListOrder = 50 -- start at 50
local classTable, classIndexTable, classOrder
local function UpdateClassSpec(classTag, enabled)
	if not E.Retail or not (classTable[classTag] and classTable[classTag].classID) then
		return
	end

	local classSpec = format('%s%s', classTag, 'spec')
	if enabled == false then
		if E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] then
			E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] = nil
			specListOrder = specListOrder - 1
		end
		return -- stop when we remove one OR when we pass disable with clear filter
	end

	local group = E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec]
	if not E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] then
		specListOrder = specListOrder + 1
		group = ACH:Group(classTable[classTag].name, nil, specListOrder)
		group.inline = true
	end

	local coloredName = E:ClassColor(classTag)
	coloredName = (coloredName and coloredName.colorStr) or 'ff666666'
	for i = 1, GetNumSpecializationsForClassID(classTable[classTag].classID) do
		local specID, name = GetSpecializationInfoForClassID(classTable[classTag].classID, i)
		local tagID = format('%s%s', classTag, specID)
		if not group.args[tagID] then
			group.args[tagID] = ACH:Toggle(format('|c%s%s|r', coloredName, name), nil, i, nil, nil, nil,
			function()
				local triggers = GetFilter(true)
				local tagTrigger = triggers.class[classTag]
				return tagTrigger and tagTrigger.specs and tagTrigger.specs[specID]
			end,
			function(_, value)
				local triggers = GetFilter(true)
				local tagTrigger = triggers.class[classTag]

				if not tagTrigger.specs then
					triggers.class[classTag].specs = {}
				end

				triggers.class[classTag].specs[specID] = value or nil

				if not next(triggers.class[classTag].specs) then
					triggers.class[classTag].specs = nil
				end

				NP:ConfigureAll()
			end)
		end
	end

	E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] = group
end

local function UpdateClassSection()
	local filter = GetFilter()
	if filter then
		if not classTable then
			classTable, classIndexTable = {}, {}
			for i = 1, GetNumClasses() do
				local classDisplayName, classTag, classID = GetClassInfo(i)
				if classTag then
					if not classTable[classTag] then
						classTable[classTag] = {}
					end
					classTable[classTag].name = classDisplayName
					classTable[classTag].classID = classID
				end
			end
			for tag in pairs(classTable) do
				tinsert(classIndexTable, tag)
			end
			sort(classIndexTable)
		end
		classOrder = 0

		for _, classTag in ipairs(classIndexTable) do
			classOrder = classOrder + 1
			local coloredName = E:ClassColor(classTag)
			coloredName = (coloredName and coloredName.colorStr) or 'ff666666'
			local classTrigger = filter.triggers.class
			if classTrigger then
				if classTrigger[classTag] and classTrigger[classTag].enabled then
					UpdateClassSpec(classTag) --populate enabled class spec boxes
				else
					UpdateClassSpec(classTag, false)
				end
			end
			E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classTag] = {
				order = classOrder,
				name = format('|c%s%s|r', coloredName, classTable[classTag].name),
				type = 'toggle',
				get = function()
					local triggers = GetFilter(true)
					local tagTrigger = triggers.class[classTag]
					return tagTrigger and tagTrigger.enabled
				end,
				set = function(_, value)
					local triggers = GetFilter(true)
					local tagTrigger = triggers.class[classTag]
					if not tagTrigger then
						triggers.class[classTag] = {}
					end
					--set this to nil if false to keep its population to only enabled ones
					if value then
						triggers.class[classTag].enabled = value
					else
						triggers.class[classTag] = nil
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
	local arg1, arg2, arg3 = GetTalentInfo(tier, column, 1)
	if E.Retail then
		if arg3 then
			return formatStr:format(arg3, arg2)
		end
	elseif arg2 then -- doesnt work right now, could later?
		return formatStr:format(arg2, arg1)
	end
end

local function GetPvpTalentString(talentID)
	local _, name, texture = GetPvpTalentInfoByID(talentID)
	if texture then
		return formatStr:format(texture, name)
	end
end

local function GenerateValues(tier, isPvP)
	local values = {}

	if isPvP then
		if E.Retail then
			local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(tier)
			if slotInfo.availableTalentIDs then
				for i = 1, #slotInfo.availableTalentIDs do
					local talentID = slotInfo.availableTalentIDs[i]
					values[talentID] = GetPvpTalentString(talentID)
				end
			end
		end
	else
		for i = 1, 3 do
			values[i] = GetTalentString(tier, i)
		end
	end

	return values
end

local function UpdateTalentSection()
	local filter = GetFilter()
	if filter then
		local maxTiers = (filter.triggers.talent.type == 'normal' and 7) or 4
		E.Options.args.nameplate.args.filters.args.triggers.args.talent.args = {
			enabled = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
				get = function()
					local triggers = GetFilter(true)
					return triggers.talent.enabled
				end,
				set = function(_, value)
					local triggers = GetFilter(true)
					triggers.talent.enabled = value
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			},
			type = {
				type = 'toggle',
				order = 2,
				name = L["Is PvP Talents"],
				disabled = function()
					local triggers = GetFilter(true)
					return not triggers.talent.enabled
				end,
				get = function()
					local triggers = GetFilter(true)
					return triggers.talent.type == 'pvp'
				end,
				set = function(_, value)
					local triggers = GetFilter(true)
					triggers.talent.type = value and 'pvp' or 'normal'
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			},
			requireAll = {
				type = 'toggle',
				order = 3,
				name = L["Require All"],
				disabled = function()
					local triggers = GetFilter(true)
					return not triggers.talent.enabled
				end,
				get = function()
					local triggers = GetFilter(true)
					return triggers.talent.requireAll
				end,
				set = function(_, value)
					local triggers = GetFilter(true)
					triggers.talent.requireAll = value
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			}
		}

		if not E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers then
			E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers = {
				type = 'group',
				order = 4,
				name = L["Tiers"],
				inline = true,
				disabled = function()
					local triggers = GetFilter(true)
					return not triggers.talent.enabled
				end,
				args = {}
			}
		end

		local order = 1
		for i = 1, maxTiers do
			E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers.args['tier' .. i .. 'enabled'] = {
				type = 'toggle',
				order = order,
				name = format(L["GARRISON_CURRENT_LEVEL"], i),
				get = function()
					local triggers = GetFilter(true)
					return triggers.talent['tier' .. i .. 'enabled']
				end,
				set = function(_, value)
					local triggers = GetFilter(true)
					triggers.talent['tier' .. i .. 'enabled'] = value
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			}

			order = order + 1

			if filter.triggers.talent['tier' .. i .. 'enabled'] then
				E.Options.args.nameplate.args.filters.args.triggers.args.talent.args.tiers.args['tier' .. i] = {
					type = 'group',
					order = order,
					inline = true,
					name = L["Tier " .. i],
					args = {
						missing = {
							type = 'toggle',
							order = 2,
							name = L["Missing"],
							desc = L["Match this trigger if the talent is not selected"],
							get = function()
								local triggers = GetFilter(true)
								return triggers.talent['tier' .. i].missing
							end,
							set = function(_, value)
								local triggers = GetFilter(true)
								triggers.talent['tier' .. i].missing = value
								UpdateTalentSection()
								NP:ConfigureAll()
							end
						},
						column = {
							type = 'select',
							order = 1,
							name = L["TALENT"],
							style = 'dropdown',
							desc = L["Talent to match"],
							get = function()
								local triggers = GetFilter(true)
								return triggers.talent['tier' .. i].column
							end,
							set = function(_, value)
								local triggers = GetFilter(true)
								triggers.talent['tier' .. i].column = value
								NP:ConfigureAll()
							end,
							values = function()
								local triggers = GetFilter(true)
								return GenerateValues(i, triggers.talent.type == 'pvp')
							end
						}
					}
				}
				order = order + 1
			end

			order = order + 1
		end
	end
end

local function UpdateInstanceDifficulty()
	local filter = GetFilter()
	if filter.triggers.instanceType.party then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.dungeonDifficulty = {
			type = 'multiselect',
			name = L["DUNGEON_DIFFICULTY"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			order = 10,
			get = function(_, key)
				local triggers = GetFilter(true)
				return triggers.instanceDifficulty.dungeon[key]
			end,
			set = function(_, key, value)
				local triggers = GetFilter(true)
				triggers.instanceDifficulty.dungeon[key] = value
				UpdateInstanceDifficulty()
				NP:ConfigureAll()
			end,
			values = {
				normal = GetDifficultyInfo(1),
				heroic = GetDifficultyInfo(2),
				mythic = GetDifficultyInfo(23),
				['mythic+'] = GetDifficultyInfo(8),
				timewalking = GetDifficultyInfo(24),
			}
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.dungeonDifficulty = nil
	end

	if filter.triggers.instanceType.raid then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.raidDifficulty = {
			type = 'multiselect',
			name = L["Raid Difficulty"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			order = 11,
			get = function(_, key)
				local triggers = GetFilter(true)
				return triggers.instanceDifficulty.raid[key]
			end,
			set = function(_, key, value)
				local triggers = GetFilter(true)
				triggers.instanceDifficulty.raid[key] = value
				UpdateInstanceDifficulty()
				NP:ConfigureAll()
			end,
			values = {
				lfr = GetDifficultyInfo(17),
				normal = GetDifficultyInfo(14),
				heroic = GetDifficultyInfo(15),
				mythic = GetDifficultyInfo(16),
				timewalking = GetDifficultyInfo(24),
				legacy10normal = GetDifficultyInfo(3),
				legacy25normal = GetDifficultyInfo(4),
				legacy10heroic = GetDifficultyInfo(5),
				legacy25heroic = GetDifficultyInfo(6),
			}
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.raidDifficulty = nil
	end
end

local function UpdateStyleLists()
	local filter = GetFilter()
	for _, which in next, {'names', 'items'} do
		if filter and filter.triggers and filter.triggers[which] then
			E.Options.args.nameplate.args.filters.args.triggers.args[which].args.list = {
				order = 50,
				type = 'group',
				name = '',
				inline = true,
				args = {}
			}

			if next(filter.triggers[which]) then
				for name in pairs(filter.triggers[which]) do
					E.Options.args.nameplate.args.filters.args.triggers.args[which].args.list.args[name] = {
						name = name,
						type = 'toggle',
						order = -1,
						get = function()
							local triggers = GetFilter(true)
							return triggers[which] and triggers[which][name]
						end,
						set = function(_, value)
							local triggers = GetFilter(true)
							triggers[which][name] = value
							NP:ConfigureAll()
						end
					}
				end
			end
		end
	end

	if filter and filter.triggers.casting and filter.triggers.casting.spells then
		E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(filter.triggers.casting.spells) then
			for name in pairs(filter.triggers.casting.spells) do
				local spell, spellID = name, tonumber(name)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					if spellName then
						if DisabledFilter() then
							spell = format('%s (%d)', spellName, spellID)
						else
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r', spellName, spellID)
						end
					end
				end

				local spellTexture = GetSpellTexture(spellID or spell)
				local spellDescription = spellTexture and E:TextureString(spellTexture, ':32:32:0:0:32:32:4:28:4:28')
				E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells.args[name] = {
					name = spell,
					desc = spellDescription,
					type = 'toggle',
					order = -1,
					get = function()
						local triggers = GetFilter(true)
						return triggers.casting.spells and triggers.casting.spells[name]
					end,
					set = function(_, value)
						local triggers = GetFilter(true)
						triggers.casting.spells[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if filter and filter.triggers.cooldowns and filter.triggers.cooldowns.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(filter.triggers.cooldowns.names) then
			for name in pairs(filter.triggers.cooldowns.names) do
				local spell, spellID = name, tonumber(name)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					if spellName then
						if DisabledFilter() then
							spell = format('%s (%d)', spellName, spellID)
						else
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r', spellName, spellID)
						end
					end
				end

				local spellTexture = GetSpellTexture(spellID or spell)
				local spellDescription = spellTexture and E:TextureString(spellTexture, ':32:32:0:0:32:32:4:28:4:28')
				E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names.args[name] = {
					name = spell,
					desc = spellDescription,
					type = 'select',
					values = {
						DISABLED = _G.DISABLE,
						ONCD = L["On Cooldown"],
						OFFCD = L["Off Cooldown"]
					},
					order = -1,
					get = function()
						local triggers = GetFilter(true)
						return triggers.cooldowns.names and triggers.cooldowns.names[name]
					end,
					set = function(_, value)
						local triggers = GetFilter(true)
						triggers.cooldowns.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if filter and filter.triggers.buffs and filter.triggers.buffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(filter.triggers.buffs.names) then
			for name in pairs(filter.triggers.buffs.names) do
				local spell, stacks = strmatch(name, NP.StyleFilterStackPattern)
				local spellID = tonumber(spell)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					if spellName then
						if DisabledFilter() then
							spell = format('%s (%d)', spellName, spellID)
						else
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r|cFF999999%s|r', spellName, spellID, (stacks ~= '' and ' x'..stacks) or '')
						end
					end
				end

				local spellTexture = GetSpellTexture(spellID or spell)
				local spellDescription = spellTexture and E:TextureString(spellTexture, ':32:32:0:0:32:32:4:28:4:28')
				E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names.args[name] = {
					textWidth = true,
					name = spell,
					desc = spellDescription,
					type = 'toggle',
					order = -1,
					get = function()
						local triggers = GetFilter(true)
						return triggers.buffs.names and triggers.buffs.names[name]
					end,
					set = function(_, value)
						local triggers = GetFilter(true)
						triggers.buffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if filter and filter.triggers.debuffs and filter.triggers.debuffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(filter.triggers.debuffs.names) then
			for name in pairs(filter.triggers.debuffs.names) do
				local spell, stacks = strmatch(name, NP.StyleFilterStackPattern)
				local spellID = tonumber(spell)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					if spellName then
						if DisabledFilter() then
							spell = format('%s (%d)', spellName, spellID)
						else
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r|cFF999999%s|r', spellName, spellID, (stacks ~= '' and ' x'..stacks) or '')
						end
					end
				end

				local spellTexture = GetSpellTexture(spellID or spell)
				local spellDescription = spellTexture and E:TextureString(spellTexture, ':32:32:0:0:32:32:4:28:4:28')
				E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names.args[name] = {
					textWidth = true,
					name = spell,
					desc = spellDescription,
					type = 'toggle',
					order = -1,
					get = function()
						local triggers = GetFilter(true)
						return triggers.debuffs.names and triggers.debuffs.names[name]
					end,
					set = function(_, value)
						local triggers = GetFilter(true)
						triggers.debuffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if filter and filter.triggers and filter.triggers.bossMods then
		E.Options.args.nameplate.args.filters.args.triggers.args.bossModAuras.args.auras = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {},
			disabled = function()
				local triggers = GetFilter(true)
				return DisabledFilter() or triggers.bossMods.missingAura or triggers.bossMods.hasAura or not triggers.bossMods.enable
			end
		}
		if next(filter.triggers.bossMods.auras) then
			for aura in pairs(filter.triggers.bossMods.auras) do
				E.Options.args.nameplate.args.filters.args.triggers.args.bossModAuras.args.auras.args[aura] = {
					name = aura,
					desc = E:TextureString(aura, ':32:32:0:0:32:32:4:28:4:28'),
					type = 'toggle',
					order = -1,
					get = function()
						local triggers = GetFilter(true)
						return triggers.bossMods and triggers.bossMods.auras and triggers.bossMods.auras[aura]
					end,
					set = function(_, value)
						local triggers = GetFilter(true)
						triggers.bossMods.auras[aura] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end
end

local UpdateFilterGroup -- set below but we need this in UpdateBossModAuras
local function UpdateBossModAuras()
	local filter = GetFilter()
	if filter and filter.triggers and filter.triggers.bossMods and next(NP.BossMods_TextureCache) then
		for texture in pairs(NP.BossMods_TextureCache) do
			E.Options.args.nameplate.args.filters.args.triggers.args.bossModAuras.args.seenList.args[texture] = {
				name = texture,
				desc = E:TextureString(texture, ':32:32:0:0:32:32:4:28:4:28'),
				type = 'toggle',
				order = -1,
				get = function()
					local triggers = GetFilter(true)
					return triggers.bossMods and triggers.bossMods.auras and triggers.bossMods.auras[texture]
				end,
				set = function(_, value)
					local triggers = GetFilter(true)
					triggers.bossMods.auras[texture] = value
					UpdateFilterGroup()
					NP:ConfigureAll()
				end
			}
		end
	end
end

function UpdateFilterGroup()
	local filter = GetFilter()
	local stackBuff, stackDebuff
	if not C.SelectedNameplateStyleFilter or not filter then
		E.Options.args.nameplate.args.filters.args.header = nil
		E.Options.args.nameplate.args.filters.args.actions = nil
		E.Options.args.nameplate.args.filters.args.triggers = nil
	end
	if C.SelectedNameplateStyleFilter and filter then
		E.Options.args.nameplate.args.filters.args.triggers = {
			type = 'group',
			name = L["Triggers"],
			order = 5,
			args = {
				enable = {
					name = L["Enable"],
					order = 0,
					type = 'toggle',
					get = function()
						local profileTriggers = GetFilter(true, true)
						return profileTriggers and profileTriggers.enable
					end,
					set = function(_, value)
						if not E.db.nameplates then E.db.nameplates = {} end
						if not E.db.nameplates.filters then E.db.nameplates.filters = {} end
						if not E.db.nameplates.filters[C.SelectedNameplateStyleFilter] then
							E.db.nameplates.filters[C.SelectedNameplateStyleFilter] = {}
						end

						local profileFilter = GetFilter(nil, true)
						if not profileFilter.triggers then profileFilter.triggers = {} end
						profileFilter.triggers.enable = value

						UpdateStyleLists() --we need this to recolor the spellid based on wether or not the filter is disabled

						NP:ConfigureAll()
					end
				},
				priority = {
					name = L["Filter Priority"],
					desc = L["Lower numbers mean a higher priority. Filters are processed in order from 1 to 100."],
					order = 1,
					type = 'range',
					min = 1,
					max = 100,
					step = 1,
					disabled = DisabledFilter,
					get = function()
						local triggers = GetFilter(true)
						return triggers.priority or 1
					end,
					set = function(_, value)
						local triggers = GetFilter(true)
						triggers.priority = value
						NP:ConfigureAll()
					end
				},
				resetFilter = {
					order = 2,
					name = L["Clear Filter"],
					desc = L["Return filter to its default state."],
					type = 'execute',
					func = function()
						local newFilter = {}
						if G.nameplate.filters[C.SelectedNameplateStyleFilter] then
							newFilter = E:CopyTable(filter, G.nameplate.filters[C.SelectedNameplateStyleFilter])
						end

						NP:StyleFilterCopyDefaults(newFilter)
						E.global.nameplate.filters[C.SelectedNameplateStyleFilter] = newFilter

						UpdateStyleLists()
						UpdateClassSection()
						UpdateTalentSection()
						UpdateInstanceDifficulty()

						NP:ConfigureAll()
					end
				},
				names = {
					name = L["Name"],
					order = 6,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						addName = {
							order = 1,
							name = L["Add Name or NPC ID"],
							desc = L["Add a Name or NPC ID to the list."],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeName = {
							order = 2,
							name = L["Remove Name or NPC ID"],
							desc = L["Remove a Name or NPC ID from the list."],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						negativeMatch = {
							order = 3,
							name = L["Negative Match"],
							desc = L["Match if Name or NPC ID is NOT in the list."],
							type = 'toggle',
							get = function(info)
								local triggers = GetFilter(true)
								return triggers[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers[info[#info]] = value
								NP:ConfigureAll()
							end
						}
					}
				},
				targeting = {
					name = L["Targeting"],
					order = 7,
					type = 'group',
					get = function(info)
						local triggers = GetFilter(true)
						return triggers[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								isTarget = ACH:Toggle(L["Is Targeted"], L["If enabled then the filter will only activate when you are targeting the unit."], 1),
								notTarget = ACH:Toggle(L["Not Targeted"], L["If enabled then the filter will only activate when you are not targeting the unit."], 2),
								requireTarget = ACH:Toggle(L["Require Target"], L["If enabled then the filter will only activate when you have a target."], 2),
								targetMe = ACH:Toggle(L["Is Targeting Player"], L["If enabled then the filter will only activate when the unit is targeting you."], 4),
								notTargetMe = ACH:Toggle(L["Not Targeting Player"], L["If enabled then the filter will only activate when the unit is not targeting you."], 5),
								isFocus = ACH:Toggle(L["Is Focused"], L["If enabled then the filter will only activate when you are focusing the unit."], 7, nil, nil, nil, nil, nil, nil, E.Classic),
								notFocus = ACH:Toggle(L["Not Focused"], L["If enabled then the filter will only activate when you are not focusing the unit."], 8, nil, nil, nil, nil, nil, nil, E.Classic)
							}
						}
					}
				},
				casting = {
					order = 8,
					type = 'group',
					name = L["Casting"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.casting[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.casting[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							args = {
								interruptible = ACH:Toggle(L["Interruptible"], L["If enabled then the filter will only activate if the unit is casting interruptible spells."], 1),
								notInterruptible = ACH:Toggle(L["Non-Interruptible"], L["If enabled then the filter will only activate if the unit is casting not interruptible spells."], 2),
								spacer1 = ACH:Spacer(3, 'full'),
								isCasting = ACH:Toggle(L["Is Casting Anything"], L["If enabled then the filter will activate if the unit is casting anything."], 4),
								notCasting = ACH:Toggle(L["Not Casting Anything"], L["If enabled then the filter will activate if the unit is not casting anything."], 5),
								spacer2 = ACH:Spacer(6, 'full'),
								isChanneling = ACH:Toggle(L["Is Channeling Anything"], L["If enabled then the filter will activate if the unit is channeling anything."], 7),
								notChanneling = ACH:Toggle(L["Not Channeling Anything"], L["If enabled then the filter will activate if the unit is not channeling anything."], 8),
							}
						},
						addSpell = {
							order = 2,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.casting.spells[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeSpell = {
							order = 3,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.casting.spells[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						notSpell = ACH:Toggle(L["Not Spell"], L["If enabled then the filter will only activate if the unit is not casting or channeling one of the selected spells."], 4),
						description1 = ACH:Description(L["You do not need to use Is Casting Anything or Is Channeling Anything for these spells to trigger."], 10),
						description2 = ACH:Description(L["If this list is empty, and if Interruptible is checked, then the filter will activate on any type of cast that can be interrupted."], 11),
					}
				},
				combat = {
					order = 9,
					type = 'group',
					name = L["Unit Conditions"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						playerGroup = {
							name = L["Player"],
							type = 'group',
							inline = true,
							order = 1,
							args = {
								inCombat = ACH:Toggle(L["In Combat"], L["If enabled then the filter will only activate when you are in combat."], 1),
								outOfCombat = ACH:Toggle(L["Out of Combat"], L["If enabled then the filter will only activate when you are out of combat."], 2),
								inVehicle = ACH:Toggle(L["In Vehicle"], L["If enabled then the filter will only activate when you are in a Vehicle."], 3, nil, nil, nil, nil, nil, nil, not E.Retail),
								outOfVehicle = ACH:Toggle(L["Out of Vehicle"], L["If enabled then the filter will only activate when you are not in a Vehicle."], 4, nil, nil, nil, nil, nil, nil, not E.Retail),
								isResting = ACH:Toggle(L["Is Resting"], L["If enabled then the filter will only activate when you are resting at an Inn."], 5),
								playerCanAttack = ACH:Toggle(L["Can Attack"], L["If enabled then the filter will only activate when the unit can be attacked by the active player."], 6),
								playerCanNotAttack = ACH:Toggle(L["Can Not Attack"], L["If enabled then the filter will only activate when the unit can not be attacked by the active player."], 7)
							}
						},
						unitGroup = {
							name = L["Unit"],
							type = 'group',
							inline = true,
							order = 2,
							args = {
								inCombatUnit = ACH:Toggle(L["In Combat"], L["If enabled then the filter will only activate when the unit is in combat."], 1),
								outOfCombatUnit = ACH:Toggle(L["Out of Combat"], L["If enabled then the filter will only activate when the unit is out of combat."], 2),
								inVehicleUnit = ACH:Toggle(L["In Vehicle"], L["If enabled then the filter will only activate when the unit is in a Vehicle."], 3, nil, nil, nil, nil, nil, nil, not E.Retail),
								outOfVehicleUnit = ACH:Toggle(L["Out of Vehicle"], L["If enabled then the filter will only activate when the unit is not in a Vehicle."], 4, nil, nil, nil, nil, nil, nil, not E.Retail),
								inParty = ACH:Toggle(L["In Party"], L["If enabled then the filter will only activate when the unit is in your Party."], 5),
								notInParty = ACH:Toggle(L["Not in Party"], L["If enabled then the filter will only activate when the unit is not in your Party."], 6),
								inRaid = ACH:Toggle(L["In Raid"], L["If enabled then the filter will only activate when the unit is in your Raid."], 7),
								notInRaid = ACH:Toggle(L["Not in Raid"], L["If enabled then the filter will only activate when the unit is not in your Raid."], 8),
								isPet = ACH:Toggle(L["Is Pet"], L["If enabled then the filter will only activate when the unit is the active player's pet."], 9),
								isNotPet= ACH:Toggle(L["Not Pet"], L["If enabled then the filter will only activate when the unit is not the active player's pet."], 10),
								isPlayerControlled = ACH:Toggle(L["Player Controlled"], L["If enabled then the filter will only activate when the unit is controlled by the player."], 11),
								isNotPlayerControlled = ACH:Toggle(L["Not Player Controlled"], L["If enabled then the filter will only activate when the unit is not controlled by the player."], 12),
								isOwnedByPlayer = ACH:Toggle(L["Owned By Player"], L["If enabled then the filter will only activate when the unit is owned by the player."], 13),
								isNotOwnedByPlayer = ACH:Toggle(L["Not Owned By Player"], L["If enabled then the filter will only activate when the unit is not owned by the player."], 14),
								isPvP = ACH:Toggle(L["Is PvP"], L["If enabled then the filter will only activate when the unit is pvp-flagged."], 15),
								isNotPvP = ACH:Toggle(L["Not PvP"], L["If enabled then the filter will only activate when the unit is not pvp-flagged."], 16),
								isTapDenied = ACH:Toggle(L["Tap Denied"], L["If enabled then the filter will only activate when the unit is tap denied."], 17),
								isNotTapDenied = ACH:Toggle(L["Not Tap Denied"], L["If enabled then the filter will only activate when the unit is not tap denied."], 18),
							}
						},
						npcGroup = {
							name = '',
							type = 'group',
							inline = true,
							order = 3,
							args = {
								hasTitleNPC = ACH:Toggle(L["Has NPC Title"], nil, 1),
								noTitleNPC = ACH:Toggle(L["No NPC Title"], nil, 2),
							}
						},
						questGroup = {
							name = '',
							type = 'group',
							inline = true,
							order = 4,
							args = {
								isQuest = ACH:Toggle(L["Quest Unit"], nil, 1),
								notQuest = ACH:Toggle(L["Not Quest Unit"], nil, 2),
								questBoss = ACH:Toggle(L["Quest Boss"], nil, 3, nil, nil, nil, nil, nil, nil, not E.Retail),
							}
						}
					}
				},
				faction = {
					order = 10,
					type = 'group',
					name = L["Unit Faction"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.faction[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.faction[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								Alliance = ACH:Toggle(L["Alliance"], nil, 1),
								Horde = ACH:Toggle(L["Horde"], nil, 2),
								Neutral = ACH:Toggle(L["Neutral"], nil, 3)
							}
						}
					}
				},
				class = {
					order = 11,
					type = 'group',
					name = L["CLASS"],
					disabled = DisabledFilter,
					args = {}
				},
				talent = {
					order = 12,
					type = 'group',
					name = L["TALENT"],
					disabled = DisabledFilter,
					hidden = not E.Retail,
					args = {}
				},
				slots = {
					name = L["Slots"],
					order = 13,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						types = {
							name = L["Equipped"],
							order = 1,
							inline = true,
							type = 'multiselect',
							sortByValue = true,
							get = function(_, key)
								local triggers = GetFilter(true)
								return triggers.slots[key]
							end,
							set = function(_, key, value)
								local triggers = GetFilter(true)
								triggers.slots[key] = value or nil
								NP:ConfigureAll()
							end,
							values = {
								[_G.INVSLOT_AMMO] = L["INVTYPE_AMMO"], -- 0
								[_G.INVSLOT_HEAD] = L["INVTYPE_HEAD"], -- 1
								[_G.INVSLOT_NECK] = L["INVTYPE_NECK"], -- 2
								[_G.INVSLOT_SHOULDER] = L["INVTYPE_SHOULDER"], -- 3
								[_G.INVSLOT_BODY] = L["INVTYPE_BODY"], -- 4 (shirt)
								[_G.INVSLOT_CHEST] = L["INVTYPE_CHEST"], -- 5
								[_G.INVSLOT_WAIST] = L["INVTYPE_WAIST"], -- 6
								[_G.INVSLOT_LEGS] = L["INVTYPE_LEGS"], -- 7
								[_G.INVSLOT_FEET] = L["INVTYPE_FEET"], -- 8
								[_G.INVSLOT_WRIST] = L["INVTYPE_WRIST"], -- 9
								[_G.INVSLOT_HAND] = L["INVTYPE_HAND"], -- 10
								[_G.INVSLOT_FINGER1] = L["INVTYPE_FINGER1"], -- 11 (no real global)
								[_G.INVSLOT_FINGER2] = L["INVTYPE_FINGER2"], -- 12 (no real global)
								[_G.INVSLOT_TRINKET1] = L["INVTYPE_TRINKET1"], -- 13 (no real global)
								[_G.INVSLOT_TRINKET2] = L["INVTYPE_TRINKET2"], -- 14 (no real global)
								[_G.INVSLOT_BACK] = L["INVTYPE_CLOAK"], -- 15
								[_G.INVSLOT_MAINHAND] = L["INVTYPE_WEAPONMAINHAND"], -- 16
								[_G.INVSLOT_OFFHAND] = L["INVTYPE_WEAPONOFFHAND"], -- 17
								[_G.INVSLOT_RANGED] = L["INVTYPE_RANGED"], -- 18
								[_G.INVSLOT_TABARD] = L["INVTYPE_TABARD"], -- 19
							},
						},
					}
				},
				items = {
					name = L["Items"],
					order = 14,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						addItem = {
							order = 1,
							name = L["Add Item Name or ID"],
							desc = L["Add a Item Name or ID to the list."],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.items[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeItem = {
							order = 2,
							name = L["Remove Item Name or ID"],
							desc = L["Remove a Item Name or ID from the list."],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.items[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						negativeMatch = {
							order = 3,
							name = L["Negative Match"],
							desc = L["Match if Item Name or ID is NOT in the list."],
							type = 'toggle',
							get = function(info)
								local triggers = GetFilter(true)
								return triggers[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers[info[#info]] = value
								NP:ConfigureAll()
							end
						}
					}
				},
				role = {
					order = 15,
					type = 'group',
					name = L["ROLE"],
					disabled = DisabledFilter,
					hidden = not E.Retail,
					args = {
						myRole = {
							name = L["Player"],
							type = 'group',
							inline = true,
							order = 2,
							get = function(info)
								local triggers = GetFilter(true)
								return triggers.role[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers.role[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								tank = ACH:Toggle(L["TANK"], nil, 1),
								healer = ACH:Toggle(L["Healer"], nil, 2),
								damager = ACH:Toggle(L["DAMAGER"], nil, 3)
							}
						},
						unitRole = {
							name = L["Unit"],
							type = 'group',
							inline = true,
							order = 2,
							get = function(info)
								local triggers = GetFilter(true)
								return triggers.unitRole[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers.unitRole[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								tank = ACH:Toggle(L["TANK"], nil, 1),
								healer = ACH:Toggle(L["Healer"], nil, 2),
								damager = ACH:Toggle(L["DAMAGER"], nil, 3)
							}
						}
					}
				},
				classification = {
					order = 16,
					type = 'group',
					name = L["Classification"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.classification[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.classification[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								worldboss = ACH:Toggle(L["RAID_INFO_WORLD_BOSS"], nil, 1),
								rareelite = ACH:Toggle(L["Rare Elite"], nil, 2),
								normal = ACH:Toggle(L["PLAYER_DIFFICULTY1"], nil, 3),
								rare = ACH:Toggle(L["ITEM_QUALITY3_DESC"], nil, 4),
								trivial = ACH:Toggle(L["Trivial"], nil, 5),
								elite = ACH:Toggle(L["ELITE"], nil, 6),
								minus = ACH:Toggle(L["Minus"], nil, 7),
							}
						}
					}
				},
				health = {
					order = 17,
					type = 'group',
					name = L["Health Threshold"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						healthThreshold = ACH:Toggle(L["Enable"], nil, 1),
						healthUsePlayer = {
							type = 'toggle',
							order = 2,
							name = L["Player Health"],
							desc = L["Enabling this will check your health amount."],
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.healthThreshold
							end
						},
						underHealthThreshold = {
							order = 4,
							type = 'range',
							name = L["Under Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0,
							max = 1,
							step = 0.01,
							isPercent = true,
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.healthThreshold
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.underHealthThreshold or 0
							end
						},
						overHealthThreshold = {
							order = 5,
							type = 'range',
							name = L["Over Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0,
							max = 1,
							step = 0.01,
							isPercent = true,
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.healthThreshold
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.overHealthThreshold or 0
							end
						}
					}
				},
				power = {
					order = 18,
					type = 'group',
					name = L["Power Threshold"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						powerThreshold = ACH:Toggle(L["Enable"], nil, 1),
						powerUsePlayer = {
							type = 'toggle',
							order = 2,
							name = L["Player Power"],
							desc = L["Enabling this will check your power amount."],
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.powerThreshold
							end
						},
						underPowerThreshold = {
							order = 4,
							type = 'range',
							name = L["Under Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0,
							max = 1,
							step = 0.01,
							isPercent = true,
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.powerThreshold
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.underPowerThreshold or 0
							end
						},
						overPowerThreshold = {
							order = 5,
							type = 'range',
							name = L["Over Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0,
							max = 1,
							step = 0.01,
							isPercent = true,
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.powerThreshold
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.overPowerThreshold or 0
							end
						}
					}
				},
				keyMod = {
					name = L["Key Modifiers"],
					order = 19,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function()
								local triggers = GetFilter(true)
								return triggers.keyMod and triggers.keyMod.enable
							end,
							set = function(_, value)
								local triggers = GetFilter(true)
								triggers.keyMod.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							get = function(info)
								local triggers = GetFilter(true)
								return triggers.keyMod[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers.keyMod[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.keyMod.enable
							end,
							args = {
								Shift = ACH:Toggle(L["SHIFT_KEY_TEXT"], nil, 1),
								Alt = ACH:Toggle(L["ALT_KEY_TEXT"], nil, 2),
								Control = ACH:Toggle(L["CTRL_KEY_TEXT"], nil, 3),
								Modifier = ACH:Toggle(L["Any"], nil, 4),
								LeftShift = ACH:Toggle(L["Left Shift"], nil, 6),
								LeftAlt = ACH:Toggle(L["Left Alt"], nil, 7),
								LeftControl = ACH:Toggle(L["Left Control"], nil, 8),
								RightShift = ACH:Toggle(L["Right Shift"], nil, 10),
								RightAlt = ACH:Toggle(L["Right Alt"], nil, 11),
								RightControl = ACH:Toggle(L["Right Control"], nil, 12)
							}
						}
					}
				},
				levels = {
					order = 20,
					type = 'group',
					name = L["Level"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						level = ACH:Toggle(L["Enable"], nil, 1),
						mylevel = {
							type = 'toggle',
							order = 2,
							name = L["Match Player Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches your own."],
							disabled = function()
								local triggers = GetFilter(true)
								return not triggers.level
							end
						},
						spacer1 = ACH:Description(L["LEVEL_BOSS"], 3),
						minlevel = {
							order = 4,
							type = 'range',
							name = L["Minimum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or higher than this value."],
							min = -1,
							max = _G.MAX_PLAYER_LEVEL + 3,
							step = 1,
							disabled = function()
								local triggers = GetFilter(true)
								return not (triggers.level and not triggers.mylevel)
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.minlevel or 0
							end
						},
						maxlevel = {
							order = 5,
							type = 'range',
							name = L["Maximum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."],
							min = -1,
							max = _G.MAX_PLAYER_LEVEL + 3,
							step = 1,
							disabled = function()
								local triggers = GetFilter(true)
								return not (triggers.level and not triggers.mylevel)
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.maxlevel or 0
							end
						},
						curlevel = {
							name = L["Current Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches this value."],
							order = 6,
							type = 'range',
							min = -1,
							max = _G.MAX_PLAYER_LEVEL + 3,
							step = 1,
							disabled = function()
								local triggers = GetFilter(true)
								return not (triggers.level and not triggers.mylevel)
							end,
							get = function()
								local triggers = GetFilter(true)
								return triggers.curlevel or 0
							end
						}
					}
				},
				cooldowns = {
					name = L["Cooldowns"],
					order = 21,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						addCooldown = {
							order = 1,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.cooldowns.names[value] = 'ONCD'
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeCooldown = {
							order = 2,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = C.Blank,
							set = function(_, value)
								if strmatch(value, '^[%s%p]-$') then return end

								local triggers = GetFilter(true)
								triggers.cooldowns.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						mustHaveAll = {
							order = 3,
							name = L["Require All"],
							desc = L["If enabled then it will require all cooldowns to activate the filter. Otherwise it will only require any one of the cooldowns to activate it."],
							type = 'toggle',
							disabled = DisabledFilter,
							get = function()
								local triggers = GetFilter(true)
								return triggers.cooldowns and triggers.cooldowns.mustHaveAll
							end,
							set = function(_, value)
								local triggers = GetFilter(true)
								triggers.cooldowns.mustHaveAll = value
								NP:ConfigureAll()
							end
						}
					}
				},
				buffs = {
					name = L["Buffs"],
					order = 22,
					type = 'group',
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.buffs and triggers.buffs[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.buffs[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						minTimeLeft = {
							order = 1,
							type = 'range',
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a buff has remaining time greater than this. Set to zero to disable."],
							min = 0,
							max = 10800,
							step = 1
						},
						maxTimeLeft = {
							order = 2,
							type = 'range',
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a buff has remaining time less than this. Set to zero to disable."],
							min = 0,
							max = 10800,
							step = 1
						},
						spacer1 = ACH:Spacer(3, 'full'),
						mustHaveAll = {
							order = 4,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = 'toggle'
						},
						missing = {
							order = 5,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = 'toggle'
						},
						hasStealable = ACH:Toggle(L["Has Stealable"], L["If enabled then the filter will only activate when the unit has a stealable buff(s)."], 6),
						hasNoStealable = ACH:Toggle(L["Has No Stealable"], L["If enabled then the filter will only activate when the unit has no stealable buff(s)."], 7),
						fromMe = ACH:Toggle(L["From Me"], nil, 8),
						fromPet = ACH:Toggle(L["From Pet"], nil, 9),
						changeList = {
							type = 'group',
							inline = true,
							name = L["Add / Remove"],
							order = 10,
							args = {
								addBuff = {
									order = 1,
									name = L["Add Spell ID or Name"],
									type = 'input',
									get = C.Blank,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end
										if stackBuff then value = value .. '\n' .. stackBuff end

										local triggers = GetFilter(true)
										triggers.buffs.names[value] = true
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								removeBuff = {
									order = 2,
									name = L["Remove Spell ID or Name"],
									desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
									type = 'input',
									get = C.Blank,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										if stackBuff then
											triggers.buffs.names[value .. '\n' .. stackBuff] = nil
										else
											for name in pairs(triggers.buffs.names) do
												local spell = strmatch(name, NP.StyleFilterStackPattern)
												if spell == value then
													triggers.buffs.names[name] = nil
												end
											end
										end

										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								stackThreshold = {
									order = 3,
									type = 'range',
									name = L["Stack Threshold"],
									desc = L["Allows you to tie a stack count to an aura when you add it to the list, which allows the trigger to act when an aura reaches X number of stacks."],
									min = 1,
									max = 250,
									softMax = 100,
									step = 1,
									get = function() return stackBuff or 1 end,
									set = function(_, value) stackBuff = (value > 1 and value) or nil end
								},
							}
						}
					}
				},
				debuffs = {
					name = L["Debuffs"],
					order = 23,
					type = 'group',
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.debuffs and triggers.debuffs[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.debuffs[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						minTimeLeft = {
							order = 1,
							type = 'range',
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time greater than this. Set to zero to disable."],
							min = 0,
							max = 10800,
							step = 1
						},
						maxTimeLeft = {
							order = 2,
							type = 'range',
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time less than this. Set to zero to disable."],
							min = 0,
							max = 10800,
							step = 1
						},
						spacer1 = ACH:Spacer(3, 'full'),
						mustHaveAll = {
							order = 4,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = 'toggle'
						},
						missing = {
							order = 5,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = 'toggle',
							disabled = DisabledFilter
						},
						hasDispellable = ACH:Toggle(L["Has Dispellable"], L["If enabled then the filter will only activate when the unit has a dispellable buff(s)."], 6),
						hasNoDispellable = ACH:Toggle(L["Has No Dispellable"], L["If enabled then the filter will only activate when the unit has no dispellable buff(s)."], 7),
						fromMe = ACH:Toggle(L["From Me"], nil, 8),
						fromPet = ACH:Toggle(L["From Pet"], nil, 9),
						changeList = {
							type = 'group',
							inline = true,
							name = L["Add / Remove"],
							order = 10,
							args = {
								addDebuff = {
									order = 6,
									name = L["Add Spell ID or Name"],
									type = 'input',
									get = C.Blank,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end
										if stackDebuff then value = value .. '\n' .. stackDebuff end

										local triggers = GetFilter(true)
										triggers.debuffs.names[value] = true
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								removeDebuff = {
									order = 7,
									name = L["Remove Spell ID or Name"],
									desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
									type = 'input',
									get = C.Blank,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										if stackDebuff then
											triggers.debuffs.names[value .. '\n' .. stackDebuff] = nil
										else
											for name in pairs(triggers.debuffs.names) do
												local spell = strmatch(name, NP.StyleFilterStackPattern)
												if spell == value then
													triggers.debuffs.names[name] = nil
												end
											end
										end

										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								stackThreshold = {
									order = 8,
									type = 'range',
									name = L["Stack Threshold"],
									min = 1,
									max = 250,
									softMax = 100,
									step = 1,
									get = function() return stackDebuff or 1 end,
									set = function(_, value) stackDebuff = (value > 1 and value) or nil end
								},
							}
						}
					}
				},
				bossModAuras = {
					name = L["Boss Mod Auras"],
					order = 24,
					type = 'group',
					get = function(info)
						UpdateBossModAuras() -- this is so we can get the seen textures without full update

						local triggers = GetFilter(true)
						return triggers.bossMods and triggers.bossMods[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.bossMods[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						enable = ACH:Toggle(L["Enable"], nil, 0),
						hasAura = {
							name = L["Has Aura"],
							order = 1,
							type = 'toggle',
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.bossMods.enable
							end
						},
						missingAura = {
							name = L["Missing Aura"],
							order = 2,
							type = 'toggle',
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.bossMods.enable
							end
						},
						seenList = {
							order = 3,
							type = 'group',
							name = L["Seen Textures"],
							inline = true,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or triggers.bossMods.missingAura or triggers.bossMods.hasAura or not triggers.bossMods.enable
							end,
							args = {
								desc = ACH:Description(L["This list will display any textures Boss Mods have sent to the Boss Mod Auras element during the current session."], 0, 'medium')
							},
						},
						changeList = {
							type = 'group',
							inline = true,
							name = L["Texture Matching"],
							order = 5,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or triggers.bossMods.missingAura or triggers.bossMods.hasAura or not triggers.bossMods.enable
							end,
							args = {
								addAura = {
									order = 1,
									name = L["Add Texture"],
									type = 'input',
									get = C.Blank,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										local textureID = tonumber(value) or value
										triggers.bossMods.auras[textureID] = true
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								removeAura = {
									order = 2,
									name = L["Remove Texture"],
									type = 'input',
									get = C.Blank,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										local textureID = tonumber(value) or value
										triggers.bossMods.auras[textureID] = nil
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								missingAuras = {
									order = 3,
									name = L["Missing Auras"],
									type = 'toggle',
									get = function(info)
										local triggers = GetFilter(true)
										return triggers.bossMods[info[#info]]
									end,
									set = function(info, value)
										local triggers = GetFilter(true)
										triggers.bossMods[info[#info]] = value
										NP:ConfigureAll()
									end
								}
							}
						}
					}
				},
				threat = {
					name = L["Threat"],
					order = 25,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function()
								local triggers = GetFilter(true)
								return triggers.threat and triggers.threat.enable
							end,
							set = function(_, value)
								local triggers = GetFilter(true)
								triggers.threat.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							get = function(info)
								local triggers = GetFilter(true)
								return triggers.threat[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers.threat[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.threat.enable
							end,
							args = {
								good = ACH:Toggle(L["Good"], nil, 1),
								goodTransition = ACH:Toggle(L["Good Transition"], nil, 2),
								badTransition = ACH:Toggle(L["Bad Transition"], nil, 3),
								bad = ACH:Toggle(L["Bad"], nil, 4),
								spacer1 = ACH:Spacer(5, 'full'),
								offTank = ACH:Toggle(L["Off Tank"], nil, 6, nil, nil, nil, nil, nil, nil, not E.Retail),
								offTankGoodTransition = {
									name = L["Off Tank Good Transition"],
									customWidth = 200,
									order = 7,
									type = 'toggle',
									hidden = not E.Retail
								},
								offTankBadTransition = {
									name = L["Off Tank Bad Transition"],
									customWidth = 200,
									order = 8,
									type = 'toggle',
									hidden = not E.Retail
								}
							}
						}
					}
				},
				nameplateType = {
					name = L["Unit Type"],
					order = 26,
					type = 'group',
					disabled = DisabledFilter,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function()
								local triggers = GetFilter(true)
								return triggers.nameplateType and triggers.nameplateType.enable
							end,
							set = function(_, value)
								local triggers = GetFilter(true)
								triggers.nameplateType.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							get = function(info)
								local triggers = GetFilter(true)
								return triggers.nameplateType[info[#info]]
							end,
							set = function(info, value)
								local triggers = GetFilter(true)
								triggers.nameplateType[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.nameplateType.enable
							end,
							args = {
								friendlyPlayer = ACH:Toggle(L["FRIENDLY_PLAYER"], nil, 1),
								friendlyNPC = ACH:Toggle(L["FRIENDLY_NPC"], nil, 2),
								enemyPlayer = ACH:Toggle(L["ENEMY_PLAYER"], nil, 3),
								enemyNPC = ACH:Toggle(L["ENEMY_NPC"], nil, 4),
								player = ACH:Toggle(L["Player"], nil, 5)
							}
						}
					}
				},
				reactionType = {
					name = L["Reaction Type"],
					order = 27,
					type = 'group',
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.reactionType and triggers.reactionType[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.reactionType[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						enable = ACH:Toggle(L["Enable"], nil, 0),
						reputation = {
							name = L["Reputation"],
							desc = L["If this is enabled then the reaction check will use your reputation with the faction the unit belongs to."],
							order = 1,
							type = 'toggle',
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.reactionType.enable
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.reactionType.enable
							end,
							args = {
								hated = {
									name = L["FACTION_STANDING_LABEL1"],
									order = 1,
									type = 'toggle',
									disabled = function()
										local triggers = GetFilter(true)
										return DisabledFilter() and triggers.reactionType.enable and triggers.reactionType.reputation
									end
								},
								hostile = ACH:Toggle(L["FACTION_STANDING_LABEL2"], nil, 2),
								unfriendly = {
									name = L["FACTION_STANDING_LABEL3"],
									order = 3,
									type = 'toggle',
									disabled = function()
										local triggers = GetFilter(true)
										return DisabledFilter() and triggers.reactionType.enable and triggers.reactionType.reputation
									end
								},
								neutral = ACH:Toggle(L["FACTION_STANDING_LABEL4"], nil, 4),
								friendly = ACH:Toggle(L["FACTION_STANDING_LABEL5"], nil, 5),
								honored = {
									name = L["FACTION_STANDING_LABEL6"],
									order = 6,
									type = 'toggle',
									disabled = function()
										local triggers = GetFilter(true)
										return DisabledFilter() and triggers.reactionType.enable and triggers.reactionType.reputation
									end
								},
								revered = {
									name = L["FACTION_STANDING_LABEL7"],
									order = 7,
									type = 'toggle',
									disabled = function()
										local triggers = GetFilter(true)
										return DisabledFilter() and triggers.reactionType.enable and triggers.reactionType.reputation
									end
								},
								exalted = {
									name = L["FACTION_STANDING_LABEL8"],
									order = 8,
									type = 'toggle',
									disabled = function()
										local triggers = GetFilter(true)
										return DisabledFilter() and triggers.reactionType.enable and triggers.reactionType.reputation
									end
								}
							}
						}
					}
				},
				creatureType = {
					name = L["Creature Type"],
					order = 28,
					type = 'group',
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.creatureType[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.creatureType[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, 'full'),
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							disabled = function()
								local triggers = GetFilter(true)
								return DisabledFilter() or not triggers.creatureType.enable
							end,
							args = {}
						}
					}
				},
				instanceType = {
					order = 29,
					type = 'group',
					name = L["Instance Type"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.instanceType[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.instanceType[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								none = ACH:Toggle(L["NONE"], nil, 1),
								scenario = ACH:Toggle(L["SCENARIOS"], nil, 2),
								party = {
									type = 'toggle',
									order = 3,
									name = L["DUNGEONS"],
									get = function()
										local triggers = GetFilter(true)
										return triggers.instanceType.party
									end,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.instanceType.party = value
										UpdateInstanceDifficulty()
										NP:ConfigureAll()
									end
								},
								raid = {
									type = 'toggle',
									order = 5,
									name = L["RAID"],
									get = function()
										local triggers = GetFilter(true)
										return triggers.instanceType.raid
									end,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.instanceType.raid = value
										UpdateInstanceDifficulty()
										NP:ConfigureAll()
									end
								},
								arena = ACH:Toggle(L["ARENA"], nil, 7),
								pvp = ACH:Toggle(L["BATTLEFIELDS"], nil, 8)
							}
						}
					}
				},
				location = {
					order = 30,
					type = 'group',
					name = L["Location"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.location[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.location[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								mapIDEnabled = {
									type = 'toggle',
									order = 1,
									name = L["Use Map ID or Name"],
									desc = L["If enabled, the style filter will only activate when you are in one of the maps specified in Map ID."],
									customWidth = 200,
								},
								mapIDs = {
									type = 'input',
									order = 2,
									name = L["Add Map ID"],
									get = E.noop,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										if triggers.location.mapIDs[value] then return end
										triggers.location.mapIDs[value] = true
										NP:ConfigureAll()
									end,
									disabled = function ()
										local triggers = GetFilter(true)
										return not triggers.location.mapIDEnabled
									end
								},
								removeMapID = {
									type = 'select',
									order = 3,
									name = L["Remove Map ID"],
									get = E.noop,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.location.mapIDs[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local triggers = GetFilter(true)
										local ids = triggers.location.mapIDs
										if not (ids and next(ids)) then return vals end

										for value in pairs(ids) do
											local info = tonumber(value) and C_Map_GetMapInfo(value)
											if info and info.name then
												info = '|cFF999999('..value..')|r '..info.name
											end
											vals[value] = info or value
										end
										return vals
									end,
									disabled = function()
										local triggers = GetFilter(true)
										local ids = triggers.location.mapIDs
										return not (triggers.location.mapIDEnabled and ids and next(ids))
									end
								},
								instanceIDEnabled = {
									type = 'toggle',
									order = 4,
									name = L["Use Instance ID or Name"],
									desc = L["If enabled, the style filter will only activate when you are in one of the instances specified in Instance ID."],
									customWidth = 200,
								},
								instanceIDs = {
									type = 'input',
									order = 5,
									name = L["Add Instance ID"],
									get = E.noop,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										if triggers.location.instanceIDs[value] then return end
										triggers.location.instanceIDs[value] = true
										NP:ConfigureAll()
									end,
									disabled = function ()
										local triggers = GetFilter(true)
										return not triggers.location.instanceIDEnabled
									end
								},
								removeInstanceID = {
									type = 'select',
									order = 6,
									name = L["Remove Instance ID"],
									get = E.noop,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.location.instanceIDs[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local triggers = GetFilter(true)
										local ids = triggers.location.instanceIDs
										if not (ids and next(ids)) then return vals end

										for value in pairs(ids) do
											local name = tonumber(value) and GetRealZoneText(value)
											if name then
												name = '|cFF999999('..value..')|r '..name
											end
											vals[value] = name or value
										end
										return vals
									end,
									disabled = function()
										local triggers = GetFilter(true)
										local ids = triggers.location.instanceIDs
										return not (triggers.location.instanceIDEnabled and ids and next(ids))
									end
								},
								zoneNamesEnabled = {
									type = 'toggle',
									order = 7,
									name = L["Use Zone Names"],
									desc = L["If enabled, the style filter will only activate when you are in one of the zones specified in Add Zone Name."],
									customWidth = 200,
								},
								zoneNames = {
									type = 'input',
									order = 8,
									name = L["Add Zone Name"],
									get = E.noop,
									set = function(_, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local triggers = GetFilter(true)
										if triggers.location.zoneNames[value] then return end
										triggers.location.zoneNames[value] = true
										NP:ConfigureAll()
									end,
									disabled = function ()
										local triggers = GetFilter(true)
										return not triggers.location.zoneNamesEnabled
									end
								},
								removeZoneName = {
									type = 'select',
									order = 9,
									name = L["Remove Zone Name"],
									get = E.noop,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.location.zoneNames[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local triggers = GetFilter(true)
										local zone = triggers.location.zoneNames
										if not (zone and next(zone)) then return vals end

										for value in pairs(zone) do vals[value] = value end
										return vals
									end,
									disabled = function()
										local triggers = GetFilter(true)
										local zone = triggers.location.zoneNames
										return not (triggers.location.zoneNamesEnabled and zone and next(zone))
									end
								},
								subZoneNamesEnabled = {
									type = 'toggle',
									order = 10,
									name = L["Use Subzone Names"],
									desc = L["If enabled, the style filter will only activate when you are in one of the subzones specified in Add Subzone Name."],
									customWidth = 200,
								},
								subZoneNames = {
									type = 'input',
									order = 11,
									name = L["Add Subzone Name"],
									get = E.noop,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.location.subZoneNames[value] = true
										NP:ConfigureAll()
									end,
									disabled = function ()
										local triggers = GetFilter(true)
										return not triggers.location.subZoneNamesEnabled
									end
								},
								removeSubZoneName = {
									type = 'select',
									order = 12,
									name = L["Remove Subzone Name"],
									get = E.noop,
									set = function(_, value)
										local triggers = GetFilter(true)
										triggers.location.subZoneNames[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local triggers = GetFilter(true)
										local zone = triggers.location.subZoneNames
										if not (zone and next(zone)) then return vals end

										for value in pairs(zone) do vals[value] = value end
										return vals
									end,
									disabled = function()
										local triggers = GetFilter(true)
										local zone = triggers.location.subZoneNames
										return not (triggers.location.subZoneNamesEnabled and zone and next(zone))
									end
								}
							}
						},
						btns = {
							type = 'group',
							inline = true,
							name = L["Add Current"],
							order = 2,
							args = {
								mapID = {
									order = 3,
									type = 'execute',
									name = L["Map ID"],
									func = function()
										local mapID = E.MapInfo.mapID
										if not mapID then return end
										mapID = tostring(mapID)

										local triggers = GetFilter(true)
										if triggers.location.mapIDs[mapID] then return end
										triggers.location.mapIDs[mapID] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Map ID: %s"], E.MapInfo.name..' ('..mapID..')'))
									end
								},
								instanceID = {
									order = 4,
									type = 'execute',
									name = L["Instance ID"],
									func = function()
										local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo()
										if not instanceID then return end
										instanceID = tostring(instanceID)

										local triggers = GetFilter(true)
										if triggers.location.instanceIDs[instanceID] then return end
										triggers.location.instanceIDs[instanceID] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Instance ID: %s"], instanceName..' ('..instanceID..')'))
									end
								},
								zoneName = {
									order = 6,
									type = 'execute',
									name = L["Zone Name"],
									func = function()
										local zone = E.MapInfo.realZoneText
										if not zone then return end

										local triggers = GetFilter(true)
										if triggers.location.zoneNames[zone] then return end
										triggers.location.zoneNames[zone] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Zone Name: %s"], zone))
									end
								},
								subZoneName = {
									order = 7,
									type = 'execute',
									name = L["Subzone Name"],
									func = function()
										local subZone = E.MapInfo.subZoneText
										if not subZone then return end

										local triggers = GetFilter(true)
										if triggers.location.subZoneNames[subZone] then return end
										triggers.location.subZoneNames[subZone] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Subzone Name: %s"], subZone))
									end
								},
							}
						}
					}
				},
				raidTarget = {
					order = 31,
					type = 'group',
					name = L["BINDING_HEADER_RAID_TARGET"],
					get = function(info)
						local triggers = GetFilter(true)
						return triggers.raidTarget[info[#info]]
					end,
					set = function(info, value)
						local triggers = GetFilter(true)
						triggers.raidTarget[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = DisabledFilter,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								star = ACH:Toggle(format(raidTargetIcon, 1, L["RAID_TARGET_1"]), nil, 1),
								circle = ACH:Toggle(format(raidTargetIcon, 2, L["RAID_TARGET_2"]), nil, 2),
								diamond = ACH:Toggle(format(raidTargetIcon, 3, L["RAID_TARGET_3"]), nil, 3),
								triangle = ACH:Toggle(format(raidTargetIcon, 4, L["RAID_TARGET_4"]), nil, 4),
								moon = ACH:Toggle(format(raidTargetIcon, 5, L["RAID_TARGET_5"]), nil, 5),
								square = ACH:Toggle(format(raidTargetIcon, 6, L["RAID_TARGET_6"]), nil, 6),
								cross = ACH:Toggle(format(raidTargetIcon, 7, L["RAID_TARGET_7"]), nil, 7),
								skull = ACH:Toggle(format(raidTargetIcon, 8, L["RAID_TARGET_8"]), nil, 8)
							}
						}
					}
				}
			}
		}

		if NP.StyleFilterCustomChecks then
			E.Options.args.nameplate.args.filters.args.triggers.args.pluginSpacer = ACH:Spacer(49, 'full')
		end

		E.Options.args.nameplate.args.filters.args.actions = {
			type = 'group',
			name = L["Actions"],
			order = 6,
			get = function(info)
				local _, actions = GetFilter(true)
				return actions[info[#info]]
			end,
			set = function(info, value)
				local _, actions = GetFilter(true)
				actions[info[#info]] = value
				NP:ConfigureAll()
			end,
			disabled = DisabledFilter,
			args = {
				hide = ACH:Toggle(L["Hide Frame"], nil, 1),
				usePortrait = {
					order = 2,
					type = 'toggle',
					name = L["Use Portrait"],
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end
				},
				nameOnly = {
					name = L["Name Only"],
					order = 3,
					type = 'toggle',
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end
				},
				spacer1 = ACH:Spacer(4, 'full'),
				scale = {
					order = 5,
					type = 'range',
					name = L["Scale"],
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end,
					get = function()
						local _, actions = GetFilter(true)
						return actions.scale or 1
					end,
					min = 0.5,
					max = 1.5,
					softMin = .75,
					softMax = 1.25,
					step = 0.01
				},
				alpha = {
					order = 6,
					type = 'range',
					name = L["Alpha"],
					desc = L["Change the alpha level of the frame."],
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end,
					get = function()
						local _, actions = GetFilter(true)
						return actions.alpha or -1
					end,
					min = -1,
					max = 100,
					step = 1
				},
				color = {
					order = 10,
					type = 'group',
					name = L["COLOR"],
					get = function(info)
						local _, actions = GetFilter(true)
						return actions.color[info[#info]]
					end,
					set = function(info, value)
						local _, actions = GetFilter(true)
						actions.color[info[#info]] = value
						NP:ConfigureAll()
					end,
					inline = true,
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end,
					args = {
						health = ACH:Toggle(L["Health"], nil, 1),
						healthColor = {
							name = L["Health Color"],
							type = 'color',
							order = 2,
							hasAlpha = true,
							disabled = function()
								local _, actions = GetFilter(true)
								return not actions.color.health
							end,
							get = function()
								local _, actions = GetFilter(true)
								local t = actions.color.healthColor
								return t.r, t.g, t.b, t.a, 136 / 255, 255 / 255, 102 / 255, 1
							end,
							set = function(_, r, g, b, a)
								local _, actions = GetFilter(true)
								local t = actions.color.healthColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						healthClass = ACH:Toggle(L["Unit Class Color"], nil, 3),
						spacer1 = ACH:Spacer(4, 'full'),
						power = ACH:Toggle(L["Power"], nil, 10),
						powerColor = {
							name = L["Power Color"],
							type = 'color',
							order = 11,
							hasAlpha = true,
							disabled = function()
								local _, actions = GetFilter(true)
								return not actions.color.power
							end,
							get = function()
								local _, actions = GetFilter(true)
								local t = actions.color.powerColor
								return t.r, t.g, t.b, t.a, 102 / 255, 136 / 255, 255 / 255, 1
							end,
							set = function(_, r, g, b, a)
								local _, actions = GetFilter(true)
								local t = actions.color.powerColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						powerClass = ACH:Toggle(L["Unit Class Color"], nil, 12),
						spacer2 = ACH:Spacer(13, 'full'),
						border = ACH:Toggle(L["Border"], nil, 20),
						borderColor = {
							name = L["Border Color"],
							type = 'color',
							order = 21,
							hasAlpha = true,
							disabled = function()
								local _, actions = GetFilter(true)
								return not actions.color.border
							end,
							get = function()
								local _, actions = GetFilter(true)
								local t = actions.color.borderColor
								return t.r, t.g, t.b, t.a, 0, 0, 0, 1
							end,
							set = function(_, r, g, b, a)
								local _, actions = GetFilter(true)
								local t = actions.color.borderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						borderClass = ACH:Toggle(L["Unit Class Color"], nil, 22)
					}
				},
				texture = {
					order = 20,
					type = 'group',
					name = L["Texture"],
					get = function(info)
						local _, actions = GetFilter(true)
						return actions.texture[info[#info]]
					end,
					set = function(info, value)
						local _, actions = GetFilter(true)
						actions.texture[info[#info]] = value
						NP:ConfigureAll()
					end,
					inline = true,
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end,
					args = {
						enable = ACH:Toggle(L["Enable"], nil, 1),
						texture = {
							order = 2,
							type = 'select',
							dialogControl = 'LSM30_Statusbar',
							name = L["Texture"],
							values = _G.AceGUIWidgetLSMlists.statusbar,
							disabled = function()
								local _, actions = GetFilter(true)
								return not actions.texture.enable
							end
						}
					}
				},
				flashing = {
					order = 30,
					type = 'group',
					name = L["Flash"],
					inline = true,
					disabled = function()
						local _, actions = GetFilter(true)
						return actions.hide
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 1,
							type = 'toggle',
							get = function()
								local _, actions = GetFilter(true)
								return actions.flash.enable
							end,
							set = function(_, value)
								local _, actions = GetFilter(true)
								actions.flash.enable = value
								NP:ConfigureAll()
							end
						},
						color = {
							name = L["COLOR"],
							type = 'color',
							order = 2,
							hasAlpha = true,
							disabled = function()
								local _, actions = GetFilter(true)
								return actions.hide
							end,
							get = function()
								local _, actions = GetFilter(true)
								local t = actions.flash.color
								return t.r, t.g, t.b, t.a, 104 / 255, 138 / 255, 217 / 255, 1
							end,
							set = function(_, r, g, b, a)
								local _, actions = GetFilter(true)
								local t = actions.flash.color
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						flashClass = {
							type = 'toggle',
							order = 3,
							name = L["Unit Class Color"],
							get = function()
								local _, actions = GetFilter(true)
								return actions.flash.class
							end,
							set = function(_, value)
								local _, actions = GetFilter(true)
								actions.flash.class = value
								NP:ConfigureAll()
							end
						},
						speed = {
							order = 4,
							type = 'range',
							name = L["SPEED"],
							disabled = function()
								local _, actions = GetFilter(true)
								return actions.hide
							end,
							get = function()
								local _, actions = GetFilter(true)
								return actions.flash.speed or 4
							end,
							set = function(_, value)
								local _, actions = GetFilter(true)
								actions.flash.speed = value
								NP:ConfigureAll()
							end,
							min = 1,
							max = 10,
							step = 1
						}
					}
				},
				text_format = {
					order = 40,
					type = 'group',
					inline = true,
					name = L["Text Format"],
					get = function(info)
						local _, actions = GetFilter(true)
						return actions.tags[info[#info]]
					end,
					set = function(info, value)
						local _, actions = GetFilter(true)
						actions.tags[info[#info]] = value
						NP:ConfigureAll()
					end,
					args = {
						name = {
							order = 1,
							name = L["Name"],
							desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
							type = 'input',
							width = 'full',
						},
						level = {
							order = 2,
							name = L["Level"],
							desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
							type = 'input',
							width = 'full',
						},
						title = {
							order = 3,
							name = L["Title"],
							desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
							type = 'input',
							width = 'full',
						},
						health = {
							order = 4,
							name = L["Health"],
							desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
							type = 'input',
							width = 'full',
						},
						power = {
							order = 5,
							name = L["Power"],
							desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
							type = 'input',
							width = 'full',
						},
					}
				}
			}
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
					disabled = function()
						local triggers = GetFilter(true)
						return DisabledFilter() or not triggers.creatureType.enable
					end
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

E.Options.args.nameplate.args.filters = {
	type = 'group',
	order = 10,
	name = L["Style Filter"],
	childGroups = 'tab',
	disabled = function() return not E.NamePlates.Initialized end,
	args = {
		addFilter = {
			order = 1,
			name = L["Create Filter"],
			type = 'input',
			get = C.Blank,
			set = function(_, value)
				if strmatch(value, '^[%s%p]-$') then return end

				if E.global.nameplate.filters[value] then
					E:Print(L["Filter already exists!"])
					return
				end

				local filter = {}
				NP:StyleFilterCopyDefaults(filter)
				E.global.nameplate.filters[value] = filter
				C.SelectedNameplateStyleFilter = value
				UpdateFilterGroup()
				NP:ConfigureAll()
			end
		},
		selectFilter = {
			name = L["Select Filter"],
			type = 'select',
			order = 2,
			sortByValue = true,
			get = function() return C.SelectedNameplateStyleFilter end,
			set = function(_, value) C.SelectedNameplateStyleFilter = value UpdateFilterGroup() end,
			values = function()
				wipe(filters)
				local list = E.global.nameplate.filters
				if not (list and next(list)) then return filters end

				local profile, priority, name = E.db.nameplates.filters
				for filter, content in pairs(list) do
					priority = (content.triggers and content.triggers.priority) or '?'
					name = (content.triggers and profile[filter] and profile[filter].triggers and profile[filter].triggers.enable and filter) or (content.triggers and format('|cFF666666%s|r', filter)) or filter
					filters[filter] = format('|cFFffff00(%s)|r %s', priority, name)
				end
				return filters
			end
		},
		removeFilter = {
			order = 3,
			name = L["Delete Filter"],
			desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
			type = 'execute',
			confirm = true,
			confirmText = L["Delete Filter"],
			func = function()
				for profile in pairs(E.data.profiles) do
					if E.data.profiles[profile].nameplates and E.data.profiles[profile].nameplates.filters
					and E.data.profiles[profile].nameplates.filters[C.SelectedNameplateStyleFilter] then
						E.data.profiles[profile].nameplates.filters[C.SelectedNameplateStyleFilter] = nil
					end
				end

				E.global.nameplate.filters[C.SelectedNameplateStyleFilter] = nil
				C.SelectedNameplateStyleFilter = nil

				UpdateFilterGroup()
				NP:ConfigureAll()
			end,
			disabled = function()
				return G.nameplate.filters[C.SelectedNameplateStyleFilter]
			end,
			hidden = function()
				return C.SelectedNameplateStyleFilter == nil
			end
		}
	}
}
