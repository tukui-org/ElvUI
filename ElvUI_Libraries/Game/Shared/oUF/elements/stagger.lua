--[[
# Element: Monk Stagger Bar

Handles the visibility and updating of the Monk's stagger bar.

## Widget

Stagger - A `StatusBar` used to represent the current stagger level.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.smoothing - Which smoothing method to use, defaults to Enum.StatusBarInterpolation.Immediate (number)

## Examples

    local Stagger = CreateFrame('StatusBar', nil, self)
    Stagger:SetSize(120, 20)
    Stagger:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, 0)

    -- Register with oUF
    self.Stagger = Stagger
--]]

local _, ns = ...
local oUF = ns.oUF

local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local UnitHasVehiclePlayerFrameUI = UnitHasVehiclePlayerFrameUI
local UnitHealthMax = UnitHealthMax
local UnitStagger = UnitStagger
local UnitIsUnit = UnitIsUnit
local wipe = wipe

local StatusBarInterpolation = Enum.StatusBarInterpolation

-- sourced from Blizzard_FrameXMLBase/Constants.lua
local SPEC_MONK_BREWMASTER = SPEC_MONK_BREWMASTER or 1
local BREWMASTER_POWER_BAR_NAME = 'STAGGER'

-- percentages at which bar should change color
local STAGGER_YELLOW_TRANSITION =  STAGGER_YELLOW_TRANSITION or 0.3
local STAGGER_RED_TRANSITION = STAGGER_RED_TRANSITION or 0.6

-- table indices of bar colors
local STAGGER_GREEN_INDEX = STAGGER_GREEN_INDEX or 1
local STAGGER_YELLOW_INDEX = STAGGER_YELLOW_INDEX or 2
local STAGGER_RED_INDEX = STAGGER_RED_INDEX or 3

local function UpdateColor(self, event, unit)
	if(unit and unit ~= self.unit) then return end
	local element = self.Stagger

	local colors = self.colors.power[BREWMASTER_POWER_BAR_NAME]
	local perc = (element.cur or 0) / (element.max or 1)

	local color
	if(perc >= STAGGER_RED_TRANSITION) then
		color = colors and colors[STAGGER_RED_INDEX]
	elseif(perc > STAGGER_YELLOW_TRANSITION) then
		color = colors and colors[STAGGER_YELLOW_INDEX]
	else
		color = colors and colors[STAGGER_GREEN_INDEX]
	end

	if(color) then
		element:GetStatusBarTexture():SetVertexColor(color:GetRGB())
	end

	--[[ Callback: Stagger:PostUpdateColor(color)
	Called after the element color has been updated.

	* self  - the Stagger element
	* color - the used ColorMixin-based object (table?)
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, color)
	end
end

local staggerCache = {}
local staggerID = {
	[124275] = true, -- [GREEN]  Light Stagger
	[124274] = true, -- [YELLOW] Moderate Stagger
	[124273] = true, -- [RED]    Heavy Stagger
}

local function verifyStagger(frame, event, unit, auraInstanceID, aura)
	if aura and staggerID[aura.spellId] then
		staggerCache[auraInstanceID] = aura
		return true -- added or updated
	elseif staggerCache[auraInstanceID] then
		staggerCache[auraInstanceID] = nil
		return true -- removed
	end
end

local function Update(self, event, unit, updateInfo)
	if oUF:ShouldSkipAuraUpdate(self, event, unit, updateInfo, not oUF.isRetail and verifyStagger or nil) then return end

	local element = self.Stagger

	--[[ Callback: Stagger:PreUpdate()
	Called before the element has been updated.

	* self - the Stagger element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	-- Blizzard code has nil checks for UnitStagger return
	local cur = UnitStagger('player') or 0
	local max = UnitHealthMax('player')

	element:SetMinMaxValues(0, max)
	element:SetValue(cur, element.smoothing)

	element.cur = cur
	element.max = max

	--[[ Callback: Stagger:PostUpdate(cur, max)
	Called after the element has been updated.

	* self - the Stagger element
	* cur  - the amount of staggered damage (number)
	* max  - the player's maximum possible health value (number)
	--]]
	if(element.PostUpdate) then
		element:PostUpdate(cur, max)
	end
end

local function Path(self, ...)
	--[[ Override: Stagger.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Stagger.Override or Update)(self, ...);

	--[[ Override: Stagger.UpdateColor(self, event, unit)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Stagger.UpdateColor or UpdateColor) (self, ...)
end

-- ElvUI changed
local function Visibility(self, event, unit)
	local element = self.Stagger
	local isShown = element:IsShown()
	local useClassbar = (SPEC_MONK_BREWMASTER ~= GetSpecialization()) or UnitHasVehiclePlayerFrameUI('player')
	local stateChanged = false

	if useClassbar and isShown then
		element:Hide()
		self:UnregisterEvent('UNIT_AURA', Path)
		stateChanged = true
	elseif not useClassbar and not isShown then
		element:Show()
		self:RegisterEvent('UNIT_AURA', Path)
		stateChanged = true
	end

	if stateChanged or event == 'PLAYER_ENTERING_WORLD' then
		wipe(staggerCache)
	end

	if element.PostVisibility then
		element.PostVisibility(self, event, unit, not useClassbar, stateChanged)
	end

	if not useClassbar then
		Path(self, event, unit)
	end
end
-- end block

local function VisibilityPath(self, ...)
	--[[ Override: Stagger.OverrideVisibility(self, event, unit)
	Used to completely override the internal visibility toggling function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Stagger.OverrideVisibility or Visibility)(self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Disable(self)
	local element = self.Stagger
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_AURA', Path)
		self:UnregisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

local function Enable(self, unit)
	if oUF.myclass ~= 'MONK' then
		Disable(self)

		return false
	end

	local element = self.Stagger
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(not element.smoothing) then
			element.smoothing = StatusBarInterpolation.Immediate
		end

		self:RegisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath, true)
		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		-- do not change this without taking Visibility into account
		element:Hide()

		return true
	end
end

oUF:AddElement('Stagger', VisibilityPath, Enable, Disable)
