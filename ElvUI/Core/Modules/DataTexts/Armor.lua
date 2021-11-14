local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local select = select
local format = format
local strjoin = strjoin
local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local ARMOR = ARMOR

local chanceString = '%.2f%%'
local displayString, lastPanel, effectiveArmor = ''

local function GetArmorReduction(armor, attackerLevel)
	local levelModifier = attackerLevel
	if levelModifier > 59 then
		levelModifier = levelModifier + (4.5 * (levelModifier - 59))
	end
	local temp = 0.1 * armor / (8.5 * levelModifier + 40)
	temp = temp/(1 + temp)

	if temp > 0.75 then return 75 end
	if temp < 0 then return 0 end

	return temp * 100
end

local function OnEvent(self)
	effectiveArmor = select(2, UnitArmor('player'))

	if E.global.datatexts.settings.Armor.NoLabel then
		self.text:SetFormattedText(displayString, effectiveArmor)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Armor.Label ~= '' and E.global.datatexts.settings.Armor.Label or ARMOR..': ', effectiveArmor)
	end

	lastPanel = self
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(L["Mitigation By Level: "])
	DT.tooltip:AddLine(' ')

	local playerLevel = E.mylevel + 3
	for _ = 1, 4 do
		local armorReduction = GetArmorReduction(effectiveArmor, playerLevel)
		DT.tooltip:AddDoubleLine(format(L["Level %d"], playerLevel), format(chanceString, armorReduction), 1, 1, 1)
		playerLevel = playerLevel - 1
	end

	local targetLevel = UnitLevel('target')
	if targetLevel and targetLevel > 0 and (targetLevel > playerLevel + 3 or targetLevel < playerLevel) then
		local armorReduction = GetArmorReduction(effectiveArmor, targetLevel)
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["Target Mitigation"], format(chanceString, armorReduction), 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Armor.NoLabel and '' or '%s', hex, '%d|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Armor', STAT_CATEGORY_ATTRIBUTES, {'UNIT_STATS', 'UNIT_RESISTANCES'}, OnEvent, nil, nil, OnEnter, nil, ARMOR, nil, ValueColorUpdate)
