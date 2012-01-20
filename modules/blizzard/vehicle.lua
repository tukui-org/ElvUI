local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

function B:PositionVehicleFrame()
	hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			VehicleSeatIndicator:ClearAllPoints()
			
			if VehicleSeatMover then
				VehicleSeatIndicator:Point("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
			else
				VehicleSeatIndicator:Point("TOPLEFT", E.UIParent, "TOPLEFT", 22, -45)
				E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "Vehicle Seat Frame")	
			end
			
			VehicleSeatIndicator:SetScale(0.8)		
		end
	end)
end