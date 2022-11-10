local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF
local Tags = ElvUF.Tags

local LCS = E.Libs.LCS
local RangeCheck = E.Libs.RangeCheck
local Translit = E.Libs.Translit
local translitMark = '!'

local _G = _G
local next, type, gmatch, gsub, format = next, type, gmatch, gsub, format
local ipairs, pairs, wipe, floor, ceil = ipairs, pairs, wipe, floor, ceil
local strfind, strmatch, strlower, strsplit = strfind, strmatch, strlower, strsplit
local utf8lower, utf8sub, utf8len = string.utf8lower, string.utf8sub, string.utf8len

local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetCurrentTitle = GetCurrentTitle
local GetCVarBool = GetCVarBool
local GetGuildInfo = GetGuildInfo
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetPetLoyalty = GetPetLoyalty
local GetPVPRankInfo = GetPVPRankInfo
local GetPVPTimer = GetPVPTimer
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
local GetRuneCooldown = GetRuneCooldown
local GetSpecialization = (E.Classic or E.Wrath and LCS.GetSpecialization) or GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetTime = GetTime
local GetTitleName = GetTitleName
local GetUnitSpeed = GetUnitSpeed
local HasPetUI = HasPetUI
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsInInstance = IsInInstance
local QuestDifficultyColors = QuestDifficultyColors
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitAffectingCombat = UnitAffectingCombat
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsAFK = UnitIsAFK
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDND = UnitIsDND
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsUnit = UnitIsUnit
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitPVPName = UnitPVPName
local UnitPVPRank = UnitPVPRank
local UnitReaction = UnitReaction
local UnitSex = UnitSex
local UnitStagger = UnitStagger

local GetUnitPowerBarTextureInfo = GetUnitPowerBarTextureInfo
local C_QuestLog_GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local C_QuestLog_GetQuestDifficultyLevel = C_QuestLog.GetQuestDifficultyLevel
local C_PetJournal_GetPetTeamAverageLevel = C_PetJournal and C_PetJournal.GetPetTeamAverageLevel

local LEVEL = strlower(LEVEL)

local POWERTYPE_MANA = Enum.PowerType.Mana
local POWERTYPE_COMBOPOINTS = Enum.PowerType.ComboPoints
local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate

local SPEC_MONK_BREWMASTER = SPEC_MONK_BREWMASTER
local UNITNAME_SUMMON_TITLE17 = UNITNAME_SUMMON_TITLE17
local UNKNOWN = UNKNOWN
local PVP = PVP

-- GLOBALS: ElvUF, Hex, _TAGS, _COLORS

local RefreshNewTags -- will turn true at EOF
function E:AddTag(tagName, eventsOrSeconds, func, block)
	if block then return end -- easy killer for tags

	if type(eventsOrSeconds) == 'number' then
		Tags.OnUpdateThrottle[tagName] = eventsOrSeconds
	else
		Tags.Events[tagName] = (E.Retail and gsub(eventsOrSeconds, 'UNIT_HEALTH_FREQUENT', 'UNIT_HEALTH')) or gsub(eventsOrSeconds, 'UNIT_HEALTH([^%s_]?)', 'UNIT_HEALTH_FREQUENT%1')
	end

	Tags.Methods[tagName] = func

	if RefreshNewTags then
		Tags:RefreshEvents(tagName)
		Tags:RefreshMethods(tagName)
	end
end

function E:CallTag(tag, ...)
	local func = ElvUF.Tags.Methods[tag]
	if func then
		return func(...)
	end
end

--Expose local functions for plugins onto this table
E.TagFunctions = {}

------------------------------------------------------------------------
--	Tag Extra Events
------------------------------------------------------------------------

Tags.SharedEvents.INSTANCE_ENCOUNTER_ENGAGE_UNIT = true
Tags.SharedEvents.PLAYER_GUILD_UPDATE = true
Tags.SharedEvents.PLAYER_TALENT_UPDATE = true
Tags.SharedEvents.QUEST_LOG_UPDATE = true

------------------------------------------------------------------------
--	Tag Functions
------------------------------------------------------------------------

local function UnitEffectiveLevel(unit)
	if E.Retail then
		return _G.UnitEffectiveLevel(unit)
	else
		return UnitLevel(unit)
	end
end
E.TagFunctions.UnitEffectiveLevel = UnitEffectiveLevel

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)

	if name == UNKNOWN and E.myclass == 'MONK' and UnitIsUnit(unit, 'pet') then
		name = format(UNITNAME_SUMMON_TITLE17, _G.UnitName('player'))
	end

	if realm and realm ~= '' then
		return name, realm
	else
		return name
	end
end
E.TagFunctions.UnitName = UnitName

local function Abbrev(name)
	local letters, lastWord = '', strmatch(name, '.+%s(.+)$')
	if lastWord then
		for word in gmatch(name, '.-%s') do
			local firstLetter = utf8sub(gsub(word, '^[%s%p]*', ''), 1, 1)
			if firstLetter ~= utf8lower(firstLetter) then
				letters = format('%s%s. ', letters, firstLetter)
			end
		end
		name = format('%s%s', letters, lastWord)
	end
	return name
end
E.TagFunctions.Abbrev = Abbrev

-- percentages at which the bar should change color
local STAGGER_YELLOW_TRANSITION = STAGGER_YELLOW_TRANSITION
local STAGGER_RED_TRANSITION = STAGGER_RED_TRANSITION
-- table indices of bar colors
local STAGGER_GREEN_INDEX = STAGGER_GREEN_INDEX or 1
local STAGGER_YELLOW_INDEX = STAGGER_YELLOW_INDEX or 2
local STAGGER_RED_INDEX = STAGGER_RED_INDEX or 3

local ClassPowers = {
	MONK		= Enum.PowerType.Chi,
	MAGE		= Enum.PowerType.ArcaneCharges,
	PALADIN		= Enum.PowerType.HolyPower,
	DEATHKNIGHT	= Enum.PowerType.Runes,
	WARLOCK		= Enum.PowerType.SoulShards
}

local function GetClassPower(Class)
	local spec = GetSpecialization()
	local min, max, r, g, b

	-- try stagger
	local monk = Class == 'MONK'
	if monk and spec == SPEC_MONK_BREWMASTER then
		min = UnitStagger('player') or 0
		max = UnitHealthMax('player')

		local staggerRatio = min / max
		local staggerIndex = (staggerRatio >= STAGGER_RED_TRANSITION and STAGGER_RED_INDEX) or (staggerRatio >= STAGGER_YELLOW_TRANSITION and STAGGER_YELLOW_INDEX) or STAGGER_GREEN_INDEX
		local color = ElvUF.colors.power.STAGGER[staggerIndex]
		r, g, b = color.r, color.g, color.b
	end

	-- try special powers or combo points
	local barType = not r and ClassPowers[Class]
	if barType then
		local dk = Class == 'DEATHKNIGHT'
		min = (dk and 0) or UnitPower('player', barType)
		max = (dk and 6) or UnitPowerMax('player', barType)

		if dk then
			for i = 1, max do
				local _, _, runeReady = GetRuneCooldown(i)
				if runeReady then
					min = min + 1
				end
			end
		end

		if min > 0 then
			local power = ElvUF.colors.ClassBars[Class]
			local color = (monk and power[min]) or (dk and (E.Wrath and ElvUF.colors.class.DEATHKNIGHT or power[spec ~= 5 and spec or 1])) or power
			r, g, b = color.r, color.g, color.b
		end
	elseif not r then
		min = UnitPower('player', POWERTYPE_COMBOPOINTS)
		max = UnitPowerMax('player', POWERTYPE_COMBOPOINTS)

		if min > 0 then
			local combo = ElvUF.colors.ComboPoints
			local c1, c2, c3 = combo[1], combo[2], combo[3]
			r, g, b = ElvUF:ColorGradient(min, max, c1.r, c1.g, c1.b, c2.r, c2.g, c2.b, c3.r, c3.g, c3.b)
		end
	end

	-- try additional mana
	local barIndex = not r and E.Retail and _G.ADDITIONAL_POWER_BAR_INDEX == 0 and _G.ALT_MANA_BAR_PAIR_DISPLAY_INFO[Class]
	if barIndex and barIndex[UnitPowerType('player')] then
		min = UnitPower('player', POWERTYPE_MANA)
		max = UnitPowerMax('player', POWERTYPE_MANA)

		local mana = ElvUF.colors.power.MANA
		r, g, b = mana.r, mana.g, mana.b
	end

	return min or 0, max or 0, r or 1, g or 1, b or 1
end
E.TagFunctions.GetClassPower = GetClassPower

------------------------------------------------------------------------
--	Looping
------------------------------------------------------------------------

for _, vars in ipairs({'',':min',':max'}) do
	E:AddTag(format('range%s', vars), 0.1, function(unit)
		if UnitIsConnected(unit) and not UnitIsUnit(unit, 'player') then
			local minRange, maxRange = RangeCheck:GetRange(unit, true)

			if vars == ':min' then
				if minRange then
					return format('%d', minRange)
				end
			elseif vars == ':max' then
				if maxRange then
					return format('%d', maxRange)
				end
			elseif minRange or maxRange then
				return format('%s - %s', minRange or '??', maxRange or '??')
			end
		end
	end)
end

for textFormat in pairs(E.GetFormattedTextStyles) do
	local tagFormat = strlower(gsub(textFormat, '_', '-'))
	E:AddTag(format('health:%s', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
		local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		if status then
			return status
		else
			return E:GetFormattedText(textFormat, UnitHealth(unit), UnitHealthMax(unit))
		end
	end)

	E:AddTag(format('health:%s-nostatus', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
		return E:GetFormattedText(textFormat, UnitHealth(unit), UnitHealthMax(unit))
	end)

	E:AddTag(format('power:%s', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
		local powerType = UnitPowerType(unit)
		local min = UnitPower(unit, powerType)
		if min ~= 0 then
			return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, powerType))
		end
	end)

	E:AddTag(format('additionalmana:%s', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
		local barIndex = _G.ADDITIONAL_POWER_BAR_INDEX == 0 and _G.ALT_MANA_BAR_PAIR_DISPLAY_INFO[E.myclass]
		if barIndex and barIndex[UnitPowerType(unit)] then
			local min = UnitPower(unit, POWERTYPE_MANA)
			if min ~= 0 then
				return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA))
			end
		end
	end, not E.Retail)

	E:AddTag(format('mana:%s', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
		local min = UnitPower(unit, POWERTYPE_MANA)
		if min ~= 0 then
			return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA))
		end
	end)

	E:AddTag(format('classpower:%s', tagFormat), (E.myclass == 'MONK' and 'UNIT_AURA ' or E.myclass == 'DEATHKNIGHT' and 'RUNE_POWER_UPDATE ' or '') .. 'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER', function()
		local min, max = GetClassPower(E.myclass)
		if min ~= 0 then
			return E:GetFormattedText(textFormat, min, max)
		end
	end, E.Classic)

	E:AddTag(format('altpower:%s', tagFormat), 'UNIT_POWER_UPDATE UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE', function(unit)
		local cur = UnitPower(unit, POWERTYPE_ALTERNATE)
		if cur > 0 then
			local max = UnitPowerMax(unit, POWERTYPE_ALTERNATE)
			return E:GetFormattedText(textFormat, cur, max)
		end
	end, not E.Retail)

	if tagFormat ~= 'percent' then
		E:AddTag(format('health:%s:shortvalue', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
			local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
			if status then
				return status
			else
				local min, max = UnitHealth(unit), UnitHealthMax(unit)
				return E:GetFormattedText(textFormat, min, max, nil, true)
			end
		end)

		E:AddTag(format('health:%s-nostatus:shortvalue', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
			local min, max = UnitHealth(unit), UnitHealthMax(unit)
			return E:GetFormattedText(textFormat, min, max, nil, true)
		end)

		E:AddTag(format('power:%s:shortvalue', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
			local powerType = UnitPowerType(unit)
			local min = UnitPower(unit, powerType)
			if min ~= 0 and tagFormat ~= 'deficit' then
				return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, powerType), nil, true)
			end
		end)

		E:AddTag(format('mana:%s:shortvalue', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
			return E:GetFormattedText(textFormat, UnitPower(unit, POWERTYPE_MANA), UnitPowerMax(unit, POWERTYPE_MANA), nil, true)
		end)

		E:AddTag(format('additionalmana:%s:shortvalue', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
			local barIndex = _G.ADDITIONAL_POWER_BAR_INDEX == 0 and _G.ALT_MANA_BAR_PAIR_DISPLAY_INFO[E.myclass]
			if barIndex and barIndex[UnitPowerType(unit)] then
				local min = UnitPower(unit, POWERTYPE_MANA)
				if min ~= 0 and tagFormat ~= 'deficit' then
					return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA), nil, true)
				end
			end
		end, not E.Retail)

		E:AddTag(format('classpower:%s:shortvalue', tagFormat), (E.myclass == 'MONK' and 'UNIT_AURA ' or E.myclass == 'DEATHKNIGHT' and 'RUNE_POWER_UPDATE ' or '') .. 'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER', function()
			local min, max = GetClassPower(E.myclass)
			if min ~= 0 then
				return E:GetFormattedText(textFormat, min, max, nil, true)
			end
		end, E.Classic)
	end
end

for textFormat, length in pairs({ veryshort = 5, short = 10, medium = 15, long = 20 }) do
	E:AddTag(format('health:deficit-percent:name-%s', textFormat), 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)
		local deficit = max - cur

		if deficit > 0 and cur > 0 then
			return _TAGS['health:deficit-percent:nostatus'](unit)
		else
			return _TAGS[format('name:%s', textFormat)](unit)
		end
	end)

	E:AddTag(format('name:abbrev:%s', textFormat), 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = UnitName(unit)
		if name and strfind(name, '%s') then
			name = Abbrev(name)
		end

		if name then
			return E:ShortenString(name, length)
		end
	end)

	E:AddTag(format('name:%s', textFormat), 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = UnitName(unit)
		if name then
			return E:ShortenString(name, length)
		end
	end)

	E:AddTag(format('name:%s:status', textFormat), 'UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		local name = UnitName(unit)
		if status then
			return status
		elseif name then
			return E:ShortenString(name, length)
		end
	end)

	E:AddTag(format('name:%s:translit', textFormat), 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = Translit:Transliterate(UnitName(unit), translitMark)
		if name then
			return E:ShortenString(name, length)
		end
	end)

	E:AddTag(format('target:%s', textFormat), 'UNIT_TARGET', function(unit)
		local targetName = UnitName(unit..'target')
		if targetName then
			return E:ShortenString(targetName, length)
		end
	end)

	E:AddTag(format('target:%s:translit', textFormat), 'UNIT_TARGET', function(unit)
		local targetName = Translit:Transliterate(UnitName(unit..'target'), translitMark)
		if targetName then
			return E:ShortenString(targetName, length)
		end
	end)
end

------------------------------------------------------------------------
--	Regular
------------------------------------------------------------------------

E:AddTag('classcolor:target', 'UNIT_TARGET', function(unit)
	return _TAGS.classcolor(unit..'target')
end)

E:AddTag('target', 'UNIT_TARGET', function(unit)
	local targetName = UnitName(unit..'target')
	if targetName then
		return targetName
	end
end)

E:AddTag('target:translit', 'UNIT_TARGET', function(unit)
	local targetName = UnitName(unit..'target')
	if targetName then
		return Translit:Transliterate(targetName, translitMark)
	end
end)

E:AddTag('health:max', 'UNIT_MAXHEALTH', function(unit)
	local max = UnitHealthMax(unit)
	return E:GetFormattedText('CURRENT', max, max)
end)

E:AddTag('health:max:shortvalue', 'UNIT_MAXHEALTH', function(unit)
	local _, max = UnitHealth(unit), UnitHealthMax(unit)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end)

E:AddTag('absorbs', 'UNIT_ABSORB_AMOUNT_CHANGED', function(unit)
	local absorb = UnitGetTotalAbsorbs(unit) or 0
	if absorb ~= 0 then
		return E:ShortValue(absorb)
	end
end, not E.Retail)

E:AddTag('health:percent-with-absorbs', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if status then
		return status
	end

	local absorb = UnitGetTotalAbsorbs(unit) or 0
	if absorb == 0 then
		return E:GetFormattedText('PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end

	local healthTotalIncludingAbsorbs = UnitHealth(unit) + absorb
	return E:GetFormattedText('PERCENT', healthTotalIncludingAbsorbs, UnitHealthMax(unit))
end, not E.Retail)

E:AddTag('health:deficit-percent:name', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
	local currentHealth = UnitHealth(unit)
	local deficit = UnitHealthMax(unit) - currentHealth

	if deficit > 0 and currentHealth > 0 then
		return _TAGS['health:percent-nostatus'](unit)
	else
		return _TAGS.name(unit)
	end
end)

E:AddTag('power:max', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
	local powerType = UnitPowerType(unit)
	local max = UnitPowerMax(unit, powerType)

	return E:GetFormattedText('CURRENT', max, max)
end)

E:AddTag('power:max:shortvalue', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
	local pType = UnitPowerType(unit)
	local max = UnitPowerMax(unit, pType)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end)

E:AddTag('mana:max:shortvalue', 'UNIT_MAXPOWER', function(unit)
	local max = UnitPowerMax(unit, POWERTYPE_MANA)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end)

E:AddTag('difficultycolor', 'UNIT_LEVEL PLAYER_LEVEL_UP', function(unit)
	local color
	if E.Retail and (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		local level = UnitBattlePetLevel(unit)
		local teamLevel = C_PetJournal_GetPetTeamAverageLevel()
		if teamLevel < level or teamLevel > level then
			color = GetRelativeDifficultyColor(teamLevel, level)
		else
			color = QuestDifficultyColors.difficult
		end
	else
		color = GetCreatureDifficultyColor(UnitEffectiveLevel(unit))
	end

	return Hex(color.r, color.g, color.b)
end)

E:AddTag('selectioncolor', 'UNIT_NAME_UPDATE UNIT_FACTION INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	local selection = NP:UnitSelectionType(unit)
	local cs = ElvUF.colors.selection[selection]
	return (cs and Hex(cs.r, cs.g, cs.b)) or '|cFFcccccc'
end)

E:AddTag('classcolor', 'UNIT_NAME_UPDATE UNIT_FACTION INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	if UnitIsPlayer(unit) then
		local _, unitClass = UnitClass(unit)
		local cs = ElvUF.colors.class[unitClass]
		return (cs and Hex(cs.r, cs.g, cs.b)) or '|cFFcccccc'
	else
		local cr = ElvUF.colors.reaction[UnitReaction(unit, 'player')]
		return (cr and Hex(cr.r, cr.g, cr.b)) or '|cFFcccccc'
	end
end)

E:AddTag('namecolor', 'UNIT_TARGET', function(unit)
	return _TAGS.classcolor(unit)
end)

E:AddTag('reactioncolor', 'UNIT_NAME_UPDATE UNIT_FACTION', function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	if unitReaction then
		local color = ElvUF.colors.reaction[unitReaction]
		return Hex(color.r, color.g, color.b)
	else
		return '|cFFc2c2c2'
	end
end)

E:AddTag('smartlevel', 'UNIT_LEVEL PLAYER_LEVEL_UP', function(unit)
	local level = UnitEffectiveLevel(unit)
	if E.Retail and (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		return UnitBattlePetLevel(unit)
	elseif level == UnitEffectiveLevel('player') then
		return nil
	elseif level > 0 then
		return level
	else
		return '??'
	end
end)

E:AddTag('realm', 'UNIT_NAME_UPDATE', function(unit)
	local _, realm = UnitName(unit)
	if realm and realm ~= '' then
		return realm
	end
end)

E:AddTag('realm:dash', 'UNIT_NAME_UPDATE', function(unit)
	local _, realm = UnitName(unit)
	if realm and (realm ~= '' and realm ~= E.myrealm) then
		return format('-%s', realm)
	elseif realm ~= '' then
		return realm
	end
end)

E:AddTag('realm:translit', 'UNIT_NAME_UPDATE', function(unit)
	local _, realm = Translit:Transliterate(UnitName(unit), translitMark)
	if realm and realm ~= '' then
		return realm
	end
end)

E:AddTag('realm:dash:translit', 'UNIT_NAME_UPDATE', function(unit)
	local _, realm = Translit:Transliterate(UnitName(unit), translitMark)

	if realm and (realm ~= '' and realm ~= E.myrealm) then
		return format('-%s', realm)
	elseif realm ~= '' then
		return realm
	end
end)

E:AddTag('threat:percent', 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE', function(unit)
	local _, _, percent = UnitDetailedThreatSituation('player', unit)
	if percent and percent > 0 and (IsInGroup() or UnitExists('pet')) then
		return format('%.0f%%', percent)
	end
end)

E:AddTag('threat:current', 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE', function(unit)
	local _, _, percent, _, threatvalue = UnitDetailedThreatSituation('player', unit)
	if percent and percent > 0 and (IsInGroup() or UnitExists('pet')) then
		return E:ShortValue(threatvalue)
	end
end)

E:AddTag('threatcolor', 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE', function(unit)
	local _, status = UnitDetailedThreatSituation('player', unit)
	if status and (IsInGroup() or UnitExists('pet')) then
		return Hex(E:GetThreatStatusColor(status, true))
	end
end)

E:AddTag('pvptimer', 1, function(unit)
	if UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then
			local mins = floor((timer * 0.001) / 60)
			local secs = floor((timer * 0.001) - (mins * 60))
			return format('%s (%01.f:%02.f)', PVP, mins, secs)
		else
			return PVP
		end
	end
end)

E:AddTag('classpowercolor', 'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER'..(E.Retail and (E.myclass == 'DEATHKNIGHT' or E.myclass == 'MONK') and ' PLAYER_SPECIALIZATION_CHANGED' or ''), function()
	local _, _, r, g, b = GetClassPower(E.myclass)
	return Hex(r, g, b)
end)

E:AddTag('manacolor', 'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER', function()
	local color = ElvUF.colors.power.MANA
	return Hex(color.r, color.g, color.b)
end)

E:AddTag('incomingheals:personal', 'UNIT_HEAL_PREDICTION', function(unit)
	local heal = UnitGetIncomingHeals(unit, 'player') or 0
	if heal ~= 0 then
		return E:ShortValue(heal)
	end
end)

E:AddTag('incomingheals:others', 'UNIT_HEAL_PREDICTION', function(unit)
	local personal = UnitGetIncomingHeals(unit, 'player') or 0
	local heal = UnitGetIncomingHeals(unit) or 0
	local others = heal - personal
	if others ~= 0 then
		return E:ShortValue(others)
	end
end)

E:AddTag('incomingheals', 'UNIT_HEAL_PREDICTION', function(unit)
	local heal = UnitGetIncomingHeals(unit) or 0
	if heal ~= 0 then
		return E:ShortValue(heal)
	end
end)

E:AddTag('distance', 0.1, function(realUnit)
	if UnitIsConnected(realUnit) and not UnitIsUnit(realUnit, 'player') then
		local unit = E:GetGroupUnit(realUnit) or realUnit
		local distance = E:GetDistance('player', unit)
		if distance then
			return format('%.1f', distance)
		end
	end
end)

E:AddTag('classificationcolor', 'UNIT_CLASSIFICATION_CHANGED', function(unit)
	local c = UnitClassification(unit)
	if c == 'rare' or c == 'elite' then
		return Hex(1, 0.5, 0.25)
	elseif c == 'rareelite' or c == 'worldboss' then
		return Hex(1, 0, 0)
	end
end)

E:AddTag('guild', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(unit)
	if UnitIsPlayer(unit) then
		return GetGuildInfo(unit)
	end
end)

E:AddTag('group:raid', 'GROUP_ROSTER_UPDATE', function(unit)
	if IsInRaid() then
		local name, realm = UnitName(unit)
		if name then
			local nameRealm = (realm and realm ~= '' and format('%s-%s', name, realm)) or name
			for i = 1, GetNumGroupMembers() do
				local raidName, _, group = GetRaidRosterInfo(i)
				if raidName == nameRealm then
					return group
				end
			end
		end
	end
end)

E:AddTag('guild:brackets', 'PLAYER_GUILD_UPDATE', function(unit)
	local guildName = GetGuildInfo(unit)
	if guildName then
		return format('<%s>', guildName)
	end
end)

E:AddTag('guild:translit', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(unit)
	if UnitIsPlayer(unit) then
		local guildName = GetGuildInfo(unit)
		if guildName then
			return Translit:Transliterate(guildName, translitMark)
		end
	end
end)

E:AddTag('guild:brackets:translit', 'PLAYER_GUILD_UPDATE', function(unit)
	local guildName = GetGuildInfo(unit)
	if guildName then
		return format('<%s>', Translit:Transliterate(guildName, translitMark))
	end
end)

E:AddTag('guild:rank', 'UNIT_NAME_UPDATE', function(unit)
	if UnitIsPlayer(unit) then
		local _, rank = GetGuildInfo(unit)
		if rank then
			return rank
		end
	end
end)

E:AddTag('arena:number', 'UNIT_NAME_UPDATE', function(unit)
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'arena' then
		for i = 1, 5 do
			if UnitIsUnit(unit, 'arena'..i) then
				return i
			end
		end
	end
end)

E:AddTag('class', 'UNIT_NAME_UPDATE', function(unit)
	if not UnitIsPlayer(unit) then return end

	local _, classToken = UnitClass(unit)
	if UnitSex(unit) == 3 then
		return _G.LOCALIZED_CLASS_NAMES_FEMALE[classToken]
	else
		return _G.LOCALIZED_CLASS_NAMES_MALE[classToken]
	end
end)

E:AddTag('specialization', 'PLAYER_TALENT_UPDATE', function(unit)
	local currentSpec = UnitIsPlayer(unit) and GetSpecialization()
	if currentSpec then
		local _, currentSpecName = GetSpecializationInfo(currentSpec)
		if currentSpecName then
			return currentSpecName
		end
	end
end, not E.Retail)

E:AddTag('name:title', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	return UnitIsPlayer(unit) and UnitPVPName(unit) or UnitName(unit)
end)

E:AddTag('title', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	if UnitIsPlayer(unit) then
		return GetTitleName(GetCurrentTitle())
	end
end)

E:AddTag('altpowercolor', 'UNIT_POWER_UPDATE UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE', function(unit)
	local cur = UnitPower(unit, POWERTYPE_ALTERNATE)
	if cur > 0 then
		local _, r, g, b = GetUnitPowerBarTextureInfo(unit, 3)
		if not r then
			r, g, b = 1, 1, 1
		end

		return Hex(r,g,b)
	end
end, not E.Retail)

E:AddTag('afk', 'PLAYER_FLAGS_CHANGED', function(unit)
	if UnitIsAFK(unit) then
		return format('|cffFFFFFF[|r|cffFF9900%s|r|cFFFFFFFF]|r', L["AFK"])
	end
end)

E:AddTag('healthcolor', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hex(0.84, 0.75, 0.65)
	else
		local r, g, b = ElvUF:ColorGradient(UnitHealth(unit), UnitHealthMax(unit), 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return Hex(r, g, b)
	end
end)

E:AddTag('status:text', 'PLAYER_FLAGS_CHANGED', function(unit)
	if UnitIsAFK(unit) then
		return format('|cffFF9900<|r%s|cffFF9900>|r', L["AFK"])
	elseif UnitIsDND(unit) then
		return format('|cffFF3333<|r%s|cffFF3333>|r', L["DND"])
	end
end)

do
	local afk = [[|TInterface\FriendsFrame\StatusIcon-Away:16:16|t]]
	local dnd = [[|TInterface\FriendsFrame\StatusIcon-DnD:16:16|t]]
	E:AddTag('status:icon', 'PLAYER_FLAGS_CHANGED', function(unit)
		if UnitIsAFK(unit) then
			return afk
		elseif UnitIsDND(unit) then
			return dnd
		end
	end)
end

E:AddTag('name:abbrev', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	local name = UnitName(unit)
	if name and strfind(name, '%s') then
		name = Abbrev(name)
	end

	return name
end)

E:AddTag('name:last', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	local name = UnitName(unit)
	if name and strfind(name, '%s') then
		name = strmatch(name, '([%S]+)$')
	end

	return name
end)

E:AddTag('health:deficit-percent:nostatus', 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = (min / max) - 1
	if deficit ~= 0 then
		return E:GetFormattedText('PERCENT', deficit, -1)
	end
end)

E:AddTag('speed:yardspersec-raw', 0.1, function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return format('%.1f', currentSpeedInYards)
end)

E:AddTag('speed:yardspersec-moving-raw', 0.1, function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return currentSpeedInYards > 0 and format('%.1f', currentSpeedInYards) or nil
end)

------------------------------------------------------------------------
--	Scoped
------------------------------------------------------------------------

do
	local faction = {
		Horde = [[|TInterface\FriendsFrame\PlusManz-Horde:16:16|t]],
		Alliance = [[|TInterface\FriendsFrame\PlusManz-Alliance:16:16|t]]
	}

	E:AddTag('faction:icon', 'UNIT_FACTION', function(unit)
		return faction[UnitFactionGroup(unit)]
	end)
end

do
	local factionColors = {
		['']	 = '|cFFc2c2c2',
		Alliance = '|cFF0099ff',
		Horde	 = '|cFFff3333',
		Neutral	 = '|cFF33ff33'
	}

	E:AddTag('factioncolor', 'UNIT_NAME_UPDATE UNIT_FACTION', function(unit)
		local englishFaction = E:GetUnitBattlefieldFaction(unit)
		return factionColors[englishFaction or '']
	end)
end

do
	local function NameHealthColor(tags,hex,unit,default)
		if hex == 'class' or hex == 'reaction' then
			return tags.classcolor(unit) or default
		elseif hex and strmatch(hex, '^%x%x%x%x%x%x$') then
			return '|cFF'..hex
		end

		return default
	end
	E.TagFunctions.NameHealthColor = NameHealthColor

	-- the third arg here is added from the user as like [name:health{ff00ff:00ff00}] or [name:health{class:00ff00}]
	E:AddTag('name:health', 'UNIT_NAME_UPDATE UNIT_FACTION UNIT_HEALTH UNIT_MAXHEALTH', function(unit, _, args)
		local name = UnitName(unit)
		if not name then return '' end

		local min, max, bco, fco = UnitHealth(unit), UnitHealthMax(unit), strsplit(':', args or '')
		local to = ceil(utf8len(name) * (min / max))

		local fill = NameHealthColor(_TAGS, fco, unit, '|cFFff3333')
		local base = NameHealthColor(_TAGS, bco, unit, '|cFFffffff')

		return to > 0 and (base..utf8sub(name, 0, to)..fill..utf8sub(name, to+1, -1)) or fill..name
	end)
end

do
	local unitStatus = {}
	E:AddTag('statustimer', 1, function(unit)
		if not UnitIsPlayer(unit) then return end

		local guid = UnitGUID(unit)
		local status = unitStatus[guid]

		if UnitIsAFK(unit) then
			if not status or status[1] ~= 'AFK' then
				unitStatus[guid] = {'AFK', GetTime()}
			end
		elseif UnitIsDND(unit) then
			if not status or status[1] ~= 'DND' then
				unitStatus[guid] = {'DND', GetTime()}
			end
		elseif UnitIsDead(unit) or UnitIsGhost(unit) then
			if not status or status[1] ~= 'Dead' then
				unitStatus[guid] = {'Dead', GetTime()}
			end
		elseif not UnitIsConnected(unit) then
			if not status or status[1] ~= 'Offline' then
				unitStatus[guid] = {'Offline', GetTime()}
			end
		else
			unitStatus[guid] = nil
		end

		if status ~= unitStatus[guid] then
			status = unitStatus[guid]
		end

		if status then
			local timer = GetTime() - status[2]
			local mins = floor(timer / 60)
			local secs = floor(timer - (mins * 60))
			return format('%s (%01.f:%02.f)', L[status[1]], mins, secs)
		end
	end)
end

do
	local GroupUnits = {}
	local frame = CreateFrame('Frame')
	frame:RegisterEvent('GROUP_ROSTER_UPDATE')
	frame:SetScript('OnEvent', function()
		wipe(GroupUnits)

		local groupType, groupSize
		if IsInRaid() then
			groupType = 'raid'
			groupSize = GetNumGroupMembers()
		elseif IsInGroup() then
			groupType = 'party'
			groupSize = GetNumGroupMembers()
		else
			groupType = 'solo'
			groupSize = 1
		end

		for index = 1, groupSize do
			local groupUnit = groupType..index
			if not UnitIsUnit(groupUnit, 'player') then
				GroupUnits[groupUnit] = true
			end
		end
	end)

	for _, var in ipairs({4,8,10,15,20,25,30,35,40}) do
		E:AddTag(format('nearbyplayers:%s', var), 0.25, function(realUnit)
			local inRange = 0

			if UnitIsConnected(realUnit) then
				local unit = E:GetGroupUnit(realUnit) or realUnit
				for groupUnit in pairs(GroupUnits) do
					if UnitIsConnected(groupUnit) and not UnitIsUnit(unit, groupUnit) then
						local distance = E:GetDistance(unit, groupUnit)
						if distance and distance <= var then
							inRange = inRange + 1
						end
					end
				end
			end

			if inRange > 0 then
				return inRange
			end
		end)
	end
end

do
	local speedText = _G.SPEED
	local baseSpeed = _G.BASE_MOVEMENT_SPEED
	E:AddTag('speed:percent', 0.1, function(unit)
		local currentSpeedInYards = GetUnitSpeed(unit)
		local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100

		return format('%s: %d%%', speedText, currentSpeedInPercent)
	end)

	E:AddTag('speed:percent-moving', 0.1, function(unit)
		local currentSpeedInYards = GetUnitSpeed(unit)
		local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100)

		if currentSpeedInPercent then
			currentSpeedInPercent = format('%s: %d%%', speedText, currentSpeedInPercent)
		end

		return currentSpeedInPercent
	end)

	E:AddTag('speed:percent-raw', 0.1, function(unit)
		local currentSpeedInYards = GetUnitSpeed(unit)
		local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100

		return format('%d%%', currentSpeedInPercent)
	end)

	E:AddTag('speed:percent-moving-raw', 0.1, function(unit)
		local currentSpeedInYards = GetUnitSpeed(unit)
		local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100)

		if currentSpeedInPercent then
			currentSpeedInPercent = format('%d%%', currentSpeedInPercent)
		end

		return currentSpeedInPercent
	end)

	E:AddTag('speed:yardspersec', 0.1, function(unit)
		local currentSpeedInYards = GetUnitSpeed(unit)
		return format('%s: %.1f', speedText, currentSpeedInYards)
	end)

	E:AddTag('speed:yardspersec-moving', 0.1, function(unit)
		local currentSpeedInYards = GetUnitSpeed(unit)
		return currentSpeedInYards > 0 and format('%s: %.1f', speedText, currentSpeedInYards) or nil
	end)
end

do
	local gold, silver = '|A:nameplates-icon-elite-gold:16:16|a', '|A:nameplates-icon-elite-silver:16:16|a'
	local typeIcon = { elite = gold, worldboss = gold, rareelite = silver, rare = silver }
	E:AddTag('classification:icon', 'UNIT_NAME_UPDATE', function(unit)
		if UnitIsPlayer(unit) then return end
		return typeIcon[UnitClassification(unit)]
	end)

	local typeName = { rare = L["Rare"], rareelite = L["Rare Elite"], elite = L["Elite"], worldboss = L["Boss"], minus = L["Affix"] }
	E:AddTag('classification', 'UNIT_CLASSIFICATION_CHANGED', function(unit)
		return typeName[UnitClassification(unit)]
	end)
end

do
	local function GetTitleNPC(unit, custom)
		if UnitIsPlayer(unit) or (E.Wrath and UnitAffectingCombat('player') and IsInInstance()) then return end

		E.ScanTooltip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetUnit(unit)
		E.ScanTooltip:Show()

		-- similar to TT.GetLevelLine
		local ttLine = _G[format('ElvUI_ScanTooltipTextLeft%d', GetCVarBool('colorblindmode') and 3 or 2)]
		local ttText = ttLine and ttLine:GetText()
		local ttLower = ttText and strlower(ttText)
		if ttLower and not strfind(ttLower, LEVEL) then
			return custom and format(custom, ttText) or ttText
		end
	end
	E.TagFunctions.GetTitleNPC = GetTitleNPC

	E:AddTag('npctitle', 'UNIT_NAME_UPDATE', function(unit)
		return GetTitleNPC(unit)
	end)

	E:AddTag('npctitle:brackets', 'UNIT_NAME_UPDATE', function(unit)
		return GetTitleNPC(unit, '<%s>')
	end)
end

do
	local function GetQuestData(unit, which, Hex)
		if UnitIsPlayer(unit) or (E.Wrath and UnitAffectingCombat('player') and IsInInstance()) then return end

		E.ScanTooltip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetUnit(unit)
		E.ScanTooltip:Show()

		local notMyQuest, activeID
		for i = 3, E.ScanTooltip:NumLines() do
			local str = _G['ElvUI_ScanTooltipTextLeft' .. i]
			local text = str and str:GetText()
			if not text or text == '' then return end

			if UnitIsPlayer(text) then
				notMyQuest = text ~= E.myname
			elseif text and not notMyQuest then
				local count, percent = NP.QuestIcons.CheckTextForQuest(text)

				-- this line comes from one line up in the tooltip
				local activeQuest = NP.QuestIcons.activeQuests[text]
				if activeQuest then activeID = activeQuest end

				if count then
					if not which then
						return text
					elseif which == 'count' then
						return percent and format('%s%%', count) or count
					elseif which == 'title' and activeID then
						local title = C_QuestLog_GetTitleForQuestID(activeID)
						local level = Hex and C_QuestLog_GetQuestDifficultyLevel(activeID)
						if level then
							local colors = GetQuestDifficultyColor(level)
							title = format('%s%s|r', Hex(colors.r, colors.g, colors.b), title)
						end

						return title
					elseif (which == 'info' or which == 'full') and activeID then
						local title = C_QuestLog_GetTitleForQuestID(activeID)
						local level = Hex and C_QuestLog_GetQuestDifficultyLevel(activeID)
						if level then
							local colors = GetQuestDifficultyColor(level)
							title = format('%s%s|r', Hex(colors.r, colors.g, colors.b), title)
						end

						if which == 'full' then
							return format('%s: %s', title, text)
						else
							return format(percent and '%s: %s%%' or '%s: %s', title, count)
						end
					end
				end
			end
		end
	end
	E.TagFunctions.GetQuestData = GetQuestData

	E:AddTag('quest:text', 'QUEST_LOG_UPDATE', function(unit)
		return GetQuestData(unit, nil, Hex)
	end)

	E:AddTag('quest:full', 'QUEST_LOG_UPDATE', function(unit)
		return GetQuestData(unit, 'full', Hex)
	end)

	E:AddTag('quest:info', 'QUEST_LOG_UPDATE', function(unit)
		return GetQuestData(unit, 'info', Hex)
	end)

	E:AddTag('quest:title', 'QUEST_LOG_UPDATE', function(unit)
		return GetQuestData(unit, 'title', Hex)
	end)

	E:AddTag('quest:count', 'QUEST_LOG_UPDATE', function(unit)
		return GetQuestData(unit, 'count', Hex)
	end)
end

do
	local highestVersion = E.version
	E:AddTag('ElvUI-Users', 20, function(unit)
		if E.UserList and next(E.UserList) then
			local name, realm = UnitName(unit)
			if name then
				local nameRealm = (realm and realm ~= '' and format('%s-%s', name, realm)) or name
				local userVersion = nameRealm and E.UserList[nameRealm]
				if userVersion then
					if highestVersion < userVersion then
						highestVersion = userVersion
					end
					return (userVersion < highestVersion) and '|cffFF3333E|r' or '|cff3366ffE|r'
				end
			end
		end
	end)
end

do
	local classIcon = [[|TInterface\WorldStateFrame\ICONS-CLASSES:32:32:0:0:256:256:%s|t]]
	local classIcons = {
		WARRIOR		= '0:64:0:64',
		MAGE		= '64:128:0:64',
		ROGUE		= '128:192:0:64',
		DRUID		= '192:256:0:64',
		HUNTER		= '0:64:64:128',
		SHAMAN		= '64:128:64:128',
		PRIEST		= '128:192:64:128',
		WARLOCK		= '192:256:64:128',
		PALADIN		= '0:64:128:192',
		DEATHKNIGHT = '64:128:128:192',
		MONK		= '128:192:128:192',
		DEMONHUNTER = '192:256:128:192',
	}

	E:AddTag('class:icon', 'PLAYER_TARGET_CHANGED', function(unit)
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			local icon = classIcons[class]
			if icon then
				return format(classIcon, icon)
			end
		end
	end)
end

E:AddTag('loyalty', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
		return (gsub(GetPetLoyalty(), '.-(%d).*', '%1'))
	end
end, not E.Classic)

if not E.Retail then
	local GetPetHappiness = GetPetHappiness
	local GetPetFoodTypes = GetPetFoodTypes

	local emotionsIcons = {
		[[|TInterface\PetPaperDollFrame\UI-PetHappiness:16:16:0:0:128:64:48:72:0:23|t]],
		[[|TInterface\PetPaperDollFrame\UI-PetHappiness:16:16:0:0:128:64:24:48:0:23|t]],
		[[|TInterface\PetPaperDollFrame\UI-PetHappiness:16:16:0:0:128:64:0:24:0:23|t]]
	}

	local emotionsDiscord = {
		E:TextureString(E.Media.ChatEmojis.Rage, ':16:16:0:0:32:32:0:32:0:32'),
		E:TextureString(E.Media.ChatEmojis.SlightFrown, ':16:16:0:0:32:32:0:32:0:32'),
		E:TextureString(E.Media.ChatEmojis.HeartEyes, ':16:16:0:0:32:32:0:32:0:32')
	}

	E:AddTag('happiness:full', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
			return _G['PET_HAPPINESS'..GetPetHappiness()]
		end
	end)

	E:AddTag('happiness:icon', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
			return emotionsIcons[GetPetHappiness()]
		end
	end)

	E:AddTag('happiness:discord', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
			return emotionsDiscord[GetPetHappiness()]
		end
	end)

	E:AddTag('happiness:color', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
			return Hex(_COLORS.happiness[GetPetHappiness()])
		end
	end)

	E:AddTag('diet', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
			return GetPetFoodTypes()
		end
	end)

	E:AddTag('pvp:title', 'UNIT_NAME_UPDATE', function(unit)
		if UnitIsPlayer(unit) then
			local rank = UnitPVPRank(unit)
			local title = GetPVPRankInfo(rank, unit)

			return title
		end
	end)

	E:AddTag('pvp:rank', 'UNIT_NAME_UPDATE', function(unit)
		if UnitIsPlayer(unit) then
			local rank = UnitPVPRank(unit)
			local _, num = GetPVPRankInfo(rank, unit)

			if num > 0 then
				return num
			end
		end
	end)

	local rankIcon = [[|TInterface\PvPRankBadges\PvPRank%02d:12:12:0:0:12:12:0:12:0:12|t]]
	E:AddTag('pvp:icon', 'UNIT_NAME_UPDATE', function(unit)
		if UnitIsPlayer(unit) then
			local rank = UnitPVPRank(unit)
			local _, num = GetPVPRankInfo(rank, unit)

			if num > 0 then
				return format(rankIcon, num)
			end
		end
	end)
end

------------------------------------------------------------------------
--	Available Tags
------------------------------------------------------------------------

E.TagInfo = {
	-- Altpower
		['altpower:current-max-percent'] = { hidden = not E.Retail, category = 'Altpower', description = "Displays altpower text on a unit in current-max-percent format" },
		['altpower:current-max'] = { hidden = not E.Retail, category = 'Altpower', description = "Displays altpower text on a unit in current-max format" },
		['altpower:current-percent'] = { hidden = not E.Retail, category = 'Altpower', description = "Displays altpower text on a unit in current-percent format" },
		['altpower:current'] = { hidden = not E.Retail, category = 'Altpower', description = "Displays altpower text on a unit in current format" },
		['altpower:deficit'] = { hidden = not E.Retail, category = 'Altpower', description = "Displays altpower text on a unit in deficit format" },
		['altpower:percent'] = { hidden = not E.Retail, category = 'Altpower', description = "Displays altpower text on a unit in percent format" },
	-- Class
		['class'] = { category = 'Class', description = "Displays the class of the unit, if that unit is a player" },
		['class:icon'] = { category = 'Class', description = "Displays the class icon of the unit, if that unit is a player" },
		['smartclass'] = { category = 'Class', description = "Displays the player's class or creature's type" },
		['specialization'] = { hidden = not E.Retail, category = 'Class', description = "Displays your current specialization as text" },
	-- Classification
		['affix'] = { category = 'Classification', description = "Displays low level critter mobs" },
		['classification:icon'] = { category = 'Classification', description = "Displays the unit's classification in icon form (golden icon for 'ELITE' silver icon for 'RARE')" },
		['classification'] = { category = 'Classification', description = "Displays the unit's classification (e.g. 'ELITE' and 'RARE')" },
		['creature'] = { category = 'Classification', description = "Displays the creature type of the unit" },
		['plus'] = { category = 'Classification', description = "Displays the character '+' if the unit is an elite or rare-elite" },
		['rare'] = { category = 'Classification', description = "Displays 'Rare' when the unit is a rare or rareelite" },
		['shortclassification'] = { category = 'Classification', description = "Displays the unit's classification in short form (e.g. '+' for ELITE and 'R' for RARE)" },
	-- Classpower
		['cpoints'] = { category = 'Classpower', description = "Displays amount of combo points the player has (only for player, shows nothing on 0)" },
		['arcanecharges'] = { hidden = not E.Retail, category = 'Classpower', description = "Displays the arcane charges (Mage)" },
		['chi'] = { hidden = not E.Retail, category = 'Classpower', description = "Displays the chi points (Monk)" },
		['classpower:current-max-percent'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current and max amount of special power, separated by a dash (% when not full power)" },
		['classpower:current-max'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current and max amount of special power, separated by a dash" },
		['classpower:current-percent'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current and percentage amount of special power, separated by a dash" },
		['classpower:current'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current amount of special power" },
		['classpower:deficit'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's special power as a deficit (Total Special Power - Current Special Power = -Deficit)" },
		['classpower:percent'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current amount of special power as a percentage" },
		['classpower:current-max-percent:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" },
		['classpower:current-max:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" },
		['classpower:current-percent:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" },
		['classpower:current:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" },
		['classpower:deficit:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" },
		['holypower'] = { hidden = not E.Retail, category = 'Classpower', description = "Displays the holy power (Paladin)" },
		['runes'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the runes (Death Knight)" },
		['soulshards'] = { hidden = not E.Retail, category = 'Classpower', description = "Displays the soulshards (Warlock)" },
	-- Colors
		['altpowercolor'] = { hidden = not E.Retail, category = 'Colors', description = "Changes the text color to the current alternative power color (Blizzard defined)" },
		['classificationcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's classification" },
		['classpowercolor'] = { category = 'Colors', description = "Changes the color of the special power based upon its type" },
		['difficulty'] = { category = 'Colors', description = "Changes color of the next tag based on how difficult the unit is compared to the players level" },
		['difficultycolor'] = { category = 'Colors', description = "Colors the following tags by difficulty, red for impossible, orange for hard, green for easy" },
		['healthcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's current health" },
		['selectioncolor'] = { category = 'Colors', description = "Colors the text, depending on the type of the unit's selection" },
		['classcolor'] = { category = 'Colors', description = "Colors names by player class or NPC reaction (Ex: [classcolor][name])" },
		['namecolor'] = { hidden = true, category = 'Colors', description = "Deprecated version of [classcolor]" },
		['powercolor'] = { category = 'Colors', description = "Colors the power text based upon its type" },
		['manacolor'] = { category = 'Colors', description = "Colors the power text based on the mana color" },
		['factioncolor'] = { category = 'Colors', description = "Colors names by Faction (Alliance, Horde, Neutral)" },
		['reactioncolor'] = { category = 'Colors', description = "Colors names by NPC reaction (Bad/Neutral/Good)" },
		['threatcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's threat situation" },
		['happiness:color'] = { hidden = E.Retail, category = 'Colors', description = "Changes the text color, depending on the pet happiness" },
	-- Guild
		['guild:brackets:translit'] = { category = 'Guild', description = "Displays the guild name with < > and transliteration (e.g. <GUILD>)" },
		['guild:brackets'] = { category = 'Guild', description = "Displays the guild name with < > brackets (e.g. <GUILD>)" },
		['guild:rank'] = { category = 'Guild', description = "Displays the guild rank" },
		['guild:translit'] = { category = 'Guild', description = "Displays the guild name with transliteration for cyrillic letters" },
		['guild'] = { category = 'Guild', description = "Displays the guild name" },
	-- Health
		['absorbs'] = { hidden = not E.Retail, category = 'Health', description = 'Displays the amount of absorbs' },
		['curhp'] = { category = 'Health', description = "Displays the current HP without decimals" },
		['deficit:name'] = { category = 'Health', description = "Displays the health as a deficit and the name at full health" },
		['health:current-max-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current and max health, without status" },
		['health:current-max-nostatus'] = { category = 'Health', description = "Displays the current and maximum health of the unit, separated by a dash, without status" },
		['health:current-max-percent-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of current and max hp (% when not full hp, without status)" },
		['health:current-max-percent-nostatus'] = { category = 'Health', description = "Displays the current and max hp of the unit, separated by a dash (% when not full hp), without status" },
		['health:current-max-percent:shortvalue'] = { category = 'Health', description = "Shortvalue of current and max hp (% when not full hp)" },
		['health:current-max-percent'] = { category = 'Health', description = "Displays the current and max hp of the unit, separated by a dash (% when not full hp)" },
		['health:current-max:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current and max hp, separated by a dash" },
		['health:current-max'] = { category = 'Health', description = "Displays the current and maximum health of the unit, separated by a dash" },
		['health:current-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current health without status" },
		['health:current-nostatus'] = { category = 'Health', description = "Displays the current health of the unit, without status" },
		['health:current-percent-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current hp (% when not full hp), without status" },
		['health:current-percent-nostatus'] = { category = 'Health', description = "Displays the current hp of the unit (% when not full hp), without status" },
		['health:current-percent:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current hp (% when not full hp)" },
		['health:current-percent'] = { category = 'Health', description = "Displays the current hp of the unit (% when not full hp)" },
		['health:current:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current health (e.g. 81k instead of 81200)" },
		['health:current'] = { category = 'Health', description = "Displays the current health of the unit" },
		['health:deficit-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the health deficit, without status" },
		['health:deficit-nostatus'] = { category = 'Health', description = "Displays the health of the unit as a deficit, without status" },
		['health:deficit-percent:name-long'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 20 letters)" },
		['health:deficit-percent:name-medium'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 15 letters)" },
		['health:deficit-percent:name-short'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 10 letters)" },
		['health:deficit-percent:name-veryshort'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 5 letters)" },
		['health:deficit-percent:name'] = { category = 'Health', description = "Displays the health deficit as a percentage and the full name of the unit" },
		['health:deficit-percent:nostatus'] = { category = 'Health', description = "Displays the health deficit as a percentage, without status" },
		['health:deficit:shortvalue'] = { category = 'Health', description = "Shortvalue of the health deficit (e.g. -41k instead of -41300)" },
		['health:deficit'] = { category = 'Health', description = "Displays the health of the unit as a deficit (Total Health - Current Health = -Deficit)" },
		['health:max:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's maximum health" },
		['health:max'] = { category = 'Health', description = "Displays the maximum health of the unit" },
		['health:percent-nostatus'] = { category = 'Health', description = "Displays the unit's current health as a percentage, without status" },
		['health:percent-with-absorbs'] = { hidden = not E.Retail, category = 'Health', description = "Displays the unit's current health as a percentage with absorb values" },
		['health:percent'] = { category = 'Health', description = "Displays the current health of the unit as a percentage" },
		['incomingheals:others'] = { category = 'Health', description = "Displays only incoming heals from other units" },
		['incomingheals:personal'] = { category = 'Health', description = "Displays only personal incoming heals" },
		['incomingheals'] = { category = 'Health', description = "Displays all incoming heals" },
		['maxhp'] = { category = 'Health', description = "Displays max HP without decimals" },
		['missinghp'] = { category = 'Health', description = "Displays the missing health of the unit in whole numbers, when not at full health" },
		['perhp'] = { category = 'Health', description = "Displays percentage HP without decimals or the % sign. You can display the percent sign by adjusting the tag to [perhp<%]." },
	--Hunter
		['diet'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the diet of your pet (Fish, Meat, ...)" },
		['happiness:discord'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the pet happiness like a Discord emoji" },
		['happiness:full'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the pet happiness as a word (e.g. 'Happy')" },
		['happiness:icon'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the pet happiness like the default Blizzard icon" },
		['loyalty'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the pet loyalty level" },
	-- Level
		['level'] = { category = 'Level', description = "Displays the level of the unit" },
		['smartlevel'] = { category = 'Level', description = "Only display the unit's level if it is not the same as yours" },
	-- Mana
		['additionalmana:current-max-percent'] = { category = 'Mana', description = "Displays the current and max additional mana of the unit, separated by a dash (% when not full)" },
		['additionalmana:current-max'] = { category = 'Mana', description = "Displays the unit's current and maximum additional mana, separated by a dash" },
		['additionalmana:current-percent'] = { category = 'Mana', description = "Displays the current additional mana of the unit and % when not full" },
		['additionalmana:current'] = { category = 'Mana', description = "Displays the unit's current additional mana" },
		['additionalmana:deficit'] = { category = 'Mana', description = "Displays the player's additional mana as a deficit" },
		['additionalmana:percent'] = { category = 'Mana', description = "Displays the player's additional mana as a percentage" },
		['additionalmana:current-max-percent:shortvalue'] = { category = 'Mana', description = "" },
		['additionalmana:current-max:shortvalue'] = { category = 'Mana', description = "" },
		['additionalmana:current-percent:shortvalue'] = { category = 'Mana', description = "" },
		['additionalmana:current:shortvalue'] = { category = 'Mana', description = "" },
		['additionalmana:deficit:shortvalue'] = { category = 'Mana', description = "" },
		['curmana'] = { category = 'Mana', description = "Displays the current mana without decimals" },
		['mana:current-max-percent'] = { category = 'Mana', description = "Displays the current and max mana of the unit, separated by a dash (% when not full)" },
		['mana:current-max'] = { category = 'Mana', description = "Displays the unit's current and maximum mana, separated by a dash" },
		['mana:current-percent'] = { category = 'Mana', description = "Displays the current mana of the unit and % when not full" },
		['mana:current'] = { category = 'Mana', description = "Displays the unit's current mana" },
		['mana:deficit'] = { category = 'Mana', description = "Displays the player's mana as a deficit" },
		['mana:percent'] = { category = 'Mana', description = "Displays the player's mana as a percentage" },
		['maxmana'] = { category = 'Mana', description = "Displays the max amount of mana the unit can have" },
		['mana:current-max-percent:shortvalue'] = { category = 'Mana', description = "" },
		['mana:current-max:shortvalue'] = { category = 'Mana', description = "" },
		['mana:current-percent:shortvalue'] = { category = 'Mana', description = "" },
		['mana:current:shortvalue'] = { category = 'Mana', description = "" },
		['mana:deficit:shortvalue'] = { category = 'Mana', description = "" },
		['mana:max:shortvalue'] = { category = 'Mana', description = "" },
	-- Miscellaneous
		['race'] = { category = 'Miscellaneous', description = "Displays the race" },
	-- Names
		['name:abbrev:long'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 20 letters)" },
		['name:abbrev:medium'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 15 letters)" },
		['name:abbrev:short'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 10 letters)" },
		['name:abbrev:veryshort'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 5 letters)" },
		['name:abbrev'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')" },
		['name:last'] = { category = 'Names', description = "Displays the last word of the unit's name" },
		['name:long:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 20 letters)" },
		['name:long:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 20 letters)" },
		['name:long'] = { category = 'Names', description = "Displays the name of the unit (limited to 20 letters)" },
		['name:medium:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 15 letters)" },
		['name:medium:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 15 letters)" },
		['name:medium'] = { category = 'Names', description = "Displays the name of the unit (limited to 15 letters)" },
		['name:short:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 10 letters)" },
		['name:short:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 10 letters)" },
		['name:short'] = { category = 'Names', description = "Displays the name of the unit (limited to 10 letters)" },
		['name:title'] = { category = 'Names', description = "Displays player name and title" },
		['name:veryshort:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 5 letters)" },
		['name:veryshort:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 5 letters)" },
		['name:veryshort'] = { category = 'Names', description = "Displays the name of the unit (limited to 5 letters)" },
		['name'] = { category = 'Names', description = "Displays the full name of the unit without any letter limitation" },
		['name:health'] = { hidden = true, category = 'Names', description = "" },
		['npctitle:brackets'] = { category = 'Names', description = "Displays the NPC title with brackets (e.g. <General Goods Vendor>)" },
		['npctitle'] = { category = 'Names', description = "Displays the NPC title (e.g. General Goods Vendor)" },
		['title'] = { category = 'Names', description = "Displays player title" },
	-- Party and Raid
		['group'] = { category = 'Party and Raid', description = "Displays the group number the unit is in (1-8)" },
		['group:raid'] = { category = 'Party and Raid', description = "Displays the group number the unit is in (1-8): Only while in a raid." },
		['leader'] = { category = 'Party and Raid', description = "Displays 'L' if the unit is the group/raid leader" },
		['leaderlong'] = { category = 'Party and Raid', description = "Displays 'Leader' if the unit is the group/raid leader" },
	-- Power
		['curpp'] = { category = 'Power', description = "Displays the unit's current power without decimals" },
		['maxpp'] = { category = 'Power', description = "Displays the max amount of power of the unit in whole numbers without decimals" },
		['missingpp'] = { category = 'Power', description = "Displays the missing power of the unit in whole numbers when not at full power" },
		['perpp'] = { category = 'Power', description = "Displays the unit's percentage power without decimals " },
		['power:current-max-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash (% when not full power)" },
		['power:current-max-percent'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash (% when not full power)" },
		['power:current-max:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash" },
		['power:current-max'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash" },
		['power:current-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and power as a percentage, separated by a dash" },
		['power:current-percent'] = { category = 'Power', description = "Displays the current power and power as a percentage, separated by a dash" },
		['power:current:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's current amount of power (e.g. 4k instead of 4000)" },
		['power:current'] = { category = 'Power', description = "Displays the unit's current amount of power" },
		['power:deficit:shortvalue'] = { category = 'Power', description = "Shortvalue of the power as a deficit (Total Power - Current Power = -Deficit)" },
		['power:deficit'] = { category = 'Power', description = "Displays the power as a deficit (Total Power - Current Power = -Deficit)" },
		['power:max:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's maximum power" },
		['power:max'] = { category = 'Power', description = "Displays the unit's maximum power" },
		['power:percent'] = { category = 'Power', description = "Displays the unit's power as a percentage" },
	-- PvP
		['arena:number'] = { category = 'PvP', description = "Displays the arena number 1-5" },
		['arenaspec'] = { category = 'PvP', description = "Displays the area spec of an unit" },
		['faction:icon'] = { category = 'PvP', description = "Displays the 'Alliance' or 'Horde' texture" },
		['faction'] = { category = 'PvP', description = "Displays 'Alliance' or 'Horde'" },
		['pvp'] = { category = 'PvP', description = "Displays 'PvP' if the unit is pvp flagged" },
		['pvptimer'] = { category = 'PvP', description = "Displays remaining time on pvp-flagged status" },
		['pvp:icon'] = { hidden = E.Retail, category = 'PvP', description = "Displays player pvp rank icon" },
		['pvp:rank'] = { hidden = E.Retail, category = 'PvP', description = "Displays player pvp rank number" },
		['pvp:title'] = { hidden = E.Retail, category = 'PvP', description = "Displays player pvp title" },
	-- Quest
		['quest:info'] = { category = 'Quest', description = "Displays the quest objectives" },
		['quest:title'] = { category = 'Quest', description = "Displays the quest title" },
		['quest:count'] = { category = 'Quest', description = "Displays the quest count" },
		['quest:full'] = { category = 'Quest', description = "Quest full" },
		['quest:text'] = { category = 'Quest', description = "Quest text" },
	-- Range
		['range'] = { category = 'Range', description = "Displays the range" },
		['range:min'] = { category = 'Range', description = "Displays the min range" },
		['range:max'] = { category = 'Range', description = "Displays the max range" },
		['distance'] = { category = 'Range', description = "Displays the distance" },
		['nearbyplayers:4'] = { category = 'Range', description = "Displays all players within 4 yards" },
		['nearbyplayers:8'] = { category = 'Range', description = "Displays all players within 8 yards" },
		['nearbyplayers:10'] = { category = 'Range', description = "Displays all players within 10 yards" },
		['nearbyplayers:15'] = { category = 'Range', description = "Displays all players within 15 yards" },
		['nearbyplayers:20'] = { category = 'Range', description = "Displays all players within 20 yards" },
		['nearbyplayers:25'] = { category = 'Range', description = "Displays all players within 25 yards" },
		['nearbyplayers:30'] = { category = 'Range', description = "Displays all players within 30 yards" },
		['nearbyplayers:35'] = { category = 'Range', description = "Displays all players within 35 yards" },
		['nearbyplayers:40'] = { category = 'Range', description = "Displays all players within 40 yards" },
	-- Realm
		['realm:dash:translit'] = { category = 'Realm', description = "Displays the server name with transliteration for cyrillic letters and a dash in front" },
		['realm:dash'] = { category = 'Realm', description = "Displays the server name with a dash in front (e.g. -Realm)" },
		['realm:translit'] = { category = 'Realm', description = "Displays the server name with transliteration for cyrillic letters" },
		['realm'] = { category = 'Realm', description = "Displays the server name" },
	-- Speed
		['speed:percent-moving-raw'] = { category = 'Speed' },
		['speed:percent-moving'] = { category = 'Speed' },
		['speed:percent-raw'] = { category = 'Speed' },
		['speed:percent'] = { category = 'Speed' },
		['speed:yardspersec-moving-raw'] = { category = 'Speed' },
		['speed:yardspersec-moving'] = { category = 'Speed' },
		['speed:yardspersec-raw'] = { category = 'Speed' },
		['speed:yardspersec'] = { category = 'Speed' },
	-- Status
		['afk'] = { category = 'Status', description = "Displays <AFK> if the unit is afk" },
		['dead'] = { category = 'Status', description = "Displays <DEAD> if the unit is dead" },
		['ElvUI-Users'] = { category = 'Status', description = "Displays current ElvUI users" },
		['offline'] = { category = 'Status', description = "Displays 'OFFLINE' if the unit is disconnected" },
		['resting'] = { category = 'Status', description = "Displays 'zzz' if the unit is resting" },
		['status:icon'] = { category = 'Status', description = "Displays AFK/DND as an orange(afk) / red(dnd) icon" },
		['status:text'] = { category = 'Status', description = "Displays <AFK> and <DND>" },
		['status'] = { category = 'Status', description = "Displays zzz, dead, ghost, offline" },
		['statustimer'] = { category = 'Status', description = "Displays a timer for how long a unit has had the status (e.g 'DEAD - 0:34')" },
	-- Target
		['classcolor:target'] = { category = 'Target', description = "[classcolor] but for the current target of the unit" },
		['target:long:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 20 letters)" },
		['target:long'] = { category = 'Target', description = "Displays the current target of the unit (limited to 20 letters)" },
		['target:medium:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 15 letters)" },
		['target:medium'] = { category = 'Target', description = "Displays the current target of the unit (limited to 15 letters)" },
		['target:short:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 10 letters)" },
		['target:short'] = { category = 'Target', description = "Displays the current target of the unit (limited to 10 letters)" },
		['target:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters" },
		['target:veryshort:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 5 letters)" },
		['target:veryshort'] = { category = 'Target', description = "Displays the current target of the unit (limited to 5 letters)" },
		['target'] = { category = 'Target', description = "Displays the current target of the unit" },
	-- Threat
		['threat:current'] = { category = 'Threat', description = "Displays the current threat as a value" },
		['threat:percent'] = { category = 'Threat', description = "Displays the current threat as a percent" },
		['threat'] = { category = 'Threat', description = "Displays the current threat situation (Aggro is secure tanking, -- is losing threat and ++ is gaining threat)" },
}

--[[
	tagName = Tag Name
	category = Category that you want it to fall in
	description = self explainitory
	order = This is optional. It's used for sorting the tags by order and not by name. The +10 is not a rule. I reserve the first 10 slots.
]]

function E:AddTagInfo(tagName, category, description, order, hidden)
	if type(order) == 'number' then order = order + 10 else order = nil end

	local info = E.TagInfo[tagName]
	if not info then
		info = {}

		E.TagInfo[tagName] = info
	end

	info.category = category or 'Miscellaneous'
	info.description = description or ''
	info.order = order or nil
	info.hidden = hidden or nil

	return info
end

RefreshNewTags = true
