--[[
# Element: Power Bar

Handles the updating of a status bar that displays the unit's power.

## Widget

Power - A `StatusBar` used to represent the unit's power.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture or a color set.

## Options

.displayAltPower                  - Use this to let the widget display alternative power, if the unit has one.
                                    By default, it does so only for raid and party units. If none, the display will fall
                                    back to the primary power (boolean)
.useAtlas                         - Use this to let the widget use an atlas for its texture if an atlas is present in
                                    `self.colors.power` for the appropriate power type (boolean)
.considerSelectionInCombatHostile - Indicates whether selection should be considered hostile while the unit is in
                                    combat with the player (boolean)
.smoothing                        - Which status bar smoothing method to use, defaults to `Enum.StatusBarInterpolation.Immediate` (number)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorDisconnected - Use `self.colors.disconnected` to color the bar if the unit is offline (boolean)
.colorTapping      - Use `self.colors.tapping` to color the bar if the unit isn't tapped by the player (boolean)
.colorThreat       - Use `self.colors.threat[threat]` to color the bar based on the unit's threat status. `threat` is
                     defined by the first return of [UnitThreatSituation](https://warcraft.wiki.gg/wiki/API_UnitThreatSituation) (boolean)
.colorPower        - Use `self.colors.power[token]` to color the bar based on the unit's power type. This method will
                     fall-back to `:GetAlternativeColor()` if it can't find a color matching the token. If this function
                     isn't defined, then it will attempt to color based upon the alternative power colors returned by
                     [UnitPowerType](https://warcraft.wiki.gg/wiki/API_UnitPowerType). If these aren't
                     defined, then it will attempt to color the bar based upon `self.colors.power[type]`. In case of
                     failure it'll default to `self.colors.power.MANA` (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](https://warcraft.wiki.gg/wiki/API_UnitClass) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorClassPet     - Use `self.colors.class[class]` to color the bar if the unit is player controlled, but not a player
                     (boolean)
.colorSelection    - Use `self.colors.selection[selection]` to color the bar based on the unit's selection color.
                     `selection` is defined by the return value of Private.unitSelectionType, a wrapper function
                     for [UnitSelectionType](https://warcraft.wiki.gg/wiki/API_UnitSelectionType) (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](https://warcraft.wiki.gg/wiki/API_UnitReaction) (boolean)

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

local unpack = unpack

local UnitClass = UnitClass
local UnitInParty = UnitInParty
local UnitPowerPercent = UnitPowerPercent
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitInRaid = UnitInRaid
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitPlayerControlled = UnitPlayerControlled
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local UnitThreatSituation = UnitThreatSituation
local GetUnitPowerBarInfo = GetUnitPowerBarInfo

-- sourced from Blizzard_UnitFrame/UnitPowerBarAlt.lua
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local StatusBarInterpolation = Enum.StatusBarInterpolation

--[[ Override: Power:GetDisplayPower(unit)
Used to get info on the unit's alternative power, if any.
Should return the power type index (see [Enum.PowerType.Alternate](https://warcraft.wiki.gg/wiki/Enum.PowerType))
and the minimum value for the given power type (see [info.minPower](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarInfo))
or nil if the unit has no alternative (alternate) power or it should not be
displayed. In case of a nil return, the element defaults to the primary power
type and zero for the minimum value.

* self - the Power element
* unit - the unit for which the update has been triggered (string)
--]]
local function GetDisplayPower(_, unit)
	local barInfo = GetUnitPowerBarInfo(unit)
	if(barInfo and barInfo.showOnRaid and (UnitInParty(unit) or UnitInRaid(unit))) then
		return ALTERNATE_POWER_INDEX, barInfo.minPower
	end
end

local function UpdateColor(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.Power

	local isPlayer = UnitIsPlayer(unit) or (oUF.isRetail and UnitInPartyIsAI(unit))

	local r, g, b, color, atlas
	if(element.colorDisconnected and not UnitIsConnected(unit)) then
		color = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		color = self.colors.tapped
	elseif(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		color =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorPower) then
		local pType, pToken, altR, altG, altB = UnitPowerType(unit)
		if(element.displayType) then
			color = self.colors.power[element.displayType]
		end

		if(not color) then
			color = self.colors.power[pToken]

			if(element.GetAlternativeColor) then
				r, g, b = element:GetAlternativeColor(unit, pType, pToken, altR, altG, altB)
			elseif(not color and altR) then
				r, g, b = altR, altG, altB
				if(r > 1 or g > 1 or b > 1) then
					-- BUG: As of 7.0.3, altR, altG, altB may be in 0-1 or 0-255 range.
					r, g, b = r / 255, g / 255, b / 255
				end
			else
				color = self.colors.power[pType] or self.colors.power.MANA
			end
		end

		if(element.useAtlas and color and color.atlas) then
			atlas = color.atlas
		elseif(element.colorPowerAtlas and color) then
			atlas = color:GetAtlas()
		end

		if(element.colorPowerSmooth) then
			if oUF.isRetail then
				local curve = color and color:GetCurve()
				if curve then
					color = UnitPowerPercent(unit, true, curve)
				end
			else
				local adjust = 0 - (element.min or 0)
				local curValue, maxValue = (element.cur or 1) + adjust, (element.max or 1) + adjust
				r, g, b = self:ColorGradient(maxValue == 0 and 0 or (curValue / maxValue), unpack(element.smoothGradient or self.colors.smooth))
				self.colors.smooth:SetRGB(r, g, b)

				color = self.colors.smooth
			end
		end
	elseif(element.colorClass and isPlayer)
		or (element.colorClassNPC and not isPlayer)
		or (element.colorClassPet and UnitPlayerControlled(unit) and not isPlayer) then
		local _, class = UnitClass(unit)
		color = self.colors.class[class]
	elseif(element.colorSelection and unitSelectionType(unit, element.considerSelectionInCombatHostile)) then
		color = self.colors.selection[unitSelectionType(unit, element.considerSelectionInCombatHostile)]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		color = self.colors.reaction[UnitReaction(unit, 'player')]
	end

	if(atlas) then
		element:SetStatusBarTexture(atlas)
		element:GetStatusBarTexture():SetVertexColor(1, 1, 1)
	else
		if(element.__texture) then
			element:SetStatusBarTexture(element.__texture)
		end

		-- it's done this way so that only non-standard powers have r, g, b values
		if(b) then
			element:GetStatusBarTexture():SetVertexColor(r, g, b)
		elseif(color) then
			element:GetStatusBarTexture():SetVertexColor(color:GetRGB())
		end
	end

	--[[ Callback: Power:PostUpdateColor(unit, color, altR, altG, altB)
	Called after the element color has been updated.

	* self  - the Power element
	* unit  - the unit for which the update has been triggered (string)
	* color - the used ColorMixin-based object (table?)
	* altR  - the red component of the used alternative color (number?)[0-1]
	* altG  - the green component of the used alternative color (number?)[0-1]
	* altB  - the blue component of the used alternative color (number?)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, color, r, g, b)
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
		displayType, min = element:GetDisplayPower(unit)
	end

	local cur, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	if not min then min = 0 end

	element:SetMinMaxValues(min, max)

	if(UnitIsConnected(unit)) then
		element:SetValue(cur, element.smoothing)
	else
		element:SetValue(max, element.smoothing)
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
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
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
			element.__owner:RegisterEvent('PARTY_MEMBER_ENABLE', ColorPath)
			element.__owner:RegisterEvent('PARTY_MEMBER_DISABLE', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_CONNECTION', ColorPath)
			element.__owner:UnregisterEvent('PARTY_MEMBER_ENABLE', ColorPath)
			element.__owner:UnregisterEvent('PARTY_MEMBER_DISABLE', ColorPath)
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
		elseif(not element.colorReaction) then
			element.__owner:UnregisterEvent('UNIT_FACTION', ColorPath)
		end
	end
end

--[[ Power:SetColorReaction(state, isForced)
Used to toggle coloring by the unit's reaction.

* self     - the Power element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorReaction(element, state, isForced)
	if(element.colorReaction ~= state or isForced) then
		element.colorReaction = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_FACTION', ColorPath)
		elseif(not element.colorTapping) then
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

local function Enable(self)
	local element = self.Power
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetColorDisconnected = SetColorDisconnected
		element.SetColorSelection = SetColorSelection
		element.SetColorTapping = SetColorTapping
		element.SetColorReaction = SetColorReaction
		element.SetColorThreat = SetColorThreat

		if(not element.smoothing) then
			element.smoothing = StatusBarInterpolation and StatusBarInterpolation.Immediate or nil
		end

		if(element.colorDisconnected) then
			self:RegisterEvent('UNIT_CONNECTION', ColorPath)
		end

		if(element.colorSelection) then
			self:RegisterEvent('UNIT_FLAGS', ColorPath)
		end

		if(element.colorTapping or element.colorReaction) then
			self:RegisterEvent('UNIT_FACTION', ColorPath)
		end

		if(element.colorThreat) then
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end

		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(element.colorPowerAtlas) then
			element.__texture = element.__texture or element:GetStatusBarTexture():GetTexture()
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

		self:UnregisterEvent('UNIT_CONNECTION', ColorPath)
		self:UnregisterEvent('UNIT_FACTION', ColorPath)
		self:UnregisterEvent('UNIT_FLAGS', ColorPath)
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)
