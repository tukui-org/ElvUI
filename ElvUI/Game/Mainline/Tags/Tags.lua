local E, L, V, P, G = unpack(ElvUI)

local _G = _G
local gsub, format = gsub, format
local strlower = strlower

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHonorLevel = UnitHonorLevel
local UnitIsPlayer = UnitIsPlayer
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local AbbreviateNumbers = AbbreviateNumbers

local POWERTYPE_MANA = Enum.PowerType.Mana

-- GLOBALS: Hex, _TAGS, _COLORS -- added by oUF
-- GLOBALS: UnitPower -- override during testing groups

E:AddTag('health:current:shortvalue', 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
	local currentHealth = UnitHealth(unit)

	return AbbreviateNumbers(currentHealth, E.Abbreviate.short)
end)

E:AddTag('power:current:shortvalue', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
	local powerType = UnitPowerType(unit)
	local currentPower = UnitPower(unit, powerType)

	return AbbreviateNumbers(currentPower, E.Abbreviate.short)
end)

E:AddTag('health:max:shortvalue', 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
	local maxHealth = UnitHealthMax(unit)

	return AbbreviateNumbers(maxHealth, E.Abbreviate.short)
end)

E:AddTag('power:max:shortvalue', 'UNIT_DISPLAYPOWER UNIT_MAXPOWER', function(unit)
	local powerType = UnitPowerType(unit)
	local maxPower = UnitPowerMax(unit, powerType)

	return AbbreviateNumbers(maxPower, E.Abbreviate.short)
end)

E:AddTag('pvp:honorlevel', 'UNIT_NAME_UPDATE', function(unit)
	if not UnitIsPlayer(unit) then return end

	return UnitHonorLevel(unit)
end)

for textFormat in pairs(E.GetFormattedTextStyles) do
	local tagFormat = strlower(gsub(textFormat, '_', '-'))

	E:AddTag(format('additionalmana:%s', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
		local altIndex = _G.ALT_POWER_BAR_PAIR_DISPLAY_INFO[E.myclass]
		local min = altIndex and altIndex[UnitPowerType(unit)] and UnitPower(unit, POWERTYPE_MANA)
		if min and min ~= 0 then
			return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA))
		end
	end)

	if tagFormat ~= 'percent' then
		E:AddTag(format('additionalmana:%s:shortvalue', tagFormat), 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER', function(unit)
			local altIndex = _G.ALT_POWER_BAR_PAIR_DISPLAY_INFO[E.myclass]
			local min = altIndex and altIndex[UnitPowerType(unit)] and UnitPower(unit, POWERTYPE_MANA)
			if min and min ~= 0 and tagFormat ~= 'deficit' then
				return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, POWERTYPE_MANA), nil, true)
			end
		end)
	end
end

do
	local specIcon = [[|T%s:16:16:0:0:64:64:4:60:4:60|t]]
	E:AddTag('spec:icon', 'PLAYER_TALENT_UPDATE UNIT_NAME_UPDATE', function(unit)
		if not UnitIsPlayer(unit) then return end

		-- try to get spec from tooltip
		local info = E.Retail and E:GetUnitSpecInfo(unit)
		if info then
			return info.icon and format(specIcon, info.icon)
		end
	end)
end

local info = E.TagInfo
info['altpowercolor'] = { category = 'Colors', description = "Changes the text color to the current alternative power color (Blizzard defined)" }
info['spec:icon'] = { category = 'Class', description = "Displays the specialization icon of the unit, if that unit is a player" }
info['additionalmana:current-max-percent'] = { category = 'Mana', description = "Displays the current and max additional mana of the unit, separated by a dash (% when not full)" }
info['additionalmana:current-max'] = { category = 'Mana', description = "Displays the unit's current and maximum additional mana, separated by a dash" }
info['additionalmana:current-percent'] = { category = 'Mana', description = "Displays the current additional mana of the unit and % when not full" }
info['additionalmana:current'] = { category = 'Mana', description = "Displays the unit's current additional mana" }
info['additionalmana:deficit'] = { category = 'Mana', description = "Displays the player's additional mana as a deficit" }
info['additionalmana:percent'] = { category = 'Mana', description = "Displays the player's additional mana as a percentage" }
info['additionalmana:current-max-percent:shortvalue'] = { category = 'Mana', description = "" }
info['additionalmana:current-max:shortvalue'] = { category = 'Mana', description = "" }
info['additionalmana:current-percent:shortvalue'] = { category = 'Mana', description = "" }
info['additionalmana:current:shortvalue'] = { category = 'Mana', description = "" }
info['additionalmana:deficit:shortvalue'] = { category = 'Mana', description = "" }
info['altpower:current-max-percent'] = { category = 'Altpower', description = "Displays altpower text on a unit in current-max-percent format" }
info['altpower:current-max'] = { category = 'Altpower', description = "Displays altpower text on a unit in current-max format" }
info['altpower:current-percent'] = { category = 'Altpower', description = "Displays altpower text on a unit in current-percent format" }
info['altpower:current'] = { category = 'Altpower', description = "Displays altpower text on a unit in current format" }
info['altpower:deficit'] = { category = 'Altpower', description = "Displays altpower text on a unit in deficit format" }
info['altpower:percent'] = { category = 'Altpower', description = "Displays altpower text on a unit in percent format" }
info['pvp:honorlevel'] = { category = 'PvP', description = "Displays honor level of the unit" }
