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

local function Enable(self, unit)
	local masterlooter = self.MasterLooter
	if(masterlooter) then
		local Update = masterlooter.Update or Update
		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', Update)
		self:RegisterEvent('PARTY_MEMBERS_CHANGED', Update)

		if(masterlooter:IsObjectType('Texture') and not masterlooter:GetTexture()) then
			masterlooter:SetTexture([[Interface\GroupFrame\UI-Group-MasterLooter]])
		end

		return true
	end
end

local function Disable(self)
	if(self.MasterLooter) then
		local Update = masterlooter.Update or Update
		self:UnregisterEvent('PARTY_LOOT_METHOD_CHANGED', Update)
		self:UnregisterEvent('PARTY_MEMBERS_CHANGED', Update)
	end
end

oUF:AddElement('MasterLooter', Update, Enable, Disable)
