--[[ Element: Additional Power Bar
 Handles updating and visibility of a status bar displaying the player's
 alternate/additional power, such as Mana for Balance druids.

 Widget

 AdditionalPower - A StatusBar to represent current caster mana.

 Sub-Widgets

 .bg - A Texture which functions as a background. It will inherit the color of
       the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
 status bar texture or color defined.

 Options

 .colorClass  - Use `self.colors.class[class]` to color the bar.
 .colorSmooth - Use `self.colors.smooth` to color the bar with a smooth
                gradient based on the players current mana percentage.
 .colorPower  - Use `self.colors.power[token]` to color the bar. This will
                always use MANA as token.

 Sub-Widget Options

 .multiplier - Defines a multiplier, which is used to tint the background based
               on the main widgets R, G and B values. Defaults to 1 if not
               present.

 Examples

   -- Position and size
   local AdditionalPower = CreateFrame("StatusBar", nil, self)
   AdditionalPower:SetSize(20, 20)
   AdditionalPower:SetPoint('TOP')
   AdditionalPower:SetPoint('LEFT')
   AdditionalPower:SetPoint('RIGHT')
   
   -- Add a background
   local Background = AdditionalPower:CreateTexture(nil, 'BACKGROUND')
   Background:SetAllPoints(AdditionalPower)
   Background:SetTexture(1, 1, 1, .5)
   
   -- Register it with oUF
   self.AdditionalPower = AdditionalPower
   self.AdditionalPower.bg = Background

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.

]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = select(2, UnitClass('player'))

local ADDITIONAL_POWER_BAR_NAME = ADDITIONAL_POWER_BAR_NAME
local ADDITIONAL_POWER_BAR_INDEX = ADDITIONAL_POWER_BAR_INDEX

local function Update(self, event, unit, powertype)
	if(unit ~= 'player' or (powertype and powertype ~= ADDITIONAL_POWER_BAR_NAME)) then return end

	local element = self.AdditionalPower
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX)
	local max = UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	local r, g, b, t
	if(element.colorClass) then
		t = self.colors.class[playerClass]
	elseif(element.colorSmooth) then
		r, g, b = self.ColorGradient(cur, max, unpack(element.smoothGradient or self.colors.smooth))
	elseif(element.colorPower) then
		t = self.colors.power[ADDITIONAL_POWER_BAR_NAME]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.AdditionalPower.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Show()

	if self.AdditionalPower.PostUpdateVisibility then
		self.AdditionalPower:PostUpdateVisibility(true, not self.AdditionalPower.isEnabled)
	end
	
	self.AdditionalPower.isEnabled = true

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Hide()
	
	if self.AdditionalPower.PostUpdateVisibility then
		self.AdditionalPower:PostUpdateVisibility(false, self.AdditionalPower.isEnabled)
	end

	self.AdditionalPower.isEnabled = nil

	Path(self, 'ElementDisable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function Visibility(self, event, unit)
	local shouldEnable

	if(not UnitHasVehicleUI('player')) then
		if(UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX) ~= 0) then
			if(ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass]) then
				local powerType = UnitPowerType(unit)
				shouldEnable = ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass][powerType]
			end
		end
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local VisibilityPath = function(self, ...)
	return (self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local element = self.AdditionalPower
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(element:IsObjectType'StatusBar' and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local element = self.AdditionalPower
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement('AdditionalPower', VisibilityPath, Enable, Disable)
