--[[
# Element: Additional Power Bar

Handles the visibility and updating of a status bar that displays the player's additional power, such as Mana for
Balance druids.

## Widget

AdditionalPower - A `StatusBar` that is used to display the player's additional power.

## Sub-Widgets

.bg - A `Texture` used as a background. Inherits the widget's color.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.smoothGradient - 9 color values to be used with the .colorSmooth option (table)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorClass   - Use `self.colors.class[class]` to color the bar based on the player's class. (boolean)
.colorSmooth  - Use `self.colors.smooth` to color the bar with a smooth gradient based on the player's current additional
               power percentage (boolean)
.colorPower   - Use `self.colors.power[token]` to color the bar based on the player's additional power type. (boolean)
.displayPairs - Use to override display pairs. (table)

## Sub-Widget Options

.multiplier - Used to tint the background based on the widget's R, G and B values. Defaults to 1 (number)[0-1]

## Examples

    -- Position and size
    local AdditionalPower = CreateFrame('StatusBar', nil, self)
    AdditionalPower:SetSize(20, 20)
    AdditionalPower:SetPoint('TOP')
    AdditionalPower:SetPoint('LEFT')
    AdditionalPower:SetPoint('RIGHT')

    -- Add a background
    local Background = AdditionalPower:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(AdditionalPower)
    Background:SetTexture(1, 1, 1, .5)

    -- Register it with oUF
    AdditionalPower.bg = Background
    self.AdditionalPower = AdditionalPower
--]]

local _, ns = ...
local oUF = ns.oUF

local _, playerClass = UnitClass('player')

-- sourced from FrameXML/AlternatePowerBar.lua
local ADDITIONAL_POWER_BAR_NAME = ADDITIONAL_POWER_BAR_NAME or 'MANA'
local ADDITIONAL_POWER_BAR_INDEX = ADDITIONAL_POWER_BAR_INDEX or 0
local ALT_MANA_BAR_PAIR_DISPLAY_INFO = ALT_MANA_BAR_PAIR_DISPLAY_INFO

local function UpdateColor(element, cur, max)
	local parent = element.__owner

	local r, g, b, t
	if(element.colorClass) then
		t = parent.colors.class[playerClass]
	elseif(element.colorSmooth) then
		r, g, b = parent:ColorGradient(cur, max, unpack(element.smoothGradient or parent.colors.smooth))
	elseif(element.colorPower) then
		t = parent.colors.power[ADDITIONAL_POWER_BAR_NAME]
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
end

local function Update(self, event, unit, powertype)
	if(not (unit and UnitIsUnit(unit, 'player') and powertype == ADDITIONAL_POWER_BAR_NAME)) then return end

	local element = self.AdditionalPower
	--[[ Callback: AdditionalPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX)
	local max = UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	--[[ Override: AdditionalPower:UpdateColor(cur, max)
	Used to completely override the internal function for updating the widget's colors.

	* self - the AdditionalPower element
	* cur  - the current value of the player's additional power (number)
	* max  - the maximum value of the player's additional power (number)
	--]]
	element:UpdateColor(cur, max)

	--[[ Callback: AdditionalPower:PostUpdate(unit, cur, max)
	Called after the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the current value of the player's additional power (number)
	* max  - the maximum value of the player's additional power (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	--[[ Override: AdditionalPower.Override(self, event, unit, ...)
	Used to completely override the element's update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.AdditionalPower.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Show()

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Hide()

	Path(self, 'ElementDisable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function Visibility(self, event, unit)
	local element = self.AdditionalPower
	local shouldEnable

	if(not UnitHasVehicleUI('player')) then
		if(UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX) ~= 0) then
			if(element.displayPairs[playerClass]) then
				local powerType = UnitPowerType(unit)
				shouldEnable = element.displayPairs[playerClass][powerType]
			end
		end
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: AdditionalPower.OverrideVisibility(self, event, unit)
	Used to completely override the element's visibility update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AdditionalPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(not element.displayPairs) then
			element.displayPairs = CopyTable(ALT_MANA_BAR_PAIR_DISPLAY_INFO)
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		return true
	end
end

local function Disable(self)
	local element = self.AdditionalPower
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement('AdditionalPower', VisibilityPath, Enable, Disable)
