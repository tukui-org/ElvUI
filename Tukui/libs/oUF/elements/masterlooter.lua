local parent, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local unit
	local method, pid, rid = GetLootMethod()
	if(method == 'master') then
		if(pid) then
			if(pid == 0) then
				unit = 'player'
			else
				unit = 'party'..pid
			end
		elseif(rid) then
			unit = 'raid'..rid
		else
			return
		end

		if(UnitIsUnit(unit, self.unit)) then
			self.MasterLooter:Show()
		elseif(self.MasterLooter:IsShown()) then
			self.MasterLooter:Hide()
		end
	elseif(self.MasterLooter:IsShown()) then
		self.MasterLooter:Hide()
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

		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:RegisterEvent('PARTY_MEMBERS_CHANGED', Path)

		if(masterlooter:IsObjectType('Texture') and not masterlooter:GetTexture()) then
			masterlooter:SetTexture([[Interface\GroupFrame\UI-Group-MasterLooter]])
		end

		return true
	end
end

local function Disable(self)
	if(self.MasterLooter) then
		self:UnregisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:UnregisterEvent('PARTY_MEMBERS_CHANGED', Path)
	end
end

oUF:AddElement('MasterLooter', Path, Enable, Disable)
