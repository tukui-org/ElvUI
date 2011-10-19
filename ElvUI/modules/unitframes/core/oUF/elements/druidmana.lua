-- Druid Mana Bar for Cat and Bear forms
-- Authors: Califpornia aka Ennie // some code taken from oUF`s EclipseBar element
if(select(2, UnitClass('player')) ~= 'DRUID') then return end

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit, powertype)
	--only the player frame will have this unit enabled
	--i mainly place this check for UNIT_DISPLAYPOWER and entering a vehicle
	if(unit ~= 'player' or (powertype and powertype ~= 'MANA')) then return end

	local druidmana = self.DruidMana
	if(druidmana.PreUpdate) then druidmana:PreUpdate(unit) end

	--check form
	if(UnitPowerType('player') == SPELL_POWER_MANA) then
		return druidmana:Hide()
	else
		druidmana:Show()
	end

	local min, max = UnitPower('player', SPELL_POWER_MANA), UnitPowerMax('player', SPELL_POWER_MANA)
	druidmana:SetMinMaxValues(0, max)
	druidmana:SetValue(min)

	local r, g, b, t
	if(druidmana.colorClass) then
		t = self.colors.class['DRUID']
	elseif(druidmana.colorSmooth) then
		r, g, b = self.ColorGradient(min, max, unpack(druidmana.smoothGradient or self.colors.smooth))
	elseif(druidmana.colorPower) then
		t = self.colors.power['MANA']
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		druidmana:SetStatusBarColor(r, g, b)

		local bg = druidmana.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(druidmana.PostUpdate) then
		return druidmana:PostUpdate(unit, min, max)
	end
end

local function Path(self, ...)
	return (self.DruidMana.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local OnDruidManaUpdate
do
	local UnitPower = UnitPower
	OnDruidManaUpdate = function(self)
		local unit = self.__owner.unit
		local mana = UnitPower(unit, SPELL_POWER_MANA)

		if(mana ~= self.min) then
			self.min = mana
			return Path(self.__owner, 'OnDruidManaUpdate', unit)
		end
	end
end

local Enable = function(self, unit)
	local druidmana = self.DruidMana
	if(druidmana and unit == 'player') then
		druidmana.__owner = self
		druidmana.ForceUpdate = ForceUpdate

		if(druidmana.frequentUpdates) then
			druidmana:SetScript('OnUpdate', OnDruidManaUpdate)
		else
			self:RegisterEvent('UNIT_POWER', Path)
		end

		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		if(druidmana:IsObjectType'StatusBar' and not druidmana:GetStatusBarTexture()) then
			druidmana:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local druidmana = self.DruidMana
	if(druidmana) then
		if(druidmana:GetScript'OnUpdate') then
			druidmana:SetScript("OnUpdate", nil)
		else
			self:UnregisterEvent('UNIT_POWER', Path)
		end

		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
	end
end

oUF:AddElement('DruidMana', Path, Enable, Disable)
