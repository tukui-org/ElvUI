 local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local min = min
local strjoin = strjoin

local GetSpellBonusDamage = GetSpellBonusDamage
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local MAX_SPELL_SCHOOLS = MAX_SPELL_SCHOOLS or 7
local displayString, db = ''

local function OnEvent(self)
	local minSpellPower

	if db.school == 0 then
		minSpellPower = GetSpellBonusDamage(2) or 0

		for i = 3, MAX_SPELL_SCHOOLS do
			minSpellPower = min(minSpellPower, GetSpellBonusDamage(i) or 0)
		end
	else
		minSpellPower = GetSpellBonusDamage(db.school)
	end

	minSpellPower = minSpellPower or 0
	if db.NoLabel then
		self.text:SetFormattedText(displayString, minSpellPower)
	else
		local separator = (db.LabelSeparator ~= '' and db.LabelSeparator) or DT.db.labelSeparator or ': '
		self.text:SetFormattedText(displayString, (db.Label ~= '' and db.Label or L["Spell Power"])..separator, minSpellPower)
	end
end

local icon = [[Interface\PaperDollInfoFrame\SpellSchoolIcon]]
local function OnEnter()
	DT.tooltip:ClearLines()

	for i = 2, MAX_SPELL_SCHOOLS do
		local value = GetSpellBonusDamage(i) or 0
		DT.tooltip:AddDoubleLine(_G['DAMAGE_SCHOOL'..i], value)
		DT.tooltip:AddTexture(icon..i)
	end

	DT.tooltip:Show()
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('SpellPower', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, OnEnter, nil, L["Spell Power"], nil, ApplySettings)
