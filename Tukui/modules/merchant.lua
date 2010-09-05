local db = TukuiCF["merchant"]

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	if db.sellgrays then
		local c = 0
		for b=0,4 do
			for s=1,GetContainerNumSlots(b) do
				local l = GetContainerItemLink(b, s)
				if l then
					local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))
					if select(3, GetItemInfo(l))==0 then
						UseContainerItem(b, s)
						PickupMerchantItem()
						c = c+p
					end
				end
			end
		end
		if c>0 then
			local g, s, c = math.floor(c/10000) or 0, math.floor((c%10000)/100) or 0, c%100
			DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.merchant_trashsell.." |cffffffff"..g..tukuilocal.goldabbrev.." |cffffffff"..s..tukuilocal.silverabbrev.." |cffffffff"..c..tukuilocal.copperabbrev..".",255,255,0)
		end
	end
	if not IsShiftKeyDown() then
		if CanMerchantRepair() and db.autorepair then
			cost, possible = GetRepairAllCost()
			if cost>0 then
				if possible then
					RepairAllItems()
					local c = cost%100
					local s = math.floor((cost%10000)/100)
					local g = math.floor(cost/10000)
					DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.merchant_repaircost.." |cffffffff"..g..tukuilocal.goldabbrev.." |cffffffff"..s..tukuilocal.silverabbrev.." |cffffffff"..c..tukuilocal.copperabbrev..".",255,255,0)
				else
					DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.merchant_repairnomoney,255,0,0)
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
		local maxStack = select(8, GetItemInfo(GetMerchantItemLink(this:GetID())))
		local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(this:GetID())
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(this:GetID(), floor(maxStack / quantity))
		end
	end
	savedMerchantItemButton_OnModifiedClick(self, ...)
end