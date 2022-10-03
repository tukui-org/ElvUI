--[[
# Element: Alternative Power Bar

Handles the visibility and updating of a status bar that displays encounter- or quest-related power information, such as
the number of hour glass charges during the Murozond encounter in the dungeon End Time.

## Widget

AlternativePower - A `StatusBar` used to represent the unit's alternative power.

## Notes

If mouse interactivity is enabled for the widget, `OnEnter` and/or `OnLeave` handlers will be set to display a tooltip.
A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.smoothGradient                   - 9 color values to be used with the .colorSmooth option (table)
.considerSelectionInCombatHostile - Indicates whether selection should be considered hostile while the unit is in
                                    combat with the player (boolean)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorThreat       - Use `self.colors.threat[threat]` to color the bar based on the unit's threat status. `threat` is
                     defined by the first return of [UnitThreatSituation](https://wow.gamepedia.com/API_UnitThreatSituation) (boolean)
.colorPower        - Use `self.colors.power[token]` to color the bar based on the unit's alternative power type
                     (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorSelection    - Use `self.colors.selection[selection]` to color the bar based on the unit's selection color.
                     `selection` is defined by the return value of Private.unitSelectionType, a wrapper function
                     for [UnitSelectionType](https://wow.gamepedia.com/API_UnitSelectionType) (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction.html) (boolean)
.colorSmooth       - Use `self.colors.smooth` to color the bar with a smooth gradient based on the unit's current
                     alternative power percentage (boolean)

## Examples

    -- Position and size
    local AlternativePower = CreateFrame('StatusBar', nil, self)
    AlternativePower:SetHeight(20)
    AlternativePower:SetPoint('BOTTOM')
    AlternativePower:SetPoint('LEFT')
    AlternativePower:SetPoint('RIGHT')

    -- Register with oUF
    self.AlternativePower = AlternativePower
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitSelectionType = Private.unitSelectionType

-- sourced from FrameXML/UnitPowerBarAlt.lua
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local ALTERNATE_POWER_NAME = 'ALTERNATE'
local GameTooltip = GameTooltip

local function updateTooltip(self)
	if GameTooltip:IsForbidden() then return end

	local name, tooltip = GetUnitPowerBarStringsByID(self.__barID)
	GameTooltip:SetText(name or '', 1, 1, 1)
	GameTooltip:AddLine(tooltip or '', nil, nil, nil, true)
	GameTooltip:Show()
end

local function onEnter(self)
	if GameTooltip:IsForbidden() or not self:IsVisible() then return end

	GameTooltip:ClearAllPoints()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:UpdateTooltip()
end

local function onLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local function UpdateColor(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= ALTERNATE_POWER_NAME) then return end
	local element = self.AlternativePower

	local r, g, b, color
	if(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		color =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorPower) then
		color = self.colors.power[ALTERNATE_POWER_INDEX]
	elseif(element.colorClass and UnitIsPlayer(unit))
		or (element.colorClassNPC and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		color = self.colors.class[class]
	elseif(element.colorSelection and unitSelectionType(unit, element.considerSelectionInCombatHostile)) then
		color = self.colors.selection[unitSelectionType(unit, element.considerSelectionInCombatHostile)]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		color = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		local adjust = 0 - (element.min or 0)
		r, g, b = self:ColorGradient((element.cur or 1) + adjust, (element.max or 1) + adjust, unpack(element.smoothGradient or self.colors.smooth))
	end

	if(color) then
		r, g, b = color[1], color[2], color[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	--[[ Callback: AlternativePower:PostUpdateColor(unit, r, g, b)
	Called after the element color has been updated.

	* self - the AlternativePower element
	* unit - the unit for which the update has been triggered (string)
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= ALTERNATE_POWER_NAME) then return end
	local element = self.AlternativePower

	--[[ Callback: AlternativePower:PreUpdate()
	Called before the element has been updated.

	* self - the AlternativePower element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local min, max, cur = 0
	local barInfo = element.__barInfo
	if(barInfo) then
		cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
		max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

		if barInfo.minPower then
			min = barInfo.minPower
		end

		element:SetMinMaxValues(min, max)
		element:SetValue(cur)
	end

	element.cur = cur
	element.min = min
	element.max = max

	--[[ Callback: AlternativePower:PostUpdate(unit, cur, min, max)
	Called after the element has been updated.

	* self - the AlternativePower element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the current value of the unit's alternative power (number?)
	* min  - the minimum value of the unit's alternative power (number?)
	* max  - the maximum value of the unit's alternative power (number?)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, min, max)
	end
end

local function Path(self, ...)
	--[[ Override: AlternativePower.Override(self, event, unit, ...)
	Used to completely override the element's update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AlternativePower.Override or Update) (self, ...);

	--[[ Override: AlternativePower.UpdateColor(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AlternativePower.UpdateColor or UpdateColor) (self, ...)
end

local function Visibility(self, event, unit)
	if(unit ~= self.unit) then return end
	local element = self.AlternativePower

	local barID = UnitPowerBarID(unit)
	local barInfo = GetUnitPowerBarInfoByID(barID)
	element.__barID = barID
	element.__barInfo = barInfo
	if(barInfo and (barInfo.showOnRaid and (UnitInParty(unit) or UnitInRaid(unit))
		or not barInfo.hideFromOthers
		or UnitIsUnit(unit, 'player')))
	then
		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		element:Show()
		Path(self, event, unit, ALTERNATE_POWER_NAME)
	else
		self:UnregisterEvent('UNIT_POWER_UPDATE', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

		element:Hide()
		Path(self, event, unit, ALTERNATE_POWER_NAME)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: AlternativePower.OverrideVisibility(self, event, unit)
	Used to completely override the element's visibility update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.AlternativePower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AlternativePower
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', VisibilityPath)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not (element:GetStatusBarTexture() or element:GetStatusBarAtlas())) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(element:IsMouseEnabled()) then
			if(not element:GetScript('OnEnter')) then
				element:SetScript('OnEnter', onEnter)
			end

			if(not element:GetScript('OnLeave')) then
				element:SetScript('OnLeave', onLeave)
			end

			--[[ Override: AlternativePower:UpdateTooltip()
			Called when the mouse is over the widget. Used to populate its tooltip.

			* self - the AlternativePower element
			--]]
			if(not element.UpdateTooltip) then
				element.UpdateTooltip = updateTooltip
			end
		end

		if(unit == 'player') then
			PlayerPowerBarAlt:UnregisterEvent('UNIT_POWER_BAR_SHOW')
			PlayerPowerBarAlt:UnregisterEvent('UNIT_POWER_BAR_HIDE')
			PlayerPowerBarAlt:UnregisterEvent('PLAYER_ENTERING_WORLD')
		end

		return true
	end
end

local function Disable(self, unit)
	local element = self.AlternativePower
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', VisibilityPath)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', VisibilityPath)

		if(unit == 'player') then
			PlayerPowerBarAlt:RegisterEvent('UNIT_POWER_BAR_SHOW')
			PlayerPowerBarAlt:RegisterEvent('UNIT_POWER_BAR_HIDE')
			PlayerPowerBarAlt:RegisterEvent('PLAYER_ENTERING_WORLD')
		end
	end
end

oUF:AddElement('AlternativePower', VisibilityPath, Enable, Disable)
