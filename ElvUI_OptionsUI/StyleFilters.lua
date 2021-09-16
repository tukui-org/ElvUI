local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(E.OptionsUI)
local NP = E:GetModule('NamePlates')
local ACD = E.Libs.AceConfigDialog
local ACH = E.Libs.ACH

local tostring = tostring
local wipe = wipe
local pairs, strmatch = pairs, strmatch
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

local raidTargetIcon = [[|TInterface\TargetingFrame\UI-RaidTargetingIcon_%s:0|t %s]]
local selectedNameplateFilter

local filters = {}

local specListOrder = 50 -- start at 50
local classTable, classIndexTable, classOrder
local function UpdateClassSpec(classTag, enabled)
	if not (classTable[classTag] and classTable[classTag].classID) then
		return
	end
	local classSpec = format('%s%s', classTag, 'spec')
	if (enabled == false) then
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
			group.args[tagID] = ACH:Toggle(format('|c%s%s|r', coloredName, name), nil, i, nil, nil, nil, function() local tagTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag] return tagTrigger and tagTrigger.specs and tagTrigger.specs[specID] end, function(_, value) local tagTrigger = E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag] if not tagTrigger.specs then E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs = {} end E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs[specID] = value or nil if not next(E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs) then E.global.nameplate.filters[selectedNameplateFilter].triggers.class[classTag].specs = nil end NP:ConfigureAll() end)
		end
	end

	E.Options.args.nameplate.args.filters.args.triggers.args.class.args[classSpec] = group
end

local function UpdateClassSection()
	if E.global.nameplate.filters[selectedNameplateFilter] then
		if not classTable then
			local classDisplayName, classTag, classID
			classTable, classIndexTable = {}, {}
			for i = 1, GetNumClasses() do
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
		local coloredName
		for _, classTag in ipairs(classIndexTable) do
			classOrder = classOrder + 1
			coloredName = E:ClassColor(classTag)
			coloredName = (coloredName and coloredName.colorStr) or 'ff666666'
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
				name = format('|c%s%s|r', coloredName, classTable[classTag].name),
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
	local _, name, texture = GetTalentInfo(tier, column, 1)
	return formatStr:format(texture, name)
end

local function GetPvpTalentString(talentID)
	local _, name, texture = GetPvpTalentInfoByID(talentID)
	return formatStr:format(texture, name)
end

local function GenerateValues(tier, isPvP)
	local values = {}

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
			values[i] = GetTalentString(tier, i)
		end
	end

	return values
end

local function UpdateTalentSection()
	if E.global.nameplate.filters[selectedNameplateFilter] then
		local maxTiers = (E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == 'normal' and 7) or 4
		E.Options.args.nameplate.args.filters.args.triggers.args.talent.args = {
			enabled = {
				type = 'toggle',
				order = 1,
				name = L["Enable"],
				get = function(info)
					return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled
				end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled = value
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			},
			type = {
				type = 'toggle',
				order = 2,
				name = L["Is PvP Talents"],
				disabled = function()
					return not E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled
				end,
				get = function(info)
					return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == 'pvp'
				end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type = value and 'pvp' or 'normal'
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			},
			requireAll = {
				type = 'toggle',
				order = 3,
				name = L["Require All"],
				disabled = function()
					return not E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled
				end,
				get = function(info)
					return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.requireAll
				end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.requireAll = value
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
					return not E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.enabled
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
				get = function(info)
					return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i .. 'enabled']
				end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i .. 'enabled'] = value
					UpdateTalentSection()
					NP:ConfigureAll()
				end
			}
			order = order + 1
			if (E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i .. 'enabled']) then
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
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i].missing
							end,
							set = function(_, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i].missing = value
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
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i].column
							end,
							set = function(_, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.talent['tier' .. i].column = value
								NP:ConfigureAll()
							end,
							values = function()
								return GenerateValues(i, E.global.nameplate.filters[selectedNameplateFilter].triggers.talent.type == 'pvp')
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
	if (E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party) then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.dungeonDifficulty = {
			type = 'multiselect',
			name = L["DUNGEON_DIFFICULTY"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			order = 10,
			get = function(_, key)
				return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[key]
			end,
			set = function(_, key, value)
				E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[key] = value
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

	if (E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid) then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.types.args.raidDifficulty = {
			type = 'multiselect',
			name = L["Raid Difficulty"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			order = 11,
			get = function(_, key)
				return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[key]
			end,
			set = function(_, key, value)
				E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[key] = value
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
	for _, which in next, {'names', 'items'} do
		if E.global.nameplate.filters[selectedNameplateFilter]
		and E.global.nameplate.filters[selectedNameplateFilter].triggers
		and E.global.nameplate.filters[selectedNameplateFilter].triggers[which] then
			E.Options.args.nameplate.args.filters.args.triggers.args[which].args.list = {
				order = 50,
				type = 'group',
				name = '',
				inline = true,
				args = {}
			}

			if next(E.global.nameplate.filters[selectedNameplateFilter].triggers[which]) then
				for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers[which]) do
					E.Options.args.nameplate.args.filters.args.triggers.args[which].args.list.args[name] = {
						name = name,
						type = 'toggle',
						order = -1,
						get = function(info)
							return E.global.nameplate.filters[selectedNameplateFilter].triggers and
								E.global.nameplate.filters[selectedNameplateFilter].triggers[which] and
								E.global.nameplate.filters[selectedNameplateFilter].triggers[which][name]
						end,
						set = function(info, value)
							E.global.nameplate.filters[selectedNameplateFilter].triggers[which][name] = value
							NP:ConfigureAll()
						end
					}
				end
			end
		end
	end

	if E.global.nameplate.filters[selectedNameplateFilter]
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.casting
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells then
		E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells) then
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells) do
				local spell, spellID = name, tonumber(name)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					local notDisabled =
						(E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
						E.db.nameplates.filters[selectedNameplateFilter].triggers and
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r', spellName, spellID)
						else
							spell = format('%s (%d)', spellName, spellID)
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
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplate.filters[selectedNameplateFilter]
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names) then
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names) do
				local spell, spellID = name, tonumber(name)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					local notDisabled =
						(E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
						E.db.nameplates.filters[selectedNameplateFilter].triggers and
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r', spellName, spellID)
						else
							spell = format('%s (%d)', spellName, spellID)
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
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplate.filters[selectedNameplateFilter]
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) then
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) do
				local spell, stacks = strmatch(name, NP.StyleFilterStackPattern)
				local spellID = tonumber(spell)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					local notDisabled =
						(E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
						E.db.nameplates.filters[selectedNameplateFilter].triggers and
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r|cFF999999%s|r', spellName, spellID, (stacks ~= '' and ' x'..stacks) or '')
						else
							spell = format('%s (%d)', spellName, spellID)
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
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplate.filters[selectedNameplateFilter]
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {}
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) then
			for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) do
				local spell, stacks = strmatch(name, NP.StyleFilterStackPattern)
				local spellID = tonumber(spell)
				if spellID then
					local spellName = GetSpellInfo(spellID)
					local notDisabled =
						(E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
						E.db.nameplates.filters[selectedNameplateFilter].triggers and
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format('|cFFffff00%s|r |cFFffffff(%d)|r|cFF999999%s|r', spellName, spellID, (stacks ~= '' and ' x'..stacks) or '')
						else
							spell = format('%s (%d)', spellName, spellID)
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
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplate.filters[selectedNameplateFilter]
	and E.global.nameplate.filters[selectedNameplateFilter].triggers
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods then
		E.Options.args.nameplate.args.filters.args.triggers.args.bossModAuras.args.auras = {
			order = 50,
			type = 'group',
			name = '',
			inline = true,
			args = {},
			disabled = function()
				return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
					E.db.nameplates.filters[selectedNameplateFilter].triggers and
					E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
					E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.missingAura or
					E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.hasAura or
					not E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.enable
			end
		}
		if next(E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras) then
			for aura in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras) do
				E.Options.args.nameplate.args.filters.args.triggers.args.bossModAuras.args.auras.args[aura] = {
					name = aura,
					desc = E:TextureString(aura, ':32:32:0:0:32:32:4:28:4:28'),
					type = 'toggle',
					order = -1,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras[aura]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras[aura] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end
end

local UpdateFilterGroup -- set below but we need this in UpdateBossModAuras
local function UpdateBossModAuras()
	if E.global.nameplate.filters[selectedNameplateFilter]
	and E.global.nameplate.filters[selectedNameplateFilter].triggers
	and E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods
	and next(NP.BossMods_TextureCache) then
		for texture in pairs(NP.BossMods_TextureCache) do
			E.Options.args.nameplate.args.filters.args.triggers.args.bossModAuras.args.seenList.args[texture] = {
				name = texture,
				desc = E:TextureString(texture, ':32:32:0:0:32:32:4:28:4:28'),
				type = 'toggle',
				order = -1,
				get = function(info)
					return E.global.nameplate.filters[selectedNameplateFilter].triggers and
						E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods and
						E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras and
						E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras[texture]
				end,
				set = function(info, value)
					E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras[texture] = value
					UpdateFilterGroup()
					NP:ConfigureAll()
				end
			}
		end
	end
end

function UpdateFilterGroup()
	local stackBuff, stackDebuff
	if not selectedNameplateFilter or not E.global.nameplate.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = nil
		E.Options.args.nameplate.args.filters.args.actions = nil
		E.Options.args.nameplate.args.filters.args.triggers = nil
	end
	if selectedNameplateFilter and E.global.nameplate.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.triggers = {
			type = 'group',
			name = L["Triggers"],
			order = 5,
			args = {
				enable = {
					name = L["Enable"],
					order = 0,
					type = 'toggle',
					get = function(info)
						return (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					set = function(info, value)
						if not E.db.nameplates then
							E.db.nameplates = {}
						end
						if not E.db.nameplates.filters then
							E.db.nameplates.filters = {}
						end
						if not E.db.nameplates.filters[selectedNameplateFilter] then
							E.db.nameplates.filters[selectedNameplateFilter] = {}
						end
						if not E.db.nameplates.filters[selectedNameplateFilter].triggers then
							E.db.nameplates.filters[selectedNameplateFilter].triggers = {}
						end
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable = value
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
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.priority or 1
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.priority = value
						NP:ConfigureAll()
					end
				},
				resetFilter = {
					order = 2,
					name = L["Clear Filter"],
					desc = L["Return filter to its default state."],
					type = 'execute',
					func = function()
						local filter = {}
						if G.nameplate.filters[selectedNameplateFilter] then
							filter = E:CopyTable(filter, G.nameplate.filters[selectedNameplateFilter])
						end
						NP:StyleFilterCopyDefaults(filter)
						E.global.nameplate.filters[selectedNameplateFilter] = filter
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
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						addName = {
							order = 1,
							name = L["Add Name or NPC ID"],
							desc = L["Add a Name or NPC ID to the list."],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeName = {
							order = 2,
							name = L["Remove Name or NPC ID"],
							desc = L["Remove a Name or NPC ID from the list."],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.names[value] = nil
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
								return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
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
						return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								isTarget = {
									name = L["Is Targeted"],
									desc = L["If enabled then the filter will only activate when you are targeting the unit."],
									order = 1,
									type = 'toggle'
								},
								notTarget = {
									name = L["Not Targeted"],
									desc = L["If enabled then the filter will only activate when you are not targeting the unit."],
									order = 2,
									type = 'toggle'
								},
								requireTarget = {
									name = L["Require Target"],
									desc = L["If enabled then the filter will only activate when you have a target."],
									order = 2,
									type = 'toggle'
								},
								targetMe = {
									name = L["Is Targeting Player"],
									desc = L["If enabled then the filter will only activate when the unit is targeting you."],
									order = 4,
									type = 'toggle'
								},
								notTargetMe = {
									name = L["Not Targeting Player"],
									desc = L["If enabled then the filter will only activate when the unit is not targeting you."],
									order = 5,
									type = 'toggle'
								},
								isFocus = {
									name = L["Is Focused"],
									desc = L["If enabled then the filter will only activate when you are focusing the unit."],
									order = 7,
									type = 'toggle'
								},
								notFocus = {
									name = L["Not Focused"],
									desc = L["If enabled then the filter will only activate when you are not focusing the unit."],
									order = 8,
									type = 'toggle'
								}
							}
						}
					}
				},
				casting = {
					order = 8,
					type = 'group',
					name = L["Casting"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.casting[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.casting[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							args = {
								interruptible = {
									type = 'toggle',
									order = 1,
									name = L["Interruptible"],
									desc = L["If enabled then the filter will only activate if the unit is casting interruptible spells."]
								},
								notInterruptible = {
									type = 'toggle',
									order = 2,
									name = L["Non-Interruptible"],
									desc = L["If enabled then the filter will only activate if the unit is casting not interruptible spells."]
								},
								spacer1 = ACH:Spacer(3, 'full'),
								isCasting = {
									type = 'toggle',
									order = 4,
									name = L["Is Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is casting anything."]
								},
								notCasting = {
									type = 'toggle',
									order = 5,
									name = L["Not Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is not casting anything."]
								},
								spacer2 = ACH:Spacer(6, 'full'),
								isChanneling = {
									type = 'toggle',
									order = 7,
									name = L["Is Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is channeling anything."]
								},
								notChanneling = {
									type = 'toggle',
									order = 8,
									name = L["Not Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is not channeling anything."]
								},
							}
						},
						addSpell = {
							order = 2,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeSpell = {
							order = 3,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.casting.spells[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						notSpell = {
							type = 'toggle',
							order = 4,
							name = L["Not Spell"],
							desc = L["If enabled then the filter will only activate if the unit is not casting or channeling one of the selected spells."]
						},
						description1 = ACH:Description(L["You do not need to use Is Casting Anything or Is Channeling Anything for these spells to trigger."], 10),
						description2 = ACH:Description(L["If this list is empty, and if Interruptible is checked, then the filter will activate on any type of cast that can be interrupted."], 11),
					}
				},
				combat = {
					order = 9,
					type = 'group',
					name = L["Unit Conditions"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						playerGroup = {
							name = L["Player"],
							type = 'group',
							inline = true,
							order = 1,
							args = {
								inCombat = {
									type = 'toggle',
									name = L["In Combat"],
									desc = L["If enabled then the filter will only activate when you are in combat."],
									order = 1
								},
								outOfCombat = {
									type = 'toggle',
									name = L["Out of Combat"],
									desc = L["If enabled then the filter will only activate when you are out of combat."],
									order = 2
								},
								inVehicle = {
									type = 'toggle',
									name = L["In Vehicle"],
									desc = L["If enabled then the filter will only activate when you are in a Vehicle."],
									order = 3
								},
								outOfVehicle = {
									type = 'toggle',
									name = L["Out of Vehicle"],
									desc = L["If enabled then the filter will only activate when you are not in a Vehicle."],
									order = 4
								},
								isResting = {
									type = 'toggle',
									name = L["Is Resting"],
									desc = L["If enabled then the filter will only activate when you are resting at an Inn."],
									order = 5
								},
								playerCanAttack = {
									type = 'toggle',
									name = L["Can Attack"],
									desc = L["If enabled then the filter will only activate when the unit can be attacked by the active player."],
									order = 6
								},
								playerCanNotAttack = {
									type = 'toggle',
									name = L["Can Not Attack"],
									desc = L["If enabled then the filter will only activate when the unit can not be attacked by the active player."],
									order = 7
								}
							}
						},
						unitGroup = {
							name = L["Unit"],
							type = 'group',
							inline = true,
							order = 2,
							args = {
								inCombatUnit = {
									type = 'toggle',
									name = L["In Combat"],
									desc = L["If enabled then the filter will only activate when the unit is in combat."],
									order = 1
								},
								outOfCombatUnit = {
									type = 'toggle',
									name = L["Out of Combat"],
									desc = L["If enabled then the filter will only activate when the unit is out of combat."],
									order = 2
								},
								inVehicleUnit = {
									type = 'toggle',
									name = L["In Vehicle"],
									desc = L["If enabled then the filter will only activate when the unit is in a Vehicle."],
									order = 3
								},
								outOfVehicleUnit = {
									type = 'toggle',
									name = L["Out of Vehicle"],
									desc = L["If enabled then the filter will only activate when the unit is not in a Vehicle."],
									order = 4
								},
								inParty = {
									type = 'toggle',
									name = L["In Party"],
									desc = L["If enabled then the filter will only activate when the unit is in your Party."],
									order = 5
								},
								notInParty = {
									type = 'toggle',
									name = L["Not in Party"],
									desc = L["If enabled then the filter will only activate when the unit is not in your Party."],
									order = 6
								},
								inRaid = {
									type = 'toggle',
									name = L["In Raid"],
									desc = L["If enabled then the filter will only activate when the unit is in your Raid."],
									order = 7
								},
								notInRaid = {
									type = 'toggle',
									name = L["Not in Raid"],
									desc = L["If enabled then the filter will only activate when the unit is not in your Raid."],
									order = 8
								},
								isPet = {
									type = 'toggle',
									name = L["Is Pet"],
									desc = L["If enabled then the filter will only activate when the unit is the active player's pet."],
									order = 9
								},
								isNotPet= {
									type = 'toggle',
									name =L["Not Pet"],
									desc = L["If enabled then the filter will only activate when the unit is not the active player's pet."],
									order = 10
								},
								isPlayerControlled = {
									type = 'toggle',
									name = L["Player Controlled"],
									desc = L["If enabled then the filter will only activate when the unit is controlled by the player."],
									order = 11
								},
								isNotPlayerControlled = {
									type = 'toggle',
									name = L["Not Player Controlled"],
									desc = L["If enabled then the filter will only activate when the unit is not controlled by the player."],
									order = 12
								},
								isOwnedByPlayer = {
									type = 'toggle',
									name = L["Owned By Player"],
									desc = L["If enabled then the filter will only activate when the unit is owned by the player."],
									order = 13
								},
								isNotOwnedByPlayer = {
									type = 'toggle',
									name = L["Not Owned By Player"],
									desc = L["If enabled then the filter will only activate when the unit is not owned by the player."],
									order = 14
								},
								isPvP = {
									type = 'toggle',
									name = L["Is PvP"],
									desc = L["If enabled then the filter will only activate when the unit is pvp-flagged."],
									order = 15
								},
								isNotPvP = {
									type = 'toggle',
									name = L["Not PvP"],
									desc = L["If enabled then the filter will only activate when the unit is not pvp-flagged."],
									order = 16
								},
								isTapDenied = {
									type = 'toggle',
									name = L["Tap Denied"],
									desc = L["If enabled then the filter will only activate when the unit is tap denied."],
									order = 17
								},
								isNotTapDenied = {
									type = 'toggle',
									name = L["Not Tap Denied"],
									desc = L["If enabled then the filter will only activate when the unit is not tap denied."],
									order = 18
								},
							}
						},
						npcGroup = {
							name = '',
							type = 'group',
							inline = true,
							order = 3,
							args = {
								hasTitleNPC = {
									type = 'toggle',
									name = L["Has NPC Title"],
									order = 1
								},
								noTitleNPC = {
									type = 'toggle',
									name = L["No NPC Title"],
									order = 2
								},
							}
						},
						questGroup = {
							name = '',
							type = 'group',
							inline = true,
							order = 4,
							args = {
								isQuest = {
									type = 'toggle',
									name = L["Quest Unit"],
									order = 1
								},
								notQuest = {
									type = 'toggle',
									name = L["Not Quest Unit"],
									order = 2
								},
								questBoss = {
									type = 'toggle',
									name = L["Quest Boss"],
									order = 3,
								},
							}
						}
					}
				},
				faction = {
					order = 10,
					type = 'group',
					name = L["Unit Faction"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.faction[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.faction[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								Alliance = {
									type = 'toggle',
									order = 1,
									name = L["Alliance"]
								},
								Horde = {
									type = 'toggle',
									order = 2,
									name = L["Horde"]
								},
								Neutral = {
									type = 'toggle',
									order = 3,
									name = L["Neutral"]
								}
							}
						}
					}
				},
				class = {
					order = 11,
					type = 'group',
					name = L["CLASS"],
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {}
				},
				talent = {
					order = 12,
					type = 'group',
					name = L["TALENT"],
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {}
				},
				slots = {
					name = L["Slots"],
					order = 13,
					type = 'group',
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = L["Equipped"],
							order = 1,
							inline = true,
							type = 'multiselect',
							sortByValue = true,
							get = function(_, key)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.slots[key]
							end,
							set = function(_, key, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.slots[key] = value or nil
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
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						addItem = {
							order = 1,
							name = L["Add Item Name or ID"],
							desc = L["Add a Item Name or ID to the list."],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.items[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeItem = {
							order = 2,
							name = L["Remove Item Name or ID"],
							desc = L["Remove a Item Name or ID from the list."],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.items[value] = nil
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
								return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
								NP:ConfigureAll()
							end
						}
					}
				},
				role = {
					order = 15,
					type = 'group',
					name = L["ROLE"],
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						myRole = {
							name = L["Player"],
							type = 'group',
							inline = true,
							order = 2,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.role[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.role[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								tank = {
									type = 'toggle',
									order = 1,
									name = L["TANK"]
								},
								healer = {
									type = 'toggle',
									order = 2,
									name = L["Healer"]
								},
								damager = {
									type = 'toggle',
									order = 3,
									name = L["DAMAGER"]
								}
							}
						},
						unitRole = {
							name = L["Unit"],
							type = 'group',
							inline = true,
							order = 2,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.unitRole[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.unitRole[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								tank = {
									type = 'toggle',
									order = 1,
									name = L["TANK"]
								},
								healer = {
									type = 'toggle',
									order = 2,
									name = L["Healer"]
								},
								damager = {
									type = 'toggle',
									order = 3,
									name = L["DAMAGER"]
								}
							}
						}
					}
				},
				classification = {
					order = 16,
					type = 'group',
					name = L["Classification"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.classification[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.classification[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								worldboss = {
									type = 'toggle',
									order = 1,
									name = L["RAID_INFO_WORLD_BOSS"]
								},
								rareelite = {
									type = 'toggle',
									order = 2,
									name = L["Rare Elite"]
								},
								normal = {
									type = 'toggle',
									order = 3,
									name = L["PLAYER_DIFFICULTY1"]
								},
								rare = {
									type = 'toggle',
									order = 4,
									name = L["ITEM_QUALITY3_DESC"]
								},
								trivial = {
									type = 'toggle',
									order = 5,
									name = L["Trivial"]
								},
								elite = {
									type = 'toggle',
									order = 6,
									name = L["ELITE"]
								},
								minus = {
									type = 'toggle',
									order = 7,
									name = L["Minus"]
								},
							}
						}
					}
				},
				health = {
					order = 17,
					type = 'group',
					name = L["Health Threshold"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						healthThreshold = {
							type = 'toggle',
							order = 1,
							name = L["Enable"]
						},
						healthUsePlayer = {
							type = 'toggle',
							order = 2,
							name = L["Player Health"],
							desc = L["Enabling this will check your health amount."],
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold
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
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.underHealthThreshold or 0
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
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.healthThreshold
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.overHealthThreshold or 0
							end
						}
					}
				},
				power = {
					order = 18,
					type = 'group',
					name = L["Power Threshold"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						powerThreshold = {
							type = 'toggle',
							order = 1,
							name = L["Enable"]
						},
						powerUsePlayer = {
							type = 'toggle',
							order = 2,
							name = L["Player Power"],
							desc = L["Enabling this will check your power amount."],
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.powerThreshold
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
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.powerThreshold
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.underPowerThreshold or 0
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
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.powerThreshold
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.overPowerThreshold or 0
							end
						}
					}
				},
				keyMod = {
					name = L["Key Modifiers"],
					order = 19,
					type = 'group',
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod and
									E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.keyMod.enable
							end,
							args = {
								Shift = {
									name = L["SHIFT_KEY_TEXT"],
									order = 1,
									type = 'toggle'
								},
								Alt = {
									name = L["ALT_KEY_TEXT"],
									order = 2,
									type = 'toggle'
								},
								Control = {
									name = L["CTRL_KEY_TEXT"],
									order = 3,
									type = 'toggle'
								},
								Modifier = {
									name = L["Any"],
									order = 4,
									type = 'toggle'
								},
								LeftShift = {
									name = L["Left Shift"],
									order = 6,
									type = 'toggle'
								},
								LeftAlt = {
									name = L["Left Alt"],
									order = 7,
									type = 'toggle'
								},
								LeftControl = {
									name = L["Left Control"],
									order = 8,
									type = 'toggle'
								},
								RightShift = {
									name = L["Right Shift"],
									order = 10,
									type = 'toggle'
								},
								RightAlt = {
									name = L["Right Alt"],
									order = 11,
									type = 'toggle'
								},
								RightControl = {
									name = L["Right Control"],
									order = 12,
									type = 'toggle'
								}
							}
						}
					}
				},
				levels = {
					order = 20,
					type = 'group',
					name = L["Level"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						level = {
							type = 'toggle',
							order = 1,
							name = L["Enable"]
						},
						mylevel = {
							type = 'toggle',
							order = 2,
							name = L["Match Player Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches your own."],
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].triggers.level
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
								return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel)
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.minlevel or 0
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
								return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel)
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.maxlevel or 0
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
								return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.level and
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.mylevel)
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.curlevel or 0
							end
						}
					}
				},
				cooldowns = {
					name = L["Cooldowns"],
					order = 21,
					type = 'group',
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						addCooldown = {
							order = 1,
							name = L["Add Spell ID or Name"],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = 'ONCD'
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeCooldown = {
							order = 2,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = 'input',
							get = function(info)
								return ''
							end,
							set = function(info, value)
								if strmatch(value, '^[%s%p]-$') then return end

								E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						mustHaveAll = {
							order = 3,
							name = L["Require All"],
							desc = L["If enabled then it will require all cooldowns to activate the filter. Otherwise it will only require any one of the cooldowns to activate it."],
							type = 'toggle',
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns and
									E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll = value
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
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
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
						mustHaveAll = {
							order = 3,
							customWidth = 100,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = 'toggle'
						},
						missing = {
							order = 4,
							customWidth = 100,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = 'toggle'
						},
						hasStealable = {
							order = 5,
							type = "toggle",
							name = L["Has Stealable"],
							desc = L["If enabled then the filter will only activate when the unit has a stealable buff(s)."]
						},
						hasNoStealable = {
							order = 6,
							type = "toggle",
							name = L["Has No Stealable"],
							desc = L["If enabled then the filter will only activate when the unit has no stealable buff(s)."],
						},
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
									get = function(info)
										return ''
									end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end
										if stackBuff then value = value .. '\n' .. stackBuff end

										E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[value] = true
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								removeBuff = {
									order = 2,
									name = L["Remove Spell ID or Name"],
									desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
									type = 'input',
									get = function(info)
										return ''
									end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										if stackBuff then
											E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[value .. '\n' .. stackBuff] = nil
										else
											for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names) do
												local spell = strmatch(name, NP.StyleFilterStackPattern)
												if spell == value then
													E.global.nameplate.filters[selectedNameplateFilter].triggers.buffs.names[name] = nil
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
									get = function(info) return stackBuff or 1 end,
									set = function(info, value) stackBuff = (value > 1 and value) or nil end
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
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
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
						mustHaveAll = {
							order = 3,
							customWidth = 100,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = 'toggle'
						},
						missing = {
							order = 4,
							customWidth = 100,
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							type = 'toggle',
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
							end
						},
						hasDispellable = {
							order = 5,
							type = "toggle",
							name = L["Has Dispellable"],
							desc = L["If enabled then the filter will only activate when the unit has a dispellable buff(s)."]
						},
						hasNoDispellable = {
							order = 6,
							type = "toggle",
							name = L["Has No Dispellable"],
							desc = L["If enabled then the filter will only activate when the unit has no dispellable buff(s)."],
						},
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
									get = function(info)
										return ''
									end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end
										if stackDebuff then value = value .. '\n' .. stackDebuff end

										E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[value] = true
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								removeDebuff = {
									order = 7,
									name = L["Remove Spell ID or Name"],
									desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
									type = 'input',
									get = function(info)
										return ''
									end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										if stackDebuff then
											E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[value .. '\n' .. stackDebuff] = nil
										else
											for name in pairs(E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names) do
												local spell = strmatch(name, NP.StyleFilterStackPattern)
												if spell == value then
													E.global.nameplate.filters[selectedNameplateFilter].triggers.debuffs.names[name] = nil
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
									get = function(info) return stackDebuff or 1 end,
									set = function(info, value) stackDebuff = (value > 1 and value) or nil end
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

						return E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle'
						},
						hasAura = {
							name = L["Has Aura"],
							order = 1,
							type = 'toggle',
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.enable
							end
						},
						missingAura = {
							name = L["Missing Aura"],
							order = 2,
							type = 'toggle',
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.enable
							end
						},
						seenList = {
							order = 3,
							type = 'group',
							name = L["Seen Textures"],
							inline = true,
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.missingAura or
									E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.hasAura or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.enable
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
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.missingAura or
									E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.hasAura or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.enable
							end,
							args = {
								addAura = {
									order = 1,
									name = L["Add Texture"],
									type = 'input',
									get = function(info)
										return ''
									end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local textureID = tonumber(value) or value
										E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras[textureID] = true
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								removeAura = {
									order = 2,
									name = L["Remove Texture"],
									type = 'input',
									get = function(info)
										return ''
									end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										local textureID = tonumber(value) or value
										E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods.auras[textureID] = nil
										UpdateFilterGroup()
										NP:ConfigureAll()
									end
								},
								missingAuras = {
									order = 3,
									name = L["Missing Auras"],
									type = 'toggle',
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods[info[#info]]
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.bossMods[info[#info]] = value
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
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.threat and
									E.global.nameplate.filters[selectedNameplateFilter].triggers.threat.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.threat.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.threat[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.threat[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.threat.enable
							end,
							args = {
								good = {
									name = L["Good"],
									order = 1,
									type = 'toggle'
								},
								goodTransition = {
									name = L["Good Transition"],
									order = 2,
									type = 'toggle'
								},
								badTransition = {
									name = L["Bad Transition"],
									order = 3,
									type = 'toggle'
								},
								bad = {
									name = L["Bad"],
									order = 4,
									type = 'toggle'
								},
								spacer1 = ACH:Spacer(5, 'full'),
								offTank = {
									name = L["Off Tank"],
									order = 6,
									type = 'toggle'
								},
								offTankGoodTransition = {
									name = L["Off Tank Good Transition"],
									customWidth = 200,
									order = 7,
									type = 'toggle'
								},
								offTankBadTransition = {
									name = L["Off Tank Bad Transition"],
									customWidth = 200,
									order = 8,
									type = 'toggle'
								}
							}
						}
					}
				},
				nameplateType = {
					name = L["Unit Type"],
					order = 26,
					type = 'group',
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle',
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType and
									E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 1,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType[info[#info]]
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.nameplateType.enable
							end,
							args = {
								friendlyPlayer = {
									name = L["FRIENDLY_PLAYER"],
									order = 1,
									type = 'toggle'
								},
								friendlyNPC = {
									name = L["FRIENDLY_NPC"],
									order = 2,
									type = 'toggle'
								},
								enemyPlayer = {
									name = L["ENEMY_PLAYER"],
									order = 3,
									type = 'toggle'
								},
								enemyNPC = {
									name = L["ENEMY_NPC"],
									order = 4,
									type = 'toggle'
								},
								player = {
									name = L["Player"],
									order = 5,
									type = 'toggle'
								}
							}
						}
					}
				},
				reactionType = {
					name = L["Reaction Type"],
					order = 27,
					type = 'group',
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType and
							E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 0,
							type = 'toggle'
						},
						reputation = {
							name = L["Reputation"],
							desc = L["If this is enabled then the reaction check will use your reputation with the faction the unit belongs to."],
							order = 1,
							type = 'toggle',
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable
							end
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable
							end,
							args = {
								hated = {
									name = L["FACTION_STANDING_LABEL1"],
									order = 1,
									type = 'toggle',
									disabled = function()
										return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
											E.db.nameplates.filters[selectedNameplateFilter].triggers and
											E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation)
									end
								},
								hostile = {
									name = L["FACTION_STANDING_LABEL2"],
									order = 2,
									type = 'toggle'
								},
								unfriendly = {
									name = L["FACTION_STANDING_LABEL3"],
									order = 3,
									type = 'toggle',
									disabled = function()
										return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
											E.db.nameplates.filters[selectedNameplateFilter].triggers and
											E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation)
									end
								},
								neutral = {
									name = L["FACTION_STANDING_LABEL4"],
									order = 4,
									type = 'toggle'
								},
								friendly = {
									name = L["FACTION_STANDING_LABEL5"],
									order = 5,
									type = 'toggle'
								},
								honored = {
									name = L["FACTION_STANDING_LABEL6"],
									order = 6,
									type = 'toggle',
									disabled = function()
										return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
											E.db.nameplates.filters[selectedNameplateFilter].triggers and
											E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation)
									end
								},
								revered = {
									name = L["FACTION_STANDING_LABEL7"],
									order = 7,
									type = 'toggle',
									disabled = function()
										return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
											E.db.nameplates.filters[selectedNameplateFilter].triggers and
											E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation)
									end
								},
								exalted = {
									name = L["FACTION_STANDING_LABEL8"],
									order = 8,
									type = 'toggle',
									disabled = function()
										return not ((E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
											E.db.nameplates.filters[selectedNameplateFilter].triggers and
											E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.enable and
											E.global.nameplate.filters[selectedNameplateFilter].triggers.reactionType.reputation)
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
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L["Enable"],
							width = 'full'
						},
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							disabled = function()
								return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
									E.db.nameplates.filters[selectedNameplateFilter].triggers and
									E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
									not E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType.enable
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
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								none = {
									type = 'toggle',
									order = 1,
									name = L["NONE"]
								},
								scenario = {
									type = 'toggle',
									order = 2,
									name = L["SCENARIOS"]
								},
								party = {
									type = 'toggle',
									order = 3,
									name = L["DUNGEONS"],
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.party = value
										UpdateInstanceDifficulty()
										NP:ConfigureAll()
									end
								},
								raid = {
									type = 'toggle',
									order = 5,
									name = L["RAID"],
									get = function(info)
										return E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid
									end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.instanceType.raid = value
										UpdateInstanceDifficulty()
										NP:ConfigureAll()
									end
								},
								arena = {
									type = 'toggle',
									order = 7,
									name = L["ARENA"]
								},
								pvp = {
									type = 'toggle',
									order = 8,
									name = L["BATTLEFIELDS"]
								}
							}
						}
					}
				},
				location = {
					order = 30,
					type = 'group',
					name = L["Location"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.location[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.location[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
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
									get = function(info) return end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs[value] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs[value] = true
										NP:ConfigureAll()
									end,
									disabled = function () return not E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDEnabled end
								},
								removeMapID = {
									type = 'select',
									order = 3,
									name = L["Remove Map ID"],
									get = function(info) return end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local ids = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs
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
										local ids = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs
										return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDEnabled and ids and next(ids))
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
									get = function(info) return end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs[value] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs[value] = true
										NP:ConfigureAll()
									end,
									disabled = function () return not E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDEnabled end
								},
								removeInstanceID = {
									type = 'select',
									order = 6,
									name = L["Remove Instance ID"],
									get = function(info) return end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local ids = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs
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
										local ids = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs
										return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDEnabled and ids and next(ids))
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
									get = function(info) return end,
									set = function(info, value)
										if strmatch(value, '^[%s%p]-$') then return end

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames[value] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames[value] = true
										NP:ConfigureAll()
									end,
									disabled = function () return not E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNamesEnabled end
								},
								removeZoneName = {
									type = 'select',
									order = 9,
									name = L["Remove Zone Name"],
									get = function(info) return end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local zone = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames
										if not (zone and next(zone)) then return vals end

										for value in pairs(zone) do vals[value] = value end
										return vals
									end,
									disabled = function()
										local zone = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames
										return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNamesEnabled and zone and next(zone))
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
									get = function(info) return end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNames[value] = true
										NP:ConfigureAll()
									end,
									disabled = function () return not E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNamesEnabled end
								},
								removeSubZoneName = {
									type = 'select',
									order = 12,
									name = L["Remove Subzone Name"],
									get = function(info) return end,
									set = function(info, value)
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNames[value] = nil
										NP:ConfigureAll()
									end,
									values = function()
										local vals = {}
										local zone = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNames
										if not (zone and next(zone)) then return vals end

										for value in pairs(zone) do vals[value] = value end
										return vals
									end,
									disabled = function()
										local zone = E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNames
										return not (E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNamesEnabled and zone and next(zone))
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

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs[mapID] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.mapIDs[mapID] = true
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

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs[instanceID] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.instanceIDs[instanceID] = true
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

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames[zone] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.zoneNames[zone] = true
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

										if E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNames[subZone] then return end
										E.global.nameplate.filters[selectedNameplateFilter].triggers.location.subZoneNames[subZone] = true
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
						return E.global.nameplate.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = '',
							type = 'group',
							inline = true,
							order = 2,
							args = {
								star = {
									type = 'toggle',
									order = 1,
									name = format(raidTargetIcon, 1, L["RAID_TARGET_1"])
								},
								circle = {
									type = 'toggle',
									order = 2,
									name = format(raidTargetIcon, 2, L["RAID_TARGET_2"])
								},
								diamond = {
									type = 'toggle',
									order = 3,
									name = format(raidTargetIcon, 3, L["RAID_TARGET_3"])
								},
								triangle = {
									type = 'toggle',
									order = 4,
									name = format(raidTargetIcon, 4, L["RAID_TARGET_4"])
								},
								moon = {
									type = 'toggle',
									order = 5,
									name = format(raidTargetIcon, 5, L["RAID_TARGET_5"])
								},
								square = {
									type = 'toggle',
									order = 6,
									name = format(raidTargetIcon, 6, L["RAID_TARGET_6"])
								},
								cross = {
									type = 'toggle',
									order = 7,
									name = format(raidTargetIcon, 7, L["RAID_TARGET_7"])
								},
								skull = {
									type = 'toggle',
									order = 8,
									name = format(raidTargetIcon, 8, L["RAID_TARGET_8"])
								}
							}
						}
					}
				}
			}
		}

		if NP.StyleFilterCustomChecks then
			E.Options.args.nameplate.args.filters.args.triggers.args.combat.args.pluginSpacer = ACH:Spacer(49, 'full')
		end

		E.Options.args.nameplate.args.filters.args.actions = {
			type = 'group',
			name = L["Actions"],
			order = 6,
			get = function(info)
				return E.global.nameplate.filters[selectedNameplateFilter].actions[info[#info]]
			end,
			set = function(info, value)
				E.global.nameplate.filters[selectedNameplateFilter].actions[info[#info]] = value
				NP:ConfigureAll()
			end,
			disabled = function()
				return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
					E.db.nameplates.filters[selectedNameplateFilter].triggers and
					E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
			end,
			args = {
				hide = {
					order = 1,
					type = 'toggle',
					name = L["Hide Frame"]
				},
				usePortrait = {
					order = 2,
					type = 'toggle',
					name = L["Use Portrait"],
					disabled = function()
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end
				},
				nameOnly = {
					name = L["Name Only"],
					order = 3,
					type = 'toggle',
					disabled = function()
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end
				},
				spacer1 = ACH:Spacer(4, 'full'),
				scale = {
					order = 5,
					type = 'range',
					name = L["Scale"],
					disabled = function()
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.scale or 1
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
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.alpha or -1
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
						return E.global.nameplate.filters[selectedNameplateFilter].actions.color[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.color[info[#info]] = value
						NP:ConfigureAll()
					end,
					inline = true,
					disabled = function()
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
					args = {
						health = {
							name = L["Health"],
							order = 1,
							type = 'toggle'
						},
						healthColor = {
							name = L["Health Color"],
							type = 'color',
							order = 2,
							hasAlpha = true,
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.health
							end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.healthColor
								return t.r, t.g, t.b, t.a, 136 / 255, 255 / 255, 102 / 255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.healthColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						healthClass = {
							type = 'toggle',
							order = 3,
							name = L["Unit Class Color"]
						},
						spacer1 = ACH:Spacer(4, 'full'),
						power = {
							name = L["Power"],
							order = 10,
							type = 'toggle'
						},
						powerColor = {
							name = L["Power Color"],
							type = 'color',
							order = 11,
							hasAlpha = true,
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.power
							end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.powerColor
								return t.r, t.g, t.b, t.a, 102 / 255, 136 / 255, 255 / 255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.powerColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						powerClass = {
							type = 'toggle',
							order = 12,
							name = L["Unit Class Color"]
						},
						spacer2 = ACH:Spacer(13, 'full'),
						border = {
							name = L["Border"],
							order = 20,
							type = 'toggle'
						},
						borderColor = {
							name = L["Border Color"],
							type = 'color',
							order = 21,
							hasAlpha = true,
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].actions.color.border
							end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.borderColor
								return t.r, t.g, t.b, t.a, 0, 0, 0, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.color.borderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						borderClass = {
							type = 'toggle',
							order = 22,
							name = L["Unit Class Color"]
						}
					}
				},
				texture = {
					order = 20,
					type = 'group',
					name = L["Texture"],
					get = function(info)
						return E.global.nameplate.filters[selectedNameplateFilter].actions.texture[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.texture[info[#info]] = value
						NP:ConfigureAll()
					end,
					inline = true,
					disabled = function()
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
					args = {
						enable = {
							name = L["Enable"],
							order = 1,
							type = 'toggle'
						},
						texture = {
							order = 2,
							type = 'select',
							dialogControl = 'LSM30_Statusbar',
							name = L["Texture"],
							values = _G.AceGUIWidgetLSMlists.statusbar,
							disabled = function()
								return not E.global.nameplate.filters[selectedNameplateFilter].actions.texture.enable
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
						return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
					end,
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
							end
						},
						color = {
							name = L["COLOR"],
							type = 'color',
							order = 2,
							hasAlpha = true,
							disabled = function()
								return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
							end,
							get = function(info)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.flash.color
								return t.r, t.g, t.b, t.a, 104 / 255, 138 / 255, 217 / 255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplate.filters[selectedNameplateFilter].actions.flash.color
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						flashClass = {
							type = 'toggle',
							order = 3,
							name = L["Unit Class Color"],
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.flash.class
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.flash.class = value
								NP:ConfigureAll()
							end
						},
						speed = {
							order = 4,
							type = 'range',
							name = L["SPEED"],
							disabled = function()
								return E.global.nameplate.filters[selectedNameplateFilter].actions.hide
							end,
							get = function(info)
								return E.global.nameplate.filters[selectedNameplateFilter].actions.flash.speed or 4
							end,
							set = function(info, value)
								E.global.nameplate.filters[selectedNameplateFilter].actions.flash.speed = value
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
						return E.global.nameplate.filters[selectedNameplateFilter].actions.tags[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplate.filters[selectedNameplateFilter].actions.tags[info[#info]] = value
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
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or
							not E.global.nameplate.filters[selectedNameplateFilter].triggers.creatureType.enable
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
	disabled = function()
		return not E.NamePlates.Initialized
	end,
	args = {
		addFilter = {
			order = 1,
			name = L["Create Filter"],
			type = 'input',
			get = function() return '' end,
			set = function(_, value)
				if strmatch(value, '^[%s%p]-$') then return end

				if E.global.nameplate.filters[value] then
					E:Print(L["Filter already exists!"])
					return
				end

				local filter = {}
				NP:StyleFilterCopyDefaults(filter)
				E.global.nameplate.filters[value] = filter
				selectedNameplateFilter = value
				UpdateFilterGroup()
				NP:ConfigureAll()
			end
		},
		selectFilter = {
			name = L["Select Filter"],
			type = 'select',
			order = 2,
			sortByValue = true,
			get = function() return selectedNameplateFilter end,
			set = function(_, value) selectedNameplateFilter = value UpdateFilterGroup() end,
			values = function()
				wipe(filters)
				local list = E.global.nameplate.filters
				if not (list and next(list)) then return filters end

				local profile, priority, name = E.db.nameplates.filters
				for filter, content in pairs(list) do
					priority = (content.triggers and content.triggers.priority) or '?'
					name =
						(content.triggers and profile[filter] and profile[filter].triggers and profile[filter].triggers.enable and
						filter) or
						(content.triggers and format('|cFF666666%s|r', filter)) or
						filter
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
					and E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] then
						E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] = nil
					end
				end
				E.global.nameplate.filters[selectedNameplateFilter] = nil
				selectedNameplateFilter = nil
				UpdateFilterGroup()
				NP:ConfigureAll()
			end,
			disabled = function()
				return G.nameplate.filters[selectedNameplateFilter]
			end,
			hidden = function()
				return selectedNameplateFilter == nil
			end
		}
	}
}
