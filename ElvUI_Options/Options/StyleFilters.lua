local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local D = E:GetModule('Distributor')
local NP = E:GetModule('NamePlates')
local LibCompress = E.Libs.Compress
local LibBase64 = E.Libs.Base64
local ACH = E.Libs.ACH
local LCS = E.Libs.LCS

local _G = _G
local wipe, pairs, strmatch, strsplit, tostring = wipe, pairs, strmatch, strsplit, tostring
local next, sort, tonumber, format = next, sort, tonumber, format

local GetClassInfo = GetClassInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetInstanceInfo = GetInstanceInfo
local GetRealZoneText = GetRealZoneText
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetTalentInfo = GetTalentInfo
local tIndexOf = tIndexOf

local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_SpecializationInfo_GetPvpTalentSlotInfo = E.Retail and C_SpecializationInfo.GetPvpTalentSlotInfo
local GetNumSpecializationsForClassID = (not E.Retail and LCS.GetNumSpecializationsForClassID) or GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = (not E.Retail and LCS.GetSpecializationInfoForClassID) or GetSpecializationInfoForClassID
local GetPvpTalentInfoByID = GetPvpTalentInfoByID

local filters = {}
local exportList = {}
local raidTargetIcon = [[|TInterface\TargetingFrame\UI-RaidTargetingIcon_%s:0|t %s]]
local sortedClasses = E:CopyTable({}, CLASS_SORT_ORDER)
sort(sortedClasses)

C.StyleFilterSelected = nil

E.Options.args.nameplates.args.stylefilters = ACH:Group(L["Style Filter"], nil, 10, 'tab', nil, nil, function() return not E.NamePlates.Initialized end)
local StyleFilters = E.Options.args.nameplates.args.stylefilters.args
local StyleFallback = NP:StyleFilterCopyDefaults()

local function GetFilter(collect, profile)
	local setting = (profile and E.db.nameplates.filters[C.StyleFilterSelected]) or E.global.nameplates.filters[C.StyleFilterSelected] or StyleFallback

	if collect and setting then
		return setting.triggers, setting.actions
	else
		return setting
	end
end
C.StyleFilterGetFilter = GetFilter

local function DisabledFilter()
	local profileTriggers = GetFilter(true, true)
	return not (profileTriggers and profileTriggers.enable)
end
C.StyleFilterDisabledFilter = DisabledFilter

local function GetFilters(info)
	wipe(filters)

	local list = E.global.nameplates.filters
	if not (list and next(list)) then
		return filters
	end

	local profile, priority, name = E.db.nameplates.filters
	for filter, content in pairs(list) do
		if info[#info] == 'selectFilter' then
			priority = (content.triggers and content.triggers.priority) or '?'
			name = (content.triggers and profile[filter] and profile[filter].triggers and profile[filter].triggers.enable and filter) or (content.triggers and format('|cFF666666%s|r', filter)) or filter
			filters[filter] = format('|cFFffff00(%s)|r %s', priority, name)
		else
			filters[filter] = filter
		end
	end

	return filters
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
		if slotInfo and slotInfo.availableTalentIDs then
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

local function GetSpellFilterInfo(name)
	local spell, stacks = strmatch(name, NP.StyleFilterStackPattern)
	local spellID = tonumber(spell)
	if spellID then
		local spellName = GetSpellInfo(spellID)
		if spellName then
			if DisabledFilter() then
				spell = format('%s (%d)', spellName, spellID)
			else
				spell = format('|cFFffff00%s|r |cFFffffff(%d)|r', spellName, spellID)

				if stacks ~= '' then
					spell = format('%s|cFF999999%s|r', spell, ' x'..stacks)
				end
			end
		end
	end

	local spellTexture = GetSpellTexture(spellID or spell)
	local spellDescription = spellTexture and E:TextureString(spellTexture, ':32:32:0:0:32:32:4:28:4:28')

	return spell, spellDescription
end

local spellTypes = { casting = true, debuffs = true, buffs = true, cooldowns = true }
local cdOptions = { DISABLED = _G.DISABLE, ONCD = L["On Cooldown"], OFFCD = L["Off Cooldown"] }
local subTypes = { casting = 'spells', debuffs = 'names', buffs = 'names', cooldowns = 'names', names = 'list', items = 'list' }
local function GetFilterOption(which)
	local option
	if which == 'cooldowns' then
		option = ACH:Select('', nil, nil, cdOptions)
	else
		option = ACH:Toggle('', nil)
		option.textWidth = true
	end

	return option
end

local function UpdateFilterList(which, initial, opt, add)
	local filter = GetFilter()
	local spell, desc

	local subType, isSpell = subTypes[which], spellTypes[which]
	local setting = StyleFilters.triggers.args[which].args[subType]
	local triggers = filter.triggers[which][subType] or filter.triggers[which]
	setting.hidden = not next(triggers)

	if initial and filter.triggers[which] then
		setting.args = {}

		for name in next, triggers do
			if isSpell then
				spell, desc = GetSpellFilterInfo(name)
			else
				spell, desc = nil, nil
			end

			local option = GetFilterOption(which)
			option.name, option.desc = spell or name, spell and desc or nil

			setting.args[name] = option
		end
	elseif not initial then
		if isSpell then
			spell, desc = GetSpellFilterInfo(opt)
		end

		local option = GetFilterOption(which)
		option.name, option.desc = spell or opt, spell and desc or nil

		setting.args[opt] = add and option or nil
	end
end

local function UpdateBossModAuras(initial, opt, add)
	local filter = GetFilter()
	local setting = StyleFilters.triggers.args.bossModAuras.args
	setting.auras.hidden = not filter or not next(filter.triggers.bossMods.auras)

	if initial then
		setting.auras.args = {}
		setting.seenList.hidden = true

		if filter and filter.triggers and filter.triggers.bossMods and filter.triggers.bossMods.auras then

			for aura in next, filter.triggers.bossMods.auras do
				setting.auras.args[aura] = ACH:Toggle(aura, E:TextureString(aura, ':32:32:0:0:32:32:4:28:4:28'))
			end
		end

		if filter and filter.triggers and filter.triggers.bossMods and next(NP.BossMods_TextureCache) then
			setting.seenList.hidden = false

			for texture in next, NP.BossMods_TextureCache do
				setting.seenList.args[texture] = ACH:Toggle(texture, E:TextureString(texture, ':32:32:0:0:32:32:4:28:4:28'))
			end
		end
	elseif not initial then
		setting.auras.args[opt] = add and ACH:Toggle(opt, E:TextureString(opt, ':32:32:0:0:32:32:4:28:4:28')) or nil
	end
end

local function UpdateFilterGroup()
	UpdateFilterList('names', true)
	UpdateFilterList('items', true)
	UpdateFilterList('cooldowns', true)
	UpdateFilterList('buffs', true)
	UpdateFilterList('debuffs', true)
	UpdateFilterList('casting', true)
end

function C:StyleFilterSetConfig(filter)
	C.StyleFilterSelected = filter
	UpdateFilterGroup()
end

local function validateCreateFilter(_, value) return not (strmatch(value, '^[%s%p]-$') or E.global.nameplates.filters[value]) end
local function validateString(_, value) return not strmatch(value, '^[%s%p]-$') end

StyleFilters.addFilter = ACH:Input(L["Create Filter"], nil, 1, nil, nil, nil, function(_, value) E.global.nameplates.filters[value] = NP:StyleFilterCopyDefaults() C:StyleFilterSetConfig(value) end, nil, nil, validateCreateFilter)
StyleFilters.selectFilter = ACH:Select(L["Select Filter"], nil, 2, GetFilters, nil, nil, function() return C.StyleFilterSelected end, function(_, value) C:StyleFilterSetConfig(value) end)
StyleFilters.selectFilter.sortByValue = true
StyleFilters.removeFilter = ACH:Select(L["Delete Filter"], L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."], 3, function() wipe(filters) for filterName in next, E.global.nameplates.filters do if not G.nameplates.filters[filterName] then filters[filterName] = filterName end end return filters end, true, nil, nil, function(_, value) for profile in pairs(E.data.profiles) do if E.data.profiles[profile].nameplates and E.data.profiles[profile].nameplates.filters then E.data.profiles[profile].nameplates.filters[value] = nil end end E.global.nameplates.filters[value] = nil exportList[value] = nil NP:ConfigureAll() C:StyleFilterSetConfig() end)

StyleFilters.triggers = ACH:Group(L["Triggers"], nil, 5, nil, nil, nil, function() return not C.StyleFilterSelected end)
-- UpdateBossModAuras needed here in get to update the list once every time you load the config with a selected filter.
StyleFilters.triggers.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function() UpdateBossModAuras(true) local profileTriggers = GetFilter(true, true) return profileTriggers and profileTriggers.enable end, function(_, value) E.db.nameplates = E.db.nameplates or {} E.db.nameplates.filters = E.db.nameplates.filters or {} E.db.nameplates.filters[C.StyleFilterSelected] = E.db.nameplates.filters[C.StyleFilterSelected] or {} local profileFilter = GetFilter(nil, true) if not profileFilter.triggers then profileFilter.triggers = {} end profileFilter.triggers.enable = value NP:ConfigureAll() end)
StyleFilters.triggers.args.priority = ACH:Range(L["Filter Priority"], L["Lower numbers mean a higher priority. Filters are processed in order from 1 to 100."], 1, { min = 1, max = 100, step = 1 }, nil, function() local triggers = GetFilter(true) return triggers.priority or 1 end, function(_, value) local triggers = GetFilter(true) if triggers then triggers.priority = value NP:ConfigureAll() end end, DisabledFilter)
StyleFilters.triggers.args.resetFilter = ACH:Execute(L["Clear Filter"], L["Return filter to its default state."], 2, function() E.global.nameplates.filters[C.StyleFilterSelected] = E:CopyTable(NP:StyleFilterCopyDefaults(), G.nameplates.filters[C.StyleFilterSelected]) UpdateFilterGroup() NP:ConfigureAll() end)

StyleFilters.triggers.args.names = ACH:Group(L["Name"], nil, 6, nil, nil, nil, DisabledFilter)
StyleFilters.triggers.args.names.args.addName = ACH:Input(L["Add Name or NPC ID"], L["Add a Name or NPC ID to the list."], 1, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.names[value] = true UpdateFilterList('names', nil, value, true) NP:ConfigureAll() end, nil, nil, validateString)
StyleFilters.triggers.args.names.args.removeName = ACH:Select(L["Remove Name or NPC ID"], L["Remove a Name or NPC ID from the list."], 2, function() local triggers, values = GetFilter(true), {} for name in next, triggers.names do values[name] = name end return values end, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.names[value] = nil UpdateFilterList('names', nil, value) NP:ConfigureAll() end)
StyleFilters.triggers.args.names.args.negativeMatch = ACH:Toggle(L["Negative Match"], L["Match if Name or NPC ID is NOT in the list."], 3, nil, nil, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end)

StyleFilters.triggers.args.names.args.list = ACH:Group('', nil, 50, nil, function(info) local triggers = GetFilter(true) return triggers.names and triggers.names[info[#info]] end, function(info, value) local triggers = GetFilter(true) if not triggers.names then triggers.names = {} end triggers.names[info[#info]] = value NP:ConfigureAll() end, nil, true)
StyleFilters.triggers.args.names.args.list.inline = true

StyleFilters.triggers.args.targeting = ACH:Group(L["Targeting"], nil, 7, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.targeting.args.types = ACH:Group('', nil, 1)
StyleFilters.triggers.args.targeting.args.types.inline = true
StyleFilters.triggers.args.targeting.args.types.args.isTarget = ACH:Toggle(L["Is Targeted"], L["If enabled then the filter will only activate when you are targeting the unit."], 1)
StyleFilters.triggers.args.targeting.args.types.args.notTarget = ACH:Toggle(L["Not Targeted"], L["If enabled then the filter will only activate when you are not targeting the unit."], 2)
StyleFilters.triggers.args.targeting.args.types.args.requireTarget = ACH:Toggle(L["Require Target"], L["If enabled then the filter will only activate when you have a target."], 3)
StyleFilters.triggers.args.targeting.args.types.args.noTarget = ACH:Toggle(L["No Target"], nil, 4)
StyleFilters.triggers.args.targeting.args.types.args.targetMe = ACH:Toggle(L["Is Targeting Player"], L["If enabled then the filter will only activate when the unit is targeting you."], 5)
StyleFilters.triggers.args.targeting.args.types.args.notTargetMe = ACH:Toggle(L["Not Targeting Player"], L["If enabled then the filter will only activate when the unit is not targeting you."], 6)
StyleFilters.triggers.args.targeting.args.types.args.isFocus = ACH:Toggle(L["Is Focused"], L["If enabled then the filter will only activate when you are focusing the unit."], 7)
StyleFilters.triggers.args.targeting.args.types.args.notFocus = ACH:Toggle(L["Not Focused"], L["If enabled then the filter will only activate when you are not focusing the unit."], 8)

StyleFilters.triggers.args.casting = ACH:Group(L["Casting"], nil, 8, nil, function(info) local triggers = GetFilter(true) return triggers.casting[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.casting[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.casting.args.types = ACH:Group('', nil, 1)
StyleFilters.triggers.args.casting.args.types.inline = true
StyleFilters.triggers.args.casting.args.types.args.interruptible = ACH:Toggle(L["Interruptible"], L["If enabled then the filter will only activate if the unit is casting interruptible spells."], 1)
StyleFilters.triggers.args.casting.args.types.args.notInterruptible = ACH:Toggle(L["Non-Interruptible"], L["If enabled then the filter will only activate if the unit is casting not interruptible spells."], 2)
StyleFilters.triggers.args.casting.args.types.args.spacer1 = ACH:Spacer(3, 'full')
StyleFilters.triggers.args.casting.args.types.args.isCasting = ACH:Toggle(L["Is Casting Anything"], L["If enabled then the filter will activate if the unit is casting anything."], 4)
StyleFilters.triggers.args.casting.args.types.args.notCasting = ACH:Toggle(L["Not Casting Anything"], L["If enabled then the filter will activate if the unit is not casting anything."], 5)
StyleFilters.triggers.args.casting.args.types.args.spacer2 = ACH:Spacer(6, 'full')
StyleFilters.triggers.args.casting.args.types.args.isChanneling = ACH:Toggle(L["Is Channeling Anything"], L["If enabled then the filter will activate if the unit is channeling anything."], 7)
StyleFilters.triggers.args.casting.args.types.args.notChanneling = ACH:Toggle(L["Not Channeling Anything"], L["If enabled then the filter will activate if the unit is not channeling anything."], 8)

StyleFilters.triggers.args.casting.args.addSpell = ACH:Input(L["Add Spell ID or Name"], nil, 2, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.casting.spells[value] = true UpdateFilterList('casting', nil, value, true) NP:ConfigureAll() end, nil, nil, validateString)
StyleFilters.triggers.args.casting.args.removeSpell = ACH:Select(L["Remove Spell ID or Name"], L["If the aura is listed with a number then you need to use that to remove it from the list."], 3, function() local triggers, values = GetFilter(true), {} for spell in next, triggers.casting.spells do values[spell] = spell end return values end, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.casting.spells[value] = nil UpdateFilterList('casting', nil, value) NP:ConfigureAll() end)
StyleFilters.triggers.args.casting.args.notSpell = ACH:Toggle(L["Not Spell"], L["If enabled then the filter will only activate if the unit is not casting or channeling one of the selected spells."], 4)
StyleFilters.triggers.args.casting.args.description1 = ACH:Description(L["You do not need to use Is Casting Anything or Is Channeling Anything for these spells to trigger."], 10)
StyleFilters.triggers.args.casting.args.description2 = ACH:Description(L["If this list is empty, and if Interruptible is checked, then the filter will activate on any type of cast that can be interrupted."], 11)

StyleFilters.triggers.args.casting.args.spells = ACH:Group('', nil, 50, nil, function(info) local triggers = GetFilter(true) return triggers.casting.spells and triggers.casting.spells[info[#info]] end, function(info, value) local triggers = GetFilter(true) if not triggers.casting.spells then triggers.casting.spells = {} end triggers.casting.spells[info[#info]] = value NP:ConfigureAll() end, nil, true)
StyleFilters.triggers.args.casting.args.spells.inline = true

StyleFilters.triggers.args.combat = ACH:Group(L["Unit Conditions"], nil, 9, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)

StyleFilters.triggers.args.combat.args.playerGroup = ACH:Group(L["Player"], nil, 1)
StyleFilters.triggers.args.combat.args.playerGroup.inline = true
StyleFilters.triggers.args.combat.args.playerGroup.args.inCombat = ACH:Toggle(L["In Combat"], L["If enabled then the filter will only activate when you are in combat."], 1)
StyleFilters.triggers.args.combat.args.playerGroup.args.outOfCombat = ACH:Toggle(L["Out of Combat"], L["If enabled then the filter will only activate when you are out of combat."], 2)
StyleFilters.triggers.args.combat.args.playerGroup.args.inVehicle = ACH:Toggle(L["In Vehicle"], L["If enabled then the filter will only activate when you are in a Vehicle."], 3, nil, nil, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.combat.args.playerGroup.args.outOfVehicle = ACH:Toggle(L["Out of Vehicle"], L["If enabled then the filter will only activate when you are not in a Vehicle."], 4, nil, nil, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.combat.args.playerGroup.args.isResting = ACH:Toggle(L["Is Resting"], L["If enabled then the filter will only activate when you are resting at an Inn."], 5)
StyleFilters.triggers.args.combat.args.playerGroup.args.notResting = ACH:Toggle(L["Not Resting"], nil, 6)
StyleFilters.triggers.args.combat.args.playerGroup.args.playerCanAttack = ACH:Toggle(L["Can Attack"], L["If enabled then the filter will only activate when the unit can be attacked by the active player."], 7)
StyleFilters.triggers.args.combat.args.playerGroup.args.playerCanNotAttack = ACH:Toggle(L["Can Not Attack"], L["If enabled then the filter will only activate when the unit can not be attacked by the active player."], 8)
StyleFilters.triggers.args.combat.args.playerGroup.args.inPetBattle = ACH:Toggle(L["In Pet Battle"], nil, 9, nil, nil, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.combat.args.playerGroup.args.notPetBattle = ACH:Toggle(L["Not Pet Battle"], nil, 10, nil, nil, nil, nil, nil, nil, not E.Retail)

StyleFilters.triggers.args.combat.args.unitGroup = ACH:Group(L["Unit"], nil, 2)
StyleFilters.triggers.args.combat.args.unitGroup.inline = true
StyleFilters.triggers.args.combat.args.unitGroup.args.inCombatUnit = ACH:Toggle(L["In Combat"], L["If enabled then the filter will only activate when the unit is in combat."], 1)
StyleFilters.triggers.args.combat.args.unitGroup.args.outOfCombatUnit = ACH:Toggle(L["Out of Combat"], L["If enabled then the filter will only activate when the unit is out of combat."], 2)
StyleFilters.triggers.args.combat.args.unitGroup.args.inVehicleUnit = ACH:Toggle(L["In Vehicle"], L["If enabled then the filter will only activate when the unit is in a Vehicle."], 3, nil, nil, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.combat.args.unitGroup.args.outOfVehicleUnit = ACH:Toggle(L["Out of Vehicle"], L["If enabled then the filter will only activate when the unit is not in a Vehicle."], 4, nil, nil, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.combat.args.unitGroup.args.inParty = ACH:Toggle(L["In Party"], L["If enabled then the filter will only activate when the unit is in your Party."], 5)
StyleFilters.triggers.args.combat.args.unitGroup.args.notInParty = ACH:Toggle(L["Not in Party"], L["If enabled then the filter will only activate when the unit is not in your Party."], 6)
StyleFilters.triggers.args.combat.args.unitGroup.args.inRaid = ACH:Toggle(L["In Raid"], L["If enabled then the filter will only activate when the unit is in your Raid."], 7)
StyleFilters.triggers.args.combat.args.unitGroup.args.notInRaid = ACH:Toggle(L["Not in Raid"], L["If enabled then the filter will only activate when the unit is not in your Raid."], 8)
StyleFilters.triggers.args.combat.args.unitGroup.args.isPet = ACH:Toggle(L["Is Pet"], L["If enabled then the filter will only activate when the unit is the active player's pet."], 9)
StyleFilters.triggers.args.combat.args.unitGroup.args.isNotPet= ACH:Toggle(L["Not Pet"], L["If enabled then the filter will only activate when the unit is not the active player's pet."], 10)
StyleFilters.triggers.args.combat.args.unitGroup.args.isPlayerControlled = ACH:Toggle(L["Player Controlled"], L["If enabled then the filter will only activate when the unit is controlled by the player."], 11)
StyleFilters.triggers.args.combat.args.unitGroup.args.isNotPlayerControlled = ACH:Toggle(L["Not Player Controlled"], L["If enabled then the filter will only activate when the unit is not controlled by the player."], 12)
StyleFilters.triggers.args.combat.args.unitGroup.args.isOwnedByPlayer = ACH:Toggle(L["Owned By Player"], L["If enabled then the filter will only activate when the unit is owned by the player."], 13)
StyleFilters.triggers.args.combat.args.unitGroup.args.isNotOwnedByPlayer = ACH:Toggle(L["Not Owned By Player"], L["If enabled then the filter will only activate when the unit is not owned by the player."], 14)
StyleFilters.triggers.args.combat.args.unitGroup.args.isPvP = ACH:Toggle(L["Is PvP"], L["If enabled then the filter will only activate when the unit is pvp-flagged."], 15)
StyleFilters.triggers.args.combat.args.unitGroup.args.isNotPvP = ACH:Toggle(L["Not PvP"], L["If enabled then the filter will only activate when the unit is not pvp-flagged."], 16)
StyleFilters.triggers.args.combat.args.unitGroup.args.isTapDenied = ACH:Toggle(L["Tap Denied"], L["If enabled then the filter will only activate when the unit is tap denied."], 17)
StyleFilters.triggers.args.combat.args.unitGroup.args.isNotTapDenied = ACH:Toggle(L["Not Tap Denied"], L["If enabled then the filter will only activate when the unit is not tap denied."], 18)
StyleFilters.triggers.args.combat.args.unitGroup.args.inMyGuild = ACH:Toggle(L["My Guild"], nil, 19)
StyleFilters.triggers.args.combat.args.unitGroup.args.notMyGuild = ACH:Toggle(L["Not My Guild"], nil, 20)
StyleFilters.triggers.args.combat.args.unitGroup.args.isOthersPet = ACH:Toggle(L["Another Players Pet"], nil, 21)
StyleFilters.triggers.args.combat.args.unitGroup.args.notOthersPet = ACH:Toggle(L["Not Another Players Pet"], nil, 22)
StyleFilters.triggers.args.combat.args.unitGroup.args.isTrivial = ACH:Toggle(L["Is Trivial"], nil, 23)
StyleFilters.triggers.args.combat.args.unitGroup.args.notTrivial = ACH:Toggle(L["Not Trivial"], nil, 24)
StyleFilters.triggers.args.combat.args.unitGroup.args.isUnconscious = ACH:Toggle(L["Unconscious"], nil, 25)
StyleFilters.triggers.args.combat.args.unitGroup.args.isConscious = ACH:Toggle(L["Conscious"], nil, 26)
StyleFilters.triggers.args.combat.args.unitGroup.args.isPossessed = ACH:Toggle(L["Is Possessed"], nil, 27)
StyleFilters.triggers.args.combat.args.unitGroup.args.notPossessed = ACH:Toggle(L["Not Possessed"], nil, 28)
StyleFilters.triggers.args.combat.args.unitGroup.args.isCharmed = ACH:Toggle(L["Is Charmed"], nil, 29)
StyleFilters.triggers.args.combat.args.unitGroup.args.notCharmed = ACH:Toggle(L["Not Charmed"], nil, 30)
StyleFilters.triggers.args.combat.args.unitGroup.args.isDeadOrGhost = ACH:Toggle(L["Dead or Ghost"], nil, 31)
StyleFilters.triggers.args.combat.args.unitGroup.args.notDeadOrGhost = ACH:Toggle(L["Alive"], nil, 32)
StyleFilters.triggers.args.combat.args.unitGroup.args.isBeingResurrected = ACH:Toggle(L["Is Being Resurrected"], nil, 33)
StyleFilters.triggers.args.combat.args.unitGroup.args.notBeingResurrected = ACH:Toggle(L["Not Being Resurrected"], nil, 34)
StyleFilters.triggers.args.combat.args.unitGroup.args.isConnected = ACH:Toggle(L["Connected"], nil, 35)
StyleFilters.triggers.args.combat.args.unitGroup.args.notConnected = ACH:Toggle(L["Disconnected"], nil, 36)

StyleFilters.triggers.args.combat.args.npcGroup = ACH:Group('', nil, 3)
StyleFilters.triggers.args.combat.args.npcGroup.inline = true
StyleFilters.triggers.args.combat.args.npcGroup.args.hasTitleNPC = ACH:Toggle(L["Has NPC Title"], nil, 1)
StyleFilters.triggers.args.combat.args.npcGroup.args.noTitleNPC = ACH:Toggle(L["No NPC Title"], nil, 2)

StyleFilters.triggers.args.combat.args.questGroup = ACH:Group('', nil, 4, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.combat.args.questGroup.inline = true
StyleFilters.triggers.args.combat.args.questGroup.args.isQuest = ACH:Toggle(L["Quest Unit"], nil, 1)
StyleFilters.triggers.args.combat.args.questGroup.args.notQuest = ACH:Toggle(L["Not Quest Unit"], nil, 2)
StyleFilters.triggers.args.combat.args.questGroup.args.questBoss = ACH:Toggle(L["Quest Boss"], nil, 3)

StyleFilters.triggers.args.faction = ACH:Group(L["Unit Faction"], nil, 10, nil, function(info) local triggers = GetFilter(true) return triggers.faction[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.faction[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.faction.args.types = ACH:Group('', nil, 2)
StyleFilters.triggers.args.faction.args.types.inline = true
StyleFilters.triggers.args.faction.args.types.args.Alliance = ACH:Toggle(L["Alliance"], nil, 1)
StyleFilters.triggers.args.faction.args.types.args.Horde = ACH:Toggle(L["Horde"], nil, 2)
StyleFilters.triggers.args.faction.args.types.args.Neutral = ACH:Toggle(L["Neutral"], nil, 3)

StyleFilters.triggers.args.class = ACH:Group(L["CLASS"], nil, 11, nil, nil, nil, DisabledFilter)

for index = 1, 12 do
	local className, classTag, classID = GetClassInfo(index)
	if classTag then
		local coloredName = E:ClassColor(classTag)
		coloredName = (coloredName and coloredName.colorStr) or 'ff666666'
		StyleFilters.triggers.args.class.args[classTag] = ACH:Toggle(format('|c%s%s|r', coloredName, className), nil, tIndexOf(sortedClasses, classTag), nil, nil, nil, function() local triggers = GetFilter(true) local tagTrigger = triggers.class[classTag] return tagTrigger and tagTrigger.enabled end, function(_, value) local triggers = GetFilter(true) local tagTrigger = triggers.class[classTag] if not tagTrigger then triggers.class[classTag] = {} end if value then triggers.class[classTag].enabled = value else triggers.class[classTag] = nil end NP:ConfigureAll() end)

		local group = ACH:Group(className, nil, tIndexOf(sortedClasses, classTag) + 12, nil, nil, nil, nil, function() local triggers = GetFilter(true) local tagTrigger = triggers.class[classTag] return not tagTrigger or not tagTrigger.enabled end)
		group.inline = true

		for k = 1, GetNumSpecializationsForClassID(classID) do
			local specID, name = GetSpecializationInfoForClassID(classID, k)

			local tagID = format('%s%s', classTag, specID)
			group.args[tagID] = ACH:Toggle(format('|c%s%s|r', coloredName, name), nil, k, nil, nil, nil, function() local triggers = GetFilter(true) local tagTrigger = triggers.class[classTag] return tagTrigger and tagTrigger.specs and tagTrigger.specs[specID] end, function(_, value) local triggers = GetFilter(true) local tagTrigger = triggers.class[classTag] if not tagTrigger.specs then triggers.class[classTag].specs = {} end triggers.class[classTag].specs[specID] = value or nil if not next(triggers.class[classTag].specs) then triggers.class[classTag].specs = nil end NP:ConfigureAll() end)
		end

		StyleFilters.triggers.args.class.args[format('%s%s', classTag, 'spec')] = group
	end
end

StyleFilters.triggers.args.talent = ACH:Group(L["TALENT"], nil, 12, nil, nil, nil, DisabledFilter, not E.Retail)
StyleFilters.triggers.args.talent.args.enabled = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.talent.enabled end, function(_, value) local triggers = GetFilter(true) triggers.talent.enabled = value NP:ConfigureAll() end)
StyleFilters.triggers.args.talent.args.type = ACH:Toggle(L["Is PvP Talents"], nil, 2, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.talent.type == 'pvp' end, function(_, value) local triggers = GetFilter(true) triggers.talent.type = value and 'pvp' or 'normal' NP:ConfigureAll() end, function() local triggers = GetFilter(true) return not triggers.talent.enabled end)
StyleFilters.triggers.args.talent.args.requireAll = ACH:Toggle(L["Require All"], nil, 3, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.talent.requireAll end, function(_, value) local triggers = GetFilter(true) triggers.talent.requireAll = value NP:ConfigureAll() end, function() local triggers = GetFilter(true) return not triggers.talent.enabled end)

for i = 1, 7 do
	local tier, enable = 'tier'..i, 'tier'..i..'enabled'
	local option = ACH:Group(L["Tier "..i], nil, i + 4)
	option.args[enable] = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.talent[enable] end, function(_, value) local triggers = GetFilter(true) triggers.talent[enable] = value NP:ConfigureAll() end, nil, function() local triggers = GetFilter(true) return (triggers.talent.type == 'pvp' and i > 3) end)
	option.args.missing = ACH:Toggle(L["Missing"], L["Match this trigger if the talent is not selected"], 2, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.talent[tier].missing end, function(_, value) local triggers = GetFilter(true) triggers.talent[tier].missing = value NP:ConfigureAll() end, nil, function() local triggers = GetFilter(true) return (not triggers.talent[enable]) or (triggers.talent.type == 'pvp' and i > 3) end)
	option.args.column = ACH:Select(L["TALENT"], L["Talent to match"], 3, function() local triggers = GetFilter(true) return GenerateValues(i, triggers.talent.type == 'pvp') end, nil, nil, function() local triggers = GetFilter(true) return triggers.talent[tier].column end, function(_, value) local triggers = GetFilter(true) triggers.talent[tier].column = value NP:ConfigureAll() end, nil, function() local triggers = GetFilter(true) return (not triggers.talent[enable]) or (triggers.talent.type == 'pvp' and i > 3) end)
	option.inline = true

	StyleFilters.triggers.args.talent.args[tier] = option
end

StyleFilters.triggers.args.slots = ACH:Group(L["Slots"], nil, 13, nil, nil, nil, DisabledFilter)
StyleFilters.triggers.args.slots.args.types = ACH:MultiSelect(L["Equipped"], nil, 1, nil, nil, nil, function(_, key) local triggers = GetFilter(true) return triggers.slots[key] end, function(_, key, value) local triggers = GetFilter(true) triggers.slots[key] = value or nil NP:ConfigureAll() end)
StyleFilters.triggers.args.slots.args.types.sortByValue = true
StyleFilters.triggers.args.slots.args.types.values = {
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
}

StyleFilters.triggers.args.items = ACH:Group(L["Items"], nil, 14, nil, nil, nil, DisabledFilter)
StyleFilters.triggers.args.items.args.addItem = ACH:Input(L["Add Item Name or ID"], L["Add a Item Name or ID to the list."], 1, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.items[value] = true UpdateFilterList('items', nil, value, true) NP:ConfigureAll() end, nil, nil, validateString)
StyleFilters.triggers.args.items.args.removeItem = ACH:Select(L["Remove Item Name or ID"], L["Remove a Item Name or ID from the list."], 2, function() local triggers, values = GetFilter(true), {} for name in next, triggers.items do values[name] = name end return values end, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.items[value] = nil UpdateFilterList('items', nil, value) NP:ConfigureAll() end)
StyleFilters.triggers.args.items.args.negativeMatch = ACH:Toggle(L["Negative Match"], L["Match if Item Name or ID is NOT in the list."], 3, nil, nil, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end)

StyleFilters.triggers.args.items.args.list = ACH:Group('', nil, 50, nil, function(info) local triggers = GetFilter(true) return triggers.items and triggers.items[info[#info]] end, function(info, value) local triggers = GetFilter(true) if not triggers.items then triggers.items = {} end triggers.items[info[#info]] = value NP:ConfigureAll() end, nil, true)
StyleFilters.triggers.args.items.args.list.inline = true

StyleFilters.triggers.args.role = ACH:Group(L["ROLE"], nil, 15, nil, nil, nil, DisabledFilter)

for option, name in next, { myRole = L["Player"], unitRole = L["Unit"] } do
	StyleFilters.triggers.args.role.args[option] = ACH:Group(name, nil, nil, nil, function(info) local triggers = GetFilter(true) return triggers[option] and triggers[option][info[#info]] end, function(info, value) local triggers = GetFilter(true) if not triggers[option] then triggers[option] = {} end triggers[option][info[#info]] = value NP:ConfigureAll() end)
	StyleFilters.triggers.args.role.args[option].inline = true

	for role, roleLocale in next, { tank = L["Tank"], healer = L["Healer"], damager = L["DAMAGER"] } do
		StyleFilters.triggers.args.role.args[option].args[role] = ACH:Toggle(roleLocale)
	end
end

StyleFilters.triggers.args.classification = ACH:Group(L["Classification"], nil, 16, nil, function(info) local triggers = GetFilter(true) return triggers.classification[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.classification[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.classification.args.types = ACH:Group('', nil, 2)
StyleFilters.triggers.args.classification.args.types.inline = true
StyleFilters.triggers.args.classification.args.types.args.worldboss = ACH:Toggle(L["RAID_INFO_WORLD_BOSS"], nil, 1)
StyleFilters.triggers.args.classification.args.types.args.rareelite = ACH:Toggle(L["Rare Elite"], nil, 2)
StyleFilters.triggers.args.classification.args.types.args.normal = ACH:Toggle(L["PLAYER_DIFFICULTY1"], nil, 3)
StyleFilters.triggers.args.classification.args.types.args.rare = ACH:Toggle(L["ITEM_QUALITY3_DESC"], nil, 4)
StyleFilters.triggers.args.classification.args.types.args.trivial = ACH:Toggle(L["Trivial"], nil, 5)
StyleFilters.triggers.args.classification.args.types.args.elite = ACH:Toggle(L["Elite"], nil, 6)
StyleFilters.triggers.args.classification.args.types.args.minus = ACH:Toggle(L["Minus"], nil, 7)

StyleFilters.triggers.args.health = ACH:Group(L["Health Threshold"], nil, 17, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.health.args.healthThreshold = ACH:Toggle(L["Enable"], nil, 1)
StyleFilters.triggers.args.health.args.healthUsePlayer = ACH:Toggle(L["Player Health"], L["Enabling this will check your health amount."], 2, nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return not triggers.healthThreshold end)
StyleFilters.triggers.args.health.args.underHealthThreshold = ACH:Range(L["Under Health Threshold"], L["If this threshold is used then the health of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."], 4, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function() local triggers = GetFilter(true) return triggers.underHealthThreshold or 0 end, nil, function() local triggers = GetFilter(true) return not triggers.healthThreshold end)
StyleFilters.triggers.args.health.args.overHealthThreshold = ACH:Range(L["Over Health Threshold"], L["If this threshold is used then the health of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."], 5, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function() local triggers = GetFilter(true) return triggers.overHealthThreshold or 0 end, nil, function() local triggers = GetFilter(true) return not triggers.healthThreshold end)

StyleFilters.triggers.args.power = ACH:Group(L["Power Threshold"], nil, 18, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.power.args.powerThreshold = ACH:Toggle(L["Enable"], nil, 1)
StyleFilters.triggers.args.power.args.powerUsePlayer = ACH:Toggle(L["Player Power"], L["Enabling this will check your power amount."], 2, nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return not triggers.powerThreshold end)
StyleFilters.triggers.args.power.args.underPowerThreshold = ACH:Range(L["Under Power Threshold"], L["If this threshold is used then the power of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."], 4, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function() local triggers = GetFilter(true) return triggers.underPowerThreshold or 0 end, nil, function() local triggers = GetFilter(true) return not triggers.powerThreshold end)
StyleFilters.triggers.args.power.args.overPowerThreshold = ACH:Range(L["Over Power Threshold"], L["If this threshold is used then the power of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."], 4, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function() local triggers = GetFilter(true) return triggers.overPowerThreshold or 0 end, nil, function() local triggers = GetFilter(true) return not triggers.powerThreshold end)

StyleFilters.triggers.args.keyMod = ACH:Group(L["Key Modifiers"], nil, 19, nil, function(info) local triggers = GetFilter(true) return triggers.keyMod and triggers.keyMod[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.keyMod[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.keyMod.args.enable = ACH:Toggle(L["Enable"], nil, 0)
StyleFilters.triggers.args.keyMod.args.types = ACH:Group('', nil, 1, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.keyMod.enable end)
StyleFilters.triggers.args.keyMod.args.types.inline = true
StyleFilters.triggers.args.keyMod.args.types.args.Shift = ACH:Toggle(L["SHIFT_KEY_TEXT"], nil, 1)
StyleFilters.triggers.args.keyMod.args.types.args.Alt = ACH:Toggle(L["ALT_KEY_TEXT"], nil, 2)
StyleFilters.triggers.args.keyMod.args.types.args.Control = ACH:Toggle(L["CTRL_KEY_TEXT"], nil, 3)
StyleFilters.triggers.args.keyMod.args.types.args.Modifier = ACH:Toggle(L["Any"], nil, 4)
StyleFilters.triggers.args.keyMod.args.types.args.LeftShift = ACH:Toggle(L["Left Shift"], nil, 6)
StyleFilters.triggers.args.keyMod.args.types.args.LeftAlt = ACH:Toggle(L["Left Alt"], nil, 7)
StyleFilters.triggers.args.keyMod.args.types.args.LeftControl = ACH:Toggle(L["Left Control"], nil, 8)
StyleFilters.triggers.args.keyMod.args.types.args.RightShift = ACH:Toggle(L["Right Shift"], nil, 10)
StyleFilters.triggers.args.keyMod.args.types.args.RightAlt = ACH:Toggle(L["Right Alt"], nil, 11)
StyleFilters.triggers.args.keyMod.args.types.args.RightControl = ACH:Toggle(L["Right Control"], nil, 12)

StyleFilters.triggers.args.levels = ACH:Group(L["Level"], nil, 20, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.levels.args.level = ACH:Toggle(L["Enable"], nil, 1)
StyleFilters.triggers.args.levels.args.mylevel = ACH:Toggle(L["Match Player Level"], L["If enabled then the filter will only activate if the level of the unit matches your own."], 2, nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return not triggers.level end)
StyleFilters.triggers.args.levels.args.spacer1 = ACH:Description(L["LEVEL_BOSS"], 3)
StyleFilters.triggers.args.levels.args.minlevel = ACH:Range(L["Minimum Level"], L["If enabled then the filter will only activate if the level of the unit is equal to or higher than this value."], 4, { min = -1, max = _G.MAX_PLAYER_LEVEL + 3, step = 1 }, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] or 0 end, nil, function() local triggers = GetFilter(true) return not (triggers.level and not triggers.mylevel) end)
StyleFilters.triggers.args.levels.args.maxlevel = ACH:Range(L["Maximum Level"], L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."], 5, { min = -1, max = _G.MAX_PLAYER_LEVEL + 3, step = 1 }, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] or 0 end, nil, function() local triggers = GetFilter(true) return not (triggers.level and not triggers.mylevel) end)
StyleFilters.triggers.args.levels.args.curlevel = ACH:Range(L["Current Level"], L["If enabled then the filter will only activate if the level of the unit matches this value."], 6, { min = -1, max = _G.MAX_PLAYER_LEVEL + 3, step = 1 }, nil, function(info) local triggers = GetFilter(true) return triggers[info[#info]] or 0 end, nil, function() local triggers = GetFilter(true) return not (triggers.level and not triggers.mylevel) end)

StyleFilters.triggers.args.buffs = ACH:Group(L["Buffs"], nil, 21, nil, function(info) local triggers = GetFilter(true) return triggers.buffs and triggers.buffs[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.buffs[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.debuffs = ACH:Group(L["Debuffs"], nil, 22, nil, function(info) local triggers = GetFilter(true) return triggers.debuffs and triggers.debuffs[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.debuffs[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)

do
	local stackThreshold
	for _, auraType in next, { 'buffs', 'debuffs' } do
		local option = StyleFilters.triggers.args[auraType].args
		option.minTimeLeft = ACH:Range(L["Minimum Time Left"], nil, 1, { min = 0, max = 10800, step = 1 })
		option.maxTimeLeft = ACH:Range(L["Maximum Time Left"], nil, 2, { min = 0, max = 10800, step = 1 })
		option.spacer1 = ACH:Spacer(3, 'full')
		option.mustHaveAll = ACH:Toggle(L["Require All"], L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."], 4)
		option.missing = ACH:Toggle(L["Missing"], L["If enabled then it checks if auras are missing instead of being present on the unit."], 5, nil, nil, nil, nil, nil, DisabledFilter)
		option.hasStealable = ACH:Toggle(L["Has Stealable"], L["If enabled then the filter will only activate when the unit has a stealable buff(s)."], 6)
		option.hasNoStealable = ACH:Toggle(L["Has No Stealable"], L["If enabled then the filter will only activate when the unit has no stealable buff(s)."], 7)
		option.fromMe = ACH:Toggle(L["From Me"], nil, 8)
		option.fromPet = ACH:Toggle(L["From Pet"], nil, 9)

		option.changeList = ACH:Group(L["Add / Remove"], nil, 10)
		option.changeList.inline = true
		option.changeList.args.addSpell = ACH:Input(L["Add Spell ID or Name"], nil, 1, nil, nil, nil, function(_, value) if stackThreshold then value = value .. '\n' .. stackThreshold end local triggers = GetFilter(true) triggers[auraType].names[value] = true stackThreshold = nil UpdateFilterList(auraType, nil, value, true) NP:ConfigureAll() end, nil, nil, validateString)
		option.changeList.args.removeSpell = ACH:Select(L["Remove Spell ID or Name"], L["If the aura is listed with a number then you need to use that to remove it from the list."], 2, function() local triggers, values = GetFilter(true), {} for name in pairs(triggers[auraType].names) do values[name] = format('%s (%d)', strsplit('\n', name)) end return values end, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers[auraType].names[value] = nil UpdateFilterList(auraType, nil, value) end)
		option.changeList.args.stackThreshold = ACH:Range(L["Stack Threshold"], L["Allows you to tie a stack count to an aura when you add it to the list, which allows the trigger to act when an aura reaches X number of stacks."], 3, { min = 1, max = 250, softMax = 100, step = 1 }, nil, function() return stackThreshold or 1 end, function(_, value) stackThreshold = (value > 1 and value) or nil end)

		option.names = ACH:Group('', nil, 50, nil, function(info) local triggers = GetFilter(true) return triggers[auraType].names and triggers[auraType].names[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers[auraType].names[info[#info]] = value NP:ConfigureAll() end, nil, true)
		option.names.inline = true
	end
end

StyleFilters.triggers.args.buffs.args.minTimeLeft.desc = L["Apply this filter if a buff has remaining time greater than this. Set to zero to disable."]
StyleFilters.triggers.args.buffs.args.maxTimeLeft.desc = L["Apply this filter if a buff has remaining time less than this. Set to zero to disable."]
StyleFilters.triggers.args.debuffs.args.minTimeLeft.desc = L["Apply this filter if a debbuff has remaining time greater than this. Set to zero to disable."]
StyleFilters.triggers.args.debuffs.args.maxTimeLeft.desc = L["Apply this filter if a debbuff has remaining time less than this. Set to zero to disable."]

StyleFilters.triggers.args.cooldowns = ACH:Group(L["Cooldowns"], nil, 23, nil, nil, nil, DisabledFilter)
StyleFilters.triggers.args.cooldowns.args.addCooldown = ACH:Input(L["Add Spell ID or Name"], nil, 1, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.cooldowns.names[value] = 'ONCD' UpdateFilterList('cooldowns', nil, value, true) NP:ConfigureAll() end, nil, nil, validateString)
StyleFilters.triggers.args.cooldowns.args.removeCooldown = ACH:Select(L["Remove Spell ID or Name"], L["If the aura is listed with a number then you need to use that to remove it from the list."], 2, function() local values = {} local triggers = GetFilter(true) for item in next, triggers.cooldowns.names do values[item] = item end return values end, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.cooldowns.names[value] = nil UpdateFilterList('cooldowns', nil, value) NP:ConfigureAll() end)
StyleFilters.triggers.args.cooldowns.args.mustHaveAll = ACH:Toggle(L["Require All"], L["If enabled then it will require all cooldowns to activate the filter. Otherwise it will only require any one of the cooldowns to activate it."], 3, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.cooldowns and triggers.cooldowns.mustHaveAll end, function(_, value) local triggers = GetFilter(true) triggers.cooldowns.mustHaveAll = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.cooldowns.args.names = ACH:Group('', nil, 50, nil, function(info) local triggers = GetFilter(true) return triggers.cooldowns.names and triggers.cooldowns.names[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.cooldowns.names[info[#info]] = value NP:ConfigureAll() end)
StyleFilters.triggers.args.cooldowns.args.names.inline = true

StyleFilters.triggers.args.bossModAuras = ACH:Group(L["Boss Mod Auras"], nil, 24, nil, function(info) local triggers = GetFilter(true) return triggers.bossMods and triggers.bossMods[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.bossMods[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.bossModAuras.args.enable = ACH:Toggle(L["Enable"], nil, 0)
StyleFilters.triggers.args.bossModAuras.args.hasAura = ACH:Toggle(L["Has Aura"], nil, 1, nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.bossMods.enable end)
StyleFilters.triggers.args.bossModAuras.args.missingAura = ACH:Toggle(L["Missing Aura"], nil, 2, nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.bossMods.enable end)

StyleFilters.triggers.args.bossModAuras.args.seenList = ACH:Group(L["Seen Textures"], nil, 3, nil, function(info) local triggers = GetFilter(true) return triggers.bossMods and triggers.bossMods.auras and triggers.bossMods.auras[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.bossMods.auras[info[#info]] = value NP:ConfigureAll() end, function() local triggers = GetFilter(true) return DisabledFilter() or triggers.bossMods.missingAura or triggers.bossMods.hasAura or not triggers.bossMods.enable end)
StyleFilters.triggers.args.bossModAuras.args.seenList.inline = true
StyleFilters.triggers.args.bossModAuras.args.seenList.args.desc = ACH:Description(L["This list will display any textures Boss Mods have sent to the Boss Mod Auras element during the current session."], 0, 'medium')

StyleFilters.triggers.args.bossModAuras.args.changeList = ACH:Group(L["Texture Matching"], nil, 5, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or triggers.bossMods.missingAura or triggers.bossMods.hasAura or not triggers.bossMods.enable end)
StyleFilters.triggers.args.bossModAuras.args.changeList.inline = true
StyleFilters.triggers.args.bossModAuras.args.changeList.args.addAura = ACH:Input(L["Add Texture"], nil, 1, nil, nil, nil, function(_, value) local triggers = GetFilter(true) local textureID = tonumber(value) or value triggers.bossMods.auras[textureID] = true UpdateBossModAuras(nil, textureID, true) NP:ConfigureAll() end, nil, nil, validateString)
StyleFilters.triggers.args.bossModAuras.args.changeList.args.removeAura = ACH:Select(L["Remove Texture"], nil, 2, function() local triggers, values = GetFilter(true), {} for textureID in next, triggers.bossMods.auras do values[tostring(textureID)] = tostring(textureID) end return values end, nil, nil, nil, function(_, value) local triggers = GetFilter(true) local textureID = tonumber(value) or value triggers.bossMods.auras[textureID] = nil UpdateBossModAuras(nil, textureID) NP:ConfigureAll() end)
StyleFilters.triggers.args.bossModAuras.args.changeList.args.missingAuras = ACH:Toggle(L["Missing Aura"], nil, 2, nil, nil, nil, function(info) local triggers = GetFilter(true) return triggers.bossMods[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.bossMods[info[#info]] = value NP:ConfigureAll() end)

StyleFilters.triggers.args.bossModAuras.args.auras = ACH:Group('', nil, 50, nil, function(info) local triggers = GetFilter(true) return triggers.bossMods and triggers.bossMods.auras and triggers.bossMods.auras[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.bossMods.auras[info[#info]] = value NP:ConfigureAll() end, function() local triggers = GetFilter(true) return DisabledFilter() or triggers.bossMods.missingAura or triggers.bossMods.hasAura or not triggers.bossMods.enable end)
StyleFilters.triggers.args.bossModAuras.args.auras.inline = true

StyleFilters.triggers.args.threat = ACH:Group(L["Threat"], nil, 25, nil, nil, nil, DisabledFilter)
StyleFilters.triggers.args.threat.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.threat and triggers.threat.enable end, function(_, value) local triggers = GetFilter(true) triggers.threat.enable = value NP:ConfigureAll() end)
StyleFilters.triggers.args.threat.args.types = ACH:Group('', nil, 1, nil, function(info) local triggers = GetFilter(true) return triggers.threat[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.threat[info[#info]] = value NP:ConfigureAll() end, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.threat.enable end)
StyleFilters.triggers.args.threat.args.types.inline = true
StyleFilters.triggers.args.threat.args.types.args.good = ACH:Toggle(L["Good"], nil, 1)
StyleFilters.triggers.args.threat.args.types.args.goodTransition = ACH:Toggle(L["Good Transition"], nil, 2)
StyleFilters.triggers.args.threat.args.types.args.badTransition = ACH:Toggle(L["Bad Transition"], nil, 3)
StyleFilters.triggers.args.threat.args.types.args.bad = ACH:Toggle(L["Bad"], nil, 4)
StyleFilters.triggers.args.threat.args.types.args.spacer1 = ACH:Spacer(5, 'full')
StyleFilters.triggers.args.threat.args.types.args.offTank = ACH:Toggle(L["Off Tank"], nil, 6)
StyleFilters.triggers.args.threat.args.types.args.offTankGoodTransition = ACH:Toggle(L["Off Tank Good Transition"], nil, 7, nil, nil, 200)
StyleFilters.triggers.args.threat.args.types.args.offTankBadTransition = ACH:Toggle(L["Off Tank Bad Transition"], nil, 8, nil, nil, 200)

StyleFilters.triggers.args.nameplateType = ACH:Group(L["Unit Type"], nil, 26, nil, nil, nil, DisabledFilter)
StyleFilters.triggers.args.nameplateType.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function() local triggers = GetFilter(true) return triggers.nameplateType and triggers.nameplateType.enable end, function(_, value) local triggers = GetFilter(true) triggers.nameplateType.enable = value NP:ConfigureAll() end)
StyleFilters.triggers.args.nameplateType.args.types = ACH:Group('', nil, 1, nil, function(info) local triggers = GetFilter(true) return triggers.nameplateType[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.nameplateType[info[#info]] = value NP:ConfigureAll() end, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.nameplateType.enable end)
StyleFilters.triggers.args.nameplateType.args.types.inline = true

for frameType, keyName in next, E.NamePlates.TriggerConditions.frameTypes do
	StyleFilters.triggers.args.nameplateType.args.types.args[keyName] = ACH:Toggle(L[frameType == 'PLAYER' and 'Player' or frameType])
end

StyleFilters.triggers.args.reactionType = ACH:Group(L["Reaction Type"], nil, 27, nil, function(info) local triggers = GetFilter(true) return triggers.reactionType and triggers.reactionType[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.reactionType[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.reactionType.args.enable = ACH:Toggle(L["Enable"], nil, 0)
StyleFilters.triggers.args.reactionType.args.reputation = ACH:Toggle(L["Reputation"], L["If this is enabled then the reaction check will use your reputation with the faction the unit belongs to."], 1, nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.reactionType.enable end)
StyleFilters.triggers.args.reactionType.args.types = ACH:Group('', nil, 2, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.reactionType.enable end)
StyleFilters.triggers.args.reactionType.args.types.inline = true

for i, reactionType in next, E.NamePlates.TriggerConditions.reactions do
	StyleFilters.triggers.args.reactionType.args.types.args[reactionType] = ACH:Toggle(L["FACTION_STANDING_LABEL"..i], nil, i)
end

StyleFilters.triggers.args.creatureType = ACH:Group(L["Creature Type"], nil, 28, nil, function(info) local triggers = GetFilter(true) return triggers.creatureType[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.creatureType[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.creatureType.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, 'full')
StyleFilters.triggers.args.creatureType.args.types = ACH:Group('', nil, 2, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.creatureType.enable end)
StyleFilters.triggers.args.creatureType.args.types.inline = true

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

	for k, v in next, E.CreatureTypes do
		StyleFilters.triggers.args.creatureType.args.types.args[v] = ACH:Toggle(k, nil, creatureTypeOrder[v], nil, nil, nil, nil, nil, function() local triggers = GetFilter(true) return DisabledFilter() or not triggers.creatureType.enable end)
	end
end

StyleFilters.triggers.args.instanceType = ACH:Group(L["Instance Type"], nil, 29, nil, function(info) local triggers = GetFilter(true) return triggers.instanceType[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.instanceType[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.instanceType.args.types = ACH:Group('', nil, 2)
StyleFilters.triggers.args.instanceType.args.types.inline = true
StyleFilters.triggers.args.instanceType.args.types.args.none = ACH:Toggle(L["None"], nil, 1)
StyleFilters.triggers.args.instanceType.args.types.args.scenario = ACH:Toggle(L["SCENARIOS"], nil, 2, nil, nil, nil, nil, nil, nil, not E.Retail)
StyleFilters.triggers.args.instanceType.args.types.args.party = ACH:Toggle(L["Party"], nil, 5)
StyleFilters.triggers.args.instanceType.args.types.args.raid = ACH:Toggle(L["Raid"], nil, 5)
StyleFilters.triggers.args.instanceType.args.types.args.arena = ACH:Toggle(L["Arena"], nil, 7, nil, nil, nil, nil, nil, nil, E.Classic)
StyleFilters.triggers.args.instanceType.args.types.args.pvp = ACH:Toggle(L["BATTLEFIELDS"], nil, 8)

StyleFilters.triggers.args.instanceType.args.dungeonDifficulty = ACH:MultiSelect(L["DUNGEON_DIFFICULTY"], L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."], 10, { normal = GetDifficultyInfo(1), heroic = GetDifficultyInfo(2) }, nil, nil, function(_, key) local triggers = GetFilter(true) return triggers.instanceDifficulty.dungeon[key] end, function(_, key, value) local triggers = GetFilter(true) triggers.instanceDifficulty.dungeon[key] = value NP:ConfigureAll() end, nil, function() local filter = GetFilter() return not filter.triggers.instanceType.party end)

if E.Retail then
	StyleFilters.triggers.args.instanceType.args.dungeonDifficulty.values.mythic = GetDifficultyInfo(23)
	StyleFilters.triggers.args.instanceType.args.dungeonDifficulty.values['mythic+'] = GetDifficultyInfo(8)
	StyleFilters.triggers.args.instanceType.args.dungeonDifficulty.values.timewalking = GetDifficultyInfo(24)
end

StyleFilters.triggers.args.instanceType.args.raidDifficulty = ACH:MultiSelect(L["Raid Difficulty"], L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."], 11, { legacy10normal = GetDifficultyInfo(3), legacy25normal = GetDifficultyInfo(4) }, nil, nil, function(_, key) local triggers = GetFilter(true) return triggers.instanceDifficulty.raid[key] end, function(_, key, value) local triggers = GetFilter(true) triggers.instanceDifficulty.raid[key] = value NP:ConfigureAll() end, nil, function() local filter = GetFilter() return not filter.triggers.instanceType.raid end)

if E.Retail then
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.lfr = GetDifficultyInfo(17)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.normal = GetDifficultyInfo(14)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.heroic = GetDifficultyInfo(15)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.mythic = GetDifficultyInfo(16)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.timewalking = GetDifficultyInfo(24)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.legacy10heroic = GetDifficultyInfo(5)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.legacy25heroic = GetDifficultyInfo(6)
else
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.legacy40normal = GetDifficultyInfo(9)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.legacy20normal = GetDifficultyInfo(148)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.normal = GetDifficultyInfo(173)
	StyleFilters.triggers.args.instanceType.args.raidDifficulty.values.heroic = GetDifficultyInfo(174)
end

local removeLocationTable = { removeMapID = 'mapIDs', removeInstanceID = 'instanceIDs', removeZoneName = 'zoneNames', removeSubZoneName = 'subZoneNames' }
local function removeLocationList(info)
	local vals = {}
	local triggers = GetFilter(true)
	local idTable = removeLocationTable[info[#info]]
	local ids = triggers.location[idTable]
	if not (ids and next(ids)) then return vals end

	for value in pairs(ids) do
		local infoTable
		if idTable == 'instanceIDs' or idTable == 'mapIDs' then
			infoTable = tonumber(value) and (idTable == 'instanceIDs' and GetRealZoneText(value) or C_Map_GetMapInfo(value))
			if infoTable then
				infoTable = '|cFF999999('..value..')|r '..(infoTable.name or infoTable)
			end
		end
		vals[value] = infoTable or value
	end
	return vals
end

StyleFilters.triggers.args.location = ACH:Group(L["Location"], nil, 30, nil, function(info) local triggers = GetFilter(true) return triggers.location[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.location[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)

StyleFilters.triggers.args.location.args.map = ACH:Group('', nil, 1)
StyleFilters.triggers.args.location.args.map.inline = true
StyleFilters.triggers.args.location.args.map.args.mapIDEnabled = ACH:Toggle(L["Use Map ID or Name"], L["If enabled, the style filter will only activate when you are in one of the maps specified in Map ID."], 1, nil, nil, 200)
StyleFilters.triggers.args.location.args.map.args.mapIDs = ACH:Input(L["Add Map ID"], nil, 2, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.mapIDs[value] = true NP:ConfigureAll() end, function () local triggers = GetFilter(true) return not triggers.location.mapIDEnabled end, nil, function(_, value) local triggers = GetFilter(true) return not (strmatch(value, '^[%s%p]-$') or triggers.location.mapIDs[value]) end)
StyleFilters.triggers.args.location.args.map.args.removeMapID = ACH:Select(L["Remove Map ID"], nil, 3, removeLocationList, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.mapIDs[value] = nil NP:ConfigureAll() end, function() local triggers = GetFilter(true) local ids = triggers.location.mapIDs return not (triggers.location.mapIDEnabled and ids and next(ids)) end)

StyleFilters.triggers.args.location.args.instance = ACH:Group('', nil, 2)
StyleFilters.triggers.args.location.args.instance.inline = true
StyleFilters.triggers.args.location.args.instance.args.instanceIDEnabled = ACH:Toggle(L["Use Instance ID or Name"], L["If enabled, the style filter will only activate when you are in one of the instances specified in Instance ID."], 1, nil, nil, 200)
StyleFilters.triggers.args.location.args.instance.args.instanceIDs = ACH:Input(L["Add Instance ID"], nil, 2, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.instanceIDs[value] = true NP:ConfigureAll() end, function() local triggers = GetFilter(true) return not triggers.location.instanceIDEnabled end, nil, function(_, value) local triggers = GetFilter(true) return not (strmatch(value, '^[%s%p]-$') or triggers.location.instanceIDs[value]) end)
StyleFilters.triggers.args.location.args.instance.args.removeInstanceID = ACH:Select(L["Remove Instance ID"], nil, 3, removeLocationList, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.instanceIDs[value] = nil NP:ConfigureAll() end, function() local triggers = GetFilter(true) local ids = triggers.location.instanceIDs return not (triggers.location.instanceIDEnabled and ids and next(ids)) end)

StyleFilters.triggers.args.location.args.zoneName = ACH:Group('', nil, 3)
StyleFilters.triggers.args.location.args.zoneName.inline = true
StyleFilters.triggers.args.location.args.zoneName.args.zoneNamesEnabled = ACH:Toggle(L["Use Zone Names"], L["If enabled, the style filter will only activate when you are in one of the zones specified in Add Zone Name."], 1, nil, nil, 200)
StyleFilters.triggers.args.location.args.zoneName.args.zoneNames = ACH:Input(L["Add Zone Name"], nil, 2, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.zoneNames[value] = true NP:ConfigureAll() end, function () local triggers = GetFilter(true) return not triggers.location.zoneNamesEnabled end, nil, function(_, value) local triggers = GetFilter(true) return not (strmatch(value, '^[%s%p]-$') or triggers.location.zoneNames[value]) end)
StyleFilters.triggers.args.location.args.zoneName.args.removeZoneName = ACH:Select(L["Remove Zone Name"], nil, 3, removeLocationList, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.zoneNames[value] = nil NP:ConfigureAll() end, function() local triggers = GetFilter(true) local zone = triggers.location.zoneNames return not (triggers.location.zoneNamesEnabled and zone and next(zone)) end)

StyleFilters.triggers.args.location.args.subZoneName = ACH:Group('', nil, 4)
StyleFilters.triggers.args.location.args.subZoneName.inline = true
StyleFilters.triggers.args.location.args.subZoneName.args.subZoneNamesEnabled = ACH:Toggle(L["Use Subzone Names"], L["If enabled, the style filter will only activate when you are in one of the subzones specified in Add Subzone Name."], 1, nil, nil, 200)
StyleFilters.triggers.args.location.args.subZoneName.args.subZoneNames = ACH:Input(L["Add Subzone Name"], nil, 2, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.subZoneNames[value] = true NP:ConfigureAll() end, function () local triggers = GetFilter(true) return not triggers.location.subZoneNamesEnabled end)
StyleFilters.triggers.args.location.args.subZoneName.args.removeSubZoneName = ACH:Select(L["Remove Subzone Name"], nil, 3, removeLocationList, nil, nil, nil, function(_, value) local triggers = GetFilter(true) triggers.location.subZoneNames[value] = nil NP:ConfigureAll() end, function() local triggers = GetFilter(true) local zone = triggers.location.subZoneNames return not (triggers.location.subZoneNamesEnabled and zone and next(zone)) end)

StyleFilters.triggers.args.location.args.btns = ACH:Group(L["Add Current"], nil, 5)
StyleFilters.triggers.args.location.args.btns.inline = true
StyleFilters.triggers.args.location.args.btns.args.mapID = ACH:Execute(L["Map ID"], nil, 1, function() local mapID = E.MapInfo.mapID if not mapID then return end mapID = tostring(mapID) local triggers = GetFilter(true) if triggers.location.mapIDs[mapID] then return end triggers.location.mapIDs[mapID] = true NP:ConfigureAll() E:Print(format(L["Added Map ID: %s"], E.MapInfo.name..' ('..mapID..')')) end, nil, nil, 130)
StyleFilters.triggers.args.location.args.btns.args.instanceID = ACH:Execute(L["Instance ID"], nil, 2, function() local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo() if not instanceID then return end instanceID = tostring(instanceID) local triggers = GetFilter(true) if triggers.location.instanceIDs[instanceID] then return end triggers.location.instanceIDs[instanceID] = true NP:ConfigureAll() E:Print(format(L["Added Instance ID: %s"], instanceName..' ('..instanceID..')')) end, nil, nil, 130)
StyleFilters.triggers.args.location.args.btns.args.zoneName = ACH:Execute(L["Zone Name"], nil, 3, function() local zone = E.MapInfo.realZoneText if not zone then return end local triggers = GetFilter(true) if triggers.location.zoneNames[zone] then return end triggers.location.zoneNames[zone] = true NP:ConfigureAll() E:Print(format(L["Added Zone Name: %s"], zone)) end, nil, nil, 130)
StyleFilters.triggers.args.location.args.btns.args.subZoneName = ACH:Execute(L["Subzone Name"], nil, 4, function() local subZone = E.MapInfo.subZoneText if not subZone then return end local triggers = GetFilter(true) if triggers.location.subZoneNames[subZone] then return end triggers.location.subZoneNames[subZone] = true NP:ConfigureAll() E:Print(format(L["Added Subzone Name: %s"], subZone)) end, nil, nil, 130)

StyleFilters.triggers.args.raidTarget = ACH:Group(L["BINDING_HEADER_RAID_TARGET"], nil, 31, nil, function(info) local triggers = GetFilter(true) return triggers.raidTarget[info[#info]] end, function(info, value) local triggers = GetFilter(true) triggers.raidTarget[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.triggers.args.raidTarget.args.types = ACH:Group('')
StyleFilters.triggers.args.raidTarget.args.types.inline = true

for i, iconName in next, E.NamePlates.TriggerConditions.raidTargets do
	StyleFilters.triggers.args.raidTarget.args.types.args[iconName] = ACH:Toggle(format(raidTargetIcon, i, L["RAID_TARGET_"..i]), nil, i)
end

local actionDefaults = {
	color = {
		healthColor = { r = 0.53, g = 1.00, b = 0.40, a = 1 },
		powerColor = { r = 0.40, g = 0.53, b = 1.00, a = 1 },
		borderColor = { r = 0, g = 0, b = 0, a = 1}
	},
	flash = {
		color = { r = 0.41, g = 0.54, b = 0.85, a = 1 },
		speed = 4
	},
}

local function actionHidePlate() local _, actions = GetFilter(true) return actions.hide end
local function actionSubGroup(info, ...)
	local _, actions = GetFilter(true)
	if not actions then return end

	if info.type == 'color' then
		local t = actions[info[#info-1]][info[#info]]
		local r, g, b, a = ...
		if r then
			t.r, t.g, t.b, t.a = r, g, b, a
		else
			local d = actionDefaults[info[#info-1]][info[#info]]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if value ~= nil then
			actions[info[#info-1]][info[#info]] = value
		else
			return actions[info[#info-1]][info[#info]]
		end
	end

	NP:ConfigureAll()
end

StyleFilters.actions = ACH:Group(L["Actions"], nil, 10, nil, function(info) local _, actions = GetFilter(true) return actions[info[#info]] end, function(info, value) local _, actions = GetFilter(true) actions[info[#info]] = value NP:ConfigureAll() end, DisabledFilter)
StyleFilters.actions.args.hide = ACH:Toggle(L["Hide Frame"], nil, 1)
StyleFilters.actions.args.usePortrait = ACH:Toggle(L["Use Portrait"], nil, 2, nil, nil, nil, nil, nil, actionHidePlate)
StyleFilters.actions.args.nameOnly = ACH:Toggle(L["Name Only"], nil, 3, nil, nil, nil, nil, nil, actionHidePlate)
StyleFilters.actions.args.spacer1 = ACH:Spacer(4, 'full')
StyleFilters.actions.args.scale = ACH:Range(L["Scale"], nil, 5, { min = .25, max = 1.5, softMin = .5, softMax = 1.25, step = .01 }, nil, nil, nil, actionHidePlate)
StyleFilters.actions.args.alpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 6, { min = -1, max = 100, step = 1 }, nil, nil, nil, actionHidePlate)

StyleFilters.actions.args.color = ACH:Group(L["COLOR"], nil, 10, nil, actionSubGroup, actionSubGroup, actionHidePlate)
StyleFilters.actions.args.color.inline = true
StyleFilters.actions.args.color.args.health = ACH:Toggle(L["Health"], nil, 1)
StyleFilters.actions.args.color.args.healthColor = ACH:Color(L["Health Color"], nil, 2, true)
StyleFilters.actions.args.color.args.healthClass = ACH:Toggle(L["Unit Class Color"], nil, 3)
StyleFilters.actions.args.color.args.spacer1 = ACH:Spacer(4, 'full')
StyleFilters.actions.args.color.args.power = ACH:Toggle(L["Power"], nil, 10)
StyleFilters.actions.args.color.args.powerColor = ACH:Color(L["Power Color"], nil, 11, true)
StyleFilters.actions.args.color.args.powerClass = ACH:Toggle(L["Unit Class Color"], nil, 12)
StyleFilters.actions.args.color.args.spacer2 = ACH:Spacer(13, 'full')
StyleFilters.actions.args.color.args.border = ACH:Toggle(L["Border"], nil, 20)
StyleFilters.actions.args.color.args.borderColor = ACH:Color(L["Border Color"], nil, 21, true)
StyleFilters.actions.args.color.args.borderClass = ACH:Toggle(L["Unit Class Color"], nil, 22)

StyleFilters.actions.args.texture = ACH:Group(L["Texture"], nil, 20, nil, actionSubGroup, actionSubGroup, actionHidePlate)
StyleFilters.actions.args.texture.inline = true
StyleFilters.actions.args.texture.args.enable = ACH:Toggle(L["Enable"], nil, 1)
StyleFilters.actions.args.texture.args.texture = ACH:SharedMediaStatusbar(L["Texture"], nil, 2, nil, nil, nil, function() local _, actions = GetFilter(true) return not actions.texture.enable end)

StyleFilters.actions.args.flash = ACH:Group(L["Flash"], nil, 30, nil, actionSubGroup, actionSubGroup, actionHidePlate)
StyleFilters.actions.args.flash.inline = true
StyleFilters.actions.args.flash.args.enable = ACH:Toggle(L["Enable"], nil, 1)
StyleFilters.actions.args.flash.args.color = ACH:Color(L["COLOR"], nil, 2, true)
StyleFilters.actions.args.flash.args.class = ACH:Toggle(L["Unit Class Color"], nil, 3)
StyleFilters.actions.args.flash.args.speed = ACH:Range(L["SPEED"], nil, nil, { min = 1, max = 10, step = 1 })

StyleFilters.actions.args.text_format = ACH:Group(L["Text Format"], nil, 40, nil, function(info) local _, actions = GetFilter(true) return actions.tags[info[#info]] end, function(info, value) local _, actions = GetFilter(true) actions.tags[info[#info]] = value NP:ConfigureAll() end)
StyleFilters.actions.args.text_format.inline = true
StyleFilters.actions.args.text_format.args.info = ACH:Description(L["Controls the text displayed. Tags are available in the Available Tags section of the config."], 1, 'medium')
StyleFilters.actions.args.text_format.args.name = ACH:Input(L["Name"], nil, 1, nil, 'full')
StyleFilters.actions.args.text_format.args.level = ACH:Input(L["Level"], nil, 2, nil, 'full')
StyleFilters.actions.args.text_format.args.title = ACH:Input(L["Title"], nil, 3, nil, 'full')
StyleFilters.actions.args.text_format.args.health = ACH:Input(L["Health"], nil, 4, nil, 'full')
StyleFilters.actions.args.text_format.args.power = ACH:Input(L["Power"], nil, 5, nil, 'full')

-- Import / Export
local function DecodeString(text)
	if not LibBase64:IsBase64(text) then return end

	local profileType, profileKey, profileData = D:Decode(text)
	if profileType == 'styleFilters' then
		local decodedText = (profileData and E:TableToLuaString(profileData)) or nil
		return D:CreateProfileExport(decodedText, profileType, profileKey)
	else
		return ''
	end
end

local function DecodeLabel(label, text)
	if not validateString(nil, text) then
		label.name = ''
		return text
	end

	local decode = DecodeString(text)
	if decode then
		return decode
	else
		label.name = L["Error decoding data. Import string may be corrupted!"]
		return text
	end
end

do
	local importText = ''
	local label = ACH:Description('', 1)
	local function Import_Set() end
	local function Import_Get() return importText end
	local function Import_TextChanged(text) if text ~= importText then importText = text end end
	local function Import_Decode() importText = DecodeLabel(label, importText) end
	local function Import_Button()
		if not validateString(nil, importText) then return end
		label.name = (D:Decode(importText) == 'styleFilters' and D:ImportProfile(importText) and L["Profile imported successfully!"]) or L["Error decoding data. Import string may be corrupted!"]
	end

	StyleFilters.import = ACH:Group(L["Import"], nil, 15)
	StyleFilters.import.args.label = label
	StyleFilters.import.args.text = ACH:Input('', nil, 1, 10, 'full', Import_Get, Import_Set)
	StyleFilters.import.args.text.disableButton = true
	StyleFilters.import.args.text.textChanged = Import_TextChanged
	StyleFilters.import.args.importButton = ACH:Execute(L["Import"], nil, 2, Import_Button)
	StyleFilters.import.args.importDecode = ACH:Execute(L["Decode"], nil, 3, Import_Decode)
end

do
	local exportText = ''
	local label = ACH:Description('', 5)
	local function Filters_Empty() if not next(exportList) then StyleFilters.export.args.text.hidden = true return true end end
	local function Filters_Get(_, key) Filters_Empty() return exportList[key] end
	local function Filters_Set(_, key, value) exportList[key] = value or nil end
	local function Export_Get() label.name = '' return exportText end
	local function Export_Set() end
	local function Export_Decode() exportText = DecodeLabel(label, exportText) end
	local function Export_Button()
		local data = {nameplates = {filters = {}}}

		if Filters_Empty() then return end

		for key in pairs(exportList) do
			data.nameplates.filters[key] = E:CopyTable({}, E.global.nameplates.filters[key])
		end

		NP:StyleFilterClearDefaults(data.nameplates.filters)
		data = E:RemoveTableDuplicates(data, G, D.GeneratedKeys.global)

		local serialData = D:Serialize(data)
		local exportString = D:CreateProfileExport(serialData, 'styleFilters', 'styleFilters')
		local compressedData = LibCompress:Compress(exportString)
		local encodedData = LibBase64:Encode(compressedData)

		exportText = encodedData
		StyleFilters.export.args.text.hidden = not exportText
	end

	StyleFilters.export = ACH:Group(L["Export"], nil, 20)
	StyleFilters.export.args.filters = ACH:MultiSelect(L["Filters"], nil, 2, GetFilters, nil, nil, Filters_Get, Filters_Set)
	StyleFilters.export.args.filters.sortByValue = true
	StyleFilters.export.args.exportButton = ACH:Execute(L["Export"], nil, 3, Export_Button)
	StyleFilters.export.args.exportDecode = ACH:Execute(L["Decode"], nil, 4, Export_Decode)
	StyleFilters.export.args.label = label
	StyleFilters.export.args.text = ACH:Input('', nil, -1, 10, 'full', Export_Get, Export_Set, nil, true)
	StyleFilters.export.args.text.disableButton = true
end
