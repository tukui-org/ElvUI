local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local B = E:GetModule('Bags')
-- GLOBALS: ElvDB

local type, wipe, pairs, ipairs, sort = type, wipe, pairs, ipairs, sort
local format, strjoin, tinsert = format, strjoin, tinsert

local _G = _G
local GetMoney = GetMoney
local IsLoggedIn = IsLoggedIn
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local BreakUpLargeNumbers = BreakUpLargeNumbers
local C_WowTokenPublic_UpdateMarketPrice = C_WowTokenPublic.UpdateMarketPrice
local C_WowTokenPublic_GetCurrentMarketPrice = C_WowTokenPublic.GetCurrentMarketPrice
local C_Timer_NewTicker = C_Timer.NewTicker

local FetchDepositedMoney = C_Bank and C_Bank.FetchDepositedMoney
local WARBANDBANK_TYPE = (Enum.BankType and Enum.BankType.Account) or 2

local Profit, Spent, Ticker = 0, 0
local resetCountersFormatter = strjoin('', '|cffaaaaaa', L["Reset Session Data: Hold Ctrl + Right Click"], '|r')
local resetInfoFormatter = strjoin('', '|cffaaaaaa', L["Reset Character Data: Hold Shift + Right Click"], '|r')

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local CURRENCY = CURRENCY

local menuList, myGold = {}, {}
local warbandGold, totalGold, totalHorde, totalAlliance = 0, 0, 0, 0
local iconStringName = '|T%s:16:16:0:0:64:64:4:60:4:60|t %s'
local db

local function SortFunction(a, b)
	return a.amount > b.amount
end

local function DeleteCharacter(_, realm, name)
	ElvDB.gold[realm][name] = nil
	ElvDB.class[realm][name] = nil
	ElvDB.faction[realm][name] = nil

	DT:ForceUpdate_DataText('Gold')
end

local function UpdateTotal(faction, change)
	if faction == 'Alliance' then
		totalAlliance = totalAlliance + change
	elseif faction == 'Horde' then
		totalHorde = totalHorde + change
	end

	totalGold = totalGold + change
end

local function DisplayCurrencyInfo()
	local index = 1
	local info, name = DT:BackpackCurrencyInfo(index)

	while name do
		if index == 1 then
			DT.tooltip:AddLine(' ')
			DT.tooltip:AddLine(CURRENCY)
		end

		if info.quantity then
			DT.tooltip:AddDoubleLine(format(iconStringName, info.iconFileID, name), BreakUpLargeNumbers(info.quantity), 1, 1, 1, 1, 1, 1)
		end

		index = index + 1
		info, name = DT:BackpackCurrencyInfo(index)
	end
end

local function UpdateGold(self, updateAll, goldChange)
	local textOnly = not db.goldCoins and true or false
	local style = db.goldFormat or 'BLIZZARD'

	if updateAll then
		wipe(myGold)
		wipe(menuList)

		totalGold, totalHorde, totalAlliance = 0, 0, 0

		tinsert(menuList, { text = '', isTitle = true, notCheckable = true })
		tinsert(menuList, { text = 'Delete Character', isTitle = true, notCheckable = true })

		local realmN = 1
		for realm in pairs(ElvDB.serverID[E.serverID]) do
			tinsert(menuList, realmN, { text = 'Delete All - '..realm, notCheckable = true, func = function() wipe(ElvDB.gold[realm]) DT:ForceUpdate_DataText('Gold') end })
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
						func = function() DeleteCharacter(self, realm, name) end
					})

					UpdateTotal(faction, gold)
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
			UpdateTotal(E.myfaction, goldChange)
		end
	end
end

local function UpdateWarbandGold()
	warbandGold = FetchDepositedMoney(WARBANDBANK_TYPE)
end

local function UpdateMarketPrice()
	return C_WowTokenPublic_UpdateMarketPrice()
end

local function OnEvent(self, event)
	if not IsLoggedIn() then return end

	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	if E.Retail then
		UpdateWarbandGold()
	end

	if (E.Retail or E.Mists) and not Ticker then
		C_WowTokenPublic_UpdateMarketPrice()
		Ticker = C_Timer_NewTicker(60, UpdateMarketPrice)
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

	UpdateGold(self, event == 'ELVUI_FORCE_UPDATE', Change)

	self.text:SetText(E:FormatMoney(NewMoney, db.goldFormat or 'BLIZZARD', not db.goldCoins))
end

local function Click(self, btn)
	if btn == 'RightButton' then
		if IsShiftKeyDown() then
			E:SetEasyMenuAnchor(E.EasyMenu, self)
			E:ComplicatedMenu(menuList, E.EasyMenu, nil, nil, nil, 'MENU')
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

	local textOnly = not db.goldCoins and true or false
	local style = db.goldFormat or 'BLIZZARD'

	DT.tooltip:AddLine(L["Session:"])
	DT.tooltip:AddDoubleLine(L["Earned:"], E:FormatMoney(Profit, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], E:FormatMoney(Spent, style, textOnly), 1, 1, 1, 1, 1, 1)

	if Spent ~= 0 then
		local gained = Profit > Spent
		DT.tooltip:AddDoubleLine(gained and L["Profit:"] or L["Deficit:"], E:FormatMoney(Profit-Spent, style, textOnly), gained and 0 or 1, gained and 1 or 0, 0, 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["Character: "])

	sort(myGold, SortFunction)

	local total, limit = #myGold, db.maxLimit
	local useLimit = limit and limit > 0
	for i, g in ipairs(myGold) do
		if useLimit and i > limit then
			local count = total - limit
			if count > 1 then
				DT.tooltip:AddLine(format('+%d %s', count, L["Hidden Characters"]), 0.75, 0.9, 1)
			end

			break
		end

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
		DT.tooltip:AddDoubleLine(L["Warband:"], E:FormatMoney(warbandGold or 0, style, textOnly), 1, 1, 1, 1, 1, 1)
	end

	if E.Retail or E.Mists then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["WoW Token:"], E:FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0, style, textOnly), 0, .8, 1, 1, 1, 1)

		DisplayCurrencyInfo()
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

DT:RegisterDatatext('Gold', nil, {E.Retail and 'ACCOUNT_MONEY' or nil, 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CURRENCY_DISPLAY_UPDATE', 'PERKS_PROGRAM_CURRENCY_REFRESH'}, OnEvent, nil, Click, OnEnter, nil, L["Gold"])
