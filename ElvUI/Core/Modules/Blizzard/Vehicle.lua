local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat
local VehicleSeatIndicator_SetUpVehicle = VehicleSeatIndicator_SetUpVehicle

local function SetPosition(_, _, relativeTo)
	if relativeTo ~= _G.VehicleSeatIndicator.mover then
		_G.VehicleSeatIndicator:ClearAllPoints()
		_G.VehicleSeatIndicator:Point('TOPLEFT', _G.VehicleSeatIndicator.mover, 'TOPLEFT', 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	local size = E.db.general.vehicleSeatIndicatorSize
	_G.VehicleSeatIndicator:Size(size)

	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	if numSeatIndicators then
		local fourth = size * 0.25

		for i = 1, numSeatIndicators do
			local button = _G['VehicleSeatIndicatorButton'..i]
			button:Size(fourth)

			local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i)
			button:ClearAllPoints()
			button:Point('CENTER', button:GetParent(), 'TOPLEFT', xOffset * size, -yOffset * size)
		end
	end
end

function B:UpdateVehicleFrame()
	if _G.VehicleSeatIndicator.currSkin then
		VehicleSeatIndicator_SetUpVehicle(_G.VehicleSeatIndicator.currSkin)
	end
end

function B:PositionVehicleFrame()
	local seatIndicator = _G.VehicleSeatIndicator
	if not seatIndicator.PositionVehicleFrameHooked then
		seatIndicator:ClearAllPoints()
		seatIndicator:SetPoint('TOPRIGHT', nil, 'BOTTOMRIGHT', 0, 0)

		hooksecurefunc(seatIndicator, 'SetPoint', SetPosition)
		hooksecurefunc('VehicleSeatIndicator_SetUpVehicle', VehicleSetUp)

		E:CreateMover(seatIndicator, 'VehicleSeatMover', L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')
		seatIndicator.PositionVehicleFrameHooked = true
	end

	seatIndicator:Size(E.db.general.vehicleSeatIndicatorSize)

	if seatIndicator.currSkin then
		VehicleSetUp(seatIndicator.currSkin)
	end
end
