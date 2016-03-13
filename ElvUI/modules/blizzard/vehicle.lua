local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: hooksecurefunc, VehicleSeatIndicator, MinimapCluster, _G, VehicleSeatMover

function B:PositionVehicleFrame()
	local function VehicleSeatIndicator_SetPosition(_,_, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			VehicleSeatIndicator:ClearAllPoints()

			if VehicleSeatMover then
				VehicleSeatIndicator:Point("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
			else
				VehicleSeatIndicator:Point("TOPLEFT", E.UIParent, "TOPLEFT", 22, -45)
				E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"])
			end

			VehicleSeatIndicator:SetScale(0.8)
		end
	end
	hooksecurefunc(VehicleSeatIndicator,"SetPoint", VehicleSeatIndicator_SetPosition)

	VehicleSeatIndicator:SetPoint('TOPLEFT', MinimapCluster, 'TOPLEFT', 2, 2) -- initialize mover
end