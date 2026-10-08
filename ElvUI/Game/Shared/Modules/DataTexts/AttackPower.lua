local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin

local AbbreviateNumbers = AbbreviateNumbers
local UnitRangedAttackPower = UnitRangedAttackPower
local UnitAttackPower = UnitAttackPower
local ComputePetBonus = ComputePetBonus

local ATTACK_POWER = ATTACK_POWER
local MELEE_ATTACK_POWER = MELEE_ATTACK_POWER
local MELEE_ATTACK_POWER_TOOLTIP = MELEE_ATTACK_POWER_TOOLTIP
local RANGED_ATTACK_POWER = RANGED_ATTACK_POWER
local RANGED_ATTACK_POWER_TOOLTIP = RANGED_ATTACK_POWER_TOOLTIP
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local PET_BONUS_TOOLTIP_SPELLDAMAGE = PET_BONUS_TOOLTIP_SPELLDAMAGE
local PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER = PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER
local ATTACK_POWER_MAGIC_NUMBER = ATTACK_POWER_MAGIC_NUMBER

local data = {
	breakpoint = 0,
	abbreviation = '',
	fractionDivisor = 1,
	significandDivisor = ATTACK_POWER_MAGIC_NUMBER,
	abbreviationIsGlobal = false,
}

local breakpoint = { breakpointData = { data } }
local displayString, totalAP, baseAP, posAP, negAP, db = ''
local isHunter = E.myclass == 'HUNTER'

local function OnEvent(panel)
	baseAP, posAP, negAP = (isHunter and UnitRangedAttackPower or UnitAttackPower)('player')
	totalAP = E:NotSecretValue(baseAP) and (baseAP + posAP + negAP) or nil

	if totalAP then
		if db.NoLabel then
			panel.text:SetFormattedText(displayString, totalAP)
		else
			panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ATTACK_POWER..': ', totalAP)
		end
	elseif db.NoLabel then
		panel.text:SetFormattedText(displayString, '|cFF888888'..baseAP..'|r')
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ATTACK_POWER..': ', '|cFF888888'..baseAP..'|r')
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local power = totalAP or baseAP -- total is secret half the time
	local bonus = E.Modern and AbbreviateNumbers(power, breakpoint) or (power / ATTACK_POWER_MAGIC_NUMBER)
	DT.tooltip:AddDoubleLine(isHunter and RANGED_ATTACK_POWER or MELEE_ATTACK_POWER , power, 1, 1, 1)
	DT.tooltip:AddLine(format(isHunter and RANGED_ATTACK_POWER_TOOLTIP or MELEE_ATTACK_POWER_TOOLTIP, bonus), nil, nil, nil, true)

	if isHunter and ComputePetBonus and E:NotSecretValue(power) then
		local petAP = ComputePetBonus('PET_BONUS_RAP_TO_AP', power)
		if petAP > 0 then
			DT.tooltip:AddLine(format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, petAP))
		end

		local petSpell = ComputePetBonus('PET_BONUS_RAP_TO_SPELLDMG', power)
		if petSpell > 0 then
			DT.tooltip:AddLine(format(PET_BONUS_TOOLTIP_SPELLDAMAGE, petSpell))
		end
	end

	DT.tooltip:Show()
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%s|r')
end

DT:RegisterDatatext('Attack Power', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'UNIT_ATTACK_POWER', 'UNIT_RANGED_ATTACK_POWER' }, OnEvent, nil, nil, OnEnter, nil, _G.ATTACK_POWER_TOOLTIP, nil, ApplySettings)
