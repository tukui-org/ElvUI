local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown

local MANA_REGEN = MANA_REGEN
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, db = ''

local function OnEvent(panel)
	local baseMR, castingMR = GetManaRegen()
	local manaRegen = (InCombatLockdown() and castingMR or baseMR) * 5

	if db.NoLabel then
		panel.text:SetFormattedText(displayString, manaRegen)
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or MANA_REGEN..': ', manaRegen)
	end
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f|r')
end

DT:RegisterDatatext('Mana Regen', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, MANA_REGEN, nil, ApplySettings)
