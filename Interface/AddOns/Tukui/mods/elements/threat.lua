--[[
	Elements handled: .Threat

	Functions that can be overridden from within a layout:
	 - :PreUpdateThreat(event, unit)
	 - :OverrideUpdateThreat(event, unit, status)
	 - :PostUpdateThreat(event, unit, status)
--]]
local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(unit ~= self.unit) then return end
	if(self.PreUpdateThreat) then self:PreUpdateThreat(event, unit) end

	unit = unit or self.unit
	local threat = self.Threat
	local status = UnitThreatSituation(unit)

	if(not self.OverrideUpdateThreat) then
		if(status and status > 0) then
			local r, g, b = GetThreatStatusColor(status)
			threat:SetVertexColor(r, g, b)
			threat:Show()
		else
			threat:Hide()
		end
	else
		self:OverrideUpdateThreat(event, unit, status)
	end

	if(self.PostUpdateThreat) then
		return self:PostUpdateThreat(event, unit, status)
	end
end

local Enable = function(self)
	local threat = self.Threat
	if(threat) then
		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
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
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
	end
end

oUF:AddElement('Threat', Update, Enable, Disable)
