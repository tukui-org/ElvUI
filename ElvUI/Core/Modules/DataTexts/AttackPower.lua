local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin

local UnitAttackPower = UnitAttackPower
local UnitRangedAttackPower = UnitRangedAttackPower
local ComputePetBonus = ComputePetBonus
local ATTACK_POWER = ATTACK_POWER
local ATTACK_POWER_MAGIC_NUMBER = ATTACK_POWER_MAGIC_NUMBER
local MELEE_ATTACK_POWER = MELEE_ATTACK_POWER
local MELEE_ATTACK_POWER_TOOLTIP = MELEE_ATTACK_POWER_TOOLTIP
local RANGED_ATTACK_POWER = RANGED_ATTACK_POWER
local RANGED_ATTACK_POWER_TOOLTIP = RANGED_ATTACK_POWER_TOOLTIP
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local PET_BONUS_TOOLTIP_SPELLDAMAGE = PET_BONUS_TOOLTIP_SPELLDAMAGE
local PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER = PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER

local displayNumberString, totalAP = ''

local function OnEvent(self)
	local base, posBuff, negBuff = (E.myclass == 'HUNTER' and UnitRangedAttackPower or UnitAttackPower)('player')
	totalAP = base + posBuff + negBuff

	self.text:SetFormattedText(displayNumberString, ATTACK_POWER, totalAP)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddDoubleLine(E.myclass == 'HUNTER' and RANGED_ATTACK_POWER or MELEE_ATTACK_POWER , totalAP, 1, 1, 1)
	DT.tooltip:AddLine(format(E.myclass == 'HUNTER' and RANGED_ATTACK_POWER_TOOLTIP or MELEE_ATTACK_POWER_TOOLTIP, totalAP / ATTACK_POWER_MAGIC_NUMBER), nil, nil, nil, true)

	if E.myclass == 'HUNTER' then
		local petAPBonus = ComputePetBonus('PET_BONUS_RAP_TO_AP', totalAP)
		local petSpellDmgBonus = ComputePetBonus('PET_BONUS_RAP_TO_SPELLDMG', totalAP)

		if petAPBonus > 0 then
			DT.tooltip:AddLine(format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, petAPBonus))
		end

		if petSpellDmgBonus > 0 then
			DT.tooltip:AddLine(format(PET_BONUS_TOOLTIP_SPELLDAMAGE, petSpellDmgBonus))
		end
	end

	DT.tooltip:Show()
end

local function ApplySettings(_, hex)
	displayNumberString = strjoin('', '%s: ', hex, '%d|r')
end

DT:RegisterDatatext('Attack Power', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'UNIT_ATTACK_POWER', 'UNIT_RANGED_ATTACK_POWER' }, OnEvent, nil, nil, OnEnter, nil, _G.ATTACK_POWER_TOOLTIP, nil, ApplySettings)
