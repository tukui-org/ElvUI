local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
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

		if c>0 then
			local g, s, c = math.floor(c/10000) or 0, math.floor((c%10000)/100) or 0, c%100
			E:Print(L['Vendored gray items for:'].." |cffffffff"..g..L.goldabbrev.." |cffffffff"..s..L.silverabbrev.." |cffffffff"..c..L.copperabbrev..".")
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