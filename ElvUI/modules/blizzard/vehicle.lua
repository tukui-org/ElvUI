--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


function E.PostVehicleMove(frame)
	VehicleSeatIndicator:ClearAllPoints()
	VehicleSeatIndicator:SetPoint("CENTER", frame, "CENTER", 0, 0)
end

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		
		if VehicleSeatMover then
			VehicleSeatIndicator:Point("TOPRIGHT", VehicleSeatMover, "TOPRIGHT", 0, 0)
		else
			VehicleSeatIndicator:Point("TOPLEFT", E.UIParent, "TOPLEFT", 36, -40)
			E.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "Vehicle Seat Frame")	
		end
		
		VehicleSeatIndicator:SetScale(0.8)
    end
end)
