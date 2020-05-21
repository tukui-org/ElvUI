local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, pairs = format, pairs
local GetMoney = GetMoney
local GetCurrencyInfo = GetCurrencyInfo
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local EXPANSION_NAME7 = EXPANSION_NAME7
local OTHER = OTHER

-- Currencies we care about
local iconString = "|T%s:16:16:0:0:64:64:4:60:4:60|t"
local Currencies = {
	--BfA
	["SEAFARERS_DUBLOON"]			= {ID = 1710},
	["SEAL_OF_WARTORN_FATE"]		= {ID = 1580},
	["WAR_RESOURCES"]				= {ID = 1560},
	["HONORBOUND_SERVICE_MEDAL"]	= {ID = 1716},
	["7TH_LEGION_SERVICE_MEDAL"]	= {ID = 1717},
	["TITAN_RESIDUUM"]				= {ID = 1718},
	["PRISMATIC_MANAPEARL"]			= {ID = 1721},
	["CORRUPTED_MEMENTOS"]			= {ID = 1719},
	["COALESCING_VISIONS"]			= {ID = 1755},
	["ECHOES_OF_NYALOTHA"]			= {ID = 1803},
	-- Other
	["DARKMOON_PRIZE_TICKET"]		= {ID = 515},
}

-- CurrencyList for config
local list = {GOLD = BONUS_ROLL_REWARD_MONEY}
for currency, data in pairs(Currencies) do
	local name = GetCurrencyInfo(data.ID)
	if name then list[currency] = name end
end
DT.CurrencyList = list

local function OnClick()
	_G.ToggleCharacter("TokenFrame")
end

local function GetInfo(id)
	local name, num, icon = GetCurrencyInfo(id)
	return num, name, (icon and format(iconString, icon)) or '136012'
end

local function AddInfo(id)
	local num, name = GetInfo(id)
	DT.tooltip:AddDoubleLine(name, num, 1, 1, 1)
end

local goldText
local function OnEvent(self)
	goldText = E:FormatMoney(GetMoney(), E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins)

	local displayed = E.db.datatexts.currencies.displayedCurrency
	local selected = Currencies[displayed]
	if displayed == "GOLD" or selected == nil then
		self.text:SetText(goldText)
	else
		local style = E.db.datatexts.currencies.displayStyle
		local num, name, icon = GetInfo(selected.ID)
		if style == "ICON" then
			self.text:SetFormattedText("%s %d", icon, num)
		elseif style == "ICON_TEXT" then
			self.text:SetFormattedText("%s %s %d", icon, name, num)
		else --ICON_TEXT_ABBR
			self.text:SetFormattedText("%s %s %d", icon, E:AbbreviateString(name), num)
		end
	end
end

local faction = (E.myfaction == "Alliance" and 1717) or 1716
local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Gold"]..":", goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(EXPANSION_NAME7) --"BfA"
	AddInfo(1565) -- RICH_AZERITE_FRAGMENT
	AddInfo(1710) -- SEAFARERS_DUBLOON
	AddInfo(1580) -- SEAL_OF_WARTORN_FATE
	AddInfo(1560) -- WAR_RESOURCES
	AddInfo(1587) -- WAR_SUPPLIES
	AddInfo(faction) -- 7th Legion or Honorbound
	AddInfo(1718) -- TITAN_RESIDUUM
	AddInfo(1721) -- PRISMATIC_MANAPEARL
	AddInfo(1719) -- CORRUPTED_MEMENTOS
	AddInfo(1755) -- COALESCING_VISIONS
	AddInfo(1803) -- ECHOES_OF_NYALOTHA
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(OTHER)
	AddInfo(515) -- DARKMOON_PRIZE_TICKET

	-- If the "Display In Tooltip" box is checked (on by default), then also display custom currencies in the tooltip.
	local shouldAddHeader = true
	for _, info in pairs(E.global.datatexts.customCurrencies) do
		if info.DISPLAY_IN_MAIN_TOOLTIP then
			if shouldAddHeader then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(L["Custom Currency"])
				shouldAddHeader = false
			end

			AddInfo(info.ID)
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', nil, {"PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, _G.CURRENCY)
