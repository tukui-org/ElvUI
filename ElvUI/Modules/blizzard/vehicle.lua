local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: VehicleSeatIndicator, VehicleSeatIndicator_SetUpVehicle
-- GLOBALS: MinimapCluster, VehicleSeatMover

local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat
local GetVehicleUIIndicator = GetVehicleUIIndicator
local hooksecurefunc = hooksecurefunc
local _G = _G

local function VehicleSeatIndicator_SetPosition(_,_, parent)
	if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	VehicleSeatIndicator:SetSize(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)
	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	if numSeatIndicators then
		for i = 1, numSeatIndicators do
			local button = _G["VehicleSeatIndicatorButton"..i];
			button:SetSize(E.db.general.vehicleSeatIndicatorSize / 4, E.db.general.vehicleSeatIndicatorSize / 4)
			local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i);
			button:ClearAllPoints()
			button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", xOffset * E.db.general.vehicleSeatIndicatorSize, -yOffset * E.db.general.vehicleSeatIndicatorSize)
		end
	end
end

function B:UpdateVehicleFrame()
	VehicleSeatIndicator_SetUpVehicle(VehicleSeatIndicator.currSkin)
end

function B:PositionVehicleFrame()
	if not VehicleSeatIndicator.PositionVehicleFrameHooked then
		hooksecurefunc(VehicleSeatIndicator, 'SetPoint', VehicleSeatIndicator_SetPosition)
		hooksecurefunc('VehicleSeatIndicator_SetUpVehicle', VehicleSetUp)
		E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, 'general,general')
		VehicleSeatIndicator.PositionVehicleFrameHooked = true
	end

	VehicleSeatIndicator:SetSize(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)

    if VehicleSeatIndicator.currSkin then
		VehicleSetUp(VehicleSeatIndicator.currSkin)
    end
end
