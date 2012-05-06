local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local picon = self.PhaseIcon
	if(picon.PreUpdate) then
		picon:PreUpdate()
	end

	local inPhase = UnitInPhase(self.unit)
	if(inPhase) then
		picon:Hide()
	else
		picon:Show()
	end

	if(picon.PostUpdate) then
		return picon:PostUpdate(inPhase)
	end
end

local Path = function(self, ...)
	return (self.PhaseIcon.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local picon = self.PhaseIcon
	if(picon) then
		picon.__owner = self
		picon.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_PHASE', Path, true)

		if(picon:IsObjectType'Texture' and not picon:GetTexture()) then
			picon:SetTexture[[Interface\TargetingFrame\UI-PhasingIcon]]
		end

		return true
	end
end

local Disable = function(self)
	local picon = self.PhaseIcon
	if(picon) then
		self:UnregisterEvent('UNIT_PHASE', Path)
	end
end

oUF:AddElement('PhaseIcon', Path, Enable, Disable)
