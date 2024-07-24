local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin, abs = format, strjoin, abs

local GetBlockChance = GetBlockChance
local GetBonusBarOffset = GetBonusBarOffset
local GetDodgeChance = GetDodgeChance
local GetInventoryItemID = GetInventoryItemID
local GetInventorySlotInfo = GetInventorySlotInfo
local GetParryChance = GetParryChance
local UnitDefense = UnitDefense
local UnitExists = UnitExists
local UnitLevel = UnitLevel

local GetItemInfo = C_Item.GetItemInfo

local BOSS = BOSS
local MISS_CHANCE = MISS_CHANCE
local BLOCK_CHANCE = BLOCK_CHANCE
local DODGE_CHANCE = DODGE_CHANCE
local PARRY_CHANCE = PARRY_CHANCE
local STAT_CATEGORY_DEFENSE = STAT_CATEGORY_DEFENSE

local chanceString, db = '%.2f%%'
local displayString, targetLevel, playerLevel
local miss, dodge, parry, block, unhittable

local function IsWearingShield()
	local slotID = GetInventorySlotInfo('SecondaryHandSlot')
	local itemID = GetInventoryItemID('player', slotID)

	if itemID then
		local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemID)
		return itemEquipLoc == 'INVTYPE_SHIELD'
	end
end

local function OnEvent(self)
	targetLevel, playerLevel = UnitLevel('target'), E.mylevel

	local levelDiff
	if not UnitExists('target') then -- If there's no target, we'll assume we're talking about a lvl +3 boss. You can click yourself to see against your level
		levelDiff = 3
		targetLevel = 73
	elseif targetLevel == -1 then
		levelDiff = 3
	elseif (targetLevel > playerLevel) or (targetLevel > 0) then
		levelDiff = targetLevel - playerLevel
	else
		levelDiff = 0
	end

	local decayRate = levelDiff * 0.2 -- According to Light's Club discord, avoidance decay should be 0.2% per level per avoidance (thus 102.4 for +3 crush cap)
	local useDecayRate = (levelDiff >= 0 and decayRate) or abs(decayRate)

	dodge = GetDodgeChance() - useDecayRate
	parry = GetParryChance() - useDecayRate
	block = GetBlockChance() - useDecayRate

	local numAvoids = 4
	if dodge <= 0 then dodge, numAvoids = 0, numAvoids - 1 end
	if parry <= 0 then parry, numAvoids = 0, numAvoids - 1 end
	if block <= 0 then block, numAvoids = 0, numAvoids - 1 end
	if E.myclass == 'DRUID' and GetBonusBarOffset() == 3 then
		parry, numAvoids = 0, numAvoids - 1
	end
	if not IsWearingShield() then
		block, numAvoids = 0, numAvoids - 1
	end

	local baseDefense, armorDefense = UnitDefense('player')
	local baseMiss = 5 - useDecayRate -- Base miss chance is 5%
	miss = baseMiss + ((baseDefense or 0) + (armorDefense or 0) - (5 * playerLevel)) * 0.04

	local unhittableMax = 100 + (decayRate * numAvoids) -- unhittableMax is 100
	local avoidance = (dodge + parry + miss) + block -- First roll on hit table determining if the hit missed
	unhittable = avoidance - unhittableMax

	if db.NoLabel then
		self.text:SetFormattedText(displayString, avoidance)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or L["AVD: "], avoidance)
	end

	-- print(unhittableMax) - should report 102.4 for a level differance of +3 for shield classes, 101.2 for druids, 101.8 for monks and dks
end

local function OnEnter()
	DT.tooltip:ClearLines()

	if targetLevel == -1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], strjoin('', ' (', BOSS, ')'))
	else
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], strjoin('', ' (', L["lvl"], ' ', (targetLevel > 0 and targetLevel) or playerLevel, ')'))
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge), 1, 1, 1)
	DT.tooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry), 1, 1, 1)
	DT.tooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block), 1, 1, 1)
	DT.tooltip:AddDoubleLine(MISS_CHANCE, format(chanceString, miss), 1, 1, 1)
	DT.tooltip:AddLine(' ')

	if unhittable > 0 then
		DT.tooltip:AddDoubleLine(L["Unhittable:"], format('+'..chanceString, unhittable), 1, 1, 1, 0, 1, 0)
	else
		DT.tooltip:AddDoubleLine(L["Unhittable:"], format(chanceString, unhittable), 1, 1, 1, 1, 0, 0)
	end

	DT.tooltip:Show()
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Avoidance', STAT_CATEGORY_DEFENSE, { 'UNIT_TARGET', 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_EQUIPMENT_CHANGED' }, OnEvent, nil, nil, OnEnter, nil, L["Avoidance Breakdown"], nil, ApplySettings)
