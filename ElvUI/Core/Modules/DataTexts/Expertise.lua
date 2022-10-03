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

local displayString, lastPanel = ''

local expertise, offhandExpertise, expertisePercent, offhandExpertisePercent, expertisePercentDisplay
local expertiseRating, expertiseBonusRating

local function OnEvent(self)
	expertise, offhandExpertise = GetExpertise()
	expertisePercent, offhandExpertisePercent = format('%.2f%%', expertise), format('%.2f%%', offhandExpertise)
	expertiseRating, expertiseBonusRating = GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE)

	expertisePercentDisplay = expertisePercent
	if (IsDualWielding()) then
		expertisePercentDisplay = format('%s / %s', expertisePercent, offhandExpertisePercent)
	end

	self.text:SetFormattedText(displayString, STAT_EXPERTISE..': ', expertisePercentDisplay)

	lastPanel = self
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(format(CR_EXPERTISE_TOOLTIP, expertisePercentDisplay, expertiseRating, expertiseBonusRating), nil, nil, nil, true)
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s', hex, '%s|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel, 2000)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Expertise', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent, nil, nil, OnEnter, nil, STAT_EXPERTISE, nil, ValueColorUpdate)
