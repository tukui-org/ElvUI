local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin
local GetBagName = GetBagName
local ToggleAllBags = ToggleAllBags
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemQualityColor = GetItemQualityColor
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local CURRENCY = CURRENCY

local displayString, lastPanel = ''
local iconString = '|T%s:14:14:0:0:64:64:4:60:4:60|t  %s'
local BAG_TYPES = {
	[0x0001] = 'Quiver',
	[0x0002] = 'Ammo Pouch',
	[0x0004] = 'Soul Bag',
}

local function OnEvent(self)
	lastPanel = self

	local free, total = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		local freeSlots, bagType = GetContainerNumFreeSlots(i)
		if not bagType or bagType == 0 then
			free, total = free + freeSlots, total + GetContainerNumSlots(i)
		end
	end

	local textFormat = E.global.datatexts.settings.Bags.textFormat
	if textFormat == 'FREE' then
		self.text:SetFormattedText(displayString, free)
	elseif textFormat == 'USED' then
		self.text:SetFormattedText(displayString, total - free)
	elseif textFormat == 'FREE_TOTAL' then
		self.text:SetFormattedText(displayString, free, total)
	else
		self.text:SetFormattedText(displayString, total - free, total)
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
			local freeSlots, bagType = GetContainerNumFreeSlots(i)
			local usedSlots, invID = numSlots - freeSlots, 19 + i
			local r, g, b, r2, g2, b2, icon

			if BAG_TYPES[bagType] then -- reverse for ammo bags
				r2, g2, b2 = E:ColorGradient(usedSlots/numSlots, 1,.1,.1, 1,1,.1, .1,1,.1) -- red, yellow, green
			else
				r2, g2, b2 = E:ColorGradient(usedSlots/numSlots, .1,1,.1, 1,1,.1, 1,.1,.1) -- green, yellow, red
			end

			if i > 0 then
				r, g, b = GetItemQualityColor(GetInventoryItemQuality('player', invID) or 1)
				icon = GetInventoryItemTexture('player', invID)
			end

			DT.tooltip:AddDoubleLine(format(iconString, icon or E.Media.Textures.Backpack, bagName), format('%d / %d', usedSlots, numSlots), r or 1, g or 1, b or 1, r2, g2, b2)
		end
	end

	if E.Retail or E.Wrath then
		for i = 1, MAX_WATCHED_TOKENS do
			local info = E.Retail and C_CurrencyInfo_GetBackpackCurrencyInfo(i) or E.Wrath and {}
			if E.Wrath then info.name, info.quantity, info.iconFileID, info.currencyTypesID = GetBackpackCurrencyInfo(i) end
			if not (info and info.name) then break end

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
	local noLabel = E.global.datatexts.settings.Bags.NoLabel and ''
	local labelString = noLabel or (E.global.datatexts.settings.Bags.Label ~= '' and E.global.datatexts.settings.Bags.Label) or strjoin('', L["Bags"], ': ')

	displayString = strjoin('', labelString, hex, (textFormat == 'FREE' or textFormat == 'USED') and '%d|r' or '%d/%d|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Bags', nil, {'BAG_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"], nil, ValueColorUpdate)
