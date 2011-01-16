local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------

if ElvCF["datatext"].gold and ElvCF["datatext"].gold > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
		Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].gold, Text)

	local Profit	= 0
	local Spent		= 0
	local OldMoney	= 0

	local function formatMoney(money)
		local gold = floor(math.abs(money) / 10000)
		local silver = mod(floor(math.abs(money) / 100), 100)
		local copper = mod(floor(math.abs(money)), 100)
		if gold ~= 0 then
			return format("%s"..ElvL.goldabbrev.." %s"..ElvL.silverabbrev.." %s"..ElvL.copperabbrev, gold, silver, copper)
		elseif silver ~= 0 then
			return format("%s"..ElvL.silverabbrev.." %s"..ElvL.copperabbrev, silver, copper)
		else
			return format("%s"..ElvL.copperabbrev, copper)
		end
	end

	local function FormatTooltipMoney(money)
		local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
		local cash = ""
		cash = format("%d"..ElvL.goldabbrev.." %d"..ElvL.silverabbrev.." %d"..ElvL.copperabbrev, gold, silver, copper)		
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

		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");				
		if (ElvuiData == nil) then ElvuiData = {}; end
		if (ElvuiData.gold == nil) then ElvuiData.gold = {}; end
		if (ElvuiData.gold[myPlayerRealm]==nil) then ElvuiData.gold[myPlayerRealm]={}; end
		ElvuiData.gold[myPlayerRealm][myPlayerName] = GetMoney();
		
		self:SetScript("OnEnter", function()
			if not InCombatLockdown() then
				self.hovered = true 
				GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, ElvDB.Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, ElvDB.mult)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(ElvL.datatext_session)
				GameTooltip:AddDoubleLine(ElvL.datatext_earned, formatMoney(Profit), 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(ElvL.datatext_spent, formatMoney(Spent), 1, 1, 1, 1, 1, 1)
				if Profit < Spent then
					GameTooltip:AddDoubleLine(ElvL.datatext_deficit, formatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
				elseif (Profit-Spent)>0 then
					GameTooltip:AddDoubleLine(ElvL.datatext_profit, formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
				end				
				GameTooltip:AddLine' '								
			
				local totalGold = 0				
				GameTooltip:AddLine(ElvL.datatext_character)			
				local thisRealmList = ElvuiData.gold[myPlayerRealm];
				for k,v in pairs(thisRealmList) do
					GameTooltip:AddDoubleLine(k, FormatTooltipMoney(v), 1, 1, 1, 1, 1, 1)
					totalGold=totalGold+v;
				end 
				GameTooltip:AddLine' '
				GameTooltip:AddLine(ElvL.datatext_server)
				GameTooltip:AddDoubleLine(ElvL.datatext_totalgold, FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

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
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
		
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
	
	-- reset gold data
	local function RESETGOLD()
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		
		ElvuiData.gold = {}
		ElvuiData.gold[myPlayerRealm]={}
		ElvuiData.gold[myPlayerRealm][myPlayerName] = GetMoney();
	end
	SLASH_RESETGOLD1 = "/resetgold"
	SlashCmdList["RESETGOLD"] = RESETGOLD
end