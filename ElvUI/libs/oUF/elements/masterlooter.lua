local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local unit = self.unit
	local masterlooter = self.MasterLooter
	if(not (UnitInParty(unit) or UnitInRaid(unit))) then
		return masterlooter:Hide()
	end

	if(masterlooter.PreUpdate) then
		masterlooter:PreUpdate()
	end

	local method, pid, rid = GetLootMethod()
	if(method == 'master') then
		local mlUnit
		if(pid) then
			if(pid == 0) then
				mlUnit = 'player'
			else
				mlUnit = 'party'..pid
			end
		elseif(rid) then
			mlUnit = 'raid'..rid
		end

		if(unit and mlUnit and UnitIsUnit(unit, mlUnit)) then
			masterlooter:Show()
		elseif(masterlooter:IsShown()) then
			masterlooter:Hide()
		end
	else
		masterlooter:Hide()
	end

	if(masterlooter.PostUpdate) then
		return masterlooter:PostUpdate(masterlooter:IsShown())
	end
end

local Path = function(self, ...)
	return (self.MasterLooter.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local masterlooter = self.MasterLooter
	if(masterlooter) then
		masterlooter.__owner = self
		masterlooter.ForceUpdate = ForceUpdate

		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(masterlooter:IsObjectType('Texture') and not masterlooter:GetTexture()) then
			masterlooter:SetTexture([[Interface\GroupFrame\UI-Group-MasterLooter]])
		end

		return true
	end
end

local function Disable(self)
	if(self.MasterLooter) then
		self:UnregisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('MasterLooter', Path, Enable, Disable)
