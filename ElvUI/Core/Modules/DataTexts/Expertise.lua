local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin

local GetExpertise = GetExpertise
local IsDualWielding = IsDualWielding
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus

local STAT_EXPERTISE = STAT_EXPERTISE
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_EXPERTISE_TOOLTIP = CR_EXPERTISE_TOOLTIP
local CR_EXPERTISE = CR_EXPERTISE

local displayString = ''
local expertiseRating, expertiseBonusRating, expertisePercentDisplay

local function OnEvent(self)
	local expertise, offhandExpertise = GetExpertise()
	local expertisePercent, offhandExpertisePercent = format('%.2f%%', expertise), format('%.2f%%', offhandExpertise)
	expertiseRating, expertiseBonusRating = GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE)

	if IsDualWielding() then
		expertisePercentDisplay = format('%s / %s', expertisePercent, offhandExpertisePercent)
	else
		expertisePercentDisplay = expertisePercent
	end

	self.text:SetFormattedText(displayString, STAT_EXPERTISE..': ', expertisePercentDisplay)
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(format(CR_EXPERTISE_TOOLTIP, expertisePercentDisplay, expertiseRating, expertiseBonusRating), nil, nil, nil, true)
	DT.tooltip:Show()
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', '%s', hex, '%s|r')

	OnEvent(self)
end

DT:RegisterDatatext('Expertise', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent, nil, nil, OnEnter, nil, STAT_EXPERTISE, nil, ValueColorUpdate)
