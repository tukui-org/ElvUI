local E, L, V, P, G = unpack(ElvUI)

local _G = _G
local gsub, format = gsub, format
local strlower = strlower

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHonorLevel = UnitHonorLevel
local UnitIsPlayer = UnitIsPlayer
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealthMissing = UnitHealthMissing
local UnitPowerMissing = UnitPowerMissing

local POWERTYPE_MANA = Enum.PowerType.Mana

-- GLOBALS: Hex, _TAGS, _COLORS -- added by oUF
-- GLOBALS: UnitPower -- override during testing groups

E:AddTag('absorbs', 'UNIT_ABSORB_AMOUNT_CHANGED', function(unit)
	return UnitGetTotalAbsorbs(unit)
end)

E:AddTag('healabsorbs', 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED', function(unit)
	return UnitGetTotalHealAbsorbs(unit)
end)

for tagFormat, which in next, { shortvalue = 'short', longvalue = 'long' } do
	E:AddTag(format('absorbs:%s', tagFormat), 'UNIT_ABSORB_AMOUNT_CHANGED', function(unit)
		local absorb = UnitGetTotalAbsorbs(unit)
		return E:AbbreviateNumbers(absorb, E.Abbreviate[which])
	end)

	E:AddTag(format('healabsorbs:%s', tagFormat), 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED', function(unit)
		local healAbsorb = UnitGetTotalHealAbsorbs(unit)
		return E:AbbreviateNumbers(healAbsorb, E.Abbreviate[which])
	end)

	E:AddTag(format('missinghp:%s', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
		local healthMissing = UnitHealthMissing(unit)
		return E:AbbreviateNumbers(healthMissing, E.Abbreviate[which])
	end)

	E:AddTag(format('missingpp:%s', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
		local powerMissing = UnitPowerMissing(unit)
		return E:AbbreviateNumbers(powerMissing, E.Abbreviate[which])
	end)

	E:AddTag(format('health:current:%s', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
		local currentHealth = UnitHealth(unit)
		return E:AbbreviateNumbers(currentHealth, E.Abbreviate[which])
	end)

	E:AddTag(format('power:current:%s', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
		local powerType = UnitPowerType(unit)
		local currentPower = UnitPower(unit, powerType)
		return E:AbbreviateNumbers(currentPower, E.Abbreviate[which])
	end)

	E:AddTag(format('health:max:%s', tagFormat), 'UNIT_HEALTH UNIT_MAXHEALTH', function(unit)
		local maxHealth = UnitHealthMax(unit)
		return E:AbbreviateNumbers(maxHealth, E.Abbreviate[which])
	end)

	E:AddTag(format('power:max:%s', tagFormat), 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER', function(unit)
		local powerType = UnitPowerType(unit)
		local maxPower = UnitPowerMax(unit, powerType)
		return E:AbbreviateNumbers(maxPower, E.Abbreviate[which])
	end)
end

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

E:RegisterInternalTagInfo(function(info)
	local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')

	info['absorbs:longvalue'] = { category = L["Health"], description = L["Displays the amount of absorbs"] }
	info['absorbs:shortvalue'] = { category = L["Health"], description = L["Displays the amount of absorbs"] }
	info['healabsorbs:longvalue'] = { category = L["Health"], description = L["Displays the amount of heal absorbs"] }
	info['healabsorbs:shortvalue'] = { category = L["Health"], description = L["Displays the amount of heal absorbs"] }
	info['missinghp:longvalue'] = { category = L["Health"], description = L["Displays the missing health of the unit in whole numbers, when not at full health"] }
	info['missinghp:shortvalue'] = { category = L["Health"], description = L["Displays the missing health of the unit in whole numbers, when not at full health"] }
	info['missingpp:longvalue'] = { category = L["Power"], description = L["Displays the missing power of the unit in whole numbers when not at full power"] }
	info['missingpp:shortvalue'] = { category = L["Power"], description = L["Displays the missing power of the unit in whole numbers when not at full power"] }
	info['altpowercolor'] = { category = L["Colors"], description = L["Changes the text color to the current alternative power color (Blizzard defined)"] }
	info['spec:icon'] = { category = L["Class"], description = L["Displays the specialization icon of the unit, if that unit is a player"] }
	info['additionalmana:current-max-percent'] = { category = L["Mana"], description = L["Displays the current and max additional mana of the unit, separated by a dash (% when not full)"] }
	info['additionalmana:current-max'] = { category = L["Mana"], description = L["Displays the unit's current and maximum additional mana, separated by a dash"] }
	info['additionalmana:current-percent'] = { category = L["Mana"], description = L["Displays the current additional mana of the unit and % when not full"] }
	info['additionalmana:current'] = { category = L["Mana"], description = L["Displays the unit's current additional mana"] }
	info['additionalmana:deficit'] = { category = L["Mana"], description = L["Displays the player's additional mana as a deficit"] }
	info['additionalmana:percent'] = { category = L["Mana"], description = L["Displays the player's additional mana as a percentage"] }
	info['additionalmana:current-max-percent:shortvalue'] = { category = L["Mana"], description = "" }
	info['additionalmana:current-max:shortvalue'] = { category = L["Mana"], description = "" }
	info['additionalmana:current-percent:shortvalue'] = { category = L["Mana"], description = "" }
	info['additionalmana:current:shortvalue'] = { category = L["Mana"], description = "" }
	info['additionalmana:deficit:shortvalue'] = { category = L["Mana"], description = "" }
	info['altpower:current-max-percent'] = { category = L["Altpower"], description = L["Displays altpower text on a unit in current-max-percent format"] }
	info['altpower:current-max'] = { category = L["Altpower"], description = L["Displays altpower text on a unit in current-max format"] }
	info['altpower:current-percent'] = { category = L["Altpower"], description = L["Displays altpower text on a unit in current-percent format"] }
	info['altpower:current'] = { category = L["Altpower"], description = L["Displays altpower text on a unit in current format"] }
	info['altpower:deficit'] = { category = L["Altpower"], description = L["Displays altpower text on a unit in deficit format"] }
	info['altpower:percent'] = { category = L["Altpower"], description = L["Displays altpower text on a unit in percent format"] }
	info['pvp:honorlevel'] = { category = L["PvP"], description = L["Displays honor level of the unit"] }
end)