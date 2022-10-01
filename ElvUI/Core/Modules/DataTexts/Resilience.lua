local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local min = min
local join = strjoin
--WoW API / Variables
local GetCombatRating = GetCombatRating
local CR_CRIT_TAKEN_MELEE = CR_CRIT_TAKEN_MELEE
local CR_CRIT_TAKEN_RANGED = CR_CRIT_TAKEN_RANGED
local CR_CRIT_TAKEN_SPELL = CR_CRIT_TAKEN_SPELL
local STAT_RESILIENCE = STAT_RESILIENCE

local displayNumberString = ''
local lastPanel

local function OnEvent(self)
	lastPanel = self

	local melee = GetCombatRating(CR_CRIT_TAKEN_MELEE)
	local ranged = GetCombatRating(CR_CRIT_TAKEN_RANGED)
	local spell = GetCombatRating(CR_CRIT_TAKEN_SPELL)

	local minResilience = min(melee, ranged)
	minResilience = min(minResilience, spell)

	self.text:SetFormattedText(displayNumberString, minResilience)
end

local function ValueColorUpdate(hex)
	displayNumberString = join('', STAT_RESILIENCE, ': ', hex, '%d|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Resilience', {'COMBAT_RATING_UPDATE'}, OnEvent, nil, nil, nil, nil, STAT_RESILIENCE)
