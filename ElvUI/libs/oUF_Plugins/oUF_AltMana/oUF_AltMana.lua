local playerClass = select(2, UnitClass('player'))
if(playerClass ~= 'DRUID' and playerClass ~= 'PRIEST') then return end


local _, ns = ...
local oUF = ns.oUF or oUF

local UPDATE_VISIBILITY = function(self, event)
	local altmana = self.AltMana
	-- check form
	local form = GetShapeshiftFormID()
	local min, max = altmana:GetMinMaxValues()

	if altmana:GetValue() == max then
		altmana:Hide()
	elseif(playerClass == "DRUID" and (form == CAT_FORM or form == BEAR_FORM or form == MOONKIN_FORM)) then
		altmana:Show()
	elseif(playerClass == "PRIEST" and SPEC_PRIEST_SHADOW == GetSpecialization()) then
		altmana:Show()
	end
	
	if(altmana.PostUpdateVisibility) then
		return altmana:PostUpdateVisibility(self.unit)
	end	
end

local UNIT_POWER = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return end
	local altmana = self.AltMana

	if not (altmana) then return end
	
	if(altmana.PreUpdate) then
		altmana:PreUpdate(unit)
	end
	local min, max = UnitPower('player', SPELL_POWER_MANA), UnitPowerMax('player', SPELL_POWER_MANA)

	altmana:SetMinMaxValues(0, max)
	altmana:SetValue(min)

	local r, g, b, t
	if(altmana.colorPower) then
		t = self.colors.power["MANA"]
	elseif(altmana.colorClass and UnitIsPlayer(unit)) or
		(altmana.colorClassNPC and not UnitIsPlayer(unit)) or
		(altmana.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(altmana.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(altmana.colorSmooth) then
		r, g, b = self.ColorGradient(min / max, unpack(altmana.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		altmana:SetStatusBarColor(r, g, b)

		local bg = altmana.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
	
	UPDATE_VISIBILITY(self)
	
	if(altmana.PostUpdatePower) then
		return altmana:PostUpdatePower(unit, min, max)
	end
end

local Update = function(self, ...)
	UNIT_POWER(self, ...)
	return UPDATE_VISIBILITY(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local altmana = self.AltMana
	if(altmana and unit == 'player') then
		altmana.__owner = self
		altmana.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_FREQUENT', UNIT_POWER)
		self:RegisterEvent('UNIT_MAXPOWER', UNIT_POWER)
		
		if(playerClass == 'PRIEST') then
			self:RegisterEvent('PLAYER_TALENT_UPDATE', UPDATE_VISIBILITY)
		else
			self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
		end
		
		return true
	end
end

local Disable = function(self)
	local altmana = self.AltMana
	if(altmana) then
		self:UnregisterEvent('UNIT_POWER_FREQUENT', UNIT_POWER)
		self:UnregisterEvent('UNIT_MAXPOWER', UNIT_POWER)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
	end
end

oUF:AddElement("AltMana", Update, Enable, Disable)