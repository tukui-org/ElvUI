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

.frequentUpdates - Indicates whether to use UNIT_POWER_FREQUENT instead UNIT_POWER_UPDATE to update the bar (boolean)
.displayPairs    - Use to override display pairs. (table)
.smoothGradient  - 9 color values to be used with the .colorSmooth option (table)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorPower  - Use `self.colors.power[token]` to color the bar based on the player's additional power type
               (boolean)
.colorClass  - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
               second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)
.colorSmooth - Use `self.colors.smooth` to color the bar with a smooth gradient based on the player's current
               additional power percentage (boolean)

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

-- ElvUI block
local unpack = unpack
local CopyTable = CopyTable
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitThreatSituation = UnitThreatSituation
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitSelectionType = UnitSelectionType
local UnitReaction = UnitReaction
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitIsConnected = UnitIsConnected
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitPowerType = UnitPowerType
-- end block

-- sourced from FrameXML/AlternatePowerBar.lua
local ADDITIONAL_POWER_BAR_NAME = ADDITIONAL_POWER_BAR_NAME or 'MANA'
local ADDITIONAL_POWER_BAR_INDEX = ADDITIONAL_POWER_BAR_INDEX or 0
local ALT_MANA_BAR_PAIR_DISPLAY_INFO = ALT_MANA_BAR_PAIR_DISPLAY_INFO

local function UpdateColor(self, event, unit, powerType)
	if(not (unit and UnitIsUnit(unit, 'player') and powerType == ADDITIONAL_POWER_BAR_NAME)) then return end
	local element = self.AdditionalPower

	local r, g, b, t
	if(element.colorPower) then
		t = self.colors.power[ADDITIONAL_POWER_BAR_INDEX]
	elseif(element.colorClass) then
		t = self.colors.class[playerClass]
	elseif(element.colorSmooth) then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
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

	--[[ Callback: AdditionalPower:PostUpdateColor(r, g, b)
	Called after the element color has been updated.

	* self - the AdditionalPower element
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(r, g, b)
	end
end

local function Update(self, event, unit, powerType)
	if(not (unit and UnitIsUnit(unit, 'player') and powerType == ADDITIONAL_POWER_BAR_NAME)) then return end
	local element = self.AdditionalPower

	--[[ Callback: AdditionalPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX), UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	element:SetMinMaxValues(0, max)

	element:SetValue(cur)

	element.cur = cur
	element.max = max

	--[[ Callback: AdditionalPower:PostUpdate(cur, max)
	Called after the element has been updated.

	* self - the AdditionalPower element
	* cur  - the current value of the player's additional power (number)
	* max  - the maximum value of the player's additional power (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, event) -- ElvUI adds event
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
	(self.AdditionalPower.Override or Update) (self, ...);

	--[[ Override: AdditionalPower.UpdateColor(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AdditionalPower.UpdateColor or UpdateColor) (self, ...)
end

local function ElementEnable(self)
	local element = self.AdditionalPower

	if(element.frequentUpdates) then
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	else
		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
	end

	self:RegisterEvent('UNIT_MAXPOWER', Path)

	element:Show()

	element.__isEnabled = true

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	local element = self.AdditionalPower

	self:UnregisterEvent('UNIT_MAXPOWER', Path)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_POWER_UPDATE', Path)

	element:Hide()

	element.__isEnabled = false
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

	local isEnabled = element.__isEnabled

	if(shouldEnable and not isEnabled) then
		ElementEnable(self)

		--[[ Callback: AdditionalPower:PostVisibility(isVisible)
		Called after the element's visibility has been changed.

		* self      - the AdditionalPower element
		* isVisible - the current visibility state of the element (boolean)
		--]]
		if(element.PostVisibility) then
			element:PostVisibility(true)
		end
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ElementDisable(self)

		if(element.PostVisibility) then
			element:PostVisibility(false)
		end
	elseif(shouldEnable and isEnabled) then
		Path(self, event, unit, ADDITIONAL_POWER_BAR_NAME)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: AdditionalPower.OverrideVisibility(self, event, unit)
	Used to completely override the element's visibility update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

--[[ Power:SetFrequentUpdates(state, isForced)
Used to toggle frequent updates.

* self  - the Power element
* state - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetFrequentUpdates(element, state, isForced)
	if(element.frequentUpdates ~= state or isForced) then
		element.frequentUpdates = state
		if(state) then
			element.__owner:UnregisterEvent('UNIT_POWER_UPDATE', Path)
			element.__owner:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		else
			element.__owner:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
			element.__owner:RegisterEvent('UNIT_POWER_UPDATE', Path)
		end
	end
end

local function Enable(self, unit)
	local element = self.AdditionalPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetFrequentUpdates = SetFrequentUpdates

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(not element.displayPairs) then
			element.displayPairs = CopyTable(ALT_MANA_BAR_PAIR_DISPLAY_INFO)
		end

		if(element:IsObjectType('StatusBar') and not (element:GetStatusBarTexture() or element:GetStatusBarAtlas())) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
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
