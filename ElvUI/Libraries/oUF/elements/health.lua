--[[
# Element: Health Bar

Handles the updating of a status bar that displays the unit's health.

## Widget

Health - A `StatusBar` used to represent the unit's health.

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.frequentUpdates   - Indicates whether to use UNIT_HEALTH_FREQUENT instead of UNIT_HEALTH to update the bar (boolean)
.smoothGradient    - 9 color values to be used with the .colorSmooth option (table)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorTapping      - Use `self.colors.tapping` to color the bar if the unit isn't tapped by the player (boolean)
.colorDisconnected - Use `self.colors.disconnected` to color the bar if the unit is offline (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorClassPet     - Use `self.colors.class[class]` to color the bar if the unit is player controlled, but not a player
                     (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction.html) (boolean)
.colorSmooth       - Use `smoothGradient` if present or `self.colors.smooth` to color the bar with a smooth gradient
                     based on the player's current health percentage (boolean)
.colorHealth       - Use `self.colors.health` to color the bar. This flag is used to reset the bar color back to default
                     if none of the above conditions are met (boolean)

## Sub-Widgets Options

.multiplier - Used to tint the background based on the main widgets R, G and B values. Defaults to 1 (number)[0-1]

## Attributes

.disconnected - Indicates whether the unit is disconnected (boolean)

## Examples

    -- Position and size
    local Health = CreateFrame('StatusBar', nil, self)
    Health:SetHeight(20)
    Health:SetPoint('TOP')
    Health:SetPoint('LEFT')
    Health:SetPoint('RIGHT')

    -- Add a background
    local Background = Health:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Health)
    Background:SetTexture(1, 1, 1, .5)

    -- Options
    Health.frequentUpdates = true
    Health.colorTapping = true
    Health.colorDisconnected = true
    Health.colorClass = true
    Health.colorReaction = true
    Health.colorHealth = true

    -- Make the background darker.
    Background.multiplier = .5

    -- Register it with oUF
	Health.bg = Background
    self.Health = Health
--]]

local _, ns = ...
local oUF = ns.oUF
local updateFrequentUpdates -- ElvUI

local function UpdateColor(element, unit, cur, max)
	local parent = element.__owner

	-- ElvUI block
	if element.frequentUpdates ~= element.__frequentUpdates then
		element.__frequentUpdates = element.frequentUpdates
		updateFrequentUpdates(parent)
	end
	-- end block

	local r, g, b, t
	if(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = parent.colors.tapped
	elseif(element.colorDisconnected and element.disconnected) then
		t = parent.colors.disconnected
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = parent.colors.class[class]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		t = parent.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		r, g, b = parent:ColorGradient(cur, max, unpack(element.smoothGradient or parent.colors.smooth))
	elseif(element.colorHealth) then
		t = parent.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(r or g or b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	--[[ Callback: Health:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Health element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	element:SetMinMaxValues(0, max)

	if(disconnected) then
		element:SetValue(max)
	else
		element:SetValue(cur)
	end

	element.disconnected = disconnected

	--[[ Override: Health:UpdateColor(unit, cur, max)
	Used to completely override the internal function for updating the widgets' colors.

	* self - the Health element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the unit's current health value (number)
	* max  - the unit's maximum possible health value (number)
	--]]
	element:UpdateColor(unit, cur, max)

	--[[ Callback: Health:PostUpdate(unit, cur, max)
	Called after the element has been updated.

	* self - the Health element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the unit's current health value (number)
	* max  - the unit's maximum possible health value (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	--[[ Override: Health.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.Health.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

-- ElvUI block
function updateFrequentUpdates(self)
	local health = self.Health
	if health.frequentUpdates and not self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
		if GetCVarBool("predictedHealth") ~= true then
			SetCVar("predictedHealth", "1")
		end

		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)

		if self:IsEventRegistered("UNIT_HEALTH") then
			self:UnregisterEvent("UNIT_HEALTH", Path)
		end
	elseif not self:IsEventRegistered("UNIT_HEALTH") then
		self:RegisterEvent('UNIT_HEALTH', Path)

		if self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Path)
		end
	end
end
-- end block

local function Enable(self, unit)
	local element = self.Health
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		-- ElvUI block
		element.__frequentUpdates = element.frequentUpdates
		updateFrequentUpdates(self)
		-- end block

		if(element.frequentUpdates) then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		else
			self:RegisterEvent('UNIT_HEALTH', Path)
		end

		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_FACTION', Path) -- For tapping

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Health
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Health', Path, Enable, Disable)
