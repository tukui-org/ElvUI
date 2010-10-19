-- © Elv22
if TukuiCF.unitframes.enable ~= true then return end
if not (select(2, UnitClass('player')) == 'DRUID' or select(2, UnitClass('player')) == 'ROGUE') then return end

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	local combos = self.ComboPoint
	local _, powertype = UnitPowerType("player")
	
	if powertype ~= "ENERGY" then 
		combos:Hide() 
		for i = 1, 5 do
			combos[i]:Hide()
		end
	else
		if(combos.PreUpdate) then combos:PreUpdate(unit) end
		
		
		local points = GetComboPoints("player")
		for i = 1, 5 do
			combos[i]:Show()
			if(i <= points) then
				combos[i]:SetAlpha(1)
			else
				combos[i]:SetAlpha(0.15)
			end
		end
		combos:Show()
		if(combos.PostUpdate) then
			return combos:PostUpdate(unit)
		end
	end
end

local Path = function(self, ...)
	return (self.ComboPoint.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local combos = self.ComboPoint
	if( combos ) then
		combos.__owner = self
		combos.ForceUpdate = ForceUpdate
		
		combos:Show()
		--Register Events
		self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
		self:RegisterEvent("UNIT_COMBO_POINTS", Path)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path)
		return true
	end
end

local Disable = function(self)
	local combos = self.ComboPoint
	if combos then
		combos:Hide()
		
		--Unregister Events
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("UNIT_COMBO_POINTS", Path)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
	end
end

oUF:AddElement("ComboPoints", Path, Enable, Disable)