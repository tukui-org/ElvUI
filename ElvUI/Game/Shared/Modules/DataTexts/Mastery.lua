local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local format = format
local next = next

local GetCombatRating = GetCombatRating
local GetMasteryEffect = GetMasteryEffect
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetSpecializationMasterySpells = C_SpecializationInfo.GetSpecializationMasterySpells or GetSpecializationMasterySpells
local CreateBaseTooltipInfo = CreateBaseTooltipInfo
local AbbreviateNumbers = AbbreviateNumbers

local STAT_MASTERY = STAT_MASTERY
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_MASTERY = CR_MASTERY

local data = {
	breakpoint = 0,
	abbreviation = '',
	fractionDivisor = 1,
	significandDivisor = 1, -- 1 / coeffect, so scaled = value * coeffect
	abbreviationIsGlobal = false,
}

local breakpoint = { breakpointData = { data } }
local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local _, coeffect = GetMasteryEffect()
	local bonus = GetCombatRatingBonus(CR_MASTERY)
	local text

	if E.Retail then
		if E:NotSecretValue(coeffect) then
			data.significandDivisor = (coeffect == 0 and 1) or ((1 / coeffect) / data.fractionDivisor)
		end

		text = AbbreviateNumbers((bonus or 0), breakpoint)
	else
		text = (bonus or 0) * coeffect
	end

	local rating = GetCombatRating(CR_MASTERY)
	local title = format('|cffFFFFFF%s: %d|r', STAT_MASTERY, rating)
	if bonus then
		title = format('%s |cffFFFFFF[|r|cff33ff33+%s%%|r|cffFFFFFF]|r', title, text)
	end

	DT.tooltip:AddLine(title)
	DT.tooltip:AddLine(' ')

	local spec = GetSpecialization()
	if spec then
		local spells = GetSpecializationMasterySpells(spec)
		local hasSpell = false
		for _, spell in next, spells do
			if hasSpell then
				DT.tooltip:AddLine(' ')
			else
				hasSpell = true
			end

			if E.Retail then
				local tooltipInfo = CreateBaseTooltipInfo('GetSpellByID', spell)
				tooltipInfo.append = true
				DT.tooltip:ProcessInfo(tooltipInfo)
			else
				DT.tooltip:AddSpellByID(spell)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(panel)
	local rating = GetMasteryEffect()
	if db.NoLabel then
		panel.text:SetFormattedText(displayString, rating)
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or STAT_MASTERY..': ', rating)
	end
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	if E.Retail then
		data.fractionDivisor = 10 ^ (db.decimalLength or 0)
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Mastery', STAT_CATEGORY_ENHANCEMENTS, {E.Mists and 'COMBAT_RATING_UPDATE' or 'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, STAT_MASTERY, nil, ApplySettings)
