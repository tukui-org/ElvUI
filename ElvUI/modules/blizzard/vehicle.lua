--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local once = false
hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("TOP", UIParent, "TOP", 0, E.Scale(-40))
		VehicleSeatIndicator:SetScale(0.8)
		if once == false then
			E.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "Vehicle Seat Frame")	
			once = true
		end
    end
end)
