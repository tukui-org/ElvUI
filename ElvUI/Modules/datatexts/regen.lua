local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local MANA_REGEN = MANA_REGEN

local displayNumberString = ''
local lastPanel;

local function OnEvent(self)
	local baseMR, castingMR = GetManaRegen()
	if InCombatLockdown() then
		self.text:SetFormattedText(displayNumberString, MANA_REGEN, castingMR*5)
	else
		self.text:SetFormattedText(displayNumberString, MANA_REGEN, baseMR*5)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%.2f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Mana Regen', {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, nil, nil, MANA_REGEN)
