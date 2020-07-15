local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, pairs, tonumber = format, pairs, tonumber
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney

local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY

local iconString = "|T%s:16:16:0:0:64:64:4:60:4:60|t"
DT.CurrencyList = { GOLD = BONUS_ROLL_REWARD_MONEY, BACKPACK = 'Backpack' }

local function OnClick()
	_G.ToggleCharacter("TokenFrame")
end

local function GetInfo(id)
	if type(id) ~= 'number' then return end
	local name, num, icon = GetCurrencyInfo(id)
	return num, name, (icon and format(iconString, icon)) or '136012'
end

local function AddInfo(id)
	local num, name, icon = GetInfo(id)
	if not name then return end
	DT.tooltip:AddDoubleLine(format('%s %s', icon, name), BreakUpLargeNumbers(num), 1, 1, 1, 1, 1, 1)
end

local goldText
local function OnEvent(self)
	goldText = E:FormatMoney(GetMoney(), E.global.datatexts.settings.Currencies.goldFormat or "BLIZZARD", not E.global.datatexts.settings.Currencies.goldCoins)

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

local function OnEnter(self)
	DT:SetupTooltip(self)

	local addLine, goldSpace
	for _, info in ipairs(E.db.datatexts.currencies.tooltip) do
		local name, currencyID, _, enabled = unpack(info)
		if currencyID and enabled then
			AddInfo(currencyID)
			goldSpace = true
		elseif enabled then
			if addLine then
				DT.tooltip:AddLine(' ')
			else
				addLine = true
			end
			DT.tooltip:AddLine(name)
			goldSpace = true
		end
	end

	if goldSpace then
		DT.tooltip:AddLine(' ')
	end
	DT.tooltip:AddDoubleLine(L["Gold"]..":", goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', nil, {"PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, _G.CURRENCY)
