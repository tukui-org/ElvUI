local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

local Translit = E.Libs.Translit
local translitMark = '!'

local _G = _G
local next, gsub, format = next, gsub, format
local abs, ipairs, pairs, floor, ceil = abs, ipairs, pairs, floor, ceil
local strfind, strmatch, strlower, strsplit = strfind, strmatch, strlower, strsplit
local utf8sub, utf8len = string.utf8sub, string.utf8len

local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetCurrentTitle = GetCurrentTitle
local GetGuildInfo = GetGuildInfo
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetPetLoyalty = GetPetLoyalty
local GetPVPRankInfo = GetPVPRankInfo
local GetPVPTimer = GetPVPTimer
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
local GetTime = GetTime
local GetTitleName = GetTitleName
local GetUnitSpeed = GetUnitSpeed
local HasPetUI = HasPetUI
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local QuestDifficultyColors = QuestDifficultyColors
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitHealthMax = UnitHealthMax
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitIsAFK = UnitIsAFK
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsDND = UnitIsDND
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsUnit = UnitIsUnit
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitPVPName = UnitPVPName
local UnitPVPRank = UnitPVPRank
local UnitReaction = UnitReaction
local UnitThreatPercentageOfLead = UnitThreatPercentageOfLead

local C_PetJournal_GetPetTeamAverageLevel = C_PetJournal and C_PetJournal.GetPetTeamAverageLevel

local POWERTYPE_MANA = Enum.PowerType.Mana
local PVP = PVP

local SPELL_FROST_ICICLES = 205473
local SPELL_ARCANE_CHARGE = 36032
local SPELL_MAELSTROM = 344179

-- GLOBALS: Hex, _TAGS, _COLORS -- added by oUF
-- GLOBALS: UnitPower, UnitHealth, UnitName, UnitClass, UnitIsDead, UnitIsGhost, UnitIsDeadOrGhost, UnitIsConnected -- override during testing groups
-- GLOBALS: GetTitleNPC, Abbrev, GetClassPower, GetQuestData, UnitEffectiveLevel, NameHealthColor -- custom ones we made


------------------------------------------------------------------------
--	Looping
------------------------------------------------------------------------

local classSpecificAura = { MAGE = E.Retail or E.Mists, SHAMAN = E.Retail, MONK = true }
local classSpecificEvents = (E.myclass == 'DEATHKNIGHT' and 'RUNE_POWER_UPDATE ') or (classSpecificAura[E.myclass] and 'UNIT_AURA ') or ''
local classSpecificMonk = not E.Classic and E.myclass == 'MONK'
local classSpecificSpells = { -- stagger IDs also in oUF stagger element
	[124275] = classSpecificMonk or nil, -- [GREEN]  Light Stagger
	[124274] = classSpecificMonk or nil, -- [YELLOW] Moderate Stagger
	[124273] = classSpecificMonk or nil, -- [RED]    Heavy Stagger
	[SPELL_ARCANE_CHARGE] = (E.Mists and E.myclass == 'MAGE') or nil,
	[SPELL_FROST_ICICLES] = (E.Retail and E.myclass == 'MAGE') or nil,
	[SPELL_MAELSTROM] = (E.Retail and E.myclass == 'SHAMAN') or nil
}

if not E.Retail then
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

		E:AddTag(format('power:%s:healeronly', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
			local role = UnitGroupRolesAssigned(unit)
			if role ~= 'HEALER' then return end

			local powerType = UnitPowerType(unit)
			local min = UnitPower(unit, powerType)
			if min ~= 0 then
				return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, powerType))
			end
		end)

		E:AddTag(format('mana:%s', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
			local min = UnitPower(unit, POWERTYPE_MANA)
			if min ~= 0 then
				return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA))
			end
		end)

		E:AddTag(format('mana:%s:healeronly', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
			local role = UnitGroupRolesAssigned(unit)
			if role ~= 'HEALER' then return end

			local min = UnitPower(unit, POWERTYPE_MANA)
			if min ~= 0 then
				return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA))
			end
		end)

		E:AddTag(format('classpower:%s', tagFormat), classSpecificEvents..'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER', function(unit)
			local min, max = GetClassPower(unit)
			if min ~= 0 then
				return E:GetFormattedText(textFormat, min, max)
			end
		end, E.Classic, classSpecificSpells)

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

			E:AddTag(format('power:%s:shortvalue:healeronly', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
				local role = UnitGroupRolesAssigned(unit)
				if role ~= 'HEALER' then return end

				local powerType = UnitPowerType(unit)
				local min = UnitPower(unit, powerType)
				if min ~= 0 and tagFormat ~= 'deficit' then
					return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, powerType), nil, true)
				end
			end)

			E:AddTag(format('mana:%s:shortvalue', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
				return E:GetFormattedText(textFormat, UnitPower(unit, POWERTYPE_MANA), UnitPowerMax(unit, POWERTYPE_MANA), nil, true)
			end)

			E:AddTag(format('mana:%s:shortvalue:healeronly', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
				local role = UnitGroupRolesAssigned(unit)
				if role ~= 'HEALER' then return end

				return E:GetFormattedText(textFormat, UnitPower(unit, POWERTYPE_MANA), UnitPowerMax(unit, POWERTYPE_MANA), nil, true)
			end)

			E:AddTag(format('classpower:%s:shortvalue', tagFormat), classSpecificEvents..'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER', function(unit)
				local min, max = GetClassPower(unit)
				if min ~= 0 then
					return E:GetFormattedText(textFormat, min, max, nil, true)
				end
			end, E.Classic, classSpecificSpells)
		end
	end

	for textFormat, length in pairs({ veryshort = 5, short = 10, medium = 15, long = 20 }) do
		E:AddTag(format('health:current:name-%s', textFormat), 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
			local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
			local cur, max = UnitHealth(unit), UnitHealthMax(unit)
			local name = UnitName(unit)

			if status then
				return status
			elseif cur ~= max then
				return E:GetFormattedText('CURRENT', cur, max, nil, true)
			elseif name then
				return E:ShortenString(name, length)
			end
		end)

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

		E:AddTag(format('target:abbrev:%s', textFormat), 'UNIT_TARGET', function(unit)
			local targetName = UnitName(unit..'target')
			if targetName and strfind(targetName, '%s') then
				targetName = Abbrev(targetName)
			end

			if targetName then
				return E:ShortenString(targetName, length)
			end
		end)

		E:AddTag(format('target:%s', textFormat), 'UNIT_TARGET', function(unit)
			local targetName = UnitName(unit..'target')
			if targetName then
				return E:ShortenString(targetName, length)
			end
		end)

		E:AddTag(format('target:%s:translit', textFormat), 'UNIT_TARGET', function(unit)
			local targetName = UnitName(unit..'target')
			if targetName then
				local translitName = Translit:Transliterate(targetName, translitMark)
				if translitName then
					return E:ShortenString(translitName, length)
				end
			end
		end)
	end
end

------------------------------------------------------------------------
--	Regular
------------------------------------------------------------------------

if not E.Retail then
	E:AddTag('classcolor:target', 'UNIT_TARGET', function(unit)
		if UnitExists(unit..'target') then
			return _TAGS.classcolor(unit..'target')
		end
	end)

	E:AddTag('target:abbrev', 'UNIT_TARGET', function(unit)
		local targetName = UnitName(unit..'target')
		if targetName and strfind(targetName, '%s') then
			targetName = Abbrev(targetName)
		end

		return targetName
	end)

	E:AddTag('target:last', 'UNIT_TARGET', function(unit)
		local targetName = UnitName(unit..'target')
		if targetName and strfind(targetName, '%s') then
			targetName = strmatch(targetName, '([%S]+)$')
		end

		return targetName
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
	end, E.Classic)

	E:AddTag('healabsorbs', 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED', function(unit)
		local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
		if healAbsorb ~= 0 then
			return E:ShortValue(healAbsorb)
		end
	end, E.Classic)

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
	end, E.Classic)

	E:AddTag('health:percent-with-absorbs:nostatus', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
		local absorb = UnitGetTotalAbsorbs(unit) or 0
		if absorb == 0 then
			return E:GetFormattedText('PERCENT', UnitHealth(unit), UnitHealthMax(unit))
		end

		local healthTotalIncludingAbsorbs = UnitHealth(unit) + absorb
		return E:GetFormattedText('PERCENT', healthTotalIncludingAbsorbs, UnitHealthMax(unit))
	end, E.Classic)

	do
		local function FormatPercent(value, maximum, dec)
			local perc = value / maximum * 100
			return E:GetFormattedText('PERCENT', perc, 100, dec)
		end

		E:AddTag('health:deficit-percent-absorbs', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
			local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

			if status then
				return status
			end

			local current = UnitHealth(unit)
			local maximum = UnitHealthMax(unit)
			local absorb = UnitGetTotalAbsorbs(unit) or 0
			local effective = current + absorb

			if maximum == 0 or effective == maximum then
				return
			end

			local deficit = maximum - effective
			local percentage = FormatPercent(abs(deficit), maximum, 1)
			return (deficit < 0 and '+' or '-') .. percentage
		end, E.Classic)
	end

	E:AddTag('health:deficit-percent:name', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
		local currentHealth = UnitHealth(unit)
		local deficit = UnitHealthMax(unit) - currentHealth

		if deficit > 0 and currentHealth > 0 then
			return _TAGS['health:percent-nostatus'](unit)
		else
			return _TAGS.name(unit)
		end
	end)

	E:AddTag('health:current:name', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
		local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		local currentHealth, max = UnitHealth(unit), UnitHealthMax(unit)

		if status then
			return status
		elseif currentHealth ~= max then
			return E:GetFormattedText('CURRENT', currentHealth, max, nil, true)
		else
			return _TAGS.name(unit)
		end
	end)

	E:AddTag('power:max', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
		local powerType = UnitPowerType(unit)
		local max = UnitPowerMax(unit, powerType)

		return E:GetFormattedText('CURRENT', max, max)
	end)

	E:AddTag('power:max:healeronly', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
		local role = UnitGroupRolesAssigned(unit)
		if role ~= 'HEALER' then return end

		local powerType = UnitPowerType(unit)
		local max = UnitPowerMax(unit, powerType)

		return E:GetFormattedText('CURRENT', max, max)
	end)

	E:AddTag('power:max:shortvalue', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
		local pType = UnitPowerType(unit)
		local max = UnitPowerMax(unit, pType)

		return E:GetFormattedText('CURRENT', max, max, nil, true)
	end)

	E:AddTag('power:max:shortvalue:healeronly', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
		local role = UnitGroupRolesAssigned(unit)
		if role ~= 'HEALER' then return end

		local pType = UnitPowerType(unit)
		local max = UnitPowerMax(unit, pType)

		return E:GetFormattedText('CURRENT', max, max, nil, true)
	end)

	E:AddTag('mana:max:shortvalue', 'UNIT_MAXPOWER', function(unit)
		local max = UnitPowerMax(unit, POWERTYPE_MANA)

		return E:GetFormattedText('CURRENT', max, max, nil, true)
	end)

	E:AddTag('mana:max:shortvalue:healeronly', 'UNIT_MAXPOWER', function(unit)
		local role = UnitGroupRolesAssigned(unit)
		if role ~= 'HEALER' then return end

		local max = UnitPowerMax(unit, POWERTYPE_MANA)

		return E:GetFormattedText('CURRENT', max, max, nil, true)
	end)

	E:AddTag('selectioncolor', 'UNIT_NAME_UPDATE UNIT_FACTION INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local selection = NP:UnitSelectionType(unit)
		local cs = ElvUF.colors.selection[selection]
		return (cs and Hex(cs.r, cs.g, cs.b)) or '|cFFcccccc'
	end)

	E:AddTag('classcolor', 'UNIT_NAME_UPDATE UNIT_FACTION INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		if UnitIsPlayer(unit) or (E.Retail and UnitInPartyIsAI(unit)) then
			local _, classToken = UnitClass(unit)
			local cs = ElvUF.colors.class[classToken]
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

	E:AddTag('threat:lead', 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE', function(unit)
		local percent = UnitThreatPercentageOfLead('player', unit)
		if percent and percent > 0 and (IsInGroup() or UnitExists('pet')) then
			return format('%.0f%%', percent)
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

	E:AddTag('classpowercolor', 'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER'..(E.Retail and ' PLAYER_SPECIALIZATION_CHANGED' or ''), function(unit)
		local _, _, r, g, b = GetClassPower(unit)
		return Hex(r, g, b)
	end, E.Classic)

	E:AddTag('permana', 'UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER', function(unit)
		local m = UnitPowerMax(unit)
		if m == 0 then
			return 0
		else
			return floor(UnitPower(unit, POWERTYPE_MANA) / m * 100 + .5)
		end
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

	E:AddTag('healthcolor', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED', function(unit)
		if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
			return Hex(0.84, 0.75, 0.65)
		else
			local minHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
			local r, g, b = E:ColorGradient(maxHealth == 0 and 0 or (minHealth / maxHealth), 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			return Hex(r, g, b)
		end
	end)

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

	E:AddTag('name:first', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = UnitName(unit)
		if name and strfind(name, '%s') then
			name = strmatch(name, '^(%S+)')
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

	-- the third arg here is added from the user as like [name:health{ff00ff:00ff00}] or [name:health{class:00ff00}]
	E:AddTag('name:health', 'UNIT_NAME_UPDATE UNIT_FACTION UNIT_HEALTH UNIT_MAXHEALTH', function(unit, _, args)
		local name = UnitName(unit)
		if not name then return end

		local min, max, bco, fco = UnitHealth(unit), UnitHealthMax(unit), strsplit(':', args or '')
		local to = ceil(utf8len(name) * (min / max))

		local fill = NameHealthColor(_TAGS, fco, unit, '|cFFff3333')
		local base = NameHealthColor(_TAGS, bco, unit, '|cFFffffff')

		return to > 0 and (base..utf8sub(name, 0, to)..fill..utf8sub(name, to+1, -1)) or fill..name
	end)

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
			EVOKER		= '0:64:192:256',
		}

		E:AddTag('class:icon', 'PLAYER_TARGET_CHANGED', function(unit)
			if not (UnitIsPlayer(unit) or (E.Retail and UnitInPartyIsAI(unit))) then return end

			local _, classToken = UnitClass(unit)
			local icon = classIcons[classToken]
			if icon then
				return format(classIcon, icon)
			end
		end)
	end

	E:AddTag('spec', 'PLAYER_TALENT_UPDATE UNIT_NAME_UPDATE', function(unit)
		if not UnitIsPlayer(unit) then return end

		-- handle player
		if UnitIsUnit(unit, 'player') then
			return E.myspecName
		end

		-- try to get spec from tooltip
		local info = E.Retail and E:GetUnitSpecInfo(unit)
		if info then
			return info.name
		end
	end)

	E:AddTag('specialization', 'PLAYER_TALENT_UPDATE UNIT_NAME_UPDATE', function(unit)
		return _TAGS.spec(unit)
	end)

	E:AddTag('deficit:name', 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
		local missinghp = _TAGS.missinghp(unit)
		if missinghp then
			return '-' .. missinghp
		else
			return _TAGS.name(unit)
		end
	end)
end

E:AddTag('target', 'UNIT_TARGET', function(unit)
	local targetName = UnitName(unit..'target')
	if targetName then
		return targetName
	end
end)

E:AddTag('difficultycolor', 'UNIT_LEVEL PLAYER_LEVEL_UP', function(unit)
	local color
	if not E.Classic and (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
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

E:AddTag('smartlevel', 'UNIT_LEVEL PLAYER_LEVEL_UP', function(unit)
	local level = UnitEffectiveLevel(unit)
	if not E.Classic and (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
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

E:AddTag('distance', 0.1, function(unit)
	if UnitIsConnected(unit) and not UnitIsUnit(unit, 'player') then
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
	if not UnitIsPlayer(unit) then return end

	return GetGuildInfo(unit)
end)

E:AddTag('guild:brackets', 'PLAYER_GUILD_UPDATE', function(unit)
	local guildName = GetGuildInfo(unit)
	if guildName then
		return format('<%s>', guildName)
	end
end)

E:AddTag('guild:translit', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(unit)
	if not UnitIsPlayer(unit) then return end

	local guildName = GetGuildInfo(unit)
	if guildName then
		return Translit:Transliterate(guildName, translitMark)
	end
end)

E:AddTag('guild:brackets:translit', 'PLAYER_GUILD_UPDATE', function(unit)
	local guildName = GetGuildInfo(unit)
	if guildName then
		return format('<%s>', Translit:Transliterate(guildName, translitMark))
	end
end)

E:AddTag('guild:rank', 'UNIT_NAME_UPDATE', function(unit)
	if not UnitIsPlayer(unit) then return end

	local _, rank = GetGuildInfo(unit)
	if rank then
		return rank
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
	if not (UnitIsPlayer(unit) or (E.Retail and UnitInPartyIsAI(unit))) then return end

	local _, classToken = UnitClass(unit)
	return E:LocalizedClassName(classToken, unit)
end)

E:AddTag('name:title', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	return UnitIsPlayer(unit) and UnitPVPName(unit) or UnitName(unit)
end)

E:AddTag('title', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
	if not UnitIsPlayer(unit) then return end

	return GetTitleName(GetCurrentTitle())
end)

E:AddTag('afk', 'PLAYER_FLAGS_CHANGED', function(unit)
	if UnitIsAFK(unit) then
		return format('|cffFFFFFF[|r|cffFF9900%s|r|cFFFFFFFF]|r', L["AFK"])
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

for _, var in ipairs({4,8,10,15,20,25,30,35,40}) do
	E:AddTag(format('nearbyplayers:%s', var), 0.25, function(unit)
		local inRange = 0

		if UnitIsConnected(unit) then
			for _, units in next, E.GroupUnitsByRole do
				for _, unitToken in next, units do
					if UnitIsConnected(unitToken) and not UnitIsUnit(unit, unitToken) then
						local distance = E:GetDistance(unit, unitToken)
						if distance and distance <= var then
							inRange = inRange + 1
						end
					end
				end
			end
		end

		if inRange > 0 then
			return inRange
		end
	end)
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
	E:AddTag('classification', 'UNIT_CLASSIFICATION_CHANGED', function(unit) -- we replace the oUF tag
		return typeName[UnitClassification(unit)]
	end)
end

E:AddTag('npctitle', 'UNIT_NAME_UPDATE', function(unit)
	return GetTitleNPC(unit)
end)

E:AddTag('npctitle:brackets', 'UNIT_NAME_UPDATE', function(unit)
	return GetTitleNPC(unit, '<%s>')
end)

E:AddTag('quest:text', 'QUEST_LOG_UPDATE', function(unit)
	return GetQuestData(unit, nil, Hex)
end, E.Classic)

E:AddTag('quest:full', 'QUEST_LOG_UPDATE', function(unit)
	return GetQuestData(unit, 'full', Hex)
end, E.Classic)

E:AddTag('quest:info', 'QUEST_LOG_UPDATE', function(unit)
	return GetQuestData(unit, 'info', Hex)
end, E.Classic)

E:AddTag('quest:title', 'QUEST_LOG_UPDATE', function(unit)
	return GetQuestData(unit, 'title', Hex)
end, E.Classic)

E:AddTag('quest:count', 'QUEST_LOG_UPDATE', function(unit)
	return GetQuestData(unit, 'count', Hex)
end, E.Classic)

if not E.Retail then
	E:AddTag('pvp:title', 'UNIT_NAME_UPDATE', function(unit)
		if not UnitIsPlayer(unit) then return end

		local rank = UnitPVPRank(unit)
		local title = GetPVPRankInfo(rank, unit)

		return title
	end)

	E:AddTag('pvp:rank', 'UNIT_NAME_UPDATE', function(unit)
		if not UnitIsPlayer(unit) then return end

		local rank = UnitPVPRank(unit)
		local _, num = GetPVPRankInfo(rank, unit)

		if num > 0 then
			return num
		end
	end)

	local rankIcon = [[|TInterface\PvPRankBadges\PvPRank%02d:12:12:0:0:12:12:0:12:0:12|t]]
	E:AddTag('pvp:icon', 'UNIT_NAME_UPDATE', function(unit)
		if not UnitIsPlayer(unit) then return end

		local rank = UnitPVPRank(unit)
		local _, num = GetPVPRankInfo(rank, unit)

		if num > 0 then
			return format(rankIcon, num)
		end
	end)
end

E:AddTag('loyalty', 'UNIT_HAPPINESS PET_UI_UPDATE', function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if hasPetUI and isHunterPet and UnitIsUnit('pet', unit) then
		return (gsub(GetPetLoyalty(), '.-(%d).*', '%1'))
	end
end, not (E.Classic or E.TBC or E.Wrath))

if E.Classic or E.TBC or E.Wrath then
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
end

do
	local highestVersion = E.version
	local iconBlue = E:TextureString(E.Media.ChatLogos.ElvBlue,':13:25')
	local iconRed = E:TextureString(E.Media.ChatLogos.ElvRed,':13:25')

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

					return (userVersion < highestVersion) and iconRed or iconBlue
				end
			end
		end
	end)
end

local info = E.TagInfo -- lets add the ones from this file into the table
if info then
	info['class'] = { category = 'Class', description = "Displays the class of the unit, if that unit is a player" }
	info['class:icon'] = { category = 'Class', description = "Displays the class icon of the unit, if that unit is a player" }
	info['smartclass'] = { category = 'Class', description = "Displays the player's class or creature's type" }

	info['affix'] = { category = 'Classification', description = "Displays low level critter mobs" }
	info['classification'] = { category = 'Classification', description = "Displays the unit's classification (e.g. 'ELITE' and 'RARE')" }
	info['classification:icon'] = { category = 'Classification', description = "Displays the unit's classification in icon form (golden icon for 'ELITE' silver icon for 'RARE')" }
	info['creature'] = { category = 'Classification', description = "Displays the creature type of the unit" }

	info['classpower:current'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current amount of special power" }
	info['classpower:current-max'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current and max amount of special power, separated by a dash" }
	info['classpower:current-max-percent'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current and max amount of special power, separated by a dash (% when not full power)" }
	info['classpower:current-max-percent:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" }
	info['classpower:current-max:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" }
	info['classpower:current-percent'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current and percentage amount of special power, separated by a dash" }
	info['classpower:current-percent:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" }
	info['classpower:current:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" }
	info['classpower:deficit'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's special power as a deficit (Total Special Power - Current Special Power = -Deficit)" }
	info['classpower:deficit:shortvalue'] = { hidden = E.Classic, category = 'Classpower', description = "" }
	info['classpower:percent'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the unit's current amount of special power as a percentage" }
	info['holypower'] = { hidden = E.Classic, category = 'Classpower', description = "Displays the holy power (Paladin)" }

	info['classcolor'] = { category = 'Colors', description = "Colors names by player class or NPC reaction (Ex: [classcolor][name])" }
	info['classificationcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's classification" }
	info['classpowercolor'] = { category = 'Colors', description = "Changes the color of the special power based upon its type" }
	info['difficultycolor'] = { category = 'Colors', description = "Colors the following tags by difficulty, red for impossible, orange for hard, green for easy" }
	info['factioncolor'] = { category = 'Colors', description = "Colors names by Faction (Alliance, Horde, Neutral)" }
	info['happiness:color'] = { hidden = not (E.Classic or E.TBC or E.Wrath), category = 'Colors', description = "Changes the text color, depending on the pet happiness" }
	info['healthcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's current health" }
	info['manacolor'] = { category = 'Colors', description = "Colors the power text based on the mana color" }
	info['namecolor'] = { hidden = true, category = 'Colors', description = "Deprecated version of [classcolor]" }
	info['reactioncolor'] = { category = 'Colors', description = "Colors names by NPC reaction (Bad/Neutral/Good)" }
	info['selectioncolor'] = { category = 'Colors', description = "Colors the text, depending on the type of the unit's selection" }

	info['guild'] = { category = 'Guild', description = "Displays the guild name" }
	info['guild:brackets'] = { category = 'Guild', description = "Displays the guild name with < > brackets (e.g. <GUILD>)" }
	info['guild:brackets:translit'] = { category = 'Guild', description = "Displays the guild name with < > and transliteration (e.g. <GUILD>)" }
	info['guild:rank'] = { category = 'Guild', description = "Displays the guild rank" }
	info['guild:translit'] = { category = 'Guild', description = "Displays the guild name with transliteration for cyrillic letters" }

	info['absorbs'] = { hidden = E.Classic, category = 'Health', description = 'Displays the amount of absorbs' }
	info['deficit:name'] = { category = 'Health', description = "Displays the health as a deficit and the name at full health" }
	info['healabsorbs'] = { hidden = E.Classic, category = 'Health', description = 'Displays the amount of heal absorbs' }
	info['health:current'] = { category = 'Health', description = "Displays the current health of the unit" }
	info['health:current-max'] = { category = 'Health', description = "Displays the current and maximum health of the unit, separated by a dash" }
	info['health:current-max-nostatus'] = { category = 'Health', description = "Displays the current and maximum health of the unit, separated by a dash, without status" }
	info['health:current-max-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current and max health, without status" }
	info['health:current-max-percent'] = { category = 'Health', description = "Displays the current and max hp of the unit, separated by a dash (% when not full hp)" }
	info['health:current-max-percent-nostatus'] = { category = 'Health', description = "Displays the current and max hp of the unit, separated by a dash (% when not full hp), without status" }
	info['health:current-max-percent-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of current and max hp (% when not full hp, without status)" }
	info['health:current-max-percent:shortvalue'] = { category = 'Health', description = "Shortvalue of current and max hp (% when not full hp)" }
	info['health:current-max:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current and max hp, separated by a dash" }
	info['health:current-nostatus'] = { category = 'Health', description = "Displays the current health of the unit, without status" }
	info['health:current-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current health without status" }
	info['health:current-percent'] = { category = 'Health', description = "Displays the current hp of the unit (% when not full hp)" }
	info['health:current-percent-nostatus'] = { category = 'Health', description = "Displays the current hp of the unit (% when not full hp), without status" }
	info['health:current-percent-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current hp (% when not full hp), without status" }
	info['health:current-percent:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current hp (% when not full hp)" }
	info['health:current:name'] = { category = 'Health', description = "Displays the current health as a shortvalue and then the full name of the unit when at full health" }
	info['health:current:name-long'] = { category = 'Health', description = "Displays the current health as a shortvalue and then the name of the unit (limited to 20 letters) when at full health" }
	info['health:current:name-medium'] = { category = 'Health', description = "Displays the current health as a shortvalue and then the name of the unit (limited to 15 letters) when at full health" }
	info['health:current:name-short'] = { category = 'Health', description = "Displays the current health as a shortvalue and then the name of the unit (limited to 10 letters) when at full health" }
	info['health:current:name-veryshort'] = { category = 'Health', description = "Displays the current health as a shortvalue and then the name of the unit (limited to 5 letters) when at full health" }
	info['health:current:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current health (e.g. 81k instead of 81200)" }
	info['health:deficit'] = { category = 'Health', description = "Displays the health of the unit as a deficit (Total Health - Current Health = -Deficit)" }
	info['health:deficit-nostatus'] = { category = 'Health', description = "Displays the health of the unit as a deficit, without status" }
	info['health:deficit-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the health deficit, without status" }
	info['health:deficit-percent-absorbs'] = { hidden = E.Classic, category = 'Health', description = "Displays the percentage deficit health including absorb values. If greater than max health that will be reflected." }
	info['health:deficit-percent:name'] = { category = 'Health', description = "Displays the health deficit as a percentage and the full name of the unit" }
	info['health:deficit-percent:name-long'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 20 letters)" }
	info['health:deficit-percent:name-medium'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 15 letters)" }
	info['health:deficit-percent:name-short'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 10 letters)" }
	info['health:deficit-percent:name-veryshort'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 5 letters)" }
	info['health:deficit-percent:nostatus'] = { category = 'Health', description = "Displays the health deficit as a percentage, without status" }
	info['health:deficit:shortvalue'] = { category = 'Health', description = "Shortvalue of the health deficit (e.g. -41k instead of -41300)" }
	info['health:max'] = { category = 'Health', description = "Displays the maximum health of the unit" }
	info['health:max:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's maximum health" }
	info['health:percent'] = { category = 'Health', description = "Displays the current health of the unit as a percentage" }
	info['health:percent-nostatus'] = { category = 'Health', description = "Displays the unit's current health as a percentage, without status" }
	info['health:percent-with-absorbs'] = { hidden = E.Classic, category = 'Health', description = "Displays the unit's current health as a percentage with absorb values" }
	info['health:percent-with-absorbs:nostatus'] = { hidden = E.Classic, category = 'Health', description = "Displays the unit's current health as a percentage with absorb values, without status" }
	info['incomingheals'] = { category = 'Health', description = "Displays all incoming heals" }
	info['incomingheals:others'] = { category = 'Health', description = "Displays only incoming heals from other units" }
	info['incomingheals:personal'] = { category = 'Health', description = "Displays only personal incoming heals" }

	info['diet'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the diet of your pet (Fish, Meat, ...)" }
	info['happiness:discord'] = { hidden = not (E.Classic or E.TBC or E.Wrath), category = 'Hunter', description = "Displays the pet happiness like a Discord emoji" }
	info['happiness:full'] = { hidden = not (E.Classic or E.TBC or E.Wrath), category = 'Hunter', description = "Displays the pet happiness as a word (e.g. 'Happy')" }
	info['happiness:icon'] = { hidden = not (E.Classic or E.TBC or E.Wrath), category = 'Hunter', description = "Displays the pet happiness like the default Blizzard icon" }
	info['loyalty'] = { hidden = E.Retail, category = 'Hunter', description = "Displays the pet loyalty level" }

	info['mana:current'] = { category = 'Mana', description = "Displays the unit's current mana" }
	info['mana:current-max'] = { category = 'Mana', description = "Displays the unit's current and maximum mana, separated by a dash" }
	info['mana:current-max-percent'] = { category = 'Mana', description = "Displays the current and max mana of the unit, separated by a dash (% when not full)" }
	info['mana:current-max-percent:healeronly'] = { category = 'Mana', description = "Displays the current and max mana of the unit, separated by a dash (% when not full) if their role is set to healer" }
	info['mana:current-max-percent:shortvalue'] = { category = 'Mana', description = "" }
	info['mana:current-max-percent:shortvalue:healeronly'] = { category = 'Mana', description = "" }
	info['mana:current-max:healeronly'] = { category = 'Mana', description = "Displays the unit's current and maximum mana, separated by a dash if their role is set to healer" }
	info['mana:current-max:shortvalue'] = { category = 'Mana', description = "" }
	info['mana:current-max:shortvalue:healeronly'] = { category = 'Mana', description = "" }
	info['mana:current-percent'] = { category = 'Mana', description = "Displays the current mana of the unit and % when not full" }
	info['mana:current-percent:healeronly'] = { category = 'Mana', description = "Displays the current mana of the unit and % when not full if their role is set to healer" }
	info['mana:current-percent:shortvalue'] = { category = 'Mana', description = "" }
	info['mana:current-percent:shortvalue:healeronly'] = { category = 'Mana', description = "" }
	info['mana:current:healeronly'] = { category = 'Mana', description = "Displays the unit's current mana if their role is set to healer" }
	info['mana:current:shortvalue'] = { category = 'Mana', description = "" }
	info['mana:current:shortvalue:healeronly'] = { category = 'Mana', description = "" }
	info['mana:deficit'] = { category = 'Mana', description = "Displays the player's mana as a deficit" }
	info['mana:deficit:healeronly'] = { category = 'Mana', description = "Displays the player's mana as a deficit if their role is set to healer" }
	info['mana:deficit:shortvalue'] = { category = 'Mana', description = "" }
	info['mana:deficit:shortvalue:healeronly'] = { category = 'Mana', description = "" }
	info['mana:max:shortvalue'] = { category = 'Mana', description = "" }
	info['mana:max:shortvalue:healeronly'] = { category = 'Mana', description = "" }
	info['mana:percent'] = { category = 'Mana', description = "Displays the player's mana as a percentage" }
	info['mana:percent:healeronly'] = { category = 'Mana', description = "Displays the player's mana as a percentage if their role is set to healer" }
	info['permana'] = { category = 'Mana', description = "Displays the unit's mana percentage without decimals" }

	info['race'] = { category = 'Miscellaneous', description = "Displays the race" }

	info['name:abbrev'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')" }
	info['name:abbrev:long'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 20 letters)" }
	info['name:abbrev:medium'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 15 letters)" }
	info['name:abbrev:short'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 10 letters)" }
	info['name:abbrev:veryshort'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 5 letters)" }
	info['name:first'] = { category = 'Names', description = "Displays the first word of the unit's name" }
	info['name:health'] = { hidden = true, category = 'Names', description = "" }
	info['name:last'] = { category = 'Names', description = "Displays the last word of the unit's name" }
	info['name:long'] = { category = 'Names', description = "Displays the name of the unit (limited to 20 letters)" }
	info['name:long:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 20 letters)" }
	info['name:long:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 20 letters)" }
	info['name:medium'] = { category = 'Names', description = "Displays the name of the unit (limited to 15 letters)" }
	info['name:medium:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 15 letters)" }
	info['name:medium:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 15 letters)" }
	info['name:short'] = { category = 'Names', description = "Displays the name of the unit (limited to 10 letters)" }
	info['name:short:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 10 letters)" }
	info['name:short:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 10 letters)" }
	info['name:title'] = { category = 'Names', description = "Displays player name and title" }
	info['name:veryshort'] = { category = 'Names', description = "Displays the name of the unit (limited to 5 letters)" }
	info['name:veryshort:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 5 letters)" }
	info['name:veryshort:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 5 letters)" }
	info['npctitle'] = { category = 'Names', description = "Displays the NPC title (e.g. General Goods Vendor)" }
	info['npctitle:brackets'] = { category = 'Names', description = "Displays the NPC title with brackets (e.g. <General Goods Vendor>)" }
	info['title'] = { category = 'Names', description = "Displays player title" }

	info['group:raid'] = { category = 'Party and Raid', description = "Displays the group number the unit is in (1-8): Only while in a raid." }

	info['power:current'] = { category = 'Power', description = "Displays the unit's current amount of power" }
	info['power:current-max'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash" }
	info['power:current-max-percent'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash (% when not full power)" }
	info['power:current-max-percent:healeronly'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash (% when not full power) if their role is set to healer" }
	info['power:current-max-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash (% when not full power)" }
	info['power:current-max-percent:shortvalue:healeronly'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash (% when not full power) if their role is set to healer" }
	info['power:current-max:healeronly'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash if their role is set to healer" }
	info['power:current-max:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash" }
	info['power:current-max:shortvalue:healeronly'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash if their role is set to healer" }
	info['power:current-percent'] = { category = 'Power', description = "Displays the current power and power as a percentage, separated by a dash" }
	info['power:current-percent:healeronly'] = { category = 'Power', description = "Displays the current power and power as a percentage, separated by a dash if their role is set to healer" }
	info['power:current-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and power as a percentage, separated by a dash" }
	info['power:current-percent:shortvalue:healeronly'] = { category = 'Power', description = "Shortvalue of the current power and power as a percentage, separated by a dash if their role is set to healer" }
	info['power:current:healeronly'] = { category = 'Power', description = "Displays the unit's current amount of power if their role is set to healer" }
	info['power:current:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's current amount of power (e.g. 4k instead of 4000)" }
	info['power:current:shortvalue:healeronly'] = { category = 'Power', description = "Shortvalue of the unit's current amount of power (e.g. 4k instead of 4000) if their role is set to healer" }
	info['power:deficit'] = { category = 'Power', description = "Displays the power as a deficit (Total Power - Current Power = -Deficit)" }
	info['power:deficit:healeronly'] = { category = 'Power', description = "Displays the power as a deficit (Total Power - Current Power = -Deficit) if their role is set to healer" }
	info['power:deficit:shortvalue'] = { category = 'Power', description = "Shortvalue of the power as a deficit (Total Power - Current Power = -Deficit)" }
	info['power:deficit:shortvalue:healeronly'] = { category = 'Power', description = "Shortvalue of the power as a deficit (Total Power - Current Power = -Deficit) if their role is set to healer" }
	info['power:max'] = { category = 'Power', description = "Displays the unit's maximum power" }
	info['power:max:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's maximum power" }
	info['power:max:shortvalue:healeronly'] = { category = 'Power', description = "Shortvalue of the unit's maximum power if their role is set to healer" }
	info['power:percent'] = { category = 'Power', description = "Displays the unit's power as a percentage" }
	info['power:percent:healeronly'] = { category = 'Power', description = "Displays the unit's power as a percentage if their role is set to healer" }

	info['arena:number'] = { category = 'PvP', description = "Displays the arena number 1-5" }
	info['faction:icon'] = { category = 'PvP', description = "Displays the 'Alliance' or 'Horde' texture" }
	info['pvp:icon'] = { hidden = E.Retail, category = 'PvP', description = "Displays player pvp rank icon" }
	info['pvp:rank'] = { hidden = E.Retail, category = 'PvP', description = "Displays player pvp rank number" }
	info['pvp:title'] = { hidden = E.Retail, category = 'PvP', description = "Displays player pvp title" }
	info['pvptimer'] = { category = 'PvP', description = "Displays remaining time on pvp-flagged status" }

	info['quest:count'] = { category = 'Quest', description = "Displays the quest count" }
	info['quest:full'] = { category = 'Quest', description = "Quest full" }
	info['quest:info'] = { category = 'Quest', description = "Displays the quest objectives" }
	info['quest:text'] = { category = 'Quest', description = "Quest text" }
	info['quest:title'] = { category = 'Quest', description = "Displays the quest title" }

	info['distance'] = { category = 'Range', description = "Displays the distance" }
	info['nearbyplayers:10'] = { category = 'Range', description = "Displays all players within 10 yards" }
	info['nearbyplayers:15'] = { category = 'Range', description = "Displays all players within 15 yards" }
	info['nearbyplayers:20'] = { category = 'Range', description = "Displays all players within 20 yards" }
	info['nearbyplayers:25'] = { category = 'Range', description = "Displays all players within 25 yards" }
	info['nearbyplayers:30'] = { category = 'Range', description = "Displays all players within 30 yards" }
	info['nearbyplayers:35'] = { category = 'Range', description = "Displays all players within 35 yards" }
	info['nearbyplayers:4'] = { category = 'Range', description = "Displays all players within 4 yards" }
	info['nearbyplayers:40'] = { category = 'Range', description = "Displays all players within 40 yards" }
	info['nearbyplayers:8'] = { category = 'Range', description = "Displays all players within 8 yards" }

	info['realm'] = { category = 'Realm', description = "Displays the server name" }
	info['realm:dash'] = { category = 'Realm', description = "Displays the server name with a dash in front (e.g. -Realm)" }
	info['realm:dash:translit'] = { category = 'Realm', description = "Displays the server name with transliteration for cyrillic letters and a dash in front" }
	info['realm:translit'] = { category = 'Realm', description = "Displays the server name with transliteration for cyrillic letters" }

	info['speed:percent'] = { category = 'Speed' }
	info['speed:percent-moving'] = { category = 'Speed' }
	info['speed:percent-moving-raw'] = { category = 'Speed' }
	info['speed:percent-raw'] = { category = 'Speed' }
	info['speed:yardspersec'] = { category = 'Speed' }
	info['speed:yardspersec-moving'] = { category = 'Speed' }
	info['speed:yardspersec-moving-raw'] = { category = 'Speed' }
	info['speed:yardspersec-raw'] = { category = 'Speed' }

	info['afk'] = { category = 'Status', description = "Displays <AFK> if the unit is afk" }
	info['ElvUI-Users'] = { category = 'Status', description = "Displays current ElvUI users" }
	info['status:icon'] = { category = 'Status', description = "Displays AFK/DND as an orange(afk) / red(dnd) icon" }
	info['status:text'] = { category = 'Status', description = "Displays <AFK> and <DND>" }
	info['statustimer'] = { category = 'Status', description = "Displays a timer for how long a unit has had the status (e.g 'DEAD - 0:34')" }

	info['classcolor:target'] = { category = 'Target', description = "[classcolor] but for the current target of the unit" }
	info['target'] = { category = 'Target', description = "Displays the current target of the unit" }
	info['target:abbrev'] = { category = 'Target', description = "Displays the name of the unit's target with abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')" }
	info['target:abbrev:long'] = { category = 'Target', description = "Displays the name of the unit's target with abbreviation (limited to 20 letters)" }
	info['target:abbrev:medium'] = { category = 'Target', description = "Displays the name of the unit's target with abbreviation (limited to 15 letters)" }
	info['target:abbrev:short'] = { category = 'Target', description = "Displays the name of the unit's target with abbreviation (limited to 10 letters)" }
	info['target:abbrev:veryshort'] = { category = 'Target', description = "Displays the name of the unit's target with abbreviation (limited to 5 letters)" }
	info['target:last'] = { category = 'Target', description = "Displays the last word of the unit's target's name" }
	info['target:long'] = { category = 'Target', description = "Displays the current target of the unit (limited to 20 letters)" }
	info['target:long:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 20 letters)" }
	info['target:medium'] = { category = 'Target', description = "Displays the current target of the unit (limited to 15 letters)" }
	info['target:medium:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 15 letters)" }
	info['target:short'] = { category = 'Target', description = "Displays the current target of the unit (limited to 10 letters)" }
	info['target:short:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 10 letters)" }
	info['target:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters" }
	info['target:veryshort'] = { category = 'Target', description = "Displays the current target of the unit (limited to 5 letters)" }
	info['target:veryshort:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 5 letters)" }

	info['threat:current'] = { category = 'Threat', description = "Displays the current threat as a value" }
	info['threat:lead'] = { category = 'Threat', description = "Displays the current threat of lead as a percent" }
	info['threat:percent'] = { category = 'Threat', description = "Displays the current threat as a percent" }
end
