local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local ipairs = ipairs
local strjoin = strjoin
local format = format
local pi = math.pi

local lastPanel
local displayString1 = ''
local displayString2 = ''

local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR
local LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT = LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT
local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local GMSURVEYRATING3 = GMSURVEYRATING3

local GetAverageItemLevel= GetAverageItemLevel
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture

local iconString = '|T%s:13:15:0:0:50:50:4:46:4:46|t %s'
local slotID = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }

local function colorize(num)
	if num >= 0 then
		return .1, 1, .1
	else
		return E:ColorGradient(-(pi/num), 1, .1, .1, 1, 1, .1, .1, 1, .1)
	end
end

local function OnEvent(self)
	local avg, avgEquipped = GetAverageItemLevel()
	local same = avg == avgEquipped
	self.text:SetFormattedText(same and displayString2 or displayString1, ITEM_LEVEL_ABBR, avgEquipped, same and avg or '0')
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local avg, avgEquipped, avgPvp = GetAverageItemLevel()
	DT.tooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL, format('%0.2f', avg), 1, 1, 1, .1, 1, .1)
	DT.tooltip:AddDoubleLine(GMSURVEYRATING3, format('%0.2f', avgEquipped), 1, 1, 1, colorize(avgEquipped - avg))
	DT.tooltip:AddDoubleLine(LFG_LIST_ITEM_LEVEL_INSTR_PVP_SHORT, format('%0.2f', avgPvp), 1, 1, 1, colorize(avgPvp - avg))
	DT.tooltip:AddLine(' ')

	for _, k in ipairs(slotID) do
		local itemInfo = E:GetGearSlotInfo('player', k)
		local ilvl = itemInfo and itemInfo.iLvl
		if ilvl then
			local link = GetInventoryItemLink('player', k)
			local icon = GetInventoryItemTexture('player', k)
			DT.tooltip:AddDoubleLine(format(iconString, icon, link), ilvl, 1, 1, 1, colorize(ilvl - avg))
		end
	end

	DT.tooltip:Show()

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString1 = strjoin('', '%s: ', hex, '%0.2f / %0.2f|r')
	displayString2 = strjoin('', '%s: ', hex, '%0.2f|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Item Level', 'Stats', {'PLAYER_AVG_ITEM_LEVEL_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, _G.LFG_LIST_ITEM_LEVEL_INSTR_SHORT)
