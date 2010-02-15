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

local Enable = function(self)
	if(self.PvP) then
		self:RegisterEvent("UNIT_FACTION", Update)

		return true
	end
end

local Disable = function(self)
	if(self.PvP) then
		self:UnregisterEvent("UNIT_FACTION", Update)
	end
end

oUF:AddElement('PvP', Update, Enable, Disable)
