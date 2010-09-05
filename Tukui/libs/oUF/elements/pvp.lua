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
	local pvp = self.PvP
	if(pvp) then
		self:RegisterEvent("UNIT_FACTION", pvp.Update or Update)

		return true
	end
end

local Disable = function(self)
	local pvp = self.PvP
	if(pvp) then
		self:UnregisterEvent("UNIT_FACTION", pvp.Update or Update)
	end
end

oUF:AddElement('PvP', Update, Enable, Disable)
