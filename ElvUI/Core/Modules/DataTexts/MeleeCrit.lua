local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin
local GetCritChance = GetCritChance
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CRIT_ABBR = CRIT_ABBR

local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local CR_CRIT_MELEE_TOOLTIP = CR_CRIT_MELEE_TOOLTIP
local CR_CRIT_MELEE = CR_CRIT_MELEE

local displayString = ''
local meleeCrit = 0
local data

local function GetSettingsData(self)
	data = E.global.datatexts.settings[self.name]
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(MELEE_CRIT_CHANCE.." "..meleeCrit)
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE)))
	DT.tooltip:Show()
end

local function OnEvent(self)
	meleeCrit = GetCritChance()

	if not data then GetSettingsData(self) end

	if data.NoLabel then
		self.text:SetFormattedText(displayString, meleeCrit)
	else
		self.text:SetFormattedText(displayString, data.Label ~= '' and data.Label or CRIT_ABBR..': ', meleeCrit)
	end
end

local function ValueColorUpdate(self, hex)
	if not data then GetSettingsData(self) end

	displayString = strjoin('', data.NoLabel and '' or '%s', hex, '%.'..data.decimalLength..'f%%|r')

	OnEvent(self)
end

DT:RegisterDatatext('Melee Crit Chance', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, MELEE_CRIT_CHANCE, nil, ValueColorUpdate)
