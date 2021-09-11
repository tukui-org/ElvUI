local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetSpellCritChance = GetSpellCritChance
local CRIT_ABBR = CRIT_ABBR
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, CRIT_ABBR, GetSpellCritChance())

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Spell Crit Chance', STAT_CATEGORY_ENHANCEMENTS, {"UNIT_STATS", "UNIT_AURA", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, nil, nil, 'Spell Crit Chance')
