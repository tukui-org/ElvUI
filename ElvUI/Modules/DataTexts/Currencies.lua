local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, pairs, wipe = format, pairs, wipe
local tonumber, tostring = tonumber, tostring
local GetMoney = GetMoney
local BreakUpLargeNumbers = BreakUpLargeNumbers

local GetCurrencyInfo = GetCurrencyInfo
local GetCurrencyListInfo = GetCurrencyListInfo
local GetCurrencyListSize = GetCurrencyListSize
local GetCurrencyListLink = GetCurrencyListLink
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink
local ExpandCurrencyList = ExpandCurrencyList
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local EXPANSION_NAME7 = EXPANSION_NAME7
local OTHER = OTHER

local iconString = "|T%s:16:16:0:0:64:64:4:60:4:60|t"
local CURRENCY_CACHE, Collapsed = {}, {}

DT.CurrencyList = { GOLD = BONUS_ROLL_REWARD_MONEY, BACKPACK = 'Backpack' }

local function OnClick()
	_G.ToggleCharacter("TokenFrame")
end

local function GetInfo(id)
	local name, num, icon = GetCurrencyInfo(id)
	return num, name, (icon and format(iconString, icon)) or '136012'
end

local function AddInfo(id)
	local num, name, icon = GetInfo(id)
	DT.tooltip:AddDoubleLine(format('%s %s', icon, name), BreakUpLargeNumbers(num), 1, 1, 1, 1, 1, 1)
end

local goldText
local function OnEvent(self, event, ...)
	if event == 'CURRENCY_DISPLAY_UPDATE' then
		local currencyType = ...
		if currencyType and not DT.CurrencyList[tostring(currencyType)] then
			DT.CurrencyList[tostring(currencyType)] = GetCurrencyInfo(currencyType)
		end
	end

	if not next(CURRENCY_CACHE) then
		local listSize, i = GetCurrencyListSize(), 1

		while listSize >= i do
			local name, isHeader, isExpanded = GetCurrencyListInfo(i)
			if isHeader and not isExpanded then
				ExpandCurrencyList(i, 1);
				listSize = GetCurrencyListSize()
				Collapsed[name] = true
			end
			if not isHeader then
				local currencyLink = GetCurrencyListLink(i)
				local currencyID = currencyLink and C_CurrencyInfo_GetCurrencyIDFromLink(currencyLink)
				if currencyID then
					DT.CurrencyList[tostring(currencyID)] = name
				end
			end
			i = i + 1
		end

		for k = 1, listSize do
			local name, isHeader, isExpanded = GetCurrencyListInfo(k)
			if isHeader and isExpanded and Collapsed[name] then
				ExpandCurrencyList(k, 0);
			end
		end

		wipe(Collapsed)
	end

	goldText = E:FormatMoney(GetMoney(), E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins)

	local displayed = E.db.datatexts.currencies.displayedCurrency
	if displayed == 'BACKPACK' then
		local displayString = ''
		for i = 1, 3 do
			local _, num, icon = GetBackpackCurrencyInfo(i);
			if num then
				displayString = (i > 1 and displayString..' ' or displayString)..format("%s %s", format(iconString, icon), E:ShortValue(num))
			end
		end

		self.text:SetText(displayString == '' and goldText or displayString)
	elseif displayed == "GOLD" then
		self.text:SetText(goldText)
	else
		local style = E.db.datatexts.currencies.displayStyle
		local num, name, icon = GetInfo(tonumber(displayed))
		if style == "ICON" then
			self.text:SetFormattedText("%s %s", icon, E:ShortValue(num))
		elseif style == "ICON_TEXT" then
			self.text:SetFormattedText("%s %s %s", icon, name, E:ShortValue(num))
		else --ICON_TEXT_ABBR
			self.text:SetFormattedText("%s %s %s", icon, E:AbbreviateString(name), E:ShortValue(num))
		end
	end
end

local faction = (E.myfaction == "Alliance" and 1717) or 1716
local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Gold"]..":", goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(EXPANSION_NAME7) --"BfA"
	AddInfo(1710) -- SEAFARERS_DUBLOON
	AddInfo(1580) -- SEAL_OF_WARTORN_FATE
	AddInfo(1560) -- WAR_RESOURCES
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

DT:RegisterDatatext('Currencies', nil, {"PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE", "GLOBAL_MOUSE_UP"}, OnEvent, nil, OnClick, OnEnter, nil, _G.CURRENCY)
