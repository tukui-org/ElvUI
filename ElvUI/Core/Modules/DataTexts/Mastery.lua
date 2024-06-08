local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin
local format = format

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetMasteryEffect = GetMasteryEffect
local GetSpecialization = GetSpecialization
local GetSpecializationMasterySpells = GetSpecializationMasterySpells
local GetTalentTreeMasterySpells = GetTalentTreeMasterySpells
local CreateBaseTooltipInfo = CreateBaseTooltipInfo
local GetPrimaryTalentTree = GetPrimaryTalentTree
local IsSpellKnown = IsSpellKnown
local GetMastery = GetMastery

local STAT_MASTERY = STAT_MASTERY
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_MASTERY = CR_MASTERY

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local masteryBonus
	if E.Cata then
		masteryBonus = GetCombatRatingBonus(CR_MASTERY) or 0

		local primaryTalentTree = IsSpellKnown(_G.CLASS_MASTERY_SPELLS[E.myclass]) and GetPrimaryTalentTree()
		if primaryTalentTree then
			local masterySpell = GetTalentTreeMasterySpells(primaryTalentTree)
			if masterySpell then
				DT.tooltip:AddSpellByID(masterySpell)
			end
		end
	else
		local _, bonusCoeff = GetMasteryEffect()
		masteryBonus = (GetCombatRatingBonus(CR_MASTERY) or 0) * (bonusCoeff or 0)

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
		end
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s [+%.2f%%]', STAT_MASTERY, BreakUpLargeNumbers(GetCombatRating(CR_MASTERY) or 0), masteryBonus))

	DT.tooltip:Show()
end

local function OnEvent(self)
	local masteryRating = (E.Cata and GetMastery()) or GetMasteryEffect()
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

DT:RegisterDatatext('Mastery', STAT_CATEGORY_ENHANCEMENTS, {E.Cata and 'COMBAT_RATING_UPDATE' or 'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, STAT_MASTERY, nil, ApplySettings)
