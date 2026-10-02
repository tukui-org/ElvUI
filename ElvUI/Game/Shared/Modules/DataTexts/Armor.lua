local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin

local UnitArmor = UnitArmor
local UnitLevel = UnitLevel

local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local ARMOR = ARMOR

local armorStale, armorActive
local changeStale, changeActive = '|cFF888888%.2f%%|r', '%.2f%%'
local displayString, db = ''

local function GetArmorReduction(armor, level)
	if level > 59 then
		level = level + (4.5 * (level - 59))
	end

	local amount = (0.1 * armor) / (8.5 * level + 40)
	local value = amount / (1 + amount)

	if value > 0.75 then
		return 75
	elseif value < 0 then
		return 0
	end

	return value * 100
end

local function OnEvent(panel)
	local _, effective = UnitArmor('player')

	armorActive = effective

	if E:NotSecretValue(effective) then
		armorStale = effective
	end

	if db.NoLabel then
		panel.text:SetFormattedText(displayString, effective)
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ARMOR..': ', effective)
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local isActive = E:NotSecretValue(armorActive)
	local effective = (isActive and armorActive) or armorStale
	local changeText = (isActive and changeActive) or changeStale

	DT.tooltip:AddLine(L["Mitigation By Level: "])
	DT.tooltip:AddLine(' ')

	local playerLevel = E.mylevel + 3
	for _ = 1, 4 do
		local reduction = GetArmorReduction(effective, playerLevel)
		DT.tooltip:AddDoubleLine(format(L["Level %d"], playerLevel), format(changeText, reduction), 1, 1, 1)
		playerLevel = playerLevel - 1
	end

	local targetLevel = UnitLevel('target')
	if (targetLevel and targetLevel > 0) and ((targetLevel > playerLevel + 3) or (targetLevel < playerLevel)) then
		local reduction = GetArmorReduction(effective, targetLevel)
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["Target Mitigation"], format(changeText, reduction), 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Armor', STAT_CATEGORY_ATTRIBUTES, {'UNIT_STATS', 'UNIT_RESISTANCES'}, OnEvent, nil, nil, OnEnter, nil, ARMOR, nil, ApplySettings)
