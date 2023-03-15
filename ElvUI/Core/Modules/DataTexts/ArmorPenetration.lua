local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local strjoin = strjoin
local format = format

local CR_ARMOR_PENETRATION = CR_ARMOR_PENETRATION
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT
local ITEM_MOD_ARMOR_PENETRATION_RATING = ITEM_MOD_ARMOR_PENETRATION_RATING

local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetArmorPenetration = GetArmorPenetration

local displayString = ''
local APRating, APBonusRating, APPercent = 0, 0, 0

local function OnEvent(self)
	APRating = GetCombatRating(CR_ARMOR_PENETRATION)
	APBonusRating = GetCombatRatingBonus(CR_ARMOR_PENETRATION)
	APPercent = GetArmorPenetration()

	self.text:SetFormattedText(displayString, 'Armor Penetration', APRating + APBonusRating)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(format(ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT, format('%d', APRating)))
	DT.tooltip:AddLine(format(ITEM_MOD_ARMOR_PENETRATION_RATING , format('%.2f%%', APPercent)))

	DT.tooltip:Show()
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%s|r')
end

DT:RegisterDatatext('Armor Penetration', STAT_CATEGORY_ENHANCEMENTS, { 'COMBAT_RATING_UPDATE' }, OnEvent, nil, nil, OnEnter, nil, nil, nil, ApplySettings)
