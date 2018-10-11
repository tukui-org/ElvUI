local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: hooksecurefunc, VehicleSeatIndicator, MinimapCluster, _G, VehicleSeatMover

function B:UpdateVehicleFrame()
	VehicleSeatIndicator_SetUpVehicle(VehicleSeatIndicator.currSkin)
end

function B:PositionVehicleFrame()
	local function VehicleSeatIndicator_SetPosition(_,_, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			VehicleSeatIndicator:ClearAllPoints()
			VehicleSeatIndicator:SetPoint("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
		end
	end

	local function VehicleSetUp(vehicleID)
		VehicleSeatIndicator:SetSize(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)
		local backgroundTexture, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
		for i = 1, numSeatIndicators do
			local button = _G["VehicleSeatIndicatorButton"..i];
			button:SetSize(E.db.general.vehicleSeatIndicatorSize / 4, E.db.general.vehicleSeatIndicatorSize / 4)
			local virtualSeatIndex, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i);
			button:ClearAllPoints()
			button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", xOffset * E.db.general.vehicleSeatIndicatorSize, -yOffset * E.db.general.vehicleSeatIndicatorSize)
		end
	end

	hooksecurefunc(VehicleSeatIndicator,"SetPoint", VehicleSeatIndicator_SetPosition)

	hooksecurefunc('VehicleSeatIndicator_SetUpVehicle', VehicleSetUp)

	VehicleSeatIndicator:SetSize(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)

	E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"])

    if VehicleSeatIndicator.currSkin then VehicleSetUp(VehicleSeatIndicator.currSkin) end
end
