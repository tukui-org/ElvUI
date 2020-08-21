local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local type = type
local format, pairs, tonumber = format, pairs, tonumber
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetMoney = GetMoney
local GetServerExpansionLevel = GetServerExpansionLevel

local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local LE_EXPANSION_SHADOWLANDS = LE_EXPANSION_SHADOWLANDS
local EXPANSION_NAME7 = EXPANSION_NAME7
local EXPANSION_NAME8 = EXPANSION_NAME8
local OTHER = OTHER

local iconString = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
DT.CurrencyList = { GOLD = BONUS_ROLL_REWARD_MONEY, BACKPACK = 'Backpack' }

local function OnClick()
	_G.ToggleCharacter('TokenFrame')
end

local function GetInfo(id)
	local info = C_CurrencyInfo_GetCurrencyInfo(id)
	if info then
		return info.name, info.quantity, (info.iconFileID and format(iconString, info.iconFileID)) or '136012'
	else
		return '', '', '136012'
	end
end

local function AddInfo(id)
	local name, num, icon = GetInfo(id)
	if name then
		DT.tooltip:AddDoubleLine(format('%s %s', icon, name), BreakUpLargeNumbers(num), 1, 1, 1, 1, 1, 1)
	end
end

local goldText
local function OnEvent(self)
	goldText = E:FormatMoney(GetMoney(), E.db.datatexts.goldFormat or 'BLIZZARD', not E.db.datatexts.goldCoins)

	local displayed = E.db.datatexts.currencies.displayedCurrency
	if displayed == 'BACKPACK' then
		local displayString = ''
		for i = 1, 3 do
			local info = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
			if info and info.quantity then
				displayString = (i > 1 and displayString..' ' or displayString)..format('%s %s', format(iconString, info.iconFileID), E:ShortValue(info.quantity))
			end
		end

		self.text:SetText(displayString == '' and goldText or displayString)
	elseif displayed == 'GOLD' then
		self.text:SetText(goldText)
	else
		local id = tonumber(displayed)
		if not id then return end

		local name, num, icon = GetInfo(id)
		if not name then return end

		local style = E.db.datatexts.currencies.displayStyle
		if style == 'ICON' then
			self.text:SetFormattedText('%s %s', icon, E:ShortValue(num))
		elseif style == 'ICON_TEXT' then
			self.text:SetFormattedText('%s %s %s', icon, name, E:ShortValue(num))
		else --ICON_TEXT_ABBR
			self.text:SetFormattedText('%s %s %s', icon, E:AbbreviateString(name), E:ShortValue(num))
		end
	end
end

local faction = (E.myfaction == 'Alliance' and 1717) or 1716
local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddDoubleLine(L["Gold"]..':', goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(' ')

	if GetServerExpansionLevel() < LE_EXPANSION_SHADOWLANDS then
		DT.tooltip:AddLine(EXPANSION_NAME7) -- BfA
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
	else
		DT.tooltip:AddLine(EXPANSION_NAME8) -- Shadowlands
		AddInfo(1751) -- Freed Soul
		AddInfo(1822) -- Renown
		AddInfo(1813) -- Reservoir Anima
		AddInfo(1810) -- Willing Soul
		AddInfo(1828) -- Soul Ash
		AddInfo(1820) -- Infused Ruby
		DT.tooltip:AddLine(' ')
	end

	DT.tooltip:AddLine(OTHER)
	AddInfo(515) -- DARKMOON_PRIZE_TICKET

	-- If the 'Display In Tooltip' box is checked (on by default), then also display custom currencies in the tooltip.
	local shouldAddHeader = true
	for _, info in pairs(E.global.datatexts.customCurrencies) do
		if info.DISPLAY_IN_MAIN_TOOLTIP then
			if shouldAddHeader then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(L["Custom Currency"])
				shouldAddHeader = false
			end

			local id = info.ID
			if id and type(id) == 'number' then
				AddInfo(id)
			end
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', nil, {'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, _G.CURRENCY)
