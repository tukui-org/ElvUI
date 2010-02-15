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
	for bagIndex = 0, 4 do
		if GetContainerNumSlots(bagIndex) > 0 then
			for slotIndex = 1, GetContainerNumSlots(bagIndex) do
				if select(2,GetContainerItemInfo(bagIndex, slotIndex)) then
					local quality = select(3, string.find(GetContainerItemLink(bagIndex, slotIndex), "(|c%x+)"))
					
					if quality == ITEM_QUALITY_COLORS[0].hex then
						UseContainerItem(bagIndex, slotIndex)
					end
				end
			end
		end
	end
end

AddOn:RegisterEvent("MERCHANT_SHOW")
AddOn["MERCHANT_SHOW"] = MERCHANT_SHOW
