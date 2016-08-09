local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local select = select
local format = string.format
local join = string.join
--WoW API / Variables
local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local EXPANSION_NAME6 = EXPANSION_NAME6
local OTHER = OTHER

-- Currencies we care about
-- Legion
local ANCIENT_MANA_ID = 1155
local ANCIENT_MANA_NAME = GetCurrencyInfo(ANCIENT_MANA_ID)
local CURIOUS_COIN_ID = 1275
local CURIOUS_COIN_NAME = GetCurrencyInfo(CURIOUS_COIN_ID)
local ORDER_RESOURCES_ID = 1220
local ORDER_RESOURCES_NAME = GetCurrencyInfo(ORDER_RESOURCES_ID)
local SIGHTLESS_EYE_ID = 1149
local SIGHTLESS_EYE_NAME = GetCurrencyInfo(SIGHTLESS_EYE_ID)
local SEAL_OF_BROKEN_FATE_ID = 1273
local SEAL_OF_BROKEN_NAME = GetCurrencyInfo(SEAL_OF_BROKEN_FATE_ID)
local NETHERSHARD_ID = 1226
local NETHERSHARD_NAME = GetCurrencyInfo(NETHERSHARD_ID)
local SHADOWY_COIN_ID = 1154
local SHADOWY_COIN_NAME = GetCurrencyInfo(SHADOWY_COIN_ID)
-- Other 
local APEXIS_CRYSTAL_ID = 823
local APEXIS_CRYSTAL_NAME = GetCurrencyInfo(APEXIS_CRYSTAL_ID)
local DARKMOON_PRIZE_TICKET_ID = 515
local DARKMOON_PRIZE_TICKET_NAME = GetCurrencyInfo(DARKMOON_PRIZE_TICKET_ID)

local gold

local function OnEvent(self, event, unit)	
	gold = GetMoney();
	self.text:SetText(E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	DT.tooltip:AddDoubleLine(L["Gold:"], E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins), 1, 1, 1)
	DT.tooltip:AddLine(' ')
	
	DT.tooltip:AddLine(EXPANSION_NAME6) --"Legion"
	DT.tooltip:AddDoubleLine(ANCIENT_MANA_NAME, select(2, GetCurrencyInfo(ANCIENT_MANA_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(CURIOUS_COIN_NAME, select(2, GetCurrencyInfo(CURIOUS_COIN_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(ORDER_RESOURCES_NAME, select(2, GetCurrencyInfo(ORDER_RESOURCES_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(SIGHTLESS_EYE_NAME, select(2, GetCurrencyInfo(SIGHTLESS_EYE_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(SEAL_OF_BROKEN_NAME, select(2, GetCurrencyInfo(SEAL_OF_BROKEN_FATE_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(NETHERSHARD_NAME, select(2, GetCurrencyInfo(NETHERSHARD_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(SHADOWY_COIN_NAME, select(2, GetCurrencyInfo(SHADOWY_COIN_ID)), 1, 1, 1)
	DT.tooltip:AddLine(' ')
	
	DT.tooltip:AddLine(OTHER)
	DT.tooltip:AddDoubleLine(APEXIS_CRYSTAL_NAME, select(2, GetCurrencyInfo(APEXIS_CRYSTAL_ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(DARKMOON_PRIZE_TICKET_NAME, select(2, GetCurrencyInfo(DARKMOON_PRIZE_TICKET_ID)), 1, 1, 1)

	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter)

