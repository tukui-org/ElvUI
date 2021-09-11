local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetSpellCritChance = GetSpellCritChance
local CRIT_ABBR = CRIT_ABBR
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''

-- Modified version of PaperDoll.lua
function GetRealSpellCrit()

	local holySchool = 2
	local minCrit = GetSpellCritChance(holySchool)
	local spellCrit

	realSpellCrit = {}
	realSpellCrit[holySchool] = minCrit

	for i=(holySchool+1), 7 do

		spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
		realSpellCrit[i] = spellCrit
	end

	minCrit = format("%.2f", minCrit)
	return minCrit
end

local function OnEvent(self)
	self.text:SetFormattedText(displayString, CRIT_ABBR, GetRealSpellCrit())

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
