--[[ Element: Alternative Power Bar

 Handles visibility and updating of the alternative power bar.

 This bar is used to display encounter/quest related power information, such as
 the number of hour glass uses left on the end boss in End Time.

 Widget

 AltPowerBar - A StatusBar to represent alternative power.

 Examples

   -- Position and size
   local AltPowerBar = CreateFrame('StatusBar', nil, self)
   AltPowerBar:SetHeight(20)
   AltPowerBar:SetPoint('BOTTOM')
   AltPowerBar:SetPoint('LEFT')
   AltPowerBar:SetPoint('RIGHT')
   
   -- Register with oUF
   self.AltPowerBar = AltPowerBar

 Callbacks
]]

local parent, ns = ...
local oUF = ns.oUF

local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX

local UpdatePower = function(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= 'ALTERNATE') then return end

	local altpowerbar = self.AltPowerBar

	--[[ :PreUpdate()

	 Called before the element has been updated.

	 Arguments

	 self - The AltPowerBar element.
	 ]]
	if(altpowerbar.PreUpdate) then
		altpowerbar:PreUpdate()
	end

	local barType, min = UnitAlternatePowerInfo(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

	altpowerbar.barType = barType
	altpowerbar:SetMinMaxValues(min, max)
	altpowerbar:SetValue(cur)

	--[[ :PostUpdate(min, cur, max)

	 Called after the element has been updated.

	 Arguments

	 self - The AltPowerBar element.
	 min  - The minimum possible power value for the active type.
	 cur  - The current power value.
	 max  - The maximum possible power value for the active type.
	]]
	if(altpowerbar.PostUpdate) then
		return altpowerbar:PostUpdate(min, cur, max)
	end
end

local ForceUpdate = function(element)
	return UpdatePower(element.__owner, 'ForceUpdate', element.__owner.unit, 'ALTERNATE')
end

local Toggler = function(self, event, unit)
	if(unit ~= self.unit) then return end
	local altpowerbar = self.AltPowerBar

	local barType, minPower, _, _, _, hideFromOthers = UnitAlternatePowerInfo(unit)
	if(barType and (not hideFromOthers or unit == 'player' or self.realUnit == 'player')) then
		self:RegisterEvent('UNIT_POWER', UpdatePower)
		self:RegisterEvent('UNIT_MAXPOWER', UpdatePower)

		ForceUpdate(altpowerbar)
		altpowerbar:Show()
	else
		self:UnregisterEvent('UNIT_POWER', UpdatePower)
		self:UnregisterEvent('UNIT_MAXPOWER', UpdatePower)

		altpowerbar:Hide()
	end
end

local Enable = function(self, unit)
	local altpowerbar = self.AltPowerBar
	if(altpowerbar) then
		altpowerbar.__owner = self
		altpowerbar.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Toggler)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Toggler)

		altpowerbar:Hide()

		if(unit == 'player') then
			PlayerPowerBarAlt:UnregisterEvent'UNIT_POWER_BAR_SHOW'
			PlayerPowerBarAlt:UnregisterEvent'UNIT_POWER_BAR_HIDE'
			PlayerPowerBarAlt:UnregisterEvent'PLAYER_ENTERING_WORLD'
		end

		return true
	end
end

local Disable = function(self, unit)
	local altpowerbar = self.AltPowerBar
	if(altpowerbar) then
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Toggler)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Toggler)

		if(unit == 'player') then
			PlayerPowerBarAlt:RegisterEvent'UNIT_POWER_BAR_SHOW'
			PlayerPowerBarAlt:RegisterEvent'UNIT_POWER_BAR_HIDE'
			PlayerPowerBarAlt:RegisterEvent'PLAYER_ENTERING_WORLD'
		end
	end
end

oUF:AddElement('AltPowerBar', Toggler, Enable, Disable)
