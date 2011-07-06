local WoW42 = select(4, GetBuildInfo()) == 40200
if(not WoW42) then return end

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local incomingResurrect = UnitHasIncomingResurrection(self.unit)
	local resurrect = self.ResurrectIcon

	if(incomingResurrect) and UnitIsDeadOrGhost(self.unit) and UnitIsConnected(self.unit) then
		resurrect:Show()
	else
		resurrect:Hide()
	end
end

local Path = function(self, ...)
	return (self.ResurrectIcon.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local resurrect = self.ResurrectIcon
	if(resurrect) then
		resurrect.__owner = self
		resurrect.ForceUpdate = ForceUpdate

		self:RegisterEvent('INCOMING_RESURRECT_CHANGED', Path)

		if(resurrect:IsObjectType('Texture') and not resurrect:GetTexture()) then
			resurrect:SetTexture[[Interface\RaidFrame\Raid-Icon-Rez]]
		end

		return true
	end
end

local Disable = function(self)
	local resurrect = self.ResurrectIcon
	if(resurrect) then
		self:UnregisterEvent('INCOMING_RESURRECT_CHANGED', Path)
	end
end

oUF:AddElement('ResurrectIcon', Path, Enable, Disable)
