local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat
local VehicleSeatIndicator_SetUpVehicle = VehicleSeatIndicator_SetUpVehicle

local function SetPosition(_,_,anchor)
	if anchor == 'MinimapCluster' or anchor == _G.MinimapCluster then
		_G.VehicleSeatIndicator:ClearAllPoints()
		_G.VehicleSeatIndicator:Point('TOPLEFT', _G.VehicleSeatMover, 'TOPLEFT', 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	local size = E.db.general.vehicleSeatIndicatorSize
	_G.VehicleSeatIndicator:Size(size)

	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	if numSeatIndicators then
		local fourth = size / 4

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
	local VehicleSeatIndicator = _G.VehicleSeatIndicator
	if not VehicleSeatIndicator.PositionVehicleFrameHooked then
		hooksecurefunc(VehicleSeatIndicator, 'SetPoint', SetPosition)
		hooksecurefunc('VehicleSeatIndicator_SetUpVehicle', VehicleSetUp)
		E:CreateMover(VehicleSeatIndicator, 'VehicleSeatMover', L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')
		VehicleSeatIndicator.PositionVehicleFrameHooked = true
	end

	VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize)

	if VehicleSeatIndicator.currSkin then
		VehicleSetUp(VehicleSeatIndicator.currSkin)
	end
end
