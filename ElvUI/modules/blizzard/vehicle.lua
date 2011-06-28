--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


function E.PostVehicleMove(frame)
	VehicleSeatIndicator:ClearAllPoints()
	VehicleSeatIndicator:SetPoint("CENTER", frame, "CENTER", 0, 0)
end

local once = false
hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:Point("TOPLEFT", E.UIParent, "TOPLEFT", 36, -40)
		VehicleSeatIndicator:SetScale(0.8)
		if once == false then
			E.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "Vehicle Seat Frame")	
			once = true
		end
    end
end)
