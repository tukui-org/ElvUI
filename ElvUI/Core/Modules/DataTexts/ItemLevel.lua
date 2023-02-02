local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local ipairs = ipairs
local format = format
local pi = math.pi

local GetItemLevelColor = GetItemLevelColor
local GetAverageItemLevel= GetAverageItemLevel
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture

local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR
local GMSURVEYRATING3 = GMSURVEYRATING3
local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT = LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT
local NOT_APPLICABLE = NOT_APPLICABLE

local sameString = '%s: %s%0.2f|r'
local bothString = '%s: %s%0.2f|r / %s%0.2f|r'
local iconString = '|T%s:13:15:0:0:50:50:4:46:4:46|t %s'
local slotID = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }
local r, g, b, avg, avgEquipped, avgPvp = 1, 1, 1, 0, 0, 0
local db

local function colorize(num)
	if num >= 0 then
		return .1, 1, .1
	else
		return E:ColorGradient(-(pi/num), 1, .1, .1, 1, 1, .1, .1, 1, .1)
	end
end

local function OnEvent(self)
	if E.Retail then
		avg, avgEquipped, avgPvp = GetAverageItemLevel()
		r, g, b = GetItemLevelColor()

		local hex = db.rarityColor and E:RGBToHex(r, g, b) or '|cFFFFFFFF'

		self.text:SetFormattedText(avg == avgEquipped and sameString or bothString, ITEM_LEVEL_ABBR, hex, avgEquipped or 0, hex, avg or 0)
	else
		self.text:SetText(NOT_APPLICABLE)
	end
end

local function OnEnter()
	if not E.Retail then return end

	DT.tooltip:ClearLines()

	DT.tooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL, format('%0.2f', avg), 1, 1, 1, r, g, b)
	DT.tooltip:AddDoubleLine(GMSURVEYRATING3, format('%0.2f', avgEquipped), 1, 1, 1, colorize(avgEquipped - avg))
	DT.tooltip:AddDoubleLine(LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT, format('%0.2f', avgPvp), 1, 1, 1, colorize(avgPvp - avg))
	DT.tooltip:AddLine(' ')

	for _, k in ipairs(slotID) do
		local info = E:GetGearSlotInfo('player', k)
		local ilvl = (info and info ~= 'tooSoon') and info.iLvl
		if ilvl then
			local link = GetInventoryItemLink('player', k)
			local icon = GetInventoryItemTexture('player', k)
			DT.tooltip:AddDoubleLine(format(iconString, icon, link), ilvl, 1, 1, 1, colorize(ilvl - avg))
		end
	end

	DT.tooltip:Show()
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end
end

DT:RegisterDatatext('Item Level', 'Stats', {'PLAYER_AVG_ITEM_LEVEL_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, _G.LFG_LIST_ITEM_LEVEL_INSTR_SHORT, nil, ApplySettings)
