local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(event == 'VehicleSwitch') then return end

	-- Calculate units to work with
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

	-- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
	if(realUnit == 'playerpet') then
		realUnit = 'pet'
	end

	if(modUnit == "pet" and realUnit ~= "pet") then
		modUnit = "vehicle"
	end

	-- Do not update if this frame is not concerned
	if(unit ~= modUnit and unit ~= realUnit and unit ~= self.unit) then return end
	
	-- Update the frame unit properties
	self.unit = modUnit
	if(modUnit ~= realUnit) then
		self.realUnit = realUnit
	else
		self.realUnit = nil
	end

	-- Refresh the frame
	return self:UpdateAllElements('VehicleSwitch')
end

local Enable = function(self, unit)
	if(
		self.disallowVehicleSwap or
		(unit and unit:match'target') or
		self:GetAttribute'unitsuffix' == 'target'
	) then return end

	self:RegisterEvent('UNIT_ENTERED_VEHICLE', Update)
	self:RegisterEvent('UNIT_EXITED_VEHICLE', Update)

	self:SetAttribute('toggleForVehicle', true)

	return true
end

local Disable = function(self)
	self:UnregisterEvent('UNIT_ENTERED_VEHICLE', Update)
	self:UnregisterEvent('UNIT_EXITED_VEHICLE', Update)

	self:SetAttribute('toggleForVehicle', nil)
end

oUF:AddElement("VehicleSwitch", Update, Enable, Disable)
