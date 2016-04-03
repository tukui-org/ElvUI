--[[ Element: Alternative Power Bar

 Handles visibility and updating of the alternative power bar.

 This bar is used to display encounter/quest related power information, such as
 the number of hour glass uses left on the end boss in End Time.

 Widget

 AltPowerBar - A StatusBar to represent alternative power.

 Options

 .colorTexture     - Use the vertex color values returned by
                     UnitAlternatePowerTextureInfo to color the bar.

 Notes

 OnEnter and OnLeave handlers to display a tooltip will be set on the widget if
 it is mouse enabled.

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

--[[ :UpdateTooltip()

 The function called when the widget is hovered. Used to populate the tooltip.

 Arguments

 self - The AltPowerBar element.
]]
local UpdateTooltip = function(self)
	GameTooltip:SetText(self.powerName, 1, 1, 1)
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
	GameTooltip:Show()
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:UpdateTooltip()
end

local OnLeave = function()
	GameTooltip:Hide()
end

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

	local _, r, g, b
	if(altpowerbar.colorTexture) then
		_, r, g, b = UnitAlternatePowerTextureInfo(unit, 2)
	end

	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

	local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo(unit)
	altpowerbar.barType = barType
	altpowerbar.powerName = powerName
	altpowerbar.powerTooltip = powerTooltip
	altpowerbar:SetMinMaxValues(min, max)
	altpowerbar:SetValue(math.min(math.max(cur, min), max))

	if(b) then
		altpowerbar:SetStatusBarColor(r, g, b)
	end

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


--[[ Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]
local Path = function(self, ...)
	return (self.AltPowerBar.Override or UpdatePower)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'ALTERNATE')
end

local Toggler = function(self, event, unit)
	if(unit ~= self.unit) then return end
	local altpowerbar = self.AltPowerBar

	local barType, _, _, _, _, hideFromOthers, showOnRaid = UnitAlternatePowerInfo(unit)
	if(barType and (showOnRaid and (UnitInParty(unit) or UnitInRaid(unit)) or not hideFromOthers or unit == 'player' or self.realUnit == 'player')) then
		self:RegisterEvent('UNIT_POWER', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		ForceUpdate(altpowerbar)
		altpowerbar:Show()
	else
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

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

		if(altpowerbar:IsMouseEnabled()) then
			if(not altpowerbar:GetScript('OnEnter')) then
				altpowerbar:SetScript('OnEnter', OnEnter)
			end

			if(not altpowerbar:GetScript('OnLeave')) then
				altpowerbar:SetScript('OnLeave', OnLeave)
			end

			if(not altpowerbar.UpdateTooltip) then
				altpowerbar.UpdateTooltip = UpdateTooltip
			end
		end

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
		altpowerbar:Hide()
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
