local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local format = format
local next = next

local GetCombatRatingBonus = GetCombatRatingBonus
local GetMasteryEffect = GetMasteryEffect
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetSpecializationMasterySpells = C_SpecializationInfo.GetSpecializationMasterySpells or GetSpecializationMasterySpells
local CreateBaseTooltipInfo = CreateBaseTooltipInfo

local STAT_MASTERY = STAT_MASTERY
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_MASTERY = CR_MASTERY

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local masteryRating, bonusCoeff = GetMasteryEffect()
	local masteryBonus = (GetCombatRatingBonus(CR_MASTERY) or 0) * (bonusCoeff or 0)

	local title = format('|cffFFFFFF%s: %.2f%%|r', STAT_MASTERY, masteryRating)
	if masteryBonus > 0 then
		title = format('%s |cffFFFFFF(%.2f%%|r |cff33ff33+%.2f%%|r|cffFFFFFF)|r', title, masteryRating - masteryBonus, masteryBonus)
	end

	DT.tooltip:AddLine(title)
	DT.tooltip:AddLine(' ')

	if E.Mists then
		local primaryTalentTree = GetSpecialization()
		if primaryTalentTree then
			local masterySpells = GetSpecializationMasterySpells(primaryTalentTree)
			local hasAddedAnyMasterySpell = false
			for _, masterySpell in next, masterySpells do
				if hasAddedAnyMasterySpell then
					DT.tooltip:AddLine(' ')
				end

				DT.tooltip:AddSpellByID(masterySpell)
				hasAddedAnyMasterySpell = true
			end
		end
	else
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

	DT.tooltip:Show()
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

DT:RegisterDatatext('Mastery', STAT_CATEGORY_ENHANCEMENTS, {E.Mists and 'COMBAT_RATING_UPDATE' or 'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, STAT_MASTERY, nil, ApplySettings)
