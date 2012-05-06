local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local raidID = UnitInRaid(self.unit)
	if(not raidID) then return end

	local maintank = self.MainTank
	if(maintank.PreUpdate) then
		maintank:PreUpdate()
	end

	local _, _, _, _, _, _, _, _, _, rinfo = GetRaidRosterInfo(raidID)
	if(rinfo == 'MAINTANK' and not UnitHasVehicleUI(self.unit)) then
		self.MainTank:Show()
	else
		self.MainTank:Hide()
	end

	if(maintank.PostUpdate) then
		return maintank:PostUpdate(rinfo)
	end
end

local Path = function(self, ...)
	return (self.MainTank.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local mt = self.MainTank

	if(mt) then
		mt.__owner = self
		mt.ForceUpdate = ForceUpdate

		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(mt:IsObjectType'Texture' and not mt:GetTexture()) then
			mt:SetTexture[[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]]
		end

		return true
	end
end

local Disable = function(self)
	local mt = self.MainTank

	if (mt) then
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('MainTank', Path, Enable, Disable)
