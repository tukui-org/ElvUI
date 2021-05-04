local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local format, strjoin, abs = format, strjoin, abs
local GetBlockChance = GetBlockChance
local GetBonusBarOffset = GetBonusBarOffset
local GetDodgeChance = GetDodgeChance
local GetInventoryItemID = GetInventoryItemID
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo
local GetParryChance = GetParryChance
local UnitLevel = UnitLevel
local BOSS = BOSS
local BLOCK_CHANCE = BLOCK_CHANCE
local DODGE_CHANCE = DODGE_CHANCE
local MISS_CHANCE = MISS_CHANCE
local PARRY_CHANCE = PARRY_CHANCE
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel, targetlv, playerlv
local basemisschance, leveldifference, dodge, parry, block, unhittable
local AVD_DECAY_RATE, chanceString = 1.5, '%.2f%%'

local function IsWearingShield()
	local slotID = GetInventorySlotInfo('SecondaryHandSlot')
	local itemID = GetInventoryItemID('player', slotID)

	if itemID then
		local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemID)
		return itemEquipLoc == 'INVTYPE_SHIELD'
	end
end

local function OnEvent(self)
	targetlv, playerlv = UnitLevel('target'), E.mylevel

	basemisschance = E.myrace == 'NightElf' and 7 or 5
	if targetlv == -1 then
		leveldifference = 3
	elseif targetlv > playerlv then
		leveldifference = (targetlv - playerlv)
	elseif targetlv < playerlv and targetlv > 0 then
		leveldifference = (targetlv - playerlv)
	else
		leveldifference = 0
	end

	if leveldifference >= 0 then
		dodge = (GetDodgeChance() - leveldifference * AVD_DECAY_RATE)
		parry = (GetParryChance() - leveldifference * AVD_DECAY_RATE)
		block = (GetBlockChance() - leveldifference * AVD_DECAY_RATE)
		basemisschance = (basemisschance - leveldifference * AVD_DECAY_RATE)
	else
		dodge = (GetDodgeChance() + abs(leveldifference * AVD_DECAY_RATE))
		parry = (GetParryChance() + abs(leveldifference * AVD_DECAY_RATE))
		block = (GetBlockChance() + abs(leveldifference * AVD_DECAY_RATE))
		basemisschance = (basemisschance+ abs(leveldifference * AVD_DECAY_RATE))
	end

	local unhittableMax = 100
	local numAvoidances = 4
	if dodge <= 0 then dodge = 0 end
	if parry <= 0 then parry = 0 end
	if block <= 0 then block = 0 end

	if E.myclass == 'DRUID' and GetBonusBarOffset() == 3 then
		parry = 0
		numAvoidances = numAvoidances - 1
	end

	if not IsWearingShield() then
		block = 0
		numAvoidances = numAvoidances - 1
	end

	unhittableMax = unhittableMax + ((AVD_DECAY_RATE * leveldifference) * numAvoidances)

	local avoided = (dodge+parry+basemisschance) --First roll on hit table determining if the hit missed
	local blocked = (100 - avoided)*block/100 --If the hit landed then the second roll determines if the his was blocked
	local avoidance = (avoided+blocked)
	unhittable = avoidance - unhittableMax

	if E.global.datatexts.settings.Avoidance.NoLabel then
		self.text:SetFormattedText(displayString, avoidance)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Avoidance.Label ~= '' and E.global.datatexts.settings.Avoidance.Label or L["AVD: "], avoidance)
	end

	--print(unhittableMax) -- should report 102.4 for a level differance of +3 for shield classes, 101.2 for druids, 101.8 for monks and dks
	lastPanel = self
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local rightString = targetlv > 1 and strjoin('', ' (', L["lvl"], ' ', targetlv, ')') or targetlv == -1 and strjoin('', ' (', BOSS, ')') or strjoin('', ' (', L["lvl"], ' ', playerlv, ')')
	DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], rightString)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge), 1, 1, 1)
	DT.tooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry), 1, 1, 1)
	DT.tooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block), 1, 1, 1)
	DT.tooltip:AddDoubleLine(MISS_CHANCE, format(chanceString, basemisschance), 1, 1, 1)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(L["Unhittable:"], (unhittable > 0 and '+' or '')..format(chanceString, unhittable), 1, 1, 1, (unhittable < 0 and 1 or 0), (unhittable > 0 and 1 or 0), 0)
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Avoidance.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Avoidance.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Avoidance', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_TARGET', 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'PLAYER_EQUIPMENT_CHANGED'}, OnEvent, nil, nil, OnEnter, nil, L["Avoidance Breakdown"], nil, ValueColorUpdate)
