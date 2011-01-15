local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(unit ~= self.unit) then return end

	local threat = self.Threat
	if(threat.PreUpdate) then threat:PreUpdate(unit) end

	unit = unit or self.unit
	local status = UnitThreatSituation(unit)

	if(status and status > 0) then
		local r, g, b = GetThreatStatusColor(status)
		threat:SetVertexColor(r, g, b)
		threat:Show()
	else
		threat:Hide()
	end

	if(threat.PostUpdate) then
		return threat:PostUpdate(unit, status)
	end
end

local Path = function(self, ...)
	return (self.Threat.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local threat = self.Threat
	if(threat) then
		threat.__owner = self
		threat.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		threat:Hide()

		if(threat:IsObjectType"Texture" and not threat:GetTexture()) then
			threat:SetTexture[[Interface\Minimap\ObjectIcons]]
			threat:SetTexCoord(6/8, 7/8, 1/2, 1)
		end

		return true
	end
end

local Disable = function(self)
	local threat = self.Threat
	if(threat) then
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
	end
end

oUF:AddElement('Threat', Path, Enable, Disable)
