local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat
local VehicleSeatIndicator_SetUpVehicle = VehicleSeatIndicator_SetUpVehicle

local function VehicleSeatIndicator_SetPosition(_,_, parent)
	if parent == "MinimapCluster" or parent == _G.MinimapCluster then
		_G.VehicleSeatIndicator:ClearAllPoints()
		_G.VehicleSeatIndicator:Point("TOPLEFT", _G.VehicleSeatMover, "TOPLEFT", 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	_G.VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)
	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	if numSeatIndicators then
		for i = 1, numSeatIndicators do
			local button = _G["VehicleSeatIndicatorButton"..i]
			button:Size(E.db.general.vehicleSeatIndicatorSize / 4, E.db.general.vehicleSeatIndicatorSize / 4)
			local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i)
			button:ClearAllPoints()
			button:Point("CENTER", button:GetParent(), "TOPLEFT", xOffset * E.db.general.vehicleSeatIndicatorSize, -yOffset * E.db.general.vehicleSeatIndicatorSize)
		end
	end
end

function B:UpdateVehicleFrame()
	VehicleSeatIndicator_SetUpVehicle(_G.VehicleSeatIndicator.currSkin)
end

function B:PositionVehicleFrame()
	local VehicleSeatIndicator = _G.VehicleSeatIndicator
	if not VehicleSeatIndicator.PositionVehicleFrameHooked then
		hooksecurefunc(VehicleSeatIndicator, 'SetPoint', VehicleSeatIndicator_SetPosition)
		hooksecurefunc('VehicleSeatIndicator_SetUpVehicle', VehicleSetUp)
		E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')
		VehicleSeatIndicator.PositionVehicleFrameHooked = true
	end

	VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)

    if VehicleSeatIndicator.currSkin then
		VehicleSetUp(VehicleSeatIndicator.currSkin)
    end
end
