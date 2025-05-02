local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local strjoin = strjoin

local GetHaste = GetHaste
local GetMeleeHaste = GetMeleeHaste
local GetRangedHaste = GetRangedHaste
local UnitAttackSpeed = UnitAttackSpeed
local GetCombatRating = GetCombatRating
local UnitRangedDamage = UnitRangedDamage
local GetCombatRatingBonus = GetCombatRatingBonus
local GetPVPGearStatRules = GetPVPGearStatRules
local BreakUpLargeNumbers = BreakUpLargeNumbers

local STAT_HASTE = STAT_HASTE
local ATTACK_SPEED = ATTACK_SPEED
local CR_HASTE_MELEE = CR_HASTE_MELEE
local CR_HASTE_RANGED = CR_HASTE_RANGED
local STAT_HASTE_TOOLTIP = STAT_HASTE_TOOLTIP
local STAT_HASTE_BASE_TOOLTIP = STAT_HASTE_BASE_TOOLTIP
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	if E.Mists then
		if E.myclass == 'HUNTER' then
			DT.tooltip:AddLine(format('%s: %.2f', ATTACK_SPEED, UnitRangedDamage('player')), 1, 1, 1)
		else
			local speed, offhandSpeed = UnitAttackSpeed('player')
			DT.tooltip:AddLine(format(offhandSpeed and '%s: %.2f / %.2f' or '%s: %.2f', ATTACK_SPEED, speed, offhandSpeed), 1, 1, 1)
		end
	else
		local haste = GetHaste()
		DT.tooltip:AddLine(format('%s: %s%.2f%%|r', STAT_HASTE, (haste < 0 and (not E.Retail or not GetPVPGearStatRules())) and '|cffFF3333' or '|cffFFFFFF', haste), 1, 1, 1)
	end

	local rating = (E.Mists and E.myclass == 'HUNTER' and CR_HASTE_RANGED) or CR_HASTE_MELEE
	DT.tooltip:AddLine(format('%s'..STAT_HASTE_BASE_TOOLTIP, _G['STAT_HASTE_'..E.myclass..'_TOOLTIP'] or STAT_HASTE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating)), nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local haste = E.Mists and ((E.myclass == 'HUNTER' and GetRangedHaste()) or GetMeleeHaste()) or GetHaste()

	if db.NoLabel then
		self.text:SetFormattedText(displayString, haste)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or STAT_HASTE..': ', haste)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Haste', STAT_CATEGORY_ENHANCEMENTS, E.Mists and { 'UNIT_STATS', 'UNIT_ATTACK_SPEED' } or { 'UNIT_STATS', 'UNIT_SPELL_HASTE', 'UNIT_AURA' }, OnEvent, nil, nil, not E.Classic and OnEnter, nil, STAT_HASTE, nil, ApplySettings)
