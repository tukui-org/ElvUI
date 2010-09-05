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

local Enable = function(self)
	local leader = self.Leader
	if(leader) then
		local Update = leader.Update or Update
		self:RegisterEvent("PARTY_LEADER_CHANGED", Update)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update)

		if(leader:IsObjectType"Texture" and not leader:GetTexture()) then
			leader:SetTexture[[Interface\GroupFrame\UI-Group-LeaderIcon]]
		end

		return true
	end
end

local Disable = function(self)
	local leader = self.Leader
	if(leader) then
		local Update = leader.Update or Update
		self:UnregisterEvent("PARTY_LEADER_CHANGED", Update)
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Update)
	end
end

oUF:AddElement('Leader', Update, Enable, Disable)
