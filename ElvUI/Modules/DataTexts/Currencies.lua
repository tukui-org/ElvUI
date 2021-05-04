local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, tonumber, wipe = format, tonumber, wipe
local pairs, ipairs, unpack, tostring = pairs, ipairs, unpack, tostring
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetMoney = GetMoney

local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY

local iconString = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
DT.CurrencyList = { GOLD = BONUS_ROLL_REWARD_MONEY, BACKPACK = 'Backpack' }

local function OnClick()
	_G.ToggleCharacter('TokenFrame')
end

local function GetInfo(id)
	local info = C_CurrencyInfo_GetCurrencyInfo(id)
	if info then
		return info.name, info.quantity, info.maxQuantity, (info.iconFileID and format(iconString, info.iconFileID)) or '136012'
	end
end

local function AddInfo(id)
	local name, num, max, icon = GetInfo(id)
	if name then
		local textRight = '%s'
		if E.global.datatexts.settings.Currencies.maxCurrency and max and max > 0 then
			textRight = '%s / '..BreakUpLargeNumbers(max)
		end

		DT.tooltip:AddDoubleLine(format('%s %s', icon, name), format(textRight, BreakUpLargeNumbers(num)), 1, 1, 1, 1, 1, 1)
	end
end

local shownHeaders = {}
local function AddHeader(id, addLine)
	if (not E.global.datatexts.settings.Currencies.headers) or shownHeaders[id] then return end

	if addLine then
		DT.tooltip:AddLine(' ')
	end

	DT.tooltip:AddLine(E.global.datatexts.settings.Currencies.tooltipData[id][1])
	shownHeaders[id] = true
end

local goldText
local function OnEvent(self)
	goldText = E:FormatMoney(GetMoney(), E.global.datatexts.settings.Currencies.goldFormat or 'BLIZZARD', not E.global.datatexts.settings.Currencies.goldCoins)

	local displayed = E.global.datatexts.settings.Currencies.displayedCurrency
	if displayed == 'BACKPACK' then
		local displayString
		for i = 1, 3 do
			local info = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
			if info and info.quantity then
				displayString = (i > 1 and displayString..' ' or '')..format('%s %s', format(iconString, info.iconFileID), E:ShortValue(info.quantity))
			end
		end

		self.text:SetText(displayString or goldText)
	elseif displayed == 'GOLD' then
		self.text:SetText(goldText)
	else
		local id = tonumber(displayed)
		if not id then return end

		local name, num, _, icon = GetInfo(id)
		if not name then return end

		local style = E.global.datatexts.settings.Currencies.displayStyle
		if style == 'ICON' then
			self.text:SetFormattedText('%s %s', icon, E:ShortValue(num))
		elseif style == 'ICON_TEXT' then
			self.text:SetFormattedText('%s %s %s', icon, name, E:ShortValue(num))
		else --ICON_TEXT_ABBR
			self.text:SetFormattedText('%s %s %s', icon, E:AbbreviateString(name), E:ShortValue(num))
		end
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	wipe(shownHeaders)
	local addLine, addLine2
	for _, info in ipairs(E.global.datatexts.settings.Currencies.tooltipData) do
		local _, id, header = unpack(info)
		if id and E.global.datatexts.settings.Currencies.idEnable[id] then
			AddHeader(header, addLine)
			AddInfo(id)
			addLine = true
		end
	end

	if addLine then
		DT.tooltip:AddLine(' ')
	end

	for _, info in pairs(E.global.datatexts.customCurrencies) do
		if info and not DT.CurrencyList[tostring(info.ID)] and info.DISPLAY_IN_MAIN_TOOLTIP then
			AddInfo(info.ID)
			addLine2 = true
		end
	end

	if addLine2 then
		DT.tooltip:AddLine(' ')
	end

	DT.tooltip:AddDoubleLine(L["Gold"]..':', goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', nil, {'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, _G.CURRENCY)
