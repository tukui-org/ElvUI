local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

ElvUF.Tags.Events['health:current'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
ElvUF.Tags.Methods['health:current'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local status = not UnitIsConnected(unit) and L['Offline'] or UnitIsGhost(unit) and L['Ghost'] or UnitIsDead(unit) and DEAD

	if (status) then
		return status
	else
		local r, g, b = ElvUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return E:GetFormattedText('CURRENT', min, max, r, g, b, 0.33, 0.59, 0.33, 0.84, 0.75, 0.65)
	end
end

ElvUF.Tags.Events['health:deficit'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
ElvUF.Tags.Methods['health:deficit'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local status = not UnitIsConnected(unit) and L['Offline'] or UnitIsGhost(unit) and L['Ghost'] or UnitIsDead(unit) and DEAD

	if (status) then
		return status
	else
		local r, g, b = ElvUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return E:GetFormattedText('DEFICIT', min, max, r, g, b, 0.33, 0.59, 0.33, 0.84, 0.75, 0.65)
	end
end

ElvUF.Tags.Events['health:current-percent'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
ElvUF.Tags.Methods['health:current-percent'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local status = not UnitIsConnected(unit) and L['Offline'] or UnitIsGhost(unit) and L['Ghost'] or UnitIsDead(unit) and DEAD

	if (status) then
		return status
	else
		local r, g, b = ElvUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return E:GetFormattedText('CURRENT_PERCENT', min, max, r, g, b, 0.33, 0.59, 0.33, 0.84, 0.75, 0.65)
	end
end

ElvUF.Tags.Events['health:current-max'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
ElvUF.Tags.Methods['health:current-max'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local status = not UnitIsConnected(unit) and L['Offline'] or UnitIsGhost(unit) and L['Ghost'] or UnitIsDead(unit) and DEAD

	if (status) then
		return status
	else
		local r, g, b = ElvUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return E:GetFormattedText('CURRENT_MAX', min, max, r, g, b, 0.33, 0.59, 0.33, 0.84, 0.75, 0.65)
	end
end

ElvUF.Tags.Events['health:current-max-percent'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
ElvUF.Tags.Methods['health:current-max-percent'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local status = not UnitIsConnected(unit) and L['Offline'] or UnitIsGhost(unit) and L['Ghost'] or UnitIsDead(unit) and DEAD

	if (status) then
		return status
	else
		local r, g, b = ElvUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return E:GetFormattedText('CURRENT_MAX_PERCENT', min, max, r, g, b, 0.33, 0.59, 0.33, 0.84, 0.75, 0.65)
	end
end

ElvUF.Tags.Events['health:percent'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
ElvUF.Tags.Methods['health:percent'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local status = not UnitIsConnected(unit) and L['Offline'] or UnitIsGhost(unit) and L['Ghost'] or UnitIsDead(unit) and DEAD

	if (status) then
		return status
	else
		local r, g, b = ElvUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return E:GetFormattedText('PERCENT', min, max, r, g, b, 0.33, 0.59, 0.33, 0.84, 0.75, 0.65)
	end
end

ElvUF.Tags.Events['power:current'] = 'UNIT_POWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	
	local r, g, b = altR, altG, altB
	local color = ElvUF['colors'].power[pToken]
	if color then
		r, g, b = color[1], color[2], color[3]
	end
	
	return E:GetFormattedText('CURRENT', min, max, r, g, b)
end

ElvUF.Tags.Events['power:current-max'] = 'UNIT_POWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current-max'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	
	local r, g, b = altR, altG, altB
	local color = ElvUF['colors'].power[pToken]
	if color then
		r, g, b = color[1], color[2], color[3]
	end
	
	return E:GetFormattedText('CURRENT_MAX', min, max, r, g, b)
end

ElvUF.Tags.Events['power:current-percent'] = 'UNIT_POWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current-percent'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	
	local r, g, b = altR, altG, altB
	local color = ElvUF['colors'].power[pToken]
	if color then
		r, g, b = color[1], color[2], color[3]
	end
	
	return E:GetFormattedText('CURRENT_PERCENT', min, max, r, g, b)
end

ElvUF.Tags.Events['power:current-max-percent'] = 'UNIT_POWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:current-max-percent'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	
	local r, g, b = altR, altG, altB
	local color = ElvUF['colors'].power[pToken]
	if color then
		r, g, b = color[1], color[2], color[3]
	end
	
	return E:GetFormattedText('CURRENT_MAX_PERCENT', min, max, r, g, b)
end

ElvUF.Tags.Events['power:percent'] = 'UNIT_POWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:percent'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	
	local r, g, b = altR, altG, altB
	local color = ElvUF['colors'].power[pToken]
	if color then
		r, g, b = color[1], color[2], color[3]
	end
	
	return E:GetFormattedText('PERCENT', min, max, r, g, b)
end

ElvUF.Tags.Events['power:deficit'] = 'UNIT_POWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:deficit'] = function(unit)
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	
	local r, g, b = altR, altG, altB
	local color = ElvUF['colors'].power[pToken]
	if color then
		r, g, b = color[1], color[2], color[3]
	end
	
	return E:GetFormattedText('DEFICIT', min, max, r, g, b)
end

ElvUF.Tags.Events['difficultycolor'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['difficultycolor'] = function(unit)
	local r, g, b = 0.69, 0.31, 0.31
	local level = UnitLevel(unit)
	if not (level < 1) then
		local DiffColor = UnitLevel('target') - UnitLevel('player')
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
	
	return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
end

ElvUF.Tags.Events['colorname'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['colorname'] = function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = RAID_CLASS_COLORS[unitClass]
		if not class then return "" end
		return string.format('|cff%02x%02x%02x', class.r * 255, class.g * 255, class.b * 255)
	elseif (unitReaction) then
		local reaction = ElvUF['colors'].reaction[unitReaction]
		return string.format('|cff%02x%02x%02x', reaction[1] * 255, reaction[2] * 255, reaction[3] * 255)
	else
		return string.format('|cff%02x%02x%02x', 214, 191, 166)	
	end
end

ElvUF.Tags.Events['level'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['level'] = function(unit)
	local level = UnitLevel(unit)
	if level == UnitLevel('player') and unit ~= 'player' then
		return ''
	elseif(level > 0) then
		return level
	else
		return '??'
	end
end

ElvUF.Tags.Events['name:short'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:short'] = function(unit)
	local name = UnitName(unit)
	return E:ShortenString(name, 10)
end

ElvUF.Tags.Events['name:medium'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:medium'] = function(unit)
	local name = UnitName(unit)
	return E:ShortenString(name, 15)
end

ElvUF.Tags.Events['name:long'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:long'] = function(unit)
	local name = UnitName(unit)
	return E:ShortenString(name, 20)
end