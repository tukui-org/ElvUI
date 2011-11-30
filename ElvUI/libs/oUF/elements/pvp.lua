local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(unit ~= self.unit) then return end

	if(self.PvP) then
		local factionGroup = UnitFactionGroup(unit)
		if(UnitIsPVPFreeForAll(unit)) then
			self.PvP:SetTexture[[Interface\TargetingFrame\UI-PVP-FFA]]
			self.PvP:Show()
		elseif(factionGroup and UnitIsPVP(unit)) then
			self.PvP:SetTexture([[Interface\TargetingFrame\UI-PVP-]]..factionGroup)
			self.PvP:Show()
		else
			self.PvP:Hide()
		end
	end
end

local Path = function(self, ...)
	return (self.PvP.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local pvp = self.PvP
	if(pvp) then
		pvp.__owner = self
		pvp.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_FACTION", Path)

		return true
	end
end

local Disable = function(self)
	local pvp = self.PvP
	if(pvp) then
		self:UnregisterEvent("UNIT_FACTION", Path)
	end
end

oUF:AddElement('PvP', Path, Enable, Disable)
