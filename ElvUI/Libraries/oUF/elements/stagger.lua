--[[ Element: Monk Stagger Bar

 Handles updating and visibility of the monk's stagger bar.

 Widget

 Stagger - A StatusBar

 Sub-Widgets

 .bg - A Texture that functions as a background. It will inherit the color
       of the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
 status bar texture or color defined.

 In order to override the internal update define the 'OnUpdate' script on the
 widget in the layout

 Sub-Widgets Options

 .multiplier - Defines a multiplier, which is used to tint the background based
               on the main widgets R, G and B values. Defaults to 1 if not
               present.

 Examples

   local Stagger = CreateFrame('StatusBar', nil, self)
   Stagger:SetSize(120, 20)
   Stagger:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, 0)

   -- Register with oUF
   self.Stagger = Stagger

 Hooks

 OverrideVisibility(self) - Used to completely override the internal visibility
                            function. Removing the table key entry will make
                            the element fall-back to its internal function
                            again.
 Override(self)           - Used to completely override the internal
                            update function. Removing the table key entry will
                            make the element fall-back to its internal function
                            again.
]]

local parent, ns = ...
local oUF = ns.oUF

-- percentages at which the bar should change color
local STAGGER_YELLOW_TRANSITION = STAGGER_YELLOW_TRANSITION
local STAGGER_RED_TRANSITION = STAGGER_RED_TRANSITION

-- table indices of bar colors
local STAGGER_GREEN_INDEX = STAGGER_GREEN_INDEX or 1
local STAGGER_YELLOW_INDEX = STAGGER_YELLOW_INDEX or 2
local STAGGER_RED_INDEX = STAGGER_RED_INDEX or 3

local UnitHealthMax = UnitHealthMax
local UnitStagger = UnitStagger

local _, playerClass = UnitClass("player")
local color

local Update = function(self, event, unit)
	if unit and unit ~= self.unit then return end
	local element = self.Stagger

	if(element.PreUpdate) then
		element:PreUpdate()
	end


	local maxHealth = UnitHealthMax("player")
	local stagger = UnitStagger("player") or 0 --For some reason stagger sometimes is nil
	local staggerPercent = stagger / maxHealth

	element:SetMinMaxValues(0, maxHealth)
	element:SetValue(stagger)

	local rgb
	if(staggerPercent >= STAGGER_RED_TRANSITION) then
		rgb = color[STAGGER_RED_INDEX]
	elseif(staggerPercent > STAGGER_YELLOW_TRANSITION) then
		rgb = color[STAGGER_YELLOW_INDEX]
	else
		rgb = color[STAGGER_GREEN_INDEX]
	end

	local r, g, b = rgb[1], rgb[2], rgb[3]
	element:SetStatusBarColor(r, g, b)

	local bg = element.bg
	if(bg) then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if(element.PostUpdate) then
		element:PostUpdate(maxHealth, stagger, staggerPercent, r, g, b)
	end
end

local Path = function(self, ...)
	return (self.Stagger.Override or Update)(self, ...)
end

local Visibility = function(self, event, unit)
	local isShown = self.Stagger:IsShown()
	local stateChanged = false
	if(SPEC_MONK_BREWMASTER ~= GetSpecialization() or UnitHasVehiclePlayerFrameUI('player')) then
		if isShown then
			self.Stagger:Hide()
			self:UnregisterEvent('UNIT_AURA', Path)
			stateChanged = true
		end
		
		if(self.Stagger.PostUpdateVisibility) then
			self.Stagger.PostUpdateVisibility(self, event, unit, false, stateChanged)
		end
	else
		if(not isShown) then
			self.Stagger:Show()
			self:RegisterEvent('UNIT_AURA', Path)
			stateChanged = true
		end
		
		if(self.Stagger.PostUpdateVisibility) then
			self.Stagger.PostUpdateVisibility(self, event, unit, true, stateChanged)
		end

		return Path(self, event, unit)
	end
end

local VisibilityPath = function(self, ...)
	return (self.Stagger.OverrideVisibility or Visibility)(self, ...)
end

local ForceUpdate = function(element)
	return VisibilityPath(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self, unit)
	if(playerClass ~= "MONK") then return end

	local element = self.Stagger
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element:Hide()

		color = self.colors.power[BREWMASTER_POWER_BAR_NAME]

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:RegisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath, true)

		if(element:IsObjectType'StatusBar' and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		MonkStaggerBar:UnregisterEvent'PLAYER_ENTERING_WORLD'
		MonkStaggerBar:UnregisterEvent'PLAYER_SPECIALIZATION_CHANGED'
		MonkStaggerBar:UnregisterEvent'UNIT_DISPLAYPOWER'
		MonkStaggerBar:UnregisterEvent'UPDATE_VEHICLE_ACTION_BAR'

		return true
	end
end

local Disable = function(self)
	local element = self.Stagger
	if(element) then
		element:Hide()
		self:UnregisterEvent('UNIT_AURA', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:UnregisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath)

		MonkStaggerBar:UnregisterEvent'PLAYER_ENTERING_WORLD'
		MonkStaggerBar:UnregisterEvent'PLAYER_SPECIALIZATION_CHANGED'
		MonkStaggerBar:UnregisterEvent'UNIT_DISPLAYPOWER'
		MonkStaggerBar:UnregisterEvent'UPDATE_VEHICLE_ACTION_BAR'
	end
end

oUF:AddElement("Stagger", VisibilityPath, Enable, Disable)
