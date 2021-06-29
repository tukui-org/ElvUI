local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local MANA_REGEN = MANA_REGEN

local displayString, lastPanel = ''

local function OnEvent(self)
	local baseMR, castingMR = GetManaRegen()
	if InCombatLockdown() then
		self.text:SetFormattedText(displayString, MANA_REGEN, castingMR*5)
	else
		self.text:SetFormattedText(displayString, MANA_REGEN, baseMR*5)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%.2f|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Mana Regen', STAT_CATEGORY_ATTRIBUTES, {'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE'}, OnEvent, nil, nil, nil, nil, MANA_REGEN, nil, ValueColorUpdate)
