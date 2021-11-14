 local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local min = min
local strjoin = strjoin
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''

local function OnEvent(self)
	local minSpellPower = GetSpellBonusDamage(2)
	local HealingPower = GetSpellBonusHealing()

	for i = 3, 7 do
		local spellPower = GetSpellBonusDamage(i);
		minSpellPower = min(minSpellPower, spellPower);
	end

	if HealingPower > minSpellPower then
		self.text:SetFormattedText(displayString, L["HP"], HealingPower)
	else
		self.text:SetFormattedText(displayString, L["SP"], minSpellPower)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%d|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Spell/Heal Power', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, L["Spell/Heal Power"])
