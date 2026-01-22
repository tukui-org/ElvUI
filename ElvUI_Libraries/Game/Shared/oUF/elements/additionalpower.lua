--[[
# Element: Additional Power Bar

Handles the visibility and updating of a status bar that displays the player's additional power, such as Mana for
Balance druids.

## Widget

AdditionalPower - A `StatusBar` that is used to display the player's additional power.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.displayPairs    - Use to override display pairs. (table)
.smoothing       - Which status bar smoothing method to use, defaults to `Enum.StatusBarInterpolation.Immediate` (number)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorPower       - Use `self.colors.power[token]` to color the bar based on the player's additional power type
                    (boolean)
.colorPowerSmooth - Use color curve from `self.colors.power[token]` to color the bar with a smooth gradient based on the
                    player's current power percentage. Requires `.colorPower` to be enabled (boolean)
.colorClass       - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                    second return of [UnitClass](https://warcraft.wiki.gg/wiki/API_UnitClass) (boolean)

## Examples

    -- Position and size
    local AdditionalPower = CreateFrame('StatusBar', nil, self)
    AdditionalPower:SetSize(20, 20)
    AdditionalPower:SetPoint('TOP')
    AdditionalPower:SetPoint('LEFT')
    AdditionalPower:SetPoint('RIGHT')

    -- Register it with oUF
    self.AdditionalPower = AdditionalPower
--]]

local _, ns = ...
local oUF = ns.oUF

local unpack = unpack

local CopyTable = CopyTable
local UnitIsUnit = UnitIsUnit
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitPowerType = UnitPowerType
local UnitPowerPercent = UnitPowerPercent

local StatusBarInterpolation = Enum.StatusBarInterpolation

-- sourced from Blizzard_UnitFrame/AlternatePowerBar.lua
local POWER_NAME = _G.ADDITIONAL_POWER_BAR_NAME or 'MANA'
local POWER_INDEX = _G.ADDITIONAL_POWER_BAR_INDEX or 0
local ALT_POWER_INFO = _G.ALT_POWER_BAR_PAIR_DISPLAY_INFO or _G.ALT_MANA_BAR_PAIR_DISPLAY_INFO or {DRUID={[8]=true}, SHAMAN={[11]=true}, PRIEST={[13]=true}}
-- NOTE: ALT_POWER and ALT_MANA have different table structures! so update this later if needed.

local function UpdateColor(self, event, unit, powerType)
	if(not (unit and UnitIsUnit(unit, 'player') and powerType == POWER_NAME)) then return end
	local element = self.AdditionalPower

	local color
	if(element.colorPower) then
		color = self.colors.power[POWER_INDEX]

		if(element.colorPowerSmooth) then
			if oUF.isRetail then
				local curve = color:GetCurve()
				if curve then
					color = UnitPowerPercent(unit, true, curve)
				end
			else
				local curValue, maxValue = element.cur or 1, element.max or 1
				local r, g, b = oUF:ColorGradient(maxValue == 0 and 0 or (curValue / maxValue), unpack(element.smoothGradient or self.colors.smooth))
				self.colors.smooth:SetRGB(r, g, b)

				color = self.colors.smooth
			end
		end
	elseif(element.colorClass) then
		color = self.colors.class[oUF.myclass]
	end

	if(color) then
		element:GetStatusBarTexture():SetVertexColor(color:GetRGB())
	end

	--[[ Callback: AdditionalPower:PostUpdateColor(color)
	Called after the element color has been updated.

	* self  - the AdditionalPower element
	* color - the used ColorMixin-based object (table?)
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, color)
	end
end

local function Update(self, event, unit, powerType)
	if(not (unit and UnitIsUnit(unit, 'player') and powerType == POWER_NAME)) then return end
	local element = self.AdditionalPower

	--[[ Callback: AdditionalPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitPower('player', POWER_INDEX), UnitPowerMax('player', POWER_INDEX)
	element:SetMinMaxValues(0, max)

	element:SetValue(cur, element.smoothing)

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

	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	element:Show()
	element.__isEnabled = true

	Path(self, 'ElementEnable', 'player', POWER_NAME)
end

local function ElementDisable(self)
	local element = self.AdditionalPower

	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	element:Hide()
	element.__isEnabled = false

	Path(self, 'ElementDisable', 'player', POWER_NAME)
end

local function Visibility(self, event, unit)
	local element = self.AdditionalPower
	local shouldEnable

	if (oUF.isClassic or oUF.isTBC) or not UnitHasVehicleUI('player') then
		local allowed = element.displayPairs[oUF.myclass]
		if allowed and UnitPowerMax(unit, POWER_INDEX) ~= 0 then
			shouldEnable = allowed[UnitPowerType(unit)]
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
		Path(self, event, unit, POWER_NAME)
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
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AdditionalPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(not element.smoothing) then
			element.smoothing = StatusBarInterpolation and StatusBarInterpolation.Immediate or nil
		end

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(not element.displayPairs) then
			element.displayPairs = CopyTable(ALT_POWER_INFO)
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
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
