local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetSpellBonusHealing = GetSpellBonusHealing
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, db = ''

local function OnEvent(self)
	if db.NoLabel then
		self.text:SetFormattedText(displayString, GetSpellBonusHealing())
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or L["HP"]..': ', GetSpellBonusHealing())
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('HealPower', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, L["Heal Power"], nil, ApplySettings)
