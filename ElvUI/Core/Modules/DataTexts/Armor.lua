local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin
local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local ARMOR = ARMOR

local chanceString = '%.2f%%'
local displayString, db, effectiveArmor, _ = ''

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
	_, effectiveArmor = UnitArmor('player')

	if db.NoLabel then
		self.text:SetFormattedText(displayString, effectiveArmor)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ARMOR..': ', effectiveArmor)
	end
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

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Armor', STAT_CATEGORY_ATTRIBUTES, {'UNIT_STATS', 'UNIT_RESISTANCES'}, OnEvent, nil, nil, OnEnter, nil, ARMOR, nil, ApplySettings)
