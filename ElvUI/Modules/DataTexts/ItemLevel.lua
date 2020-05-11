local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local displayString1 = ''
local displayString2 = ''
local lastPanel
local strjoin = strjoin
local format = format

local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR
local LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT = LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT
local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local GMSURVEYRATING3 = GMSURVEYRATING3

local GetAverageItemLevel= GetAverageItemLevel
local GetInstanceInfo = GetInstanceInfo
local C_PvP_IsWarModeActive = C_PvP.IsWarModeActive
local GetInventoryItemLink = GetInventoryItemLink

local slotID = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}

local function OnEvent(self, event)
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()

	if avgItemLevel == avgItemLevelEquipped then
		self.text:SetFormattedText(displayString2, ITEM_LEVEL_ABBR, avgItemLevelEquipped)
	else
		self.text:SetFormattedText(displayString1, ITEM_LEVEL_ABBR, avgItemLevelEquipped, avgItemLevel)
	end
end

local function OnEnter(self)
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()

	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL, format('%0.2f', avgItemLevel), 1, 1, 1, 0, 1, 0)
	DT.tooltip:AddDoubleLine(GMSURVEYRATING3, format('%0.2f', avgItemLevelEquipped), 1, 1, 1, 0, 1, 0)
	DT.tooltip:AddDoubleLine(LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT, format('%0.2f', avgItemLevelPvp), 1, 1, 1, 0, 1, 0)

	DT.tooltip:AddLine(" ")

	for _, k in pairs(slotID) do
		local itemLink = GetInventoryItemLink("player", k)
		local itemIcon = GetInventoryItemTexture("player", k)
		local itemInfo = E:GetGearSlotInfo('player', k)
		if itemInfo then
			local r, g, b = E:ColorGradient((itemInfo.iLvl - avgItemLevel) * 100, 1, 0, 0, 1, 1, 0, 0, 1, 0)
			DT.tooltip:AddDoubleLine(itemLink, itemInfo.iLvl, 1, 1, 1, r, g, b)
		end
	end

	DT.tooltip:Show()

	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayString1 = strjoin("", "%s: ", hex, "%0.2f / %0.2f|r")
	displayString2 = strjoin("", "%s: ", hex, "%0.2f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext("Item Level", 'Stats', {"PLAYER_ENTERING_WORLD", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, OnEvent, nil, nil, OnEnter, nil, LFG_LIST_ITEM_LEVEL_INSTR_SHORT)
