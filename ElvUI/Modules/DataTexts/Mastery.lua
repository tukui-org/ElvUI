local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetMasteryEffect = GetMasteryEffect
local GetSpecialization = GetSpecialization
local GetSpecializationMasterySpells = GetSpecializationMasterySpells
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local STAT_MASTERY = STAT_MASTERY

local displayString, lastPanel = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local primaryTalentTree = GetSpecialization()
	if primaryTalentTree then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree)
		if masterySpell then
			DT.tooltip:AddSpellByID(masterySpell)
		end
		if masterySpell2 then
			DT.tooltip:AddLine(' ')
			DT.tooltip:AddSpellByID(masterySpell2)
		end

		DT.tooltip:Show()
	end
end

local function OnEvent(self)
	lastPanel = self

	local masteryRating = GetMasteryEffect()
	if E.global.datatexts.settings.Mastery.NoLabel then
		self.text:SetFormattedText(displayString, masteryRating)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Mastery.Label ~= '' and E.global.datatexts.settings.Mastery.Label or STAT_MASTERY..': ', masteryRating)
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Mastery.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Mastery.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Mastery', STAT_CATEGORY_ENHANCEMENTS, {'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, STAT_MASTERY, nil, ValueColorUpdate)
