local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")
local twipe = table.wipe
local ceil, sqrt = math.ceil, math.sqrt
------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

local function UnitName(unit)
	local name = _G.UnitName(unit);
	if name == UNKNOWN and E.myclass == "MONK" and UnitIsUnit(unit, "pet") then
		name = UNITNAME_SUMMON_TITLE17:format(_G.UnitName("player"))
	else
		return name
	end
end

ElvUF.Tags.Events['altpower:percent'] = "UNIT_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods['altpower:percent'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)

		return E:GetFormattedText('PERCENT', cur, max)
	else
		return ''
	end
end

ElvUF.Tags.Events['altpower:current'] = "UNIT_POWER"
ElvUF.Tags.Methods['altpower:current'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		return cur
	else
		return ''
	end
end

ElvUF.Tags.Events['altpower:current-percent'] = "UNIT_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods['altpower:current-percent'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)

		return E:GetFormattedText('CURRENT_PERCENT', cur, max)
	else
		return ''
	end
end

ElvUF.Tags.Events['altpower:deficit'] = "UNIT_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods['altpower:deficit'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)

		return E:GetFormattedText('DEFICIT', cur, max)
	else
		return ''
	end
end

ElvUF.Tags.Events['altpower:current-max'] = "UNIT_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods['altpower:current-max'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)

		return E:GetFormattedText('CURRENT_MAX', cur, max)
	else
		return ''
	end
end

ElvUF.Tags.Events['altpower:current-max-percent'] = "UNIT_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods['altpower:current-max-percent'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)

		E:GetFormattedText('CURRENT_MAX_PERCENT', cur, max)
	else
		return ''
	end
end

ElvUF.Tags.Events['altpowercolor'] = "UNIT_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods['altpowercolor'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local tPath, r, g, b = UnitAlternatePowerTextureInfo(u, 2)

		if not r then
			r, g, b = 1, 1, 1
		end

		return Hex(r,g,b)
	else
		return ''
	end
end

ElvUF.Tags.Events['afk'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['afk'] = function(unit)
	local isAFK = UnitIsAFK(unit)
	if isAFK then
		return ('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r'):format(DEFAULT_AFK_MESSAGE)
	else
		return ''
	end
end

ElvUF.Tags.Events['healthcolor'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['healthcolor'] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hex(0.84, 0.75, 0.65)
	else
		local r, g, b = ElvUF.ColorGradient(UnitHealth(unit), UnitHealthMax(unit), 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return Hex(r, g, b)
	end
end

ElvUF.Tags.Events['health:current'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['health:current'] = function(unit)
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']
	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events['health:deficit'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['health:deficit'] = function(unit)
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('DEFICIT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events['health:current-percent'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['health:current-percent'] = function(unit)
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT_PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events['health:current-max'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['health:current-max'] = function(unit)
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT_MAX', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events['health:current-max-percent'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['health:current-max-percent'] = function(unit)
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT_MAX_PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events['health:max'] = 'UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:max'] = function(unit)
	local max = UnitHealthMax(unit)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['health:percent'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['health:percent'] = function(unit)
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events['health:current-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:current-nostatus'] = function(unit)
	return E:GetFormattedText('CURRENT', UnitHealth(unit), UnitHealthMax(unit))
end

ElvUF.Tags.Events['health:deficit-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:deficit-nostatus'] = function(unit)
	return E:GetFormattedText('DEFICIT', UnitHealth(unit), UnitHealthMax(unit))
end

ElvUF.Tags.Events['health:current-percent-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:current-percent-nostatus'] = function(unit)
	return E:GetFormattedText('CURRENT_PERCENT', UnitHealth(unit), UnitHealthMax(unit))
end

ElvUF.Tags.Events['health:current-max-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:current-max-nostatus'] = function(unit)
	return E:GetFormattedText('CURRENT_MAX', UnitHealth(unit), UnitHealthMax(unit))
end

ElvUF.Tags.Events['health:current-max-percent-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:current-max-percent-nostatus'] = function(unit)
	return E:GetFormattedText('CURRENT_MAX_PERCENT', UnitHealth(unit), UnitHealthMax(unit))
end

ElvUF.Tags.Events['health:percent-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:percent-nostatus'] = function(unit)
	return E:GetFormattedText('PERCENT', UnitHealth(unit), UnitHealthMax(unit))
end

ElvUF.Tags.Events['powercolor'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['powercolor'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)	
	local color = ElvUF['colors'].power[pToken]
	if color then
		return Hex(color[1], color[2], color[3])
	else
		return Hex(altR, altG, altB)
	end
end

ElvUF.Tags.Events['power:current'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current'] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)
	
	return min == 0 and ' ' or	E:GetFormattedText('CURRENT', min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events['power:current-max'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current-max'] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('CURRENT_MAX', min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events['power:current-percent'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current-percent'] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('CURRENT_PERCENT', min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events['power:current-max-percent'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current-max-percent'] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('CURRENT_MAX_PERCENT', min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events['power:percent'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:percent'] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('PERCENT', min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events['power:deficit'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:deficit'] = function(unit)
	local pType = UnitPowerType(unit)
		
	return E:GetFormattedText('DEFICIT', UnitPower(unit, pType), UnitPowerMax(unit, pType), r, g, b)
end

ElvUF.Tags.Events['power:max'] = 'UNIT_DISPLAYPOWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:max'] = function(unit)
	local max = UnitPowerMax(unit, UnitPowerType(unit))
			
	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['mana:current'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:current'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		local min = UnitPower(unit, pType)
		return min == 0 and ' ' or	E:GetFormattedText('CURRENT', min, UnitPowerMax(unit, pType))
	else
		return ''
	end
end

ElvUF.Tags.Events['mana:current-max'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:current-max'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		local min = UnitPower(unit, pType)
		return min == 0 and ' ' or	E:GetFormattedText('CURRENT_MAX', min, UnitPowerMax(unit, pType))
	else
		return ''
	end
end

ElvUF.Tags.Events['mana:current-percent'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:current-percent'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		local min = UnitPower(unit, pType)
		return min == 0 and ' ' or	E:GetFormattedText('CURRENT_PERCENT', min, UnitPowerMax(unit, pType))
	else
		return ''
	end
end

ElvUF.Tags.Events['mana:current-max-percent'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:current-max-percent'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		local min = UnitPower(unit, pType)
		return min == 0 and ' ' or	E:GetFormattedText('CURRENT_MAX_PERCENT', min, UnitPowerMax(unit, pType))
	else
		return ''
	end
end

ElvUF.Tags.Events['mana:percent'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:percent'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		local min = UnitPower(unit, pType)
		return min == 0 and ' ' or	E:GetFormattedText('PERCENT', min, UnitPowerMax(unit, pType))
	else
		return ''
	end
end

ElvUF.Tags.Events['mana:deficit'] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:deficit'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		return E:GetFormattedText('DEFICIT', UnitPower(unit, pType), UnitPowerMax(unit, pType), r, g, b)
	else
		return ''
	end
end

ElvUF.Tags.Events['mana:max'] = 'UNIT_DISPLAYPOWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:max'] = function(unit)
	local pType = UnitPowerType(unit)
	if pType == 0 then
		local max = UnitPowerMax(unit, UnitPowerType(unit))		
		return E:GetFormattedText('CURRENT', max, max)
	else
		return ''
	end
end

ElvUF.Tags.Events['difficultycolor'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['difficultycolor'] = function(unit)
	local r, g, b = 0.55, 0.57, 0.61
	if ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
		level = UnitBattlePetLevel(unit)

		local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
		if teamLevel < level or teamLevel > level then
			local c = GetRelativeDifficultyColor(teamLevel, level)
			r, g, b = c.r, c.g, c.b
		else
			local c = QuestDifficultyColors["difficult"]
			r, g, b = c.r, c.g, c.b
		end
	else
		local DiffColor = UnitLevel(unit) - UnitLevel('player')
		if (DiffColor >= 5) then
			r, g, b = 0.69, 0.31, 0.31
		elseif (DiffColor >= 3) then
			r, g, b = 0.71, 0.43, 0.27
		elseif (DiffColor >= -2) then
			r, g, b = 0.84, 0.75, 0.65
		elseif (-DiffColor <= GetQuestGreenRange()) then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	
	return Hex(r, g, b)
end

ElvUF.Tags.Events['namecolor'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['namecolor'] = function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = ElvUF.colors.class[unitClass]
		if not class then return "" end
		return Hex(class[1], class[2], class[3])
	elseif (unitReaction) then
		local reaction = ElvUF['colors'].reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return '|cFFC2C2C2'
	end
end

ElvUF.Tags.Events['smartlevel'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['smartlevel'] = function(unit)
	local level = UnitLevel(unit)
	if ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
		return UnitBattlePetLevel(unit);
	elseif level == UnitLevel('player') then
		return ''
	elseif(level > 0) then
		return level
	else
		return '??'
	end
end

ElvUF.Tags.Events['name:veryshort'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:veryshort'] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 5) or ''
end

ElvUF.Tags.Events['name:short'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:short'] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 10) or ''
end

ElvUF.Tags.Events['name:medium'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:medium'] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 15) or ''
end

ElvUF.Tags.Events['name:long'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:long'] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 20) or ''
end

ElvUF.Tags.Events['threat:percent'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['threat:percent'] = function(unit)
	local _, _, percent = UnitDetailedThreatSituation('player', unit)
	if(percent and percent > 0) and (IsInGroup() or UnitExists('pet')) then
		return format('%.0f%%', percent)
	else 
		return ''
	end
end

ElvUF.Tags.Events['threat:current'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['threat:current'] = function(unit)
	local _, _, percent, _, threatvalue = UnitDetailedThreatSituation('player', unit)
	if(percent and percent > 0) and (IsInGroup() or UnitExists('pet')) then
		return E:ShortValue(threatvalue)
	else 
		return ''
	end
end

ElvUF.Tags.Events['threatcolor'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['threatcolor'] = function(unit)
	local _, status = UnitDetailedThreatSituation('player', unit)
	if (status) and (IsInGroup() or UnitExists('pet')) then
		return Hex(GetThreatStatusColor(status))
	else 
		return ''
	end
end

local unitStatus = {}
ElvUF.Tags.OnUpdateThrottle['statustimer'] = 1
ElvUF.Tags.Methods['statustimer'] = function(unit)
	if not UnitIsPlayer(unit) then return; end
	local guid = UnitGUID(unit)
	if (UnitIsAFK(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'AFK' then 
			unitStatus[guid] = {'AFK', GetTime()} 
		end
	elseif(UnitIsDND(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'DND' then 
			unitStatus[guid] = {'DND', GetTime()} 
		end
	elseif(UnitIsDead(unit)) or (UnitIsGhost(unit))then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'Dead' then 
			unitStatus[guid] = {'Dead', GetTime()} 
		end
	elseif(not UnitIsConnected(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'Offline' then 
			unitStatus[guid] = {'Offline', GetTime()} 
		end
	else
		unitStatus[guid] = nil
	end

	if unitStatus[guid] ~= nil then
		local status = unitStatus[guid][1]
		local timer = GetTime() - unitStatus[guid][2]
		local mins = floor(timer / 60)
		local secs = floor(timer - (mins * 60))
		return ("%s (%01.f:%02.f)"):format(status, mins, secs)
	else 
		return ''
	end
end

ElvUF.Tags.OnUpdateThrottle['pvptimer'] = 1
ElvUF.Tags.Methods['pvptimer'] = function(unit)	
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then	
			local mins = floor((timer / 1000) / 60)
			local secs = floor((timer / 1000) - (mins * 60))
			return ("%s (%01.f:%02.f)"):format(PVP, mins, secs)
		else
			return PVP
		end
	else
		return ""
	end
end

local Harmony = { 
	[0] = {1, 1, 1},
	[1] = {.57, .63, .35, 1},
	[2] = {.47, .63, .35, 1},
	[3] = {.37, .63, .35, 1},
	[4] = {.27, .63, .33, 1},
	[5] = {.17, .63, .33, 1},
	[6] = {.17, .63, .33, 1},
}

local function GetClassPower(class)
	local min, max, r, g, b = 0, 0, 0, 0, 0
	local spec = GetSpecialization()
	if class == 'PALADIN' then
		min = UnitPower('player', SPELL_POWER_HOLY_POWER);
		max = UnitPowerMax('player', SPELL_POWER_HOLY_POWER);	
		r, g, b = 228/255, 225/255, 16/255
	elseif class == 'MONK' then
		min = UnitPower("player", SPELL_POWER_CHI)
		max = UnitPowerMax("player", SPELL_POWER_CHI)
		r, g, b = unpack(Harmony[min])
	elseif class == 'DRUID' and GetShapeshiftFormID() == MOONKIN_FORM then
		min = UnitPower('player', SPELL_POWER_ECLIPSE)
		max = UnitPowerMax('player', SPELL_POWER_ECLIPSE)
		if GetEclipseDirection() == 'moon' then
			r, g, b = .80, .82,  .60
		else
			r, g, b = .30, .52, .90
		end
	elseif class == 'PRIEST' and spec == SPEC_PRIEST_SHADOW and UnitLevel("player") > SHADOW_ORBS_SHOW_LEVEL then
		min = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
		max = UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS)
		r, g, b = 1, 1, 1
	elseif class == 'WARLOCK' then
		if (spec == SPEC_WARLOCK_DESTRUCTION) then	
			min = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
			max = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
			min = math.floor(min / 10)
			max = math.floor(max / 10)
			r, g, b = 230/255, 95/255,  95/255
		elseif ( spec == SPEC_WARLOCK_AFFLICTION ) then
			min = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
			max = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)
			r, g, b = 148/255, 130/255, 201/255
		elseif spec == SPEC_WARLOCK_DEMONOLOGY then
			min = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
			max = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
			r, g, b = 148/255, 130/255, 201/255
		end
	end
	
	return min, max, r, g, b
end

ElvUF.Tags.Events['classpowercolor'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpowercolor'] = function()
	local _, _, r, g, b = GetClassPower(E.myclass)
	return Hex(r, g, b)
end

ElvUF.Tags.Events['classpower:current'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpower:current'] = function()
	local min, max = GetClassPower(E.myclass)
	if min == 0 then
		return ' '
	else
		return E:GetFormattedText('CURRENT', min, max)
	end	
end

ElvUF.Tags.Events['classpower:deficit'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpower:deficit'] = function()
	local min, max = GetClassPower(E.myclass)
	if min == 0 then
		return ' '
	else
		return E:GetFormattedText('DEFICIT', min, max)
	end
end

ElvUF.Tags.Events['classpower:current-percent'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpower:current-percent'] = function()
	local min, max = GetClassPower(E.myclass)
	if min == 0 then
		return ' '
	else
		return E:GetFormattedText('CURRENT_PERCENT', min, max)
	end
end

ElvUF.Tags.Events['classpower:current-max'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpower:current-max'] = function()
	local min, max = GetClassPower(E.myclass)
	if min == 0 then
		return ' '
	else
		return E:GetFormattedText('CURRENT_MAX', min, max)
	end
end

ElvUF.Tags.Events['classpower:current-max-percent'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpower:current-max-percent'] = function()
	local min, max = GetClassPower(E.myclass)
	if min == 0 then
		return ' '
	else
		return E:GetFormattedText('CURRENT_MAX_PERCENT', min, max)
	end
end

ElvUF.Tags.Events['classpower:percent'] = 'UNIT_POWER_FREQUENT PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM'
ElvUF.Tags.Methods['classpower:percent'] = function()
	local min, max = GetClassPower(E.myclass)
	if min == 0 then
		return ' '
	else
		return E:GetFormattedText('PERCENT', min, max)
	end
end

ElvUF.Tags.Events['absorbs'] = 'UNIT_ABSORB_AMOUNT_CHANGED'
ElvUF.Tags.Methods['absorbs'] = function(unit)
	local absorb = UnitGetTotalAbsorbs(unit) or 0
	if absorb == 0 then
		return ' '
	else
		return E:ShortValue(absorb)
	end
end

ElvUF.Tags.Events['incomingheals:personal'] = 'UNIT_HEAL_PREDICTION'
ElvUF.Tags.Methods['incomingheals:personal'] = function(unit)
	local heal = UnitGetIncomingHeals(unit, 'player') or 0
	if heal == 0 then
		return ' '
	else
		return E:ShortValue(heal)
	end
end

ElvUF.Tags.Events['incomingheals:others'] = 'UNIT_HEAL_PREDICTION'
ElvUF.Tags.Methods['incomingheals:others'] = function(unit)
	local heal = UnitGetIncomingHeals(unit) or 0
	if heal == 0 then
		return ' '
	else
		return E:ShortValue(heal)
	end
end

ElvUF.Tags.Events['incomingheals'] = 'UNIT_HEAL_PREDICTION'
ElvUF.Tags.Methods['incomingheals'] = function(unit)
	local personal = UnitGetIncomingHeals(unit, 'player') or 0
	local others = UnitGetIncomingHeals(unit) or 0
	local heal = personal + others
	if heal == 0 then
		return ' '
	else
		return E:ShortValue(heal)
	end
end

local GroupUnits = {}
local f = CreateFrame("Frame")

f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
	local groupType, groupSize
	twipe(GroupUnits)

	if IsInRaid() then
		groupType = "raid"
		groupSize = GetNumGroupMembers()
	elseif IsInGroup() then
		groupType = "party"
		groupSize = GetNumGroupMembers() - 1
		GroupUnits["player"] = true
	else
		groupType = "solo"
		groupSize = 1
	end

	for index = 1, groupSize do
		local unit = groupType..index
		if not UnitIsUnit(unit, "player") then
			GroupUnits[unit] = true
		end
	end
end)

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:8'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:8'] = function(unit)
	local unitsInRange, d = 0
	if UnitIsConnected(unit) then
		for groupUnit, _ in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				d = E:GetDistance(unit, groupUnit, true)
				if d and d <= 8 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end
	
	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:10'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:10'] = function(unit)
	local unitsInRange, d = 0
	if UnitIsConnected(unit) then
		for groupUnit, _ in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				d = E:GetDistance(unit, groupUnit, true)
				if d and d <= 10 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end
	
	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:30'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:30'] = function(unit)
	local unitsInRange, d = 0
	if UnitIsConnected(unit) then
		for groupUnit, _ in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				d = E:GetDistance(unit, groupUnit, true)
				if d and d <= 30 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end
	
	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['distance'] = 0.1
ElvUF.Tags.Methods['distance'] = function(unit)
	local d
	if UnitIsConnected(unit) and not UnitIsUnit(unit, 'player') then
		d = E:GetDistance('player', unit, true)

		if d then
			d = format("%.1f", d)
		end
	end
	
	return d or ''
end