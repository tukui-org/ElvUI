if not TukuiDB["unitframes"].enable == true then return end

oUF.TagEvents['[DiffColor]'] = 'UNIT_LEVEL'
if (not oUF.Tags['[DiffColor]']) then
	oUF.Tags['[DiffColor]']  = function(unit)
		local r, g, b
		local level = UnitLevel(unit)
		if (level < 1) then
			r, g, b = 0.69, 0.31, 0.31
		else
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
end

local colors = setmetatable({
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
}, {__index = oUF.colors})

oUF.TagEvents['[GetNameColor]'] = 'UNIT_HAPPINESS'
if (not oUF.Tags['[GetNameColor]']) then
	oUF.Tags['[GetNameColor]'] = function(unit)
		local reaction = UnitReaction(unit, 'player')
		if (unit == 'pet' and GetPetHappiness()) then
			local c = colors.happiness[GetPetHappiness()]
			return string.format('|cff%02x%02x%02x', c[1] * 255, c[2] * 255, c[3] * 255)
		elseif (UnitIsPlayer(unit)) then
			return oUF.Tags['[raidcolor]'](unit)
		elseif (reaction) then
			local c =  colors.reaction[reaction]
			return string.format('|cff%02x%02x%02x', c[1] * 255, c[2] * 255, c[3] * 255)
		else
			r, g, b = .84,.75,.65
			return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
		end
	end
end

local utf8sub = function(string, i, dots)
	local bytes = string:len()
	if (bytes <= i) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and '...' or '')
		else
			return string
		end
	end
end

oUF.TagEvents['[NameShort]'] = 'UNIT_NAME_UPDATE'
if (not oUF.Tags['[NameShort]']) then
	oUF.Tags['[NameShort]'] = function(unit)
		local name = UnitName(unit)
		return utf8sub(name, 10, false)
	end
end

oUF.TagEvents['[NameMedium]'] = 'UNIT_NAME_UPDATE'
if (not oUF.Tags['[NameMedium]']) then
	oUF.Tags['[NameMedium]'] = function(unit)
		local name = UnitName(unit)
		if (unit == 'pet' and name == 'Unknown') then
			return 'Pet'
		else
			return utf8sub(name, 18, true)
		end
	end
end

oUF.TagEvents['[NameLong]'] = 'UNIT_NAME_UPDATE'
if (not oUF.Tags['[NameLong]']) then
	oUF.Tags['[NameLong]'] = function(unit)

			local name = UnitName(unit)
			return utf8sub(name, 20, true)

	end
end

oUF.Tags['[smarthp]'] = function(u)
	local min, max = UnitHealth(u), UnitHealthMax(u)
	return UnitIsDeadOrGhost(u) and oUF.Tags['[dead]'](u) or (min~=max) and format('|cffff8080%d|r|cff0090ff %.0f|r%%', min-max, min/max*100) or max
end

oUF.Tags['[smartpp]'] = function(u)
	local min, max = UnitPower(u), UnitPowerMax(u)
	return (UnitPowerType(u) == 0 and min > 0) and format('|cff%02x%02x%02x%.0f|r%%', 0, 144, 255, min/max*100)
end

oUF.Tags['[offline]'] = function(u)
	if not UnitIsConnected(u) then
		return ("|cffB1071E"..tukuilocal.unitframes_ouf_offlinedps.."|r")
	end
end
	
oUF.Tags['[dead]'] = function(u) return UnitIsDeadOrGhost(u) and tukuilocal.unitframes_ouf_deaddps end
oUF.Tags['[afk]'] = function(u) return UnitIsAFK(u) and ' AFK' end

oUF.TagEvents['[smarthp]'] = 'UNIT_HEALTH'
oUF.TagEvents['[smartpp]'] = 'UNIT_MANA UNIT_DISPLAYPOWER'

oUF.TagEvents['[afk]'] = 'PLAYER_FLAGS_CHANGED'

