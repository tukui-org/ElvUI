local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local AbbreviateNumbers = AbbreviateNumbers

local MANA_REGEN = MANA_REGEN
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local data = {
	breakpoint = 0,
	abbreviation = '',
	fractionDivisor = 1,
	significandDivisor = 0.2, -- 1 / 5, so scaled = value * 5
	abbreviationIsGlobal = false,
}

local breakpoint = { breakpointData = { data } }
local displayString, db = ''

local function OnEvent(panel)
	local baseMR, castingMR = GetManaRegen()
	local regen = InCombatLockdown() and castingMR or baseMR

	local manaRegen = E.Modern and AbbreviateNumbers(regen, breakpoint) or (regen * 5)
	if db.NoLabel then
		panel.text:SetFormattedText(displayString, manaRegen)
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or MANA_REGEN..': ', manaRegen)
	end
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	if E.Modern then
		data.fractionDivisor = 10 ^ (db.decimalLength or 0)
		data.significandDivisor = 0.2 / data.fractionDivisor

		displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%s|r')
	else
		displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f|r')
	end
end

DT:RegisterDatatext('Mana Regen', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, MANA_REGEN, nil, ApplySettings)
