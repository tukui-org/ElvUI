--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------

if TukuiCF["datatext"].gold and TukuiCF["datatext"].gold > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	TukuiDB.PP(TukuiCF["datatext"].gold, Text)

	local Profit	= 0
	local Spent		= 0
	local OldMoney	= 0
	local myPlayerRealm = GetCVar("realmName");

	local function formatMoney(money)
		local gold = floor(math.abs(money) / 10000)
		local silver = mod(floor(math.abs(money) / 100), 100)
		local copper = mod(floor(math.abs(money)), 100)
		if gold ~= 0 then
			return format("%s"..tukuilocal.goldabbrev.." %s"..tukuilocal.silverabbrev.." %s"..tukuilocal.copperabbrev, gold, silver, copper)
		elseif silver ~= 0 then
			return format("%s"..tukuilocal.silverabbrev.." %s"..tukuilocal.copperabbrev, silver, copper)
		else
			return format("%s"..tukuilocal.copperabbrev, copper)
		end
	end

	local function FormatTooltipMoney(money)
		local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
		local cash = ""
		cash = format("%.2d"..tukuilocal.goldabbrev.." %.2d"..tukuilocal.silverabbrev.." %.2d"..tukuilocal.copperabbrev, gold, silver, copper)		
		return cash
	end	

	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			OldMoney = GetMoney()
		end
		
		local NewMoney	= GetMoney()
		local Change = NewMoney-OldMoney -- Positive if we gain money
		
		if OldMoney>NewMoney then		-- Lost Money
			Spent = Spent - Change
		else							-- Gained Moeny
			Profit = Profit + Change
		end
		
		Text:SetText(formatMoney(NewMoney))
		-- Setup Money Tooltip
		self:SetAllPoints(Text)

		local myPlayerName  = UnitName("player");				
		if (TukuiData == nil) then TukuiData = {}; end
		if (TukuiData.gold == nil) then TukuiData.gold = {}; end
		if (TukuiData.gold[myPlayerRealm]==nil) then TukuiData.gold[myPlayerRealm]={}; end
		TukuiData.gold[myPlayerRealm][myPlayerName] = GetMoney();
				
		OldMoney = NewMoney
	end

	Stat:RegisterEvent("PLAYER_MONEY")
	Stat:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	Stat:RegisterEvent("SEND_MAIL_COD_CHANGED")
	Stat:RegisterEvent("PLAYER_TRADE_MONEY")
	Stat:RegisterEvent("TRADE_MONEY_CHANGED")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function() OpenAllBags() end)
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			self.hovered = true 
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, TukuiDB.Scale(6));
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.mult)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(tukuilocal.datatext_session)
			GameTooltip:AddDoubleLine(tukuilocal.datatext_earned, formatMoney(Profit), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(tukuilocal.datatext_spent, formatMoney(Spent), 1, 1, 1, 1, 1, 1)
			if Profit < Spent then
				GameTooltip:AddDoubleLine(tukuilocal.datatext_deficit, formatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
			elseif (Profit-Spent)>0 then
				GameTooltip:AddDoubleLine(tukuilocal.datatext_profit, formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
			end				
			GameTooltip:AddLine' '								
		
			local totalGold = 0				
			GameTooltip:AddLine(tukuilocal.datatext_character)			
			local thisRealmList = TukuiData.gold[myPlayerRealm];
			for k,v in pairs(thisRealmList) do
				GameTooltip:AddDoubleLine(k, FormatTooltipMoney(v), 1, 1, 1, 1, 1, 1)
				totalGold=totalGold+v;
			end 
			GameTooltip:AddLine' '
			GameTooltip:AddLine(tukuilocal.datatext_server)
			GameTooltip:AddDoubleLine(tukuilocal.datatext_totalgold, FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

			for i = 1, MAX_WATCHED_TOKENS do
				local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
				if name and i == 1 then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(CURRENCY)
				end
				local r, g, b = 1,1,1
				if itemID then r, g, b = GetItemQualityColor(select(3, GetItemInfo(itemID))) end
				if name and count then GameTooltip:AddDoubleLine(name, count, r, g, b, 1, 1, 1) end
			end
			GameTooltip:Show()
		end
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)	
	-- reset gold data
	local function RESETGOLD()
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		
		TukuiData.gold = {}
		TukuiData.gold[myPlayerRealm]={}
		TukuiData.gold[myPlayerRealm][myPlayerName] = GetMoney();
	end
	SLASH_RESETGOLD1 = "/resetgold"
	SlashCmdList["RESETGOLD"] = RESETGOLD
end