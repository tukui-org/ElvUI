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

.frequentUpdates                  - Indicates whether to use UNIT_POWER_FREQUENT instead UNIT_POWER_UPDATE to update the
                                    bar (boolean)
.displayPairs                     - Use to override display pairs. (table)
.smoothGradient                   - 9 color values to be used with the .colorSmooth option (table)
.considerSelectionInCombatHostile - Indicates whether selection should be considered hostile while the unit is in
                                    combat with the player (boolean)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorDisconnected - Use `self.colors.disconnected` to color the bar if the unit is offline (boolean)
.colorTapping      - Use `self.colors.tapping` to color the bar if the unit isn't tapped by the player (boolean)
.colorThreat       - Use `self.colors.threat[threat]` to color the bar based on the unit's threat status. `threat` is
                     defined by the first return of [UnitThreatSituation](https://wow.gamepedia.com/API_UnitThreatSituation) (boolean)
.colorPower        - Use `self.colors.power[token]` to color the bar based on the player's additional power type
                     (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorClassPet     - Use `self.colors.class[class]` to color the bar if the unit is player controlled, but not a player
                     (boolean)
.colorSelection    - Use `self.colors.selection[selection]` to color the bar based on the unit's selection color.
                     `selection` is defined by the return value of Private.UnitSelectionType, a wrapper function
                     for [UnitSelectionType](https://wow.gamepedia.com/API_UnitSelectionType) (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction.html) (boolean)
.colorSmooth       - Use `self.colors.smooth` to color the bar with a smooth gradient based on the player's current
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

local function UpdateColor(self, event, unit, powertype)
	if(not (unit and UnitIsUnit(unit, 'player') and powertype == ADDITIONAL_POWER_BAR_NAME)) then return end
	local element = self.AdditionalPower

	local r, g, b, t
	if(element.colorDisconnected and element.disconnected) then
		t = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = self.colors.tapped
	elseif(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		t =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorPower) then
		t = self.colors.power[ADDITIONAL_POWER_BAR_INDEX]
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(element.colorSelection and UnitSelectionType(unit, element.considerSelectionInCombatHostile)) then
		t = self.colors.selection[UnitSelectionType(unit, element.considerSelectionInCombatHostile)]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, 'player')]
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

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function ColorPath(self, ...)
	--[[ Override: AdditionalPower.UpdateColor(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AdditionalPower.UpdateColor or UpdateColor) (self, ...)
end

local function Update(self, event, unit, powertype)
	if(not (unit and UnitIsUnit(unit, 'player') and powertype == ADDITIONAL_POWER_BAR_NAME)) then return end

	local element = self.AdditionalPower
	--[[ Callback: AdditionalPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX)
	local max = UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	local disconnected = not UnitIsConnected(unit)

	element:SetMinMaxValues(0, max)

	if(disconnected) then
		element:SetValue(max)
	else
		element:SetValue(cur)
	end

	element.cur = cur
	element.max = max
	element.disconnected = disconnected

	--[[ Callback: AdditionalPower:PostUpdate(unit, cur, max)
	Called after the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the current value of the player's additional power (number)
	* max  - the maximum value of the player's additional power (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event) -- ElvUI adds event
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

	ColorPath(self, ...)
end

local function ElementEnable(self)
	local element = self.AdditionalPower

	if(element.colorDisconnected) then
		self:RegisterEvent('UNIT_CONNECTION', ColorPath)
	end

	if(element.colorSelection) then
		self:RegisterEvent('UNIT_FLAGS', ColorPath)
	end

	if(element.colorTapping) then
		self:RegisterEvent('UNIT_FACTION', ColorPath)
	end

	if(element.colorThreat) then
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
	end

	if(element.frequentUpdates) then
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	else
		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
	end

	self:RegisterEvent('UNIT_MAXPOWER', Path)

	element:Show()

	-- ElvUI block
	if element.PostUpdateVisibility then
		element:PostUpdateVisibility(true, not element.isEnabled)
	end

	element.isEnabled = true
	-- end block

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_POWER_UPDATE', Path)
	self:UnregisterEvent('UNIT_CONNECTION', ColorPath)
	self:UnregisterEvent('UNIT_FACTION', ColorPath)
	self:UnregisterEvent('UNIT_FLAGS', ColorPath)
	self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)

	self.AdditionalPower:Hide()

	-- ElvUI block
	local element = self.AdditionalPower
	if element.PostUpdateVisibility then
		element:PostUpdateVisibility(false, element.isEnabled)
	end

	element.isEnabled = nil
	-- end block

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
	(self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

--[[ Power:SetColorDisconnected(state)
Used to toggle coloring if the unit is offline.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorDisconnected(element, state)
	if(element.colorDisconnected ~= state) then
		element.colorDisconnected = state
		if(element.colorDisconnected) then
			element.__owner:RegisterEvent('UNIT_CONNECTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_CONNECTION', ColorPath)
		end
	end
end

--[[ Power:SetColorSelection(state)
Used to toggle coloring by the unit's selection.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorSelection(element, state)
	if(element.colorSelection ~= state) then
		element.colorSelection = state
		if(element.colorSelection) then
			element.__owner:RegisterEvent('UNIT_FLAGS', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FLAGS', ColorPath)
		end
	end
end

--[[ Power:SetColorTapping(state)
Used to toggle coloring if the unit isn't tapped by the player.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorTapping(element, state)
	if(element.colorTapping ~= state) then
		element.colorTapping = state
		if(element.colorTapping) then
			element.__owner:RegisterEvent('UNIT_FACTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FACTION', ColorPath)
		end
	end
end

--[[ Power:SetColorThreat(state)
Used to toggle coloring by the unit's threat status.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorThreat(element, state)
	if(element.colorThreat ~= state) then
		element.colorThreat = state
		if(element.colorThreat) then
			element.__owner:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end
	end
end

--[[ Power:SetFrequentUpdates(state)
Used to toggle frequent updates.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetFrequentUpdates(element, state)
	if(element.frequentUpdates ~= state) then
		element.frequentUpdates = state
		if(element.frequentUpdates) then
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
		element.SetColorDisconnected = SetColorDisconnected
		element.SetColorSelection = SetColorSelection
		element.SetColorTapping = SetColorTapping
		element.SetColorThreat = SetColorThreat
		element.SetFrequentUpdates = SetFrequentUpdates

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(not element.displayPairs) then
			element.displayPairs = CopyTable(ALT_MANA_BAR_PAIR_DISPLAY_INFO)
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
