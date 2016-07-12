--[[ Element: Druid Mana Bar
 Handles updating and visibility of a status bar displaying the player's
 alternate/additional power, such as Mana for Balance druids.

 Widget

 DruidMana - A StatusBar to represent current caster mana.

 Sub-Widgets

 .bg - A Texture which functions as a background. It will inherit the color of
       the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
 status bar texture or color defined.

 Options

 .colorClass  - Use `self.colors.class[class]` to color the bar. This will
                always use DRUID as class.
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
   local DruidMana = CreateFrame("StatusBar", nil, self)
   DruidMana:SetSize(20, 20)
   DruidMana:SetPoint('TOP')
   DruidMana:SetPoint('LEFT')
   DruidMana:SetPoint('RIGHT')
   
   -- Add a background
   local Background = DruidMana:CreateTexture(nil, 'BACKGROUND')
   Background:SetAllPoints(DruidMana)
   Background:SetTexture(1, 1, 1, .5)
   
   -- Register it with oUF
   self.DruidMana = DruidMana
   self.DruidMana.bg = Background

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.

]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = select(2, UnitClass('player'))
local isBetaClient = select(4, GetBuildInfo()) >= 70000

local ADDITIONAL_POWER_BAR_NAME = ADDITIONAL_POWER_BAR_NAME
local ADDITIONAL_POWER_BAR_INDEX = ADDITIONAL_POWER_BAR_INDEX

local function Update(self, event, unit, powertype)
	if(unit ~= 'player' or (powertype and powertype ~= ADDITIONAL_POWER_BAR_NAME)) then return end

	local druidmana = self.DruidMana
	if(druidmana.PreUpdate) then druidmana:PreUpdate(unit) end

	-- Hide the bar if the active power type is the same as the alternate.
	if(UnitPowerType('player') == ADDITIONAL_POWER_BAR_INDEX) then
		return druidmana:Hide()
	elseif (not event) or (event and event ~= "ElementDisable") then
		druidmana:Show()
	end

	local cur = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX)
	local max = UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	druidmana:SetMinMaxValues(0, max)
	druidmana:SetValue(cur)

	local r, g, b, t
	if(druidmana.colorClass) then
		t = self.colors.class[playerClass]
	elseif(druidmana.colorSmooth) then
		r, g, b = self.ColorGradient(cur, max, unpack(druidmana.smoothGradient or self.colors.smooth))
	elseif(druidmana.colorPower) then
		t = self.colors.power[ADDITIONAL_POWER_BAR_NAME]
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
		return druidmana:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.DruidMana.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	self.DruidMana:Show()

	if self.DruidMana.PostUpdateVisibility then
		self.DruidMana:PostUpdateVisibility(true, not self.DruidMana.isEnabled)
	end
	
	self.DruidMana.isEnabled = true

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	self.DruidMana:Hide()
	
	if self.DruidMana.PostUpdateVisibility then
		self.DruidMana:PostUpdateVisibility(false, self.DruidMana.isEnabled)
	end

	self.DruidMana.isEnabled = nil

	Path(self, 'ElementDisable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function Visibility(self, event, unit)
	local druidmana = self.DruidMana
	local shouldEnable

	if(not UnitHasVehicleUI('player')) then
		if(UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX) ~= 0) then
			if(isBetaClient) then
				if (playerClass == "DRUID" and GetSpecialization() == 1) or (playerClass ~= "DRUID") then
					if(ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass]) then
						local powerType = UnitPowerType(unit)
						shouldEnable = ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass][powerType]
					end
				end
			else
				if(playerClass == 'DRUID' and UnitPowerType(unit) == ADDITIONAL_POWER_BAR_INDEX) then
					shouldEnable = true
				end
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
	return (self.DruidMana.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local druidmana = self.DruidMana
	if(druidmana and unit == 'player') then
		druidmana.__owner = self
		druidmana.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(druidmana:IsObjectType'StatusBar' and not druidmana:GetStatusBarTexture()) then
			druidmana:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local druidmana = self.DruidMana
	if(druidmana) then
		ElementDisable(self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement('DruidMana', VisibilityPath, Enable, Disable)
