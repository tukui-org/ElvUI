local parent, ns = ...
local oUF = ns.oUF

local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local Update = function(self, event, unit)
	if(unit ~= 'player' and unit ~= 'vehicle') then return end

	local cpoints = self.CPoints
	if(cpoints.PreUpdate) then
		cpoints:PreUpdate()
	end

	local cp
	if(UnitHasVehicleUI'player') then
		cp = GetComboPoints('vehicle')
	else
		cp = GetComboPoints('player')
	end

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:Show()
		else
			cpoints[i]:Hide()
		end
	end

	if(cpoints.PostUpdate) then
		return cpoints:PostUpdate(cp, anticipation)
	end
end

local Path = function(self, ...)
	return (self.CPoints.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local cpoints = self.CPoints
	if(cpoints) then
		cpoints.__owner = self
		cpoints.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_COMBO_POINTS', Path, true)
		self:RegisterEvent('UNIT_AURA', Path, true)

		for index = 1, MAX_COMBO_POINTS do
			local cpoint = cpoints[index]
			if(cpoint:IsObjectType'Texture' and not cpoint:GetTexture()) then
				cpoint:SetTexture[[Interface\ComboFrame\ComboPoint]]
				cpoint:SetTexCoord(0, 0.375, 0, 1)
			end
		end

		return true
	end
end

local Disable = function(self)
	local cpoints = self.CPoints
	if(cpoints) then
		self:UnregisterEvent('UNIT_COMBO_POINTS', Path)
		self:UnregisterEvent('UNIT_AURA', Path)
	end
end

oUF:AddElement('CPoints', Path, Enable, Disable)
