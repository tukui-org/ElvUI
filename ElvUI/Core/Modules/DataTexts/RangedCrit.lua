local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local strjoin = strjoin
local GetRangedCritChance = GetRangedCritChance
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local RANGED_CRIT_CHANCE = RANGED_CRIT_CHANCE
local CR_CRIT_RANGED_TOOLTIP = CR_CRIT_RANGED_TOOLTIP
local CRIT_ABBR = CRIT_ABBR
local CR_CRIT_RANGED = CR_CRIT_RANGED

local displayString = ''
local rangedCrit = 0
local critChance = 0
local data

local function GetSettingsData(self)
	data = E.global.datatexts.settings[self.name]
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(RANGED_CRIT_CHANCE.." "..critChance)
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(format(CR_CRIT_RANGED_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED)))
	DT.tooltip:Show()
end

local function OnEvent(self)
	rangedCrit = GetRangedCritChance()

	if not data then GetSettingsData(self) end

	if data.NoLabel then
		self.text:SetFormattedText(displayString, rangedCrit)
	else
		self.text:SetFormattedText(displayString, data.Label ~= '' and data.Label or CRIT_ABBR..': ', rangedCrit)
	end
end

local function ValueColorUpdate(self, hex)
	if not data then GetSettingsData(self) end

	displayString = strjoin('', data.NoLabel and '' or '%s', hex, '%.'..data.decimalLength..'f%%|r')

	OnEvent(self)
end

DT:RegisterDatatext('Ranged Crit Chance', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, not E.Classic and OnEnter, nil, RANGED_CRIT_CHANCE, nil, ValueColorUpdate)
