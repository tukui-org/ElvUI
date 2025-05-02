local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat

function BL:SetVehiclePosition(_, relativeTo)
	local mover = _G.VehicleSeatIndicator.mover
	if mover and relativeTo ~= mover then
		_G.VehicleSeatIndicator:ClearAllPoints()
		_G.VehicleSeatIndicator:Point('TOPLEFT', mover, 'TOPLEFT', 0, 0)
	end
end

function BL:SetUpVehicle()
	local size = E.db.general.vehicleSeatIndicatorSize
	_G.VehicleSeatIndicator:Size(size)

	if not self then return end -- this is vehicleIndicatorID

	local _, numIndicators = GetVehicleUIIndicator(self)
	if numIndicators then
		local fourth = size * 0.25
		for i = 1, numIndicators do
			local button = _G['VehicleSeatIndicatorButton'..i]
			if button then
				local _, x, y = GetVehicleUIIndicatorSeat(self, i)
				button:ClearAllPoints()
				button:Point('CENTER', button:GetParent(), 'TOPLEFT', x * size, -y * size)
				button:Size(fourth)
			end
		end
	end
end

function BL:UnloadVehicleTextures() -- removes UIParent_ManageFramePositions()
	self.BackgroundTexture:SetTexture()
	self.currSkin = nil

	self:HideButtons()
	self:UpdateShownState()

	_G.DurabilityFrame:SetAlerts()
end

function BL:UpdateVehicleFrame()
	BL.SetUpVehicle(_G.VehicleSeatIndicator.currSkin)
end

function BL:PositionVehicleFrame()
	local indicator = _G.VehicleSeatIndicator
	if E.Mists then
		if not indicator.PositionVehicleFrameHooked then
			hooksecurefunc(indicator, 'SetPoint', BL.SetVehiclePosition)
			hooksecurefunc('VehicleSeatIndicator_SetUpVehicle', BL.SetUpVehicle)

			indicator:ClearAllPoints()
			indicator:SetPoint('TOPRIGHT', _G.MinimapCluster, 'BOTTOMRIGHT', 0, 0)
			indicator:Size(E.db.general.vehicleSeatIndicatorSize)

			E:CreateMover(indicator, 'VehicleSeatMover', L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, 'general,blizzardImprovements')
			indicator.PositionVehicleFrameHooked = true
		end

		BL:UpdateVehicleFrame()
	elseif E.Retail and E.private.actionbar.enable then
		indicator.UnloadTextures = BL.UnloadVehicleTextures -- fix a taint when actionbars in use
	end
end
