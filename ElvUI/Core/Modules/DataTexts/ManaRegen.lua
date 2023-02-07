local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown

local MANA_REGEN = MANA_REGEN
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString = ''

local function OnEvent(self)
	local baseMR, castingMR = GetManaRegen()

	self.text:SetFormattedText(displayString, MANA_REGEN, (InCombatLockdown() and castingMR or baseMR) * 5)
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%.2f|r')
end

DT:RegisterDatatext('Mana Regen', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, MANA_REGEN, nil, ApplySettings)
