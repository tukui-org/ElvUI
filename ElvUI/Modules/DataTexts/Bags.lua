local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
local function OnEvent(self)
	lastPanel = self
	local free, total = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	self.text:SetFormattedText(displayString, L["Bags"]..': ', total - free, total)
end

local function OnClick()
	ToggleAllBags()
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for i = 0, NUM_BAG_SLOTS do
		local bagName = GetBagName(i)
		if bagName then
			local bagFreeSlots = GetContainerNumFreeSlots(i)
			local bagSlots = GetContainerNumSlots(i)
			local r, g, b, icon = 1, 1, 1, 'Interface/Buttons/Button-Backpack-Up'
			local r2, g2, b2 = E:ColorGradient(bagFreeSlots/bagSlots, .1, 1, .1, 1, 1, .1, 1, .1, .1)

			if i > 0 then
				local quality = GetInventoryItemQuality("player", 19 + i)
				r, g, b = GetItemQualityColor(quality or 1)
				icon = GetInventoryItemTexture("player", 19 + i)
			end

			DT.tooltip:AddDoubleLine(format(iconString, icon, bagName), format('%d / %d', bagFreeSlots, bagSlots), r, g, b, r2, g2, b2)
		end
	end

	for i = 1, MAX_WATCHED_TOKENS do
		local info = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if info then
			if i == 1 then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(CURRENCY)
				DT.tooltip:AddLine(" ")
			end
			if info.quantity then
				DT.tooltip:AddDoubleLine(format(iconString, info.iconFileID, info.name), info.quantity, 1, 1, 1, 1, 1, 1)
			end
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s", hex, "%d/%d|r")

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Bags', nil, {"BAG_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"])
