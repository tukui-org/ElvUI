local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local unit = self.unit
	if((UnitInParty(unit) or UnitInRaid(unit)) and UnitIsPartyLeader(unit)) then
		self.Leader:Show()
	else
		self.Leader:Hide()
	end
end

local Path = function(self, ...)
	return (self.Leader.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local leader = self.Leader
	if(leader) then
		leader.__owner = self
		leader.ForceUpdate = ForceUpdate

		self:RegisterEvent("PARTY_LEADER_CHANGED", Path)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", Path)

		if(leader:IsObjectType"Texture" and not leader:GetTexture()) then
			leader:SetTexture[[Interface\GroupFrame\UI-Group-LeaderIcon]]
		end

		return true
	end
end

local Disable = function(self)
	local leader = self.Leader
	if(leader) then
		self:UnregisterEvent("PARTY_LEADER_CHANGED", Path)
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Path)
	end
end

oUF:AddElement('Leader', Path, Enable, Disable)
