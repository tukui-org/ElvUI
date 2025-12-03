local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local pairs, strjoin = pairs, strjoin

local HONOR_CURRENCY = Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID

local defaults = {
	showIcon = true,
	nameStyle = 'full',
	showMax = true,
	currencyTooltip = true
}

local function OnEvent(panel)
	local info = DT:CurrencyInfo(panel.name)
	local currency = E.global.datatexts.customCurrencies[panel.name]
	if info and currency then
		local displayString

		if currency.nameStyle ~= 'none' then
			displayString = strjoin(': ', (currency.nameStyle == 'full' and currency.name) or E:AbbreviateString(currency.name), '%d')
		end

		if currency.showMax and (info.maxQuantity and info.maxQuantity > 0) then
			displayString = strjoin(' ', displayString or '%d', '/', info.maxQuantity)
		end

		panel.text:SetFormattedText(displayString or '%d', info.quantity)
		panel.icon:SetShown(currency.showIcon)
		panel.icon:SetTexture(info.iconFileID)

		if (E.Wrath or E.Mists) and panel.name == HONOR_CURRENCY then
			panel.icon:SetTexCoord(0.06325, 0.59375, 0.03125, 0.57375)
		end
	end
end

local function OnEnter(panel)
	DT.tooltip:ClearLines()

	if E.Retail then
		DT.tooltip:SetCurrencyByID(panel.name)
	else
		DT.tooltip:SetCurrencyTokenByID(panel.name)
	end

	DT.tooltip:Show()
end

local currencyEvents = { 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE', 'PERKS_PROGRAM_CURRENCY_REFRESH' }
local function RegisterDT(currencyID, name, update)
	local data = DT:RegisterDatatext(currencyID, _G.CURRENCY, currencyEvents, OnEvent, nil, nil, OnEnter, nil, name)
	data.isCurrency = true

	if update then
		DT:UpdateQuickDT()
	end

	return data
end

function DT:RegisterCustomCurrencyDT(currencyID)
	if currencyID then
		if E.global.datatexts.customCurrencies[currencyID] then return end

		local info, name = DT:CurrencyInfo(currencyID)
		if not name then return end

		G.datatexts.customCurrencies[currencyID] = defaults
		E.global.datatexts.customCurrencies[currencyID] = E:CopyTable({ name = info.name }, defaults)

		return RegisterDT(currencyID, info.name, true)
	else --We called this in DT:Initialize, so load all the stored currency datatexts
		for id, info in pairs(E.global.datatexts.customCurrencies) do
			G.datatexts.customCurrencies[id] = defaults
			info = E:CopyTable(info, defaults, true)

			RegisterDT(id, info.name)
		end
	end
end

function DT:RemoveCustomCurrency(currencyID)
	DT.RegisteredDataTexts[currencyID] = nil
	DT.DataTextList[currencyID] = nil

	DT:UpdateQuickDT()
	DT:LoadDataTexts()
end
