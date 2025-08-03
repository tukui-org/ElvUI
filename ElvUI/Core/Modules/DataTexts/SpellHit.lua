local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetSpellHitModifier = GetSpellHitModifier
local GetCombatRatingBonus = GetCombatRatingBonus
local IsSpellKnown = C_SpellBook.IsSpellKnown or IsPlayerSpell

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_HIT_SPELL = CR_HIT_SPELL

local displayString, db = ''

local function OnEvent(self)
	local spellHit = E.Classic and GetSpellHitModifier() or GetCombatRatingBonus(CR_HIT_SPELL) or 0

	if IsSpellKnown(28878) then
		spellHit = spellHit + 1 -- Heroic Presence
	end

	if db.NoLabel then
		self.text:SetFormattedText(displayString, spellHit)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or L["Spell Hit"]..': ', spellHit)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Spell Hit', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, L["Spell Hit"], nil, ApplySettings)
