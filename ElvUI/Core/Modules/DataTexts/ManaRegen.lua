local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
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

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Mana Regen', _G.STAT_CATEGORY_ATTRIBUTES, {'UNIT_STATS', 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, MANA_REGEN, nil, ValueColorUpdate)
