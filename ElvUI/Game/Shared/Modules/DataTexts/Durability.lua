local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format, next, wipe = format, next, wipe

local ToggleCharacter = ToggleCharacter
local GetInventoryItemDurability = GetInventoryItemDurability
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemLink = GetInventoryItemLink

local DURABILITY = DURABILITY
local REPAIR_COST = REPAIR_COST

local tooltipString = '%d%%'
local tempDurabilities = {}
local totalDurabilities = {}
local totalDurability = 100
local totalRepairCost = 0
local db

local inventorySlots = {
	INVTYPE_HEAD = 1,
	INVTYPE_SHOULDER = 3,
	INVTYPE_CHEST = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_RANGED = 18
}

local function OnEvent(panel)
	local tempDurability = 100
	local tempRepairCost = 0

	wipe(tempDurabilities)

	for _, index in next, inventorySlots do
		local currentDura, maxDura = GetInventoryItemDurability(index)
		if currentDura and maxDura > 0 then
			local perc, repairCost, _ = (currentDura/maxDura)*100
			tempDurabilities[index] = perc

			if perc < tempDurability then
				tempDurability = perc
			end

			if E.Retail then
				local data = E.ScanTooltip:GetInventoryInfo('player', index)
				repairCost = data and data.repairCost
			else
				_, _, repairCost = E.ScanTooltip:SetInventoryItem('player', index)
			end

			tempRepairCost = tempRepairCost + (repairCost or 0)
		end
	end

	-- require data to update display
	if next(tempDurabilities) then
		totalDurability = tempDurability
		totalRepairCost = tempRepairCost

		wipe(totalDurabilities) -- clear it before the copy
		E:CopyTable(totalDurabilities, tempDurabilities)
	end

	local r, g, b = E:ColorGradient(totalDurability * .01, 1, .1, .1, 1, 1, .1, .1, 1, .1)
	local hex = E:RGBToHex(r, g, b)

	if db.NoLabel then
		panel.text:SetFormattedText('%s%d%%|r', hex, totalDurability)
	else
		panel.text:SetFormattedText('%s%s%d%%|r', db.Label ~= '' and db.Label or (DURABILITY..': '), hex, totalDurability)
	end

	if totalDurability <= db.percThreshold then
		E:Flash(panel, 0.5, true)
	else
		E:StopFlash(panel, 1)
	end
end

local function Click()
	if not E:AlertCombat() then
		ToggleCharacter('PaperDollFrame')
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for slot, durability in next, totalDurabilities do
		DT.tooltip:AddDoubleLine(format('|T%s:14:14:0:0:64:64:4:60:4:60|t %s', GetInventoryItemTexture('player', slot), GetInventoryItemLink('player', slot)), format(tooltipString, durability), 1, 1, 1, E:ColorGradient(durability * 0.01, 1, .1, .1, 1, 1, .1, .1, 1, .1))
	end

	if totalRepairCost > 0 then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(REPAIR_COST, E:FormatMoney(totalRepairCost, db.goldFormat or 'BLIZZARD', not db.goldCoins), .6, .8, 1, 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function ApplySettings(panel)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end
end

DT:RegisterDatatext('Durability', nil, { 'UPDATE_INVENTORY_DURABILITY' }, OnEvent, nil, Click, OnEnter, nil, DURABILITY, nil, ApplySettings)
