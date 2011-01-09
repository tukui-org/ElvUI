--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("TOP", UIParent, "TOP", 0, TukuiDB.Scale(-40))
		VehicleSeatIndicator:SetScale(0.5)
    end
end)
