 local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local min = min
local strjoin = strjoin
local GetSpellBonusDamage = GetSpellBonusDamage
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local MAX_SPELL_SCHOOLS = MAX_SPELL_SCHOOLS or 7
local displayString, lastPanel = ''

local function OnEvent(self)
	local minSpellPower

	if E.global.datatexts.settings.SpellPower.school == 0 then
		minSpellPower = GetSpellBonusDamage(2)

		for i = 3, MAX_SPELL_SCHOOLS do
			minSpellPower = min(minSpellPower, GetSpellBonusDamage(i))
		end
	else
		minSpellPower = GetSpellBonusDamage(E.global.datatexts.settings.SpellPower.school)
	end

	self.text:SetFormattedText(displayString, L["SP"], minSpellPower)

	lastPanel = self
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for i = 2, MAX_SPELL_SCHOOLS do
		DT.tooltip:AddDoubleLine(_G['DAMAGE_SCHOOL'..i], GetSpellBonusDamage(i))
		DT.tooltip:AddTexture([[Interface\PaperDollInfoFrame\SpellSchoolIcon]]..i)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%d|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('SpellPower', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, OnEnter, nil, L["Spell Power"])
