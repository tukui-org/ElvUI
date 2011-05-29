if(select(2, UnitClass('player')) ~= 'DRUID') then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local UPDATE_VISIBILITY = function(self, event)
	local druidmana = self.DruidAltMana
	-- check form
	local form = GetShapeshiftFormID()
	local min, max = druidmana.ManaBar:GetMinMaxValues()
	if druidmana.ManaBar:GetValue() == max then
		druidmana:Hide()
	elseif (form == BEAR_FORM or form == CAT_FORM) then
		druidmana:Show()
	else
		druidmana:Hide()
	end
end

local UNIT_POWER = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return end
	local druidmana = self.DruidAltMana
	
	if not (druidmana.ManaBar) then return end
	
	if(druidmana.PreUpdate) then
		druidmana:PreUpdate(unit)
	end
	local min, max = UnitPower('player', SPELL_POWER_MANA), UnitPowerMax('player', SPELL_POWER_MANA)

	druidmana.ManaBar:SetMinMaxValues(0, max)
	druidmana.ManaBar:SetValue(min)

	local r, g, b, t
	if(druidmana.colorPower) then
		t = self.colors.power["MANA"]
	elseif(druidmana.colorClass and UnitIsPlayer(unit)) or
		(druidmana.colorClassNPC and not UnitIsPlayer(unit)) or
		(druidmana.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(druidmana.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(druidmana.colorSmooth) then
		r, g, b = self.ColorGradient(min / max, unpack(druidmana.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		druidmana.ManaBar:SetStatusBarColor(r, g, b)

		local bg = druidmana.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(druidmana.PostUpdatePower) then
		return druidmana:PostUpdatePower(unit)
	end
	
	UPDATE_VISIBILITY(self)
end

local Update = function(self, ...)
	UNIT_POWER(self, ...)
	return UPDATE_VISIBILITY(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local druidmana = self.DruidAltMana
	if(druidmana and unit == 'player') then
		druidmana.__owner = self
		druidmana.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER', UNIT_POWER)
		self:RegisterEvent('UNIT_MAXPOWER', UNIT_POWER)
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
		
		return true
	end
end

local Disable = function(self)
	local druidmana = self.DruidAltMana
	if(druidmana) then
		self:UnregisterEvent('UNIT_POWER', UNIT_POWER)
		self:UnregisterEvent('UNIT_MAXPOWER', UNIT_POWER)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
	end
end

oUF:AddElement("DruidAltMana", Update, Enable, Disable)