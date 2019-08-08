local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local strjoin = strjoin
--WoW API / Variables
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing

local displayString, lastPanel = ''

local function OnEvent(self)
	local spellpwr = GetSpellBonusDamage(7)
	local healpwr = GetSpellBonusHealing()

	if healpwr > spellpwr then
		self.text:SetFormattedText(displayString, L["HP"], healpwr)
	else
		self.text:SetFormattedText(displayString, L["SP"], spellpwr)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Spell/Heal Power', {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, nil, nil,L["Spell/Heal Power"])
