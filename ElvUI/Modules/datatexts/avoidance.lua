local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format, join = string.format, string.join
local abs = abs
--WoW API / Variables
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local UnitLevel = UnitLevel
local GetDodgeChance = GetDodgeChance
local GetParryChance = GetParryChance
local GetBlockChance = GetBlockChance
local GetBonusBarOffset = GetBonusBarOffset
local BOSS = BOSS
local DODGE_CHANCE = DODGE_CHANCE
local PARRY_CHANCE = PARRY_CHANCE
local BLOCK_CHANCE = BLOCK_CHANCE
local MISS_CHANCE = MISS_CHANCE

local displayString, lastPanel
local targetlv, playerlv
local basemisschance, leveldifference, dodge, parry, block, avoidance, unhittable, avoided, blocked, numAvoidances, unhittableMax
local chanceString = "%.2f%%"
local AVD_DECAY_RATE = 1.5

local function IsWearingShield()
	local slotID = GetInventorySlotInfo("SecondaryHandSlot")
	local itemID = GetInventoryItemID('player', slotID)

	if itemID then
		local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemID)
		return itemEquipLoc == "INVTYPE_SHIELD"
	end
end

local function OnEvent(self)
	targetlv, playerlv = UnitLevel("target"), UnitLevel("player")

	basemisschance = E.myrace == "NightElf" and 7 or 5
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
		dodge = (GetDodgeChance() - leveldifference*AVD_DECAY_RATE)
		parry = (GetParryChance() - leveldifference*AVD_DECAY_RATE)
		block = (GetBlockChance() - leveldifference*AVD_DECAY_RATE)
		basemisschance = (basemisschance - leveldifference*AVD_DECAY_RATE)
	else
		dodge = (GetDodgeChance() + abs(leveldifference*AVD_DECAY_RATE))
		parry = (GetParryChance() + abs(leveldifference*AVD_DECAY_RATE))
		block = (GetBlockChance() + abs(leveldifference*AVD_DECAY_RATE))
		basemisschance = (basemisschance+ abs(leveldifference*AVD_DECAY_RATE))
	end

	unhittableMax = 100
	numAvoidances = 4
	if dodge <= 0 then dodge = 0 end
	if parry <= 0 then parry = 0 end
	if block <= 0 then block = 0 end

	if E.myclass == "DRUID" and GetBonusBarOffset() == 3 then
		parry = 0
		numAvoidances = numAvoidances - 1
	end

	if not IsWearingShield() then
		block = 0
		numAvoidances = numAvoidances - 1
	end

	unhittableMax = unhittableMax + ((AVD_DECAY_RATE * leveldifference) * numAvoidances)

	avoided = (dodge+parry+basemisschance) --First roll on hit table determining if the hit missed
	blocked = (100 - avoided)*block/100 --If the hit landed then the second roll determines if the his was blocked
	avoidance = (avoided+blocked)
	unhittable = avoidance - unhittableMax

	self.text:SetFormattedText(displayString, L["AVD: "], avoidance)

	--print(unhittableMax) -- should report 102.4 for a level differance of +3 for shield classes, 101.2 for druids, 101.8 for monks and dks
	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if targetlv > 1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", L["lvl"], " ", targetlv, ")"))
	elseif targetlv == -1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", BOSS, ")"))
	else
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", L["lvl"], " ", playerlv, ")"))
	end
	DT.tooltip:AddLine' '
	DT.tooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge),1,1,1)
	DT.tooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry),1,1,1)
	DT.tooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block),1,1,1)
	DT.tooltip:AddDoubleLine(MISS_CHANCE, format(chanceString, basemisschance),1,1,1)
	DT.tooltip:AddLine(' ')

	if unhittable > 0 then
		DT.tooltip:AddDoubleLine(L["Unhittable:"], '+'..format(chanceString, unhittable), 1, 1, 1, 0, 1, 0)
	else
		DT.tooltip:AddDoubleLine(L["Unhittable:"], format(chanceString, unhittable), 1, 1, 1, 1, 0, 0)
	end
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Avoidance', {"UNIT_TARGET", "UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", 'PLAYER_EQUIPMENT_CHANGED'}, OnEvent, nil, nil, OnEnter, nil, L["Avoidance Breakdown"])
