--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local ElvDB = ElvDB
local once = false
hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("TOP", UIParent, "TOP", 0, ElvDB.Scale(-40))
		VehicleSeatIndicator:SetScale(0.8)
		if once == false then
			ElvDB.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "Vehicle Seat Frame")	
			once = true
		end
    end
end)
