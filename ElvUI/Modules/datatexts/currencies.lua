local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format = string.format
local join = string.join
--WoW API / Variables
local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney

-- Currencies we care about
-- Legion
local ANCIENT_MANA = 1155
local CURIOUS_COIN = 1275
local ORDER_RESOURCES = 1220
local SIGHTLESS_EYE = 1149
local SEAL_OF_BROKEN_FATE = 1273
local NETHERSHARD = 1226
local SHADOWY_COIN = 1154
-- Other 
local APEXIS_CRYSTAL = 823
local DARKMOON_PRIZE_TICKET = 515

local gold

local function OnEvent(self, event, unit)	
	gold = GetMoney();
	self.text:SetText(E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	DT.tooltip:AddDoubleLine(L["Gold:"], E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins), 1, 1, 1)
	DT.tooltip:AddLine(' ')
	
	DT.tooltip:AddLine(L["Legion:"])
	DT.tooltip:AddDoubleLine(L["Ancient Mana"], select(2, GetCurrencyInfo(ANCIENT_MANA)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Curious Coin"], select(2, GetCurrencyInfo(CURIOUS_COIN)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Order Resources"], select(2, GetCurrencyInfo(ORDER_RESOURCES)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Sightless Eye"], select(2, GetCurrencyInfo(SIGHTLESS_EYE)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Seal of Broken Fate"], select(2, GetCurrencyInfo(SEAL_OF_BROKEN_FATE)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Nethershard"], select(2, GetCurrencyInfo(NETHERSHARD)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Shadowy Coin"], select(2, GetCurrencyInfo(SHADOWY_COIN)), 1, 1, 1)
	DT.tooltip:AddLine(' ')
	
	DT.tooltip:AddLine(L["Other:"])
	DT.tooltip:AddDoubleLine(L["Apexis Crystals"], select(2, GetCurrencyInfo(APEXIS_CRYSTAL)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Darkmoon Prize Ticket"], select(2, GetCurrencyInfo(DARKMOON_PRIZE_TICKET)), 1, 1, 1)

	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter)

