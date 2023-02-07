local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local format = format

local GetMasteryEffect = GetMasteryEffect
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpecialization = GetSpecialization
local GetSpecializationMasterySpells = GetSpecializationMasterySpells
local BreakUpLargeNumbers = BreakUpLargeNumbers

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local STAT_MASTERY = STAT_MASTERY
local CreateBaseTooltipInfo = CreateBaseTooltipInfo
local CR_MASTERY = CR_MASTERY

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local primaryTalentTree = GetSpecialization()
	if primaryTalentTree then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree)
		if masterySpell then
			if CreateBaseTooltipInfo then
				local tooltipInfo = CreateBaseTooltipInfo('GetSpellByID', masterySpell)
				tooltipInfo.append = true
				DT.tooltip:ProcessInfo(tooltipInfo)
			else
				DT.tooltip:AddSpellByID(masterySpell)
			end
		end

		if masterySpell2 then
			DT.tooltip:AddLine(' ')

			if CreateBaseTooltipInfo then
				local tooltipInfo = CreateBaseTooltipInfo('GetSpellByID', masterySpell2)
				tooltipInfo.append = true
				DT.tooltip:ProcessInfo(tooltipInfo)
			else
				DT.tooltip:AddSpellByID(masterySpell2)
			end
		end

		local _, bonusCoeff = GetMasteryEffect()
		local masteryBonus = (GetCombatRatingBonus(CR_MASTERY) or 0) * (bonusCoeff or 0)

		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(format('%s: %s [+%.2f%%]', STAT_MASTERY, BreakUpLargeNumbers(GetCombatRating(CR_MASTERY) or 0), masteryBonus))

		DT.tooltip:Show()
	end
end

local function OnEvent(self)
	local masteryRating = GetMasteryEffect()
	if db.NoLabel then
		self.text:SetFormattedText(displayString, masteryRating)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or STAT_MASTERY..': ', masteryRating)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Mastery', STAT_CATEGORY_ENHANCEMENTS, {'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, STAT_MASTERY, nil, ApplySettings)
