if not TukuiAutoRepair == true then return end

--------------------------------------------------------------------
-- CREDIT : FatalEntity 
--------------------------------------------------------------------

local AddOn = CreateFrame("Frame")
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
AddOn:SetScript("OnEvent", OnEvent)

------------------------------------------------------------------------
--	Auto Repair
------------------------------------------------------------------------
local function MERCHANT_SHOW(...)
	if CanMerchantRepair() then
		local cost = GetRepairAllCost()
		if cost > 0 and not IsShiftKeyDown() then
			local L = GetLocale()
			if cost > GetMoney() then
				if(L=="ruRU") then
					print("Недостаточно средств для ремонта.")
				elseif(L=="frFR") then
					print("Trésorerie insuffisante pour réparer l'équipement.")
				elseif(L=="deDE") then
					print("Ihr habt nicht genügend Gold für die Reparatur.")                                         
				else			
					print("Insufficient Funds to Repair.") 
				end
			end
			
			local gold = floor(math.abs(cost) / 10000)
			local silver = mod(floor(math.abs(cost) / 100), 100)
			local copper = mod(floor(math.abs(cost)), 100)
			if(L=="ruRU") then
				if gold ~= 0 then
					cost = format("%s|cffffd700з|r %s|cffc7c7cfс|r %s|cffeda55fм|r", gold, silver, copper)
				elseif silver ~= 0 then
					cost = format("%s|cffc7c7cfс|r %s|cffeda55fм|r", silver, copper)
				else
					cost = format("%s|cffeda55fм|r", copper)
				end
			elseif(L=="frFR") then
				if gold ~= 0 then
					cost = format("%s|cffffd700o|r %s|cffc7c7cfa|r %s|cffeda55fc|r", gold, silver, copper)
				elseif silver ~= 0 then
					cost = format("%s|cffc7c7cfa|r %s|cffeda55fc|r", silver, copper)
				else
					cost = format("%s|cffeda55fc|r", copper)
				end
			elseif(L=="deDE") then
				if gold ~= 0 then
					cost = format("%s|cffffd700g|r %s|cffc7c7cfs|r %s|cffeda55fk|r", gold, silver, copper)
				elseif silver ~= 0 then
					cost = format("%s|cffc7c7cfs|r %s|cffeda55fk|r", silver, copper)
				else
					cost = format("%s|cffeda55fk|r", copper)
				end                                
			else
				if gold ~= 0 then
					cost = format("%s|cffffd700g|r %s|cffc7c7cfs|r %s|cffeda55fc|r", gold, silver, copper)
				elseif silver ~= 0 then
					cost = format("%s|cffc7c7cfs|r %s|cffeda55fc|r", silver, copper)
				else
					cost = format("%s|cffeda55fc|r", copper)
				end
			end
			
			if AutoRepairGuildFund == true then
				if CanGuildBankRepair() then
					RepairAllItems(1)
					if GetRepairAllCost() == 0 then
						-- i'll need to localize this later.
						print(format("All items repaired using guild bank funds for %s.", cost))
					end
				end
			end
			
			if GetRepairAllCost() then
				RepairAllItems()
				if(L=="ruRU") then
					print(format("Все вещи отремонтированы за %s.", cost))
				elseif(L=="frFR") then
					print(format("Tous les objets réparés pour %s.", cost))
				elseif(L=="deDE") then
					print(format("Alle Gegenstände wurden für %s repariert.", cost))                                        
				else
					print(format("All items repaired for %s.", cost))
				end
			end
		end
	end
end

AddOn:RegisterEvent("MERCHANT_SHOW")
AddOn["MERCHANT_SHOW"] = MERCHANT_SHOW
