local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local B = E:GetModule('Bags')

local _G = _G
local type, wipe, pairs, ipairs, sort = type, wipe, pairs, ipairs, sort
local format, strjoin, tinsert = format, strjoin, tinsert

local GetMoney = GetMoney
local IsControlKeyDown = IsControlKeyDown
local IsLoggedIn = IsLoggedIn
local IsShiftKeyDown = IsShiftKeyDown
local BreakUpLargeNumbers = BreakUpLargeNumbers
local C_WowTokenPublic_UpdateMarketPrice = C_WowTokenPublic.UpdateMarketPrice
local C_WowTokenPublic_GetCurrentMarketPrice = C_WowTokenPublic.GetCurrentMarketPrice
local C_Timer_NewTicker = C_Timer.NewTicker
-- GLOBALS: ElvDB

local Profit, Spent, Ticker = 0, 0
local resetCountersFormatter = strjoin('', '|cffaaaaaa', L["Reset Session Data: Hold Ctrl + Right Click"], '|r')
local resetInfoFormatter = strjoin('', '|cffaaaaaa', L["Reset Character Data: Hold Shift + Right Click"], '|r')

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local CURRENCY = CURRENCY

--Retail
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo

--Wrath
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo

local menuList, myGold = {}, {}
local totalGold, totalHorde, totalAlliance = 0, 0, 0
local iconString = '|T%s:16:16:0:0:64:64:4:60:4:60|t'

local function sortFunction(a, b)
	return a.amount > b.amount
end

local function deleteCharacter(self, realm, name)
	ElvDB.gold[realm][name] = nil
	ElvDB.class[realm][name] = nil
	ElvDB.faction[realm][name] = nil

	DT:ForceUpdate_DataText('Gold')
end

local function updateTotal(faction, change)
	if faction == 'Alliance' then
		totalAlliance = totalAlliance + change
	elseif faction == 'Horde' then
		totalHorde = totalHorde + change
	end

	totalGold = totalGold + change
end

local function updateGold(self, updateAll, goldChange)
	local textOnly = not E.global.datatexts.settings.Gold.goldCoins and true or false
	local style = E.global.datatexts.settings.Gold.goldFormat or 'BLIZZARD'

	if updateAll then
		wipe(myGold)
		wipe(menuList)

		totalGold, totalHorde, totalAlliance = 0, 0, 0

		tinsert(menuList, { text = '', isTitle = true, notCheckable = true })
		tinsert(menuList, { text = 'Delete Character', isTitle = true, notCheckable = true })

		local realmN = 1
		for realm in pairs(ElvDB.serverID[E.serverID]) do
			tinsert(menuList, realmN, { text = 'Delete All - '..realm, notCheckable = true, func = function() ElvDB.gold[realm] = {} DT:ForceUpdate_DataText('Gold') end })
			realmN = realmN + 1
			for name in pairs(ElvDB.gold[realm]) do
				local faction = ElvDB.faction[realm][name]
				local gold = ElvDB.gold[realm][name]

				if gold then
					local color = E:ClassColor(ElvDB.class[realm][name]) or PRIEST_COLOR

					tinsert(myGold, {
							name = name,
							realm = realm,
							amount = gold,
							amountText = E:FormatMoney(gold, style, textOnly),
							faction = faction or '',
							r = color.r, g = color.g, b = color.b,
					})

					tinsert(menuList, {
						text = format('%s - %s', name, realm),
						notCheckable = true,
						func = function() deleteCharacter(self, realm, name) end
					})

					updateTotal(faction, gold)
				end
			end
		end
	else
		for _, info in ipairs(myGold) do
			if info.name == E.myname and info.realm == E.myrealm then
				info.amount = ElvDB.gold[E.myrealm][E.myname]
				info.amountText = E:FormatMoney(ElvDB.gold[E.myrealm][E.myname], style, textOnly)

				break
			end
		end

		if goldChange then
			updateTotal(E.myfaction, goldChange)
		end
	end
end

local function OnEvent(self, event)
	if not IsLoggedIn() then return end

	if E.Retail and not Ticker then
		C_WowTokenPublic_UpdateMarketPrice()
		Ticker = C_Timer_NewTicker(60, C_WowTokenPublic_UpdateMarketPrice)
	end

	if event == 'ELVUI_FORCE_UPDATE' then
		ElvDB = ElvDB or {}

		ElvDB.gold = ElvDB.gold or {}
		ElvDB.gold[E.myrealm] = ElvDB.gold[E.myrealm] or {}

		ElvDB.class = ElvDB.class or {}
		ElvDB.class[E.myrealm] = ElvDB.class[E.myrealm] or {}
		ElvDB.class[E.myrealm][E.myname] = E.myclass

		ElvDB.faction = ElvDB.faction or {}
		ElvDB.faction[E.myrealm] = ElvDB.faction[E.myrealm] or {}
		ElvDB.faction[E.myrealm][E.myname] = E.myfaction

		ElvDB.serverID = ElvDB.serverID or {}
		ElvDB.serverID[E.serverID] = ElvDB.serverID[E.serverID] or {}
		ElvDB.serverID[E.serverID][E.myrealm] = true
	end

	--prevent an error possibly from really old profiles
	local oldMoney = ElvDB.gold[E.myrealm][E.myname]
	if oldMoney and type(oldMoney) ~= 'number' then
		ElvDB.gold[E.myrealm][E.myname] = nil
		oldMoney = nil
	end

	local NewMoney = GetMoney()
	ElvDB.gold[E.myrealm][E.myname] = NewMoney

	local OldMoney = oldMoney or NewMoney
	local Change = NewMoney-OldMoney -- Positive if we gain money
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end

	updateGold(self, event == 'ELVUI_FORCE_UPDATE', Change)

	self.text:SetText(E:FormatMoney(NewMoney, E.global.datatexts.settings.Gold.goldFormat or 'BLIZZARD', not E.global.datatexts.settings.Gold.goldCoins))
end

local function Click(self, btn)
	if btn == 'RightButton' then
		if IsShiftKeyDown() then
			DT:SetEasyMenuAnchor(DT.EasyMenu, self)
			_G.EasyMenu(menuList, DT.EasyMenu, nil, nil, nil, 'MENU')
		elseif IsControlKeyDown() then
			Profit = 0
			Spent = 0
		end
	else
		_G.ToggleAllBags()
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local textOnly = not E.global.datatexts.settings.Gold.goldCoins and true or false
	local style = E.global.datatexts.settings.Gold.goldFormat or 'BLIZZARD'

	DT.tooltip:AddLine(L["Session:"])

	DT.tooltip:AddDoubleLine(L["Earned:"], E:FormatMoney(Profit, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], E:FormatMoney(Spent, style, textOnly), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		DT.tooltip:AddDoubleLine(L["Deficit:"], E:FormatMoney(Profit-Spent, style, textOnly), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		DT.tooltip:AddDoubleLine(L["Profit:"], E:FormatMoney(Profit-Spent, style, textOnly), 0, 1, 0, 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["Character: "])

	sort(myGold, sortFunction)

	for _, g in ipairs(myGold) do
		local nameLine = ''
		if g.faction ~= '' and g.faction ~= 'Neutral' then
			nameLine = format([[|TInterface\FriendsFrame\PlusManz-%s:14|t ]], g.faction)
		end

		local toonName = format('%s%s%s', nameLine, g.name, (g.realm and g.realm ~= E.myrealm and ' - '..g.realm) or '')
		DT.tooltip:AddDoubleLine((g.name == E.myname and toonName..[[ |TInterface\COMMON\Indicator-Green:14|t]]) or toonName, g.amountText, g.r, g.g, g.b, 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["Server: "])
	if totalAlliance > 0 and totalHorde > 0 then
		if totalAlliance ~= 0 then DT.tooltip:AddDoubleLine(L["Alliance: "], E:FormatMoney(totalAlliance, style, textOnly), 0, .376, 1, 1, 1, 1) end
		if totalHorde ~= 0 then DT.tooltip:AddDoubleLine(L["Horde: "], E:FormatMoney(totalHorde, style, textOnly), 1, .2, .2, 1, 1, 1) end
		DT.tooltip:AddLine(' ')
	end
	DT.tooltip:AddDoubleLine(L["Total: "], E:FormatMoney(totalGold, style, textOnly), 1, 1, 1, 1, 1, 1)

	if E.Retail then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["WoW Token:"], E:FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0, style, textOnly), 0, .8, 1, 1, 1, 1)
	end

	if E.Retail or E.Wrath then
		for i = 1, _G.MAX_WATCHED_TOKENS do
			local info = E.Retail and C_CurrencyInfo_GetBackpackCurrencyInfo(i) or E.Wrath and {}
			if E.Wrath then info.name, info.quantity, info.iconFileID, info.currencyTypesID = GetBackpackCurrencyInfo(i) end
			if not (info and info.name) then break end

			if i == 1 then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(CURRENCY)
			end
			if info.quantity then
				DT.tooltip:AddDoubleLine(format('%s %s', format(iconString, info.iconFileID), info.name), BreakUpLargeNumbers(info.quantity), 1, 1, 1, 1, 1, 1)
			end
		end
	end

	local grayValue = B:GetGraysValue()
	if grayValue > 0 then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["Grays"], E:FormatMoney(grayValue, style, textOnly), nil, nil, nil, 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(resetCountersFormatter)
	DT.tooltip:AddLine(resetInfoFormatter)
	DT.tooltip:Show()
end

DT:RegisterDatatext('Gold', nil, {'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED'}, OnEvent, nil, Click, OnEnter, nil, L["Gold"])
