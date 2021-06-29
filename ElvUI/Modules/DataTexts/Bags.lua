local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local format = format
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local ToggleAllBags = ToggleAllBags
local CURRENCY = CURRENCY
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local GetBagName = GetBagName
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemTexture = GetInventoryItemTexture
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo

local displayString, lastPanel = ''
local iconString = '|T%s:14:14:0:0:64:64:4:60:4:60|t  %s'
local bagIcon = 'Interface/Buttons/Button-Backpack-Up'

local function OnEvent(self)
	lastPanel = self
	local free, total, used = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	used = total - free

	local textFormat = E.global.datatexts.settings.Bags.textFormat

	if textFormat == "FREE" then
		self.text:SetFormattedText(displayString, L["Bags"]..": ", free)
	elseif textFormat == "USED" then
		self.text:SetFormattedText(displayString, L["Bags"]..": ", used)
	elseif textFormat == "FREE_TOTAL" then
		self.text:SetFormattedText(displayString, L["Bags"]..": ", free, total)
	else
		self.text:SetFormattedText(displayString, L["Bags"]..": ", used, total)
	end
end

local function OnClick()
	ToggleAllBags()
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for i = 0, NUM_BAG_SLOTS do
		local bagName = GetBagName(i)
		if bagName then
			local numSlots = GetContainerNumSlots(i)
			local freeSlots = GetContainerNumFreeSlots(i)
			local usedSlots, sumNum = numSlots - freeSlots, 19 + i

			local r2, g2, b2 = E:ColorGradient(usedSlots / numSlots, .1,1,.1, 1,1,.1, 1,.1,.1)
			local r, g, b, icon

			if i > 0 then
				r, g, b = GetItemQualityColor(GetInventoryItemQuality('player', sumNum) or 1)
				icon = GetInventoryItemTexture('player', sumNum)
			end

			DT.tooltip:AddDoubleLine(format(iconString, icon or bagIcon, bagName), format('%d / %d', usedSlots, numSlots), r or 1, g or 1, b or 1, r2, g2, b2)
		end
	end

	for i = 1, MAX_WATCHED_TOKENS do
		local info = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if info then
			if i == 1 then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(CURRENCY)
				DT.tooltip:AddLine(' ')
			end
			if info.quantity then
				DT.tooltip:AddDoubleLine(format(iconString, info.iconFileID, info.name), info.quantity, 1, 1, 1, 1, 1, 1)
			end
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	local textFormat = E.global.datatexts.settings.Bags.textFormat
	if textFormat == "FREE" or textFormat == "USED" then
		displayString = strjoin('', '%s', hex, '%d|r')
	else
		displayString = strjoin('', '%s', hex, '%d/%d|r')
	end

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Bags', nil, {'BAG_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"], nil, ValueColorUpdate)
