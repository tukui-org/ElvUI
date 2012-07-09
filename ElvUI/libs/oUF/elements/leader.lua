local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local leader = self.Leader
	if(leader.PreUpdate) then
		leader:PreUpdate()
	end

	local unit = self.unit
	local isLeader = (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit)
	if(isLeader) then
		leader:Show()
	else
		leader:Hide()
	end

	if(leader.PostUpdate) then
		return leader:PostUpdate(isLeader)
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

		self:RegisterEvent("PARTY_LEADER_CHANGED", Path, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", Path, true)

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
		self:UnregisterEvent("GROUP_ROSTER_UPDATE", Path)
	end
end

oUF:AddElement('Leader', Path, Enable, Disable)
