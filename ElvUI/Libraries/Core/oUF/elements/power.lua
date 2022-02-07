--[[
# Element: Power Bar

Handles the updating of a status bar that displays the unit's power.

## Widget

Power - A `StatusBar` used to represent the unit's power.

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture or a color set.

## Options

.frequentUpdates                  - Indicates whether to use UNIT_POWER_FREQUENT instead UNIT_POWER_UPDATE to update the
                                    bar (boolean)
.displayAltPower                  - Use this to let the widget display alternative power, if the unit has one.
                                    By default, it does so only for raid and party units. If none, the display will fall
                                    back to the primary power (boolean)
.useAtlas                         - Use this to let the widget use an atlas for its texture if an atlas is present in
                                    `self.colors.power` for the appropriate power type (boolean)
.smoothGradient                   - 9 color values to be used with the .colorSmooth option (table)
.considerSelectionInCombatHostile - Indicates whether selection should be considered hostile while the unit is in
                                    combat with the player (boolean)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorDisconnected - Use `self.colors.disconnected` to color the bar if the unit is offline (boolean)
.colorTapping      - Use `self.colors.tapping` to color the bar if the unit isn't tapped by the player (boolean)
.colorThreat       - Use `self.colors.threat[threat]` to color the bar based on the unit's threat status. `threat` is
                     defined by the first return of [UnitThreatSituation](https://wow.gamepedia.com/API_UnitThreatSituation) (boolean)
.colorPower        - Use `self.colors.power[token]` to color the bar based on the unit's power type. This method will
                     fall-back to `:GetAlternativeColor()` if it can't find a color matching the token. If this function
                     isn't defined, then it will attempt to color based upon the alternative power colors returned by
                     [UnitPowerType](http://wowprogramming.com/docs/api/UnitPowerType.html). If these aren't
                     defined, then it will attempt to color the bar based upon `self.colors.power[type]`. In case of
                     failure it'll default to `self.colors.power.MANA` (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorClassPet     - Use `self.colors.class[class]` to color the bar if the unit is player controlled, but not a player
                     (boolean)
.colorSelection    - Use `self.colors.selection[selection]` to color the bar based on the unit's selection color.
                     `selection` is defined by the return value of Private.unitSelectionType, a wrapper function
                     for [UnitSelectionType](https://wow.gamepedia.com/API_UnitSelectionType) (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction.html) (boolean)
.colorSmooth       - Use `smoothGradient` if present or `self.colors.smooth` to color the bar with a smooth gradient
                     based on the player's current power percentage (boolean)

## Sub-Widget Options

.multiplier - A multiplier used to tint the background based on the main widgets R, G and B values. Defaults to 1
              (number)[0-1]

## Examples

    -- Position and size
    local Power = CreateFrame('StatusBar', nil, self)
    Power:SetHeight(20)
    Power:SetPoint('BOTTOM')
    Power:SetPoint('LEFT')
    Power:SetPoint('RIGHT')

    -- Add a background
    local Background = Power:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Power)
    Background:SetTexture(1, 1, 1, .5)

    -- Options
    Power.frequentUpdates = true
    Power.colorTapping = true
    Power.colorDisconnected = true
    Power.colorPower = true
    Power.colorClass = true
    Power.colorReaction = true

    -- Make the background darker.
    Background.multiplier = .5

    -- Register it with oUF
    Power.bg = Background
    self.Power = Power
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitSelectionType = Private.unitSelectionType

-- sourced from FrameXML/UnitPowerBarAlt.lua
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10

--[[ Override: Power:GetDisplayPower()
Used to get info on the unit's alternative power, if any.
Should return the power type index (see [Enum.PowerType.Alternate](https://wow.gamepedia.com/Enum_Unit.PowerType))
and the minimum value for the given power type (see [info.minPower](https://wow.gamepedia.com/API_GetUnitPowerBarInfo))
or nil if the unit has no alternative (alternate) power or it should not be
displayed. In case of a nil return, the element defaults to the primary power
type and zero for the minimum value.

* self - the Power element
--]]
local function GetDisplayPower(element)
	local unit = element.__owner.unit
	local barInfo = GetUnitPowerBarInfo(unit)
	if(barInfo and barInfo.showOnRaid and (UnitInParty(unit) or UnitInRaid(unit))) then
		return ALTERNATE_POWER_INDEX, barInfo.minPower
	end
end

local function UpdateColor(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.Power

	local pType, pToken, altR, altG, altB = UnitPowerType(unit)

	local r, g, b, t, atlas
	if(element.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = self.colors.tapped
	elseif(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		t =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorPower) then
		if(element.displayType ~= ALTERNATE_POWER_INDEX) then
			t = self.colors.power[pToken]
			if(not t) then
				if(element.GetAlternativeColor) then
					r, g, b = element:GetAlternativeColor(unit, pType, pToken, altR, altG, altB)
				elseif(altR) then
					r, g, b = altR, altG, altB
					if(r > 1 or g > 1 or b > 1) then
						-- BUG: As of 7.0.3, altR, altG, altB may be in 0-1 or 0-255 range.
						r, g, b = r / 255, g / 255, b / 255
					end
				else
					t = self.colors.power[pType] or self.colors.power.MANA
				end
			end
		else
			t = self.colors.power[ALTERNATE_POWER_INDEX]
		end

		if(element.useAtlas and t and t.atlas) then
			atlas = t.atlas
		end
	elseif(element.colorClass and UnitIsPlayer(unit))
		or (element.colorClassNPC and not UnitIsPlayer(unit))
		or (element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(element.colorSelection and unitSelectionType(unit, element.considerSelectionInCombatHostile)) then
		t = self.colors.selection[unitSelectionType(unit, element.considerSelectionInCombatHostile)]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		local adjust = 0 - (element.min or 0)
		r, g, b = self:ColorGradient((element.cur or 1) + adjust, (element.max or 1) + adjust, unpack(element.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(atlas) then
		element:SetStatusBarAtlas(atlas)
		element:SetStatusBarColor(1, 1, 1)
	elseif(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	--[[ Callback: Power:PostUpdateColor(unit, r, g, b)
	Called after the element color has been updated.

	local bg = element.bg
	if(bg and b) then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end
	--]]

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function ColorPath(self, ...)
	--[[ Override: Power.UpdateColor(self, event, unit)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Power.UpdateColor or UpdateColor) (self, ...)
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.Power

	--[[ Callback: Power:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Power element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local displayType, min
	if(oUF.isRetail and element.displayAltPower) then
		displayType, min = element:GetDisplayPower()
	end

	local cur, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	if not min then min = 0 end

	element:SetMinMaxValues(min, max)

	if(UnitIsConnected(unit)) then
		element:SetValue(cur)
	else
		element:SetValue(max)
	end

	element.cur = cur
	element.min = min
	element.max = max
	element.displayType = displayType

	--[[ Callback: Power:PostUpdate(unit, cur, min, max)
	Called after the element has been updated.

	* self - the Power element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the unit's current power value (number)
	* min  - the unit's minimum possible power value (number)
	* max  - the unit's maximum possible power value (number)
	--]]
	if(element.PostUpdate) then
		element:PostUpdate(unit, cur, min, max)
	end
end

local function Path(self, event, ...)
	if (self.isForced and event ~= 'ElvUI_UpdateAllElements') then return end -- ElvUI changed

	--[[ Override: Power.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Power.Override or Update) (self, event, ...);

	ColorPath(self, event, ...)
end

local function ForceUpdate(element)
	Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

--[[ Power:SetColorDisconnected(state, isForced)
Used to toggle coloring if the unit is offline.

* self     - the Power element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorDisconnected(element, state, isForced)
	if(element.colorDisconnected ~= state or isForced) then
		element.colorDisconnected = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_CONNECTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_CONNECTION', ColorPath)
		end
	end
end

--[[ Power:SetColorSelection(state, isForced)
Used to toggle coloring by the unit's selection.

* self     - the Power element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorSelection(element, state, isForced)
	if(element.colorSelection ~= state or isForced) then
		element.colorSelection = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_FLAGS', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FLAGS', ColorPath)
		end
	end
end

--[[ Power:SetColorTapping(state, isForced)
Used to toggle coloring if the unit isn't tapped by the player.

* self     - the Power element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorTapping(element, state, isForced)
	if(element.colorTapping ~= state or isForced) then
		element.colorTapping = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_FACTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FACTION', ColorPath)
		end
	end
end

--[[ Power:SetColorThreat(state, isForced)
Used to toggle coloring by the unit's threat status.

* self     - the Power element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorThreat(element, state, isForced)
	if(element.colorThreat ~= state or isForced) then
		element.colorThreat = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end
	end
end

--[[ Power:SetFrequentUpdates(state, isForced)
Used to toggle frequent updates.

* self     - the Power element
* state    - the desired state (boolean)
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

local function Enable(self)
	local element = self.Power
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetColorDisconnected = SetColorDisconnected
		element.SetColorSelection = SetColorSelection
		element.SetColorTapping = SetColorTapping
		element.SetColorThreat = SetColorThreat
		element.SetFrequentUpdates = SetFrequentUpdates

		oUF:RegisterEvent(self, 'UNIT_MAXPOWER', Path)

		if(element.frequentUpdates) then
			oUF:RegisterEvent(self, 'UNIT_POWER_FREQUENT', Path)
		else
			oUF:RegisterEvent(self, 'UNIT_POWER_UPDATE', Path)
		end

		if(element.colorDisconnected) then
			oUF:RegisterEvent(self, 'UNIT_CONNECTION', ColorPath)
		end

		if(element.colorSelection) then
			oUF:RegisterEvent(self, 'UNIT_FLAGS', ColorPath)
		end

		if(element.colorTapping) then
			oUF:RegisterEvent(self, 'UNIT_FACTION', ColorPath)
		end

		if(element.colorThreat) then
			oUF:RegisterEvent(self, 'UNIT_THREAT_LIST_UPDATE', ColorPath)
		end

		oUF:RegisterEvent(self, 'UNIT_DISPLAYPOWER', Path)
		oUF:RegisterEvent(self, 'UNIT_POWER_BAR_HIDE', Path)
		oUF:RegisterEvent(self, 'UNIT_POWER_BAR_SHOW', Path)

		if(element:IsObjectType('StatusBar') and not (element:GetStatusBarTexture() or element:GetStatusBarAtlas())) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(oUF.isRetail and not element.GetDisplayPower) then
			element.GetDisplayPower = GetDisplayPower
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Power
	if(element) then
		element:Hide()

		oUF:UnregisterEvent(self, 'UNIT_DISPLAYPOWER', Path)
		oUF:UnregisterEvent(self, 'UNIT_MAXPOWER', Path)
		oUF:UnregisterEvent(self, 'UNIT_POWER_BAR_HIDE', Path)
		oUF:UnregisterEvent(self, 'UNIT_POWER_BAR_SHOW', Path)
		oUF:UnregisterEvent(self, 'UNIT_POWER_FREQUENT', Path)
		oUF:UnregisterEvent(self, 'UNIT_POWER_UPDATE', Path)
		oUF:UnregisterEvent(self, 'UNIT_CONNECTION', ColorPath)
		oUF:UnregisterEvent(self, 'UNIT_FACTION', ColorPath)
		oUF:UnregisterEvent(self, 'UNIT_FLAGS', ColorPath)
		oUF:UnregisterEvent(self, 'UNIT_THREAT_LIST_UPDATE', ColorPath)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)
