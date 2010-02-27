if not TukuiSellGray == true then return end

--------------------------------------------------------------------
-- CREDIT : FatalEntity 
--------------------------------------------------------------------

local AddOn = CreateFrame("Frame")
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
AddOn:SetScript("OnEvent", OnEvent)

------------------------------------------------------------------------
--	Auto SELL JUNK
------------------------------------------------------------------------
local function MERCHANT_SHOW(...)
   local cost = 0
   for bagIndex=0,4 do
      for s=1,GetContainerNumSlots(bagIndex) do
         local l = GetContainerItemLink(bagIndex, s)
         if l then
            local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(bagIndex, s))
            if select(3, GetItemInfo(l))==0 then
               UseContainerItem(bagIndex, s)
               PickupMerchantItem()
               cost = cost+p
            end
         end
      end
   end
   if cost>0 then
      local gold = floor(math.abs(cost) / 10000)
      local silver = mod(floor(math.abs(cost) / 100), 100)
      local copper = mod(floor(math.abs(cost)), 100)
      
      if gold ~= 0 then
         cost = format("%s|cffffd700g|r %s|cffc7c7cfs|r %s|cffeda55fc|r", gold, silver, copper)
      elseif silver ~= 0 then
         cost = format("%s|cffc7c7cfs|r %s|cffeda55fc|r", silver, copper)
      else
         cost = format("%s|cffeda55fc|r", copper)
      end
      DEFAULT_CHAT_FRAME:AddMessage("+"..cost)
   end
end

AddOn:RegisterEvent("MERCHANT_SHOW")
AddOn["MERCHANT_SHOW"] = MERCHANT_SHOW
