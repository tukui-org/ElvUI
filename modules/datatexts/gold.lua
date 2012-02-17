local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local defaultColor = { 1, 1, 1 }
local Profit	= 0
local Spent		= 0

local function formatMoney(money)
	local gold = floor(math.abs(money) / 10000)
	local silver = mod(floor(math.abs(money) / 100), 100)
	local copper = mod(floor(math.abs(money)), 100)
	if gold ~= 0 then
		return format("%s"..L.goldabbrev.." %s"..L.silverabbrev.." %s"..L.copperabbrev, gold, silver, copper)
	elseif silver ~= 0 then
		return format("%s"..L.silverabbrev.." %s"..L.copperabbrev, silver, copper)
	else
		return format("%s"..L.copperabbrev, copper)
	end
end

local function FormatTooltipMoney(money)
	if not money then return end
	local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
	local cash = ""
	cash = format("%d"..L.goldabbrev.." %d"..L.silverabbrev.." %d"..L.copperabbrev, gold, silver, copper)		
	return cash
end

local function OnEvent(self, event, ...)
	if not IsLoggedIn() then return end
	local NewMoney = GetMoney()
	if (ElvData == nil) then ElvData = {}; end
	if (ElvData['gold'] == nil) then ElvData['gold'] = {}; end
	if (ElvData['gold'][E.myrealm] == nil) then ElvData['gold'][E.myrealm] = {} end
	if (ElvData['gold'][E.myrealm][E.myname] == nil) then ElvData['gold'][E.myrealm][E.myname] = NewMoney end
	
	local OldMoney = ElvData['gold'][E.myrealm][E.myname] or NewMoney
	
	local Change = NewMoney-OldMoney -- Positive if we gain money
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end
	
	self.text:SetText(formatMoney(NewMoney))

	ElvData['gold'][E.myrealm][E.myname] = NewMoney
end

local function Click()
	ToggleAllBags()
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	GameTooltip:AddLine(L['Session:'])
	GameTooltip:AddDoubleLine(L["Earned:"], formatMoney(Profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Spent:"], formatMoney(Spent), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		GameTooltip:AddDoubleLine(L["Deficit:"], formatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		GameTooltip:AddDoubleLine(L["Profit:"	], formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
	end				
	GameTooltip:AddLine' '								

	local totalGold = 0				
	GameTooltip:AddLine(L["Character: "])			

	for k,_ in pairs(ElvData['gold'][E.myrealm]) do
		if ElvData['gold'][E.myrealm][k] then 
			GameTooltip:AddDoubleLine(k, FormatTooltipMoney(ElvData['gold'][E.myrealm][k]), 1, 1, 1, 1, 1, 1)
			totalGold=totalGold+ElvData['gold'][E.myrealm][k]
		end
	end
	
	GameTooltip:AddLine' '
	GameTooltip:AddLine(L["Server: "])
	GameTooltip:AddDoubleLine(L["Total: "], FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY)
		end
		if name and count then GameTooltip:AddDoubleLine(name, count, 1, 1, 1) end
	end	
	
	GameTooltip:Show()
end

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('Gold', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED'}, OnEvent, nil, Click, OnEnter)

