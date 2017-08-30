local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local select, pairs = select, pairs
local format = string.format
--WoW API / Variables
local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local EXPANSION_NAME6 = EXPANSION_NAME6
local OTHER = OTHER

-- Currencies we care about
local Currencies = {
	-- Legion
	["ANCIENT_MANA"] = {ID = 1155, NAME = GetCurrencyInfo(1155), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1155)), 16, 16)},
	["CURIOUS_COIN"] = {ID = 1275, NAME = GetCurrencyInfo(1275), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1275)), 16, 16)},
	["ORDER_RESOURCES"] = {ID = 1220, NAME = GetCurrencyInfo(1220), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1220)), 16, 16)},
	["LEGIONFALL_WAR_SUPPLIES"] = {ID = 1342, NAME = GetCurrencyInfo(1342), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1342)), 16, 16)}, 
	["SIGHTLESS_EYE"] = {ID = 1149, NAME = GetCurrencyInfo(1149), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1149)), 16, 16)},
	["SEAL_OF_BROKEN_FATE"] = {ID = 1273, NAME = GetCurrencyInfo(1273), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1273)), 16, 16)},
	["NETHERSHARD"] = {ID = 1226, NAME = GetCurrencyInfo(1226), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1226)), 16, 16)},
	["SHADOWY_COIN"] = {ID = 1154, NAME = GetCurrencyInfo(1154), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1154)), 16, 16)},
	["VEILED_ARGUNITE"] = {ID = 1508, NAME = GetCurrencyInfo(1508), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(1508)), 16, 16)},
	-- Other 
	["APEXIS_CRYSTAL"] = {ID = 823, NAME = GetCurrencyInfo(823), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(823)), 16, 16)},
	["DARKMOON_PRIZE_TICKET"] = {ID = 515, NAME = GetCurrencyInfo(515), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(515)), 16, 16)},
}

local currencyList
function DT:Currencies_GetCurrencyList()
	currencyList = {}
	for currency, data in pairs(Currencies) do
		currencyList[currency] = data.NAME
	end
	currencyList["GOLD"] = BONUS_ROLL_REWARD_MONEY

	return currencyList
end

local gold
local chosenCurrency, currencyAmount

local function OnEvent(self)
	gold = GetMoney();
	if E.db.datatexts.currencies.displayedCurrency == "GOLD" then
		self.text:SetText(E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))
	else
		chosenCurrency = Currencies[E.db.datatexts.currencies.displayedCurrency]
		if chosenCurrency then
			currencyAmount = select(2, GetCurrencyInfo(chosenCurrency.ID))
			if E.db.datatexts.currencies.displayStyle == "ICON" then
				self.text:SetFormattedText("%s %d", chosenCurrency.ICON, currencyAmount)
			elseif E.db.datatexts.currencies.displayStyle == "ICON_TEXT" then
				self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, chosenCurrency.NAME, currencyAmount)
			else --ICON_TEXT_ABBR
				self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, E:AbbreviateString(chosenCurrency.NAME), currencyAmount)
			end
		end
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	DT.tooltip:AddDoubleLine(L["Gold"]..":", E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins), nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(' ')
	
	DT.tooltip:AddLine(EXPANSION_NAME6) --"Legion"
	DT.tooltip:AddDoubleLine(Currencies["ANCIENT_MANA"].NAME, select(2, GetCurrencyInfo(Currencies["ANCIENT_MANA"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["CURIOUS_COIN"].NAME, select(2, GetCurrencyInfo(Currencies["CURIOUS_COIN"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["ORDER_RESOURCES"].NAME, select(2, GetCurrencyInfo(Currencies["ORDER_RESOURCES"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["LEGIONFALL_WAR_SUPPLIES"].NAME, select(2, GetCurrencyInfo(Currencies["LEGIONFALL_WAR_SUPPLIES"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["SIGHTLESS_EYE"].NAME, select(2, GetCurrencyInfo(Currencies["SIGHTLESS_EYE"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["SEAL_OF_BROKEN_FATE"].NAME, select(2, GetCurrencyInfo(Currencies["SEAL_OF_BROKEN_FATE"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["NETHERSHARD"].NAME, select(2, GetCurrencyInfo(Currencies["NETHERSHARD"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["SHADOWY_COIN"].NAME, select(2, GetCurrencyInfo(Currencies["SHADOWY_COIN"].ID)), 1, 1, 1)
	DT.tooltip:AddLine(' ')
	
	DT.tooltip:AddLine(OTHER)
	DT.tooltip:AddDoubleLine(Currencies["APEXIS_CRYSTAL"].NAME, select(2, GetCurrencyInfo(Currencies["APEXIS_CRYSTAL"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["DARKMOON_PRIZE_TICKET"].NAME, select(2, GetCurrencyInfo(Currencies["DARKMOON_PRIZE_TICKET"].ID)), 1, 1, 1)

	--[[
		If the "Display In Tooltip" box is checked (on by default), then also display custom
		currencies in the tooltip.
	]]
	local shouldAddHeader = true
	for currencyID, info in pairs(E.global.datatexts.customCurrencies) do
		if info.DISPLAY_IN_MAIN_TOOLTIP then
			if shouldAddHeader then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(L["Custom Currency"])
				shouldAddHeader = false
			end
			
			DT.tooltip:AddDoubleLine(info.NAME, select(2, GetCurrencyInfo(info.ID)), 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, CURRENCY)

