local E, L, DF = unpack(select(2, ...)); --Engine
local M = E:GetModule('Misc');

function M:LoadMerchant()
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		local c = 0
		for b=0,4 do
			for s=1,GetContainerNumSlots(b) do
				local l = GetContainerItemLink(b, s)
				if l then
					local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))
					if select(3, GetItemInfo(l))==0 and p>0 then
						UseContainerItem(b, s)
						PickupMerchantItem()
						c = c+p
					end
				end
			end
		end
		local goldabbrev = "|cffffd700g|r"
		local silverabbrev = "|cffc7c7cfs|r"
		local copperabbrev = "|cffeda55fc|r"
		local merchant_repairnomoney = "You don't have enough money for repair!"
		local merchant_repaircost = "Your items have been repaired for"
		local merchant_trashsell = "Your vendor trash has been sold and you earned"
		if c>0 then
			local g, s, c = math.floor(c/10000) or 0, math.floor((c%10000)/100) or 0, c%100
			DEFAULT_CHAT_FRAME:AddMessage(merchant_trashsell.." |cffffffff"..g..goldabbrev.." |cffffffff"..s..silverabbrev.." |cffffffff"..c..copperabbrev..".",255,255,0)
		end
		if not IsShiftKeyDown() then
			if CanMerchantRepair() then
				guildRepairFlag = 0
				local cost, possible = GetRepairAllCost()
				-- additional checks for guild repairs
				if (IsInGuild()) and (CanGuildBankRepair()) then
					 if cost <= GetGuildBankWithdrawMoney() or GetGuildBankWithdrawMoney() == -1 then
						guildRepairFlag = 1
					 end
				end
				if cost>0 then
					if (possible or guildRepairFlag) then
						RepairAllItems(guildRepairFlag)
						local c = cost%100
						local s = math.floor((cost%10000)/100)
						local g = math.floor(cost/10000)
						DEFAULT_CHAT_FRAME:AddMessage(merchant_repaircost.." |cffffffff"..g..goldabbrev.." |cffffffff"..s..silverabbrev.." |cffffffff"..c..copperabbrev..".",255,255,0)
					else
						DEFAULT_CHAT_FRAME:AddMessage(merchant_repairnomoney,255,0,0)
					end
				end
			end
		end
	end)
	f:RegisterEvent("MERCHANT_SHOW")

	-- buy max number value with alt
	local savedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if ( IsAltKeyDown() ) then
			local itemLink = GetMerchantItemLink(self:GetID())
			if not itemLink then return end
			local maxStack = select(8, GetItemInfo(itemLink))
			if ( maxStack and maxStack > 1 ) then
				BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
			end
		end
		savedMerchantItemButton_OnModifiedClick(self, ...)
	end
end